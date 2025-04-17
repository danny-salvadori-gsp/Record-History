public with sharing class AccountTriggerHandler {

	/**
	 * Handle after insert. Creates field history
	 */
	public static void handleAfterInsert(Map<Id, Account>  triggerNewMap) {
		Historian.writeHistory(triggerNewMap);
	}

	/**
	 * Handle after update. Creates field history
	 */
	public static void handleAfterUpdate(Map<Id, Account> triggerOldMap, Map<Id, Account>  triggerNewMap) {
		Historian.writeHistory(triggerOldMap, triggerNewMap);
	}

}