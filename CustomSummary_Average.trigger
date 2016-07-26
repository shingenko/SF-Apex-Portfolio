//after a custom summary record is inserted or update, query the ticketing system to populate
//an average for the amount of time that has been spent working on resolutions
Trigger Averager on CustomSummaryObject__c (after insert, after update)
{	
	List<CustomSummaryObject__c> toUpdate = new List<CustomSummaryObject__c>();
	for(CustomSummaryObject__c cobjsum : Trigger.new)
	{
		CustomSummaryObject__c oldmap = new CustomSummaryObject__c();
		if(Trigger.isUpdate)oldmap = Trigger.oldMap.get(cobjsum.Id);
		if(Trigger.isInsert)oldmap.Period_Start__c = null;
		if(cobjsum.Object_to_Summarize__c == 'TicketingSystem__c')
		{
			
			if(cobjsum.Period_Start__c != oldmap.Period_Start__c)
			{
				AggregateResult[] groupedResults = [SELECT AVG(TimeTillResolved_Minutes__c)aver
													FROM TicketingSystem__c
													WHERE Date_Closed__c >= : cobjsum.DateRangeBegin__c and Date_Closed__c <= : cobjsum.DateRangeEnd__c];
				
				Double intdata = (Double)groupedResults[0].get('aver');
				
				
				CustomSummaryObject__c updateThis = new CustomSummaryObject__c();
				updateThis.Value__c = intdata;
				//updateThis.Test__c = intdata;
				updateThis.Id = cobjsum.Id;
				toUpdate.add(updateThis);
			}
		}
		
	}
	update toUpdate;
}
