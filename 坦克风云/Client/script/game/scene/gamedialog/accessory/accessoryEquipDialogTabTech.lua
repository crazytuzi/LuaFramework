--配件科技的tab
accessoryEquipDialogTabTech={}

function accessoryEquipDialogTabTech:new(tankID,partID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.tankID=tankID
	nc.partID=partID
	nc.data=accessoryVoApi:getAccessoryByPart(tankID,partID)
	nc.selectedTech=1
	nc.allTabs={}
	nc.attLbs={}
	nc.propSps={}
	return nc
end

function accessoryEquipDialogTabTech:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initUp()
	self:initDown()
	if(self.data.techID)then
		self:switchTech(self.data.techID)
	else
		self:switchTech(1)
	end
	local function refreshListener(event,data)
		for k,v in pairs(data.type) do
			if(v==4 or v==3)then
				self:refresh()
				break
			end
		end
	end
	self.refreshListener=refreshListener
	eventDispatcher:addEventListener("accessory.data.refresh",refreshListener)
	return self.bgLayer
end

function accessoryEquipDialogTabTech:initUp()
	local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	local upBg=CCSprite:create("public/hero/heroequip/equipBigBg.jpg")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	upBg:setScale((G_VisibleSizeWidth - 42)/upBg:getContentSize().width)
	upBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 288)
	self.bgLayer:addChild(upBg)
	local iconBg=CCSprite:createWithSpriteFrameName("accessoryRoundBg.png")
	iconBg:setPosition(130,G_VisibleSizeHeight - 288)
	self.bgLayer:addChild(iconBg)
	local icon=accessoryVoApi:getAccessoryIcon(self.data.type,70,100)
	icon:setPosition(130,G_VisibleSizeHeight - 288)
	self.bgLayer:addChild(icon)
	local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
	self.rankLb=GetTTFLabel(self.data.rank,30)
	self.rankLb:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
	rankTip:addChild(self.rankLb)
	rankTip:setScale(0.5)
	rankTip:setAnchorPoint(ccp(0,1))
	rankTip:setPosition(ccp(0,100))
	icon:addChild(rankTip)
	self.lvLb=GetTTFLabel(getlocal("fightLevel",{self.data.lv}),20)
	self.lvLb:setAnchorPoint(ccp(1,0))
	self.lvLb:setPosition(ccp(85,5))
	icon:addChild(self.lvLb)
	local techTip=CCSprite:createWithSpriteFrameName("IconLevelBlue.png")
	self.techLb=GetTTFLabel(self.data.techLv or 0,30)
	self.techLb:setPosition(getCenterPoint(techTip))
	techTip:addChild(self.techLb)
	techTip:setScale(0.5)
	techTip:setAnchorPoint(ccp(1,1))
	techTip:setPosition(ccp(98,100))
	icon:addChild(techTip)
	--红配晋升开关开启 && 红色配件 && 已经绑定
	if base.redAccessoryPromote == 1 and self.data:getConfigData("quality") == 5 and self.data.bind == 1 then
		local promoteLvBg = CCSprite:createWithSpriteFrameName("accessoryPromote_IconLevel.png")
		local promoteLvLb = GetTTFLabel(self.data.promoteLv or 0, 30)
		promoteLvLb:setPosition(getCenterPoint(promoteLvBg))
		promoteLvBg:addChild(promoteLvLb)
		promoteLvBg:setScale(0.5)
		promoteLvBg:setAnchorPoint(ccp(0, 0))
		promoteLvBg:setPosition(ccp(0, 0))
		icon:addChild(promoteLvBg)
	end

	local nameLb=GetTTFLabelWrap(getlocal(self.data:getConfigData("name")),strSize2,CCSizeMake(icon:getContentSize().width+40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	nameLb:setAnchorPoint(ccp(0.5,1))
	local posX,posY=icon:getPosition()
	nameLb:setPosition(posX,posY - icon:getContentSize().height/2 - 10)
	self.bgLayer:addChild(nameLb)

	local titleLb=GetTTFLabel(getlocal("accessory_attChange"),24,true)
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("orangeMask.png",CCRect(20,0,552,42),function ( ... )end)
	titleBg:setContentSize(CCSizeMake(titleLb:getContentSize().width + 120,titleLb:getContentSize().height + 16))
	titleBg:setPosition(240 + titleLb:getContentSize().width/2,G_VisibleSizeHeight - 190)
	self.bgLayer:addChild(titleBg)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(240 + titleLb:getContentSize().width/2,G_VisibleSizeHeight - 190)
	self.bgLayer:addChild(titleLb)
end

function accessoryEquipDialogTabTech:initDown()
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("orangeMask.png",CCRect(20,0,552,42),function ( ... )end)
	titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,40))
	titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 440)
	self.bgLayer:addChild(titleBg)
	local titleLb=GetTTFLabel(getlocal("accessory_chooseTech"),24,true)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 440)
	self.bgLayer:addChild(titleLb)

	local tabBtn=CCMenu:create()
	tabBtn:setAnchorPoint(ccp(0,0))
	tabBtn:setPosition(0,0)
	tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(tabBtn)
	local techNum=accessoryVoApi:getUnlockTechNum()
	local posX
	local function tabClick(tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:switchTech(tag - 100)
	end
	for i=1,techNum do
		local tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
		tabBtnItem:setTag(100 + i)
		tabBtnItem:registerScriptTapHandler(tabClick)
		tabBtnItem:setAnchorPoint(ccp(0,1))
		tabBtn:addChild(tabBtnItem)
		tabBtnItem:setTag(100 + i)
		self.allTabs[i]=tabBtnItem
		local lb=GetTTFLabelWrap(getlocal("accessory_techName_"..i),20,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		lb:setTag(31)
		lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
		tabBtnItem:addChild(lb)
		if(i==1)then
			posX=(G_VisibleSizeWidth - techNum*tabBtnItem:getContentSize().width)/2
		end
		tabBtnItem:setPosition(posX,G_VisibleSizeHeight - 460)
		posX=posX + tabBtnItem:getContentSize().width
	end
	local lineBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),tabClick)
	lineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 505 - 24))
	lineBg:setAnchorPoint(ccp(0,0))
	lineBg:setPosition(20,24)
	self.bgLayer:addChild(lineBg)
	local downBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,60,60),function ( ... )end)
	downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 505 - 35))
	downBg:setAnchorPoint(ccp(0,0))
	downBg:setPosition(30,30)
	self.bgLayer:addChild(downBg)
	self.costBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),function ( ... )end)
	self.costBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,40))
	self.costBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 540)
	self.bgLayer:addChild(self.costBg)
	self.costTitle=GetTTFLabel(getlocal("alien_tech_consume_material"),24,true)
	self.costTitle:setColor(G_ColorYellowPro)
	self.costTitle:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 540)
	self.bgLayer:addChild(self.costTitle)
	local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScaleX((G_VisibleSizeWidth - 60)/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 680))
	self.bgLayer:addChild(lineSp,2)
end

function accessoryEquipDialogTabTech:switchTech(type)
	self.selectedTech=type
	for k,v in pairs(self.allTabs) do
		local lb=tolua.cast(v:getChildByTag(31),"CCLabelTTF")
		if(k==type)then
			v:setEnabled(false)
			lb:setColor(G_ColorWhite)
		else
			v:setEnabled(true)
			lb:setColor(G_TabLBColorGreen)
		end
	end
	self:refresh()
end

function accessoryEquipDialogTabTech:refresh()
	self.data=accessoryVoApi:getAccessoryByPart(self.tankID,self.partID)
	self:refreshUp()
	self:refreshDown()
end

function accessoryEquipDialogTabTech:stopNumAction( )
	self.bgLayer:stopAllActions()

	for k,v in pairs(self.attlbsActionShowTb) do
		self.attlbsActionShowTb[k]:stopAllActions()
		self.attlbsActionShowTb[k]:setScale(1)
	end
end

function accessoryEquipDialogTabTech:showChangeNum()
	self:stopNumAction()

	for k,v in pairs(self.attlbsActionShowTb) do
		G_showNumberScaleByAction(self.attlbsActionShowTb[k],0.15,1.2)
	end
	local function callbackToShow( )
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),30,nil,nil,nil,G_ColorYellowPro)
	end
	local callFunc=CCCallFunc:create(callbackToShow)
	local delay=CCDelayTime:create(0.8)
	local acArr=CCArray:create()
	acArr:addObject(delay)
	acArr:addObject(callFunc)
	local seq=CCSequence:create(acArr)
	self.bgLayer:runAction(seq)
	
end

function accessoryEquipDialogTabTech:refreshUp()
	local strSize2 = 21
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
	self.rankLb:setString(self.data.rank)
	self.lvLb:setString(getlocal("fightLevel",{self.data.lv}))
	self.techLb:setString(self.data.techLv or 0)
	if(#self.attLbs>0)then
		for k,v in pairs(self.attLbs) do
			v:removeFromParentAndCleanup(true)
		end
	end
	self.attlbsActionShowTb = {}
	self.attLbs={}
	local posY=G_VisibleSizeHeight - 225
	local techLvLbStr = GetTTFLabel(getlocal("powerGuide_techPercent",{""}),strSize2)
	techLvLbStr:setAnchorPoint(ccp(0,0.5))
	techLvLbStr:setPosition(235,posY)
	self.bgLayer:addChild(techLvLbStr)
	table.insert(self.attLbs,techLvLbStr)
	local techLvLb=GetTTFLabel(self.data.techLv or 0,strSize2)
	techLvLb:setAnchorPoint(ccp(0,0.5))
	techLvLb:setPosition(techLvLbStr:getPositionX()+techLvLbStr:getContentSize().width,posY)
	self.bgLayer:addChild(techLvLb)
	table.insert(self.attLbs,techLvLb)
	table.insert(self.attlbsActionShowTb,techLvLb)
	if(self.data.techLv==nil or self.data.techLv==0 or (self.data:techLvMax()==false and self.selectedTech==self.data.techID))then
		local techLvLb2=GetTTFLabel(" ↑ +1",strSize2)
		techLvLb2:setColor(G_ColorGreen)
		techLvLb2:setAnchorPoint(ccp(0,0.5))
		techLvLb2:setPosition(techLvLb:getPositionX() + techLvLb:getContentSize().width,posY)
		self.bgLayer:addChild(techLvLb2)
		table.insert(self.attLbs,techLvLb2)
	elseif(self.data:techLvMax()==true and self.selectedTech==self.data.techID)then
		local techLvLb2=GetTTFLabel(" "..getlocal("donatePointMax"),strSize2)
		techLvLb2:setColor(G_ColorYellowPro)
		techLvLb2:setAnchorPoint(ccp(0,0.5))
		techLvLb2:setPosition(techLvLb:getPositionX() + techLvLb:getContentSize().width,posY)
		self.bgLayer:addChild(techLvLb2)
		table.insert(self.attLbs,techLvLb2)
	end
	posY=posY - 30
	local attTb
	local newAttTb
	if(self.data.techLv and self.data.techLv>0)then
		attTb=self.data:getTechAttByIDAndLv(self.data.techID,self.data.techLv)
		if(self.selectedTech==self.data.techID)then
			newAttTb=self.data:getTechAttByIDAndLv(self.selectedTech,self.data.techLv + 1)
		else
			newAttTb=self.data:getTechAttByIDAndLv(self.selectedTech,self.data.techLv)
		end
	else
		attTb={}
		newAttTb=self.data:getTechAttByIDAndLv(self.selectedTech,1)
	end
	local differenceTb={}
	local lvMax=(self.selectedTech==self.data.techID and self.data:techLvMax())
	if(lvMax)then
		differenceTb=attTb
	else
		for k,v in pairs(attTb) do
			differenceTb[k]=0
		end
		for k,v in pairs(newAttTb) do
			differenceTb[k]=0
		end
	end
	for attType,attValue in pairs(differenceTb) do
		local effectStr,changeEffectStr
		local nowValue=attTb[attType] or 0
		local newValue=(newAttTb and newAttTb[attType]) or 0
		local difference=newValue - nowValue
		if(accessoryCfg.attEffect[attType]==1)then
			effectStr=nowValue.."%"
			changeEffectStr=difference.."%"
		else
			effectStr=nowValue
			changeEffectStr=difference
		end
		local lb1=GetTTFLabel(getlocal("accessory_attAdd_"..attType,{""}),strSize2)
		lb1:setAnchorPoint(ccp(0,0.5))
		lb1:setPosition(235,posY)
		self.bgLayer:addChild(lb1)
		table.insert(self.attLbs,lb1)

		lb1Num = GetTTFLabel(effectStr,strSize2)
		lb1Num:setAnchorPoint(ccp(0,0.5))
		lb1Num:setPosition(lb1:getPositionX()+lb1:getContentSize().width,posY)
		self.bgLayer:addChild(lb1Num)
		table.insert(self.attLbs,lb1Num)
		table.insert(self.attlbsActionShowTb,lb1Num)
		local color
		if(lvMax)then
			changeEffectStr=" "..getlocal("donatePointMax")
			color=G_ColorYellowPro
		elseif(difference>0)then
			changeEffectStr=" ↑ +"..changeEffectStr
			color=G_ColorGreen
		elseif(difference<0)then
			changeEffectStr=" ↓ "..changeEffectStr--自带负号，不需要再加一个减号了
			color=G_ColorRed
		else
			changeEffectStr=""
			color=G_ColorWhite
		end
		local lb2=GetTTFLabel(changeEffectStr,strSize2)
		lb2:setColor(color)
		lb2:setAnchorPoint(ccp(0,0.5))
		lb2:setPosition(lb1Num:getPositionX() + lb1Num:getContentSize().width,posY)
		self.bgLayer:addChild(lb2)
		table.insert(self.attLbs,lb2)
		posY=posY - 30
	end
	if(self.selectedTech==self.data.techID)then
		local oldPointLb1Str = GetTTFLabel(getlocal("accessory_techName_"..self.data.techID)..": ",strSize2)
		oldPointLb1Str:setAnchorPoint(ccp(0,0.5))
		oldPointLb1Str:setPosition(235,posY)
		self.bgLayer:addChild(oldPointLb1Str)
		table.insert(self.attLbs,oldPointLb1Str)

		local oldPointLb1=GetTTFLabel(self.data:getTechSkillPointByIDAndLv(),strSize2)
		oldPointLb1:setAnchorPoint(ccp(0,0.5))
		oldPointLb1:setPosition(oldPointLb1Str:getContentSize().width+oldPointLb1Str:getPositionX(),posY)
		self.bgLayer:addChild(oldPointLb1)
		table.insert(self.attLbs,oldPointLb1)
		table.insert(self.attlbsActionShowTb,oldPointLb1)
		local oldPointLb2
		if(lvMax)then
			oldPointLb2=GetTTFLabel(" "..getlocal("donatePointMax"),strSize2)
			oldPointLb2:setColor(G_ColorYellowPro)
		else
			local addValue=self.data:getTechSkillPointByIDAndLv(self.data.techID,self.data.techLv + 1) - self.data:getTechSkillPointByIDAndLv(self.data.techID,self.data.techLv)
			oldPointLb2=GetTTFLabel(" ↑ +"..addValue,strSize2)
			oldPointLb2:setColor(G_ColorGreen)
		end
		oldPointLb2:setAnchorPoint(ccp(0,0.5))
		oldPointLb2:setPosition(oldPointLb1:getPositionX() + oldPointLb1:getContentSize().width,posY)
		self.bgLayer:addChild(oldPointLb2)
		table.insert(self.attLbs,oldPointLb2)
		posY=posY - 30
	else
		local newLv
		if(self.data.techLv and self.data.techLv>0)then
			local oldPointLb1Str = GetTTFLabel(getlocal("accessory_techName_"..self.data.techID)..": ",strSize2)
			oldPointLb1Str:setAnchorPoint(ccp(0,0.5))
			oldPointLb1Str:setPosition(235,posY)
			self.bgLayer:addChild(oldPointLb1Str)
			table.insert(self.attLbs,oldPointLb1Str)

			newLv=self.data.techLv
			local oldPointLb1=GetTTFLabel(self.data:getTechSkillPointByIDAndLv(),strSize2)
			oldPointLb1:setAnchorPoint(ccp(0,0.5))
			oldPointLb1:setPosition(oldPointLb1Str:getContentSize().width+oldPointLb1Str:getPositionX(),posY)
			self.bgLayer:addChild(oldPointLb1)
			table.insert(self.attLbs,oldPointLb1)
			table.insert(self.attlbsActionShowTb,oldPointLb1)
			local oldPointLb2=GetTTFLabel(" ↓ -"..self.data:getTechSkillPointByIDAndLv(),strSize2)
			oldPointLb2:setColor(G_ColorRed)
			oldPointLb2:setAnchorPoint(ccp(0,0.5))
			oldPointLb2:setPosition(oldPointLb1:getPositionX() + oldPointLb1:getContentSize().width,posY)
			self.bgLayer:addChild(oldPointLb2)
			table.insert(self.attLbs,oldPointLb2)
			posY=posY - 30
		else
			newLv=1
		end
		local newPointLb1=GetTTFLabel(getlocal("accessory_techName_"..self.selectedTech)..": 0",strSize2)
		newPointLb1:setAnchorPoint(ccp(0,0.5))
		newPointLb1:setPosition(240,posY)
		self.bgLayer:addChild(newPointLb1)
		table.insert(self.attLbs,newPointLb1)
		local newPointLb2=GetTTFLabel(" ↑ +"..self.data:getTechSkillPointByIDAndLv(self.selectedTech,newLv),strSize2)
		newPointLb2:setColor(G_ColorGreen)
		newPointLb2:setAnchorPoint(ccp(0,0.5))
		newPointLb2:setPosition(240 + newPointLb1:getContentSize().width,posY)
		self.bgLayer:addChild(newPointLb2)
		table.insert(self.attLbs,newPointLb2)
		posY=posY - 30
	end
	local tankAccessory=accessoryVoApi:getTankAccessories(self.tankID)
	if(tankAccessory and lvMax==false)then
		local oldTechPointTb={}
		local newTechPointTb={}
		local techNum=accessoryVoApi:getUnlockTechNum()
		for i=1,techNum do
			oldTechPointTb[i]=0
			newTechPointTb[i]=0
		end
		for partID,aVo in pairs(tankAccessory) do
			if(partID~="p"..self.partID)then
				if(aVo.techLv and aVo.techLv>0)then
					oldTechPointTb[aVo.techID]=oldTechPointTb[aVo.techID] + aVo:getTechSkillPointByIDAndLv()
					newTechPointTb[aVo.techID]=newTechPointTb[aVo.techID] + aVo:getTechSkillPointByIDAndLv()
				end
			end
		end
		if(self.data.techLv and self.data.techLv>0)then
			oldTechPointTb[self.data.techID]=oldTechPointTb[self.data.techID] + self.data:getTechSkillPointByIDAndLv()
		end
		local newLv
		if(self.selectedTech==self.data.techID)then
			newLv=self.data.techLv + 1
		else
			newLv=self.data.techLv or 1
		end
		newTechPointTb[self.selectedTech]=newTechPointTb[self.selectedTech] + self.data:getTechSkillPointByIDAndLv(self.selectedTech,newLv)
		local oldSkillTb={}
		local newSkillTb={}
		local length=accessoryVoApi:getTechSkillMaxLv()
		for techID,techPoint in pairs(oldTechPointTb) do
			local lv
			for i=1,length do
				local exp=accessorytechCfg.lvNeed[i]
				if(techPoint<exp)then
					lv=i - 1
					break
				end
			end
			if(lv==nil)then
				lv=length
			end
			oldSkillTb[techID]=lv
		end
		for techID,techPoint in pairs(newTechPointTb) do
			local lv
			for i=1,length do
				local exp=accessorytechCfg.lvNeed[i]
				if(techPoint<exp)then
					lv=i - 1
					break
				end
			end
			if(lv==nil)then
				lv=length
			end
			newSkillTb[techID]=lv
		end
		local differenceTb={}
		for techID,skillLv in pairs(oldSkillTb) do
			if(newSkillTb[techID]~=skillLv)then
				differenceTb[techID]=newSkillTb[techID] - skillLv
			end
		end
		for techID,changeLv in pairs(differenceTb) do
			local skillID=accessorytechCfg.techSkill["t"..self.tankID][techID]
			local lv
			if(oldSkillTb[techID]==0)then
				lv=1
			else
				lv=oldSkillTb[techID]
			end
			local skillName=getlocal(abilityCfg[skillID][lv].name)
			local techLb1Str = GetTTFLabel(skillName..": ",strSize2)
			techLb1Str:setAnchorPoint(ccp(0,0.5))
			techLb1Str:setPosition(235,posY)
			self.bgLayer:addChild(techLb1Str)
			table.insert(self.attLbs,techLb1Str)

			local techLb1=GetTTFLabel(oldSkillTb[techID],strSize2)
			techLb1:setAnchorPoint(ccp(0,0.5))
			techLb1:setPosition(techLb1Str:getContentSize().width+techLb1Str:getPositionX(),posY)
			self.bgLayer:addChild(techLb1)
			table.insert(self.attLbs,techLb1)
			table.insert(self.attlbsActionShowTb,techLb1)
			local techLb2
			if(changeLv>0)then
				techLb2=GetTTFLabel(" ↑ +"..changeLv,strSize2)
				techLb2:setColor(G_ColorGreen)
			else
				techLb2=GetTTFLabel(" ↓ "..changeLv,strSize2)--自带负号，不需要再加一个减号了
				techLb2:setColor(G_ColorRed)
			end
			techLb2:setAnchorPoint(ccp(0,0.5))
			techLb2:setPosition(techLb1:getPositionX() + techLb1:getContentSize().width,posY)
			self.bgLayer:addChild(techLb2)
			table.insert(self.attLbs,techLb2)
			posY=posY - 30
		end
	end
end

function accessoryEquipDialogTabTech:refreshDown()
	if(#self.propSps>0)then
		for k,v in pairs(self.propSps) do
			v:removeFromParentAndCleanup(true)
		end
	end
	self.propSps={}
	local lvMax=(self.selectedTech==self.data.techID and self.data:techLvMax())
	if(lvMax)then
		self.costBg:setVisible(false)
		self.costTitle:setVisible(false)
		local lvMaxLb=GetTTFLabelWrap(getlocal("backstage9044"),25,CCSizeMake(G_VisibleSizeWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		lvMaxLb:setColor(G_ColorYellowPro)
		lvMaxLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 600)
		self.bgLayer:addChild(lvMaxLb)
		table.insert(self.propSps,lvMaxLb)
	else
		self.costBg:setVisible(true)
		self.costTitle:setVisible(true)
	end
	local toLv
	if(self.data.techLv==nil)then
		toLv=1
	elseif(self.selectedTech~=self.data.techID or lvMax)then
		toLv=self.data.techLv
	else
		toLv=self.data.techLv + 1
	end
	local props=accessoryVoApi:getTechChangeProp(self.data,self.selectedTech)
	local function sortFunc(a,b)
		if(a.type==b.type)then
			if(a.eType==b.eType)then
				local aIndex=tonumber(string.sub(a.id,2))
				local bIndex=tonumber(string.sub(b.id,2))
				return aIndex<bIndex
			else
				return a.eType<b.eType
			end
		else
			return a.type<b.type
		end
	end
	table.sort(props,sortFunc)
	local num=#props
	local unitWidth=(G_VisibleSizeWidth - 60)/num
	local canCompose=true
	for i=1,num do
		local prop=props[i]
		if(lvMax==false)then
			local icon=G_getItemIcon(prop,80,true,self.layerNum)
			icon:setTouchPriority(-(self.layerNum-1)*20-4)
			local posX=30 + unitWidth*(i - 0.5)
			icon:setPosition(posX,G_VisibleSizeHeight - 610)
			self.bgLayer:addChild(icon)
			table.insert(self.propSps,icon)
			local needNum=prop.num
			local hasNum
			if(prop.type=="e")then
				if(prop.eType=="p")then
					hasNum=accessoryVoApi:getPropNums()[prop.key] or 0
				elseif(prop.eType=="f")then
					local fVo=accessoryVoApi:getFragmentByID(prop.key)
					if(fVo)then
						hasNum=fVo.num
					else
						hasNum=0
					end
				else
					hasNum=0
				end
			else
				local propId=(tonumber(prop.key) or tonumber(RemoveFirstChar(prop.key)))
				hasNum=bagVoApi:getItemNumId(propId)
			end
			local numLb=GetTTFLabel(hasNum.." / "..needNum,25)
			if(hasNum>=needNum)then
				numLb:setColor(G_ColorGreen)
			else
				numLb:setColor(G_ColorRed)
				canCompose=false
			end
			numLb:setPosition(posX,G_VisibleSizeHeight - 665)
			self.bgLayer:addChild(numLb)
			table.insert(self.propSps,numLb)
		else
			canCompose=false
		end
	end
	local btnText
	if(self.selectedTech==self.data.techID or self.data.techLv==nil or self.data.techLv==0 or lvMax)then
		btnText=getlocal("upgrade")
	else
		btnText=getlocal("accessory_techChange")
	end
	local function onChange()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:change()
	end
	local changeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onChange,nil,btnText,24/0.7)
	changeItem:setScale(0.7)
	changeItem:setAnchorPoint(ccp(0.5,0))
	local changeBtn=CCMenu:createWithItem(changeItem)
	changeBtn:setAnchorPoint(ccp(0.5,0))
	changeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	local btnY
	if(G_isIphone5())then
		btnY=75
	else
		btnY=35
	end
	changeBtn:setPosition(G_VisibleSizeWidth/2,btnY)
	self.bgLayer:addChild(changeBtn)
	changeItem:setEnabled(canCompose)
	table.insert(self.propSps,changeBtn)
	local tankStr
	local tankID=self.tankID
	if(tankID==1)then
		tankStr=getlocal("tanke")
	elseif(tankID==2)then
		tankStr=getlocal("jianjiche")
	elseif(tankID==3)then
		tankStr=getlocal("zixinghuopao")
	elseif(tankID==4)then
		tankStr=getlocal("huojianche")
	end
	local tankAccessory=accessoryVoApi:getTankAccessories(self.tankID)
	local techPoint=0
	for partID,aVo in pairs(tankAccessory) do
		if(aVo.techID==self.selectedTech)then
			techPoint=techPoint + aVo:getTechSkillPointByIDAndLv()
		end
	end
	local nextLv
	local nextPoint
	local length=accessoryVoApi:getTechSkillMaxLv()
	for i=1,length do
		local exp=accessorytechCfg.lvNeed[i]
		if(techPoint<exp)then
			nextLv=i
			nextPoint=exp
			break
		end
	end
	if(nextLv==nil)then
		nextLv=length
		nextPoint=accessorytechCfg.lvNeed[length]
	end
	if(nextLv)then
		local posY
		if(G_isIphone5())then
			posY=G_VisibleSizeHeight - 720
		else
			posY=G_VisibleSizeHeight - 700
		end
		local function showInfo()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			PlayEffect(audioCfg.mouseClick)
			self:showInfo()
		end
		local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11)
		infoItem:setScale(0.8)
		local infoBtn=CCMenu:createWithItem(infoItem)
		infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		infoBtn:setPosition(G_VisibleSizeWidth - 90,posY - 15)
		self.bgLayer:addChild(infoBtn)
		table.insert(self.propSps,infoBtn)
		local skillID=accessorytechCfg.techSkill["t"..self.tankID][self.selectedTech]
		local skillName=getlocal(abilityCfg[skillID][nextLv].name)
		local skillNameLb=GetTTFLabel(getlocal("allianceSkillName",{skillName,nextLv}),25)
		skillNameLb:setColor(G_ColorYellowPro)
		skillNameLb:setAnchorPoint(ccp(0.5,1))
		skillNameLb:setPosition(G_VisibleSizeWidth/2,posY)
		self.bgLayer:addChild(skillNameLb)
		table.insert(self.propSps,skillNameLb)
		local unLockDesc=GetTTFLabelWrap(getlocal("accessory_techSkill_unlock",{tankStr,getlocal("accessory_techName_"..self.selectedTech),nextPoint}),25,CCSizeMake(G_VisibleSizeWidth - 70,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		unLockDesc:setColor(G_ColorYellowPro)
		unLockDesc:setAnchorPoint(ccp(0.5,1))
		unLockDesc:setPosition(G_VisibleSizeWidth/2,skillNameLb:getPositionY() - skillNameLb:getContentSize().height - 20)
		self.bgLayer:addChild(unLockDesc)
		table.insert(self.propSps,unLockDesc)
	end
end

function accessoryEquipDialogTabTech:showInfo()
	local maxLv=accessoryVoApi:getTechSkillMaxLv()
	local tankAccessory=accessoryVoApi:getTankAccessories(self.tankID)
	local techPoint=0
	local curLv
	for partID,aVo in pairs(tankAccessory) do
		if(aVo.techID==self.selectedTech and aVo.techLv>0)then
			techPoint=techPoint + aVo:getTechSkillPointByIDAndLv()
		end
	end
	for i=1,maxLv do
		local exp=accessorytechCfg.lvNeed[i]
		if(techPoint<exp)then
			curLv=i - 1
			break
		end
	end
	if(curLv==nil)then
		curLv=maxLv
	end
	local contentTb={getlocal("accessory_techAdd",{""}),getlocal("accessory_techName_"..self.selectedTech).." "..getlocal("scheduleChapter",{curLv,maxLv})}
	local colorTb={G_ColorWhite,G_ColorYellowPro}
	for i=1,maxLv do
		local skillID=accessorytechCfg.techSkill["t"..self.tankID][self.selectedTech]
		local skillName=getlocal(abilityCfg[skillID][i].name)
		local nameStr
		if(i<=curLv)then
			nameStr=getlocal("allianceSkillName",{skillName,i}).." ("..getlocal("command_finish_tip")..")"
		else
			nameStr=getlocal("allianceSkillName",{skillName,i}).." ("..getlocal("scheduleChapter",{techPoint,accessorytechCfg.lvNeed[i]})..")"
		end
		table.insert(contentTb,nameStr)
		local param={}
		if(abilityCfg[skillID][i].value1)then
			param[1]=abilityCfg[skillID][i].value1*100
		end
		if(abilityCfg[skillID][i].value2)then
			param[2]=abilityCfg[skillID][i].value2*100
		end
		local skillDesc=getlocal(abilityCfg[skillID][i].desc,param)
		table.insert(contentTb,skillDesc)
		if(i<=curLv)then
			table.insert(colorTb,G_ColorGreen)
			table.insert(colorTb,G_ColorGreen)
		else
			table.insert(colorTb,G_ColorGray)
			table.insert(colorTb,G_ColorGray)
		end
	end
	local tankStr
	local tankID=self.tankID
	if(tankID==1)then
		tankStr=getlocal("tanke")
	elseif(tankID==2)then
		tankStr=getlocal("jianjiche")
	elseif(tankID==3)then
		tankStr=getlocal("zixinghuopao")
	elseif(tankID==4)then
		tankStr=getlocal("huojianche")
	end
	table.insert(contentTb,getlocal("accessory_techSkill_unlock2",{tankStr}))
	table.insert(colorTb,G_ColorYellowPro)
	table.insert(contentTb,getlocal("accessory_techSkill_cover"))
	table.insert(colorTb,G_ColorYellowPro)
	local layerNum=self.layerNum + 1
	local sd=smallDialog:new()
	local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum,{},25,{})
	sd.bgLayer:setContentSize(CCSizeMake(550,500))
	local function eventHandler(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return #contentTb
		elseif fn=="tableCellSizeForIndex" then
			local lb=GetTTFLabelWrap(contentTb[idx + 1],25,CCSizeMake(520,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			return CCSizeMake(510,lb:getContentSize().height + 20)
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			local lb=GetTTFLabelWrap(contentTb[idx + 1],25,CCSizeMake(480,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			lb:setColor(colorTb[idx + 1])
			lb:setAnchorPoint(ccp(0,0))
			lb:setPosition(ccp(10,10))
			cell:addChild(lb)
			return cell
		elseif fn=="ccTouchBegan" then
			return true
		elseif fn=="ccTouchMoved" then
		elseif fn=="ccTouchEnded"  then
		elseif fn=="ccScrollEnable" then
		end
	end
	local hd=LuaEventHandler:createHandler(eventHandler)
	local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(510,450),nil)
	tv:setTableViewTouchPriority(-(layerNum-1)*20-5)
	tv:setPosition(ccp(20,20))
	tv:setMaxDisToBottomOrTop(20)
	sd.bgLayer:addChild(tv)
	local function onClickMask()
		if(tv:getScrollEnable()==true and tv:getIsScrolled()==false)then
			sd:close()
		end
	end
	local maskBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(0,0,10,10),onClickMask)
	maskBg:setContentSize(CCSizeMake(510,450))
	maskBg:setTouchPriority(-(layerNum-1)*20-4)
	maskBg:setAnchorPoint(ccp(0,0))
	maskBg:setPosition(ccp(20,20))
	maskBg:setOpacity(0)
	sd.bgLayer:addChild(maskBg)
	sceneGame:addChild(dialogLayer,layerNum)
end

function accessoryEquipDialogTabTech:change()
	local lvMax=(self.selectedTech==self.data.techID and self.data:techLvMax())
	if(lvMax)then
		do return end
	end
	local function callback()
		self:showChangeNum()
		-- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),28)
	end
	if(self.data.techLv==nil or self.data.techLv==0 or self.selectedTech==self.data.techID)then
		accessoryVoApi:techUpgrade(self.tankID,self.partID,self.selectedTech,callback)
	else
		--如果更换会导致解锁技能变化就弹出2次确认
		local tankAccessory=accessoryVoApi:getTankAccessories(self.tankID)
		local oldTechPointTb={}
		local newTechPointTb={}
		local techNum=accessoryVoApi:getUnlockTechNum()
		for i=1,techNum do
			oldTechPointTb[i]=0
			newTechPointTb[i]=0
		end
		for partID,aVo in pairs(tankAccessory) do
			if(partID~="p"..self.partID)then
				if(aVo.techLv and aVo.techLv>0)then
					oldTechPointTb[aVo.techID]=oldTechPointTb[aVo.techID] + aVo:getTechSkillPointByIDAndLv()
					newTechPointTb[aVo.techID]=newTechPointTb[aVo.techID] + aVo:getTechSkillPointByIDAndLv()
				end
			end
		end
		oldTechPointTb[self.data.techID]=oldTechPointTb[self.data.techID] + self.data:getTechSkillPointByIDAndLv()
		newTechPointTb[self.selectedTech]=newTechPointTb[self.selectedTech] + self.data:getTechSkillPointByIDAndLv(self.selectedTech,self.data.techLv)
		local oldSkillTb={}
		local newSkillTb={}
		local length=accessoryVoApi:getTechSkillMaxLv()
		for techID,techPoint in pairs(oldTechPointTb) do
			local lv
			for i=1,length do
				local exp=accessorytechCfg.lvNeed[i]
				if(techPoint<exp)then
					lv=i - 1
					break
				end
			end
			if(lv==nil)then
				lv=length
			end
			oldSkillTb[techID]=lv
		end
		for techID,techPoint in pairs(newTechPointTb) do
			local lv
			for i=1,length do
				local exp=accessorytechCfg.lvNeed[i]
				if(techPoint<exp)then
					lv=i - 1
					break
				end
			end
			if(lv==nil)then
				lv=length
			end
			newSkillTb[techID]=lv
		end
		local differenceTb={}
		for techID,skillLv in pairs(oldSkillTb) do
			if(newSkillTb[techID]~=skillLv)then
				differenceTb[techID]=newSkillTb[techID] - skillLv
			end
		end
		local flag=false
		for techID,changeLv in pairs(differenceTb) do
			if(changeLv<0)then
				flag=true
				break
			end
		end
		if(flag)then
			local function onConfirm()
				accessoryVoApi:techChange(self.tankID,self.partID,self.selectedTech,callback)
			end
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("accessory_techChangeWarning"),nil,self.layerNum+1)
		else
			accessoryVoApi:techChange(self.tankID,self.partID,self.selectedTech,callback)
		end
	end
end

function accessoryEquipDialogTabTech:dispose()
	eventDispatcher:removeEventListener("accessory.data.refresh",self.refreshListener)
	self.selectedTech=nil
	self.bgLayer=nil
	self.layerNum=nil
	self.allTabs=nil
	self.selectedTech=nil
	self.attLbs=nil
	self.propSps=nil
end