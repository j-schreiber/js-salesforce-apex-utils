@isTest
public class Test_Unit_TestMockFactory {
    private static final String DEFAULT_ACCOUNT_MOCK = 'ApexUtils_MockData_Account_Default';
    private static final String DEFAULT_ORDER_MOCK = 'ApexUtils_MockData_Order_WithLineItems';
    private static final String DEFAULT_MOCK_CONTACTS = 'ApexUtils_MockData_Contacts_Default';

    @isTest
    static void createSObjectMock_ValidResourceName_CreateMockRecord() {
        // ACT
        Account accOne = (Account) TestMockFactory.createSObjectMock(DEFAULT_ACCOUNT_MOCK, Account.SObjectType);
        Account accTwo = (Account) TestMockFactory.createSObjectMock(DEFAULT_ACCOUNT_MOCK, Account.SObjectType);
        Order orderOne = (Order) TestMockFactory.createSObjectMock(DEFAULT_ORDER_MOCK, Order.SObjectType);
        // ASSERT
        System.assertEquals('Apex Utils Test Business Account', accOne.Name, 'first account name');
        System.assertEquals('Apex Utils Test Business Account', accTwo.Name, 'second account name');
        System.assertEquals('001000000000001AAA', accOne.Id, 'first mock id 18 characters');
        System.assertEquals('001000000000001', accOne.Id, 'first mock id 15 characters');
        System.assertEquals('001000000000002AAA', accTwo.Id, 'second mock id 18 characters');
        System.assertEquals('001000000000002', accTwo.Id, 'second mock id 15 characters');
        System.assertEquals('00000100', orderOne.OrderNumber, 'first order number');
        System.assertEquals('801000000000001AAA', orderOne.Id, 'first order mock id 18 characters');
        System.assertEquals('801000000000001', orderOne.Id, 'first order mock id 15 characters');
    }

    @isTest
    static void createSObjectMocks_ValidResourceName_CreateMockList() {
        // ACT
        List<Contact> contacts = (List<Contact>) TestMockFactory.createSObjectMocks(DEFAULT_MOCK_CONTACTS, Contact.SObjectType);

        // ASSERT
        System.assertEquals(2, contacts.size(), 'serialised contacts');
        System.assertEquals('003000000000001AAA', contacts[0].Id, 'first contact id');
        System.assertEquals('003000000000002AAA', contacts[1].Id, 'second contact id');
    }

    @isTest
    static void createSObjectMock_DefaultMock_CreatesEmptyRecord() {
        // ACT
        Account a = (Account) TestMockFactory.createSObjectMock(Account.SObjectType);
        // ASSERT
        System.assertEquals(new Set<String>{ 'Id' }, a.getPopulatedFieldsAsMap().keySet(), 'populated fields');
        System.assertEquals('001000000000001AAA', a.Id, 'mocked id');
    }

    @isTest
    static void createSObjectMocks_ComplexAccountInputs_CreatesAccountMocks() {
        // ACT
        List<Map<String, Object>> accountInputs = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Name' => 'Test Account 1',
                'BillingAddress' => new Map<String, Object>{ 'street' => 'Test Straße 1', 'postalCode' => '86152' },
                'CreatedDate' => System.now()
            },
            new Map<String, Object>{
                'Name' => 'Test Account 2',
                'BillingAddress' => new Map<String, Object>{ 'street' => 'Test Straße 2', 'postalCode' => '86150', 'city' => 'Augsburg' },
                'OwnerId' => new Map<String, Object>{ 'Username' => 'admin-salesforce@mobilityhouse.com' }
            },
            new Map<String, Object>{
                'Name' => 'Test Account 3',
                'AccountNumber' => '1002',
                'Contacts' => new List<Map<String, Object>>{
                    new Map<String, Object>{ 'LastName' => 'Kontakt 1' },
                    new Map<String, Object>{ 'LastName' => 'Kontakt 2' }
                }
            }
        };
        List<Account> mockAccounts = (List<Account>) TestMockFactory.createSObjectMocks(Account.SObjectType, accountInputs);

        // ASSERT
        System.assertEquals(3, mockAccounts.size(), 'mocked account size');
        System.assertEquals(
            new Set<String>{ 'Id', 'Name', 'BillingAddress', 'CreatedDate' },
            mockAccounts[0].getPopulatedFieldsAsMap().keySet(),
            'first account populated fields'
        );
        System.assertEquals('Test Account 1', mockAccounts[0].Name, 'first account name');
        System.assertEquals('Test Straße 1', mockAccounts[0].BillingAddress.getStreet(), 'first account billing street');
        System.assertEquals('86152', mockAccounts[0].BillingAddress.getPostalCode(), 'first account billing postal code');
        System.assertEquals(null, mockAccounts[0].BillingAddress.getCity(), 'first account billing city');
        System.assertEquals(
            new Set<String>{ 'Id', 'Name', 'BillingAddress', 'OwnerId', 'Owner' },
            mockAccounts[1].getPopulatedFieldsAsMap().keySet(),
            'second account populated fields'
        );
        System.assertEquals('Test Account 2', mockAccounts[1].Name, 'second account name');
        System.assertEquals('Test Straße 2', mockAccounts[1].BillingAddress.getStreet(), 'second account billing street');
        System.assertEquals('86150', mockAccounts[1].BillingAddress.getPostalCode(), 'second account billing postal code');
        System.assertEquals('Augsburg', mockAccounts[1].BillingAddress.getCity(), 'second account billing city');
        System.assertEquals('005000000000001AAA', mockAccounts[1].OwnerId, 'second account owner id');
        System.assertEquals('admin-salesforce@mobilityhouse.com', mockAccounts[1].Owner.Username, 'second account owner');
        System.assertEquals(
            new Set<String>{ 'Id', 'AccountNumber', 'Name', 'Contacts' },
            mockAccounts[2].getPopulatedFieldsAsMap().keySet(),
            'third account populated fields'
        );
        System.assertEquals('Test Account 3', mockAccounts[2].Name, 'third account name');
        System.assertEquals('1002', mockAccounts[2].AccountNumber, 'third account number');
        System.assertEquals(2, mockAccounts[2].Contacts.size(), 'third account contacts');
    }

    @isTest
    static void createSObjectMock_EmptyFieldInputs_CreatesEmptyRecord() {
        // ACT
        Account a = (Account) TestMockFactory.createSObjectMock(Account.SObjectType, new Map<String, Object>());
        // ASSERT
        System.assertEquals(new Set<String>{ 'Id' }, a.getPopulatedFieldsAsMap().keySet(), 'populated fields');
        System.assertEquals('001000000000001AAA', a.Id, 'mocked id');
    }

    @isTest
    static void createSObjectMock_BasicOrderFields_CreateOrderMockRecord() {
        // ACT
        Order mockOrder = (Order) TestMockFactory.createSObjectMock(
            Order.SObjectType,
            new Map<String, Object>{
                'Name' => 'Test Order',
                'TotalAmount' => 1337.37,
                'OrderNumber' => '00001337',
                'EffectiveDate' => Date.newInstance(2020, 10, 1)
            }
        );
        // ASSERT
        System.assertEquals('00001337', mockOrder.OrderNumber, 'order number');
        System.assertEquals('801000000000001AAA', mockOrder.Id, 'order mock id 18 characters');
        System.assertEquals('801000000000001', mockOrder.Id, 'order mock id 15 characters');
        System.assertEquals(1337.37, mockOrder.TotalAmount, 'order mock formula field');
        System.assertEquals(Date.newInstance(2020, 10, 1), mockOrder.EffectiveDate, 'order mock date field');
    }

    @isTest
    static void createSObjectMock_OrderWithItems_CreateOrderMockRecord() {
        // ARRANGE
        Map<String, Object> orderFields = new Map<String, Object>{ 'OrderNumber' => '00001337' };
        List<Map<String, Object>> orderItems = new List<Map<String, Object>>{
            new Map<String, Object>{ 'UnitPrice' => 100.00, 'Quantity' => 3, 'TotalPrice' => 300.00 },
            new Map<String, Object>{ 'UnitPrice' => 125.00, 'Quantity' => 4, 'TotalPrice' => 500.00 }
        };
        orderFields.put('OrderItems', orderItems);

        // ACT
        Order mockOrder = (Order) TestMockFactory.createSObjectMock(Order.SObjectType, orderFields);
        // ASSERT
        System.assertEquals('00001337', mockOrder.OrderNumber, 'order number');
        System.assertEquals('801000000000001AAA', mockOrder.Id, 'order mock id 18 characters');
        System.assertEquals(2, mockOrder.OrderItems.size(), 'mocked order items');
        System.assertEquals('802000000000001AAA', mockOrder.OrderItems[0].Id, 'first order item id');
        System.assertEquals(300.00, mockOrder.OrderItems[0].TotalPrice, 'first order item total price');
        System.assertEquals(100.00, mockOrder.OrderItems[0].UnitPrice, 'first order item unit price');
        System.assertEquals(3, mockOrder.OrderItems[0].Quantity, 'first order item quantity');
        System.assertEquals('802000000000002AAA', mockOrder.OrderItems[1].Id, 'second order item id');
        System.assertEquals(500.00, mockOrder.OrderItems[1].TotalPrice, 'second order item total price');
        System.assertEquals(125.00, mockOrder.OrderItems[1].UnitPrice, 'second order item unit price');
        System.assertEquals(4, mockOrder.OrderItems[1].Quantity, 'second order item quantity');
    }

    @isTest
    static void createSObjectMock_EmptyListForChildRelationship_CreateMockRecordWithEmptySubselect() {
        // ARRANGE
        Map<String, Object> orderFields = new Map<String, Object>{
            'OrderNumber' => '00001337',
            'OrderItems' => new List<Map<String, Object>>()
        };

        // ACT
        Order mockOrder = (Order) TestMockFactory.createSObjectMock(Order.SObjectType, orderFields);
        // ASSERT
        System.assertEquals('00001337', mockOrder.OrderNumber, 'order number');
        System.assertEquals(0, mockOrder.OrderItems.size(), 'mocked order items');
    }

    @isTest
    static void createSObjectMock_ContactWithParentAccount_CreateContactMockRecord() {
        // ARRANGE
        Map<String, Object> input = new Map<String, Object>{
            'AccountId' => new Map<String, Object>{ 'Name' => 'Test Company GmbH', 'AccountNumber' => '1000' },
            'LastName' => 'Tester',
            'Email' => 'info@lietzau-consulting.de'
        };
        // ACT
        Contact mockContact = (Contact) TestMockFactory.createSobjectMock(Contact.SObjectType, input);
        // ASSERT
        System.assertEquals('001000000000001AAA', mockContact.AccountId, 'AccountId with mocked parent id');
        System.assertEquals('001000000000001AAA', mockContact.Account.Id, 'Account.Id with mocked parent id');
        System.assertEquals('Test Company GmbH', mockContact.Account.Name, 'Account.Name with input');
        System.assertEquals('1000', mockContact.Account.AccountNumber, 'Account.AccountNumber with input');
        System.assertEquals('Tester', mockContact.LastName, 'LastName with input');
        System.assertEquals('info@lietzau-consulting.de', mockContact.Email, 'Email with input');
    }

    @isTest
    static void createSObjectMock_SetParentRelationshipFieldWithMockSObject_CreateChildWithParent() {
        // ARRANGE
        Account parentAcc = (Account) TestMockFactory.createSObjectMock(Account.SObjectType);
        // ACT
        Contact mockContact = (Contact) TestMockFactory.createSobjectMock(
            Contact.SObjectType,
            new Map<String, Object>{ 'AccountId' => parentAcc, 'LastName' => 'Tester' }
        );
        // ASSERT
        System.assertEquals(parentAcc.Id, mockContact.AccountId, 'AccountId with mocked parent id');
        System.assertEquals(parentAcc.Id, mockContact.Account.Id, 'Account.Id with mocked parent id');
        System.assertEquals('Tester', mockContact.LastName, 'LastName with input');
    }

    @isTest
    static void createSObjectMock_SetParentRelationshipFieldWithId_CreateChildOnly() {
        // ARRANGE
        Account parentAcc = (Account) TestMockFactory.createSObjectMock(Account.SObjectType);
        // ACT
        Contact mockContact = (Contact) TestMockFactory.createSobjectMock(
            Contact.SObjectType,
            new Map<String, Object>{ 'AccountId' => parentAcc.Id, 'LastName' => 'Tester' }
        );
        // ASSERT
        System.assertEquals(parentAcc.Id, mockContact.AccountId, 'AccountId with mocked parent id');
        System.assertEquals(null, mockContact.Account, 'parent relationship not set');
        System.assertEquals('Tester', mockContact.LastName, 'LastName with input');
    }

    @isTest
    static void createSObjectMock_ParentRelationshipFieldAsMockedSObject_CreateChildWithParent() {
        // ARRANGE
        Account parentAcc = (Account) TestMockFactory.createSObjectMock(Account.SObjectType);
        // ACT
        Contact mockContact = (Contact) TestMockFactory.createSobjectMock(
            Contact.SObjectType,
            new Map<String, Object>{ 'AccountId' => parentAcc, 'LastName' => 'Tester' }
        );
        // ASSERT
        System.assertEquals(parentAcc.Id, mockContact.AccountId, 'AccountId with mocked parent id');
        System.assertEquals(parentAcc.Id, mockContact.Account.Id, 'Account.Id with mocked parent id');
        System.assertEquals('Tester', mockContact.LastName, 'LastName with input');
    }

    @isTest
    static void createSObjectMock_ParentRelationshipAsSObjectNoId_CreateChildWithParent() {
        // ACT
        Contact mockContact = (Contact) TestMockFactory.createSobjectMock(
            Contact.SObjectType,
            new Map<String, Object>{ 'AccountId' => new Account(Name = 'Test Name GmbH'), 'LastName' => 'Tester' }
        );
        // ASSERT
        System.assertEquals('001000000000001AAA', mockContact.AccountId, 'AccountId with mocked parent id');
        System.assertEquals('001000000000001AAA', mockContact.Account.Id, 'Account.Id with mocked parent id');
        System.assertEquals('Test Name GmbH', mockContact.Account.Name, 'Account.Id with mocked parent id');
        System.assertEquals('Tester', mockContact.LastName, 'LastName with input');
    }

    @isTest
    static void createSObjectMock_ParentRelationshipAsSObjectWithId_CreateChildWithParent() {
        // ACT
        Contact mockContact = (Contact) TestMockFactory.createSobjectMock(
            Contact.SObjectType,
            new Map<String, Object>{
                'AccountId' => new Account(Name = 'Test Name GmbH', Id = '001000000000100AAA'),
                'LastName' => 'Tester'
            }
        );
        // ASSERT
        System.assertEquals('001000000000100AAA', mockContact.AccountId, 'AccountId with mocked parent id');
        System.assertEquals('001000000000100AAA', mockContact.Account.Id, 'Account.Id with mocked parent id');
        System.assertEquals('Test Name GmbH', mockContact.Account.Name, 'Account.Id with mocked parent id');
        System.assertEquals('Tester', mockContact.LastName, 'LastName with input');
    }

    @isTest
    static void createSObjectMock_InvalidFieldForParentRelationship_ThrowsException() {
        // ARRANGE
        Map<String, Object> input = new Map<String, Object>{
            'FirstName' => new Map<String, Object>{ 'Name' => 'Test Company GmbH', 'AccountNumber' => '1000' },
            'LastName' => 'Tester',
            'Email' => 'info@lietzau-consulting.de'
        };
        // ASSERT
        try {
            Contact mockContact = (Contact) TestMockFactory.createSObjectMock(Contact.SObjectType, input);
            System.assert(false, 'Expected exception');
        } catch (TestMockFactory.SObjectMockException e) {
            System.assert(e.getMessage().contains('STRING'), 'contains desired type: ' + e.getMessage());
            System.assert(e.getMessage().contains('FirstName'), 'contains field name: ' + e.getMessage());
        }
    }

    @isTest
    static void createSObjectMock_InvalidInputForParentRelationship_ThrowsException() {
        // ARRANGE
        Map<String, Object> input = new Map<String, Object>{
            'OwnerId' => 'admin-salesforce@mobilityhouse.com',
            'LastName' => 'Tester',
            'Email' => 'info@lietzau-consulting.de'
        };
        // ASSERT
        try {
            Contact mockContact = (Contact) TestMockFactory.createSObjectMock(Contact.SObjectType, input);
            System.assert(false, 'Expected exception');
        } catch (TestMockFactory.SObjectMockException e) {
            System.assert(e.getMessage().contains('OwnerId'), 'contains field name: ' + e.getMessage());
            System.assert(e.getMessage().contains('User'), 'contains target entity name: ' + e.getMessage());
            System.assert(e.getMessage().contains('Map<String, Object>'), 'contains desired format: ' + e.getMessage());
            System.assert(e.getMessage().contains('admin-salesforce@mobilityhouse.com'), 'contains input: ' + e.getMessage());
        }
    }

    @isTest
    static void createSObjectMock_InvalidInputForAddressField_ThrowsException() {
        // ARRANGE
        Map<String, Object> input = new Map<String, Object>{
            'MailingAddress' => 'Some Street Name 1',
            'LastName' => 'Tester',
            'Email' => 'info@lietzau-consulting.de'
        };
        // ASSERT
        try {
            Contact mockContact = (Contact) TestMockFactory.createSObjectMock(Contact.SObjectType, input);
            System.assert(false, 'Expected exception');
        } catch (TestMockFactory.SObjectMockException e) {
            System.assert(e.getMessage().contains('System.Address'), 'is address message: ' + e.getMessage());
            System.assert(e.getMessage().contains('MailingAddress'), 'error contains field name: ' + e.getMessage());
        }
    }

    @isTest
    static void createSObjectMock_InvalidInputForRegularField_ThrowsException() {
        // ARRANGE
        Map<String, Object> input = new Map<String, Object>{
            'LastName' => new Map<String, Object>{ 'street' => 'Straße 1' },
            'Email' => 'info@lietzau-consulting.de'
        };
        // ASSERT
        try {
            Contact mockContact = (Contact) TestMockFactory.createSObjectMock(Contact.SObjectType, input);
            System.assert(false, 'Expected exception');
        } catch (TestMockFactory.SObjectMockException e) {
            System.assert(e.getMessage().contains('STRING'), 'error contains infos about field type: ' + e.getMessage());
            System.assert(e.getMessage().contains('LastName'), 'error contains field name: ' + e.getMessage());
        }
    }

    @isTest
    static void createSObjectMock_InvalidChildRelationshipName_ThrowsException() {
        // ARRANGE
        Map<String, Object> orderInput = new Map<String, Object>{ 'OrderNumber' => '00001337' };
        List<Map<String, Object>> orderItems = new List<Map<String, Object>>{
            new Map<String, Object>{ 'UnitPrice' => 100.00, 'Quantity' => 3, 'TotalPrice' => 300.00 },
            new Map<String, Object>{ 'UnitPrice' => 125.00, 'Quantity' => 4, 'TotalPrice' => 500.00 }
        };
        orderInput.put('InvalidRelationshipName__x', orderItems);

        // ASSERT
        try {
            Order mockOrder = (Order) TestMockFactory.createSObjectMock(Order.SObjectType, orderInput);
            System.assert(false, 'Expected exception');
        } catch (TestMockFactory.SObjectMockException e) {
            System.assert(e.getMessage().contains('InvalidRelationshipName__x'), 'error contains field name: ' + e.getMessage());
            System.assert(e.getMessage().contains('Order'), 'error contains sobject name: ' + e.getMessage());
        }
    }

    @isTest
    static void createSObjectMock_InvalidInputForChildRelationship_ThrowsException() {
        // ARRANGE
        Map<String, Object> orderInput = new Map<String, Object>{ 'OrderNumber' => '00001337' };
        Map<String, Object> orderItems = new Map<String, Object>{ 'UnitPrice' => 100.00, 'Quantity' => 3, 'TotalPrice' => 300.00 };
        orderInput.put('OrderItems', orderItems);

        // ASSERT
        try {
            Order mockOrder = (Order) TestMockFactory.createSObjectMock(Order.SObjectType, orderInput);
            System.assert(false, 'Expected exception');
        } catch (TestMockFactory.SObjectMockException e) {
            System.assert(e.getMessage().contains('OrderItems'), 'error contains field name: ' + e.getMessage());
            System.assert(e.getMessage().contains('List<Map<String, Object>>'), 'error contains details: ' + e.getMessage());
        }
    }

    @isTest
    static void createSObjectMock_InvalidSObjectField_ThrowsException() {
        // ASSERT
        try {
            Order mockOrder = (Order) TestMockFactory.createSObjectMock(
                Order.SObjectType,
                new Map<String, Object>{ 'OrderNumber' => '00001337', 'SomeInvalidField__a' => 'ABC' }
            );
            System.assert(false, 'Expected exception');
        } catch (TestMockFactory.SObjectMockException e) {
            System.assert(e.getMessage().contains('SomeInvalidField__a'), 'error contains field name: ' + e.getMessage());
            System.assert(e.getMessage().contains('Order'), 'error contains sobject name: ' + e.getMessage());
        }
    }

    @isTest
    static void createSObjectMock_SetRecordTypeIdInInput_ThrowsException() {
        // ARRANGE
        Map<String, Schema.RecordTypeInfo> accountRecordTypes = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName();
        // abort test, if PersonAccounts are not enabled
        if (!accountRecordTypes.containsKey('PersonAccount')) {
            return;
        }

        // ASSERT
        try {
            Account mockAccount = (Account) TestMockFactory.createSObjectMock(
                Account.SObjectType,
                new Map<String, Object>{
                    'LastName' => 'Tester',
                    'RecordTypeId' => accountRecordTypes.get('PersonAccount').getRecordTypeId()
                }
            );
            System.assert(false, 'Expected exception');
        } catch (TestMockFactory.SObjectMockException e) {
            System.assert(e.getMessage().contains('record type'), 'is record type message: ' + e.getMessage());
            System.assert(e.getMessage().contains('Account'), 'error contains sobject name: ' + e.getMessage());
        }
    }

    @isTest
    static void createSObjectMock_SetRecordTypeParentMockInInput_ThrowsException() {
        // ARRANGE
        Map<String, Schema.RecordTypeInfo> accountRecordTypes = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName();
        // abort test, if PersonAccounts are not enabled
        if (!accountRecordTypes.containsKey('PersonAccount')) {
            return;
        }

        // ASSERT
        try {
            Account mockAccount = (Account) TestMockFactory.createSObjectMock(
                Account.SObjectType,
                new Map<String, Object>{
                    'LastName' => 'Tester',
                    'RecordTypeId' => new Map<String, Object>{ 'DeveloperName' => 'PersonAccount' }
                }
            );
            System.assert(false, 'Expected exception');
        } catch (TestMockFactory.SObjectMockException e) {
            System.assert(e.getMessage().contains('RecordTypeId'), 'is record type message: ' + e.getMessage());
        }
    }

    @isTest
    static void createSObjectMock_RecordTypeDeveloperName_TranslatesToId() {
        // ARRANGE
        Map<String, Schema.RecordTypeInfo> accountRecordTypes = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName();
        // abort test, if PersonAccounts are not enabled
        if (!accountRecordTypes.containsKey('PersonAccount')) {
            return;
        }

        // ACT
        Account mockAccount = (Account) TestMockFactory.createSObjectMock(
            Account.SObjectType,
            new Map<String, Object>{
                'AccountNumber' => '1234',
                'RecordTypeId' => accountRecordTypes.get('PersonAccount').getDeveloperName()
            }
        );

        // ASSERT
        System.assertEquals(accountRecordTypes.get('PersonAccount').getRecordTypeId(), mockAccount.get('RecordTypeId'), 'record type id');
        System.assertEquals('1234', mockAccount.AccountNumber, 'last name');
    }

    @isTest
    static void overrideField_SetValueForReadOnlyField_FieldOverridden() {
        // ACT
        Account a = new Account(Name = 'Account Name');
        DateTime newValue = DateTime.newInstance(2020, 1, 2);
        a = (Account) TestMockFactory.overrideField(a, 'CreatedDate', newValue);
        // ASSERT
        System.assertEquals(newValue, a.CreatedDate, 'created date');
        System.assertEquals('Account Name', a.Name, 'name remains');
    }

    @isTest
    static void overrideField_SetParentObjectInput_FieldOverridden() {
        // ACT
        Contact c = new Contact(LastName = 'Tester', Email = 'tester@example.com');
        c = (Contact) TestMockFactory.overrideField(
            c,
            'AccountId',
            new Map<String, Object>{ 'Name' => 'Acc GmbH', 'AccountNumber' => '1000' }
        );
        // ASSERT
        System.assertNotEquals(null, c.AccountId, 'account id');
        System.assertNotEquals(null, c.Account, 'parent account');
        System.assertEquals('1000', c.Account.AccountNumber, 'account number');
        System.assertEquals('Acc GmbH', c.Account.Name, 'account name');
    }

    @isTest
    static void overrideFieldAsToken_SetParentObjectInput_FieldOverridden() {
        // ACT
        Contact c = new Contact(LastName = 'Tester', Email = 'tester@example.com');
        c = (Contact) TestMockFactory.overrideField(
            c,
            Schema.Contact.AccountId,
            new Map<String, Object>{ 'Name' => 'Acc GmbH', 'AccountNumber' => '1000' }
        );
        // ASSERT
        System.assertNotEquals(null, c.AccountId, 'account id');
        System.assertNotEquals(null, c.Account, 'parent account');
        System.assertEquals('1000', c.Account.AccountNumber, 'account number');
        System.assertEquals('Acc GmbH', c.Account.Name, 'account name');
    }

    @isTest
    static void overrideField_SetParentInvalidInput_ThrowsException() {
        // ACT
        Contact c = new Contact(LastName = 'Tester', Email = 'tester@example.com');
        try {
            c = (Contact) TestMockFactory.overrideField(c, 'AccountId', 'Invalid Input');
            System.assert(false, 'expected exception');
        } catch (TestMockFactory.SObjectMockException e) {
            System.assert(e.getMessage().contains('AccountId'), 'contains field name: ' + e.getMessage());
            System.assert(e.getMessage().contains('Account'), 'contains target entity name: ' + e.getMessage());
            System.assert(e.getMessage().contains('Map<String, Object>'), 'contains desired format: ' + e.getMessage());
            System.assert(e.getMessage().contains('Invalid Input'), 'contains input: ' + e.getMessage());
        }
    }

    @isTest
    static void overrideField_SetValidGenericMockInput_ChildrenSet() {
        // ACT
        Account a = new Account(Name = 'Account Name');
        a = (Account) TestMockFactory.overrideField(
            a,
            'Contacts',
            new List<Map<String, Object>>{
                new Map<String, Object>{ 'LastName' => 'Tester 1' },
                new Map<String, Object>{ 'LastName' => 'Tester 2' },
                new Map<String, Object>{ 'LastName' => 'Tester 3' }
            }
        );
        // ASSERT
        System.assertEquals('Account Name', a.Name, 'retrains existing property');
        System.assertEquals(3, a.Contacts.size(), 'contacts subselect mocked');
        for (Contact c : a.Contacts) {
            System.assertNotEquals(null, c.Id, 'contact id mocked');
        }
        System.assertEquals('Tester 1', a.Contacts[0].LastName, 'first contact name');
        System.assertEquals('Tester 2', a.Contacts[1].LastName, 'second contact name');
        System.assertEquals('Tester 3', a.Contacts[2].LastName, 'third contact name');
    }

    @isTest
    static void overrideField_SetValidChildRecordsInput_ChildrenSet() {
        // ACT
        Account a = new Account(Name = 'Account Name');
        a = (Account) TestMockFactory.overrideField(
            a,
            'Contacts',
            new List<Contact>{
                new Contact(LastName = 'Tester 1', Email = 'tester1@example.com'),
                new Contact(LastName = 'Tester 2', Email = 'tester2@example.com'),
                new Contact(LastName = 'Tester 3', Email = 'tester3@example.com')
            }
        );
        // ASSERT
        System.assertEquals('Account Name', a.Name, 'retrains existing property');
        System.assertEquals(3, a.Contacts.size(), 'contacts subselect mocked');
        for (Contact c : a.Contacts) {
            System.assertNotEquals(null, c.Id, 'contact id mocked');
        }
        System.assertEquals('Tester 1', a.Contacts[0].LastName, 'first contact name');
        System.assertEquals('Tester 2', a.Contacts[1].LastName, 'second contact name');
        System.assertEquals('Tester 3', a.Contacts[2].LastName, 'third contact name');
    }

    @isTest
    static void overrideField_SetInvalidChildRecordsInput_ThrowsException() {
        // ACT
        Account a = new Account(Name = 'Account Name');
        try {
            a = (Account) TestMockFactory.overrideField(
                a,
                'Contacts',
                new List<Asset>{ new Asset(Name = 'Asset 1'), new Asset(Name = 'Asset 2'), new Asset(Name = 'Asset 3') }
            );
            System.assert(false, 'expected exception');
        } catch (TestMockFactory.SObjectMockException e) {
            System.assert(e.getMessage().contains('Contacts'), 'error contains field name: ' + e.getMessage());
            System.assert(e.getMessage().contains('List<Asset>'), 'error picks up wrong input: ' + e.getMessage());
            System.assert(e.getMessage().contains('List<Contact>'), 'error contains instructions: ' + e.getMessage());
        }
    }

    @isTest
    static void overrideField_SetValueForReadOnlyFieldToken_FieldOverridden() {
        // ACT
        Account a = new Account(Name = 'Account Name');
        DateTime newValue = DateTime.newInstance(2020, 1, 2);
        a = (Account) TestMockFactory.overrideField(a, Schema.Account.CreatedDate, newValue);
        // ASSERT
        System.assertEquals(newValue, a.CreatedDate, 'created date');
        System.assertEquals('Account Name', a.Name, 'name remains');
    }

    @isTest
    static void generateFakeId_OverrideSeed_ReturnsFixedId() {
        // ACT
        Id mockId1 = TestMockFactory.generateFakeId(Account.SObjectType, 10);
        Id mockId2 = TestMockFactory.generateFakeId(Account.SObjectType, 10);
        Id mockId3 = TestMockFactory.generateFakeId(Account.SObjectType, 10);
        // ASSERT
        System.assertEquals('001000000000010AAA', mockId1, 'first mock id 18 characters');
        System.assertEquals('001000000000010AAA', mockId2, 'second mock id 18 characters');
        System.assertEquals('001000000000010AAA', mockId3, 'third mock id 18 characters');
    }
}
