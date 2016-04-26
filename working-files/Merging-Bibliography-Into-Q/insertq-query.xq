xquery version "3.1";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

for $bibl in fn:collection("Saints-Bibliography")//TEI:bibl
let $bibltitle := $bibl/TEI:title/text()
let $biblauthor := $bibl/TEI:author/text()

for $row in fn:doc("Saints-Bibliography/zoteroid.xml")/root/row
let $author := $row/authorabbr/text()
let $title := $row/titleabbr/text()

where $bibltitle = $title

return element pair {attribute doc{fn:base-uri($bibltitle[1])},($bibltitle, $title)}