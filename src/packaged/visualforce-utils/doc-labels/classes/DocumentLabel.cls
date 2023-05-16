public class DocumentLabel {
    private DocumentLabel__c record;
    Map<String, DocumentLabelTranslation__c> translations;

    public DocumentLabel(DocumentLabel__c record) {
        this.record = record;
        this.translations = new Map<String, DocumentLabelTranslation__c>();
        for (DocumentLabelTranslation__c dlt : record.Translations__r) {
            this.translations.put(dlt.Language__c, dlt);
        }
    }

    public String translate(String language) {
        if (this.translations.containsKey(language)) {
            return this.translations.get(language).Value__c;
        }
        return this.record.Name;
    }
}
