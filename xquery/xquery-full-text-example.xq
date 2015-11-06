declare namespace tei = "http://www.tei-c.org/ns/1.0";
for $x in collection("/Users/nathan/Documents/Employment/Syriac Reference Portal/srophe/persons/xml/tei")
let $y := $x//tei:persName[. contains text "Ephrem"]
where $y!=''
order by $x//Floruit
return $y