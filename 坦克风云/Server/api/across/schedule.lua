--
-- 跨服战赛程
-- User: luoning
-- Date: 14-10-16
-- Time: 上午11:38
--
function api_cross_schedule(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if uid == nil then
        return response
    end

    require "model.matches"

    local mMatches = model_matches()
    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end

    response.data.schedule = mMatches.battleList
    response.ret = 0
    response.msg = "Success"
    return response
end

