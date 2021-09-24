--
-- 跨服战赛程
-- User: lmh
-- Date: 15-03-30
-- Time: 11:38
--
function api_worldwar_schedule(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local jointype =request.params.jointype or 1 
    
    if uid == nil then
        return response
    end

    require "model.wmatches"

    local mMatches = model_wmatches()
    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end

    mMatches.getMultInfo(jointype)
    response.data.schedule=mMatches.battleList[jointype]
    response.data.crossuser = mMatches.userinfo[jointype]
    response.data.landform  = copyTab(mMatches.landform[jointype])
    if response.data.schedule then
        local inedx=#response.data.schedule
        for k,v in pairs(response.data.schedule[inedx]) do
            local dayarr = k:split('g') 
            local landform=tonumber(dayarr[2])
            table.insert(response.data.landform[landform],v) 
        end
    end
    response.ret = 0
    response.msg = "Success"
    return response
end

