@isTest
public class Test_Unit_TestSpyProvider {
    @isTest
    static void getSpy_RegisteredSpyMethodName_ReturnMethodSpy() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        utilStub.registerSpy('addChild');
        // ACT
        TestMethodSpy spy = utilStub.getSpy('addChild');
        // ASSERT
        System.Assert.areEqual('addChild', spy.MethodName, 'Method Name');
    }

    @isTest
    static void getSpy_UnregisteredSpyMethodName_SpyException() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        // ACT
        try {
            TestMethodSpy spy = utilStub.getSpy('addChild');
            System.Assert.fail('Expected TestSpyException');
        } catch (Exception e) {
            System.Assert.isTrue(e.getMessage().contains('addChild'), 'Exception message contains addChild method name');
        }
    }

    @isTest
    static void handleMethodCall_UnregisteredSpyMethodName_SpyException() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        // ACT
        try {
            ValidationResult vr = (ValidationResult) utilStub.handleMethodCall(
                null,
                'validate',
                ValidationResult.class,
                new List<Type>(),
                new List<String>(),
                new List<Object>()
            );
            System.Assert.fail('Expected TestSpyException');
        } catch (Exception e) {
            System.Assert.isTrue(e.getMessage().contains('validate'), 'Exception message contains validate method name');
        }
    }

    @isTest
    static void handleMethodCall_RegisteredSpyMethodName_StubbedReturnValue() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        utilStub.registerSpy('validate', new ValidationResult());
        // ACT
        ValidationResult vr = (ValidationResult) utilStub.handleMethodCall(
            null,
            'validate',
            ValidationResult.class,
            new List<Type>(),
            new List<String>(),
            new List<Object>()
        );
        // ASSERT
        System.Assert.isTrue(vr.isValid(), 'Returned stubbed validation result');
    }

    @isTest
    static void handleMethodCall_RegisteredExceptionSpy_StubbedExceptionIsThrown() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy validateSpy = utilStub.registerSpy('validate', new ValidationResult());
        validateSpy.throwExceptionOnCall(new IllegalArgumentException('My Stubbed Exception'));
        // ACT
        try {
            ValidationResult vr = (ValidationResult) utilStub.handleMethodCall(
                null,
                'validate',
                ValidationResult.class,
                new List<Type>(),
                new List<String>(),
                new List<Object>()
            );
            System.Assert.fail('Expected Exception');
        } catch (Exception e) {
            System.Assert.areEqual('My Stubbed Exception', e.getMessage(), 'getMessage');
        }
    }

    @isTest
    static void methodSpyHasBeenCalled_HasActuallyBeenCalled_MethodPasses() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy validateMethodSpy = utilStub.registerSpy('validate', new ValidationResult());
        ValidationResult vr = (ValidationResult) utilStub.handleMethodCall(
            null,
            'validate',
            ValidationResult.class,
            new List<Type>(),
            new List<String>(),
            new List<Object>()
        );
        // ASSERT
        validateMethodSpy.hasBeenCalled();
    }

    @isTest
    static void methodSpyHasBeenCalled_HasNotBeenCalled_SpyException() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy validateMethodSpy = utilStub.registerSpy('validate', new ValidationResult());
        // ASSERT
        try {
            validateMethodSpy.hasBeenCalled();
            System.Assert.fail('Expected TestSpyException');
        } catch (Exception e) {
            String expectedError = String.format(System.Label.Expected_At_Least_One_Call_For_Method_Spy, new List<Object>{ 'validate' });
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }

    @isTest
    static void methodSpyHasNotBeenCalled_HasActuallyBeenCalled_SpyException() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy validateMethodSpy = utilStub.registerSpy('validate', new ValidationResult());
        ValidationResult vr = (ValidationResult) utilStub.handleMethodCall(
            null,
            'validate',
            ValidationResult.class,
            new List<Type>(),
            new List<String>(),
            new List<Object>()
        );
        // ASSERT
        try {
            validateMethodSpy.hasNotBeenCalled();
            System.Assert.fail('Expected TestSpyException');
        } catch (Exception e) {
            String expectedError = String.format(System.Label.Expected_No_Calls_For_Method_Spy, new List<Object>{ 'validate', 1 });
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }

    @isTest
    static void methodSpyHasNotBeenCalled_HasNotBeenCalled_MethodPasses() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy validateMethodSpy = utilStub.registerSpy('validate', new ValidationResult());
        // ASSERT
        validateMethodSpy.hasNotBeenCalled();
    }

    @isTest
    static void methodSpyHasBeenCalledNumberOfTimes_ExpectedCallCounterMisMatch_SpyException() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy validateMethodSpy = utilStub.registerSpy('validate', new ValidationResult());
        utilStub.handleMethodCall(null, 'validate', ValidationResult.class, new List<Type>(), new List<String>(), new List<Object>());
        utilStub.handleMethodCall(null, 'validate', ValidationResult.class, new List<Type>(), new List<String>(), new List<Object>());
        // ASSERT
        try {
            validateMethodSpy.hasBeenCalledNumberOfTimes(3);
            System.Assert.fail('Expected TestSpyException');
        } catch (Exception e) {
            String expectedError = String.format(
                System.Label.Expected_Specific_Number_Of_Calls_For_Method_Spy,
                new List<Object>{ 3, 'validate', 2 }
            );
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }

    @isTest
    static void methodSpyHasBeenCalledNumberOfTimes_ExpectedCallCounterMatch_MethodPass() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy validateMethodSpy = utilStub.registerSpy('validate', new ValidationResult());
        utilStub.handleMethodCall(null, 'validate', ValidationResult.class, new List<Type>(), new List<String>(), new List<Object>());
        utilStub.handleMethodCall(null, 'validate', ValidationResult.class, new List<Type>(), new List<String>(), new List<Object>());
        // ASSERT
        validateMethodSpy.hasBeenCalledNumberOfTimes(2);
    }

    @isTest
    static void methodSpyHasBeenCalledWithOnLast_HasNotBeenCalledAtAll_SpyException() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy addChildMethodSpy = utilStub.registerSpy('addChild');
        // ASSERT
        try {
            addChildMethodSpy.hasBeenCalledWithOnLast(
                new List<Object>{ new Account(Name = 'Test Child Account'), Schema.Account.ParentId }
            );
            System.Assert.fail('Expected TestSpyException');
        } catch (Exception e) {
            String expectedError = String.format(
                System.Label.Expected_Specific_Number_Of_Calls_For_Method_Spy,
                new List<Object>{ 1, 'addChild', 0 }
            );
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }

    @isTest
    static void methodSpyHasBeenCalledWithOnLast_DifferentCallParameters_SpyException() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy addChildMethodSpy = utilStub.registerSpy('addChild');
        List<Object> actualParams = new List<Object>{ new Account(Name = 'Test Child Account'), Schema.Account.ParentId };
        List<Object> expectedParams = new List<Object>{ new Account(Name = 'Other Test Child Account'), Schema.Account.ParentId };
        utilStub.handleMethodCall(
            null,
            'addChild',
            ValidationResult.class,
            new List<Type>(),
            new List<String>{ 'child', 'relationshipField' },
            actualParams
        );
        // ASSERT
        try {
            addChildMethodSpy.hasBeenCalledWithOnLast(expectedParams);
            System.Assert.fail('Expected TestSpyException');
        } catch (Exception e) {
            String expectedError = String.format(
                System.Label.Last_Call_Of_Spy_Method_Was_Not_With_Expected_Param_Values,
                new List<Object>{ 'addChild', expectedParams, actualParams }
            );
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }

    @isTest
    static void methodSpyHasBeenCalledWithOnLast_IdenticalCallParameters_MethodPasses() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy addChildMethodSpy = utilStub.registerSpy('addChild');
        List<Object> actualParams = new List<Object>{ new Account(Name = 'Test Child Account'), Schema.Account.ParentId };
        utilStub.handleMethodCall(
            null,
            'addChild',
            ValidationResult.class,
            new List<Type>(),
            new List<String>{ 'child', 'relationshipField' },
            actualParams
        );
        // ASSERT
        addChildMethodSpy.hasBeenCalledWithOnLast(actualParams);
    }

    @isTest
    static void methodSpyHasBeenCalledWithOnNth_IdenticalSameCallParameter_MethodPasses() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy addChildMethodSpy = utilStub.registerSpy('addChild');
        List<Object> actualParamsOne = new List<Object>{ new Account(Name = 'Test Child Account #1'), Schema.Account.ParentId };
        List<Object> actualParamsTwo = new List<Object>{ new Account(Name = 'Test Child Account #2'), Schema.Account.ParentId };
        utilStub.handleMethodCall(
            null,
            'addChild',
            ValidationResult.class,
            new List<Type>(),
            new List<String>{ 'child', 'relationshipField' },
            actualParamsOne
        );
        utilStub.handleMethodCall(
            null,
            'addChild',
            ValidationResult.class,
            new List<Type>(),
            new List<String>{ 'child', 'relationshipField' },
            actualParamsTwo
        );
        // ASSERT
        addChildMethodSpy.hasBeenCalledWithOnNth(1, actualParamsOne);
        addChildMethodSpy.hasBeenCalledWithOnNth(2, actualParamsTwo);
    }

    @isTest
    static void methodSpyGetFromNthCallParameters_TwoCallsWithParameters_ListWithParameters() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy methodSpy = utilStub.registerSpy('concatStrings');
        List<Object> actualParamsOne = new List<Object>{ 'Call 1, Param 1', 'Call 1, Param 2' };
        List<Object> actualParamsTwo = new List<Object>{ 'Call 2, Param 1', 'Call 2, Param 2' };
        utilStub.handleMethodCall(
            null,
            'concatStrings',
            ValidationResult.class,
            new List<Type>(),
            new List<String>{ 'string1', 'string2' },
            actualParamsOne
        );
        utilStub.handleMethodCall(
            null,
            'concatStrings',
            ValidationResult.class,
            new List<Type>(),
            new List<String>{ 'string1', 'string2' },
            actualParamsTwo
        );

        // ACT
        List<Object> paramsOne = methodSpy.getFromNthCallParameters(0);
        List<Object> paramsTwo = methodSpy.getFromNthCallParameters(1);

        // ASSERT
        System.Assert.isTrue(actualParamsOne.equals(paramsOne), 'params one: ' + paramsOne);
        System.Assert.isTrue(actualParamsTwo.equals(paramsTwo), 'params two: ' + paramsTwo);
    }

    @isTest
    static void methodSpyGetFromNthCallParameters_OneCallWithParameters_ExceptionGettingParamsForCallTwo() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy methodSpy = utilStub.registerSpy('concatStrings');
        List<Object> actualParamsOne = new List<Object>{ 'Call 1, Param 1', 'Call 1, Param 2' };
        utilStub.handleMethodCall(
            null,
            'concatStrings',
            ValidationResult.class,
            new List<Type>(),
            new List<String>{ 'string1', 'string2' },
            actualParamsOne
        );

        // ACT
        try {
            methodSpy.getFromNthCallParameters(1);
            System.Assert.fail('Expected TestSpyException');
        } catch (Exception e) {
            String expectedError = String.format(
                System.Label.Expected_Specific_Number_Of_Calls_For_Method_Spy,
                new List<Object>{ 2, 'concatStrings', 1 }
            );
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }

    @isTest
    static void methodSpyGetFromLastCallParameters_TwoCallsWithParameters_ListWithLastParameters() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy methodSpy = utilStub.registerSpy('concatStrings');
        List<Object> actualParamsOne = new List<Object>{ 'Call 1, Param 1', 'Call 1, Param 2' };
        List<Object> actualParamsTwo = new List<Object>{ 'Call 2, Param 1', 'Call 2, Param 2' };
        utilStub.handleMethodCall(
            null,
            'concatStrings',
            ValidationResult.class,
            new List<Type>(),
            new List<String>{ 'string1', 'string2' },
            actualParamsOne
        );
        utilStub.handleMethodCall(
            null,
            'concatStrings',
            ValidationResult.class,
            new List<Type>(),
            new List<String>{ 'string1', 'string2' },
            actualParamsTwo
        );

        // ACT
        List<Object> lastParams = methodSpy.getFromLastCallParameters();

        // ASSERT
        System.Assert.isTrue(actualParamsTwo.equals(lastParams), 'last params: ' + lastParams);
    }

    @isTest
    static void methodSpyGetFromLastCallParameters_NoCall_Exception() {
        // ARRANGE
        TestSpyProvider utilStub = new TestSpyProvider();
        TestMethodSpy methodSpy = utilStub.registerSpy('concatStrings');

        // ACT
        try {
            methodSpy.getFromLastCallParameters();
            System.Assert.fail('Expected TestSpyException');
        } catch (Exception e) {
            String expectedError = String.format(
                System.Label.Expected_At_Least_One_Call_For_Method_Spy,
                new List<Object>{ 'concatStrings' }
            );
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }
}
