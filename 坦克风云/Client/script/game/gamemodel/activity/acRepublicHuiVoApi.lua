acRepublicHuiVoApi = {
	isToday=true,
	lastListTime=0,
}

function acRepublicHuiVoApi:clearAll()
	self.flag={0,0,0}
	self.isToday=true
	self.lastListTime=0
end

function acRepublicHuiVoApi:getAcVo()
	return activityVoApi:getActivityVo("republicHui")
end

function acRepublicHuiVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acRepublicHuiVoApi:getRouletteCfg()
	local vo=self:getAcVo()
	if vo and vo.acCfg then
		return vo.acCfg
	end
	return {}
end
function acRepublicHuiVoApi:getTankRewardCfg( ... )
	local vo = self:getAcVo()
	if vo and vo.tankReward then
		return vo.tankReward
	end
	return {}
end

function acRepublicHuiVoApi:getTankIDAndNeedPartNum()
	local aid
	local tankID
	local needPartNum
	local tankNum
	if self:getTankRewardCfg() then
		for k,v in pairs(self:getTankRewardCfg()) do
			if type(v)=="table" then
				for m,n in pairs(v) do
					aid=m
					tankNum=n
				end
			else
				needPartNum=tonumber(v)
			end
		end
	end
	if aid then
		local arr = Split(aid,"a")
		tankID =arr[2]
	end
	return aid,tonumber(tankID),tonumber(needPartNum),tonumber(tankNum)
end
function acRepublicHuiVoApi:getHadPieceNum()
	local vo=self:getAcVo()
	if vo and vo.hasNum and type(vo.hasNum)=="table" then
		for k,v in pairs(vo.hasNum) do
			if v then
				return v
			end
		end
		
	end
	return 0 
end
function acRepublicHuiVoApi:canComposeTank()
	local hadNUm = self:getHadPieceNum()
	local aid,tankID,needNum,tankNum = acRepublicHuiVoApi:getTankIDAndNeedPartNum()
	if hadNUm and needNum and hadNUm>=needNum then
		return true
	end
	return false
end

--凑齐碎片了，合成坦克
function acRepublicHuiVoApi:compose(callback)
	if self:canComposeTank()==true then
		local aid,tankID,needNum,tankNum=acRepublicHuiVoApi:getTankIDAndNeedPartNum()
		local composeNum=math.floor(self:getHadPieceNum()/needNum)*tankNum
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				tankVoApi:addTank(tankID,composeNum)
				local tankName=getlocal(tankCfg[tankID].name)
				local messageKey = tankName.." x"..composeNum
				local message={key="chatSystemMessage6",param={playerVoApi:getPlayerName(),messageKey}}
    			chatVoApi:sendSystemMessage(message)
				local str = getlocal("active_lottery_reward_tank",{getlocal(tankCfg[tankID].name)," x"..composeNum})
 				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)

				self:updatePartNum(-(composeNum*(needNum/tankNum)))
				if(callback)then
					callback()
				end
				activityVoApi:updateShowState(vo)
			end
		end
		socketHelper:activeRepublicHuiCompose(onRequestEnd)
	end
	
end

function acRepublicHuiVoApi:updatePartNum(num,key)
	local vo=self:getAcVo()
	if vo  and type(vo.hasNum)=="table" then
		if SizeOfTable(vo.hasNum)==0 and key then
			vo.hasNum[key]=num
		else
			for k,v in pairs(vo.hasNum) do
				if v then
					vo.hasNum[k]=v+num
				end
			end
		end
		
	end
end

function acRepublicHuiVoApi:getDiceNum()
	return 6,6
end

function acRepublicHuiVoApi:getLotteryCommonCost()
	local vo=self:getAcVo()
	if vo and vo.cost then
		return vo.cost
	end
	return 0
end

function acRepublicHuiVoApi:getLotterySuperCost()
	local vo=self:getAcVo()
	if vo and vo.multiCost then
		return vo.multiCost
	end
	return 0
end
function acRepublicHuiVoApi:setflickerPosition(pos)
	local vo=self:getAcVo()
	if vo and vo.position then
		vo.position=pos
	end
	return 1
end

function acRepublicHuiVoApi:getflickerPosition( ... )
	local vo=self:getAcVo()
	if vo and vo.position then
		if vo.position==0 then
			vo.position=1
		end
		return vo.position
	end
	return 1
end



function acRepublicHuiVoApi:canReward()
local isfree=true							--是否是第一次免费
	if self:isRouletteToday()==true then
		isfree=false
	end
	return isfree
end

function acRepublicHuiVoApi:setLastListTime(time)
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = time
		activityVoApi:updateShowState(vo)
	end

end

function acRepublicHuiVoApi:isRouletteToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end





