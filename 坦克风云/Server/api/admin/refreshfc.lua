function api_admin_refreshfc(request)   
 local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
   local uid = request.uid 
   local uobjs = getUserObjs(uid)
   regEventBeforeSave(uid,'e1')
  
   processEventsBeforeSave()

   if uobjs.save() then
        processEventsAfterSave()
        response.ret = 0        
        response.msg = 'Success'
   end

   return response
end