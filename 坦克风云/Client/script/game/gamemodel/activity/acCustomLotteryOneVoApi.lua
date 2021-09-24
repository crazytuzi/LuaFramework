acCustomLotteryOneVoApi = {}

function acCustomLotteryOneVoApi:getAcVo()
	return activityVoApi:getActivityVo("customLottery1")
end

function acCustomLotteryOneVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

-- 获取配置的非免费抽奖每次需要的金币
function acCustomLotteryOneVoApi:getCfgCost()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.cost
	end
	return 99999
end


function acCustomLotteryOneVoApi:canReward()
	return false
end

-- 是否可以免费抽取
function acCustomLotteryOneVoApi:checkIfFreeGame()
	return false
end

-- 抽取奖励完成之后刷新数据
function acCustomLotteryOneVoApi:afterGameOver()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true -- 强制更新数据
	end
end

-- 从前一天过度到后一天时重新获取数据
function acCustomLotteryOneVoApi:refresh()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true
	end
	
end

function acCustomLotteryOneVoApi:getChatGoodCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.good then
		return acVo.good
	end
	return {}
end
function acCustomLotteryOneVoApi:getIsChatMessegeByID(types,key)
	local goodCfg = self:getChatGoodCfg()
	local isChat = false
	if goodCfg and type(goodCfg)=="table" and SizeOfTable(goodCfg)>0 then
		for k,v in pairs(goodCfg) do
			if v and type(v)=="table" then
				for m,n in pairs(v) do
					if m and n and m==types and key == n then
						isChat = true
						return isChat
					end
				end
			end
		end
	end
	return false
end


function acCustomLotteryOneVoApi:getRewardListCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.list then
		return acVo.list
	end
	return {}
end
function acCustomLotteryOneVoApi:getRewardItemByID(id)
	local list = self:getRewardListCfg()
	local pType,pid,pNum
	--{{p="p427",num=2},{p="p428"},{p="p429"},{p="p430"}}
	if list and type(list)=="table" and SizeOfTable(list)>0 then
		for k,v in pairs(list) do
			if k == id and v and type(v)=="table" then
				for m,n in pairs(v) do
					if m and n then
						if m=="num" then
							pNum=n
						else
							pType,pid= m,n
						end
					end
				end
			end
		end
		return pType,pid,pNum
	end
end
function acCustomLotteryOneVoApi:getLotteryNumCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.time ~=nil then
		return tonumber(acVo.time)
	end
	return tonumber(-1)
end

function acCustomLotteryOneVoApi:getHadLotteryNum()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.lotteryNum ~=nil then
		return tonumber(acVo.lotteryNum)
	end
	return 0
end

function acCustomLotteryOneVoApi:updateHadLotteryNum(num)
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.lotteryNum ~=nil then
		acVo.lotteryNum = acVo.lotteryNum+num
	end
end
function acCustomLotteryOneVoApi:getLeftLotteryNum()
	-- body
	local numCfg = self:getLotteryNumCfg()
	local hadNum = self:getHadLotteryNum()
	if numCfg and numCfg == tonumber(-1) then
		return tonumber(-1)
	else
		if numCfg>= hadNum then
			return tonumber(numCfg-hadNum)
		else
			return 0
		end
	end

end


function acCustomLotteryOneVoApi:getHadRewardList()
	local acVo = self:getAcVo()
	if acVo ~= nil and acVo.rewardList ~=nil then
		return acVo.rewardList
	end
	return nil
end

function acCustomLotteryOneVoApi:getHadRewardItemByID(id)
	local list = self:getHadRewardList()
	local pType,pid,pNum
	--{{p="p427",num=2},{p="p428"},{p="p429"},{p="p430"}}
	if list and type(list)=="table" and SizeOfTable(list)>0 then
		for k,v in pairs(list) do
			if k == id and v then
				pType,pid,pNum = v[1],v[2],v[3]
			end
		end
		return pType,pid,pNum
	end
end
