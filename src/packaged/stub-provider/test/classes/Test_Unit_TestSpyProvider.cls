@isTest
public class Test_Unit_TestSpyProvider {
    @isTest
    static void getSpy_RegisteredSpyMethodName_ReturnMethodSpy() {
        // Arrange
        TestSpyProvider utilStub = new TestSpyProvider();
        utilStub.registerSpy('myMethod');

        // Act
        TestMethodSpy spy = utilStub.getSpy('myMethod');

        // Assert
        System.Assert.areEqual('myMethod', spy.MethodName, 'Method Name');
    }

    @isTest
    static void getSpy_UnregisteredSpyMethodName_SpyException() {
        // Arrange
        TestSpyProvider utilStub = new TestSpyProvider();

        // Act
        try {
            TestMethodSpy spy = utilStub.getSpy('myMethod');
            System.Assert.fail('Expected TestSpyException');
        } catch (Exception e) {
            System.Assert.isTrue(e.getMessage().contains('myMethod'), 'Exception message contains myMethod method name');
        }
    }

    @isTest
    static void handleMethodCall_SpyNotRegistrered_ThrowsException() {
        // Act
        TestSpyProvider stubProvider = new TestSpyProvider();
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);
        try {
            Integer i = spt.myIntegerTestMethod();
            System.Assert.fail('Expected TestSpyException');
        } catch (Exception e) {
            System.Assert.isTrue(e.getMessage().contains('myIntegerTestMethod'), 'Message contains not-stubbed method name');
        }
    }

    @isTest
    static void handleMethodCall_SpyRegistered_ReturnsStubValue() {
        // Act
        TestSpyProvider stubProvider = new TestSpyProvider();
        stubProvider.registerSpy('myIntegerTestMethod', 2);
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);
        Integer i = spt.myIntegerTestMethod();

        // Assert
        System.Assert.areEqual(2, i, 'Returned stubbed value');
    }

    @isTest
    static void handleMethodCall_StubException_StubbedExceptionIsThrown() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myIntegerTestMethod', null);
        spy.throwExceptionOnCall(new IllegalArgumentException('My stubbed exception'));
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);

        // Act
        try {
            Integer i = spt.myIntegerTestMethod();
            System.Assert.fail('Expected Exception');
        } catch (IllegalArgumentException e) {
            System.Assert.areEqual('My stubbed exception', e.getMessage(), 'getMessage');
        }
    }

    @isTest
    static void assertSpyWasCalled_HasBeenCalled_MethodPasses() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myIntegerTestMethod', 2);
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);

        // Act
        spt.myIntegerTestMethod();

        // Assert
        spy.hasBeenCalled();
    }

    @isTest
    static void assertSpyWasCalled_HasNotBeenCalled_ThrowsSpyException() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myIntegerTestMethod', 2);
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);

        // Assert
        try {
            spy.hasBeenCalled();
            System.Assert.fail('Expected TestSpyException');
        } catch (TestSpyException e) {
            String expectedError = String.format(
                System.Label.Expected_At_Least_One_Call_For_Method_Spy,
                new List<Object>{ 'myIntegerTestMethod' }
            );
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }

    @isTest
    static void assertSpyWasNotCalled_HasBeenCalled_ThrowsSpyException() {
        // Act
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myIntegerTestMethod', 2);
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);
        spt.myIntegerTestMethod();

        // Assert
        try {
            spy.hasNotBeenCalled();
            System.Assert.fail('Expected TestSpyException');
        } catch (TestSpyException e) {
            String expectedError = String.format(
                System.Label.Expected_No_Calls_For_Method_Spy,
                new List<Object>{ 'myIntegerTestMethod', 1 }
            );
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }

    @isTest
    static void assertSpyWasNotCalled_HasNotBeenCalled_MethodPasses() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myIntegerTestMethod', 2);
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);

        // Assert
        spy.hasNotBeenCalled();
    }

    @isTest
    static void assertSpyWasCalledSpecificNumber_ExpectedCallCounterMismatch_ThrowsSpyException() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myIntegerTestMethod', 2);
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);

        // Act
        spt.myIntegerTestMethod();
        spt.myIntegerTestMethod();

        // Assert
        try {
            spy.hasBeenCalledNumberOfTimes(3);
            System.Assert.fail('Expected TestSpyException');
        } catch (TestSpyException e) {
            String expectedError = String.format(
                System.Label.Expected_Specific_Number_Of_Calls_For_Method_Spy,
                new List<Object>{ 3, 'myIntegerTestMethod', 2 }
            );
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }

    @isTest
    static void assertSpyWasCalledSpecificNumber_ExpectedCallCounterMatch_MethodPass() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myIntegerTestMethod', 2);
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);

        // Act
        spt.myIntegerTestMethod();
        spt.myIntegerTestMethod();
        spt.myIntegerTestMethod();

        // Assert
        spy.hasBeenCalledNumberOfTimes(3);
    }

    @isTest
    static void assertSpyWasCalledWithOnLast_HasNotBeenCalledAtAll_ThrowsSpyException() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myStringTestMethod', 'Override');
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);

        // Assert
        try {
            spy.hasBeenCalledWithOnLast('Some input');
            System.Assert.fail('Expected TestSpyException');
        } catch (TestSpyException e) {
            String expectedError = String.format(
                System.Label.Expected_Specific_Number_Of_Calls_For_Method_Spy,
                new List<Object>{ 1, 'myStringTestMethod', 0 }
            );
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }

    @isTest
    static void assertSpyWasCalledWithOnLast_DifferentCallParameters_ThrowsSpyException() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myStringTestMethod', 'Override');
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);

        // Act
        spt.myStringTestMethod('Test input');

        // Assert
        try {
            spy.hasBeenCalledWithOnLast('Another input');
            System.Assert.fail('Expected TestSpyException');
        } catch (TestSpyException e) {
            List<String> expectedInput = new List<String>{ 'Another input' };
            List<String> actualInput = new List<String>{ 'Test input' };
            String expectedError = String.format(
                System.Label.Last_Call_Of_Spy_Method_Was_Not_With_Expected_Param_Values,
                new List<Object>{ 'myStringTestMethod', expectedInput, actualInput }
            );
            System.Assert.areEqual(expectedError, e.getMessage(), 'Exception error message');
        }
    }

    @isTest
    static void methodSpyHasBeenCalledWithOnLast_IdenticalCallParameters_MethodPasses() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myStringTestMethod', 'Override');
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);

        // Act
        spt.myStringTestMethod('Test input');

        // Assert
        spy.hasBeenCalledWithOnLast('Test input');
    }

    @isTest
    static void assertSpyHasBeenCalledWithOnNth_IdenticalSameCallParameter_MethodPasses() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myStringTestMethod', 'Override');
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);

        // Act
        spt.myStringTestMethod('First input');
        spt.myStringTestMethod('Second input');

        // Assert
        spy.hasBeenCalledWithOnNth(1, new List<Object>{ 'First input' });
        spy.hasBeenCalledWithOnNth(2, new List<Object>{ 'Second input' });
    }

    @isTest
    static void getCallParameters_TwoCallsWithParameters_ListWithParameters() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myStringTestMethod', 'Override');
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);
        spt.myStringTestMethod('First input');
        spt.myStringTestMethod('Second input');

        // Act
        List<Object> paramsOne = spy.getParametersFromNthCall(0);
        List<Object> paramsTwo = spy.getParametersFromNthCall(1);

        // Assert
        System.Assert.areEqual(new List<Object>{ 'First input' }, paramsOne, 'first call params');
        System.Assert.areEqual(new List<Object>{ 'Second input' }, paramsTwo, 'second call params');
    }

    @isTest
    static void getCallParameters_OnlyCalledOnce_ThrowsExceptionOnSecondGet() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myStringTestMethod', 'Override');
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);
        spt.myStringTestMethod('First input');

        // Assert
        List<Object> paramsOne = spy.getParametersFromNthCall(0);
        System.Assert.areEqual(new List<Object>{ 'First input' }, paramsOne, 'first call params');
        try {
            spy.getParametersFromNthCall(1);
            System.Assert.fail('Expected TestSpyException');
        } catch (TestSpyException e) {
            System.Assert.isTrue(e.getMessage().contains('myStringTestMethod'), 'message contains method name');
        }
    }

    @isTest
    static void getLastCallParameters_CallsWithDifferentParameters_ReturnsLastParameters() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myStringTestMethod', 'Override');
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);
        spt.myStringTestMethod('First input');
        spt.myStringTestMethod('Second input');
        spt.myStringTestMethod('Third input');

        // Assert
        List<Object> params = spy.getParametersFromLastCall();
        System.Assert.areEqual(new List<Object>{ 'Third input' }, params, 'last call params');
    }

    @isTest
    static void getLastCallParameters_MethodWasNotCalled_ThrowsException() {
        // Arrange
        TestSpyProvider stubProvider = new TestSpyProvider();
        TestMethodSpy spy = stubProvider.registerSpy('myStringTestMethod', 'Override');
        StubProviderTester spt = (StubProviderTester) Test.createStub(StubProviderTester.class, stubProvider);

        // Assert
        try {
            spy.getParametersFromLastCall();
            System.Assert.fail('Expected TestSpyException');
        } catch (TestSpyException e) {
            System.Assert.isTrue(e.getMessage().contains('myStringTestMethod'), 'message contains method name');
        }
    }
}
