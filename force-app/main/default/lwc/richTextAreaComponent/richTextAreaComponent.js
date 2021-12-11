/**
 * @description       :
 * @author            : Amit Singh
 * @group             :
 * @last modified on  : 12-08-2021
 * @last modified by  : Amit Singh
**/
import { LightningElement, api } from 'lwc';

export default class RichTextAreaComponent extends LightningElement {
    @api placeholder;
    @api value;
    @api label;
    @api required;
    requiredMessage = '⚠️ Value is required for this field';
    _validity = true;

    handleChange = (event)=>{
        event.preventDefault();
        this.value = event.target.value;
    }

    @api
    validate() {
        if( this.validateInput() ) {
            return {
                isValid: true
            };
        } else {
            return {
                isValid: false,
                errorMessage: this.requiredMessage
            };
        }
    }

    validateInput(){
        if(!this.value){
            this._validity = false;
        }else{
            this._validity = true;
        }
        return this._validity;
    }
}