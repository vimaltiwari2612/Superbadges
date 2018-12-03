@IsTest
public class TestDataFactory {

	public static List<Case> createMaintenanceRequest(string requestType, integer totalNumber) {

		List<Case> mtnRequests = new List<Case>();

		if (totalNumber >0 && requestType.length()>0 ){
			//create Veichle
			Vehicle__c v = new Vehicle__c(Name='TestVehicle 01', VIN_Number__c='aqwepnvaore2424');
			insert v;

			//create Equipments: two with different maintenance cycles
			List<Product2> prods = new List<Product2>();
			prods.add(new Product2(Name='TestProduct 01', Warehouse_SKU__c='200001', Lifespan_Months__c=12, Maintenance_Cycle__c=60, Replacement_Part__c=true));
			prods.add(new Product2(Name='TestProduct 02', Warehouse_SKU__c='200002', Lifespan_Months__c=24, Maintenance_Cycle__c=30, Replacement_Part__c=true));
			insert prods; 

			//create maintenance requests
			for (integer i = 0; i<totalNumber; i++) {
				mtnRequests.add(new Case(Type = requestType, Status='New', Origin='Phone', Equipment__c=prods[0].id, Subject='Test Case'));
			}
			insert mtnRequests;

			//Add two work parts for each maintenance request created
			List<Work_Part__c> wps = new List<Work_Part__c>();
			for (Case c: mtnRequests) {
				wps.add(new Work_Part__c(Equipment__c=prods[0].id, Maintenance_Request__c=c.id, Quantity__c=1));
				wps.add(new Work_Part__c(Equipment__c=prods[1].id, Maintenance_Request__c=c.id, Quantity__c=2));
			}
			insert wps;

		}	

		return mtnRequests;
	}
}