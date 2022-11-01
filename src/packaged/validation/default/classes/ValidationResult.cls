/**
 * The validation result is returned by the `validate()` method of the `Validator` interface. It contains all validation messages
 * and provides utilities to work with validation messages.
 *
 * @author Jannis Schreiber
 * @group Validation
 * @see Validator
 */
public class ValidationResult {
    private List<ValidationMessage> messages;
    private Validation.ErrorMode errorMode;

    /**
     * Initialize a new validation result with an empty error message cache
     */
    public ValidationResult() {
        this.messages = new List<ValidationMessage>();
        this.errorMode = Validation.ErrorMode.SILENT;
    }

    /**
     * Initialize a new validation result with an existing validation result. This constructor
     * allows to chain construction of validation results.
     */
    public ValidationResult(ValidationResult existingResult) {
        this();
        this.append(existingResult);
    }

    /**
     * Sets the error mode that is used, when `isValid` or `getMessages` is called.
     *
     * @param newMode
     */
    public void setMode(Validation.ErrorMode newMode) {
        this.errorMode = newMode;
    }

    /**
     * Appends an existing validation result to this validation result and adds all
     * error messages in the same order.
     *
     * @param existingResult The existing validation result
     */
    public void append(ValidationResult existingResult) {
        for (ValidationMessage ve : existingResult.getMessages()) {
            this.addMessage(ve);
        }
    }

    /**
     * Add an error message to the validation result and set the error level.
     *
     * @param errorMessage Error message to add
     * @param errorLevel The error level of the validation error
     */
    public void addMessage(String errorMessage, ValidationMessage.Type errorLevel) {
        if (String.isNotBlank(errorMessage)) {
            this.addMessage(new ValidationMessage(errorMessage, errorLevel));
        }
    }

    /**
     * Add an error message to the validation result with the default errorlevel `ERROR`.
     *
     * @param errorMessage       Error message to add
     */
    public void addMessage(String errorMessage) {
        if (String.isNotBlank(errorMessage)) {
            this.addMessage(new ValidationMessage(errorMessage));
        }
    }

    /**
     * Add a pre-configured validation error to the validation result.
     *
     * @param errorMessage       Error message to add
     */
    public void addMessage(ValidationMessage errorMessage) {
        this.messages.add(errorMessage);
    }

    /**
     * Evaluates, if the list of messages for the validation result is empty (true) or not (false).
     * Uses the error mode of the validation result (default is SILENT).
     *
     * @return `Boolean`           True, if no messages have been added to the validation result
     */
    public Boolean isValid() {
        return this.getMessages().isEmpty();
    }

    /**
     * Checks for messages and returns true, if no messages are found. For APEX_EXCEPTION validation mode,
     * an exception is thrown.
     *
     * @param mode  Error mode enum, overrides any previously set mode.
     * @return      `Boolean`
     */
    public Boolean isValid(Validation.ErrorMode mode) {
        return this.getMessages(mode).isEmpty();
    }

    /**
     * Returns all error messages that are added to the validation result. Uses
     * the error mode of the validation result (default is SILENT).
     *
     * @return `List<ValidationMessage>`      All error messages
     */
    public List<ValidationMessage> getMessages() {
        return this.getMessages(this.errorMode);
    }

    /**
     * Returns all error messages that are added to the validation result OR
     * throws an exception, containing all messages as string.
     *
     * @param mode Error mode enum, overrides any previously set mode.
     * @return `List<ValidationMessage>`      All error messages
     */
    public List<ValidationMessage> getMessages(Validation.ErrorMode mode) {
        switch on mode {
            when APEX_EXCEPTION {
                if (!this.messages.isEmpty()) {
                    this.throwValidationException();
                }
            }
            when LWC_EXCEPTION {
                if (!this.messages.isEmpty()) {
                    this.throwAuraHandledException();
                }
            }
        }
        return messages;
    }

    /**
     * Returns all error messages of this validation result as blank strings
     *
     * @return `List<String>`      All error messages
     */
    public List<String> getMessagesAsString() {
        List<String> errStrings = new List<String>();
        for (ValidationMessage ve : this.getMessages())
            errStrings.add(ve.getMessage());
        return errStrings;
    }

    /**
     * Returns all error messages of this validation result as a single concatenated string.
     *
     * @return `String`      All error messages in a single string
     */
    public String getMessagesAsSingleString() {
        return String.join(getMessagesAsString(), '; ');
    }

    /**
     * Get validation messages filtered by error level.
     *
     * @param messageType The desired error level to filter
     * @return `List<ValidationMessage>`      All error messages
     */
    public List<ValidationMessage> getMessages(ValidationMessage.Type messageType) {
        return filterValidationMessagesByErrorLevel(messageType);
    }

    /**
     * Get validation messages filtered by error level as a list of strings.
     *
     * @param messageType The desired error level to filter for
     * @return `List<String>`      All error messages
     */
    public List<String> getMessagesAsString(ValidationMessage.Type messageType) {
        List<String> messagestrings = new List<String>();
        for (ValidationMessage ve : this.getMessages(messageType)) {
            messagestrings.add(ve.getMessage());
        }
        return messagestrings;
    }

    /**
     * Get validation messages filtered by error level as a single string, concatenated with semikolon.
     *
     * @param messageType The desired error level to filter for
     * @return `String` All error messages in a single string
     */
    public String getMessagesAsSingleString(ValidationMessage.Type messageType) {
        return this.getMessagesAsSingleString(messageType, '; ');
    }

    /**
     * Get validation messages filtered by error level as a single string and set the concatenator.
     *
     * @param messageType The desired error level to filter for
     * @param concatenator The concatenator to use
     * @return `String` All error messages in a single string
     */
    public String getMessagesAsSingleString(ValidationMessage.Type messageType, String concatenator) {
        return String.join(this.getMessagesAsString(messageType), concatenator);
    }

    /**                                    PRIVATE METHODS                                  */

    private List<ValidationMessage> filterValidationMessagesByErrorLevel(ValidationMessage.Type messageType) {
        List<ValidationMessage> filteredmessages = new List<ValidationMessage>();
        for (ValidationMessage ve : this.getMessages()) {
            if (ve.getType() == messageType) {
                filteredmessages.add(ve);
            }
        }
        return filteredmessages;
    }

    private void throwValidationException() {
        ValidationException ve = new ValidationException();
        ve.setMessage(this.getSilentmessages());
        throw ve;
    }

    private void throwAuraHandledException() {
        String msg = this.getSilentmessages();
        AuraHandledException ahe = new AuraHandledException(msg);
        ahe.setMessage(msg);
        throw ahe;
    }

    private String getSilentmessages() {
        Validation.ErrorMode originalMode = this.errorMode;
        this.setMode(Validation.ErrorMode.SILENT);
        String errs = this.getMessagesAsSingleString();
        this.setMode(originalMode);
        return errs;
    }
}
