@isTest
public class Test_E2E_SObjectExtension {
    @TestSetup
    static void makeData() {
        ApexUtilsFixtures.Accounts.insertAccountsWithContacts();
        ApexUtilsFixtures.Orders.insertProductsWithStandardPrices();
    }

    @isTest
    static void mergeWith_ParentPopulated_ParentValuesMerged() {
        // Act
        Contact c1 = [SELECT Id, Account.Name FROM Contact WHERE Email = 'tester1@starship.de'];
        Contact c2 = [SELECT Id, Account.Name FROM Contact WHERE Email = 'tester2@starship.de'];
        c2.Account.Name = 'New Company Name';
        c2.Account.Type = 'Customer';
        SObjectExtension ext = new SObjectExtension(c1);
        ext.mergeWith(c2);

        // Assert
        System.Assert.areEqual('New Company Name', c1.Account.Name, 'Acc Name');
        System.Assert.areEqual('Customer', c1.Account.Type, 'Acc Type');
        System.Assert.areEqual(c2.AccountId, c1.AccountId, 'Acc Id');
    }

    @isTest
    static void mergeWith_ParentNotPopulated_ParentCreated() {
        // Act
        Contact c1 = [SELECT Id FROM Contact WHERE Email = 'tester1@starship.de'];
        Contact c2 = [SELECT Id, Account.Name FROM Contact WHERE Email = 'tester2@starship.de'];
        c2.Account.Name = 'New Company Name';
        c2.Account.Type = 'Customer';
        SObjectExtension ext = new SObjectExtension(c1);
        ext.mergeWith(c2);

        // Assert
        System.Assert.areEqual('New Company Name', c1.Account.Name, 'Acc Name');
        System.Assert.areEqual('Customer', c1.Account.Type, 'Acc Type');
        System.Assert.areEqual(c2.AccountId, c1.AccountId, 'Acc Id');
    }

    @isTest
    static void mergeWith_NoParentInSecondary_ParentNotUpdated() {
        // Act
        Contact c1 = [SELECT Id, Account.Name, Account.Type FROM Contact WHERE Email = 'tester2@starship.de'];
        Contact c2 = [SELECT Id FROM Contact WHERE Email = 'tester1@starship.de'];
        SObjectExtension ext = new SObjectExtension(c1);
        ext.mergeWith(c2);

        // Assert
        System.Assert.areEqual('Starship Galactica Ltd.', c1.Account.Name, 'Acc Name');
        System.Assert.areEqual(null, c1.Account.Type, 'Acc Type');
        System.Assert.areEqual(c2.AccountId, c1.AccountId, 'Acc Id');
    }

    @isTest
    static void mergeWith_SecondaryWithNullParentObject_ParentRemovedOnPrimary() {
        // Act
        Contact c1 = [SELECT Id, Account.Name, Account.Type FROM Contact WHERE Email = 'tester2@starship.de'];
        Contact c2 = new Contact(LastName = 'Tester', AccountId = null);
        c2.Account = null;
        SObjectExtension.mergeRecords(c1, c2);

        // Assert
        System.Assert.areEqual(
            new Set<String>{ 'Id', 'Account', 'AccountId', 'LastName' },
            c1.getPopulatedFieldsAsMap().keySet(),
            'populated fields'
        );
        System.Assert.areEqual(null, c1.AccountId, 'AccountId is null');
        System.Assert.areEqual(null, c1.Account, 'Account is null');
    }
}
