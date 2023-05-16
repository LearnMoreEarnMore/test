public class ScheduleApexJob implements Schedulable {
   
   public void execute(SchedulableContext SC) {
      CompositeOrderBatchToDelete cobd= new CompositeOrderBatchToDelete(); 
       Database.executeBatch(cobd);
   }
    
}