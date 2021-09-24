-- 获取异星矿山的信息
    -- 玩家的攻击，掠夺次数等
function api_alienmine_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task"})
    local mTroop = uobjs.getModel('troops')

    local alienMineBattleInfo = mTroop.getAlienMineBattleInfo()
    local alienMineCfg = getConfig("alienMineCfg") 

    processEventsBeforeSave()

    response.data.alienmineGet = alienMineBattleInfo
    response.data.alienmineCfg = {
        startTime = alienMineCfg.startTime,
        endTime = alienMineCfg.endTime,
        openTime = alienMineCfg.openTime,
        dailyOccupyNum=alienMineCfg.dailyOccupyNum, -- 每日占领的次数
        dailyRobNum=alienMineCfg.dailyRobNum, -- 每日掠夺的次数
    }

    response.ret = 0
    response.msg = 'Success'
    
    return response
end	