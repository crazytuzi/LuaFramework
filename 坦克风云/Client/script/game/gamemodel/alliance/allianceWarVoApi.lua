allianceWarVoApi=
{
	cityList={},		--各个城市的数据
	todayArea=0,		--今天是哪个战区开战
	targetCity=nil,		--本军团报名的目标城市ID
	targetState=0,		--报名状态, 0为没有报名成功, 1就是报名成功第一名, 2就是报名成功第二名
	ownCity=nil,		--本军团占领的城市ID
	memList={},			--参战成员列表
	joinTime=0,			--报名参加军团战的时间
	selfAllianceWarVo=nil,  --战场数据
	selfAllianceWarUserVo=nil,--战场上用户的数据(自己)
	signUpTime=nil,		--报名时间的配置，从后台传回来
	startWarTime=nil,	--各个城市的开战时间配置，从后台传回来
    memFlag=-1,
    warid=0,            --本场战斗id
    isEnd=false,		--军团战是否结束
    isAutoSupplement=false,--自动选择最大战力
}
function allianceWarVoApi:getIsAutoSupplement()
	return self.isAutoSupplement
end

function allianceWarVoApi:setIsAutoSupplement(isAutoSupplement)
	self.isAutoSupplement=isAutoSupplement
end

function allianceWarVoApi:getIsEnd()
	return self.isEnd
end
function allianceWarVoApi:setIsEnd(isEnd)
	self.isEnd=isEnd
end
function allianceWarVoApi:getMemFlag()
	return self.memFlag
end
function allianceWarVoApi:setMemFlag(memFlag)
	self.memFlag=memFlag
end
function allianceWarVoApi:clearMemList()
	if self.memList then
		for k,v in pairs(self.memList) do
			v=nil
		end
		self.memList=nil
	end
	self.memList={}
end
function allianceWarVoApi:formatMemList(data)
	if data then
		if data.queue then
			for k,v in pairs(data.queue) do
				-- local idx=(tonumber(k) or tonumber(RemoveFirstChar(k)))
				local uid=tonumber(v) or 0
				if uid and uid>0 then
					local memVo=allianceMemberVoApi:getMemberByUid(uid)
					if memVo and SizeOfTable(memVo)>0 then
						local vo = allianceBattleMemVo:new()
				    	vo:initWithData(uid,memVo.name,memVo.level,memVo.role,memVo.fight,memVo.donate,memVo.useDonate,1,k)
				    	table.insert(self.memList,vo)
					end
					-- table.insert(self.memList,{uid=v,index=k,isBattle=1})
				end
			end
		end
		if data.members then
			for k,v in pairs(data.members) do
				local uid=tonumber(v) or 0
				if uid and uid>0 then
					local memVo=allianceMemberVoApi:getMemberByUid(uid)
					if memVo and SizeOfTable(memVo)>0 then
						local vo = allianceBattleMemVo:new()
				    	vo:initWithData(uid,memVo.name,tonumber(memVo.level),tonumber(memVo.role),tonumber(memVo.fight),tonumber(memVo.donate),tonumber(memVo.useDonate),0)
						table.insert(self.memList,vo)
					end
				end
				-- table.insert(self.memList,{uid=v,isBattle=0})
			end
		end

		local function sortAsc(a, b)
			if a and b then
				if a.isBattle and b.isBattle then
					if a.isBattle==b.isBattle then
						if tonumber(a.fight) and tonumber(b.fight) then
							return tonumber(a.fight)>tonumber(b.fight)
						end
					else
						return a.isBattle>b.isBattle
					end
				end
			end
		end
		table.sort(self.memList,sortAsc)

		-- for k,v in pairs(self.memList) do
		-- 	print(k,"k",v,v.isBattle,v.fight)
		-- end
	end
end
function allianceWarVoApi:getMemList()
	if self.memList and SizeOfTable(self.memList)>0 then
		return self.memList
	end
	return {}
end
function allianceWarVoApi:getBattleMemNum()
	local battleNum=0
	local readyNum=0
	if self.memList and SizeOfTable(self.memList)>0 then
		for k,v in pairs(self.memList) do
			if v and v.isBattle==1 then
				battleNum=battleNum+1
			elseif v and v.isBattle==0 then
				readyNum=readyNum+1
			end
		end
	end
	return battleNum,readyNum
end
function allianceWarVoApi:setBattleMem(memuid,isBattle,index)
	if self.memList==nil then
		self.memList={}
	end
	-- local isHas=false
	for k,v in pairs(self.memList) do
		if v and tonumber(v.uid)==tonumber(memuid) then
			v.isBattle=isBattle
			if isBattle==1 then
				v.index=index
			else
				v.index=nil
			end
			-- isHas=true
		end
	end
	-- if isHas==false then
	-- 	local memVo=allianceMemberVoApi:getMemberByUid(memuid)
	-- 	if memVo and SizeOfTable(memVo)>0 then
	-- 		local vo = allianceBattleMemVo:new()
	-- 		local idx
	-- 		if isBattle==1 then
	-- 			idx=index
	-- 		else
	-- 			idx=nil
	-- 		end
	--     	vo:initWithData(memuid,memVo.name,memVo.level,memVo.role,memVo.fight,memVo.donate,memVo.useDonate,isBattle,idx)
	--     	table.insert(self.memList,vo)
	-- 	end
	-- end
	local function sortAsc(a, b)
		if a and b then
			if a.isBattle and b.isBattle then
				if a.isBattle==b.isBattle then
					if tonumber(a.fight) and tonumber(b.fight) then
						return tonumber(a.fight)>tonumber(b.fight)
					end
				else
					return a.isBattle>b.isBattle
				end
			end
		end
	end
	table.sort(self.memList,sortAsc)
end
function allianceWarVoApi:updateBattleMem(data)
	if self.memList==nil then
		self.memList={}
	end
	if data and data.members then
        local members=data.members
        if members and SizeOfTable(members)>0 then
	        for m,n in pairs(members) do
	        	local isHas=false
	        	for k,v in pairs(self.memList) do
					if v and tonumber(v.uid)==tonumber(n.uid) then
						allianceWarVoApi:setBattleMem(n.uid,n.batte,n.q)
						isHas=true
					end
				end
	            if isHas==false then
	            	local memuid=tonumber(n.uid)
	            	local memVo=allianceMemberVoApi:getMemberByUid(memuid)
					if memVo and SizeOfTable(memVo)>0 then
						local vo = allianceBattleMemVo:new()
						local idx
						local isBattle=n.batte
						if isBattle==1 then
							idx=n.q
						else
							idx=nil
						end
				    	vo:initWithData(memuid,memVo.name,memVo.level,memVo.role,memVo.fight,memVo.donate,memVo.useDonate,isBattle,idx)
				    	table.insert(self.memList,vo)
					end
					local function sortAsc(a, b)
						if a and b then
							if a.isBattle and b.isBattle then
								if a.isBattle==b.isBattle then
									if tonumber(a.fight) and tonumber(b.fight) then
										return tonumber(a.fight)>tonumber(b.fight)
									end
								else
									return a.isBattle>b.isBattle
								end
							end
						end
					end
					table.sort(self.memList,sortAsc)
	            end
	        end
	        self.memFlag=0
	    end
    end
end
function allianceWarVoApi:getLeftIndex()
	if self.memList and SizeOfTable(self.memList)>0 then
		local maxNum=allianceWarCfg.numberOfBattle
		for i=1,maxNum do
			local indexStr="q"..i
			local isBattle=false
			for k,v in pairs(self.memList) do
				if v and v.index and v.index==indexStr then
					isBattle=true
				end
			end
			if isBattle==false then
				return indexStr
			end
		end
	end
	return nil
end
function allianceWarVoApi:isCanBattle()
	if self.memList and SizeOfTable(self.memList)>0 then
		for k,v in pairs(self.memList) do
			if v and v.uid==playerVoApi:getUid() and v.isBattle==1 then
				return true
			end
		end
	end
	return false
end

function allianceWarVoApi:requestAllianceWarInfo(callback)
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if(selfAlliance==nil)then
		callback(false)
		return false
	end
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if(ret==true)then
			if(sData.data.info)then
				local ownTime=tonumber(sData.data.info.own_at)
				if(ownTime and ownTime>=base.serverTime-24*3600)then
					self.ownCity=tonumber(sData.data.info.ownid)
					if(self.ownCity==0)then
						self.ownCity=nil
					end
				else
					self.ownCity=nil
				end
				self.targetCity=tonumber(sData.data.info.areaid)
				if(self.targetCity==0)then
					self.targetCity=nil
				end
                self.warid=tonumber(sData.data.info.warid)
			else
				self.targetCity=nil
				self.ownCity=nil
                self.warid=0
			end
			if(sData.data.targetState)then
				self.targetState=tonumber(sData.data.targetState)
			else
				self.targetState=0
			end
			if(sData.data.joinline_at)then
				self.joinTime=tonumber(sData.data.joinline_at)
			else
				self.joinTime=0
			end
			self.todayArea=0
			if(sData.data.openPosition)then
				for k,v in pairs(sData.data.openPosition) do
					if(tonumber(v)==1)then
						self.todayArea=1
						break
					elseif(tonumber(v)==5)then
						self.todayArea=2
						break
					end
				end
			end
			--后台传回来的报名时间
			if(sData.data.signUpTime)then
				self.signUpTime=
				{
					--报名的开始时间, {时,分}
					start={tonumber(sData.data.signUpTime.start[1]),tonumber(sData.data.signUpTime.start[2])},
					--报名的结束时间, {时,分}
					finish={tonumber(sData.data.signUpTime.finish[1]),tonumber(sData.data.signUpTime.finish[2])}
				}
			end
			--后台传回来的各个城市的开战时间
			if(sData.data.startWarTime)then
				self.startWarTime=sData.data.startWarTime
			end
			callback(true)
		else
			callback(false)
		end
	end
	socketHelper:allianceWarGetInfo(selfAlliance.aid,onRequestEnd)
end

function allianceWarVoApi:requestCityInfo(cityID,callback)
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if(selfAlliance==nil)then
		callback(cityID,false)
		return false
	end
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		local cityID=sData.data.areaid
		if(ret==true)then
			local cityVo=allianceWarCityVo:new()
			cityVo:initWithData(sData.data)
			self.cityList[cityID]=cityVo
			callback(cityID,true)
		else
			callback(cityID,false)
		end
	end
	socketHelper:allianceWarGetCityInfo(selfAlliance.aid,cityID,onRequestEnd)
end
--获取某城市当前的状态
--param cityID: 要获取状态的城市ID
--return 0: 未开始报名或战斗已经结束
--return 10: 报名阶段但不能报名
--return 11: 报名阶段可报名但是未报名
--return 12: 报名阶段已报名
--return 20: 报名结束到等待开战的阶段
--return 21: 开战前几分钟, 准备进场的阶段
--return 30: 战斗中
--return 40: 战斗结束, 可以查看战报
function allianceWarVoApi:getStatus(cityID)
	if(cityID==nil)then
		return 0
	end
	local curTime=base.serverTime
	local zeroTime=G_getWeeTs(base.serverTime)
	local cityCfg=self:getCityCfgByID(cityID)
	if(cityCfg.area~=self.todayArea)then
		return 0
	elseif(curTime<zeroTime+self.signUpTime.start[1]*3600+self.signUpTime.start[2]*60)then
		return 0
	elseif(curTime<zeroTime+self.signUpTime.finish[1]*3600+self.signUpTime.finish[2]*60)then
		if(self.ownCity~=nil)then
			return 10
		elseif(self.targetCity==nil)then
			return 11
		else
			return 12
		end
	else
		local beginBattleTime=zeroTime+self.startWarTime[cityID][1]*3600+self.startWarTime[cityID][2]*60
		if(base.serverTime<beginBattleTime-allianceWarCfg.prepareTime)then
			return 20
		elseif(base.serverTime<beginBattleTime)then
			return 21
		elseif(base.serverTime<beginBattleTime+allianceWarCfg.maxBattleTime)then
			local cityData=self:getCityDataByID(cityID)
			if(cityData==nil or cityData.inWar==false)then
				return 40
			else
				return 30
			end
		else
			return 40
		end
	end
end

--根据ID获取城市配置
--param cityID: 要查找的城市ID
function allianceWarVoApi:getCityCfgByID(cityID)
	--一般而言，城市ID应该就等于城市在配置表中的key
	if(allianceWarCfg.city[cityID] and allianceWarCfg.city[cityID].id==cityID)then
		return allianceWarCfg.city[cityID]
	--如果不等于的话就得遍历
	else
		for k,v in pairs(allianceWarCfg.city) do
			if(v.id==cityID)then
				return v
			end
		end
	end
	return nil
end

--根据ID获取城市数据
--param cityID: 要查找的城市ID
function allianceWarVoApi:getCityDataByID(cityID)
	--一般而言，城市ID应该就等于城市在数据表中的key
	if(self.cityList[cityID] and self.cityList[cityID].id==cityID)then
		return self.cityList[cityID]
	--如果不等于的话就得遍历
	else
		for k,v in pairs(self.cityList) do
			if(v.id==cityID)then
				return v
			end
		end
	end
	return nil
end

--获取某个地区的所有城市配置
function allianceWarVoApi:getCityCfgListByArea(areaID)
	local list={}
	for k,v in pairs(allianceWarCfg.city) do
		if(v.area==areaID)then
			table.insert(list,v)
		end
	end
	return list
end

--设置某个城市的数据已经过期了，再获取的时候需要重新取数据
--param cityID 要设置过期的城市ID, 如果不传的话就是将所有城市数据都设置过期
function allianceWarVoApi:setCityInfoExpire(cityID)
	if(cityID==nil)then
		for k,v in pairs(self.cityList) do
			v.updateTime=0
		end
	else
		local cityVo=self:getCityDataByID(cityID)
		if(cityVo)then
			cityVo.updateTime=0
		end
	end
end

--检查是否可以进行投标
--param cityID 要查询的城市ID
--return 0: 可以报名
--return 1: 没有军团, 不能参加军团战
--return 2: 不是军团长或副军团长, 权限不足
--return 3: 今天没有开放该城市所在的区域
--return 4: 昨天占领了城市, 今天不能报名
--return 5: 已经报名了其他城市
--return 6: 不在报名时间内
--return 99: 其他错误
function allianceWarVoApi:checkCanBid(cityID)
	if(allianceVoApi:getSelfAlliance()==nil)then
		return 1
	end
	if(tonumber(allianceVoApi:getSelfAlliance().role)~=1 and tonumber(allianceVoApi:getSelfAlliance().role)~=2)then
		return 2
	end
	local cityCfg=self:getCityCfgByID(cityID)
	if(cityCfg.area~=self.todayArea)then
		return 3
	end
	local status=self:getStatus(cityID)
	if(status==11)then
		return 0
	elseif(status==10)then
		return 4
	elseif(status==12)then
		return 5
	else
		return 6
	end
	return 99
end

--投拍报名
function allianceWarVoApi:bid(funds,cityID,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if(ret==true)then
			self.targetCity=sData.data.areaid
			local selfAlliance=allianceVoApi:getSelfAlliance()
			if(selfAlliance and sData.data.point)then
				selfAlliance.point=tonumber(sData.data.point)
			end
			local cityData=self:getCityDataByID(self.targetCity)
			if(cityData)then
				cityData.applycount=cityData.applycount+1
			end
			callback(true)
		else
			callback(false)
		end
	end
	socketHelper:allianceWarSignUp(allianceVoApi:getSelfAlliance().aid,funds,cityID,onRequestEnd)
end

--进入战场
function allianceWarVoApi:enterbattle(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if(ret==true)then
			callback(true)
		else
			callback(false)
		end
	end
	socketHelper:allianceWarJoinBattle(allianceVoApi:getSelfAlliance().aid,onRequestEnd)
end

--初始化战场数据
function allianceWarVoApi:initBattlefield(allianceWarTb)
	if self.selfAllianceWarVo==nil then
		self.selfAllianceWarVo= allianceWarVo:new()
	end
	self.selfAllianceWarVo:initWithData(allianceWarTb)
    self:getSelfOid()
end

function allianceWarVoApi:getBattlefield()
	local tb={}
	for i=1,9,1 do
		local str="h"..i
		if self.selfAllianceWarVo[str]~=nil and SizeOfTable(self.selfAllianceWarVo[str])==0 then
			tb[str]=0
		elseif self.selfAllianceWarVo[str]~=nil and self.selfAllianceWarVo[str].label==1 then
			tb[str]=1
		elseif self.selfAllianceWarVo[str]~=nil and self.selfAllianceWarVo[str].label==2 then
			tb[str]=2
		end
	end
	return tb
end
--取出当前自己占领了哪个据点 0为没占领
function allianceWarVoApi:getSelfOid()
	local hid=0

	for i=1,9,1 do
		local str="h"..i
		if self.selfAllianceWarVo[str]~=nil and self.selfAllianceWarVo[str].oid==playerVoApi:getUid() then
			hid=self.selfAllianceWarVo[str].placeId
            tankVoApi:clearTanksTbByType(6)
            for k,v in pairs(self.selfAllianceWarVo[str].troops) do
                if SizeOfTable(v)>0 then
                    local mid=tonumber(RemoveFirstChar(v[1]))
                    tankVoApi:setTanksByType(6,k,mid,v[2])
		end
	end

        end
    end
    if hid==0 then
        tankVoApi:clearTanksTbByType(6)
    end
	return hid
end
--判断玩家是否占领 传入UID
function allianceWarVoApi:checkIsInHold(uid)
	local isInHold=false
	for i=1,9,1 do
		local str="h"..i
		if self.selfAllianceWarVo[str]~=nil and self.selfAllianceWarVo[str].oid==uid then
            isInHold=true
		end
	end

	return isInHold
end

--最大值限制
function allianceWarVoApi:getMaxPointTb(tb)
    local temTb={0,0}
    if tb[1]>allianceWarCfg.winPointMax and tb[2]>allianceWarCfg.winPointMax then
        if tb[1]>tb[2] then
            local temPoint=tb[1]-allianceWarCfg.winPointMax
            temTb={allianceWarCfg.winPointMax,tb[2]-temPoint}
        elseif tb[1]<tb[2] then
            local temPoint=tb[2]-allianceWarCfg.winPointMax
            temTb={tb[1]-temPoint,allianceWarCfg.winPointMax}
        elseif tb[1]==tb[2] then
            temTb={allianceWarCfg.winPointMax,allianceWarCfg.winPointMax}
        end
    elseif tb[1]>allianceWarCfg.winPointMax and tb[2]<allianceWarCfg.winPointMax then
        temTb={allianceWarCfg.winPointMax,tb[2]}
    elseif tb[2]>allianceWarCfg.winPointMax and tb[1]<allianceWarCfg.winPointMax then
        temTb={tb[1],allianceWarCfg.winPointMax}
    else
        temTb=tb
    end

    return temTb
end

--取出当前比分
function allianceWarVoApi:getPoint()
	local tb={0,0}
	if self.selfAllianceWarVo~=nil and self.selfAllianceWarVo.point~=nil then
		tb=self.selfAllianceWarVo.point
        tb=self:getMaxPointTb(tb)
	end
	return tb
end
--设置比分
function allianceWarVoApi:setPoint(redPoint,bluePoint)
    if self.selfAllianceWarVo~=nil and self.selfAllianceWarVo.point~=nil then
        self.selfAllianceWarVo.point[1]=redPoint
        self.selfAllianceWarVo.point[2]=bluePoint
    end
end

--初始化战场用户数据
function allianceWarVoApi:initBattlefieldUser(allianceWarUserTb)
	if self.selfAllianceWarUserVo==nil then
		self.selfAllianceWarUserVo= allianceWarUserVo:new()
	end
	self.selfAllianceWarUserVo:initWithData(allianceWarUserTb)
end
--取出战场用户数据vo
function allianceWarVoApi:getBattlefieldUser()
	return self.selfAllianceWarUserVo
end
--取出CD时间 如果大于120 则现在没有cd 返回时间和 是否在cd中
function allianceWarVoApi:getBattlefieldUserCDTime()
    local time=base.serverTime-self.selfAllianceWarUserVo.cdtime_at
    local isCD=true
    if time>allianceWarCfg.cdTime then
        isCD=false
    end
    return isCD,(allianceWarCfg.cdTime-time)

end

function allianceWarVoApi:getCDGems(time)
    return math.ceil(time/10)
end

--检查本军团是否是在战斗状态
function allianceWarVoApi:checkInWar()
	if(self:getStatus(self.targetCity)==30 and (self.targetState==1 or self.targetState==2))then
		return true
	else
		return false
	end
end

--检查本军团是否不在战斗状态 或者战斗已经结束
function allianceWarVoApi:checkInWarOrOver()
	local inWar=self:checkInWar()
	--if (inWar==true and self:getIsEnd()==true) or inWar==false then
    if (self:getIsEnd()==true) or inWar==false then
		return true
	end
	return false
end

function allianceWarVoApi:getTargetCity()
	return self.targetCity
end
function allianceWarVoApi:getLeftWarTime()
	local zeroTime=G_getWeeTs(base.serverTime)
	local beginBattleTime=zeroTime+self.startWarTime[self.targetCity][1]*3600+self.startWarTime[self.targetCity][2]*60
	local endTime=beginBattleTime+allianceWarCfg.warTime
	local leftTime=endTime-base.serverTime
	return leftTime
end

function allianceWarVoApi:getAllianceNameTb()
	return self.cityList[self.targetCity].bidList
end



--将一个时间table转换成 时:分 这样的字符串
--param timeTb: 一个table, table的第一个元素是时，第二个元素是分，e.g: [12,0]表示12点整
--return 一个字符串，例如 "12:00"
function allianceWarVoApi:formatTimeStrByTb(timeTb)
	local hour
	if(timeTb[1]>=10)then
		hour=tostring(timeTb[1])
	else
		hour="0"..tostring(timeTb[1])
	end
	local min
	if(timeTb[2]>=10)then
		min=tostring(timeTb[2])
	else
		min="0"..tostring(timeTb[2])
	end
	local timeStr=hour..":"..min
	return timeStr
end

function allianceWarVoApi:isInAllianceWarDialog()
    local isIn=false
    if G_AllianceWarDialogTb["allianceWarDialog"]~=nil then
        isIn=true
    end
    return isIn
end

function allianceWarVoApi:clear()
	self.cityList={}
	self.todayArea=0
	self.targetCity=nil
	self.targetState=0
	self.ownCity=nil
	self.joinTime=0
	self.selfAllianceWarUserVo=nil
	self.selfAllianceWarVo=nil
	self:clearMemList()
	self.memFlag=-1
    self.warid=0
    self.startWarTime=nil
    self.signUpTime=nil
    self.isEnd=false

end