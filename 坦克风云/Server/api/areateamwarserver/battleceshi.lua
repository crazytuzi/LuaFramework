
function api_areateamwarserver_battleceshi(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
        err = {},
        over={},
    }

    local battleDebug = false

    ---------------------------------------------------------------------
    -- init
    local ts = os.time()
    local sevbattleCfg = getConfig('serverWarLocalCfg')
    local mapCfg = getConfig('serverWarLocalMapCfg1')
    local cityCfg = mapCfg.cityCfg
    local overSkyladderRank

    -- model
    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct()

    local overSkyladderRank = true
    if overSkyladderRank and base and type(base) == 'table' and base.status and tonumber(base.status) == 1 then
        local bidDatas = mAreaWar.getBidData()
        local groups = mAreaWar.getWarGroups()
        for k,v in pairs(bidDatas) do
            local currnum = 0
            local groupnum = #groups or 0
            for _,group in pairs(groups) do
                if tonumber(v["round_"..group]) >= 2 then
                    currnum = currnum + 1
                end
            end
            if currnum >= groupnum then
                require "api/admin.accountsbattle"
                local status,result = pcall(_ENV["api_admin_accountsbattle"],{params={battleType=5}})
                if status then
                    writeLog(json.encode({ts=ts,runId=runId,status='sucess'}),"skyladderAccountsForArea")
                else
                    local base = skyladderserver.getStatus()
                    writeLog(json.encode({ts=ts,runId=runId,status='fail'}),"skyladderAccountsForArea")
                end
            end
        end
    end
    
    response.ret = 0
    response.msg = 'Success'

    return response
end
