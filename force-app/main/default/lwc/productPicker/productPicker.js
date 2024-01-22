import { LightningElement, api, track } from 'lwc';

export default class ProductPicker extends LightningElement {
    @api label;
    @api pickerscenarioid;
    @api pickerselectedname;
    @track pickerselectedproductId;

    picker_handleRecordPick(event) {
        this.pickerselectedproductId = event.detail.recordId;
        console.log('picker_handleRecordPick pickerselectedproductId:', this.pickerselectedproductId);

        // Notify the parent component about the selected Product2
        this.sendData();
        
        
    }

    picker_handleTextChange(event) {
        this.pickerselectedname = event.target.value;
        this.sendData();
    }

    sendData(){
        console.log('sendData', 
        { 
            'pickerscenarioid': this.pickerscenarioid,
            'pickerselectedproductId': this.pickerselectedproductId,
            'pickerselectedname': this.pickerselectedname
        });

        const productSelectedEvent = new CustomEvent('productselected', {
            detail: {
                scenarioId: this.pickerscenarioid,
                productId: this.pickerselectedproductId,
                scenarioNewName: this.pickerselectedname
            }
        });
        this.dispatchEvent(productSelectedEvent);
    }
}