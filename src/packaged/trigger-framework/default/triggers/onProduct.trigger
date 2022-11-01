trigger onProduct on Product2(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    Triggers.run(Schema.Product2.SObjectType);
}
