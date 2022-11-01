/**
 *
 *
 * @group Trigger Framework
 */
public class TriggerContext {
    public System.TriggerOperation operation;
    public Boolean isInsert;
    public Boolean isUpdate;
    public Boolean isDelete;
    public Boolean isUndelete;
    public Boolean isBefore;
    public Boolean isAfter;
    public Integer size;
    public Schema.SObjectType sObjectType;
    public Map<Id, SObject> newMap;
    public Map<Id, SObject> oldMap;
    public List<SObject> newList;
    public List<SObject> oldList;

    /**
     * Convenience getter for the primary record list. Always returns a non-null list.
     * Returns newList for insert, update and undelete operations. oldList for delete.
     *
     * @return  `List<SObject>`
     */
    public List<SObject> getPrimaryList() {
        if (this.isInsert || this.isUpdate || this.isUndelete) {
            return this.newList;
        } else {
            return this.oldList;
        }
    }

    /**
     * Convenience getter for record ids in this trigger context. Returns empty Set
     * in before insert context.
     *
     * @return  `Set<Id>`
     */
    public Set<Id> getRecordIds() {
        if (this.isInsert || this.isUpdate || this.isUndelete) {
            return this.newMap.keySet();
        } else {
            return this.oldMap.keySet();
        }
    }
}
