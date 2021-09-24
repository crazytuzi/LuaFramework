--
-- 军团跨服战文本战报
-- User: luoning
-- Date: 14-10-15
-- Time: 下午8:59
--
function api_across_report(request)

    
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
    local page = tonumber(request.params.page) or 1
    --请求个人数据还是全服数据 0 全服，1个人
    local dtype = tonumber(request.params.dtype) or 0
    local noCache = tonumber(request.params.noCache) or 0

    if uid == nil and bid == nil and round == nil or did == nil or category == nil then
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

    local reportInfo, nextPage = mMatches.getReportInfo(bid, round, did, page, uid, dtype,noCache)

    response.data.report = reportInfo
    response.data.nextPage = nextPage
    response.msg = "Success"
    response.ret = 0
    return response
end
