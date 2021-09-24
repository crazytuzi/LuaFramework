-- 金矿
function api_map_goldmine(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    -- 金矿是否已开
    if not switchIsEnabled('goldmine') then
        response.ret = 0
        response.err = "switch not enable"
        response.msg = 'Success'
        return response
    end

    if request.params.action == 1 then
        local cronid = request.workId
        if not cronid then
            response.ret = -102
            response.err = "not cronid"
            return response
        end

        -- 本地的所有任务信息
        local mGoldMine = require "model.goldmine"
        local goldMineCronInfo = mGoldMine.getGoldMineCronInfo()
        
        -- 校验是否能跟本地任务信息对应上
        if not goldMineCronInfo[tostring(cronid)] or goldMineCronInfo[tostring(cronid)] ~= request.params.nextInfo then
            response.ret = -102
            response.err = "not cronInfo"
            return response
        end

        -- 清除该任务
        mGoldMine.delGoldMineCronId(cronid)

        -- 生成金矿
        local mid = mGoldMine.createGoldMine()
        local allGoldMineInfo = mGoldMine.saveGoldMineId(mid)

        -- 清理过期的金矿数据
        mGoldMine.clearExpireGoldMineId(allGoldMineInfo)

    elseif tonumber(request.params.action) == 2 then
        local mGoldMine = require "model.goldmine"
        mGoldMine.repair()

        local sql = "UPDATE  map, userinfo SET map.type = 0, map.level = 0, map.oid = 0, map.name ='', map.power = 0, map.rank = 0, map.protect = 0, map.pic = NULL, map.alliance = 0 WHERE map.oid > 0 and map.type = 6 AND userinfo.uid = map.oid AND (userinfo.mapx != map.x OR userinfo.mapy != map.y)";
        getDbo():query(sql) 

        refreshAchievementRanking()
    -- 推送金矿消失的信息
    elseif tonumber(request.params.action) == 3 then
        local mid = request.params.mid
        if mid then
            local mMap = require 'lib.map'
            local mapData = mMap:getMapById(mid)
            local level = tonumber(mapData.level) or 0
            local mapx = tonumber(mapData.x) or 0
            local mapy = tonumber(mapData.y) or 0

            local msg = {
                content={
                    contentType=4,
                    type=37,
                    params={
                        overgm={mapx,mapy,level}
                    }  
                },
                channel=1,
                type="chat",
            }
            
            sendMessage(msg)
        end
    end

    response.ret = 0
    response.msg = 'Success'

    return response
end
