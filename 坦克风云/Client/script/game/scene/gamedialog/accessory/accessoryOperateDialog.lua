--配件操作的面板，强化突破改造科技绑定等
accessoryOperateDialog=commonDialog:new()
function accessoryOperateDialog:new(tankID,partID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.tankID=tankID
	nc.partID=partID
	nc.data=accessoryVoApi:getAccessoryByPart(tankID,partID)
	nc.btnTb={}
	nc.isShow=true
	return nc
end

function accessoryOperateDialog:resetTab()
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight - 105))
	self.panelLineBg:setAnchorPoint(ccp(0,0))
	self.panelLineBg:setPosition(ccp(20,20))
	local function refreshListener(event,data)
		if(self.isShow==false)then
			self.needRefresh=true
			do return end
		end
		for k,v in pairs(data.type) do
			if(v==4)then
				self:refresh()
				break
			end
		end
	end
	self.refreshListener=refreshListener
	eventDispatcher:addEventListener("accessory.data.refresh",refreshListener)
end

function accessoryOperateDialog:initTableView()
	self:initUp()
	self:initDown()
end

function accessoryOperateDialog:initUp()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	local operateBg=CCSprite:create("public/accessoryOperateBg.jpg")
	operateBg:setAnchorPoint(ccp(0.5,1))
	local scale=(G_VisibleSizeWidth - 44)/operateBg:getContentSize().width
	operateBg:setScale(scale)
	operateBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 85)
	self.bgLayer:addChild(operateBg)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	self:refreshUp()
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setScale((G_VisibleSizeWidth - 40)/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 85 - 500))
	self.bgLayer:addChild(lineSp)
end

function accessoryOperateDialog:refreshUp()
	if(self.btnTb and #self.btnTb>0)then
		for k,v in pairs(self.btnTb) do
			for kk,vv in pairs(v) do
				vv:removeFromParentAndCleanup(true)
			end			
		end
	end
	self.btnTb={}
	if(self.accessoryIcon)then
		self.accessoryIcon:removeFromParentAndCleanup(true)
	end
	self.accessoryIcon=accessoryVoApi:getAccessoryIcon(self.data.type,80,100)
	self.accessoryIcon:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 85 - 220)
	self.bgLayer:addChild(self.accessoryIcon)
	local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
	local rankLb=GetTTFLabel(self.data.rank,30)
	rankLb:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
	rankTip:addChild(rankLb)
	rankTip:setScale(0.5)
	rankTip:setAnchorPoint(ccp(0,1))
	rankTip:setPosition(ccp(0,100))
	self.accessoryIcon:addChild(rankTip)
	local lvLb=GetTTFLabel(getlocal("fightLevel",{self.data.lv}),20)
	lvLb:setAnchorPoint(ccp(1,0))
	lvLb:setPosition(ccp(85,5))
	self.accessoryIcon:addChild(lvLb)
	if(self.data.bind==1 and self.data:getConfigData("quality")>3 and base.accessoryTech==1)then
		local techTip=CCSprite:createWithSpriteFrameName("IconLevelBlue.png")
		local techLb=GetTTFLabel(self.data.techLv or 0,30)
		techLb:setPosition(getCenterPoint(techTip))
		techTip:addChild(techLb)
		techTip:setScale(0.5)
		techTip:setAnchorPoint(ccp(1,1))
		techTip:setPosition(ccp(98,100))
		self.accessoryIcon:addChild(techTip)
	end
	--红配晋升开关开启 && 红色配件 && 已经绑定
	if base.redAccessoryPromote == 1 and self.data:getConfigData("quality") == 5 and self.data.bind == 1 then
		local promoteLvBg = CCSprite:createWithSpriteFrameName("accessoryPromote_IconLevel.png")
		local promoteLvLb = GetTTFLabel(self.data.promoteLv or 0, 30)
		promoteLvLb:setPosition(getCenterPoint(promoteLvBg))
		promoteLvBg:addChild(promoteLvLb)
		promoteLvBg:setScale(0.5)
		promoteLvBg:setAnchorPoint(ccp(0, 0))
		promoteLvBg:setPosition(ccp(0, 0))
		self.accessoryIcon:addChild(promoteLvBg)
	end
	local bindStr
	if(self.data.bind==1)then
		bindStr="\n"..getlocal("accessory_bindOver")
	else
		bindStr=""
	end
	if(self.accessoryLb==nil)then
		self.accessoryLb=GetTTFLabelWrap(getlocal(self.data:getConfigData("name"))..bindStr,25,CCSizeMake(self.accessoryIcon:getContentSize().width+40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		self.accessoryLb:setAnchorPoint(ccp(0.5,1))
		self.accessoryLb:setPosition(G_VisibleSizeWidth/2,self.accessoryIcon:getPositionY() - 55)
		self.bgLayer:addChild(self.accessoryLb)
	else
		self.accessoryLb:setString(getlocal(self.data:getConfigData("name"))..bindStr)
	end
	--强化
	local function onUpgrade(object,fn,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:showEquipDialog()
	end
	local sp1=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryUpgrade.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp1:addChild(tmpIcon)
	local sp2=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryUpgrade.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp2:addChild(tmpIcon)
	sp2:setScale(0.8)
	local upgradeItem=CCMenuItemSprite:create(sp1,sp2,sp1)
	sp2:setAnchorPoint(ccp(0.5,0.5))
	sp2:setPosition(ccp(50,50))
	upgradeItem:registerScriptTapHandler(onUpgrade)
	local upgradeBtn=CCMenu:createWithItem(upgradeItem)
	local upgradeLb=GetTTFLabel(getlocal("upgrade"),25)
	local upgradeBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),onUpgrade)
	upgradeBg:setContentSize(CCSizeMake(upgradeLb:getContentSize().width + 60,upgradeLb:getContentSize().height + 10))
	upgradeLb:setPosition(getCenterPoint(upgradeBg))
	upgradeBg:addChild(upgradeLb)
	--改造
	local function onSmelt(object,fn,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:showEquipDialog(2)
	end
	local sp1=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessorySmelt.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp1:addChild(tmpIcon)
	local sp2=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessorySmelt.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp2:addChild(tmpIcon)
	sp2:setScale(0.8)
	local smeltItem=CCMenuItemSprite:create(sp1,sp2,sp1)
	sp2:setAnchorPoint(ccp(0.5,0.5))
	sp2:setPosition(ccp(50,50))
	smeltItem:registerScriptTapHandler(onSmelt)
	local smeltBtn=CCMenu:createWithItem(smeltItem)
	local smeltLb=GetTTFLabel(getlocal("smelt"),25)
	local smeltBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),onSmelt)
	smeltBg:setContentSize(CCSizeMake(smeltLb:getContentSize().width + 60,smeltLb:getContentSize().height + 10))
	smeltLb:setPosition(getCenterPoint(smeltBg))
	smeltBg:addChild(smeltLb)
	--突破
	local function onEvolution(object,fn,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		
		if self.data:getConfigData("quality")==4 and accessoryVoApi:isUpgradeQualityRed()==true then
			if self.data.bind==1 then
				accessoryVoApi:showEvolutionDialog(self.tankID,self.partID,self.layerNum + 1)
			else
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_evolution_need_bind"),30)
			end
		else
			accessoryVoApi:showEvolutionDialog(self.tankID,self.partID,self.layerNum + 1)
		end
	end
	local sp1=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryEvolution.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp1:addChild(tmpIcon)
	local sp2=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryEvolution.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp2:addChild(tmpIcon)
	sp2:setScale(0.8)
	local evolutionItem=CCMenuItemSprite:create(sp1,sp2,sp1)
	sp2:setAnchorPoint(ccp(0.5,0.5))
	sp2:setPosition(ccp(50,50))
	evolutionItem:registerScriptTapHandler(onEvolution)
	local evolutionBtn=CCMenu:createWithItem(evolutionItem)
	local evolutionLb=GetTTFLabel(getlocal("breakthrough"),25)
	local evolutionBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),onEvolution)
	evolutionBg:setContentSize(CCSizeMake(evolutionLb:getContentSize().width + 60,evolutionLb:getContentSize().height + 10))
	evolutionLb:setPosition(getCenterPoint(evolutionBg))
	evolutionBg:addChild(evolutionLb)
	--精炼
	local function onPurify(object,fn,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:showEquipDialog(3)
	end
	local sp1=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryPurify.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp1:addChild(tmpIcon)
	local sp2=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryPurify.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp2:addChild(tmpIcon)
	sp2:setScale(0.8)
	local purifyItem=CCMenuItemSprite:create(sp1,sp2,sp1)
	sp2:setAnchorPoint(ccp(0.5,0.5))
	sp2:setPosition(ccp(50,50))
	purifyItem:registerScriptTapHandler(onPurify)
	local purifyBtn=CCMenu:createWithItem(purifyItem)
	local purifyLb=GetTTFLabel(getlocal("purifying"),25)
	local purifyBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),onPurify)
	purifyBg:setContentSize(CCSizeMake(purifyLb:getContentSize().width + 60,purifyLb:getContentSize().height + 10))
	purifyLb:setPosition(getCenterPoint(purifyBg))
	purifyBg:addChild(purifyLb)
	--绑定
	local function onBind(object,fn,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		accessoryVoApi:showBindSmallDialog(self.tankID,self.partID,self.layerNum + 1)
	end
	local sp1=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryBind.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp1:addChild(tmpIcon)
	local sp2=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryBind.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp2:addChild(tmpIcon)
	sp2:setScale(0.8)
	local bindItem=CCMenuItemSprite:create(sp1,sp2,sp1)
	sp2:setAnchorPoint(ccp(0.5,0.5))
	sp2:setPosition(ccp(50,50))
	bindItem:registerScriptTapHandler(onBind)
	local bindBtn=CCMenu:createWithItem(bindItem)
	local bindLb=GetTTFLabel(getlocal("bindText"),25)
	local bindBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),onBind)
	bindBg:setContentSize(CCSizeMake(bindLb:getContentSize().width + 60,bindLb:getContentSize().height + 10))
	bindLb:setPosition(getCenterPoint(bindBg))
	bindBg:addChild(bindLb)
	--科技
	local function onTech(object,fn,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:showEquipDialog(4)
	end
	local sp1=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryTech.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp1:addChild(tmpIcon)
	local sp2=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryTech.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp2:addChild(tmpIcon)
	sp2:setScale(0.8)
	local techItem=CCMenuItemSprite:create(sp1,sp2,sp1)
	sp2:setAnchorPoint(ccp(0.5,0.5))
	sp2:setPosition(ccp(50,50))
	techItem:registerScriptTapHandler(onTech)
	local techBtn=CCMenu:createWithItem(techItem)
	local techLb=GetTTFLabel(getlocal("alliance_skill"),25)
	local techBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),onTech)
	techBg:setContentSize(CCSizeMake(techLb:getContentSize().width + 60,techLb:getContentSize().height + 10))
	techLb:setPosition(getCenterPoint(techBg))
	techBg:addChild(techLb)
	--脱下
	local function onTakeOff(object,fn,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		self:takeOff()
	end
	local sp1=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryTakeOff.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp1:addChild(tmpIcon)
	local sp2=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon=CCSprite:createWithSpriteFrameName("accessoryTakeOff.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp2:addChild(tmpIcon)
	sp2:setScale(0.8)
	local takeOffItem=CCMenuItemSprite:create(sp1,sp2,sp1)
	sp2:setAnchorPoint(ccp(0.5,0.5))
	sp2:setPosition(ccp(50,50))
	takeOffItem:registerScriptTapHandler(onTakeOff)
	local takeOffBtn=CCMenu:createWithItem(takeOffItem)
	local takeOffLb=GetTTFLabel(getlocal("accessory_unware"),25)
	local takeOffBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),onTakeOff)
	takeOffBg:setContentSize(CCSizeMake(takeOffLb:getContentSize().width + 60,takeOffLb:getContentSize().height + 10))
	takeOffLb:setPosition(getCenterPoint(takeOffBg))
	takeOffBg:addChild(takeOffLb)

	--晋升
	local function onPromote(obj, fn, tag)
		if G_checkClickEnable() == false then
			do return end
		else
			base.setWaitTime = G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		print("cjl ------->>> 晋升")
		accessoryVoApi:showPromoteSmallDialog(self.layerNum + 1, self.tankID, self.partID)
	end
	local sp1 = CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon = CCSprite:createWithSpriteFrameName("accessoryPromote_icon.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp1:addChild(tmpIcon)
	local sp2 = CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
	local tmpIcon = CCSprite:createWithSpriteFrameName("accessoryPromote_icon.png")
	tmpIcon:setScale(0.9)
	tmpIcon:setPosition(50,50)
	sp2:addChild(tmpIcon)
	sp2:setScale(0.8)
	local promoteItem = CCMenuItemSprite:create(sp1, sp2, sp1)
	sp2:setAnchorPoint(ccp(0.5,0.5))
	sp2:setPosition(ccp(50,50))
	promoteItem:registerScriptTapHandler(onPromote)
	local promoteBtn = CCMenu:createWithItem(promoteItem)
	local promoteLb = GetTTFLabel(getlocal("promotion"), 25)
	local promoteBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png", CCRect(30, 0, 60, 36), onPromote)
	promoteBg:setContentSize(CCSizeMake(promoteLb:getContentSize().width + 60, promoteLb:getContentSize().height + 10))
	promoteLb:setPosition(getCenterPoint(promoteBg))
	promoteBg:addChild(promoteLb)

	self.btnTb={{upgradeBtn,upgradeBg},{smeltBtn,smeltBg}}
	--配件绑定和突破用同一个开关, 然而如果是紫色突破成橙色的话还是保持原来的逻辑；绑定的橙色配件可以突破，未绑定显示突破按钮，但是提示需绑定
	if((base.accessoryBind==1 and self.data:getConfigData("quality")<4) or self.data:getConfigData("quality")==3 or (accessoryVoApi:isUpgradeQualityRed()==true and self.data:getConfigData("quality")==4))then
		table.insert(self.btnTb,{evolutionBtn,evolutionBg})
	end
	--红配晋升开关开启 && 红色配件 && 已经绑定
	if base.redAccessoryPromote == 1 and self.data:getConfigData("quality") == 5 and self.data.bind == 1 then
		table.insert(self.btnTb, {promoteBtn, promoteBg})
	end
	local canBind=accessoryVoApi:checkCanBind(self.tankID,self.partID)
	if(self.data.bind==1 and playerVoApi:getPlayerLevel()>=50 and self.data:getConfigData("quality")>3 and base.accessoryTech==1)then
		table.insert(self.btnTb,{techBtn,techBg})
	elseif(canBind==0 or canBind==3)then
		table.insert(self.btnTb,{bindBtn,bindBg})
	end
	if(accessoryVoApi:succinctIsOpen() and self.data:getConfigData("quality")>2)then
		table.insert(self.btnTb,{purifyBtn,purifyBg})
	end
	if(self.data.bind~=1)then
		table.insert(self.btnTb,{takeOffBtn,takeOffBg})
	end
	local posTb
	local count=#self.btnTb
	if(count==2)then
		posTb={ccp(500,G_VisibleSizeHeight - 85 - 220),ccp(140,G_VisibleSizeHeight - 85 - 220)}
	elseif(count==3)then
		posTb={ccp(320,G_VisibleSizeHeight - 85 - 60),ccp(450,G_VisibleSizeHeight - 85 - 300),ccp(190,G_VisibleSizeHeight - 85 - 300)}
	elseif(count==4)then
		posTb={ccp(190,G_VisibleSizeHeight - 85 - 110),ccp(450,G_VisibleSizeHeight - 85 - 110),ccp(450,G_VisibleSizeHeight - 85 - 330),ccp(190,G_VisibleSizeHeight - 85 - 330)}
	elseif(count==5)then
		posTb={ccp(320,G_VisibleSizeHeight - 85 - 60),ccp(490,G_VisibleSizeHeight - 85 - 180),ccp(440,G_VisibleSizeHeight - 85 - 330),ccp(200,G_VisibleSizeHeight - 85 - 330),ccp(150,G_VisibleSizeHeight - 85 - 180)}
	else
		posTb={ccp(220,G_VisibleSizeHeight - 85 - 80),ccp(420,G_VisibleSizeHeight - 85 - 80),ccp(500,G_VisibleSizeHeight - 85 - 220),ccp(420,G_VisibleSizeHeight - 85 - 360),ccp(220,G_VisibleSizeHeight - 85 - 360),ccp(140,G_VisibleSizeHeight - 85 - 220)}
	end
	for k,pos in pairs(posTb) do
		self.btnTb[k][1]:setTouchPriority(-(self.layerNum-1)*20-2)
		self.btnTb[k][1]:setPosition(pos)
		self.btnTb[k][2]:setPosition(pos.x,pos.y - 65)
		self.bgLayer:addChild(self.btnTb[k][1])
		self.bgLayer:addChild(self.btnTb[k][2])
	end
end

function accessoryOperateDialog:showEquipDialog(tab)
	self.isShow=false
	local function onCloseEquip(event,data)
		self.isShow=true
		if(self.needRefresh)then
			self:refresh()
		end
		eventDispatcher:removeEventListener("accessory.dialog.closeEquip",onCloseEquip)
	end
	eventDispatcher:addEventListener("accessory.dialog.closeEquip",onCloseEquip)
	accessoryVoApi:showEquipDialog(self.tankID,self.partID,self.layerNum + 1,tab)
end

function accessoryOperateDialog:initDown()
	local strSize2 = 21
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
	local attAdd=self.data:getAttWithSuccinct()
	local startY=G_VisibleSizeHeight - 85 - 500
	local row = 4
	if G_getIphoneType() == G_iphone4 then
		row = 5
	end
	local unitHeight=math.min((startY - 50)/row,90)

	local propertyTb = {
		{ icon = "accessoryUpgrade.png", label = getlocal("accessory_lv",{self.data.lv}) },
		{ icon = "accessorySmelt.png", label = getlocal("accessory_rank",{self.data.rank}) },
	}
	if base.succinct == 1 then
		table.insert(propertyTb, { icon = "accessoryPurify.png", label = getlocal("accessory_purifyAdd",{SizeOfTable(self:getPurifyExtraAtt())}) })
	end
	if base.accessoryTech == 1 then
		table.insert(propertyTb, { icon = "accessoryTech.png", label = getlocal("accessory_techPoint",{self.data:getTechSkillPointByIDAndLv()}) })
	end
	if base.redAccessoryPromote == 1 then
		table.insert(propertyTb, { icon = "accessoryPromote_icon.png", label = getlocal("accessory_promoteLevel",{self.data.promoteLv}) })
	end
	for i = 1, 4 do
		local tempIcon, tempLabel
		if i == 1 then tempIcon = buffEffectCfg[100].icon
		elseif i == 2 then tempIcon = buffEffectCfg[108].icon
		elseif i == 3 then tempIcon = buffEffectCfg[201].icon
		elseif i == 4 then tempIcon = buffEffectCfg[202].icon
		end
		if accessoryCfg.attEffect[i] == 1 then
			tempLabel = getlocal("accessory_attAdd_" .. i, {attAdd[i] .. "%%"})
		else
			tempLabel = getlocal("accessory_attAdd_" .. i, {attAdd[i]})
		end
		table.insert(propertyTb, { icon = tempIcon, label = tempLabel })
	end
	local propertyTbSize = SizeOfTable(propertyTb)
	if propertyTbSize % 2 ~= 0 then
		table.insert(propertyTb, propertyTbSize - 3, {})
	end
	local iconSize = 70
	if G_getIphoneType() == G_iphone4 then
		iconSize = 50
	end
	for i, v in pairs(propertyTb) do
		if v.icon then
			local icon = CCSprite:createWithSpriteFrameName(v.icon)
			local posX,posY
			if(i%2==0)then
				posX=G_VisibleSizeWidth/2 + 5
				posY=startY - unitHeight*i/2 + unitHeight/2
			else
				posX=30
				posY=startY - unitHeight*(i+1)/2 + unitHeight/2
			end
			icon:setScale(iconSize/icon:getContentSize().width)
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(posX,posY)
			self.bgLayer:addChild(icon)
			local lb = GetTTFLabelWrap(v.label, strSize2, CCSizeMake(G_VisibleSizeWidth - 450, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
			lb:setTag(200 + i)
			lb:setAnchorPoint(ccp(0,0.5))
			lb:setPosition(posX + 80,posY)
			self.bgLayer:addChild(lb)
		end
	end

--[[
	--该逻辑可能存在问题，如果科技开关(accessoryTech)开启，精炼开关(succinct)关闭，精炼的图标仍然会显示出来 @?????????
	--但是策划口述强调的是精炼开关(succinct)不会关闭 ......^.^
	local endIndex
	if(base.accessoryTech==1)then
		endIndex=8
	elseif(base.succinct==1)then
		endIndex=7
	else
		endIndex=6
	end
	for i=1,endIndex do
		local icon
		if(i==endIndex - 3)then
			icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[100].icon)
		elseif(i==endIndex - 2)then
			icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[108].icon)
		elseif(i==endIndex - 1)then
			icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[201].icon)
		elseif(i==endIndex)then
			icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[202].icon)
		elseif(i==1)then
			icon=CCSprite:createWithSpriteFrameName("accessoryUpgrade.png")
		elseif(i==2)then
			icon=CCSprite:createWithSpriteFrameName("accessorySmelt.png")
		elseif(i==3)then
			icon=CCSprite:createWithSpriteFrameName("accessoryPurify.png")
		elseif(i==4)then
			icon=CCSprite:createWithSpriteFrameName("accessoryTech.png")
		end
		local posX,posY
		if(i%2==0)then
			posX=G_VisibleSizeWidth/2 + 5
			posY=startY - unitHeight*i/2 + unitHeight/2
		else
			posX=30
			posY=startY - unitHeight*(i+1)/2 + unitHeight/2
		end
		icon:setScale(70/icon:getContentSize().width)
		icon:setAnchorPoint(ccp(0,0.5))
		icon:setPosition(posX,posY)
		self.bgLayer:addChild(icon)
		local lb
		if(i>endIndex - 4)then
			local attIndex=i - (endIndex - 4)
			if(accessoryCfg.attEffect[attIndex]==1)then
				lb=GetTTFLabelWrap(getlocal("accessory_attAdd_"..attIndex,{attAdd[attIndex].."%%"}),strSize2,CCSizeMake(G_VisibleSizeWidth-450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			else
				lb=GetTTFLabelWrap(getlocal("accessory_attAdd_"..attIndex,{attAdd[attIndex]}),strSize2,CCSizeMake(G_VisibleSizeWidth-450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			end
		elseif(i==1)then
			lb=GetTTFLabelWrap(getlocal("accessory_lv",{self.data.lv}),strSize2,CCSizeMake(G_VisibleSizeWidth-450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		elseif(i==2)then
			lb=GetTTFLabelWrap(getlocal("accessory_rank",{self.data.rank}),strSize2,CCSizeMake(G_VisibleSizeWidth-450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		elseif(i==3)then
			lb=GetTTFLabelWrap(getlocal("accessory_purifyAdd",{SizeOfTable(self:getPurifyExtraAtt())}),strSize2,CCSizeMake(G_VisibleSizeWidth-450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		elseif(i==4)then
			lb=GetTTFLabelWrap(getlocal("accessory_techPoint",{self.data:getTechSkillPointByIDAndLv()}),strSize2,CCSizeMake(G_VisibleSizeWidth-450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		end
		lb:setTag(200 + i)
		lb:setAnchorPoint(ccp(0,0.5))
		lb:setPosition(posX + 80,posY)
		self.bgLayer:addChild(lb)
	end
--]]
	local gsLb=GetTTFLabel(getlocal("accessory_gsAdd",{self.data:getGS() + self.data:getGsAdd()}),25)
	gsLb:setTag(101)
	if(G_isIphone5())then
		gsLb:setPosition(ccp(G_VisibleSizeWidth/2,68))
	else
		gsLb:setPosition(ccp(G_VisibleSizeWidth/2,38))
	end
	gsLb:setColor(G_ColorGreen)
	self.bgLayer:addChild(gsLb)
end

function accessoryOperateDialog:getPurifyExtraAtt()
	local totalBonus={}
	local succinct=self.data:getSuccinct()
	local refineId=self.data:getConfigData("refineId")
	if(refineId and refineId>0)then
		local bounsAtt = succinctCfg.bounsAtt[refineId]
		for i=1,4 do
			local flag=false
			for k,v in pairs(bounsAtt[i][1]) do
				if(i==2)then
					if(succinct[1]>=v)then
						flag=true
					end
				elseif(i==1)then
					if(succinct[2]>=v)then
						flag=true
					end
				else
					if(succinct[i]>=v)then
						flag=true
					end
				end
			end
			if(flag)then
				for k,v in pairs(bounsAtt[i][2]) do
					if(totalBonus[k])then
						totalBonus[k]=totalBonus[k] + v
					else
						totalBonus[k]=v
					end
				end
			end
		end
	end
	return totalBonus
end

function accessoryOperateDialog:refresh()
	if(self.isCloseing)then
		do return end
	end
	self.data=accessoryVoApi:getAccessoryByPart(self.tankID,self.partID)
	if(self.data==nil)then
		do return end
	end
	self.needRefresh=false
	self:refreshUp()
	local attAdd=self.data:getAttWithSuccinct()

	local propertyTb = {
		{ label = getlocal("accessory_lv",{self.data.lv}) },
		{ label = getlocal("accessory_rank",{self.data.rank}) },
	}
	if base.succinct == 1 then
		table.insert(propertyTb, { label = getlocal("accessory_purifyAdd",{SizeOfTable(self:getPurifyExtraAtt())}) })
	end
	if base.accessoryTech == 1 then
		table.insert(propertyTb, { label = getlocal("accessory_techPoint",{self.data:getTechSkillPointByIDAndLv()}) })
	end
	if base.redAccessoryPromote == 1 then
		table.insert(propertyTb, { label = getlocal("accessory_promoteLevel",{self.data.promoteLv}) })
	end
	for i = 1, 4 do
		local tempLabel
		if accessoryCfg.attEffect[i] == 1 then
			tempLabel = getlocal("accessory_attAdd_" .. i, {attAdd[i] .. "%%"})
		else
			tempLabel = getlocal("accessory_attAdd_" .. i, {attAdd[i]})
		end
		table.insert(propertyTb, { label = tempLabel })
	end
	for i, v in pairs(propertyTb) do
		local lb = tolua.cast(self.bgLayer:getChildByTag(200 + i), "CCLabelTTF")
		if lb then
			lb:setString(v.label)
		end
	end

--[[
	--该逻辑可能存在问题，如果科技开关(accessoryTech)开启，精炼开关(succinct)关闭，精炼的图标仍然会显示出来 @?????????
	--但是策划口述强调的是精炼开关(succinct)不会关闭 ......^.^
	local endIndex
	if(base.accessoryTech==1)then
		endIndex=8
	elseif(base.succinct==1)then
		endIndex=7
	else
		endIndex=6
	end
	for i=1,endIndex do
		local lb=tolua.cast(self.bgLayer:getChildByTag(200 + i),"CCLabelTTF")
		if(lb)then
			if(i>endIndex - 4)then
				local attIndex=i - (endIndex - 4)
				if(accessoryCfg.attEffect[i]==1)then
					lb:setString(getlocal("accessory_attAdd_"..attIndex,{attAdd[attIndex].."%%"}))
				else
					lb:setString(getlocal("accessory_attAdd_"..attIndex,{attAdd[attIndex]}))
				end
			elseif(i==1)then
				lb:setString(getlocal("accessory_lv",{self.data.lv}))
			elseif(i==2)then
				lb:setString(getlocal("accessory_rank",{self.data.rank}))
			elseif(i==3)then
				lb:setString(getlocal("accessory_purifyAdd",{SizeOfTable(self:getPurifyExtraAtt())}))
			elseif(i==4)then
				lb:setString(getlocal("accessory_techPoint",{self.data:getTechSkillPointByIDAndLv()}))
			end
		end
	end
--]]
	local gsLb=tolua.cast(self.bgLayer:getChildByTag(101),"CCLabelTTF")
	if(gsLb)then
		gsLb:setString(getlocal("accessory_gsAdd",{self.data:getGS() + self.data:getGsAdd()}))
	end
end

function accessoryOperateDialog:takeOff()
	if(self.data==nil)then
		do return end
	end
	if(self.data.bind==1)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage9042"),30)
		do return end
	end
	if(accessoryVoApi:getABagLeftGrid()<=0)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_bag_full"),30)
		do return end
	end
	local function callback()
		self:close()
	end
	accessoryVoApi:takeOff(self.tankID,self.partID,callback)
end

function accessoryOperateDialog:dispose()
	eventDispatcher:removeEventListener("accessory.data.refresh",self.refreshListener)
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryOperateBg.jpg")
	self.btnTb=nil
	self.isShow=nil
	self.needRefresh=nil
	eventDispatcher:dispatchEvent("accessory.dialog.closeOperate")
end