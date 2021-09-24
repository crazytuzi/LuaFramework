--
-- 修改跨服战积分
-- User: luoning
-- Date: 14-10-27
-- Time: 上午11:05
--
function api_admin_modifycrosspoint(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local point = tonumber(request.params.point) or 0
    local wpoint = tonumber(request.params.wpoint) or 0
    if uid == nil or point == nil then
        return response
    end

    require "model.matches"
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", 'crossinfo','wcrossinfo'})
    local mCrossinfo = uobjs.getModel('crossinfo')
    local mWcrossinfo = uobjs.getModel('wcrossinfo')
    if point~=0 then
        local mMatches = model_matches()
        if not next(mMatches.base) then
            response.ret = -1
            return response
        end
        mCrossinfo.setMatchId(mMatches.base.matchId, mMatches.base.et)
        mCrossinfo.addAdminPoint(mMatches.base.matchId, point)
    end
    if wpoint~=0 then
        mWcrossinfo.addAdminPoint(wpoint)
    end
    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    return response
end

