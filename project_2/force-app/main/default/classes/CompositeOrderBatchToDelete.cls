public class CompositeOrderBatchToDelete implements Database.Batchable<Sobject> {
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
         Date thirtyDaysAgo = Date.today().addDays(-30);
        String query = 'SELECT Id FROM composite_orders__c WHERE CreatedDate< :thirtyDaysAgo AND Status__c != \'Failed\'';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc,List<composite_orders__c> scope)
    {
        delete scope;
    }	
    public void finish(Database.BatchableContext bc)
    {
      system.debug('Batch Job successfully ran');  
    }
}