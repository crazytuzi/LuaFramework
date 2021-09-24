--[[
    获取新的军团战的战场信息

    前端设部队/买buff等操作都是在进入战场后操作,进战场时应该要做报名验证,
    但是没有做,因为进战场的操作频繁,而且玩家只是获取数据显示,不涉及数据修改,前端做验证就行了
]]
function api_alliancewarnew_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            alliancewar = {}
        },
    }

    local uid = tonumber(request.uid)
    local positionId = tonumber(request.params.positionId) -- 战场
    local init = request.params.init

    if uid == nil or positionId == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid,true)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","useralliancewar"})
    local mUserAllianceWar = uobjs.getModel('useralliancewar')
    local mAllianceWar = require "model.alliancewarnew"

    local warId = mAllianceWar.getWarId(positionId)

    -- 已结束
    if mAllianceWar.getOverBattleFlag(warId) then
        response.ret = 0
        response.msg = 'Success'
        response.data.alliancewar.isover = 1
        return response
    end
    
    -- 开放状态
    local warOpenStatus = mAllianceWar.getWarOpenStatus(positionId,warId)
    if warOpenStatus ~= 0 then
        response.ret = warOpenStatus
        return response
    end

    -- if init then
        mAllianceWar.joinAllianceWar(warId,uid)
    -- end

    -- 当前分数
    local placePoint,positionInfo = mAllianceWar.getAllPlacePoint(positionId,warId)
    local point = mAllianceWar.getPositionPoints(warId)

    for k,v in pairs(point) do 
        point[k] = (point[k] or 0) + (placePoint[k] or 0)
    end

    response.data.alliancewar.positionInfo = mAllianceWar.formatPlacesDataForClient(positionInfo)
    response.data.alliancewar.positionInfo.point = point
    response.data.useralliancewar = mUserAllianceWar.toArray(true)
    response.ret = 0
    response.msg = 'Success'

    return response
end
