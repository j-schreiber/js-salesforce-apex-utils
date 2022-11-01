trigger onOrder on Order(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    Triggers.run(Schema.Order.SObjectType);
}
