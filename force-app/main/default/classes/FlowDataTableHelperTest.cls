/**
 * @description       :
 * @author            : Amit Singh
 * @group             :
 * @last modified on  : 11-03-2021
 * @last modified by  : Amit Singh
**/
@IsTest
public with sharing class FlowDataTableHelperTest {

    private static FINAL String WHERE_CLAUSE = ' WHERE ';
    private static FINAL String ORDER_BY_CLAUSE = ' ORDER BY ';

    @IsTest
    private static void fetchsObjectsTest(){

        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Rating = 'Hot';
        accountRecord.Industry = 'Education';
        accountRecord.Phone = '5623548789';
        insert accountRecord;

        FlowDataTableHelper.DataTableInput wrapper = new FlowDataTableHelper.DataTableInput();
        wrapper.fieldsToDisplay = 'Name, Rating, Industry, Parent.Name, CreatedDate';
        wrapper.fieldsToLink = 'Name, Parent.Name';
        wrapper.limitClause = '10';
        wrapper.objectAPIName = 'Account';
        wrapper.orderBy = ORDER_BY_CLAUSE + 'CreatedDate' + ' ' + 'DESC';
        wrapper.filter = WHERE_CLAUSE + 'Id' + ' = \'' + accountRecord.Id + '\'';

        Test.startTest();
            FlowDataTableHelper.fetchsObjects( JSON.serialize(wrapper) );
        Test.stopTest();
    }

    @IsTest
    private static void fetchsObjectsTestContact(){

        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Account';
        contactRecord.LastName  = 'Hot';
        contactRecord.Email     = 'testcontact+fb@gmail.com';
        contactRecord.Phone     = '5623548789';
        insert contactRecord;

        FlowDataTableHelper.DataTableInput wrapper = new FlowDataTableHelper.DataTableInput();
        wrapper.fieldsToDisplay = 'Name, Email, Phone, AccountId';
        wrapper.fieldsToLink = 'Name';
        wrapper.limitClause = '10';
        wrapper.objectAPIName = 'Contact';
        wrapper.orderBy = ORDER_BY_CLAUSE + 'CreatedDate' + ' ' + 'DESC';

        Test.startTest();
            FlowDataTableHelper.fetchsObjects( JSON.serialize(wrapper) );
        Test.stopTest();
    }
}