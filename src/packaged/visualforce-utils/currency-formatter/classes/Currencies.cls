public class Currencies {
    public static Map<String, CurrencyType> currencyTypes {
        get {
            if (currencyTypes == null) {
                currencyTypes = new Map<String, CurrencyType>();
                for (CurrencyType ct : [SELECT Id, IsoCode, DecimalPlaces FROM CurrencyType]) {
                    currencyTypes.put(ct.IsoCode, ct);
                }
            }
            return currencyTypes;
        }
        set;
    }

    public static Map<String, CurrencyTypeExtension> currencyTypeExtensions = new Map<String, CurrencyTypeExtension>();

    public static CurrencyTypeExtension get(String isoCode) {
        if (!currencyTypeExtensions.containsKey(isoCode)) {
            currencyTypeExtensions.put(
                isoCode,
                new CurrencyTypeExtension(isoCode, Currency__mdt.getInstance(isoCode), currencyTypes.get(isoCode))
            );
        }
        return currencyTypeExtensions.get(isoCode);
    }

    public static String format(String isoCode, Decimal value) {
        return get(isoCode).format(value);
    }

    public static String format(String isoCode, Decimal value, CurrencyFormatLength formattingStyle) {
        return get(isoCode).format(value, formattingStyle);
    }
}
