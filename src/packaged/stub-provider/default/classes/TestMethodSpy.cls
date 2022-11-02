/**
 * The SpyMethod provides generic functionality to dynamically stub a method of any apex class.
 *
 * @author Jannis Schreiber
 * @group Stub Framework
 */
public virtual class TestMethodSpy {
    private Integer CallCounter;
    private Object ReturnValue;
    private Exception ExceptionToThrow;
    public String MethodName { get; private set; }
    private List<List<Object>> CallParameters;

    public TestMethodSpy(String methodName) {
        this.CallCounter = 0;
        this.CallParameters = new List<List<Object>>();
        this.MethodName = methodName;
    }

    /**
     * This is the implementation of the `System.StubProvider`. Do not use this method directly, it is called by the stubbing API.
     *
     * @param returnType
     * @param listOfParamTypes
     * @param listOfParamNames
     * @param listOfArgs
     * @return  `Object`
     */
    public virtual Object handleCall(Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
        this.CallCounter++;
        this.CallParameters.add(listOfArgs);
        if (ExceptionToThrow != null) {
            throw ExceptionToThrow;
        }
        return this.ReturnValue;
    }

    /**
     * Manually set the return value. Override this method when implementing your own spy.
     *
     * @param returnValue
     */
    public virtual void setReturnValue(Object returnValue) {
        this.ReturnValue = returnValue;
    }

    /**
     * Manually let the method throw an exception, if it is executed. The exception is thrown for every call
     * to the method.
     *
     * @param exceptionToThrow Any exception, that should be thrown when method is executed
     */
    public virtual void throwExceptionOnCall(Exception exceptionToThrow) {
        this.ExceptionToThrow = exceptionToThrow;
    }

    /**
     * Assert that the method was called with a single argument.
     *
     * @param expectedCallArg
     * @see TestMethodSpy.hasBeenCalledWithOnNth
     * @exception `TestSpyException` Details about the failed assert.
     */
    public void hasBeenCalledWithOnLast(Object expectedCallArg) {
        this.hasBeenCalledWithOnLast(new List<Object>{ expectedCallArg });
    }

    /**
     * Assert on the used parameter values of the last method call. Use this method if you want to verify that
     * the method was called with a specific set of parameter values. The method also checks that at least one call
     * was made.
     *
     * @param expectedCallArgs
     * @see TestMethodSpy.hasBeenCalledWithOnNth
     * @exception `TestSpyException` Details about the failed assert.
     */
    public void hasBeenCalledWithOnLast(List<Object> expectedCallArgs) {
        this.hasBeenCalledWithOnNth(this.CallParameters.size(), expectedCallArgs);
    }

    /**
     * Assert on the used parameter values of the n-th method call (1-based). Use this method if you want to verify that
     * the method was called with a specific set of parameter values.
     *
     * @param nthCall The n-th call you want to check. Starts at 1.
     * @param expectedCallArgs
     * @exception `TestSpyException` Details about the failed assert.
     */
    public void hasBeenCalledWithOnNth(Integer nthCall, List<Object> expectedCallArgs) {
        if (this.CallParameters.isEmpty() || this.CallParameters.size() < nthCall) {
            throw new TestSpyException(
                String.format(
                    System.Label.Expected_Specific_Number_Of_Calls_For_Method_Spy,
                    new List<Object>{ Math.Max(nthCall, 1), this.MethodName, this.CallParameters.size() }
                )
            );
        }
        if (!expectedCallArgs.equals(this.CallParameters.get(nthCall - 1))) {
            throw new TestSpyException(
                String.format(
                    System.Label.Last_Call_Of_Spy_Method_Was_Not_With_Expected_Param_Values,
                    new List<Object>{ this.MethodName, expectedCallArgs, this.CallParameters.get(nthCall - 1) }
                )
            );
        }
    }

    /**
     * Assert that the method was called at least once. The verification only fails if the method was never called
     * and always succeeds, no matter how many calls were made.
     *
     * @exception `TestSpyException` Details about the failed assert.
     */
    public void hasBeenCalled() {
        if (this.CallCounter == 0) {
            throw new TestSpyException(
                String.format(System.Label.Expected_At_Least_One_Call_For_Method_Spy, new List<Object>{ this.MethodName })
            );
        }
    }

    /**
     * Assert that the method was never called. The verification fails if the method was called at least once, no matter how often.
     *
     * @exception `TestSpyException` Details about the failed assert.
     */
    public void hasNotBeenCalled() {
        if (this.CallCounter > 0) {
            throw new TestSpyException(
                String.format(System.Label.Expected_No_Calls_For_Method_Spy, new List<Object>{ this.MethodName, this.CallCounter })
            );
        }
    }

    /**
     * Assert that the method was called a specific number of times. Use this method if you require specific verification
     * about the number of calls.
     *
     * @exception `TestSpyException` Details about the failed assert.
     */
    public void hasBeenCalledNumberOfTimes(Integer expectedCallCounter) {
        if (this.CallCounter != expectedCallCounter) {
            throw new TestSpyException(
                String.format(
                    System.Label.Expected_Specific_Number_Of_Calls_For_Method_Spy,
                    new List<Object>{ expectedCallCounter, this.MethodName, this.CallCounter }
                )
            );
        }
    }

    /**
     * Get the call parameters list from the last call.
     *
     * @return  `List<Object>`
     */
    public virtual List<Object> getParametersFromLastCall() {
        hasBeenCalled();
        return getParametersFromNthCall(this.CallParameters.size() - 1);
    }

    /**
     * Get the call parameters list from the nth call.
     *
     * @param callIndex
     * @return  `List<Object>`
     */
    public virtual List<Object> getParametersFromNthCall(Integer callIndex) {
        if (this.CallCounter < (callIndex + 1)) {
            throw new TestSpyException(
                String.format(
                    System.Label.Expected_Specific_Number_Of_Calls_For_Method_Spy,
                    new List<Object>{ (callIndex + 1), this.MethodName, this.CallCounter }
                )
            );
        }
        return this.CallParameters?.get(callIndex);
    }
}
