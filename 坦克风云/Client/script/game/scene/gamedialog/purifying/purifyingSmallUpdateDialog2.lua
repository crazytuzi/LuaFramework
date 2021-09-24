purifyingSmallUpdateDialog2=smallDialog:new()

function purifyingSmallUpdateDialog2:new(oldLevel)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.oldLevel=oldLevel
    self.dialogHeight=440
    self.dialogWidth=600
    self.parent=nil
    self.data=nil
    self.type=0     --是配件还是碎片
    return nc
end

function purifyingSmallUpdateDialog2:init(layerNum,parent,titleStr,isUnlock)
	self.layerNum=layerNum
    self.parent=parent

    local PreTb = {
    "privilege_1",
    "privilege_2",
    "privilege_3",
    "privilege_4",
    "privilege_5",
    "privilege_6",
    "privilege_7",
    "privilege_8",
    "privilege_9",
    "privilege_10",
    "privilege_11",

    }
    local lockPreStr
    self.level = accessoryVoApi:getSuccinct_level()
    for k,v in pairs(PreTb) do
        if self.level==succinctCfg[v] then
            lockPreStr=getlocal(v)
            isUnlock=true
            break
        end
    end

    if isUnlock==false or isUnlock==nil then
        self.dialogHeight=360
    end

    local function nilFunc()
	end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168,86,10,10),nilFunc)
    self.dialogLayer=CCLayer:create()

    local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
    self.dialogLayer:setBSwallowsTouches(true);

    if titleStr~=nil then
        if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai"  or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage()=="pt" or G_getCurChoseLanguage()=="fr" then
          self.titleLabel = GetTTFLabelWrap(titleStr,33,CCSizeMake(dialogBg:getContentSize().width-220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
        else
          self.titleLabel = GetTTFLabel(titleStr,40)
        end
        self.titleLabel:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-40))
        dialogBg:addChild(self.titleLabel,2);
     end

    local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
         
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)

	--遮罩层
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

	local panelLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),nilFunc)
	panelLineBg:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height/2+10))
	panelLineBg:setContentSize(CCSizeMake(560,dialogBg:getContentSize().height-200))
	dialogBg:addChild(panelLineBg)

	local lbWidth = 30
	local lbHeight = dialogBg:getContentSize().height-120
	local engineerLvLb = GetTTFLabel(getlocal("purifying_engineer_level",{self.oldLevel}),25)
    engineerLvLb:setPosition(ccp(lbWidth,lbHeight))
    engineerLvLb:setAnchorPoint(ccp(0,0.5))
    dialogBg:addChild(engineerLvLb)

    local arrowSp = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
    arrowSp:setAnchorPoint(ccp(0,0.5))
    engineerLvLb:addChild(arrowSp)
    arrowSp:setPosition(engineerLvLb:getContentSize().width+20,engineerLvLb:getContentSize().height/2)

    local newLvLb = GetTTFLabel(accessoryVoApi:getSuccinct_level(),25)
    newLvLb:setAnchorPoint(ccp(0,0.5))
    arrowSp:addChild(newLvLb)
    newLvLb:setPosition(arrowSp:getContentSize().width+20,arrowSp:getContentSize().height/2)


    local icon1=CCSprite:createWithSpriteFrameName("refiningAtkIcon.png")
    icon1:setAnchorPoint(ccp(0,0.5))
    icon1:setPosition(ccp(lbWidth,lbHeight-40))
    dialogBg:addChild(icon1)
    icon1:setScale(0.6)

    local andLb = GetTTFLabel("&",22)
    andLb:setPosition(ccp(icon1:getContentSize().width+3,icon1:getContentSize().height/2))
    andLb:setAnchorPoint(ccp(0,0.5))
    icon1:addChild(andLb)

    local icon2=CCSprite:createWithSpriteFrameName("refiningLifeIcon.png")
    icon2:setAnchorPoint(ccp(0,0.5))
    icon2:setPosition(ccp(andLb:getContentSize().width+3,andLb:getContentSize().height/2))
    andLb:addChild(icon2)

    local limitLb1 = GetTTFLabel(getlocal("limit_up"),40)
    limitLb1:setAnchorPoint(ccp(0,0.5))
    icon2:addChild(limitLb1)
    limitLb1:setPosition(icon2:getContentSize().width+20,icon2:getContentSize().height/2)

    local maohaoLb = GetTTFLabel(":",40)
    maohaoLb:setAnchorPoint(ccp(0,0.5))
    maohaoLb:setPosition(ccp(limitLb1:getContentSize().width+8,limitLb1:getContentSize().height/2))
    limitLb1:addChild(maohaoLb)

    

    local oldLifeLimit = GetTTFLabel(succinctCfg.attLifeLimit[self.oldLevel]*100 .. "%",40)
    oldLifeLimit:setAnchorPoint(ccp(0,0.5))
    maohaoLb:addChild(oldLifeLimit)
    oldLifeLimit:setPosition(maohaoLb:getContentSize().width+20,maohaoLb:getContentSize().height/2)

    local arrowSp = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
    arrowSp:setAnchorPoint(ccp(0,0.5))
    oldLifeLimit:addChild(arrowSp)
    arrowSp:setPosition(oldLifeLimit:getContentSize().width+20,oldLifeLimit:getContentSize().height/2)
    arrowSp:setScale(1.5)

    local newLvLb = GetTTFLabel(succinctCfg.attLifeLimit[accessoryVoApi:getSuccinct_level()]*100 .. "%",25)
    newLvLb:setAnchorPoint(ccp(0,0.5))
    arrowSp:addChild(newLvLb)
    newLvLb:setPosition(arrowSp:getContentSize().width+20,arrowSp:getContentSize().height/2)



    local icon1=CCSprite:createWithSpriteFrameName("refiningPenIcon.png")
    icon1:setAnchorPoint(ccp(0,0.5))
    icon1:setPosition(ccp(lbWidth,lbHeight-80))
    dialogBg:addChild(icon1)
    icon1:setScale(0.6)

    local andLb = GetTTFLabel("&",22)
    andLb:setPosition(ccp(icon1:getContentSize().width+3,icon1:getContentSize().height/2))
    andLb:setAnchorPoint(ccp(0,0.5))
    icon1:addChild(andLb)

    local icon2=CCSprite:createWithSpriteFrameName("refiningDefIcon.png")
    icon2:setAnchorPoint(ccp(0,0.5))
    icon2:setPosition(ccp(andLb:getContentSize().width+3,andLb:getContentSize().height/2))
    andLb:addChild(icon2)

    local limitLb1 = GetTTFLabel(getlocal("limit_up"),40)
    limitLb1:setAnchorPoint(ccp(0,0.5))
    icon2:addChild(limitLb1)
    limitLb1:setPosition(icon2:getContentSize().width+20,icon2:getContentSize().height/2)

    local maohaoLb = GetTTFLabel(":",40)
    maohaoLb:setAnchorPoint(ccp(0,0.5))
    maohaoLb:setPosition(ccp(limitLb1:getContentSize().width+8,limitLb1:getContentSize().height/2))
    limitLb1:addChild(maohaoLb)

    local oldLifeLimit = GetTTFLabel(succinctCfg.arpArmorLimit[self.oldLevel],40)
    oldLifeLimit:setAnchorPoint(ccp(0,0.5))
    maohaoLb:addChild(oldLifeLimit)
    oldLifeLimit:setPosition(maohaoLb:getContentSize().width+20,maohaoLb:getContentSize().height/2)

    local arrowSp = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
    arrowSp:setAnchorPoint(ccp(0,0.5))
    oldLifeLimit:addChild(arrowSp)
    arrowSp:setPosition(oldLifeLimit:getContentSize().width+20,oldLifeLimit:getContentSize().height/2)
    arrowSp:setScale(1.5)

    local newLvLb = GetTTFLabel(succinctCfg.arpArmorLimit[accessoryVoApi:getSuccinct_level()],25)
    newLvLb:setAnchorPoint(ccp(0,0.5))
    arrowSp:addChild(newLvLb)
    newLvLb:setPosition(arrowSp:getContentSize().width+20,arrowSp:getContentSize().height/2)


    if isUnlock then
        local unlockPrivilege = GetTTFLabel(getlocal("unlock_privilege"),25)
        unlockPrivilege:setPosition(ccp(dialogBg:getContentSize().width/2,lbHeight-130))
        unlockPrivilege:setAnchorPoint(ccp(0.5,0.5))
        dialogBg:addChild(unlockPrivilege)

        local autoPurifying = GetTTFLabel(lockPreStr,25)
        autoPurifying:setPosition(ccp(dialogBg:getContentSize().width/2,lbHeight-170))
        autoPurifying:setAnchorPoint(ccp(0.5,0.5))
        dialogBg:addChild(autoPurifying)
    end


	local function touchBtn()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local btnItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchBtn,nil,getlocal("confirm"),25)
	btnItem:setAnchorPoint(ccp(0.5,0))
	local Btn=CCMenu:createWithItem(btnItem);
	Btn:setTouchPriority(-(self.layerNum-1)*20-4);
	Btn:setPosition(ccp(dialogBg:getContentSize().width/2,20))
	dialogBg:addChild(Btn)


    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))   

end

function purifyingSmallUpdateDialog2:initTableView()
	local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-300),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,120))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function purifyingSmallUpdateDialog2:eventHandler(handler,fn,idx,cel)
end	

