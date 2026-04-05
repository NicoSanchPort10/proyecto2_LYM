module Verilang::Highlight

import IO;
import ParseTree;
import String;
import Verilang::Load;

public map[str, str] htmlEscapes = (
  "\<": "&lt;",
  "\>": "&gt;",
  "&" : "&amp;"
);

str highlightHTML(str src)
  = highlightTreeHTML(loadParseTree(src));

str highlightHTML(loc src)
  = highlightTreeHTML(loadParseTree(src));

str highlightTreeHTML(Tree t)
  = "\<pre class=\"verilang\"\>\<code\><trim(renderHTMLRec(t))>\</code\>\</pre\>";

bool isKeywordToken(str s)
  = /^[a-zA-Z0-9_\-]*$/ := s;

str renderHTMLRec(t:appl(prod(lit(str l), _, _), _))
  = span("Keyword", l)
  when isKeywordToken(l);

str renderHTMLRec(t:appl(prod(cilit(str l), _, _), _))
  = span("Keyword", l)
  when isKeywordToken(l);

str renderHTMLRec(t:appl(prod(_, _, {*_, \tag("category"(str cat))}), list[Tree] as))
  = span(cat, ("" | it + renderHTMLRec(a) | a <- as));

str renderHTMLRec(appl(prod(_, _, set[Attr] attrs), list[Tree] as))
  = ("" | it + renderHTMLRec(a) | a <- as)
  when {*_, \tag("category"(str _))} !:= attrs;

str renderHTMLRec(appl(regular(_), list[Tree] as))
  = ("" | it + renderHTMLRec(a) | a <- as);

str renderHTMLRec(amb({k, *_}))
  = renderHTMLRec(k);

default str renderHTMLRec(Tree t)
  = escape(unparse(t), htmlEscapes);

str span(str class, str src)
  = "\<span class=\"<class>\"\><src>\</span\>";

void writeHighlightedHTML(loc src, loc target) {
  writeFile(target, highlightHTML(src));
}
