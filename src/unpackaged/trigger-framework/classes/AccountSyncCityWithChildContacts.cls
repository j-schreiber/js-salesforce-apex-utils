public without sharing class AccountSyncCityWithChildContacts implements TriggerExecutable {
    public void execute(TriggerContext context) {
        List<Contact> childContacts = [SELECT Id FROM Contact WHERE AccountId IN :context.oldMap.keySet()];
        update childContacts;
    }
}
