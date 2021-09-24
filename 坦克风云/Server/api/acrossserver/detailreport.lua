--
-- 得到详情比赛信息
-- User: luoning
-- Date: 14-12-20
-- Time: 下午6:51
--
function api_acrossserver_detailreport(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    -- 战斗标识
    local rId = request.params.rId  -- 跨服战id

    if rId == nil then
        response.ret = -102
        return response
    end

    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()

    -- local report = across:getBattleDetailReportInfo(rId)
    local report = across:getDetailReportFromReportCenter(rId)
    response.data.detailreport  = report
    response.ret = 0
    response.msg = 'Success'

    return response

end

