--平台战选择路线的小面板
platWarSelectRoadDialog=smallDialog:new()

--param cityID: 城市ID, a1到a11
function platWarSelectRoadDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.dialogWidth=550
	nc.dialogHeight=750
	return nc
end

function platWarSelectRoadDialog:init(layerNum,fleetIndex,callback)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
	self.isTouch=nil
	self.layerNum=layerNum
	self.fleetIndex=fleetIndex
	local function onHide()
		self:close()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),onHide)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),onHide)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(touchDialogBg)

	local titleLb=GetTTFLabel(getlocal("plat_war_changeRoad"),28)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 50))
	dialogBg:addChild(titleLb,1)

	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 70))
	dialogBg:addChild(lineSp)

	local troopList=platWarVoApi:getTroopList()
	local roadSelfNumList={}
	local roadEnemyNumList={}
	if(platWarVoApi:getPlatList()[1][1]==base.serverPlatID)then
		roadSelfNumList=troopList[1]
		roadEnemyNumList=troopList[2]
	else
		roadSelfNumList=troopList[2]
		roadEnemyNumList=troopList[1]
	end
	local function onSelectRoad(tag,object)
		local line=tankVoApi:getPlatWarFleetIndex(self.fleetIndex)
		if line==tag then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_had_select_road"),30)
			do return end
		end
		tankVoApi:setPlatWarFleetIndex(self.fleetIndex,tag)
		if callback then
			callback()
		end
		self:close()
	end
	local posY=self.dialogHeight - 85
	for i=1,platWarCfg.mapAttr.lineNum do
		local realIndex=platWarCfg.mapAttr.linePosClient[i]
		local landType=platWarCfg.mapAttr.lineLandtype[realIndex]
		local icon=GetBgIcon("world_ground_"..landType..".png")
		icon:setScale(120/icon:getContentSize().width)
		icon:setPosition(ccp(80,posY - 60))
		dialogBg:addChild(icon)
		local roadName=GetTTFLabel(getlocal("plat_war_road_"..realIndex),25)
		roadName:setColor(G_ColorGreen)
		roadName:setAnchorPoint(ccp(0,0.5))
		roadName:setPosition(150,posY - 15)
		dialogBg:addChild(roadName)
		local numLb1=GetTTFLabelWrap(getlocal("plat_war_ourTroopsNum",{roadSelfNumList[realIndex]}),23,CCSizeMake(self.dialogWidth - 300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		numLb1:setAnchorPoint(ccp(0,0.5))
		numLb1:setPosition(150,posY - 65)
		dialogBg:addChild(numLb1)
		local numLb2=GetTTFLabelWrap(getlocal("plat_war_enemyTroopsNum",{roadEnemyNumList[realIndex]}),23,CCSizeMake(self.dialogWidth - 300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		numLb2:setAnchorPoint(ccp(0,0.5))
		numLb2:setPosition(150,posY - 105)
		dialogBg:addChild(numLb2)
		local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",onSelectRoad,realIndex,getlocal("dailyAnswer_tab1_btn"),25)
		local okBtn=CCMenu:createWithItem(okItem)
		okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		okBtn:setPosition(self.dialogWidth - 100,posY - 60)
		dialogBg:addChild(okBtn)
		posY = posY - 130
	end

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function platWarSelectRoadDialog:dispose()
end