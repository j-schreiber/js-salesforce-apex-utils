/**
 * An individual validation message that is created for the SObject record or an specific SObject field. The message
 * supports three error levels (INFO, WARNING, ERROR).
 *
 * @author Jannis Schreiber
 * @group Validation
 * @see Validator
 * @see ValidationResult
 */
public class ValidationMessage {
    private String message;
    private List<Schema.SObjectField> fields;
    private ValidationMessage.Type messageType;

    private ValidationMessage() {
        this.fields = new List<Schema.SObjectField>();
    }

    /**
     * Create a generic validation error for an SObject record with the ERROR level.
     *
     * @param errorMessage Error message to store
     */
    public ValidationMessage(String errorMessage) {
        this(errorMessage, ValidationMessage.Type.ERROR);
    }

    /**
     * Create a validation error for an SObject record and set the error level
     *
     * @param errorMessage Error message to store
     * @param messageType   Error level (INFO,WARNING,ERROR)
     */
    public ValidationMessage(String errorMessage, ValidationMessage.Type messageType) {
        this();
        this.message = errorMessage;
        this.messageType = messageType;
    }

    /**
     * Create a default validation error for a specific SObject field
     *
     * @param errorMessage Error message to store
     * @param field        Field token of the SObject field that is affected by the error
     */
    public ValidationMessage(String errorMessage, Schema.SObjectField field) {
        this(errorMessage, field, ValidationMessage.Type.ERROR);
    }

    /**
     * Create a validation error for a specific SObject field and set the error level
     *
     * @param errorMessage Error message to store
     * @param field        Field token of the SObject field that is affected by the error
     * @param messageType  Error level (INFO,WARNING,ERROR)
     */
    public ValidationMessage(String errorMessage, Schema.SObjectField field, ValidationMessage.Type messageType) {
        this(errorMessage, messageType);
        this.fields.add(field);
    }

    public String getMessage() {
        return this.message;
    }

    public ValidationMessage.Type getType() {
        return this.messageType;
    }

    public List<Schema.SObjectField> getFields() {
        return this.fields;
    }

    public enum Type {
        INFO,
        WARNING,
        ERROR
    }
}
