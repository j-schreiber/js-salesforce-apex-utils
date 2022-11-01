Welcome to the JS Salesforce Apex Utils.

# Documentation

The repository uses ApexDox to create documentation. For best user experience clone the repo, run ApexDox, and open the docs locally.

# Test Mock Factory

A SObject mock factory that allows you to write loosely coupled unit tests. Mock system and formula fields, parent- and child relationships as well as rollup summary fields. Create new mock records from scratch or simply override selected properties on existing records.

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

The aim of this library is to mock a sobject record as conveniently and straightforward as possible. I believe that tests are the best developer documentation there is. So [check out the test class](src/packaged/main/test/classes/Test_Unit_TestMockFactory.cls) to see the mock factory in action. I [wrote a blog post](https://lietzau-consulting.de/2022/01/a-library-to-mock-sobject-records/) with more examples.

### Create A SObject Mock Instance

The easiest way to start is creating a new instance from scratch:

```java
Account mockAcc = (Account) TestMockFactory.createSObjectMock(Account.SObjectType);
```

The method is overloaded. You can specify a map of inputs for any property (including system fields, formula fields, rollup summaries or relationships):

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

# Trigger Framework

A lightweight and lean trigger framework that implements the "single trigger per object" best practice. Implement the `TriggerExecutable` interface, register the handler and let the framework do the heavy lifting for you.

See my [blog post](https://lietzau-consulting.de/2022/10/progressive-apex-trigger-framework-for-salesforce/) for more information.

## Implement the TriggerExecutable Interface

The framework automatically sets all context variables in the `TriggerContext`.

```java
public class MyCustomHandler implements TriggerExecutable {
    public void execute(TriggerContext context) {
        // implement trigger logic here
    }
}
```

## Register a TriggerExecutable

We use the `TriggerFeatureControl__mdt` custom metadata to register handlers and control their execution. You can find example configs in [unpackaged/customMetadata](unpackaged/customMetadata).

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Account: Sync Shipping Address</label>
    <protected>false</protected>
    <values>
        <field>Handler__c</field>
        <value xsi:type="xsd:string">AccountSyncShippingAddress</value>
    </values>
    <!-- removed for brevity -->
</CustomMetadata>
```
