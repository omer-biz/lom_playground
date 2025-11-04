port module Main exposing (..)

import Browser exposing (Document)
import Html exposing (Html, button, div, h1, header, main_, pre, section, text, textarea)
import Html.Attributes exposing (attribute, class, placeholder)
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
        [ div [ class "max-w-[1400px] mx-auto" ]
            [ viewHeader
            , viewMain
            ]
        ]
    }


viewMain : Html msg
viewMain =
    main_ [ class "grid gap-4 mt-8" ]
        [ div [ class "grid grid-cols-1 md:grid-cols-2 gap-4" ]
            [ viewLuaCode
            , viewTextAndResult
            ]
        , div [ class "flex gap-3 justify-end" ]
            [ button [ class "px-4 py-2 rounded bg-green-600 text-white" ]
                [ text "Run          " ]
            , button [ class "px-4 py-2 rounded border" ]
                [ text "Export JSON          " ]
            ]
        ]


viewTextAndResult : Html msg
viewTextAndResult =
    div [ class "flex-col gap-2 space-y-2 md:flex" ]
        [ viewText
        , viewResult
        ]


viewResult : Html msg
viewResult =
    let
        viewSectionHeader =
            div [ class "section-header" ]
                [ div [ class "flex items-center justify-between mb-3" ]
                    [ div [ class "flex items-center gap-2" ]
                        [ -- svg [ class "w-5 h-5 text-sky-600", fill "none", viewBox "0 0 24 24" ]
                          --     [ path [ d "M4 6h16M4 12h16M4 18h16", attribute "stroke" "currentColor", attribute "stroke-linecap" "round", attribute "stroke-width" "1.2" ]
                          --         []
                          --     , text "                  "
                          --     ]
                          -- ,
                          div []
                            [ div [ class "font-medium" ]
                                [ text "Output" ]
                            , div [ class "text-xs text-slate-500" ]
                                [ text "Shows stdout and stderr (errors) from the parser.                    " ]
                            ]
                        ]
                    , div [ class "flex items-center gap-2" ]
                        [ button [ class "text-sm px-2 py-1 rounded border" ]
                            [ text "Clear                  " ]
                        ]
                    ]
                , div [ class "underline h-0.5 bg-gradient-to-r from-indigo-600 to-cyan-400" ]
                    []
                ]

        viewTabHeader =
            div [ class "flex gap-2 mb-3" ]
                [ button [ class "tabBtn px-3 py-1 rounded bg-indigo-600 text-white text-sm", attribute "data-tab" "stdout" ]
                    [ text "stdout              " ]
                , button [ class "tabBtn px-3 py-1 rounded border text-sm", attribute "data-tab" "stderr" ]
                    [ text "stderr              " ]
                ]
    in
    section [ class "bg-white rounded-lg shadow p-4" ]
        [ viewSectionHeader
        , viewTabHeader
        , pre [ class "p-3 bg-slate-100 min-h-[160px] rounded text-sm font-mono" ]
            []
        , pre [ class "p-3 bg-rose-100 min-h-[160px] rounded text-sm font-mono hidden" ]
            []
        ]


viewText : Html msg
viewText =
    section [ class "bg-white rounded-lg shadow p-4" ]
        [ div [ class "section-header" ]
            [ div [ class "flex items-center justify-between mb-3" ]
                [ div [ class "flex items-center gap-2" ]
                    [ -- svg [ class "w-5 h-5 text-orange-500", fill "none", viewBox "0 0 24 24" ]
                      --     [ path [ d "M4 6h16M4 12h16M4 18h16", attribute "stroke" "currentColor", attribute "stroke-linecap" "round", attribute "stroke-width" "1.2" ]
                      --         []
                      --     , text "                  "
                      --     ]
                      -- ,
                      div []
                        [ div [ class "font-medium" ]
                            [ text "Text to parse" ]
                        , div [ class "text-xs text-slate-500" ]
                            [ text "The input string that will be fed to the grammar." ]
                        ]
                    ]
                , div [ class "flex items-center gap-2" ]
                    [ button [ class "text-sm px-2 py-1 rounded border" ]
                        [ text "Clear                  " ]
                    ]
                ]
            , div [ class "underline h-0.5 bg-gradient-to-r from-indigo-600 to-cyan-400" ]
                []
            ]
        , textarea [ class "w-full min-h-[180px] font-mono text-sm p-3 border rounded resize-y", placeholder "Type the text to parse" ]
            []
        ]


viewLuaCode : Html msg
viewLuaCode =
    let
        viewCodeArea =
            textarea
                [ class "w-full min-h-[340px] font-mono text-sm p-3 border rounded resize-y"
                , placeholder "-- write your lua code here"
                , attribute "spellcheck" "false"
                ]
                []

        viewSectionHeader =
            div [ class "section-header" ]
                [ div [ class "flex items-center justify-between mb-3" ]
                    [ div [ class "flex items-center gap-2" ]
                        [ -- svg [ class "w-5 h-5 text-green-600", fill "none", viewBox "0 0 24 24" ]
                          --     [ path [ d "M4 6h16M4 12h16M4 18h16", attribute "stroke" "currentColor", attribute "stroke-linecap" "round", attribute "stroke-width" "1.2" ]
                          --         []
                          --     , text "                "
                          --     ]
                          -- ,
                          div []
                            [ div [ class "font-medium" ]
                                [ text "Grammar (Lua)" ]
                            , div [ class "text-xs text-slate-500" ]
                                [ text "The parser definition. Highest priority pane." ]
                            ]
                        ]
                    , div [ class "flex items-center gap-2" ]
                        [ button [ class "text-sm px-2 py-1 rounded border" ] [ text "clear" ] ]
                    ]
                , div [ class "underline h-0.5 bg-gradient-to-r from-indigo-600 to-cyan-400" ]
                    []
                ]
    in
    section [ class "bg-white rounded-lg shadow p-4" ]
        [ viewSectionHeader
        , viewCodeArea
        ]


viewHeader : Html msg
viewHeader =
    header [ class "flex items-center gap-3 text-xl font-semibold" ]
        [ h1 []
            [ text "svg logo"
            , text "Lom Playground"
            ]
        , div [ class "flex items-center gap-3" ]
            [ button [ class "px-3 py-1 rounded border border-slate-200 text-sm" ] [ text "Copy Share Link" ]
            ]
        ]


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
