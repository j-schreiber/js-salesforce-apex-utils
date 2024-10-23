@isTest
public class Test_E2E_TestSObjectTreeLoader {
    @isTest
    static void newSObjectTreeLoader_SimplePlanFile_ImportPlanInitialised() {
        // Act
        SObjectTreeLoader tdl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Plan');

        // Assert
        System.Assert.areEqual(2, tdl.getOperations().size(), 'import operations initialised');
    }

    @isTest
    static void newSObjectTreeLoader_ComplexPlanFile_ImportPlanInitialised() {
        // Act
        SObjectTreeLoader dl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Complex_Plan');

        // Assert
        System.Assert.areEqual(5, dl.getOperations().size(), 'import operations initialised');
        System.Assert.areEqual(
            new Set<String>{ 'Accounts_Import', 'Contacts_Import', 'My_Assets_Import', 'Cases' },
            dl.getNamedOperations().keySet(),
            'named operations'
        );
        System.Assert.areEqual(Schema.Asset.getSObjectType(), dl.getOperation('My_Assets_Import').getSObjectType(), 'asset operation type');
        System.Assert.areEqual(Schema.Case.getSObjectType(), dl.getOperation('Cases').getSObjectType(), 'case operation type');
    }

    @isTest
    static void newSObjectTreeLoader_EmptyPlanFile_ImportPlanInitialised() {
        // Act
        SObjectTreeLoader tdl = TestData.newSObjectTreeLoader('Generic_Test_Data_Empty_List');

        // Assert
        System.Assert.areEqual(0, tdl.getOperations().size(), 'initialises two imports');
    }

    @isTest
    static void newSObjectTreeLoader_InvalidPlanFile_ThrowsException() {
        // Arrange
        Set<String> invalidFileNames = new Set<String>{ 'Apex_Utils_Default_Contacts', 'ApexUtils_MockData_Contacts_Default' };

        // Act
        for (String fileName : invalidFileNames) {
            try {
                SObjectTreeLoader tdl = TestData.newSObjectTreeLoader(fileName);
                System.Assert.fail('Expected exception for: ' + fileName);
            } catch (TestData.ParseException pe) {
                System.Assert.isTrue(
                    pe.getMessage().contains(System.Label.Cannot_Deserialize_Plan_File_JSON_Exception.left(30)),
                    String.format('message contains details for filename {0}: {1}', new List<Object>{ fileName, pe.getMessage() })
                );
            }
        }
    }

    @isTest
    static void newSObjectTreeLoader_NonExistingFileName_ThrowsException() {
        // Act
        try {
            SObjectTreeLoader tdl = TestData.newSObjectTreeLoader('Non Existing 234234234');
            System.Assert.fail('Expected exception');
        } catch (QueryException qe) {
            System.Assert.areEqual(
                String.format(System.Label.No_Plan_File_Found_For_Name, new List<Object>{ 'Non Existing 234234234' }),
                qe.getMessage(),
                'exception message'
            );
        }
    }

    @isTest
    static void newSObjectTreeLoader_NonExistingFileInImportDefinition_ThrowsException() {
        // Act
        try {
            SObjectTreeLoader tdl = TestData.newSObjectTreeLoader('Test_Data_Loader_Invalid_Plan');
            System.Assert.fail('Expected exception');
        } catch (QueryException qe) {
            System.Assert.areEqual(
                String.format(System.Label.No_Records_File_Found_For_Name, new List<Object>{ 'Non_Existent_File_For_Accounts 3489723' }),
                qe.getMessage(),
                'exception message'
            );
        }
    }

    @isTest
    static void loadData_SimplePlan_AllRecordsInserted() {
        // Act
        TestData.load('Test_Data_Loader_Testing_Plan');

        // Assert
        System.Assert.areEqual(3, [SELECT COUNT() FROM Account], 'accs created');
        System.Assert.areEqual(2, [SELECT COUNT() FROM Contact], 'contacts created');
        Account starShipAcc = [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE AccountNumber = '1000'];
        System.Assert.areEqual(2, starShipAcc.Contacts.size(), 'contacts on first acc');
    }

    @isTest
    static void loadData_ComplexPlan_AllRecordsInserted() {
        // Act
        TestData.load('Test_Data_Loader_Testing_Complex_Plan');

        // Assert
        System.Assert.areEqual(3, [SELECT COUNT() FROM Product2], 'products created');
        System.Assert.areEqual(5, [SELECT COUNT() FROM Account], 'accs created');
        System.Assert.areEqual(2, [SELECT COUNT() FROM Contact], 'contacts created');
        System.Assert.areEqual(3, [SELECT COUNT() FROM Asset], 'assets created');
    }

    @isTest
    static void loadData_DefaultSetting_RunsAllTriggers() {
        // Arrange
        setMockTriggerSetting('Account', 'Test_E2E_TestSObjectTreeLoader.MockErrorExecutable');

        // Act
        try {
            TestData.load('Test_Data_Loader_Testing_Plan');
            System.Assert.fail('Expected exception');
        } catch (DmlException de) {
            System.Assert.isTrue(
                de.getMessage().contains('Mock error from account trigger'),
                'message contains mock error: ' + de.getMessage()
            );
        }
    }

    @isTest
    static void loadData_BypassTriggersSetting_NoTriggersExecuted() {
        // Arrange
        setMockTriggerSetting('Account', 'Test_E2E_TestSObjectTreeLoader.MockErrorExecutable');

        // Act
        TestData.load('Test_Data_Loader_Testing_Plan_Bypass');

        // Assert
        System.Assert.areEqual(3, [SELECT COUNT() FROM Account], 'accs created');
    }

    @isTest
    static void loadRecords_ValidRecordsFile_AllRecordsInserted() {
        // Act
        TestData.loadRecords(Schema.Account.getSObjectType(), 'Apex_Utils_Default_Business_Accounts_1');

        // Assert
        System.Assert.areEqual(3, [SELECT COUNT() FROM Account], 'accs inserted');
    }

    @isTest
    static void loadRecords_InvalidFileName_ThrowsException() {
        // Act
        try {
            SObjectTreeLoader tdl = TestData.loadRecords(Schema.Account.getSObjectType(), 'Something unknown');
            System.Assert.fail('Expected exception');
        } catch (QueryException qe) {
            System.Assert.areEqual(
                String.format(System.Label.No_Records_File_Found_For_Name, new List<Object>{ 'Something unknown' }),
                qe.getMessage(),
                'exception message'
            );
        }
    }

    @isTest
    static void loadRecords_ResolveRefsFalseInPlanFile_IgnoresLookupFields() {
        // Act
        TestData.load('Test_Data_Loader_Testing_Complex_Plan');

        // Assert
        List<Case> cases = [SELECT Id, AccountId FROM Case];
        System.Assert.areEqual(3, cases.size(), 'all cases inserted');
        for (Case c : cases) {
            System.Assert.isNull(c.AccountId, 'account id is null');
        }
    }

    @isTest
    static void loadRecords_ResolveRefsOverwrittenWithTrue_ResolvesLookupFields() {
        // Act
        SObjectTreeLoader dl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Complex_Plan')
            .getOperation('Cases')
            .setResolveRefs(true)
            .getSObjectTreeLoader()
            .executePlan();

        // Assert
        List<Case> cases = [SELECT Id, AccountId FROM Case];
        System.Assert.areEqual(3, cases.size(), 'all cases inserted');
        for (Case c : cases) {
            System.Assert.isNotNull(c.AccountId, 'account id is not null');
        }
    }

    @isTest
    static void loadRecords_FileWithReferencesSetResolveRefsFalse_InsertRecordsIgnoresLookupFields() {
        // Act
        SObjectTreeLoader dl = new SObjectTreeLoader()
            .addOperation(Schema.Case.getSObjectType(), 'Cases')
            .addSourceFile('Apex_Utils_Data_Default_Cases')
            .setResolveRefs(false)
            .getSObjectTreeLoader()
            .executePlan();

        // Assert
        List<Case> cases = [SELECT Id, AccountId FROM Case];
        System.Assert.areEqual(3, cases.size(), 'all cases inserted');
        for (Case c : cases) {
            System.Assert.isNull(c.AccountId, 'account id is null');
        }
    }

    @isTest
    static void loadRecords_PlanWithRecordFactory_FactoryRecordsInserted() {
        // Act
        TestData.load('Test_Data_Loader_Factory_Test_Plan');

        // Assert
        System.Assert.areEqual(3, [SELECT COUNT() FROM Account], 'number of accounts');
        System.Assert.areEqual(2, [SELECT COUNT() FROM Contact], 'number of contacts');
        Account firstTestAcc = [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE AccountNumber = '1000'];
        System.Assert.areEqual(2, firstTestAcc.Contacts.size(), 'contacts for starship account (1000)');
    }

    @isTest
    static void loadRecords_ConstructLoaderWithRecordFactory_FactoryRecordsInserted() {
        // Act
        SObjectTreeLoader stl = new SObjectTreeLoader()
            .addOperation(Account.SObjectType)
            .addFactory(new SObjectTreeLoaderMocks.BusinessAccountMocks1())
            .getSObjectTreeLoader()
            .addOperation(Contact.SObjectType)
            .addFactory(new SObjectTreeLoaderMocks.DynamicContactMocks())
            .getSObjectTreeLoader()
            .addOperation(Case.SObjectType)
            .addSourceFile('Apex_Utils_Data_Default_Cases')
            .getSObjectTreeLoader()
            .executePlan();

        // Assert
        System.Assert.areEqual(3, [SELECT COUNT() FROM Account], 'number of accounts');
        System.Assert.areEqual(9, [SELECT COUNT() FROM Contact], 'number of contacts');
        System.Assert.areEqual(3, [SELECT COUNT() FROM Case], 'number of cases');
        for (Account acc : [SELECT Id, Name, (SELECT Id FROM Contacts) FROM Account]) {
            System.Assert.areEqual(3, acc.Contacts.size(), 'contacts for account: ' + acc.Name);
        }
        for (Case c : [SELECT Id, AccountId, Subject FROM Case]) {
            System.Assert.areNotEqual(null, c.AccountId, 'case is related to an account: ' + c.Subject);
        }
    }

    private static void setMockTriggerSetting(String objectName, String mockHandler) {
        TriggerFeatureControl__mdt mockSetting = TriggersMocks.makeTriggerControl('DATA_LOADER_MOCK_SETTING', mockHandler);
        mockSetting.RunOnBeforeInsert__c = true;
        TriggerControlsRepository.setMocks(objectName, new List<TriggerFeatureControl__mdt>{ mockSetting });
    }

    public class MockErrorExecutable implements TriggerExecutable {
        public void execute(TriggerContext context) {
            for (Account a : (List<Account>) context.getPrimaryList()) {
                a.addError('Mock error from account trigger');
            }
        }
    }
}
