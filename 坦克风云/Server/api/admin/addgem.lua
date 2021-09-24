function api_admin_addgem(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)
    local nums = tonumber(request.params.nums) or 0

    if uid == nil or nums < 1 then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local oldGems  =  mUserinfo.gems
    local ret = mUserinfo.addResource({gems=nums})
    
    if ret and uobjs.save() then 
        processEventsAfterSave()
        response.data.currGems =mUserinfo.gems
        response.data.oldGems = oldGems
        response.ret = 0        
        response.msg = 'Success'
    end

    return response
end