require "luascript/script/game/gamemodel/daily/dailyVo"

dailyVoApi={
	allDailyVo=nil,
	coinGems=15,
	unlockLevel=15,
}

function dailyVoApi:showDailyDialog(layerNum)
	if(G_getBHVersion()==2)then
		require "luascript/script/game/scene/gamedialog/dailyTwoDialog"
		local dd = dailyTwoDialog:new()
		local dailyTwo = dd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("dailyUseIt"),true,layerNum);
		sceneGame:addChild(dailyTwo,layerNum);
	else
		require "luascript/script/game/scene/gamedialog/dailyDialog"
		local dd = dailyDialog:new()
		local titleStr,tbArr
		if(base.hexieMode==1)then
			titleStr=getlocal("dailyUseIt")
			tbArr={getlocal("exchangePrimary"),getlocal("exchangeSenior")}
		else
			titleStr=getlocal("daily_scene_title")
			tbArr={getlocal("lotteryCommon"),getlocal("lotterySenior")}
		end
		local vd = dd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,titleStr,true,layerNum);
		sceneGame:addChild(vd,layerNum);
	end
end

function dailyVoApi:clearDaily()
	if self.allDailyVo then
		for k,v in pairs(self.allDailyVo) do
			self.allDailyVo[k]=nil
		end
	end
	self.allDailyVo={}
end

function dailyVoApi:getRewardLevel( ... )
	local level = playerVoApi:getPlayerLevel()
	local levelCfg = playerCfg.levelGroup
	for k,v in pairs(levelCfg) do
		if level < v then
			return k-1,#levelCfg
		end
	end
	return #levelCfg,#levelCfg
end

function dailyVoApi:getGemValue(seq)
	local gemValue
	local level = self:getRewardLevel()
	if playerCfg and playerCfg["reward"..seq.."Value"] and playerCfg["reward"..seq.."Value"][level] then
		gemValue = playerCfg["reward"..seq.."Value"][level]
	end
	return gemValue
end

function dailyVoApi:formatData(data)
	local rewardLevel = self:getRewardLevel()
	for k,v in pairs(playerCfg.dailygoods) do
		local lotteryData={}
		if data and data["d"..k] then
			lotteryData=data["d"..k]
		end	
		local num=0
		local freeNum=v.freeNum or 0
		local cost=v.consume or 0
		--local awardPool=v.awardPool or {}
		local award={}
		if v.reward and v.reward[rewardLevel] then
			award=FormatItem(v.reward[rewardLevel],false)
		end
		local time=0
		if lotteryData.ts then
			time=lotteryData.ts
		end
		if lotteryData.num then
			num=lotteryData.num
		end
		if v.perCoinGems then
			self.coinGems=v.perCoinGems
		end
        local vo = dailyVo:new()
        vo:initWithData(k,freeNum,num,award,cost,time)
        table.insert(self.allDailyVo,k,vo)
    end
end
function dailyVoApi:getAllDailyVo()
    if self.allDailyVo==nil then
        self.allDailyVo={}
    end
    return self.allDailyVo
end
function dailyVoApi:getCoinGems()
	return self.coinGems
end
function dailyVoApi:getUnlockLevel()
	return self.unlockLevel
end

function dailyVoApi:getDailyVo(id)
    local voTb=self:getAllDailyVo()
	for k,v in pairs(voTb) do
		if v and v.id and id and tostring(v.id)==tostring(id) then
			return v
		end
	end
	return {}
end

function dailyVoApi:getDailyNum()
    local tbb=self:getAllDailyVo()
	return SizeOfTable(tbb)
end
--[[
function dailyVoApi:getUpdateTime()
	local dailyTs=DailyUpdateTime()
	return dailyTs
end
function dailyVoApi:isReward(id)
	local rewardNum=0
	local vo=self:getDailyVo(id)
	--local udTime=self:getUpdateTime()
	if vo~=nil and SizeOfTable(vo)>0 then
		--if vo.time>0 and vo.time>udTime then
		if vo.time>0 and G_isToday(vo.time) then
			rewardNum=vo.num
		end
		if vo.maxNum>0 and rewardNum>=vo.maxNum then
			return true
		end
	end
	return false
end
function dailyVoApi:hasReward()
    local hasReward=true
    if self:isReward(1)==true and self:isReward(2)==true then
        hasReward=false
    end
    return hasReward
end
]]
function dailyVoApi:isFreeByType(index)
	local vo=self:getDailyVo(index)
	local time=vo.time
	if index==1 then
		if time and time>0 and G_isToday(time) and vo.num>=vo.freeNum then
			return false
		end
	elseif index==2 then
		if playerVoApi:getPlayerLevel()<self:getUnlockLevel() then
			do return false end
		end
		-- if time and time>0 then
            -- 高级抽奖每日免费1次
			local vipPrivilegeSwitch=base.vipPrivilegeSwitch or {}
			if vipPrivilegeSwitch.vfn==1 then
				local vipRelatedCfg=playerCfg.vipRelatedCfg or {}
				local freeSeniorLotteryNum=vipRelatedCfg.freeSeniorLotteryNum or {}
				if playerVoApi:getVipLevel()>=freeSeniorLotteryNum[1] then
					-- if vo.num==vo.freeNum or G_isToday(time)==false then
					if G_isToday(time)==false then
						return true,true
					end
				end
			end
		if time and time>0 then
			return false
		end
	end
	return true
end
function dailyVoApi:isFree()
	if self:isFreeByType(1) or self:isFreeByType(2) then
		return true
	end
	return false
end
--幸运币数量
function dailyVoApi:getLuckyCoins()
	local luckyCoinNum=bagVoApi:getItemNumId(47)
    return luckyCoinNum
end
--差多少幸运币可以抽奖
function dailyVoApi:coinLessNum(id)
	local vo=self:getDailyVo(id)
	local coinsCost=vo.cost
	local luckyCoins=self:getLuckyCoins()
	if coinsCost>luckyCoins then
		return coinsCost-luckyCoins
	end
	return -1
end
--每种抽奖的成本   即全是用宝石购买时，花费的宝石数
function dailyVoApi:getGemsCost(id)
	local vo=self:getDailyVo(id)
	local gemsCost=self:getCoinGems()*vo.cost
	return gemsCost
end
--幸运币不足，购买幸运币需要花费宝石数
function dailyVoApi:buyCoinNeedGems(id)
	local vo=self:getDailyVo(id)
	local diffNum=self:coinLessNum(id)
	if diffNum>0 then
		return diffNum*self:getCoinGems()
	end
	return -1
end
--玩家宝石不足，还差多少宝石可以抽奖
function dailyVoApi:gemLessNum(id)
	--local gemsCost=self:getGemsCost(id)
	local gemsCost=self:buyCoinNeedGems(id)
	if gemsCost>playerVoApi:getGems() then
		return (gemsCost-playerVoApi:getGems())
	end
	return -1
end

function dailyVoApi:is_Today(idx)
	if idx ==nil then
		idx =2
	end
	local  vo = self:getDailyVo(idx)
	if vo and vo.time then
		return G_isToday(vo.time)
	end
	return false
end
function dailyVoApi:updateRewardNum()
	local id=1
	local vo=self:getDailyVo(id)
	local time=vo.time
	if time and time>0 and G_isToday(time)==false then
		if self.allDailyVo[id].num~=0 then
			self.allDailyVo[id].num=0
		end
		return true
	end
	return false
end




