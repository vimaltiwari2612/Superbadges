@isTest
private class WarehouseSyncTest {
	
	@isTest 
	static void SyncTest() {
		// Implement test code

		Test.startTest();
       	WarehouseSyncSchedule syncMe = new WarehouseSyncSchedule();
       	Datetime dt = Datetime.now().addMinutes(3);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobID = System.schedule('Test the Queue Status', CRON_EXP, syncMe);
        Test.stopTest();
        CronTrigger cTId = [SELECT State FROM CronTrigger WHERE Id = :jobID];
        System.assertEquals('WAITING', String.valueOf(cTId.State), 'jobID Doesnt Match');

	}
}