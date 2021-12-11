/**
 * @description       :
 * @author            : Amit Singh
 * @group             :
 * @last modified on  : 11-12-2021
 * @last modified by  : Amit Singh
**/
public with sharing class FlowDataTableHelper {

    public static final String NAME_STRING   = 'Name';
    public static final String URL_TYPE_NAME = 'url';

    @AuraEnabled(cacheable=true)
    public static DataTableResponse fetchsObjects(String requiredData){

        List<DataTableColumn> columns = new List<DataTableColumn>();
        DataTableResponse response    = new DataTableResponse();

        if(!String.isBlank(requiredData)){

            String theQuery = ' SELECT Id, ';
            DataTableInput inputWrapper = (DataTableInput)JSON.deserialize(requiredData, DataTableInput.class);

            Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(inputWrapper.objectAPIName);
            Schema.DescribeSObjectResult describeResult = sobjType.getDescribe();
            Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
            List<String> linksSet   = new List<String>();
            Set<String> fieldsSet   = new Set<String>();
            if(inputWrapper != null && !String.isBlank(inputWrapper.fieldsToDisplay) ){
                List<String> allfields = inputWrapper.fieldsToDisplay.split(',');
                if(inputWrapper.fieldsToLink != null && !String.isBlank(inputWrapper.fieldsToLink)){
                    linksSet = inputWrapper.fieldsToLink.split(',');
                    for(String str : linksSet){
                        fieldsSet.add(str.trim() );
                    }
                }
                for (String field : allfields) {
                    theQuery += field.trim()+', ';
                    DataTableColumn column = new DataTableColumn();
                    if( fieldsMap.containsKey( field.trim() ) && !field.trim().endsWith('__c')  && !field.trim().endsWith('Id') ){
                        Schema.SObjectField fieldInfo = fieldsMap.get( field.trim() );
                        Schema.DescribeFieldResult fieldResult = fieldInfo.getDescribe();
                        column = FlowDatatableWrapper.getFieldWrapper(fieldResult);
                        if(fieldsSet.contains(field.trim())){
                            column  = FlowDatatableWrapper.setupLinkAttributes(column);
                            column.fieldName = column.fieldName+'Url';
                        }
                        columns.add(column);
                    }else if( field.trim().contains('.') ){
                        column = prepareColumns(field.trim(), column, fieldsSet, theQuery);
                        columns.add(column);
                    }else if( field.trim().endsWith('__c') || field.trim().endsWith('Id') ){
                        String newFieldName = FlowDatatableWrapper.getFieldName( field.trim() );
                        column = prepareColumns(field.trim(), column, fieldsSet, theQuery);
                        column.fieldName = field.trim();
                        column.typeAttributes            = new TypeAttributes();
                        Map<String, String> labelMap     = new Map<String, String>();
                        labelMap.put('fieldName',newFieldName);
                        column.typeAttributes.label  = labelMap;
                        column.typeAttributes.target = '_blank';
                        column.type                  = 'reference';
                        theQuery                    += newFieldName+', ';
                        columns.add(column);
                    }
                }
            }
            String finalQuery = theQuery.substringBeforeLast(',');
            finalQuery += ' FROM '+inputWrapper.objectAPIName;
            if(!String.isBlank(inputWrapper.filter)){
                finalQuery += inputWrapper.filter;
            }
            if(!String.isBlank(inputWrapper.orderBy)){
                finalQuery += inputWrapper.orderBy;
            }
            if(!String.isBlank(inputWrapper.limitClause)){
                finalQuery += ' LIMIT '+inputWrapper.limitClause;
            }
            List<sObject> recordData = Database.query(finalQuery);
            List<Map<String, Object>> fieldValuesMapList = getFieldValues(recordData, columns, fieldsSet);
            response.columns = columns;
            response.data    = fieldValuesMapList;
        }
        return response;
    }

    private static DataTableColumn prepareColumns(String field, DataTableColumn column, Set<String> fieldsSet, String theQuery){
        column.label             = FlowDatatableWrapper.prepareFieldLabel( field.trim() ).trim();
        column.fieldName         = field.trim();
        column.type              = 'text';
        column.sortable          = true;
        column.wrapText          = true;
        if( fieldsSet.contains( field.trim() )){
            String newFieldName  = FlowDatatableWrapper.getFieldName( field.trim() );
            column               = FlowDatatableWrapper.setupLinkAttributes(column);
            column.fieldName     = newFieldName;
            column.type          = 'reference';
            //theQuery            += newFieldName+', ';
        }
        return column;
    }

    private static List<Map<String, Object>> getFieldValues(List<SObject> resultList, List<DataTableColumn> fieldsWrappersList, Set<String> linksSet) {
        List<Map<String, Object>> fieldValuesMapList = new List<Map<String, Object>>();
        Map<String, Object> fieldValuesMap;
        String name, newName;
        Object value, newValue;
        Boolean isUrl;
        for (SObject record : resultList) {
            fieldValuesMap = new Map<String, Object>();
            for (DataTableColumn fieldWrapper : fieldsWrappersList) {
                if ('action' != fieldWrapper.type) {
                    name = fieldWrapper.fieldName;
                    isUrl = false;
                    if (null != fieldWrapper.type && fieldWrapper.type.equals('reference') ) {
                        isUrl = true;
                    }
                    if(name.endsWith('Url')){
                        value = findFieldValue(name.substringBefore('Url'), record, isUrl);
                        value = null == value ? null : value;
                        fieldValuesMap.put(name.substringBefore('Url'), value);
                    }else{
                        value = findFieldValue(name, record, isUrl);
                        value = null == value ? null : value;
                        fieldValuesMap.put(name, value);
                    }
                    if (isUrl) {
                        newName  = fieldWrapper.typeAttributes.label.get('fieldName');
                        newValue = findFieldValue(newName, record, false);
                        newValue = null == newValue ? null : newValue;
                        fieldValuesMap.put(newName, newValue);
                    }else if(name.endsWith('Url') && linksSet.contains(name.substringBefore('Url'))){
                        newName = name;
                        newValue = FlowDatatableWrapper.salesforceUrl()+record.get('Id');
                        newValue = null == newValue ? null : newValue;
                        fieldValuesMap.put(newName, newValue);
                    }
                }
            }
            if (!fieldValuesMap.containsKey('Id')) {
                fieldValuesMap.put('Id', record.get('Id'));
            }
            fieldValuesMapList.add(fieldValuesMap);
        }
        return fieldValuesMapList;
    }

    private static Object findFieldValue(String name, SObject record, Boolean prepareLink) {
        Object value;
        if (name.contains('.')) {
            List<String> sObjectsList = name.split('\\.');
            if(sObjectsList.size() == 2){
                String attribName = sObjectsList[0];
                String fieldName = sObjectsList[1];
                Map<String, Object> recordMap = (Map<String, Object>)JSON.deserializeUntyped( JSON.serialize(record) );
                Object recordValue = recordMap.get(attribName);
                if(null != recordValue){
                    Map<String, Object> recordValueMap = (Map<String, Object>)JSON.deserializeUntyped( JSON.serialize(recordValue) );
                    value = recordValueMap.get(fieldName);
                }
            }else{
                value = null;
            }
        } else {
            value = record.get(name);
        }
        return null == value ? null : prepareLink ? FlowDatatableWrapper.salesforceUrl() + value : value;
    }

    public class DataTableInput{
        public String queryString       { get; set; }
        public String fieldsToDisplay   { get; set; }
        public String fieldsToLink      { get; set; }
        public String objectAPIName     { get; set; }
        public String filter            { get; set; }
        public String orderBy           { get; set; }
        public String limitClause       { get; set; }
    }

    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumn> columns { get; set; }
        @AuraEnabled
        public List<Object> data            { get; set; }
    }

    public class DataTableColumn {
        @AuraEnabled
        public String label                  { get; set; }
        @AuraEnabled
        public String fieldName              { get; set; }
        @AuraEnabled
        public String type                   { get; set; }
        @AuraEnabled
        public Boolean sortable              { get; set; }
        @AuraEnabled
        public Boolean wrapText              { get; set; }
        @AuraEnabled
        public TypeAttributes typeAttributes { get; set; }
    }

    public class TypeAttributes {
        @AuraEnabled
        public String currencyCode                  { get; set; }
        @AuraEnabled
        public String day                           { get; set; }
        @AuraEnabled
        public String month                         { get; set; }
        @AuraEnabled
        public String year                          { get; set; }
        @AuraEnabled
        public Map<String, String> label            { get; set; }
        @AuraEnabled
        public String target                        { get; set; }
        @AuraEnabled
        public List<Map<String, String>> rowActions { get; set; }
    }

}