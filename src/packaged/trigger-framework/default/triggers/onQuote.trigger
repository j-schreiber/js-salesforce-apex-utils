trigger onQuote on Quote(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    Triggers.run(Schema.Quote.SObjectType);
}
