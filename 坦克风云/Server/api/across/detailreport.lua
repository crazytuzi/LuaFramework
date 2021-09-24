--
-- 得到详情比赛信息
-- User: luoning
-- Date: 14-12-20
-- Time: 下午6:51
--
function api_across_detailreport(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local bid = request.params.bid
    local rId = tonumber(request.params.rid)

    if uid == nil and bid == nil and rId == nil then
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

    local reportInfo = mMatches.getDetailReportInfo(rId)

    response.data.detailReport = reportInfo
    response.msg = "Success"
    response.ret = 0
    return response

end

