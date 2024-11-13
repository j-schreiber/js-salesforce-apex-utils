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
    private List<ISObjectTreeRecordsFactory> factories;

    public SObjectTreeBranchOperation(SObjectTreeLoader SObjectTreeLoaderTransation, ExtendedDescribeSObjectResult sObjectDescribe) {
        this.sObjectDescribe = sObjectDescribe;
        this.SObjectTreeLoaderTransation = SObjectTreeLoaderTransation;
        this.recordPrototypes = new Map<String, SObjectTreeRecord>();
        this.bypassTriggers = false;
        this.resolveReferences = true;
        this.factories = new List<ISObjectTreeRecordsFactory>();
    }

    //          BUILDER API

    /**
     * Queries a source file by its name and adds it to the operation.
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
     * Adds a source file to this operation. All records in all files
     * will be merged and reference ids are checked for uniqueness.
     *
     * @param sourceFile
     * @return  `SObjectTreeBranchOperation`
     */
    public SObjectTreeBranchOperation addSourceFile(StaticResource sourceFile) {
        Map<String, SObjectTreeRecord> extractedPrototypes = this.deserializeSourceFile(sourceFile);
        this.storePrototypes(extractedPrototypes, sourceFile.Name);
        return this;
    }

    /**
     *
     *
     * @param recordFactory
     * @return  `SObjectTreeBranchOperation`
     */
    public SObjectTreeBranchOperation addFactory(ISObjectTreeRecordsFactory recordFactory) {
        this.factories.add(recordFactory);
        // Map<String, SObjectTreeRecord> prototypes = new Map<String, SObjectTreeRecord>();
        // Map<String, SObject> records = recordFactory.getRecords(this.getSObjectTreeLoader());
        // for (String recordReferenceId : records.keySet()) {
        //     prototypes.put(recordReferenceId, new SObjectTreeRecord(records.get(recordReferenceId), this));
        // }
        // this.storePrototypes(prototypes, ApexTypeUtils.getTypeNameFromInstance(recordFactory));
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
        for (SObjectTreeRecord dlr : this.getTreeRecords().values()) {
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

    public Map<String, SObjectTreeRecord> getTreeRecords() {
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
        for (SObjectTreeRecord dlr : this.getTreeRecords().values()) {
            records.add(dlr.resolve(this.resolveReferences));
        }
        this.resolveFactoriesToList(records);
        return records;
    }

    //          PRIVATE ZONE

    private void resolveFactoriesToList(List<SObject> records) {
        // factories are only resolved once
        for (Integer i = this.factories.size() - 1; i >= 0; i--) {
            Map<String, SObjectTreeRecord> prototypes = new Map<String, SObjectTreeRecord>();
            Map<String, SObject> factoryRecords = this.factories[i].getRecords(this.getSObjectTreeLoader());
            for (String recordReferenceId : factoryRecords.keySet()) {
                prototypes.put(recordReferenceId, new SObjectTreeRecord(factoryRecords.get(recordReferenceId), this));
            }
            this.storePrototypes(prototypes, ApexTypeUtils.getTypeNameFromInstance(this.factories[i]));
            records.addAll(factoryRecords.values());
            this.factories.remove(i);
        }
    }

    private void storePrototypes(Map<String, SObjectTreeRecord> prototypes, String sourceName) {
        this.assertUniquenessAccrossAllOperations(prototypes.keySet(), sourceName);
        this.assertSObjectType(prototypes);
        this.recordPrototypes.putAll(prototypes);
    }

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

    private void assertUniquenessAccrossAllOperations(Set<String> keyValues, String sourceName) {
        Set<String> existingKeysInOtherOps = this.SObjectTreeLoaderTransation.getRecordsBySObjectType(this.getSObjectType()).keySet();
        for (String newKey : keyValues) {
            if (existingKeysInOtherOps.contains(newKey)) {
                throwUniquenessConstraintException(newKey, sourceName);
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

    private void assertSObjectType(Map<String, SObjectTreeRecord> recordPrototypes) {
        for (SObjectTreeRecord proto : recordPrototypes.values()) {
            if (proto.getSObjectType() == null) {
                continue;
            }
            if (proto.getSObjectType() != this.getSObjectType()) {
                throw new SObjectTreeLoaderException(
                    String.format(
                        System.Label.Incompatible_SObject_Type_In_Source_File_Added_To_Operation,
                        new List<Object>{ this.getSObjectType(), proto.getSObjectType() }
                    )
                );
            }
        }
    }
}
