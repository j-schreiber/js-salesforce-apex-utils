/**
 * The data loader holds a list of import operations. Use the API to manipulate
 * existing operations or add new operations.
 *
 * @author Jannis Schreiber
 * @group Apex Data Loader
 */
global without sharing class SObjectTreeLoader {
    private List<SObjectTreeBranchOperation> importOperations;
    private Map<String, SObjectTreeBranchOperation> namedOperations;

    public SObjectTreeLoader() {
        this.importOperations = new List<SObjectTreeBranchOperation>();
        this.namedOperations = new Map<String, SObjectTreeBranchOperation>();
    }

    //              BUILDER API

    /**
     * Execute all operations in designated order. This executes one DML per
     * import operation.
     *
     * @return  `SObjectTreeLoader`
     */
    global SObjectTreeLoader executePlan() {
        for (SObjectTreeBranchOperation importOp : this.getOperations()) {
            importOp.run();
        }
        return this;
    }

    //              PUBLIC API

    /**
     * Add a blank operation to the end of the plan.
     *
     * @param typeOfOperation
     * @return  `SObjectTreeBranchOperation`
     */
    public SObjectTreeBranchOperation addOperation(Schema.SObjectType typeOfOperation) {
        return addOperation(typeOfOperation, null);
    }

    /**
     * Add a blank operation to the end of the plan and specify an operation name.
     *
     * @param typeOfOperation
     * @param operationName
     * @return  `SObjectTreeBranchOperation`
     */
    public SObjectTreeBranchOperation addOperation(Schema.SObjectType typeOfOperation, String operationName) {
        SObjectTreeBranchDefinition def = new SObjectTreeBranchDefinition();
        def.operationName = operationName;
        def.sobjectName = String.valueOf(typeOfOperation);
        def.files = new List<String>();
        def.resolveRefs = true;
        def.bypassTriggers = false;
        return addOperation(def);
    }

    /**
     * Initialise and add a operation based on a complex definition.
     *
     * @param branchDef
     * @return  `SObjectTreeBranchOperation`
     */
    public SObjectTreeBranchOperation addOperation(SObjectTreeBranchDefinition branchDef) {
        SObjectTreeBranchOperation op = new SObjectTreeBranchOperation(this, ExtendedSchema.describeSObject(branchDef.sobjectName));
        if (branchDef.files != null) {
            for (String sourceFileName : branchDef.files) {
                op.addSourceFile(sourceFileName);
            }
        }
        if (branchDef.factories != null) {
            for (String factoryName : branchDef.factories) {
                op.addFactory(
                    (ISObjectTreeRecordsFactory) ApexTypeUtils.initializeInstanceFromName(factoryName, ISObjectTreeRecordsFactory.class)
                );
            }
        }
        op.setBypassTriggers(branchDef.bypassTriggers);
        if (branchDef.resolveRefs != null) {
            op.setResolveRefs(branchDef.resolveRefs);
        }
        this.importOperations.add(op);
        this.putNamedOperation(branchDef.operationName, op);
        return op;
    }

    /**
     * Returns all import operations in order of execution
     *
     * @return  `List<SObjectTreeBranchOperation>`
     */
    public List<SObjectTreeBranchOperation> getOperations() {
        return this.importOperations;
    }

    /**
     * Aggregates records by sobject type and returns the prototypes.
     *
     * @param sobjectType
     * @return  `Map<String, SObjectTreeRecord>`
     */
    public Map<String, SObjectTreeRecord> getRecordsBySObjectType(Schema.SObjectType sobjectType) {
        Map<String, SObjectTreeRecord> allRecords = new Map<String, SObjectTreeRecord>();
        for (SObjectTreeBranchOperation op : this.filterOperationsByType(sobjectType)) {
            allRecords.putAll(op.getTreeRecords());
        }
        return allRecords;
    }

    /**
     * All named operations
     *
     * @return  `Map<String, SObjectTreeBranchOperation>`
     */
    public Map<String, SObjectTreeBranchOperation> getNamedOperations() {
        return this.namedOperations;
    }

    /**
     *
     *
     * @param operationName
     * @return  `SObjectTreeBranchOperation`
     * @exception
     */
    public SObjectTreeBranchOperation getOperation(String operationName) {
        if (!this.namedOperations.containsKey(operationName)) {
            throw new SObjectTreeLoaderException(
                String.format(System.Label.Unknown_Operation_Name_Requested, new List<Object>{ operationName })
            );
        }
        return this.namedOperations.get(operationName);
    }

    //          PRIVATE ZONE

    private void putNamedOperation(String operationName, SObjectTreeBranchOperation op) {
        if (String.isNotBlank(operationName)) {
            if (this.namedOperations.containsKey(operationName)) {
                Integer index = this.getOperations().indexOf(this.namedOperations.get(operationName));
                throw new SObjectTreeLoaderException(
                    String.format(System.Label.Operation_Name_Already_Exists_In_Plan, new List<Object>{ operationName, index + 1 })
                );
            }
            this.namedOperations.put(operationName, op);
        }
    }

    private List<SObjectTreeBranchOperation> filterOperationsByType(Schema.SObjectType sobjectType) {
        List<SObjectTreeBranchOperation> filteredOps = new List<SObjectTreeBranchOperation>();
        for (SObjectTreeBranchOperation op : this.getOperations()) {
            if (op.getSObjectType() == sobjectType) {
                filteredOps.add(op);
            }
        }
        return filteredOps;
    }
}
