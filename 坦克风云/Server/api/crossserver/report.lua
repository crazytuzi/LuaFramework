-- 获取战报
function api_crossserver_report(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    -- 战斗标识
    local bid = request.params.bid  -- 跨服战id
    local round = request.params.round  -- 轮次
    local pos = request.params.pos  -- 所属位置（a-h）
    local group = request.params.group  -- 分组(胜者组/败者组)
    local inning = request.params.inning    -- 第几回合

    if bid == nil or round == nil or pos == nil or group == nil or inning== nil then
        response.ret = -102
        return response
    end

    local crossserver = require "model.crossserver"
    local cross = crossserver.new()

    local report = cross:getBattleReport(bid,round,group,pos,inning)
    if report and report.info then
        report.info = json.decode(report.info)
    end

    response.data.report  = report
    response.ret = 0
    response.msg = 'Success'

    return response
end
