function api_prop_cancel(request)
    local response = {
        data = {},
    }

    local uid = request.uid
    local pid = 'p' .. request.params.pid
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local prop = uobjs.getModel('props')	
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    local ret,et = prop.cancel(pid,request.params.nums,request.params.slotid)
    
    local mTask = uobjs.getModel('task')
    mTask.check()

    if ret and uobjs.save() then
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.props = prop.toArray(true)        
        response.data.bag = mBag.toArray(true)
        response.ret = 0
        response.msg = 'Success'
        ------------------------删除消息推送 start ----------------------------------------   
        if type (request.push)=='table' and moduleIsEnabled('push') ==1 then
            if request.push.tb[4]~=nil and request.push.tb[4]==1 then
                --加速或取消删除消息
                local execRet, code=M_push.delPushMsg({bindid=request.push.binid,ts=et,id=uid..pid,appid=request.appid})
            end
            
        end
        ------------------------删除消息推送 end   ----------------------------------------   
    else
        response.ret = -1
    end

    return response
end
