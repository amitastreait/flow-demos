/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement,api } from 'lwc';
import saveSign from '@salesforce/apex/SignatureLwcHelper.saveSignature';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

let isDownFlag,
isDotFlag = false,
prevX = 0,
currX = 0,
prevY = 0,
currY = 0;

let x = "#0000A0"; //blue color to show the signature
let y = 1.5; //weight of line width and dot.

let canvasElement, ctx; //storing canvas context
let dataURL,convertedDataURI; //holds image data

export default class CaptureSignatureController extends LightningElement {

    @api recordId;
    @api ContentVersionData;
    @api contentVersionId;

    isSpinner = false;
    //event listeners added for drawing the signature within shadow boundary
    constructor() {
        super();
        this.template.addEventListener('mousemove', this.handleMouseMove.bind(this));
        this.template.addEventListener('mousedown', this.handleMouseDown.bind(this));
        this.template.addEventListener('mouseup', this.handleMouseUp.bind(this));
        this.template.addEventListener('mouseout', this.handleMouseOut.bind(this));
    }

    //retrieve canvase and context
    renderedCallback(){
        canvasElement = this.template.querySelector('canvas');
        ctx = canvasElement.getContext("2d");
    }

    //handler for mouse move operation
    handleMouseMove(event){
        this.searchCoordinatesForEvent('move', event);
    }

    //handler for mouse down operation
    handleMouseDown(event){
        this.searchCoordinatesForEvent('down', event);
    }

    //handler for mouse up operation
    handleMouseUp(event){
        this.searchCoordinatesForEvent('up', event);
    }

    //handler for mouse out operation
    handleMouseOut(event){
        this.searchCoordinatesForEvent('out', event);
    }

    handleSaveClick(){
        //set to draw behind current content
        ctx.globalCompositeOperation = "destination-over";
        ctx.fillStyle = "#FFF"; //white
        ctx.fillRect(0,0,canvasElement.width, canvasElement.height);

        //convert to png image as dataURL
        dataURL = canvasElement.toDataURL("image/png");
        //convert that as base64 encoding
        convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
        this.ContentVersionData = convertedDataURI;
        //call Apex method imperatively and use promise for handling sucess & failure
        this.isSpinner = true;
        saveSign({
            ContentVersionData: convertedDataURI,
            recordId : this.recordId
        })
        .then(result => {
            this.contentVersionId = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Salesforce File created with Signature',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            console.log('error : ',error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating Salesforce File record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        })
        .finally(() => {
            this.isSpinner = false;
        });
    }

    //clear the signature from canvas
    handleClearClick(){
        ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);
    }

    searchCoordinatesForEvent(requestedEvent, event){
        event.preventDefault();
        if (requestedEvent === 'down') {
            this.setupCoordinate(event);
            isDownFlag = true;
            isDotFlag = true;
            if (isDotFlag) {
                this.drawDot();
                isDotFlag = false;
            }
        }
        if (requestedEvent === 'up' || requestedEvent === "out") {
            isDownFlag = false;
        }
        if (requestedEvent === 'move') {
            if (isDownFlag) {
                this.setupCoordinate(event);
                this.redraw();
            }
        }
    }

    setupCoordinate(eventParam){
        const clientRect = canvasElement.getBoundingClientRect();
        prevX = currX;
        prevY = currY;
        currX = eventParam.clientX -  clientRect.left;
        currY = eventParam.clientY - clientRect.top;
    }

    redraw() {
        ctx.beginPath();
        ctx.moveTo(prevX, prevY);
        ctx.lineTo(currX, currY);
        ctx.strokeStyle = x; //sets the color, gradient and pattern of stroke
        ctx.lineWidth = y;
        ctx.closePath(); //create a path from current point to starting point
        ctx.stroke(); //draws the path
    }
    //this draws the dot
    drawDot(){
        ctx.beginPath();
        ctx.fillStyle = x; //blue color
        ctx.fillRect(currX, currY, y, y); //fill rectrangle with coordinates
        ctx.closePath();
    }
}
