public with sharing class SObjectWrapperUtility
{
	/**
	Copyright (c) 2020  ShinGenko
	https://github.com/shingenko/SF-Apex-Portfolio/edit/master/SObjectWrapperUtility.cls
	https://github.com/samuel-reyes/SalesforcePortfolio/edit/master/SObjectWrapperUtility.cls

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	
	**/
	
	/** Map<FieldName,IsFieldWriteable> **/
	private Map<String, Boolean> objectFields {get;set;}
	public String jsonString;

	/**
    * @author Samuel Reyes
    * @date 2020-01-13
    * @description Constructor(s) for class to perform initial setup tasks required to work properly.
    * @param SObjectType objType - The Schema defined type of object whose fields we need to check against.
    * @param SObject[] items - A list of instantiated SObjects for any single SObjectType.
    */
	public SObjectWrapperUtility(SObjectType objType, SObject[] items)
	{

		this.objectFields = new Map<String,Boolean>();
		System.debug(LoggingLevel.DEBUG, 'SObjectWrapperUtility has been initialized with objType :: ' + objType.getDescribe().getName());

		Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();

		for( String fieldName : fieldMap.keySet() )
		{
			Schema.SObjectField currentField = fieldMap.get(fieldName);
			if(currentField.getDescribe().isUpdateable()){ this.objectFields.put(currentField.getDescribe().getName(),true); }
			else{ this.objectFields.put(currentField.getDescribe().getName(),false); }
		}

		this.jsonString = this.generateJSON(items);
		System.debug(LoggingLevel.DEBUG, 'generated JSON string :: ' + this.jsonString);
	}

	/**
    * @author Samuel Reyes
    * @date 2020-01-13
    * @description Typically Salesforce will take records returned from Apex, and pass them to the front end with any null
    * values as empty object keys. This creates problems when trying to sort records via Javascript. This wrapper will
    * process the records prior to their being sent to the front end, and restores all unpopulated field keys.
    * This does NOT SOQL query any missing field values, but will simply restore keys for records passed into it.
    * @param SObject[] items - A list of instantiated SObjects for any single SObjectType.
    * Wrapper currently only supports wrapping types of one item.
    * @return JSON string ready to be passed to front end Javascript.
    */
	private String generateJSON(SObject[] items)
	{
		SObjectWrapper[] records = new SObjectWrapper[0];
		for(SObject item : items)
		{
			Map<String, Object> fields = new Map<String,Object>();
			Set<String> populatedFields = item.getPopulatedFieldsAsMap().keySet();
			System.debug(LoggingLevel.FINE, 'populatedFields output :: ' + populatedFields);

			for(String field : this.objectFields.keySet())
			{
				if(!populatedFields.contains(field))
				{
					fields.put(field,null);
				}
				else
				{
					fields.put(field, item.get(field));
				}
			}
			records.add(new SObjectWrapper((Id)item.get('Id'),fields));
		}
		return JSON.serialize(records);
	}


	private class SObjectWrapper
	{
		public Id recordId {get;set;}
		public Map<String,Object> fields {get;set;}

		SObjectWrapper(Id recId, Map<String,Object> recFieldsMap)
		{
			this.recordId = recId;
			this.fields = recFieldsMap;
		}
	}
}
