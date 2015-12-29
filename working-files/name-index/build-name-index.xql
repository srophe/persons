xquery version "3.0";

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace functx = "http://www.functx.com";
declare namespace syriaca = "http://syriaca.org";
declare variable $names-db := 
    let $collection-uri := '/db/apps/srophe-data/data/names/tei/'
    let $file-name := 'forenames-all.xml'
    let $file-contents := '<?xml version="1.0" encoding="UTF-8"?><TEI xmlns="http://www.tei-c.org/ns/1.0"></TEI>'
    return
        (:($collection-uri, $file-name, syriaca:build-tei($bibl) ):)
        doc(xmldb:store($collection-uri, xmldb:encode-uri($file-name), $file-contents));

declare function syriaca:add-nameset ($names-to-add as node()*) as node()* {
    let $names-db-tei := $names-db/TEI
    return 
        update insert $names-to-add into $names-db-tei
};

declare function syriaca:update-nameset ($names-to-add as node()*,$matching-nameset as node()*) as node()* {
    let $names-db-tei := $names-db/TEI
(:    let $old-nameset := $names-db-tei/persName[forename[$pos]]:)
    let $new-nameset := element persName {functx:distinct-deep(($names-to-add/forename, $matching-nameset/forename))}
    return
        (
            update insert $new-nameset following $matching-nameset,
            update delete $matching-nameset
        )
};

declare function functx:distinct-deep
  ( $nodes as node()* )  as node()* {

    for $seq in (1 to count($nodes))
    return $nodes[$seq][not(functx:is-node-in-sequence-deep-equal(
                          .,$nodes[position() < $seq]))]
 } ;
 
declare function functx:is-node-in-sequence-deep-equal
  ( $node as node()? ,
    $seq as node()* )  as xs:boolean {

   some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
 } ;


(: does this get all persons? :)
let $uri := '/db/apps/srophe-data/data/persons/tei/*.xml'
let $persons := collection(doc($uri))//TEI/text/body/listPerson/person


for $person in $persons
    let $all-person-forenames := 
        element persName {
            for $name in $person/persName
            return
                if ($name/forename) then
                    element forename {$name/@xml:lang,$name/forename/text()}
                    else ()
        }
    return
        let $index := 
            for $forename in $all-person-forenames/forename
            let $matching-nameset := $names-db/TEI/persName[forename=$forename]
            return $matching-nameset
        return 
            if ($index) then
                syriaca:update-nameset($all-person-forenames,$index)
                else syriaca:add-nameset($all-person-forenames)
