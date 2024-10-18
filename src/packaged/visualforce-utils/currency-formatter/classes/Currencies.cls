/**
 * Provides static methods to quickly format decimal values as currencies (in String format)
 * and initialise the Currency Type Extension utility class for more customizability.
 *
 * @group Visualforce Utilities
 * @see CurrencyTypeExtension
 */
public class Currencies {
    public static Map<String, CurrencyTypeExtension> currencyTypeExtensions = new Map<String, CurrencyTypeExtension>();
    private static Map<String, Currency__mdt> mockCurrencyConfigs = new Map<String, Currency__mdt>();

    /**
     * Factory method to construct a currency extension. Use this if you want to customize
     * the formatting and override the default settings for the currency.
     *
     * @param isoCode
     * @return  `CurrencyTypeExtension`
     */
    public static CurrencyTypeExtension get(String isoCode) {
        if (!currencyTypeExtensions.containsKey(isoCode)) {
            currencyTypeExtensions.put(isoCode, new CurrencyTypeExtension(isoCode, getCurrencyConfiguration(isoCode)));
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

    //                  PRIVATE ZONE

    private static Currency__mdt getCurrencyConfiguration(String isoCode) {
        if (mockCurrencyConfigs.containsKey(isoCode)) {
            return mockCurrencyConfigs.get(isoCode);
        }
        return Currency__mdt.getInstance(isoCode);
    }

    @testVisible
    private static void setMockCurrencyConfiguration(Currency__mdt mockConfig) {
        mockCurrencyConfigs.put(mockConfig.DeveloperName, mockConfig);
    }
}
