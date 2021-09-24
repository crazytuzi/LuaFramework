function api_accessory_list(request)
  local response = {
    ret=-1,
        msg='error',
        data = {},
  }

  local uid = request.uid
  if not uid or uid<=0 then
    response.ret=-102
    return response
  end
    
  if moduleIsEnabled('ec') == 0 then
      response.ret = -9000
      return response
  end

  local uobjs = getUserObjs(uid)
  uobjs.load({"accessory"})
  local mAccessory = uobjs.getModel('accessory')

  response.data.accessory = mAccessory.toArray(true)
  response.ret = 0	    
  response.msg = 'Success'
 
    
  return response


















end