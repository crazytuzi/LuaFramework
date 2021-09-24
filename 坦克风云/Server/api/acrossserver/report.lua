-- 获取战报
function api_acrossserver_report(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    -- 战斗标识
    local bid = request.params.bid  -- 跨服战id
    local round = request.params.round  -- 轮次
    local group = request.params.group  -- 分组(胜者组/败者组)
    local dtype = request.params.dtype
    local uid = request.params.uid
    local page = request.params.page

    if bid == nil or round == nil or group == nil or dtype == nil or uid == nil then
        response.ret = -102
        return response
    end

    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()
    across:setRedis(bid)

    -- local report, nextPage = across:getBattleReport(bid,round,group,uid,dtype,page)
    local report, nextPage = across:getBattleReportFromReportCenter(bid,round,group,uid,dtype,page)
    local result = {}
    if type(report) == "table" and next(report) then
        local mapIndex = {"type","bid","id","attId","attName","defId","defName","attAName","defAName","attAid","defAid","updated_at","placeId","aPrevPlace","dPrevPlace","baseblood","victor","placeOid","bomb"}
        for i,v in pairs(report) do
            result[i] = {}
            for _,tmpIndex in pairs(mapIndex) do
                if v[tmpIndex] then
                    table.insert(result[i], v[tmpIndex])
                else
                    table.insert(result[i], 0)
                end
            end
        end
    end

    response.data.report  = result
    response.data.nextPage = nextPage
    response.ret = 0
    response.msg = 'Success'

    return response
end
