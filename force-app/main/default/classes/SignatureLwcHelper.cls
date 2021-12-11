public with sharing class SignatureLwcHelper {

    @AuraEnabled
    public static String saveSignature(String ContentVersionData, Id recordId){

        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = 'Signature-'+System.now() +'.png';
        cVersion.Origin = 'H';
        cVersion.Title = 'Signature-'+System.now() +'.png';
        cVersion.VersionData = EncodingUtil.base64Decode(ContentVersionData);
        Insert cVersion;

        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;
        cDocLink.LinkedEntityId = recordId;
        cDocLink.ShareType = 'I';
        cDocLink.Visibility = 'AllUsers';
        Insert cDocLink;

        return cVersion.Id;
    }
}