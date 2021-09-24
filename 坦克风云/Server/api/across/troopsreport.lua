--
-- 军团战坦克损毁报告
-- User: luoning
-- Date: 14-12-8
-- Time: 下午5:07
--

function api_across_troopsreport(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local bid = request.params.bid
    --区别是服内赛还是跨服赛
    local category = request.params.category
    local round = request.params.round
    local did = request.params.did

    if uid == nil and bid == nil and round == nil or did == nil then
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

    --检查是否有正在进行的跨服战
    require "model.amatches"
    local mMatches = model_amatches()
    mMatches.setBaseData(amMatchinfo)

    local reportInfo = mMatches.getTroopsReportInfo(bid, round, did)

    response.data.report = reportInfo
    response.msg = "Success"
    response.ret = 0
    return response

end

