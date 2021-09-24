acStormRocketVoApi=
{
	partNum=9,
	rewardTank=nil,
	gemCost=nil,
	tuhaoCost=nil,
	buyGemCost=nil,
	buyPartNum=nil,
	vipMulti=nil,
}

function acStormRocketVoApi:getAcVo()
	return activityVoApi:getActivityVo("stormrocket")
end

function acStormRocketVoApi:getComposeTankID()
	return self.rewardTank
end

--获取单次抽奖的花费
function acStormRocketVoApi:getSingleCost()
	return self.gemCost
end

--获取十连抽的花费
function acStormRocketVoApi:getTuhaoCost()
	return self.tuhaoCost
end

--获取暴击倍数
function acStormRocketVoApi:getCriticalPercent()
	local vipLevel=playerVoApi:getVipLevel()
	if(vipLevel==nil or self.vipMulti==nil or self.vipMulti[vipLevel+1]==nil)then
		return 2
	else
		return tonumber(self.vipMulti[vipLevel+1])
	end
end

--获取所有部位的碎片数目
--return 一个table，每个元素是每个部位的碎片数 e.g.: {1,3,0,0,5,0,0,0,0}
function acStormRocketVoApi:getNumTb()
	local vo=self:getAcVo()
	if(vo)then
		return vo.partTb
	else
		local tb={}
		for i=1,self.partNum do
			tb[i]=0
		end
		return tb
	end
end

--抽奖
--param type: 抽奖方式，0为使用免费抽奖，1为单次抽奖，2为十连抽
function acStormRocketVoApi:play(type,callback)
	if(type==0 and self:hasFreeTime()==false)then
		do return end
	end
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if(type==1)then
				playerVoApi:setGems(playerVoApi:getGems()-self:getSingleCost())
			elseif(type==2)then
				playerVoApi:setGems(playerVoApi:getGems()-self:getTuhaoCost())
			end
			local vo=self:getAcVo()
			if(type==0)then
				vo.lastTime=base.serverTime
			end
			local result=sData.data.stormrocket
			if(result and result.active and result.active.t)then
				for i=1,self.partNum do
					if(result.active.t["part"..i])then
						vo.partTb[i]=tonumber(result.active.t["part"..i])
						else
						vo.partTb[i]=0
					end
				end
			end
			activityVoApi:updateShowState(vo)
			if(callback)then
				callback(result.iscrit,result.reward)
			end
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage9000"),30)
		end
	end
	local param={}
	if(type==0)then
		param["free"]=1
	elseif(type==1)then
		param["num"]=1
	elseif(type==2)then
		param["num"]=10
	else
		do return end
	end
	socketHelper:activeStormRocket(1,param,onRequestEnd)
end

--获取当前可以合成多少个坦克
function acStormRocketVoApi:getComposeNum()
	local vo=self:getAcVo()
	if(vo==nil)then
		return 0
	end
	local minNum=nil
	for i=1,self.partNum do
		if(vo.partTb[i]==nil)then
			minNum=0
			break
		else
			if(minNum==nil or vo.partTb[i]<minNum)then
				minNum=vo.partTb[i]
			end
		end
	end
	return minNum
end

--凑齐碎片了，合成坦克
function acStormRocketVoApi:compose(callback)
	local composeNum=self:getComposeNum()
	if(composeNum==0)then
		do return end
	end
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local reward={o={{}}}
			reward.o[1][self.rewardTank]=composeNum
			local formatReward=FormatItem(reward)
			G_showRewardTip(formatReward,true)
			local vo=self:getAcVo()
			for i=1,self.partNum do
				vo.partTb[i]=vo.partTb[i]-composeNum
			end
			if(callback)then
				callback()
			end
			activityVoApi:updateShowState(vo)
		end
	end
	socketHelper:activeStormRocket(2,{},onRequestEnd)
end

--购买碎片
--param part: 要购买的碎片部位
function acStormRocketVoApi:buyFragment(part,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			playerVoApi:setGems(playerVoApi:getGems()-self.buyGemCost)
			local result=sData.data.stormrocket
			if(result and result.active and result.active.t)then
				local vo=self:getAcVo()
				for i=1,self.partNum do
					if(result.active.t["part"..i])then
						vo.partTb[i]=tonumber(result.active.t["part"..i])
					else
						vo.partTb[i]=0
					end
				end
			end

			if(callback)then
				callback()
			end
		end
	end
	local param={part="part"..part}
	socketHelper:activeStormRocket(3,param,onRequestEnd)
end

--是否有免费次数
function acStormRocketVoApi:hasFreeTime()
	local vo=self:getAcVo()
	if(vo)then
		local zeroTime=G_getWeeTs(base.serverTime)
		if(vo.lastTime<zeroTime)then
			return true
		end
	end
	return false
end

function acStormRocketVoApi:canReward()
	local vo=self:getAcVo()
	if(vo)then
		local zeroTime=G_getWeeTs(base.serverTime)
		if(vo.lastTime<zeroTime)then
			return true
		end
		if(vo.partTb)then
			local allFlag=true
			for i=1,self.partNum do
				if(vo.partTb[i]==nil or vo.partTb[i]<=0)then
					allFlag=false
					break
				end
			end
			if(allFlag==true)then
				return true
			end
		end
	end
	return false
end
