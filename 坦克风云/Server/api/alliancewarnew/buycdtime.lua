-- 购买CD时间
function api_alliancewarnew_buycdtime(request)
    local response = {
        ret=-1,
        msg='error',
        data = {alliancewar={}},
    }

    -- 军团战功能关闭
    if moduleIsEnabled('alliancewarnew') == 0 then
        response.ret = -4012
        return response
    end

    local uid = tonumber(request.uid)

    if uid == nil then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","useralliancewar"})        
    local mUserAllianceWar = uobjs.getModel('useralliancewar')    
    local allianceWarCfg = getConfig('allianceWar2Cfg')

    local mAllianceWar = require "model.alliancewarnew"

    -- 已结束
    if mAllianceWar.getOverBattleFlag(mUserAllianceWar.bid) then
        response.ret = 0
        response.msg = 'Success'
        response.data.alliancewar.isover = 1
        return response
    end
    
    local ts = getClientTs()
    local times = mUserAllianceWar.cdtime_at + allianceWarCfg.cdTime - ts

    if times > 0 then
        local gemCost = math.ceil(times / 10)
        local mUserinfo = uobjs.getModel('userinfo')

        if not mUserinfo.useGem(gemCost) then
            response.ret = -109 
            return response
        end

        -- 30 购买cd时间   
        --日常任务
        local mDailyTask = uobjs.getModel('dailytask')
        --新的日常任务检测
        mDailyTask.changeNewTaskNum('s402',1)
        regActionLogs(uid,1,{action=30,item="",value=gemCost,params={buyNum=times}})
    end

    mUserAllianceWar.setCdTimeAt(ts - allianceWarCfg.cdTime)
    processEventsBeforeSave()

    if uobjs.save() then
        processEventsAfterSave()
        response.data.useralliancewar = mUserAllianceWar.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
