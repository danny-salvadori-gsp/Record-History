@istest
public with sharing class HistorianTest {

	private static final String ACC_NAME_BEFORE = 'Test Account Insert Name';
	private static final String ACC_NAME_AFTER = 'Test Account Update Name';

	@isTest
	static void writeHistoryInsertTest() {
		Test.startTest();
		Account testAccount = new Account(Name = ACC_NAME_BEFORE);
		insert testAccount;
		Test.stopTest();
		List<Field_History__c> histories = [
				SELECT Id, New_Value_Text__c, Old_Value_Text__c, Field_API_Name__c
				FROM Field_History__c
		];
		Assert.areEqual(3, histories.size(), 'Wrong number of histories after account insert'); // Contains OwnerId and CleanStatus, too
		Field_History__c nameHistory = getNameHistory(histories);
		Assert.isNotNull(nameHistory, 'No history created for the name field on insert');
		Assert.areEqual(null, nameHistory.Old_Value_Text__c, 'Wrong OLD value for acc name change history on insert');
		Assert.areEqual(ACC_NAME_BEFORE, nameHistory.New_Value_Text__c, 'Wrong NEW value for acc name change history');
	}

	@isTest
	static void writeHistoryUpdateTest() {
		Account testAccount = new Account(Name = ACC_NAME_BEFORE);
		insert testAccount;
		Assert.areEqual(3, [SELECT count(Id) c FROM Field_History__c][0].get('c'), 'Wrong number of histories after account insert'); // Contains OwnerId and CleanStatus, too
		Test.startTest();
		testAccount.Name = ACC_NAME_AFTER;
		update testAccount;
		Test.stopTest();
		List<Field_History__c> histories = [
				SELECT Id, New_Value_Text__c, Old_Value_Text__c, Field_API_Name__c
				FROM Field_History__c
				ORDER BY Name DESC
		];
		Field_History__c nameHistory = getNameHistory(histories);
		Assert.isNotNull(nameHistory, 'No history created for the name field on insert');
		Assert.areEqual(ACC_NAME_BEFORE, nameHistory.Old_Value_Text__c, 'Wrong OLD value for acc name change history after update');
		Assert.areEqual(ACC_NAME_AFTER, nameHistory.New_Value_Text__c, 'Wrong NEW value for acc name change history after update');
	}

	/**
	* Helper to get the name field history from among other histories
	*/
	private static Field_History__c getNameHistory(List<Field_History__c> histories) {
		Field_History__c nameHistory;
		for (Field_History__c history : histories) {
			if (history.Field_API_Name__c == 'Name') {
				nameHistory = history;
				break;
			}
		}
		return nameHistory;
	}
}