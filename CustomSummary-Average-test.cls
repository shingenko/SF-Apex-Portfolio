@isTest //test class for averaging trigger for CustomSummary__c
public class CustomSummaryTrigger_Test_Class
{
	public static void generateData()
	{
		TicketingSystem__c ticket = new TicketingSystem__c();
		ticket.FirstName__c = 'Goku';
		ticket.LastName__c = 'Son';
		ticket.Issue__c = 'Shenron is no longer being brought forth when we collect the dragonballs, and a message pops up about over using them.';
		ticket.Phone__c = '111-111-1111';
		ticket.Date_Closed__c = Datetime.Now();
		ticket.SubmitDate__c = Datetime.newInstance(2016, 07, 12, 18, 33, 12);
		insert ticket;

		CustomSummaryObject__c customSummary = new CustomSummaryObject__c();
		customSummary.Name = 'TestRecord';
		CustomSummaryObject__c.Object_to_Summarize__c = 'TicketingSystem__c';
		customSummary.DateRangeBegin__c = Datetime.newInstance(2016, 07, 01, 00, 01, 01);
		customSummary.DateRangeEnd__c = Datetime.Now();
		insert customSummary;
	}

	public static testhMethod runTest()
	{
		generateData();
		CustomSummaryObject__c toTest = [SELECT Id, Name, Average__c, Object_to_Summarize__c
											FROM CustomSummaryObject__c
											WHERE Name = 'TestRecord'
											LIMIT 1];

		Test.startTest();
		System.assertNotEquals(Average__c, null);
		System.assertEquals(toTest.Object_to_Summarize__c, 'TicketingSystem__c');
		Test.stopTest();
	}
}
