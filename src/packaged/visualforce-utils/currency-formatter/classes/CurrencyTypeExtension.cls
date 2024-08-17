/**
 * Represents a currency like `USD` or `EUR` and provides various methods
 * to format decimals with that currency.
 *
 * @group Visualforce Utilities
 */
public class CurrencyTypeExtension {
    String isoCode;
    Currency__mdt config;
    CurrencyFormatLength formattingStyle;
    Formatter valueFormatter;

    /**
     * Do not construct directly. Use the factory method in `Currencies`.
     */
    public CurrencyTypeExtension(String isoCode, Currency__mdt cmd) {
        this.config = cmd;
        if (this.config == null) {
            throw new IllegalArgumentException(
                String.format(System.Label.Invalid_Currency_Iso_Code_Unknown_Custom_Metadata, new List<Object>{ isoCode })
            );
        }
        this.setFormattingStyle(CurrencyFormatLength.valueOf(this.config.FormatLength__c));
    }

    //                 PUBLIC

    /**
     * Formats the input with the default formatting style from config.
     *
     * @param value
     * @return  `String`
     */
    public String format(Decimal value) {
        return this.valueFormatter.format(value);
    }

    /**
     * Formats the input with a custom formatting style.
     *
     * @param value
     * @param formattingStyle
     * @return  `String`
     */
    public String format(Decimal value, CurrencyFormatLength formattingStyle) {
        Formatter f = this.makeFormatter(formattingStyle);
        return f.format(value);
    }

    /**
     * Returns the currency Iso Code.
     *
     * @return  `String`
     */
    public String getIsoCode() {
        return this.config.DeveloperName;
    }

    /**
     * Sets the formatting style for all future calls to `format`.
     *
     * @param formattingStyle
     * @return  `CurrencyTypeExtension`
     */
    public CurrencyTypeExtension setFormattingStyle(CurrencyFormatLength formattingStyle) {
        this.formattingStyle = formattingStyle;
        this.valueFormatter = this.makeFormatter(formattingStyle);
        return this;
    }

    public String getSymbol() {
        return this.config.Symbol__c;
    }

    public String getSymbolPosition() {
        return this.config.SymbolPosition__c;
    }

    public String getCodePosition() {
        return this.config.CodePosition__c;
    }

    public CurrencyFormatLength getFormattingStyle() {
        return this.formattingStyle;
    }

    //                  PRIVATE ZONE

    private Formatter makeFormatter(CurrencyFormatLength style) {
        Formatter f;
        switch on style {
            when SYMBOL {
                f = new ShortStyleFormatter();
            }
            when ISO_CODE {
                f = new IsoStyleFormatter();
            }
            when else {
                f = new ExplicitStyleFormatter();
            }
        }
        f.symbolBeforeNumber = this.config.SymbolPosition__c == 'BEFORE';
        f.codeBeforeNumber = this.config.CodePosition__c == 'BEFORE';
        f.isoCode = this.config.DeveloperName;
        f.symbol = this.config.Symbol__c;
        f.decimalSeparator = this.config.DecimalSeparator__c;
        f.thousandSeparator = this.config.ThousandsSeparator__c;
        f.scale = OrgCurrencyConfiguration.getDecimalPlaces(this.config.DeveloperName);
        return f;
    }

    private abstract class Formatter {
        public Boolean symbolBeforeNumber;
        public Boolean codeBeforeNumber;
        public String isoCode;
        public String symbol;
        public String decimalSeparator;
        public String thousandSeparator;
        public Integer scale;

        public abstract String format(Decimal value);

        private String formatNumber(Decimal value) {
            Decimal roundedValue = value.setScale(this.scale, System.RoundingMode.HALF_UP);
            if (this.scale > 0) {
                return String.format(
                    '{0}{1}{2}',
                    new List<Object>{
                        this.formatIntLiteral(roundedValue),
                        this.decimalSeparator,
                        this.formatPrecisionLiteral(roundedValue)
                    }
                );
            } else {
                return this.formatIntLiteral(roundedValue);
            }
        }

        private String formatPrecisionLiteral(Decimal value) {
            Integer precisionValue = Integer.valueOf((value.abs() - value.abs().intValue()) * Math.pow(10, this.scale));
            if (precisionValue.format().length() < this.scale) {
                return precisionValue.format().leftPad(this.scale, '0');
            } else {
                return precisionValue.format().left(this.scale);
            }
        }

        private String formatIntLiteral(Decimal value) {
            return value.abs().intValue().format().replaceAll('(\\.|,| |’)', this.thousandSeparator);
        }

        public String formatSign(Decimal value) {
            return value >= 0 ? '' : '-';
        }
    }

    private class ShortStyleFormatter extends Formatter {
        public override String format(Decimal value) {
            if (this.symbolBeforeNumber) {
                return String.format('{0}{1}{2}', new List<Object>{ this.formatSign(value), this.symbol, this.formatNumber(value) });
            } else {
                return String.format('{0}{1} {2}', new List<Object>{ this.formatSign(value), this.formatNumber(value), this.symbol });
            }
        }
    }

    private class IsoStyleFormatter extends Formatter {
        public override String format(Decimal value) {
            if (this.codeBeforeNumber) {
                return String.format('{0} {1}{2}', new List<Object>{ this.isoCode, this.formatSign(value), this.formatNumber(value) });
            } else {
                return String.format('{0}{1} {2}', new List<Object>{ this.formatSign(value), this.formatNumber(value), this.isoCode });
            }
        }
    }

    private class ExplicitStyleFormatter extends Formatter {
        public override String format(Decimal value) {
            String shortFormatted;
            if (this.symbolBeforeNumber) {
                shortFormatted = String.format(
                    '{0}{1}{2}',
                    new List<Object>{ this.formatSign(value), this.symbol, this.formatNumber(value) }
                );
            } else {
                shortFormatted = String.format(
                    '{0}{1} {2}',
                    new List<Object>{ this.formatSign(value), this.formatNumber(value), this.symbol }
                );
            }
            if (this.codeBeforeNumber) {
                return String.format('{0} {1}', new List<Object>{ this.isoCode, shortFormatted });
            } else {
                return String.format('{0} {1}', new List<Object>{ shortFormatted, this.isoCode });
            }
        }
    }
}
