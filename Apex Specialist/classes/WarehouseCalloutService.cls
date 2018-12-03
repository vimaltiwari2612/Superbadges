public with sharing class WarehouseCalloutService 
{
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    class Equipment
    {
        //public Id id{get;set;}
        public boolean replacement{get;set;}
        public Integer quantity{get;set;}
        public String name{get;set;}
        public Decimal maintenanceperiod{get;set;}
        public Decimal lifespan{get;set;}
        public Decimal cost{get;set;}
        public String sku{get;set;}
    }
    
    // complete this method to make the callout (using @future) to the
    // REST endpoint and update equipment on hand.
    @Future(Callout = True)
    public static void runWarehouseEquipmentSync()
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setHeader('Content-type', 'application/json');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200)
        {
             List<Equipment> equipments = (List<Equipment>)Json.deserialize(response.getBody(), List<Equipment>.class);
            List<Product2> toInsert = new List<Product2>();
            for(Equipment e:equipments)
            {
                Product2 equipment = new Product2();
                equipment.Replacement_Part__c = e.replacement;
                equipment.Current_Inventory__c = e.quantity;
                equipment.Name = e.name;
                equipment.Maintenance_Cycle__c = e.maintenanceperiod;
                equipment.Lifespan_Months__c = e.lifespan;
                equipment.Cost__c = e.cost;
                equipment.Warehouse_SKU__c = e.sku;
                
                System.debug('[Equipment]:'+equipment);
                toInsert.add(equipment);
            }
            
            upsert toInsert Warehouse_SKU__c;
        }
    }

}