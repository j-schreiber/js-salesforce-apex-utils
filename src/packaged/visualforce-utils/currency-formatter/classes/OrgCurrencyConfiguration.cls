public with sharing class OrgCurrencyConfiguration {
    @testVisible
    private static Map<String, SObject> currencyTypes {
        get {
            if (currencyTypes == null) {
                currencyTypes = new Map<String, SObject>();
                for (SObject ct : Database.query('SELECT Id, IsoCode, DecimalPlaces FROM CurrencyType')) {
                    currencyTypes.put((String) ct.get('IsoCode'), ct);
                }
            }
            return currencyTypes;
        }
        set;
    }

    public static Integer getDecimalPlaces(String isoCode) {
        if (UserInfo.isMultiCurrencyOrganization()) {
            if (!currencyTypes.containsKey(isoCode)) {
                throw new IllegalArgumentException(
                    String.format(System.Label.Invalid_Currency_Iso_Code_Unknown_Currency_Type, new List<Object>{ isoCode })
                );
            }
            return Integer.valueOf(currencyTypes.get(isoCode).get('DecimalPlaces'));
        } else {
            return 2;
        }
    }
}
