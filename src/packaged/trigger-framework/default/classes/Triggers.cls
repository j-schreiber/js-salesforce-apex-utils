/**
 * Provides a trigger framework that can be used to implement the single trigger per object best practice.
 * Implements various controls to enable/disable execution during contexts.
 *
 * @author Jannis Schreiber
 * @group Trigger Framework
 */
public class Triggers {
    private static Boolean isDisabled = false;
    private static Set<Schema.SObjectType> disabledSObjects = new Set<Schema.SObjectType>();
    private static Set<String> disabledFeatures = new Set<String>();
    private static Set<String> disabledExecutables = new Set<String>();
    private static Set<String> forceEnabledFeatures = new Set<String>();
    private static Map<Schema.SObjectType, List<FeatureControl>> cachedControls = new Map<Schema.SObjectType, List<FeatureControl>>();

    /**
     * Disables all trigger features, until enabled again. This fully prevents the
     * execution of any handler and supersedes all other control APIs.
     */
    public static void disableAll() {
        isDisabled = true;
    }

    /**
     * Enables all trigger features. Only effective, if `disableAll` was called previously,
     * sobjects or individual features were disabled.
     */
    public static void enableAll() {
        isDisabled = false;
        disabledSObjects.clear();
        disabledFeatures.clear();
    }

    /**
     * Disables processing of trigger features for a certain sobject type. This prevents the
     * execution of handlers for a particular SObject, from all contexts.
     *
     * @param sobjectType
     */
    public static void disableSObject(Schema.SObjectType sobjectType) {
        if (sobjectType == null) {
            throw ApexUtilsExceptions.makeNewInputCannotBeNull('SObjectType');
        }
        disabledSObjects.add(sobjectType);
    }

    /**
     * Disables processing of trigger features for a list of sobject types.
     *
     * @param sObjectTypes
     */
    public static void disableSObjects(List<Schema.SObjectType> sobjectTypes) {
        for (Schema.SObjectType sobj : sobjectTypes) {
            disableSobject(sobj);
        }
    }

    /**
     * Enables processing of trigger features for a certain sobject type.
     * If the sobject wasn't disabled, this has no effect.
     *
     * @param sobjectType
     */
    public static void enableSObject(Schema.SObjectType sobjectType) {
        if (sobjectType == null) {
            throw ApexUtilsExceptions.makeNewInputCannotBeNull('SObjectType');
        }
        disabledSObjects.remove(sobjectType);
    }

    /**
     * Disables a trigger feature control by it's developer name. Has no effect,
     * if the feature control does not exist.
     * Is evaluated before `forceActivateFeature`. Disabled features are never executed.
     *
     * @param featureControlDeveloperName
     */
    public static void disableFeature(String featureControlDeveloperName) {
        if (String.isBlank(featureControlDeveloperName)) {
            throw ApexUtilsExceptions.makeNewInputCannotBeNull('Name');
        }
        disabledFeatures.add(featureControlDeveloperName);
    }

    /**
     * Disables a TriggerExecutable by class type. If the class type is not
     * registered or does not implement the TriggerExecutable interface, calling
     * this method has no effect.
     *
     * @param executable
     */
    public static void disableFeature(System.Type executable) {
        if (executable == null) {
            throw ApexUtilsExceptions.makeNewInputCannotBeNull('executable');
        }
        disabledExecutables.add(String.valueOf(executable));
    }

    /**
     * Disables a list of trigger feature controls by it's developer name. Has no effect,
     * if the feature controls do not exist.
     * Is evaluated before `forceActivateFeature`. Disabled features are never executed.
     *
     * @param featureControlDeveloperName
     */
    public static void disableFeatures(List<String> featureNames) {
        for (String feature : featureNames) {
            disableFeature(feature);
        }
    }

    /**
     * Enables a trigger feature control by it's developer name. Has no
     * effect, if the feature control wasn't disabled.
     *
     * @param featureControlDeveloperName
     */
    public static void enableFeature(String featureControlDeveloperName) {
        if (String.isBlank(featureControlDeveloperName)) {
            throw ApexUtilsExceptions.makeNewInputCannotBeNull('Name');
        }
        disabledFeatures.remove(featureControlDeveloperName);
    }

    /**
     * Enables a `TriggerExecutable` by its system type. Has no effect,
     * if the class does not implement the interface or was not disabled.
     *
     * @param executable
     */
    public static void enableFeature(System.Type executable) {
        if (executable == null) {
            throw ApexUtilsExceptions.makeNewInputCannotBeNull('executable');
        }
        disabledExecutables.remove(String.valueOf(executable));
    }

    /**
     * Ignores the "is active" control and runs a feature during execution.
     * Useful for testing context, where controls are deployed as inactive.
     * Is evaluated after `disableAll` and `disableSObject`
     *
     * @param featureControlDeveloperName
     *
     * @example
     * Triggers.forceActivateFeature('My_Custom_Metadata_Record_Name');
     */
    public static void forceActivateFeature(String featureControlDeveloperName) {
        if (String.isBlank(featureControlDeveloperName)) {
            throw ApexUtilsExceptions.makeNewInputCannotBeNull('Name');
        }
        forceEnabledFeatures.add(featureControlDeveloperName);
    }

    /**
     * Main entry point that starts a context with the passed-in sobject type
     * and all trigger context variables. Call this method from triggers on custom
     * objects. Enable the trigger for all contexts.
     *
     * @param sObjectType
     *
     * @example
     * Triggers.run(Schema.MyCustomObject__c.SObjectType);
     */
    public static void run(Schema.SObjectType sObjectType) {
        if (isDisabled || disabledSObjects.contains(sObjectType)) {
            return;
        }
        TriggerContext context = new TriggerContext();
        context.sObjectType = sObjectType;
        context.newList = Trigger.new;
        context.oldList = Trigger.old;
        context.newMap = Trigger.newMap;
        context.oldMap = Trigger.oldMap;
        context.operation = Trigger.operationType;
        context.isInsert = Trigger.isInsert;
        context.isUpdate = Trigger.isUpdate;
        context.isDelete = Trigger.isDelete;
        context.isUndelete = Trigger.isUndelete;
        context.isBefore = Trigger.isBefore;
        context.isAfter = Trigger.isAfter;
        context.size = Trigger.size;
        executeFeatures(context);
    }

    /**                                 PRIVATE ZONE                                 */

    private static void executeFeatures(TriggerContext context) {
        for (FeatureControl control : getControls(context.sObjectType)) {
            if (!control.isApplicable(context.operation)) {
                continue;
            }
            if (disabledExecutables.contains(control.getConfig().Handler__c)) {
                continue;
            }
            if (disabledFeatures.contains(control.getName())) {
                continue;
            }
            if (control.isActive() || forceEnabledFeatures.contains(control.getConfig().DeveloperName)) {
                control.getHandler().execute(context);
            }
        }
    }

    private static List<FeatureControl> getControls(Schema.SObjectType sObjectType) {
        if (!cachedControls.containsKey(sObjectType)) {
            cachedControls.put(sObjectType, new List<FeatureControl>());
            for (TriggerFeatureControl__mdt config : TriggerControlsRepository.getControls(String.valueOf(sObjectType))) {
                cachedControls.get(sObjectType).add(new FeatureControl(config));
            }
        }
        return cachedControls.get(sObjectType);
    }

    private class FeatureControl {
        TriggerFeatureControl__mdt config;
        TriggerExecutable handler;

        private FeatureControl(TriggerFeatureControl__mdt config) {
            this.config = config;
        }

        private TriggerFeatureControl__mdt getConfig() {
            return this.config;
        }

        private TriggerExecutable getHandler() {
            if (this.handler == null) {
                this.handler = (TriggerExecutable) ApexTypeUtils.initializeInstanceFromName(
                    this.getConfig().Handler__c,
                    TriggerExecutable.class
                );
            }
            return this.handler;
        }

        private String getName() {
            return this.getConfig().DeveloperName;
        }

        private Boolean isActive() {
            return this.getConfig().IsActive__c;
        }

        private Boolean isApplicable(System.TriggerOperation operation) {
            if (operation == System.TriggerOperation.BEFORE_INSERT && this.getConfig().RunOnBeforeInsert__c) {
                return true;
            }
            if (operation == System.TriggerOperation.AFTER_INSERT && this.getConfig().RunOnAfterInsert__c) {
                return true;
            }
            if (operation == System.TriggerOperation.BEFORE_UPDATE && this.getConfig().RunOnBeforeUpdate__c) {
                return true;
            }
            if (operation == System.TriggerOperation.AFTER_UPDATE && this.getConfig().RunOnAfterUpdate__c) {
                return true;
            }
            if (operation == System.TriggerOperation.BEFORE_DELETE && this.getConfig().RunOnBeforeDelete__c) {
                return true;
            }
            if (operation == System.TriggerOperation.AFTER_DELETE && this.getConfig().RunOnAfterDelete__c) {
                return true;
            }
            if (operation == System.TriggerOperation.AFTER_UNDELETE && this.getConfig().RunOnAfterUndelete__c) {
                return true;
            }
            return false;
        }
    }
}
