public without sharing class TriggerControlsRepository {
    private static Map<String, List<TriggerFeatureControl__mdt>> mocks = new Map<String, List<TriggerFeatureControl__mdt>>();

    @testVisible
    private static void setMocks(String sobjectName, List<TriggerFeatureControl__mdt> mockControls) {
        mocks.put(sobjectName, mockControls);
    }

    public static List<TriggerFeatureControl__mdt> getControls(String sobjectName) {
        if (Test.isRunningTest() && mocks.containsKey(sobjectName)) {
            return mocks.get(sobjectName);
        }
        return [
            SELECT
                Id,
                DeveloperName,
                Handler__c,
                IsActive__c,
                Priority__c,
                RunOnAfterDelete__c,
                RunOnAfterInsert__c,
                RunOnAfterUndelete__c,
                RunOnAfterUpdate__c,
                RunOnBeforeDelete__c,
                RunOnBeforeInsert__c,
                RunOnBeforeUpdate__c
            FROM TriggerFeatureControl__mdt
            WHERE SObjectName__c = :sobjectName
            ORDER BY Priority__c ASC
        ];
    }
}
