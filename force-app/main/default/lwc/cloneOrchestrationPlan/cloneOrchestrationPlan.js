import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord } from 'lightning/uiRecordApi';
import invokeMethod from "@salesforce/apex/CloneOrchestrationScenario.invokeMethod";

const FIELDS = ["vlocity_cmt__OrchestrationScenario__c.Name"];


export default class MultiStepForm extends LightningElement {
    @api editable;
    @track stepOne = true;
    @track stepTwo = false;
    @track stepFinal = false;
    @track stepSpinner = true;
    @track scenarioName = '';
    @track stepTwoInput = '';
    @track selectedProductId = null;

    @track scenariosMap = [];
    @track scenariosWithProducts = [];
    @track error;

    @api recordId; // Record Id passed from the page

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ data, error }) {
        // Check if recordId is defined
        if (this.recordId) {
            if (data) {
                console.log('Record details:', data);
                console.log('Scenario Name:', data.fields.Name.value);
                this.scenarioName = data.fields.Name.value;
            } else if (error) {
                console.error('Error fetching record details', error);
            }
        }
    }

    handleTextChange(event) {
        this.scenarioName = event.target.value;
    }

    handleNext() {
        this.callInvokeMethod({recordId: this.recordId, methodName: 'getScenarios'});

        this.stepOne = false;
        this.stepTwo = true;
    }
    handlePicker(event){
        this.selectedProductId = event.detail.recordId;
    }
    get isNextButtonDisabled() {
        return !this.selectedProductId || !this.scenarioName;
    }

    handleStepTwoInput(event) {
        this.stepTwoInput = event.target.value;
    }
    handleProductSelected(event) {
        console.log('handleProductSelected');
        const { scenarioId, productId, scenarioNewName } = event.detail;
        console.log(`Scenario ID: ${scenarioId}, Product2 ID: ${productId}, Scneario Name: ${scenarioNewName}`);

        // Check if a map with the same scenarioId already exists
        const existingIndex = this.scenariosWithProducts.findIndex(item => item.scenarioId === scenarioId);

        if (existingIndex !== -1) {
            // Update the existing map
            console.log('existing index', { 'scenarioId': scenarioId, 'productId': productId, 'scenarioNewName': scenarioNewName});
            this.scenariosWithProducts[existingIndex] = { 'scenarioId': scenarioId, 'productId': productId, 'scenarioNewName': scenarioNewName};
        } else {
            // Add a new map
            console.log('not existing index true', { 'scenarioId': scenarioId, 'productId': productId, 'scenarioNewName': scenarioNewName});

            this.scenariosWithProducts.push({ 'scenarioId': scenarioId, 'productId': productId, 'scenarioNewName': scenarioNewName });

        }

        console.log('Updated scenariosWithProducts:', this.scenariosWithProducts);
    }

    handleClone() {
        // example scenariosWithProducts = [{ 'scenarioId': a3l123123123, 'productId': at3a123123123, 'scenarioNewName': TEST }, {...}]
        const jsonStringScenariosMap = JSON.stringify(this.scenariosWithProducts);
        console.log('handleClone scenariosJSON -> ' + jsonStringScenariosMap);
        this.callInvokeMethod({scenariosMap: jsonStringScenariosMap, methodName: 'cloneScenarioWithNewName'});

        this.stepTwo = false;
        this.stepFinal = true;
    }

    callInvokeMethod(params){
        console.log('invokeMethod', params);
        this.error = null;
        invokeMethod({input: params})
            .then((result) => {
                if(params.methodName == 'getScenarios'){
                    this.scenariosMap = result.scenariosMap;
                }
                console.log('result', result);
                this.stepSpinner = false;
            })
            .catch((error) => {
                this.error = error.body.exceptionType + ': ' + error.body.message;
                this.stepOne = true;
                this.stepTwo = false;
                this.stepFinal = false;
                console.log('error', error);
            })
    }

    connectedCallback() {
        console.log('connectedCallback');
    }
}