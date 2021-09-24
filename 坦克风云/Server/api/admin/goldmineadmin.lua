function api_admin_goldmineadmin(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    -- 本地的所有任务信息
    local mGoldMine = require "model.goldmine"
    local goldMineCronInfo = mGoldMine.getGoldMineCronInfo()
    local goldMineMap = mGoldMine.getGoldMineInfo()

    local goldMineMapInfo = {}
    local mid = {}
    for k,v in pairs(goldMineMap) do
        goldMineMapInfo[k] = {getPosByMid(tonumber(v[1])),v[2],v[3]}
        table.insert(mid,v[1])
    end

    if next(mid) then
        local db = getDbo()
        local result = db:getAllRows("select id,type from map where id in (".. table.concat(mid,",") ..") ")

        if type(result) == 'table' then
            for k,v in pairs(result) do
                if goldMineMapInfo[tostring(v.id)] then
                    goldMineMapInfo[tostring(v.id)][4] = v.type
                end
            end
        end
    end 
    
    response.data.goldMineCronInfo = mGoldMine.getvalidCronId(goldMineCronInfo)
    response.data.goldMineMap = goldMineMapInfo

    response.ret = 0
    response.msg = 'Success'

    return response
end