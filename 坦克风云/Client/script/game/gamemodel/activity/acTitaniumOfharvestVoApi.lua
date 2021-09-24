acTitaniumOfharvestVoApi={
	lFlag=1,
	tankFlag=0,
	rFlag1=0,
	rFlag2=0,
	isToday=true,
	taiNum=0,-- 游戏没退出，领取的钛矿
	enterGameFlag=true,
}

function acTitaniumOfharvestVoApi:getAcVo()
	return activityVoApi:getActivityVo("taibumperweek")
end

function acTitaniumOfharvestVoApi:canReward()
	local isfree=false
	local task = self:getTask()	
	if task then
		local missionFlag = self:getMissionFlag()
		for k,v in pairs(missionFlag) do
			if v==1 then
				return true
			end
		end
	end						--是否是第一次免费
	local res = self:getDayres()
	if res then
		if self:getChongzhiReward()>0 then
			return true
		end
	end
	
	return false
end

function acTitaniumOfharvestVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acTitaniumOfharvestVoApi:getDayres()
	local vo=self:getAcVo()
	return vo.dayres
end

function acTitaniumOfharvestVoApi:getTask()
	local vo=self:getAcVo()
	return vo.task
end

-- 异形科技普通改造打折
function acTitaniumOfharvestVoApi:getValue()
	local vo=self:getAcVo()
	return vo.value
end

-- 登陆标志位
function acTitaniumOfharvestVoApi:setlFlag(flag)
	self.lFlag = flag
end

function acTitaniumOfharvestVoApi:getlFlag()
	return self.lFlag
end

-- 生产tank标志位
function acTitaniumOfharvestVoApi:setTankFlag(flag)
	self.tankFlag = flag
end

-- 采集资源标志位
function acTitaniumOfharvestVoApi:setrFlag1(flag)
	self.rFlag1 = flag
end

function acTitaniumOfharvestVoApi:setrFlag2(flag)
	self.rFlag2 = flag
end

function acTitaniumOfharvestVoApi:getPd()
	local vo=self:getAcVo()
	return vo.pd or 0
end

function acTitaniumOfharvestVoApi:getPf()
	local vo=self:getAcVo()
	return vo.pf
end

function acTitaniumOfharvestVoApi:setTaiNum(taiNum)
	self.taiNum=taiNum
end

-- 进入板子时的时间
function acTitaniumOfharvestVoApi:getEnterGameFlag()
	return self.enterGameFlag
end

function acTitaniumOfharvestVoApi:setEnterGameFlag(time)
	self.enterGameFlag=time
end

-- 上一次充值的凌晨时间
function acTitaniumOfharvestVoApi:getPt()
	local vo=self:getAcVo()
	return vo.pt or 0
end

function acTitaniumOfharvestVoApi:getTitleName()
	local titleName = getlocal("activity_TitaniumOfharvest_title1")
	local vo=self:getAcVo()
	local startStr = G_getDataTimeStr(vo.st)
	local monthNum = tonumber(string.sub(startStr,1,2))
	local dayNum = tonumber(string.sub(startStr,4,5))
	if monthNum==4 and dayNum==30 then
		titleName = getlocal("activity_TitaniumOfharvest_title2")
	elseif monthNum==5 and dayNum>=1 and dayNum<=10 then
		titleName = getlocal("activity_TitaniumOfharvest_title2")
	end
	return titleName
end


function acTitaniumOfharvestVoApi:acIsActive()
	local vo=self:getAcVo()
	if vo and base.serverTime>vo.st and  base.serverTime<vo.et then
		return true
	end
	return false
end

-- 0前往  1领取  2已领取
function acTitaniumOfharvestVoApi:getMissionFlag(istoday)
	local vo=self:getAcVo()
	self.flag = {}
	local task = self:getTask()

	if istoday then
		vo.lFlag=nil
		vo.tankFlag=nil
		vo.rFlag1=nil
		vo.rFlag2=nil
		vo.RNum=0
		vo.tankNum=0

		self.lFlag=1
		self.tankFlag=0
		self.rFlag1=0
		self.rFlag2=0
	end
	
	if vo.lFlag then
		self.flag[1]=2
	else
		self.flag[1]=self.lFlag or 1
	end
	
	-- tank
	if vo.tankFlag then
		self.flag[2]=2
	elseif vo.tankNum and vo.tankNum>=task["t"][1][1] then
		self.flag[2]=1
	else
		self.flag[2]=0
	end

	if self.tankFlag==2 then
		self.flag[2]=2
	end

	-- 采集的资源是否够领取
	local Rnum = vo.RNum or 0
	if Rnum>=task["r"][2][1] then
		self.flag[3]=1
		self.flag[4]=1
	elseif Rnum>=task["r"][1][1] then
		self.flag[3]=1
		self.flag[4]=0
	else
		self.flag[3]=0
		self.flag[4]=0
	end

	-- 领取标志位已存在（资源）
	if vo.rFlag1 and vo.rFlag1=="p1" then
		self.flag[3]=2
	end
	if  vo.rFlag1 and vo.rFlag1=="p2" then
		self.flag[4]=2
	end

	if vo.rFlag2 and vo.rFlag2=="p1" then
		self.flag[3]=2
	end
	if  vo.rFlag2 and vo.rFlag2=="p2" then
		self.flag[4]=2
	end

	-- 领取之后自己设置的标志位
	if self.rFlag1==2 then
		self.flag[3]=2
	end
	if self.rFlag2==2 then
		self.flag[4]=2
	end

	return self.flag
end

-- 获得充值奖励钛矿的数量
function acTitaniumOfharvestVoApi:getChongzhiReward()
	local vo=self:getAcVo()
	local pfr=vo.pfr or {}
	local res = acTitaniumOfharvestVoApi:getDayres()
	local numAll = 0
	if vo.pf then
		for k,v in pairs(vo.pf) do
			
			local num=v
			if pfr[k] then
				num=v-pfr[k]
			end

			numAll = numAll+res[tonumber(RemoveFirstChar(k))]*num
		end
	else
		numAll = 0 
	end
	return numAll-self.taiNum
end

function acTitaniumOfharvestVoApi:clear()
	self.lFlag=1
	self.tankFlag=0
	self.rFlag1=0
	self.rFlag2=0
end

function acTitaniumOfharvestVoApi:clearAll()
	self.lFlag=1
	self.tankFlag=0
	self.rFlag1=0
	self.rFlag2=0
	self.isToday=true
	self.taiNum=0-- 游戏没退出，领取的钛矿
	self.enterGameFlag=true


end