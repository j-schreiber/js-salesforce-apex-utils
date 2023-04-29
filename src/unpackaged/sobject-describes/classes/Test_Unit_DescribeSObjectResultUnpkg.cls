@isTest
public class Test_Unit_DescribeSObjectResultUnpkg {
    @isTest
    static void getFieldSet_IsInvalidFieldSetName_ThrowsIllegalArgumentException() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Account.SObjectType);
        // ASSERT
        try {
            describeResult.getFieldSet('Non_Existing_Field_Set');
            System.Assert.fail('expected exception');
        } catch (IllegalArgumentException qbe) {
            System.Assert.isTrue(qbe.getMessage().contains('Non_Existing_Field_Set'), 'error contains input: ' + qbe.getMessage());
            System.Assert.isTrue(qbe.getMessage().contains('Account'), 'error contains sobject name: ' + qbe.getMessage());
        }
    }

    @isTest
    static void getFieldSet_ValidFieldSetName_ReturnsFieldSet() {
        // ARRANGE
        ExtendedDescribeSObjectResult describeResult = new ExtendedDescribeSObjectResult(Contact.SObjectType);
        // ACT
        Schema.FieldSet fieldSet = describeResult.getFieldSet('powersuite__Cache_Testing_Fields');
        // ASSERT
        System.Assert.areEqual('Cache_Testing_Fields', fieldSet.getName(), 'returns field set by name');
    }

    @isTest
    static void resolveFieldLiteral_ValidCustomFieldName_ReturnsFieldToken() {
        // Act
        ExtendedDescribeSObjectResult result = new ExtendedDescribeSObjectResult(Schema.Contact.SObjectType);
        List<Schema.SObjectField> resolvedTokens = result.resolveFieldLiteral('powersuite__TestField__c');

        // Assert
        System.Assert.areEqual(new List<Schema.SObjectField>{ Schema.Contact.TestField__c }, resolvedTokens, 'tokens for: TestField__c');
    }
}
