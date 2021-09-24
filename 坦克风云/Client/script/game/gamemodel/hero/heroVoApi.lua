
heroVoApi={
	heroList={},
	soulList={},
	info={},
	troopsTb={0,0,0,0,0,0},
	defTroops={0,0,0,0,0,0},
	arenaTroops={0,0,0,0,0,0},
	allianceTroops={0,0,0,0,0,0},
	stats={d={},m={},a={},l={}},--各种队列状态
	serverWarTroop1={0,0,0,0,0,0}, --跨服个人战英雄第一场
    serverWarTroop2={0,0,0,0,0,0}, --跨服个人战英雄第二场
    serverWarTroop3={0,0,0,0,0,0}, --跨服个人战英雄第三场
    serverWarTeamTroops={0,0,0,0,0,0}, --跨服军团战英雄
    bossbattleTroops={0,0,0,0,0,0},--世界boss
    worldWarTroop1={0,0,0,0,0,0}, --世界争霸英雄部队一
    worldWarTroop2={0,0,0,0,0,0}, --世界争霸英雄部队二
    worldWarTroop3={0,0,0,0,0,0}, --世界争霸英雄部队三
    currentHonorID=nil,					--当前正在进行授勋任务的英雄ID
    realiseSkillList={}, 	--领悟出来的技能列表，{h1={s101=10,s102=15},h2={...}}
    localWarTroops={0,0,0,0,0,0}, --区域战预设英雄
    localWarCurTroops={0,0,0,0,0,0}, --区域战当前英雄
    swAttackTroops={0,0,0,0,0,0}, --超级武器攻击英雄
    swDefenceTroops={0,0,0,0,0,0}, --超级武器防守英雄
    platWarTroop1={0,0,0,0,0,0}, --平台战英雄部队一
    platWarTroop2={0,0,0,0,0,0}, --平台战英雄部队二
    platWarTroop3={0,0,0,0,0,0}, --平台战英雄部队三
    serverWarLocalTroop1={0,0,0,0,0,0}, --群雄争霸英雄部队一
    serverWarLocalTroop2={0,0,0,0,0,0}, --群雄争霸英雄部队二
    serverWarLocalTroop3={0,0,0,0,0,0}, --群雄争霸英雄部队三
    serverWarLocalCurTroop1={0,0,0,0,0,0}, --群雄争霸英雄部队现状一
    serverWarLocalCurTroop2={0,0,0,0,0,0}, --群雄争霸英雄部队现状二
    serverWarLocalCurTroop3={0,0,0,0,0,0}, --群雄争霸英雄部队现状三
    allianceWar2Troops={0,0,0,0,0,0}, --新军团战预设英雄
    allianceWar2CurTroops={0,0,0,0,0,0}, --新军团战当前英雄
    newYearBossTroops={0,0,0,0,0,0}, --除夕活动攻击boss英雄
    dimensionalWarTroops={0,0,0,0,0,0}, --异元战场报名英雄
    dimensionalWarTroopsData={0,0,0,0,0,0}, --异元战场报名英雄数据，hid-品阶-等级
    serverWarTeamCurTroops={0,0,0,0,0,0}, --跨服军团战当前英雄
    exp=0, -- 三种经验书转成的经验值
    championshipWarPersonalHeroTb={0,0,0,0,0,0}, --军团锦标赛个人战将领
    championshipWarHeroTb={0,0,0,0,0,0}, --军团锦标赛军团战将领
    skillResetTimer=nil, --技能重置的过期时间戳
    allPower=0,--所有将领总战力
}
function heroVoApi:clear()
	self.allPower=0
    self.heroList={}
    self.soulList={}
    self.info={}
    self.troopsTb={0,0,0,0,0,0}
    self.defTroops={0,0,0,0,0,0}
	self.arenaTroops={0,0,0,0,0,0}
    self.stats={d={},m={},a={},l={},w={}}
    self:clearServerWarTroops()
    self:clearServerWarTeamTroops()
    self.bossbattleTroops={0,0,0,0,0,0}
    self:clearWorldWarTroops()
    self.currentHonorID=nil
    self.realiseSkillList={}
    self:clearLocalWarTroops()
    self:clearLocalWarCurTroops()
    self:clearServerWarLocalTroops()
    self:clearServerWarLocalCurTroops()
    self:clearAllianceWar2Troops()
    self:clearAllianceWar2CurTroops()
    self.newYearBossTroops={0,0,0,0,0,0}
    self:clearDimensionalWarTroops()
    self:clearServerWarTeamCurTroops()
    self:clearChampionshipWarHeroTb()
    self:clearChampionshipWarPersonalHeroTb()
    self.exp=0
    self.skillResetTimer=nil
    heroAdjutantVoApi:clear()
end



function heroVoApi:allAtkHero()
	local tb = {}
	if self.stats.a~=nil then
		for k,v in pairs(self.stats.a) do
			for i,j in pairs(v) do
				table.insert(tb,j)
			end
		end
	end
	if self.stats.l~=nil then
		for k,v in pairs(self.stats.l) do
			for i,j in pairs(v) do
				table.insert(tb,j)
			end
		end
	end
	return tb
end

function heroVoApi:defAtkHero()
	local tb = {}
	for k,v in pairs(self:allAtkHero()) do
		for i,j in pairs(self:getDefHeroList()) do
			if v==j then
				table.insert(tb,j)
			end
		end
	end
	return tb
end

function heroVoApi:getHeroColor(productOrder)
	local color = G_ColorWhite
	if productOrder==2 then
		color=G_ColorGreen
	elseif productOrder==3 then
		color=G_ColorBlue
	elseif productOrder==4 then
		color=G_ColorPurple
	elseif productOrder==5 then
		color=G_ColorOrange
	elseif productOrder==6 then
		color=G_ColorRed
	end
	return color
end

function heroVoApi:isHaveHero()
	local isHave = false

	if SizeOfTable(self.heroList)>0 then
		isHave = true
	end

	return isHave
end

function heroVoApi:setDefHeroList(tb)
	print("heroVoApi:setDefHeroList")
	if tb~=nil then
		if self.stats.d==nil then
			self.stats.d={}
			self.stats.d[1]={}
		end
		self.stats.d[1]=tb
		self.defTroops=tb
	end
end

function heroVoApi:getDefHeroList()
	local tmpDefTroops={0,0,0,0,0,0}
	if self.stats.d~=nil and SizeOfTable(self.stats.d)>0 then
		self.defTroops=self.stats.d[1]
		local tankTb=tankVoApi:getTemDefenseTanks()
		for k,v in pairs(tankTb) do
			if SizeOfTable(v)==0 or (v[2] and v[2]==0) then
				--当前位置没有坦克时，清空该位置的英雄
				self.defTroops[k]=0
			end
		end
		--除去出战的英雄
		tmpDefTroops=G_clone(self.defTroops)
		local allAtkHero=self:allAtkHero()
		if allAtkHero and SizeOfTable(allAtkHero)>0 then
			for k,v in pairs(allAtkHero) do
				for m,n in pairs(tmpDefTroops) do
					if v==n then
						tmpDefTroops[m]=0
					end
				end
			end
		end
	end
	return tmpDefTroops
end

function heroVoApi:getArenaHeroList()
	if self.stats.m~=nil and SizeOfTable(self.stats.m)>0 then
		self.arenaTroops=self.stats.m[1]
	end
	return self.arenaTroops
end

function heroVoApi:setArenaHeroList(tb)
	if tb==nil then
		tb={0,0,0,0,0,0}
	end
	if self.stats.m==nil then
		self.stats.m={}
		self.stats.m[1]={}
	end
	self.stats.m[1]=tb
	self.arenaTroops=tb
end


function heroVoApi:getBossHeroList()
	--[[if self.stats.m~=nil and SizeOfTable(self.stats.m)>0 then
		self.bossbattleTroops=self.stats.m[1]
	end--]]
	return self.bossbattleTroops
end

function heroVoApi:setBossHeroList(tb)
	if tb==nil then
		tb={0,0,0,0,0,0}
	end
	--[[if self.stats.m==nil then
		self.stats.m={}
		self.stats.m[1]={}
	end
	self.stats.m[1]=tb--]]
	self.bossbattleTroops=tb
end

function heroVoApi:getAllianceHeroList()
	if self.stats.l~=nil and SizeOfTable(self.stats.l)>0 then
		self.allianceTroops=self.stats.l[1]
	end
	return self.allianceTroops
end

function heroVoApi:getMachiningHeroList(tb)
	for k,v in pairs(self.troopsTb) do
		if SizeOfTable(tb[k])==0 then
			self:setTroopsByPos(k,0)
		end
	end
	return self.troopsTb
end



function heroVoApi:isHaveTroops()
	local ishave=false
	for k,v in pairs(self.troopsTb) do
		if v~=0 then
			ishave=true
		end
	end
	return ishave
end

function heroVoApi:bestHero(type,tankTb)
	local tempTanks
	if tankTb then
		tempTanks=tankTb
	else
		tempTanks=tankVoApi:getTanksTbByType(type)
	end

	local heroList=G_clone(self.heroList)
	-- table.sort(heroList,function(a,b) return a.heroPower>b.heroPower end)
	-- local tb = {}
	-- local index=nil
	if type then
		if type==7 or type==8 or type==9 then
			heroList=self:getCanSetBestHeroList(heroList,type-6)
		end 
		if type==11 then
			heroList=self:getBestHeroListExpedition()
			-- table.sort(heroList,function(a,b) return a.heroPower>b.heroPower end)
		end
		if type==13 or type==14 or type==15 then
			heroList=self:getWorldWarCanSetBestHeroList(heroList,type-12)
		end 
		if type==21 or type==22 or type==23 then
			heroList=self:getPlatWarCanSetBestHeroList(heroList,type-20)
		end 
		if type==24 or type==25 or type==26 then
			heroList=self:getServerWarLocalCanSetBestHeroList(heroList,type-23)
		end 
	end

	local tb = {0,0,0,0,0,0}

	local bestTanks={{},{},{},{},{},{}}
	for k,v in pairs(tempTanks) do
		if v and SizeOfTable(v)>0 then
			local fight=0
			if tankTb and v[3] then
				fight=v[3]
			else
				fight=tankVoApi:getBestTanksFighting(v[1],v[2])
			end
			bestTanks[k]={fight,k,v}
		else
			bestTanks[k]={}
		end
	end

    local function sortTb(a,b)
    	if a and b then
    		if a[1] and b[1] then
	    		if a[1]==b[1] then
	    			if a[2] and b[2] then
	    				return a[2]<b[2]
	    			end
	    		else
	    			return a[1]>b[1]
	    		end
	    	elseif a[2] and b[2] then
    			return a[2]<b[2]
	        end
	    end
    end
    table.sort(bestTanks,sortTb)

	for idx,tData in pairs(bestTanks) do
		if tData and SizeOfTable(tData)>0 then
			local k=tData[2]
			local v=tData[3]
			if k and v and SizeOfTable(v)>0 then
				local temHero=nil
				local temPower=0
				for m,n in pairs(heroList) do
					if self:isInQueueByHid(n.hid)==false then
						local heroPower=0
						for i,j in pairs(heroListCfg[n.hid].heroAtt) do
							heroPower=heroPower+j[1]*n.productOrder*10+j[2]*n.level*10
						end
						for i,j in pairs(n.skill) do
							local effectValue=1
							local skillCfg=heroSkillCfg[i]
							if skillCfg.conditionType then
								local cType=tonumber(skillCfg.conditionType)
								if cType==21 then 	--前排生效
									effectValue=0
									if k<=3 then
										effectValue=1
									end
								elseif cType==22 then 	--后排生效
									effectValue=0
									if k>3 then
										effectValue=1
									end
								elseif cType>=26 and cType<=29 then 	--坦克类型
									effectValue=0
									local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
									local tType=tonumber(tankCfg[id].type)
									if cType==26 then	--坦克生效
										if tType==1 then
											effectValue=1
										end
									elseif cType==27 then 	--歼击车生效
										if tType==2 then
											effectValue=1
										end
									elseif cType==28 then 	--自行火炮生效
										if tType==4 then
											effectValue=1
										end
									elseif cType==29 then 	--火箭车生效
										if tType==8 then
											effectValue=1
										end
									end
								elseif cType==34 then
									effectValue=0
									local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
									local isSpecial=tonumber(tankCfg[id].isSpecial)
									if isSpecial and isSpecial==1 then
										effectValue=1
									end
								end
							end

							heroPower=heroPower+heroSkillCfg[i].skillPower*j*effectValue
						end
						if temHero==nil then
							temHero=n
						end

						if temPower==heroPower then
							local temHid=(tonumber(temHero.hid) or tonumber(RemoveFirstChar(temHero.hid)))
							local hid=(tonumber(n.hid) or tonumber(RemoveFirstChar(n.hid)))
							if temHid>hid then
								temHero=n
								temPower=heroPower
							end
						elseif temPower<heroPower then
							temHero=n
							temPower=heroPower
						end
					end
				end

				if temHero and temHero.hid then
					tb[k]=temHero.hid
					for m,n in pairs(heroList) do
						if temHero.hid==n.hid then
							table.remove(heroList,m)
						end
					end
				end
			end
		end
	end
	-- table.sort(heroList,function(a,b) return a.heroPower>b.heroPower end)

	return tb
end



function heroVoApi:getSoulHid(sid)
	return heroCfg.soul2hero[sid]
end

function heroVoApi:getSoulSid(hid)
	return heroListCfg[hid].fusionId
end

function heroVoApi:setTroopsByTb(tb)
	if tb~=nil then
		self.troopsTb=G_clone(tb)
	end
end
function heroVoApi:setTroopsByPos(pos,hid,type)
	self.troopsTb[pos]=hid
	if type then
		if type==7 or type==8 or type==9 then
			self:setServerWarHeroByIndex(type-6,pos,hid)
		elseif type==10 then
			self:setServerWarTeamHeroByPos(pos,hid)
		elseif type==13 or type==14 or type==15 then
			self:setWorldWarHeroByIndex(type-12,pos,hid)
		elseif type==17 then
			self:setLocalWarHeroByPos(pos,hid)
		elseif type==18 then
			self:setLocalWarCurHeroByPos(pos,hid)
		elseif type==21 or type==22 or type==23 then
			self:setPlatWarHeroByIndex(type-20,pos,hid)
		elseif type==24 or type==25 or type==26 then
			self:setServerWarLocalHeroByIndex(type-23,pos,hid)
		elseif type==27 or type==28 or type==29 then
			self:setServerWarLocalCurHeroByIndex(type-26,pos,hid)
		elseif type==33 then
			self:setDimensionalWarHeroByPos(pos,hid)
		elseif type==34 then
			self:setServerWarTeamCurHeroByPos(pos,hid)
		elseif type==35 then -- 领土争夺战 防守
			ltzdzFightApi:setHeroByPos(pos,hid,type)
		elseif type==36 then -- 领土争夺战 战斗
			ltzdzFightApi:setHeroByPos(pos,hid,type)
		elseif type==38 then
			self:setChampionshipWarPersonalHeroByPos(pos,hid)
		elseif type==39 then
			self:setChampionshipWarHeroByPos(pos,hid)
		end
	end
end
function heroVoApi:deletTroopsByPos(pos,type)
	self.troopsTb[pos]=0
	if type then
		if type==7 or type==8 or type==9 then
			heroVoApi:deleteTroopsByIndex(type-6,pos)
		elseif type==10 then
			self:setServerWarTeamHeroByPos(pos,0)
		elseif type==13 or type==14 or type==15 then
			self:setWorldWarHeroByIndex(type-12,pos,0)
		elseif type==17 then
			self:setLocalWarHeroByPos(pos,0)
		elseif type==18 then
			self:setLocalWarCurHeroByPos(pos,0)
		elseif type==21 or type==22 or type==23 then
			self:setPlatWarHeroByIndex(type-20,pos,0)
		elseif type==24 or type==25 or type==26 then
			self:setServerWarLocalHeroByIndex(type-23,pos,0)
		elseif type==27 or type==28 or type==29 then
			self:setServerWarLocalCurHeroByIndex(type-26,pos,0)
		elseif type==33 then
			self:setDimensionalWarHeroByPos(pos,0)
		elseif type==34 then
			self:setServerWarTeamCurHeroByPos(pos,0)
		elseif type==35 then -- 领土争夺战 -防守
			ltzdzFightApi:setHeroByPos(pos,0,type)
		elseif type==36 then -- 领土争夺战 -进攻
			ltzdzFightApi:setHeroByPos(pos,0,type)
		elseif type==38 then
			self:setChampionshipWarPersonalHeroByPos(pos,0)
		elseif type==39 then
			self:setChampionshipWarHeroByPos(pos,0)

		end
	end
end
function heroVoApi:clearTroops()
	self.troopsTb={0,0,0,0,0,0}
end

function heroVoApi:getTroopsHeroList()
	return self.troopsTb
end

function heroVoApi:getSelectHeroList()
	local hTb = G_clone(self.heroList)
    for k,v in pairs(self.troopsTb) do
    	for i,j in pairs(hTb) do
    		if v==j.hid then
    			table.remove(hTb,i)
    			break
    		elseif v and type(v)=="string" then
	    		local hidArr=Split(v,"-")
	    		if hidArr and hidArr[1] then
	    			if hidArr[1]==j.hid then
		    			table.remove(hTb,i)
		    			break
    		end
    	end
    end
    	end
    end
    for k,v in pairs(self:allAtkHero()) do
    	for i,j in pairs(hTb) do
    		if v==j.hid then
    			table.remove(hTb,i)
    			break
    		end
    	end
    end
    return hTb
end


function heroVoApi:getRealiseSkillList(hid)
	if hid and self.realiseSkillList and self.realiseSkillList[hid] then
		return self.realiseSkillList[hid]
	else
		return {}
	end
end
function heroVoApi:setRealiseSkillList(hid,skillList)
	if hid and self.realiseSkillList then
		self.realiseSkillList[hid]={}
		if skillList then
			self.realiseSkillList[hid]=skillList
		end
	end
end

function heroVoApi:getHeroList()
    return self.heroList
end

function heroVoApi:getSoulList()
    return self.soulList
end

function heroVoApi:getHeroInfo()
    return self.info
end

function heroVoApi:getSoulNumListBySid(sid)
	local num = 0
    for k,v in pairs(self.soulList) do
    	if v.sid==sid then
    		num=v.num
    		return num
    	end
    end
    return num
end
function heroVoApi:addSoul(sid,num,hasBagData)
	local hasBagData = hasBagData or false
	if sid then
		local hid=heroCfg.soul2hero[sid]
		if hid and self:getIsHonored(hid)==true  then
			if hasBagData == false then
				local pid=heroCfg.getSkillItem
				local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
				bagVoApi:addBag(id,num)
			end
		else
			local isHave= false
			for k,v in pairs(self.soulList) do
		    	if v.sid==sid then
		    		v.num=v.num+num
		    		isHave=true

		    	end
		    end
		    if isHave== false then
		    	local vo = soulVo:new()
				vo:initWithData(sid,num)
				table.insert(self.soulList,vo)
		    	-- local tb = {sid=sid,num=num}
		    	-- table.insert(self.soulList,tb)
		    end
		end
	end
end

function heroVoApi:init(tb)
    require "luascript/script/config/gameconfig/heroFeatCfg"
	if tb~=nil then
		if tb.hero~=nil then
			self.heroList={}
			self:initHeroList(tb.hero)
		end
		if tb.soul~=nil then
			self.soulList={}
			self:initSoulList(tb.soul)
		end
		if tb.info~=nil then
			self.info={}
			self:initInfo(tb.info)
		end
		if tb.stats~=nil then
			self.stats={d={},m={},a={},w={}}
			self:initStats(tb.stats)
		end
		if(tb.feat~=nil)then
			self.currentHonorID=tb.feat[1]
			local hero=self:getCurrentHonorHero()
			if(hero)then
				if self:checkCanHonor(hero)==true then
					hero.taskID=heroFeatCfg.heroQuest[self.currentHonorID][hero.productOrder - heroFeatCfg.fusionLimit + 1][tb.feat[2]][1]
					hero.taskProceed=tonumber(tb.feat[3]) or 0	
				end
			end
		end
		if(tb.hfeats~=nil)then
			for hid,taskIndex in pairs(tb.hfeats) do
				local hero=self:getHeroByHid(hid)
				if(hero)then
					if self:checkCanHonor(hero)==true then
						if(type(taskIndex)=="table")then
							hero.taskID=heroFeatCfg.heroQuest[hid][hero.productOrder - heroFeatCfg.fusionLimit + 1][taskIndex[2]][1]
							hero.taskProceed=taskIndex[3]
						else
							hero.taskID=heroFeatCfg.heroQuest[hid][hero.productOrder - heroFeatCfg.fusionLimit + 1][taskIndex][1]
							hero.taskProceed=0
						end
					end
				end
			end
		end
		if(tb.finfo~=nil)then
			self.realiseSkillList={}
			self.realiseSkillList=tb.finfo
		end
		if tb.exp~=nil then
			self:setExp(tb.exp)
		end
		--技能重置的过期时间戳
		self.skillResetTimer = tb.skilltime
		--初始化副官数据
		heroAdjutantVoApi:initData(tb)
	end
end

function heroVoApi:setExp(exp)
	self.exp=exp
end
function heroVoApi:getExp()
	return self.exp
end

function heroVoApi:isInQueueByHid(hid)
	local isIn = false
	for k,v in pairs(heroVoApi:allAtkHero()) do
		if hid==v then
			isIn=true
		end
	end
	return isIn
end


function heroVoApi:initHeroList(tb)
	for k,v in pairs(tb) do
		local vo = heroVo:new()
		vo:initWithData(k,v)
		table.insert( self.heroList,  vo)
	end
	self.allPower = 0
	for k,v in pairs(self.heroList) do
		local sort=0
		if heroVoApi:isInQueueByHid(v.hid) then
			sort=100
		end
		local sortId = v.productOrder*100000+v.level*1000+sort+(100-tonumber(RemoveFirstChar(v.hid)))
		v.sortId=sortId

		local heroPower=0
		for i,j in pairs(heroListCfg[v.hid].heroAtt) do
			heroPower=heroPower+j[1]*v.productOrder*10+j[2]*v.level*10
		end
		for m,n in pairs(v.skill) do
			heroPower=heroPower+heroSkillCfg[m].skillPower*n
		end
		v.heroPower=heroPower
		self.allPower =self.allPower + v.heroPower
	end
	table.sort(self.heroList,function(a,b) return a.sortId>b.sortId end)
	-- for k,v in pairs(self.heroList) do
	-- 	print("aa=",k,v.heroPower)
	-- end
end

function heroVoApi:initSoulList(tb)
	for k,v in pairs(tb) do
		local vo = soulVo:new()
		vo:initWithData(k,v)
		table.insert(self.soulList,vo)
	end
end

function heroVoApi:getShowSoul()
	local tb= G_clone(self.soulList)

	for j=1,#self.heroList do
		for i=1,#tb do
			if self.heroList[j].hid==heroCfg.soul2hero[tb[i].sid] then
				table.remove(tb,i)
				break
			end
		end
	end

	-- print("~~~~~~~~~~")
	-- G_dayin(tb)
	-- print("~~~~~~~~~~~\n")
	table.sort(tb,function(a,b) return a.sortId>b.sortId end)
	
	return tb
end

function heroVoApi:initStats(tb)
	self.stats=tb
end

function heroVoApi:initInfo(tb)
	 --    "p": 4,
	 --    "pt": 1414080417,
	 --    "t": 1414079445,
	 --    "guide": 2,
	 --    "c": 2,
	 --    "pc": 2995
	self.info.commonLotteryNum=0 --c 普通已抽奖次数
	self.info.commonLotterySt=0 --t 上次普通抽奖时间
	self.info.advancedLotteryNum=0 --p 上次高级抽奖次数
	self.info.advancedLotterySt=0 --pt 上次高级抽奖时间
	self.info.advancedLotteryGold=0 --pc 上次高级抽奖金钱
	self.info.guide={0,0} --guide 已做过引导

	if tb.c~=nil then
		self.info.commonLotteryNum=tb.c
	end
	if tb.t~=nil then
		self.info.commonLotterySt=tb.t
	end
	if tb.p~=nil then
		self.info.advancedLotteryNum=tb.p
	end
	if tb.pt~=nil then
		self.info.advancedLotterySt=tb.pt
	end
	if tb.pc~=nil then
		self.info.advancedLotteryGold=tb.pc
	end
	if tb.guide~=nil then
		if type(tb.guide)=="table" then
			for k,v in pairs(tb.guide) do
				if v==1 then
					self:setHeroGuide(1,1)
				end
				if v==2 then
					self:setHeroGuide(2,1)
				end
			end
		end
	end
end


function heroVoApi:isHasFreeLottery()
	if self:isCanCommonLottery()==0 or self:getHeroGuide(1)==0 or self:isFreeAdvancedLottery()==0 or self:getHeroGuide(2)==0 then
		return true
	end
	return false
end

function heroVoApi:isCanCommonLottery()
	if self.info.commonLotterySt==nil then
		self.info.commonLotterySt=0
	end
	local lastTime=self.info.commonLotterySt
	if  G_isToday(lastTime)==false then
		if self.info.commonLotteryNum==nil or self.info.commonLotteryNum~=0 then
			self.info.commonLotteryNum=0
		end
		do return 0 end
	else
		if self.info.commonLotteryNum>=heroCfg.freeTicketLimit then
			return 1--,GetTimeStr((G_getWeeTs(lastTime)+3600*24)-base.serverTime)
		elseif base.serverTime-lastTime<heroCfg.freeTicketTime then
			if stewardVoApi and stewardVoApi:isOpen()==true then --如果军务管家功能开启就取消招募的CD功能
				return 0
			else
				return 2,GetTimeStr(heroCfg.freeTicketTime-(base.serverTime-lastTime))
			end
	    else
	    	return 0
		end
	end
end

function heroVoApi:isFreeAdvancedLottery()
	if self.info.advancedLotterySt and (base.serverTime-self.info.advancedLotterySt)<heroCfg.payTicketTime then
		return 1,GetTimeStr(heroCfg.payTicketTime-(base.serverTime-self.info.advancedLotterySt))
    else
    	return 0
	end
end

--某些将领需要做特殊处理，映射一个将领
function heroVoApi:relationHeroInfo()
	for k,v in pairs(heroCfg.heroRelation) do
		local rehid = nil
		if v[G_getCurChoseLanguage()] then
			rehid = v[G_getCurChoseLanguage()]
		end
		if rehid then
			heroListCfg[k].heroName = heroListCfg[rehid].heroName
			heroListCfg[k].heroDes = heroListCfg[rehid].heroDes
			heroListCfg[k].national = heroListCfg[rehid].national
		end
	end
end

function heroVoApi:getHeroName(hid)
	return getlocal(heroListCfg[hid].heroName)
end

function heroVoApi:getHeroDes(hid)
	return getlocal(heroListCfg[hid].heroDes)
end

function heroVoApi:getHeroNation(hid)
	return getlocal("nation_name_s"..heroListCfg[hid].national)

end



function heroVoApi:getHeroSoulName(hid)
	return getlocal("heroSoulName",{getlocal(heroListCfg[hid].heroName)})
end

function heroVoApi:getHeroIconOnly(hid)
	if hid and hid~=0 and hid~="" then

		local heroIcon=heroListCfg[hid].heroIcon
		if(heroCfg.iconMap[hid] and heroCfg.iconMap[hid][G_getCurChoseLanguage()])then
			heroIcon=heroCfg.iconMap[hid][G_getCurChoseLanguage()]
		end
		local heroImageStr ="ship/Hero_Icon/"..heroIcon
		if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
			heroImageStr ="ship/Hero_Icon_Cartoon/"..heroIcon
		end

		icon = CCSprite:create(heroImageStr)
		if icon==nil then
			icon=CCSprite:createWithSpriteFrameName("blackHero.png")
		end
		return icon
	end
end

function heroVoApi:getHeroSpeInfo(hid)

	local heroList = heroVoApi:getHeroList()
	local flag = 0
	for k,v in pairs(heroList) do
		if hid == v.hid then
			flag = 1
			return v
		end
	end
	
	if flag == 0 then
		local key = "s"..RemoveFirstChar(hid)
		local soulList = heroVoApi:getShowSoul()
		for k,v in pairs(soulList) do
			if key == v.sid then
				return v
			end
		end
	end

	-- 没有该将领魂魄显示，数量为0
	local key =  "s"..RemoveFirstChar(hid)
	local heroInfo = {sid=key,num=0}
	return heroInfo
end

--hotherData：存储将领显示的别的数据比如说副官功能数据
function heroVoApi:getHeroIcon(id,productOrder,isShowStar,callback,isGray,isShowFire,hideStarBg,hotherData)
	local function aCallback( ... )
		
	end
	if callback==nil then
		callback=aCallback
	end

	if isShowStar==nil then
		isShowStar=true
	end
	local hid=nil
	local iconBg=nil
	local imageStr = "heroHead1.png"
	local icon=CCSprite:createWithSpriteFrameName("blackHero.png")
	local bg
	if(productOrder==nil)then
		bg=LuaCCSprite:createWithSpriteFrameName("heroHeadBG1.png",callback)
	elseif(tonumber(productOrder)==2)then
		bg=LuaCCSprite:createWithSpriteFrameName("heroHeadBG.png",callback)
	else
		bg=LuaCCSprite:createWithSpriteFrameName("heroHeadBG"..productOrder..".png",callback)
	end
	if(bg==nil)then
		bg=LuaCCSprite:createWithSpriteFrameName("heroHeadBG.png",callback)
	end
	-- bg:setIsSallow(false)
	if id then
		local hType=string.sub(id,1,1)
		if hType and hType=="s" then
			hid=heroCfg.soul2hero[id]
		else
			hid=id
		end
	end
	if hid and hid~=0 and hid~="" then
		if productOrder then
			imageStr = "heroHead"..productOrder..".png"
			G_heroImage[id]=imageStr
		end
		iconBg = CCSprite:createWithSpriteFrameName(imageStr)
		local heroIcon=heroListCfg[hid].heroIcon
		if(heroCfg.iconMap[hid] and heroCfg.iconMap[hid][G_getCurChoseLanguage()])then
			heroIcon=heroCfg.iconMap[hid][G_getCurChoseLanguage()]
		end
		-- if(hid=="h41" and G_getCurChoseLanguage()=="cn")then
		-- 	heroListCfg[hid].heroIcon="hero_icon_41_cn.png"
		-- end
		local heroImageStr ="ship/Hero_Icon/"..heroIcon
		if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
			heroImageStr ="ship/Hero_Icon_Cartoon/"..heroIcon
		end


		icon = CCSprite:create(heroImageStr)
		if icon==nil then
			icon=CCSprite:createWithSpriteFrameName("blackHero.png")
		end
		if iconBg then
			iconBg:setPosition(getCenterPoint(icon))
			icon:addChild(iconBg)
		end

		local star=self:getHeroStars(productOrder)
		if star and star>0 and isShowStar==true then
			--starBg的尺寸247 × 60
			local posTb={
				{ccp(123.5,25)},
				{ccp(105.5,27.5),ccp(141.5,27.5)},
				{ccp(87.5,30),ccp(123.5,25),ccp(159.5,30)},
				{ccp(69.5,32.5),ccp(105.5,27.5),ccp(141.5,27.5),ccp(177.5,32.5)},
				{ccp(51.5,35),ccp(87.5,30),ccp(123.5,25),ccp(159.5,30),ccp(195.5,35)},
			}
			local starBg = CCSprite:createWithSpriteFrameName("heroBg.png")
			if hideStarBg == true then
				starBg:setOpacity(0)
				starBg:setPosition(ccp(icon:getContentSize().width/2,-15))
			else
				starBg:setPosition(ccp(icon:getContentSize().width/2,0))
			end
			icon:addChild(starBg,2)
			if(star<=5)then
				for i=1,star do
					local starSize=36
					local starSpace=36
					local starSp=CCSprite:createWithSpriteFrameName("StarIcon.png")
					starSp:setScale(starSize/starSp:getContentSize().width)
					starSp:setPosition(posTb[star][i])
					starBg:addChild(starSp,1)
				end
			else
				for i=1,5 do
					local starSize=36
					local starSpace=36
					local starSp
					if(i==3)then
						starSp=CCSprite:createWithSpriteFrameName("heroStar.png")
					else
						starSp=CCSprite:createWithSpriteFrameName("StarIcon.png")
					end
					starSp:setPosition(posTb[5][i])
					starBg:addChild(starSp,1)
				end
			end
		end
	else
		iconBg = CCSprite:createWithSpriteFrameName(imageStr)
		if iconBg then
			iconBg:setPosition(getCenterPoint(icon))
			icon:addChild(iconBg)
		end
	end
	icon:setPosition(getCenterPoint(bg))
	bg:addChild(icon)
	if isGray==true then
		local function tmpFunc()
      
	    end
	    local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
	    maskSp:setOpacity(255)
	    maskSp:setContentSize(bg:getContentSize())
	    maskSp:setPosition(getCenterPoint(bg))
	    bg:addChild(maskSp,5)
	end
	if icon and isShowFire==true and productOrder and tonumber(productOrder) and tonumber(productOrder)>=5 then
		local fireBg=icon
		local borderFlame1,borderFlame2,borderFlame3,borderFlame4
		if(productOrder==5)then
			borderFlame1 = CCParticleSystemQuad:create("worldWar/fireBorder.plist")
			borderFlame2 = CCParticleSystemQuad:create("worldWar/fireBorderVertical02.plist")
			borderFlame3 = CCParticleSystemQuad:create("worldWar/fireBorderVertical02.plist")
			borderFlame4 = CCParticleSystemQuad:create("worldWar/fireBorder.plist")
		else
			borderFlame1 = CCParticleSystemQuad:create("public/hero/fireBorderBlue.plist")
			borderFlame2 = CCParticleSystemQuad:create("public/hero/fireBorderV02.plist")
			borderFlame3 = CCParticleSystemQuad:create("public/hero/fireBorderV02.plist")
			borderFlame4 = CCParticleSystemQuad:create("public/hero/fireBorderBlue.plist")
		end
		borderFlame1:setScaleX(0.37)
		borderFlame1.positionType=kCCPositionTypeGrouped
		borderFlame1:setPosition(ccp(fireBg:getContentSize().width/2,fireBg:getContentSize().height-5))
		fireBg:addChild(borderFlame1)
		borderFlame2:setScaleY(1.35)
		borderFlame2.positionType=kCCPositionTypeGrouped
		borderFlame2:setPosition(ccp(10,fireBg:getContentSize().height/2))
		fireBg:addChild(borderFlame2)
		borderFlame3:setScaleY(1.35)
		borderFlame3.positionType=kCCPositionTypeGrouped
		borderFlame3:setPosition(ccp(fireBg:getContentSize().width,fireBg:getContentSize().height/2))
		fireBg:addChild(borderFlame3)
		if isShowStar~=true then
			borderFlame4:setScaleX(0.37)
			borderFlame4.positionType=kCCPositionTypeGrouped
			borderFlame4:setPosition(ccp(fireBg:getContentSize().width/2,0))
			fireBg:addChild(borderFlame4)
		end
	end
	local showAjt = true
	if hotherData and hotherData.showAjt~=nil then
		showAjt = hotherData.showAjt
	end
	if (isShowStar==true or showAjt==true) and base.adjSwitch==1 and productOrder and tonumber(productOrder)>=3 then --三阶及以上的将领会解锁副官功能故显示将领副官的图标
		if showAjt == true then
			local adjutants = {} --副官数据
			if hotherData and hotherData.adjutants then
				adjutants = hotherData.adjutants
			else
				local default = true
				if hotherData and hotherData.isDefault~=nil then
					default = hotherData.isDefault
				end
				if default == true then --默认取自己将领的副官数据
					local ajtTb = heroAdjutantVoApi:getAdjutant(id) or {}
					for k,v in pairs(ajtTb) do
						if v[3] and v[4] then
							table.insert(adjutants, {v[3],tonumber(v[4])})
						end
					end
				end
			end
			if SizeOfTable(adjutants)>0 then
				local adjutantCfg = heroAdjutantVoApi:getAdjutantCfg()
				local effectList = adjutantCfg.chainEffectList
				local adjutantLayer = CCSprite:createWithSpriteFrameName("adj_hero_ patch"..productOrder..".png")
				adjutantLayer:setAnchorPoint(ccp(0.5,0))
				adjutantLayer:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height-4)
				iconBg:addChild(adjutantLayer,3)
				local ajtCount,ajtSpaceX = SizeOfTable(adjutants),2
				local iconWidth = 24
				local firstPosX = 134/2-(ajtCount*iconWidth+(ajtCount-1)*ajtSpaceX)/2
				local ajtcfg = adjutantCfg.adjutantList
				for k, v in pairs(adjutants) do
					if v and v[1] and v[2] then
						local cfg = ajtcfg[v[1]]
						local pic = "adj_hero_cap"..cfg.quality..".png"
						--空槽
						local pointBg = CCSprite:createWithSpriteFrameName("adj_hero_capbg.png")
						pointBg:setScale(iconWidth/pointBg:getContentSize().width)
						pointBg:setAnchorPoint(ccp(0,0.5))
						pointBg:setPosition(firstPosX+(k-1)*(iconWidth+ajtSpaceX),adjutantLayer:getContentSize().height/2-7)
						adjutantLayer:addChild(pointBg)
						--副官图标
						local pointSp =CCSprite:createWithSpriteFrameName(pic)
						pointSp:setPosition(getCenterPoint(pointBg))
						pointBg:addChild(pointSp)
					end
				end
			end
		end
	end
	return bg
end

function heroVoApi:getHeroByHid(hid)
	local heroList=self:getHeroList()
	for k,v in pairs(heroList) do
		if hid and v.hid==hid then
			return v
		end
	end
	return nil
end

function heroVoApi:getSkillNeedPropIconBySid(sid,level,layerNum)
	local propsTb = heroSkillCfg[sid].breach[level].props
	local isSuccessUpdate = true
	local propsTbClone = G_clone(propsTb)
	for k,v in pairs(propsTbClone) do
		propsTbClone[k]=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(k)))
	end
	local itemTb={p=propsTbClone}
	local pTab=FormatItem(itemTb)
	local propsSpTb={}
	for k,v in pairs(pTab) do
		local icon=G_getItemIcon(v,100,true,layerNum)
		local str=bagVoApi:getItemNumId(v.id).."/"..propsTb["p"..v.id]
		local strLb=GetTTFLabel(str,22)
		strLb:setPosition(ccp(icon:getContentSize().width/2,15))
		icon:addChild(strLb)
		if bagVoApi:getItemNumId(v.id)<propsTb["p"..v.id] then
			strLb:setColor(G_ColorRed)
			isSuccessUpdate=false
		end
		table.insert(propsSpTb,icon)
	end


	return propsSpTb,isSuccessUpdate,propsTb
end

function heroVoApi:getThrouhNeedPropIconBySid(hid,productOrder,layerNum)
	local propsTb = heroListCfg[hid].throuh[productOrder].props
	local sid = heroListCfg[hid].fusionId

	local isSuccessUpdate = true
	local propsTbClone = G_clone(propsTb)
	for k,v in pairs(propsTbClone) do
		propsTbClone[k]=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(k)))
	end
	local itemTb={p=propsTbClone}
	local pTab=FormatItem(itemTb)
	local propsSpTb={}
	if(heroListCfg[hid].throuh[productOrder].soul and heroListCfg[hid].throuh[productOrder].soul[sid])then
		local throuhNum=heroListCfg[hid].throuh[productOrder].soul[sid]
		local soulNum=self:getSoulNumListBySid(sid)
		local str=soulNum.."/"..throuhNum
		local strLb=GetTTFLabel(str,30)
		if soulNum<throuhNum then
			strLb:setColor(G_ColorRed)
			isSuccessUpdate=false
		end
		local hItemTab={h={}}
		hItemTab.h[sid]=soulNum
		local hTab=FormatItem(hItemTab)
		local heroItem=hTab[1]
		local icon=G_getItemIcon(heroItem,100,true,layerNum)
		icon:addChild(strLb)
		-- icon:setScale(0.7)
		table.insert(propsSpTb,icon)
		strLb:setPosition(ccp(icon:getContentSize().width/2,15))
	end
	for k,v in pairs(pTab) do
		local icon=G_getItemIcon(v,100,true,layerNum)
		local str=bagVoApi:getItemNumId(v.id).."/"..propsTb["p"..v.id]
		local strLb=GetTTFLabel(str,22)
		strLb:setPosition(ccp(icon:getContentSize().width/2,15))
		icon:addChild(strLb)
		if bagVoApi:getItemNumId(v.id)<propsTb["p"..v.id] then
			strLb:setColor(G_ColorRed)
			isSuccessUpdate=false
		end
		table.insert(propsSpTb,icon)
	end 
	return propsSpTb,isSuccessUpdate,propsTb
end
function heroVoApi:getHeroLeftExp(heroVo)
	local exp = heroCfg.levelUP[heroVo.productOrder][heroVo.level+1]-heroVo.points+1
	local maxLv=heroCfg.heroLevel[heroVo.productOrder]
	if tonumber(heroVo.level)==tonumber(maxLv) then
		exp=exp-1
	end

	local haveExp = heroVo.points-heroCfg.levelUP[heroVo.productOrder][heroVo.level]

	local per = haveExp*100/(heroCfg.levelUP[heroVo.productOrder][heroVo.level+1]-heroCfg.levelUP[heroVo.productOrder][heroVo.level])
	return exp,per,haveExp
end
-- 一键升级  现在的经验最高能升多少级
function heroVoApi:canMaxUpLevel(heroVo,currentExp)
	local currentLv=heroVo.level
	local maxLv=heroCfg.heroLevel[heroVo.productOrder]
	local playerLv=playerVoApi:getPlayerLevel()
	if playerLv<maxLv then
		maxLv=playerLv
	end
	local upLv=0
	local oneNeedExp=0
	local allExp=0
	for i=currentLv+1,maxLv do
		local needExp = heroCfg.levelUP[heroVo.productOrder][i]-heroVo.points
		if i==currentLv+1 then
			oneNeedExp=needExp
		end
		if currentExp-needExp>=1 then
			upLv=upLv+1
			allExp=needExp
		else
			return upLv,allExp+1,oneNeedExp+1
		end
	end
	return upLv,allExp+1,oneNeedExp+1
end

-- 是否有经验书转换经验
function heroVoApi:isHaveBookChangeExp()
	local idTb=self:getHeroExpBookList()
	for k,v in pairs(idTb) do
		local num = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(v)))
		if num>0 then
			return true
		end
	end
	return false
end

--将领经验书相关道具，如果后期新增将领经验书道具则需要在列表新增
function heroVoApi:getHeroExpBookList()
	return {"p446","p447","p448","p449","p450"}
end

function heroVoApi:getAddBuffTb(heroVo)
	local tb = {}
	for k,v in pairs(heroListCfg[heroVo.hid].heroAtt) do
	    tb[k]=v[1]*heroVo.productOrder+v[2]*heroVo.level
    end
    local tb2 = {}
    for k,v in pairs(heroListCfg[heroVo.hid].heroAtt) do
	    tb2[k]=v[1]*heroVo.productOrder+v[2]*(heroVo.level+1)
    end

    return tb,tb2
end

function heroVoApi:getMaxBuffTb(heroVo)
    local maxTb = {}
    for k,v in pairs(heroListCfg[heroVo.hid].heroAtt) do
	    maxTb[k]=v[1]*heroVo.productOrder+v[2]*(heroCfg.heroLevel[heroVo.productOrder])
    end

    return maxTb
end


function heroVoApi:getHeroGuide(type)
	if self.info.guide==nil then
		self.info.guide={0,0}
	end
	if type and self.info.guide then
		return self.info.guide[type]
	end
	return 0
end
function heroVoApi:setHeroGuide(type,guide)
	if type and self.info.guide then
		self.info.guide[type]=guide
	end
end
function heroVoApi:isExistHero(hero)
	if hero and hero.hid and  self.heroList then
		for k,v in pairs(self.heroList) do
			if tostring(hero.hid)==tostring(v.hid) then
				return true
			end
		end
	end
	return false
end
function heroVoApi:getExistsHeroSoul(productOrder)
	if productOrder then
		local productOrder=tonumber(productOrder)
		if productOrder and heroCfg.fusion[productOrder] then
			return heroCfg.fusion[productOrder]/2
		end
	end
	return 0
end
function heroVoApi:getHeroStars(productOrder)
	local starNum=0
	if productOrder and tonumber(productOrder) then
		starNum=tonumber(productOrder)
	end
	return starNum
end

function heroVoApi:getNewHeroData(item,oldHeroList)
	local type
	local isHas=false
	local addNum=0
	local newProductOrder
	if item.type=="h" then
		if item.eType=="h" then
			if oldHeroList then
				for k,v in pairs(oldHeroList) do
					if item.key==v.hid then
						isHas=true
						addNum=self:getExistsHeroSoul(item.num)
						local hero=self:getHeroByHid(v.hid)
						if hero and hero.productOrder and v.productOrder then
							if hero.productOrder>v.productOrder then
								newProductOrder=hero.productOrder
							end
						end
					end
				end
			end
			type=1
		elseif item.eType=="s" then
			addNum=item.num
			type=2
		end
	end
	return type,isHas,addNum,newProductOrder
end
-- ifAwaken是否已经觉醒了，otherSid是否计算另外一个sid对应的值
--isbase ：为true时不加任何系统加成
function heroVoApi:getHeroSkillLvAndValue(hid,sid,productOrder,ifAwaken,otherSid,lv,isbase,showMax)
	local isMax = false
	local hVo = self:getHeroByHid(hid)
	local skillsCfg={}
	for k,v in pairs(heroListCfg[hid].skills) do
		if v[1]==sid then
			skillsCfg=v
			break
		end
	end
	local level
	if(lv)then
		level=lv
	else
		level = hVo.skill[sid]
		if level==nil then
			local awakenSkill=equipCfg[hid]["e1"].awaken.skill
			sid=awakenSkill[sid]	
			level = hVo.skill[sid]
		end
	end
	if ifAwaken==true then
		skillsCfg=heroListCfg[hid].skills[1]
	end
	local maxSkillLv = skillsCfg[2][productOrder]
	if heroAdjutantVoApi:isOpen() and isbase ~= true then
		local adjPorpTb, adjPropValueTb = heroAdjutantVoApi:getExtraProperty(hid, 3)
		if adjPropValueTb and adjPropValueTb["skill"] then
			maxSkillLv = maxSkillLv + adjPropValueTb["skill"]
		end
	end
	if showMax == true then
		level = maxSkillLv
	end
	local lvStr = G_LV()..level.."/"..maxSkillLv
	if level==0 then
		level=1
		lvStr=G_LV()..level
	end
	
	local valueStr,sv
	if type(heroSkillCfg[sid].attType) == "table" then
		for k, v in pairs(heroSkillCfg[sid].attType) do
			local value = level*heroSkillCfg[sid].attValuePerLv[k]*100
			if (ifAwaken==true or ifAwaken==false) and otherSid then
				local oldValue = level*heroSkillCfg[otherSid].attValuePerLv[k]*100
				value=ifAwaken and (value-oldValue) or (oldValue-value)
			end
			if valueStr == nil then
				valueStr = {}
				sv = {}
			end
			valueStr[k]=value.."%%"
			sv[k] = value
			if v=="antifirst" or v=="first" then
				valueStr[k]=value/100
				sv[k] = value/100
			end
		end
	else
		local value=level*heroSkillCfg[sid].attValuePerLv*100
		if (ifAwaken==true or ifAwaken==false) and otherSid then
			local oldValue = level*heroSkillCfg[otherSid].attValuePerLv*100
			value=ifAwaken and (value-oldValue) or (oldValue-value)
		end
		valueStr=value.."%%"
		sv = value
		if heroSkillCfg[sid].attType=="antifirst" or heroSkillCfg[sid].attType=="first" then
			valueStr=value/100
			sv = value/100
		end
	end
	if hVo and hVo.skill[sid] and hVo.skill[sid]>=maxSkillLv then
		isMax=true
	end
	return lvStr,valueStr,isMax,level,sv
end

function heroVoApi:isHeroMaxLv(hid,productOrder,heroVo)
	local isMax = false
	local hVo
	if heroVo then
		hVo = heroVo
	else
		hVo = self:getHeroByHid(hid)
	end
	local maxLevel =heroCfg.heroLevel[productOrder]
	if hVo.level>=maxLevel then
		isMax=true
	end
	return isMax
end
function heroVoApi:getSkillIconBySid(sid)
	local nameStr="ship/heroskillImage/"..heroSkillCfg[sid].icon
	G_heroImage[sid]=nameStr
	return nameStr
end

--检查英雄是否可以授勋
--param heroVo: 英雄的数据
--return true or false
function heroVoApi:checkCanHonor(heroVo)
	if(heroVo.level>=heroFeatCfg.levelLimit and heroVoApi:getHeroStars(heroVo.productOrder)==heroFeatCfg.fusionLimit)then
		return true
	else
		if(heroVoApi:heroHonor2IsOpen())then
			if(heroVo.level>=heroFeatCfg.levelLimit2[1] and heroVoApi:getHeroStars(heroVo.productOrder)==heroFeatCfg.fusionLimit2[1])then
				return true
			end
		end
		return false
	end
end

--检查英雄是否已经授勋
--param heroVo: 英雄的数据
--return true or false
function heroVoApi:checkHonored(heroVo)
	local star=heroVoApi:getHeroStars(heroVo.productOrder)
	if(star==heroFeatCfg.fusionLimit + 1)then
		return true
	else
		if(heroVoApi:heroHonor2IsOpen())then
			if(star==heroFeatCfg.fusionLimit2[1] + 1)then
				return true
			end
		end
		return false
	end
end

--获取当前版本的将领最大品阶
function heroVoApi:getHeroMaxProduct()
	if(heroVoApi:heroHonor2IsOpen())then
		return 6
	elseif(heroVoApi:heroHonorIsOpen())then
		return 5
	else
		local unlockThroughLevel=playerVoApi:getMaxLvByKey("unlockThroughLevel")
		if(unlockThroughLevel==nil)then
			unlockThroughLevel=1
		end
		return math.min(unlockThroughLevel,4)
	end
end

--获取可以授勋的英雄列表
--return 一个table, 里面是所有可以授勋的英雄数据
function heroVoApi:getCanHonorHeroList()
	local result={}
	for k,v in pairs(self.heroList) do
		if(heroVoApi:checkCanHonor(v))then
			table.insert(result,v)
		end
	end
	return result
end

--获取已经授勋的英雄列表
--return 一个table, 里面是所有已授勋的英雄数据
function heroVoApi:getHonoredHeroList()
	local result={}
	for k,v in pairs(self.heroList) do
		if(heroVoApi:checkHonored(v))then
			table.insert(result,v)
		end
	end
	return result
end

--获取该英雄是否已经授勋
function heroVoApi:getIsHonored(hid)
	local isHonored=false
	if hid then
		local honoredHeroList=self:getHonoredHeroList()
		if honoredHeroList then
			for k,v in pairs(honoredHeroList) do
				if v and v.hid==hid then
					isHonored=true
				end
			end
		end
	end
	return isHonored
end

--获取当前正在觉醒的英雄vo
function heroVoApi:getCurrentHonorHero()
	if(self.currentHonorID)then
		for k,v in pairs(self.heroList) do
			if(v.hid==self.currentHonorID)then
				return v
			end
		end
	end
	return nil
end

--弹出将领授勋详情的面板
--param hero: 将领的数据vo
function heroVoApi:showHonorTaskDialog(hero,layerNum)
	require "luascript/script/game/scene/gamedialog/heroDialog/heroHonorTaskDialog"
	local dialog=heroHonorTaskDialog:new(hero)
	local dialogBg=dialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("hero_honor_title"),true,layerNum)
	sceneGame:addChild(dialogBg,layerNum)
end

--将领授勋: 接受授勋任务
--param hid: 要开始授勋任务的将领id
function heroVoApi:acceptHonorTask(hid,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			eventDispatcher:dispatchEvent("hero.honor",{type="accept",hid=hid})
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:heroHonorAccept(hid,onRequestEnd)
end

function heroVoApi:dropHonorTask(hid,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if(ret==true)then
			self.currentHonorID=nil
			eventDispatcher:dispatchEvent("hero.honor",{type="cancel",hid=hid})
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:heroHonorCancel(hid,onRequestEnd)
end

--将领授勋: 执行授勋, 分分钟从SB变NB
--param hid: 要授勋的英雄ID
function heroVoApi:wakeUp(hid,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			eventDispatcher:dispatchEvent("hero.honor",{type="success",hid=hid})
			if(callback)then
				callback()
			end
			G_SyncData()
		end
	end
	socketHelper:heroHonorWakeUp(hid,onRequestEnd)
end

----------以下跨服战英雄信息----------
--跨服战某一场英雄信息
function heroVoApi:getServerWarHeroList(index)
	if index and self["serverWarTroop"..index] then
		return self["serverWarTroop"..index]
	end
	return {0,0,0,0,0,0}
end
--跨服战某一场设置英雄
function heroVoApi:setServerWarHeroList(index,heroList)
	if index then
		self["serverWarTroop"..index]={0,0,0,0,0,0}
		if heroList then
			for k,v in pairs(heroList) do
				if v then
					self["serverWarTroop"..index][k]=v
				end
			end
		end
	end
end
--跨服战某一场设置英雄
function heroVoApi:setServerWarHeroByIndex(index,pos,hid)
	if index then
		if pos and self["serverWarTroop"..index] then
			self["serverWarTroop"..index][pos]=hid
		end
	end
end
--跨服战某一场可以设置的英雄
function heroVoApi:getCanSetHeroList()
	local heroList=self:getSelectHeroList()
	for i=1,3 do
		for k,v in pairs(self["serverWarTroop"..i]) do
			for m,n in pairs(heroList) do
				if v~=0 and n.hid and v==n.hid then
					table.remove(heroList,m)
				end
			end
		end
	end
	return heroList
end

function heroVoApi:isHaveCanFightHeroInExpedition()
	local isHave = false
	if SizeOfTable(self:getCanSetBestHeroListExpedition())>0 then
		isHave = true
	end
	return isHave
end

function heroVoApi:getBestHeroListExpedition()
	local herotb = G_clone(self.heroList)

	for k,v in pairs(expeditionVoApi:getDeadHero()) do
		for i=1,#herotb do
			if herotb[i].hid==v then
				table.remove(herotb, i)
				break
			end
		end
	end
	return herotb

end
function heroVoApi:getCanSetBestHeroListExpedition()
	local herotb = G_clone(self:getSelectHeroList())

	for k,v in pairs(expeditionVoApi:getDeadHero()) do
		for i=1,#herotb do
			if herotb[i].hid==v then
				table.remove(herotb, i)
				break
			end
		end
	end

	return herotb
end
--跨服战某一场最大战力推荐英雄时可以设置的英雄
function heroVoApi:getCanSetBestHeroList(heroList,index)
	if heroList then
		for i=1,3 do
			if index~=i then
				for k,v in pairs(self["serverWarTroop"..i]) do
					for m,n in pairs(heroList) do
						if v~=0 and n.hid and v==n.hid then
							table.remove(heroList,m)
						end
					end
				end
			end
		end
	end
	return heroList
end
--清空跨服战某一场的英雄设置
function heroVoApi:deleteTroopsByIndex(index,pos)
	if index then
		if pos and self["serverWarTroop"..index] then
			self["serverWarTroop"..index][pos]=0
		else
			self["serverWarTroop"..index]={0,0,0,0,0,0}
		end
	end
end
--清空跨服战英雄设置
function heroVoApi:clearServerWarTroops()
	self.serverWarTroop1={0,0,0,0,0,0}
	self.serverWarTroop2={0,0,0,0,0,0}
	self.serverWarTroop3={0,0,0,0,0,0}
end
----------以上跨服战英雄信息----------

--发送请求时，没有部队不设置英雄
--isSetTroops 不设置troops,只检测英雄是否对应有部队，不在设置部队发请求时使用
function heroVoApi:getBindFleetHeroList(heroList,tb,type,isSetTroops)
	if isSetTroops==nil then
		isSetTroops=true
	end
	if isSetTroops==true then
		for k,v in pairs(heroList) do
			if SizeOfTable(tb[k])==0 then
				self:setTroopsByPos(k,0,type)
			end
		end
		return heroList
	else
		local list=G_clone(heroList)
		for k,v in pairs(list) do
			if SizeOfTable(tb[k])==0 then
				list[k]=0 
			end
		end
		return list
	end
end

----------以下军团跨服战英雄信息----------
--清空军团跨服战英雄设置
function heroVoApi:clearServerWarTeamTroops()
	self.serverWarTeamTroops={0,0,0,0,0,0}
end
--军团跨服战英雄信息
function heroVoApi:getServerWarTeamHeroList()
	if self.serverWarTeamTroops then
		return self.serverWarTeamTroops
	end
	return {0,0,0,0,0,0}
end
--军团跨服战设置英雄
function heroVoApi:setServerWarTeamHeroList(heroList)
	if heroList then
		for k,v in pairs(heroList) do
			if v and (type(v)=="string" or type(v)=="number") then
				self.serverWarTeamTroops[k]=v
			else
				self.serverWarTeamTroops[k]=0
			end
		end
	end
end
--军团跨服战某一个位置设置英雄
function heroVoApi:setServerWarTeamHeroByPos(pos,hid)
	if pos and self.serverWarTeamTroops then
		self.serverWarTeamTroops[pos]=hid
	else
		self.serverWarTeamTroops={0,0,0,0,0,0}
	end
end

--清空军团跨服战当前英雄设置
function heroVoApi:clearServerWarTeamCurTroops()
	self.serverWarTeamCurTroops={0,0,0,0,0,0}
end
--军团跨服战当前英雄信息
function heroVoApi:getServerWarTeamCurHeroList()
	if self.serverWarTeamCurTroops then
		return self.serverWarTeamCurTroops
	end
	return {0,0,0,0,0,0}
end
--军团跨服战设置当前英雄
function heroVoApi:setServerWarTeamCurHeroList(heroList)
	if heroList then
		for k,v in pairs(heroList) do
			if v and (type(v)=="string" or type(v)=="number") then
				self.serverWarTeamCurTroops[k]=v
			else
				self.serverWarTeamCurTroops[k]=0
			end
		end
	end
end
--军团跨服战某一个位置设置当前英雄
function heroVoApi:setServerWarTeamCurHeroByPos(pos,hid)
	if pos and self.serverWarTeamCurTroops then
		self.serverWarTeamCurTroops[pos]=hid
	else
		self.serverWarTeamCurTroops={0,0,0,0,0,0}
	end
end


----------以上军团跨服战英雄信息----------
function heroVoApi:getNewHeroChat(hid)
	if hid then
		local heroList=heroVoApi:getHeroList()
		for k,v in pairs(heroList) do
			if v and v.hid and v.hid==hid then
				if v.productOrder and v.productOrder>=2 then
					local star=self:getHeroStars(v.productOrder)
					local name=self:getHeroName(v.hid)
	                local message={key="conGetNewHero",param={playerVoApi:getPlayerName(),star,name}}
	                chatVoApi:sendSystemMessage(message)
	            end
			end
		end
	end
end

----------以下世界争霸英雄信息----------
--世界争霸某一场英雄信息
function heroVoApi:getWorldWarHeroList(index)
	if index and self["worldWarTroop"..index] then
		return self["worldWarTroop"..index]
	end
	return {0,0,0,0,0,0}
end
--世界争霸某一场设置英雄
function heroVoApi:setWorldWarHeroList(index,heroList)
	if index then
		self["worldWarTroop"..index]={0,0,0,0,0,0}
		if heroList then
			for k,v in pairs(heroList) do
				if v then
					self["worldWarTroop"..index][k]=v
				end
			end
		end
	end
end
--世界争霸某一场设置英雄
function heroVoApi:setWorldWarHeroByIndex(index,pos,hid)
	if index then
		if pos and self["worldWarTroop"..index] then
			self["worldWarTroop"..index][pos]=hid
		end
	end
end
--世界争霸某一场可以设置的英雄
function heroVoApi:getWorldWarCanSetHeroList()
	local heroList=self:getSelectHeroList()
	for i=1,3 do
		for k,v in pairs(self["worldWarTroop"..i]) do
			for m,n in pairs(heroList) do
				if v~=0 and n.hid and v==n.hid then
					table.remove(heroList,m)
				end
			end
		end
	end
	return heroList
end

--世界争霸某一场最大战力推荐英雄时可以设置的英雄
function heroVoApi:getWorldWarCanSetBestHeroList(heroList,index)
	if heroList then
		for i=1,3 do
			if index~=i then
				for k,v in pairs(self["worldWarTroop"..i]) do
					for m,n in pairs(heroList) do
						if v~=0 and n.hid and v==n.hid then
							table.remove(heroList,m)
						end
					end
				end
			end
		end
	end
	return heroList
end
--清空世界争霸某一场的英雄设置
function heroVoApi:deleteWorldWarTroopsByIndex(index,pos)
	if index then
		if pos and self["worldWarTroop"..index] then
			self["worldWarTroop"..index][pos]=0
		else
			self["worldWarTroop"..index]={0,0,0,0,0,0}
		end
	end
end
--清空世界争霸英雄设置
function heroVoApi:clearWorldWarTroops()
    self.worldWarTroop1={0,0,0,0,0,0}
    self.worldWarTroop2={0,0,0,0,0,0}
    self.worldWarTroop3={0,0,0,0,0,0}
end
--英雄是否完全一样
function heroVoApi:isSameHero(hero1,hero2)
	local isSame=true
	if hero1 and hero2 then
		for k,v in pairs(hero1) do
			-- if hero2[k]==nil or hero2[k]~=v then
			-- 	isSame=false
			-- end
			-- print("hero2[k],v",hero2[k],v)
			if hero2[k]==nil then
				isSame=false
			elseif hero2[k]~=v then
				if type(v)=="string" then
					local heroArr=Split(v,"-")
					if heroArr and heroArr[1] and heroArr[2] and heroArr[3] then
						local hid,productOrder,level=heroArr[1],tonumber(heroArr[2]),tonumber(heroArr[3])
						if hero2[k]==hid then
							local hvo=self:getHeroByHid(hid)
							-- print("hid,productOrder,level",hid,productOrder,level)
							-- print("hvo.hid,hvo.productOrder,hvo.level",hvo.hid,hvo.productOrder,hvo.level)
							if hvo==nil then
								isSame=false
							elseif hvo and (hvo.hid~=hid or hvo.productOrder~=productOrder or hvo.level~=level) then
								isSame=false
			end
						else
							isSame=false
		end
					else
						isSame=false
	end
				else
					isSame=false
				end
			end
		end
		-- print("isSame",isSame)
	end
	return isSame
end

----------以上世界争霸英雄信息----------

----------以下将领领悟----------
function heroVoApi:getHeroHonorSkillLvAndValue(hid,sid,productOrder,lv)
	local isMax = false
	local hVo = self:getHeroByHid(hid)
	local level=0
	if(lv)then
		level=lv
	else
		local skillList=hVo.honorSkill
		for k,v in pairs(skillList) do
			if v and v[1] and v[2] then
				if sid==v[1] then
					level=v[2]
	    		end
    		end
    	end
    end
	local maxLv = self:getSkillMaxLevel(hid)
	if level==0 then
		level=1
    end
	local lvStr = G_LV()..level--.."/"..maxLv
	if level>=maxLv then
		isMax=true
    end
	
	local valueStr,sv
	if type(heroSkillCfg[sid].attType) == "table" then
		for k, v in pairs(heroSkillCfg[sid].attType) do
			local value = level * heroSkillCfg[sid].attValuePerLv[k]*100
			if valueStr == nil then
				valueStr = {}
				sv = {}
			end
			valueStr[k] = value .. "%%"
			sv[k] = value
			if v=="antifirst" or v=="first" then
				valueStr[k] = value / 100
				sv[k] = value / 100
			end
		end
	else
		local value=level*heroSkillCfg[sid].attValuePerLv*100
		valueStr=value.."%%"
		sv = value
		if heroSkillCfg[sid].attType=="antifirst" or heroSkillCfg[sid].attType=="first" then
			valueStr=value/100
			sv = value / 100
	    end
	end

	return lvStr,valueStr,isMax,level,sv
end

--获取英雄资质等级和对应的字母等级和颜色 realiseNum 领悟次数
function heroVoApi:getQualityLevel(realiseNum)
	local qualityLevel,qualityStr,color=0,"",G_ColorWhite
	if realiseNum and heroFeatCfg then
		if heroFeatCfg.aptitude then
			for k,v in pairs(heroFeatCfg.aptitude) do
				if realiseNum>=v then
					qualityLevel=k-1
				end
			end
		end
		if qualityLevel and heroFeatCfg.qualificationLevel and heroFeatCfg.qualificationLevel[qualityLevel+1] then
			local levelTab=heroFeatCfg.qualificationLevel[qualityLevel+1]
			if levelTab and SizeOfTable(levelTab)>0 then
				qualityStr=levelTab[1]
				color=self:getQualityLevelColor(levelTab[2])
			end
		end
	end
	return qualityLevel,qualityStr,color
end

--获取英雄资质等级对应的颜色
function heroVoApi:getQualityLevelColor(colorType)
	local color=G_ColorWhite
	if colorType then
		if colorType==1 then
			color=G_ColorWhite
		elseif colorType==2 then
			color=G_ColorGreen
		elseif colorType==3 then
			color=G_ColorBlue
		elseif colorType==4 then
			color=G_ColorPurple
		elseif colorType==5 then
			color=G_ColorOrange
		elseif colorType==6 then
			color=G_ColorYellowPro
		end
	end
	return color
end

--获取英雄领悟的技能最大等级 配置的skillLevelLimit-10+英雄资质等级(根据领悟次数取配置)
function heroVoApi:getSkillMaxLevel(hid)
	local skillMaxLevel=25
	local isLevelMax=false
	if hid and heroListCfg[hid] and heroListCfg[hid].skillLevelLimit then
		local maxLevel=heroListCfg[hid].skillLevelLimit
		if heroAdjutantVoApi:isOpen() then
			local adjPorpTb, adjPropValueTb = heroAdjutantVoApi:getExtraProperty(hid, 2)
			if adjPropValueTb and adjPropValueTb["exploit"] then
				maxLevel = maxLevel + adjPropValueTb["exploit"]
			end
		end
		skillMaxLevel=maxLevel-10
		local heroVo=self:getHeroByHid(hid)
		if heroVo and heroVo.realiseNum then
			local qualityLevel=self:getQualityLevel(heroVo.realiseNum)
			skillMaxLevel=skillMaxLevel+qualityLevel
			if skillMaxLevel>=maxLevel then
				isLevelMax=true
			end
		end
	end
	return skillMaxLevel,isLevelMax
end

--获取领悟技能的索引
function heroVoApi:getHonorSidIndex(hid,sid)
	local realiseSkillList=self:getRealiseSkillList(hid)
	if hid and sid then
		for k,v in pairs(realiseSkillList) do
			for m,n in pairs(v) do
				if m==sid then
					return k
				end
			end
		end
	end
    return 0
end

--领悟
function heroVoApi:realiseSkillUpdate(hid,realiseID,skillTab)
    self:setRealiseSkillList(hid,skillTab)
	if self.heroList and hid then
		for k,v in pairs(self.heroList) do
			if hid and v.hid==hid then
				v.realiseID=realiseID
				v.realiseNum=v.realiseNum+1
			end
		end
	end
end

--获取已经使用领悟技能
--如果传了heroVo就取heroVo的领悟技能
function heroVoApi:getUsedRealiseSkill(hid,heroVo)
	if heroVo then
		return heroVo.honorSkill or {}
	end
	if hid then
		local heroList=self:getHeroList()
		if heroList and SizeOfTable(heroList)>0 then
			for k,v in pairs(heroList) do
				if v and v.hid==hid and v.honorSkill and #v.honorSkill>0 then
					return v.honorSkill
				end
			end
		end
	end
	return {}
end

--根据hid获取领悟消耗金币
function heroVoApi:getGemCost(hid)
	local gemCost=0
	if heroFeatCfg and heroFeatCfg.gemCost and heroFeatCfg.gemCost[1] then
		gemCost=heroFeatCfg.gemCost[1]
			end
	local hero=self:getHeroByHid(hid)
	if hero and hero.realiseNum then
		local rNum=hero.realiseNum+1
		if rNum>SizeOfTable(heroFeatCfg.gemCost) then
			rNum=SizeOfTable(heroFeatCfg.gemCost)
		end
		gemCost=heroFeatCfg.gemCost[rNum]
	end
	return gemCost
end
--根据hid获取领悟道具
function heroVoApi:getPropItem(hid)
	local propItem
	local propCost
	if heroFeatCfg and heroFeatCfg.propCost and heroFeatCfg.propCost[1] then
		propCost=heroFeatCfg.propCost[1]
	end
	local hero=self:getHeroByHid(hid)
	if hero and hero.realiseNum then
		local rNum=hero.realiseNum+1
		if rNum>SizeOfTable(heroFeatCfg.propCost) then
			rNum=SizeOfTable(heroFeatCfg.propCost)
		end
		propCost=heroFeatCfg.propCost[rNum]
	end
	if propCost then
		local propItemTab=FormatItem(propCost)
		if propItemTab and propItemTab[1] then
			propItem=propItemTab[1]
		end
	end
	return propItem
end

--根据技能等级获取技能的颜色
--param lv: 技能的等级
--return: 一个ccc3颜色
function heroVoApi:getSkillColorByLv(level)
	local colorIndex
	-- print("level====?",level,SizeOfTable(heroCfg.skillLvColor))
	if(heroCfg.skillLvColor[level])then
		colorIndex=heroCfg.skillLvColor[level]
	end
	-- print("colorIndex-->",colorIndex)
	if(colorIndex>=6)then
		return G_ColorYellowPro
	elseif(colorIndex==5)then
		return G_ColorOrange
	elseif(colorIndex==4)then
		return G_ColorPurple
	elseif(colorIndex==3)then
		return G_ColorBlue
	elseif(colorIndex==2)then
		return G_ColorGreen
	else
		return G_ColorWhite
	end
end

--处理后台推送
function heroVoApi:dealWithServerPush(type,data)
	if(type=="feat")then
		self.currentHonorID=data[1]
		local hero=self:getCurrentHonorHero()
		if(hero)then
			local tip
			local taskIndex=tonumber(data[2])
			local taskProceed=tonumber(data[3])
			hero.taskID=heroFeatCfg.heroQuest[self.currentHonorID][hero.productOrder - heroFeatCfg.fusionLimit + 1][taskIndex][1]
			hero.taskProceed=taskProceed or 0
			local delayShow,showTaskID
			if(taskProceed==0 and taskIndex>1)then
				tip=getlocal("hero_honor_completeTip",{taskIndex - 1})
				showTaskID=heroFeatCfg.heroQuest[self.currentHonorID][hero.productOrder - heroFeatCfg.fusionLimit + 1][taskIndex - 1][1]
			else
				showTaskID=hero.taskID
				local maxProceed=heroFeatCfg.heroQuest[self.currentHonorID][hero.productOrder - heroFeatCfg.fusionLimit + 1][taskIndex][2]
				if(taskProceed>=maxProceed)then
					tip=getlocal("hero_honor_completeTip",{taskIndex})
				else
					if(showTaskID=="t9")then
						local proceedStr,totalStr
						if(taskProceed==nil or taskProceed==0)then
							proceedStr=heroFeatCfg.qualificationLevel[1][1] or 0
						else
							proceedStr=heroFeatCfg.qualificationLevel[taskProceed][1] or 0
						end
						totalStr=heroFeatCfg.qualificationLevel[maxProceed][1] or 0
						tip=getlocal("hero_honor_proceedTip",{proceedStr,totalStr})
					else
						tip=getlocal("hero_honor_proceedTip",{taskProceed,maxProceed})
					end
				end
			end
			--2347的任务都是要求胜利后才算进度, 所以要延迟显示tip, 其他的任务都是当时显示tip即可
			if(showTaskID=="t2" or showTaskID=="t3" or showTaskID=="t4" or showTaskID=="t7" or showTaskID=="t14")then
				local function showTipListener(event,data)
					eventDispatcher:removeEventListener("battle.close",heroVoApi.showTipListener)
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tip,30)
				end
				if(heroVoApi.showTipListener)then
					eventDispatcher:removeEventListener("battle.close",heroVoApi.showTipListener)
				end
				heroVoApi.showTipListener=showTipListener
				eventDispatcher:addEventListener("battle.close",heroVoApi.showTipListener)
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tip,30)
			end
			eventDispatcher:dispatchEvent("hero.honor",{type="update"})
		end
	end
end
--打开将领领悟界面
function heroVoApi:showHeroRealiseDialog(hero,layerNum,parent)
	require "luascript/script/game/scene/gamedialog/heroDialog/heroRealiseDialog"
	local td=heroRealiseDialog:new(hero,layerNum,parent)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("hero_honor_realise"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--将领技能描述的小面板
function heroVoApi:showHeroSkillDescDialog(hid,sid,productOrder,skillLv,isHonorSkill,layerNum)
	require "luascript/script/game/scene/gamedialog/heroDialog/heroSkillDescDialog"
	local sd=heroSkillDescDialog:new(hid,sid,productOrder,skillLv,isHonorSkill)
	sd:init(layerNum)
end

--是否开放将领授勋
function heroVoApi:heroHonorIsOpen()
	local unlockThroughLevel=playerVoApi:getMaxLvByKey("unlockThroughLevel")
	if base.herofeat and base.herofeat==1 and unlockThroughLevel and unlockThroughLevel>=5 then
		return true
	else
		return false
	end
end

--是否开放将领二次授勋
function heroVoApi:heroHonor2IsOpen()
	local unlockThroughLevel=playerVoApi:getMaxLvByKey("unlockThroughLevel")
	if base.herofeat==1 and base.herofeat2==1 and unlockThroughLevel and unlockThroughLevel>=5 then
		return true
	else
		return false
	end
end

----------以上将领领悟----------

----------以下区域战将领----------
--清空区域战英雄设置
function heroVoApi:clearLocalWarTroops()
	self.localWarTroops={0,0,0,0,0,0}
end
function heroVoApi:clearLocalWarCurTroops()
	self.localWarCurTroops={0,0,0,0,0,0}
end
--军团区域战英雄信息
function heroVoApi:getLocalWarHeroList()
	if self.localWarTroops then
		return self.localWarTroops
	end
	return {0,0,0,0,0,0}
end
--军团区域战当前英雄信息
function heroVoApi:getLocalWarCurHeroList()
	if self.localWarCurTroops then
		return self.localWarCurTroops
	end
	return {0,0,0,0,0,0}
end
--军团区域战设置英雄
function heroVoApi:setLocalWarHeroList(heroList)
	if heroList then
		for k,v in pairs(heroList) do
			if v and (type(v)=="string" or type(v)=="number") then
				self.localWarTroops[k]=v
			else
				self.localWarTroops[k]=0
			end
		end
	end
end
--军团区域战设置当前英雄
function heroVoApi:setLocalWarCurHeroList(heroList)
	if heroList then
		for k,v in pairs(heroList) do
			if v and (type(v)=="string" or type(v)=="number") then
				self.localWarCurTroops[k]=v
			else
				self.localWarCurTroops[k]=0
			end
		end
	end
end
--区域战某一个位置设置英雄
function heroVoApi:setLocalWarHeroByPos(pos,hid)
	if pos and self.localWarTroops then
		self.localWarTroops[pos]=hid
	else
		self.localWarTroops={0,0,0,0,0,0}
	end
end
--区域战当前某一个位置设置英雄
function heroVoApi:setLocalWarCurHeroByPos(pos,hid)
	if pos and self.localWarCurTroops then
		self.localWarCurTroops[pos]=hid
	else
		self.localWarCurTroops={0,0,0,0,0,0}
	end
end

----------以上区域战将领----------

----------以下超级武器英雄将领----------
-- --清空超级武器攻击部队英雄设置
-- function heroVoApi:clearSWAttackTroops()
-- 	self.swAttackTroops={0,0,0,0,0,0}
-- end
-- --超级武器攻击部队英雄信息
-- function heroVoApi:getSWAttackHeroList()
-- 	if self.swAttackTroops then
-- 		return self.swAttackTroops
-- 	end
-- 	return {0,0,0,0,0,0}
-- end
-- --超级武器攻击部队设置英雄
-- function heroVoApi:setSWAttackHeroList(heroList)
-- 	if heroList then
-- 		for k,v in pairs(heroList) do
-- 			if v and (type(v)=="string" or type(v)=="number") then
-- 				self.swAttackTroops[k]=v
-- 			else
-- 				self.swAttackTroops[k]=0
-- 			end
-- 		end
-- 	end
-- end
-- --超级武器攻击部队某一个位置设置英雄
-- function heroVoApi:setSWAttackHeroByPos(pos,hid)
-- 	if pos and self.swAttackTroops then
-- 		self.swAttackTroops[pos]=hid
-- 	else
-- 		self.swAttackTroops={0,0,0,0,0,0}
-- 	end
-- end

--清空超级武器防守部队英雄设置
function heroVoApi:clearSWDefenceTroops()
	self.swDefenceTroops={0,0,0,0,0,0}
end
--超级武器防守部队英雄信息
function heroVoApi:getSWDefenceHeroList()
	if self.stats.w~=nil and SizeOfTable(self.stats.w)>0 then
		self.swDefenceTroops=self.stats.w[1]
	end
	if self.swDefenceTroops then
		return self.swDefenceTroops
	end
	return {0,0,0,0,0,0}
end
--超级武器防守部队设置英雄
function heroVoApi:setSWDefenceHeroList(heroList)
	if heroList then
		if self.stats.w==nil then
			self.stats.w={}
		end
		if self.stats.w[1]==nil then
			self.stats.w[1]={}
		end
		for k,v in pairs(heroList) do
			if v and (type(v)=="string" or type(v)=="number") then
				self.swDefenceTroops[k]=v
				self.stats.w[1][k]=v
			else
				self.swDefenceTroops[k]=0
				self.stats.w[1][k]=0
			end
		end
	end
end
--超级武器防守部队某一个位置设置英雄
function heroVoApi:setSWDefenceHeroByPos(pos,hid)
	if self.stats.w==nil or SizeOfTable(self.stats.w)==0 then
		self.stats.w={}
		self.stats.w[1]={0,0,0,0,0,0}
	end
	if pos and self.swDefenceTroops then
		self.swDefenceTroops[pos]=hid
		self.stats.w[1][pos]=hid
	else
		self.swDefenceTroops={0,0,0,0,0,0}
		self.stats.w[1]={0,0,0,0,0,0}
	end
end

----------以上超级武器英雄将领----------


----------以下平台战英雄信息----------
--平台战某一场英雄信息
function heroVoApi:getPlatWarHeroList(index)
	if index and self["platWarTroop"..index] then
		return self["platWarTroop"..index]
	end
	return {0,0,0,0,0,0}
end
--平台战某一场设置英雄
function heroVoApi:setPlatWarHeroList(index,heroList)
	if index then
		self["platWarTroop"..index]={0,0,0,0,0,0}
		if heroList then
			for k,v in pairs(heroList) do
				if v then
					self["platWarTroop"..index][k]=v
				end
			end
		end
	end
end
--平台战某一场设置英雄
function heroVoApi:setPlatWarHeroByIndex(index,pos,hid)
	if index then
		if pos and self["platWarTroop"..index] then
			self["platWarTroop"..index][pos]=hid
		end
	end
end
--平台战某一场可以设置的英雄
function heroVoApi:getPlatWarCanSetHeroList()
	local heroList=self:getSelectHeroList()
	for i=1,3 do
		for k,v in pairs(self["platWarTroop"..i]) do
			for m,n in pairs(heroList) do
				if v~=0 and n.hid and v==n.hid then
					table.remove(heroList,m)
				end
			end
		end
	end
	return heroList
end

--平台战某一场最大战力推荐英雄时可以设置的英雄
function heroVoApi:getPlatWarCanSetBestHeroList(heroList,index)
	if heroList then
		for i=1,3 do
			if index~=i then
				for k,v in pairs(self["platWarTroop"..i]) do
					for m,n in pairs(heroList) do
						if v~=0 and n.hid and v==n.hid then
							table.remove(heroList,m)
						end
					end
				end
			end
		end
	end
	return heroList
end
--清空平台战某一场的英雄设置
function heroVoApi:deletePlatWarTroopsByIndex(index,pos)
	if index then
		if pos and self["platWarTroop"..index] then
			self["platWarTroop"..index][pos]=0
		else
			self["platWarTroop"..index]={0,0,0,0,0,0}
		end
	end
end
--清空平台战英雄设置
function heroVoApi:clearPlatWarTroops()
    self.platWarTroop1={0,0,0,0,0,0}
    self.platWarTroop2={0,0,0,0,0,0}
    self.platWarTroop3={0,0,0,0,0,0}
end

----------以上平台战英雄信息----------


----------以下群雄争霸英雄信息----------
--某一场英雄信息
function heroVoApi:getServerWarLocalHeroList(index)
	if index and self["serverWarLocalTroop"..index] then
		return self["serverWarLocalTroop"..index]
	end
	return {0,0,0,0,0,0}
end
--某一场设置英雄
function heroVoApi:setServerWarLocalHeroList(index,heroList)
	if index then
		self["serverWarLocalTroop"..index]={0,0,0,0,0,0}
		if heroList then
			for k,v in pairs(heroList) do
				if v then
					self["serverWarLocalTroop"..index][k]=v
				end
			end
		end
	end
end
--某一场设置英雄
function heroVoApi:setServerWarLocalHeroByIndex(index,pos,hid)
	if index then
		if pos and self["serverWarLocalTroop"..index] then
			self["serverWarLocalTroop"..index][pos]=hid
		end
	end
end
--某一场可以设置的英雄
function heroVoApi:getServerWarLocalCanSetHeroList(type)
	local heroList=self:getSelectHeroList()
	local selectId=type-23 --当前部队id
	for i=1,3 do
		if i~=selectId then
			for k,v in pairs(self["serverWarLocalTroop"..i]) do
				for m,n in pairs(heroList) do
					if v~=0 and n.hid and v==n.hid then
						table.remove(heroList,m)
					end
				end
			end
		end
	end
	return heroList
end

--某一场最大战力推荐英雄时可以设置的英雄
function heroVoApi:getServerWarLocalCanSetBestHeroList(heroList,index)
	if heroList then
		for i=1,3 do
			if index~=i then
				for k,v in pairs(self["serverWarLocalTroop"..i]) do
					for m,n in pairs(heroList) do
						if v~=0 and n.hid and v==n.hid then
							table.remove(heroList,m)
						end
					end
				end
			end
		end
	end
	return heroList
end
--清空某一场的英雄设置
function heroVoApi:deleteServerWarLocalTroopsByIndex(index,pos)
	if index then
		if pos and self["serverWarLocalTroop"..index] then
			self["serverWarLocalTroop"..index][pos]=0
		else
			self["serverWarLocalTroop"..index]={0,0,0,0,0,0}
		end
	end
end
--清空英雄设置
function heroVoApi:clearServerWarLocalTroops()
    self.serverWarLocalTroop1={0,0,0,0,0,0}
    self.serverWarLocalTroop2={0,0,0,0,0,0}
    self.serverWarLocalTroop3={0,0,0,0,0,0}
end


--某一场英雄现状信息
function heroVoApi:getServerWarLocalCurHeroList(index)
	if index and self["serverWarLocalCurTroop"..index] then
		return self["serverWarLocalCurTroop"..index]
	end
	return {0,0,0,0,0,0}
end
--某一场设置现状英雄
function heroVoApi:setServerWarLocalCurHeroList(index,heroList)
	if index then
		self["serverWarLocalCurTroop"..index]={0,0,0,0,0,0}
		if heroList then
			for k,v in pairs(heroList) do
				if v then
					self["serverWarLocalCurTroop"..index][k]=v
				end
			end
		end
	end
end
--某一场设置现状英雄
function heroVoApi:setServerWarLocalCurHeroByIndex(index,pos,hid)
	if index then
		if pos and self["serverWarLocalCurTroop"..index] then
			self["serverWarLocalCurTroop"..index][pos]=hid
		end
	end
end
--某一场可以设置的现状英雄
function heroVoApi:getServerWarLocalCanSetCurHeroList()
	local heroList=self:getSelectHeroList()
	for i=1,3 do
		for k,v in pairs(self["serverWarLocalCurTroop"..i]) do
			for m,n in pairs(heroList) do
				if v~=0 and n.hid and v==n.hid then
					table.remove(heroList,m)
				end
			end
		end
	end
	return heroList
end

--清空某一场的现状英雄设置
function heroVoApi:deleteServerWarLocalCurTroopsByIndex(index,pos)
	if index then
		if pos and self["serverWarLocalCurTroop"..index] then
			self["serverWarLocalCurTroop"..index][pos]=0
		else
			self["serverWarLocalCurTroop"..index]={0,0,0,0,0,0}
		end
	end
end
--清空现状英雄设置
function heroVoApi:clearServerWarLocalCurTroops()
    self.serverWarLocalCurTroop1={0,0,0,0,0,0}
    self.serverWarLocalCurTroop2={0,0,0,0,0,0}
    self.serverWarLocalCurTroop3={0,0,0,0,0,0}
end

----------以上群雄争霸英雄信息----------

function heroVoApi:getNewYearBossHeroList()
	return self.newYearBossTroops
end

function heroVoApi:setNewYearBossHeroList(tb)
	if tb==nil then
		tb={0,0,0,0,0,0}
	end
	self.newYearBossTroops=tb
end
----------以上群雄争霸英雄信息----------



----------以下新军团战将领----------
--清空新军团战英雄设置
function heroVoApi:clearAllianceWar2Troops()
	self.allianceWar2Troops={0,0,0,0,0,0}
end
--新军团战英雄信息
function heroVoApi:getAllianceWar2HeroList()
	if self.allianceWar2Troops then
		return self.allianceWar2Troops
	end
	return {0,0,0,0,0,0}
end
--新军团战设置英雄
function heroVoApi:setAllianceWar2HeroList(heroList)
	if heroList then
		for k,v in pairs(heroList) do
			if v and (type(v)=="string" or type(v)=="number") then
				self.allianceWar2Troops[k]=v
			else
				self.allianceWar2Troops[k]=0
			end
		end
	end
end
--新军团战某一个位置设置英雄
function heroVoApi:setAllianceWar2HeroByPos(pos,hid)
	if pos and self.allianceWar2Troops then
		self.allianceWar2Troops[pos]=hid
	else
		self.allianceWar2Troops={0,0,0,0,0,0}
	end
end

--清空新军团战当前英雄设置
function heroVoApi:clearAllianceWar2CurTroops()
	self.allianceWar2CurTroops={0,0,0,0,0,0}
end
--新军团战当前英雄信息
function heroVoApi:getAllianceWar2CurHeroList()
	if self.allianceWar2CurTroops then
		return self.allianceWar2CurTroops
	end
	return {0,0,0,0,0,0}
end
--新军团战设置当前英雄
function heroVoApi:setAllianceWar2CurHeroList(heroList)
	if heroList then
		for k,v in pairs(heroList) do
			if v and (type(v)=="string" or type(v)=="number") then
				self.allianceWar2CurTroops[k]=v
			else
				self.allianceWar2CurTroops[k]=0
			end
		end
	end
end
--新军团战当前某一个位置设置英雄
function heroVoApi:setAllianceWar2CurHeroByPos(pos,hid)
	if pos and self.allianceWar2CurTroops then
		self.allianceWar2CurTroops[pos]=hid
	else
		self.allianceWar2CurTroops={0,0,0,0,0,0}
	end
end

----------以上新军团战将领----------

----------以下异元战场报名将领----------
--清空英雄设置
function heroVoApi:clearDimensionalWarTroops()
	self.dimensionalWarTroops={0,0,0,0,0,0}
	self.dimensionalWarTroopsData={0,0,0,0,0,0}
end
function heroVoApi:getDimensionalWarTroopsData()
	if self.dimensionalWarTroopsData then
		return self.dimensionalWarTroopsData
	end
	return {0,0,0,0,0,0}
end
function heroVoApi:setDimensionalWarTroopsData(heroList)
	if heroList then
		for k,v in pairs(heroList) do
			if v and (type(v)=="string" or type(v)=="number") then
				self.dimensionalWarTroopsData[k]=v
			else
				self.dimensionalWarTroopsData[k]=0
			end
		end
	end
end
--英雄信息
function heroVoApi:getDimensionalWarHeroList()
	if self.dimensionalWarTroops then
		return self.dimensionalWarTroops
	end
	return {0,0,0,0,0,0}
end
--设置英雄
function heroVoApi:setDimensionalWarHeroList(heroList)
	if heroList then
		for k,v in pairs(heroList) do
			if v and (type(v)=="string" or type(v)=="number") then
				self.dimensionalWarTroops[k]=v
			else
				self.dimensionalWarTroops[k]=0
			end
		end
	end
end
--某一个位置设置英雄
function heroVoApi:setDimensionalWarHeroByPos(pos,hid)
	if pos and self.dimensionalWarTroops then
		self.dimensionalWarTroops[pos]=hid
	else
		self.dimensionalWarTroops={0,0,0,0,0,0}
	end
end
----------以上异元战场报名将领----------


-- 两个位置交换英雄
function heroVoApi:exchangeHerosByType(type,id1,id2)
 	local tempTab = heroVoApi:getTroopsHeroList()
    local tab1 = tempTab[id1]
    tempTab[id1] = tempTab[id2]
    if type==3 or type==35 or type==36 then
    	self:setTroopsByPos(id1,tempTab[id1],type)
    	self:setTroopsByPos(id2,tab1,type)
    end
    tempTab[id2] = tab1
end

--显示将领招募页面
function heroVoApi:showHeroRecruitDialog(layerNum)
	local playerLv=playerVoApi:getPlayerLevel()
	if base.heroSwitch==0 or playerLv<base.heroOpenLv then
		do return end
	end
	require "luascript/script/game/scene/gamedialog/heroDialog/heroRecruitDialog"
	local td=heroRecruitDialog:new(layerNum)
	local tbArr={}
	local str=getlocal("recruitTitle")
	if G_getBHVersion()==2 then
		str=getlocal("newrecruitTitle")
	end
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168  , 86, 10, 10),tbArr,nil,nil,str,true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--得到将领的最大品阶
function heroVoApi:getHeroMaxQuality()
	return self:getHeroMaxProduct()
end

--得到将领可升级到的最大等级
function heroVoApi:getHeroMaxLevel()
	local maxQuality = self:getHeroMaxQuality()
	local maxLv
	if maxQuality > SizeOfTable(heroCfg.heroLevel) then
		maxLv = heroCfg.heroLevel[SizeOfTable(heroCfg.heroLevel)]
	else
		maxLv = heroCfg.heroLevel[maxQuality]
	end
	return maxLv
end

function heroVoApi:getFightingByHeros(heroId)
	if heroId ~= nil then
        local heroVo = self:getHeroByHid(heroId)
        local heroCfg = heroListCfg[heroId]
        if heroVo and heroCfg then
            local Attr=0
            for k,v in pairs(heroCfg.heroAtt) do
                Attr=Attr + heroVo.productOrder * v[1] + heroVo.level * v[2]
            end
            Attr=Attr*10
             
            local skill={}
            for k1,v1 in pairs(heroVo.skill) do
                if v1 > 0 then
                    skill[k1] = v1
                end
            end

            for k2,v2 in pairs(heroVo.honorSkill) do
                if v2 and v2[2] and v2[2]> 0 then
                    skill[v2[1]] = v2[2]
                end
            end

            --将领装备
            if base.he == 1 then
                local hequipVo = heroEquipVoApi:getEquipVo(heroId)
            	local eattrs={}
                for i=1,6 do
                    local sid = "e"..i
                    local upgrade=equipCfg[heroId][sid].upgrade.att
                    local grow=equipCfg[heroId][sid].grow.att
                    local awaken=equipCfg[heroId][sid].awaken.att
                    local qlevel=1
                    local plevel=1
                    local alevel=0
                    if hequipVo and hequipVo.eList and hequipVo.eList[sid] then
                        qlevel = hequipVo.eList[sid][1]
                        plevel = hequipVo.eList[sid][2]
                        alevel = hequipVo.eList[sid][3]
                    end
                    for k,v in pairs (grow)  do
                        eattrs[k]=(eattrs[k] or 0) +v*qlevel
                    end 
                    for k,v in pairs (upgrade)  do
                        eattrs[k]=(eattrs[k] or 0) +v*plevel
                    end 
                    for k,v in pairs (awaken)  do
                        eattrs[k]=(eattrs[k] or 0) +v*alevel
                    end
                end

                local point=0
                for k,v in pairs(eattrs)  do
                    if k=='first' and  k=='antifirst'  then
                        point=point+v*4.5
                    else
                        point=point+v*10
                    end
                end
                Attr=Attr+point
            end

            for sk2,sv2 in pairs(skill) do
                if sv2 >0 then
                    local skillCfg =heroSkillCfg[sk2]
                    Attr=Attr+(tonumber(skillCfg.skillPower)*sv2)
                end
            end
            return Attr
        end
    end
    return 0
end

--是否开放将领招募
function heroVoApi:isOpenHeroRecruit()
	if base.heroSwitch==0 then
		return false
	end
	local heroOpenLv=base.heroOpenLv or 20
	if playerVoApi:getPlayerLevel()>=heroOpenLv then
		return true
	end
	return false
end

--获取免费数据
--[[@return
	{ 
		普通：{ 当前免费次数, 最大免费次数 },
		高级：{ 当前免费次数, 最大免费次数(写死1次) } 
	}
--]]
function heroVoApi:getFreeData()
	local num=heroCfg.freeTicketLimit-(self:getHeroInfo().commonLotteryNum or 0)
	if num<0 then
		num=0
	end
	local advancedNum=self:isFreeAdvancedLottery()
	if advancedNum==1 then
		advancedNum=0
	else
		advancedNum=1
	end
	return { {num,heroCfg.freeTicketLimit}, {advancedNum,1} }
end


function heroVoApi:setChampionshipWarHeroByPos(pos,hid)
	if pos and self.championshipWarHeroTb then
		self.championshipWarHeroTb[pos]=hid
	else
		self.championshipWarHeroTb={0,0,0,0,0,0}
	end
end
function heroVoApi:setChampionshipWarPersonalHeroByPos(pos,hid)
	if pos and self.championshipWarPersonalHeroTb then
		self.championshipWarPersonalHeroTb[pos]=hid
	else
		self.championshipWarPersonalHeroTb={0,0,0,0,0,0}
	end
end
--设置军团锦标赛军团战将领数据
function heroVoApi:setChampionshipWarHeroTb(heroTb)
	if heroTb==nil or SizeOfTable(heroTb)==0 then
		heroTb={0,0,0,0,0,0}
	end
	self.championshipWarHeroTb=heroTb
end
--设置军团锦标赛个人战将领数据
function heroVoApi:setChampionshipWarPersonalHeroTb(heroTb)
	if heroTb==nil or SizeOfTable(heroTb)==0 then
		heroTb={0,0,0,0,0,0}
	end
	self.championshipWarPersonalHeroTb=heroTb
end
--获取军团锦标赛军团战将领数据
function heroVoApi:getChampionshipWarHeroTb()
	return self.championshipWarHeroTb
end
--获取军团锦标赛个人战将领数据
function heroVoApi:getChampionshipWarPersonalHeroTb()
	return self.championshipWarPersonalHeroTb
end
--清除军团锦标赛军团战将领数据
function heroVoApi:clearChampionshipWarHeroTb()
	self.championshipWarHeroTb={0,0,0,0,0,0}
end
--清除军团锦标赛个人战将领数据
function heroVoApi:clearChampionshipWarPersonalHeroTb()
	self.championshipWarPersonalHeroTb={0,0,0,0,0,0}
end

--判断将领技能是否可以重置
function heroVoApi:isCanResetSkill()
	if self.skillResetTimer then
		return base.serverTime >= self.skillResetTimer, self.skillResetTimer - base.serverTime
	end
	return true
end

--获取将领技能重置返还的物品
function heroVoApi:getSkillResetReturnItem(sid, level)
	local tempTb = {}
	for lv = 1, level - 1 do
		local propsTb = heroSkillCfg[sid].breach[lv].props
		for k, v in pairs(propsTb) do
			tempTb[k] = (tempTb[k] or 0) + v
		end
	end
	if SizeOfTable(tempTb) > 0 then
		for k, v in pairs(tempTb) do
			local num = math.floor(v * heroCfg.heroSkillReturnRes)
			if num > 0 then
				tempTb[k] = num
			else
				tempTb[k] = nil
			end
		end
		return FormatItem({p = tempTb})
	end
end

function heroVoApi:showSkillResetDialog(layerNum, hid, skillId, skillCurLv, callback)
	local isCanReset, timer = self:isCanResetSkill()
    if isCanReset == false then
        local tipsStr = getlocal("heroSkill_resetTimerTips", {G_formatActiveDate(timer)})
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipsStr, 30)
        do return end
    end
    local returnAwardTb = self:getSkillResetReturnItem(skillId, skillCurLv)
    local function resetCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if callback then
            	callback()
            end
            for k,v in pairs(returnAwardTb) do
                G_addPlayerAward(v.type, v.key, v.id, v.num)
            end
            G_showRewardTip(returnAwardTb, true)
        end
    end
    allianceSmallDialog:showOKDialog(function()
        if returnAwardTb then
            smallDialog:showRewardPreviewDialog(layerNum + 1, {getlocal("heroSkill_resetReturnText"), getlocal("heroSkill_resetReturnTips")}, returnAwardTb, function(sdObj)
                if sdObj and sdObj.close then
                    sdObj:close()
                end
                socketHelper:heroSkillReset(resetCallback, hid, skillId)
            end)
        else
            print("cjl ------>>> ERROR: 暂无要返还的物品！")
        end
    end, {getlocal("heroSkill_resetText"), getlocal("heroSkill_resetTips", {heroCfg.heroSkillReSetCd / 86400})}, layerNum + 1)
end

--针对跨服演习大战的将领信息数据
function heroVoApi:exerWarHeroVo(heroTb)
	if heroTb then
		local hid = heroTb[1]
	    local heroLevel = heroTb[2] or 1
	    local heroStarLv = heroTb[3] or 1
	    local heroSkillLv = heroTb[4] or 1
	    local hVo = heroVo:new()
        local heroSkill = {}
        if heroListCfg[hid].skills then
            for k, v in pairs(heroListCfg[hid].skills) do
                table.insert(heroSkill, {v[1], heroSkillLv})
            end
        end
        hVo:initWithData(hid, {heroLevel, 0, heroStarLv, heroSkill})

        local addAdTb = {}
      	for mm, nn in pairs(heroListCfg[hVo.hid].heroAtt) do
        	table.insert(addAdTb, mm)
      	end

        local share={}
	    share.heroVo = hVo
	    share.stype=2 --将领分享类型
	    share.name = playerVoApi:getPlayerName()
	    share.hid = hVo.hid --将领id
	    share.lv = hVo.level --将领等级
	    share.gd = hVo.productOrder --将领品阶
	    local atb=heroVoApi:getAddBuffTb(hVo)
	    local property={} --属性加成
	    for i=1,#addAdTb do
	      property[i]={}
	      local strLb2
	      if atb[addAdTb[i]] then
	        property[i][1]=atb[addAdTb[i]].."%"
	      else
	        property[i][1]="-"
	      end
	     
	      if property[i][2]==nil then
	        property[i][2]="-"
	      end
	      property[i][3]=addAdTb[i]
	    end
	    share.p=property --将领的属性的加成

	    share.sb=heroSkill --常规技能
        return share
	end
end

function heroVoApi:showHeroInfoSmallDialog(heroVo,onlyBaseAttr,isMax,layerNum)
	require "luascript/script/game/scene/gamedialog/heroDialog/heroInfoSmallDialog"
	heroInfoSmallDialog:showHeroInfo(heroVo, onlyBaseAttr,isMax,layerNum)
end

--将领顶级属性信息
function heroVoApi:showMaxHeroInfo(hid,layerNum)
	if hid == nil or  heroListCfg[hid] == nil then
		do return end
	end
	local skills = {}
    for k,v in pairs(heroListCfg[hid].skills) do
        skills[v[1]]=1
    end
    local vo = heroVo:new()
    local maxLv = self:getHeroMaxLevel()
    local maxQuality = self:getHeroMaxQuality()
    vo:initWithData(hid,{maxLv,0,maxQuality,skills})
    self:showHeroInfoSmallDialog(vo,true,true,layerNum)
end

function heroVoApi:getPropertyValueStr(pkey, pv)
	if pkey == "antifirst" or pkey == "first" then
		return tostring(pv)
	end
	return tostring(pv).."%%"
end

--获取将领技能描述
function heroVoApi:getSkillDesc(sid, sv)
	local skcfg = heroSkillCfg[sid]
	if FuncSwitchApi:isEnabled("heroskill_revision") == true then
		--部分技能优化
		if (skcfg.conditionType >= 1 and skcfg.conditionType <= 6) or skcfg.conditionType == 25 or skcfg.conditionType == 35 then
			local rate = 1
			if skcfg.conditionType <= 6 then
				rate = 0.1
			elseif skcfg.conditionType == 25 then
				rate = 0.2
			elseif skcfg.conditionType == 35 then
				rate = 0.4
			end
			local descKey = Split(skcfg.des, "_")[3]
			descKey = "skill_newdes_"..descKey
			return getlocal(descKey,{self:getPropertyValueStr(skcfg.attType, sv), self:getPropertyValueStr(skcfg.attType, sv*rate)})
		end
	end
	local vstrTb = {}	
	if type(skcfg.attType) == "table" then
		for k,v in pairs(skcfg.attType) do
			vstrTb[k] = self:getPropertyValueStr(v, sv[k])
		end
	else
		vstrTb = {self:getPropertyValueStr(skcfg.attType, sv)}		
	end
	return getlocal(skcfg.des, vstrTb)
end