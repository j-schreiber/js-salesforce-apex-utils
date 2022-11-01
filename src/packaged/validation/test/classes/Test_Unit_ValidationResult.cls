@isTest
public class Test_Unit_ValidationResult {
    @isTest
    static void init_BlankValidationResult_NoErrors() {
        // ACT
        ValidationResult vr = new ValidationResult();
        // ASSERT
        System.Assert.isTrue(vr.isValid(), 'isValid()');
        System.Assert.isTrue(vr.getMessages().isEmpty(), 'getMessages().isEmpty()');
        System.Assert.isTrue(vr.getMessagesAsString().isEmpty(), 'getMessagesAsString().isEmpty()');
    }

    @isTest
    static void init_ExistingResultNoErrors_ValidResultInitialized() {
        // ARRANGE
        ValidationResult validFirstResult = new ValidationResult();
        // ACT
        ValidationResult secondResult = new ValidationResult(validFirstResult);
        // ASSERT
        System.Assert.isTrue(secondResult.isValid(), 'secondResult.isValid()');
    }

    @isTest
    static void init_ExistingResultWithErrors_ErrorsFromExistingResultIntegrated() {
        // ARRANGE
        ValidationResult firstResult = new ValidationResult();
        firstResult.addMessage('Test Error');
        // ACT
        ValidationResult secondResult = new ValidationResult(firstResult);
        // ASSERT
        System.Assert.areEqual(false, secondResult.isValid(), 'secondResult.isValid()');
        System.Assert.areEqual(1, secondResult.getMessages().size(), 'secondResult.getMessages().size()');
    }

    @isTest
    static void init_MultipleChainedResults_ErrorsFromExistingResultsIntegrated() {
        // ARRANGE
        ValidationResult firstResult = new ValidationResult();
        firstResult.addMessage('Test Error');
        ValidationResult secondResult = new ValidationResult(firstResult);
        secondResult.addMessage('Second Test Error');
        // ACT
        ValidationResult thirdResult = new ValidationResult(secondResult);
        // ASSERT
        System.Assert.areEqual(false, thirdResult.isValid(), 'thirdResult.isValid()');
        System.Assert.areEqual(2, thirdResult.getMessages().size(), 'thirdResult.getMessages().size()');
    }

    @isTest
    static void append_EmptyExistingResult_NoErrorsAdded() {
        // ARRANGE
        ValidationResult firstResult = new ValidationResult();
        // ACT
        firstResult.append(new ValidationResult());
        // ASSERT
        System.Assert.isTrue(firstResult.isValid(), 'isValid()');
    }

    @isTest
    static void append_ExistingResultWithErrorsToEmptyResult_AllErrorsAdded() {
        // ARRANGE
        ValidationResult firstResult = new ValidationResult();
        ValidationResult secondResult = new ValidationResult();
        secondResult.addMessage(new ValidationMessage('First Error', ValidationMessage.Type.ERROR));
        secondResult.addMessage(new ValidationMessage('Second Warning', ValidationMessage.Type.WARNING));
        // ACT
        firstResult.append(secondResult);
        // ASSERT
        System.Assert.areEqual(false, firstResult.isValid(), 'isValid()');
        System.Assert.areEqual(secondResult.getMessages()[0], firstResult.getMessages()[0], 'Order of errors. First error.');
        System.Assert.areEqual(secondResult.getMessages()[1], firstResult.getMessages()[1], 'Order of errors. Second error.');
    }

    @isTest
    static void append_ExistingResultWithErrorsToResultWithErrors_AllErrorsAdded() {
        // ARRANGE
        ValidationResult firstResult = new ValidationResult();
        firstResult.addMessage('First Result Error');
        ValidationResult secondResult = new ValidationResult();
        secondResult.addMessage(new ValidationMessage('First Error', ValidationMessage.Type.ERROR));
        secondResult.addMessage(new ValidationMessage('Second Warning', ValidationMessage.Type.WARNING));
        // ACT
        firstResult.append(secondResult);
        // ASSERT
        System.Assert.areEqual(false, firstResult.isValid(), 'isValid()');
        System.Assert.areEqual(secondResult.getMessages()[0], firstResult.getMessages()[1], 'Order of errors. First error.');
        System.Assert.areEqual(secondResult.getMessages()[1], firstResult.getMessages()[2], 'Order of errors. Second error.');
    }

    @isTest
    static void addError_DefaultErrorString_DefaultValidationMessageAdded() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        // ACT
        vr.addMessage('Test');
        // ASSERT
        System.Assert.areEqual(1, vr.getMessages().size(), 'getMessages().size()');
        System.Assert.areEqual(ValidationMessage.Type.ERROR, vr.getMessages()[0].getType(), 'Level of created error');
        System.Assert.areEqual('Test', vr.getMessages()[0].getMessage(), 'getMessages()[0].ErrorMsg');
    }

    @isTest
    static void addError_ErrorMessageWithErrorLevel_SpecificValidationMessageAdded() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        // ACT
        vr.addMessage('Test', ValidationMessage.Type.INFO);
        // ASSERT
        System.Assert.areEqual(1, vr.getMessages().size(), 'getMessages().size()');
        System.Assert.areEqual(ValidationMessage.Type.INFO, vr.getMessages()[0].getType(), 'Level of created error');
        System.Assert.areEqual('Test', vr.getMessages()[0].getMessage(), 'getMessages()[0].ErrorMsg');
    }

    @isTest
    static void addError_PreconfiguredValidationMessage_ValidationMessageAdded() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        // ACT
        vr.addMessage(new ValidationMessage('Test'));
        // ASSERT
        System.Assert.areEqual(1, vr.getMessages().size(), 'getMessages().size()');
        System.Assert.areEqual('Test', vr.getMessages()[0].getMessage(), 'getMessages()[0].ErrorMsg');
    }

    @isTest
    static void addError_PreconfiguredErrorWithFieldAndLevel_ValidationMessageAdded() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        // ACT
        vr.addMessage(new ValidationMessage('Info Test', Schema.Account.BillingStreet, ValidationMessage.Type.INFO));
        // ASSERT
        System.Assert.areEqual(1, vr.getMessages().size(), 'getMessages().size()');
        System.Assert.areEqual('Info Test', vr.getMessages()[0].getMessage(), 'getMessages()[0].getMessage()');
        System.Assert.areEqual(ValidationMessage.Type.INFO, vr.getMessages()[0].getType(), 'getMessages()[0].getType()');
        System.Assert.areEqual(1, vr.getMessages()[0].getFields().size(), 'getMessages()[0].getFields().size()');
        System.Assert.areEqual(Schema.Account.BillingStreet, vr.getMessages()[0].getFields()[0], 'getMessages()[0].Fields[0]');
    }

    @isTest
    static void addError_PreconfiguredErrorWithField_ValidationMessageAdded() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        // ACT
        vr.addMessage(new ValidationMessage('Test', Schema.Account.BillingStreet));
        // ASSERT
        System.Assert.areEqual(1, vr.getMessages().size(), 'getMessages().size()');
        System.Assert.areEqual('Test', vr.getMessages()[0].getMessage(), 'getMessages()[0].getMessage()');
        System.Assert.areEqual(ValidationMessage.Type.ERROR, vr.getMessages()[0].getType(), 'getMessages()[0].getType()');
        System.Assert.areEqual(1, vr.getMessages()[0].getFields().size(), 'getMessages()[0].getFields().size()');
        System.Assert.areEqual(Schema.Account.BillingStreet, vr.getMessages()[0].getFields()[0], 'getMessages()[0].Fields[0]');
    }

    @isTest
    static void addError_PreconfigureErrorLevel_ValidationMessageAdded() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        // ACT
        vr.addMessage(new ValidationMessage('Test', ValidationMessage.Type.WARNING));
        // ASSERT
        System.Assert.areEqual(1, vr.getMessages().size(), 'getMessages().size()');
        System.Assert.areEqual(ValidationMessage.Type.WARNING, vr.getMessages()[0].getType(), 'getMessages()[0].getType()');
        System.Assert.areEqual('Test', vr.getMessages()[0].getMessage(), 'getMessages()[0].ErrorMsg');
    }

    @isTest
    static void getMessages_FilterForLevel_FilteredErrorList() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        vr.addMessage(new ValidationMessage('Test', ValidationMessage.Type.WARNING));
        vr.addMessage(new ValidationMessage('Another Warning', ValidationMessage.Type.WARNING));
        vr.addMessage(new ValidationMessage('Info Test With Field', Schema.Account.BillingStreet, ValidationMessage.Type.INFO));
        // ACT
        List<ValidationMessage> filteredErrs = vr.getMessages(ValidationMessage.Type.ERROR);
        List<ValidationMessage> filteredWarnings = vr.getMessages(ValidationMessage.Type.WARNING);
        List<ValidationMessage> filteredInfos = vr.getMessages(ValidationMessage.Type.INFO);
        // ASSERT
        System.Assert.areEqual(0, filteredErrs.size(), 'Filtering ERROR results');
        System.Assert.areEqual(2, filteredWarnings.size(), 'Filtering WARNING results');
        System.Assert.areEqual(1, filteredInfos.size(), 'Filtering INFO results');
    }

    @isTest
    static void getMessagesAsString_HasErrors_ErrorMessagesAsListOfStrings() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        // ACT
        vr.addMessage(new ValidationMessage('Test', ValidationMessage.Type.WARNING));
        vr.addMessage(new ValidationMessage('Info Test With Field', Schema.Account.BillingStreet, ValidationMessage.Type.INFO));
        // ASSERT
        System.Assert.areEqual(2, vr.getMessagesAsString().size(), 'getMessagesAsSingleString().size()');
        System.Assert.areEqual('Test', vr.getMessagesAsString()[0], '[0]');
        System.Assert.areEqual('Info Test With Field', vr.getMessagesAsString()[1], '[1]');
    }

    @isTest
    static void getMessagesAsString_FilterForLevel_FilteredErrorList() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        vr.addMessage(new ValidationMessage('Test', ValidationMessage.Type.WARNING));
        vr.addMessage(new ValidationMessage('Another Warning', ValidationMessage.Type.WARNING));
        vr.addMessage(new ValidationMessage('Info Test With Field', Schema.Account.BillingStreet, ValidationMessage.Type.INFO));
        // ACT
        List<String> filteredWarnings = vr.getMessagesAsString(ValidationMessage.Type.WARNING);
        List<String> filteredInfos = vr.getMessagesAsString(ValidationMessage.Type.INFO);
        // ASSERT
        System.Assert.areEqual(2, filteredWarnings.size(), 'Filtering WARNING results');
        System.Assert.areEqual(new List<String>{ 'Test', 'Another Warning' }, filteredWarnings, 'Content of warnings');
        System.Assert.areEqual(1, filteredInfos.size(), 'Filtering INFO results');
        System.Assert.areEqual(new List<String>{ 'Info Test With Field' }, filteredInfos, 'Content of infos');
    }

    @isTest
    static void getMessagesAsSingleString_HasErrors_ConcatenatedErrorsReturned() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        // ACT
        vr.addMessage(new ValidationMessage('Test', ValidationMessage.Type.WARNING));
        vr.addMessage(new ValidationMessage('Info Test With Field', Schema.Account.BillingStreet, ValidationMessage.Type.INFO));
        // ASSERT
        System.Assert.areEqual('Test; Info Test With Field', vr.getMessagesAsSingleString(), 'getMessagesAsSingleString()');
    }

    @isTest
    static void getMessagesAsSingleString_FilterForLevel_FilteredLevelsConcatenated() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        vr.addMessage(new ValidationMessage('Test', ValidationMessage.Type.WARNING));
        vr.addMessage(new ValidationMessage('Another Warning', ValidationMessage.Type.WARNING));
        vr.addMessage(new ValidationMessage('Info Test With Field', Schema.Account.BillingStreet, ValidationMessage.Type.INFO));
        // ACT
        String warnings = vr.getMessagesAsSingleString(ValidationMessage.Type.WARNING);
        // ASSERT
        String expectedWarnings = String.join(new List<String>{ 'Test', 'Another Warning' }, '; ');
        System.Assert.areEqual(expectedWarnings, warnings, 'Concatenated with default');
    }

    @isTest
    static void getMessagesAsSingleString_FilterForLevelCustomConcatenator_FilteredLevelsConcatenated() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        vr.addMessage(new ValidationMessage('Test', ValidationMessage.Type.WARNING));
        vr.addMessage(new ValidationMessage('Another Warning', ValidationMessage.Type.WARNING));
        vr.addMessage(new ValidationMessage('Info Test With Field', Schema.Account.BillingStreet, ValidationMessage.Type.INFO));
        // ACT
        String warnings = vr.getMessagesAsSingleString(ValidationMessage.Type.WARNING, ' -- ');
        // ASSERT
        String expectedWarnings = String.join(new List<String>{ 'Test', 'Another Warning' }, ' -- ');
        System.Assert.areEqual(expectedWarnings, warnings, 'Concatenated custom concatenator');
    }

    @isTest
    static void getMessagesAsSingleString_NoErrors_EmptyString() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        // ASSERT
        System.Assert.areEqual('', vr.getMessagesAsSingleString(), 'getMessagesAsSingleString()');
    }

    @isTest
    static void getMessages_SilentModeHasErrors_ErrorsReturned() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        vr.addMessage('Some Error');
        // ACT
        List<ValidationMessage> errsWithMode = vr.getMessages(Validation.ErrorMode.SILENT);
        List<ValidationMessage> errsWithoutMode = vr.getMessages();
        // ASSERT
        System.Assert.areEqual(1, errsWithMode.size(), 'number of errors');
        System.Assert.areEqual('Some Error', errsWithMode[0].getMessage(), 'first getMessage()');
        System.Assert.areEqual(1, errsWithoutMode.size(), 'number of errors');
        System.Assert.areEqual('Some Error', errsWithoutMode[0].getMessage(), 'first getMessage()');
    }

    @isTest
    static void getMessages_ExceptionModeHasErrors_ThrowsException() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        vr.addMessage('Some Error');

        // ASSERT
        try {
            vr.getMessages(Validation.ErrorMode.APEX_EXCEPTION);
            System.Assert.fail('Should have thrown exception');
        } catch (ValidationException ve) {
            System.Assert.areEqual('Some Error', ve.getMessage());
        }
        try {
            vr.getMessages(Validation.ErrorMode.LWC_EXCEPTION);
            System.Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ahe) {
            System.Assert.areEqual('Some Error', ahe.getMessage());
        }
    }

    @isTest
    static void isValid_ExceptionModeHasErrors_ThrowsException() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        vr.addMessage('Some Error');

        // ASSERT
        try {
            vr.isValid(Validation.ErrorMode.APEX_EXCEPTION);
            System.Assert.fail('Should have thrown exception');
        } catch (ValidationException ve) {
            System.Assert.areEqual('Some Error', ve.getMessage());
        }
        try {
            vr.isValid(Validation.ErrorMode.LWC_EXCEPTION);
            System.Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ahe) {
            System.Assert.areEqual('Some Error', ahe.getMessage());
        }
    }

    @isTest
    static void getMessages_SetModeExceptionHasErrors_ThrowsException() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        vr.addMessage('Some Error');

        // ASSERT
        // apex exception
        vr.setMode(Validation.ErrorMode.APEX_EXCEPTION);
        try {
            vr.getMessages();
            System.Assert.fail('Should have thrown ValidationException');
        } catch (ValidationException ve) {
            System.Assert.areEqual('Some Error', ve.getMessage());
        }

        // aura handled exception
        vr.setMode(Validation.ErrorMode.LWC_EXCEPTION);
        try {
            vr.getMessages();
            System.Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ahe) {
            System.Assert.areEqual('Some Error', ahe.getMessage());
        }
    }

    @isTest
    static void isValid_SetModeExceptionHasErrors_ThrowsException() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        vr.addMessage('Some Error');

        // ASSERT
        // apex exception
        vr.setMode(Validation.ErrorMode.APEX_EXCEPTION);
        try {
            vr.isValid();
            System.Assert.fail('Should have thrown ValidationException');
        } catch (ValidationException ve) {
            System.Assert.areEqual('Some Error', ve.getMessage());
        }

        // aura handled exception
        vr.setMode(Validation.ErrorMode.LWC_EXCEPTION);
        try {
            vr.isValid();
            System.Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ahe) {
            System.Assert.areEqual('Some Error', ahe.getMessage());
        }
    }

    @isTest
    static void getMessages_ExceptionModeHasNoErrors_ReturnsEmptyList() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        // ACT
        List<ValidationMessage> errsWithApexMode = vr.getMessages(Validation.ErrorMode.APEX_EXCEPTION);
        List<ValidationMessage> errsWithLwcMode = vr.getMessages(Validation.ErrorMode.LWC_EXCEPTION);
        // ASSERT
        System.Assert.areEqual(0, errsWithApexMode.size(), 'number of errors');
        System.Assert.areEqual(0, errsWithLwcMode.size(), 'number of errors');
    }

    @isTest
    static void isValid_ExceptionModeHasNoErrors_ReturnsTrue() {
        // ARRANGE
        ValidationResult vr = new ValidationResult();
        // ACT
        Boolean validWithApexMode = vr.isValid(Validation.ErrorMode.APEX_EXCEPTION);
        Boolean validWithLwcMode = vr.isValid(Validation.ErrorMode.LWC_EXCEPTION);
        // ASSERT
        System.Assert.isTrue(validWithApexMode, 'is valid in apex mode');
        System.Assert.isTrue(validWithLwcMode, 'is valid in lwc mode');
    }

    public class MockValidValidator implements Validator {
        public ValidationResult validate(SObject so) {
            ValidationResult vr = new ValidationResult();
            return vr;
        }

        public Set<String> getFields() {
            return new Set<String>();
        }
    }

    public class MockErrorValidator implements Validator {
        public ValidationResult validate(SObject so) {
            ValidationResult vr = new ValidationResult();
            vr.addMessage('This is an default error message on record level');
            vr.addMessage(new ValidationMessage('This is a special error message on field level', Schema.Account.BillingStreet));
            return vr;
        }

        public Set<String> getFields() {
            return new Set<String>{ 'Id', 'Name', 'BillingStreet' };
        }
    }
}
