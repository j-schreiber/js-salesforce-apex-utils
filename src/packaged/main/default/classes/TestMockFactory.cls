/**
 * Utilities to create sobject mocks from static resources
 *
 * @author Jannis Schreiber
 * @group Stub Framework
 */
@isTest
public class TestMockFactory {
    private static Map<Schema.SObjectType, SObjectMockFactory> sObjectMockFactorys = new Map<Schema.SObjectType, SObjectMockFactory>();

    /**
     * Generates a mocked id for the sobject type. The Id is guaranteed
     * to be unique for the context.
     *
     * @param sobjectType
     * @return  `Id`
     */
    public static Id generateFakeId(Schema.SObjectType sobjectType) {
        return getSObjectMockFactory(sobjectType).generateId();
    }

    /**
     * Generates a mocked id for the sobject type and set the seed yourself.
     * This doesn't increment the counter.
     *
     * @param sobjectType
     * @return  `Id`
     */
    public static Id generateFakeId(Schema.SObjectType sobjectType, Integer idSeed) {
        return getSObjectMockFactory(sobjectType).generateId(idSeed);
    }

    /**
     * Returns the sobject mock factory singleton for the sobject type.
     *
     * @param sobjectType
     * @return  `SObjectMockFactory`
     */
    public static SObjectMockFactory getSObjectMockFactory(Schema.SObjectType sobjectType) {
        if (!sObjectMockFactorys.containsKey(sobjectType)) {
            sObjectMockFactorys.put(sobjectType, new SObjectMockFactory(sobjectType));
        }
        return sObjectMockFactorys.get(sobjectType);
    }

    /**
     * Creates a sobject mock record using a static resource (the resource is expected
     * to contain a serialised record).
     *
     * @param resourceName
     * @param sObjectType
     * @return  `SObject`
     */
    public static SObject createSObjectMock(String resourceName, Schema.SObjectType sObjectType) {
        SObject so = (SObject) createGenericMock(resourceName, SObject.class);
        so.Id = generateFakeId(sobjectType);
        return so;
    }

    /**
     * Creates a list of sobject mock records using a static resource (the resource is expected
     * to contain a serialised record list).
     *
     * @param resourceName
     * @param sObjectType
     * @return  `SObject`
     */
    public static List<SObject> createSObjectMocks(String resourceName, Schema.SObjectType sObjectType) {
        List<SObject> sos = (List<SObject>) createGenericMock(resourceName, List<SObject>.class);
        for (SObject so : sos) {
            so.Id = generateFakeId(sobjectType);
        }
        return sos;
    }

    /**
     * Creates a sobject mock record using any key/value pairs. Allows to populate fields,
     * child and parent relationships and returns an instance of the sobject.
     *
     * @param sObjectType
     * @param sObjectInput
     * @return  `SObject`
     */
    public static SObject createSObjectMock(Schema.SObjectType sObjectType, Map<String, Object> sObjectInput) {
        return getSObjectMockFactory(sobjectType).create(sObjectInput);
    }

    /**
     * Creates a list of sobject mock records using any key/value pairs.
     *
     * @param sObjectType
     * @param sObjectInputs
     * @return  `SObject`
     */
    public static List<SObject> createSObjectMocks(Schema.SObjectType sObjectType, List<Map<String, Object>> sObjectInputs) {
        return getSObjectMockFactory(sobjectType).create(sObjectInputs);
    }

    /**
     * Overrides a single field of the sobject record. Returns an exact copy of the input record
     * with the field value overridden.
     *
     * @param existingRecord
     * @param fieldName Developer name of the field
     * @param newValue
     * @return  `SObject`
     */
    public static SObject overrideField(SObject existingRecord, String fieldName, Object newValue) {
        return getSObjectMockFactory(existingRecord.getSObjectType()).setProperty(existingRecord, fieldName, newValue);
    }

    /**
     * Overrides a single field of the sobject record. Returns an exact copy of the input record
     * with the field value overridden.
     *
     * @param existingRecord
     * @param fieldToken Field token of the field to override
     * @param newValue
     * @return  `SObject`
     */
    public static SObject overrideField(SObject existingRecord, Schema.SObjectField fieldToken, Object newValue) {
        return getSObjectMockFactory(existingRecord.getSObjectType()).setProperty(existingRecord, String.valueOf(fieldToken), newValue);
    }

    /**
     * Creates a new mock record instance that has nothing but a mock id populated
     *
     * @param sObjectType
     * @return  `SObject`
     */
    public static SObject createSObjectMock(Schema.SObjectType sObjectType) {
        return getSObjectMockFactory(sobjectType).create();
    }

    /**
     * Creates any generic mock from a static JSON file
     *
     * @param resourceName
     * @param apexType
     * @return  `Object`
     */
    public static Object createGenericMock(String resourceName, System.Type apexType) {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = :resourceName LIMIT 1];
        return JSON.deserialize(sr.Body.toString(), apexType);
    }

    public class SObjectMockFactory {
        private Schema.SObjectType sobjectType;
        private Schema.DescribeSObjectResult describeResult;
        private System.Type serialisationType;
        private IdGenerator idGen;

        // lazy-init, so this only is visited if we need to
        private Map<String, Schema.ChildRelationship> childRelationships {
            get {
                if (this.childRelationships == null) {
                    this.childRelationships = new Map<String, Schema.ChildRelationship>();
                    List<Schema.ChildRelationship> crs = this.describeResult.getChildRelationships();
                    for (Schema.ChildRelationship childRelationship : crs) {
                        this.childRelationships.put(childRelationship.getRelationshipName(), childRelationship);
                    }
                }
                return this.childRelationships;
            }
            set;
        }

        private SObjectMockFactory(Schema.SObjectType sobjectType) {
            this.sobjectType = sobjectType;
            this.describeResult = this.sobjectType.getDescribe();
            this.idGen = new IdGenerator(sobjectType);
            this.serialisationType = Type.forName(String.valueOf(sObjectType));
        }

        public Id generateId() {
            return this.idGen.generate();
        }

        public Id generateId(Integer seed) {
            return this.idGen.generate(seed);
        }

        public SObject create() {
            return this.create(new Map<String, Object>());
        }

        public SObject create(Map<String, Object> fieldValues) {
            return this.setProperties(this.sobjectType.newSObject(this.generateId()), fieldValues);
        }

        public List<SObject> create(List<Map<String, Object>> sobjectInputs) {
            List<SObject> mockRecords = new List<SObject>();
            for (Map<String, Object> input : (List<Map<String, Object>>) sobjectInputs) {
                mockRecords.add(this.create(input));
            }
            return mockRecords;
        }

        public SObject setProperty(SObject existingRecord, String fieldName, Object fieldValue) {
            return this.setProperties(existingRecord, new Map<String, Object>{ fieldName => fieldValue });
        }

        public SObject setProperties(SObject existingRecord, Map<String, Object> overrideFieldValues) {
            Map<String, Object> raw = new Map<String, Object>(existingRecord.getPopulatedFieldsAsMap());
            for (String field : overrideFieldValues.keySet()) {
                this.verifyPropertyName(field);
                SObjectProperty prop = this.makeProperty(field);
                raw.putAll(prop.parseInput(overrideFieldValues.get(field)));
            }
            String jsonString = JSON.serialize(raw);
            return (SObject) JSON.deserialize(jsonString, serialisationType);
        }

        private SObjectProperty makeProperty(String propName) {
            if (this.isChildRelationship(propName)) {
                return new SObjectChildProperty(propName, this.childRelationships.get(propName));
            }
            if (propName == 'RecordTypeId') {
                return new SObjectRecordTypeProperty(this.sobjectType.getDescribe());
            }
            Schema.DescribeFieldResult fieldDescribe = this.getFieldDescribeResult(propName);
            return new SObjectFieldProperty(propName, fieldDescribe);
        }

        private void verifyPropertyName(String propertyName) {
            if (this.getFieldToken(propertyName) == null && !this.childRelationships.containsKey(propertyName)) {
                throw new SObjectMockException(
                    String.format('Invalid property name for {0}: {1}', new List<Object>{ this.sobjectType, propertyName })
                );
            }
        }

        private Boolean isChildRelationship(String fieldName) {
            return this.childRelationships.containsKey(fieldName);
        }

        private Schema.DescribeFieldResult getFieldDescribeResult(String fieldName) {
            return this.getFieldToken(fieldName).getDescribe();
        }

        private Schema.SObjectField getFieldToken(String fieldName) {
            return this.describeResult.fields.getMap().get(fieldName);
        }
    }

    private abstract class SObjectProperty {
        private String name;

        private SObjectProperty(String propName) {
            this.name = propName;
        }

        public abstract Map<String, Object> parseInput(Object inputValue);
    }

    private class SObjectRecordTypeProperty extends SObjectProperty {
        Schema.DescribeSObjectResult sobjectDescribe;

        private SObjectRecordTypeProperty(Schema.DescribeSObjectResult sobjectDescribe) {
            super('RecordTypeId');
            this.sobjectDescribe = sobjectDescribe;
        }

        public override Map<String, Object> parseInput(Object inputValue) {
            this.validateInput(inputValue);
            return new Map<String, Object>{ this.name => this.getRecordTypeId((String) inputValue) };
        }

        private Id getRecordTypeId(String recordTypeName) {
            return this.sobjectDescribe.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        }

        private void validateInput(Object input) {
            if (!(input instanceof String)) {
                throw new SObjectMockException(
                    String.format('Error on {0}: Input is not a String value. Did you set an Id?', new List<Object>{ this.name })
                );
            }
            if (!this.sobjectDescribe.getRecordTypeInfosByDeveloperName().containsKey((String) input)) {
                throw new SObjectMockException(
                    String.format(
                        'Error on {0}: Input is not an existing record type on {1}. Use the developer name.',
                        new List<Object>{ this.name, this.sobjectDescribe.getName() }
                    )
                );
            }
        }
    }

    private class SObjectFieldProperty extends SObjectProperty {
        private Schema.DescribeFieldResult describeResult;

        private SObjectFieldProperty(String propName, Schema.DescribeFieldResult describeResult) {
            super(propName);
            this.describeResult = describeResult;
        }

        public override Map<String, Object> parseInput(Object inputValue) {
            this.validateInput(inputValue);
            return this.getFieldValue(inputValue);
        }

        private Map<String, Object> getFieldValue(Object inputValue) {
            switch on this.describeResult.getType() {
                when Reference {
                    if ((inputValue instanceof Id)) {
                        return new Map<String, Object>{ this.name => inputValue };
                    } else {
                        SObject parent = this.createParent(inputValue);
                        return new Map<String, Object>{ this.name => parent.Id, this.describeResult.getRelationshipName() => parent };
                    }
                }
                when else {
                    return new Map<String, Object>{ this.name => inputValue };
                }
            }
        }

        private void validateInput(Object inputValue) {
            switch on this.describeResult.getType() {
                when Reference {
                    this.validateForParentRelationship(inputValue);
                }
                when Address {
                    this.validateForAddress(inputValue);
                }
                when else {
                    this.validateForBasicField(inputValue);
                }
            }
        }

        private SObject createParent(Object parentInput) {
            Schema.SObjectType parentType = this.getParentSObjectType();
            SObjectMockFactory parentFactory = getSObjectMockFactory(parentType);
            if (parentInput instanceof SObject) {
                return parentFactory.create(((SObject) parentInput).getPopulatedFieldsAsMap());
            } else {
                return parentFactory.create((Map<String, Object>) parentInput);
            }
        }

        private Schema.SObjectType getParentSObjectType() {
            return this.describeResult.getReferenceTo()[0];
        }

        private void validateForAddress(Object input) {
            if (!(input instanceof Map<String, Object>)) {
                throw new SObjectMockException(
                    String.format(
                        'Error on {0}: Input is not of format {1}. Cannot serialize to: {2}',
                        new List<Object>{ this.describeResult.getName(), 'Map<String, Object>', 'System.Address' }
                    )
                );
            }
        }

        private void validateForBasicField(Object input) {
            if (input instanceof Map<String, Object>) {
                throw new SObjectMockException(
                    String.format(
                        'Error on {0}: Cannot serialize Map<String, Object> into {1}',
                        new List<Object>{ this.describeResult.getName(), this.describeResult.getType() }
                    )
                );
            }
        }

        private void validateForParentRelationship(Object input) {
            if (this.describeResult.getReferenceTo().isEmpty()) {
                throw new SObjectMockException(
                    String.format(
                        'Error on {1}: Is not a parent relationship. Did you use the field name?',
                        new List<Object>{ this.describeResult.getName() }
                    )
                );
            }
            if (!(input instanceof Map<String, Object>) && !(input instanceof SObject) && !(input instanceof Id)) {
                throw new SObjectMockException(
                    String.format(
                        'Error on {0}: Input is not of format {1}. Cannot serialize to {2}: {3}',
                        new List<Object>{
                            this.describeResult.getName(),
                            'Map<String, Object> or SObject or Id',
                            this.describeResult.getReferenceTo()[0],
                            input
                        }
                    )
                );
            }
        }
    }

    private class SObjectChildProperty extends SObjectProperty {
        private Schema.ChildRelationship childRelationshipDescribe;

        private SObjectChildProperty(String propName, Schema.ChildRelationship childRelationship) {
            super(propName);
            this.childRelationshipDescribe = childRelationship;
        }

        public override Map<String, Object> parseInput(Object inputValue) {
            this.validateInput(inputValue);
            List<Map<String, Object>> cleanedInput = this.cleanInput(inputValue);
            return new Map<String, Object>{ this.name => this.createChildRelationship(cleanedInput) };
        }

        private void validateInput(Object input) {
            if (!(input instanceof List<Object>)) {
                throw new SObjectMockException(
                    String.format(
                        'Error on {0}: Input is not of format {1}. Cannot serialize into: {2}',
                        new List<Object>{
                            this.childRelationshipDescribe.getRelationshipName(),
                            'List<Map<String, Object>> or List<SObject>',
                            this.childRelationshipDescribe.getChildSObject()
                        }
                    )
                );
            }
            if (input instanceof List<SObject>) {
                List<SObject> castedInput = (List<SObject>) input;
                if (castedInput.getSObjectType() != this.childRelationshipDescribe.getChildSObject()) {
                    throw new SObjectMockException(
                        String.format(
                            'Error on {0}: Input is List<{1}>, but expected List<{2}>.',
                            new List<Object>{
                                this.childRelationshipDescribe.getRelationshipName(),
                                castedInput.getSObjectType(),
                                this.childRelationshipDescribe.getChildSObject()
                            }
                        )
                    );
                }
            }
        }

        private SObjectChildRelationship createChildRelationship(List<Map<String, Object>> children) {
            Schema.SObjectType childType = this.getChildRelationshipType();
            SObjectMockFactory childFactory = TestMockFactory.getSObjectMockFactory(childType);
            List<SObject> childRecords = childFactory.create(children);
            return new SObjectChildRelationship(childRecords);
        }

        private List<Map<String, Object>> cleanInput(Object input) {
            if (input instanceof List<SObject>) {
                List<Map<String, Object>> cleanedInput = new List<Map<String, Object>>();
                for (SObject child : (List<SObject>) input) {
                    cleanedInput.add(child.getPopulatedFieldsAsMap());
                }
                return cleanedInput;
            }
            return (List<Map<String, Object>>) input;
        }

        private Schema.SObjectType getChildRelationshipType() {
            return this.childRelationshipDescribe.getChildSObject();
        }
    }

    private class SObjectChildRelationship {
        public Boolean done;
        public Integer totalSize;
        public List<SObject> records;

        public SObjectChildRelationship(List<SObject> childRecords) {
            this.done = true;
            this.records = childRecords;
            this.totalSize = childRecords.size();
        }
    }

    public class IdGenerator {
        private Integer recordCounter = 1;
        private Schema.SObjectType sobjectType;

        public IdGenerator(Schema.SObjectType sobjectType) {
            this.sobjectType = sobjectType;
        }

        public Id generate() {
            return this.generate(this.recordCounter++);
        }

        public Id generate(Integer seed) {
            return Id.valueOf(this.sobjectType.getDescribe().getKeyPrefix() + String.valueOf(seed).leftPad(12, '0'));
        }
    }

    public class SObjectMockException extends Exception {
    }
}
