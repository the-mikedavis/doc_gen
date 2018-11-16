port module Player exposing (..)

import Platform.Cmd exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Task
import Array exposing (Array)


---- MODEL ----


type alias Flags =
    { videos : List Int
    }


type alias Model =
    { videos : Array Int
    , currentVideo : Int
    }


init : Flags -> ( Model, Cmd Msg )
init { videos } =
    let
        model =
          { videos = Array.fromList videos
          , currentVideo = 0
          }
    in
        ( model, Cmd.none )



---- UPDATE ----


type Msg
    = Seek Int
    | VideoEnded


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Seek index ->
            ( { model | currentVideo = index }, playVideo True )
        VideoEnded ->
            let
                newIndex =
                    model.currentVideo + 1
                done =
                    newIndex == Array.length model.videos
            in
                case done of
                    True ->
                        ( model, Cmd.none )
                    False ->
                        ( { model | currentVideo = newIndex }, playVideo True )


-- incoming port
port videoEnded : (Bool -> msg) -> Sub msg

-- outgoing, start the video (assuming it's in paused)
port playVideo : Bool -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    videoEnded (\_ -> VideoEnded)


---- VIEW ----


currentVideoUri : Model -> String
currentVideoUri model =
    let
        index =
            case (Array.get model.currentVideo model.videos) of
                Just index ->
                  index
                Nothing ->
                  -1
    in
        "/stream/" ++ (toString index)


view : Model -> Html Msg
view model =
    div
       []
       [ video
           [ id "theater"
           , attribute "preload" "auto"
           , attribute "controls" "true"
           , class "mb-4 rounded"
           ]
           [ source
               [ attribute "src" (currentVideoUri model)
               , attribute "type" "video/mp4"
               ]
               []
           ]
       , div
           [ class "flex w-full overflow-x-scroll"
           ]
           (Array.toList (Array.indexedMap (\i d -> drawThumbs d i model.currentVideo) model.videos))
       ]


drawThumbs : Int -> Int -> Int -> Html Msg
drawThumbs id index currentIndex =
    div [ classList
            [ ( "theater-thumb-holster", True )
            , ( "w-1/5", True )
            , ( "pb-2", True )
            , ( "border-blue-dark", index == currentIndex )
            , ( "border-b", index == currentIndex )
            , ( "border-b-2", index == currentIndex )
            ]
        ]
        [ img
            [ class "theater-thumbs border border-grey-darker"
            , src ("/thumb/" ++ (toString id) ++ "/jpeg")
            , onClick (Seek index)
            ]
            []
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
