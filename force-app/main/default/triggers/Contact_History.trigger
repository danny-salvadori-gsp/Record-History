trigger Contact_History on Contact (after insert, after update) {

if (Trigger.isAfter && Trigger.isInsert) {
	ContactTriggerHandler.handleAfterInsert(Trigger.newMap);
}

if (Trigger.isAfter && Trigger.isUpdate) {
	ContactTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
}
}