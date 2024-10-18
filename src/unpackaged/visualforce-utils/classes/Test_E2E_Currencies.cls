@isTest
public class Test_E2E_Currencies {
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

    @isTest
    static void format_PositiveNumbersUSDExplicitStyle_FormatsWithUSDLocale() {
        // Arrange
        Map<Decimal, String> inputOutputs = new Map<Decimal, String>{
            0.00 => '$0.00 USD',
            0.99 => '$0.99 USD',
            0.99999 => '$1.00 USD',
            1.00 => '$1.00 USD',
            1.1 => '$1.10 USD',
            1.10 => '$1.10 USD',
            1.509 => '$1.51 USD',
            999.99 => '$999.99 USD',
            1000.00 => '$1,000.00 USD',
            1000000.00 => '$1,000,000.00 USD'
        };

        // Assert
        for (Decimal inputValue : inputOutputs.keySet()) {
            System.Assert.areEqual(
                inputOutputs.get(inputValue),
                Currencies.format('USD', inputValue, CurrencyFormatLength.EXPLICIT),
                'output matches expected'
            );
        }
    }

    @isTest
    static void format_NegativeNumbersUSDExplicitStyle_FormatsWithUSDLocale() {
        // Arrange
        Map<Decimal, String> inputOutputs = new Map<Decimal, String>{
            -0.00 => '$0.00 USD',
            -0.99 => '-$0.99 USD',
            -0.99999 => '-$1.00 USD',
            -1.00 => '-$1.00 USD',
            -1.1 => '-$1.10 USD',
            -1.10 => '-$1.10 USD',
            -1.509 => '-$1.51 USD',
            -999.99 => '-$999.99 USD',
            -1000.00 => '-$1,000.00 USD',
            -1000000.00 => '-$1,000,000.00 USD'
        };

        // Assert
        for (Decimal inputValue : inputOutputs.keySet()) {
            System.Assert.areEqual(
                inputOutputs.get(inputValue),
                Currencies.format('USD', inputValue, CurrencyFormatLength.EXPLICIT),
                'output matches expected'
            );
        }
    }

    @isTest
    static void format_LargeNumberAsCHF_FormatsWithCHFLocale() {
        // Assert
        System.Assert.areEqual(
            'CHF 100’000.01',
            Currencies.format('CHF', 100000.01, CurrencyFormatLength.ISO_CODE),
            'output matches expected'
        );
    }

    @isTest
    static void format_IDRShortStyle_FormatsWithIDRLocale() {
        // Arrange
        // test only executes if multi-currency is enabled
        // it requires a correctly imported IDR with 0 Decimal Places
        if (!UserInfo.isMultiCurrencyOrganization()) {
            return;
        }

        // Act & Assert
        Map<Decimal, String> inputOutputs = new Map<Decimal, String>{
            0.99 => 'Rp1',
            -0.99 => '-Rp1',
            123456789 => 'Rp123.456.789',
            -123456789 => '-Rp123.456.789'
        };
        for (Decimal inputValue : inputOutputs.keySet()) {
            System.Assert.areEqual(
                inputOutputs.get(inputValue),
                Currencies.format('IDR', inputValue, CurrencyFormatLength.SYMBOL),
                'output matches expected'
            );
        }
    }
}
