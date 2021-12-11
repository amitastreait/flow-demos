/**
 * @description       :
 * @author            : Amit Singh
 * @group             :
 * @last modified on  : 12-09-2021
 * @last modified by  : Amit Singh
**/
public class AccountTriggerHandler implements TriggerInterface {

    public List<sObject> filterRecords(TriggerContext tc){
        List<Account> filteredRecords = (List<Account>)tc.newList;
        return filteredRecords;
    }

    public void execute(List<sObject> records, TriggerContext tc){
        System.debug(' records \n '+ records);
    }
}