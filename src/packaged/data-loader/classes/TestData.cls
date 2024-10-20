/**
 * Load test data from plan files (similar to data tree import) or instantiate
 * `SObjectTreeLoader` instance to further customize a test data import transaction.
 *
 * @author Jannis Schreiber
 * @group Apex Data Loader
 */
@isTest
global without sharing class TestData {
    /**
     * Initialises a transaction from a test plan import file
     *
     * @param testDataPlan
     * @return  `SObjectTreeLoader`
     */
    global static SObjectTreeLoader newSObjectTreeLoader(String testDataPlan) {
        StaticResource planFile = loadResource(testDataPlan);
        if (planFile == null) {
            throw new QueryException(String.format(System.Label.No_Plan_File_Found_For_Name, new List<Object>{ testDataPlan }));
        }
        ParseResult result = parsePlanFile(planFile);
        if (!result.isSuccess()) {
            throw new ParseException(result.printErrors());
        }
        SObjectTreeLoader dl = new SObjectTreeLoader();
        for (SObjectTreeBranchDefinition importDef : result.importDefinitions) {
            dl.addOperation(importDef);
        }
        return dl;
    }

    /**
     * Executes a test data import transaction from a test plan
     * import file and inserts all records.
     *
     * @param testDataPlan
     * @return  `SObjectTreeLoader`
     */
    global static SObjectTreeLoader load(String testDataPlan) {
        return newSObjectTreeLoader(testDataPlan).executePlan();
    }

    /**
     * Shortcut to load records from a single test-file. Records cannot
     * contain references.
     *
     * @param testRecordsFileName
     * @return  `SObjectTreeLoader`
     */
    global static SObjectTreeLoader loadRecords(Schema.SObjectType sobjectType, String testRecordsFileName) {
        return new SObjectTreeLoader().addOperation(sobjectType).addSourceFile(testRecordsFileName).getSObjectTreeLoader().executePlan();
    }

    //          PRIVATE ZONE

    private static ParseResult parsePlanFile(StaticResource planFile) {
        ParseResult pr = new ParseResult();
        try {
            pr.importDefinitions = (List<SObjectTreeBranchDefinition>) JSON.deserializeStrict(
                planFile.Body.toString(),
                List<SObjectTreeBranchDefinition>.class
            );
            for (SObjectTreeBranchDefinition def : pr.importDefinitions) {
                parseSObjectName(def.sobjectName);
            }
        } catch (JSONException jsone) {
            ParseResultError pre = new ParseResultError();
            pre.message = String.format(System.Label.Cannot_Deserialize_Plan_File_JSON_Exception, new List<Object>{ jsone.getMessage() });
            pr.errors.add(pre);
        }
        return pr;
    }

    private static void parseSObjectName(String sobjectName) {
        if (ExtendedSchema.describeSObject(sobjectName) == null) {
            throw new IllegalArgumentException(
                String.format(System.Label.Invalid_SObject_Type_In_Import_Definition, new List<Object>{ sobjectName })
            );
        }
    }

    private static StaticResource loadResource(String resourceFileName) {
        return (StaticResource) ApexCache.JsonStaticResources.get(resourceFileName);
    }

    public class ParseException extends Exception {
    }

    private class ParseResult {
        private List<SObjectTreeBranchDefinition> importDefinitions;
        private List<ParseResultError> errors = new List<ParseResultError>();

        public Boolean isSuccess() {
            return this.errors.isEmpty();
        }

        public List<ParseResultError> getErrors() {
            return this.errors;
        }

        public String printErrors() {
            List<String> msgs = new List<String>();
            for (ParseResultError pre : this.getErrors()) {
                msgs.add(pre.message);
            }
            return String.join(msgs, ', ');
        }
    }

    private class ParseResultError {
        public String message;
    }
}
