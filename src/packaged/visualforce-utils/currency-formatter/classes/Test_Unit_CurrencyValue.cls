@isTest
public class Test_Unit_CurrencyValue {
    @isTest
    static void format_UnconfiguredCurrencyIsoCode_ThrowsException() {
        // Assert
        try {
            String output = CurrencyValue.format('ABC', 1234);
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
            System.Assert.areEqual(inputOutputs.get(inputValue), CurrencyValue.format('EUR', inputValue), 'output matches expected');
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
                CurrencyValue.format('EUR', inputValue, CurrencyValue.FormatLength.ISO_FORMAT),
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
                CurrencyValue.format('EUR', inputValue, CurrencyValue.FormatLength.SHORT_FORMAT),
                'output matches expected'
            );
        }
    }

    @isTest
    static void format_NegativeNumbersEUR_FormatsWithEURLocale() {
        // Arrange
        Map<Decimal, String> inputOutputs = new Map<Decimal, String>{
            -0.00 => 'EUR 0,00',
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
                CurrencyValue.format('EUR', inputValue, CurrencyValue.FormatLength.ISO_FORMAT),
                'output matches expected'
            );
        }
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
                CurrencyValue.format('USD', inputValue, CurrencyValue.FormatLength.EXPLICIT_FORMAT),
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
                CurrencyValue.format('USD', inputValue, CurrencyValue.FormatLength.EXPLICIT_FORMAT),
                'output matches expected'
            );
        }
    }

    @isTest
    static void format_LargeNumberAsCHF_FormatsWithCHFLocale() {
        // Assert
        System.Assert.areEqual(
            'CHF 100’000.01',
            CurrencyValue.format('CHF', 100000.01, CurrencyValue.FormatLength.ISO_FORMAT),
            'output matches expected'
        );
    }

    @isTest
    static void format_IDRShortStyle_FormatsWithIDRLocale() {
        // Arrange
        Map<Decimal, String> inputOutputs = new Map<Decimal, String>{
            0.99 => 'Rp1',
            -0.99 => '-Rp1',
            123456789 => 'Rp123.456.789',
            -123456789 => '-Rp123.456.789'
        };

        // Assert
        for (Decimal inputValue : inputOutputs.keySet()) {
            System.Assert.areEqual(
                inputOutputs.get(inputValue),
                CurrencyValue.format('IDR', inputValue, CurrencyValue.FormatLength.SHORT_FORMAT),
                'output matches expected'
            );
        }
    }
}
