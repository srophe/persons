xquery version "3.1";

declare namespace TEI = "http://www.tei-c.org/ns/1.0";

(: for each row/record in the zoteroid file :)
for $row in fn:doc("zoteroid-insert/zoteroid.xml")/root/row
let $author := $row/authorabbr/text()
let $title := $row/titleabbr/text()
let $zoteroid := $row/zotero/text()

(: for each person record with unmatched title and no author :)
for $biblnoauthor in fn:collection("zoteroid-insert")//TEI:person/TEI:bibl[not(TEI:ptr) and not(TEI:author)]
let $bibltitlenoauthor := $biblnoauthor/TEI:title/text()
let $biblcitedrange := $biblnoauthor/TEI:citedRange/text()

(: for each person record with unmatched author and title :)
for $biblwauthor in fn:collection("zoteroid-insert")//TEI:person/TEI:bibl[not(TEI:ptr) and TEI:author]
let $bibltitlewauthor := $biblwauthor/TEI:title/text()
let $biblauthor := $biblwauthor/TEI:author/text()

where $bibltitlenoauthor = $title

return 
  insert node attribute n {$biblcitedrange} into $bibltitlenoauthor
