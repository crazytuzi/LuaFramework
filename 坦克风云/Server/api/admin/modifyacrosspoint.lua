--
-- 修改团队跨服战积分数据
-- User: luoning
-- Date: 14-12-3
-- Time: 下午4:22
--

function api_admin_modifyacrosspoint(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local point = tonumber(request.params.point) or 0

    if uid == nil or point == nil then
        return response
    end

    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    local amMatchinfo = mServerbattle.getAcrossBattleInfo()
    if not next(amMatchinfo) then
        response.ret=-21001
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", 'acrossinfo'})
    local mCrossinfo = uobjs.getModel('acrossinfo')
    mCrossinfo.setMatchId(amMatchinfo.bid, amMatchinfo.et)
    mCrossinfo.addAdminPoint(amMatchinfo.bid, point)

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    return response
end

