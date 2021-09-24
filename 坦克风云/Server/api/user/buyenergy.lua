function api_user_buyenergy(request)
    local response = {}
    response.data={}

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local ret,iGems,buyNum = mUserinfo.buyEnergy()
    
    local mTask = uobjs.getModel('task')
    mTask.check()
    
    -- 春节攀升埋点
    activity_setopt(uid, 'chunjiepansheng', {action='tl'})
    --粽子作战 记录购买体力次数
    activity_setopt(uid, 'zongzizuozhan', {u=uid,action='log',num=1})
    -- 悬赏任务
    activity_setopt(uid,'xuanshangtask',{t='',e='tl',n=1})      
    -- 愚人节大作战-购买X次体力
    activity_setopt(uid,'foolday2018',{act='task',tp='tl',num=1})

    regActionLogs(uid,1,{action=3,item='energy',value=iGems,params={energyNum=mUserinfo.energy,buyNum=buyNum}})
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
