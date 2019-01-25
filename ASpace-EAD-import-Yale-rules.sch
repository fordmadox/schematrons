<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" 
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    queryBinding="xslt2">
    <ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
    <ns uri="urn:isbn:1-931666-22-9" prefix="ead"/>
    
    <!-- thinking about some yale-specific rules to this file, but haven't cataloged what those should be just yet -->
    
    <pattern>
        <rule context="*:container[@label]">
            <assert test="lower-case(@label) ne 'mixed_materials ()'">Looks like this container didn't match any item records at all.</assert>
            <assert test="string-length(replace(@label, '\D', '')) eq 14">The barcode must be 14 digits in length.</assert>
        </rule>
    </pattern>
    
    <!-- no longer need to add the bib number here, so don't worry about it
    <pattern>
        <rule context="*:eadheader/*:filedesc/*:notestmt/*:note[@type='bpg']/*:p/*:num[@type='Orbis-bib']">
            <assert test="normalize-space(.)">The bib ID is missing.  Check the master file to make sure it's in the list.</assert>
        </rule>
    </pattern>
    -->
    
</schema>