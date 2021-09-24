-- 记录分组信息
function api_skyladder_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    if moduleIsEnabled('ladder') == 0 then
        response.ret = -19000
        return response
    end
    
    local ts = getClientTs()
    local config = getConfig("skyladderCfg")
    
    -- 天梯榜状态
    require "model.skyladder"
    local skyladder = model_skyladder()
    local base = skyladder.getBase() -- 阶段状态
    local over = tonumber(base.over) -- 阶段状态
    local fin = json.decode(base.fin) or {} -- 已经结算的大战
    local seasonSt = tonumber(base.currst) or 0

    -- 各项赛事开启情况
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    local warlist = {}
    local function getBattleFinTime(bType,et)
        local sevbattleCfg
        local hour
        local finTime = et
        local bType = tonumber(bType)
        
        if bType == 1 then
            sevbattleCfg = getConfig("serverWarPersonalCfg")
            hour = sevbattleCfg.startBattleTs[1][1] * 3600 + sevbattleCfg.startBattleTs[1][2] * 60 +sevbattleCfg.battleTime * 3
            finTime = et - 86400 * 4 + hour + 86400
        elseif bType == 2 then
            sevbattleCfg = getConfig("serverWarTeamCfg")
            hour = sevbattleCfg.startBattleTs[1][1] * 3600 + sevbattleCfg.startBattleTs[1][2] * 60 + sevbattleCfg.warTime + 300
            finTime = et - 86400 * 4 + hour
        elseif bType == 3 then
            sevbattleCfg = getConfig("worldWarCfg")
            hour = sevbattleCfg.tmatch2starttime1[1] * 3600 + sevbattleCfg.tmatch2starttime1[2] * 60 + sevbattleCfg.battleTime * 3
            finTime = et - 86400 * 4 + hour
        elseif bType == 5 then
            sevbattleCfg = getConfig("serverWarLocalCfg")
            hour = sevbattleCfg.startWarTime.a[1] * 3600 + sevbattleCfg.startWarTime.a[2] * 60 +sevbattleCfg.maxBattleTime * 2
            finTime = et - 86400 * 1 + hour - 86400 * 4
        end
        
        
        
        return finTime
    end

    local plat = getClientPlat()
    local projectsIncluded = config.projectsIncluded
    local noShow = config.noShow[plat] or config.noShow.default
    for i,v in pairs(projectsIncluded) do
        local item = {}
        if not noShow[tostring(i)] then
            local result = mServerbattle.getserverbattlehistorycfg(tonumber(i),1) or {}

            -- 舰队新加优化,新赛季开启后,老赛季的大战数据不参与显示逻辑
            if (tonumber(result.et) or 0) < seasonSt then
                result = {}
            end

            item.bid = result.bid
            item.id = tonumber(result.type) or i
            item.st = tonumber(result.st) or 0
            item.et = tonumber(result.et) or 0
            item.flag = 0
            
            if over == 1 then
                -- item.flag = 1 -- 本赛季已结算 所有大战强制标记为已结束(坦克)
                item.flag = 4 -- 舰队优化
            else
                if item.st >= ts then
                    item.flag = 3 -- 即将开启
                elseif item.st < ts and item.et >= ts then
                    item.flag = 2 -- 进行中
                elseif item.st < ts and item.et < ts then
                    item.flag = 4 -- 敬请期待(很久之前的上一次时间，意为本赛季还没开启过)
                end

                if item.bid then
                    local finTime = getBattleFinTime(item.id,item.et)
                    -- print(item.id,result.bid,getDateByTimeZone(finTime,'%Y-%m-%d %H:%M:%S'),getDateByTimeZone(item.et,'%Y-%m-%d %H:%M:%S'))
                    if (ts >= finTime and ts < item.et) then
                        item.flag = 1 -- 已结束 本赛季开启过并完成
                    else
                        if fin[tostring(item.id)] then
                            item.flag = 4 -- 已结束 本赛季开启过并完成
                        end

                        if skyladder.getBattleFin(base.cubid,item.id,item.bid) then
                            -- item.flag                    = 1 -- 本赛季开启的该大战已结算完成 
                            item.flag = 4 -- 舰队优化
                        end
                    end
                end
            end
        else
            item.id = tonumber(i)
            item.st = 0
            item.et = 0
            item.flag = 0
        end
        
        table.insert(warlist,item)
    end
    
    
    local rversion = config.personRewardMapping[plat] and config.personRewardMapping[plat] or config.personRewardMapping.default
    
    local _,hofcount=skyladder.getAllHistory(0,20)
    local isBattle
    local counttime = config.counttime or 300
    local battleTs = getServerWarFlag()

    if battleTs then
        isBattle = 1
    end
    
    response.ret = 0
    response.msg = 'Success'
    response.data.ladder = {season=base.season,overtime=base.overtime,warlist=warlist,hofcount=hofcount,counttime=counttime,isBattle=isBattle,rverion=rversion}

    return response
end