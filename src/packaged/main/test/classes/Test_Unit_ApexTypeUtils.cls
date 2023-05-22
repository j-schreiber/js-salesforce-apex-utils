@isTest
public class Test_Unit_ApexTypeUtils {
    @isTest
    static void getClassName_NamespacedClassName_ReturnsRawClassName() {
        // Act
        String className = ApexTypeUtils.getClassName(Test_Unit_ApexTypeUtils.class);

        // Assert
        System.Assert.areEqual('Test_Unit_ApexTypeUtils', className, 'class name');
    }

    @isTest
    static void getClassNamespacePrefix_NamespacedClassName_ReturnsNamespacePrefix() {
        // Act
        String prefix = ApexTypeUtils.getClassNamespacePrefix(Test_Unit_ApexTypeUtils.class);

        // Assert
        System.Assert.areEqual('powersuite', prefix, 'namespace prefix');
    }

    @isTest
    static void getOrgNamespacePrefix_OrgMayHaveNamespace_ReturnsOrgNamespacePrefix() {
        // Act
        Test.startTest();
        String prefix = ApexTypeUtils.getOrgNamespacePrefix();
        String prefixCall2 = ApexTypeUtils.getOrgNamespacePrefix();
        String prefixCall3 = ApexTypeUtils.getOrgNamespacePrefix();

        // Assert
        System.Assert.areEqual(1, Limits.getQueries(), 'total queries executed');
        Organization org = [SELECT NamespacePrefix FROM Organization];
        // org without namespace is null, but utils return empty string
        if (String.isBlank(org.NamespacePrefix)) {
            System.Assert.areEqual('', prefix, 'namespace prefix');
            System.Assert.areEqual('', prefixCall2, 'namespace prefixCall2');
        } else {
            System.Assert.areEqual(org.NamespacePrefix, prefix, 'namespace prefix');
            System.Assert.areEqual(org.NamespacePrefix, prefixCall2, 'namespace prefixCall2');
        }
        Test.stopTest();
    }
}
