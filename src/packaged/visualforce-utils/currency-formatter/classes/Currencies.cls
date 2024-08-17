/**
 * Provides static methods to quickly format decimal values as currencies (in String format)
 * and initialise the Currency Type Extension utility class for more customizability.
 *
 * @group Visualforce Utilities
 * @see CurrencyTypeExtension
 */
public class Currencies {
    // public static Map<String, CurrencyType> currencyTypes {
    //     get {
    //         if (currencyTypes == null) {
    //             currencyTypes = new Map<String, CurrencyType>();
    //             for (CurrencyType ct : [SELECT Id, IsoCode, DecimalPlaces FROM CurrencyType]) {
    //                 currencyTypes.put(ct.IsoCode, ct);
    //             }
    //         }
    //         return currencyTypes;
    //     }
    //     set;
    // }

    public static Map<String, CurrencyTypeExtension> currencyTypeExtensions = new Map<String, CurrencyTypeExtension>();

    /**
     * Factory method to construct a currency extension. Use this if you want to customize
     * the formatting and override the default settings for the currency.
     *
     * @param isoCode
     * @return  `CurrencyTypeExtension`
     */
    public static CurrencyTypeExtension get(String isoCode) {
        if (!currencyTypeExtensions.containsKey(isoCode)) {
            currencyTypeExtensions.put(isoCode, new CurrencyTypeExtension(isoCode, Currency__mdt.getInstance(isoCode)));
        }
        return currencyTypeExtensions.get(isoCode);
    }

    /**
     * Quickly formats a decimal value as a currency using the default configuration.
     *
     * @param isoCode The code for the currency
     * @param value
     * @return  `String`
     */
    public static String format(String isoCode, Decimal value) {
        return get(isoCode).format(value);
    }

    /**
     * Format a currency using the default configuration, but allows to explicitly set
     * the format length. See `CurrencyFormatLength` for explanation of available
     * formatting styles.
     *
     * @param isoCode
     * @param value
     * @param formattingStyle Set the style how to format the currency
     * @return  `String`
     */
    public static String format(String isoCode, Decimal value, CurrencyFormatLength formattingStyle) {
        return get(isoCode).format(value, formattingStyle);
    }
}
