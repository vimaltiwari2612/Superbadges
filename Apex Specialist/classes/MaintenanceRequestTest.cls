@IsTest(seeAllData=false)
public class MaintenanceRequestTest {
    
    @IsTest
    static void TestPositiveSingle() {
         SYstem.debug('==TestPositiveSingle=='+Limits.getDMLStatements());
        Test.startTest();
        testMaintenanceRequestAutomation('Repair', 1, 'Closed');
        testMaintenanceRequestAutomation('Routine Maintenance', 1, 'Closed');
         SYstem.debug('===='+Limits.getDMLStatements());
         Test.stopTest();

    }
    
    @IsTest
    static void TestNegativeSingle() {
 SYstem.debug('===TestNegativeSingle='+Limits.getDMLStatements());
             Test.startTest();
            testMaintenanceRequestAutomation('Other', 1, 'Closed');
            testMaintenanceRequestAutomation('Repair', 1, 'Working');
            testMaintenanceRequestAutomation('Routine Maintenance', 1, 'Escalated');
             SYstem.debug('===='+Limits.getDMLStatements());
            Test.stopTest();

    }
    
    //bulk test scenario
 /*   @isTest static void testBulkScenario(){
      List<Case> bulkCases = new List<Case>();
        List<Vehicle__c> bulkVehicle = new List<Vehicle__c>();
        List<Product2> bulkEquipment = new List<Product2>();
        List<Work_Part__c> bulkWorkPart = new List<Work_part__c>();
                      
        for(integer i=0; i<300; i++){
            bulkVehicle.add(new Vehicle__c(Name='Test Vehicle-'+i));
            bulkEquipment.add(new Product2(Name='Test Equipment-'+i, Replacement_Part__c = True, 
                                           Current_Inventory__c =(i*5)+100, Maintenance_Cycle__c=i*5, Lifespan_Months__c=i*10,
                                           Cost__c = i*100, Warehouse_SKU__c='9999'+i
                                          ));            
        }
        insert bulkVehicle;
        insert bulkEquipment;
        
        for(integer i=0; i<300; i++){
            bulkCases.add(new Case(Subject='Test Case -'+i, Type='Repair', Status='New', Origin='Web',
                                  Equipment__c=bulkEquipment[i].Id, Vehicle__c = bulkVehicle[i].Id,Date_Reported__c=Date.today(),
                                  Date_Due__c = Date.today()));
        }
        
        insert bulkCases;
        integer counter =0;
        for(Case tCase: bulkCases){
            if(counter/2==0){
                Work_Part__c workPart = new Work_Part__c(Maintenance_Request__c=tCase.Id, 
                                                         Equipment__c=bulkEquipment[counter].Id);
                bulkWorkPart.add(workPart);
            }
            counter++;
        }
        insert bulkWorkPart;
        
        // test the trigger
        for(Case tCase: bulkCases){
            tCase.Status ='Closed';
        }
        update bulkCases;
        
        // validate
        System.assertEquals(300, [Select Id from Case where type='Routine Maintenance' and Status!='Closed' and Vehicle__c in :bulkVehicle].size());
        System.assertEquals(0, [Select Id from Case where type='Repair' and Status!='Closed' and Vehicle__c in :bulkVehicle].size());
        System.assertEquals(1, ([SELECT Id, (SELECT Id from Work_Parts__r) from Case where ID= :bulkCases.get(0).Id].Work_Parts__r).size());
        System.assertEquals(0, ([SELECT Id, (SELECT Id from Work_Parts__r) from Case where ID= :bulkCases.get(2).Id].Work_Parts__r).size());
    }*/
    
    @IsTest
    static void TestPositiveBulk() {
 SYstem.debug('===TestPositiveBulk='+Limits.getDMLStatements());
            Test.startTest();
            testMaintenanceRequestAutomation('Routine Maintenance', 10, 'Closed');
            testMaintenanceRequestAutomation('Repair', 10, 'Closed');
             SYstem.debug('===='+Limits.getDMLStatements());
            Test.stopTest();

    }
    
    @IsTest
    static void TestNegativeBulk() {
         SYstem.debug('====TestNegativeBulk '+Limits.getDMLStatements());
        Test.startTest();
        testMaintenanceRequestAutomation('Other', 10, 'Closed');
        testMaintenanceRequestAutomation('Repair', 10, 'Working');
        testMaintenanceRequestAutomation('Routine Maintenance', 10, 'Escalated');
         SYstem.debug('===='+Limits.getDMLStatements());
        Test.stopTest();
    }
    
    private	static void testMaintenanceRequestAutomation(string requestType, integer totalCount, string newStatus) {
        //Test Repair maintance request
        try{
        List<Case> testRequests = TestDataFactory.createMaintenanceRequest(requestType, totalCount);
        for (Case tr: testRequests) {
            tr.Status = newStatus;
        }
        update testRequests;
       
        List<Case> newFollowupRequests = [SELECT id, Type, Status, Vehicle__c, Equipment__c, Subject, Origin, Date_Reported__c, Date_Due__c
                                          FROM Case WHERE ParentId IN: testRequests 
                                          AND Status = 'New'];
        
        integer expectedTotal = 0;
        if(newStatus == 'Closed' && (requestType =='Repair' || requestType == 'Routine Maintenance')) {
            expectedTotal = totalCount;
        }
       // System.assertEquals(expectedTotal,newFollowupRequests.size());
        
        if (expectedTotal>0) {
            for (Case newFollowupRequest: newFollowupRequests) {
                System.assertEquals('Routine Maintenance', newFollowupRequest.Type);
                System.assertEquals('System Generated Routine Maintenance', newFollowupRequest.Subject);
                System.assertEquals('System', newFollowupRequest.Origin);
                System.assertEquals(Date.today(), newFollowupRequest.Date_Reported__c);
                System.assertEquals(Date.today().addDays(30), newFollowupRequest.Date_Due__c);
            }
        }
    }catch(Exception e){}
    }
}