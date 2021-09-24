acNewYearsEveVoApi={
	tankState = {ALIVE = 1,REVIVING = 2},
	needRefresh = false,
	killType = {CUSTOM = 1,SPECIAL = 2},
	rankList = {{},{}},
	dataOverTime = 60,
	lastSyncTime = 0,
	spaceTime = 0,
	acShowType = { TYPE_1=1, TYPE_2=2 },
	log = {}
}

function acNewYearsEveVoApi:getAcVo()
	if self.vo == nil then
		self.vo = activityVoApi:getActivityVo("newyeareva")
	end
	return self.vo
end

function acNewYearsEveVoApi:updateData(data)
	local acVo = self:getAcVo()
	if acVo then
		acVo:updateSpecialData(data)
	end
end

function acNewYearsEveVoApi:clearAll()
	self.log = {}
	self.needRefresh = false
	self.rankList = {{},{}}
	self.dataOverTime = 60
	self.lastSyncTime = 0
	self.spaceTime = 0
	self.vo = nil
end

function acNewYearsEveVoApi:canReward()
	return  false
end

function acNewYearsEveVoApi:getAcShowType()
	local version = self:getVersion()
	if version==2 then
		return self.acShowType.TYPE_2
	else
		return self.acShowType.TYPE_1
	end
end

function acNewYearsEveVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
end

--获取剩余免费带部队攻击坦克夕的次数
function acNewYearsEveVoApi:getFreeAttackCount()
	local freeCount = 0
	local vo = self:getAcVo()
	if vo then
		freeCount = vo.freeAttackNum - vo.attackedCount
		if tonumber(freeCount) < 0 then
			freeCount = 0
		end
	end
	return freeCount
end

function acNewYearsEveVoApi:judgeAttackEnable()
	local isEnable = false
	local attackCost = 0
	local vo = self:getAcVo()
	if vo and vo.freeAttackNum then
		local freeCount = vo.freeAttackNum
		local attackedCount = vo.attackedCount
		local buyAttackNum = SizeOfTable(vo.buyCost)
		if attackedCount - freeCount < buyAttackNum then
			isEnable = true
		else
			isEnable = false
		end
		if isEnable == true then
			if attackedCount < freeCount then
				attackCost = 0
			elseif vo.buyCost then
				attackCost = vo.buyCost[attackedCount + 1 - freeCount]
			elseif vo.buyCost == nil then
				isEnable = false
			end
		end
	end
	return isEnable,attackCost
end

function acNewYearsEveVoApi:isGemsEnough(cost)
	local isEnough = false
	if playerVoApi then
		local curGems = playerVoApi:getGems()
		if curGems >= tonumber(cost) then
			isEnough = true
		end
	end
	return isEnough
end

--获取礼炮攻击的剩余次数和总次数
function acNewYearsEveVoApi:getSaluteAttackNum()
	local attackedCount = 0
	local totalNum = 0
	local vo = self:getAcVo()
	if vo then
		if vo.saluteLimit then
			local vip = playerVoApi:getVipLevel()
			local vipLimit = SizeOfTable(vo.saluteLimit) - 1
			if tonumber(vip) >= vipLimit then
				vip = vipLimit
			end

			totalNum = vo.saluteLimit[vip + 1]
			attackedCount = vo.saluteAttackedCount
			if attackedCount == nil then
				attackedCount = 0
			end
		end
	end

	return attackedCount,totalNum
end

function acNewYearsEveVoApi:isVipReachTop()
	local vo = self:getAcVo()
	if vo then
		local vip = playerVoApi:getVipLevel()
		local vipLimit = tonumber(playerVoApi:getMaxLvByKey("maxVip")) or (SizeOfTable(vo.saluteLimit) - 1)
		if tonumber(vip) >= vipLimit then
			return true
		end
	end
	return false
end

--获取除夕活动的爆竹攻击，爆竹连击，礼包攻击花费的金币数
function acNewYearsEveVoApi:getAttackCostNum()
	local crackerCost = 0
	local crackerMultiCost = 0
	local saluteCost = 0
	local vo = self:getAcVo()
	if vo then
		if vo.cost[1] then
			crackerCost = vo.cost[1]
		end
		if vo.cost[2] then
			crackerMultiCost = vo.cost[2]
		end
		if vo.cost[3] then
			saluteCost = vo.cost[3]
		end		
	end

	return crackerCost,crackerMultiCost,saluteCost
end

--获取玩家对夕当前最高的伤害值
function acNewYearsEveVoApi:getMyBestDamage()
	local bestDamage = 0
	local vo = self:getAcVo()
	if vo then
		bestDamage = vo.bestDamage
	end
	return bestDamage
end

function acNewYearsEveVoApi:getHpPercent()
	local percent = 100
	local hpIndex = 6
	local vo = self:getAcVo()
	if vo then
		if tonumber(vo.attckedHp) > tonumber(vo.maxHp) then
			curHp = 0
			vo.attckedHp = vo.maxHp
		else
			curHp = tonumber(vo.maxHp) - tonumber(vo.attckedHp)
		end
		maxHp = tonumber(vo.maxHp)
		local perHp = maxHp/6

		if  vo.attckedHp>=maxHp then
			percent = 0
		else
			percent = (perHp - vo.attckedHp%perHp)/perHp*100
		end

		hpIndex = 6 - math.floor(vo.attckedHp/perHp)

		-- print("attckedHp =========== ",vo.attckedHp)
		-- print("curHp ============ ",curHp)
		-- print("maxHp ============ ",maxHp)
		-- print("percent ============= ",percent)
	end
	return percent,hpIndex
end

function acNewYearsEveVoApi:hasAttacked()
	local vo = self:getAcVo()
	if vo then
		if vo.saluteAttackedCount == nil then
			return false
		elseif vo.bestDamage <= 0 then
			return false
		end
	end
	return true
end

function acNewYearsEveVoApi:getRemainReviveTime()
	local remainTime = 12*3600
	local vo = self:getAcVo()
	if vo then
		remainTime = vo.totalReviveTime - (base.serverTime - vo.lastKillTime) 
	end
	return remainTime
end

function acNewYearsEveVoApi:checkTankState()
	local state = self.tankState.ALIVE
	local remainTime = 0
	local vo = self:getAcVo()
	if vo then
		remainTime = vo.totalReviveTime - (base.serverTime - vo.lastKillTime)

		if remainTime < 0 then
			remainTime = 0
		end
		-- print("state ======= ",state)
		if vo.attckedHp < vo.maxHp then
			state = self.tankState.ALIVE
		else
			state = self.tankState.REVIVING
		end
	end
	-- print("state ======= ",state)
	-- print("remainTime ======= ",remainTime)
	return state,remainTime
end

function acNewYearsEveVoApi:setTankDamage(damage)
	local vo = self:getAcVo()
	if vo then
		vo.attckedHp = damage
	end
end

function acNewYearsEveVoApi:getTankHp()
	local curHp = 0
	local vo = self:getAcVo()
	if vo then
		curHp = vo.maxHp - vo.attckedHp
	end
	return curHp
end

function acNewYearsEveVoApi:setBossOldHp(hp)
	local vo = self:getAcVo()
	if vo then
		vo.oldHp = vo.oldHp - hp
	end
end


function acNewYearsEveVoApi:getBossOldHp()
	local vo = self:getAcVo()
	if vo then
		return vo.oldHp
	end
	return 0
end

function acNewYearsEveVoApi:getMaxHp()
	local vo = self:getAcVo()
	if vo then
		return vo.maxHp
	end
	return 0
end

function acNewYearsEveVoApi:getTankPaotouCfg()
	local vo = self:getAcVo()
	if vo then
		return vo.paotou
	end
end

function acNewYearsEveVoApi:getNoSubLifeBossPaotou(btdata,mm)--预先判断损失的炮口
  local vo = self:getAcVo()
  local subHp = 0
  for i=1,mm do
  		local curDate = btdata[i]
	    local dataTb=Split(curDate,"-")
	    subHp = subHp + tonumber(dataTb[1])
  end

  local newHp = vo.oldHp-subHp
  local maxHp = self:getMaxHp()
  local tankTb = {}
  if newHp <=0 then
    return tankTb
  end
  for i=1,6 do
    if newHp>maxHp/6*(i-1) then
      tankTb[vo.paotou[6-i+1]]=1
    end
  end

   return tankTb
end

function acNewYearsEveVoApi:getBossPaotou()
	local tankTb = {}
	local vo = self:getAcVo()
	if vo then
  		if vo.oldHp <=0 then
    		return tankTb
 		end
  		for i=1,6 do
    		if vo.oldHp>vo.maxHp/6*(i-1) then
      			tankTb[vo.paotou[6-i+1]]=1
    		end
  		end
	end
   	return tankTb
end

function acNewYearsEveVoApi:getDestoryPaotouByHP(bossHP,oldHP)
    local maxHp = self:getMaxHp()
    local oldTankHP = oldHP
    local bossHp = bossHP
    local paotouCfg = self:getTankPaotouCfg()
    
    local oldPaotou = {}
    if oldTankHP <=0 then
        oldPaotou = {}
    end
    for i=1,6 do
        if oldTankHP>maxHp/6*(i-1) then
            oldPaotou[paotouCfg[6-i+1]]=1
        end
    end

    local destoryPaotou = {}
    local tankTb = {}
    for i=1,6 do
        if bossHp>maxHp/6*(i-1) then
            tankTb[paotouCfg[6-i+1]]=1
        end
    end

    for k,v in pairs(oldPaotou) do
        if v and tankTb[k]==nil then
            table.insert(destoryPaotou,k)
        end
    end
    return destoryPaotou
end

function acNewYearsEveVoApi:getLastAttackTime()
	local time
	local vo = self:getAcVo()
	if vo then
		time = vo.lastAttackTime
	end
	return time
end

function acNewYearsEveVoApi:resetAttackNum()
	local vo = self:getAcVo()
	if vo then
		vo:resetAcData()
	end
end

function acNewYearsEveVoApi:getCustomRewards()
	local vo = self:getAcVo()
	if vo then
		return vo.customRewards.r
	end
	return nil
end

function acNewYearsEveVoApi:getSpecialRewards()
	local vo = self:getAcVo()
	if vo then
		return vo.specialRewards.r
	end
	return nil
end

--获取年兽的等级
function acNewYearsEveVoApi:getTankLv()
	local vo = self:getAcVo()
	if vo then
		return vo.evaLevel
	end
	return bossCfg.startLevel
end

function acNewYearsEveVoApi:getRankCount()
	local rankCount = 0
	local vo = self:getAcVo()
	if vo then
		rankCount = vo.rankCount
	end
	return rankCount
end

-- nosave：true不保存
function acNewYearsEveVoApi:getTroopsData(nosave)
	local tanks={{},{},{},{},{},{}}
	local hero={0,0,0,0,0,0}
	local aitroops={0,0,0,0,0,0}
	local emblemId=nil
	local planePos=nil
	local airship = nil
	local dataKey="acNewYearsEveTroops@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
    local localData=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
    local saveFlag=false
    if(localData~=nil and localData~="")then
        local troopsDataTab=G_Json.decode(localData)
        if troopsDataTab and type(troopsDataTab)=="table" and troopsDataTab.tanks then
        	tanks=troopsDataTab.tanks
        	local bType = 30
        	local oldTmpEquip = emblemVoApi:getTmpEquip(bType)
    --     	local maxTroopsNum=playerVoApi:getTotalTroops(30)
    --     	for k,v in pairs(tanks) do
    --     		local tankId,num=v[1],v[2]
    --     		print("k,tankId,num,maxTroopsNum",k,tankId,num,maxTroopsNum)
				-- if num and num>maxTroopsNum then
    -- 				tanks[k][2]=maxTroopsNum
    -- 				saveFlag=true
    -- 			end
    --     	end
        	if troopsDataTab.hero then
        		hero=troopsDataTab.hero
        	end
        	if troopsDataTab.aitroops then
        		aitroops=troopsDataTab.aitroops
        	end
        	print("troopsDataTab.emblemId",troopsDataTab.emblemId)
        	if troopsDataTab.emblemId then
        		emblemId=troopsDataTab.emblemId
        		emblemVoApi:setTmpEquip(emblemId,bType) --算带兵量要用tmpEquip
        	end
        	if troopsDataTab.planePos then
        		planePos=troopsDataTab.planePos
        	end
        	if troopsDataTab.airship then
        		airship = troopsDataTab.airship
        	end
        	local maxTroopsNum=playerVoApi:getTotalTroops(bType)
        	for k,v in pairs(tanks) do
        		local tankId,num=v[1],v[2]
        		if num and num>maxTroopsNum then
    				tanks[k][2]=maxTroopsNum
    				saveFlag=true
    			end
        	end
        	if nosave then --不保存需要还原tmpEquip
        		emblemVoApi:setTmpEquip(oldTmpEquip,bType)
        	end
        end
    end
    if saveFlag==true and not nosave then
	    local troopsData={tanks=tanks,hero=hero,emblemId=emblemId,planePos=planePos,aitroops=aitroops,airship=airship}
    	acNewYearsEveVoApi:setTroopsData(troopsData)
    end
    return tanks,hero,emblemId,planePos,aitroops,airship
end
function acNewYearsEveVoApi:setTroopsData(troopsData)
	if troopsData then
		local localData=G_Json.encode(troopsData)
		local dataKey="acNewYearsEveTroops@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
		CCUserDefault:sharedUserDefault():setStringForKey(dataKey,localData)
		CCUserDefault:sharedUserDefault():flush()
	end
end
function acNewYearsEveVoApi:setNewYearBossFleet(tanks,hero,troopsType,emblemId,planePos,aitroops,airship)
	if tanks then
        for k,v in pairs(tanks) do
            if v and v[1] and v[2] and tonumber(v[2]) then
                local tid=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
                tankVoApi:setTanksByType(troopsType,k,tid,tonumber(v[2]))
            else
                tankVoApi:deleteTanksTbByType(troopsType,k)
            end
        end
    end
    if hero then
        heroVoApi:setNewYearBossHeroList(hero)
    end
    if aitroops then
    	AITroopsFleetVoApi:setNewYearBossAITroopsList(aitroops)
    end
    if emblemId then
    	emblemVoApi:setBattleEquip(troopsType,emblemId)
	end
	if planePos then
    	planeVoApi:setBattleEquip(troopsType,planePos)
	end
	if airship then
		airShipVoApi:setBattleEquip(troopsType,airship)
	end
end

function acNewYearsEveVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acNewYearsEveVoApi:pushMessage(params)
	--print("......params.damage",params.damage)
	self:setTankDamage(params.damage)
	eventDispatcher:dispatchEvent("newyeareva.damageChanged",nil)
	print("newyeareva.damageChanged")
end

function acNewYearsEveVoApi:checkNoTroops()
  local isEableAttack=true
  local num=0;
  local tanks = self:getTroopsData(true)
  for k,v in pairs(tanks) do
      if SizeOfTable(v)==0 then
          num=num+1;
      end
  end
  if num==6 or SizeOfTable(tanks)==0 then
      isEableAttack=false
  end
  return isEableAttack
end

function acNewYearsEveVoApi:composeRewards(killTypeTb)
	local cPaotouRewards = {}--普通炮头奖励
	local sPaotuRewards = {}--特殊炮头奖励（击杀奖励）
	local cPaotouNum = 0
	local sPaotouNum = 0
	for k,v in pairs(killTypeTb) do
		if v == self.killType.CUSTOM then
			cPaotouNum = cPaotouNum + 1
		elseif v == self.killType.SPECIAL then
			sPaotouNum = sPaotouNum + 1
		end
	end
	if cPaotouNum > 0 then
		cPaotouRewards = self:getCustomRewards()
		cPaotouRewards = FormatItem(cPaotouRewards,nil,true)
		for k,v in pairs(cPaotouRewards) do
			if v.num then
				v.num = v.num*cPaotouNum
			end
		end
	end
	if sPaotouNum > 0 then
		sPaotuRewards = self:getSpecialRewards()
		sPaotuRewards = FormatItem(sPaotuRewards,nil,true)
		for k,v in pairs(sPaotuRewards) do
			if v.num then
				v.num = v.num*sPaotouNum
			end
		end
	end
	return cPaotouRewards,sPaotuRewards
end

function acNewYearsEveVoApi:activeNewyeareva(action,method,callback)
	if action=="ranklist" then
		local function listCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.ranklist then
	            	local rank=sData.data.ranklist
	            	self:setRankList(method,rank)
	                if callback then
	                	callback()
	                end
	            end
	        end
	    end
		socketHelper:activeNewyeareva(action,method,nil,listCallback)
	elseif action=="rankreward" then
		local canReward,status,rank=self:canRankReward(method)
		if canReward==true and rank and rank>0 then
			local function rewardCallback(fn,data)
				local ret,sData=base:checkServerData(data)
		        if ret==true then
		            if sData and sData.data and sData.data.newyeareva then
		            	self:updateData(sData.data.newyeareva)
		            end
		            if sData and sData.data and sData.data.reward then
		            	local reward=sData.data.reward
		            	local award=FormatItem(sData.data.reward) or {}
						for k,v in pairs(award) do
							G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
						end
						G_showRewardTip(award)
		            end
		            if callback then
	                	callback()
	                end
		        end
		    end
			socketHelper:activeNewyeareva(action,method,rank,rewardCallback)
		end
	end
end

function acNewYearsEveVoApi:getRankList(type)
	if type and self.rankList and self.rankList[type] then
		return self.rankList[type]
	else
		return {}
	end
end
function acNewYearsEveVoApi:setRankList(type,rank)
	if type and rank then
		if self.rankList==nil then
			self.rankList={}
		end
		self.rankList[type]=rank
		-- local function sortFunc(a,b)
		-- 	if a and b and a[3] and b[3] then
		-- 		return a[3]>b[3]
		-- 	end
		-- end
		-- table.sort(self.rankList[type],sortFunc)
	end
end

function acNewYearsEveVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

-- 是否是领奖时间
function acNewYearsEveVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end


function acNewYearsEveVoApi:canRankReward(type)
	if self and self:acIsStop()==true then
		local rankList=self:getRankList(type)
		if rankList and SizeOfTable(rankList)>0 then
			for k,v in pairs(rankList) do
				if v and v[1] and tonumber(v[1])==playerVoApi:getUid() then
					local vo = self:getAcVo()
					if vo and vo.hasRewardTb then
						for m,n in pairs(vo.hasRewardTb) do
							if n and n==type then
								return false,2
							end
						end
					end
					return true,0,k
				end
			end
		end
	end
	return false,1
end

function acNewYearsEveVoApi:isCanJoinActivity()
	local curLevel = playerVoApi:getPlayerLevel()
	if tonumber(curLevel) >= 30 then
		return true,30
	end
	return false,30
end

--获取击败夕后的全服奖励
function acNewYearsEveVoApi:getAllServerRewards()
	local killrewards = {}
	local vo = self:getAcVo()
	if vo then
		killrewards = vo.killreward
	end
	return killrewards
end

--是否处于领奖时间
function acNewYearsEveVoApi:isRewardTime()
	local vo = self:getAcVo()
	if vo then
		if base.serverTime > vo.acEt-86400 and base.serverTime < vo.acEt then
			return true
		end
	end
	return false
end

function acNewYearsEveVoApi:getTimeStr()
	local str = ""
	local vo=self:getAcVo()
	if vo then
		-- local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt-86400)
		-- str=getlocal("activity_timeLabel")..":"..timeStr
		local activeTime = vo.acEt - 86400 - base.serverTime > 0 and G_formatActiveDate(vo.acEt - 86400 - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		return getlocal("activityCountdown")..":"..activeTime
	end

	return str
end

function acNewYearsEveVoApi:getRewardTimeStr()
	local str = ""
	local vo = self:getAcVo()
	if vo then
		-- local rewardTimeStr = activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
		-- str = getlocal("recRewardTime")..":"..rewardTimeStr
		local activeTime = G_formatActiveDate(vo.acEt - base.serverTime)
		if self:isRewardTime()==false then
			activeTime=getlocal("notYetStr")
		end
		return getlocal("onlinePackage_next_title")..activeTime
	end
	return str
end

function acNewYearsEveVoApi:sendDamageNote(damage)
	local _key="activity_newyearseve_note1"
	if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
		_key="activity_newyearseve_note1_1"
	end
	message={key=_key,param={playerVoApi:getPlayerName(),damage}}
    chatVoApi:sendSystemMessage(message)
end

-- function acNewYearsEveVoApi:sendReviveNote()
-- 	message={key="activity_newyearseve_note2",param={}}
--     chatVoApi:sendSystemMessage(message)
-- end

function acNewYearsEveVoApi:composeRewardPool()
	local crackerRewards,saluteRewards,paotouRewards,killRewards = self:getRewardPool()
	local allRewardContent = {}
  	if SizeOfTable(crackerRewards) > 0 then
  		local _key="activity_newyearseve_prompt13"
  		if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
  			_key="activity_newyearseve_prompt13_1"
  		end
    	table.insert(allRewardContent,getlocal(_key))
	    for k,v in pairs(crackerRewards) do
          table.insert(allRewardContent,v)
        end
    end
  	if SizeOfTable(saluteRewards) > 0 then
  		local _key="activity_newyearseve_prompt14"
  		if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
  			_key="activity_newyearseve_prompt14_1"
  		end
    	table.insert(allRewardContent,getlocal(_key))
	    for k,v in pairs(saluteRewards) do
          table.insert(allRewardContent,v)
        end
    end
  	if SizeOfTable(paotouRewards) > 0 then
    	table.insert(allRewardContent,getlocal("activity_newyearseve_prompt15"))
	    for k,v in pairs(paotouRewards) do
          table.insert(allRewardContent,v)
        end
    end
  	if SizeOfTable(killRewards) > 0 then
  		local _key="activity_newyearseve_prompt16"
  		if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
  			_key="activity_newyearseve_prompt16_1"
  		end
    	table.insert(allRewardContent,getlocal(_key))
	    for k,v in pairs(killRewards) do
          table.insert(allRewardContent,v)
        end
    end

    return allRewardContent
end

function acNewYearsEveVoApi:getRewardPool()
	local pool1 = {}
	local pool2 = {}
	local pool3 = {}
	local pool4 = {}
	local vo = self:getAcVo()
	if vo then
		if vo.rewardPool.pool1 then
			for k,v in pairs(vo.rewardPool.pool1) do
				local reward = FormatItem(v,nil,true)
				for k,item in pairs(reward) do
					table.insert(pool1,item)
				end
			end
		end
		if vo.rewardPool.pool2 then
			for k,v in pairs(vo.rewardPool.pool2) do
				local reward = FormatItem(v,nil,true)
				for k,item in pairs(reward) do
					table.insert(pool2,item)
				end
			end
		end
		pool3 = self:getCustomRewards()
		pool3 = FormatItem(pool3,nil,true)

		pool4 = self:getSpecialRewards()
		pool4 = FormatItem(pool4,nil,true)
	end
	return pool1,pool2,pool3,pool4
end

function acNewYearsEveVoApi:getBattleRewards(damage,baseRewards,killTypeTb)
    local baseRewardList = {}  
    local cpaotouRewards = {}
    local spaotouRewards = {}
    if baseRewards then
    	baseRewardList = FormatItem(baseRewards,nil,true)
    	-- G_dayin(baseRewardList)
    end
    if killTypeTb then
        cpaotouRewards,spaotouRewards = acNewYearsEveVoApi:composeRewards(killTypeTb)
    end
    local rewardsViewContent = {}
    local rewardList = {}
    if SizeOfTable(baseRewardList) > 0 then
    	local _key="activity_newyearseve_prompt7"
    	if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
    		_key="activity_newyearseve_prompt7_1"
    	end
	    table.insert(rewardsViewContent,getlocal(_key,{FormatNumber(damage)}))
    	for k,v in pairs(baseRewardList) do
      		table.insert(rewardsViewContent,v)
      		table.insert(rewardList,v)
    	end
	end

    if SizeOfTable(cpaotouRewards) > 0 then
        table.insert(rewardsViewContent,getlocal("activity_newyearseve_prompt10"))
        for k,v in pairs(cpaotouRewards) do
          table.insert(rewardsViewContent,v)
          table.insert(rewardList,v)
        end
    end

    if SizeOfTable(spaotouRewards) > 0 then
    	local _key="activity_newyearseve_prompt11"
    	if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
    		_key="activity_newyearseve_prompt11_1"
    	end
        table.insert(rewardsViewContent,getlocal(_key))
        for k,v in pairs(spaotouRewards) do
          table.insert(rewardsViewContent,v)
          table.insert(rewardList,v)
        end
    end

    return rewardsViewContent,rewardList
end

function acNewYearsEveVoApi:tick()
	if self:acIsStop() == false then
		if base.serverTime-self.lastSyncTime>=self.dataOverTime then
	        local function infoCallback(fn,data)
	            local ret,sData=base:checkServerData(data)
	            if ret==true then
	                if sData and sData.data then
	                    acNewYearsEveVoApi:updateData(sData.data)
	                    self.lastSyncTime = base.serverTime
	                end
	                if self:getHpPercent()<=0 then
	                	self.dataOverTime = self:getRemainReviveTime()
	                	self.spaceTime = self.dataOverTime
	                else
	                	self.dataOverTime = 60
	                end
	            end
	        end
	        socketHelper:getNewYearEvaInfo(infoCallback,false)
		end

		-- print("self.spaceTime ======= ",self.spaceTime)
		if self.spaceTime > 10 then
			self.spaceTime = self.spaceTime - 10
			if self.spaceTime <= 0 then
				--发送复活公告
				-- print("发送复活年兽公告")
				local _key="activity_newyearseve_note2"
				if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
					_key="activity_newyearseve_note2_1"
				end
	         	local params={subType=4,contentType=3,message={key=_key,param={}},ts=base.serverTime}
				chatVoApi:addChat(1,0,"",0,"",params,base.serverTime)
				self.spaceTime = 0
			end
		end
	end
end

function acNewYearsEveVoApi:getReviveHour()
	local time = 6
	local vo = self:getAcVo()
	if vo then
		time = math.floor(vo.totalReviveTime/3600)
	end

	return time
end

function acNewYearsEveVoApi:isSameToGunNum(btdata,curIdx,beAttkPos)
	local GunNums = SizeOfTable(self:getBossPaotou())
	local addHurt = 0
	local isDie = 1
	local maxHp = self:getMaxHp()
  	local bossHp = self:getBossOldHp()
  	local tankTb = {}
  	local isSame = true
  	local nextAttPos = 0
  	local curGunNum = 0
  	local paotouCfg = self:getTankPaotouCfg()
  	for i=1,curIdx do
  		if btdata==nil or  btdata[i]==nil then
  			return isSame,0
  		end
		local willHurtTb = Split(btdata[i],"-")
		addHurt =addHurt+willHurtTb[1]
		if willHurtTb[2] ==0 then
			isDie =willHurtTb[2]
		end
	end
  	for i=1,6 do
    	if bossHp-addHurt>maxHp/6*(i-1) then
      	tankTb[paotouCfg[6-i+1]]=1
    	end
  	end
  	for k,v in pairs(paotouCfg) do
  		if v ==beAttkPos then
  			curGunNum =k
  		end
  	end
  	if SizeOfTable(tankTb) ~=GunNums and tankTb[paotouCfg[curGunNum]] ==nil then
  		isSame =false
  		for i=1,6 do
  			if beAttkPos ==paotouCfg[i]  then
  				if i+1>6 then
  					nextAttPos =paotouCfg[i-1]
  				else
  					nextAttPos =paotouCfg[i+1]
  				end
  			end
  		end
  	end
	return isSame ,isDie,nextAttPos
end

function acNewYearsEveVoApi:getTitleWithTypeNum(typeNum)
	local titleName = ""
	if typeNum == 0 then
		titleName = getlocal("normalAttack")..getlocal("EarnRewardStr")
	elseif typeNum == 1 or typeNum == 2 or typeNum == 3 then
		if self:getVersion() == 2 then
			titleName = getlocal("activity_newyearseve_btnname"..typeNum.."_1")..getlocal("EarnRewardStr")
		else
			titleName = getlocal("activity_newyearseve_btnname"..typeNum)..getlocal("EarnRewardStr")
		end
		-- print("titleName====>>>>",titleName)
	elseif typeNum == 4 then
		titleName = getlocal("destroyTheGun")..getlocal("EarnRewardStr")
	end

	return titleName
end

-- 获取日志
function acNewYearsEveVoApi:getLog(showlog)
		local function callback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data and sData.data.log then
					self.log = {}
					for k,v in pairs(sData.data.log) do
						
						local rewardlist = {}
						local typeNum=v[1]
						local rewards={v[2]}
						local time=v[3] or base.serverTime
						local hxReward = self:getHexieReward()
						if hxReward then
							table.insert(rewardlist,hxReward)
						end
						for k,v in pairs(rewards) do
    						local reward = FormatItem(v,nil,true)
							table.insert(rewardlist,reward)
						end

                    	local title = {self:getTitleWithTypeNum(typeNum)}
                    	local content={rewardlist}
                    	local log={title=title,content=content,ts=time}

						table.insert(self.log,log)

					end
					showlog(self.log)
				end
			end
		end
		socketHelper:acNewYearsEveGetLog(callback)
end

function acNewYearsEveVoApi:getHexieReward()
	local acVo=self:getAcVo()
	if acVo and acVo.hxcfg then
		local hxcfg=acVo.hxcfg
		if hxcfg then
			return FormatItem(hxcfg.reward)[1]
		end
	end
	return nil
end