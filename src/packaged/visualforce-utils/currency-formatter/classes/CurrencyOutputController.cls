public class CurrencyOutputController {
    public String currencyInputCode { get; set; }
    public Decimal numericInputValue { get; set; }

    public String getFormattedValue() {
        return CurrencyValue.format(this.currencyInputCode, this.numericInputValue);
    }
}
