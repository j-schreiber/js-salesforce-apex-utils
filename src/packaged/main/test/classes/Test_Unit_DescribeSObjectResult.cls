@isTest
public class Test_Unit_DescribeSObjectResult {
    @isTest
    static void describeSObject_WithSObjectToken_AllDefaultsInitialised() {
        // ACT
        ExtendedDescribeSObjectResult describeResult = ExtendedSchema.describeSObject(Account.SObjectType);
        // ASSERT
        Schema.DescribeSObjectResult expectedDescribe = Account.SObjectType.getDescribe();
        System.Assert.areEqual('Account', describeResult.getResult().getName(), 'initialises describe result');
        System.Assert.areEqual(expectedDescribe.fields.getMap(), describeResult.getFields(), 'returns all fields');
    }

    @isTest
    static void describeSObject_WithSObjectDescribeResult_AllDefaultsInitialised() {
        // ARRANGE
        Schema.DescribeSObjectResult orderResult = Order.getSObjectType().getDescribe();
        // ACT
        ExtendedDescribeSObjectResult describeResult = ExtendedSchema.describeSObject(orderResult);
        // ASSERT
        System.Assert.areEqual('Order', describeResult.getResult().getName(), 'initialises describe result');
    }

    @isTest
    static void describeSObject_WithValidSObjectApiName_AllDefaultsInitialised() {
        // ACT
        ExtendedDescribeSObjectResult describeResult = ExtendedSchema.describeSObject('Order');
        // ASSERT
        System.Assert.areEqual('Order', describeResult.getResult().getName(), 'initialises describe result');
    }

    @isTest
    static void describeSObject_WithInvalidSObjectApiName_ThrowsException() {
        // ACT
        try {
            ExtendedDescribeSObjectResult describeResult = ExtendedSchema.describeSObject('InvalidObject__x');
            System.Assert.fail('expected exception');
        } catch (InvalidParameterValueException ipve) {
            System.Assert.isTrue(ipve.getMessage().contains('InvalidObject__x'), 'message contains input: ' + ipve.getMessage());
        }
    }

    @isTest
    static void describeSObjects_WithValidSObjectList_ReturnsDescribeResults() {
        // ACT
        Map<String, ExtendedDescribeSObjectResult> results1 = ExtendedSchema.describeSObjects(
            new Set<String>{ 'ACCOUNT', 'contact', 'OrDeR', 'Opportunity' }
        );
        Map<String, ExtendedDescribeSObjectResult> results2 = ExtendedSchema.describeSObjects(
            new Set<String>{ 'account', 'CONTACT', 'ordeR', 'opportunity' }
        );

        // ASSERT
        System.Assert.areEqual(new Set<String>{ 'OrDeR', 'Opportunity', 'ACCOUNT', 'contact' }, results1.keySet(), 'key set');
        System.Assert.areEqual(new Set<String>{ 'ordeR', 'opportunity', 'account', 'CONTACT' }, results2.keySet(), 'key set');
        System.Assert.areEqual(results1.get('ACCOUNT'), results2.get('account'), 'returns same describe for Account');
        System.Assert.areEqual(results1.get('contact'), results2.get('CONTACT'), 'returns same describe for Contact');
        System.Assert.areEqual(results1.get('OrDeR'), results2.get('ordeR'), 'returns same describe for Order');
        System.Assert.areEqual(results1.get('Opportunity'), results2.get('opportunity'), 'returns same describe for Opportunity');
    }

    @isTest
    static void describeSObject_WithInvalidSObjectsInList_ThrowsException() {
        // ACT
        try {
            Map<String, ExtendedDescribeSObjectResult> describeResults = ExtendedSchema.describeSObjects(
                new Set<String>{ 'Account', 'Contact', 'Order', 'Opportunity', 'InvalidObject__x' }
            );
            System.Assert.fail('expected exception');
        } catch (InvalidParameterValueException ipve) {
            System.Assert.isTrue(ipve.getMessage().contains('InvalidObject__x'), 'message contains input: ' + ipve.getMessage());
        }
    }

    @isTest
    static void getField_IsInvalidFieldName_ThrowsIllegalArgumentException() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Account.SObjectType);
        // ASSERT
        try {
            describeResult.getField('SomethingInvalid__x');
            System.Assert.fail('expected exception');
        } catch (IllegalArgumentException qbe) {
            System.Assert.isTrue(qbe.getMessage().contains('SomethingInvalid__x'), 'error contains input: ' + qbe.getMessage());
            System.Assert.isTrue(qbe.getMessage().contains('Account'), 'error contains sobject name: ' + qbe.getMessage());
        }
    }

    @isTest
    static void getField_ValidFieldName_ReturnsFieldToken() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Account.SObjectType);
        // ACT
        Schema.SObjectField fieldToken = describeResult.getField('Name');
        // ASSERT
        System.Assert.areEqual(Schema.Account.Name, fieldToken, 'returns token by name');
    }

    @isTest
    static void hasField_ValidNameCaseSensitive_True() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Account.SObjectType);
        // ASSERT
        System.Assert.isTrue(describeResult.hasField('Name'), 'has field: name');
        System.Assert.isTrue(describeResult.hasField('BillingStreet'), 'has field: billing street');
        System.Assert.isTrue(describeResult.hasField('AccountNumber'), 'has field: account number');
    }

    @isTest
    static void hasField_ValidNameCaseInsensitive_True() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Account.SObjectType);
        // ASSERT
        System.Assert.isTrue(describeResult.hasField('NAME'), 'has field: name');
        System.Assert.isTrue(describeResult.hasField('billingstreet'), 'has field: billing street');
        System.Assert.isTrue(describeResult.hasField('accountNumber'), 'has field: account number');
    }

    @isTest
    static void hasField_InvalidNameCaseSensitive_False() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Account.SObjectType);
        // ASSERT
        System.Assert.areEqual(false, describeResult.hasField('Invalid__x'), 'has field: invalid name');
    }

    @isTest
    static void getParentRelationship_InvalidRelationshipName_ThrowsIllegalArgumentException() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Contact.SObjectType);
        // ASSERT
        try {
            describeResult.getParentRelationship('InvalidParentRelationship');
            System.Assert.fail('expected exception');
        } catch (IllegalArgumentException qbe) {
            System.Assert.areEqual(
                true,
                qbe.getMessage().contains('InvalidParentRelationship'),
                'error contains input: ' + qbe.getMessage()
            );
            System.Assert.isTrue(qbe.getMessage().contains('Contact'), 'error contains sobject name: ' + qbe.getMessage());
        }
    }

    @isTest
    static void getParentRelationship_UseFieldName_ThrowsIllegalArgumentException() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Contact.SObjectType);
        // ASSERT
        try {
            describeResult.getParentRelationship('AccountId');
            System.Assert.fail('expected exception');
        } catch (IllegalArgumentException qbe) {
            System.Assert.isTrue(qbe.getMessage().contains('AccountId'), 'error contains input: ' + qbe.getMessage());
            System.Assert.isTrue(qbe.getMessage().contains('Contact'), 'error contains sobject name: ' + qbe.getMessage());
        }
    }

    @isTest
    static void getParentRelationship_CaseInsensitiveInput_ReturnsLookupFieldToken() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Contact.SObjectType);
        // ACT
        Schema.DescribeFieldResult parentField = describeResult.getParentRelationship('aCCounT');
        // ASSERT
        System.Assert.areEqual(Account.SObjectType, parentField.getReferenceTo()[0], 'sobject type of lookup object');
        System.Assert.areEqual('AccountId', parentField.getName(), 'field name');
    }

    @isTest
    static void getParentRelationship_ValidRelationshipName_ReturnsLookupFieldToken() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Contact.SObjectType);
        // ACT
        Schema.DescribeFieldResult parentField = describeResult.getParentRelationship('Account');
        // ASSERT
        System.Assert.areEqual(Account.SObjectType, parentField.getReferenceTo()[0], 'sobject type of lookup object');
        System.Assert.areEqual('AccountId', parentField.getName(), 'field name');
    }

    @isTest
    static void getParentRelationshipsAsMap_ObjectHasRelationships_ReturnsAllLookupFields() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Contact.SObjectType);
        // ACT
        Map<String, Schema.DescribeFieldResult> lookupFields = describeResult.getParentRelationshipsAsMap();
        // ASSERT
        System.Assert.isFalse(lookupFields.isEmpty(), 'fields are not empty');
        for (Schema.DescribeFieldResult field : lookupFields.values()) {
            System.Assert.isNotNull(field.getRelationshipName(), 'relationship name');
        }
    }

    @isTest
    static void getChildRelationship_InvalidRelationshipName_ThrowsIllegalArgumentException() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Account.SObjectType);
        // ASSERT
        try {
            describeResult.getChildRelationship('InvalidChildRelationship');
            System.Assert.fail('expected exception');
        } catch (IllegalArgumentException qbe) {
            System.Assert.areEqual(
                true,
                qbe.getMessage().contains('InvalidChildRelationship'),
                'error contains input: ' + qbe.getMessage()
            );
            System.Assert.isTrue(qbe.getMessage().contains('Account'), 'error contains sobject name: ' + qbe.getMessage());
        }
    }

    @isTest
    static void getChildRelationship_ValidRelationshipName_ReturnsChildRelationship() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Account.SObjectType);
        // ACT
        Schema.ChildRelationship childRel = describeResult.getChildRelationship('Contacts');
        // ASSERT
        System.Assert.areEqual(Contact.SObjectType, childRel.getChildSObject(), 'sobject type of child relationship');
        System.Assert.areEqual('Contacts', childRel.getRelationshipName(), 'relationship return');
    }

    @isTest
    static void getChildRelationship_CaseInsensitiveInput_ReturnsChildRelationship() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Account.SObjectType);
        // ACT
        Schema.ChildRelationship childRel = describeResult.getChildRelationship('CONTACTS');
        // ASSERT
        System.Assert.areEqual(Contact.SObjectType, childRel.getChildSObject(), 'sobject type of child relationship');
        System.Assert.areEqual('Contacts', childRel.getRelationshipName(), 'relationship return');
    }

    @isTest
    static void getEditableFields_Account_ReturnsEditableNonSystemFields() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Account.SObjectType);

        // ACT
        Map<String, Schema.SObjectField> fields = describeResult.getEditableFields();

        // ASSERT
        System.Assert.areEqual(false, fields.containsKey('Id'), 'does not contain Id: ' + fields.keySet());
        System.Assert.areEqual(false, fields.containsKey('id'), 'does not contain id: ' + fields.keySet());
        System.Assert.areEqual(false, fields.containsKey('CreatedDate'), 'does not contain CreatedDate: ' + fields.keySet());
        System.Assert.areEqual(false, fields.containsKey('LastModifiedDate'), 'does not contain LastModifiedDate: ' + fields.keySet());
        System.Assert.areEqual(false, fields.containsKey('BillingAddress'), 'does not contain BillingAddress: ' + fields.keySet());
        System.Assert.isTrue(fields.containsKey('Name'), 'does contain Name: ' + fields.keySet());
        System.Assert.isTrue(fields.containsKey('BillingStreet'), 'does contain BillingStreet: ' + fields.keySet());
    }

    @isTest
    static void resolveFieldLiteral_PlainField_ReturnsSingleToken() {
        // ACT
        ExtendedDescribeSObjectResult result = new ExtendedDescribeSObjectResult(Schema.Contact.SObjectType);

        // ASSERT
        System.Assert.areEqual(new List<Schema.SObjectField>{ Schema.Contact.LastName }, result.resolveFieldLiteral('LastName'));
        System.Assert.areEqual(new List<Schema.SObjectField>{ Schema.Contact.LastName }, result.resolveFieldLiteral('lastname'));
        System.Assert.areEqual(new List<Schema.SObjectField>{ Schema.Contact.Email }, result.resolveFieldLiteral('Email'));
        System.Assert.areEqual(new List<Schema.SObjectField>{ Schema.Contact.Email }, result.resolveFieldLiteral('EMAIL'));
        System.Assert.areEqual(new List<Schema.SObjectField>{ Schema.Contact.MailingStreet }, result.resolveFieldLiteral('MailingStreet'));
    }

    @isTest
    static void resolveFieldLiteral_ParentRelationshipField_ReturnsTokenList() {
        // ACT
        ExtendedDescribeSObjectResult result = new ExtendedDescribeSObjectResult(Schema.Contact.SObjectType);

        // ASSERT
        System.Assert.areEqual(
            new List<Schema.SObjectField>{ Schema.Contact.ReportsToId, Schema.Contact.LastName },
            result.resolveFieldLiteral('ReportsTo.LastName')
        );
        System.Assert.areEqual(
            new List<Schema.SObjectField>{ Schema.Contact.AccountId, Schema.Account.ParentId, Schema.Account.AccountNumber },
            result.resolveFieldLiteral('Account.Parent.AccountNumber')
        );
    }

    @isTest
    static void resolveFieldLiteral_ChildRelationship_ThrowsException() {
        // ACT
        ExtendedDescribeSObjectResult result = new ExtendedDescribeSObjectResult(Schema.Account.SObjectType);

        // ASSERT
        try {
            result.resolveFieldLiteral('Contacts');
            System.Assert.fail('Expected exception');
        } catch (IllegalArgumentException e) {
            System.Assert.isTrue(e.getMessage().contains('Contacts'), 'message contains Contacts' + e.getMessage());
        }
    }
}
