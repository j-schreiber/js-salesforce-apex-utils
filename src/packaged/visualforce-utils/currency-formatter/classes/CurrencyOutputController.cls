public class CurrencyOutputController {
    public String currencyInputCode { get; set; }
    public Decimal numericInputValue { get; set; }
    public String styleOverride { get; set; }

    public String getFormattedValue() {
        if (this.styleOverride == null) {
            return Currencies.format(this.currencyInputCode, this.numericInputValue);
        } else {
            return Currencies.format(this.currencyInputCode, this.numericInputValue, this.getFormatStyle());
        }
    }

    private CurrencyFormatLength getFormatStyle() {
        return CurrencyFormatLength.valueOf(this.styleOverride);
    }
}
