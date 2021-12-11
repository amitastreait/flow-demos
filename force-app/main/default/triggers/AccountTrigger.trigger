/**
 * @description       :
 * @author            : Amit Singh
 * @group             :
 * @last modified on  : 12-09-2021
 * @last modified by  : Amit Singh
**/
trigger AccountTrigger on Account (before insert, after insert, after update) {
    TriggerDispatcher.run('Account');
}