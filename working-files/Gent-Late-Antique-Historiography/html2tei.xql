xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace http = "http://w3c.org" ;
declare namespace syriaca = "http://syriaca.org";
declare namespace functx = "http://www.functx.com";

let $doc := doc('/Users/nathan/Documents/Employment/Syriaca/srophe/persons/working-files/Gent-Late-Antique-Historiography/authors-from-lah.xml')
for $person in $doc/root/ul/li
    let $person-link := $person/descendant::a[contains(@href,'authors')]
    let $person-id := replace($person-link/@href,'http://www.late-antique-historiography.ugent.be/database/authors/','')
    let $person-doc :=
http:send-request(
<http:request href="http://www.late-antique-historiography.ugent.be/database/authors/283/" method="get">
</http:request>)//*:div[@id='content']
    let $persNames := 
        for $name in $person//div[@class='field field-other-names' or @class='field field-name']//span
        let $lang :=
            if(matches($name,'[ܐ-ܬ]')) then
                'syr'
            else if(matches($name,'[ا-و]')) then
                'ar'
            else if(matches($name,'[α-ω]')) then
                'grc'
            else if(matches($name,'[ա-և]')) then
                'hy'    
            else if($name/@class='english') then
                'en'
            else if($name/@class!='transliteration') then
                'la'
            else ()
        return element persName { if($name/@class!='transliteration') then attribute xml:lang {$lang} else (), attribute type {$name/@class}, normalize-space($name/text())}
        
        (:<persName xml:lang="{$lang}" type="{$name/@class}">{normalize-space($name/text())}</persName>:)
    let $works := 
        for $work in $person//div[@class='field field-works']//a/@href
        return <relation name="dc:creator" active="{$person-link/@href}" passive="{$work}"/>
return 
    <tei:person>
    {$persNames}
    <idno type="LAH">{$person-id}</idno>
    <idno type="URI"/>
    {$works}
    <date>{$person-doc//div[@class='field field-date']/div[@class='field-items']}</date>
    </tei:person>
    
    
    
    
    