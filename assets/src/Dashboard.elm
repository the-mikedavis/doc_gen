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


type alias Flags =
    { uri : String
    , token : String
    }

type alias Model =
    { videos : List Video
    , visibleVideos : List Video
    , phxSocket : Phoenix.Socket.Socket Msg
    , searchString : String
    , editId : Maybe Int
    , shownVideo : Maybe Video
    , csrfToken : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        channel =
            Phoenix.Channel.init "video:lobby"

        initSocket =
            Phoenix.Socket.init flags.uri

        model =
            { videos = []
            , visibleVideos = []
            , phxSocket = initSocket
            , searchString = ""
            , editId = Nothing
            , shownVideo = Nothing
            , csrfToken = flags.token
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
    | ShowVideo Video
    | CloseEdit Int
    | CloseShow


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

        ShowVideo video ->
            case model.shownVideo of
                Nothing ->
                    ( { model | shownVideo = Just video }, Cmd.none )

                Just anotherVideo ->
                    if anotherVideo == video then
                        ( { model | shownVideo = Nothing }, Cmd.none )
                    else
                        ( { model | shownVideo = Just video }, Cmd.none )

        CloseEdit _ ->
            let
                phxPush =
                    Phoenix.Push.init "videos" "video:lobby"
                        |> Phoenix.Push.onOk PopulateVideos
                        |> Phoenix.Push.onError HandleSendError

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push phxPush model.phxSocket
            in
                ( { model | phxSocket = phxSocket, editId = Nothing }
                , Cmd.map PhoenixMsg phxCmd
                )

        CloseShow ->
            ( { model | shownVideo = Nothing }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg


joinChannel : Cmd Msg
joinChannel =
    Task.succeed JoinChannel
        |> Task.perform identity



---- VIEW ----


drawControls : Video -> String -> Html Msg
drawControls video token =
    let
        deleteUri =
          "/admin/videos/" ++ (toString video.id)
    in
        div [ attribute "class" "dashboard-controls flex justify-center pb-4" ]
            [ i
                [ attribute "class" "fas fa-pencil-alt bg-grey-light hover:bg-grey text-grey-darkest font-bold rounded-full p-3 mx-4 shadow-md"
                , onClick (EditVideo video)
                ]
                []
            , i
                [ attribute "class" "far fa-eye bg-grey-light hover:bg-grey text-grey-darkest font-bold rounded-full p-3 mx-4 shadow-md"
                , onClick (ShowVideo video)
                ]
                []
            , a
                [ attribute "class" "dashboard-edit-link bg-grey-light hover:bg-grey text-grey-darkest font-bold rounded-full p-3 mx-4 shadow-md"
                , attribute "href" deleteUri
                , attribute "data-to" deleteUri
                , attribute "data-method" "delete"
                , attribute "data-confirm" "Are you sure?"
                , attribute "data-csrf" token
                ]
                [ i
                    [ attribute "class" "fas fa-trash-alt" ]
                    []
                ]
            ]


drawContent : Video -> Html Msg
drawContent video =
    div [ attribute "class" "py-3 px-3" ]
        [ p []
            [ span [ attribute "class" "inline-block text-blue-dark text-sm font-bold mb-1 mr-2" ]
                [ text "Title" ]
            , text video.title
            ]
        , p []
            [ span [ attribute "class" "inline-block text-blue-dark text-sm font-bold mb-1 mr-2" ]
                [ text "Interviewee" ]
            , text video.interviewee
            ]
        , p []
            [ span [ attribute "class" "inline-block text-blue-dark text-sm font-bold mb-1 mr-2" ]
                [ text "Length" ]
            , text ((toString video.duration) ++ " seconds")
            ]
        , p []
            [ span [ attribute "class" "inline-block text-blue-dark text-sm font-bold mb-1 mr-2" ]
                [ text "Tags" ]
            , text (String.join ", " video.tags)
            ]
        , p []
            [ span [ attribute "class" "inline-block text-blue-dark text-sm font-bold mb-1 mr-2" ]
                [ text "Segment" ]
            , text video.segment
            ]
        , p []
            [ span [ attribute "class" "inline-block text-blue-dark text-sm font-bold mb-1 mr-2" ]
                [ text "Type" ]
            , text video.clip_type
            ]
        ]


drawVideo : Video -> String -> Html Msg
drawVideo video token =
    div
        [ attribute "class" "w-1/2 lg:w-1/3 py-2 px-2"
        ]
        [ div
            [ attribute "class" "bg-white shadow-md rounded video-panel overflow-hidden" ]
            [ img
                [ attribute "src" ("/thumb/" ++ (toString video.id) ++ "/jpeg")
                , attribute "class" "dashboard-preview"
                , attribute "onmouseover" "animateThumb(event)"
                , attribute "onmouseout" "stillThumb(event)"
                ]
                []
            , (drawContent video)
            , (drawControls video token)
            ]
        ]


drawSearchBar : String -> Html Msg
drawSearchBar searchString =
    div [ attribute "class" "bg-white shadow-md rounded-lg w-full p-1" ]
        [ div
            [ attribute "class" "border-b border-b-2 border-blue-dark m-2 py-2"
            ]
            [ input
                [ attribute "type" "text"
                , attribute "class" "appearance-none bg-transparent border-none w-full text-grey-darker mr-3 py-1 pl-2 pr-4 leading-tight focus:outline-none"
                , attribute "placeholder" "Search"
                , onInput StartSearch
                , value searchString
                ]
                []
            ]
        ]


drawEditPanel : Maybe Int -> Html Msg
drawEditPanel editId =
    case editId of
        Nothing ->
            div [ attribute "id" "edit-panel" ]
                []

        Just id ->
            div [ attribute "id" "edit-panel" ]
                [ div
                    [ attribute "class" "curtain"
                    ]
                    [ iframe [ attribute "src" ("/admin/videos/" ++ (toString id) ++ "/edit") ] []
                    , i
                        [ attribute "class" "fas fa-times close-btn bg-grey-light hover:bg-grey text-grey-darkest rounded-full p-3 shadow-md"
                        , onClick (CloseEdit id)
                        ]
                        []
                    ]
                ]


drawVideoPopup : Maybe Video -> Html Msg
drawVideoPopup activeVideo =
    case activeVideo of
        Nothing ->
            div [ attribute "id" "video-popout-holster" ]
                []

        Just vod ->
            div [ attribute "id" "video-popout-holster" ]
                [ div
                    [ attribute "class" "curtain"
                    ]
                    [ video
                        [ attribute "controls" "true"
                        ]
                        [ source
                            [ attribute "src" ("/stream/" ++ (toString vod.id)) ]
                            []
                        ]
                    , i
                        [ attribute "class" "fas fa-times close-btn bg-grey-light hover:bg-grey text-grey-darkest rounded-full p-3 shadow-md"
                        , onClick CloseShow
                        ]
                        []
                    ]
                ]


view : Model -> Html Msg
view model =
    let
        drawVideos videos =
            videos
                |> List.sortBy .title
                |> List.map (\v -> drawVideo v model.csrfToken)
    in
        div [ attribute "class" "" ]
            [ (drawSearchBar model.searchString)
            , (drawVideoPopup model.shownVideo)
            , (drawEditPanel model.editId)
            , div
                [ attribute "class" "flex flex-wrap -mx-2 my-2"
                ]
                (model |> searchFilter |> drawVideos)
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


main : Program Flags Model Msg
main =
    programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
