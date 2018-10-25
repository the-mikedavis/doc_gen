module LiveTags exposing (..)

import Platform.Cmd exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline
import Task
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Array


---- MODEL ----


type alias Tag =
    { name : String
    , weight : Int
    , active : Bool
    }


decodeTag : Decode.Decoder Tag
decodeTag =
    Json.Decode.Pipeline.decode Tag
        |> Json.Decode.Pipeline.required "name" (Decode.string)
        |> Json.Decode.Pipeline.required "weight" (Decode.int)
        |> Json.Decode.Pipeline.required "active" (Decode.bool)


tagListDecoder : Decode.Decoder (List Tag)
tagListDecoder =
    Decode.list decodeTag


type alias Flags =
    { id : Int
    , uri : String
    }


type alias Model =
    { tags : List Tag
    , tagInProgress : String
    , phxSocket : Phoenix.Socket.Socket Msg
    , videoId : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        { uri, id } =
            flags

        channel =
            Phoenix.Channel.init "tag:lobby"

        initSocket =
            Phoenix.Socket.init uri
                |> Phoenix.Socket.on "new_tag" "tag:lobby" AddTag

        model =
            { tags = []
            , tagInProgress = ""
            , phxSocket = initSocket
            , videoId = id
            }
    in
        ( model, joinChannel )



---- UPDATE ----


type Msg
    = StartTag String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | AddTag Encode.Value
    | PopulateTags Encode.Value
    | HandleSendError Encode.Value
    | JoinChannel
    | DeleteTag Tag
    | RemoveTag Encode.Value
    | ToggleTag Tag
    | KeyDown Int


createTag : String -> Tag
createTag name =
    { name = name
    , active = True
    , weight = 1
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )

        StartTag tag ->
            ( { model | tagInProgress = tag }, Cmd.none )

        AddTag raw ->
            let
                msg =
                    Decode.decodeValue (Decode.field "name" Decode.string) raw
            in
                case msg of
                    Ok new_tag ->
                        ( { model | tags = (createTag new_tag) :: model.tags }, Cmd.none )

                    Err error ->
                        ( model, Cmd.none )

        HandleSendError _ ->
            ( model, Cmd.none )

        JoinChannel ->
            let
                payload =
                    (Encode.object [ ( "video_id", Encode.int model.videoId ) ])

                channel =
                    Phoenix.Channel.init "tag:lobby"
                        |> Phoenix.Channel.withPayload payload
                        |> Phoenix.Channel.onJoin PopulateTags

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        PopulateTags raw ->
            let
                msg =
                    Decode.decodeValue (Decode.field "tags" tagListDecoder) raw
            in
                case msg of
                    Ok message ->
                        ( { model | tags = message }, Cmd.none )

                    Err error ->
                        ( model, Cmd.none )

        DeleteTag tag ->
            let
                payload =
                    Encode.object
                        [ ( "name", Encode.string tag.name )
                        ]

                phxPush =
                    Phoenix.Push.init "delete_tag" "tag:lobby"
                        |> Phoenix.Push.withPayload payload
                        |> Phoenix.Push.onOk RemoveTag
                        |> Phoenix.Push.onError HandleSendError

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push phxPush model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        RemoveTag raw ->
            let
                msg =
                    Decode.decodeValue (Decode.field "name" Decode.string) raw
            in
                case msg of
                    Ok tag ->
                        ( { model | tags = List.filter (\t -> t.name /= tag) model.tags }
                        , Cmd.none
                        )

                    Err error ->
                        ( model, Cmd.none )

        ToggleTag tag ->
            let
                tags =
                    List.map
                        (\t ->
                            if t.name == tag.name then
                                { t | active = not t.active }
                            else
                                t
                        )
                        model.tags
            in
                ( { model | tags = tags }, Cmd.none )

        KeyDown key ->
            if key == 13 then
                let
                    payload =
                        Encode.object
                            [ ( "name", Encode.string model.tagInProgress )
                            ]

                    phxPush =
                        Phoenix.Push.init "new_tag" "tag:lobby"
                            |> Phoenix.Push.withPayload payload
                            |> Phoenix.Push.onOk AddTag
                            |> Phoenix.Push.onError HandleSendError

                    ( phxSocket, phxCmd ) =
                        Phoenix.Socket.push phxPush model.phxSocket
                in
                    ( { model | phxSocket = phxSocket, tagInProgress = "" }
                    , Cmd.map PhoenixMsg phxCmd
                    )
            else
                ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


joinChannel : Cmd Msg
joinChannel =
    Task.succeed JoinChannel
        |> Task.perform identity


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Decode.map tagger keyCode)



---- VIEW ----


drawTag : Tag -> Html Msg
drawTag tag =
    div [ attribute "class" "w-1/2 md:w-1/4 lg:w-1/5 px-1"
        , onClick (ToggleTag tag)
        ]
        [ div
            [ classList [
                ("bg-blue-darker", not tag.active),
                ("bg-blue", tag.active),
                ("py-4", True),
                ("px-3", True),
                ("my-1", True),
                ("shadow-md", True),
                ("text-white", True),
                ("text-sm", True),
                ("font-bold", True),
                ("tag-body", True)
              ]
            ]
            [ input
                [ attribute "id" tag.name
                , attribute "name" ("video[" ++ (toString tag.name) ++ "]")
                , attribute "class" "tag-checkbox"
                , type_ "checkbox"
                , checked tag.active
                ]
                []
            , span [ attribute "class" "px-1" ]
                [ text tag.name ]
            , i
                [ attribute "class" "fas fa-times close-button text-teal px-1"
                , onClick (DeleteTag tag)
                ]
                []
            ]
        ]


view : Model -> Html Msg
view model =
    let
        drawTags tags =
            tags
                |> List.sortBy (\t -> t.name)
                |> List.map drawTag
    in
        div [ attribute "class" "w-full" ]
            [ div
                [ attribute "class" "flex flex-wrap -mx-2 pr-2"
                ]
                (drawTags model.tags)
            , div
                [ attribute "class" "border-b border-b-2 border-blue-dark my-4 py-2 w-1/2"
                ]
                [ input
                    [ attribute "placeholder" "Create a New Tag"
                    , attribute "class" "appearance-none bg-transparent border-none w-full text-grey-darker mr-3 py-1 px-2 leading-tight focus:outline-none"
                    , onInput StartTag
                    , onKeyDown KeyDown
                    , value model.tagInProgress
                    ]
                    []
                ]
            ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
