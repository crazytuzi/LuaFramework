acArmamentsUpdateDialog2=acArmamentsUpdateDialog:new()

function acArmamentsUpdateDialog2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self


    self.cellHeight2=nil
    return nc
end
function acArmamentsUpdateDialog2:initmaterialsSprite()
    local headercapInSet = CCRect(20, 20, 10, 10);
    local function headerSprieClick(hd,fn,idx)
    
    end
    local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",headercapInSet,headerSprieClick)
    headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, (self.bgLayer:getContentSize().height-450)/2-5))
    headerSprie:ignoreAnchorPointForPosition(false);
    headerSprie:setAnchorPoint(ccp(0,0));
    headerSprie:setIsSallow(false)
    headerSprie:setPosition(ccp(30,(self.bgLayer:getContentSize().height-450)/2+45));
    self.bgLayer:addChild(headerSprie)

    local icon = CCSprite:createWithSpriteFrameName("item_prop_395.png")
    icon:setAnchorPoint(ccp(0,1))
    icon:setPosition(ccp(10,headerSprie:getContentSize().height-20))
    headerSprie:addChild(icon)

    local function mDescBgtouch()
    end
    local mDesccapInSet = CCRect(20, 20, 10, 10)
    local mDescBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",mDesccapInSet,mDescBgtouch)
    mDescBg:setContentSize(CCSizeMake(440,self.normalHeight))
    mDescBg:setAnchorPoint(ccp(0,1))
    mDescBg:setPosition(ccp(20+icon:getContentSize().width,headerSprie:getContentSize().height-20))
    headerSprie:addChild(mDescBg,1)
    local function mDescCallBack(...)
       return self:eventHandler1(...)
    end
    local mDeschd= LuaEventHandler:createHandler(mDescCallBack)
    self.tv1=LuaCCTableView:createWithEventHandler(mDeschd,CCSizeMake(380,self.normalHeight-20),nil)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv1:setPosition(ccp(55,10))
    mDescBg:addChild(self.tv1,1)
    self.tv1:setMaxDisToBottomOrTop(50)
    
    local function gotoStageHandler(tag,object)
        if G_checkClickEnable()==false then
          do
              return
          end
        end

        if newGuidMgr:isNewGuiding()==true then --新手引导
            do
              return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        activityAndNoteDialog:closeAllDialog()
        storyScene:setShow()
        
    end
    local stageBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",gotoStageHandler,0,getlocal("activity_armamentsUpdate_gotoStage"),25)
    stageBtn:setAnchorPoint(ccp(0.5, 0)) 
    local stageMenu=CCMenu:createWithItem(stageBtn)
    stageMenu:setPosition(ccp(headerSprie:getContentSize().width/2+50,10))
    stageMenu:setTouchPriority(-(self.layerNum-1)*20-4) 
    headerSprie:addChild(stageMenu,1)
end

function acArmamentsUpdateDialog2:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local descLabel=GetTTFLabelWrap(getlocal("activity_armamentsUpdate_materialsDesc1",{11}),25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if self.cellHeight1==nil then
            self.cellHeight1=descLabel:getContentSize().height+10
        end 
        if self.cellHeight1 <self.normalHeight-20 then
            self.cellHeight1 = self.normalHeight-20
        end
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.cellHeight1)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        
        local descLabel=GetTTFLabelWrap(getlocal("activity_armamentsUpdate_materialsDesc1",{11}),25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if self.cellHeight1==nil then
            self.cellHeight1=descLabel:getContentSize().height+10
        end 
        if self.cellHeight1 <self.normalHeight-20 then
            self.cellHeight1 = self.normalHeight-20
        end
        descLabel:setAnchorPoint(ccp(0,0.5))
        descLabel:setPosition(ccp(0,self.cellHeight1/2))
        cell:addChild(descLabel,1)
        descLabel:setColor(G_ColorYellow)

    
        return cell

    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end
function acArmamentsUpdateDialog2:initRefitSprie( ... )
		local refitcapInSet = CCRect(20, 20, 10, 10);
    local function refitSprieClick(hd,fn,idx)
    
    end
    local refitSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",refitcapInSet,refitSprieClick)
    refitSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,(self.bgLayer:getContentSize().height-450)/2-5))
    refitSprie:ignoreAnchorPointForPosition(false);
    refitSprie:setAnchorPoint(ccp(0,0));
    refitSprie:setIsSallow(false)
    refitSprie:setPosition(ccp(30,35));
    self.bgLayer:addChild(refitSprie)

    local refitIcon = CCSprite:createWithSpriteFrameName("ArtilleryLv6.png")
    refitIcon:setScale(100 / refitIcon:getContentSize().width)
    refitIcon:setAnchorPoint(ccp(0,1))
    refitIcon:setPosition(ccp(10,refitSprie:getContentSize().height-20))
    refitSprie:addChild(refitIcon)

    local function refitDescBgtouch()
    end
    local refitDesccapInSet = CCRect(20, 20, 10, 10)
    local refitDescBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",refitDesccapInSet,refitDescBgtouch)
    refitDescBg:setContentSize(CCSizeMake(440,self.normalHeight))
    refitDescBg:setAnchorPoint(ccp(0,1))
    refitDescBg:setPosition(ccp(120,refitSprie:getContentSize().height-20))
    refitSprie:addChild(refitDescBg,1)
    local function refitDescCallBack(...)
       return self:eventHandler2(...)
    end
    local refitDeschd= LuaEventHandler:createHandler(refitDescCallBack)
    self.tv2=LuaCCTableView:createWithEventHandler(refitDeschd,CCSizeMake(380,self.normalHeight-20),nil)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv2:setPosition(ccp(55,10))
    refitDescBg:addChild(self.tv2,1)
    self.tv2:setMaxDisToBottomOrTop(50)
    
    local function gotoRefitHandler(tag,object)
        if G_checkClickEnable()==false then
          do
              return
          end
        end
        PlayEffect(audioCfg.mouseClick)
        

        activityAndNoteDialog:gotoByTag(7,self.layerNum)
    end
    local refitBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",gotoRefitHandler,0,getlocal("activity_armamentsUpdate_gotoRefit"),25)
    refitBtn:setAnchorPoint(ccp(0.5, 0)) 
    local refitMenu=CCMenu:createWithItem(refitBtn)
    refitMenu:setPosition(ccp(refitSprie:getContentSize().width/2+50,10))
    refitMenu:setTouchPriority(-(self.layerNum-1)*20-4) 
    refitSprie:addChild(refitMenu,1) 
end

function acArmamentsUpdateDialog2:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local descLabel=GetTTFLabelWrap(getlocal("activity_armamentsUpdate_tankDesc2"),25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if self.cellHeight2==nil then
            self.cellHeight2=descLabel:getContentSize().height+10
        end 
        if self.cellHeight2 < self.normalHeight-20 then
            self.cellHeight2 = self.normalHeight-20
        end
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.cellHeight2)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        
        local descLabel=GetTTFLabelWrap(getlocal("activity_armamentsUpdate_tankDesc2"),25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if self.cellHeight2==nil then
            self.cellHeight2=descLabel:getContentSize().height+10
        end 
        if self.cellHeight2 <self.normalHeight-20 then
            self.cellHeight2 = self.normalHeight-20
        end
        descLabel:setAnchorPoint(ccp(0,0.5))
        descLabel:setPosition(ccp(0,self.cellHeight2/2))
        cell:addChild(descLabel,1)
        descLabel:setColor(G_ColorYellow)
    
        return cell

    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acArmamentsUpdateDialog2:dispose()
    self.cellHeight=nil
    self.cellHeight1=nil
    self.normalHeight=nil
    self.bgLayer=nil
    self.cellHeight2=nil
end


