exerWarVoApi = {}

--0：开启
--1：开关未开
--2：玩家等级不够
--3：大战已过期
function exerWarVoApi:isOpen()
    if self.warSt == nil or self.warEt == nil or base.serverTime >= self.warEt or base.serverTime < self.warSt then
        return 3
    end
    local cfg = self:getWarCfg()
    local playerLv = playerVoApi:getPlayerLevel()
    if playerLv < cfg.levelLimit then
        return 2, cfg.levelLimit
    end
    return 0
end

function exerWarVoApi:setWarTime(wart)
    if wart then
        self.warSt, self.warEt = tonumber(wart.st), tonumber(wart.et)
    end
end

function exerWarVoApi:getWarTime()
	return self.warSt, self.warEt
end

--获取联合演习状态
--0：未开启
-- >=10：服内pvp
-- 11：服内pvp设置部队阶段
-- 12：服内pvp战斗阶段
-- 13：服内pvp战斗结束查看战报阶段
-- >=20：跨服pvp初赛
-- 21：跨服初赛调整部队阶段（报名阶段）
-- 22：参赛名单生成中
-- 23：跨服初赛战斗阶段
-- 24：初赛战斗结束
-- 30：跨服决赛
-- 40：所有赛事已结束
function exerWarVoApi:getWarStatus()
    local warCfg = self:getWarCfg()
    local pvp1Et = self.warSt + warCfg.pvp1Time * 86400
    local pvp2Et = pvp1Et + warCfg.pvp2Time * 86400
    if base.serverTime <= pvp1Et then
        local weets = G_getWeeTs(base.serverTime) --当天零点时间戳
        local joinEt = weets + warCfg.PVP1.joinTime
        local overEt = weets + warCfg.PVP1.overTime
        local dayEt = weets + 86400
        local status, et = 10, pvp1Et
        if base.serverTime <= joinEt then --每天设置部队阶段
            status, et = 11, joinEt
        elseif base.serverTime <= overEt then --每天战斗阶段
            status, et = 12, overEt
        elseif base.serverTime <= dayEt then --每天战斗结束查看战报阶段
            status, et = 13, dayEt
        else
            status, et = 10, pvp1Et
        end
        local round = math.ceil((base.serverTime - self.warSt) / 86400) --当前是服内pvp第几轮
        if base.serverTime == weets then --********跨天00点的误差计算
        	round = round + 1
        end
        return status, et, round
    elseif base.serverTime <= pvp2Et - 86400 then --跨服初赛
        local weets = G_getWeeTs(base.serverTime) --当天零点时间戳
        local joinEt = weets + warCfg.PVP2.joinTime
        local overEt = weets + warCfg.PVP2.overTime
        if base.serverTime == weets then --********跨天00点的误差计算
	    	return 24, pvp2Et
	    end
        if base.serverTime <= joinEt then --初赛调整部队阶段
            return 21, joinEt
        elseif base.serverTime <= joinEt + 5 * 60 then --处理参赛名单需要5分钟
            return 22, joinEt + 5 * 60
        elseif base.serverTime <= overEt then --初赛战斗阶段
            return 23, overEt
        end
        return 24, pvp2Et
    elseif base.serverTime <= pvp2Et then --跨服决赛
    	return 30
    elseif base.serverTime <= self.warEt then --所有赛事已结束
    	return 40, self.warEt
    end
    return 0, 0
end

function exerWarVoApi:getWarPeroid()
    local peroid = 7
    local status, et, round = self:getWarStatus()
    if status > 0 and status < 20 then --服内pvp
        peroid = round
    elseif status >= 20 and status < 30 then --跨服pvp初赛
        peroid = 6
    end
    return peroid, status --跨服pvp决赛
end

--配置数据
function exerWarVoApi:getWarCfg()
    if self.warCfg == nil then
        self.warCfg = G_requireLua("config/gameconfig/exerwar/serverWarExerciseCfg")
        if self.warCfg.plat and self.warCfg.plat[base.serverPlatID] then --替换部分各平台差异化的数据
            for k, v in pairs(self.warCfg.plat[base.serverPlatID]) do
                self.warCfg[k] = v
            end
        end
    end
    return self.warCfg
end

function exerWarVoApi:showExerWarDialog(layerNum, isEnter)
	local flag, openLv = self:isOpen()
    if flag ~= 0 then
        local tipStr = ""
        if flag == 2 then
            tipStr = getlocal("elite_challenge_unlock_level", {openLv})
        elseif flag == 3 then
            tipStr = getlocal("exerwar_noopen")
        end
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
        do return end
    end
    self:exerWarInit(function()
    	if isEnter == nil and self:isShowRedPoint() == true then
    		require "luascript/script/game/scene/gamedialog/exerwar/exerWarWelcomeDialog"
    		local td = exerWarWelcomeDialog:new(layerNum)
		    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("exerwar_title"), true, layerNum)
		    sceneGame:addChild(dialog, layerNum)
    	else
    		if type(isEnter) == "function" then
    			isEnter()
    		end
	    	require "luascript/script/game/scene/gamedialog/exerwar/exerWarDialog"
		    local td = exerWarDialog:new(layerNum)
		    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("exerwar_title"), true, layerNum)
		    sceneGame:addChild(dialog, layerNum)
		end
    end)
end

function exerWarVoApi:createTroopsLayer(layerNum, troopsNum)
	require "luascript/script/game/scene/gamedialog/exerwar/exerWarTroopsLayer"
	local troopsLayerObj = exerWarTroopsLayer:new(layerNum, troopsNum)
	if troopsLayerObj:init() then
		return troopsLayerObj
	end
end

function exerWarVoApi:exerWarInit(callback)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	self:initData(sData.data)
        	if callback then
        		callback()
        	end
			local myAlliance = allianceVoApi:getSelfAlliance()
        	local ts, value = exerWarVoApi:getFinalTimeStatus()
        	if ts == 0 and value == 0 and self.finalRank > 0 and myAlliance and myAlliance.aid > 0 then --决赛已经结束
        		local rankReward=exerWarVoApi:getRankReward()
        		for k,v in pairs(rankReward) do
        			if self.finalRank >= v.range[1] and self.finalRank <= v.range[2] then
        				local reward = FormatItem(v.reward)
        				for k,v in pairs(reward) do
        					if v.type == "al" then
				        		if allianceVoApi:isFlagUnlock() == false then --如果没有拥有该旗帜，则加旗帜
				        			allianceVoApi:setUnlockFlagValue(v.key) --添加旗帜
				        		end
        						do break end
        					end
        				end
        			end
        		end
        	end
        end
	end
	socketHelper:exerWarInit(socketCallback)
end

--跨服演习战保存阵容
--@lineupsTb : 阵容数据
function exerWarVoApi:saveLineups(callback, lineupsTb)
	if lineupsTb == nil then
		return
	end
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data and sData.data.setst then
        		self.setTroopsTs = sData.data.setst
        	end
        	self.troopsInfo = G_clone(lineupsTb)
        	if callback then
        		callback()
        	end
        end
    end
	socketHelper:exerWarSettingsLineups(socketCallback, self:encodeTroopsInfo(lineupsTb))
end

function exerWarVoApi:initData(sData)
	if sData then
		if sData.reporturl then --跨服战报IP
			self.serverHost = sData.reporturl
		end
		if sData.equipData then --随机池相关数据
			--前5轮的主题数据(实为主题id，在策划保证不会断续的情况下以索引值使用)
			if sData.equipData.themeindexTb then
				self.themeTb = sData.equipData.themeindexTb
			end
			if sData.equipData.tankTb then --坦克随机池
				self.randomPoolTank = sData.equipData.tankTb
			end
			if sData.equipData.heroTb then --英雄将领随机池
				self.randomPoolHero = sData.equipData.heroTb
			end
		end
		if sData.ecrossinfo then
			if sData.ecrossinfo.bid then
				self.bid = sData.ecrossinfo.bid
			end
			if sData.ecrossinfo.tinfo then --已设置的部队信息
				self.troopsInfo = self:decodeTroopsInfo(sData.ecrossinfo.tinfo)
			end
			if sData.ecrossinfo.pointinfo then
				self.pointinfo = sData.ecrossinfo.pointinfo
			end
			if sData.ecrossinfo.point then
				self.myPoint = sData.ecrossinfo.point
			end
			if sData.ecrossinfo.isenterserver then --0：未进入，1：进入初赛，2：进入决赛
				self.isEnterServer = sData.ecrossinfo.isenterserver
			end
			if sData.ecrossinfo.praiseflag then --是否点赞
				self.isPraise = (sData.ecrossinfo.praiseflag == 1) and true or false
			end
			if sData.ecrossinfo.shopinfo then --商店中的积分兑换
				self.exchangeInfo = sData.ecrossinfo.shopinfo
			end
			if sData.ecrossinfo.pointlog then --商店中的兑换记录
				self.exchangeLog = sData.ecrossinfo.pointlog
			end
			if sData.ecrossinfo.setst then --最近一次设置服内pvp部队的时间，>0 说明玩家设置过部队
				self.setTroopsTs = sData.ecrossinfo.setst
			end

			if sData.ecrossinfo.score then
				if self.rankSelfData == nil then
					self.rankSelfData = {}
				end
				self.rankSelfData.score = sData.ecrossinfo.score
			end
			if sData.ecrossinfo.surrate then
				if self.rankSelfData == nil then
					self.rankSelfData = {}
				end
				self.rankSelfData.surrate = sData.ecrossinfo.surrate
			end
			if sData.ecrossinfo.fc then
				if self.rankSelfData == nil then
					self.rankSelfData = {}
				end
				self.rankSelfData.fc = sData.ecrossinfo.fc
			end
			if sData.ecrossinfo.gem then --已竞拍的金币数
				self.auctionGem = sData.ecrossinfo.gem
			end
			if self.finalRank == nil then
				self.finalRank = 0
			end
			if sData.ecrossinfo.ranking then --跨服决赛自己的排名
				self.finalRank = sData.ecrossinfo.ranking
			end
		end
	end
end

function exerWarVoApi:decodeTroopsInfo(troopsData)
	local warCfg = self:getWarCfg()
	local peroid = self:getWarPeroid()
	local pvpWarCfg
	if peroid <= 5 then
		pvpWarCfg = warCfg.PVP1
	else
		pvpWarCfg = warCfg.PVP2
	end
	local tData = {}
	for k, v in pairs(troopsData) do
		local tankTb, heroTb, atTb = {}, {}, {}
		for i = 1, 6 do
			if v.fleetinfo and v.fleetinfo[i] then
				tankTb[i] = v.fleetinfo[i]
			else
				tankTb[i] = {}
			end
			if v.hero and v.hero[i] then
				local heroLv = pvpWarCfg.heroChoice.heroGrade
				local heroStarLv = pvpWarCfg.heroChoice.heroStar
				local heroSkillLv = pvpWarCfg.heroChoice.skillGrade
				heroTb[i] = { v.hero[i], heroLv, heroStarLv, heroSkillLv }
			else
				heroTb[i] = 0
			end
			if v.at and v.at[i] and v.at[i] ~= 0 then
				local aiLv = pvpWarCfg.AIchoice.AIgrade
				local aiGrade = pvpWarCfg.AIchoice.AIquality
				local aiSkillLv = pvpWarCfg.AIchoice.AIskillGrade
				atTb[i] = { v.at[i], aiLv, aiGrade, aiSkillLv }
			else
				atTb[i] = 0
			end
		end
		local planeTb = { v.plane, v.planeskill }
		table.insert(tData, { tankTb, heroTb, atTb, v.equip, planeTb })
	end
	return tData
end

function exerWarVoApi:encodeTroopsInfo(troopsData)
	local tData = {}
	for k, v in pairs(troopsData) do
		local tankTb, heroTb, atTb = {}, {}, {}
		for i = 1, 6 do
			if v[1] and v[1][i] and v[1][i][1] then
				tankTb[i] = { tonumber(v[1][i][1]) or tonumber(RemoveFirstChar(v[1][i][1])), v[1][i][2] }
			else
				tankTb[i] = {}
			end
			if v[2] and v[2][i] then
				heroTb[i] = v[2][i][1]
			else
				heroTb[i] = 0
			end
			if v[3] and type(v[3][i]) == "table" then
				atTb[i] = v[3][i][1]
			else
				atTb[i] = 0
			end
		end
		local planeId, planeSkillId
		if v[5] then
			planeId = v[5][1]
			planeSkillId = v[5][2]
		end
		local tempTb = {
			fleetinfo = tankTb,
			hero = heroTb,
			at = atTb,
			equip = v[4],
			plane = planeId,
			planeskill = planeSkillId,
		}
		table.insert(tData, tempTb)
	end
	return tData
end

--获取初始带兵量
function exerWarVoApi:getBaseTroopsNum()
	local warCfg = self:getWarCfg()
	return warCfg.playerTroops
end

--随机阵容
--@troopsNum : 带兵量
--@return : 
function exerWarVoApi:randomLineups(troopsNum, customRandomPool)
	if self.randomPoolTank == nil or self.randomPoolHero == nil then
		return
	end
	if troopsNum == nil or troopsNum == 0 then
		troopsNum = self:getBaseTroopsNum()
	end
	local warCfg = self:getWarCfg()
	local peroid = self:getWarPeroid()
	local kkk = 0
	local function isEqual(value, pData, troopsType, pvpWarCfg, rValueTemp)
		kkk = kkk + 1
		if kkk % (6 * 6 * 6 * ((peroid > 5) and 3 or 1)) == 0 then
			assert(false, "处理因配置数据问题导致死循环:[中断随机]")
		end
		for k, v in pairs(pData) do
			if v == value then
				return true
			end
		end
		if troopsType == 3 and pvpWarCfg then
			local aiPoolTb
			if customRandomPool and customRandomPool[troopsType] then
				aiPoolTb = customRandomPool[troopsType]
			else
				aiPoolTb = pvpWarCfg.AIchoice.AI
			end
			if aiPoolTb and aiPoolTb[value] then
				local haveSelectAITroopsTb = {}
				for kk, vv in pairs(rValueTemp or pData) do
					table.insert(haveSelectAITroopsTb, aiPoolTb[vv])
				end
				local aid = aiPoolTb[value]
				local limitTb = AITroopsVoApi:getLimitTroopsCfg(aid)
	            local conflictTb = AITroopsVoApi:troopsConflict(limitTb, haveSelectAITroopsTb)
	            local sizeOfConflictTable = SizeOfTable(conflictTb)
	            if sizeOfConflictTable ~= 0 then
	            	return true
	            end
	        end
		end
		return false
	end
	local function randomTroops(troopsType, pvpWarCfg, randomIndexTb, flagAI)
		local randomPool, randomPoolSize, maxRandomNum
		if troopsType == 1 then --坦克
			if customRandomPool and customRandomPool[troopsType] then
				randomPool = customRandomPool[troopsType]
			else
				randomPool = self.randomPoolTank[peroid]
			end
			maxRandomNum = pvpWarCfg.tankChoice.tankNum
		elseif troopsType == 2 then --英雄将领
			if customRandomPool and customRandomPool[troopsType] then
				randomPool = customRandomPool[troopsType]
			else
				randomPool = self.randomPoolHero[peroid]
			end
			maxRandomNum = pvpWarCfg.heroChoice.heroMax
		elseif troopsType == 3 then --AI部队
			if customRandomPool and customRandomPool[troopsType] then
				randomPool = customRandomPool[troopsType]
			else
				randomPool = pvpWarCfg.AIchoice.AI
			end
			maxRandomNum = pvpWarCfg.AIchoice.AInum
		elseif troopsType == 4 then --军徽
			if customRandomPool and customRandomPool[troopsType] then
				randomPool = customRandomPool[troopsType]
			else
				randomPool = pvpWarCfg.equipChoice.equipId
			end
			randomPoolSize = SizeOfTable(randomPool)
			local randomIndex = math.random(1, randomPoolSize)
			if randomIndexTb then
				while isEqual(randomIndex, randomIndexTb) do
					randomIndex = math.random(1, randomPoolSize)
				end
			end
			return randomPool[randomIndex], randomIndex
		elseif troopsType == 5 then --飞机/飞机技能
			if customRandomPool and customRandomPool[troopsType] and customRandomPool[troopsType][1] then
				randomPool = customRandomPool[troopsType][1]
			else
				randomPool = pvpWarCfg.planeChoice.planeId
			end
			randomPoolSize = SizeOfTable(randomPool)
			local randomIndexPID = math.random(1, randomPoolSize)
			if randomIndexTb then
				while isEqual(randomIndexPID, randomIndexTb[1]) do
					randomIndexPID = math.random(1, randomPoolSize)
				end
			end
			local planeId = randomPool[randomIndexPID]
			if customRandomPool and customRandomPool[troopsType] and customRandomPool[troopsType][2] then
				randomPool = customRandomPool[troopsType][2]
			else
				randomPool = pvpWarCfg.planeChoice.skillId
			end
			randomPoolSize = SizeOfTable(randomPool)
			local randomIndexPSID = math.random(1, randomPoolSize)
			if randomIndexTb then
				while isEqual(randomIndexPSID, randomIndexTb[2]) do
					randomIndexPSID = math.random(1, randomPoolSize)
				end
			end
			local planeSkillId = randomPool[randomIndexPSID]
			return { planeId, planeSkillId }, { randomIndexPID, randomIndexPSID }
		end
		if randomPool then
			local rValueTb = {}
			randomPoolSize = SizeOfTable(randomPool)
			local randomPoolIndexTb = {}
			if randomIndexTb then
				randomPoolIndexTb = randomIndexTb
			end
			local rValueTemp
			if troopsType == 3 and flagAI == true then
				rValueTemp = {}
			end
			for i = 1, maxRandomNum do
				local rValue = math.random(1, randomPoolSize)
				while isEqual(rValue, randomPoolIndexTb, troopsType, pvpWarCfg, rValueTemp) do
					rValue = math.random(1, randomPoolSize)
				end
				table.insert(randomPoolIndexTb, rValue)
				if rValueTemp then
					table.insert(rValueTemp, rValue)
				end
				if troopsType == 1 then --坦克
					table.insert(rValueTb, { tonumber(RemoveFirstChar(randomPool[rValue])), troopsNum })
				elseif troopsType == 2 then --英雄将领
					local heroLv = pvpWarCfg.heroChoice.heroGrade
					local heroStarLv = pvpWarCfg.heroChoice.heroStar
					local heroSkillLv = pvpWarCfg.heroChoice.skillGrade
					table.insert(rValueTb, { randomPool[rValue], heroLv, heroStarLv, heroSkillLv })
				elseif troopsType == 3 then --AI部队
					local aiLv = pvpWarCfg.AIchoice.AIgrade
					local aiGrade = pvpWarCfg.AIchoice.AIquality
					local aiSkillLv = pvpWarCfg.AIchoice.AIskillGrade
					table.insert(rValueTb, { randomPool[rValue], aiLv, aiGrade, aiSkillLv })
				end
			end
			return rValueTb, randomPoolIndexTb
		end
	end
	if peroid <= 5 then
		local pvpWarCfg = warCfg.PVP1
		if self.themeTb and self.themeTb[peroid] then
			local themeId = self.themeTb[peroid]
			--@如果策划没有遵守承诺而导致id断续了，那就遍历themeChoice
			-- for k, v in pairs(pvpWarCfg.themeChoice) do
			-- 	if v.id == themeId then
			-- 		themeData = v
			-- 		break
			-- 	end
			-- end
			local themeData = pvpWarCfg.themeChoice[themeId]
			local lineupsData = {}
			--坦克部队随机 start
			local tankPool = self.randomPoolTank[peroid]
			local tankPoolSize = 0
			local maxTankNum = pvpWarCfg.tankChoice.tankNum
			if themeData.type == 1 then
				--[[随机上阵规则：如果没有坦克类型要求，就从坦克中10随机选6后打乱顺序放到1-6号位，将领，AI（固定放在123号位），飞机，飞机技能同理。
				如果要求“最多X组Y”，就先从0-X中随机出Y的数量，再随机剩余的车。打乱顺序放到1-6号位其他装备完全随机。
				如果要求“最少X组Y”，就先随机X个Y，再随机剩余的车，打乱顺序排列，其他装备随机
				(*[打乱顺序排列]暂未实现，待后续具体需求再来实现...)]]
				-- themeData.d1 --1-坦克，2-歼击车，4-自行火炮，8-火箭车
				-- themeData.d2 --上阵限制组数（{0,x}前者为类型参数（0为必须上阵x组，1为上阵不可超过x组），后者为上阵组数）
				local randomPool = {}
				local suprRandomPool = {}
				local randomPoolSize = 0
				for k, v in pairs(tankPool) do
					if tankCfg[tonumber(RemoveFirstChar(v))].type == tostring(themeData.d1) then
						table.insert(randomPool, k)
						randomPoolSize = randomPoolSize + 1
					else
						table.insert(suprRandomPool, k)
					end
					tankPoolSize = tankPoolSize + 1
				end
				if randomPoolSize > 0 then
					local tankPoolIndexTb = {}
					if themeData.d2[1] == 0 then
						local rPoolIndexTb = {}
						--防止因策划疏忽导致配置数据错误造成死循环
						local tempSize = (randomPoolSize < themeData.d2[2]) and randomPoolSize or themeData.d2[2]
						-- local tempSize = themeData.d2[2]
						for i = 1, tempSize do
							local rValue = math.random(1, randomPoolSize)
							while isEqual(rValue, rPoolIndexTb) do
								rValue = math.random(1, randomPoolSize)
							end
							table.insert(rPoolIndexTb, rValue)
							table.insert(tankPoolIndexTb, randomPool[rValue])
						end
						if tempSize < maxTankNum then
							for i = 1, maxTankNum - tempSize do
								local rValue = math.random(1, tankPoolSize)
								while isEqual(rValue, tankPoolIndexTb) do
									rValue = math.random(1, tankPoolSize)
								end
								table.insert(tankPoolIndexTb, rValue)
							end
						end
					elseif themeData.d2[1] == 1 then
						--防止因策划疏忽导致配置数据错误造成死循环
						local tempSize = math.random(0, (randomPoolSize < themeData.d2[2]) and randomPoolSize or themeData.d2[2])
						-- local tempSize = math.random(0, themeData.d2[2])
						local rPoolIndexTb = {}
						for i = 1, tempSize do
							local rValue = math.random(1, randomPoolSize)
							while isEqual(rValue, rPoolIndexTb) do
								rValue = math.random(1, randomPoolSize)
							end
							table.insert(rPoolIndexTb, rValue)
							table.insert(tankPoolIndexTb, randomPool[rValue])
						end
						if tempSize < maxTankNum then
							local supreRPSize = SizeOfTable(suprRandomPool)
							local supreRPIndexTb = {}
							for i = 1, maxTankNum - tempSize do
								local rValue = math.random(1, supreRPSize)
								while isEqual(rValue, supreRPIndexTb) do
									rValue = math.random(1, supreRPSize)
								end
								table.insert(supreRPIndexTb, rValue)
								table.insert(tankPoolIndexTb, suprRandomPool[rValue])
							end
						end
					end
					lineupsData[1] = {}
					for k, v in pairs(tankPoolIndexTb) do
						table.insert(lineupsData[1], { tonumber(RemoveFirstChar(tankPool[v])), troopsNum })
					end
				end
			end
			--坦克部队随机 end

			local startIndex = 1
			if lineupsData[1] then
				startIndex = 2
			end
			for i = startIndex, 5 do
				lineupsData[i] = randomTroops(i, pvpWarCfg)
				--检测军徽带兵量
				if i == 4 and lineupsData[i] and lineupsData[i] ~= "" then
					local eCfg = emblemVoApi:getEquipCfgById(lineupsData[i])
            		if eCfg and eCfg.attUp and eCfg.attUp.troopsAdd then
            			for k, v in pairs(lineupsData[1]) do
            				lineupsData[1][k][2] = lineupsData[1][k][2] + eCfg.attUp.troopsAdd
            			end
            		end
				end
			end
			return lineupsData
		else
			assert(false, "服内pvp暂无主题数据，无法随机部队！")
		end
	elseif peroid == 6 then
		local pvpWarCfg = warCfg.PVP2
		local lineupsDataTb = {}
		if customRandomPool then
			--随机一支部队
			for k, v in pairs(customRandomPool) do
				if k == 1 or k == 2 or k == 3 then
					local tempTb = {}
					for kk, vv in pairs(v) do
						if k == 1 and tonumber(vv[1]) then
							table.insert(tempTb, "a" .. vv[1])
						else
							table.insert(tempTb, vv[1])
						end
					end
					customRandomPool[k] = tempTb
				end
				lineupsDataTb[k] = randomTroops(k, pvpWarCfg)
			end
		else
			local randomIndexTb = {}
			--随机三支部队
			for j = 1, 3 do
				local lineupsData = {}
				local tempRandomIndexTb = {}
				for n = 1, 5 do
					local rIndexTb = (n == 5) and {{},{}} or {}
					for m = 1, j do
						if randomIndexTb[m] and randomIndexTb[m][n] then
							if type(randomIndexTb[m][n]) == "number" then
								table.insert(rIndexTb, randomIndexTb[m][n])
							else
								if n == 5 then
									for l = 1, 2 do
										table.insert(rIndexTb[l], randomIndexTb[m][n][l])
									end
								else
									for kk, vv in pairs(randomIndexTb[m][n]) do
										table.insert(rIndexTb, vv)
									end
								end
							end
						end
					end
					lineupsData[n], tempRandomIndexTb[n] = randomTroops(n, pvpWarCfg, rIndexTb, true)
					--检测军徽带兵量
					if n == 4 and lineupsData[n] and lineupsData[n] ~= "" then
						local eCfg = emblemVoApi:getEquipCfgById(lineupsData[n])
	            		if eCfg and eCfg.attUp and eCfg.attUp.troopsAdd then
	            			for k, v in pairs(lineupsData[1]) do
	            				lineupsData[1][k][2] = lineupsData[1][k][2] + eCfg.attUp.troopsAdd
	            			end
	            		end
					end
				end
				lineupsDataTb[j] = lineupsData
				randomIndexTb[j] = tempRandomIndexTb
			end
		end
		return lineupsDataTb
	end
end

--获取已保存的部队信息
--@troopsIndex : 部队索引值(第几只部队)
function exerWarVoApi:getTroopsData(troopsIndex)
	if self.troopsInfo then
		if self.setTroopsTs and G_getWeeTs(self.setTroopsTs) ~= G_getWeeTs(base.serverTime) then
			do return end
		end
		return G_clone(self.troopsInfo[troopsIndex or 1])
	end
end

--获取可用部队数据
function exerWarVoApi:getCanUseTroops()
	local troopsData
	local warCfg = self:getWarCfg()
	local peroid = self:getWarPeroid()
	local function initTroopsData(pvpWarCfg, specialHeroTb)
		troopsData = {}
		local troopsNum = self:getBaseTroopsNum()
		local tankPool = self.randomPoolTank[peroid]
		if tankPool == nil then
			return
		end
		troopsData[1] = {}
		for k, v in pairs(tankPool) do
			table.insert(troopsData[1], { v, troopsNum })
		end

		troopsData[2] = {}
		local heroPool = self.randomPoolHero[peroid]
		local recFlag
		local heroLv = pvpWarCfg.heroChoice.heroGrade
		local heroStarLv = pvpWarCfg.heroChoice.heroStar
		local heroSkillLv = pvpWarCfg.heroChoice.skillGrade
		for k, v in pairs(heroPool) do
			if specialHeroTb then
				for kk, vv in pairs(specialHeroTb) do
					if v == vv then
						recFlag = true
						break
					end
				end
			end
			local tempHeroTb = { v, heroLv, heroStarLv, heroSkillLv }
			if recFlag then
				recFlag = nil
				table.insert(troopsData[2], 1, tempHeroTb)
			else
				table.insert(troopsData[2], tempHeroTb)
			end
		end

		troopsData[3] = {}
		local aiTroopsPool = pvpWarCfg.AIchoice.AI
		local aiLv = pvpWarCfg.AIchoice.AIgrade
		local aiGrade = pvpWarCfg.AIchoice.AIquality
		local aiSkillLv = pvpWarCfg.AIchoice.AIskillGrade
		for k, v in pairs(aiTroopsPool) do
			table.insert(troopsData[3], { v, aiLv, aiGrade, aiSkillLv })
		end

		troopsData[4] = pvpWarCfg.equipChoice.equipId

		troopsData[5] = {
			pvpWarCfg.planeChoice.planeId,
			pvpWarCfg.planeChoice.skillId
		}
	end
	if peroid <= 5 then
		local pvpWarCfg = warCfg.PVP1
		if self.themeTb and self.themeTb[peroid] then
			local themeId = self.themeTb[peroid]
			--@如果策划没有遵守承诺而导致id断续了，那就遍历themeChoice
			-- for k, v in pairs(pvpWarCfg.themeChoice) do
			-- 	if v.id == themeId then
			-- 		themeData = v
			-- 		break
			-- 	end
			-- end
			local themeData = pvpWarCfg.themeChoice[themeId]
			initTroopsData(pvpWarCfg, themeData.specialhero)
		end
	elseif peroid == 6 then
		local pvpWarCfg = warCfg.PVP2
		initTroopsData(pvpWarCfg)
	end
	return troopsData
end

--显示可用部队信息小弹板
function exerWarVoApi:showAllTroopsSmallDialog(layerNum, troopsData)
	require "luascript/script/game/scene/gamedialog/exerwar/exerWarSmallDialog"
	exerWarSmallDialog:showAllTroops(layerNum, getlocal("exerwar_canUseTroopsInfoText"), troopsData)
end

--@ bkey:轮数-场次（只在16强对阵战报时使用）
function exerWarVoApi:getReportList(peroid, bkey)
	local reportList = self:getReportCache(peroid, bkey)
	if reportList then
		return reportList
	end
	local rType
	if peroid <= 5 then
		rType = 1 --服内
	elseif peroid == 6 then
		rType = 2 --跨服初赛
	elseif peroid == 7 then
		rType = 3 --跨服决赛
	end
	local ip
	if rType == 1 then
		ip = base.serverIp
	elseif (rType == 2 or rType == 3) and self.serverHost then
		ip = self.serverHost
	end
	if ip then
		local httpURL = "http://" .. ip .. "/tank-server/public/index.php/api/exerwar/reportlist"
		local ts = G_getWeeTs(self.warSt) + 86400 * (peroid - 1)
		local requestParams = string.format("bid=%s&uid=%s&zoneid=%s&type=%s&ts=%s", self.bid, playerVoApi:getUid(), base.curZoneID, rType, ts)
		if bkey then
			requestParams = requestParams .. "&bkey=" .. bkey
		end
		local responseStr = G_sendHttpRequestPost(httpURL, requestParams)
		if responseStr and responseStr ~= "" then
			print("cjl ------>>> http URL:\n", httpURL .. "?" .. requestParams)
			print("cjl ------>>> http response:\n", responseStr)
			local sData = G_Json.decode(responseStr)
			if sData and sData.ret == 0 then
				self:addReportCache(sData.data, peroid, bkey)
				return sData.data
			end
		end
	end
end

--@rid : 战报id
function exerWarVoApi:getReportDetail(peroid, rid)
	local rType
	if peroid <= 5 then
		rType = 1 --服内
	elseif peroid == 6 then
		rType = 2 --跨服初赛
	elseif peroid == 7 then
		rType = 3 --跨服决赛
	end
	local ip
	if rType == 1 then
		ip = base.serverIp
	elseif (rType == 2 or rType == 3) and self.serverHost then
		ip = self.serverHost
	end
	if ip then
		local httpURL = "http://" .. ip ..  "/tank-server/public/index.php/api/exerwar/report"
		local requestParams = string.format("id=%s&uid=%s&zoneid=%s&type=%s", rid, playerVoApi:getUid(), base.curZoneID, rType)
		local responseStr = G_sendHttpRequestPost(httpURL, requestParams)
		if responseStr and responseStr ~= "" then
			print("cjl ------>>> http URL:\n", httpURL .. "?" .. requestParams)
			print("cjl ------>>> http response:\n", responseStr)
			local sData = G_Json.decode(responseStr)
			if sData and sData.ret == 0 then
				if sData.data and sData.data.list then
					self:addReportCache(sData.data.list, peroid, rid)
					return sData.data.list
				end
			end
		end
	end
end

function exerWarVoApi:addReportCache(data, peroid, rid)
	if data == nil then
		do return end
	end
	if self.reportCache == nil then
		self.reportCache = {}
	end
	if self.reportCache[peroid] == nil then
		self.reportCache[peroid] = {}
	end
	if rid then
		if self.reportCache[peroid][2] == nil then
			self.reportCache[peroid][2] = {}
		end
		self.reportCache[peroid][2][rid] = data
	else
		self.reportCache[peroid][1] = data
	end
end

function exerWarVoApi:getReportCache(peroid, rid)
	if self.reportCache and self.reportCache[peroid] then
		if rid then
			if self.reportCache[peroid][2] then
				return self.reportCache[peroid][2][rid]
			end
		else
			return self.reportCache[peroid][1]
		end
	end
end

--@rid : 战报id
function exerWarVoApi:showReportDetail(layerNum, peroid, rid, report, reportTitleStr)
	local reportData
	if report then
		reportData = report
	else
		reportData = self:getReportCache(peroid, rid)
		if reportData == nil then
			reportData = self:getReportDetail(peroid, rid)
		end
	end
	if reportData then
		-------------- 检测地形主题，更改战斗背景 --------------
		if self.themeTb and self.themeTb[peroid] then
			local warCfg = self:getWarCfg()
			local themeId = self.themeTb[peroid]
			--@如果策划没有遵守承诺而导致id断续了，那就遍历themeChoice
			-- for k, v in pairs(warCfg.PVP1.themeChoice) do
			-- 	if v.id == themeId then
			-- 		themeData = v
			-- 		break
			-- 	end
			-- end
			local themeData = warCfg.PVP1.themeChoice[themeId]
			if themeData and themeData.type == 4 then
				reportData.landform = {themeData.d1, themeData.d1}
			end
		end
		-------------- 检测地形主题，更改战斗背景 --------------
		require "luascript/script/game/scene/gamedialog/exerwar/exerWarReportDetailDialog"
		local td = exerWarReportDetailDialog:new(layerNum, reportData, reportTitleStr)
	    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("fight_content_fight_title"), true, layerNum)
	    sceneGame:addChild(dialog, layerNum)
	else
		G_showTipsDialog(getlocal("serverWarLocal_noData"))
	end
end

--检测单支部队是否设置完整
--所有战斗位坦克，将领，AI部队，军徽，飞机都设置视为完整
--troops：需要检查的部队信息，peroid：服内pvp第几轮
--return 1：坦克不合法，2：将领不合法，3：AI部队不合法，4：军徽不合法，5：飞机不合法，6：主题限制坦克种类数量不够
function exerWarVoApi:isTroopsFull(troops, peroid)
    if troops == nil or type(troops) ~= "table" then
        return false
    end
    local theme
    if peroid and peroid <= 5 and self.themeTb then
    	local themeId = self.themeTb[peroid]
    	local pvpWarCfg = self:getWarCfg()
    	theme = pvpWarCfg.PVP1.themeChoice[themeId]
    end
    local tankTb, heroTb, aiTb, emblemId, planeTb = (troops[1] or {}), (troops[2] or {}), (troops[3] or {}), troops[4], (troops[5] or {})
    local num, tankTbSize = 0, 0
    for k, v in pairs(tankTb) do
    	if v[1] == nil or v[2] == nil or v[2] == 0 then
    		return false, 1 --坦克有空位
    	end
    	local tankId = tonumber(v[1]) or tonumber(RemoveFirstChar(v[1]))
        local tankType = tankCfg[tankId].type
        if theme and theme.type == 1 and theme.d1 == tonumber(tankType) then
        	num = num + 1
        end
        tankTbSize = tankTbSize + 1
    end
    if tankTbSize ~= 6 then
    	return false, 1 --坦克有空位
    end
    if theme and theme.type == 1 and theme.d2 then
    	if theme.d2[1] == 1 and num > theme.d2[2] then --装配不可超过d2[2]组
    		return false, 6
    	elseif theme.d2[1] == 0 and num < theme.d2[2] then --装配必须是d2[2]组
    		return false, 6
    	end
    end
    if emblemId == nil then
        return false, 4 --军徽没有装配
    end
    if planeTb[1] == nil or planeTb[2] == nil then
        return false, 5 --没有装配飞机或主动技能
    end
    local aiNum = 0
    for k, v in pairs(aiTb) do
    	if v and type(v) == "table" and v[1] then
    		aiNum = aiNum + 1
    	end
    end
    local AILimitNum = AITroopsFleetVoApi:AITroopsEquipLimitNum()
    if aiNum ~= AILimitNum then
        return false, 3 --AI部队不合法
    end
    local heroTbSize = 0
    for k, v in pairs(heroTb) do
    	if v == nil or v == 0 or v[1] == nil then
    		return false, 2 --将领有空位
    	end
    	heroTbSize = heroTbSize + 1
    end
    if heroTbSize ~= 6 then
    	return false, 2 --将领有空位
    end
    return true
end

--判断两只部队是否相同
function exerWarVoApi:checkSameTroops(troops1, troops2)
	if troops1 and troops2 then
		local str1 = G_Json.encode(troops1)
		local str2 = G_Json.encode(troops2)
		if str1 == str2 then
			return true
		end
	end
	if troops1 == nil and troops2 == nil then
		return true
	end
	return false
end

--获取当前结算x强
function exerWarVoApi:getFinalTimeStatus()
	local peroid, status = self:getWarPeroid()
	if peroid >= 7 and status >= 30 then
		if status == 30 then
			local warCfg = self:getWarCfg()
			local tempTime = G_getWeeTs(base.serverTime) + warCfg.PVP2.lastTime
			if base.serverTime <= tempTime then --16进8，定8强
				return tempTime - base.serverTime, 8
			elseif (base.serverTime - tempTime) / warCfg.PVP2.intervalTime <= 1 then --8进4，定4强
				return warCfg.PVP2.intervalTime - (base.serverTime - tempTime), 4
			elseif (base.serverTime - tempTime) / warCfg.PVP2.intervalTime <= 2 then --4进2，定2强
				return warCfg.PVP2.intervalTime - (base.serverTime - tempTime - warCfg.PVP2.intervalTime), 2
			elseif (base.serverTime - tempTime) / warCfg.PVP2.intervalTime <= 3 then --总决赛，定冠军
				return warCfg.PVP2.intervalTime - (base.serverTime - tempTime - warCfg.PVP2.intervalTime * 2), 1
			end
		end
		return 0, 0 --已结束
	else
		return --未开启
	end
end

function exerWarVoApi:showReportListSmallDialog(layerNum, period, round, isShowPraise)
	local reportData = self:getReportList(period, round)
	if reportData and reportData.list and reportData.list[1] then
		reportData = reportData.list[1]
	end
	if reportData then
		local reportTitleStr
		local roundI = tonumber(Split(round, "-")[1])
		if roundI == 1 or roundI == 2 then
			if roundI == 1 then
				reportTitleStr = getlocal("exerwar_competitionTitleText", {8})
			else
				reportTitleStr = getlocal("exerwar_competitionTitleText", {4})
            end
        elseif roundI == 3 then
            reportTitleStr = getlocal("world_war_semi_final_battle")
        else
            reportTitleStr = getlocal("serverwar_finalFight")
		end
		require "luascript/script/game/scene/gamedialog/exerwar/exerWarSmallDialog"
		exerWarSmallDialog:showReportList(layerNum, getlocal("exerwar_checkReportText"), reportData, reportTitleStr, isShowPraise)
	else
		G_showTipsDialog(getlocal("serverWarLocal_noData"))
	end
end

function exerWarVoApi:showScoreDetailSmallDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/exerwar/exerWarSmallDialog"
	exerWarSmallDialog:showScoreDetail(layerNum, getlocal("exerwar_scoreDetailText"))
end

function exerWarVoApi:getMyPoint()
	if self.myPoint then
		return self.myPoint
	end
	return 0
end

function exerWarVoApi:getPointInfo()
	if self.pointinfo then
		return self.pointinfo
	end
end

--获取总积分
function exerWarVoApi:getTotalScore()
	local score = 0
	if self.pointinfo then
		for k, v in pairs(self.pointinfo) do
			score = score + v
		end
	end
	return score
end

--获取排行积分（从前5轮中取最大的3个）
function exerWarVoApi:getRankScore()
	local score = 0
	local tempMaxIndex
	if self.pointinfo then
		local tempScore = {}
		for k, v in pairs(self.pointinfo) do
			if tonumber(RemoveFirstChar(k)) <= 5 then
				table.insert(tempScore, { key = k, value = v })
			end
		end
		table.sort(tempScore, function(a, b) return a.value > b.value end)
		for i = 1, 3 do
			if tempScore[i] then
				score = score + tempScore[i].value
				if tempMaxIndex == nil then
					tempMaxIndex = {}
				end
				table.insert(tempMaxIndex, tempScore[i].key)
			end
		end
	end
	return score, tempMaxIndex
end

--获取参赛名单
function exerWarVoApi:getCompetitionList()
	if self.competitionList then
		return self.competitionList
	else
		local warCfg = self:getWarCfg()
		local httpURL = "http://"  .. self.serverHost .. "/tank-server/public/index.php/api/exerwar/compe"
		local requestParams = string.format("bid=%s&uid=%s&zoneid=%s", self.bid, playerVoApi:getUid(), base.curZoneID)
		local responseStr = G_sendHttpRequestPost(httpURL, requestParams)
		if responseStr and responseStr ~= "" then
			print("cjl ------>>> http URL:\n", httpURL .. "?" .. requestParams)
			print("cjl ------>>> http response:\n", responseStr)
			local sData = G_Json.decode(responseStr)
			if sData and sData.ret == 0 then
				if sData.data and sData.data.list then
					self.competitionList = sData.data.list
					return sData.data.list
				end
			end
		end
	end
end

--是否进入初赛（决赛是在初赛的基础上，所以进入决赛的就一定进入了初赛）
function exerWarVoApi:isEnterFirstPVP()
	return (self.isEnterServer == 1 or self.isEnterServer == 2)
end

--是否进入决赛
function exerWarVoApi:isEnterFinal()
	return (self.isEnterServer == 2)
end

--获取决赛日的16强数据
function exerWarVoApi:getFinalData(callback)
	local ts, value = self:getFinalTimeStatus()
	if ts == nil and value == nil then --未开启
		return
	end
	if self.finalData and SizeOfTable(self.finalData) > 0 then
		if type(callback) == "function" then
			callback(self.finalData)
		end
		return self.finalData
	else
		local function socketCallback(fn, data)
			local ret, sData = base:checkServerData(data)
	        if ret == true then
	        	if sData and sData.data and sData.data.battlelist then
	        		self.finalData = sData.data.battlelist
		        	if type(callback) == "function" then
		        		callback(self.finalData)
		        	end
	        	end
	        end
	    end
		socketHelper:exerWarFinal(socketCallback)
	end
end

function exerWarVoApi:getScoreShopData(shopId)
	local warCfg = self:getWarCfg()
	if shopId then
		for k, v in pairs(warCfg.pointShop) do
			if shopId == v.id then
				return v
			end
		end
	else
        local period, warStatus = self:getWarPeroid()
        local ts, value = self:getFinalTimeStatus()
        if period >= 7 and ts and ts == 0 and value and value == 0 then --所有赛事结束后才可购买
        	local canBuyTb, notCanBuyTb = {}, {}
        	local myScore = self:getMyPoint()
        	for k, v in pairs(warCfg.pointShop) do
        		local isCanBuy = false
        		local buyNum = self:getScoreShopExchangeNum(v.id)
        		if v.num > buyNum then
	        		if v.type == 2 then
	        			isCanBuy = self:isEnterFirstPVP()
	        		elseif v.type == 3 then
	        			isCanBuy = self:isEnterFinal()
	        		else
	        			isCanBuy = true
	        		end
	        	end
	        	if isCanBuy then
	        		if myScore < v.cost then
	        			isCanBuy = false
	        		end
	        	end
	        	local sflag = true -- 是否可以售卖的标识
	        	local rwards = FormatItem(v.item)
	        	for k,v in pairs(rwards) do
		        	if bagVoApi:isRedAccessoryProp(v.key) == true and bagVoApi:isRedAccPropCanSell() == false then
		        		sflag = false
		        		do break end
		        	end
	        	end
	        	if sflag == true then --排除掉不可以售卖红色配件的相关购买项
	        		if isCanBuy then
		        		table.insert(canBuyTb, v)
		        	else
		        		table.insert(notCanBuyTb, v)
		        	end
	        	end
        	end
        	local tempDataA, tempDataB, tempDataC = {}, {}, {}
        	for k, v in pairs(notCanBuyTb) do
        		if v.num > self:getScoreShopExchangeNum(v.id) then
        			if myScore < v.cost then
        				table.insert(tempDataA, v)
        			else
        				table.insert(tempDataB, v)
        			end
        		else
        			table.insert(tempDataC, v)
        		end
        	end
        	local tempData = {}
        	for k, v in pairs(canBuyTb) do table.insert(tempData, v) end
        	for k, v in pairs(tempDataA) do table.insert(tempData, v) end
        	for k, v in pairs(tempDataB) do table.insert(tempData, v) end
        	for k, v in pairs(tempDataC) do table.insert(tempData, v) end
        	return tempData
        else
        	return warCfg.pointShop
        end
	end
end

--【跨服演习战】商店购买
--@ shopid:商店id
--@ num:购买数量
function exerWarVoApi:shopBuyItem(callback, shopid, num)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		local temp = self:getScoreShopData(shopid)
				sData.data.point = self:getMyPoint() - temp.cost * num
				self:initData({ ecrossinfo = sData.data })
	        	if type(callback) == "function" then
	        		callback()
	        	end
	        end
        end
	end
	socketHelper:exerWarShopBuy(socketCallback, shopid, num)
end

--获取积分商店兑换次数
function exerWarVoApi:getScoreShopExchangeNum(shopId)
	if self.exchangeInfo and self.exchangeInfo["i" .. shopId] then
		return self.exchangeInfo["i" .. shopId]
	end
	return 0
end

--获取积分商店兑换记录
function exerWarVoApi:getScoreShopExchangeLog()
	if self.exchangeLog then
		table.sort(self.exchangeLog, function(a, b) return a[1] > b[1] end)
		return self.exchangeLog
	end
end

--获取16强排行奖励
function exerWarVoApi:getRankReward()
	local warCfg = self:getWarCfg()
	return warCfg.rankReward
end

--是否可以点赞
function exerWarVoApi:isCanPraise()
	return (not (self.isPraise or false))
end

--获取点赞积分
function exerWarVoApi:getPraiseScore()
	local warCfg = self:getWarCfg()
	return warCfg.PVP2.praisePoint
end

--点赞
function exerWarVoApi:requestPraise(callback)
	if self.isPraise == true then
		G_showTipsDialog(getlocal("exerwar_havePraiseText"))
		return
	end
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	local rewardPoint = self:getMyPoint() + self:getPraiseScore()
			self:initData({ ecrossinfo = { praiseflag = 1, point = rewardPoint } })
    		if type(callback) == "function" then
    			callback()
    		end
        end
    end
	socketHelper:exerWarPraise(socketCallback)
end

--获取继承配件的百分比
function exerWarVoApi:getAccessoryPercent()
	local warCfg = self:getWarCfg()
	return warCfg.PVP2.succeedPercent * 100
end

--获取开启的剩余时间
function exerWarVoApi:getOpenSurplusTime(tempPeroid)
	local peroid = self:getWarPeroid()
	if tempPeroid > peroid then
		local ts = G_getWeeTs(base.serverTime) + 86400 - base.serverTime +  (tempPeroid - peroid - 1) * 86400
		return ((ts < 0) and 0 or ts)
	end
	return 0
end

--获得演习主题
function exerWarVoApi:getManeuverThemeTitle(tempPeroid)
	local str = ""
	local peroid = tempPeroid or self:getWarPeroid()
	if self.themeTb and self.themeTb[peroid] then
		local warCfg = self:getWarCfg()
		local themeId = self.themeTb[peroid]
		--@如果策划没有遵守承诺而导致id断续了，那就遍历themeChoice
		-- for k, v in pairs(warCfg.PVP1.themeChoice) do
		-- 	if v.id == themeId then
		-- 		themeData = v
		-- 		break
		-- 	end
		-- end
		local themeData = warCfg.PVP1.themeChoice[themeId]
		if themeData then
			local fleetNameMap = {[1] = getlocal("tanke"), [2] = getlocal("jianjiche"), [4] = getlocal("zixinghuopao"), [8] = getlocal("huojianche"), [15] = getlocal("believer_all_fleet")}
			--类型为1时：d1-坦克类型（1-坦克，2-歼击车，4-自行火炮，8-火箭车），d2-上阵限制组数（{0,x}前者为类型参数（0为必须上阵x组，1为上阵不可超过x组），后者为上阵组数）；
			--类型为2时：d1-克制类型（1-坦克，2-歼击车，4-自行火炮，8-火箭车），d2-克制坦克（1-坦克，2-歼击车，4-自行火炮，8-火箭车），d3-提升百分比；
			--类型为3时：d1-属性增长号位，d2-提升属性类型及提升百分比；
			--类型为4时：d1-地形类型（1-山地，2-沙漠，3-平原，4-森林，5-沼泽，6-城市））
			if themeData.type == 1 then --阵容相关
				if themeData.d2[1] == 0 then
					str = getlocal("exerwar_maneuverThemeText" .. themeData.type .. "_1", {themeData.d2[2], fleetNameMap[themeData.d1]})
				elseif themeData.d2[1] == 1 then
					str = getlocal("exerwar_maneuverThemeText" .. themeData.type .. "_2", {themeData.d2[2], fleetNameMap[themeData.d1]})
				end
			elseif themeData.type == 2 then --克制相关
				str = getlocal("exerwar_maneuverThemeText" .. themeData.type, {fleetNameMap[themeData.d1], fleetNameMap[themeData.d2], (themeData.d3 * 100)})
			elseif themeData.type == 3 then --属性相关
				local attStr, attValue
				for k, v in pairs(themeData.d2) do
					attStr = getlocal(buffEffectCfg[buffKeyMatchCodeCfg[k]].name)
					attValue = (v * 100)
				end
				str = getlocal("exerwar_maneuverThemeText" .. themeData.type, {themeData.d1, attStr, attValue})
			elseif themeData.type == 4 then --地形相关
				local params = {getlocal("world_ground_name_" .. themeData.d1)}
				local groundCfg = worldGroundCfg[themeData.d1]
				if groundCfg then
					for k, v in pairs(groundCfg.attType) do
						local attName = getlocal("exerwar_themeGroundAtt_" .. v)
						local attValue = ((groundCfg.attValue[k] > 0) and "+" or "") .. groundCfg.attValue[k]
						table.insert(params, attName .. attValue)
					end
				end
				str = getlocal("exerwar_maneuverThemeText" .. themeData.type, params)
			end
			str = str .. " " .. getlocal("firstValue") .. "+" .. (themeData.first or 0)
		end
	end
	return str
end

function exerWarVoApi:setRedPointStatus()
	local flag, peroid = self:isShowRedPoint()
	if flag == true then
		local settingsKey = "exerWar@day" .. peroid .. "@" .. playerVoApi:getUid() .. "@" .. base.curZoneID
		local settingsValue = "1-" .. base.serverTime
		CCUserDefault:sharedUserDefault():setStringForKey(settingsKey, settingsValue)
		CCUserDefault:sharedUserDefault():flush()
	end
end

function exerWarVoApi:isShowRedPoint()
	if self:isOpen() ~= 0 then
		return false
	end
	local peroid, status = self:getWarPeroid()
	if peroid == 7 then
		if status >= 40 then
			peroid = peroid + 1
		end
	end
	local settingsKey = "exerWar@day" .. peroid .. "@" .. playerVoApi:getUid() .. "@" .. base.curZoneID
	local valueStr = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
	local valueTb = Split(valueStr, "-")
	local flag, flagTs = 0, 0
	if type(valueTb) == "table" then
		flag = tonumber(valueTb[1]) or 0
		flagTs = tonumber(valueTb[2]) or 0
	end
	if flag == 1 and (peroid <= 7 and G_getWeeTs(base.serverTime) == G_getWeeTs(flagTs) or true) then
		return false, peroid
	else
		return true, peroid
	end
end

--胜利获得的积分(pvpType: 1服内, 2跨服)
function exerWarVoApi:getWinScore(pvpType)
	local warCfg = self:getWarCfg()
	return warCfg["PVP" .. pvpType].winPoint
end

--失败获得的积分(pvpType: 1服内, 2跨服)
function exerWarVoApi:getFailScore(pvpType)
	local warCfg = self:getWarCfg()
	return warCfg["PVP" .. pvpType].lossPoint
end

function exerWarVoApi:sortHeroPool(data)
	local peroid = self:getWarPeroid()
	if self.themeTb and self.themeTb[peroid] then
		local warCfg = self:getWarCfg()
		local themeId = self.themeTb[peroid]
		--@如果策划没有遵守承诺而导致id断续了，那就遍历themeChoice
		-- for k, v in pairs(warCfg.PVP1.themeChoice) do
		-- 	if v.id == themeId then
		-- 		themeData = v
		-- 		break
		-- 	end
		-- end
		local themeData = warCfg.PVP1.themeChoice[themeId]
		if themeData and themeData.type == 4 then
			if themeData.specialhero then
				local tempData = {}
				for kk, vv in pairs(data) do
					local heroId = vv[1]
					for k, v in pairs(themeData.specialhero) do
						if heroId == v then
							tempData[k] = vv
							table.remove(data, kk)
							break
						end
					end
				end
				local tempDataI = 1
				for k, v in pairs(tempData) do
					table.insert(data, tempDataI, v)
					tempDataI = tempDataI + 1
				end
			end
		end
	end
	return data
end

--获取将领地形主题图片
function exerWarVoApi:getHeroGroundPic(heroId)
	local peroid = self:getWarPeroid()
	if self.themeTb and self.themeTb[peroid] then
		local warCfg = self:getWarCfg()
		local themeId = self.themeTb[peroid]
		--@如果策划没有遵守承诺而导致id断续了，那就遍历themeChoice
		-- for k, v in pairs(warCfg.PVP1.themeChoice) do
		-- 	if v.id == themeId then
		-- 		themeData = v
		-- 		break
		-- 	end
		-- end
		local themeData = warCfg.PVP1.themeChoice[themeId]
		if themeData and themeData.type == 4 then
			if themeData.specialhero then
				for k, v in pairs(themeData.specialhero) do
					if heroId == v then
						return ("world_ground_" .. themeData.d1 .. ".png")
					end
				end
			end
		end
	end
end

--判断将领是否增加先手值
function exerWarVoApi:isHeroFirst(heroId)
	if heroId and heroListCfg[heroId] then
        for k, v in pairs(heroListCfg[heroId].skills) do
        	local heroSkillId = v[1]
        	if heroSkillCfg[heroSkillId] and (heroSkillCfg[heroSkillId].attType == "first" or heroSkillCfg[heroSkillId].attType == "antifirst") then
        		return true
        	end
        end
    end
    return false
end

--获取积分兑换功能开启时间
function exerWarVoApi:getExchangeOpenTime()
	local warCfg = self:getWarCfg()
	-- local openTs = (self.warSt + (warCfg.pvp1Time + warCfg.pvp2Time) * 86400)
	local openTs = (self.warSt + (warCfg.pvp1Time + warCfg.pvp2Time - 1) * 86400)
	openTs = openTs + warCfg.PVP2.lastTime + 3 * warCfg.PVP2.intervalTime
	openTs = openTs + 1
	if base.serverTime <= openTs then
		return openTs - base.serverTime
	end
	return 0
end

--获取积分兑换功能剩余时间
function exerWarVoApi:getExchangeSupreTime()
	local peroid, status = self:getWarPeroid()
	local ts, value = self:getFinalTimeStatus()
	if peroid >= 7 and ts and ts == 0 and value and value == 0 then
		if self.warEt > base.serverTime then
			return self.warEt - base.serverTime
		end
	end
	return 0
end

--是否设置过部队
function exerWarVoApi:isSettingTroops()
	if self.setTroopsTs and self.setTroopsTs > 0 then
		return true
	end
	return false
end

--获取基础先手值
function exerWarVoApi:getBaseFirstValue()
	local warCfg = self:getWarCfg()
	return warCfg.playerFirst
end

--获取先手值
function exerWarVoApi:getFirstValue(troopsData)
	local firstValue = 0
	if troopsData then
		for k, v in pairs(troopsData) do
			if k == 2 or k == 4 then --只有将领和军徽加先手值
				if k == 2 then
					for kk, vv in pairs(v) do
						local heroId = vv[1]
						if heroId and heroListCfg[heroId] then
	                        -- local heroLevel = vv[2] or 1
	                        -- local heroStarLv = vv[3] or 1
	                        local heroSkillLv = vv[4] or 1
	                        for kkk, vvv in pairs(heroListCfg[heroId].skills) do
	                        	local heroSkillId = vvv[1]
	                        	if heroSkillCfg[heroSkillId] and heroSkillCfg[heroSkillId].attType == "first" then
	                        		firstValue = firstValue + (heroSkillCfg[heroSkillId].attValuePerLv * heroSkillLv)
	                        	end
	                        end
	                    end
					end
				else
					local emblemId = v
					if emblemListCfg.equipListCfg[emblemId] then
						local emblemSkillId = emblemListCfg.equipListCfg[emblemId].skill[1]
						local emblemSkillLv = emblemListCfg.equipListCfg[emblemId].skill[2]
						if emblemListCfg.skillCfg[emblemSkillId] and emblemListCfg.skillCfg[emblemSkillId].stype == 2 then
							if emblemListCfg.skillCfg[emblemSkillId]["value" .. emblemSkillLv] then
								firstValue = firstValue + emblemListCfg.skillCfg[emblemSkillId]["value" .. emblemSkillLv][1]
							end
						end
					end
				end
			end
		end
	end
	return firstValue
end

--获取晋级人数
--@cType: 1-服内, 2-跨服, nil-默认
function exerWarVoApi:getWinNum(cType)
	local warCfg = self:getWarCfg()
	if cType == nil then
		return warCfg.severWinner
	elseif warCfg["PVP" .. cType] then
		return warCfg["PVP" .. cType].winNum
	end
	return 0
end

function exerWarVoApi:requestRankData(idx, callback)
	if idx == 1 then
		local function socketCallback(fn, data)
			local ret, sData = base:checkServerData(data)
	        if ret == true then
	        	if sData and sData.data then
		    		if type(callback) == "function" then
		    			callback(sData.data)
		    		end
		    	end
	        end
	    end
		socketHelper:exerWarRanklist(socketCallback)
	else
		local userParams = {"preli", "final", "fame"}
		local httpURL = "http://" .. self.serverHost ..  "/tank-server/public/index.php/api/exerwar/" .. userParams[idx - 1]
		local requestParams = string.format("bid=%s&uid=%s&zoneid=%s", self.bid, playerVoApi:getUid(), base.curZoneID)
		if idx == 2 or idx == 3 or idx == 4 then
			local warCfg = self:getWarCfg()
			local ts
			if idx == 2 then
				ts = G_getWeeTs(self.warSt) + warCfg.pvp1Time * 86400 + warCfg.PVP2.overTime
			else
				ts = G_getWeeTs(self.warSt) + (6 * 86400) + warCfg.PVP2.lastTime + warCfg.PVP2.intervalTime * 3
			end
			requestParams = requestParams .. "&ts=" .. ts
		end
		local responseStr = G_sendHttpRequestPost(httpURL, requestParams)
		if responseStr and responseStr ~= "" then
			print("cjl ------>>> http URL:\n", httpURL .. "?" .. requestParams)
			print("cjl ------>>> http response:\n", responseStr)
			local sData = G_Json.decode(responseStr)
			if sData and sData.ret == 0 then
				if sData.data and sData.data.list then
					if type(callback) == "function" then
						callback(sData.data.list)
					end
				end
			end
		end
	end
end

function exerWarVoApi:getRankSelfData()
	if self.rankSelfData then
		return self.rankSelfData
	end
	return {}
end

--获取已竞拍的金币数
function exerWarVoApi:getAuctionGem()
	if self.auctionGem then
		return self.auctionGem
	end
	return 0
end

function exerWarVoApi:setAuctionGem(auctionGem)
	self.auctionGem = auctionGem
end

--获取保送倒计时
function exerWarVoApi:getBiddingCountdown()
	local warCfg = self:getWarCfg()
	local auctionSt = G_getWeeTs(self.warSt) + (warCfg.pvp1Time - 1) * 86400 --竞拍开始时间（包括军事演习第一的开始时间）
	local auctionEt = auctionSt + warCfg.PVP1.joinTime --竞拍结束时间
	local auctionShowTs = auctionSt + warCfg.PVP1.overTime --竞拍公布时间
	if base.serverTime <= auctionSt + 1 then --距竞拍开启的剩余时间
		return 1, auctionSt - base.serverTime
	elseif base.serverTime <= auctionEt + 1 then --距竞拍结束的剩余时间
		return 2, auctionEt - base.serverTime
	elseif base.serverTime <= auctionShowTs + 1 then ----距竞拍公布的剩余时间
		return 3, auctionShowTs - base.serverTime
	else
		return 4
	end
end

function exerWarVoApi:getAuctionNeedAndLimit()
	local warCfg = self:getWarCfg()
	local needCost, limitCost, addCost = warCfg.PVP1.buyCost, warCfg.PVP1.tickeCost1, warCfg.PVP1.tickeCost2
	return needCost, limitCost, addCost
end

function exerWarVoApi:auctionSocket(gem, callback)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	self.auctionGem = (self.auctionGem or 0) + gem
        	if callback then
        		callback()
        	end
        end
	end
	socketHelper:exerWarAuction(gem, socketCallback)
end

function exerWarVoApi:clear()
	self.serverHost = nil
	self.themeTb = nil
	self.randomPoolTank = nil
	self.randomPoolHero = nil
	self.bid = nil
	self.troopsInfo = nil
	self.pointinfo = nil
	self.myPoint = nil
	self.isEnterServer = nil
	self.isPraise = nil
	self.exchangeInfo = nil
	self.exchangeLog = nil
	self.setTroopsTs = nil
	self.rankSelfData = nil
	self.auctionGem = nil
	self.finalRank = nil
	self.reportCache = nil
	self.competitionList = nil
    self.finalData = nil
end
