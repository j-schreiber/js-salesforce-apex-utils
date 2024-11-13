public class SObjectTreeRecord {
    private Map<String, Object> prototype;
    private Map<String, Object> recordAttributes;
    private SObject record;
    private ExtendedDescribeSObjectResult sobjectDescribe;
    private SObjectTreeBranchOperation parentOperation;

    public SObjectTreeRecord(Map<String, Object> raw, SObjectTreeBranchOperation parentOperation) {
        this.prototype = raw;
        this.recordAttributes = (Map<String, Object>) this.prototype.get('attributes');
        this.prototype.remove('attributes');
        this.sobjectDescribe = parentOperation.getDescribe();
        this.parentOperation = parentOperation;
        this.record = this.sobjectDescribe.getToken().newSObject();
    }

    public SObjectTreeRecord(SObject templateRecord, SObjectTreeBranchOperation parentOperation) {
        this.sobjectDescribe = parentOperation.getDescribe();
        this.parentOperation = parentOperation;
        this.record = templateRecord;
    }

    //          PUBLIC API

    public void putValue(Schema.SObjectField fieldToken, Object fieldValue) {
        this.prototype.put(String.valueOf(fieldToken), fieldValue);
    }

    public String getReferenceKey() {
        return (String) this.recordAttributes.get('referenceId');
    }

    /**
     * SObject type of the tree record
     *
     * @return  `Schema.SObjectType`
     */
    public Schema.SObjectType getSObjectType() {
        String sObjectName = (String) this.recordAttributes?.get('type');
        if (String.isBlank(sObjectName)) {
            return null;
        } else {
            return ExtendedSchema.describeSObject(sObjectName).getToken();
        }
    }

    /**
     * Returns the raw key/value map from JSON input.
     *
     * @return  `Map<String, Object>`
     */
    public Map<String, Object> getPrototype() {
        return this.prototype;
    }

    /**
     * The fully initialised SObject record, after `resolve` was used.
     *
     * @return  `SObject`
     */
    public SObject getRecord() {
        return this.record;
    }

    /**
     * Resolves the prototype-map to an actual sobject record and caches the result.
     * This method resolves references ("@"-notation).
     *
     * @return  `SObject`
     */
    public SObject resolve() {
        return this.resolve(true);
    }

    /**
     * Resolves the prototype-map to an actual sobject record and caches the result.
     *
     * @param resolveReferences Specify, if references should be resolved.
     * @return  `SObject`
     */
    public SObject resolve(Boolean resolveReferences) {
        if (this.getPrototype() == null) {
            return this.record;
        }
        for (String fieldName : this.getPrototype().keySet()) {
            Schema.DescribeFieldResult fieldDescribe = this.sobjectDescribe.getField(fieldName).getDescribe();
            FieldResolver fr = loadResolver(fieldDescribe, resolveReferences);
            this.record.put(fieldName, fr.resolveFieldValue(this.getPrototype().get(fieldName)));
        }
        return this.record;
    }

    //          PRIVATE ZONE

    private FieldResolver loadResolver(Schema.DescribeFieldResult fieldDescribe, Boolean resolveFlag) {
        switch on fieldDescribe.getType() {
            when REFERENCE {
                if (fieldDescribe.getReferenceTo()[0] == Schema.RecordType.getSObjectType()) {
                    return new RecordTypeResolver(fieldDescribe, this);
                } else {
                    return new ParentLookupResolver(fieldDescribe, this, resolveFlag);
                }
            }
            when DATE, DATETIME {
                return new DateResolver(fieldDescribe, this);
            }
            when else {
                return new FieldResolver(fieldDescribe, this);
            }
        }
    }

    private virtual class FieldResolver {
        Schema.DescribeFieldResult fieldDescribe;
        SObjectTreeRecord record;

        public FieldResolver(Schema.DescribeFieldResult fieldDescribe, SObjectTreeRecord record) {
            this.fieldDescribe = fieldDescribe;
            this.record = record;
        }

        public virtual Object resolveFieldValue(Object inputValue) {
            return inputValue;
        }
    }

    private abstract class LookupFieldResolver extends FieldResolver {
        public LookupFieldResolver(Schema.DescribeFieldResult fieldDescribe, SObjectTreeRecord record) {
            super(fieldDescribe, record);
        }

        protected String extractReferenceValue(Object fieldValue) {
            if (!(fieldValue instanceof String)) {
                throw new SObjectTreeLoaderException(System.Label.References_To_Other_Records_Must_Be_String_Or_Id);
            }
            if (!((String) fieldValue).startsWith('@')) {
                throw new SObjectTreeLoaderException(
                    String.format(
                        System.Label.Invalid_Reference_SObject_Field_Misses_Identifier,
                        new List<Object>{ fieldValue, this.fieldDescribe.getName(), this.record.getReferenceKey() }
                    )
                );
            }
            return ((String) fieldValue).substringAfter('@');
        }
    }

    private class ParentLookupResolver extends LookupFieldResolver {
        Boolean resolveReferencesToRecords;

        public ParentLookupResolver(Schema.DescribeFieldResult fieldDescribe, SObjectTreeRecord record, Boolean resolveReferences) {
            super(fieldDescribe, record);
            this.resolveReferencesToRecords = resolveReferences;
        }

        public override Object resolveFieldValue(Object inputValue) {
            if (inputValue instanceof Id) {
                return (Id) inputValue;
            } else {
                if (!this.resolveReferencesToRecords) {
                    return null;
                }
                String prototypeRefId = this.extractReferenceValue(inputValue);
                return this.resolveParentRecordId(prototypeRefId);
            }
        }

        private Id resolveParentRecordId(String referenceId) {
            Schema.SObjectType targetType = this.fieldDescribe.getReferenceTo()[0];
            SObjectTreeRecord parentRecord = this.record.parentOperation.getSObjectTreeLoader()
                .getRecordsBySObjectType(targetType)
                .get(referenceId);
            if (parentRecord == null) {
                throw new SObjectTreeLoaderException(
                    String.format(
                        System.Label.Unknown_Reference_Value_Check_Source_Files,
                        new List<Object>{ referenceId, this.fieldDescribe.getName(), this.record.getReferenceKey(), targetType }
                    )
                );
            }
            if (parentRecord.getRecord().Id == null) {
                throw new SObjectTreeLoaderException(
                    String.format(
                        System.Label.Tried_To_Resolve_Reference_To_Non_Inserted_Record,
                        new List<Object>{ referenceId, this.record.getReferenceKey() }
                    )
                );
            }
            return parentRecord.getRecord().Id;
        }
    }

    private class RecordTypeResolver extends LookupFieldResolver {
        public RecordTypeResolver(Schema.DescribeFieldResult fieldDescribe, SObjectTreeRecord record) {
            super(fieldDescribe, record);
        }

        public override Object resolveFieldValue(Object inputValue) {
            String recordTypeDeveloperName = this.extractReferenceValue(inputValue);
            return resolveRecordTypeId(recordTypeDeveloperName);
        }

        private Id resolveRecordTypeId(String recordTypeName) {
            Map<String, RecordTypeInfo> infos = this.record.sobjectDescribe.getResult().getRecordTypeInfosByDeveloperName();
            if (infos.containsKey(recordTypeName)) {
                return infos.get(recordTypeName).getRecordTypeId();
            } else {
                throw new SObjectTreeLoaderException(
                    String.format(
                        System.Label.Specified_Record_Type_Is_Invalid_For_SObject,
                        new List<Object>{ recordTypeName, this.record.sobjectDescribe.getToken() }
                    )
                );
            }
        }
    }

    private class DateResolver extends FieldResolver {
        private Pattern isoDateFormat = Pattern.compile('^\\d{4}-\\d{2}-\\d{2}$');
        private Pattern formulaFormat = Pattern.compile('^(TODAY){1}(:(ADD_DAYS|ADD_YEARS|ADD_MONTHS):(-)?\\d{1,3})?$');

        public DateResolver(Schema.DescribeFieldResult fieldDescribe, SObjectTreeRecord record) {
            super(fieldDescribe, record);
        }

        public override Object resolveFieldValue(Object inputValue) {
            if (inputValue instanceof Date) {
                return (Date) inputValue;
            }
            if (!(inputValue instanceof String)) {
                throw new SObjectTreeLoaderException('Date must be set as STRING or FORMULA.');
            }
            return this.parseDateInput((String) inputValue);
        }

        private Date parseDateInput(String dateAsString) {
            if (formulaFormat.matcher(dateAsString).matches()) {
                return this.resolveDateFormula(dateAsString);
            } else if (isoDateFormat.matcher(dateAsString).matches()) {
                return Date.valueOf(dateAsString);
            } else {
                throw new SObjectTreeLoaderException(
                    String.format(
                        System.Label.Date_Or_Formula_Does_Not_Match_RegEx,
                        new List<Object>{ formulaFormat.pattern(), dateAsString }
                    )
                );
            }
        }

        private Date resolveDateFormula(String formulaInput) {
            List<String> formula = formulaInput.split(':');
            if (formula.size() == 3) {
                Integer formulaParam = Integer.valueOf(formula[2]);
                String formulaAlgorithm = formula[1];
                switch on formulaAlgorithm {
                    when 'ADD_DAYS' {
                        return DateUtils.today().addDays(formulaParam);
                    }
                    when 'ADD_MONTHS' {
                        return DateUtils.today().addMonths(formulaParam);
                    }
                    when 'ADD_YEARS' {
                        return DateUtils.today().addYears(formulaParam);
                    }
                    when else {
                        throw new SObjectTreeLoaderException(
                            'Reached statement that was supposed to be unreachable. Good job at breaking things ;).'
                        );
                    }
                }
            } else {
                return DateUtils.today();
            }
        }
    }
}
