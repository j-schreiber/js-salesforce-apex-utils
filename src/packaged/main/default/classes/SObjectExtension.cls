/**
 * This class is designed to be used similar to the base `SObject` class. You
 * typically treat it similar to a record. Most methods act on the record that
 * is used to construct this instance.
 */
public class SObjectExtension {
    /**
     * Additional options for merging records
     */
    public class MergeOptions {
        /**
         * Ignore fields for merging, if the values are empty or blank on the secondary record.
         * Default is false.
         */
        public Boolean onlyMergeNonEmptyFields = false;

        /**
         * Exclude specific fields from merging. Names are case-insensitive.
         * By default, no fields are ignored.
         */
        public Set<String> ignoreFields = new Set<String>();

        /**
         * Override fields that are populated with non-empty values on primary record.
         * Default is true.
         */
        public Boolean overrideOnConflict = true;
    }

    private ExtendedDescribeSObjectResult describeResult {
        get {
            if (this.describeResult == null) {
                this.describeResult = ExtendedSchema.describeSObject(this.record.getSObjectType());
            }
            return this.describeResult;
        }
        set;
    }
    private SObject record {
        get;
        set {
            if (value == null) {
                throw new IllegalArgumentException('Record cannot be null!');
            }
            this.record = value;
        }
    }

    /**
     * Construct a new instance with a record.
     *
     * @param record
     */
    public SObjectExtension(SObject record) {
        this.record = record;
    }

    //              STATIC API

    /**
     * Shorthand to merge two sobject records. Merges the second record into
     * the first record. Fields from first record are overwritten with values
     * from the second records.
     *
     * @param primary
     * @param secondary
     * @return  `SObject`
     */
    public static SObject mergeRecords(SObject primary, SObject secondary) {
        return new SObjectExtension(primary).mergeWith(secondary);
    }

    /**
     * Shorthand to merge two sobject records. Allows to specify options.
     *
     * @param primary
     * @param secondary
     * @param options
     * @return  `SObject`
     */
    public static SObject mergeRecords(SObject primary, SObject secondary, MergeOptions options) {
        return new SObjectExtension(primary).mergeWith(secondary, options);
    }

    //              INSTANCE API

    /**
     * Merges the primary record of this instance with the input value.
     *
     * @param secondary
     * @return  `SObject`
     * @exception
     */
    public SObject mergeWith(SObject secondary) {
        return this.mergeWith(secondary, new MergeOptions());
    }

    /**
     * Merges the primary record of this instance with the input value and
     * specify additional options.
     *
     * @param secondary
     * @param options
     * @return  `SObject`
     * @exception
     */
    public SObject mergeWith(SObject secondary, MergeOptions options) {
        if (this.record.getSObjectType() != secondary.getSObjectType()) {
            throw new IllegalArgumentException(
                String.format(
                    System.Label.Source_Record_SObject_Type_Does_Not_Match,
                    new List<Object>{ this.record.getSObjectType(), secondary.getSObjectType() }
                )
            );
        }
        Set<String> ignoreFields = this.sanitizeIgnoreFieldOptions(options.ignoreFields);
        for (String fieldName : secondary.getPopulatedFieldsAsMap().keySet()) {
            if (ignoreFields.contains(fieldName.toLowerCase())) {
                continue;
            }
            if (secondary.getPopulatedFieldsAsMap().get(fieldName) == null && options.onlyMergeNonEmptyFields) {
                continue;
            }
            if (this.describeResult.hasField(fieldName) && !this.describeResult.isSystemReadOnly(fieldName)) {
                this.parseFieldType(fieldName);
                this.record.put(fieldName, secondary.get(fieldName));
            }
            if (this.describeResult.hasParentRelationship(fieldName)) {
                SObject primaryParent = this.record.getSObject(fieldName);
                SObject secondaryParent = secondary.getSObject(fieldName);
                this.record.putSObject(fieldName, primaryParent == null ? secondaryParent : mergeRecords(primaryParent, secondaryParent));
            }
        }
        return this.record;
    }

    //                  PRIVATE ZONE

    private Set<String> sanitizeIgnoreFieldOptions(Set<String> inputFields) {
        Set<String> output = new Set<String>();
        if (inputFields == null) {
            return output;
        }
        for (String input : inputFields) {
            output.add(input.toLowerCase());
        }
        return output;
    }

    private void parseFieldType(String fieldName) {
        Schema.DescribeFieldResult fieldDescribe = this.describeResult.getField(fieldName).getDescribe();
        if (this.fieldTypeNotSupported(fieldDescribe)) {
            throw new IllegalArgumentException(
                String.format(
                    'Field type {0} for {1} not supported!',
                    new List<Object>{ String.valueOf(fieldDescribe.getType()).toUpperCase(), fieldName }
                )
            );
        }
    }

    private Boolean fieldTypeNotSupported(Schema.DescribeFieldResult fieldDescribe) {
        switch on fieldDescribe.getType() {
            when Address, MultiPicklist, Location, Id, EncryptedString, base64 {
                return true;
            }
            when else {
                return false;
            }
        }
    }
}
