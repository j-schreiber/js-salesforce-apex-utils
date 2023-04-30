@isTest
public class Test_Unit_CurrenciesUnpkg {
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
                Currencies.format('IDR', inputValue, CurrencyFormatLength.SYMBOL),
                'output matches expected'
            );
        }
    }
}
