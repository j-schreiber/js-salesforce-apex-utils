Visualforce components to improve PDF generation

## Configuration

The module dynamically checks if multi-currency is enabled. If it is, it uses the native currency configuration to evaluate decimal places. If multi-currency is disabled, all currencies are displayed with 2 decimal places (consistent with Salesforce standard).

To work correctly, you need to set up a currency in the `CurrencyType` and the custom metadata extension `Currency__mdt`.

### Configure the native currency

Navigate to Setup > Manage Currencies.

### Configure the custom metadata

Navigate to Setup > Custom Metadata Types > Currency\_\_mdt > Manage Records

Use the 3-letter ISO CODE to set up new currencies. The developer name must be a valid native currency code (e.g. EUR, USD, CAD, etc).
Additional configured extension records do not matter. They are ignored, if a corresponding `CurrencyType` is missing.

## Currency Formatter

Renders currency values independent of the user's locale. It allows to configure the locale for a currency in custom metadata and applies the locale to render it.

The standard configuration implements the guidelines in the [Unicode CLDR](https://cldr.unicode.org/) and the specifications in [ISO 4217](https://www.iso.org/iso-4217-currency-codes.html).

### Visualforce Usage

```html
<!-- dynamic values from apex controller / attributes -->
<c:currencyOutput value="{!value}" currencyIsoCode="{!isoCode}" />

<!-- formats with USD default style (EXPLICIT). Prints as "$1,234.56 USD" -->
<c:currencyOutput value="1234.56" currencyIsoCode="USD" />

<!-- override style to format as "1.234,56 €" -->
<c:currencyOutput value="1234.56" currencyIsoCode="EUR" style="SYMBOL" />
```

### Apex Usage

```java
// format raw numbes with default configuration
String formattedCurr = Currencies.format('EUR', 1234.56);

// change the formatting style for EUR in this execution context
CurrencyTypeExtension eurCurr = Currencies.get('EUR');
eurCurr.setFormattingStyle(CurrencyFormatLength.SYMBOL);
String formattedCurr = eurCurr.format(1234.56);

// temporarily format EUR with ISO style (1.234,56 EUR)
String formattedCurr = Currencies.format('EUR', 1234.56, CurrencyFormatLength.ISO_CODE);
```
