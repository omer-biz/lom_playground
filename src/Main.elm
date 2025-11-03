port module Main exposing (..)

import Browser exposing (Document)
import Html exposing (button, h1, text, textarea)
import Html.Attributes exposing (cols, id, rows)
import Html.Events exposing (onClick, onInput)


port runLuaCode : String -> Cmd msg


port lomStdErr : (String -> msg) -> Sub msg


port lomStdOut : (String -> msg) -> Sub msg


type alias Model =
    { code : String
    , output : List ConsoleOutput
    }


type ConsoleOutput
    = StdErr String
    | StdOut String


type Msg
    = Run
    | UpdateCode String
    | UpdateStdErr String
    | UpdateStdOut String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Run ->
            ( model, runLuaCode model.code )

        UpdateCode code ->
            ( { model | code = code }, Cmd.none )

        UpdateStdErr stderr ->
            ( { model | output = StdErr stderr :: model.output }, Cmd.none )

        UpdateStdOut stdout ->
            ( { model | output = StdOut stdout :: model.output }, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "Lom Playground"
    , body =
        [ h1 [] [ text "lom + Lua WASM Playground" ]
        , textarea [ id "code", rows 10, cols 50, onInput UpdateCode ]
            [ text model.code ]
        , button [ onClick Run ] [ text "Run" ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ lomStdErr UpdateStdErr, lomStdOut UpdateStdOut ]


main : Program () Model Msg
main =
    Browser.document
        { init = \() -> ( Model "print('Hello from Lua in WASM!')" [], Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
