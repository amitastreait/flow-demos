/**
 * @description       : 
 * @author            : Amit Singh
 * @group             : 
 * @last modified on  : 12-11-2021
 * @last modified by  : Amit Singh
**/
import { api, LightningElement } from 'lwc';

export default class RichTextLwc extends LightningElement {
    @api label;
    @api placeholder;
    @api value;
    @api required;

    handleChange = event => {
        event.preventDefault();
        this.value = event.target.value;
    }

    @api
    validate(){
        
        if(this.value){ // theres is something in the textarea inout
            return {
                isValid: true
            };
        }else{
            return {
                isValid: false,
                errorMessage: '⚠️ Value is required for this field'
            };
        }
        
    }
}