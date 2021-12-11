/**
 * @description       :
 * @author            : Amit Singh
 * @group             : Flow
 * @last modified on  : 12-09-2021
 * @last modified by  : Amit Singh
**/
public class LeadAssignmentUsingFlow {

    /**
    * @description
    * @author Amit Singh | 12-09-2021
    * @param LeadIds
    **/
    @InvocableMethod(label='Lead Assignment Using Apex' description='Trigger the lead assignment rule' category='Lead')
    public static void LeadAssign(List<Id> LeadIds){
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        Lead leadRecord = [select id from lead where lead.id in :LeadIds];
        leadRecord.setOptions(dmo);
        update leadRecord;
    }
}