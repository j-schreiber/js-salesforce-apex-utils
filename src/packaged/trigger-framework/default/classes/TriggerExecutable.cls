/**
 * Implement this interface in your feature implementation. The framework will
 * invoke every class that implements the interface and is registered with a
 * `TriggerFeatureControl__mdt`.
 *
 * @group Trigger Framework
 *
 * @example
 * public without sharing class MyTriggerExecutable implements TriggerExecutable {
 *  public static void execute(TriggerContext context) {
 *      // do awesome stuff on the context
 *  }
 * }
 */
public interface TriggerExecutable {
    /**
     * The framework automatically populates the `TriggerContext` with all
     * variables from `System.Trigger`.
     *
     * @param context
     */
    void execute(TriggerContext context);
}
