trigger onOpportunityLineItem on OpportunityLineItem(
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
) {
    Triggers.run(Schema.OpportunityLineItem.SObjectType);
}
