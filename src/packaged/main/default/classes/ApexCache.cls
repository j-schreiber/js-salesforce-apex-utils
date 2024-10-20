public without sharing class ApexCache {
    public static Map<String, StaticResource> JsonStaticResources {
        get {
            if (JsonStaticResources == null) {
                JsonStaticResources = new Map<String, StaticResource>();
                for (StaticResource sr : [SELECT Id, Body, Name FROM StaticResource WHERE ContentType = 'application/json']) {
                    JsonStaticResources.put(sr.Name, sr);
                }
            }
            return JsonStaticResources;
        }
        private set;
    }
}
