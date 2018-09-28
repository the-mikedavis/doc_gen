module LiveTags exposing (..)

--import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
--import Phoenix.Socket
--import Phoenix.Channel
--import Phoenix.Push


---- MODEL ----


type alias Model =
  { 
    tags : List String --,
    --sock : Phoenix.Socket.Socket Msg
  }


init : ( Model, Cmd Msg )
init =
  let
    model =
      {
        tags = [ "Test Tag" ]
      }
  in
    ( model, Cmd.none )



---- UPDATE ----


type Msg
  = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  ( model, Cmd.none )



---- VIEW ----

drawTag : String -> Html Msg
drawTag tag =
  li []
  [ text tag
  ]

view : Model -> Html Msg
view model =
  let
      drawTags tags =
        tags |> List.map drawTag
  in
    div []
    [ ul [] (model.tags |> drawTags)
    ]



---- PROGRAM ----


main : Program Never Model Msg
main =
  Html.program
    { view = view
    , init = init
    , update = update
    , subscriptions = always Sub.none
    }
