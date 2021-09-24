-- 获取任务列表
function api_fleetgo_tasklist(request)
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
    local km = request.params.km
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local cfg = getConfig('fleetgo')
    local Cfg = copyTab(cfg)
    if type(mUserinfo.flags.task)~='table' or not next(mUserinfo.flags.task) then
        mUserinfo.flags.task={}
        for k,v in pairs(Cfg.serverreward.achievement) do
            mUserinfo.flags.task[k]={}
            mUserinfo.flags.task[k].index=v[1].index
            mUserinfo.flags.task[k].r=0 --0未完成、1可领取、2已领取
            mUserinfo.flags.task[k].p=1 --进度 1,2,3
            mUserinfo.flags.task[k].cur=0 --当前数量
        end
    end
    local taskCfg=Cfg.serverreward.achievement
    -- ptb:e(taskCfg)
    for k,v in pairs(mUserinfo.flags.task) do
        local info=taskCfg[k][v.p]
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
        response.ret = 0
        response.msg = 'Success'
    end
    return response

end