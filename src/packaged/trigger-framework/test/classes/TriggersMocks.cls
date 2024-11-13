@isTest
public class TriggersMocks {
    public static TriggerFeatureControl__mdt makeTriggerControl(String developerName, String triggerHandler) {
        return new TriggerFeatureControl__mdt(
            DeveloperName = developerName,
            Handler__c = triggerHandler,
            IsActive__c = true,
            Priority__c = 100,
            RunOnAfterDelete__c = false,
            RunOnAfterInsert__c = false,
            RunOnAfterUndelete__c = false,
            RunOnAfterUpdate__c = false,
            RunOnBeforeDelete__c = false,
            RunOnBeforeInsert__c = false,
            RunOnBeforeUpdate__c = false
        );
    }
}
