--获取军团战不同地区的排行榜
function api_alliance_applyrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    local areaid= tonumber(request.params.areaid) or 0
    local aid   = tonumber(request.params.aid) or 0
    local date  = getWeeTs()

    if uid == nil or  aid == 0 or areaid == 0 then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('alliancewar') == 0 then
        response.ret = -4012
        return response
    end
    local mAllianceWar = require "model.alliancewar"
    local warId = mAllianceWar:getWarId(areaid)
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

    local execRet, code = M_alliance.applyrank{uid=uid,aid=aid,areaid=areaid,date=date,warid=warId}
    
    if not execRet then
        response.ret = code
        return response
    end

    response.ret = 0
    response.data.rank = execRet.data.rank
    response.data.applycount = execRet.data.applycount
    response.data.ownerID = execRet.data.ownerID
    response.data.ownerName = execRet.data.ownerName
    response.data.areaid=areaid
    response.data.inWar =execRet.data.inWar
    response.msg = 'Success'
    
    return response
   
end