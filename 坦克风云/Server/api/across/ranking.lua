--
-- 比赛排名信息
-- User: luoning
-- Date: 14-10-16
-- Time: 下午9:49
--

function api_across_ranking(request)
    
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

    --检查比赛是否可押注
    require "model.amatches"
    local mMatches = model_amatches()
    mMatches.setBaseData(amMatchinfo)

    response.data.ranking = mMatches.getRankInfo()
    response.msg = "Success"
    response.ret = 0
    return response
end

