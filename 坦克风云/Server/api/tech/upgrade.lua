function api_tech_upgrade(request)
    local response = {}
    response.data={}
    
     local uid = request.uid
    local tid = 't' .. request.params.tid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTechs = uobjs.getModel('techs')
    
    local ret,et,lvl = mTechs.upgrade(tid)
        
    local mTask = uobjs.getModel('task')
    mTask.check()

    processEventsBeforeSave()

    if ret and uobjs.save() then 
        processEventsAfterSave()
        response.data.techs = mTechs.toArray(true)
        response.data.userinfo = mUserinfo.toArray(true)
        response.ret = 0	    
        response.msg = 'Success'
         ------------------------消息推送 start ----------------------------------------   
        if type (request.push)=='table' and moduleIsEnabled('push') ==1 then
            if request.push.tb[3]~=nil and request.push.tb[3]==1 then

                local execRet, code=M_push.addPushMsg({bindid=request.push.binid,ts=et,t=2,pt=request.system,lag=request.lang,msg=tid,id=uid..tid,l=lvl,appid=request.appid})
            end
        end
        ------------------------消息推送 end   ----------------------------------------   
    else
        response.ret = -1
        response.msg = uobjs.msg
    end
    
    return response
end	