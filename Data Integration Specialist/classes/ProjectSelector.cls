public class ProjectSelector {

    public static final String STATUS_BILLABLE = 'Billable';

    public static List<Project__c> getAllProjects(Integer queryLimit) {
        return [
                SELECT
                        Id, Status__c, ProjectRef__c, Name
                FROM
                        Project__c
                LIMIT
                        :queryLimit
        ];
    }

    public static List<Project__c> getProjects(String projectRef, String oppId) {
        return [
                SELECT
                        Id
                FROM
                        Project__c
                WHERE
                ProjectRef__c =: projectRef
                AND
                Opportunity__c =: oppId
        ];
    }

    public static List<Project__c> getProjects(Set<Id> ids) {
        return [
                SELECT
                        ProjectRef__c, Billable_Amount__c
                FROM
                        Project__c
                WHERE
                        Id IN :ids
        ];
    }
}