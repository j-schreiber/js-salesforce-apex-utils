@isTest
public class Test_Unit_Currencies {
    @isTest
    static void format_UnconfiguredCurrencyIsoCode_ThrowsException() {
        // Assert
        try {
            String output = Currencies.format('ABC', 1234);
            System.Assert.fail('Expected exception, but continued.');
        } catch (IllegalArgumentException iae) {
            String expectedMsg = String.format(System.Label.Invalid_Currency_Iso_Code_Unknown_Custom_Metadata, new List<Object>{ 'ABC' });
            System.Assert.areEqual(expectedMsg, iae.getMessage(), 'exception message');
        }
    }

    @isTest
    static void format_UserDefaultCurrency_FormatsToConfig() {
        // Arrange
        String testCurrencyCode = UserInfo.getDefaultCurrency();
        Currency__mdt userDefaultMock = makeDefaultMock(testCurrencyCode);
        Currencies.setMockCurrencyConfiguration(userDefaultMock);

        // Act & Assert
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
        for (Decimal inputValue : inputOutputs.keySet()) {
            System.Assert.areEqual(
                inputOutputs.get(inputValue),
                Currencies.format(testCurrencyCode, inputValue),
                'output matches expected'
            );
        }
    }

    static Currency__mdt makeDefaultMock(String isoCode) {
        return new Currency__mdt(
            DeveloperName = isoCode,
            Label = 'Test Currency',
            CodePosition__c = 'BEFORE',
            SymbolPosition__c = 'AFTER',
            DecimalSeparator__c = ',',
            ThousandsSeparator__c = '.',
            FormatLength__c = 'SYMBOL',
            Symbol__c = '€'
        );
    }
}
