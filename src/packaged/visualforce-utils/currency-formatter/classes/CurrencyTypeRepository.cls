public class CurrencyTypeRepository {
    public static Map<String, CurrencyType> Values {
        get {
            if (Values == null) {
                Values = new Map<String, CurrencyType>();
                for (CurrencyType ct : [SELECT Id, IsoCode, DecimalPlaces FROM CurrencyType]) {
                    Values.put(ct.IsoCode, ct);
                }
            }
            return Values;
        }
        set;
    }
}
