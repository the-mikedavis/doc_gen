module LiveTags exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


---- MODEL ----


type alias Model =
  { 
    tags : List String,
    tagInProgress : String
  }


init : ( Model, Cmd Msg )
init =
  let
    model =
      {
        tags = [ ],
        tagInProgress = ""
      }
  in
    ( model, Cmd.none )



---- UPDATE ----


type Msg
  = StartTag String
  | SubmitTag


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    StartTag tag ->
      ( { model | tagInProgress = tag }, Cmd.none )
    SubmitTag ->
      ( { model | tags = model.tagInProgress :: model.tags, tagInProgress = "" },
      Cmd.none)

---- VIEW ----

drawTag : String -> Html Msg
drawTag tag =
  li [ ]
  [ input [ attribute "id" tag
          , attribute "name" ("video[" ++ (toString tag) ++ "]")
          , attribute "type" "checkbox"] [ ]
  , text tag
  , i [ attribute "class" "fas fa-times" ] [ ]
  ]

view : Model -> Html Msg
view model =
  let
      drawTags tags =
        tags
        |> List.filter(\t -> String.length t > 0)
        |> List.sort
        |> List.map drawTag
  in
    div [ ]
    [ ul [ ] (model.tagInProgress :: model.tags |> drawTags)
    , h4 [ ] [ text "Create New Tags" ]
    , input [ onInput StartTag
            , value model.tagInProgress ] []
    , button [ onClick SubmitTag
             , attribute "type" "button" ] [ text "Create" ]
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
