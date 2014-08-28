xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

<div>
{
    for $person in collection("../xml/tei?select=*.xml")//tei:person
    for $date in $person/*
    where $date/@notBefore and empty($date/@notAfter)
    let $id := $person/@xml:id
    return 
        <date xml:id="{$id}" type="{name($date)}">{string($date)}</date>
    
}
</div>