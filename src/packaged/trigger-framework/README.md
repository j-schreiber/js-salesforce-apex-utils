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
