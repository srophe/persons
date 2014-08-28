xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

<div>
{
    for $name-part in collection("../xml/tei?select=*.xml")//tei:persName/*
    where name($name-part) = 'addName' and $name-part/@type != 'family'
    let $type := $name-part/@type
    return 
        <roleName type="{$type}">{string($name-part)}</roleName>
    
}
</div>