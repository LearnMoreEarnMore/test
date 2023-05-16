import { LightningElement,api,track  } from 'lwc';
import Id from '@salesforce/user/Id';
import getOrderDetails from '@salesforce/apex/OrderDetailsFetchingClass.getOrderDetails';

import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import MailingPostalCode from '@salesforce/schema/Contact.MailingPostalCode';


export default class OrderDetailsComponent extends LightningElement {


   @api recordId
   @api objectApiName
   @track userId = Id;


   data
    OrderDetails = [];
   @track processingorders;
   @track dispatchedorders;
   @track deliveredorders;
    //get all buyers without corporation details onto buyers section to display
    connectedCallback() {
       console.log('calling connected callback');
       getOrderDetails({ userId: this.userId})
       .then(result => {
           console.log('calling connected callback result',result);
           for (var key in result) {
               this.OrderDetails.push({ key: key, value: result[key] });
               console.log('key', key, result[key]);
               if(key=='Processing')
               {
                   console.log('processingorders',result[key]);
                   this.processingorders = result[key];
               }
               else if(key=='Dispatched')
               {
                   this.dispatchedorders =result[key];
               }
               else if(key=='Delivered')
               {
                   this.deliveredorders =result[key];
               }
           }
        console.log('processingorders in line 41', this.processingorders);
        console.log('dispatchedorders',this.dispatchedorders);
        console.log('processingorders',this.deliveredorders);
       })
       .catch(error => {
           console.log(error);
       });
   }
  
}