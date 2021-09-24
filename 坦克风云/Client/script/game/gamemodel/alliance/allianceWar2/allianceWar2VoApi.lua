allianceWar2VoApi=
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
    -- selectedCityIndex=1,--选择的哪个城市
    openDate=1,		--是奇数还是偶数开放战斗，0是偶数天开,1是奇数天开
    initFlag=-1,	--是否是第一次请求，后台初始化
    tipFlag=true,
    ownsData={},	--所有占领城市的军团数据
    cityUpdateTime=0,	--城市上次刷新时间
    savedTroops={},	--保存的部队信息
    isOccupied=false,	--战斗中是否占领据点
    isShowResult=false,	--战斗结束时是否没显示结算面板（在战斗中）
}

function allianceWar2VoApi:getInitFlag()
	return self.initFlag
end
function allianceWar2VoApi:setInitFlag(initFlag)
	self.initFlag=initFlag
end

-- 军团战是否开启
function allianceWar2VoApi:isOpenBattle()
	local weets=G_getWeeTs(base.serverTime)
	weets = weets + base.curTimeZone * 3600
	local day=math.ceil(weets/86400)
	if G_isGlobalServer()==true then
		if (day%2)==self.openDate then
			return false
		else
			return true
		end
	else
		if (day%2)==self.openDate then
			return true
		else
			return false
		end
	end
end

function allianceWar2VoApi:getIsAutoSupplement()
	return self.isAutoSupplement
end

function allianceWar2VoApi:setIsAutoSupplement(isAutoSupplement)
	self.isAutoSupplement=isAutoSupplement
end

function allianceWar2VoApi:getIsEnd()
	return self.isEnd
end
function allianceWar2VoApi:setIsEnd(isEnd)
	self.isEnd=isEnd
end
function allianceWar2VoApi:getMemFlag()
	return self.memFlag
end
function allianceWar2VoApi:setMemFlag(memFlag)
	self.memFlag=memFlag
end
function allianceWar2VoApi:clearMemList()
	if self.memList then
		for k,v in pairs(self.memList) do
			v=nil
		end
		self.memList=nil
	end
	self.memList={}
end
function allianceWar2VoApi:formatMemList(data)
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
function allianceWar2VoApi:getMemList()
	if self.memList and SizeOfTable(self.memList)>0 then
		return self.memList
	end
	return {}
end
function allianceWar2VoApi:getBattleMemNum()
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
function allianceWar2VoApi:setBattleMem(memuid,isBattle,index)
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
function allianceWar2VoApi:updateBattleMem(data)
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
						self:setBattleMem(n.uid,n.batte,n.q)
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

function allianceWar2VoApi:isCanBattle()
	-- if self.memList and SizeOfTable(self.memList)>0 then
	-- 	for k,v in pairs(self.memList) do
	-- 		if v and v.uid==playerVoApi:getUid() and v.isBattle==1 then
	-- 			return true
	-- 		end
	-- 	end
	-- end
	-- return false
	return true
end

function allianceWar2VoApi:requestAllianceWarInfo(callback)
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
				if sData.data.info.warid then
	                self.warid=tonumber(sData.data.info.warid)
	            end
			else
				self.targetCity=nil
				self.ownCity=nil
                self.warid=0
			end
			if self.warid==nil or self.warid==0 then
				if sData.data.oldwarid then
					self.warid=tonumber(sData.data.oldwarid)
				end
			end
			if(sData.data.targetState)then
				self.targetState=tonumber(sData.data.targetState)
			else
				self.targetState=0
			end
			-- if(sData.data.joinline_at)then
			-- 	self.joinTime=tonumber(sData.data.joinline_at)
			-- else
			-- 	self.joinTime=0
			-- end
			if(sData.data.join_at)then
				self.joinTime=tonumber(sData.data.join_at)
			else
				self.joinTime=0
			end
			self.todayArea=1
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
				-- print("self.signUpTime.start[1]",self.signUpTime.start[1])	
			end
			--后台传回来的各个城市的开战时间
			if(sData.data.startWarTime)then
				self.startWarTime=sData.data.startWarTime
			end
			--开放战斗，0是偶数天开,1是奇数天开
			if(sData.data.openDate)then
				self.openDate=sData.data.openDate
			end

			if(sData.data.useralliancewar and sData.data.useralliancewar.info and self.targetCity)then
				local troops=sData.data.useralliancewar.info.troops
				local hero=sData.data.useralliancewar.info.hero
				local aitroops=sData.data.useralliancewar.info.aitroops --AI部队
				local emblemID=sData.data.useralliancewar.info.equip
				local planePos=sData.data.useralliancewar.info.plane
				local tskin=sData.data.useralliancewar.info.skin --坦克皮肤数据
				local airshipId = sData.data.useralliancewar.info.ap --上阵飞艇
				local status=self:getStatus(self.targetCity)
				if status and status==30 then
                else
                	local battleType = 31
                    if troops then
                        for k,v in pairs(troops) do
                            if v and v[1] and v[2] then
                                local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
                                local num=tonumber(v[2])
                                tankVoApi:setTanksByType(battleType,k,id,num)
                            else
                                tankVoApi:deleteTanksTbByType(battleType,k)
                            end
                        end
                    end
                    if hero then
                        heroVoApi:setAllianceWar2CurHeroList(G_clone(hero))
                    end
                    --设置当前AI部队
                    if aitroops then
                    	AITroopsFleetVoApi:setAllianceWar2CurAITroopsList(G_clone(aitroops))
                    end
                    emblemVoApi:setBattleEquip(battleType,emblemID)
                    planeVoApi:setBattleEquip(battleType,planePos)
                    if tskin then
                    	tankSkinVoApi:setTankSkinListByBattleType(battleType,G_clone(tskin))
                    end
                    if airshipId then
                    	airShipVoApi:setBattleEquip(battleType,airshipId)
                    end
                end
                -- print("troops-31~~~~~~~~")
                -- G_dayin(tankVoApi:getTanksTbByType(31))
			end
			callback(true)
		else
			callback(false)
		end
	end
	socketHelper:alliancewarnewGetapply(selfAlliance.aid,onRequestEnd)
end

function allianceWar2VoApi:requestCityInfo(cityID,callback)
	local selfAlliance=allianceVoApi:getSelfAlliance()
	if(selfAlliance==nil)then
		callback(cityID,false)
		return false
	end
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		-- local cityID=sData.data.areaid
		if(ret==true)then
			if allianceWar2Cfg and allianceWar2Cfg.city then
				for k,v in pairs(allianceWar2Cfg.city) do
					if v and v.id then
						local cID=v.id
						local formatCityData={}
						for m,n in pairs(sData.data) do
							if m=="inWar" then
							elseif m=="areaid" then
								formatCityData[m]=cID
							elseif (m=="rank" or m=="newinWar" or m=="applycount") and cID and n and n[cID] then
								if m=="newinWar" then
									formatCityData["inWar"]=n[cID]
								else
									formatCityData[m]=n[cID]
								end
							else
								formatCityData[m]=n
							end
						end
						local cityVo=allianceWar2CityVo:new()
						cityVo:initWithData(formatCityData)
						self.cityList[cID]=cityVo
					end
				end
			end
			self:setCityUpdateTime(base.serverTime)
			callback(cityID,true)
		else
			callback(cityID,false)
		end
	end
	socketHelper:alliancewarnewGetCityInfo(selfAlliance.aid,cityID,onRequestEnd)
end
--获取某城市当前的状态
--param cityID: 要获取状态的城市ID
--return 0: 未开始报名或战斗已经结束
--return 10: 报名阶段但不能报名
--return 11: 报名阶段可报名但是未报名
--return 12: 报名阶段已报名
--return 20: 报名结束到等待开战的阶段
--return 30: 战斗中
--return 40: 占领期，战斗结束, 可以查看战报
--return 50: 未开始报名，战斗结束, 可以查看战报
function allianceWar2VoApi:getStatus(cityID)
	if(cityID==nil)then
		return 0
	end
	if G_isGlobalServer()==true then
		local curTime=base.serverTime
		local zeroTime=G_getWeeTs(base.serverTime)
		if self:isOpenBattle()==false then
			if(self.targetCity==nil)then
				return 11
			else
				return 12
			end
		else
			if self:getIsInOccupy(cityID)==true then
				return 40
			else
				local beginBattleTime=zeroTime+self.startWarTime[cityID][1]*3600+self.startWarTime[cityID][2]*60
				if(base.serverTime<beginBattleTime)then
					return 20
				elseif(base.serverTime<beginBattleTime+allianceWar2Cfg.maxBattleTime)then
					local cityData=self:getCityDataByID(cityID)
					if(cityData==nil or cityData.inWar==false)then
						return 40
					else
						return 30
					end
				else
					return 50
				end
			end
		end
	else
		if self:getIsInOccupy(cityID)==true then
			return 40
		elseif self:isOpenBattle()==false then
			return 50
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
			-- print("cityID",cityID)
			-- print("self.startWarTime",self.startWarTime)
			-- print("self.startWarTime[cityID]",self.startWarTime[cityID])
			-- print("self.startWarTime[cityID][1]",self.startWarTime[cityID][1])
			local beginBattleTime=zeroTime+self.startWarTime[cityID][1]*3600+self.startWarTime[cityID][2]*60
			-- print("beginBattleTime",beginBattleTime)
			-- print("beginBattleTime-allianceWar2Cfg.prepareTime",beginBattleTime-allianceWar2Cfg.prepareTime)
			-- print("base.serverTime",base.serverTime)
			-- if(base.serverTime<beginBattleTime-allianceWar2Cfg.prepareTime)then
			-- 	return 20
			-- elseif(base.serverTime<beginBattleTime)then
			-- 	return 21
			if(base.serverTime<beginBattleTime)then
				return 20
			elseif(base.serverTime<beginBattleTime+allianceWar2Cfg.maxBattleTime)then
				local cityData=self:getCityDataByID(cityID)
				if(cityData==nil or cityData.inWar==false)then
					return 40
				else
					return 30
				end
			else
				return 50
			end
		end
	end
end
--是否在占领期
function allianceWar2VoApi:getIsInOccupy(cityID)
	local isInOccupy,isShowOccupy=false,false
	local endTime=0
	if cityID then
		local ownsData=self:getOwnsData()
		if ownsData then
			for k,v in pairs(ownsData) do
				if v and v.areaid and v.areaid==cityID then
					if v.ownat and tonumber(v.ownat) and base.serverTime<(tonumber(v.ownat)+86400) then
						isInOccupy=true
						endTime=(tonumber(v.ownat)+86400)
					end
				end
			end
		end
		if isInOccupy==false then
			if self.startWarTime then
				local zeroTime=G_getWeeTs(base.serverTime)
				local beginBattleTime=zeroTime+self.startWarTime[cityID][1]*3600+self.startWarTime[cityID][2]*60
				if self:isOpenBattle()==false then
					if base.serverTime<beginBattleTime then
						isInOccupy=true
						endTime=beginBattleTime
					end
				else
					if base.serverTime>beginBattleTime then
						local cityData=self:getCityDataByID(cityID)
						if cityData and cityData.allianceID1==nil and cityData.allianceID2==nil then
							isInOccupy=true
							endTime=beginBattleTime+86400
							isShowOccupy=true
						end
					end
				end
			end
		end
	end
	-- print("isInOccupy",isInOccupy)
	return isInOccupy,endTime,isShowOccupy
end

--根据ID获取城市配置
--param cityID: 要查找的城市ID
function allianceWar2VoApi:getCityCfgByID(cityID)
	--一般而言，城市ID应该就等于城市在配置表中的key
	if(allianceWar2Cfg.city[cityID] and allianceWar2Cfg.city[cityID].id==cityID)then
		return allianceWar2Cfg.city[cityID]
	--如果不等于的话就得遍历
	else
		for k,v in pairs(allianceWar2Cfg.city) do
			if(v.id==cityID)then
				return v
			end
		end
	end
	return nil
end

--根据ID获取城市数据
--param cityID: 要查找的城市ID
function allianceWar2VoApi:getCityDataByID(cityID)
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
function allianceWar2VoApi:getCityCfgListByArea(areaID)
	local list={}
	for k,v in pairs(allianceWar2Cfg.city) do
		if(v.area==areaID)then
			table.insert(list,v)
		end
	end
	return list
end

--设置某个城市的数据已经过期了，再获取的时候需要重新取数据
--param cityID 要设置过期的城市ID, 如果不传的话就是将所有城市数据都设置过期
function allianceWar2VoApi:setCityInfoExpire(cityID)
	-- if(cityID==nil)then
	-- 	for k,v in pairs(self.cityList) do
	-- 		v.updateTime=0
	-- 	end
	-- else
	-- 	local cityVo=self:getCityDataByID(cityID)
	-- 	if(cityVo)then
	-- 		cityVo.updateTime=0
	-- 	end
	-- end
	self:setCityUpdateTime(0)
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
function allianceWar2VoApi:checkCanBid(cityID)
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
function allianceWar2VoApi:bid(funds,cityID,callback)
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
	socketHelper:alliancewarnewApply(allianceVoApi:getSelfAlliance().aid,funds,cityID,onRequestEnd)
end

-- --进入战场
-- function allianceWar2VoApi:enterbattle(callback)
-- 	local function onRequestEnd(fn,data)
-- 		local ret,sData=base:checkServerData(data)
-- 		if(ret==true)then
-- 			callback(true)
-- 		else
-- 			callback(false)
-- 		end
-- 	end
-- 	socketHelper:alliancewarnewJoinline(allianceVoApi:getSelfAlliance().aid,onRequestEnd)
-- end

--初始化战场数据
function allianceWar2VoApi:initBattlefield(allianceWarTb)
	if self.selfAllianceWarVo==nil then
		self.selfAllianceWarVo= allianceWar2Vo:new()
	end
	self.selfAllianceWarVo:initWithData(allianceWarTb)
    self:getSelfOid()
end

function allianceWar2VoApi:getBattlefield()
	local tb={}
	if self.selfAllianceWarVo then
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
	end
	return tb
end
--取出当前自己占领了哪个据点 0为没占领
function allianceWar2VoApi:getSelfOid()
	local hid=0
	if self.selfAllianceWarVo then
		local tType=31
		for i=1,9,1 do
			local str="h"..i
			if self.selfAllianceWarVo[str]~=nil and self.selfAllianceWarVo[str].oid==playerVoApi:getUid() then
				hid=self.selfAllianceWarVo[str].placeId
				hid=(tonumber(hid) or tonumber(RemoveFirstChar(hid)))
	   --          tankVoApi:clearTanksTbByType(tType)
	   --          for k,v in pairs(self.selfAllianceWarVo[str].troops) do
	   --              if SizeOfTable(v)>0 then
	   --                  local mid=tonumber(RemoveFirstChar(v[1]))
	   --                  tankVoApi:setTanksByType(tType,k,mid,v[2])
				-- 	end
				-- end
			end
        end
     --    if hid==0 then
	    --     tankVoApi:clearTanksTbByType(tType)
	    -- end
    end
	return hid
end
--判断玩家是否占领 传入UID
function allianceWar2VoApi:checkIsInHold(uid)
	local isInHold=false
	if self.selfAllianceWarVo then
		for i=1,9,1 do
			local str="h"..i
			if self.selfAllianceWarVo[str]~=nil and self.selfAllianceWarVo[str].oid==uid then
	            isInHold=true
			end
		end
	end
	return isInHold
end
--根据hid取出据点数据
function allianceWar2VoApi:getPositionInfo(hid)
	if hid and self.selfAllianceWarVo then
		return self.selfAllianceWarVo[hid]
	end
	return nil
end

--最大值限制
function allianceWar2VoApi:getMaxPointTb(tb)
    local temTb={0,0}
    if tb[1]>allianceWar2Cfg.winPointMax and tb[2]>allianceWar2Cfg.winPointMax then
        if tb[1]>tb[2] then
            local temPoint=tb[1]-allianceWar2Cfg.winPointMax
            temTb={allianceWar2Cfg.winPointMax,tb[2]-temPoint}
        elseif tb[1]<tb[2] then
            local temPoint=tb[2]-allianceWar2Cfg.winPointMax
            temTb={tb[1]-temPoint,allianceWar2Cfg.winPointMax}
        elseif tb[1]==tb[2] then
            temTb={allianceWar2Cfg.winPointMax,allianceWar2Cfg.winPointMax}
        end
    elseif tb[1]>allianceWar2Cfg.winPointMax and tb[2]<allianceWar2Cfg.winPointMax then
        temTb={allianceWar2Cfg.winPointMax,tb[2]}
    elseif tb[2]>allianceWar2Cfg.winPointMax and tb[1]<allianceWar2Cfg.winPointMax then
        temTb={tb[1],allianceWar2Cfg.winPointMax}
    else
        temTb=tb
    end

    return temTb
end

--取出当前比分
function allianceWar2VoApi:getPoint()
	local tb={0,0}
	-- print("self.selfAllianceWarVo",self.selfAllianceWarVo)
	if self.selfAllianceWarVo~=nil and self.selfAllianceWarVo.point~=nil then
		-- print("self.selfAllianceWarVo.point",self.selfAllianceWarVo.point)
		tb=self.selfAllianceWarVo.point
		-- G_dayin(tb)
        tb=self:getMaxPointTb(tb)
        -- G_dayin(tb)
	end
	return tb
end
--设置比分
function allianceWar2VoApi:setPoint(redPoint,bluePoint)
    if self.selfAllianceWarVo~=nil and self.selfAllianceWarVo.point~=nil then
        self.selfAllianceWarVo.point[1]=redPoint
        self.selfAllianceWarVo.point[2]=bluePoint
    end
end

--取出每10秒分数增长
function allianceWar2VoApi:getPerPoint()
	if self.selfAllianceWarVo~=nil and self.selfAllianceWarVo.perPoint~=nil then
        return self.selfAllianceWarVo.perPoint
    else
    	return {0,0}
    end
end


--初始化战场用户数据
function allianceWar2VoApi:initBattlefieldUser(allianceWarUserTb)
	if self.selfAllianceWarUserVo==nil then
		self.selfAllianceWarUserVo= allianceWar2UserVo:new()
	end
	self.selfAllianceWarUserVo:initWithData(allianceWarUserTb)
end
--取出战场用户数据vo
function allianceWar2VoApi:getBattlefieldUser()
	if self.selfAllianceWarUserVo then
		return self.selfAllianceWarUserVo
	else
		return {}
	end
end
--取出CD时间 如果大于120 则现在没有cd 返回时间和 是否在cd中
function allianceWar2VoApi:getBattlefieldUserCDTime()
	if self.selfAllianceWarUserVo and self.selfAllianceWarUserVo.cdtime_at then
	    local time=base.serverTime-self.selfAllianceWarUserVo.cdtime_at
	    local isCD=true
	    if time>allianceWar2Cfg.cdTime then
	        isCD=false
	    end
	    return isCD,(allianceWar2Cfg.cdTime-time)
	else
		return false,0
	end
end

function allianceWar2VoApi:getCDGems(time)
    return math.ceil(time/10)
end

--检查本军团是否是在战斗状态
function allianceWar2VoApi:checkInWar()
	if(self:getStatus(self.targetCity)==30 and (self.targetState==1 or self.targetState==2))then
		return true
	else
		return false
	end
end

--检查本军团是否不在战斗状态 或者战斗已经结束
function allianceWar2VoApi:checkInWarOrOver()
	local inWar=self:checkInWar()
	--if (inWar==true and self:getIsEnd()==true) or inWar==false then
    if (self:getIsEnd()==true) or inWar==false then
		return true
	end
	return false
end

function allianceWar2VoApi:getTargetCity()
	return self.targetCity
end
function allianceWar2VoApi:getLeftWarTime()
	local zeroTime=G_getWeeTs(base.serverTime)
	local beginBattleTime=zeroTime+self.startWarTime[self.targetCity][1]*3600+self.startWarTime[self.targetCity][2]*60
	local endTime=beginBattleTime+allianceWar2Cfg.maxBattleTime
	local leftTime=endTime-base.serverTime
	return leftTime
end

function allianceWar2VoApi:getAllianceNameTb()
	return self.cityList[self.targetCity].bidList
end



--将一个时间table转换成 时:分 这样的字符串
--param timeTb: 一个table, table的第一个元素是时，第二个元素是分，e.g: [12,0]表示12点整
--return 一个字符串，例如 "12:00"
function allianceWar2VoApi:formatTimeStrByTb(timeTb)
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

function allianceWar2VoApi:isInAllianceWarDialog()
    local isIn=false
    if G_AllianceWarDialogTb["allianceWar2Dialog"]~=nil then
        isIn=true
    end
    return isIn
end

function allianceWar2VoApi:endBattle(callback)
    local function getCallback(fn,data)
        local cresult,retTb=base:checkServerData(data)
        if cresult==true then
            -- self.callbackNum1=0
            self:setInitFlag(1)
            if retTb.data~=nil and retTb.data.alliancewar~=nil and retTb.data.alliancewar.isover==1 then
                G_isRefreshGetpoint=false
			    self:setIsEnd(true)
			    G_updateEmailList(1,nil,false)
			    allianceWar2RecordVoApi:setDFlag(-1)
			    self:setCityInfoExpire(nil)

			    local function getbattlelogCallback(fn,data)
			        local ret,sData=base:checkServerData(data)
			        if ret==true then
			            if sData.data and sData.data.alog then
			                allianceWar2RecordVoApi:formatResultData(sData.data.alog)
			                base.pauseSync=false
			                G_SyncData()
			                if (G_AllianceWarDialogTb["allianceWar2Dialog"] or G_AllianceWarDialogTb["allianceWar2OverviewDialog"]) and battleScene.isBattleing==false then
			                    local isVictory=allianceWar2RecordVoApi:isVictory()
			                    local params={}
			                    local function callback1(tag,object)
			                    end
			                    allianceSmallDialog:showWar2ResultDialog("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),isVictory,callback1,true,7,params)
			                end
			                self:setPoint(allianceWar2RecordVoApi.redPoint,allianceWar2RecordVoApi.bluePoint)
			            end
			        end
			    end
			    local type=2
			    local selfAlliance = allianceVoApi:getSelfAlliance()
			    local aid=selfAlliance.aid
			    local uid=playerVoApi:getUid()
			    local warid=self.warid
			    -- print("aid",aid)
			    -- print("uid",uid)
			    -- print("warid",warid)
			    if warid and warid>0 then
			        socketHelper:alliancewarnewGetbattlelog(warid,type,aid,uid,nil,nil,getbattlelogCallback)
			    end
			    base.allianceTime=nil
			    G_getAlliance()

			    if callback then
	                callback()
	            end
            end
        end
    end
    local initFlag=nil
    if self:getInitFlag()==-1 then
        initFlag=true
    end
	local targetCity=self.targetCity
    socketHelper:alliancewarnewGet(targetCity,initFlag,getCallback)
end

--所有城市占领数据
function allianceWar2VoApi:getOwnsData()
	return self.ownsData
end
function allianceWar2VoApi:setOwnsData(ownsData)
	if ownsData then
		self.ownsData=ownsData
	end
end

--城市是否只有一个军团报名
function allianceWar2VoApi:getIsOneSign(cityID)
	local isOneSign=false
	if cityID then
		local cityData=self:getCityDataByID(cityID)
		if cityData and (cityData.allianceID1 and cityData.allianceID2==nil) or (cityData.allianceID1==nil and cityData.allianceID2) then
			isOneSign=true
		end
	end
	return isOneSign
end

--战斗中是否占领据点
function allianceWar2VoApi:getOccupyData()
	return self.occupyData
end
function allianceWar2VoApi:setOccupyData(cityID,value)
	if self.occupyData==nil then
		self.occupyData={}
	end
	if cityID then
		self.occupyData[cityID]=value
	end
end

--------------以下军团战部队---------------
--弹出我的部队面板
function allianceWar2VoApi:showTroopsDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2TroopsDialog"
	local td=allianceWar2TroopsDialog:new()
	local tbArr={getlocal("local_war_troops_status"),getlocal("local_war_troops_preset")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("local_war_my_troops"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

-- 0可以设置,1不能设置
function allianceWar2VoApi:getSetFleetStatus()
	local cityID=self:getTargetCity()
	local status=self:getStatus(cityID)
	if status>=20 and status<=30 then
		return 0
	end
	return 1,getlocal("local_war_troops_cannot_set_fleet")
end

--获取部队标示
function allianceWar2VoApi:getTankInfoFlag()
	return self.tankInfoFlag
end
function allianceWar2VoApi:setTankInfoFlag(flag)
	self.tankInfoFlag=flag
end

--上次设置部队时间
function allianceWar2VoApi:getLastSetFleetTime()
	return self.lastSetFleetTime
end
function allianceWar2VoApi:setLastSetFleetTime(time)
	self.lastSetFleetTime=time
end

--上次城市刷新时间
function allianceWar2VoApi:getCityUpdateTime()
	return self.cityUpdateTime
end
function allianceWar2VoApi:setCityUpdateTime(cityUpdateTime)
	self.cityUpdateTime=cityUpdateTime
end

function allianceWar2VoApi:getSavedTroops()
	return self.savedTroops
end
function allianceWar2VoApi:setSavedTroops(savedTroops)
	self.savedTroops=savedTroops
end

function allianceWar2VoApi:isHasSetFleet()
	local hasSetTroops=false
    local tanksTb=tankVoApi:getTanksTbByType(32)
    if tanksTb then
        for k,v in pairs(tanksTb) do
            if v and SizeOfTable(v)>0 then
                hasSetTroops=true
            end
        end
    end
    return hasSetTroops
end

function allianceWar2VoApi:getIsShowResult()
	return self.isShowResult
end
function allianceWar2VoApi:setIsShowResult(isShowResult)
	self.isShowResult=isShowResult
end

function allianceWar2VoApi:setCurHero(sData)
	local isSetCurHero=false
	if sData and sData.data and sData.data.alliancewar and sData.data.alliancewar.positionInfo then
		local positionInfo=sData.data.alliancewar.positionInfo
		for k,v in pairs(positionInfo) do
			if k~="point" and v and v.oid then
				if v.oid==playerVoApi:getUid() and v.heros then
					isSetCurHero=true
					heroVoApi:setAllianceWar2CurHeroList(v.heros)
				end 
			end
		end
	end
	if isSetCurHero==false then
		local hero=heroVoApi:getAllianceWar2HeroList()
		heroVoApi:setAllianceWar2CurHeroList(G_clone(hero))
	end
end

function allianceWar2VoApi:setCurAITroops(sData)
	local isSetCurAITroops=false
	if sData and sData.data and sData.data.alliancewar and sData.data.alliancewar.positionInfo then
		local positionInfo=sData.data.alliancewar.positionInfo
		for k,v in pairs(positionInfo) do
			if k~="point" and v and v.oid then
				if v.oid==playerVoApi:getUid() and v.aitroops then
					isSetCurAITroops=true
					AITroopsFleetVoApi:setAllianceWar2CurAITroopsList(v.aitroops)
				end 
			end
		end
	end
	if isSetCurAITroops==false then
		local aitroops=AITroopsFleetVoApi:getAllianceWar2AITroopsList()
		AITroopsFleetVoApi:setAllianceWar2CurAITroopsList(G_clone(aitroops))
	end
end

function allianceWar2VoApi:setCurTroopsSkin(sData)
	local isSetCurSkin=false
	if sData and sData.data and sData.data.alliancewar and sData.data.alliancewar.positionInfo then
		local positionInfo=sData.data.alliancewar.positionInfo
		for k,v in pairs(positionInfo) do
			if k~="point" and v and v.oid then
				if v.oid==playerVoApi:getUid() and v.skin then
					isSetCurSkin=true
					tankSkinVoApi:setTankSkinListByBattleType(31, v.skin)
				end 
			end
		end
	end
	if isSetCurSkin==false then
		local tskin=tankSkinVoApi:getTankSkinListByBattleType(32)	
		tankSkinVoApi:setTankSkinListByBattleType(31, G_clone(tskin))
	end
end

-- 设置当前军徽，如果占领状态，则不设置
function allianceWar2VoApi:setCurEquip(sData)
	local hasSet=false
	if sData and sData.data and sData.data.alliancewar and sData.data.alliancewar.positionInfo then
		local positionInfo=sData.data.alliancewar.positionInfo
		for k,v in pairs(positionInfo) do
			if k~="point" and v and v.oid then
				if v.oid==playerVoApi:getUid() then
					hasSet=true
					if v.equip then
						emblemVoApi:setBattleEquip(31,v.equip)
					else
						emblemVoApi:setBattleEquip(31,nil)
					end
					if v.plane then
						if type(v.plane)=="string" then
							local planeVo=planeVoApi:getPlaneVoById(v.plane)
							if planeVo and planeVo.idx then
								planeVoApi:setBattleEquip(31,planeVo.idx)
							else
								planeVoApi:setBattleEquip(31,nil)
							end
						else
							planeVoApi:setBattleEquip(31,v.plane)
						end
					else
						planeVoApi:setBattleEquip(31,nil)
					end
					airShipVoApi:setBattleEquip(31, v.ap)
				end
			end
		end
	end
	if hasSet==false then
		local emblemID=emblemVoApi:getBattleEquip(32)
		emblemVoApi:setBattleEquip(31,emblemID)
		local planePos=planeVoApi:getBattleEquip(32)
		planeVoApi:setBattleEquip(31,planePos)
		local airshipId = airShipVoApi:getBattleEquip(32)
		airShipVoApi:setBattleEquip(31,airshipId)
	end
end

--------------以上军团战部队---------------

-- 展示详情面板
-- allianceWar2VoApi:showDetailDialog(self.layerNum+1,self.selectedCityData,1)
function allianceWar2VoApi:showDetailDialog(layerNum,cityData,type)
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2DetailDialog"
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2DetailTab1"
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2DetailTab2"

	local td=allianceWar2DetailDialog:new(cityData,type)
	local tbArr={getlocal("plat_war_reward_detail"),getlocal("allianceWar2_bid_detail")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerInfo"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

-- 展示科技面板（buffer）
function allianceWar2VoApi:showBufferDialog(layerNum)
	if allianceWar2VoApi.tipFlag then
		allianceWar2VoApi.tipFlag=false
		eventDispatcher:dispatchEvent("allianceWar2.bufferChange",{})
	end
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2BuffDialog"

	local td=allianceWar2BuffDialog:new()
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_skill"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

-- 展示奖励面板
function allianceWar2VoApi:showRewardDialog(layerNum,cityData,type)
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2RewardDialog"
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2DetailTab1"

	local td=allianceWar2RewardDialog:new(cityData,type)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerInfo"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

-- 展示战报面板
function allianceWar2VoApi:showRecordDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2RecordDialog"
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2RecordTab1"
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2RecordTab2"
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2RecordTab3"

	local td=allianceWar2RecordDialog:new()
	local tbArr={getlocal("local_war_report_person"),getlocal("allianceWar2_allianceReport"),getlocal("alliance_war_stats")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("allianceWar_battleReport"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

-- 显示结算面板
function allianceWar2VoApi:showResultDialog()
	local isVictory=allianceWar2RecordVoApi:isVictory()
    local params={}
    local function callback(tag,object)
    end
    allianceSmallDialog:showWar2ResultDialog("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),isVictory,callback,true,7,params)
end

function allianceWar2VoApi:clear()
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
    -- self.selectedCityIndex=1
    self.openDate=1
    self.initFlag=-1
    self.tipFlag=true
    self.ownsData={}
    self.cityUpdateTime=0
    self.savedTroops={}
    self.isOccupied=false
    self.isShowResult=false
end