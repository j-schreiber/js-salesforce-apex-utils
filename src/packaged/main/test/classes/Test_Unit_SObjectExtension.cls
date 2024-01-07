@isTest
public class Test_Unit_SObjectExtension {
    @isTest
    static void mergeRecords_IncompatibleSObjects_ThrowsException() {
        // Act
        Account acc1 = new Account(Name = 'Test Name');
        try {
            SObjectExtension.mergeRecords(acc1, new Contact(LastName = 'Tester'));
            System.Assert.fail('Expected exception, but succeded');
        } catch (IllegalArgumentException iae) {
            System.Assert.isTrue(iae.getMessage().contains('Account'), 'contains Account: ' + iae.getMessage());
            System.Assert.isTrue(iae.getMessage().contains('Contact'), 'contains Contact: ' + iae.getMessage());
        }
    }

    @isTest
    static void mergeRecords_BasicFields_AllValuesMerged() {
        // Act
        Account acc1 = new Account(Name = 'Test Name');
        Account acc2 = new Account(Name = 'Second Test Name', AccountNumber = '123');
        SObjectExtension.mergeRecords(acc1, acc2);

        // Assert
        System.Assert.areEqual(new Account(Name = 'Second Test Name', AccountNumber = '123'), acc1, 'all fields merged');
    }

    @isTest
    static void mergeRecords_WithSystemFields_OnlyBasicFieldsMerged() {
        // Act
        Account acc1 = (Account) TestMockFactory.createSObjectMock(
            Schema.Account.SObjectType,
            new Map<String, Object>{ 'Name' => 'Test Name' }
        );
        Account acc2 = (Account) TestMockFactory.createSObjectMock(
            Schema.Account.SObjectType,
            new Map<String, Object>{
                'Name' => 'Second Test Name',
                'CreatedDate' => DateTime.newInstance(2024, 1, 1, 12, 0, 0),
                'AccountNumber' => '123'
            }
        );
        Id originalId = acc1.Id;
        SObjectExtension.mergeRecords(acc1, acc2);

        // Assert
        System.Assert.areEqual(
            new Account(Id = originalId, Name = 'Second Test Name', AccountNumber = '123'),
            acc1,
            'only editable fields merged'
        );
    }

    @isTest
    static void mergeRecords_SecondaryWithParentObject_ParentMerged() {
        // Act
        Account acc1 = (Account) TestMockFactory.createSObjectMock(
            Schema.Account.SObjectType,
            new Map<String, Object>{ 'Name' => 'Test Name' }
        );
        Account acc2 = (Account) TestMockFactory.createSObjectMock(
            Schema.Account.SObjectType,
            new Map<String, Object>{ 'ParentId' => new Account(Name = 'Parent Account'), 'AccountNumber' => '123' }
        );
        Id originalId = acc1.Id;
        SObjectExtension.mergeRecords(acc1, acc2);

        // Assert
        Account expectedAccount = (Account) TestMockFactory.createSObjectMock(
            Schema.Account.SObjectType,
            new Map<String, Object>{
                'Id' => originalId,
                'Name' => 'Test Name',
                'ParentId' => new Account(Id = acc2.Parent.Id, Name = 'Parent Account'),
                'AccountNumber' => '123'
            }
        );
        System.Assert.areEqual(
            new Set<String>{ 'Id', 'Name', 'ParentId', 'Parent', 'AccountNumber' },
            acc1.getPopulatedFieldsAsMap().keySet(),
            'populated fields'
        );
        for (String field : expectedAccount.getPopulatedFieldsAsMap().keySet()) {
            System.Assert.areEqual(
                expectedAccount.getPopulatedFieldsAsMap().get(field),
                acc1.getPopulatedFieldsAsMap().get(field),
                'value for : ' + field
            );
        }
    }

    @isTest
    static void mergeRecords_BothRecordsWithParentObject_ParentMerged() {
        // Act
        Account acc1 = (Account) TestMockFactory.createSObjectMock(
            Schema.Account.SObjectType,
            new Map<String, Object>{
                'Name' => 'Test Name',
                'ParentId' => new Account(Name = 'Parent Account One', BillingStreet = 'Yolostreet 1')
            }
        );
        Account acc2 = (Account) TestMockFactory.createSObjectMock(
            Schema.Account.SObjectType,
            new Map<String, Object>{ 'ParentId' => new Account(Name = 'Parent Account Two'), 'AccountNumber' => '123' }
        );
        Id originalId = acc1.Id;
        Account mergeResult = (Account) SObjectExtension.mergeRecords(acc1, acc2);

        // Assert
        Account expectedAccount = (Account) TestMockFactory.createSObjectMock(
            Schema.Account.SObjectType,
            new Map<String, Object>{
                'Id' => originalId,
                'Name' => 'Test Name',
                'ParentId' => new Account(Id = acc1.Parent.Id, Name = 'Parent Account Two', BillingStreet = 'Yolostreet 1'),
                'AccountNumber' => '123'
            }
        );
        // mock factory always sets lookup field and parent.
        // we are only interested in the parent object, not the lookup
        expectedAccount.ParentId = acc2.ParentId;
        System.Assert.areEqual(
            new Set<String>{ 'Id', 'Name', 'ParentId', 'Parent', 'AccountNumber' },
            mergeResult.getPopulatedFieldsAsMap().keySet(),
            'populated fields'
        );
        for (String field : expectedAccount.getPopulatedFieldsAsMap().keySet()) {
            System.Assert.areEqual(
                expectedAccount.getPopulatedFieldsAsMap().get(field),
                mergeResult.getPopulatedFieldsAsMap().get(field),
                'value for : ' + field
            );
        }
    }

    @isTest
    static void mergeRecords_MergeEmpty_NullValuesOverwritten() {
        // Act
        Account acc1 = new Account(Name = 'Test Name');
        Account acc2 = new Account(Name = null, AnnualRevenue = null, NumberOfEmployees = null);
        SObjectExtension.mergeRecords(acc1, acc2);

        // Assert
        System.Assert.areEqual(null, acc1.Name, 'Name is merged');
        System.Assert.areEqual(null, acc1.AnnualRevenue, 'Revenue field is merged');
        System.Assert.areEqual(null, acc1.NumberOfEmployees, 'employees field is merged');
        System.Assert.isTrue(acc1.isSet('Name'), 'name is set');
        System.Assert.isTrue(acc1.isSet('AnnualRevenue'), 'revenue is set');
        System.Assert.isTrue(acc1.isSet('NumberOfEmployees'), 'number of employees is set');
    }

    @isTest
    static void mergeRecords_OnlyMergeNonEmpty_NullsIgnored() {
        // Act
        Opportunity oppty1 = new Opportunity(Name = 'Test Name', CloseDate = Date.newInstance(2024, 1, 6));
        Opportunity oppty2 = new Opportunity(Name = null, Amount = null, TotalOpportunityQuantity = null, CloseDate = null);
        SObjectExtension.MergeOptions opts = new SObjectExtension.MergeOptions();
        opts.onlyMergeNonEmptyFields = true;
        SObjectExtension.mergeRecords(oppty1, oppty2, opts);

        // Assert
        System.Assert.areEqual('Test Name', oppty1.Name, 'name is not merged');
        System.Assert.areEqual(null, oppty1.Amount, 'amount field is not merged');
        System.Assert.areEqual(null, oppty1.TotalOpportunityQuantity, 'TotalOpportunityQuantity is not merged');
        System.Assert.areEqual(Date.newInstance(2024, 1, 6), oppty1.CloseDate, 'close date is not merged');
        System.Assert.isTrue(oppty1.isSet('Name'), 'name is set');
        System.Assert.isTrue(oppty1.isSet('CloseDate'), 'close date is set');
        System.Assert.isFalse(oppty1.isSet('Amount'), 'amount is not set');
        System.Assert.isFalse(oppty1.isSet('TotalOpportunityQuantity'), 'TotalOpportunityQuantity is not set');
    }

    @isTest
    static void mergeRecords_IgnoreFields_FieldsNotWritten() {
        // Act
        Opportunity oppty1 = new Opportunity(Name = 'Test Name', CloseDate = Date.newInstance(2024, 1, 6));
        Opportunity oppty2 = new Opportunity(
            Name = 'Name Two',
            Amount = 9999,
            TotalOpportunityQuantity = 1000,
            CloseDate = Date.newInstance(2023, 12, 30)
        );
        SObjectExtension.MergeOptions opts = new SObjectExtension.MergeOptions();
        opts.ignoreFields.add('nAmE');
        opts.ignoreFields.add('CLOSEDATE');
        SObjectExtension.mergeRecords(oppty1, oppty2, opts);

        // Assert
        System.Assert.areEqual('Test Name', oppty1.Name, 'name is not merged');
        System.Assert.areEqual(9999, oppty1.Amount, 'amount field is not merged');
        System.Assert.areEqual(1000, oppty1.TotalOpportunityQuantity, 'TotalOpportunityQuantity is not merged');
        System.Assert.areEqual(Date.newInstance(2024, 1, 6), oppty1.CloseDate, 'close date is not merged');
    }
}
