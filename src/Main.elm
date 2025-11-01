port module Main exposing (..)

import Browser exposing (Document)
import Html exposing (button, h1, text, textarea)
import Html.Attributes exposing (cols, id, rows)
import Html.Events exposing (onClick)


port runLuaCode : String -> Cmd msg


type alias Model =
    { code : String
    }


type Msg
    = Run


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Run ->
            ( model, runLuaCode model.code )


view : Model -> Document Msg
view model =
    { title = "Lom Playground"
    , body =
        [ h1 [] [ text "lom + Lua WASM Playground" ]
        , textarea [ id "code", rows 10, cols 50 ]
            [ text model.code ]
        , button [ onClick Run ] [ text "Run" ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.document
        { init = \() -> ( Model "print('Hello from Lua in WASM!')" , Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
