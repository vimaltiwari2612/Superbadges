public class BillingCalloutService {

    public static final String BIlLING_SERVICE_CREDENTIALS = 'BillingServiceCredential';
    private static final ServiceCredentials__c CREDENTIALS = ServiceCredentials__c.getinstance(BIlLING_SERVICE_CREDENTIALS);

    @future(callout=true)
    public static void callBillingService(String projectId) {
        List<Project__c> projects = ProjectSelector.getProjects(new Set<Id>{projectId});

        if (projects.isEmpty() || projects[0].ProjectRef__c == null || projects[0].Billable_Amount__c == null) {
            // log error
            return;
        }

        // prepare proxy
        BillingServiceProxy.project soapProject = prepareProjectProxy(projects[0]);

        // callout
        BillingServiceProxy.InvoicesPortSoap11 port = new BillingServiceProxy.InvoicesPortSoap11();
        String response = port.billProject(soapProject);

        // update project on success
        if (response == 'OK') {
            Project__c project = new Project__c(
                    Id = projectId,
                    Status__c = 'Billed'
            );
            update project;
        }
    }

    private static BillingServiceProxy.project prepareProjectProxy(Project__c project) {
        BillingServiceProxy.project soapProject = new BillingServiceProxy.project();
        soapProject.projectRef = project.ProjectRef__c;
        soapProject.billAmount = project.Billable_Amount__c;
        soapProject.username = CREDENTIALS.Username__c;
        soapProject.password = CREDENTIALS.Password__c;
        return soapProject;
    }
}