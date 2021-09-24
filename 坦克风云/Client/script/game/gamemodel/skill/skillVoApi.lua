--技能的voapi
skillVoApi={
	allSkills={},
	eagleEyeTime=nil,	--上次触发鹰眼技能的时间
	eagleEyePos=nil,	--鹰眼技能侦察到的坐标
	changeTs=0,			--上次进行勋章兑换的时间戳
}

--初始化所有技能
function skillVoApi:init()
	for sid,cfg in pairs(playerSkillCfg.skillList) do
		local sVo=skillVo:new(sid)
		sVo:initWithData(0)
		self.allSkills[sid]=sVo
	end
end

--更新技能数据
function skillVoApi:update(lvTab)
	 for sid,lv in pairs(lvTab) do
	 	if(sid=="buy_at")then
	 		self.changeTs=tonumber(lv)
	 	else
		 	local sVo=self.allSkills[sid]
		 	if(sVo)then
	 			sVo:initWithData(lv)
	 		end
	 	end
	 end
end

--获取所有技能的skillVo
function skillVoApi:getAllSkills()
	return self.allSkills
end

--根据sid获取某个技能在某个等级的的加成数值
--param id: 技能ID
--param lv: 技能等级，不传的话默认取技能当前等级的加成数
function skillVoApi:getSkillAddPerById(id,lv)
	if(id==nil or self.allSkills[id]==nil)then
		return 0
	end
	if(lv==nil)then
		lv=self.allSkills[id].lv
	end
	--鹰眼技能特殊处理
	if(id=="s301")then
		local skillValue=self.allSkills[id].cfg.skillValue
		return self.allSkills[id].cfg.skillCooldown,self.allSkills[id].cfg.skillRange + lv*skillValue
	end
	if(self.allSkills[id])then
		local skillValue=self.allSkills[id].cfg.skillValue
		if(skillValue)then
			return skillValue*lv
		elseif(self.allSkills[id].cfg.getNewSkill)then
			local abilityID=self.allSkills[id].cfg.getNewSkill
			local aCfg=abilityCfg[abilityID]
			if(aCfg and aCfg[lv])then
				return aCfg[lv].value1,aCfg[lv].value2
			else
				return 0
			end
		else
			return 0
		end
	else
		return 0
	end
end

--获取技能加成数值的文字表示，主要是该加百分号的加百分号
function skillVoApi:getSkillAddPerStrById(id,lv)
	if(lv==nil)then
		lv=self.allSkills[id].lv or 0
	end
	--鹰眼技能特殊处理
	if(id=="s301")then
		local skillValue=self.allSkills[id].cfg.skillValue
		return self.allSkills[id].cfg.skillCooldown,self.allSkills[id].cfg.skillRange + lv*skillValue
	end
	if(self.allSkills[id])then
		local skillValue=self.allSkills[id].cfg.skillValue
		if(skillValue)then
			local attributeType=self.allSkills[id].cfg.attributeType
			if(attributeType and (attributeType==201 or attributeType==202))then
				return skillValue*lv
			else
				return (skillValue*lv*100).."%"
			end
		elseif(self.allSkills[id].cfg.getNewSkill)then
			local abilityID=self.allSkills[id].cfg.getNewSkill
			local aCfg=abilityCfg[abilityID]
			if(aCfg and aCfg[lv])then
				local value1=aCfg[lv].value1
				if(value1)then
					value1=(value1*100).."%"
				end
				local value2=aCfg[lv].value2
				if(value2)then
					value2=(value2*100).."%"
				end
				return value1,value2
			else
				return 0
			end
		else
			return 0
		end
	else
		return 0
	end
end

--获取某个技能升级需要的玩家等级
--param id: 技能的id
--param lv: 要升级到的等级，如果不传的话默认就是当前技能等级+1
--return 需要的等级数
function skillVoApi:getLvRequireByIdAndLv(id,lv)
	if(self.allSkills[id])then
		local lvRequire=self.allSkills[id].cfg.levelRequire
		if(lvRequire==nil)then
			return 0
		end
		if(lv)then
			return lvRequire*lv
		else
			local curLv=self.allSkills[id].lv
			return lvRequire*(curLv + 1)
		end
	else
		return 0
	end
end

--获取某个技能升级需要的道具
--param id: 技能的id
--param lv: 要升级到的等级，如果不传的话默认就是当前技能等级+1
--return 一个table，table的key是各个道具的id，value是道具的数目
function skillVoApi:getPropRequireByIdAndLv(id,lv)
	if(self.allSkills[id])then
		local data=self.allSkills[id]
		local needProp
		local flag=false
		if(data.cfg.relationSkill)then			
			for k,relationID in pairs(data.cfg.relationSkill) do
				if(relationID~=id)then
					local sVo=self.allSkills[relationID]
					if(sVo.lv>0)then
						flag=true
						break
					end
				end
			end
		end
		if(flag)then
			needProp=self.allSkills[id].cfg.needPropID2
		else
			needProp=self.allSkills[id].cfg.needPropID1
		end
		local toLv
		if(lv)then
			toLv=lv
		else
			toLv=self.allSkills[id].lv + 1
		end
		local result={}
		if(needProp)then
			for propID,paramTb in pairs(needProp) do
				local needNum=toLv*paramTb[1] + paramTb[2]
				result[propID]=needNum
			end
		end
		return result
	else
		return {}
	end
end

--返回技能等级最低的，相等则返回id较小的
function skillVoApi:getMinLvSkillId()
	local minID,minLv
	for sid,sVo in pairs(self.allSkills) do
		if(minLv==nil or sVo.lv<minLv)then
			minID=sid
			minLv=sVo.lv
		elseif(sVo.lv==minLv)then
			if(tonumber(RemoveFirstChar(sid))<tonumber(RemoveFirstChar(minID)))then
				minID=sid
				minLv=sVo.lv
			end
		end
	end
	local sVo=skillVo:new(minID)
	sVo:initWithData(minLv)
	return sVo
end

--根据技能ID获取技能名称
function skillVoApi:getSkillNameById(id)
	return self.allSkills[id].cfg.name
end

--是否所有技能都是0级
function skillVoApi:getSkillIsAllZero()
	local isAllZero=true
	for sid,sVo in pairs(self.allSkills) do
		if sVo.lv>0 then
			isAllZero=false
			break
		end
	end
	return isAllZero
end

--根据坦克的type获取分在该类坦克下的技能
--param tankType: 1,2,4,8是四种坦克，0是通用技能
function skillVoApi:getSkillListByType(tankType)
	local skillList={}
	for sid,sVo in pairs(self.allSkills) do
		if(sVo.cfg.skillType==tankType)then
			skillList[sid]=sVo
		end
	end
	return skillList
end

--检查某个技能是否可以升级
--param sid: 要升级的sid
--return 0: 可以升级
--return 1: 道具不足
--return 2: 等级不足
--return 3: 等级已满
--return 4: 前置技能等级不足
--return 5: 当前有另一个三级技能没有升满，无法开始升第二个三级技能
function skillVoApi:checkCanUpgrade(sid)
	local data=self.allSkills[sid]
	local maxLevel=skillVoApi:getSkillMaxLv(sid)
	local addValue = strategyCenterVoApi:getAttributeValue(13)
	if addValue and addValue > 0 and data.cfg.nblv == 1 then
		maxLevel = maxLevel + addValue
	end
	if(data.lv>=maxLevel)then
		return 3
	end
	local needProp=skillVoApi:getPropRequireByIdAndLv(sid)
	for pid,num in pairs(needProp) do
		local numID=tonumber(RemoveFirstChar(pid))
		if(bagVoApi:getItemNumId(numID)<num)then
			return 1
		end
	end
	local lvNeed=skillVoApi:getLvRequireByIdAndLv(sid)
	local playerLv = playerVoApi:getPlayerLevel()
	if addValue and addValue > 0 and data.cfg.nblv == 1 and playerLv == playerVoApi:getMaxLvByKey("roleMaxLevel") then
		playerLv = playerLv + addValue
	end
	if(playerLv<lvNeed)then
		return 2
	end
	local needSkillID=data.cfg.needSkillID
	if(needSkillID)then
		for sid,paramTb in pairs(needSkillID) do
			local preSkill=self.allSkills[sid]
			local needLv=(data.lv + 1)*paramTb[1] + paramTb[2]
			if(preSkill.lv<needLv)then
				return 4
			end
		end
	end
	if(data.cfg.relationSkill)then
		for k,relationID in pairs(data.cfg.relationSkill) do
			if(relationID~=sid)then
				local sVo=self.allSkills[relationID]
				if(sVo.lv>0 and sVo.lv<skillVoApi:getSkillMaxLv(relationID))then
					return 5
				end
			end
		end
	end
	return 0
end

--获取某个技能最多可以升多少级
--return 该技能可以升几级
--return 升级总共需要的道具数目
function skillVoApi:getSkillUpLv(sid)
	local data=self.allSkills[sid]
	local maxLv=math.min(playerVoApi:getPlayerLevel(),skillVoApi:getSkillMaxLv(sid))
	local addValue = strategyCenterVoApi:getAttributeValue(13)
	if addValue and addValue > 0 and data.cfg.nblv == 1 and playerVoApi:getPlayerLevel() == playerVoApi:getMaxLvByKey("roleMaxLevel") then
		maxLv = maxLv + addValue
	end
	local result=maxLv - data.lv
	local needProp
	local flag=false
	if(data.cfg.relationSkill)then			
		for k,relationID in pairs(data.cfg.relationSkill) do
			if(relationID~=sid)then
				local sVo=self.allSkills[relationID]
				if(sVo.lv>0)then
					flag=true
					break
				end
			end
		end
	end
	if(flag)then
		needProp=self.allSkills[sid].cfg.needPropID2
	else
		needProp=self.allSkills[sid].cfg.needPropID1
	end
	local minPropLv=result
	for propID,paramTb in pairs(needProp) do
		local a=paramTb[1]
		local b=paramTb[2]
		local propNumID=tonumber(RemoveFirstChar(propID))
		for x=1,minPropLv do
			--根据公式计算出来的，升x级需要的道具数目, a(l+1)+b+a(l+2)+b+a(l+3)+b+...+a(l+x)+b<=n
			local propNum=a*data.lv*x + a*x*x/2 + a*x/2 + b*x
			if(propNum>bagVoApi:getItemNumId(propNumID))then
				minPropLv=x - 1
				break
			end
		end
	end
	local resultProp={}
	for propID,paramTb in pairs(needProp) do
		local a=paramTb[1]
		local b=paramTb[2]
		local propNum=a*data.lv*minPropLv + a*minPropLv*minPropLv/2 + a*minPropLv/2 + b*minPropLv
		resultProp[propID]=propNum
	end
	result=minPropLv
	local minNeedSLv=result
	local needSkillID=data.cfg.needSkillID
	if(needSkillID)then
		for sid,paramTb in pairs(needSkillID) do
			local a=paramTb[1]
			local b=paramTb[2]
			for x=1,minNeedSLv do
				local needLv=a*(data.lv + x) + b
				if(self.allSkills[sid].lv<needLv)then
					minNeedSLv=x - 1
					break
				end
			end
		end
	end
	result=minNeedSLv
	--如果minNeedSLv比minPropLv小，那么升级所需的道具就得重新用新的等级重新算一下
	if(result<minPropLv)then
		resultProp={}
		for propID,paramTb in pairs(needProp) do
			local a=paramTb[1]
			local b=paramTb[2]
			local propNum=a*data.lv*result + a*result*result/2 + a*result/2 + b*result
			resultProp[propID]=propNum
		end
	end
	return result,resultProp
end

--根据技能ID获取技能图标
--有些新技能图标是拼起来的
function skillVoApi:getSkillIconById(sid)
	local data=self.allSkills[sid]
	local skillIcon=CCSprite:createWithSpriteFrameName(data.cfg.background)
	if(data.cfg.frame)then
		local frame=CCSprite:createWithSpriteFrameName(data.cfg.frame)
		frame:setPosition(getCenterPoint(skillIcon))
		skillIcon:addChild(frame)
	end
	if(data.cfg.picture)then
		local picture=CCSprite:createWithSpriteFrameName(data.cfg.picture)
		picture:setPosition(getCenterPoint(skillIcon))
		skillIcon:addChild(picture)
	end
	if(data.cfg.mark)then
		local mark=CCSprite:createWithSpriteFrameName(data.cfg.mark)
		mark:setPosition(skillIcon:getContentSize().width*0.75,skillIcon:getContentSize().height/4)
		skillIcon:addChild(mark)
	end
	return skillIcon
end

--获取技能的最大等级
function skillVoApi:getSkillMaxLv(sid)
	local maxLvByRole
	local playerMaxLv=playerVoApi:getMaxLvByKey("roleMaxLevel")
	local lvRequire=self.allSkills[sid].cfg.levelRequire
	if(lvRequire)then
		maxLvByRole=math.floor(playerMaxLv/lvRequire)
	end
	local needSkillID=self.allSkills[sid].cfg.needSkillID
	if(needSkillID)then
		for needID,paramTb in pairs(needSkillID) do
			local needMax=skillVoApi:getSkillMaxLv(needID)
			local tmpMax=math.floor(needMax - paramTb[2])/paramTb[1]
			if(maxLvByRole==nil or maxLvByRole>tmpMax)then
				maxLvByRole=tmpMax
			end
		end
	end
	if(maxLvByRole)then
		return math.min(self.allSkills[sid].cfg.maxLevel,maxLvByRole)
	else
		return self.allSkills[sid].cfg.maxLevel
	end
end

--鹰眼技能是否已经初始化
function skillVoApi:checkEagleEyeInit()
	if(base.nbSkillOpen==0)then
		return true
	end
	local sVo=self.allSkills["s301"]
	local hasSkill=(sVo and sVo.lv>0)
	--如果技能没有升级就不需要数据，就当已经初始化过了
	if(not hasSkill)then
		return true
	elseif(self.eagleEyeTime==nil)then
		return false
	else
		return true
	end
end

--鹰眼技能是否在CD中
function skillVoApi:checkEagleEyeCD()
	if(self.eagleEyeTime==nil or base.nbSkillOpen==0)then
		return true
	end
	if(base.serverTime>=self.eagleEyeTime + playerSkillCfg.skillList["s301"].skillCooldown*3600)then
		return false
	end
	return true
end

--当前是否可以兑换道具
--param pid: 要兑换的道具，目前只有p3302
function skillVoApi:checkPropCanChange(pid)
	if(playerSkillCfg.getPropList[pid]==nil or playerSkillCfg.getPropList[pid].coolDown==nil)then
		return false
	end
	local cdTime=tonumber(playerSkillCfg.getPropList[pid].coolDown)
	if(self.changeTs==nil or self.changeTs + cdTime<=base.serverTime)then
		return true
	else
		return false
	end
end

--获取兑换道具的CD时间
--param pid: 要兑换的道具，目前只有p3302
function skillVoApi:getChangeCD(pid)
	if(playerSkillCfg.getPropList[pid]==nil or playerSkillCfg.getPropList[pid].coolDown==nil or self.changeTs==nil)then
		return 0
	end
	return self.changeTs + playerSkillCfg.getPropList[pid].coolDown
end

--检查某个坐标是否被鹰眼侦察出来了
function skillVoApi:checkBaseScout(x,y)
	if(self.eagleEyePos and x==self.eagleEyePos[1] and y==self.eagleEyePos[2])then
		local dataKey="eagleEyeRemove@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
		--侦察过之后如果已经可以移除了就往本地记一次本次移除的技能触发时间
		if(CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)==self.eagleEyeTime)then
			return false
		else
			return true
		end
	end
	return false
end

function skillVoApi:getEagleEyeTime()
	return self.eagleEyeTime
end

function skillVoApi:getEagleEyePos()
	if(self.eagleEyePos and self.eagleEyePos[1] and self.eagleEyePos[2])then
		local dataKey="eagleEyeRemove@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
		if(CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)==self.eagleEyeTime)then
			return nil
		else
			return self.eagleEyePos
		end
	end
	return nil
end

--升级技能
--param sid: 要升级的技能ID，s101，s102
--param targetLv: 要升到的目标等级
function skillVoApi:upgrade(sid,targetLv,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if(callback)then
				callback()
			end

			local skillCfg=playerSkillCfg.skillList[sid]
			if skillCfg.nblv==3 then
                -- 1:玩家名称  2:活动名称 3:等级 4:奖励 5:技能名称
				local params = {key="skillUpgradeMessage",param={{playerVoApi:getPlayerName(),1},{skillCfg.name,5},{targetLv,3}}}
		        chatVoApi:sendUpdateMessage(41,params)
			end
		end
	end
	local numID=tonumber(RemoveFirstChar(sid))
	if(targetLv==nil)then
		targetLv=self.allSkills[sid].lv + 1
	end
	socketHelper:upgradeSkill(numID,targetLv,onRequestEnd)
end

--重置技能，退还消耗的荣誉勋章
function skillVoApi:reset(callback)
	local function onRequestEnd(fn,data)
		if base:checkServerData(data)==true then
			for sid,sVo in pairs(self.allSkills) do
				sVo:initWithData(0)
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:resetSkill(onRequestEnd)
end

--自动升级
function skillVoApi:autoUpgrade(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if(callback)then
				callback()
			end
			if sData and sData.data and sData.data.skills then
				for k,v in pairs(sData.data.skills) do
					local skillCfg=playerSkillCfg.skillList[k]
					if skillCfg.nblv==3 then
		                -- 1:玩家名称  2:活动名称 3:等级 4:奖励 5:技能名称
						local params = {key="skillUpgradeMessage",param={{playerVoApi:getPlayerName(),1},{skillCfg.name,5},{v,3}}}
				        chatVoApi:sendUpdateMessage(41,params)
					end
				end
			end
		end
	end
	socketHelper:autoUpdateSkill(onRequestEnd)
end

--获取鹰眼数据
function skillVoApi:getEagleEyeData(callback)
	--为了防止一直不停请求，所以发请求的时候就加一个10秒钟的过期时间
	self.eagleEyeTime=base.serverTime - playerSkillCfg.skillList["s301"].skillCooldown*3600 + 10
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.eagleEyeMap then
				skillVoApi:formatEagleEyeData(sData.data.eagleEyeMap)
			end
			if(callback)then
				callback()
			end
		else
			self.eagleEyeTime=base.serverTime + 300
		end
	end
	socketHelper:skillEagleEye(onRequestEnd)
end

function skillVoApi:formatEagleEyeData(data)
	local time=tonumber(data[1])
	local posX=tonumber(data[2])
	local posY=tonumber(data[3])
	self.eagleEyeTime=time
	self.eagleEyePos={posX,posY}
	eventDispatcher:dispatchEvent("skill.eagleeye.change")
end

--道具兑换
function skillVoApi:changeProp(pid,callback)
	local function onRequestEnd(fn,data)
		if base:checkServerData(data)==true then
			--兑换接口里面没反时间戳，所以前台自己写一下
			if(self:checkPropCanChange(pid))then
				self.changeTs=base.serverTime
			end
			local costGems=playerSkillCfg.getPropList[pid].costGem
			if(costGems and costGems>0)then
				playerVoApi:setGems(playerVoApi:getGems() - costGems)
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:skillGetProp(pid,onRequestEnd)
end

function skillVoApi:clear()
	if self.allSkills~=nil then
		for k,v in pairs(self.allSkills) do
			self.allSkills[k]=nil
		end
		self.allSkills=nil
	end
	self.allSkills={}
	self.eagleEyeTime=nil
	self.eagleEyePos=nil
	self.changeTs=0
end