--
-- 比赛排名信息
-- User: luoning
-- Date: 14-10-16
-- Time: 下午9:49
--

function api_cross_ranking(request)
    
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

    --检查比赛是否可押注
    require "model.matches"
    local mMatches = model_matches()

    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end
    response.data.ranking = {}
    if mMatches.getRankInfo() then
        response.data.ranking = mMatches.formatRanking()
    end
    response.msg = "Success"
    response.ret = 0
    return response
end

