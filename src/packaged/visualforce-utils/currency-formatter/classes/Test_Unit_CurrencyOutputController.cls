@isTest
public class Test_Unit_CurrencyOutputController {
    @isTest
    static void getFormattedValue_ValidCurrency_FormatsValue() {
        // Act
        CurrencyOutputController ctrl = new CurrencyOutputController();
        ctrl.currencyInputCode = 'EUR';
        ctrl.numericInputValue = 123.45;

        // Assert
        System.Assert.areEqual('123,45 €', ctrl.getFormattedValue(), 'formatted value');
    }
}
