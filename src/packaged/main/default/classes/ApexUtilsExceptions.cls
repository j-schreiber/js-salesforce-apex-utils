public class ApexUtilsExceptions {
    public static IllegalArgumentException makeNewInputCannotBeNull(String inputName) {
        return new IllegalArgumentException(String.format(System.Label.Input_Parameter_Cannot_Be_Null, new List<Object>{ inputName }));
    }
}
