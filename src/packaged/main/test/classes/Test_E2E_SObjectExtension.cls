@isTest
public class Test_E2E_SObjectExtension {
    @TestSetup
    static void makeData() {
        ApexUtilsFixtures.Accounts.insertAccountsWithContacts();
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
}
