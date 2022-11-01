/**
 * The SpyProvider implements universal methods for objects that implement the `System.StubProvider` interface to spy and
 * assert on stubbed method calls. You can dynamically register a stubbed method implementation on the spy provider and later
 * assert on calls to this method.
 *
 * @author Jannis Schreiber
 * @group Stub Framework
 */
public virtual class TestSpyProvider implements System.StubProvider {
    public Map<String, TestMethodSpy> Spies = new Map<String, TestMethodSpy>();

    /**
     * This is the implementation of the `System.StubProvider`. Do not use this method directly, it is called by the stubbing API.
     * If the called method on the mock is not registed, an exception is thrown during run-time.
     *
     * @param stubbedObject
     * @param stubbedMethodName
     * @param returnType
     * @param listOfParamTypes
     * @param listOfParamNames
     * @param listOfArgs
     * @return  `Object`
     */
    public Object handleMethodCall(
        Object stubbedObject,
        String stubbedMethodName,
        Type returnType,
        List<Type> listOfParamTypes,
        List<String> listOfParamNames,
        List<Object> listOfArgs
    ) {
        return this.getSpy(stubbedMethodName).handleCall(returnType, listOfParamTypes, listOfParamNames, listOfArgs);
    }

    /**
     * Registers a new stub implementation of a method that also acts as a spy. Overrides existing
     * spies for the same method name and returns the spy. Use this method to register your own spy implementations.
     *
     * @param spy Pre-initialized method spy
     * @return  `TestMethodSpy`
     */
    public TestMethodSpy registerSpy(TestMethodSpy spy) {
        this.Spies.put(spy.MethodName, spy);
        return spy;
    }

    /**
     * Registers a new stub implementation of a void method that also acts as a spy. Overrides existing
     * spies for the same method name and returns the newly created spy.
     *
     * @param methodName The stubbed method name to create a spy
     * @return  `TestMethodSpy`
     */
    public TestMethodSpy registerSpy(String methodName) {
        TestMethodSpy spy = new TestMethodSpy(methodName);
        return registerSpy(spy);
    }

    /**
     * Registers a new stub implementation of a non-void method that also acts as a spy and sets the return value for the spy
     * Overrides existing spies for the same method name and returns the newly created spy.
     *
     * @param methodName The stubbed method name to create a spy
     * @param returnValue The value, that the stub/spy will return when its called
     * @return  `TestMethodSpy`
     */
    public TestMethodSpy registerSpy(String methodName, Object returnValue) {
        TestMethodSpy spy = new TestMethodSpy(methodName);
        spy.setReturnValue(returnValue);
        return registerSpy(spy);
    }

    /**
     * Returns a registered spy by its name. If the spy is not registered, this method throws a custom exception.
     * Always use this method when accessing spies.
     *
     * @param methodName
     * @return  `TestMethodSpy`
     */
    public TestMethodSpy getSpy(String methodName) {
        if (!this.Spies.containsKey(methodName)) {
            throw new TestSpyException(
                String.format(System.Label.Called_A_Method_On_Stub_That_Has_Not_Been_Stubbed, new List<Object>{ methodName })
            );
        }
        return this.Spies.get(methodName);
    }
}
