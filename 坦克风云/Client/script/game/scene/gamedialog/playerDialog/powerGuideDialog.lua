powerGuideDialog=commonDialog:new()

function powerGuideDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.cellTb={}
	self.cellNum=9
	self.tickIndex=0
	self.cellInitIndex=0
	self.percentTb={}
	return nc
end

function powerGuideDialog:initTableView()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-230))
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
	self:initDown()
end

function powerGuideDialog:initUp()
	-- local maxPower=tankVoApi:getPlayerPowerLimit()
	local power=playerVoApi:getPlayerPower()
	local powerLb=GetTTFLabel(getlocal("showAttackRank")..": "..power.." ("..FormatNumber(power)..")",25)
	powerLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-100))
	self.bgLayer:addChild(powerLb)

	local maxPowerDescLb=GetTTFLabel(getlocal("powerGuide_maxPower"),25)
	maxPowerDescLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-135))
	self.bgLayer:addChild(maxPowerDescLb)

	local percent=0
	local length=#self.percentTb
	for i=1,length do
		percent=percent+self.percentTb[i]/(length*100)
	end
	percent=percent*100
	if(percent>100)then
		percent=100
	end
	AddProgramTimer(self.bgLayer,ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-180),823,nil,nil,"VipIconYellowBarBg.png","xpBar.png",824)
	local powerBar = tolua.cast(self.bgLayer:getChildByTag(823),"CCProgressTimer")
	powerBar:setScaleX(395/powerBar:getContentSize().width)
	powerBar:setScaleY(30/powerBar:getContentSize().height)
	powerBar:setPercentage(percent)
	local powerBarBg = tolua.cast(self.bgLayer:getChildByTag(824),"CCSprite")
	powerBarBg:setScaleX(400/powerBarBg:getContentSize().width)
	powerBarBg:setScaleY(40/powerBarBg:getContentSize().height)

	local percentLb=GetTTFLabel(string.format("%.2f",percent).."%",25)
	percentLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-180))
	self.bgLayer:addChild(percentLb,2)
end

function powerGuideDialog:initDown()
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-270),nil)
	tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	tv:setPosition(ccp(30,40))
	tv:setMaxDisToBottomOrTop(110)
	self.bgLayer:addChild(tv,1)
end

function powerGuideDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.cellNum
	elseif fn=="tableCellSizeForIndex" then
		local cellHeight = 180
		if G_getCurChoseLanguage() =="ru" then
			cellHeight =260
		end
		return  CCSizeMake(G_VisibleSizeWidth-60,cellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		self.cellTb[idx+1]=cell
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function powerGuideDialog:fastTick()
	self.tickIndex=self.tickIndex+1
	if(self.tickIndex%5==0)then
		self.cellInitIndex=self.cellInitIndex+1
		if(self.cellTb[self.cellInitIndex])then
			local backSprie=self:getCell(self.cellInitIndex-1)
			self.cellTb[self.cellInitIndex]:addChild(backSprie)
		end
	end
	if(self.cellInitIndex>=self.cellNum)then
		self:initUp()
		base:removeFromNeedRefresh(self)
	end
end

function powerGuideDialog:getCell(idx)
	local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function () end)
	local bspHeight = 175
	if G_getCurChoseLanguage() =="ru" then
		bspHeight =255
	end
	backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, bspHeight))
	backSprie:ignoreAnchorPointForPosition(false)
	backSprie:setAnchorPoint(ccp(0,0))
	backSprie:setPosition(ccp(0,0))
	backSprie:setTouchPriority(-(self.layerNum-1)*20-1)

	local icon
	local upStr
	local downStr
	local percent
	local clickable
	local function onClickIcon(object,fn,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		local id=tag-5180
		self:showCellTip(id)
	end
	if(idx==0)then
		icon=LuaCCSprite:createWithSpriteFrameName("item_shuji_04.png",onClickIcon)
		icon:setScale(100/icon:getContentSize().width)
		percent=playerVoApi:getTroops()/playerVoApi:getPlayerLevel()*100
		upStr=getlocal("powerGuide_leaderPercent",{""})
		downStr=getlocal("powerGuide_leftLeader",{bagVoApi:getItemNumId(20)})
		if(playerVoApi:getTroops()>=playerVoApi:getPlayerLevel())then
			clickable=false
		else
			clickable=true
		end
	elseif(idx==1)then
		icon=LuaCCSprite:createWithSpriteFrameName("item_xunzhang_02.png",onClickIcon)
		icon:setScale(100/icon:getContentSize().width)
		local allSkills=skillVoApi:getAllSkills()
		local totalSkill=0
		for k,v in pairs(allSkills) do
			totalSkill=totalSkill+v.lv
		end
		local skillLimit
		if(base.nbSkillOpen==1 and playerVoApi:getPlayerLevel()>=playerSkillCfg.openlevel)then
			--陶也给的特殊算法，参数是什么意思得问陶也
			skillLimit=playerVoApi:getPlayerLevel()*( 4 + 8 + 2 + 8 ) + 12*5 - 500
		else
			--以前只有12个技能
			skillLimit=12*playerVoApi:getPlayerLevel()
		end
		percent=totalSkill/skillLimit*100
		upStr=getlocal("powerGuide_skillPercent",{""})
		downStr=getlocal("powerGuide_leftSkill",{bagVoApi:getItemNumId(19)})
		if(totalSkill>=skillLimit)then
			clickable=false
		else
			clickable=true
		end
	elseif(idx==2)then
		icon=LuaCCSprite:createWithSpriteFrameName("Icon_ke_yan_zhong_xin.png",onClickIcon)
		icon:setScale(100/icon:getContentSize().width)
		local totalTech=0
		clickable=false
		local lv,cur,next = playerVoApi:getHonorInfo()
		local singleLimit=math.min(playerVoApi:getMaxLvByKey("techMaxLevel"),lv)
		local techLimit=singleLimit*8
		local buildVo=buildingVoApi:getBuildiingVoByBId(3)
		if(buildVo and buildVo.level>0)then
			for i=1,8 do
				local techVo=technologyVoApi:getTechVoByTId(i)
				if(techVo~=nil)then
					totalTech=totalTech+techVo.level
				end
				if(techVo.level<singleLimit)then
					clickable=true
				end
			end
		end
		if(techLimit>0)then
			percent=totalTech/techLimit*100
		else
			percent=0
		end
		upStr=getlocal("powerGuide_techPercent",{""})
		if(clickable)then
			downStr=getlocal("powerGuide_techCanUpgrade")
		else
			downStr=getlocal("powerGuide_techCantUpgrade")
		end
	elseif(idx==3)then
		icon=LuaCCSprite:createWithSpriteFrameName("Icon_gong_hui.png",onClickIcon)
		icon:setScale(100/icon:getContentSize().width)
		local selfAlliance=allianceVoApi:getSelfAlliance()
		if(selfAlliance==nil)then
			clickable=false
			upStr=getlocal("powerGuide_allianceSkillPercent",{""})
			percent=0
			downStr=getlocal("noAlliance")
		else
			local totalLv=0
			local lvLimit=0
			for i=11,14 do
				local skillCfg=allianceSkillCfg[i]
				local skillID=tonumber(skillCfg.sid)
				totalLv=totalLv+allianceSkillVoApi:getSkillLevel(skillID)
				lvLimit=lvLimit+selfAlliance.level
			end
			if(lvLimit>0)then
				percent=totalLv/lvLimit*100
			else
				percent=0
			end
			upStr=getlocal("powerGuide_allianceSkillPercent",{""})
			local donateCount=0
			for i=1,5 do
				local count=allianceVoApi:getDonateCount(i)
				donateCount=donateCount+count
			end
			local donateMaxCount=allianceVoApi:getDonateMaxNum()*5
			downStr=getlocal("powerGuide_allianceDonate",{donateCount,donateMaxCount})
			if(donateCount>=donateMaxCount)then
				clickable=false
			elseif(totalLv<lvLimit)then
				clickable=true
			end
		end
		if(base.isAllianceOpen~=true)then
			upStr=getlocal("alliance_notOpen")
			downStr=""
			clickable=false
		end
	elseif(idx==4)then
		local vo=self:getMinUpgradeAccessory()
		if(vo)then
			icon=accessoryVoApi:getAccessoryIcon(vo.type,80,100,onClickIcon)
		else
			icon=GetBgIcon("mainBtnAccessory.png",onClickIcon,nil,80,100)
		end
		local totalLv=self:getAccessoryTotalLv()
		local lvLimit=accessoryVoApi:getUnlockPartByLv(math.min(playerVoApi:getPlayerLevel(),playerVoApi:getMaxLvByKey("roleMaxLevel")))*playerVoApi:getPlayerLevel()*4
		if(lvLimit>0)then
			percent=totalLv/lvLimit*100
		else
			percent=0
		end
		upStr=getlocal("accessory_lv",{""})
		local canUpgrade=self:checkCanUpgrade()
		if(canUpgrade==0)then
			downStr=getlocal("powerGuide_accessoryUpgradeDesc")
			clickable=true
		elseif(canUpgrade==2)then
			downStr=getlocal("resourcelimit")
			clickable=true
		elseif(canUpgrade==false)then
			downStr=getlocal("powerGuide_accessoryUpgradeDesc2")
			clickable=false
		end
		if(base.ifAccessoryOpen~=1)then
			upStr=getlocal("alliance_notOpen")
			downStr=""
			clickable=false
		end
	elseif(idx==5)then
		local vo=self:getMinSmeltAccessory()
		if(vo)then
			icon=accessoryVoApi:getAccessoryIcon(vo.type,80,100,onClickIcon)
		else
			icon=GetBgIcon("mainBtnAccessory.png",onClickIcon,nil,80,100)
		end
		local totalRank=self:getAccessoryTotalRank()
		-- local rankLimit=accessoryVoApi:getUnlockPartByLv(playerVoApi:getPlayerLevel())*accessoryCfg.smeltMaxRank*4
		local maxQuality=accessoryCfg.maxQuality
		local smeltMaxRank=accessoryVoApi:getSmeltMaxRank(maxQuality)
		local rankLimit=accessoryVoApi:getUnlockPartByLv(playerVoApi:getPlayerLevel())*smeltMaxRank*4
		if(rankLimit>0)then
			if(rankLimit<totalRank)then
				rankLimit=totalRank
			end
			percent=totalRank/rankLimit*100
		else
			percent=0
		end
		upStr=getlocal("accessory_rank",{""})
		local canSmelt=self:checkCanSmelt()
		if(canSmelt==0)then
			downStr=getlocal("powerGuide_accessorySmeltDesc")
			clickable=true
		elseif(canSmelt==false)then
			downStr=getlocal("powerGuide_accessorySmeltDesc2")
			clickable=false
		elseif(canSmelt>=20 and canSmelt<30)then
			downStr=getlocal("powerGuide_accessorySmeltDesc3")
			clickable=true
		end
		if(base.ifAccessoryOpen~=1)then
			upStr=getlocal("alliance_notOpen")
			downStr=""
			clickable=false
		end
	elseif(idx==6)then
		icon=accessoryVoApi:getFragmentIcon("f0",80,100,onClickIcon)
		local ownedNum=self:getEquipedAccessoryScore()
		local limitNum=accessoryVoApi:getUnlockPartByLv(playerVoApi:getPlayerLevel())*accessoryCfg.maxQuality*4
		if(limitNum>0)then
			percent=ownedNum/limitNum*100
		else
			percent=0
		end
		upStr=getlocal("powerGuide_accessoryQualityPercent",{""})
		local unEquipedNum=self:getUnEquipedPurpleAccessoryNum()
		downStr=getlocal("powerGuide_accessoryQualityDesc",{unEquipedNum})
		if(ownedNum<limitNum)then
			clickable=true
		else
			clickable=false
		end
		if(base.ifAccessoryOpen~=1)then
			upStr=getlocal("alliance_notOpen")
			downStr=""
			clickable=false
		end
	elseif(idx==7)then
		local tankID=tankVoApi:getBestTankCanProduce()
		if(tankID)then
			icon=tankVoApi:getTankIconSp(tankID,nil,onClickIcon)--LuaCCSprite:createWithSpriteFrameName(tankCfg[tankID].icon,onClickIcon)
			local worstPower=self:getWorstPower()
			local bestPower=tankVoApi:getBestTanksFighting(tankID,1)
			if(bestPower>0)then
				percent=worstPower/bestPower*100
			else
				percent=0
			end
			if(percent>100)then
				percent=100
			end
			upStr=getlocal("powerGuide_produceTankPowerPercent",{""})
			downStr=getlocal("powerGuide_produceTankPowerDesc",{getlocal(tankCfg[tankID].name)})
			if(worstPower<bestPower)then
				clickable=true
			else
				clickable=false
			end
		else
			icon=LuaCCSprite:createWithSpriteFrameName("Icon_tan_ke_gong_chang.png",onClickIcon)
			percent=0
			upStr=getlocal("powerGuide_produceTankPowerPercent",{""})
			downStr=getlocal("powerGuide_produceTankNoTank")
			clickable=false
		end
		icon:setScale(100/icon:getContentSize().width)
	elseif(idx==8)then
		icon=LuaCCSprite:createWithSpriteFrameName("Icon_tan_ke_gong_chang.png",onClickIcon)
		local totalNum=self:getTankNumInBestTanks()
		local limitNum=(playerVoApi:getTroopsLvNum()+playerVoApi:getExtraTroopsNum())*6
		if(limitNum>0)then
			percent=totalNum/limitNum*100
		else
			percent=0
		end
		if(percent>100)then
			percent=100
		end
		upStr=getlocal("powerGuide_tankNumPercent",{""})
		if(percent<100)then
			downStr=getlocal("powerGuide_tankNumDesc",{limitNum-totalNum})
		else
			downStr=getlocal("powerGuide_tankNumDesc2")
		end
		local buildVo=buildingVoApi:getBuildiingVoByBId(11)
		if(buildVo and buildVo.level and buildVo.level>0)then
			if(percent<100)then
				clickable=true
			else
				clickable=false
			end
		else
			clickable=false
		end
		icon:setScale(100/icon:getContentSize().width)
	end
	icon:setPosition(ccp(60,backSprie:getContentSize().height/2))
	icon:setTag(5180+idx)
	icon:setTouchPriority(-(self.layerNum-1)*20-2)
	backSprie:addChild(icon)

	table.insert(self.percentTb,percent)

	local upLb=GetTTFLabelWrap(upStr,20,CCSizeMake(G_VisibleSizeWidth-350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
	upLb:setAnchorPoint(ccp(0,0))
	upLb:setPosition(ccp(115,backSprie:getContentSize().height/2+22))
	backSprie:addChild(upLb,2)

	AddProgramTimer(backSprie,ccp(0,0),518,nil,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",519)
	local powerBar = tolua.cast(backSprie:getChildByTag(518),"CCProgressTimer")
	powerBar:setScaleX(300/powerBar:getContentSize().width)
	powerBar:setScaleY(40/powerBar:getContentSize().height)
	powerBar:setAnchorPoint(ccp(0,0.5))
	powerBar:setPosition(ccp(115,backSprie:getContentSize().height/2))
	powerBar:setPercentage(percent)
	local powerBarBg=tolua.cast(backSprie:getChildByTag(519),"CCSprite")
	powerBarBg:setScaleX(300/powerBarBg:getContentSize().width)
	powerBarBg:setScaleY(40/powerBarBg:getContentSize().height)
	powerBarBg:setAnchorPoint(ccp(0,0.5))
	powerBarBg:setPosition(ccp(115,backSprie:getContentSize().height/2))

	local percentLb=GetTTFLabel(string.format("%.2f",percent).."%",20)
	percentLb:setAnchorPoint(ccp(1,0.5))
	percentLb:setPosition(400,backSprie:getContentSize().height/2)
	backSprie:addChild(percentLb,3)

	local downLb=GetTTFLabelWrap(downStr,20,CCSizeMake(G_VisibleSizeWidth-350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	downLb:setAnchorPoint(ccp(0,1))
	downLb:setPosition(ccp(115,backSprie:getContentSize().height/2-22))
	backSprie:addChild(downLb)

	local function onClickGoto()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		self:redirect(idx)
	end
	local gotoMenu=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickGoto,nil,getlocal("activity_heartOfIron_goto"),24,101)
	gotoMenu:setScale(0.7)
	local lb = gotoMenu:getChildByTag(101)
	if lb then
		lb = tolua.cast(lb,"CCLabelTTF")
		lb:setFontName("Helvetica-bold")
	end
	gotoMenu:setEnabled(clickable)
	local gotoBtn=CCMenu:createWithItem(gotoMenu)
	gotoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	gotoBtn:setPosition(ccp(backSprie:getContentSize().width-80,backSprie:getContentSize().height/2))
	backSprie:addChild(gotoBtn,2)

	return backSprie
end

function powerGuideDialog:getMinUpgradeAccessory()
	local minLv=playerVoApi:getMaxLvByKey("roleMaxLevel")
	local minQuality=accessoryCfg.maxQuality+1
	local minVo
	for i=1,4 do
		for j=1,accessoryCfg.unLockPart do
			local aVo=accessoryVoApi:getAccessoryByPart(i,j)
			if(aVo~=nil)then
				if(aVo.lv<minLv)then
					minLv=aVo.lv
					minQuality=tonumber(aVo:getConfigData("quality"))
					minVo=aVo
				elseif(aVo.lv==minLv)then
					local quality=tonumber(aVo:getConfigData("quality"))
					if(quality<minQuality)then
						minLv=aVo.lv
						minQuality=quality
						minVo=aVo
					end
				end
			end
		end
	end
	return minVo
end

function powerGuideDialog:getAccessoryTotalLv()
	local total=0
	for i=1,4 do
		for j=1,accessoryCfg.unLockPart do
			local aVo=accessoryVoApi:getAccessoryByPart(i,j)
			if(aVo~=nil)then
				total=total+aVo.lv
			end
		end
	end
	return total
end

function powerGuideDialog:checkCanUpgrade()
	local result=false
	for i=1,4 do
		for j=1,accessoryCfg.unLockPart do
			local canUpgrade=accessoryVoApi:checkCanUpgrade(i,j)
			if(canUpgrade==0)then
				return canUpgrade
			elseif(canUpgrade==2)then
				result=canUpgrade
			end
		end
	end
	return result
end

function powerGuideDialog:getMinSmeltAccessory()
	-- local minRank=accessoryCfg.smeltMaxRank
	local minQuality=accessoryCfg.maxQuality+1
	local minVo
	for i=1,4 do
		for j=1,accessoryCfg.unLockPart do
			local aVo=accessoryVoApi:getAccessoryByPart(i,j)
			if(aVo~=nil)then
				local quality=tonumber(aVo:getConfigData("quality"))
				local minRank=accessoryVoApi:getSmeltMaxRank(quality)
				if(aVo.rank<minRank)then
					minRank=aVo.rank
					-- minQuality=tonumber(aVo:getConfigData("quality"))
					minQuality=quality
					minVo=aVo
				elseif(aVo.rank==minRank)then
					-- local quality=tonumber(aVo:getConfigData("quality"))
					if(quality<minQuality)then
						minRank=aVo.rank
						minQuality=quality
						minVo=aVo
					end
				end
			end
		end
	end
	return minVo
end

function powerGuideDialog:getAccessoryTotalRank()
	local total=0
	for i=1,4 do
		for j=1,accessoryCfg.unLockPart do
			local aVo=accessoryVoApi:getAccessoryByPart(i,j)
			if(aVo~=nil)then
				total=total+aVo.rank
			end
		end
	end
	return total
end

function powerGuideDialog:checkCanSmelt()
	local result=false
	for i=1,4 do
		for j=1,accessoryCfg.unLockPart do
			local canUpgrade=accessoryVoApi:checkCanSmelt(i,j)
			if(canUpgrade==0)then
				return canUpgrade
			elseif(canUpgrade>=20 and canUpgrade<30)then
				result=canUpgrade
			end
		end
	end
	return result
end

function powerGuideDialog:getEquipedAccessoryScore()
	local total=0
	local unLockPart=accessoryVoApi:getUnlockPartByLv(playerVoApi:getPlayerLevel())
	for i=1,4 do
		for j=1,unLockPart do
			local aVo=accessoryVoApi:getAccessoryByPart(i,j)
			if(aVo~=nil)then
				local quality=tonumber(aVo:getConfigData("quality"))
				total=total+quality
			end
		end
	end
	return total
end

function powerGuideDialog:getUnEquipedPurpleAccessoryNum()
	local total=0
	local allAccessory=accessoryVoApi:getAccessoryBag()
	for k,v in pairs(allAccessory) do
		local quality=tonumber(v:getConfigData("quality"))
		if(quality>2)then
			local tankID=v:getConfigData("tankID")
			local part=v:getConfigData("part")
			local equipedAvo=accessoryVoApi:getAccessoryByPart(tankID,part)
			if(equipedAvo==nil or tonumber(equipedAvo:getConfigData("quality"))<quality)then
				total=total+1
			end
		end
	end
	return total
end

function powerGuideDialog:getWorstPower()
	local bestTanks=tankVoApi:getBestTanks()
	local minPower
	for k,v in pairs(bestTanks) do
		local power=tankVoApi:getBestTanksFighting(v[1],1)
		if(minPower==nil or minPower>power)then
			minPower=power
		end
	end
	if(minPower==nil)then
		minPower=0
	end
	return minPower
end

function powerGuideDialog:getTankNumInBestTanks()
	local bestTanks=tankVoApi:getBestTanks()
	local count=0
	for k,v in pairs(bestTanks) do
		count=count+v[2]
	end
	return count
end

function powerGuideDialog:showCellTip(id)
	local str
	local param
	if(id==6)then
		if(accessoryCfg.maxQuality==3)then
			param=getlocal("accessory_purpleQuality")
		elseif(accessoryCfg.maxQuality==4)then
			param=getlocal("accessory_orangeQuality")
        elseif(accessoryCfg.maxQuality==5)then
            param=getlocal("accessory_redQuality")
		end
		str=getlocal("powerGuide_tip7",{param})
	else
		str=getlocal("powerGuide_tip"..(id+1))
	end
	PlayEffect(audioCfg.mouseClick)
	local tabStr={}
	local tabColor ={}
	local td=smallDialog:new()
	tabStr = {"\n",str,"\n"}
	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorYellow,nil})
	sceneGame:addChild(dialog,self.layerNum+1)
end

function powerGuideDialog:redirect(idx)
	self:close()
	local function onCloseEnd()
		if(idx==0)then
			-- local td=playerDialog:new(1,self.layerNum)
			-- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
			-- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,self.layerNum)
			-- sceneGame:addChild(dialog,self.layerNum)
			local td=playerVoApi:showPlayerDialog(1,self.layerNum)
		elseif(idx==1)then
			-- local td=playerDialog:new(2,self.layerNum)
			-- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
			-- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,self.layerNum)
			-- sceneGame:addChild(dialog,self.layerNum)
			-- td:tabClick(1)
			local td=playerVoApi:showPlayerDialog(2,self.layerNum)
	        td:tabClick(1)
		elseif(idx==2)then
            require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
			local buildVo=buildingVoApi:getBuildiingVoByBId(3)
			local td=techCenterDialog:new(3,self.layerNum,true)
			local bName=getlocal(buildingCfg[8].buildName)
			local tbArr={getlocal("building"),getlocal("startResearch")}
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,self.layerNum)
			sceneGame:addChild(dialog,self.layerNum)
			td:tabClick(1)
		elseif(idx==3)then
			require "luascript/script/game/scene/gamedialog/allianceDialog/allianceSkillDialog"
			local td=allianceSkillDialog:new(self.layerNum)
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_technology"),true,self.layerNum)
			sceneGame:addChild(dialog,self.layerNum)
		elseif(idx==4)then
			local canUpgrade=self:checkCanUpgrade()
			if(canUpgrade==2)then
                local td=shopVoApi:showPropDialog(self.layerNum,true)
				td:tabClick(1,false)
			elseif(canUpgrade==0)then
				accessoryVoApi:showAccessoryDialog(sceneGame,self.layerNum)
			end
		elseif(idx==5)then
			accessoryVoApi:showAccessoryDialog(sceneGame,self.layerNum)
		elseif(idx==6)then
			accessoryVoApi:showAccessoryDialog(sceneGame,self.layerNum)
		elseif(idx==7)then
            require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
			local buildVo=buildingVoApi:getBuildiingVoByBId(11)
			local td=tankFactoryDialog:new(11,self.layerNum)
			local bName=getlocal(buildingCfg[6].buildName)
			local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,self.layerNum)
			td:tabClick(1)
			sceneGame:addChild(dialog,self.layerNum)
		elseif(idx==8)then
            require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
			local buildVo=buildingVoApi:getBuildiingVoByBId(11)
			local td=tankFactoryDialog:new(11,self.layerNum)
			local bName=getlocal(buildingCfg[6].buildName)
			local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,self.layerNum)
			td:tabClick(1)
			sceneGame:addChild(dialog,self.layerNum)
		end
	end
	local callFunc=CCCallFunc:create(onCloseEnd)
	local delay=CCDelayTime:create(0.4)
	local acArr=CCArray:create()
	acArr:addObject(delay)
	acArr:addObject(callFunc)
	local seq=CCSequence:create(acArr)
	sceneGame:runAction(seq)
end

function powerGuideDialog:dispose()
	-- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
	-- if G_isCompressResVersion()==true then
	-- 	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.png")
	-- else
	-- 	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.pvr.ccz")
	-- end
	self.cellTb=nil
	self.tickIndex=nil
	self.cellInitIndex=nil
	self.percentTb=nil
end