@isTest
public class ApexUtilsFixtures {
    public static SetupObjectFixtures Setup = new SetupObjectFixtures();
    public static AccountFixtures Accounts = new AccountFixtures();

    public class SetupObjectFixtures {
        public Group insertQueue(String queueName, String enabledSobject) {
            return this.insertQueue(queueName, new List<String>{ enabledSobject });
        }
        public Group insertQueue(String queueName, List<String> enabledSobjects) {
            Group queueGroup = new Group(Name = queueName, Type = 'Queue');
            System.runAs(new User(Id = UserInfo.getUserId())) {
                insert queueGroup;
                List<QueuesObject> enablements = new List<QueuesObject>();
                for (String enabledObj : enabledSobjects) {
                    enablements.add(new QueueSObject(QueueId = queueGroup.Id, SObjectType = enabledObj));
                }
                insert enablements;
            }
            return queueGroup;
        }
    }

    public class AccountFixtures {
        public Account insertDefaultAccount() {
            Account a = CreateDefaultAccount();
            insertAccountsWithoutTriggers(new List<Account>{ a });
            return a;
        }

        public List<Account> insertMultipleAccounts() {
            List<Account> accs = CreateMultipleAccounts();
            insertAccountsWithoutTriggers(accs);
            return accs;
        }

        public List<Account> insertAccountsWithContacts() {
            List<Account> accs = InsertMultipleAccounts();
            List<Contact> contacts = new List<Contact>();
            contacts.add(CreateContact(accs[0].Id, 'tester1@starship.de', 'Tester 1'));
            contacts.add(CreateContact(accs[0].Id, 'tester2@starship.de', 'Tester 2'));
            contacts.add(CreateContact(accs[0].Id, 'tester3@starship.de', 'Tester 3'));
            contacts.add(CreateContact(accs[1].Id, 'tester4@colonial-one.de', 'Tester 4'));
            contacts.add(CreateContact(accs[1].Id, 'tester5@colonial-one.de', 'Tester 5'));
            contacts.add(CreateContact(accs[1].Id, 'tester6@colonial-one.de', 'Tester 6'));
            contacts.add(CreateContact(accs[2].Id, 'tester7@cloud-nine.de', 'Tester 7'));
            contacts.add(CreateContact(accs[2].Id, 'tester8@cloud-nine.de', 'Tester 8'));
            contacts.add(CreateContact(accs[2].Id, 'tester9@cloud-nine.de', 'Tester 9'));
            insert contacts;
            return accs;
        }

        public List<Account> createMultipleAccounts() {
            List<Account> accs = new List<Account>();
            accs.add(
                new Account(
                    Name = 'Starship Galactica Ltd.',
                    AccountNumber = '1000',
                    BillingStreet = 'Allersberger Str. 8-10',
                    BillingPostalCode = '90461',
                    BillingCity = 'Nürnberg',
                    BillingCountryCode = 'DE',
                    NumberOfEmployees = 100
                )
            );
            accs.add(
                new Account(
                    Name = 'Colonial One',
                    AccountNumber = '1001',
                    BillingStreet = 'Bayerstraße 10',
                    BillingPostalCode = '80335',
                    BillingCity = 'München',
                    BillingCountryCode = 'DE',
                    NumberOfEmployees = 100
                )
            );
            accs.add(
                new Account(
                    Name = 'Cloud 9 GmbH',
                    AccountNumber = '1002',
                    BillingStreet = 'Viktoriastraße 7-5',
                    BillingPostalCode = '86150',
                    BillingCity = 'Augsburg',
                    BillingCountryCode = 'DE',
                    NumberOfEmployees = 100
                )
            );
            return accs;
        }

        public Account createDefaultAccount() {
            Account a = CreateAccount('Apex Utils Test Business Account', '2000');
            a.BillingStreet = 'Allersberger Straße 8-10';
            a.BillingPostalCode = '90461';
            a.BillingCity = 'Nürnberg';
            a.BillingStateCode = null;
            a.ShippingStreet = 'Allersberger Straße 8-10';
            a.ShippingPostalCode = '90461';
            a.ShippingCity = 'Nürnberg';
            a.ShippingStateCode = null;
            a.NumberOfEmployees = 1;
            return a;
        }

        public Account createAccount(String accountName, String accountNumber) {
            return new Account(Name = accountName, AccountNumber = accountNumber, BillingCountryCode = 'DE', ShippingCountryCode = 'DE');
        }

        public Contact createContact(Id accountId, String email, String lastName) {
            return new Contact(AccountId = accountId, Email = email, FirstName = 'Test', LastName = lastName);
        }

        private void insertAccountsWithoutTriggers(List<Account> accs) {
            Triggers.disableSObject(Schema.Account.SObjectType);
            insert accs;
            Triggers.enableSObject(Schema.Account.SObjectType);
        }

        private void insertOrdersWithoutTriggers(List<Order> ords) {
            Triggers.disableSObject(Schema.Order.SObjectType);
            insert ords;
            Triggers.enableSObject(Schema.Order.SObjectType);
        }
    }
}
