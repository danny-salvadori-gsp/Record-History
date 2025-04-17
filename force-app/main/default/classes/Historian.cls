public with sharing class Historian {

	/**
	 * Helper signature that assumes it's being given the Trigger.newMap from an insert trigger
	 */
	public static void writeHistory(Map<Id, SObject> triggerNewMap) {
		Map<Id, SObject> triggerOldMap = new Map<Id, SObject>();
		writeHistory(triggerOldMap, triggerNewMap);
	}

	/**
	* Create a Field_History__c record for each updateable field changed among given records
	*/
	public static void writeHistory(Map<Id, SObject> triggerOldMap, Map<Id, SObject> triggerNewMap) {

		// Just a quick POC version of this code. Should really work for multiple SObject types
		List<String> updateableFields;
		if (triggerNewMap == null || triggerNewMap.isEmpty()) {
			return;
		} else {
			updateableFields = getUpdateableFields(triggerNewMap.values()[0].Id);
		}

		// Check what fields are changed and create a history record for each
		List<Field_History__c> fieldHistoriesForInsert = new List<Field_History__c>();
		for (Id recordId : triggerNewMap.keySet()) {
			SObject oldRecord = triggerOldMap.get(recordId);
			SObject newRecord = triggerNewMap.get(recordId);
			for (String field : updateableFields) {
				if (
						(oldRecord == null && newRecord.get(field) != null)
						|| (oldRecord != null && oldRecord.get(field) != newRecord.get(field))
				) {
					fieldHistoriesForInsert.add(generateFieldHistory(oldRecord, newRecord, field));
				}
			}
		}

		insert fieldHistoriesForInsert;
	}

	/**
	 * Schema-helper method. Gets all updateable fields for an SObject from a given record ID
	 */
	public static List<String> getUpdateableFields(Id recordId) {
		List<String> fieldApiNames = new List<String>();
		Schema.SObjectType sObjectType = recordId.getSObjectType();
		Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
		Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
		for (Schema.SObjectField sObjectField: fieldsMap.values()) {
			DescribeFieldResult fieldDescribe = sObjectField.getDescribe();
			if (fieldDescribe.isUpdateable()) {
				fieldApiNames.add(fieldDescribe.getLocalName());
			}
		}
		return fieldApiNames;
	}

	/**
	 * Create a Field_History__c record from given old/new record and a field that we know has changed
	 */
	public static Field_History__c generateFieldHistory(SObject oldRecord, SObject newRecord, String fieldApiName) {
		String newValueString = newRecord.get(fieldApiName) == null ? '' : String.valueOf(newRecord.get(fieldApiName));
		if (newValueString.length() > 255) {
			newValueString = newValueString.substring(0, 255);
		}
		String oldValueString = '';
		if (oldRecord != null) {
			oldValueString = oldRecord.get(fieldApiName) == null ? '' : String.valueOf(oldRecord.get(fieldApiName));
			if (oldValueString.length() > 255) {
				oldValueString = oldValueString.substring(0, 255);
			}
		}

		Field_History__c newFieldHistoryRecord = new Field_History__c(
			Change_Time__c = System.now(),
			Change_User__c = Userinfo.getUserId(),
			Field_API_Name__c = fieldApiName,
			New_Value_Text__c = newValueString,
			Old_Value_Text__c = oldValueString,
			Record_Id__c = newRecord.Id,
			Sobject_Api_Name__c = newRecord.Id.getSObjectType().getDescribe().getLocalName()
		);
		return newFieldHistoryRecord;
	}

}