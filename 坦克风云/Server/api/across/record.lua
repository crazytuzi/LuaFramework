--
-- 商店购买记录
-- User: luoning
-- Date: 14-10-16
-- Time: 下午12:40
--
function api_across_record(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

    if uid == nil  then
        response.ret = -102
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

    local record = mCrossinfo.getPointRecord(amMatchinfo.bid)
    response.data.record = record
    response.ret = 0
    response.msg = 'Success'
    return response
end

