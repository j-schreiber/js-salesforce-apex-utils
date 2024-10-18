/**
 * An extension of the platform `DescribeSObjectResult` that augments it for more utility methods.
 * This is a workaround for the limitations of the platform.
 *
 * @group SObject Utilities
 */
global class ExtendedDescribeSObjectResult {
    private Schema.DescribeSObjectResult describeResult;
    private Schema.SObjectType sObjectToken;
    private Map<String, Schema.DescribeFieldResult> parentRelationships;
    private Map<String, Schema.ChildRelationship> childRelationships;
    Map<String, Schema.SObjectField> customFields;
    Map<String, Schema.SObjectField> editableFields;

    public ExtendedDescribeSObjectResult(Schema.SObjectType sobjectToken) {
        this.sobjectToken = sobjectToken;
        this.describeResult = sobjectToken.getDescribe();
    }

    public ExtendedDescribeSObjectResult(Schema.DescribeSObjectResult describeResult) {
        this.describeResult = describeResult;
        this.sobjectToken = describeResult.getSObjectType();
    }

    public ExtendedDescribeSObjectResult(String sObjectApiName) {
        this(Schema.describeSObjects(new List<String>{ sObjectApiName })[0]);
    }

    /**
     * Returns the standard platform describe result
     *
     * @return  `Schema.DescribeSObjectResult`
     */
    global Schema.DescribeSObjectResult getResult() {
        return this.describeResult;
    }

    /**
     * Returns the original sobject token
     *
     * @return  `Schema.SObjectType`
     */
    global Schema.SObjectType getToken() {
        return this.sObjectToken;
    }

    /**
     * Convenience accessor for all fields by developer name
     *
     * @return  `Map<String, Schema.SObjectField>`
     */
    global Map<String, Schema.SObjectField> getFields() {
        return this.getResult().fields.getMap();
    }

    /**
     * Builds a map of all editable fields. Keys are not special `fields` property
     * and are case sensitive.
     *
     * @return  `Map<String, Schema.SObjectField>`
     */
    global Map<String, Schema.SObjectField> getEditableFields() {
        if (this.editableFields == null) {
            this.editableFields = new Map<String, Schema.SObjectField>();
            for (Schema.SObjectField fieldToken : this.getFields().values()) {
                if (ExtendedDescribeSObjectResult.isEditable(fieldToken.getDescribe())) {
                    this.editableFields.put(String.valueOf(fieldToken), fieldToken);
                }
            }
        }
        return this.editableFields;
    }

    /**
     * Builds a map of all custom fields. Keys are not special `fields` property
     * and are case sensitive.
     *
     * @return  `Map<String, Schema.SObjectField>`
     */
    global Map<String, Schema.SObjectField> getCustomFields() {
        if (this.customFields == null) {
            this.customFields = new Map<String, Schema.SObjectField>();
            for (Schema.SObjectField fieldToken : this.getFields().values()) {
                if (fieldToken.getDescribe().isCustom()) {
                    this.customFields.put(String.valueOf(fieldToken), fieldToken);
                }
            }
        }
        return this.customFields;
    }

    /**
     * Validates, if the sobject has a field
     *
     * @return  `Boolean`
     */
    global Boolean hasField(String fieldName) {
        return this.getFields().containsKey(fieldName);
    }

    /**
     * Convenience accessor for all field sets by developer name
     *
     * @return  `Map<String, Schema.FieldSet>`
     */
    global Map<String, Schema.FieldSet> getFieldSets() {
        return this.getResult().fieldsets.getMap();
    }

    /**
     * Returns the correct field token for a given field developer name
     *
     * @param fieldName
     * @return  `Schema.SObjectField`
     * @exception
     */
    global Schema.SObjectField getField(String fieldName) {
        if (!this.hasField(fieldName)) {
            throw new IllegalArgumentException(
                String.format(System.Label.Is_Not_A_Valid_Field, new List<Object>{ fieldName, this.getToken() })
            );
        }
        return this.getFields().get(fieldName);
    }

    /**
     * Returns the field set for a given field-set developer name
     *
     * @param fieldName
     * @return  `Schema.SObjectField`
     * @exception
     */
    global Schema.FieldSet getFieldSet(String fieldSetName) {
        if (!this.getFieldSets().containsKey(fieldSetName)) {
            throw new IllegalArgumentException(
                String.format(System.Label.Is_Not_A_Valid_Field_Set, new List<Object>{ fieldSetName, this.getToken() })
            );
        }
        return this.getFieldSets().get(fieldSetName);
    }

    /**
     * Returns all fields that reference to a parent object (lookup fields) as map by their
     * field developer names.
     *
     * @return  `Map<String, Schema.DescribeFieldResult>`
     */
    global Map<String, Schema.DescribeFieldResult> getParentRelationshipsAsMap() {
        if (this.parentRelationships == null) {
            this.parentRelationships = new Map<String, Schema.DescribeFieldResult>();
            for (Schema.SObjectField field : this.getFields().values()) {
                Schema.DescribeFieldResult describeResult = field.getDescribe();
                if (String.isNotBlank(describeResult.getRelationshipName())) {
                    this.parentRelationships.put(describeResult.getRelationshipName().toLowerCase(), describeResult);
                }
            }
        }
        return this.parentRelationships;
    }

    /**
     * Returns all child relationships as map by their child relationship developer name (as seen
     * from the parent).
     *
     * @return  `Map<String, Schema.SObjectField>`
     */
    global Map<String, Schema.ChildRelationship> getChildRelationshipsAsMap() {
        if (this.childRelationships == null) {
            this.childRelationships = new Map<String, Schema.ChildRelationship>();
            List<Schema.ChildRelationship> crs = this.getResult().getChildRelationships();
            for (Schema.ChildRelationship childRelationship : crs) {
                if (String.isNotBlank(childRelationship.getRelationshipName())) {
                    this.childRelationships.put(childRelationship.getRelationshipName().toLowerCase(), childRelationship);
                }
            }
        }
        return this.childRelationships;
    }

    /**
     *
     *
     * @param relationshipName
     * @return  `Schema.ChildRelationship`
     * @exception
     */
    global Schema.ChildRelationship getChildRelationship(String relationshipName) {
        String lowerCaseName = relationshipName.toLowerCase();
        if (!this.getChildRelationshipsAsMap().containsKey(lowerCaseName)) {
            throw new IllegalArgumentException(
                String.format(System.Label.Is_Not_A_Valid_Child_Relationship, new List<Object>{ relationshipName, this.getToken() })
            );
        }
        return this.getChildRelationshipsAsMap().get(lowerCaseName);
    }

    /**
     *
     *
     * @param relationshipName
     * @return  `Schema.DescribeFieldResult`
     * @exception
     */
    global Schema.DescribeFieldResult getParentRelationship(String relationshipName) {
        Schema.SObjectField fieldToken = this.getFieldTokenForRelationshipField(relationshipName);
        if (String.isBlank(fieldToken.getDescribe().getRelationshipName())) {
            throw new IllegalArgumentException(
                String.format(System.Label.Is_Not_A_Valid_Parent_Relationship, new List<Object>{ relationshipName, this.getToken() })
            );
        }
        return fieldToken.getDescribe();
    }

    /**
     * Resolves a field query literal to a list of sobject fields. For plain fields
     * returns a list of one field token.
     *
     * @param fieldLiteral
     * @return  `List<Schema.SObjectField>`
     */
    global List<Schema.SObjectField> resolveFieldLiteral(String fieldLiteral) {
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
        if (fieldLiteral.substringBefore('.') == fieldLiteral) {
            fieldList.add(this.getField(fieldLiteral));
        } else {
            Schema.DescribeFieldResult parentField = this.getParentRelationship(fieldLiteral.substringBefore('.'));
            fieldList.add(parentField.getSObjectField());
            ExtendedDescribeSObjectResult parentDescribe = ExtendedSchema.describeSObject(parentField.getReferenceTo()[0]);
            fieldList.addAll(parentDescribe.resolveFieldLiteral(fieldLiteral.substringAfter('.')));
        }
        return fieldList;
    }

    //                          PRIVATE ZONE

    private static Boolean isEditable(Schema.DescribeFieldResult fieldDescribe) {
        return fieldDescribe.isCreateable() && fieldDescribe.isAccessible() && fieldDescribe.isUpdateable();
    }

    private Schema.SObjectField getFieldTokenForRelationshipField(String fieldName) {
        if (fieldName.contains('__r')) {
            return this.getField(fieldName.replace('__r', '__c'));
        } else {
            return this.getField(fieldName + 'Id');
        }
    }
}
