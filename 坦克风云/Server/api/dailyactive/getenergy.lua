--
-- 免费获取疲劳值
-- User: luoning
-- Date: 15-2-4
-- Time: 上午11:27
--

function api_dailyactive_getenergy(request)

    local aname = 'getenergy'
    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid or 0
    local dtype = tonumber(request.params.dtype) or 1

    if uid == 0 then
        response.ret = -102
        response.msg = 'uid invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","dailyenergy"})
    local userinfo = uobjs.getModel('userinfo')
    local mDailyEnergy = uobjs.getModel('dailyenergy')

    -- 判断玩家能否领取体力  当前体力上限值是200 如果此时199 则领取的值直接累加 超过200且保留
    local maxEnergy = getConfig("player.maxEnergy")
    if userinfo.energy>=maxEnergy then
        response.ret = -2038
        response.msg = 'energy is enough'
        return response
    end

    local weelTs = getWeeTs()
    local nowTime = getClientTs()
    local activeCfg = getConfig("dailyactive.getEnergyNoonCfg")
    local moduleName = "drew1"
    if dtype == 2 then
         activeCfg = getConfig("dailyactive.getEnergyNightCfg")
         moduleName = "drew2"
    end

    --每日答题开关
    if moduleIsEnabled(moduleName)==0 then
        response.ret = -9000
        return response
    end

    local st = weelTs + activeCfg.opentime[1][1] * 3600 + activeCfg.opentime[1][2] * 60
    local et = weelTs + activeCfg.opentime[2][1] * 3600 + activeCfg.opentime[2][2] * 60

    if nowTime < st or nowTime > et then
        return response
    end

    if not mDailyEnergy.info.r then
        mDailyEnergy.info.r = {0,0 }
        mDailyEnergy.info.t = 0
    end

    --每天重置
    if mDailyEnergy.info.t < weelTs then
        mDailyEnergy.info.r = {0,0 }
        mDailyEnergy.info.t = weelTs
    end

    --已经领奖
    if mDailyEnergy.info.r[dtype] and mDailyEnergy.info.r[dtype] == 1 then
        response.ret = -30001
        return response
    end

    --添加奖励
    if not takeReward(uid, activeCfg.serverReward.reward) then
        return response
    end

    --记录已经领奖
    mDailyEnergy.info.r[dtype] = 1

    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response
end
