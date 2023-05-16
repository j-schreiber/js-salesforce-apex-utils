public class DocumentLabels {
    private static Map<String, DocumentLabel> labels {
        get {
            if (labels == null) {
                labels = new Map<String, DocumentLabel>();
                for (DocumentLabel__c dl : [
                    SELECT Id, Name, Language__c, (SELECT Id, Language__c, Value__c FROM Translations__r)
                    FROM DocumentLabel__c
                ]) {
                    labels.put(dl.Name, new DocumentLabel(dl));
                }
            }
            return labels;
        }
        set;
    }

    public static String getTranslation(String masterLabel, String languageCode) {
        if (labels.containsKey(masterLabel)) {
            return labels.get(masterLabel).translate(languageCode);
        }
        return masterLabel;
    }
}
