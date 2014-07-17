xquery version "3.0";

declare namespace tei="http://www.tei-c.org/ns/1.0";

<div>
{
    for $person in collection("/apps/persons/data/tei")//tei:persName[child::text()]
    let $mistake := string-join($person/text(),' ')
    let $uri := string($person/parent::tei:person/@xml:id)
    let $persNumber := string($person/@xml:id)
    let $source := $person/@source
    let $bibl :=
        if($person/parent::tei:person/tei:bibl[tei:ptr[ends-with(@target,'bibl/5')]]) then concat('#',string($person/parent::tei:person/tei:bibl[tei:ptr[ends-with(@target,'bibl/5')]]/@xml:id))
        else ''
    where $source != $bibl or $person[not(@source)]
    order by $mistake
    return
        if($mistake = ", ") then ()
        else        <item file="{$uri}" persName="{$persNumber}">{$mistake}</item>
    
}
</div>