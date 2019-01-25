<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" 
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    queryBinding="xslt2">
    <ns uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
    <ns uri="urn:isbn:1-931666-22-9" prefix="ead"/>
    <!-- eventually, this file should test for all of the ASpace "EAD" requirements prior to import  
        (still need to figure what all of those are, including all undocumented data model constraints, etc.)
        
for the time being, i removed namespace checks so that the same rules will work for DTD and/or schema-associated files.
        
        still to add:
            dao stuff (must have title and href attributes?)
           something about field lengths (also need to test for length of title / unit ids, etc.)... if something is too long for the database, etc., like the 65k character limit :(
           what else???
        
        still to do:
           re-write the error messages!
           make sure that the error messages include everything needed
           pray that i can use xpath 2.0, as i've done here
           group and arrange this file like a semi-decent schematron file should actually be structured (and learn how to do that!)
           
    -->
    
    <pattern>
        <rule context="*:archdesc">
            <assert test="@level">You must supply a level attribute at the resource level</assert>
        </rule>
        <rule context="*:archdesc/*:did">
            <assert test="*:unittitle[normalize-space()]">You must supply a
                title at the resource level</assert>               
            <assert test="descendant::*:unitdate[normalize-space()] or descendant::*:unitdate[@normal]"
                >You must supply a date at the resource level (including as child of unittitle)</assert>
            <assert test="*:unitid[normalize-space()][not(@audience='internal')][1]">You must supply an
                identifier at the resource level</assert>
            <assert test="*:physdesc/*:extent[normalize-space()][1]">You must
                supply an extent statement at the resource level. This should be formatted with an
                extent number and an extent type, like so: "3.25 cubic meters"</assert>
            <!-- is ASpace (like the AT) fine with this value just being in physdesc?  if so, then update this check.  or, make ASpace more strict, so that folks can still 
            import generic physdesc notes at the resource level.-->
            <assert test="*:physdesc/*:extent[1][matches(normalize-space(.), '\D')]">
                The extent statement must contain more than just an extent number. If you're making use of the 
                @unit attribute, you would probably be safe in copying that value to the end of the extent's 
                text node (e.g. @unit="Linear Feet", 5...  could be changed to
                @unit="Linear Feet", 5 Linear Feet)
            </assert>
            <assert test="*:physdesc/*:extent[1][matches(normalize-space(.), '\s')][matches(normalize-space(.), '^\d')]">
                The extent statement must start with a number and it must also have at least one space present.
                (e.g. "5 Linear Feet" is a valid value, but "5items" is not).
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="*:unitid">
            <assert test="not(@audience='internal')">ArchivesSpace has no concept of an unpublished identifier, yet this component has an internal-only identifier.  Please verify that the input file is correct.</assert>
            <assert test="not(contains(@type, 'Database::'))">Woah. Looks like an internal-only AT or Aeon database ID is going to be imported as a published component unique identifier. Those should be removed.</assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="*:unitdate[contains(@normal, '/')]">
            <!-- this will work for most cases, but it's not going to catch if someone inputs a date like 2010-02-30...
                the EAD2002 schema also won't pick that particular error up (and it sounds like EAD3 is doing away with all of those sorts of validations!)  
            to correct that here, i'd just need to analye the string and set year, month, and day values for each begin and end dates to do the validtion.
            i assume that's worth doing?
            -->
            <let name="begin_date" value="substring-before(@normal, '/')"/>
            <let name="end_date" value="substring-after(@normal, '/')"/>
            <assert test="replace($end_date, '-', '') >= replace($begin_date, '-', '')">The date
                normalization value for this field needs to be updated. The first date, <value-of
                    select="$begin_date"/>, is encoded as occurring <span class="italic"
                        >before</span> the end date, <value-of select="$end_date"/>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="*[@level ='otherlevel']">
            <assert test="@otherlevel">If the value of a level attribute is "otherlevel', then you
                must specify the value of the otherlevel attribute</assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="*:c/*:did | *[matches(local-name(), '^c0|^c1')]/*:did">
            <assert test="parent::*/@level">You must specify a level attribute at every level of
                description</assert>
            <assert
                test="*:unittitle[normalize-space()]  or descendant::*:unitdate[normalize-space()] or descendant::*:unitdate[@normal]"
                > You must specify either a title or a date when describing archival components
                (this is a requirement enforced by the AchivesSpace data model, not by EAD)</assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="*:c/*:did/*:physdesc/*:extent[1] | *[matches(local-name(), '^c0|^c1')]/*:did/*:physdesc/*:extent[1]">
            <assert test="matches(normalize-space(.), '\D')">
                The extent statement should contain more than just an extent number since ArchivesSpace will not import
                any extent attribute values. If you're making use of the 
                @unit attribute, you would probably be safe in copying that value to the end of the extent's 
                text node (e.g. @unit="Linear Feet", 5...  could be changed to
                @unit="Linear Feet", 5 Linear Feet)
            </assert>  
        </rule>
    </pattern>
    
    <pattern>
        <rule context="*:archdesc//*:c | *:archdesc//*[matches(local-name(), '^c0|c1' )]">
            <report test="*:note">The ArchivesSpace EAD importer will silently drop note elements. Please convert these to "odd" elements.</report>
            <!--
                figure out how to do the replacements directly in oXygen.
                something like:
                sqf:fix="replaceNote"
            <sqf:fix id="replaceNote">
                <sqf:description>
                    <sqf:title>Change the note element to an odd element</sqf:title>
                </sqf:description>
                <sqf:replace match="*:note" node-type="element" target="ead:odd" select=".">
<sqf:keep/>                    
                </sqf:replace>
            </sqf:fix>
            -->
        </rule>    

    </pattern>

    <!-- doesn't seem to be needed in the newest version
    <pattern>
        <rule context="text()">
            <report test="matches(., '’|“|”')">
                Smart quote detected. These characters need to be replaced before importing your files
                into ArchivesSpace.
            </report>
        </rule>
    </pattern>
    -->
    <!-- need to get a list of invalid characters, if any still cause the importer problems.-->
    

    
    <!-- rather than include this rule, the EAD importer shoud only use the container/@id values during import if there is more than 1 @id per archival component-->
    <pattern>
        <rule context="*:container[not(@parent)]">
            <assert test="@id">In order to ensure that your container elements import properly, you should assign id attributes for each container grouping per archival component</assert>
        </rule>
    </pattern>
    <pattern>
        <rule context="*:container">
            <assert test="@type">A container type value ("Box", "Folder", etc.) is required for a container element to be imported.</assert>
        </rule>
    </pattern>
    
    <!-- what other elements need to be matched here, since ASpace doesn't ignore empty elements? -->
    <pattern>
        <rule context="*:unitdate">
            <assert test="normalize-space() or @normal">The ArchivesSpace importer won't skip over empty elements, so if you use this value, you must provide a date (either as text or an attribute value)</assert>
        </rule>
    </pattern>

</schema>
