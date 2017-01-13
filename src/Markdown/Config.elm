module Markdown.Config exposing
    ( Options
    , HtmlOption(..)
    , SanitizeOptions
    , defaultOptions
    , defaultSanitizeOptions
    , Elements
    , defaultElements
    , CodeBlock
    , ListElement(..)
    , Image
    , Link
    )



{-| Configure markdown to fit your needs.

# Options
@docs Options, HtmlOption, SanitizeOptions, defaultOptions, defaultSanitizeOptions

# Elements
@docs Elements, defaultElements, CodeBlock, ListElement, Image, Link

-}


import Html exposing (Html, h1, h2, h3, h4, h5, h6, p, blockquote, ul, ol, code, pre, img, a, text, strong, em, hr, br)
import Html.Attributes exposing (start, class, src, alt, title, href)



----------------------------------------------------------------------
------------------------------- Options ------------------------------
----------------------------------------------------------------------


{-| Some parser options so you can tweak things for your
particular case. 

- `softAsHardLineBreak`: If set to `True`, will render `\n` as `<br>`.
- `html`: This determine what to do with raw html elements.
    
-}
type alias Options =
    { softAsHardLineBreak : Bool
    , html : HtmlOption
    }


{-| The `Options` used in `Markdown.toHtml`.

```
{ softAsHardLineBreak = False
, html = Sanitize defaultSanitizeOptions
}
```
-}
defaultOptions : Options
defaultOptions =
    { softAsHardLineBreak = False
    , html = Sanitize defaultSanitizeOptions
    }


{-| Choose what to do with raw html elements.

- `ParseUnsafe`: Will parse any valid html tag and attribute. This includes malicious code like `<script>alert("XSS ALERT!!");</script>`.
- `Sanitize SanitizeOptions`: Will parse only specific html elements and attributes.
- `DontParse`: Do not parse any html tag. It will include the raw text in the output.
-}
type HtmlOption
    = ParseUnsafe
    | Sanitize SanitizeOptions
    | DontParse


{-| Choose what html elements and attributes are allowed to parse.

- `allowedHtmlElements`: List of allowed html elements.
- `allowedHtmlAttributes`: List of allowed attributes.
-}
type alias SanitizeOptions =
    { allowedHtmlElements : List String
    , allowedHtmlAttributes : List String
    }


{-| The `SanitizeOptions` used by `defaultOptions`.

```
{ allowedHtmlElements =
    [ "address", "article", "aside", "b", "blockquote"
    , "body","br", "caption", "center", "cite", "code", "col"
    , "colgroup", "dd", "details", "div", "dl", "dt", "figcaption"
    , "figure", "footer", "h1", "h2", "h3", "h4", "h5", "h6", "hr"
    , "i", "legend", "li", "link", "main", "menu", "menuitem"
    , "nav", "ol", "optgroup", "option", "p", "pre", "section"
    , "strike", "summary", "small", "table", "tbody", "td"
    , "tfoot", "th", "thead", "title", "tr", "ul" ]
, allowedHtmlAttributes =
    [ "name", "class" ]
```
-}
defaultSanitizeOptions : SanitizeOptions
defaultSanitizeOptions =
    { allowedHtmlElements = defaultAllowedHtmlElements
    , allowedHtmlAttributes = defaultAllowedHtmlAttributes
    }


defaultAllowedHtmlElements : List String
defaultAllowedHtmlElements =
    [ "address", "article", "aside", "b", "blockquote"
    , "body","br", "caption", "center", "cite", "code", "col"
    , "colgroup", "dd", "details", "div", "dl", "dt", "figcaption"
    , "figure", "footer", "h1", "h2", "h3", "h4", "h5", "h6", "hr"
    , "i", "legend", "li", "link", "main", "menu", "menuitem"
    , "nav", "ol", "optgroup", "option", "p", "pre", "section"
    , "strike", "summary", "small", "table", "tbody", "td"
    , "tfoot", "th", "thead", "title", "tr", "ul" ]


defaultAllowedHtmlAttributes : List String
defaultAllowedHtmlAttributes =
    [ "name", "class" ]



----------------------------------------------------------------------
------------------------------ Elements ------------------------------
----------------------------------------------------------------------


{-| A record to be used with `customHtml` of how each element
is rendered to html.
-}
type alias Elements =
    { heading : Int -> List (Html Never) -> Html Never
    , thematicBreak : Html Never
    , paragraph : Bool -> List (Html Never) -> List (Html Never)
    , blockQuote : List (Html Never) -> Html Never
    , code : CodeBlock -> Html Never
    , list : ListElement -> List ( Html Never ) -> Html Never
    , emphasis : List (Html Never) -> Html Never
    , strongEmphasis : List (Html Never) -> Html Never
    , codeSpan : String -> Html Never
    , link : Link -> List (Html Never) -> Html Never
    , image : Image -> Html Never
    , hardLineBreak : Html Never
    }


{-| The elements used in `toHtml` and `withOptions`.
-}
defaultElements : Elements
defaultElements =
    { heading = headingElement
    , thematicBreak = hr [] []
    , paragraph = paragraphElement
    , blockQuote = blockquote []
    , code = codeElement
    , list = listElement
    , emphasis = emphasisElement
    , strongEmphasis = strongEmphasisElement
    , codeSpan = codeSpanElement
    , link = linkElement
    , image = imageElement
    , hardLineBreak = br [] []
    }



-- Heading


headingElement : Int -> List (Html Never) -> Html Never
headingElement level =
    case level of
        1 -> h1 []
        2 -> h2 []
        3 -> h3 []
        4 -> h4 []
        5 -> h5 []
        _ -> h6 []



-- Paragraph


paragraphElement : Bool -> List (Html Never) -> List (Html Never)
paragraphElement textAsParagraph innerHtml =
    if textAsParagraph then
        [ p [] innerHtml ]

    else
        innerHtml



-- Code Block


{-| Code block element model. If you want to use a highlight package,
you have access to the code here.
-}
type alias CodeBlock =
    { language : Maybe String
    , code : String
    }


codeElement : CodeBlock -> Html Never
codeElement codeBlock =
    let
        basicView : List (Html.Attribute Never) -> Html Never
        basicView attrs =
            pre []
                [ code attrs
                    [ text codeBlock.code ]
                ]

    in
        case codeBlock.language of
            Just language ->
                basicView [ class ("language-" ++ language) ]

            Nothing ->
                basicView []



-- List


{-| List element model. The `Int` in `Ordered Int` is the
first number used to start an ordered list.
-}
type ListElement
    = Unordered
    | Ordered Int


listElement : ListElement -> List (Html Never) -> Html Never
listElement type_ =
    case type_ of
        Ordered startInt ->
            if startInt == 1 then
                ol []
            
            else
                ol [ start startInt ]

        Unordered ->
            ul []



-- Emphasis


emphasisElement : List (Html Never) -> Html Never
emphasisElement =
    em []


strongEmphasisElement : List (Html Never) -> Html Never
strongEmphasisElement =
    strong []



-- Code Span


codeSpanElement : String -> Html Never
codeSpanElement codeStr =
    code [] [ text codeStr ]



-- Link


{-| Link element model.
-}
type alias Link =
    { url : String
    , title : Maybe String
    }


linkElement : Link -> List (Html Never) -> Html Never
linkElement model =
    case model.title of
        Just title_ ->
            a [ href model.url, title title_ ]
            

        Nothing ->
            a [ href model.url ]



-- Image


{-| Image element model.
-}
type alias Image =
    { alt : String
    , src : String
    , title : Maybe String
    }


imageElement : Image -> Html Never
imageElement model =
    case model.title of
        Just title_ ->
            img
                [ alt model.alt
                , src model.src
                , title title_
                ] []
            

        Nothing ->
            img
                [ alt model.alt
                , src model.src
                ] []