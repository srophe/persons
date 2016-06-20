xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: for each row/record in the zoteroid file where there is no text node for the element uritype :)
for $row in fn:doc("saints/zoteroid.xml")/root/row[not(uritype/text())]
let $author := $row/authorabbr/text()
let $title := $row/titleabbr/text()
let $zoteroid := $row/zotero/text()

(: for each zotero idno in Syriaca.org bibl records:)
for $biblfile in fn:collection("bibl/tei")
let $zoteroidno := $biblfile//tei:text//tei:idno[@type="zotero"]/text()
let $biblURI := $biblfile//tei:text//tei:idno[@type="URI"][1]/text()

(: for bibl records in each person record without a bibl URI :)
for $bibl in fn:collection("saints")//tei:person/tei:bibl[not(tei:ptr)]
let $bibltitle := $bibl/tei:title/text()
let $biblauthor := $bibl/tei:author/text()
let $biblcitedrange := $bibl/tei:citedRange/text()

where $bibltitle = $title and $biblauthor = $author

return 
  
