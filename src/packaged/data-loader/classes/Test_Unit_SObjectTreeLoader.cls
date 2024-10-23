@isTest
public class Test_Unit_SObjectTreeLoader {
    @isTest
    static void init_duplicateSObjectOperation_MergesRecordsFromBothOperations() {
        // Act
        SObjectTreeLoader dl = new SObjectTreeLoader();
        dl.addOperation(Account.getSObjectType()).addSourceFile('Apex_Utils_Default_Business_Accounts_1');
        dl.addOperation(Account.getSObjectType()).addSourceFile('Apex_Utils_Default_Business_Accounts_2');

        // Assert
        System.Assert.areEqual(2, dl.getOperations().size(), 'operations initialised');
        System.Assert.areEqual(Schema.Account.getSObjectType(), dl.getOperations()[0].getSObjectType(), 'first operation type');
        System.Assert.areEqual(3, dl.getOperations()[0].getTreeRecords().size(), 'records for first operation');
        System.Assert.areEqual(Schema.Account.getSObjectType(), dl.getOperations()[1].getSObjectType(), 'second operation type');
        System.Assert.areEqual(2, dl.getOperations()[1].getTreeRecords().size(), 'records for second operation');
        System.Assert.areEqual(5, dl.getRecordsBySObjectType(Schema.Account.getSObjectType()).size(), 'size of all account records');
    }

    @isTest
    static void addSourceFile_RecordHasNoAttributes_ThrowsException() {
        // Act & Assert
        SObjectTreeLoader dl = new SObjectTreeLoader();
        try {
            dl.addOperation(Account.getSObjectType()).addSourceFile('Test_Records_File_Invalid_Attributes');
            System.Assert.fail('Expected exception');
        } catch (SObjectTreeLoaderException dle) {
            String expectedMessage = String.format(
                System.Label.Test_Record_Has_No_Valid_Attributes,
                new List<Object>{ 'Test_Records_File_Invalid_Attributes', 1 }
            );
            System.Assert.areEqual(expectedMessage, dle.getMessage(), 'exception message');
        }
    }

    @isTest
    static void addSourceFile_RecordHasBlankReference_ThrowsException() {
        // Act & Assert
        SObjectTreeLoader dl = new SObjectTreeLoader();
        try {
            dl.addOperation(Account.getSObjectType()).addSourceFile('Test_Records_File_Blank_Reference');
            System.Assert.fail('Expected exception');
        } catch (SObjectTreeLoaderException dle) {
            String expectedMessage = String.format(
                System.Label.Test_Record_Has_No_Reference_Key,
                new List<Object>{ 'Test_Records_File_Blank_Reference', 2 }
            );
            System.Assert.areEqual(expectedMessage, dle.getMessage(), 'exception message');
        }
    }

    @isTest
    static void addSourceFile_IncompatibleRecordsToOperationType_ThrowsException() {
        // Arrange
        SObjectTreeLoader dl = new SObjectTreeLoader();
        SObjectTreeBranchOperation contactOp = dl.addOperation(Contact.SObjectType);

        // Act
        try {
            contactOp.addSourceFile('Apex_Utils_Default_Business_Accounts_1');
            System.Assert.fail('Expected exception');
        } catch (SObjectTreeLoaderException dle) {
            String expectedMessage = String.format(
                System.Label.Incompatible_SObject_Type_In_Source_File_Added_To_Operation,
                new List<Object>{ 'Contact', 'Account' }
            );
            System.Assert.areEqual(expectedMessage, dle.getMessage(), 'exception message');
        }
        System.Assert.areEqual(0, contactOp.getTreeRecords().size(), 'tree records in contact op');
        System.Assert.areEqual(0, contactOp.getRecords().size(), 'records in contact op');
    }

    @isTest
    static void addSourceFile_FileDoesNotSpecifyRecordTypes_AddsRecordsToOperation() {
        // Arrange
        SObjectTreeLoader dl = new SObjectTreeLoader();
        SObjectTreeBranchOperation contactOp = dl.addOperation(Contact.SObjectType);

        // Act
        contactOp.addSourceFile('Apex_Utils_Data_Default_Cases');
        // resolving getRecords would fail, but that's okay in this test scenario
        System.Assert.areEqual(3, contactOp.getTreeRecords().size(), 'prototypes in contact op');
    }

    @isTest
    static void getRecords_BasicAccountRecordTransaction_InitialisesRecordsFromJSON() {
        // Arrange
        SObjectTreeLoader dl = new SObjectTreeLoader();
        dl.addOperation(Account.getSObjectType()).addSourceFile('Apex_Utils_Default_Business_Accounts_1');

        // Act
        SObjectTreeBranchOperation businessAccOp = dl.getOperations()[0];
        List<Account> records = (List<Account>) businessAccOp.getRecords();

        // Assert
        System.Assert.areEqual(3, records.size(), 'number of records initialised');
        System.Assert.areEqual(
            new Set<String>{ 'Starship', 'ColonialOne', 'CloudNine' },
            businessAccOp.getTreeRecords().keySet(),
            'prototypes keyset'
        );
        System.Assert.areEqual('Starship Galactica Ltd.', records[0].Name, 'name of first record');
        System.Assert.areEqual(1000, records[0].AnnualRevenue, 'annual revenue of first record');
        System.Assert.areEqual(100, records[0].NumberOfEmployees, 'annual revenue of first record');
        System.Assert.areEqual('Colonial One', records[1].Name, 'name of second record');
        System.Assert.areEqual('Cloud 9 GmbH', records[2].Name, 'name of third record');
    }

    @isTest
    static void getPrototypes_CombinedRecordTransactions_InitialisesRecordsFromJSON() {
        // Arrange
        SObjectTreeLoader dl = new SObjectTreeLoader();
        dl.addOperation(Account.getSObjectType()).addSourceFile('Apex_Utils_Default_Business_Accounts_1');
        dl.addOperation(Contact.getSObjectType()).addSourceFile('Apex_Utils_Default_Contacts');

        // Act
        SObjectTreeBranchOperation contactOp = dl.getOperations()[1];

        // Assert
        System.Assert.areEqual(new Set<String>{ 'ContactRef1', 'ContactRef2' }, contactOp.getTreeRecords().keySet(), 'prototypes keyset');
        SObjectTreeRecord firstContact = contactOp.getTreeRecords().get('ContactRef1');
        System.Assert.areEqual('Adama', firstContact.getPrototype().get('LastName'), 'last name of first record');
        System.Assert.areEqual('@Starship', firstContact.getPrototype().get('AccountId'), 'reference placeholder of first record');
        SObjectTreeRecord secondContact = contactOp.getTreeRecords().get('ContactRef2');
        System.Assert.areEqual('Roslin', secondContact.getPrototype().get('LastName'), 'last name of second record');
        System.Assert.areEqual('@Starship', secondContact.getPrototype().get('AccountId'), 'reference placeholder of second record');
    }

    @isTest
    static void resolveRecords_InvalidReferenceInLookupField_ThrowsException() {
        // Arrange
        SObjectTreeLoader dl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Plan');
        dl.getOperations()[1].getTreeRecords().get('ContactRef1').getPrototype().put('AccountId', 'Starship');

        // Act
        try {
            List<Contact> contacts = (List<Contact>) dl.getOperations()[1].getRecords();
            System.Assert.fail('Expected exception');
        } catch (SObjectTreeLoaderException dle) {
            System.Assert.areEqual(
                String.format(
                    System.Label.Invalid_Reference_SObject_Field_Misses_Identifier,
                    new List<Object>{ 'Starship', 'AccountId', 'ContactRef1' }
                ),
                dle.getMessage(),
                'exception message'
            );
        }
    }

    @isTest
    static void resolveRecords_UndefinedReferenceInLookupField_ThrowsException() {
        // Arrange
        SObjectTreeLoader dl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Plan');
        // fake successful insert for all accounts in transaction
        mockAccountOperationIds(dl);

        // Act
        try {
            dl.getOperations()[1].getTreeRecords().get('ContactRef2').getPrototype().put('AccountId', '@NotExistingInAccsFile');
            List<Contact> contacts = (List<Contact>) dl.getOperations()[1].getRecords();
            System.Assert.fail('Expected exception');
        } catch (SObjectTreeLoaderException dle) {
            System.Assert.areEqual(
                String.format(
                    System.Label.Unknown_Reference_Value_Check_Source_Files,
                    new List<Object>{ 'NotExistingInAccsFile', 'AccountId', 'ContactRef2', 'Account' }
                ),
                dle.getMessage(),
                'exception message'
            );
        }
    }

    @isTest
    static void addOperation_AmbiguousReferencesInDifferentOperations_ThrowsException() {
        // Arrange
        SObjectTreeLoader dl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Plan');

        // Act
        try {
            dl.addOperation(Account.getSObjectType()).addSourceFile('Apex_Utils_Default_Business_Accounts_1');
            System.Assert.fail('Expected exception');
        } catch (SObjectTreeLoaderException dle) {
            System.Assert.areEqual(
                String.format(
                    System.Label.Ambiguous_Reference_Key_For_SObject_In_Source_Files,
                    new List<Object>{ 'Starship', 'Account', 'Apex_Utils_Default_Business_Accounts_1' }
                ),
                dle.getMessage(),
                'exception message'
            );
        }
    }

    @isTest
    static void addOperation_AmbiguousReferencesInSameOperations_ThrowsException() {
        // Arrange
        SObjectTreeLoader dl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Plan');
        StaticResource recordsFile = [SELECT Id, Name, Body FROM StaticResource WHERE Name = 'Apex_Utils_Default_Business_Accounts_1'];

        // Act
        try {
            dl.getOperations()[0].addSourceFile(recordsFile);
            System.Assert.fail('Expected exception');
        } catch (SObjectTreeLoaderException dle) {
            System.Assert.areEqual(
                String.format(
                    System.Label.Ambiguous_Reference_Key_For_SObject_In_Source_Files,
                    new List<Object>{ 'Starship', 'Account', 'Apex_Utils_Default_Business_Accounts_1' }
                ),
                dle.getMessage(),
                'exception message'
            );
        }
    }

    @isTest
    static void addOperation_DuplicateOperationName_ThrowsException() {
        // Arrange
        SObjectTreeLoader dl = new SObjectTreeLoader();
        dl.addOperation(Schema.Account.getSObjectType(), 'My_Account_Import');

        // Act
        try {
            dl.addOperation(Schema.Account.getSObjectType(), 'My_Account_Import');
            System.Assert.fail('Expected exception');
        } catch (SObjectTreeLoaderException dle) {
            System.Assert.areEqual(
                String.format(System.Label.Operation_Name_Already_Exists_In_Plan, new List<Object>{ 'My_Account_Import', 1 }),
                dle.getMessage(),
                'exception message'
            );
        }
    }

    @isTest
    static void resolveRecords_ReferenceRecordNotYetInserted_ThrowsException() {
        // Arrange
        SObjectTreeLoader dl = new SObjectTreeLoader();
        dl.addOperation(Contact.getSObjectType()).addSourceFile('Apex_Utils_Default_Contacts');
        dl.addOperation(Account.getSObjectType()).addSourceFile('Apex_Utils_Default_Business_Accounts_1');

        // Act
        try {
            List<Contact> contacts = (List<Contact>) dl.getOperations()[0].getRecords();
            System.Assert.fail('Expected exception');
        } catch (SObjectTreeLoaderException dle) {
            System.Assert.areEqual(
                String.format(
                    System.Label.Tried_To_Resolve_Reference_To_Non_Inserted_Record,
                    new List<Object>{ 'Starship', 'ContactRef1' }
                ),
                dle.getMessage(),
                'exception message'
            );
        }
    }

    @isTest
    static void getRecords_AddChildOperation_ResolvesParentLookups() {
        // Arrange
        SObjectTreeLoader dl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Plan');
        mockAccountOperationIds(dl);
        Id fakeAccId = dl.getOperations()[0].getTreeRecords().get('Starship').getRecord().Id;
        System.Assert.isNotNull(fakeAccId, 'fakeAccId was mocked successfully');

        // Act
        SObjectTreeBranchOperation contactOp = dl.getOperations()[1];
        List<Contact> contacts = (List<Contact>) contactOp.getRecords();

        // Assert
        System.Assert.areEqual(fakeAccId, contacts[0].AccountId, 'first contact account id');
        System.Assert.areEqual(Date.newInstance(1947, 2, 24), contacts[0].Birthdate, 'first contact birth date');
        System.Assert.areEqual('w.adama@battlestar-galactica.com', contacts[0].Email, 'first contact email');
        System.Assert.areEqual(fakeAccId, contacts[1].AccountId, 'second contact account id');
    }

    @isTest
    static void getRecords_WithRecordsFactory_RecordsInitialised() {
        // Act
        SObjectTreeLoader stl = new SObjectTreeLoader();
        SObjectTreeBranchOperation accOperation = stl.addOperation(Account.SObjectType)
            .addFactory(new SObjectTreeLoaderMocks.DefaultAccountFactoryMock());
        List<Account> accs = (List<Account>) accOperation.getRecords();

        // Assert
        System.Assert.areEqual(1, accs.size(), 'number of accs created');
        System.Assert.areEqual('Test Account From Default Mock', accs[0].Name, 'account name');
        System.Assert.areEqual(new Set<String>{ 'AccountRef1' }, accOperation.getTreeRecords().keySet(), 'tree records key set');
    }

    @isTest
    static void getOperation_SetFieldValue_PrototypeValuesOverridden() {
        // Arrange
        SObjectTreeLoader dl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Complex_Plan');
        // fake successful insert for all accounts und contacts in transaction
        // this is necessary to successfully resolve asset records
        mockAccountOperationIds(dl);
        mockContactOperationIds(dl);

        // Act
        dl.getOperation('My_Assets_Import').setField(Schema.Asset.Status, 'Active').getSObjectTreeLoader();

        // Assert
        for (SObjectTreeRecord assetPrototype : dl.getOperation('My_Assets_Import').getTreeRecords().values()) {
            System.Assert.areEqual(assetPrototype.getPrototype().get('Status'), 'Active', 'asset prototype status was updated');
        }
        for (Asset ass : (List<Asset>) dl.getOperation('My_Assets_Import').getRecords()) {
            System.Assert.areEqual(ass.Status, 'Active', 'asset status was updated');
        }
    }

    @isTest
    static void getOperation_InvalidOperationName_ThrowsException() {
        // Arrange
        SObjectTreeLoader dl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Complex_Plan');

        // Act
        try {
            dl.getOperation('Invalid Name for Operation');
            System.Assert.fail('Expected exception');
        } catch (SObjectTreeLoaderException e) {
            System.Assert.isTrue(
                e.getMessage().contains('Invalid Name for Operation'),
                'message contains invalid input: ' + e.getMessage()
            );
        }
    }

    @isTest
    static void setFields_OverrideDateField_ResolvesToCorrectDate() {
        // Arrange
        SObjectTreeLoader dl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Plan');
        dl.getOperation('Contacts_Import').setField(Schema.Contact.Birthdate, Date.newInstance(1999, 10, 31));
        mockAccountOperationIds(dl);

        // Act
        List<Contact> conts = (List<Contact>) dl.getOperation('Contacts_Import').getRecords();

        // Assert
        for (Contact c : conts) {
            System.Assert.areEqual(Date.newInstance(1999, 10, 31), c.Birthdate, 'birth date value');
        }
    }

    @isTest
    static void setFields_SetReferenceFieldWithValidId_ResolvesIdInRecord() {
        // Arrange
        SObjectTreeLoader dl = TestData.newSObjectTreeLoader('Test_Data_Loader_Testing_Plan');
        Id mockAccountId = TestMockFactory.generateFakeId(Schema.Account.getSObjectType());
        dl.getOperation('Contacts_Import').setField(Schema.Contact.AccountId, mockAccountId);

        // Act
        List<Contact> conts = (List<Contact>) dl.getOperation('Contacts_Import').getRecords();

        // Assert
        for (Contact c : conts) {
            System.Assert.areEqual(mockAccountId, c.AccountId, 'resolved input from setField');
        }
    }

    @isTest
    static void resolveRecordPrototype_SetRelativeDateFormulaAddDays_ResolveToActualDate() {
        // Arrange
        TestSpyProvider operationStub = new TestSpyProvider();
        operationStub.registerSpy('getDescribe', ExtendedSchema.describeSObject('WorkOrder'));
        SObjectTreeBranchOperation op = (SObjectTreeBranchOperation) Test.createStub(SObjectTreeBranchOperation.class, operationStub);

        // Act
        SObjectTreeRecord testPrototype = new SObjectTreeRecord(new Map<String, Object>{ 'StartDate' => 'TODAY:ADD_DAYS:30' }, op);

        // Assert
        System.Assert.areEqual(DateUtils.today().addDays(30), testPrototype.resolve().get('StartDate'), 'resolved start date');
    }

    @isTest
    static void resolveRecordPrototype_SetRelativeDateFormulaSubstractDays_ResolveToActualDate() {
        // Arrange
        TestSpyProvider operationStub = new TestSpyProvider();
        operationStub.registerSpy('getDescribe', ExtendedSchema.describeSObject('WorkOrder'));
        SObjectTreeBranchOperation op = (SObjectTreeBranchOperation) Test.createStub(SObjectTreeBranchOperation.class, operationStub);

        // Act
        SObjectTreeRecord testPrototype = new SObjectTreeRecord(new Map<String, Object>{ 'StartDate' => 'TODAY:ADD_DAYS:-100' }, op);

        // Assert
        System.Assert.areEqual(DateUtils.today().addDays(-100), testPrototype.resolve().get('StartDate'), 'resolved start date');
    }

    @isTest
    static void resolveRecordPrototype_SetRelativeDateFormulaToday_ResolveToToday() {
        // Arrange
        TestSpyProvider operationStub = new TestSpyProvider();
        operationStub.registerSpy('getDescribe', ExtendedSchema.describeSObject('WorkOrder'));
        SObjectTreeBranchOperation op = (SObjectTreeBranchOperation) Test.createStub(SObjectTreeBranchOperation.class, operationStub);

        // Act
        SObjectTreeRecord testPrototype = new SObjectTreeRecord(new Map<String, Object>{ 'StartDate' => 'TODAY' }, op);

        // Assert
        System.Assert.areEqual(DateUtils.today(), testPrototype.resolve().get('StartDate'), 'resolved start date');
    }

    @isTest
    static void resolveRecordPrototype_SetRelativeDateFormulaAddYears_ResolveToActualDate() {
        // Arrange
        TestSpyProvider operationStub = new TestSpyProvider();
        operationStub.registerSpy('getDescribe', ExtendedSchema.describeSObject('WorkOrder'));
        SObjectTreeBranchOperation op = (SObjectTreeBranchOperation) Test.createStub(SObjectTreeBranchOperation.class, operationStub);

        // Act
        SObjectTreeRecord testPrototype = new SObjectTreeRecord(new Map<String, Object>{ 'StartDate' => 'TODAY:ADD_YEARS:2' }, op);

        // Assert
        System.Assert.areEqual(DateUtils.today().addYears(2), testPrototype.resolve().get('StartDate'), 'resolved start date');
    }

    @isTest
    static void resolveRecordPrototype_IncompleteDateFormulas_ThrowsException() {
        // Arrange
        TestSpyProvider operationStub = new TestSpyProvider();
        operationStub.registerSpy('getDescribe', ExtendedSchema.describeSObject('WorkOrder'));
        SObjectTreeBranchOperation op = (SObjectTreeBranchOperation) Test.createStub(SObjectTreeBranchOperation.class, operationStub);

        // Act & Assert
        Set<String> invalidInputs = new Set<String>{
            'TODAY:ADD_DAYS',
            'TODAY:ADD_DAYS:',
            'TODAY;ADD_YEARS:1000',
            'NOW:ADD_DAYS:1',
            'TODAY : SUBSTRACT_DAYS : 1',
            'today:add_days:10',
            'TODAY:ADD_DAYS:one',
            '2022-10-10:ADD_DAYS:10'
        };
        for (String invalidFormula : invalidInputs) {
            try {
                SObjectTreeRecord testPrototype = new SObjectTreeRecord(new Map<String, Object>{ 'StartDate' => invalidFormula }, op);
                testPrototype.resolve();
                System.Assert.fail('Expected exception, but succeeded');
            } catch (SObjectTreeLoaderException dle) {
                String expectedMsg = String.format(
                    System.Label.Date_Or_Formula_Does_Not_Match_RegEx,
                    new List<Object>{ '^(TODAY){1}(:(ADD_DAYS|ADD_YEARS|ADD_MONTHS):(-)?\\d{1,3})?$', invalidFormula }
                );
                System.Assert.areEqual(expectedMsg, dle.getMessage(), 'error message for: ' + invalidFormula);
            }
        }
    }

    @isTest
    static void resolveRecordPrototype_InvalidDateSyntax_ThrowsException() {
        // Arrange
        TestSpyProvider operationStub = new TestSpyProvider();
        operationStub.registerSpy('getDescribe', ExtendedSchema.describeSObject('WorkOrder'));
        SObjectTreeBranchOperation op = (SObjectTreeBranchOperation) Test.createStub(SObjectTreeBranchOperation.class, operationStub);

        // Act & Assert
        Set<String> invalidInputs = new Set<String>{ '20.09.1989', '20/09/1989', '2024/07/23', '2024/7/23' };
        for (String invalidFormula : invalidInputs) {
            try {
                SObjectTreeRecord testPrototype = new SObjectTreeRecord(new Map<String, Object>{ 'StartDate' => invalidFormula }, op);
                testPrototype.resolve();
                System.Assert.fail('Expected exception, but succeeded');
            } catch (SObjectTreeLoaderException dle) {
                String expectedMsg = String.format(
                    System.Label.Date_Or_Formula_Does_Not_Match_RegEx,
                    new List<Object>{ '^(TODAY){1}(:(ADD_DAYS|ADD_YEARS|ADD_MONTHS):(-)?\\d{1,3})?$', invalidFormula }
                );
                System.Assert.areEqual(expectedMsg, dle.getMessage(), 'error message for: ' + invalidFormula);
            }
        }
    }

    @isTest
    static void setResolveRefsFalse_SetIdWithSetFields_ResolveToDirectId() {
        // Arrange
        SObjectTreeLoader dl = new SObjectTreeLoader()
            .addOperation(Schema.Case.getSObjectType(), 'Cases')
            .addSourceFile('Apex_Utils_Data_Default_Cases')
            .setResolveRefs(false)
            .getSObjectTreeLoader();
        Id mockAccountId = TestMockFactory.generateFakeId(Schema.Account.getSObjectType());

        // Act
        dl.getOperation('Cases').setField(Schema.Case.AccountId, mockAccountId);
        List<Case> cases = (List<Case>) dl.getOperation('Cases').getRecords();

        // Assert
        for (Case c : cases) {
            System.Assert.areEqual(mockAccountId, c.AccountId, 'AccountId');
        }
    }

    private static void mockAccountOperationIds(SObjectTreeLoader testLoader) {
        for (SObjectTreeRecord accRec : testLoader.getOperation('Accounts_Import').getTreeRecords().values()) {
            accRec.getRecord().Id = TestMockFactory.generateFakeId(Schema.Account.getSObjectType());
        }
    }

    private static void mockContactOperationIds(SObjectTreeLoader testLoader) {
        for (SObjectTreeRecord cRec : testLoader.getOperation('Contacts_Import').getTreeRecords().values()) {
            cRec.getRecord().Id = TestMockFactory.generateFakeId(Schema.Contact.getSObjectType());
        }
    }
}
