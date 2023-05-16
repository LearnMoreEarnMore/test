public class IncomingCompositeOrderProcess implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        string query ='SELECT Product_Description__c,BillToContact__c,Customer_City__c,Customer_Code__c, Customer_Country__c, Customer_Email__c, Customer_Name__c, Customer_Phone__c, Customer_Postal_Code__c, Customer_State__c, Customer_Street__c, Expected_Delivery_Date__c, Id, Order_Purchase_Date__c, Product_Code__c, Name, Product_Price__c, Product_Type__c, Quantity__c, Sales_Order__c, Shipping_City__c, Shipping_Country__c, Shipping_Postal_Code__c, Shipping_State__c, Shipping_Street__c, Status__c FROM composite_orders__c where Status__c !=\'Processed\' and Product_Type__c=\'K\' ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc,List<composite_orders__c> comprodlist )
    {
        List <composite_orders__c> validCompositeOrders = new List<composite_orders__c>();
        List <composite_orders__c> inValidCompositeOrders = new List<composite_orders__c>();
        /** 
            * Reviewed By Naresh Polimera
            * !: Always use Username instead of Name.
            * TODO: Tweek this below code.
        */
       // id opsowner=[SELECT Id FROM User where Name='ops Manager'].Id; 
       id opsowner=[SELECT Id,Username FROM User where Username='opsmanager123@gmail.com'].Id;//changed code
        for(Integer i=0;i<comprodlist.size();i++) {
            
            /**
            * Reviewed By Naresh Polimera
            * !: Query in LOOP is Harmful.
            */
            Boolean isValid = isValidProductOrNot(comprodlist[i].Product_Code__c);
            if(!isValid) {
                system.debug('Is Not A Valid Product:'+comprodlist[i].Product_Code__c); 
                comprodlist[i].Status__c= 'Error - Product entry not exists in Products/pricebook or not active';
                comprodlist[i].OwnerId= opsowner;
                inValidCompositeOrders.add(comprodlist[i]);
            }
            else
                validCompositeOrders.add(comprodlist[i]);
            system.debug('Is Valid Product :'+comprodlist[i].Product_Code__c);
        }
        update inValidCompositeOrders;
        createAccounts(validCompositeOrders);
        createOrders(validCompositeOrders);
        createOrderLineItems(validCompositeOrders);
    }
    Public void finish(Database.BatchableContext bc)
    {

    }
    /*** Method to check ordered product exist in both product and pricebookentry  ***/
    public static Boolean isValidProductOrNot(string prodCode)
    {
        Boolean isValid = True;
        list<product2> prodlst = new list<product2>([SELECT Id, Name, ProductCode, IsActive FROM Product2 where productcode =:prodCode and IsActive=true]);
        /**
        * Reviewed By Naresh Polimera
        * TODO: Tweek this below code.
        */
        if(prodlst.size() == 0){
            isValid = False;
        }
        else if(prodlst.size() > 0){
            /**
            * Reviewed By Naresh Polimera
            * !: Never Use Hard coded values in the Query.
            * !: Get Only count instead of multiple fields based on functionality.
            * TODO: Not a good Practice.
            */
            list<pricebookEntry> pribklst = new list<pricebookEntry>([SELECT Id, Name, IsActive, Pricebook2Id FROM PricebookEntry where Pricebook2Id =:'01s5i00000EdDGeAAN' 
            and productcode =:prodCode and IsActive=true]);
            /**
            * Reviewed By Naresh Polimera
            * TODO: use Ternary Operator
            */
            if(pribklst.size()>0)
                isValid = True;
            else
                isValid = False;
        }
        return isValid;
    }
    /**** Create Account ****/  
    public static void createAccounts(list<composite_orders__c> validCompositeOrders)
    {
        // personal Account creation
        list<Account> lstacc = new list<Account>();
        /**
        * Reviewed By Naresh Polimera
        * !: Remove uncessary field or list and SOQL that are not being using.
        */
        // if already there is an email and account is created once if again comporders comes it again creates account to avoid this below code is used.
       list<Account> accEmailLst = new list<Account>([SELECT PersonEmail FROM Account ]);
        set<String> emailSet = new set<String>();
        for(composite_orders__c co:validCompositeOrders)
        {
            if(!emailSet.contains(co.Customer_Email__c))
            {
                emailSet.add(co.Customer_Email__c);
                /**
* Reviewed By Naresh Polimera
* !: Use Aggregate Query
*/
   /*SELECT Id, Name, AccountNumber, PersonEmail FROM Account WHERE Name = :co.BillToContact__c AND PersonEmail = :co.Customer_Email__c
    GROUP BY Id, Name, AccountNumber, PersonEmail;*/

                list<Account> acc = [SELECT Id, Name, AccountNumber, PersonEmail FROM Account where  Name = :co.BillToContact__c and PersonEmail =: co.Customer_Email__c ]; 
                if(acc.isEmpty())
                {
                    Account a = new Account();
                    a.LastName = co.BillToContact__c;
                    a.PersonEmail = co.Customer_Email__c;
                    a.Website = co.Customer_Code__c;
                    a.Phone = co.Customer_Phone__c;
                    lstacc.add(a);
                }
            }
        } 
        if(!lstacc.isempty()) 
            insert lstacc;
    }
    /**** Order Creation ****/
    public static void createOrders(list<composite_orders__c> validCompositeOrders)
    {
        list<Order> ordlst = new list<Order>();
        id pricebookid =[SELECT Id FROM Pricebook2 where Name='Standard Price Book' limit 1].Id;
        list<composite_orders__c> colst = new list<composite_orders__c>();
        
        for(composite_orders__c co:validCompositeOrders)
        {
            Order ord = new Order();
            ord.Name=co.Product_Description__c;
            ord.Status='Draft';
            ord.Pricebook2Id=pricebookid;
            ord.Order_Amount__c=co.Product_Price__c;
            ord.ShippingStreet=co.Shipping_Street__c;
            ord.ShippingCity=co.Shipping_City__c;
            ord.ShippingCountry=co.Shipping_Country__c;
            ord.ShippingState=co.Shipping_State__c;
            ord.ShippingPostalCode=co.Shipping_Postal_Code__c;
            ord.BillingCity=co.Customer_City__c;
            ord.BillingCountry=co.Customer_Country__c;
            ord.BillingState=co.Customer_State__c;
            ord.BillingStreet=co.Customer_Street__c;
            ord.BillingPostalCode=co.Customer_Postal_Code__c;
            ord.Vendor_Order_Number__c=co.Sales_Order__c;
            ord.EffectiveDate=co.Order_Purchase_Date__c;
            ord.Customer_Name__c=co.Customer_Name__c;
            ord.Contact_Phone_Number__c=co.Customer_Phone__c;
            list<Account> accs = [SELECT Id,Name,PersonEmail FROM Account where PersonEmail =: co.Customer_Email__c];
            ord.AccountId = accs[0].Id;
            ordlst.add(ord);
            
            co.Status__c='Processed';
            colst.add(co);
            
        }
        
        if(!ordlst.isempty())
        {
            system.debug('insert'+ordlst);
            insert ordlst;
            system.debug('inserted'+ordlst);
            update colst;
        }
    }
    /**** order line items creation ****/
    public void createOrderLineItems(list<composite_orders__c> validCompositeOrders)
    {
        
        list<OrderItem> ordlineitemslst = new list<OrderItem>();
        id pricebookid =[SELECT Id FROM Pricebook2 where Name='Standard Price Book' limit 1].Id;
        list<Product2> prodlist = new list<Product2>([SELECT Id, ProductCode FROM Product2]);
        list<PricebookEntry> prlist = new list<PricebookEntry>([SELECT Id, Name,Pricebook2Id, ProductCode, UnitPrice FROM PricebookEntry where Pricebook2Id =:pricebookid]);
        map<string,PricebookEntry> PricebookEntrymap = new map<string,PricebookEntry>();
        for(PricebookEntry p:prlist)
        {
            PricebookEntrymap.put(p.ProductCode, p);
        }
        
        for(composite_orders__c co:validCompositeOrders )
        {
            id orderid =[SELECT Id FROM Order where Vendor_Order_Number__c =:co.Sales_Order__c].Id;
            Id baseprod =[select Id from Product2 where ProductCode=:co.Product_Code__c].Id;
            list<Product2> prodlineitems =[select Id,ProductCode from Product2 where SourceProductId=:baseprod];
            for(Product2 pl : prodlineitems)
            {
                OrderItem o = new OrderItem();
                o.Product2Id= pl.Id;
                o.OrderId=orderid;
                o.PricebookEntryId=PricebookEntrymap.get(pl.ProductCode).id;
                o.UnitPrice=PricebookEntrymap.get(pl.ProductCode).UnitPrice;
                o.Quantity=co.Quantity__c;
                ordlineitemslst.add(o);
            }
        }
        composite_orders__c[] lineitems=  [SELECT  Sales_Order__c, Status__c FROM composite_orders__c where Product_Type__c='R' and Status__c!='Processed'];
        for(composite_orders__c olstatusupdate : lineitems)
        {
            olstatusupdate.Status__c='Processed';
        }
        if(!ordlineitemslst.isEmpty())
        {
            insert ordlineitemslst;
            update lineitems;
        }
    }

    public void createOrderLineItemsTest(list<composite_orders__c> validCompositeOrders)
    {
        List<string> lstProductCodes = new List<string>();
        List<double> lstOrderNumbers = new List<double>();
        Map<string, Id> mapProductIdByCode = new map<String, Id>();
        for(composite_orders__c co : validCompositeOrders)
        {
            lstProductCodes.add(co.Product_Code__c);
            lstOrderNumbers.add(co.Sales_Order__c);
        }
        List<Product2> lst = [SELECT ID, PRODUCTCODE FROM PRODUCT2 WHERE PRODUCTCODE IN:lstProductCodes ];
        List<Order> lstOrders = [select id from order where Vendor_Order_Number__c in: lstOrderNumbers ];
        for(Product2 prod: lst) {
            mapProductIdByCode.put(prod.PRODUCTCODE,prod.Id);
        }
        Map<double, Id> mapOrderIdBySalesOrderNumber = new map<double, Id>();

        for(Order ord : lstOrders) {
            mapOrderIdBySalesOrderNumber.put(ord.Vendor_Order_Number__c,ord.Id);
        }
        for(composite_orders__c co : validCompositeOrders)
        {
            OrderItem o = new OrderItem();
            o.Product2Id= mapProductIdByCode.get(co.Product_Code__c);
            o.OrderId = mapOrderIdBySalesOrderNumber.get(co.Sales_Order__c);
            o.Quantity=co.Quantity__c;
            //o.PricebookEntryId=PricebookEntrymap.get(pl.ProductCode).id;
           // o.UnitPrice=PricebookEntrymap.get(pl.ProductCode).UnitPrice;
        }
    }
}