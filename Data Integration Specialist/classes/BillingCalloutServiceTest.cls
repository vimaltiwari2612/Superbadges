@isTest
private class BillingCalloutServiceTest {

    @testSetup static void setupProject(){
        
        Opportunity oppo = new Opportunity();
        oppo.Name = 'TestOpp';
        oppo.CloseDate = Date.today();
        oppo.StageName = 'Prospecting';
        insert oppo;
        
        Project__c proj = new Project__c();
        proj.Name = 'TestProj';
        proj.Billable_Amount__c = 1000;        
        proj.ProjectRef__c = 'TestRef';
        proj.Status__c = 'Running';
        proj.Opportunity__c = oppo.Id;
        insert proj;
        
        ServiceCredentials__c servCred = new ServiceCredentials__c();
        servCred.Name = 'BillingServiceCredential';
        servCred.Username__c = 'user1';
        servCred.Password__c = 'pass1';
        insert servCred;
        
    }
    
    @isTest static void testCalloutSuccess(){
                                Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
        List<Project__c> prof = [SELECT Status__C FROM Project__c WHERE ProjectRef__c = 'TestRef'];
        System.assertEquals(1, prof.size());
        Test.startTest();
        prof[0].Status__c = 'Billable';
        update prof;
        Test.stopTest();
        prof = [SELECT Status__C FROM Project__c WHERE ProjectRef__c = 'TestRef'];
        System.assertEquals(1, prof.size());  
        System.assertEquals('Billed', prof[0].Status__C);
    }

    @isTest static void testCalloutFailure(){
                                Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
        List<Project__c> prof = [SELECT Status__C FROM Project__c WHERE ProjectRef__c = 'TestRef'];
        System.assertEquals(1, prof.size());
        Test.startTest();
        prof[0].Status__c = 'Running';
        update prof;
        Test.stopTest();
        prof = [SELECT Status__C FROM Project__c WHERE ProjectRef__c = 'TestRef'];
        System.assertEquals(1, prof.size());  
        System.assertEquals('Running', prof[0].Status__C);
    }
    
}