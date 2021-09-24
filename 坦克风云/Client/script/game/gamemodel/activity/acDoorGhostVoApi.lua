acDoorGhostVoApi = {}

function acDoorGhostVoApi:getAcVo()
	return activityVoApi:getActivityVo("doorGhost")
end
function acDoorGhostVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acDoorGhostVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acDoorGhostVoApi:getOpenDoorCostCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.refreshCost ~= nil then
		return acVo.refreshCost
	end
	return {}
end

function acDoorGhostVoApi:getOpenDoorCost()
	local costCfg = self:getOpenDoorCostCfg()
	local refreshCostNum = self:getRefreshNum()
	if costCfg ~= nil then
		if SizeOfTable(costCfg) > refreshCostNum then
			return costCfg[refreshCostNum+1]
		else
			return costCfg[SizeOfTable(costCfg)]
		end

	end
	return 0
end

function acDoorGhostVoApi:getRefreshNum()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.refreshCostNum ~= nil then
		return tonumber(acVo.refreshCostNum)
	end
	return 0
end

function acDoorGhostVoApi:getFreeRefresh()
	local acVo = self:getAcVo()
	local viplV = playerVoApi:getVipLevel()
	local free = false
	if acVo ~= nil and acVo.vipFreeLv ~= nil and acVo.free then
		if viplV>=acVo.vipFreeLv and acVo.free<=0 then
			free = true
			return free
		end
	end
	return free
end


function acDoorGhostVoApi:getAcGhostRewardCfg()
	local acVo = self:getAcVo()

	if acVo ~= nil and acVo.ghostReward ~= nil then
		return acVo.ghostReward
	end
	return {}

end
function acDoorGhostVoApi:getTotalGhost()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		if acVo.v then
			if acVo.maxghost and acVo.v >= acVo.maxghost then
				return tonumber(acVo.maxghost)
			end
			return tonumber(acVo.v)
		end
	end
	return 0
end
function acDoorGhostVoApi:getRewardById(id)
	local acCfg = self:getAcGhostRewardCfg()
	if acCfg ~= nil then
		return acCfg[id]
	end
	return nil
end
function acDoorGhostVoApi:afterGetReward(id)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.c = acVo.c + 1
	end
	activityVoApi:updateShowState(acVo)
	acVo.stateChanged = true
end

-- 抓到鬼前台更新
function acDoorGhostVoApi:addTotalGhost(ghost)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.v = acVo.v + ghost
		if acVo.maxghost and acVo.v >= acVo.maxghost then
			acVo.v= acVo.maxghost
		end
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

function acDoorGhostVoApi:checkIfHadRewardById(id)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.c ~= nil and (acVo.c >= id) then
		return true
	end
	return false
end

function acDoorGhostVoApi:checkIfCanRewardById(id)
	local needGhost = self:getNeedGhostById(id)
	local ghost = self:getTotalGhost()
	if needGhost ~= nil and (ghost >= needGhost) then
		return true
	end
	return false
end

function acDoorGhostVoApi:getHadRewardId()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.c ~= nil then
		return tonumber(acVo.c)
	end
	return 0
end

function acDoorGhostVoApi:getNeedGhostById(id)
	local rewardCfg = self:getRewardById(id)
	if rewardCfg ~= nil and rewardCfg["nm"] then
		return tonumber(rewardCfg["nm"])
	end
	return 0
end


-- 得到当前可以领取的奖励
function acDoorGhostVoApi:getCurrentCanGetReward()
	local acCfg = self:getAcGhostRewardCfg()
	if acCfg ~= nil then
		local rewardLen = SizeOfTable(acCfg)
		if rewardLen ~= nil and rewardLen > 0 then
			for i=1,rewardLen do
				if self:checkIfCanRewardById(i) == true and self:checkIfHadRewardById(i) == false then
					return self:getRewardById(i), i
				end
			end
		end
	end	
	return nil
end


function acDoorGhostVoApi:getDoorReward()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.doorReward ~= nil then
		return acVo.doorReward
	end
	return {}
end

function acDoorGhostVoApi:getDoorRewardByID(id)
	local doorRewardCfg = self:getDoorReward()
	if doorRewardCfg ~=nil then
		for k,v in pairs(doorRewardCfg) do
			if k == id and v then
				return v 
			end
		end
	end
end

function acDoorGhostVoApi:getHadOpenDoor()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.openDoor ~= nil then
		return acVo.openDoor
	end
	return {}
end
function acDoorGhostVoApi:getIsOpenByID(id)
	local openDoorTb = self:getHadOpenDoor()
	if openDoorTb and SizeOfTable(openDoorTb)>0 then
		for k,v in pairs(openDoorTb) do
			if v and v == id then
				return true
			end

		end
	end
	return false
end

function acDoorGhostVoApi:getHadOpenDoorNum()
	local hadOpenTb = self:getHadOpenDoor()
	if hadOpenTb then
		return SizeOfTable(hadOpenTb)
	end
	return 0
end

function acDoorGhostVoApi:getMaxOpenDoorNum()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.MaxOpenDoor ~= nil then
		return acVo.MaxOpenDoor
	end
	return 3
end
function acDoorGhostVoApi:updateHadOpenDoorNum(id)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		if  acVo.openDoor ==nil then
			acVo.openDoor ={}
		end
		local hadOpen = false
		for k,v in pairs(acVo.openDoor) do
			if v == id then
				hadOpen = true
			end
		end
		if hadOpen == false then
			table.insert(acVo.openDoor,id)
		end
	end
end

function acDoorGhostVoApi:refreshData(data)
	local acVo = self:getAcVo()
	if acVo.openDoor ~=nil then
		acVo.openDoor={}
	end

end

--今日是否重置过
function acDoorGhostVoApi:isToday()
	local ecVo=self:getAcVo()
	if ecVo then
		local lastTs=ecVo.refreshTime or 0 --上一次重置时间
		return G_isToday(lastTs)
	end
	return true
end

function acDoorGhostVoApi:canReward()

	local acCfg = self:getAcGhostRewardCfg()
	if acCfg ~= nil then
		local rewardLen = SizeOfTable(acCfg)
		if rewardLen ~= nil and rewardLen > 0 then
			for i=1,rewardLen do
				if self:checkIfCanRewardById(i) == true and self:checkIfHadRewardById(i) == false then
					return true
				end
			end
		end
	end	
	return false
end