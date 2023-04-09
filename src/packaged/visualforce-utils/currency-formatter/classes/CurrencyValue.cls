public class CurrencyValue {
    String isoCode;
    Currency__mdt config;
    CurrencyType currType;
    Decimal value;
    FormatLength formattingStyle;
    Formatter valueFormatter;

    public enum FormatLength {
        SHORT_FORMAT,
        ISO_FORMAT,
        EXPLICIT_FORMAT
    }

    public CurrencyValue(String isoCode, Decimal value) {
        this.isoCode = isoCode;
        this.currType = CurrencyTypeRepository.Values.get(isoCode);
        if (this.currType == null) {
            throw new IllegalArgumentException(
                String.format(System.Label.Invalid_Currency_Iso_Code_Unknown_Currency_Type, new List<Object>{ isoCode })
            );
        }
        this.config = Currency__mdt.getInstance(this.isoCode);
        if (this.config == null) {
            throw new IllegalArgumentException(
                String.format(System.Label.Invalid_Currency_Iso_Code_Unknown_Custom_Metadata, new List<Object>{ isoCode })
            );
        }
        this.value = value.setScale(this.currType.DecimalPlaces, RoundingMode.HALF_UP);
        this.setFormattingStyle(CurrencyValue.FormatLength.valueOf(this.config.FormatLength__c));
    }

    //                 PUBLIC STATIC

    public static String format(String isoCode, Decimal value) {
        return new CurrencyValue(isoCode, value).format();
    }

    public static String format(String isoCode, Decimal value, FormatLength formattingStyle) {
        return new CurrencyValue(isoCode, value).setFormattingStyle(formattingStyle).format();
    }

    //                    PUBLIC

    public CurrencyValue setFormattingStyle(CurrencyValue.FormatLength formattingStyle) {
        this.formattingStyle = formattingStyle;
        switch on this.formattingStyle {
            when SHORT_FORMAT {
                this.valueFormatter = new ShortStyleFormatter();
            }
            when ISO_FORMAT {
                this.valueFormatter = new IsoStyleFormatter();
            }
            when else {
                this.valueFormatter = new ExplicitStyleFormatter();
            }
        }
        this.valueFormatter.symbolBeforeNumber = this.config.CurrencySymbolPosition__c == 'BEFORE';
        this.valueFormatter.codeBeforeNumber = this.config.CurrencyCodePosition__c == 'BEFORE';
        this.valueFormatter.isoCode = this.isoCode;
        this.valueFormatter.symbol = this.config.CurrencySymbol__c;
        this.valueFormatter.decimalSeparator = this.config.DecimalSeparator__c;
        this.valueFormatter.thousandSeparator = this.config.ThousandsSeparator__c;
        this.valueFormatter.scale = this.currType.DecimalPlaces;
        return this;
    }

    public String format() {
        return this.valueFormatter.format(this.value);
    }

    public Decimal getAbsoluteValue() {
        return this.value.abs();
    }

    public String getSign() {
        return this.value >= 0 ? '' : '-';
    }

    public String getDefaultLocale() {
        return this.config.NativeLocale__c;
    }

    public String getSymbol() {
        return this.config.CurrencySymbol__c;
    }

    public String getSymbolPosition() {
        return this.config.CurrencySymbolPosition__c;
    }

    public String getCodePosition() {
        return this.config.CurrencyCodePosition__c;
    }

    public FormatLength getFormattingStyle() {
        return this.formattingStyle;
    }

    //                  PRIVATE ZONE

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
            if (this.scale > 0) {
                return String.format(
                    '{0}{1}{2}',
                    new List<Object>{ this.formatIntLiteral(value), this.decimalSeparator, this.formatPrecisionLiteral(value) }
                );
            } else {
                return this.formatIntLiteral(value);
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
