public with sharing class ContactTriggerHandler {

	/**
	 * Handle after insert. Creates field history
	 */
	public static void handleAfterInsert(Map<Id, Contact>  triggerNewMap) {
		Historian.writeHistory(triggerNewMap);
	}

	/**
	 * Handle after update. Creates field history
	 */
	public static void handleAfterUpdate(Map<Id, Contact> triggerOldMap, Map<Id, Contact>  triggerNewMap) {
		Historian.writeHistory(triggerOldMap, triggerNewMap);
	}

}