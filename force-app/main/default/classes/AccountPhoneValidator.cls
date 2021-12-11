/**
 * @description       :
 * @author            : Amit Singh
 * @group             : Account
 * @last modified on  : 12-11-2021
 * @last modified by  : Amit Singh
**/
public with sharing class AccountPhoneValidator implements TriggerInterface {

    public List<sObject> filterRecords(TriggerContext tc){
        List<Account> filteredRecords = (List<Account>)tc.newList;
        return filteredRecords;
    }

    public void execute(List<sObject> records, TriggerContext tc){
        System.debug(' records Order No 2 \n '+ records);
    }
}
