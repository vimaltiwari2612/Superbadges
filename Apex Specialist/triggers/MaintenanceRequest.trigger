trigger MaintenanceRequest on Case (before update, after update) {
    if(Trigger.isUpdate && Trigger.isAfter){
        Set<Id> caseId = new Set<Id>();
        for(Case c : Trigger.New){
            Case oldCase = (Case)Trigger.OldMap.get(c.Id);
            if(c.Status == 'Closed' && c.Status != oldCase.Status && (c.Type == 'Routine Maintenance' || c.Type == 'Repair')){
                caseId.add(c.Id);
            }
        }
        if(caseId.size() > 0){
            MaintenanceRequestHelper.updateWorkOrders(caseId);
        }
    }
}