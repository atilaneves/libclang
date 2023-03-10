module clang.c.documentation;
import clang.c.CXString;
import clang.c.index;

extern (C) @nogc nothrow @trusted pure:

/**
 * \defgroup CINDEX_COMMENT Comment introspection
 *
 * The routines in this group provide access to information in documentation
 * comments. These facilities are distinct from the core and may be subject to
 * their own schedule of stability and deprecation.
 *
 * @{
 */

/**
 * A parsed comment.
 */
struct CXComment
{
    const(void)* ASTNode;

    /**
     * Given a cursor that represents a documentable entity (e.g.,
     * declaration), return the associated parsed comment as a
     * \c CXComment_FullComment AST node.
     */

    /**
     * Describes the type of the comment AST node (\c CXComment).  A comment
     * node can be considered block content (e. g., paragraph), inline content
     * (plain text) or neither (the root AST node).
     */

    /**
     * Null comment.  No AST node is constructed at the requested location
     * because there is no text or a syntax error.
     */

    /**
     * Plain text.  Inline content.
     */

    /**
     * A command with word-like arguments that is considered inline content.
     *
     * For example: \\c command.
     */

    /**
     * HTML start tag with attributes (name-value pairs).  Considered
     * inline content.
     *
     * For example:
     * \verbatim
     * <br> <br /> <a href="http://example.org/">
     * \endverbatim
     */

    /**
     * HTML end tag.  Considered inline content.
     *
     * For example:
     * \verbatim
     * </a>
     * \endverbatim
     */

    /**
     * A paragraph, contains inline comment.  The paragraph itself is
     * block content.
     */

    /**
     * A command that has zero or more word-like arguments (number of
     * word-like arguments depends on command name) and a paragraph as an
     * argument.  Block command is block content.
     *
     * Paragraph argument is also a child of the block command.
     *
     * For example: \has 0 word-like arguments and a paragraph argument.
     *
     * AST nodes of special kinds that parser knows about (e. g., \\param
     * command) have their own node kinds.
     */

    /**
     * A \\param or \\arg command that describes the function parameter
     * (name, passing direction, description).
     *
     * For example: \\param [in] ParamName description.
     */
    struct CXTranslationUnitImpl;
    alias CXTranslationUnit = CXTranslationUnitImpl*;
    CXTranslationUnit TranslationUnit;
}

CXComment clang_Cursor_getParsedComment (CXCursor C);

enum CXCommentKind
{
    CXComment_Null = 0,
    CXComment_Text = 1,
    CXComment_InlineCommand = 2,
    CXComment_HTMLStartTag = 3,
    CXComment_HTMLEndTag = 4,
    CXComment_Paragraph = 5,
    CXComment_BlockCommand = 6,
    CXComment_ParamCommand = 7,

    /**
     * A \\tparam command that describes a template parameter (name and
     * description).
     *
     * For example: \\tparam T description.
     */
    CXComment_TParamCommand = 8,

    /**
     * A verbatim block command (e. g., preformatted code).  Verbatim
     * block has an opening and a closing command and contains multiple lines of
     * text (\c CXComment_VerbatimBlockLine child nodes).
     *
     * For example:
     * \\verbatim
     * aaa
     * \\endverbatim
     */
    CXComment_VerbatimBlockCommand = 9,

    /**
     * A line of text that is contained within a
     * CXComment_VerbatimBlockCommand node.
     */
    CXComment_VerbatimBlockLine = 10,

    /**
     * A verbatim line command.  Verbatim line has an opening command,
     * a single line of text (up to the newline after the opening command) and
     * has no closing command.
     */
    CXComment_VerbatimLine = 11,

    /**
     * A full comment attached to a declaration, contains block content.
     */
    CXComment_FullComment = 12
}

alias CXComment_Null = CXCommentKind.CXComment_Null;
alias CXComment_Text = CXCommentKind.CXComment_Text;
alias CXComment_InlineCommand = CXCommentKind.CXComment_InlineCommand;
alias CXComment_HTMLStartTag = CXCommentKind.CXComment_HTMLStartTag;
alias CXComment_HTMLEndTag = CXCommentKind.CXComment_HTMLEndTag;
alias CXComment_Paragraph = CXCommentKind.CXComment_Paragraph;
alias CXComment_BlockCommand = CXCommentKind.CXComment_BlockCommand;
alias CXComment_ParamCommand = CXCommentKind.CXComment_ParamCommand;
alias CXComment_TParamCommand = CXCommentKind.CXComment_TParamCommand;
alias CXComment_VerbatimBlockCommand = CXCommentKind.CXComment_VerbatimBlockCommand;
alias CXComment_VerbatimBlockLine = CXCommentKind.CXComment_VerbatimBlockLine;
alias CXComment_VerbatimLine = CXCommentKind.CXComment_VerbatimLine;
alias CXComment_FullComment = CXCommentKind.CXComment_FullComment;

/**
 * The most appropriate rendering mode for an inline command, chosen on
 * command semantics in Doxygen.
 */
enum CXCommentInlineCommandRenderKind
{
    /**
     * Command argument should be rendered in a normal font.
     */
    CXCommentInlineCommandRenderKind_Normal = 0,

    /**
     * Command argument should be rendered in a bold font.
     */
    CXCommentInlineCommandRenderKind_Bold = 1,

    /**
     * Command argument should be rendered in a monospaced font.
     */
    CXCommentInlineCommandRenderKind_Monospaced = 2,

    /**
     * Command argument should be rendered emphasized (typically italic
     * font).
     */
    CXCommentInlineCommandRenderKind_Emphasized = 3,

    /**
     * Command argument should not be rendered (since it only defines an anchor).
     */
    CXCommentInlineCommandRenderKind_Anchor = 4
}

alias CXCommentInlineCommandRenderKind_Normal = CXCommentInlineCommandRenderKind.CXCommentInlineCommandRenderKind_Normal;
alias CXCommentInlineCommandRenderKind_Bold = CXCommentInlineCommandRenderKind.CXCommentInlineCommandRenderKind_Bold;
alias CXCommentInlineCommandRenderKind_Monospaced = CXCommentInlineCommandRenderKind.CXCommentInlineCommandRenderKind_Monospaced;
alias CXCommentInlineCommandRenderKind_Emphasized = CXCommentInlineCommandRenderKind.CXCommentInlineCommandRenderKind_Emphasized;
alias CXCommentInlineCommandRenderKind_Anchor = CXCommentInlineCommandRenderKind.CXCommentInlineCommandRenderKind_Anchor;

/**
 * Describes parameter passing direction for \\param or \\arg command.
 */
enum CXCommentParamPassDirection
{
    /**
     * The parameter is an input parameter.
     */
    CXCommentParamPassDirection_In = 0,

    /**
     * The parameter is an output parameter.
     */
    CXCommentParamPassDirection_Out = 1,

    /**
     * The parameter is an input and output parameter.
     */
    CXCommentParamPassDirection_InOut = 2
}

alias CXCommentParamPassDirection_In = CXCommentParamPassDirection.CXCommentParamPassDirection_In;
alias CXCommentParamPassDirection_Out = CXCommentParamPassDirection.CXCommentParamPassDirection_Out;
alias CXCommentParamPassDirection_InOut = CXCommentParamPassDirection.CXCommentParamPassDirection_InOut;

/**
 * \param Comment AST node of any kind.
 *
 * \returns the type of the AST node.
 */
CXCommentKind clang_Comment_getKind (CXComment Comment);

/**
 * \param Comment AST node of any kind.
 *
 * \returns number of children of the AST node.
 */
uint clang_Comment_getNumChildren (CXComment Comment);

/**
 * \param Comment AST node of any kind.
 *
 * \param ChildIdx child index (zero-based).
 *
 * \returns the specified child of the AST node.
 */
CXComment clang_Comment_getChild (CXComment Comment, uint ChildIdx);

/**
 * A \c CXComment_Paragraph node is considered whitespace if it contains
 * only \c CXComment_Text nodes that are empty or whitespace.
 *
 * Other AST nodes (except \c CXComment_Paragraph and \c CXComment_Text) are
 * never considered whitespace.
 *
 * \returns non-zero if \c Comment is whitespace.
 */
uint clang_Comment_isWhitespace (CXComment Comment);

/**
 * \returns non-zero if \c Comment is inline content and has a newline
 * immediately following it in the comment text.  Newlines between paragraphs
 * do not count.
 */
uint clang_InlineContentComment_hasTrailingNewline (CXComment Comment);

/**
 * \param Comment a \c CXComment_Text AST node.
 *
 * \returns text contained in the AST node.
 */
CXString clang_TextComment_getText (CXComment Comment);

/**
 * \param Comment a \c CXComment_InlineCommand AST node.
 *
 * \returns name of the inline command.
 */
CXString clang_InlineCommandComment_getCommandName (CXComment Comment);

/**
 * \param Comment a \c CXComment_InlineCommand AST node.
 *
 * \returns the most appropriate rendering mode, chosen on command
 * semantics in Doxygen.
 */
CXCommentInlineCommandRenderKind clang_InlineCommandComment_getRenderKind (
    CXComment Comment);

/**
 * \param Comment a \c CXComment_InlineCommand AST node.
 *
 * \returns number of command arguments.
 */
uint clang_InlineCommandComment_getNumArgs (CXComment Comment);

/**
 * \param Comment a \c CXComment_InlineCommand AST node.
 *
 * \param ArgIdx argument index (zero-based).
 *
 * \returns text of the specified argument.
 */
CXString clang_InlineCommandComment_getArgText (CXComment Comment, uint ArgIdx);

/**
 * \param Comment a \c CXComment_HTMLStartTag or \c CXComment_HTMLEndTag AST
 * node.
 *
 * \returns HTML tag name.
 */
CXString clang_HTMLTagComment_getTagName (CXComment Comment);

/**
 * \param Comment a \c CXComment_HTMLStartTag AST node.
 *
 * \returns non-zero if tag is self-closing (for example, &lt;br /&gt;).
 */
uint clang_HTMLStartTagComment_isSelfClosing (CXComment Comment);

/**
 * \param Comment a \c CXComment_HTMLStartTag AST node.
 *
 * \returns number of attributes (name-value pairs) attached to the start tag.
 */
uint clang_HTMLStartTag_getNumAttrs (CXComment Comment);

/**
 * \param Comment a \c CXComment_HTMLStartTag AST node.
 *
 * \param AttrIdx attribute index (zero-based).
 *
 * \returns name of the specified attribute.
 */
CXString clang_HTMLStartTag_getAttrName (CXComment Comment, uint AttrIdx);

/**
 * \param Comment a \c CXComment_HTMLStartTag AST node.
 *
 * \param AttrIdx attribute index (zero-based).
 *
 * \returns value of the specified attribute.
 */
CXString clang_HTMLStartTag_getAttrValue (CXComment Comment, uint AttrIdx);

/**
 * \param Comment a \c CXComment_BlockCommand AST node.
 *
 * \returns name of the block command.
 */
CXString clang_BlockCommandComment_getCommandName (CXComment Comment);

/**
 * \param Comment a \c CXComment_BlockCommand AST node.
 *
 * \returns number of word-like arguments.
 */
uint clang_BlockCommandComment_getNumArgs (CXComment Comment);

/**
 * \param Comment a \c CXComment_BlockCommand AST node.
 *
 * \param ArgIdx argument index (zero-based).
 *
 * \returns text of the specified word-like argument.
 */
CXString clang_BlockCommandComment_getArgText (CXComment Comment, uint ArgIdx);

/**
 * \param Comment a \c CXComment_BlockCommand or
 * \c CXComment_VerbatimBlockCommand AST node.
 *
 * \returns paragraph argument of the block command.
 */
CXComment clang_BlockCommandComment_getParagraph (CXComment Comment);

/**
 * \param Comment a \c CXComment_ParamCommand AST node.
 *
 * \returns parameter name.
 */
CXString clang_ParamCommandComment_getParamName (CXComment Comment);

/**
 * \param Comment a \c CXComment_ParamCommand AST node.
 *
 * \returns non-zero if the parameter that this AST node represents was found
 * in the function prototype and \c clang_ParamCommandComment_getParamIndex
 * function will return a meaningful value.
 */
uint clang_ParamCommandComment_isParamIndexValid (CXComment Comment);

/**
 * \param Comment a \c CXComment_ParamCommand AST node.
 *
 * \returns zero-based parameter index in function prototype.
 */
uint clang_ParamCommandComment_getParamIndex (CXComment Comment);

/**
 * \param Comment a \c CXComment_ParamCommand AST node.
 *
 * \returns non-zero if parameter passing direction was specified explicitly in
 * the comment.
 */
uint clang_ParamCommandComment_isDirectionExplicit (CXComment Comment);

/**
 * \param Comment a \c CXComment_ParamCommand AST node.
 *
 * \returns parameter passing direction.
 */
CXCommentParamPassDirection clang_ParamCommandComment_getDirection (
    CXComment Comment);

/**
 * \param Comment a \c CXComment_TParamCommand AST node.
 *
 * \returns template parameter name.
 */
CXString clang_TParamCommandComment_getParamName (CXComment Comment);

/**
 * \param Comment a \c CXComment_TParamCommand AST node.
 *
 * \returns non-zero if the parameter that this AST node represents was found
 * in the template parameter list and
 * \c clang_TParamCommandComment_getDepth and
 * \c clang_TParamCommandComment_getIndex functions will return a meaningful
 * value.
 */
uint clang_TParamCommandComment_isParamPositionValid (CXComment Comment);

/**
 * \param Comment a \c CXComment_TParamCommand AST node.
 *
 * \returns zero-based nesting depth of this parameter in the template parameter list.
 *
 * For example,
 * \verbatim
 *     template<typename C, template<typename T> class TT>
 *     void test(TT<int> aaa);
 * \endverbatim
 * for C and TT nesting depth is 0,
 * for T nesting depth is 1.
 */
uint clang_TParamCommandComment_getDepth (CXComment Comment);

/**
 * \param Comment a \c CXComment_TParamCommand AST node.
 *
 * \returns zero-based parameter index in the template parameter list at a
 * given nesting depth.
 *
 * For example,
 * \verbatim
 *     template<typename C, template<typename T> class TT>
 *     void test(TT<int> aaa);
 * \endverbatim
 * for C and TT nesting depth is 0, so we can ask for index at depth 0:
 * at depth 0 C's index is 0, TT's index is 1.
 *
 * For T nesting depth is 1, so we can ask for index at depth 0 and 1:
 * at depth 0 T's index is 1 (same as TT's),
 * at depth 1 T's index is 0.
 */
uint clang_TParamCommandComment_getIndex (CXComment Comment, uint Depth);

/**
 * \param Comment a \c CXComment_VerbatimBlockLine AST node.
 *
 * \returns text contained in the AST node.
 */
CXString clang_VerbatimBlockLineComment_getText (CXComment Comment);

/**
 * \param Comment a \c CXComment_VerbatimLine AST node.
 *
 * \returns text contained in the AST node.
 */
CXString clang_VerbatimLineComment_getText (CXComment Comment);

/**
 * Convert an HTML tag AST node to string.
 *
 * \param Comment a \c CXComment_HTMLStartTag or \c CXComment_HTMLEndTag AST
 * node.
 *
 * \returns string containing an HTML tag.
 */
CXString clang_HTMLTagComment_getAsString (CXComment Comment);

/**
 * Convert a given full parsed comment to an HTML fragment.
 *
 * Specific details of HTML layout are subject to change.  Don't try to parse
 * this HTML back into an AST, use other APIs instead.
 *
 * Currently the following CSS classes are used:
 * \li "para-brief" for \paragraph and equivalent commands;
 * \li "para-returns" for \\returns paragraph and equivalent commands;
 * \li "word-returns" for the "Returns" word in \\returns paragraph.
 *
 * Function argument documentation is rendered as a \<dl\> list with arguments
 * sorted in function prototype order.  CSS classes used:
 * \li "param-name-index-NUMBER" for parameter name (\<dt\>);
 * \li "param-descr-index-NUMBER" for parameter description (\<dd\>);
 * \li "param-name-index-invalid" and "param-descr-index-invalid" are used if
 * parameter index is invalid.
 *
 * Template parameter documentation is rendered as a \<dl\> list with
 * parameters sorted in template parameter list order.  CSS classes used:
 * \li "tparam-name-index-NUMBER" for parameter name (\<dt\>);
 * \li "tparam-descr-index-NUMBER" for parameter description (\<dd\>);
 * \li "tparam-name-index-other" and "tparam-descr-index-other" are used for
 * names inside template template parameters;
 * \li "tparam-name-index-invalid" and "tparam-descr-index-invalid" are used if
 * parameter position is invalid.
 *
 * \param Comment a \c CXComment_FullComment AST node.
 *
 * \returns string containing an HTML fragment.
 */
CXString clang_FullComment_getAsHTML (CXComment Comment);

/**
 * Convert a given full parsed comment to an XML document.
 *
 * A Relax NG schema for the XML can be found in comment-xml-schema.rng file
 * inside clang source tree.
 *
 * \param Comment a \c CXComment_FullComment AST node.
 *
 * \returns string containing an XML document.
 */
CXString clang_FullComment_getAsXML (CXComment Comment);

/**
 * @}
 */

/* CLANG_C_DOCUMENTATION_H */
