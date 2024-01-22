global with sharing class CloneOrchestrationScenario{

    public class ScenarioJSONWrapper {
        public String productId ;
        public String scenarioId;
        public String scenarioNewName;
    }

    // @InvocableMethod(label='Clone Orchestration Scenario' description='Clone Orchestration Scenario with new name and update child records')
    @AuraEnabled()
    global static Map<String, Object> invokeMethod(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        
        if (input.get('methodName') == 'cloneScenarioWithNewName') {
            
            System.debug('methodName - > ' + input.get('methodName'));
            System.debug('scenariosMap - > ' + input.get('scenariosMap'));
            // example scenarios map:
            // scenariosMap - > ({productId=01tAd000000rZ1JIAU, scenarioId=a3TAd000000550fMAA, scenarioNewName=TEST Active Products E2E Change Link Type}, {productId=01t3H000003lUIpQAM, scenarioId=a3TAd000000552HMAQ, scenarioNewName=TEST  Product Globill CFS Change Link Type}, {productId=01tAd000000rZ1IIAU, scenarioId=a3TAd000000553tMAA, scenarioNewName=TEST  Active Product SDM CFS Change Link Type})
            List<ScenarioJSONWrapper> scenariosMap = (List<ScenarioJSONWrapper>) JSON.deserialize((String)input.get('scenariosMap'), List<ScenarioJSONWrapper>.class);
            System.debug('deserialized scenariosMap - > ' + scenariosMap);
            // List<Map<String, Object>> scenariosMap = (List<Map<String, Object>>) input.get('scenariosMap');
            // return true;
            Boolean resultMethod = cloneScenarioWithNewName(scenariosMap);
        }
        if (input.get('methodName') == 'getScenarios') {
            System.debug('methodName - > ' + input.get('methodName'));
            System.debug('recordId - > ' + input.get('recordId'));
            
            Id recordId =  (Id)input.get('recordId');
            vlocity_cmt__OrchestrationScenario__c scenario = [ SELECT Id, vlocity_cmt__OrchestrationPlanDefinitionId__c FROM vlocity_cmt__OrchestrationScenario__c WHERE Id =: recordId LIMIT 1 ];
            System.debug('vlocity_cmt__OrchestrationPlanDefinitionId__c - > ' + scenario.vlocity_cmt__OrchestrationPlanDefinitionId__c);
            
            List<Id> plansIds = getAllPlanDeifinitions(scenario.vlocity_cmt__OrchestrationPlanDefinitionId__c);
            System.debug('plansId - > ' + plansIds);

            Map<Id, String> scenariosMap = new Map<Id, String>{};
            List <Map<String,String>> listMap = new List<Map<String,String>>();
            scenariosMap = getScenariosMap(plansIds);

            for (String key : scenariosMap.keySet()) {
                Map<String,String> temp = new Map<String,String>();
                temp.put('Id', key);
                temp.put('Name', scenariosMap.get(key));
                listMap.add(temp);
                
            }
            

            output.put('scenariosMap', listMap);
        }

        return output;
    }

    public static Boolean cloneScenarioWithNewName(List<ScenarioJSONWrapper> dataList) {
        // List<Id> newScenarioIds = new List<Id>();
        
        // List<Id> receivedScenariosIds = new List<Id>();
        // for (Map<String, String> item : dataList) {
        //     if (item.containsKey('scenarioId') && item.get('scenarioId') != null) {
        //         receivedScenariosIds.add((Id)item.get('scenarioId'));
        //     }
        // }
        

        // // Pobierz istniejący rekord vlocity_cmt__OrchestrationScenario__c
        // // List<String> fieldsScenario = getUpdateableFields(vlocity_cmt__OrchestrationScenario__c.SObjectType);
        // String soqlScenario = ''
        //         + ' SELECT Id, vlocity_cmt__OrchestrationPlanDefinitionId__c'
        //         + ' FROM vlocity_cmt__OrchestrationScenario__c'
        //         + ' WHERE Id IN :receivedScenariosIds';

        // List<vlocity_cmt__OrchestrationPlanDefinition__c> existingScenariosList = Database.query(soqlScenario);
        

        // List<Id> existingScenarios_PlanDefinitionIds = new List<Id>();
        // for (vlocity_cmt__OrchestrationPlanDefinition__c s : existingScenariosList) {
        //    existingScenarios_PlanDefinitionIds.add(s.vlocity_cmt__OrchestrationPlanDefinitionId__c);
        // }

        // // List<String> fieldsPlan = getUpdateableFields(vlocity_cmt__OrchestrationPlanDefinition__c.SObjectType);
        // String soqlPlan = ''
        //         + ' SELECT Id'
        //         + ' FROM vlocity_cmt__OrchestrationPlanDefinition__c'
        //         + ' WHERE Id IN :existingScenarios_PlanDefinitionIds';
        // System.debug('query soqlPlan');
        // System.debug(Database.query(soqlPlan));
        // List<vlocity_cmt__OrchestrationPlanDefinition__c> existingPlanList = Database.query(soqlPlan);
        
        // =====================
        Map<String, String> scenariosNewNameMap = new Map<String, String>();
        Map<String, String> scenariosNewProductMap = new Map<String, String>();
        
        List<Id> receivedScenariosIds = new List<Id>();
        // {productId=01tAd000000rZ1JIAU, scenarioId=a3TAd000000550fMAA, scenarioNewName=TEST}
        for (ScenarioJSONWrapper item : dataList) {
            // if (item.containsKey('scenarioId') && item.get('scenarioId') != null) {
            receivedScenariosIds.add((Id)item.scenarioId);
            scenariosNewNameMap.put((String)item.scenarioId, (String)item.scenarioNewName);
            scenariosNewProductMap.put((String)item.scenarioId,(String)item.productId);
            // }
        }

        // Retrieve existing vlocity_cmt__OrchestrationScenario__c records
        List<vlocity_cmt__OrchestrationScenario__c> existingScenariosList = [
            SELECT Id, vlocity_cmt__OrchestrationPlanDefinitionId__c
            FROM vlocity_cmt__OrchestrationScenario__c
            WHERE Id IN :receivedScenariosIds
        ];
        Map<String, String> plansRelatedToScenarios = new Map<String, String>();

        List<Id> existingScenarios_PlanDefinitionIds = new List<Id>();
        List<Id> queryScenariosIds = new List<Id>();
        for (vlocity_cmt__OrchestrationScenario__c s : existingScenariosList) {
            existingScenarios_PlanDefinitionIds.add(s.vlocity_cmt__OrchestrationPlanDefinitionId__c);
            queryScenariosIds.add(s.Id);
            plansRelatedToScenarios.put((String)s.vlocity_cmt__OrchestrationPlanDefinitionId__c, (String)s.Id);
        }

        // Retrieve existing vlocity_cmt__OrchestrationPlanDefinition__c records
        List<vlocity_cmt__OrchestrationPlanDefinition__c> existingPlanList = [
            SELECT Id
            FROM vlocity_cmt__OrchestrationPlanDefinition__c
            WHERE Id IN :existingScenarios_PlanDefinitionIds
        ];

        Map<String, String> plansNewNameMap = new Map<String, String>();

        List<Id> queryPlansIds = new List<Id>();
        for (vlocity_cmt__OrchestrationPlanDefinition__c p : existingPlanList) {
            queryPlansIds.add(p.Id);
            
            String tempScnearioId = plansRelatedToScenarios.get(p.Id);
            plansNewNameMap.put((String)p.Id, scenariosNewNameMap.get(tempScnearioId));
        }

        Map<Id,Id> plansParentId = clonePlanDefinitions(queryPlansIds, plansNewNameMap);

        Map<Id,Id> scenariosParentId = cloneScenarios(queryScenariosIds, scenariosNewNameMap, scenariosNewProductMap, plansParentId);

        // =====================

        Map<String,String> newOrchItems = cloneOrchestrationItemsWithDependencies(queryPlansIds, plansParentId);
            
        return true;
    }

    global class CloneInput {
        @InvocableVariable(label='Record ID')
        global String recordId;

        @InvocableVariable(label='New Name')
        global String newName;
        
        @InvocableVariable(label='Product Name')
        global String productName;

        @InvocableVariable(label='Method Name')
        global String methodName;
    }

    private static Map<Id,Id> clonePlanDefinitions(List<id> plansId, Map<String,String> newNames){
        List<String> fieldsPlan = getUpdateableFields(vlocity_cmt__OrchestrationPlanDefinition__c.SObjectType);
        String soqlPlan = ''
                + ' SELECT ' + String.join(fieldsPlan, ',')
                + ' FROM vlocity_cmt__OrchestrationPlanDefinition__c'
                + ' WHERE Id IN :plansId';
        List<vlocity_cmt__OrchestrationPlanDefinition__c> queryPlans = Database.query(soqlPlan);

        List<sObject> clonedRecords = new List<sObject>();
        
        for (vlocity_cmt__OrchestrationPlanDefinition__c plan : queryPlans) {
            vlocity_cmt__OrchestrationPlanDefinition__c clonedRecord = plan.clone(false, true);
            clonedRecord.put('Name', newNames.get(clonedRecord.getCloneSourceId()));

            clonedRecords.add(clonedRecord);
        }

        insert clonedRecords;

        Map<Id,Id> planParentId = new Map<Id, Id>();

        for (sObject item : clonedRecords){
            System.debug('Putting into newItems, key ->' + item.getCloneSourceId() +', value -> ' + item.Id);
            planParentId.put(item.getCloneSourceId(), item.Id);
        }        

        return planParentId;
    }
    // private static vlocity_cmt__OrchestrationScenario__c queryScenario(String scenarioId){
    //     List<Id> tempScenario= new List<Id>();
    //     tempScenario.add(scenarioId);
    //     List<vlocity_cmt__OrchestrationScenario__c> scenarios = queryScenario(tempScenario);
    //     if (scenarios != null) {
    //         return scenarios[0];
    //     }
    //     return null;
    // }

    private static Map<Id,Id> cloneScenarios(List<id> scenariosIds, Map<String,String> newNames, Map<String,String> newProducts, Map<Id,Id> plansNewId){
        List<String> fieldsScenario = getUpdateableFields(vlocity_cmt__OrchestrationScenario__c.SObjectType);
        String soqlScenario = ''
                + ' SELECT ' + String.join(fieldsScenario, ',')
                + ' FROM vlocity_cmt__OrchestrationScenario__c'
                + ' WHERE Id In :scenariosIds';

        List<vlocity_cmt__OrchestrationScenario__c> queryScenarios = Database.query(soqlScenario);
         
        List<sObject> clonedRecords = new List<sObject>();
        
        for (sObject scenario : queryScenarios) {
            sObject clonedRecord = scenario.clone(false, true);
            //     if (field != 'Id' && field != 'Name' && field != 'vlocity_cmt__Product2Id__c' && field != 'vlocity_cmt__OrchestrationPlanDefinitionId__c') {
            clonedRecord.put('Name', newNames.get(clonedRecord.getCloneSourceId()));
            clonedRecord.put('vlocity_cmt__Product2Id__c', newProducts.get(clonedRecord.getCloneSourceId()));
            Id tempPlanId = (Id)clonedRecord.get('vlocity_cmt__OrchestrationPlanDefinitionId__c');
            clonedRecord.put('vlocity_cmt__OrchestrationPlanDefinitionId__c', plansNewId.get(tempPlanId));

            clonedRecords.add(clonedRecord);
        }

        insert clonedRecords;

        Map<Id,Id> scenarioParentId = new Map<Id, Id>();

        for (sObject item : clonedRecords){
            System.debug('Putting into newItems, key ->' + item.getCloneSourceId() +', value -> ' + item.Id);
            scenarioParentId.put(item.getCloneSourceId(), item.Id);
        }        

        return scenarioParentId;
    }

    private static List<Id> getAllPlanDeifinitions(String planId) {
        List<Id> tempPlan = new List<Id>();
        tempPlan.add((Id)planId);
        return getAllPlanDefinitions(tempPlan, new List<Id>());
    }
    
    
    private static List<Id> getAllPlanDefinitions(List<Id> planId, List<Id> skipDependencies) {
        Set<Id> uniquePlanIds = new Set<Id>();
    
        List<vlocity_cmt__OrchestrationDependencyDefinition__c> dependencies = [SELECT Id, vlocity_cmt__OrchestrationItemDefinitionId__r.vlocity_cmt__OrchestrationPlanDefinitionId__c
            FROM vlocity_cmt__OrchestrationDependencyDefinition__c
            WHERE vlocity_cmt__DependencyItemDefinitionId__r.vlocity_cmt__OrchestrationPlanDefinitionId__c IN :planId
            AND Id NOT IN :skipDependencies];
    
        for (vlocity_cmt__OrchestrationDependencyDefinition__c dependency : dependencies) {
            skipDependencies.add(dependency.Id);
            uniquePlanIds.add(dependency.vlocity_cmt__OrchestrationItemDefinitionId__r.vlocity_cmt__OrchestrationPlanDefinitionId__c);
        }
    
        if (uniquePlanIds.size() > 0) {
            List<Id> ids = new List<Id>(uniquePlanIds);
            List<Id> recursiveIds = getAllPlanDefinitions(ids, skipDependencies);
            if (recursiveIds != null) {
                uniquePlanIds.addAll(recursiveIds);
            }
        }
    
        return new List<Id>(uniquePlanIds);
    }
    

    private static Map<Id, String> getScenariosMap(List<Id> plansId){

        Map<Id,String> scenariosMap = new Map<Id, String>();
        List<vlocity_cmt__OrchestrationScenario__c> scenarios = [ SELECT Id, Name FROM vlocity_cmt__OrchestrationScenario__c
        WHERE vlocity_cmt__OrchestrationPlanDefinitionId__c IN :plansId];

        for (vlocity_cmt__OrchestrationScenario__c scenario : scenarios) {
            scenariosMap.put(scenario.Id, scenario.Name);
        }
       
        return scenariosMap;
    }

    private static Map<String,String> cloneOrchestrationItemsWithDependencies(List<Id> planIds, Map<Id,Id> newPlanIds) {
        // Retrieve fields dynamically for the child object, excluding system fields
        List<String> orchItemFields = getUpdateableFields(Schema.getGlobalDescribe().get('vlocity_cmt__OrchestrationItemDefinition__c'));
        List<Id> existingIds = new List<Id>();
        
        Map<String,String> newItems = new Map<String, String>(); //should be mapped by <existingRecordId, clonedRecordId>
        
        // Construct dynamic SOQL query
        String OrchItemssoql = 'SELECT Id, vlocity_cmt__OrchestrationPlanDefinitionId__c, ' + String.join(orchItemFields, ',') +
                      ' FROM vlocity_cmt__OrchestrationItemDefinition__c' +
                      ' WHERE vlocity_cmt__OrchestrationPlanDefinitionId__c IN :planIds';
        System.debug('OrchItemssoql -> ' + OrchItemssoql);
        List<sObject> orchItems = Database.query(OrchItemssoql);
        List<sObject> clonedorchItems = new List<sObject>();

        for (sObject item : orchItems) {
            sObject clonedItem = item.clone(false, true);
            Id tempPlanId = (Id)item.get('vlocity_cmt__OrchestrationPlanDefinitionId__c');
            clonedItem.put('vlocity_cmt__OrchestrationPlanDefinitionId__c', newPlanIds.get(tempPlanId));
            existingIds.add(item.Id);

            clonedorchItems.add(clonedItem);
        }

        insert clonedorchItems;
        
        for (sObject item : clonedorchItems){
            System.debug('Putting into newItems, key ->' + item.getCloneSourceId() +', value -> ' + item.Id);
            newItems.put(item.getCloneSourceId(), item.Id);
        }

        List<String> dependencyFields = getUpdateableFields(Schema.getGlobalDescribe().get('vlocity_cmt__OrchestrationDependencyDefinition__c'));
        System.debug(dependencyFields);
        String soqlDependency = 'SELECT name, vlocity_cmt__dependencyitemdefinitionid__c, vlocity_cmt__dependencytype__c, vlocity_cmt__scope__c, vlocity_cmt__OrchestrationItemDefinitionId__c' +
                        ' FROM vlocity_cmt__OrchestrationDependencyDefinition__c' +
                        ' WHERE vlocity_cmt__OrchestrationItemDefinitionId__c IN :existingIds';


        List<vlocity_cmt__OrchestrationDependencyDefinition__c> dependencies = Database.query(soqlDependency);

        List<sObject> clonedDependencies = new List<sObject>();

        for (vlocity_cmt__OrchestrationDependencyDefinition__c dependency : dependencies) {

            sObject clonedDependency = dependency.clone(false, true);

            System.debug('Cloning dependency -> ' + dependency.Name);
            System.debug('dependency vlocity_cmt__OrchestrationItemDefinitionId__c -> ' + newItems.get(dependency.vlocity_cmt__OrchestrationItemDefinitionId__c));
            System.debug('dependency vlocity_cmt__DependencyItemDefinitionId__c -> ' + newItems.get(dependency.vlocity_cmt__DependencyItemDefinitionId__c));

            clonedDependency.put('vlocity_cmt__OrchestrationItemDefinitionId__c', newItems.get(dependency.vlocity_cmt__OrchestrationItemDefinitionId__c));
            clonedDependency.put('vlocity_cmt__DependencyItemDefinitionId__c', newItems.get(dependency.vlocity_cmt__DependencyItemDefinitionId__c));

            clonedDependencies.add(clonedDependency);
    }

        insert clonedDependencies;

        return newItems;
    }

    // Helper method to get updateable fields for a given SObjectType
    private static List<String> getUpdateableFields(Schema.SObjectType sObjectType) {
        List<String> updateableFields = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();

        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            if (fieldDescribe.isUpdateable() && !fieldDescribe.isCalculated() && !fieldDescribe.isAutoNumber() && fieldName != 'vlocity_cmt__GlobalKey__c') {
                updateableFields.add(fieldName);
            }
        }

        return updateableFields;
    }

    public class Results {
        @InvocableVariable(label='Scenario ID' description='' required=true)
        public Id scenarioId;

        @InvocableVariable(label='Scenario Map' description='' required=true)
        public String scenarioMap;
    }
}