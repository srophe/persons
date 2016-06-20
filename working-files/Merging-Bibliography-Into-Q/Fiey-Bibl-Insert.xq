declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: for each row/record in the zoteroid file where there is no text node for the element uritype :)
for $row in fn:doc("zoteroid/zoteroid.xml")/root/row[not(uritype/text())]
let $author := $row/authorabbr/text()
let $title := $row/titleabbr/text()
let $zoteroid := $row/zotero/text()

(: for each zotero idno in Syriaca.org bibl records:)
(: Get bibl uri:)
let $biblURI := 
              for $biblfile in fn:collection("bibl")//tei:idno[@type="zotero"][. = $zoteroid]
              let $uri := replace($biblfile/ancestor::tei:TEI/descendant::tei:publicationStmt/descendant::tei:idno[@type="URI"][starts-with(.,'http://syriaca.org/')]/text(),'/tei','')
              return $uri
return 
  if(count($biblURI gt 1)) then (<zotero-id>{$zoteroid}</zotero-id>, <bibl-id>{$uri}</bibl-id>) 
  else   
    (: for bibl records in each person record without a bibl URI :)
    for $bibl in fn:collection("saints")//tei:person/tei:bibl[not(tei:ptr)]
    let $bibltitle := $bibl/tei:title/text()
    let $biblauthor := $bibl/tei:author/text()
    let $biblcitedrange := $bibl/tei:citedRange/text()
  
    where $bibltitle = $title and $biblauthor = $author
  
    return 
    $bibl
