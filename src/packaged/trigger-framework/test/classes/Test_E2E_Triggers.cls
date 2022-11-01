/**
 * Due to the nature of frameworks, they are hard to test during development.
 * Most testing is done in unpackaged source of Apex Utils package. These tests
 * are primarily for test coverage and the most fundamental functionality.
 *
 * @author Jannis Schreiber
 */
@isTest
public class Test_E2E_Triggers {
    @isTest
    static void insertAccount_DefaultAccount_DmlSuccessful() {
        // ACT
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        List<Database.SaveResult> srs = Database.insert(accs, false);

        // ASSERT
        for (Database.SaveResult sr : srs) {
            System.Assert.isTrue(sr.isSuccess(), 'is success: ' + sr.getErrors());
        }
    }

    @isTest
    static void updateAccount_DefaultAccount_DmlSuccessful() {
        // ARRANGE
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        insert accs;

        // ACT
        for (Account a : accs) {
            a.Name = a.Name + ' NEW';
        }
        List<Database.SaveResult> srs = Database.update(accs, false);

        // ASSERT
        for (Database.SaveResult sr : srs) {
            System.Assert.isTrue(sr.isSuccess(), 'is success: ' + sr.getErrors());
        }
    }

    @isTest
    static void deleteAccount_DefaultAccount_DmlSuccessful() {
        // ARRANGE
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        insert accs;

        // ACT
        List<Database.DeleteResult> drs = Database.delete(accs, false);

        // ASSERT
        for (Database.DeleteResult dr : drs) {
            System.Assert.isTrue(dr.isSuccess(), 'is success: ' + dr.getErrors());
        }
    }

    @isTest
    static void undeleteAccount_DefaultAccount_DmlSuccessful() {
        // ARRANGE
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        insert accs;
        delete accs;

        // ACT
        List<Database.UndeleteResult> drs = Database.undelete(accs, false);

        // ASSERT
        for (Database.UndeleteResult udr : drs) {
            System.Assert.isTrue(udr.isSuccess(), 'is success: ' + udr.getErrors());
        }
    }

    @isTest
    static void insertAccount_DisableAll_NoFeatureExecuted() {
        // ACT
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        Triggers.disableAll();
        insert accs;
        Triggers.enableAll();

        // ASSERT
        System.Assert.areEqual(accs.size(), [SELECT COUNT() FROM Account], 'accounts inserted');
    }

    @isTest
    static void insertAccount_WithMockFeatures_FeaturesExecuted() {
        // ARRANGE
        setupAccountMockFeatureControls();

        // ACT
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        for (Account a : accs) {
            a.BillingCity = null;
            a.AccountNumber = null;
        }
        insert accs;

        // ASSERT
        accs = [SELECT BillingCity, AccountNumber FROM Account WHERE Id IN :accs];
        for (Account a : accs) {
            System.Assert.areEqual('München', a.BillingCity, 'billing city');
            System.Assert.isNull(a.AccountNumber, 'account number');
        }
    }

    @isTest
    static void insertContacts_AccountsHaveMockFeaturesEnabled_NoFeaturesExecuted() {
        // ARRANGE
        setupAccountMockFeatureControls();
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        insert accs;

        // ACT
        List<Contact> contacts = new List<Contact>();
        contacts.add(ApexUtilsFixtures.Accounts.CreateContact(accs[0].Id, 'tester1@starship.de', 'Tester 1'));
        contacts.add(ApexUtilsFixtures.Accounts.CreateContact(accs[0].Id, 'tester2@starship.de', 'Tester 2'));
        contacts.add(ApexUtilsFixtures.Accounts.CreateContact(accs[0].Id, 'tester3@starship.de', 'Tester 3'));
        insert contacts;

        // ASSERT
        System.Assert.areEqual(contacts.size(), [SELECT COUNT() FROM CONTACT], 'contacts inserted');
    }

    @isTest
    static void disableSObject_Null_ThrowsException() {
        // ASSERT
        try {
            Triggers.disableSObject(null);
            System.Assert.fail('Expected exception, but proceeded');
        } catch (IllegalArgumentException iae) {
            System.Assert.isTrue(iae.getMessage().contains('cannot be null'));
        }
    }

    @isTest
    static void enableSObject_Null_ThrowsException() {
        // ASSERT
        try {
            Triggers.enableSObject(null);
            System.Assert.fail('Expected exception, but proceeded');
        } catch (IllegalArgumentException iae) {
            System.Assert.isTrue(iae.getMessage().contains('cannot be null'));
        }
    }

    @isTest
    static void disableFeature_NullEmpty_ThrowsException() {
        // ASSERT
        try {
            String configName;
            Triggers.disableFeature(configName);
            System.Assert.fail('Expected exception, but proceeded');
        } catch (IllegalArgumentException iae) {
            System.Assert.isTrue(iae.getMessage().contains('cannot be null'));
        }
        try {
            Triggers.disableFeature('');
            System.Assert.fail('Expected exception, but proceeded');
        } catch (IllegalArgumentException iae) {
            System.Assert.isTrue(iae.getMessage().contains('cannot be null'));
        }
    }

    @isTest
    static void enableFeature_NullEmpty_ThrowsException() {
        // ASSERT
        try {
            String configName;
            Triggers.enableFeature(configName);
            System.Assert.fail('Expected exception, but proceeded');
        } catch (IllegalArgumentException iae) {
            System.Assert.isTrue(iae.getMessage().contains('cannot be null'));
        }
        try {
            Triggers.enableFeature('');
            System.Assert.fail('Expected exception, but proceeded');
        } catch (IllegalArgumentException iae) {
            System.Assert.isTrue(iae.getMessage().contains('cannot be null'));
        }
    }

    @isTest
    static void forceActivateFeature_NullEmpty_ThrowsException() {
        // ASSERT
        try {
            Triggers.forceActivateFeature(null);
            System.Assert.fail('Expected exception, but proceeded');
        } catch (IllegalArgumentException iae) {
            System.Assert.isTrue(iae.getMessage().contains('cannot be null'));
        }
        try {
            Triggers.forceActivateFeature('');
            System.Assert.fail('Expected exception, but proceeded');
        } catch (IllegalArgumentException iae) {
            System.Assert.isTrue(iae.getMessage().contains('cannot be null'));
        }
    }

    @isTest
    static void forceActivateFeature_InactiveFeature_FeatureExecuted() {
        // ARRANGE
        setupAccountMockFeatureControls();
        Triggers.forceActivateFeature('MOCK_ACCOUNT_TESTING_3');

        // ACT
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        for (Account a : accs) {
            a.BillingCity = 'München';
            a.AccountNumber = null;
        }
        insert accs;

        // ASSERT
        accs = [SELECT AccountNumber FROM Account WHERE Id IN :accs];
        for (Account a : accs) {
            System.Assert.areEqual('M-1234', a.AccountNumber, 'account number');
        }
    }

    @isTest
    static void forceActivateFeature_FeatureIsDisabled_FeatureNotExecuted() {
        // ARRANGE
        setupAccountMockFeatureControls();
        // order doesn't matter
        Triggers.disableFeature('MOCK_ACCOUNT_TESTING_3');
        Triggers.forceActivateFeature('MOCK_ACCOUNT_TESTING_3');

        // ACT
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        for (Account a : accs) {
            a.AccountNumber = null;
        }
        insert accs;

        // ASSERT
        accs = [SELECT AccountNumber FROM Account WHERE Id IN :accs];
        for (Account a : accs) {
            System.Assert.isNull(a.AccountNumber, 'account number');
        }
    }

    @isTest
    static void forceActivateFeature_SObjectDisabled_FeatureNotExecuted() {
        // ARRANGE
        setupAccountMockFeatureControls();
        // order doesn't matter
        Triggers.disableSObject(Schema.Account.SObjectType);
        Triggers.forceActivateFeature('MOCK_ACCOUNT_TESTING_3');

        // ACT
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        for (Account a : accs) {
            a.AccountNumber = null;
        }
        insert accs;

        // ASSERT
        accs = [SELECT AccountNumber FROM Account WHERE Id IN :accs];
        for (Account a : accs) {
            System.Assert.isNull(a.AccountNumber, 'account number');
        }
    }

    @isTest
    static void enableAll_FeatureWasDisabled_FeatureExecuted() {
        // ARRANGE
        setupAccountMockFeatureControls();
        Triggers.disableFeature('MOCK_ACCOUNT_TESTING_1');

        // ACT
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        for (Account a : accs) {
            a.BillingCity = null;
        }
        Triggers.enableAll();
        insert accs;

        // ASSERT
        for (Account a : [SELECT Id, BillingCity FROM Account WHERE Id IN :accs]) {
            System.Assert.areEqual('München', a.BillingCity, 'billing city from MOCK_ACCOUNT_TESTING_1');
        }
    }

    @isTest
    static void enableAll_SObjectWasDisabled_SObjectTriggersExecuted() {
        // ARRANGE
        setupAccountMockFeatureControls();
        Triggers.disableSObjects(
            new List<Schema.SObjectType>{ Schema.Account.SObjectType, Schema.Contact.SObjectType, Schema.Order.SObjectType }
        );

        // ACT
        List<Account> accs = ApexUtilsFixtures.Accounts.CreateMultipleAccounts();
        for (Account a : accs) {
            a.BillingCity = null;
        }
        Triggers.enableAll();
        insert accs;

        // ASSERT
        for (Account a : [SELECT Id, BillingCity FROM Account WHERE Id IN :accs]) {
            System.Assert.areEqual('München', a.BillingCity, 'billing city from MOCK_ACCOUNT_TESTING_1');
        }
    }

    private static void setupAccountMockFeatureControls() {
        List<TriggerFeatureControl__mdt> mocks = new List<TriggerFeatureControl__mdt>();
        mocks.add(
            new TriggerFeatureControl__mdt(
                DeveloperName = 'MOCK_ACCOUNT_TESTING_1',
                Handler__c = 'Test_E2E_Triggers.AccountWriteBillingCity',
                IsActive__c = true,
                Priority__c = 100,
                RunOnAfterDelete__c = false,
                RunOnAfterInsert__c = false,
                RunOnAfterUndelete__c = false,
                RunOnAfterUpdate__c = false,
                RunOnBeforeDelete__c = false,
                RunOnBeforeInsert__c = true,
                RunOnBeforeUpdate__c = true
            )
        );
        mocks.add(
            new TriggerFeatureControl__mdt(
                DeveloperName = 'MOCK_ACCOUNT_TESTING_3',
                Handler__c = 'Test_E2E_Triggers.AccountFillAccountNumber',
                IsActive__c = false,
                Priority__c = 101,
                RunOnAfterDelete__c = false,
                RunOnAfterInsert__c = false,
                RunOnAfterUndelete__c = false,
                RunOnAfterUpdate__c = false,
                RunOnBeforeDelete__c = false,
                RunOnBeforeInsert__c = true,
                RunOnBeforeUpdate__c = false
            )
        );
        mocks.add(
            new TriggerFeatureControl__mdt(
                DeveloperName = 'MOCK_ACCOUNT_TESTING_2',
                Handler__c = 'Test_E2E_Triggers.AccountBlockDeletion',
                IsActive__c = true,
                Priority__c = 100,
                RunOnAfterDelete__c = false,
                RunOnAfterInsert__c = false,
                RunOnAfterUndelete__c = false,
                RunOnAfterUpdate__c = false,
                RunOnBeforeDelete__c = true,
                RunOnBeforeInsert__c = false,
                RunOnBeforeUpdate__c = false
            )
        );
        TriggerControlsRepository.setMocks('Account', mocks);
    }

    public class AccountWriteBillingCity implements TriggerExecutable {
        public void execute(TriggerContext context) {
            for (Account a : (List<Account>) context.getPrimaryList()) {
                if (String.isBlank(a.BillingCity)) {
                    a.BillingCity = 'München';
                }
            }
        }
    }

    public class AccountFillAccountNumber implements TriggerExecutable {
        public void execute(TriggerContext context) {
            for (Account a : (List<Account>) context.getPrimaryList()) {
                if (a.BillingCity == 'München') {
                    a.AccountNumber = 'M-1234';
                }
            }
        }
    }

    public class AccountBlockDml implements TriggerExecutable {
        public void execute(TriggerContext context) {
            for (Account a : (List<Account>) context.getPrimaryList()) {
                if (String.isNotBlank(a.AccountNumber)) {
                    a.addError('Blocked in AccountBlockDml');
                }
            }
        }
    }
}
