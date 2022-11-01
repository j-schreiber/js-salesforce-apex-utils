@isTest
public class Test_E2E_AccountTrigger {
    private static void enableTestingFeatures() {
        Triggers.forceActivateFeature('Account_Write_Billing_City');
        Triggers.forceActivateFeature('Account_Fill_Account_Number');
        Triggers.forceActivateFeature('Sync_Cities_From_Parent_Account');
        Triggers.forceActivateFeature('Sync_City_With_Child_Contacts');
    }

    @isTest
    static void insertAccount_BasicDefaults_BillingCityPopulated() {
        // ACT
        enableTestingFeatures();
        Account a = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        a.BillingCity = null;
        Database.SaveResult sr = Database.insert(a, false);

        // ASSERT
        System.Assert.isTrue(sr.isSuccess(), 'is success: ' + sr.getErrors());
        a = [SELECT Id, BillingCity, ShippingCity, AccountNumber FROM Account WHERE Id = :a.Id];
        System.Assert.areEqual('München', a.BillingCity, 'billing city');
        System.Assert.areEqual('München', a.ShippingCity, 'shipping city synced');
        System.Assert.areEqual('M-1234', a.AccountNumber, 'account number');
    }

    @isTest
    static void insertAccount_HasCity_BillingCityAsInput() {
        // ACT
        enableTestingFeatures();
        Account a = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        a.BillingCity = 'Augsburg';
        a.AccountNumber = null;
        Database.SaveResult sr = Database.insert(a, false);

        // ASSERT
        System.Assert.isTrue(sr.isSuccess(), 'is success: ' + sr.getErrors());
        a = [SELECT Id, BillingCity, AccountNumber FROM Account WHERE Id = :a.Id];
        System.Assert.areEqual('Augsburg', a.BillingCity, 'billing city');
        System.Assert.isNull(a.AccountNumber, 'account number');
    }

    @isTest
    static void updateAccount_HasNoBillingCity_CityPopulated() {
        // ARRANGE
        Account a = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        insert a;

        // ACT
        enableTestingFeatures();
        a.BillingCity = null;
        Database.SaveResult sr = Database.update(a, false);

        // ASSERT
        System.Assert.isTrue(sr.isSuccess(), 'is success: ' + sr.getErrors());
        a = [SELECT Id, BillingCity, AccountNumber FROM Account WHERE Id = :a.Id];
        System.Assert.areEqual('München', a.BillingCity, 'billing city');
        System.Assert.areEqual('M-1234', a.AccountNumber, 'account number');
    }

    @isTest
    static void insertContact_AccountHasBillingCity_BothCitiesPopulated() {
        // ARRANGE
        Account a = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        a.BillingCity = 'Augsburg';
        insert a;

        // ACT
        enableTestingFeatures();
        Contact c = new Contact(AccountId = a.Id, LastName = 'Tester', Email = 'test@example.com');
        insert c;

        // ASSERT
        c = [SELECT MailingCity, OtherCity FROM Contact WHERE Id = :c.Id];
        System.Assert.areEqual('Augsburg', c.MailingCity, 'mailing city');
        System.Assert.areEqual('Augsburg', c.OtherCity, 'other city');
    }

    @isTest
    static void updateAccount_ChangeBillingCity_CitiesInContactsPopulated() {
        // ARRANGE
        Account a = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        insert a;
        List<Contact> cs = new List<Contact>();
        cs.add(new Contact(AccountId = a.Id, LastName = 'Tester 1', Email = 'test1@example.com'));
        cs.add(new Contact(AccountId = a.Id, LastName = 'Tester 2', Email = 'test2@example.com'));
        cs.add(new Contact(AccountId = a.Id, LastName = 'Tester 3', Email = 'test3@example.com'));
        insert cs;

        // ACT
        enableTestingFeatures();
        a.BillingCity = 'Augsburg';
        update a;

        // ASSERT
        for (Contact c : [SELECT MailingCity, OtherCity FROM Contact WHERE Id IN :cs]) {
            System.Assert.areEqual('Augsburg', c.MailingCity, 'mailing city');
            System.Assert.areEqual('Augsburg', c.OtherCity, 'other city');
        }
    }

    @isTest
    static void insertAccount_DisableAll_NoFeatureExecuted() {
        // ACT
        enableTestingFeatures();
        Account a = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        a.BillingCity = null;
        a.AccountNumber = '1000';
        Triggers.disableAll();
        insert a;
        Triggers.enableAll();

        // ASSERT
        a = [SELECT Id, BillingCity, AccountNumber FROM Account WHERE Id = :a.Id];
        System.Assert.isNull(a.BillingCity, 'billing city');
        System.Assert.areEqual('1000', a.AccountNumber, 'account number');
    }

    @isTest
    static void insertAccount_EnableAllAfterDisable_AllFeaturesExecuted() {
        // ACT
        enableTestingFeatures();
        Account a = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        a.BillingCity = null;
        a.AccountNumber = '1000';
        Triggers.disableAll();
        Triggers.enableAll();
        insert a;

        // ASSERT
        a = [SELECT Id, BillingCity, AccountNumber FROM Account WHERE Id = :a.Id];
        System.Assert.areEqual('München', a.BillingCity, 'billing city');
        System.Assert.areEqual('M-1234', a.AccountNumber, 'account number');
    }

    @isTest
    static void insertAccount_DisableAccountSObject_NoFeatureExecuted() {
        // ACT
        enableTestingFeatures();
        Account a = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        a.BillingCity = null;
        a.AccountNumber = '1000';
        Triggers.disableSObject(Schema.Account.SObjectType);
        insert a;

        // ASSERT
        a = [SELECT Id, BillingCity, AccountNumber FROM Account WHERE Id = :a.Id];
        System.Assert.isNull(a.BillingCity, 'billing city');
        System.Assert.areEqual('1000', a.AccountNumber, 'account number');
    }

    @isTest
    static void insertAccount_EnableAccountSObjectAfterDisable_NoFeatureExecuted() {
        // ACT
        enableTestingFeatures();
        Account disabledAccount = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        disabledAccount.Name = 'Disabled GmbH';
        disabledAccount.BillingCity = null;
        disabledAccount.AccountNumber = '1000';
        Account enabledAccount = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        enabledAccount.Name = 'Enabled Company LLC';
        enabledAccount.BillingCity = 'München';
        Triggers.disableSObject(Schema.Account.SObjectType);
        insert disabledAccount;
        Triggers.enableSObject(Schema.Account.SObjectType);
        insert enabledAccount;

        // ASSERT
        disabledAccount = [SELECT Id, BillingCity, AccountNumber FROM Account WHERE Id = :disabledAccount.Id];
        System.Assert.isNull(disabledAccount.BillingCity, 'billing city');
        System.Assert.areEqual('1000', disabledAccount.AccountNumber, 'account number');
        enabledAccount = [SELECT Id, BillingCity, AccountNumber FROM Account WHERE Id = :enabledAccount.Id];
        System.Assert.areEqual('München', enabledAccount.BillingCity, 'billing city');
        System.Assert.areEqual('M-1234', enabledAccount.AccountNumber, 'account number');
    }

    @isTest
    static void insertAccount_DisableContactSObject_AccountFeaturesExecuted() {
        // ACT
        enableTestingFeatures();
        Account enabledAccount = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        enabledAccount.Name = 'Enabled Company LLC';
        enabledAccount.BillingCity = null;
        Triggers.disableSObject(Schema.Contact.SObjectType);
        insert enabledAccount;

        // ASSERT
        enabledAccount = [SELECT Id, BillingCity, AccountNumber FROM Account WHERE Id = :enabledAccount.Id];
        System.Assert.areEqual('München', enabledAccount.BillingCity, 'billing city');
        System.Assert.areEqual('M-1234', enabledAccount.AccountNumber, 'account number');
    }

    @isTest
    static void insertAccount_DisableTestingFeature_OtherFeaturesExecuted() {
        // ACT
        enableTestingFeatures();
        Account acc = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        acc.Name = 'Company LLC';
        acc.BillingCity = null;
        acc.AccountNumber = '1000';
        Triggers.disableFeature('Account_Fill_Account_Number');
        insert acc;

        // ASSERT
        acc = [SELECT Id, BillingCity, AccountNumber FROM Account WHERE Id = :acc.Id];
        System.Assert.areEqual('München', acc.BillingCity, 'billing city');
        System.Assert.areEqual('1000', acc.AccountNumber, 'account number');
    }

    @isTest
    static void insertAccount_EnableTestingFeatureAgain_AllFeaturesExecuted() {
        // ACT
        enableTestingFeatures();
        Account acc = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        acc.Name = 'Disabled Company GmbH';
        acc.BillingCity = null;
        acc.AccountNumber = null;
        Account acc2 = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        acc2.Name = 'Enabled Company LLC';
        acc2.BillingCity = null;
        acc2.AccountNumber = null;
        Triggers.disableFeature('Account_Fill_Account_Number');
        insert acc;
        Triggers.enableFeature('Account_Fill_Account_Number');
        insert acc2;

        // ASSERT
        acc = [SELECT Id, BillingCity, AccountNumber FROM Account WHERE Id = :acc.Id];
        System.Assert.areEqual('München', acc.BillingCity, 'billing city');
        System.Assert.isNull(acc.AccountNumber, 'account number');
        acc2 = [SELECT Id, BillingCity, AccountNumber FROM Account WHERE Id = :acc2.Id];
        System.Assert.areEqual('München', acc2.BillingCity, 'billing city');
        System.Assert.areEqual('M-1234', acc2.AccountNumber, 'account number');
    }

    @isTest
    static void insertAccount_EnableBlockingFeature_DmlBlocked() {
        // ARRANGE
        Triggers.forceActivateFeature('Account_Block_Delete');
        Account acc = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        insert acc;

        // ACT
        Database.DeleteResult dr = Database.delete(acc, false);

        // ASSERT
        System.Assert.areEqual(false, dr.isSuccess(), 'delete successful');
        System.Assert.areEqual('Blocked in AccountBlockDml', dr.getErrors()[0].getMessage(), 'dml error message');
    }

    @isTest
    static void disableFeature_EnabledValidTriggerExecutable_FeatureNotExecuted() {
        // ACT
        Triggers.disableFeature(AccountSyncShippingAddress.class);
        Account a = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        a.BillingCity = 'München';
        insert a;

        // ASSERT
        a = [SELECT Id, BillingCity, ShippingCity FROM Account WHERE Id = :a.Id];
        System.Assert.areEqual('München', a.BillingCity, 'billing city');
        System.Assert.areEqual('Nürnberg', a.ShippingCity, 'original shipping city from fixture');
    }

    @isTest
    static void disableFeature_DisabledValidTriggerExecutable_OtherFeaturesExecuted() {
        // ACT
        Triggers.disableFeature(AccountSyncCityWithChildContacts.class);
        Account a = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        a.BillingCity = 'München';
        insert a;

        // ASSERT
        a = [SELECT Id, BillingCity, ShippingCity FROM Account WHERE Id = :a.Id];
        System.Assert.areEqual('München', a.BillingCity, 'billing city');
        System.Assert.areEqual('München', a.ShippingCity, 'shipping city synced');
    }

    @isTest
    static void enableFeature_EnablePreviouslyDisabledFeature_FeatureIsExecuted() {
        // ACT
        Triggers.disableFeature(AccountSyncShippingAddress.class);
        Account disabledAccount = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        disabledAccount.Name = 'Disabled Company GmbH';
        disabledAccount.BillingCity = 'Berlin';
        insert disabledAccount;
        Triggers.enableFeature(AccountSyncShippingAddress.class);
        Account enabledAccount = ApexUtilsFixtures.Accounts.CreateDefaultAccount();
        enabledAccount.Name = 'Enabled Feature AG';
        enabledAccount.BillingCity = 'München';
        insert enabledAccount;

        // ASSERT
        enabledAccount = [SELECT Id, BillingCity, ShippingCity FROM Account WHERE Id = :enabledAccount.Id];
        disabledAccount = [SELECT Id, BillingCity, ShippingCity FROM Account WHERE Id = :disabledAccount.Id];
        System.Assert.areEqual('München', enabledAccount.ShippingCity, 'synced shipping city');
        System.Assert.areEqual('Nürnberg', disabledAccount.ShippingCity, 'original shipping city from fixture');
    }
}
