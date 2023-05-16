public without sharing class OrderDetailsFetchingClass {
 




  @AuraEnabled(cacheable=true)
   public static Map<String,List<Order>> getOrderDetails(Id userId){
       List<String> productIds = new List<String>();
       List<String> contentDocumentIds = new List<String>();
       List<String> orderIds = new List<String>();
       List<ContentVersion> contentDocumentVersions = new List<ContentVersion>();
       Map<String,String> contentdocmap = new  Map<String,String>();
       Map<String,List<Order>> listOfOrders = new Map<String,List<Order>>();
          //get User Details
         System.debug('userId::' +userId);
        User userRecord= [select Id,ContactId from User where Id =:userId With SECURITY_ENFORCED];
        System.debug('userRecord.ContactId::' +userRecord.ContactId);
        //get Contact Details
        Contact conRecord = [select Id,AccountId from Contact where Id=:userRecord.ContactId With SECURITY_ENFORCED];
        System.debug('conRecord.AccountId::' +conRecord.AccountId);
        //get Order Details
       //  List<order> processingorders = [select Id,AccountId from Order where AccountId =:conRecord.AccountId AND status='Activated' With SECURITY_ENFORCED];
       //  List<order> dispatchedorders = [select Id,AccountId from Order where AccountId =:conRecord.AccountId AND status='Dispatched' With SECURITY_ENFORCED];
       //  List<order> deliveredorders = [select Id,AccountId from Order where AccountId =:conRecord.AccountId AND status='Delivered' With SECURITY_ENFORCED];
        List<order> processingorders = [select Id,AccountId,Name,OrderNumber,EffectiveDate,Status from Order];
       //  for(order o:processingorders)
       //  {
       //     orderIds.add(o.Id);
       //  }
      //  List<orderItem> orderProducts = [select Id,OrderId,Product2Id from orderItem where OrderId =: orderIds];
       //  for(orderItem op:orderProducts)
       //  {
       //     productIds.add(op.Product2Id);
       //  }
       //  List<ContentDocumentLink> cdlDocs = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: productIds];
       //  for(ContentDocumentLink c:cdlDocs)
       //  {
         
       //     ContentDocumentIds.add(c.ContentDocumentId);
       //     contentdocmap.put(c.ContentDocumentId,c.LinkedEntityId);
       //  }
       //  contentDocumentVersions =[SELECT Id, ContentDocumentId,VersionData,ContentBodyId, VersionNumber, Title FROM ContentVersion where ContentDocumentId =: ContentDocumentIds];
       //  for(ContentDocumentLink c:cdlDocs)
       //  {
       //     Map<String,String> contentvermap = new  Map<String,String>();
       //    // contentvermap.put(contentdocmap.get(c.ContentDocumentId),c.VersionData);
       //  }
       // List<order> dispatchedorders = [select Id,AccountId,Product__c from Order];
         List<order> dispatchedorders = [select Id,AccountId,Name from Order];
         List<order> deliveredorders = [select Id,AccountId,Name from Order];
      
        System.debug('orders::' +processingorders);
        System.debug('orders::' +deliveredorders);
        System.debug('orders::' +dispatchedorders);
        listOfOrders.put('Processing',processingorders);
       //  listOfOrders.put('Dispatched',dispatchedorders);
       //  listOfOrders.put('Delivered',deliveredorders);
        return listOfOrders;
       


   }
}