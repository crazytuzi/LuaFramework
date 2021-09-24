function api_user_buygrow(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})
    local mUserinfo = uobjs.getModel('userinfo')
   
   
    if moduleIsEnabled('gw') == 0 then
        response.ret = -9000
        return response
    end

    if mUserinfo.grow==1 then
        response.ret = -1987 
        return response
    end
    local usegems = tonumber(getConfig('player.buygrowgems')) 

    if usegems <= 0 then
        response.ret = -120
        return response 
    end

    --ptb:p(mUserinfo)
    local ret =mUserinfo.useGem(usegems)

    if not ret then
        response.ret = -1996
        return response 
    end
    mUserinfo.grow=1
    regActionLogs(uid,1,{action=5001,item='buygrow',value=usegems,params={}})
    processEventsBeforeSave()

    if ret and uobjs.save() then
        processEventsAfterSave()
        response.ret = 0
        response.data.userinfo = mUserinfo.toArray(true)
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end

    return response
end
