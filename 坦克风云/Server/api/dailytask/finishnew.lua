--  新的每日任务完成
function api_dailytask_finishnew(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mDailytask = uobjs.getModel('dailytask')
    local mUserinfo = uobjs.getModel('userinfo')
    local status,cost,rais = mDailytask.finishnew(request.params.taskid,request.params.useGem,mUserinfo.level)
    response.data.status = status

    local mTask = uobjs.getModel('task')
    mTask.check()

    -- actionlog
    if request.params.useGem and cost and cost > 0 then
        regActionLogs(uid,1,{action=18,item="dailytaskfinish",value=cost,params={}})
    end
     
    processEventsBeforeSave()
    if status==1 and uobjs.save() then 
        local mBag = uobjs.getModel('bag')
        local mTroop = uobjs.getModel('troops')
        response.data.troops = mTroop.toArray(true)      
        response.data.bag = mBag.toArray(true)
        response.data.userinfo = mUserinfo.toArray(true)        
        response.data.dailytask = mDailytask.toArray(true) 
        processEventsAfterSave()
        response.ret = 0
        response.data.rais=rais
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end

    return response
end
