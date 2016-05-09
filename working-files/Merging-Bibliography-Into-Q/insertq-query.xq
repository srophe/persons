xquery version "3.1";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

for $bibl in fn:collection("saints/tei")//TEI:person/TEI:bibl[not(TEI:ptr)]
let $bibltitle := $bibl/TEI:title/text()
let $biblauthor := $bibl/TEI:author/text()

for $row in fn:doc("saints/zoteroid.xml")/root/row
let $author := $row/authorabbr/text()
let $title := $row/titleabbr/text()

return $author
