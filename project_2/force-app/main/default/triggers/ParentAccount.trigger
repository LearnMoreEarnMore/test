trigger ParentAccount on Account (after insert) { 

if(Trigger.IsAfter && Trigger.IsInsert)
      {
          Id profid =[select Id from Profile where name='Portal User'].Id;
          list<user> userlst = new list<user>();
          for(Account acc : Trigger.New)
                        {
                            if(acc.IsPersonAccount==TRUE)
                                {
                                    //id conid =[select Id from Contact where Email=:acc.PersonEmail].Id;
                                    
                                    List<Contact> conLst = [Select Id from Contact where Email=:acc.PersonEmail];
                                    List<id> idLst = new List<id>();
                                    for(Contact con :conLst)
                                    {
                                        idLst.add(con.id);
                                    }
                                     id conid =idLst[0];
                                    system.debug('test1' +conid);
                                    User p = new User();
                                    p.Username=acc.PersonEmail;
                                    system.debug('test2'+acc.PersonEmail);
                                    p.LastName=acc.LastName;
                                    system.debug('test3'+acc.LastName);
                                    p.FirstName=acc.FirstName;
                                    system.debug('test4'+acc.FirstName);
                                    p.ProfileId=profid;
                                    system.debug('test5'+profid);
                                    p.Email=acc.PersonEmail;
                                    system.debug('test6'+acc.PersonEmail);
                                    p.alias=acc.LastName.mid(0, 8);
                                    system.debug('test7'+acc.LastName);
                                    p.TimeZoneSidKey='GMT';
                                    p.LocaleSidKey='en_IN';
                                    p.EmailEncodingKey='UTF-8';
                                    p.LanguageLocaleKey='en_US';
                                    p.ContactId=conid;
                                    system.debug('test8'+conid);
                                    userlst.add(p);
                                }
                        }
          
          if(!userlst.isEmpty())
          {
              system.debug('test9'+userlst);
              insert userlst;
               system.debug('test10'+userlst);
              
          }

      }
}