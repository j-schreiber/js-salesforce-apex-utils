/**
 * A initialised import operation, as specified in the data loader plan file.
 * Operations can only be instantiated and accessed from a data loader instance.
 *
 * @author Jannis Schreiber
 * @group Apex Data Loader
 */
public class SObjectTreeBranchOperation {
    private ExtendedDescribeSObjectResult sObjectDescribe;
    private Map<String, SObjectTreeRecord> recordPrototypes;
    private Boolean bypassTriggers;
    private Boolean resolveReferences;
    SObjectTreeLoader SObjectTreeLoaderTransation;

    public SObjectTreeBranchOperation(SObjectTreeLoader SObjectTreeLoaderTransation, ExtendedDescribeSObjectResult sObjectDescribe) {
        this.sObjectDescribe = sObjectDescribe;
        this.SObjectTreeLoaderTransation = SObjectTreeLoaderTransation;
        this.recordPrototypes = new Map<String, SObjectTreeRecord>();
        this.bypassTriggers = false;
        this.resolveReferences = true;
    }

    //          BUILDER API

    /**
     * Adds a source file to the import operation.
     *
     * @param sourceFileName
     * @return  `SObjectTreeBranchOperation`
     */
    public SObjectTreeBranchOperation addSourceFile(String sourceFileName) {
        StaticResource sourceFile = (StaticResource) ApexCache.JsonStaticResources.get(sourceFileName);
        if (sourceFile == null) {
            throw new QueryException(String.format(System.Label.No_Records_File_Found_For_Name, new List<Object>{ sourceFileName }));
        }
        return this.addSourceFile(sourceFile);
    }

    /**
     * Adds an addition source file to this operation. All records in all files
     * will be merged and reference ids are checked for uniqueness.
     *
     * @param sourceFile
     * @return  `SObjectTreeBranchOperation`
     */
    public SObjectTreeBranchOperation addSourceFile(StaticResource sourceFile) {
        Map<String, SObjectTreeRecord> extractedPrototypes = this.deserializeSourceFile(sourceFile);
        this.assertUniquenessAccrossAllOperations(extractedPrototypes.keySet(), sourceFile);
        this.recordPrototypes.putAll(extractedPrototypes);
        return this;
    }

    /**
     * Overrides the `bypassTriggers` flag from import definition
     *
     * @param bypassValue
     * @return  `SObjectTreeBranchOperation`
     */
    public SObjectTreeBranchOperation setBypassTriggers(Boolean bypassValue) {
        if (bypassValue == null) {
            bypassValue = false;
        }
        this.bypassTriggers = bypassValue;
        return this;
    }

    /**
     * Overrides the field value for all prototypes in this operation.
     *
     * @param fieldToken
     * @param fieldValue
     * @return  `SObjectTreeBranchOperation`
     */
    public SObjectTreeBranchOperation setField(Schema.SObjectField fieldToken, Object fieldValue) {
        for (SObjectTreeRecord dlr : this.getPrototypes().values()) {
            dlr.putValue(fieldToken, fieldValue);
        }
        return this;
    }

    /**
     * Override the flag to resolve references. If this is set to false (default is true),
     * all references to other records in the source files and prototypes are ignored.
     * Ids that are populated directly (not with "@" notation) are still inserted.
     *
     * @param newValue
     * @return  `SObjectTreeBranchOperation`
     */
    public SObjectTreeBranchOperation setResolveRefs(Boolean newValue) {
        this.resolveReferences = newValue;
        return this;
    }

    /**
     * Returns the parent data loader instance, of this import operation
     *
     * @return  `SObjectTreeLoader`
     */
    public SObjectTreeLoader getSObjectTreeLoader() {
        return this.SObjectTreeLoaderTransation;
    }

    //          PUBLIC API

    public List<SObject> run() {
        List<SObject> records = this.getRecords();
        if (this.bypassTriggers) {
            Triggers.disableSObject(this.getSObjectType());
        }
        insert records;
        if (this.bypassTriggers) {
            Triggers.enableSObject(this.getSObjectType());
        }
        return records;
    }

    public Map<String, SObjectTreeRecord> getPrototypes() {
        return this.recordPrototypes;
    }

    public Schema.SObjectType getSObjectType() {
        return this.getDescribe().getToken();
    }

    public ExtendedDescribeSObjectResult getDescribe() {
        return this.sObjectDescribe;
    }

    public List<SObject> getRecords() {
        String listType = 'List<' + this.getSObjectType() + '>';
        List<SObject> records = (List<SObject>) Type.forName(listType).newInstance();
        for (SObjectTreeRecord dlr : this.getPrototypes().values()) {
            records.add(dlr.resolve(this.resolveReferences));
        }
        return records;
    }

    //          PRIVATE ZONE

    private Map<String, SObjectTreeRecord> deserializeSourceFile(StaticResource sourceFile) {
        Map<String, SObjectTreeRecord> prototypes = new Map<String, SObjectTreeRecord>();
        Map<String, Object> fileBody = (Map<String, Object>) JSON.deserializeUntyped(sourceFile.Body.toString());
        List<Object> records = (List<Object>) fileBody.get('records');
        for (Object rawRecord : records) {
            this.assertAttributesIntegrity((Map<String, Object>) rawRecord, records.indexOf(rawRecord), sourceFile.Name);
            SObjectTreeRecord dlr = new SObjectTreeRecord((Map<String, Object>) rawRecord, this);
            if (prototypes.containsKey(dlr.getReferenceKey())) {
                this.throwUniquenessConstraintException(dlr.getReferenceKey(), sourceFile.Name);
            }
            prototypes.put(dlr.getReferenceKey(), dlr);
        }
        return prototypes;
    }

    private void assertUniquenessAccrossAllOperations(Set<String> keyValues, StaticResource sourceFile) {
        Set<String> existingKeysInOtherOps = this.SObjectTreeLoaderTransation.getRecordsBySObjectType(this.getSObjectType()).keySet();
        for (String newKey : keyValues) {
            if (existingKeysInOtherOps.contains(newKey)) {
                throwUniquenessConstraintException(newKey, sourceFile.Name);
            }
        }
    }

    private void throwUniquenessConstraintException(String keyValue, String sourceFileName) {
        throw new SObjectTreeLoaderException(
            String.format(
                System.Label.Ambiguous_Reference_Key_For_SObject_In_Source_Files,
                new List<Object>{ keyValue, this.getSObjectType(), sourceFileName }
            )
        );
    }

    private void assertAttributesIntegrity(Map<String, Object> rawRecordBody, Integer index, String fileName) {
        if (rawRecordBody.get('attributes') == null || !(rawRecordBody.get('attributes') instanceof Map<String, Object>)) {
            throw new SObjectTreeLoaderException(
                String.format(System.Label.Test_Record_Has_No_Valid_Attributes, new List<Object>{ fileName, index + 1 })
            );
        }
        Map<String, Object> recordAttributes = (Map<String, Object>) rawRecordBody.get('attributes');
        if (!(recordAttributes.get('referenceId') instanceof String) || String.isBlank((String) recordAttributes.get('referenceId'))) {
            throw new SObjectTreeLoaderException(
                String.format(System.Label.Test_Record_Has_No_Reference_Key, new List<Object>{ fileName, index + 1 })
            );
        }
    }
}
