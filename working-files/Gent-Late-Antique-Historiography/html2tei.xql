xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace syriaca = "http://syriaca.org";
declare namespace functx = "http://www.functx.com";

let $doc := doc('/Users/nathan/Documents/Employment/Syriaca/srophe/persons/working-files/Gent-Late-Antique-Historiography/authors-from-lah.xml')
for $person in $doc/root/ul/li
    let $person-link := $person/descendant::a[contains(@href,'authors')]
    let $person-id := replace($person-link/@href,'http://www.late-antique-historiography.ugent.be/database/authors/','')
    let $person-doc := doc(concat('http://www.late-antique-historiography.ugent.be/database/authors/',$person-id))
    let $persNames := 
        for $name in $person//div[@class='field field-other-names' or @class='field field-name']//span
        return <persName xml:lang="{$name/@class}">{$name/text()}</persName>
    let $works := 
        for $work in $person//div[@class='field field-works']//a/@href
        return <relation name="dc:creator" active="{$person-link/@href}" passive="{$work}"/>
return 
    <tei:person>
    {$persNames}
    <idno type="LAH">{$person-id}</idno>
    <idno type="URI"/>
    {$works}
    </tei:person>
    
    (:
    Would like to insert the following, but can't b/c Oxygen thinks the document is malformed
    <date>{$person-doc//div[@class='field field-date']/div[@class='field-items']}</date>
    :)