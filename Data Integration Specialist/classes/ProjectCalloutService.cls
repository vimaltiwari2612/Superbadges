public class ProjectCalloutService {
    //method to be invoked by ProcessBuilder apex
    @InvocableMethod
    public static void postOpportunityToPMS(List<Id> oppoIds){
        Opportunity opp = [SELECT Id,Name,Account.Name,CloseDate,Amount FROM Opportunity WHERE Id = :oppoIds[0]];
        String serviceToken = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
        
        String jsonInput = '{\n' +
            ' "opportunityId" : "'+opp.Id+'",\n'+
            ' "opportunityName" : "'+opp.Name+'",\n'+
            ' "accountName" : "'+opp.Account.Name+'",\n'+
            ' "closeDate" : "'+String.ValueOf(opp.CloseDate).mid(0,10)+'",\n'+   
            ' "amount" : "'+opp.Amount+'"\n}';
            
        System.enqueueJob(new QueueablePMSCall(serviceToken, jsonInput, opp.Id));
    }    
    
    class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts{
        private String serviceToken;
        private String jsonInput;
        private Id oppId;
        
        public QueueablePMSCall(String serviceToken, String jsonInput, Id oppId){
            this.serviceToken = serviceToken;
            this.jsonInput = jsonInput;
            this.oppId = oppId;
        }
        
        public void execute(QueueableContext qc){
            postToPMS(serviceToken, jsonInput, oppId);        
        }
    }
    
    @Future(callout=true)
    private static void postToPMS(String serviceToken, String jsonInput, Id oppoId){
        HTTPRequest req = new HTTPRequest();
        req.setEndPoint('callout:ProjectService');
        req.setMethod('POST');
        req.setHeader('token',serviceToken);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody(jsonInput);
        
        HTTP http = new HTTP();
        HTTPResponse res = http.send(req);
        
        Opportunity opp = new Opportunity(Id=oppoId);
        if(res.getStatusCode() == 201){
            opp.StageName = 'Submitted Project';                
            System.debug('Success: ' + res.getStatus());
        }else{
            opp.StageName = 'Resubmit Project';
            System.debug('Failure: ' + res.getStatusCode() + ' ' + res.getStatus());
        }
        update opp;
    }
}