trigger onCase on Case(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    Triggers.run(Schema.Case.SObjectType);
}
