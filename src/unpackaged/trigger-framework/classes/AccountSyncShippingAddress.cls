public class AccountSyncShippingAddress implements TriggerExecutable {
    public void execute(TriggerContext context) {
        for (Account a : (List<Account>) context.getPrimaryList()) {
            a.ShippingStreet = a.BillingStreet;
            a.ShippingPostalCode = a.BillingPostalCode;
            a.ShippingCity = a.BillingCity;
        }
    }
}
