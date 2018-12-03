public class MaintenanceRequestHelper {
    public static void updateWorkOrders(Set<Id> caseId){
        List<Case> newCaseList = new List<Case>();
        List<Case> listCase = [Select id,Equipment__c,Vehicle__c,Equipment__r.Maintenance_Cycle__c,
        (Select Equipment__r.Maintenance_Cycle__c from Work_Parts__r) from Case where Id In: caseId];
        for(Case c: listCase){
            Case newCase = new Case();
            if(c.Equipment__c != NULL )
                newCase.Equipment__c = c.Equipment__c;
            newCase.Type = 'Routine Maintenance';
            newCase.Subject = 'Routine Maintenance Auto-generated';
            newCase.Date_Reported__c = System.today();
            Integer shortSpan = 0;
            if(c.Work_Parts__r.size() > 0){
                for(Work_Part__c wp : c.Work_Parts__r){
                    if(wp.Equipment__r.Maintenance_Cycle__c != NULL && (wp.Equipment__r.Maintenance_Cycle__c < shortSpan || shortSpan == 0 )){
                        shortSpan = Integer.ValueOf(wp.Equipment__r.Maintenance_Cycle__c);
                    }
                }
            }
            newCase.Date_Due__c = System.today().addDays(shortSpan);
            newCaseList.add(newCase);
        }
        if(newCaseList.size() > 0){
            insert newCaseList;
        }    
    }        
}