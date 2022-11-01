public without sharing class SyncCityWithParentAccount implements TriggerExecutable {
    public void execute(TriggerContext context) {
        Set<Id> accountIds = new Set<Id>();
        for (Contact c : (List<Contact>) context.getPrimaryList()) {
            accountIds.add(c.AccountId);
        }
        accountIds.remove(null);
        Map<Id, Account> parentAccs = new Map<Id, Account>([SELECT Id, BillingCity FROM Account WHERE Id IN :accountIds]);
        for (Contact c : (List<Contact>) context.getPrimaryList()) {
            c.MailingCity = parentAccs.get(c.AccountId).BillingCity;
            c.OtherCity = parentAccs.get(c.AccountId).BillingCity;
        }
    }
}
