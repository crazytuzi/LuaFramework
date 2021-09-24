purifyingSmallUpdateDialog=smallDialog:new()

function purifyingSmallUpdateDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.dialogHeight=800
    self.dialogWidth=600

    self.parent=nil
    self.data=nil
    self.type=0     --是配件还是碎片
    return nc
end

function purifyingSmallUpdateDialog:init(layerNum,parent,titleStr)
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
	self.layerNum=layerNum
    self.parent=parent  
    self.level = accessoryVoApi:getSuccinct_level()
    self.privilegeTb=
    {
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

	local lbWidth = 80
	local lbHeight = dialogBg:getContentSize().height-120
	local engineerLb = GetTTFLabel(getlocal("engineer"),strSize2)
    engineerLb:setPosition(ccp(lbWidth,lbHeight))
    engineerLb:setAnchorPoint(ccp(0.5,0.5))
    dialogBg:addChild(engineerLb)

	local privilegeLb = GetTTFLabel(getlocal("dailyTask_sub_title_4"),strSize2)
    privilegeLb:setPosition(ccp(480,lbHeight))
    privilegeLb:setAnchorPoint(ccp(0.5,0.5))
    dialogBg:addChild(privilegeLb)

    local lvLb = GetTTFLabel(getlocal("RankScene_level"),strSize2)
    lvLb:setPosition(ccp(lbWidth,lbHeight-40))
    lvLb:setAnchorPoint(ccp(0.5,0.5))
    dialogBg:addChild(lvLb)

    local icon1=CCSprite:createWithSpriteFrameName("refiningAtkIcon.png")
    icon1:setAnchorPoint(ccp(0,0.5))
    icon1:setPosition(ccp(lbWidth+90,lbHeight))
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



    local limitLb1 = GetTTFLabelWrap(getlocal("limit_up"),strSize2,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    limitLb1:setPosition(ccp(lbWidth+100,lbHeight-40))
    limitLb1:setAnchorPoint(ccp(0,0.5))
    dialogBg:addChild(limitLb1)


    local icon1=CCSprite:createWithSpriteFrameName("refiningPenIcon.png")
    icon1:setAnchorPoint(ccp(0,0.5))
    icon1:setPosition(ccp(lbWidth+210,lbHeight))
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

    local limitLb2 = GetTTFLabelWrap(getlocal("limit_up"),strSize2,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    limitLb2:setPosition(ccp(lbWidth+220,lbHeight-40))
    limitLb2:setAnchorPoint(ccp(0,0.5))
    dialogBg:addChild(limitLb2)

    self:initTableView()

	local function touchBtn()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local btnItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchBtn,nil,getlocal("confirm"),strSize2)
	btnItem:setAnchorPoint(ccp(0.5,0))
	local Btn=CCMenu:createWithItem(btnItem);
	Btn:setTouchPriority(-(self.layerNum-1)*20-4);
	Btn:setPosition(ccp(dialogBg:getContentSize().width/2,20))
	dialogBg:addChild(Btn)


    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    

end

function purifyingSmallUpdateDialog:initTableView()
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

function purifyingSmallUpdateDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        if self.level==succinctCfg.engineerLvLimit then
            return self.level+1
        else
            return self.level+2
        end
        
    elseif fn=="tableCellSizeForIndex" then
    	self.cellSize = CCSizeMake(self.bgLayer:getContentSize().width-20,70)
       return  self.cellSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

		if idx==0 then
			local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
			bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2+10,self.cellSize.height/2));
			bgSp:setScaleY(self.cellSize.height/bgSp:getContentSize().height)
			bgSp:setScaleX(730/bgSp:getContentSize().width)
			cell:addChild(bgSp)

		end

        local lbWidth = 30 

        local lvStr
        local limitStr1
        local limitStr2
        if idx==0 then
            lvStr=self.level
            limitStr1=succinctCfg.attLifeLimit[self.level]*100 .. "%"
            limitStr2=succinctCfg.arpArmorLimit[self.level]
        else
            lvStr=idx
            limitStr1=succinctCfg.attLifeLimit[idx]*100 .. "%"
            limitStr2=succinctCfg.arpArmorLimit[idx]
        end
        local lvLb = GetTTFLabel(lvStr,25)
	    lvLb:setPosition(ccp(70,35))
	    lvLb:setAnchorPoint(ccp(0.5,0.5))
	    cell:addChild(lvLb)


	    local limitLb1 = GetTTFLabel(limitStr1,25)
	    limitLb1:setPosition(ccp(170,self.cellSize.height/2))
	    limitLb1:setAnchorPoint(ccp(0,0.5))
	    cell:addChild(limitLb1)

	    local limitLb2 = GetTTFLabel(limitStr2,25)
	    limitLb2:setPosition(ccp(300,self.cellSize.height/2))
	    limitLb2:setAnchorPoint(ccp(0,0.5))
	    cell:addChild(limitLb2)

        local priStr=""
        local comLv
        if idx==0 then
            comLv=self.level
        else
            comLv=idx
        end

        if succinctCfg.privilege_1==comLv then
            priStr=getlocal(self.privilegeTb[1])
        elseif succinctCfg.privilege_2==comLv then
            priStr=getlocal(self.privilegeTb[2])
        elseif succinctCfg.privilege_3==comLv then
            priStr=getlocal(self.privilegeTb[3])
        elseif succinctCfg.privilege_4==comLv then
            priStr=getlocal(self.privilegeTb[4])
        elseif succinctCfg.privilege_5==comLv then
            priStr=getlocal(self.privilegeTb[5])
        elseif succinctCfg.privilege_6==comLv then
            priStr=getlocal(self.privilegeTb[6])
        elseif succinctCfg.privilege_7==comLv then
            priStr=getlocal(self.privilegeTb[7])
        elseif succinctCfg.privilege_8==comLv then
            priStr=getlocal(self.privilegeTb[8])
        elseif succinctCfg.privilege_9==comLv then
            priStr=getlocal(self.privilegeTb[9])
        elseif succinctCfg.privilege_10==comLv then
            priStr=getlocal(self.privilegeTb[10])
        elseif succinctCfg.privilege_11==comLv then
            priStr=getlocal(self.privilegeTb[11])
        end

        local priLb=GetTTFLabelWrap(priStr,25,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    priLb:setPosition(ccp(380,self.cellSize.height/2))
	    priLb:setAnchorPoint(ccp(0,0.5))
	    cell:addChild(priLb)

        if idx>self.level then
            lvLb:setColor(G_ColorGray)
            limitLb1:setColor(G_ColorGray)
            limitLb2:setColor(G_ColorGray)
            priLb:setColor(G_ColorGray)           
        end



        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end

end	

