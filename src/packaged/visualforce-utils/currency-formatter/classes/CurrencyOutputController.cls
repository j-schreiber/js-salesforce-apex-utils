public class CurrencyOutputController {
    public String currencyInputCode { get; set; }
    public Decimal numericInputValue { get; set; }
    public String styleOverride { get; set; }

    public String getFormattedValue() {
        if (this.styleOverride == null) {
            return CurrencyValue.format(this.currencyInputCode, this.numericInputValue);
        } else {
            return CurrencyValue.format(this.currencyInputCode, this.numericInputValue, this.getFormatStyle());
        }
    }

    private CurrencyValue.FormatLength getFormatStyle() {
        return CurrencyValue.FormatLength.valueOf(this.styleOverride);
    }
}
