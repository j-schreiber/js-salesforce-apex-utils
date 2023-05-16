public class DocumentLabelController {
    public String inputLanguage { get; set; }
    public String inputValue { get; set; }

    public String getLocalizedValue() {
        return DocumentLabels.getTranslation(inputValue, inputLanguage);
    }
}
