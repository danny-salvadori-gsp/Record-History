trigger Account_History on Account (after insert, after update) {

	if (Trigger.isAfter && Trigger.isInsert) {
		AccountTriggerHandler.handleAfterInsert(Trigger.newMap);
	}

	if (Trigger.isAfter && Trigger.isUpdate) {
		AccountTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
	}

}