port module Main exposing (..)

import Browser exposing (Document)
import Browser.Events as BE
import Html exposing (Html, button, div, h1, header, main_, pre, section, text, textarea)
import Html.Attributes exposing (attribute, class, id, placeholder, style)
import Html.Events as Events exposing (onClick, onInput, onMouseDown)
import Icons
import Json.Decode as D
import Json.Encode as E


port runLuaCode : { code : String, input : String } -> Cmd msg


port listenDrag : String -> Cmd msg


port stopDrag : String -> Cmd msg


port hermesStdErr : (String -> msg) -> Sub msg


port hermesStdOut : (String -> msg) -> Sub msg


port draggedHorizontal : (Float -> msg) -> Sub msg


port draggedVertical : (Float -> msg) -> Sub msg


type alias Model =
    { code : String
    , output : List ConsoleOutput
    , input : String
    , dragHorizontal : DragState
    , dragVertical : DragState
    }


type ConsoleOutput
    = StdErr String
    | StdOut String


type DragState
    = Static Float
    | Moving Float


type Direction
    = Horizontal
    | Vertical


type alias Flags =
    { parser_code : Maybe String
    , input : Maybe String
    }


type Msg
    = Run
    | UpdateCode String
    | UpdateStdErr String
    | UpdateStdOut String
    | UpdateInput String
    | DragStart Direction
    | DragStop Direction
    | DragMove Direction Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Run ->
            ( { model | output = [] }, runLuaCode { code = model.code, input = model.input } )

        UpdateCode code ->
            ( { model | code = code }, Cmd.none )

        UpdateStdErr stderr ->
            ( { model | output = StdErr stderr :: model.output }, Cmd.none )

        UpdateStdOut stdout ->
            ( { model | output = StdOut stdout :: model.output }, Cmd.none )

        UpdateInput input ->
            ( { model | input = input }, Cmd.none )

        DragStart direction ->
            let
                f =
                    toFraction (getDragState direction model)
            in
            ( updateDragState model direction (Moving f)
            , dragPort direction listenDrag
            )

        DragStop direction ->
            let
                f =
                    toFraction (getDragState direction model)
            in
            ( updateDragState model direction (Static f)
            , dragPort direction stopDrag
            )

        DragMove direction f ->
            ( updateDragState model
                direction
                (-- if isDragging then
                 Moving f
                 -- else
                 --    Static (toFraction <| getDragState direction model)
                )
            , Cmd.none
            )


dragPort : Direction -> (String -> a) -> a
dragPort direction handler =
    case direction of
        Horizontal ->
            handler "horizontal"

        Vertical ->
            handler "vertical"


getDragState :
    Direction
    -> { a | dragHorizontal : b, dragVertical : b }
    -> b
getDragState direction model =
    case direction of
        Horizontal ->
            model.dragHorizontal

        Vertical ->
            model.dragVertical


toFraction : DragState -> Float
toFraction dragState =
    case dragState of
        Static f ->
            f

        Moving f ->
            f


updateDragState : Model -> Direction -> DragState -> Model
updateDragState model direction newState =
    case direction of
        Horizontal ->
            { model | dragHorizontal = newState }

        Vertical ->
            { model | dragVertical = newState }


view : Model -> Document Msg
view model =
    { title = "Hermes Playground"
    , body =
        [ viewHeader
        , viewMain model
        ]
    }


viewMain : Model -> Html Msg
viewMain model =
    main_ [ class "flex flex-1 overflow-hidden" ]
        [ viewLuaCode model
        , div
            [ id "verticalDivider"
            , class "divider-x"
            , onMouseDown <| DragStart Vertical
            ]
            []
        , viewTextAndResult model
        ]


viewTextAndResult : Model -> Html Msg
viewTextAndResult model =
    div [ id "rightPane", class "flex flex-col flex-1" ]
        [ viewText model
        , div
            [ id "horizontalDivider"
            , class "divider-y"
            , onMouseDown <| DragStart Horizontal
            ]
            []
        , viewResult model.output
        ]


viewResult : List ConsoleOutput -> Html msg
viewResult output =
    let
        viewSectionHeader =
            div [ class "section-header" ]
                [ div [ class "flex items-center justify-between mb-3" ]
                    [ div [ class "flex items-center gap-2" ]
                        [ Icons.output "w-10 h-10"
                        , div []
                            [ div [ class "font-medium" ]
                                [ text "Output" ]
                            , div [ class "text-xs text-slate-500" ]
                                [ text "Shows stdout and stderr (errors) from the parser." ]
                            ]
                        ]
                    ]
                , div [ class "underline h-0.5 bg-gradient-to-r from-indigo-600 to-cyan-400" ]
                    []
                ]

        viewStderr err =
            pre [ class "p-3 bg-rose-100  rounded text-sm font-mono" ]
                [ text err ]

        viewStdout out =
            pre [ class "p-3 bg-slate-100 rounded text-sm font-mono" ]
                [ text out ]

        viewAll : List (Html msg)
        viewAll =
            output
                |> List.reverse
                |> List.map
                    (\o ->
                        case o of
                            StdErr err ->
                                viewStderr err

                            StdOut out ->
                                viewStdout out
                    )
    in
    section [ id "outputPane", class "bg-white rounded-lg shadow p-4 flex-1 flex flex-col" ]
        [ viewSectionHeader
        , div [ class "overflow-y-scroll" ] viewAll
        ]


viewText : Model -> Html Msg
viewText model =
    section
        [ id "inputPane"
        , class "flex-1 border-b border-slate-200 p-4 flex flex-col"
        , style "height" (String.fromFloat (100 * toFraction model.dragHorizontal) ++ "%")
        , style "flex" "none"
        ]
        [ div [ class "section-header" ]
            [ div [ class "flex items-center justify-between mb-3" ]
                [ div [ class "flex items-center gap-2" ]
                    [ Icons.input "w-10 h-10"
                    , div []
                        [ div [ class "font-medium" ]
                            [ text "Text to parse" ]
                        , div [ class "text-xs text-slate-500" ]
                            [ text "The input string that will be fed to the parser." ]
                        ]
                    ]
                ]
            , div [ class "underline h-0.5 bg-gradient-to-r from-indigo-600 to-cyan-400" ]
                []
            ]
        , textarea
            [ class "flex-1 w-full font-mono text-sm bg-slate-100 rounded-lg p-3 resize-none focus:outline-none focus:ring-2 focus:ring-blue-400"
            , placeholder "Type the text to parse"
            , onInput UpdateInput
            ]
            [ text model.input ]
        ]


viewLuaCode : Model -> Html Msg
viewLuaCode model =
    let
        viewCodeArea =
            luaEditor model.code UpdateCode

        viewSectionHeader =
            div [ class "section-header" ]
                [ div [ class "flex items-center justify-between mb-3" ]
                    [ div [ class "flex items-center gap-2" ]
                        [ Icons.lua "w-10 h-10"
                        , div []
                            [ div [ class "font-medium" ]
                                [ text "Lua" ]
                            , div [ class "text-xs text-slate-500" ]
                                [ text "The parser definition. Hermes code to parse the text." ]
                            ]
                        ]
                    , div [ class "flex items-center gap-2" ]
                        [ button
                            [ class "px-4 py-1 rounded bg-green-500 text-white"
                            , onClick Run
                            ]
                            [ text "Run" ]
                        ]
                    ]
                , div [ class "underline h-0.5 bg-gradient-to-r from-indigo-600 to-cyan-400" ]
                    []
                ]
    in
    section
        [ id "editorPane"
        , class "flex flex-col flex-[2] border-r border-slate-200 p-4"
        , style "width" (String.fromFloat (100 * toFraction model.dragVertical) ++ "%")
        , style "flex" "none"
        ]
        [ viewSectionHeader
        , viewCodeArea
        ]


luaEditor : String -> (String -> msg) -> Html msg
luaEditor value onInput =
    Html.node "lua-editor"
        [ attribute "value" value
        , Events.on "editorChanged" <|
            D.map onInput <|
                D.at [ "target", "value" ] D.string
        , class "flex-1 w-full font-mono text-sm bg-slate-100 rounded-lg p-3 resize-none focus:outline-none focus:ring-2 focus:ring-blue-400"
        ]
        []


viewHeader : Html msg
viewHeader =
    header [ class "px-4 border-slate-200 border-b-8" ]
        [ h1 [ class "flex items-center gap-x-3" ]
            [ Icons.logo "w-20 h-20"
            , text "Hermes Playground"
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ hermesStdErr UpdateStdErr
        , hermesStdOut UpdateStdOut
        , dragSub model.dragHorizontal Horizontal draggedHorizontal
        , dragSub model.dragVertical Vertical draggedVertical
        ]


dragSub :
    DragState
    -> Direction
    -> ((Float -> Msg) -> Sub Msg)
    -> Sub Msg
dragSub dragState direction dragged =
    case dragState of
        Static _ ->
            Sub.none

        Moving _ ->
            Sub.batch
                [ BE.onMouseUp <| D.succeed (DragStop direction)
                , dragged <|
                    \fraction ->
                        DragMove direction fraction
                ]


init : E.Value -> ( Model, Cmd msg )
init rawFlags =
    let
        flags =
            case D.decodeValue flagsDecoder rawFlags of
                Ok f ->
                    f

                Err _ ->
                    { parser_code = Nothing, input = Nothing }
    in
    ( { code = Maybe.withDefault "print('Hello from Lua in WASM!')" flags.parser_code
      , output = []
      , input = Maybe.withDefault "" flags.input
      , dragHorizontal = Static 0.5
      , dragVertical = Static 0.5
      }
    , Cmd.none
    )


flagsDecoder : D.Decoder Flags
flagsDecoder =
    D.map2 (\c i -> { parser_code = c, input = i })
        (D.maybe (D.field "parser_code" D.string))
        (D.maybe (D.field "_input" D.string))


main : Program E.Value Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
