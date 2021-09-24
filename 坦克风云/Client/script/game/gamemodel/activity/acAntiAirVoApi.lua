--打飞机活动的voapi
acAntiAirVoApi={}

function acAntiAirVoApi:getAcVo()
	return activityVoApi:getActivityVo("battleplane")
end

function acAntiAirVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acAntiAirVoApi:checkInit(callback)
	local vo=self:getAcVo()
	if(vo and vo.curShowList)then
		if(callback)then
			callback()
		end
	else
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				local vo=self:getAcVo()
				if(sData.data.battleplane)then
					vo:updateSpecialData(sData.data.battleplane)
				end
				if(callback)then
					callback()
				end
			end
		end
		socketHelper:activityAntiAir(1,nil,onRequestEnd)
	end
end

--获取奖池
function acAntiAirVoApi:getShowList()
	local vo=self:getAcVo()
	if(vo and vo.showList)then
		return vo.showList
	else
		return {}
	end
end

--奖池里面哪些要带光圈的
function acAntiAirVoApi:getFlickerTb()
	local vo=self:getAcVo()
	if(vo and vo.flickerTb)then
		return vo.flickerTb
	else
		return {}
	end
end

--获取本次已经抽到的奖励
function acAntiAirVoApi:getBeforeReward()
	local vo=self:getAcVo()
	if(vo and vo.getRewardList)then
		return vo.getRewardList
	else
		return {}
	end
end

--获取本轮的六个奖励
--return: 一个table，里面的每个元素表示奖励的品质，例如{1,1,2,3,1,2}
function acAntiAirVoApi:getCurReward()
	local vo=self:getAcVo()
	if(vo and vo.curShowList)then
		return vo.curShowList
	else
		return {}
	end
end

--剩下的飞机
function acAntiAirVoApi:getLeftPlane()
	local total=#(self:getCurReward())
	local get=SizeOfTable(self:getBeforeReward())
	--最多能打3个，所以要减3
	return math.max(total - get - 3,0)
end

--获取打飞机的价格
--param type: 1是打一次的价格，2是全打的价格
function acAntiAirVoApi:getCost(type)
	local vo=self:getAcVo()
	if(type==1)then
		return vo.cost1
	else
		return vo.cost2
	end
end

function acAntiAirVoApi:canReward()
	local vo=self:getAcVo()
	if(vo.freeUsed and vo.freeUsed==1)then
		if(vo.resetTs and G_getWeeTs(base.serverTime)<=G_getWeeTs(vo.resetTs))then
			return false
		else
			return true
		end
	else
		return true
	end
end

--抽奖
--param type: 1是用免费抽，2是单抽1次，3是全抽
function acAntiAirVoApi:draw(type,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local vo=self:getAcVo()
			if(vo.getRewardList==nil)then
				vo.getRewardList={}
			end
			if(type==1)then
				vo.freeUsed=1
				vo.resetTs=G_getWeeTs(base.serverTime)
			end
			local oldBeforeReward=self:getBeforeReward()
			if(data.battleplane)then
				vo:updateSpecialData(data.battleplane)
			end
			local rewardTb={}
			if(sData.data.report)then
				for k,v in pairs(sData.data.report) do
					local reward=v[1]
					local key=v[2]
					reward=FormatItem(reward)[1]
					if(oldBeforeReward[key]==nil)then
						rewardTb[key]=reward
					end
					vo.getRewardList[key]=reward
				end
			end
			for k,v in pairs(rewardTb) do
				local key
				for kk,vv in pairs(self:getShowList()) do
					if(vv.num==v.num and vv.id==v.id and vv.type==v.type and vv.eType==v.eType)then
						key=kk
						break
					end
				end
				G_addPlayerAward(v.type,v.key,v.id,v.num)
				if(key and self:getFlickerTb()[key]==1)then
					local message={key="activity_battleplane_notice",param={playerVoApi:getPlayerName(),v.name,v.num}}
					chatVoApi:sendSystemMessage(message)
				end
			end
			if(type==1)then
				activityVoApi:updateShowState(vo)
				vo.stateChanged=true
			else
				local cost
				if(type==2)then
					cost=self:getCost(1)
				else
					cost=self:getCost(2)
				end
				playerVoApi:setGems(playerVoApi:getGems() - cost)
			end
			if(callback)then
				callback(rewardTb)
			end
		end
	end
	socketHelper:activityAntiAir(2,type,onRequestEnd)
end

--重置
function acAntiAirVoApi:reset(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local vo=self:getAcVo()
			if(vo)then
				if(vo.curShowList)then
					vo.curShowList={}
				end
				if(vo.getRewardList)then
					vo.getRewardList={}
				end
			end
			if(sData.data.battleplane)then
				vo:updateSpecialData(sData.data.battleplane)
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:activityAntiAir(1,nil,onRequestEnd)
end