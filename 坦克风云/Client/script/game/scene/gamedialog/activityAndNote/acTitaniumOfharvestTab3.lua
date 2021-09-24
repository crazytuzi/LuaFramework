acTitaniumOfharvestTab3={

}

function acTitaniumOfharvestTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    return nc
end
function acTitaniumOfharvestTab3:init(layerNum)
 	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

	-- 活动info
	local capInSet = CCRect(65, 25, 1, 1)
	local function bgClick(hd,fn,idx)
    end
    local desBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",capInSet,bgClick)
	desBg:setContentSize(CCSizeMake(G_VisibleSize.width-60,180))
	desBg:setAnchorPoint(ccp(0.5,1))
	desBg:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height-165))
	desBg:setTouchPriority(-(self.layerNum-1)*20-1)
	self.bgLayer:addChild(desBg)

	local timeTitle = GetTTFLabel(getlocal("activity_timeLabel"),25)
    timeTitle:setAnchorPoint(ccp(0.5,1))
	timeTitle:setPosition(ccp(desBg:getContentSize().width/2, desBg:getContentSize().height-10))
	desBg:addChild(timeTitle)
	timeTitle:setColor(G_ColorGreen)

	local timeLabel = GetTTFLabelWrap(acTitaniumOfharvestVoApi:getTimeStr(),25,CCSizeMake(desBg:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeLabel:setAnchorPoint(ccp(0.5,1))
	timeLabel:setPosition(ccp(desBg:getContentSize().width/2, desBg:getContentSize().height-45))
	desBg:addChild(timeLabel)
    self.timeLb=timeLabel
    self:updateAcTime()

	local desTv,desLabel = G_LabelTableView(CCSizeMake(desBg:getContentSize().width-135, desBg:getContentSize().height-90),getlocal("activity_TitaniumOfharvest_tab3_des"),25,kCCTextAlignmentLeft)
 	desBg:addChild(desTv)
    desTv:setPosition(ccp(130,10))
    desTv:setAnchorPoint(ccp(0,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    desTv:setMaxDisToBottomOrTop(100) 

    local logoSp = CCSprite:createWithSpriteFrameName("alien_tech_building_1.png")
    logoSp:setPosition(ccp(65,desBg:getContentSize().height/2-15))
    logoSp:setScale(0.6)
    logoSp:setAnchorPoint(ccp(0.5,0.5))
    desBg:addChild(logoSp)


	local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local descBg1 =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
    descBg1:setContentSize(CCSizeMake(430,180))
    descBg1:setAnchorPoint(ccp(0,0))
    descBg1:setPosition(ccp(30,self.bgLayer:getContentSize().height- 580))
    self.bgLayer:addChild(descBg1)

    local desTv1,desLabel1 = G_LabelTableView(CCSizeMake(descBg1:getContentSize().width-60, descBg1:getContentSize().height-30),getlocal("activity_TitaniumOfharvest_tab3_des1"),25,kCCTextAlignmentLeft)
 	descBg1:addChild(desTv1)
    desTv1:setPosition(ccp(20,10))
    desTv1:setAnchorPoint(ccp(0,1))
    desTv1:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    desTv1:setMaxDisToBottomOrTop(100)

    local characterSp = CCSprite:createWithSpriteFrameName("NewCharacter02.png") --姑娘
    characterSp:setAnchorPoint(ccp(1,0))
    characterSp:setPosition(ccp(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height - 598))
    characterSp:setScale(0.9)
    self.bgLayer:addChild(characterSp)

    local rect = CCRect(0, 0, 50, 50);
	local capInSet = CCRect(20, 20, 10, 10);
	local function bsClick(hd,fn,idx)
	end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bsClick)
	backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, G_VisibleSize.height- 722))
	backSprie:ignoreAnchorPointForPosition(false);
	backSprie:setAnchorPoint(ccp(0.5,0));
	backSprie:setIsSallow(false)
	backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
	backSprie:setPosition(ccp(G_VisibleSize.width/2,130))
	self.bgLayer:addChild(backSprie)

	local lineSprie =CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 3))
	lineSprie:ignoreAnchorPointForPosition(false);
	lineSprie:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2))
	backSprie:addChild(lineSprie)

	local taiSp = CCSprite:createWithSpriteFrameName("resourse_normal_uranium.png")
    taiSp:setPosition(ccp(15,backSprie:getContentSize().height/4))
    taiSp:setScale(0.9)
    taiSp:setAnchorPoint(ccp(0,0.5))
    backSprie:addChild(taiSp)

    local buildSp = CCSprite:createWithSpriteFrameName("icon_build.png")
    buildSp:setPosition(ccp(15,backSprie:getContentSize().height/4*3))
    buildSp:setScale(0.9)
    buildSp:setAnchorPoint(ccp(0,0.5))
    backSprie:addChild(buildSp)

		

	local desTv2,desLabel2 = G_LabelTableView(CCSizeMake(backSprie:getContentSize().width-130, backSprie:getContentSize().height/2-10),getlocal("activity_TitaniumOfharvest_tab3_des2"),25,kCCTextAlignmentLeft)
 	backSprie:addChild(desTv2)
    desTv2:setPosition(ccp(120,backSprie:getContentSize().height/2+5))
    desTv2:setAnchorPoint(ccp(0,1))
    desTv2:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    desTv2:setMaxDisToBottomOrTop(100)

    local desTv3,desLabel3 = G_LabelTableView(CCSizeMake(backSprie:getContentSize().width-130, backSprie:getContentSize().height/2-10),getlocal("activity_TitaniumOfharvest_tab3_des3",{(1-acTitaniumOfharvestVoApi:getValue())*100 .. "%%"}),25,kCCTextAlignmentLeft)
 	backSprie:addChild(desTv3)
    desTv3:setPosition(ccp(120,5))
    desTv3:setAnchorPoint(ccp(0,1))
    desTv3:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    desTv3:setMaxDisToBottomOrTop(100)


    local function touchGotoItem()
        if G_checkClickEnable()==false then
                do
                    return
                end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local playerLv=playerVoApi:getPlayerLevel()
        if playerLv<alienTechCfg.openlevel then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_unlock_player_level",{alienTechCfg.openlevel}),30)
        else
            activityAndNoteDialog:closeAllDialog()
            alienTechVoApi:showAlienTechFactoryDialog(3)
        end
            
        
    end
    local gotoItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchGotoItem,nil,getlocal("activity_heartOfIron_goto"),25)
	gotoItem:setAnchorPoint(ccp(0.5,0))
	local gotoMenu=CCMenu:createWithItem(gotoItem)
	gotoMenu:setTouchPriority(-(self.layerNum-1)*20-2)
	gotoMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2, 40))
	self.bgLayer:addChild(gotoMenu)

	return self.bgLayer
end

function acTitaniumOfharvestTab3:tick()
    self:updateAcTime()
end

function acTitaniumOfharvestTab3:updateAcTime()
  local acVo=acTitaniumOfharvestVoApi:getAcVo()
  if acVo and self.timeLb then
    G_updateActiveTime(acVo,self.timeLb)
  end
end

function acTitaniumOfharvestTab3:dispose()
	self.bgLayer=nil
	self.layerNum=nil
	self.tv=nil
    self.timeLb=nil
end