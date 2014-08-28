xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

<div>
{
    for $relation in collection("../xml/tei?select=*.xml")//tei:relation
    return 
        <relation name="{$relation/@name}" type="{$relation/@type}"/>
    
}
</div>