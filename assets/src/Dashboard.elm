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
  { weight : Int
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
  |> Json.Decode.Pipeline.required "weight" (Decode.int)
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
    }


init : String -> ( Model, Cmd Msg )
init socketUri =
    let
        channel =
            Phoenix.Channel.init "video:lobby"

        initSocket =
            Phoenix.Socket.init ("ws://" ++ socketUri)
                |> Phoenix.Socket.withDebug
                -- |> Phoenix.Socket.on "new_tag" "tag:lobby" AddTag

        model =
            { videos = []
            , visibleVideos = []
            , phxSocket = initSocket
            }
    in
        ( model, joinChannel )



---- UPDATE ----


type Msg
    = PhoenixMsg (Phoenix.Socket.Msg Msg)
    | PopulateVideos Encode.Value
    | HandleSendError Encode.Value
    | JoinChannel


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
                      Debug.log (toString message)
                        ( { model | videos = message, visibleVideos = message }
                        , Cmd.none )

                    Err error ->
                      Debug.log(error)
                        ( model, Cmd.none )


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
        , p [] [ span [ attribute "class" "highlight" ]
                      [ text "title: " ]
               , text video.title
               ]
        , p [] [ span [ attribute "class" "highlight" ]
                      [ text "interviewee: " ]
               , text video.interviewee
               ]
        , p [] [ span [ attribute "class" "highlight" ]
                      [ text "length: " ]
               , text ((toString video.duration) ++ " seconds")
               ]
        , p [] [ span [ attribute "class" "highlight" ]
                      [ text "keywords: " ]
               , text (String.join ", " video.tags)
               ]
        , p [] [ span [ attribute "class" "highlight" ]
                      [ text "type: " ]
               , text video.clip_type
               ]
        , i
            [ attribute "class" "fa fa-pencil-square-o"
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
            [ div [] (model.visibleVideos |> drawVideos)
            ]



---- PROGRAM ----


main : Program String Model Msg
main =
    programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
