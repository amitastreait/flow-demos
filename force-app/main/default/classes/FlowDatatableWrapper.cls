/**
 * @description       :
 * @author            : Amit Singh
 * @group             :
 * @last modified on  : 11-12-2021
 * @last modified by  : Amit Singh
**/
public with sharing class FlowDatatableWrapper {

    private static final String NAME_STRING   = 'Name';
    private static final String URL_TYPE_NAME = 'url';

    public static String prepareFieldLabel(String fieldApiName){
        String newLabel = fieldApiName.replace('__c', '').replace('Id', '');
        if(fieldApiName.contains('.')){
            List<String> sObjectsList = fieldApiName.split('\\.');
            if(sObjectsList.size() == 2){
                String attribName = sObjectsList[0];
                String fieldName  = sObjectsList[1];
                newLabel = attribName.replace('__r', '')+' '+fieldName;
            }
        }
        return newLabel;
    }

    public static FlowDataTableHelper.DataTableColumn getFieldWrapper(Schema.DescribeFieldResult field) {
        FlowDataTableHelper.DataTableColumn newWrapper = new FlowDataTableHelper.DataTableColumn();
        newWrapper.label     = field.getLabel();
        newWrapper.fieldName = field.getName();
        newWrapper.type      = field.getType().name().toLowerCase();
        newWrapper.sortable  = true;
        newWrapper.wrapText  = true;
        if ('double' == newWrapper.type) {
            newWrapper.type = 'number';
        }
        if('picklist' == newWrapper.type || 'string' == newWrapper.type){
            newWrapper.type = 'text';
        }
        if ('datetime' == newWrapper.type) {
            newWrapper.type = 'date';
            newWrapper      = setDateAttributes(newWrapper, true);
        }
        Boolean isReference = 'reference' == newWrapper.type;
        if (isReference) {
            newWrapper.fieldName = getFieldName(newWrapper.fieldName);
        }
        return newWrapper;
    }

    public static FlowDataTableHelper.DataTableColumn setupLinkAttributes(FlowDataTableHelper.DataTableColumn newWrapper) {
        newWrapper.typeAttributes        = new FlowDataTableHelper.TypeAttributes();
        Map<String, String> labelMap     = new Map<String, String>();
        labelMap.put('fieldName', newWrapper.fieldName);
        newWrapper.typeAttributes.label  = labelMap;
        newWrapper.typeAttributes.target = '_blank';
        return newWrapper;
    }

    public static FlowDataTableHelper.DataTableColumn setDateAttributes(FlowDataTableHelper.DataTableColumn newWrapper, Boolean showDateAsNumeric){
        if (showDateAsNumeric) {
            newWrapper.typeAttributes       = new FlowDataTableHelper.TypeAttributes();
            newWrapper.typeAttributes.day   = 'numeric';
            newWrapper.typeAttributes.month = 'numeric';
            newWrapper.typeAttributes.year  = 'numeric';
        }
        return newWrapper;
    }

    public static String salesforceUrl(){
        return System.Url.getSalesforceBaseUrl().toExternalForm()+'/';
    }

    public static String getFieldName(String fieldName) {
        String newFieldName = fieldName;
        if (fieldName.equalsIgnoreCase('Id')) {
            newFieldName = NAME_STRING;
        }else if (fieldName.endsWithIgnoreCase(NAME_STRING)) {
            newFieldName = fieldName.removeEndIgnoreCase(NAME_STRING) + 'Id';
        }else if (fieldName.endsWithIgnoreCase('id')) {
            newFieldName = fieldName.removeEndIgnoreCase('id') + '.Name';
        }else if (fieldName.endsWithIgnoreCase('__c')) {
            newFieldName = fieldName.removeEndIgnoreCase('c') + 'r.Name';
        }else if (fieldName.contains('__r.')) {
            newFieldName = fieldName.substringBeforeLast('.') + '.' + 'Id';
        }
        return newFieldName;
    }
}