public class ApexTypeUtils {
    public static Object initializeInstanceFromName(String apexClassName, System.Type targetType) {
        if (String.isNotBlank(apexClassName)) {
            System.Type classType = Type.forName(apexClassName);
            if (classType == null) {
                throw new IllegalArgumentException(
                    String.format(System.Label.Invalid_Name_Apex_Class_Not_Found, new List<Object>{ apexClassName })
                );
            }
            if (!targetType.isAssignableFrom(classType)) {
                throw new IllegalArgumentException(
                    String.format(
                        System.Label.Apex_Class_Does_Not_Implement_Interface,
                        new List<Object>{ apexClassName, String.valueOf(targetType) }
                    )
                );
            }
            return classType.newInstance();
        }
        return null;
    }
}
