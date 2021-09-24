require "luascript/script/game/gamemodel/alienTech/alienTechVo"
alienTechVoApi={
	allAlienTech={}, --{"t8":1,"t1":3}
	usedAlienTech={}, --{"a10033":{"t329","t323",0,0,-1},"a10001":{"t1",0,"t3","t9"},}  0 是默认解锁的位置 -1 是自己解锁的
	pointTb={},
	treeCfg={},
	flag=-1,

	canTransformCommonTb={},	--已经解锁可以改装的普通坦克
	canTransformSpecialTb={},	--已经解锁可以改装的特战坦克
	allCanTransformCommonTb={},	--所有已开放的可以改装的普通坦克
	canTransformTankIdTb={},--luckyPoker活动开启的坦克

	produceSpeedUpTb={},	--加速生产科技，{"a10002":"t13",}
	addAbilityTb={},		--坦克技能增加点数，{"a10005":"t49",}

	alienResource={},
	alienDailyResource={},
	resFlag=1,
	resDailyFlag=1,

	giftExpireTime=0,
	giftAllList={},
	giftSendList={},
	giftAcceptList={},

	giftRequestFlag=false, --是否已经获取礼物列表的标记
}

function alienTechVoApi:getFlag()
	return self.flag
end
function alienTechVoApi:setFlag(flag)
	self.flag=flag
end

function alienTechVoApi:getResFlag()
	return self.resFlag
end
function alienTechVoApi:setResFlag(resFlag)
	self.resFlag=resFlag
end

function alienTechVoApi:getResDailyFlag()
	return self.resDailyFlag
end
function alienTechVoApi:setResDailyFlag(resDailyFlag)
	self.resDailyFlag=resDailyFlag
end

function alienTechVoApi:showAlienTechFactoryDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/alienTechFactoryDialog/alienTechFactoryDialog"
	
    local function openAlienCallback()
        local isLuckyPoker = false
        if acLuckyPokerVoApi and acLuckyPokerVoApi:IsAcInAllAc( ) ==true then
        	isLuckyPoker = true
        end

        local canTransformTb=self:getCanTransformTb(2,nil,isLuckyPoker)
        local tbArr={getlocal("alien_tech_common_transform")}

        if (canTransformTb and SizeOfTable(canTransformTb)>0) or isLuckyPoker ==true then
        	table.insert(tbArr,getlocal("alien_tech_special_transform"))
        end
        -- base.etank=0
        if base.etank==1 then
        	table.insert(tbArr,getlocal("tank_reduction"))
        end
        local td = alienTechFactoryDialog:new()
        local vd = td:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alien_tech_factory_title"),true,layerNum)
        sceneGame:addChild(vd,layerNum)
    end
    self:getTechData(openAlienCallback)
end

function alienTechVoApi:getProduceSpeedUpTb()
	if self.produceSpeedUpTb==nil or SizeOfTable(self.produceSpeedUpTb)==0 then
		for k,v in pairs(alienTechCfg.talent) do
			local valueTb=v[alienTechCfg.keyCfg.value]
			local isAdd=false
			if valueTb and SizeOfTable(valueTb)>0 then
				for i,j in pairs(valueTb) do
					if j and type(j)=="table" and j[200] then
						isAdd=true
					end
				end
			end
			if isAdd==true then
				local tank
				local effectTroops=v[alienTechCfg.keyCfg.effectTroops]
				if type(effectTroops)=="table" then
					-- tank=effectTroops[1]
					for i,j in pairs(effectTroops) do
						self.produceSpeedUpTb[j]=k
					end
				else
					-- tank=effectTroops
					self.produceSpeedUpTb[effectTroops]=k
				end
				-- self.produceSpeedUpTb[tank]=k
			end
		end
	end
	return self.produceSpeedUpTb
end

function alienTechVoApi:getPointTb()
	return self.pointTb
end
function alienTechVoApi:getPointByTypeIndex(type,index)
	local point=0
	if self.pointTb==nil then
		self.pointTb={}
	end
	if type and index and point then
		if self.pointTb[type]==nil then
			self.pointTb[type]={}
		end
		if self.pointTb[type][index]==nil then
			self.pointTb[type][index]=0
		end
		point=self.pointTb[type][index]
	end
	return point
end
function alienTechVoApi:setPointByTypeIndex(type,index,point)
	if self.pointTb==nil then
		self.pointTb={}
	end
	if type and index and point then
		if self.pointTb[type]==nil then
			self.pointTb[type]={}
		end
		self.pointTb[type][index]=point
	end
end
function alienTechVoApi:getPointByType(type)
	if type then
		local point=0
		local pointTb=self:getPointTb()
		local pTb=pointTb[type]
		for k,v in pairs(pTb) do
			point=point+tonumber(v)
		end
		return point
	end
	return 0
end


function alienTechVoApi:clearTechData()
    self.allAlienTech={}
    self.usedAlienTech={}
end

function alienTechVoApi:setPartTechData(data)
	if data then
		if data.info then
			self.allAlienTech=data.info
		end
		if data.used then
			self.usedAlienTech=data.used
		end
	end
end

function alienTechVoApi:setTechData(data)
	if data then
		if data.info then
			self.allAlienTech=data.info
		end
		if data.used then
			self.usedAlienTech=data.used
		end
		if data.prop then
			self.alienResource=data.prop
		end
		if data.pinfo then
			self:setAlienDailyRes(data.pinfo)
		end
		
		self.canTransformCommonTb={}
		self.canTransformSpecialTb={}
	end
end


function alienTechVoApi:checkUpdateDailyRes()
	if self.alienDailyResource and self.alienDailyResource.ts then
		if G_isToday(self.alienDailyResource.ts)==false then
			self.alienDailyResource={}
			self.alienDailyResource.ts=G_getWeeTs(base.serverTime)+86400
			self:setResDailyFlag(0)
		end
	end
end
function alienTechVoApi:setAlienDailyRes(resData)
	if resData then
		self.alienDailyResource=resData
		self:checkUpdateDailyRes() 
		self:setResDailyFlag(0)
	end
end
function alienTechVoApi:getAlienDailyResByType(resType)
	local num=0
	if resType and self.alienDailyResource and self.alienDailyResource[resType] then
		num=tonumber(self.alienDailyResource[resType]) or 0
	end
	return num
end
function alienTechVoApi:setAlienDailyResByType(resType,num)
	if self.alienDailyResource==nil then
		self.alienDailyResource={}
	end
	if resType then
		self.alienDailyResource[resType]=num
		self:setResDailyFlag(0)
	end
end

function alienTechVoApi:getAlienResByType(resType)
	local num=0
	if resType and self.alienResource and self.alienResource[resType] then
		num=tonumber(self.alienResource[resType]) or 0
	end
	return num
end
function alienTechVoApi:setAlienResByType(resType,num)
	if self.alienResource==nil then
		self.alienResource={}
	end
	if resType then
		self.alienResource[resType]=num
		self:setResFlag(0)
	end
end

function alienTechVoApi:getTechData(callback)
	if self:getFlag()==-1 then
		local function getTechDataCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
            	if sData.data and sData.data.alien then
	            	self:setTechData(sData.data.alien)
	            	self:getTreeCfg()
	            	self:setFlag(1)
	            end

            	if callback then
					callback()
				end
            end
		end
		socketHelper:alienGet(getTechDataCallback)
	else
		if callback then
			callback()
		end
	end
end


function alienTechVoApi:getAllAlienTech()
	return self.allAlienTech
end
function alienTechVoApi:getUsedAlienTech()
	return self.usedAlienTech
end
function alienTechVoApi:getAlienResource()
	return self.alienResource
end

function alienTechVoApi:getTechLevel(tid)
	if tid and tid~=0 and self.allAlienTech and self.allAlienTech[tid] then
		return self.allAlienTech[tid]
	end
	return 0
end

function alienTechVoApi:getTechTbByTank(tankId)
	local techTb={{},{}}
	if tankId and alienTechCfg.canUseTech and alienTechCfg.canUseTech[tankId] then
		-- techTb=alienTechCfg.canUseTech[tankId]
		local canUseTech=alienTechCfg.canUseTech[tankId]
		local commonTb=canUseTech[1] or {}
		local specialTb=canUseTech[2] or {}
		for k,v in pairs(commonTb) do
			if v and alienTechCfg.talent[v] then
				local unlockVersion=alienTechCfg.talent[v][alienTechCfg.keyCfg.unlockVersion] or 0
				local unlockAlienTech=playerVoApi:getMaxLvByKey("unlockAlienTech") or 0
				if unlockAlienTech and unlockVersion and tonumber(unlockAlienTech)>=tonumber(unlockVersion) then
					table.insert(techTb[1],v)
				end
			end
		end
		for k,v in pairs(specialTb) do
			if v and alienTechCfg.talent[v] then
				local unlockVersion=alienTechCfg.talent[v][alienTechCfg.keyCfg.unlockVersion] or 0
				local unlockAlienTech=playerVoApi:getMaxLvByKey("unlockAlienTech") or 0
				if unlockAlienTech and unlockVersion and tonumber(unlockAlienTech)>=tonumber(unlockVersion) then
					table.insert(techTb[2],v)
				end
			end
		end
	end
	return techTb
end
function alienTechVoApi:getSlotAndFixed(tankId)
	local fixedTb={}
	local techTb=self:getTechTbByTank(tankId)
	if techTb and techTb[2] then
		fixedTb=techTb[2]
	end
	local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
	local alienSlot=tankCfg[tid].alienSlot
	-- local fixedTb=tankCfg[tid].fixedSlot or {}
	return alienSlot,fixedTb
end
function alienTechVoApi:getSlotByTank(tankId)
	if tankId then
		local slotTb={-2,-2,-2,-2,-2,-2}
		local alienSlot,fixedTb=self:getSlotAndFixed(tankId)
		local fixedNum=alienSlot[1] or 0
		local num=alienSlot[2] or 0
		local totalNum=num+SizeOfTable(fixedTb)

		for i=1,6 do
			if i<=num then
				if i<=fixedNum then
					slotTb[i]=0
				else
					slotTb[i]=-1
				end
			elseif i>=5 then
				local tid=fixedTb[i-4]
				slotTb[i]=tid
			end
		end

		local index=0
		if self.usedAlienTech and self.usedAlienTech[tankId] then
			local usedAlienTech=self.usedAlienTech[tankId]
			for k,v in pairs(usedAlienTech) do
				if v==0 then
					index=index+1
					slotTb[index]=v
				else
					local talent=alienTechCfg.talent[v]
					if talent then
						local talentType=talent[alienTechCfg.keyCfg.talentType]
						if talentType and talentType==1 then
							index=index+1
							slotTb[index]=v
						end
					end
				end
			end
		end
		return slotTb,totalNum
	end
	return {},0
end


--返回：0可以使用，1已经装备，2已装有同类型的技能，3未解锁(等级为0也显示未解锁)
function alienTechVoApi:getTechCanUsedStatus(techType,tankId,techId)
	local aType=alienTechCfg.talent[techId][alienTechCfg.keyCfg.attributeType]
	local usedAlienTech=self:getUsedAlienTech()
	if usedAlienTech and usedAlienTech[tankId] then
		for k,v in pairs(usedAlienTech[tankId]) do
			if v and type(v)=="string" then
				if techId and v==techId then
					do return 1 end
				else
					local attributeType=alienTechCfg.talent[v][alienTechCfg.keyCfg.attributeType]
					if aType and aType==attributeType then
						do return 2,v end
					end
				end
			end
		end
	end
	local isUnlock=self:getTechIsUnlock(techId,techType,true)
	if isUnlock==true then
	else
		return 3
	end
	return 0
end
function alienTechVoApi:getCanUseTechTbByTank(tType,tankId)
	local tTab={}
	local techTb=self:getTechTbByTank(tankId)
	if techTb and techTb[1] then
		for k,v in pairs(techTb[1]) do
			if v and v~=0 then
				local isInsert=false
				local cfg=alienTechCfg.talent[v]
				local talentType=cfg[alienTechCfg.keyCfg.talentType]
				local effectTroops=cfg[alienTechCfg.keyCfg.effectTroops]
				if effectTroops and talentType and talentType==1 then
					if type(effectTroops)=="table" then
						for m,n in pairs(effectTroops) do
							if n and n==tankId then
								isInsert=true
							end
						end
					end
				end
				if isInsert==true then
					local status,techId=self:getTechCanUsedStatus(tType,tankId,v)
					local sortId
					if status==0 then
						sortId=1,techId
					elseif status==1 then
						sortId=0,techId
					elseif status>=2 then
						sortId=status-1,techId
					end
					local tab={tid=v,status=status,sortId=sortId,techId=techId}
					table.insert(tTab,tab)
				end
			end
		end
	end
	local function sortFunc(a,b)
		if a and b and a.status and b.status then
			if a.status==b.status then
				if a.tid and b.tid then
					local aid=(tonumber(a.tid) or tonumber(RemoveFirstChar(a.tid)))
					local bid=(tonumber(b.tid) or tonumber(RemoveFirstChar(b.tid)))
					return aid<bid
				end
			else
				return a.status<b.status
			end
			
		end
	end
	table.sort(tTab,sortFunc)
	return tTab
end

function alienTechVoApi:updateSavedTank()
	local hasTanks={}
	local homeTanks=tankVoApi:getAllTanks()
	for k,v in pairs(homeTanks) do
		if v and ((v[1] and v[1]>0) or (v[3] and v[3]>0)) then
			hasTanks["a"..k]=1
		end
	end
	local attackTankSlots=attackTankSoltVoApi:getAllAttackTankSlots()
	for k,v in pairs(attackTankSlots) do
		if v and v.troops then
			for m,n in pairs(v.troops) do
				for id,num in pairs(n) do
					if id then
						hasTanks[id]=1
					end
				end
			end
		end
	end

	local tanksStr=""
	for k,v in pairs(hasTanks) do
		if v and v==1 then
			tanksStr=tanksStr.."@"..k
		end
	end
	local dataKey="alienTechHasTanks@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
	CCUserDefault:sharedUserDefault():setStringForKey(dataKey,tanksStr)
	CCUserDefault:sharedUserDefault():flush()
end

function alienTechVoApi:getIsShowTank(tanks)
	local dataKey="alienTechHasTanks@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
	local tanksStr=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
	if tanksStr and tanksStr~="" then
		local tankArr=Split(tanksStr,"@")
		if tanks and SizeOfTable(tanks)>0 and tankArr and SizeOfTable(tankArr)>0 then
			for k,v in pairs(tankArr) do
				if v and v~="" then
					for m,n in pairs(tanks) do
						local id = tonumber(v) or tonumber(RemoveFirstChar(v))
						local aid=v
						if G_pickedList(id)~=id then
							aid="a" .. G_pickedList(id) 
						end
						if aid==n then
							return true
						end
					end
				end
				
			end
		end
	end
	return false
end

function alienTechVoApi:getTreeCfg(flag)
	if SizeOfTable(self.treeCfg)==0 then
		if flag or self:getFlag()~=-1 then
			local tree=G_clone(alienTechCfg.tree)
			local index=1
			local unlockAlienTech=playerVoApi:getMaxLvByKey("unlockAlienTech")

			local tempTree={}
			for k,v in pairs(tree) do
				v.troopType=k
				table.insert(tempTree,v)
			end
			local function sortFunc(a,b)
				return a.troopType<b.troopType
			end
			table.sort(tempTree,sortFunc)

			for k,v in pairs(tempTree) do
				if v then
					if v.troopType<=8 or (v.troopType>8 and self:getIsShowTank(v.desc)==true) then
						if self.pointTb[index]==nil then
							self.pointTb[index]={}
						end
						local totalPoint=0
						local pointTab={}
						for m,n in pairs(v.tech) do
							local idx=math.ceil(m/11)
							if pointTab[idx]==nil then
								pointTab[idx]=0
							end
							if self.pointTb[index][idx]==nil then
								self.pointTb[index][idx]=0
							end
							if n~=0 then
								local unlockVersion=alienTechCfg.talent[n][alienTechCfg.keyCfg.unlockVersion]
								if unlockAlienTech and unlockVersion and tonumber(unlockAlienTech)>=tonumber(unlockVersion) then

									local point=alienTechCfg.talent[n][alienTechCfg.keyCfg.maxLv]
									totalPoint=totalPoint+point
									pointTab[idx]=pointTab[idx]+point
									self.pointTb[index][idx]=self.pointTb[index][idx]+self:getTechLevel(n)
								else
									n=0
									v.tech[m]=0
								end
							end
						end
						v.totalPoint=totalPoint
						v.pointTab=pointTab
						-- v.troopType=k

						local desc={}
						for m,n in pairs(v.unlock) do
							if unlockAlienTech and n and tonumber(unlockAlienTech)>=tonumber(n) then
								desc[m]=v.desc[m]
							end
						end
						v.desc=desc

						table.insert(self.treeCfg,v)
						index=index+1
					end
				end
			end
		end
	end
	return self.treeCfg
end
--科技在当前版本是否已经开放
function alienTechVoApi:getTechCurrVersionIsOpen(tid)
	if tid and tid~=0 then
		local unlockVersion=alienTechCfg.talent[tid][alienTechCfg.keyCfg.unlockVersion] or 0
		local unlockAlienTech=playerVoApi:getMaxLvByKey("unlockAlienTech") or 0
		if unlockAlienTech and unlockVersion and tonumber(unlockAlienTech)>=tonumber(unlockVersion) then
			return true
		end
	end
	return false
end

function alienTechVoApi:getTechIsUnlock(tid,type,zeroLvIsLock)
	local isUnlock=false
	if tid and tid~=0 and type then
		local tCfg=alienTechCfg.talent[tid]
		local enableRequireLv=tCfg[alienTechCfg.keyCfg.enableRequireLv]
		local enableRequireTroopTypeLv=tCfg[alienTechCfg.keyCfg.enableRequireTroopTypeLv]

		isUnlock=true
		for k,v in pairs(enableRequireLv) do
			local level=self:getTechLevel(k)
			if level<v then
				isUnlock=false
			end
		end
		local typePoint=self:getPointByType(type)
		if typePoint<enableRequireTroopTypeLv then
			isUnlock=false
		end
		if zeroLvIsLock==true then
			local curLevel=self:getTechLevel(tid)
			if curLevel<=0 then
				isUnlock=false
			end
		end
	end
	return isUnlock
end

--index lineTb的索引
--lType 类型：1全的线，0少一条 
--type 技能大的类型
--idx 坦克索引：tree的desc
function alienTechVoApi:getLineIsUnlock(index,lType,type,idx)
	if lType==nil then
		lType=1
	end
	local isUnlock=false
	local treeCfg=self:getTreeCfg()
	if treeCfg and SizeOfTable(treeCfg)>0 then
		local tech=treeCfg[type].tech
		if (lType==1 and index<8) or (lType==0 and index<7) then
			if lType==0 and index<7 and index>=3 then
				index=index+1
			end
		-- if index<8 then
			local techId=tech[idx*11+index+4]
			if techId==0 then
				if (index+4)==5 or (index+4)==6 then
					techId=tech[idx*11+9]
				elseif (index+4)==7 or (index+4)==8 then
					techId=tech[idx*11+10]
				end
				if techId==0 then
					techId=tech[idx*11+11]
				end
			end
			if techId~=0 then
				isUnlock=self:getTechIsUnlock(techId,type)
			end
		else
			for i=1,4 do
				local techId=tech[(idx+1)*11+i]
				if techId and techId~=0 then
					local tempUnlock=self:getTechIsUnlock(techId,type)
					if tempUnlock==true then
						isUnlock=true
					end
				end
			end
		end
	end
	if isUnlock==true then
		return 2
	else
		return 1
	end
end

function alienTechVoApi:getTechValue(tid,attrType)
	local value=0
	local nextValue=0
	local curLevel=self:getTechLevel(tid)
	local nextLevel=curLevel+1
	local tCfg=alienTechCfg.talent[tid]
	local maxLv=tCfg[alienTechCfg.keyCfg.maxLv]
    local addAttrTb=tCfg[alienTechCfg.keyCfg.value]
	if curLevel>maxLv then
		curLevel=maxLv
	end
	if nextLevel>maxLv then
		nextLevel=maxLv
	end
	if addAttrTb and addAttrTb[curLevel] and addAttrTb[curLevel][attrType] then
		value=addAttrTb[curLevel][attrType] or 0
	end
	if addAttrTb and addAttrTb[nextLevel] and addAttrTb[nextLevel][attrType] then
		nextValue=addAttrTb[nextLevel][attrType] or 0
	end
	return value,nextValue
end


--返回：0可以，1已满级，2材料不足
function alienTechVoApi:canUpgradeTech(tid)
	if tid and self.allAlienTech then
		local tCfg=alienTechCfg.talent[tid]
		local maxLv=tCfg[alienTechCfg.keyCfg.maxLv]
		local resourceConsume=tCfg[alienTechCfg.keyCfg.resourceConsume]
		if self.allAlienTech[tid]==nil then
			self.allAlienTech[tid]=0
		end
		local curLevel=self.allAlienTech[tid]
		if curLevel and curLevel>=maxLv then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_level_max"),30)
			do return 1 end
		end
		local needTankNum=0
		local commentTankNum=0
	    local costTb=resourceConsume[curLevel+1]
	    local itemTb=FormatItem(costTb)
	    if itemTb and SizeOfTable(itemTb)>0 then
	    	for k,v in pairs(itemTb) do
                if v and v.key then
                	if v.type=="p" then
                		local id=(tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))
                		local pNum=bagVoApi:getItemNumId(id)
                		if pNum<v.num then
                			do return 2 end
                		end
            		elseif v.type=="u" then
		                if v.key=="gem" or v.key=="gems" then
		                	if playerVo["gems"]<v.num then
		                		do return 2 end
		                	end
		                elseif playerVo[v.key] then
		                	if playerVo[v.key]<v.num then
		                		do return 2 end
		                	end
		                end
		            elseif v.type=="o" then
		            	local id=(tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))
		            	needTankNum=v.num
		            	commentTankNum=tankVoApi:getTankCountByItemId(id)
		            	local num=commentTankNum+tankVoApi:getTankCountByItemId(id+40000)
		            	if num<v.num then
		            		do return 2 end
		            	end
		            elseif v.type=="r" then
		            	local num=self:getAlienResByType(v.key)
		            	if num<v.num then
		            		do return 2 end
		            	end
            		end
                end
            end
	    end

		do return 0,needTankNum,commentTankNum end
	end
	return -1
end
function alienTechVoApi:upgradeTech(tid,callback,layerNum)
	if tid and self.allAlienTech then
		local upgradeStatus,needTankNum,commentTankNum=self:canUpgradeTech(tid)
		if upgradeStatus==0 then
			local function alienUpgradeCallback(fn,data)
	            local ret,sData=base:checkServerData(data)
	            if ret==true then
	            	if sData.data and sData.data.alien then
		            	self:setTechData(sData.data.alien)
		            	alienTechVoApi:setFlag(0)

		            	if callback then
		            		callback()
		            	end

		            	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_upgrade_success"),30)
		            end
	            end
			end
			local enum=0
			if needTankNum>commentTankNum then
				enum=needTankNum-commentTankNum
			end
			local function socketFunc()
	        	socketHelper:alienUpgrade(tid,alienUpgradeCallback,enum)
	        end
	        if enum>0 then
	        	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),socketFunc,getlocal("dialog_title_prompt"),getlocal("alien_tech_smelt_tip",{enum}),nil,layerNum)
	        else
	        	socketFunc()
	        end
			

		else
			if upgradeStatus==1 then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_level_max"),30)
			elseif upgradeStatus==2 then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_material_not_enough"),30)
			end
		end
	end
end



function alienTechVoApi:getCanTransformTb(tankType,isShowAll,isLuckyPoker)--isLuckyPoker:适用于无限火力
	-- print("tankType----isShowAll----->",tankType,isShowAll,isLuckyPoker)
	if tankType==1 or tankType==nil then
		if isShowAll and isShowAll==true then
			if self.allCanTransformCommonTb==nil or SizeOfTable(self.allCanTransformCommonTb)==0 then
				for k,v in pairs(alienTechCfg.talent) do
					local talentType=alienTechCfg.talent[k][alienTechCfg.keyCfg.talentType]
					if talentType==3 then
						local isOpen=self:getTechCurrVersionIsOpen(k)
						if isOpen==true then
							local tankId=alienTechCfg.talent[k][alienTechCfg.keyCfg.effectTroops]
							-- local tid=(tonumber(j) or tonumber(RemoveFirstChar(j)))
							-- if tankCfg[tid] and tankCfg[tid].isSpecial and tankCfg[tid].isSpecial==0 then
							-- 	table.insert(self.allCanTransformCommonTb,{j,k})
							-- 	if tankId and type(tankId)=="string" then
							-- 		table.insert(self.allCanTransformCommonTb,{tankId,k})
							-- 	end
							-- end
							if tankId and type(tankId)=="table" then
								for i,j in pairs(tankId) do
									local tid=(tonumber(j) or tonumber(RemoveFirstChar(j)))
									if tankCfg[tid] and tankCfg[tid].isSpecial and tankCfg[tid].isSpecial==0 then
										table.insert(self.allCanTransformCommonTb,{j,k})
									end
								end
							elseif tankId and type(tankId)=="string" then
								table.insert(self.allCanTransformCommonTb,{tankId,k})
							end
						end
					end
				end
				-- local allTech=self:getAllAlienTech()
				-- for k,v in pairs(allTech) do
				-- 	if v and tonumber(v) and tonumber(v)>0 then
				-- 		local talentType=alienTechCfg.talent[k][alienTechCfg.keyCfg.talentType]
				-- 		if talentType==3 then
				-- 			local tankId=alienTechCfg.talent[k][alienTechCfg.keyCfg.effectTroops]
				-- 			local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
				-- 			if tankCfg[tid] and tankCfg[tid].isSpecial and tankCfg[tid].isSpecial==0 then
				-- 				if tankId and type(tankId)=="string" then
				-- 					table.insert(self.allCanTransformCommonTb,{tankId,k})
				-- 				end
				-- 			end
				-- 		end
				-- 	end
				-- end
				local function sortFunc(a,b)
					if a and b and a[1] and b[1] then
						local aid=(tonumber(a[1]) or tonumber(RemoveFirstChar(a[1])))
						local bid=(tonumber(b[1]) or tonumber(RemoveFirstChar(b[1])))
						-- if aid and bid then
						-- 	return aid<bid
						-- end
						if aid and bid and tankCfg[aid] and tankCfg[bid] and tankCfg[aid].sortId and tankCfg[bid].sortId then
							return tonumber(tankCfg[aid].sortId)<tonumber(tankCfg[bid].sortId)
						end
					end
				end
				table.sort(self.allCanTransformCommonTb,sortFunc)
			end
			return self.allCanTransformCommonTb
		else
			if self.canTransformCommonTb==nil or SizeOfTable(self.canTransformCommonTb)==0 then
				local allTech=self:getAllAlienTech()
				for k,v in pairs(allTech) do
					if v and tonumber(v) and tonumber(v)>0 then
						local talentType=alienTechCfg.talent[k][alienTechCfg.keyCfg.talentType]
						if talentType==3 then
							local tankId=alienTechCfg.talent[k][alienTechCfg.keyCfg.effectTroops]
							-- local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
							-- if tankCfg[tid] and tankCfg[tid].isSpecial and tankCfg[tid].isSpecial==0 then
							-- 	if tankId and type(tankId)=="string" then
							-- 		table.insert(self.canTransformCommonTb,{tankId,k})
							-- 	end
							-- end
							if tankId and type(tankId)=="table" then
								for i,j in pairs(tankId) do
									local tid=(tonumber(j) or tonumber(RemoveFirstChar(j)))
									if tankCfg[tid] and tankCfg[tid].isSpecial and tankCfg[tid].isSpecial==0 then
										table.insert(self.canTransformCommonTb,{j,k})
									end
								end
							elseif tankId and type(tankId)=="string" then
								table.insert(self.canTransformCommonTb,{tankId,k})
							end
						end
					end
				end
				local function sortFunc(a,b)
					if a and b and a[1] and b[1] then
						local aid=(tonumber(a[1]) or tonumber(RemoveFirstChar(a[1])))
						local bid=(tonumber(b[1]) or tonumber(RemoveFirstChar(b[1])))
						-- if aid and bid then
						-- 	return aid<bid
						-- end
						if aid and bid and tankCfg[aid] and tankCfg[bid] and tankCfg[aid].sortId and tankCfg[bid].sortId then
							return tonumber(tankCfg[aid].sortId)<tonumber(tankCfg[bid].sortId)
						end
					end
				end
				table.sort(self.canTransformCommonTb,sortFunc)
			end
			return self.canTransformCommonTb
		end
	else
		if self.canTransformSpecialTb==nil or SizeOfTable(self.canTransformSpecialTb)==0 then
			local allTech=self:getAllAlienTech()
			if isLuckyPoker and isLuckyPoker == true then
				local allAc =activityVoApi:getAllActivity()
				-- self.canTransformTankIdTb = {}-----活动开启后可直接改造的坦克表（会遍历多开的情况）
				for k,v in pairs(allAc) do
					local acType = v.type
					local arr = Split(acType,"_")
					if arr[1] =="luckcard" then
						local curTb = acLuckyPokerVoApi:getNextRequireUseInAlienFactory(acType)---对应活动开启的坦克
						for m,n in pairs(curTb) do
							table.insert(self.canTransformTankIdTb,n)
						end
					end
				end
				for m,n in pairs(self.canTransformTankIdTb) do
					for k,v in pairs(alienTechCfg.talent) do
						if alienTechCfg.talent[k][alienTechCfg.keyCfg.talentType] == 3 then 
							local tankId=alienTechCfg.talent[k][alienTechCfg.keyCfg.effectTroops]

							local isRepeatId = false
							if tankId and type(tankId) =="table" then
								for i,j in pairs(tankId) do
									local tid=(tonumber(j) or tonumber(RemoveFirstChar(j)))
									if j ==n  and tankCfg[tid] and tankCfg[tid].isSpecial and tankCfg[tid].isSpecial==1 then
										for kk,vv in pairs(self.canTransformSpecialTb) do
											if vv[1] == j then
												isRepeatId =true
											end
										end

										if isRepeatId ==false then
											table.insert(self.canTransformSpecialTb,{j,k})
										end
									end
									isRepeatId =false
								end
							elseif  n == alienTechCfg.talent[k][alienTechCfg.keyCfg.effectTroops] then
								for kk,vv in pairs(self.canTransformSpecialTb) do
									if vv[1] == tankId then
										isRepeatId =true
									end
								end
								if isRepeatId ==false then
									table.insert(self.canTransformSpecialTb,{n,k})
								end
							end
						end
					end
				end
			end
			for k,v in pairs(allTech) do
				if v and tonumber(v) and tonumber(v)>0 then
					local talentType=alienTechCfg.talent[k][alienTechCfg.keyCfg.talentType]
					if talentType==3 then
						local tankId=alienTechCfg.talent[k][alienTechCfg.keyCfg.effectTroops]
						-- local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
						-- if tankCfg[tid] and tankCfg[tid].isSpecial and tankCfg[tid].isSpecial==1 then
						-- 	if tankId and type(tankId)=="string" then
						-- 		table.insert(self.canTransformSpecialTb,{tankId,k})
						-- 	end
						-- end
						local isRepeatId =false
						if tankId and type(tankId)=="table" then
							for i,j in pairs(tankId) do
								local tid=(tonumber(j) or tonumber(RemoveFirstChar(j)))
								if tankCfg[tid] and tankCfg[tid].isSpecial and tankCfg[tid].isSpecial==1 then
									for kk,vv in pairs(self.canTransformSpecialTb) do
										if vv[1] == j then
											isRepeatId =true
										end
									end
									if isRepeatId ==false then
										table.insert(self.canTransformSpecialTb,{j,k})
									end
								end
								isRepeatId =false
							end
						elseif tankId and type(tankId)=="string" then
							for kk,vv in pairs(self.canTransformSpecialTb) do
								if vv[1] == tankId then
									isRepeatId =true
								end
							end
							if isRepeatId ==false then
								table.insert(self.canTransformSpecialTb,{tankId,k})
							end
							
						end
					end
				end
			end
			local function sortFunc(a,b)
				if a and b and a[1] and b[1] then
					local aid=(tonumber(a[1]) or tonumber(RemoveFirstChar(a[1])))
					local bid=(tonumber(b[1]) or tonumber(RemoveFirstChar(b[1])))
					-- if aid and bid then
					-- 	return aid<bid
					-- end
					if aid and bid and tankCfg[aid] and tankCfg[bid] and tankCfg[aid].sortId and tankCfg[bid].sortId then
						return tonumber(tankCfg[aid].sortId)<tonumber(tankCfg[bid].sortId)
					end
				end
			end
			table.sort(self.canTransformSpecialTb,sortFunc)
		end
		return self.canTransformSpecialTb
	end
end

function alienTechVoApi:isInCanTransformTankIdTb(tankId)
	
	for k,v in pairs(self.canTransformTankIdTb) do
		if v ==tankId then
			return true
		end
	end
	return false
end

function alienTechVoApi:getIsCanTransform(tankId,nums,isSpecial,sale)
	local result=true
	if isSpecial and isSpecial==true then
		local costReR1=tankCfg[tankId].upgradeMetalConsume
		local costReR2=tankCfg[tankId].upgradeOilConsume
		local costReR3=tankCfg[tankId].upgradeSiliconConsume
		local costReR4=tankCfg[tankId].upgradeUraniumConsume
		if playerVoApi:getR1()<(costReR1*nums*sale) then
			result=false
		end
		if playerVoApi:getR2()<(costReR2*nums*sale) then
			result=false
		end
		if playerVoApi:getR3()<(costReR3*nums*sale) then
			result=false
		end
		if playerVoApi:getR4()<(costReR4*nums*sale) then
			result=false
		end
	else
		local costReR4=tankCfg[tankId].alienUraniumConsume
		if playerVoApi:getR4()<(costReR4*nums*sale) then
			result=false
		end
	end

	local costProps=tankCfg[tankId].upgradePropConsume
	if costProps~="" and type(costProps)=="table" then
		for k,v in pairs(costProps) do
			local pid=v[1]
			local pNum=tonumber(v[2]) or 0
			local hasPNum=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid)))
			if hasPNum<(pNum*nums) then
				result=false
			end
		end
	end

	local costTanks=tankCfg[tankId].upgradeShipConsume
	local costTankId=0
	local costTankNum=0
	local hasTankNum1=0
	local hasTankNum2=0
	if costTanks and costTanks~="" then
		costTankId=tonumber(Split(costTanks,",")[1]) or 0
		costTankNum=tonumber(Split(costTanks,",")[2]) or 0
		if costTankId>0 then
			hasTankNum1=tankVoApi:getTankCountByItemId(costTankId)
			hasTankNum2=tankVoApi:getTankCountByItemId(costTankId+40000)
			local hasTankNum=hasTankNum1+hasTankNum2
			if hasTankNum<(costTankNum*nums) then
				result=false
			end
		end
	end

	return result,costTankNum*nums-hasTankNum1
end


--id tank的id：10001
function alienTechVoApi:getAlienAddAttr(id)
	--异星科技属性加成
    --精准,闪避,暴击,装甲,攻击力,生命值,暴击伤害增加,暴击伤害减少,防护,击破,增加技能等级
    local accuracy,evade,crit,anticrit,dmg,maxhp,critDmg,decritDmg,armor,arp,skill=0,0,0,0,0,0,0,0,0,0,0
    if base.alien==1 and base.richMineOpen==1 then
        local usedAlienTech=self:getUsedAlienTech()
        local tankid="a"..id
    	if alienTechCfg and alienTechCfg.tankRelationServer then
			for k,v in pairs(alienTechCfg.tankRelationServer) do
				if k==tankid then
					tankid=v
					break
				end
			end
		end
        if usedAlienTech and usedAlienTech[tankid] then
            for k,v in pairs(usedAlienTech[tankid]) do
                if v and type(v)=="string" and alienTechCfg.talent[v] and alienTechCfg.talent[v][alienTechCfg.keyCfg.value] then
                    local valueTb=alienTechCfg.talent[v][alienTechCfg.keyCfg.value]
                    local tLevel=alienTechVoApi:getTechLevel(v)
                    if valueTb and type(valueTb)=="table" and SizeOfTable(valueTb)>0 and tLevel>0 then
                        local value=valueTb[tLevel]
                        if value and type(value)=="table" and SizeOfTable(value)>0 then
                            for i,j in pairs(value) do 
                                local tValue=tonumber(j)
                                if type(i)=="string" and abilityCfg[i] then
                                    skill=tValue
                                else
                                    if i==102 then
                                        accuracy=tValue
                                    elseif i==103 then
                                        evade=tValue
                                    elseif i==104 then
                                        crit=tValue
                                    elseif i==105 then
                                        anticrit=tValue
                                    elseif i==100 then
                                        dmg=tValue
                                    elseif i==108 then
                                        maxhp=tValue
                                    elseif i==110 then
                                        critDmg=tValue
                                    elseif i==111 then
                                        decritDmg=tValue
                                    elseif i==201 then
                                        armor=tValue
                                    elseif i==202 then
                                        arp=tValue
                                    end 
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return accuracy,evade,crit,anticrit,dmg,maxhp,critDmg,decritDmg,armor,arp,skill
end

--异星科技增加技能点数
function alienTechVoApi:getAlienAddSkill(id)
	local abilityID=""
	local abilityLv=0
    if base.alien==1 and base.richMineOpen==1 then
        local addAbilityTb=self:getAddAbilityTb()
        if addAbilityTb and addAbilityTb["a"..id] then
            local techId=addAbilityTb["a"..id]
            if alienTechVoApi:getTechLevel(techId)>0 then
                if alienTechCfg and alienTechCfg.talent and alienTechCfg.talent[techId] and alienTechCfg.talent[techId][alienTechCfg.keyCfg.value] then
                    local valueTb=alienTechCfg.talent[techId][alienTechCfg.keyCfg.value]
                    for k,v in pairs(valueTb[1]) do
                        if abilityID==nil or abilityID=="" then
                            abilityID=k
                        end
                        abilityLv=tonumber(v)
                    end
                end
            end
        end
    end
    return abilityID,abilityLv
end

function alienTechVoApi:getAddAbilityTb()
	if self.addAbilityTb==nil or SizeOfTable(self.addAbilityTb)==0 then
		for k,v in pairs(alienTechCfg.talent) do
			local valueTb=v[alienTechCfg.keyCfg.value]
			local isAdd=false
			if valueTb and SizeOfTable(valueTb)>0 then
				for i,j in pairs(valueTb) do
					if j and type(j)=="table" then
						for m,n in pairs(j) do
							if type(m)=="string" and abilityCfg and abilityCfg[m] then
								isAdd=true
							end
						end
					end
				end
			end
			if isAdd==true then
				-- local tank
				local effectTroops=v[alienTechCfg.keyCfg.effectTroops]
				if type(effectTroops)=="table" then
					-- tank=effectTroops[1]
					for m,n in pairs(effectTroops) do
						self.addAbilityTb[n]=k
						if alienTechCfg and alienTechCfg.tankRelationServer then
							for i,j in pairs(alienTechCfg.tankRelationServer) do
								if j==n then
									self.addAbilityTb[i]=k
								end
							end
						end
					end
				else
					-- tank=effectTroops
					self.addAbilityTb[effectTroops]=k
					if alienTechCfg and alienTechCfg.tankRelationServer then
						for i,j in pairs(alienTechCfg.tankRelationServer) do
							if j==effectTroops then
								self.addAbilityTb[i]=k
							end
						end
					end
				end
				-- self.addAbilityTb[tank]=k
				-- if alienTechCfg and alienTechCfg.tankRelationServer then
				-- 	for i,j in pairs(alienTechCfg.tankRelationServer) do
				-- 		if j==tank then
				-- 			self.addAbilityTb[i]=k
				-- 		end
				-- 	end
				-- end
			end
		end
	end
	return self.addAbilityTb
end

--获取要解锁的位置
function alienTechVoApi:getUnlockSlotIndex(tankId)
	local slotTb,totalPoint=self:getSlotByTank(tankId)
	if slotTb and SizeOfTable(slotTb)>0 then
		for i=1,6 do
			local techId=slotTb[i]
	        if techId and techId==-1 then
	        	return i
	        end
		end
	else
		return 3
	end
end

function alienTechVoApi:getAddAttrStr(attrType)
	if type(attrType)=="string" then
		local name=abilityCfg[attrType][1].name
		return getlocal(name),1
	else
		return G_getPropertyStr(attrType),2
	end
end

function alienTechVoApi:getTechName(tid)
	return getlocal("alien_tech_name_"..tid)
end

function alienTechVoApi:getTechDesc(tid)
	local enableRequireTroopTypeLv=alienTechCfg.talent[tid][alienTechCfg.keyCfg.enableRequireTroopTypeLv]
	return getlocal("alien_tech_desc_t1",{enableRequireTroopTypeLv}),enableRequireTroopTypeLv
end



-------------以下军团赠送-------------

function alienTechVoApi:updateFriendData(sData)
	if sData and sData.data and sData.data.friendgift then
		self.giftAllList={}
		self.giftSendList={}
		self.giftAcceptList={}

		local friendData=sData.data.friendgift
		if(friendData.give)then
			for k,uid in pairs(friendData.give) do
				table.insert(self.giftSendList,uid)
			end
		end
		if(friendData.receive)then
			for k,uid in pairs(friendData.receive) do
				table.insert(self.giftAcceptList,uid)
			end
		end
		if(friendData.giftlist)then
			for k,tb in pairs(friendData.giftlist) do
				table.insert(self.giftAllList,tb[1])
			end
		end
		self.giftRequestFlag=true
	end
end
function alienTechVoApi:initFriend(callback)
	if(base.serverTime<self.giftExpireTime)then
		if(callback)then
			callback()
		end
	else
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				self:updateFriendData(sData)
				self.giftExpireTime=math.min(base.serverTime + 900,self:getNextGiftRefreshTime())
				if(callback)then
					callback()
				end
			end
		end
		socketHelper:alienGift("init",nil,onRequestEnd)
	end
end

function alienTechVoApi:getNextGiftRefreshTime()
	local todayExpire=G_getWeeTs(base.serverTime)+alienTechCfg.giftRefreshTime*3600
	if(base.serverTime<todayExpire)then
		return todayExpire
	else
		return todayExpire + 86400
	end
end

function alienTechVoApi:checkGiftExpired()
	if(base.serverTime>=self.giftExpireTime)then
		return true
	else
		return false
	end
end

--处理后台推送, 有好友给用户送了礼物
--param uidTb: 一个table, 里面是所有给用户送了礼物的好友的uid
function alienTechVoApi:receiveGift(uidTb)
	for k,v in pairs(uidTb) do
		table.insert(self.giftAllList,v)
	end
	eventDispatcher:dispatchEvent("alien.gift.refresh")
end

function alienTechVoApi:getAllGift()
	return self.giftAllList
end

function alienTechVoApi:getGiftSend()
	return self.giftSendList
end

function alienTechVoApi:getGiftAccept()
	return self.giftAcceptList
end

--检查今天是否已经赠送过该好友礼物
--param uid: 要检测的uid
function alienTechVoApi:checkHasSend(uid)
	for k,v in pairs(self.giftSendList) do
		if(tonumber(v)==tonumber(uid))then
			return true
		end
	end
	return false
end

--检查今天是否已经收取过好友礼物
--param uid: 要检测的uid
function alienTechVoApi:checkHasAccept(uid)
	for k,v in pairs(self.giftAcceptList) do
		if(tonumber(v)==tonumber(uid))then
			return true
		end
	end
	return false
end

--检查该好友今天是否给自己送过礼物
--param uid: 要检测的uid
function alienTechVoApi:checkHasGift(uid)
	for k,v in pairs(self.giftAllList) do
		if(tonumber(v)==tonumber(uid))then
			return true
		end
	end
	return false
end

--向指定好友送礼
function alienTechVoApi:sendGift(uid,callback)
	if uid and self:checkHasSend(uid)==false then
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				self:updateFriendData(sData)
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_send_success"),30)
				if(callback)then
					callback()
				end
			end
		end
		local uidTb={uid}
		socketHelper:alienGift("give",uidTb,onRequestEnd)
	end
end

--收取指定好友的礼物
function alienTechVoApi:acceptGift(uid,callback)
	if uid and self:checkHasGift(uid)==true and self:checkHasAccept(uid)==false then
		if self:isAcceptNumMax()==false then
			local function onRequestEnd(fn,data)
				local ret,sData=base:checkServerData(data)
				if ret==true then
					self:updateFriendData(sData)

					if sData and sData.data and sData.data.giftreward then
						local giftreward=sData.data.giftreward or {}
						if giftreward and SizeOfTable(giftreward)>0 then
							local rewardTb=giftreward[1] or {}
							if rewardTb and rewardTb[1] and rewardTb[2] then
								local memUid=rewardTb[1]
								local reward=rewardTb[2]
								if memUid and reward and SizeOfTable(reward)>0 then
									local award=FormatItem(reward)
									for k,v in pairs(award) do
										G_addPlayerAward(v.type,v.key,v.id,v.num)
									end

									local memName=""
									local memTab=allianceMemberVoApi:getMemberTab()
									for k,v in pairs(memTab) do
										if v and v.uid and tonumber(v.uid)==tonumber(memUid) then
											memName=v.name
										end
									end
									local awardStr=G_showRewardTip(award,false,true)
									smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_accept_gift",{memName,awardStr}),30)
								end
							end
						end
					end

					if(callback)then
						callback()
					end
				end
			end
			local uidTb={uid}
			socketHelper:alienGift("receive",uidTb,onRequestEnd)
		end
	end
end

--向所有好友送礼
function alienTechVoApi:sendAllGift(callback)
	local uidTb=self:sendAllUidTb()
	if uidTb and SizeOfTable(uidTb)>0 then
		local function onRequestEnd(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				self:updateFriendData(sData)
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_send_success"),30)
				if(callback)then
					callback()
				end
			end
		end
		socketHelper:alienGift("give",uidTb,onRequestEnd)
	end
end

--收取所有好友的礼物
function alienTechVoApi:acceptAllGift(callback)
	if self:isAcceptNumMax()==false then
		local uidTb=self:acceptAllUidTb()
		if uidTb and SizeOfTable(uidTb)>0 then
			local function onRequestEnd(fn,data)
				local ret,sData=base:checkServerData(data)
				if ret==true then
					self:updateFriendData(sData)

					local rewardStr=""
					if sData and sData.data and sData.data.giftreward then
						local giftreward=sData.data.giftreward
						if giftreward and SizeOfTable(giftreward)>0 then
							for k,v in pairs(giftreward) do
								if v and v[1] and v[2] and SizeOfTable(v[2])>0 then
									local memUid=v[1]
									local reward=v[2]
									local award=FormatItem(reward)
									for m,n in pairs(award) do
										G_addPlayerAward(n.type,n.key,n.id,n.num)
									end

									local memName=""
									local memTab=allianceMemberVoApi:getMemberTab()
									for m,n in pairs(memTab) do
										if n and n.uid and tonumber(n.uid)==tonumber(memUid) then
											memName=n.name
										end
									end
									local awardStr=G_showRewardTip(award,false,true)
									local str=getlocal("alien_tech_accept_gift",{memName,awardStr})
									if rewardStr=="" then
										rewardStr=str
									else
										rewardStr=rewardStr.."\n"..str
									end
								end
							end
							-- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr,30)
						end
					end

					if(callback)then
						callback(rewardStr)
					end
				end
			end
			socketHelper:alienGift("receive",uidTb,onRequestEnd)
		end
	end
end

--收取数量是否达到上限
function alienTechVoApi:isAcceptNumMax()
	if self.giftAcceptList then
		if SizeOfTable(self.giftAcceptList)<alienTechCfg.rewardlimit then
			return false
		end
		return true
	end
	return false
end

--是否能赠送全部
function alienTechVoApi:sendAllUidTb()
	local uidTb={}
	local memTab=allianceMemberVoApi:getMemberTab()
	local flag=self:getGiftRequestFlag()
	if memTab and SizeOfTable(memTab)>0 and flag==true then
		for k,v in pairs(memTab) do
			if v and v.uid and tonumber(v.uid)~=tonumber(playerVoApi:getUid()) then
				if self:checkHasSend(v.uid)==false then
					table.insert(uidTb,v.uid)
				end
			end
		end
	end
	return uidTb
end

--是否能接受全部
function alienTechVoApi:acceptAllUidTb()
	local uidTb={}
	local acceptNum=0
	if self.giftAcceptList then
		acceptNum=SizeOfTable(self.giftAcceptList)
	end
	local memTab=allianceMemberVoApi:getMemberTab()
	local flag=self:getGiftRequestFlag()
	if memTab and SizeOfTable(memTab)>0 and flag==true then
		for k,v in pairs(memTab) do
			if v and v.uid and tonumber(v.uid)~=tonumber(playerVoApi:getUid()) then
				if self:checkHasGift(v.uid)==true and self:checkHasAccept(v.uid)==false then
					if acceptNum+SizeOfTable(uidTb)<alienTechCfg.rewardlimit then
						table.insert(uidTb,v.uid)
					end
				end
			end
		end
	end
	return uidTb
end

-------------以上军团赠送-------------

--根据技能判断，是否显示xx改坦克
function alienTechVoApi:getIsShowTankGaiBySid(techId)
	if techId then
		if alienTechCfg and alienTechCfg.talent and alienTechCfg.talent[techId] then
			local techCfg=alienTechCfg.talent[techId]
			local talentType=techCfg[alienTechCfg.keyCfg.talentType]
			if talentType and talentType~=3 and techCfg[alienTechCfg.keyCfg.effectTroops] then
				local tanks={}
				local effectTroops=G_clone(techCfg[alienTechCfg.keyCfg.effectTroops])
				if type(effectTroops)=="string" then
					tanks={effectTroops}
				else
					tanks=effectTroops
				end
				local isShowGai,tankGaiId=self:getIsShowTankGai(tanks)
				if isShowGai==true and tankGaiId then
					return true,tankGaiId
				end
			end
		end
	end
	return false
end
--根据坦克判断，是否显示xx改坦克 tanks={"a10001","a10002"}
function alienTechVoApi:getIsShowTankGai(tanks)
	if tanks and SizeOfTable(tanks)>0 then
		if alienTechCfg and alienTechCfg.tankRelationServer then
			for k,v in pairs(alienTechCfg.tankRelationServer) do
				local id=(tonumber(k) or tonumber(RemoveFirstChar(k)))
				if id<50000 then
					for m,n in pairs(tanks) do
						if v and v==n then
							if id and tankCfg[id] and self:getIsShowTank({k})==true then
								return true,k
							end
						end
					end
				end
			end
		end
	end
	return false
end

-- 所有能还原的精英坦克
function alienTechVoApi:getAllReductionTank()
	local allTank = tankVoApi:getAllTanks()
	local allReductionTank = {}

	for k,v in pairs(allTank) do
		if G_pickedList(tonumber(k))~=tonumber(k) then
			table.insert(allReductionTank,{k,v[1]})
		end
	end
	local function sortFunc(a,b)
		local aid=(tonumber(a[1]) or tonumber(RemoveFirstChar(a[1])))
		local bid=(tonumber(b[1]) or tonumber(RemoveFirstChar(b[1])))
		return aid<bid
	end
	table.sort(allReductionTank,sortFunc)

	return allReductionTank
end

function alienTechVoApi:isCanGatherAlienRes()
	local gatherFlag=false
	local myLv=playerVoApi:getPlayerLevel()
	if base.alien==1 and base.landFormOpen==1 and myLv>=alienTechCfg.openlevel then
		gatherFlag=true
	end
	return gatherFlag
end

function alienTechVoApi:getAlienGatherUpByType(resType)
	local max=0
	if resType then
	    local acVo = activityVoApi:getActivityVo("alienbumperweek")
	    local vo=activityVoApi:getActivityVo("yichujifa")
	    local maxLv=alienTechCfg.resource[resType].maxLv
	    max=maxLv*playerVoApi:getPlayerLevel()
	    local addUpp=0
	    if vo and activityVoApi:isStart(vo)==true then
	        addUpp=acImminentVoApi:getUpperLimit()/100*max
	    end
	    if acVo and activityVoApi:isStart(acVo)==true then
	        local rate = acAlienbumperweekVoApi:getResRate()
	        max=max*rate
	    end
	    if addUpp>0 then
	        max=max+addUpp
	    end
	end
    return max
end

-- 是否有异星科技可以升级
function alienTechVoApi:isCanUpdate()

	local treeCfg=self:getTreeCfg()
	if treeCfg and SizeOfTable(treeCfg)>0 then
	else
		do return false end
	end
	local allTech=self:getAllAlienTech()
	for k,v in pairs(treeCfg) do
		local tech=v.tech
		for kk,vv in pairs(tech) do
			if vv~=0 then
				local tCfg=alienTechCfg.talent[vv]
				local maxLv=tCfg[alienTechCfg.keyCfg.maxLv]
				local curLv=allTech[vv] or 0
				if curLv<maxLv then
					return false
				end
			end
		end
	end
	return true
	
end

function alienTechVoApi:getFriendRequest(callback)
	local cmd="alien.gift"
	local params={action="init"}
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			self:updateFriendData(sData)
			if callback then
				callback()
			end
		end
	end
	local callback=onRequestEnd
	return cmd,params,callback
end

function alienTechVoApi:getGiftRequestFlag()
	return self.giftRequestFlag
end

function alienTechVoApi:acceptAllGiftHandler(acceptCallBack)
	local function realAccept()
		local function callback(rewardStr)
			if rewardStr and rewardStr~="" then
				smallDialog:showTableViewSure("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),rewardStr,true,8,nil,true)
			end
			if acceptCallBack then
				acceptCallBack()
			end
		end
		self:acceptAllGift(callback)
	end
	self:initFriend(realAccept)
end

-- 新增buffer
function alienTechVoApi:showBufferDialog(layerNum,istouch,isuseami,titleStr,category,tid)
	require "luascript/script/game/scene/gamedialog/alienTechDialog/alienBufferSmallDialog"
	alienBufferSmallDialog:showalienBuffer(layerNum,istouch,isuseami,titleStr,category,tid)
end

function alienTechVoApi:getBufferLv(tid,selectIndex)
	
	local level=0
    local subTime=0

    if selectIndex then
    else
    	local treeCfg=alienTechVoApi:getTreeCfg()
    	if treeCfg then
    		for index,value in pairs(treeCfg) do
    			for id,Tid in pairs(value.desc) do
    				if Tid==tid then
    					selectIndex=index
    					break
    				end
    			end
			end
    	end
    	
    end
	if selectIndex then
		local bufftree=alienTechCfg.bufftree
	    local bufferValue=bufftree[tid]
	    if bufferValue then
		    local point=alienTechVoApi:getPointByType(selectIndex)
		    
		    for k,v in pairs(bufferValue) do
		    	local isUnlock=alienTechVoApi:getTechIsUnlock(v[3],selectIndex,true)
		    	print("isUnlock",v[3],selectIndex,isUnlock)
		    	if isUnlock and point>=v[2] then
		    		level=k
		    		subTime=v[1]
		    	end
		    end
		end
	end
	return level,subTime
end

--异星科技建筑特效
function alienTechVoApi:createAlienTechBase(callback)
	local buildSp
	local animSpTb = {}
	if G_getGameUIVer() == 2 then
		--建筑底座
	    local basePic = "alien_tech_building_1.png"
		if callback and type(callback) == "table" then
		    buildSp = LuaCCSprite:createWithSpriteFrameName(basePic, callback)
		else
		    buildSp = CCSprite:createWithSpriteFrameName(basePic)
		end

	    --建筑球形顶
	    local ballSp = CCSprite:createWithSpriteFrameName("alienTech_ball.png")
	    ballSp:setPosition(getCenterPoint(buildSp))
	    buildSp:addChild(ballSp, 2)
	    table.insert(animSpTb, ballSp)

	    --建筑底座特效
	    local baseLightSp = CCSprite:createWithSpriteFrameName("alienTech_light1.png")
	    baseLightSp:setPosition(80,86.5)
	    buildSp:addChild(baseLightSp)
	    table.insert(animSpTb, baseLightSp)
		G_playFrame(baseLightSp,{frmn=20,frname="alienTech_light",perdelay=0.05,forever={0,0},blendType=1})

		local startPos = ccp(80.5, 120.5)

		--建筑后光圈
	    local backCircelSp = CCSprite:createWithSpriteFrameName("alienTech_bcircel.png")
	    backCircelSp:setPosition(startPos)
	    buildSp:addChild(backCircelSp)
	    table.insert(animSpTb, backCircelSp)

	    --建筑前光圈
	    local frontCircelSp = CCSprite:createWithSpriteFrameName("alienTech_fcircel.png")
	    frontCircelSp:setPosition(startPos)
	    buildSp:addChild(frontCircelSp, 4)
	    table.insert(animSpTb, frontCircelSp)

		--建筑光圈
	    local licircelSp = CCSprite:createWithSpriteFrameName("alienTech_licircel.png")
	    licircelSp:setPosition(startPos)
	    buildSp:addChild(licircelSp)
	    G_playBlendGL(licircelSp, GL_ONE, GL_ONE)
	    table.insert(animSpTb, licircelSp)

	    --浮动动画
	    local function circelAnim(animSp, fade)
	    	local down = CCEaseSineInOut:create(CCMoveBy:create(1.5, ccp(0, -4)))
	    	local up = CCEaseSineInOut:create(CCMoveBy:create(1.5, ccp(0, 4)))
	    	if fade == true then
	    		local fadeIn = CCFadeIn:create(1.5)
		    	local fadeOut = CCFadeOut:create(1.5)
		    	local arr1 = CCArray:create()
		    	arr1:addObject(down)
	    		arr1:addObject(fadeOut)
	    		local arr2 = CCArray:create()
		    	arr2:addObject(up)
	    		arr2:addObject(fadeIn)
		    	local spawnOut = CCSpawn:create(arr1)
		    	local spawnIn = CCSpawn:create(arr2)
		    	animSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(spawnOut, spawnIn)))
		    else
		    	animSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(down, up)))
	    	end
	    end
	    circelAnim(backCircelSp)
	    circelAnim(frontCircelSp)
	    circelAnim(licircelSp, true)
	else
		local playSpeed = 0.1
	    local stIndex = math.ceil((deviceHelper:getRandom()/100)*9)
	    if stIndex == 0 then
	        stIndex = 1
	    end
	    local basePic = "alien_tech_building_"..stIndex..".png"
	    if callback and type(callback) == "table" then
		    buildSp = LuaCCSprite:createWithSpriteFrameName(basePic, callback)
		else
		    buildSp = CCSprite:createWithSpriteFrameName(basePic)
		end
		local animArr = CCArray:create()
	    for kk=stIndex+1, 15 do
	        local nameStr="alien_tech_building_"..kk..".png"
	        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	        animArr:addObject(frame)
	    end
	    for kk=1, stIndex do
	        local nameStr="alien_tech_building_"..kk..".png"
	        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	        animArr:addObject(frame)
	    end
	    local animation=CCAnimation:createWithSpriteFrames(animArr)
		animation:setDelayPerUnit(playSpeed)
		local animate=CCAnimate:create(animation)
		local repeatForever=CCRepeatForever:create(animate)
		buildSp:runAction(repeatForever)
	end
	table.insert(animSpTb, buildSp)
	
	return buildSp, animSpTb
end


function alienTechVoApi:clear()
    self:clearTechData()
    self.pointTb={}
	self.treeCfg={}
    self.flag=-1
    self.canTransformCommonTb={}
	self.canTransformSpecialTb={}
	self.allCanTransformCommonTb={}
	self.canTransformTankIdTb = {}
	self.produceSpeedUpTb={}
	self.addAbilityTb={}
	self.alienResource={}
	self.alienDailyResource={}
	self.resFlag=1
	self.resDailyFlag=1

	self.giftExpireTime=0
	self.giftAllList={}
	self.giftSendList={}
	self.giftAcceptList={}
	self.giftRequestFlag=false
end

