/**
 * Extends the standard `System.Schema` and constructs `ExtendedDescribeSObjectResults`.
 *
 * @group SObject Utilities
 * @see ExtendedDescribeSObjectResult
 */
public class ExtendedSchema {
    static Map<String, ExtendedDescribeSObjectResult> describeResults = new Map<String, ExtendedDescribeSObjectResult>();

    public static ExtendedDescribeSObjectResult describeSObject(String sobjectName) {
        String key = sobjectName.toLowerCase();
        if (!describeResults.containsKey(key)) {
            describeResults.put(key, new ExtendedDescribeSObjectResult(sobjectName));
        }
        return describeResults.get(key);
    }

    public static Map<String, ExtendedDescribeSObjectResult> describeSObjects(Set<String> sobjectNames) {
        List<String> undescribedSobjects = new List<String>();
        for (String sobjectName : sobjectNames) {
            if (!describeResults.containsKey(sobjectName.toLowerCase())) {
                undescribedSobjects.add(sobjectName);
            }
        }
        if (!undescribedSobjects.isEmpty()) {
            List<Schema.DescribeSObjectResult> results = Schema.describeSObjects(undescribedSobjects);
            for (Integer i = 0; i < undescribedSobjects.size() - 1; i++) {
                describeResults.put(undescribedSobjects[i].toLowerCase(), new ExtendedDescribeSObjectResult(results[i]));
            }
        }
        Map<String, ExtendedDescribeSObjectResult> resultMap = new Map<String, ExtendedDescribeSObjectResult>();
        for (String sobjectName : sobjectNames) {
            resultMap.put(sobjectName, describeResults.get(sobjectName.toLowerCase()));
        }
        return resultMap;
    }

    public static ExtendedDescribeSObjectResult describeSObject(Schema.SObjectType sObjectType) {
        String key = String.valueOf(sObjectType).toLowerCase();
        if (!describeResults.containsKey(key)) {
            describeResults.put(key, new ExtendedDescribeSObjectResult(sObjectType));
        }
        return describeResults.get(key);
    }

    public static ExtendedDescribeSObjectResult describeSObject(Schema.DescribeSObjectResult describeResult) {
        String key = String.valueOf(describeResult.getSobjectType()).toLowerCase();
        if (!describeResults.containsKey(key)) {
            describeResults.put(key, new ExtendedDescribeSObjectResult(describeResult));
        }
        return describeResults.get(key);
    }
}
