/**
 * @description       :
 * @author            : Amit Singh
 * @group             :
 * @last modified on  : 12-08-2021
 * @last modified by  : Amit Singh
**/
import { LightningElement, api } from 'lwc';

export default class Rating extends LightningElement {
    static value;
    @api name;
    @api ratingValue;

    connectedCallback(){
        let inputs = [...this.template.querySelectorAll('input')];
        inputs.forEach( ( item, index, originalArray ) => {
            console.log(item.id);
        });
    }

    rating(event) {
        Rating.value = event.target.value;
        const eventRating = new CustomEvent('rating', {
            detail: {
                ratingValue : Rating.value,
                name        : this.name
            }
        });
        this.dispatchEvent(eventRating);
    }
}