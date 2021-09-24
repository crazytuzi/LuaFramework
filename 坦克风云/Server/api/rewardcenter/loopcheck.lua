function api_rewardcenter_loopcheck(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

	if not moduleIsEnabled('rewardcenter') then
		response.ret = -314
        return response
	end
	
    require "model.active"
	require "lib.rewardcenter"
	
	local ts = getClientTs()
	local rewardcenter = model_rewardcenter()
    local mActive = model_active()
    local actives = mActive.toArray()
	local redis = getRedis()
    local config = getConfig("active")
    local list = {}
	
	function sendAllUserReward(aid,config,rankList,rewardConfig,rtime,method)
		local rtime = rtime or os.time()
		local version = config.v or nil
		local result = {}

		for sn,rinfo in ipairs(rankList) do
            if type(rinfo) == 'table' and next(rinfo) then
    			local uid = tonumber(rinfo[1]) or nil
    			local rank = tonumber(sn)

                if not method or method == 0 then
                    if uid and rank and rewardConfig[rank] then
                        local ret = sendToRewardCenter(uid,'ac',aid,rtime,nil,{v=version,r=rank},rewardConfig[rank])
                        if ret then
                            table.insert(result,{uid,rank})
                        end
                    end
                else
                    for i,v in pairs(rewardConfig) do
                        if rank >= v[1][1] and rank <= v[1][2] then
                            rankIndex = i
                            if uid and rankIndex and v[2] then
                                local ret = sendToRewardCenter(uid,'ac',aid,rtime,nil,{v=version,r=rank},v[2])
                                if ret then
                                    table.insert(result,{uid,rank})
                                end
                            end
                        end
                    end
                end
            end
		end
		
		return result
	end
	
    if type(actives) == 'table' then
        for aid,ainfo in pairs(actives) do
			if ts >= tonumber(ainfo.st) and ts <= tonumber(ainfo.et) then 
                -- 活动时间 基本配置检查
				if tonumber(ainfo.et) - ts < 86400 then
                    local checkKey = "z"..getZoneId().."."..aid..".rewardSend."..ainfo.st
                    local status = redis:get(checkKey) or 0
					--print('status',status)
                    if status == 0 then
                        local activeConfig
                        if config[aid] then
                            activeConfig = config[aid]
                        else
                            activeConfig = getConfig("active/"..aid)
                        end
                        
                        if activeConfig['multiSelectType'] and activeConfig[tonumber(ainfo.cfg)] then -- 处理多版本
                            activeConfig = activeConfig[tonumber(ainfo.cfg)]
                        elseif not activeConfig['multiSelectType']then
                            ainfo.cfg = nil
                        end

                        if type(ainfo['selfcfg']) == 'string' and #ainfo['selfcfg'] > 2 then -- 处理自定义配置
                            activeConfig = mActive.selfCfg(aid, true)
                        end
                            
                        --if ainfo.name == 'wheelFortune' then
                        -- print('name',ainfo.name)
                        if ainfo.name == '123456' then
                            local rankList = getActiveRanking(wheelFortune,ainfo.st)
                            local list = sendAllUserReward(aid,{v=ainfo.cfg},rankList,activeConfig.serverreward)
                            
                            writeLog(getDateByTimeZone(nil,"%Y-%m-%d %H:%M:%S") .. '|' .. checkKey .. '|' .. json.encode({aid,{v=ainfo.cfg},rankList,list}),'rewardcenterloopcheck')
                        elseif ainfo.name == 'fightRanknew' then
                            --print('fightRanknew')
                            local rankList = getActiveRanking("fightRanknew",ainfo.st)
                            local list = sendAllUserReward(aid,{v=ainfo.cfg},rankList,activeConfig.serverreward.box)
                            --ptb:p(rankList)
                            writeLog(getDateByTimeZone(nil,"%Y-%m-%d %H:%M:%S") .. '|' .. checkKey .. '|' .. json.encode({aid,{v=ainfo.cfg},rankList,list}),'rewardcenterloopcheck')
                        elseif ainfo.name == 'challengeranknew' then
                            --print('challengeranknew')
                            local rankList = getActiveRanking("challengeranknew",ainfo.st)
                            --ptb:p(rankList)
                            local list = sendAllUserReward(aid,{v=ainfo.cfg},rankList,activeConfig.serverreward.box)
                            --ptb:p(rankList)
                            writeLog(getDateByTimeZone(nil,"%Y-%m-%d %H:%M:%S") .. '|' .. checkKey .. '|' .. json.encode({aid,{v=ainfo.cfg},rankList,list}),'rewardcenterloopcheck')
                        elseif ainfo.name == 'rechargeCompetition' then
                            local listData = getRechargeCompetitionRankList(ainfo,activeConfig)
                            local rankList = {}
                            local zid = getZoneId()
                            if type(listData) == 'table' then
                                for k,v in pairs(listData) do
                                    if type(v) == 'table' and v.userid then
                                        if tonumber(v.zoneid) == zid then
                                            table.insert(rankList,{tonumber(v.userid)})
                                        else
                                            table.insert(rankList,{})
                                        end
                                    end
                                end

                                local list = sendAllUserReward(aid,{v=ainfo.cfg},rankList,activeConfig.serverreward,nil,100)
                                writeLog(getDateByTimeZone(nil,"%Y-%m-%d %H:%M:%S") .. '|' .. checkKey .. '|' .. json.encode({aid,{v=ainfo.cfg},rankList,list}),'rewardcenterloopcheck')
                            end
                        end
                        
                        redis:set(checkKey,1)
                        redis:expire(checkKey,86400*5)
                    end
                end
			end
        end
    end
	
	-- rewardcenter.delExpireReward(86400*5)

    response.ret = 0
    response.msg = 'Success'
    
    return response
end
