@isTest
public class SObjectTreeLoaderMocks {
    public class DefaultAccountFactoryMock implements ISObjectTreeRecordsFactory {
        public Map<String, Account> getRecords(SObjectTreeLoader context) {
            return new Map<String, Account>{
                'AccountRef1' => new Account(
                    Name = 'Test Account From Default Mock',
                    AccountNumber = '1000',
                    BillingStreet = 'Test Straße 1',
                    BillingCity = 'München',
                    ShippingStreet = 'Test Straße 1',
                    ShippingCity = 'München'
                )
            };
        }
    }
    public class BusinessAccountMocks1 implements ISObjectTreeRecordsFactory {
        public Map<String, Account> getRecords(SObjectTreeLoader context) {
            return new Map<String, Account>{
                'Starship' => new Account(
                    Name = 'Starship Galactica Ltd.',
                    AccountNumber = '1000',
                    BillingStreet = 'Allersberger Str. 8-10',
                    BillingPostalCode = '90461',
                    BillingCity = 'Nürnberg',
                    AnnualRevenue = 1000,
                    NumberOfEmployees = 100
                ),
                'ColonialOne' => new Account(
                    Name = 'Colonial One',
                    AccountNumber = '1001',
                    BillingStreet = 'Bayerstraße 10',
                    BillingPostalCode = '80335',
                    BillingCity = 'München'
                ),
                'CloudNine' => new Account(
                    Name = 'Cloud 9 GmbH',
                    AccountNumber = '1002',
                    BillingStreet = 'Viktoriastraße 7-5',
                    BillingPostalCode = '86150',
                    BillingCity = 'Augsburg'
                )
            };
        }
    }
    public class DynamicContactMocks implements ISObjectTreeRecordsFactory {
        public Map<String, Contact> getRecords(SObjectTreeLoader context) {
            Map<String, Contact> contacts = new Map<String, Contact>();
            Integer incrementer = 0;
            for (Account acc : [SELECT Id, Name FROM Account]) {
                // increments, then returns
                contacts.put('ContactRef' + ++incrementer, new Contact(AccountId = acc.Id, LastName = 'Tester ' + incrementer));
                contacts.put('ContactRef' + ++incrementer, new Contact(AccountId = acc.Id, LastName = 'Tester ' + incrementer));
                contacts.put('ContactRef' + ++incrementer, new Contact(AccountId = acc.Id, LastName = 'Tester ' + incrementer));
            }
            return contacts;
        }
    }
}
