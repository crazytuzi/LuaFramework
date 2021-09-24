-- 重新集结部队
function api_alliancewar_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            alliancewar = {}
        },
    }

    -- 军团战功能关闭
    if moduleIsEnabled('alliancewar') == 0 then
        response.ret = -4012
        return response
    end

    local uid = tonumber(request.uid)
    local positionId = tonumber(request.params.positionId) -- 战场

    if uid == nil or positionId == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid,true)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","useralliancewar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUserAllianceWar = uobjs.getModel('useralliancewar')
    local mAllianceWar = require "model.alliancewar"

    -- 未加入军团
    if mUserinfo.alliance <= 0 then
        response.ret = -8012
        return response
    end

    local warId = mAllianceWar:getWarId(positionId)
    if not warId then
        response.ret = -4002
        return response
    end

    local positionInfo = mAllianceWar:getPositionInfo(positionId,warId)

    local placePoint = mAllianceWar:getAllPlacePoint(positionId,warId)
    positionInfo.point = mAllianceWar:getPositionPoints(positionId,warId)
    
    for k,v in pairs(positionInfo.point) do 
        positionInfo.point[k] = (positionInfo.point[k] or 0) + (placePoint[k] or 0)
    end

    response.data.alliancewar.positionInfo = positionInfo
    response.data.useralliancewar = mUserAllianceWar.toArray(true)
    response.ret = 0
    response.msg = 'Success'

    return response
end
