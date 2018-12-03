@isTest
private class ProjectRESTServiceTest {

    public static testMethod void testSuccess()
    {

        Account acct = new Account(Name='Test Account');
        insert acct;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acct.id, 
            CloseDate = System.Today(),            
            Amount = 12480.00,
            Type = 'New Project',
            DeliveryInstallationStatus__c='Completed',
            StageName='Negotiation/Review');
        insert opp;
        
        
        Test.startTest();
        string strResponse = ProjectRESTService.postProjectData('1234','TestProject', 
            string.valueOf(opp.Id), opp.CloseDate, opp.CloseDate+1, double.valueOf(opp.Amount),'Billable');
        system.assertEquals('OK', strResponse);
        Test.stopTest();
        Opportunity oppAfter = [select ID, DeliveryInstallationStatus__c from Opportunity where ID = :opp.Id LIMIT 1][0];
        system.assertEquals('In progress', oppAfter.DeliveryInstallationStatus__c); 
    } 
    
    public static testMethod void testFailure()
    {

        Account acct = new Account(Name='Test Account');
        insert acct;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acct.id, 
            CloseDate = System.Today(),            
            Amount = 12480.00,
            Type = 'New Project',
            DeliveryInstallationStatus__c='Completed',
            StageName='Negotiation/Review');
        insert opp;
        
        
        Test.startTest();
        string strResponse = ProjectRESTService.postProjectData('1234','TestProject', 
            '1234', opp.CloseDate, opp.CloseDate+1, double.valueOf(opp.Amount),'Billable');
        system.assertEquals('Failed', strResponse);
        Test.stopTest();
        Opportunity oppAfter = [select ID, DeliveryInstallationStatus__c from Opportunity where ID = :opp.Id LIMIT 1][0];
        system.assertEquals('Completed', oppAfter.DeliveryInstallationStatus__c); 
    } 

}