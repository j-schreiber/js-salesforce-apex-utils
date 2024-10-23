public class ApexTypeUtils {
    private static String orgNamespacePrefix;

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

    public static String getClassName(System.Type classType) {
        if (getClassNamespacePrefix(classType) == '') {
            return String.valueOf(classType);
        } else {
            List<String> classNameParts = String.valueOf(classType).split('\\.', 2);
            Type namespacedType = Type.forName(classNameParts[0], classNameParts[1]);
            return classNameParts[1];
        }
    }

    public static String getTypeNameFromInstance(Object anyInputObject) {
        return String.valueOf(anyInputObject).split(':')[0];
    }

    public static String getClassNamespacePrefix(System.Type classType) {
        List<String> classNameParts = String.valueOf(classType).split('\\.', 2);
        if (classNameParts.size() > 1) {
            Type namespacedType = Type.forName(classNameParts[0], classNameParts[1]);
            if (namespacedType == classType) {
                return classNameParts[0];
            }
        }
        return '';
    }

    public static String getOrgNamespacePrefix() {
        if (orgNamespacePrefix == null) {
            Organization org = [SELECT NamespacePrefix FROM Organization];
            orgNamespacePrefix = org.NamespacePrefix == null ? '' : org.NamespacePrefix;
        }
        return orgNamespacePrefix;
    }
}
