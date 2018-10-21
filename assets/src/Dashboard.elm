module Dashboard exposing (..)

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


---- MODEL ----


type alias Video =
    { segment : String
    , duration : Int
    , clip_type : String
    , id : Int
    , interviewee : String
    , path : String
    , tags : List String
    , title : String
    }


decodeVideo : Decode.Decoder Video
decodeVideo =
    Json.Decode.Pipeline.decode Video
        |> Json.Decode.Pipeline.required "segment" (Decode.string)
        |> Json.Decode.Pipeline.required "duration" (Decode.int)
        |> Json.Decode.Pipeline.required "clip_type" (Decode.string)
        |> Json.Decode.Pipeline.required "id" (Decode.int)
        |> Json.Decode.Pipeline.required "interviewee" (Decode.string)
        |> Json.Decode.Pipeline.required "path" (Decode.string)
        |> Json.Decode.Pipeline.required "tags" (Decode.list Decode.string)
        |> Json.Decode.Pipeline.required "title" (Decode.string)


videoListDecoder : Decode.Decoder (List Video)
videoListDecoder =
    Decode.list decodeVideo


type alias Model =
    { videos : List Video
    , visibleVideos : List Video
    , phxSocket : Phoenix.Socket.Socket Msg
    , searchString : String
    , editId : Maybe Int
    }


init : String -> ( Model, Cmd Msg )
init socketUri =
    let
        channel =
            Phoenix.Channel.init "video:lobby"

        initSocket =
            Phoenix.Socket.init ("ws://" ++ socketUri)
                |> Phoenix.Socket.withDebug

        model =
            { videos = []
            , visibleVideos = []
            , phxSocket = initSocket
            , searchString = ""
            , editId = Nothing
            }
    in
        ( model, joinChannel )



---- UPDATE ----


type Msg
    = PhoenixMsg (Phoenix.Socket.Msg Msg)
    | PopulateVideos Encode.Value
    | HandleSendError Encode.Value
    | JoinChannel
    | StartSearch String
    | EditVideo Video
    | CloseEdit Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )

        HandleSendError _ ->
            let
                message =
                    "Failed to Send Message"

                a =
                    Debug.log ("Failed to send message")
            in
                ( model, Cmd.none )

        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init "video:lobby"
                        |> Phoenix.Channel.onJoin PopulateVideos

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        PopulateVideos raw ->
            let
                msg =
                    Decode.decodeValue (Decode.field "videos" videoListDecoder) raw
            in
                case msg of
                    Ok message ->
                        ( { model | videos = message, visibleVideos = message }
                        , Cmd.none
                        )

                    Err error ->
                        Debug.log (error)
                            ( model, Cmd.none )

        StartSearch searchString ->
            ( { model | searchString = searchString }, Cmd.none )

        EditVideo video ->
            case model.editId of
                Nothing ->
                    ( { model | editId = Just video.id }, Cmd.none )

                Just id ->
                    if id == video.id then
                        ( { model | editId = Nothing }, Cmd.none )
                    else
                        ( { model | editId = Just id }, Cmd.none )

        CloseEdit _ ->
            ( { model | editId = Nothing }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


joinChannel : Cmd Msg
joinChannel =
    Task.succeed JoinChannel
        |> Task.perform identity



---- VIEW ----


drawVideo : Video -> Html Msg
drawVideo video =
    div [ attribute "class" "video-entry" ]
        [ img [] []
        , p []
            [ span [ attribute "class" "highlight" ]
                [ text "title: " ]
            , text video.title
            ]
        , p []
            [ span [ attribute "class" "highlight" ]
                [ text "interviewee: " ]
            , text video.interviewee
            ]
        , p []
            [ span [ attribute "class" "highlight" ]
                [ text "segment: " ]
            , text video.segment
            ]
        , p []
            [ span [ attribute "class" "highlight" ]
                [ text "length: " ]
            , text ((toString video.duration) ++ " seconds")
            ]
        , p []
            [ span [ attribute "class" "highlight" ]
                [ text "keywords: " ]
            , text (String.join ", " video.tags)
            ]
        , p []
            [ span [ attribute "class" "highlight" ]
                [ text "type: " ]
            , text video.clip_type
            ]
        , i
            [ attribute "class" "far fa-edit"
            , onClick (EditVideo video)
            ]
            []
        ]


drawSearchBar : String -> Html Msg
drawSearchBar searchString =
    div []
        [ text "Search: "
        , input
            [ attribute "type" "text"
            , onInput StartSearch
            , value searchString
            ]
            []
        ]


drawEditPanel : Maybe Int -> Html Msg
drawEditPanel editId =
    case editId of
        Nothing ->
            div [ attribute "class" "edit-panel" ]
                []

        Just id ->
            div [ attribute "class" "edit-panel" ]
                [ iframe [ attribute "src" ("/admin/videos/" ++ (toString id) ++ "/edit") ] []
                , i
                    [ attribute "class" "fas fa-times"
                    , onClick (CloseEdit id)
                    ]
                    []
                ]


view : Model -> Html Msg
view model =
    let
        drawVideos videos =
            videos
                |> List.map drawVideo
    in
        div []
            [ (drawSearchBar model.searchString)
            , (drawEditPanel model.editId)
            , div [] (model |> searchFilter |> drawVideos)
            ]



---- PROGRAM ----


allText : Video -> List String
allText video =
    let
        tagsText =
            video.tags

        titleText =
            String.words video.title

        otherTexts =
            [ video.interviewee, video.title, toString video.segment, toString video.duration, video.clip_type ]
    in
        tagsText
            ++ titleText
            ++ otherTexts
            |> List.map String.toLower


searchFilter : Model -> List Video
searchFilter model =
    model.videos
        |> List.filter (\vText -> List.any (String.contains (String.toLower model.searchString)) (allText vText))


main : Program String Model Msg
main =
    programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
