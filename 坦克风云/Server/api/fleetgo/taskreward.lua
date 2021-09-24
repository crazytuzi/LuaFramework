-- 领取任务奖励
function api_fleetgo_taskreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    if moduleIsEnabled('fleetgo') == 0 then
        response.ret = -180
        return response
    end
    local uid = request.uid
    local taskType = request.params.type --任务类型
    local taskP=request.params.p -- 任务进度
    if not uid then
        response.ret = -102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local cfg = getConfig('fleetgo')
    local Cfg = copyTab(cfg)
    local taskList = Cfg.serverreward.achievement
    local taskCfg=taskList[taskType][taskP]

    if type(taskCfg)~='table' or not next(taskCfg) then
        response.ret=-102
        return response
    end
    local curtask=mUserinfo.flags.task[taskType]
    -- 验证任务信息
    if type(curtask)~='table' or not next(curtask) or curtask.p~=taskP then
        response.ret=-102
        return response
    end
    -- 判断条件
    if curtask.r~=1 then
        response.ret=-102
        return response
    end

    local reward={}
    for k,v in pairs(taskCfg.serverreward)  do
        reward[k]=(reward[k] or 0)+v
    end
    if  not takeReward(uid,reward) then
        response.ret=-403
        return response
    end
    if taskCfg.next then
        mUserinfo.flags.task[taskType].p=taskCfg.next
        mUserinfo.flags.task[taskType].index=taskList[taskType][taskCfg.next].index
        mUserinfo.flags.task[taskType].r=0
        mUserinfo.flags.task[taskType].con=taskList[taskType][taskCfg.next][1]
    else
        mUserinfo.flags.task[taskType].r=2
    end
    -- ptb:e(taskCfg)
    for k,v in pairs(mUserinfo.flags.task) do
        local info=taskList[k][v.p]
        if v.r==0 then
            mUserinfo.flags.task[k].con=info[1]
            if mUserinfo.flags.task[k].cur>=info[1] then
                mUserinfo.flags.task[k].r=1
            end
        end
    end
    if uobjs.save() then    
        processEventsAfterSave()
        response.data.tasklist=mUserinfo.flags.task
        response.data.reward=formatReward(reward)
        response.ret = 0
        response.msg = 'Success'
    end
    return response

end