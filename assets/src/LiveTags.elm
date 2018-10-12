module LiveTags exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Json.Encode as Encode
import Json.Decode as Decode
import Task

import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push


---- MODEL ----


type alias Model =
  {
    tags : List String,
    tagInProgress : String,
    phxSocket : Phoenix.Socket.Socket Msg
  }


init : ( Model, Cmd Msg )
init =
  let
    channel =
      Phoenix.Channel.init "tag:lobby"
    initSocket =
      Phoenix.Socket.init "ws://galactica.relaytms.com:4000/socket/websocket"
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "tag_created" "tag:lobby" AddTag
    model =
      {
        tags = [ ],
        tagInProgress = "",
        phxSocket = initSocket
      }
  in
    ( model, joinChannel )


---- UPDATE ----


type Msg
  = StartTag String
  | SubmitTag
  | PhoenixMsg (Phoenix.Socket.Msg Msg)
  | AddTag Encode.Value
  | PopulateTags Encode.Value
  | HandleSendError Encode.Value
  | JoinChannel
  | DeleteTag String
  | RemoveTag Encode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    PhoenixMsg msg ->
      let
          ( phxSocket, phxCmd ) = Phoenix.Socket.update msg model.phxSocket
      in
          ( { model | phxSocket = phxSocket } , Cmd.map PhoenixMsg phxCmd )
    StartTag tag ->
      ( { model | tagInProgress = tag }, Cmd.none )
    SubmitTag ->
      let
          a = Debug.log("About to submit the tag")
          payload =
            Encode.object
              [
                ( "name", Encode.string model.tagInProgress )
              ]
          phxPush =
            Phoenix.Push.init "new_tag" "tag:lobby"
              |> Phoenix.Push.withPayload payload
              |> Phoenix.Push.onOk AddTag
              |> Phoenix.Push.onError HandleSendError
          (phxSocket, phxCmd) = Phoenix.Socket.push phxPush model.phxSocket
      in
          ( { model | phxSocket = phxSocket, tagInProgress = "" }
          , Cmd.map PhoenixMsg phxCmd )
    AddTag raw ->
      let
          msg = Decode.decodeValue (Decode.field "name" Decode.string) raw
      in
          case msg of
            Ok new_tag ->
              ( { model | tags = new_tag :: model.tags }, Cmd.none )
            Err error ->
              ( model, Cmd.none )
    HandleSendError _ ->
      let
          message = "Failed to Send Message"
          a = Debug.log("Failed to send message")
      in
          ( { model | tags = message :: model.tags }, Cmd.none )
    JoinChannel ->
      let
          channel =
            Phoenix.Channel.init "tag:lobby"
              |> Phoenix.Channel.onJoin PopulateTags

          ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel model.phxSocket
      in
          ( { model | phxSocket = phxSocket }
          , Cmd.map PhoenixMsg phxCmd
          )
    PopulateTags raw ->
      let
        msg = Decode.decodeValue (Decode.field "tags" (Decode.list Decode.string)) raw
      in
          case msg of
            Ok message ->
              ( { model | tags = message }, Cmd.none )
            Err error ->
              ( model, Cmd.none )
    DeleteTag tag ->
      let
          a = Debug.log("About to delete a tag")
          payload =
            Encode.object
              [
                ( "name", Encode.string tag )
              ]
          phxPush =
            Phoenix.Push.init "delete_tag" "tag:lobby"
              |> Phoenix.Push.withPayload payload
              |> Phoenix.Push.onOk RemoveTag
              |> Phoenix.Push.onError HandleSendError

          ( phxSocket, phxCmd ) = Phoenix.Socket.push phxPush model.phxSocket
      in
          ( { model | phxSocket = phxSocket }
          , Cmd.map PhoenixMsg phxCmd )
    RemoveTag raw ->
      let
          msg = Decode.decodeValue (Decode.field "name" Decode.string) raw
      in
          case msg of
            Ok tag ->
              ( { model | tags = List.filter (\t -> t /= tag) model.tags }
              , Cmd.none
              )
            Err error ->
              ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.phxSocket PhoenixMsg

joinChannel : Cmd Msg
joinChannel =
  Task.succeed JoinChannel
    |> Task.perform identity

---- VIEW ----

drawTag : String -> Html Msg
drawTag tag =
  li [ ]
  [ input [ attribute "id" tag
          , attribute "name" ("video[" ++ (toString tag) ++ "]")
          , attribute "type" "checkbox"] [ ]
  , text tag
  , i [ attribute "class" "fas fa-times"
      , onClick (DeleteTag tag) ] [ ]
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
    , subscriptions = subscriptions
    }
