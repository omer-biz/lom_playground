port module Main exposing (..)

import Browser exposing (Document)
import Html exposing (Html, button, div, h1, header, main_, pre, section, text, textarea)
import Html.Attributes exposing (attribute, class, placeholder)
import Html.Events exposing (onClick, onInput)


port runLuaCode : { code : String, input : String } -> Cmd msg


port lomStdErr : (String -> msg) -> Sub msg


port lomStdOut : (String -> msg) -> Sub msg


type alias Model =
    { code : String
    , output : List ConsoleOutput
    , input : String
    }


type ConsoleOutput
    = StdErr String
    | StdOut String


type Msg
    = Run
    | UpdateCode String
    | UpdateStdErr String
    | UpdateStdOut String
    | UpdateInput String


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


view : Model -> Document Msg
view model =
    { title = "Lom Playground"
    , body =
        [ div [ class "max-w-[1400px] mx-auto" ]
            [ viewHeader
            , viewMain model
            ]
        ]
    }


viewMain : Model -> Html Msg
viewMain model =
    main_ [ class "grid grid-cols-1 md:grid-cols-2 gap-4 mt-8" ]
        [ viewLuaCode model.code
        , viewTextAndResult model
        ]


viewTextAndResult : Model -> Html Msg
viewTextAndResult model =
    div [ class "flex-col gap-2 space-y-2 md:flex" ]
        [ viewText model.input
        , viewResult model.output
        ]


viewResult : List ConsoleOutput -> Html msg
viewResult output =
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
    section [ class "bg-white rounded-lg shadow p-4" ]
        [ viewSectionHeader
        , div [ class "min-h-[160px]" ]  viewAll
        ]


viewText : String -> Html Msg
viewText input =
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
        , textarea
            [ class "w-full min-h-[180px] font-mono text-sm p-3 border rounded resize-y"
            , placeholder "Type the text to parse"
            , onInput UpdateInput
            ]
            [ text input ]
        ]


viewLuaCode : String -> Html Msg
viewLuaCode code =
    let
        viewCodeArea =
            textarea
                [ class "w-full min-h-[340px] font-mono text-sm p-3 border rounded resize-y"
                , placeholder "-- write your lua code here"
                , attribute "spellcheck" "false"
                , onInput UpdateCode
                ]
                [ text code ]

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
                                [ text "Lua" ]
                            , div [ class "text-xs text-slate-500" ]
                                [ text "The parser definition. Lom code to parse the text." ]
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
        { init = \() -> ( Model "print('Hello from Lua in WASM!')" [] "", Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
