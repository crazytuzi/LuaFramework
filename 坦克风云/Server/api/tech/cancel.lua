function api_tech_cancel(request)
    local response = {}
    response.data = {}

    local uid = request.uid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTechs = uobjs.getModel('techs')
    local ret,et,tid = mTechs.cancel(request.params.slotid)
    
    local mTask = uobjs.getModel('task')
    mTask.check()

    processEventsBeforeSave()

    if ret and uobjs.save() then 	
        processEventsAfterSave()
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.techs = mTechs.toArray(true)
        response.ret = 0
        response.msg = 'Success'
        ------------------------删除消息推送 start ----------------------------------------   
        if type (request.push)=='table' and moduleIsEnabled('push') ==1 then
            if request.push.tb[3]~=nil and request.push.tb[3]==1 then
                --加速或取消删除消息
                local execRet, code=M_push.delPushMsg({bindid=request.push.binid,ts=et,id=uid..tid,appid=request.appid})
            end
            
        end
        ------------------------删除消息推送 end   ----------------------------------------   
    else			
        response.ret = -1
    end

    return response
end
