/**
 * @description       : This class is used to convert the Lead using Flow
 * @author            : Amit Singh
 * @group             : Flow
 * @last modified on  : 12-11-2021
 * @last modified by  : Amit Singh
**/
public with sharing class ConvertLeadUsingFlows {

    @InvocableMethod(label='Lead Convert Using Apex' description='Convert the Lead Record Using Apex' category='Lead')
    public static List<ConvertLeadUsingFlows.OutputWrapper> LeadConvert(List<Id> LeadIds){
        /* Get the MasterLabel from LeadStatus Object using SOQL where isConverted is True and Store the MasterLabel */
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        /* Create the list of Database.LeadConvert */
        List<Database.LeadConvert> leadConvertList = new List<Database.LeadConvert>();
        for(Id LeadId : LeadIds){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(LeadId);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            //lc.setDoNotCreateOpportunity(true);
            leadConvertList.add(lc);
        }
        List<Database.LeadConvertResult> leadConvertResult = Database.convertLead(leadConvertList);
        return new List<ConvertLeadUsingFlows.OutputWrapper>();
    }
    /*
        Input Parameters
            Apex Input          Flow Input
            List<T>         ~=  Id
            List<List<Id>>  ~= List<Id>
    */

    public class OutputWrapper{
        @InvocableVariable(label='Records for Input' description='yourDescription')
        public String status;
        @InvocableVariable(label='Records for Input' description='yourDescription')
        public String message;
    }
}
