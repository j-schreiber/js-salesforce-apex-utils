# Test Mock Factory

A SObject mock factory that makes it easier to write true unit tests. Mock system and formula fields, parent- and child relationships as well as rollup summary fields. Create new mock records from scratch or simply override selected properties on existing records.

## Why Even Bother?

Because mocking and stubbig are a fundamental part of writing solid unit tests. If you don't mock, you are limited to in-memory records. They will get you only so far, until you need to insert them in order to populate system fields such as `CreatedDate` or `Id`. You don't want to insert records into the database. It is 10-fold slower than mocking and can cause nasty bugs such as the [UNABLE_TO_LOCK_ROW](https://lietzau-consulting.de/2021/12/unable-to-lock-row-in-tests/).

Instead of using

```java
Account acc = new Account(
    Name = 'My Test Name',
    AccountNumber = '1000',
    BillingStreet = 'Test Straße 1',
    BillingPostalCode = '86150'
);
```

use

```java
Account mockAcc = (Account) TestMockFactory.createSObjectMock(
  Account.SObjectType,
  new Map<String, Object>{
    'Name' => 'Company Ltd.',
    'AccountNumber' => '1000',
    'CreatedDate' => System.now(),
    'BillingAddress' => new Map<String, Object>{
      'street' => 'Test Straße 1',
      'postalCode' => '86150',
      'city' => 'Augsburg'
    },
    'OwnerId' => new User(UserName = 'info@example.com', Alias = 'admin'),
    'Contacts' => new List<Map<String, Object>>{
      new Map<String, Object>{'Email' => 'contact1@example.com'},
      new Map<String, Object>{'Email' => 'contact2@example.com'}
    }
  }
);
```

This will create an account, that is similar to the following SOQL query (given the user and contacts exist)

```java
Account a = [
    SELECT Id, Name, AccountNumber, CreatedDate, BillingAddress, OwnerId, Owner.Id, Owner.Username, Owner.Alias, (SELECT Id, Email FROM Contacts)
    FROM Account
];
```

## Key Features

The aim of this library is to mock a records as convenient as possible. I believe that tests are the best developer documentation there is. So [check out the test class](src/packaged/main/test/classes/Test_Unit_TestMockFactory.cls) to see the mock factory in action. I [wrote a blog post](https://lietzau-consulting.de/2022/01/a-library-to-mock-sobject-records/) with more examples.

### Create Record Mock

The simplest way is creating a mock record with `Id` only:

```java
Account mockAcc = (Account) TestMockFactory.createSObjectMock(Account.SObjectType);
```

The method is overloaded. You can specify a map of inputs for any property (including system fields, formula fields, rollup summaries or parent/child relationships):

```java
Order o = (Order) TestMockFactory.createSObjectMock(
    Order.SObjectType,
    new Map<String, Object>{
        'OrderNumber' => '00001337',
        'Name' => 'Special Customer Order',
        'TotalAmount' => 1337.37,
        'EffectiveDate' => Date.newInstance(2020, 10, 1)
    }
);
```

### Override Read-only Fields

You can override field values of existing records. The method generates a new record internally, that's why you have to use the return value. This works for record that were created with the SObject constructor, retrieved by SOQL or mocked with the factory.

Technically, you can also override normal fields. But why would you?

#### Override System Field

```java
Account acc = new Account(Name = 'Test Account GmbH');
acc = (Account) TestMockFactory.overrideField(
    acc,
    Schema.Account.CreatedDate,
    DateTime.newInstance(2022, 11, 2, 7, 58, 0)
);
```

#### Override Parent Relationship

```java
Contact c = new Contact(LastName = 'Tester', Email = 'tester@example.com');
c = (Contact) TestMockFactory.overrideField(
    c,
    Schema.Contact.AccountId,
    new Map<String, Object>{ 'Name' => 'Acc GmbH', 'AccountNumber' => '1000' }
);
```

#### Override Child Relationship

```java
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
```

# Extended SObject Describe

Everything you need that you won't get from the regular `DescribeSObjectResult`. Don't construct instances directly, use the `ExtendedSchema` instead.

```java
ExtendedDescribeSObjectResult accountResult = ExtendedSchema.describeSObject(Account.SObjectType);
```
