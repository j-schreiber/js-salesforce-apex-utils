/**
 * The validator interface allows you to implement custom validation code.
 *
 * @author Jannis Schreiber
 * @group Validation
 * @see ValidationResult
 * @see SObjectUtility
 */
public interface Validator {
    /**
     * Implement custom validation logic that is executed on the input record.
     * Make sure that your code is generic and can run in bulkified context (e.g. without SELECT / DML statements).
     *
     * @param   sourceRecord    The source sobject record that is validated
     *
     * @return                  The validation result
     */
    ValidationResult validate(SObject sourceRecord);

    /**
     * Implement this method to tell the converter all fields that are required for the validation.
     * The engine ensures, that these fields are always included in the query. You can use field API names
     * (`AccountId` or `MyCustomField__c`), relationships (`Account.Name`) or subqueries
     * (`(SELECT Id,Name FROM Contacts WHERE Email != NULL)`)
     *
     * @return                  Field API Names or subquery that are required for the validation
     */
    Set<String> getFields();
}
