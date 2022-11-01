trigger onQuoteLineItem on QuoteLineItem(
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
) {
    Triggers.run(Schema.QuoteLineItem.SObjectType);
}
