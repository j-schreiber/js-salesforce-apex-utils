@isTest
public class Test_Unit_Currencies {
    @isTest
    static void format_UnconfiguredCurrencyIsoCode_ThrowsException() {
        // Assert
        try {
            String output = Currencies.format('ABC', 1234);
            System.Assert.fail('Expected exception, but continued.');
        } catch (IllegalArgumentException iae) {
            String expectedMsg = String.format(System.Label.Invalid_Currency_Iso_Code_Unknown_Currency_Type, new List<Object>{ 'ABC' });
            System.Assert.areEqual(expectedMsg, iae.getMessage(), 'exception message');
        }
    }

    @isTest
    static void format_PositiveValuesEUR_FormatsWithLocale() {
        // Arrange
        Map<Decimal, String> inputOutputs = new Map<Decimal, String>{
            0.00 => '0,00 €',
            0.05 => '0,05 €',
            0.50 => '0,50 €',
            0.99 => '0,99 €',
            0.99999 => '1,00 €',
            1.00 => '1,00 €',
            1.1 => '1,10 €',
            1.10 => '1,10 €',
            1.01 => '1,01 €',
            1.509 => '1,51 €',
            999.99 => '999,99 €',
            1000.00 => '1.000,00 €',
            1000000.00 => '1.000.000,00 €'
        };

        // Assert
        for (Decimal inputValue : inputOutputs.keySet()) {
            System.Assert.areEqual(
                inputOutputs.get(inputValue),
                Currencies.format('EUR', inputValue),
                'output matches for input: ' + inputValue
            );
        }
    }

    @isTest
    static void format_PositiveValuesEURIsoStyle_FormatsWithLocale() {
        // Arrange
        Map<Decimal, String> inputOutputs = new Map<Decimal, String>{
            0.00 => 'EUR 0,00',
            0.05 => 'EUR 0,05',
            0.50 => 'EUR 0,50',
            0.99 => 'EUR 0,99',
            0.99999 => 'EUR 1,00',
            1.00 => 'EUR 1,00',
            1.1 => 'EUR 1,10',
            1.10 => 'EUR 1,10',
            1.01 => 'EUR 1,01',
            1.509 => 'EUR 1,51',
            999.99 => 'EUR 999,99',
            1000.00 => 'EUR 1.000,00',
            1000000.00 => 'EUR 1.000.000,00'
        };

        // Assert
        for (Decimal inputValue : inputOutputs.keySet()) {
            System.Assert.areEqual(
                inputOutputs.get(inputValue),
                Currencies.format('EUR', inputValue, CurrencyFormatLength.ISO_CODE),
                'output matches expected'
            );
        }
    }

    @isTest
    static void format_PositiveValuesEURShortStyle_FormatsWithLocale() {
        // Arrange
        Map<Decimal, String> inputOutputs = new Map<Decimal, String>{
            0.00 => '0,00 €',
            0.05 => '0,05 €',
            0.50 => '0,50 €',
            0.99 => '0,99 €',
            0.99999 => '1,00 €',
            1.00 => '1,00 €',
            1.1 => '1,10 €',
            1.10 => '1,10 €',
            1.01 => '1,01 €',
            1.509 => '1,51 €',
            999.99 => '999,99 €',
            1000.00 => '1.000,00 €',
            1000000.00 => '1.000.000,00 €'
        };

        // Assert
        for (Decimal inputValue : inputOutputs.keySet()) {
            System.Assert.areEqual(
                inputOutputs.get(inputValue),
                Currencies.format('EUR', inputValue, CurrencyFormatLength.SYMBOL),
                'output matches expected'
            );
        }
    }

    @isTest
    static void format_NegativeNumbersEUR_FormatsWithEURLocale() {
        // Arrange
        Map<Decimal, String> inputOutputs = new Map<Decimal, String>{
            -0.00 => 'EUR 0,00',
            -0.504 => 'EUR -0,50',
            -0.505 => 'EUR -0,51',
            -0.506 => 'EUR -0,51',
            -0.99 => 'EUR -0,99',
            -0.99999 => 'EUR -1,00',
            -1.00 => 'EUR -1,00',
            -1.1 => 'EUR -1,10',
            -1.10 => 'EUR -1,10',
            -1.509 => 'EUR -1,51',
            -999.99 => 'EUR -999,99',
            -1000.00 => 'EUR -1.000,00',
            -1000000.00 => 'EUR -1.000.000,00'
        };

        // Assert
        for (Decimal inputValue : inputOutputs.keySet()) {
            System.Assert.areEqual(
                inputOutputs.get(inputValue),
                Currencies.format('EUR', inputValue, CurrencyFormatLength.ISO_CODE),
                'output for input: ' + inputValue
            );
        }
    }

    @isTest
    static void newInstance_EUR_InitFromConfig() {
        // Act
        CurrencyTypeExtension cur = Currencies.get('EUR');
        Currency__mdt config = Currency__mdt.getInstance('EUR');

        // Assert
        System.Assert.areEqual('EUR', cur.getIsoCode(), 'iso code');
        System.Assert.areEqual(config.Symbol__c, cur.getSymbol(), 'symbol');
        System.Assert.areEqual(config.SymbolPosition__c, cur.getSymbolPosition(), 'symbol position');
        System.Assert.areEqual(config.CodePosition__c, cur.getCodePosition(), 'code position');
        CurrencyFormatLength expectedStyle = CurrencyFormatLength.valueOf(config.FormatLength__c);
        System.Assert.areEqual(expectedStyle, cur.getFormattingStyle(), 'formatting style');
    }

    @isTest
    static void format_WithStyleOverride_RetainsOriginalStyle() {
        // Arrange
        CurrencyTypeExtension cur = Currencies.get('EUR');

        // Act
        String explicitFormatting = cur.format(100.00, CurrencyFormatLength.EXPLICIT);

        // Assert
        Currency__mdt config = Currency__mdt.getInstance('EUR');
        CurrencyFormatLength expectedStyle = CurrencyFormatLength.valueOf(config.FormatLength__c);
        System.Assert.areEqual(expectedStyle, cur.getFormattingStyle(), 'formatting style');
    }

    @isTest
    static void setFormattingStyle_NewStyle_OverridesOriginalStyle() {
        // Arrange
        CurrencyTypeExtension cur = Currencies.get('EUR');

        // Act
        Currencies.get('EUR').setFormattingStyle(CurrencyFormatLength.EXPLICIT);

        // Assert
        System.Assert.areEqual(CurrencyFormatLength.EXPLICIT, cur.getFormattingStyle(), 'formatting style');
    }
}
