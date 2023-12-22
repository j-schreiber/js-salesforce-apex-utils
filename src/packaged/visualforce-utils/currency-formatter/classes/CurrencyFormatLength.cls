/**
 * Offers options, how a currency is displayed. All options respect
 * the currency specific configuration.
 *
 * `SYMBOL` prints the ISO symbol, e.g. "123 €" or "$123"
 * `ISO_CODE` prints the formal three-letter ISO code, e.g. "EUR 123"
 * `EXPLICIT` prints the ISO code and the symbol, e.g. "$123 CAD"
 *
 * @group Visualforce Utilities
 * @see Currencies
 */
public enum CurrencyFormatLength {
    SYMBOL,
    ISO_CODE,
    EXPLICIT
}
