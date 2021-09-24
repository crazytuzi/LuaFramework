--require "luascript/script/componet/commonDialog"
acLuckUpDialog=commonDialog:new()

function acLuckUpDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.normalHeight=220
    if G_getIphoneType() == G_iphoneX then
        self.normalHeight = self.normalHeight + 45
    end

    return nc
end


--设置对话框里的tableView
function acLuckUpDialog:initTableView()
    self.panelLineBg:setVisible(false)
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-460),nil)

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,20))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)


    local characterSp
    if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
        characterSp = CCSprite:create("public/guide.png")
    else
        characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter_new.png") --姑娘
    end
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(10,self.bgLayer:getContentSize().height - 430))
    self.bgLayer:addChild(characterSp,5)

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite:setPosition(ccp((G_VisibleSizeWidth)/2,self.bgLayer:getContentSize().height - 428))
    self.bgLayer:addChild(lineSprite,6)
    
    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg:setContentSize(CCSizeMake(410,200))
    girlDescBg:setAnchorPoint(ccp(0,0))
    girlDescBg:setPosition(ccp(180,self.bgLayer:getContentSize().height - 410))
    self.bgLayer:addChild(girlDescBg,4)
    
    local descLabel=GetTTFLabelWrap(getlocal("activity_luckUp_content"),26,CCSizeMake(340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2+100,self.bgLayer:getContentSize().height-310))
    self.bgLayer:addChild(descLabel,5)
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-105))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local acVo = acLuckUpVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-140))
        self.bgLayer:addChild(timeLabel)
        self.timeLb=timeLabel
        self:updateAcTime()
    end

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acLuckUpDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 3

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.normalHeight)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()
        cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, self.normalHeight))
        
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        
        end
        local txtSize = 25
        local interval = 4
        if G_getIphoneType() == G_iphoneX then
            interval = 45
        end
        local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
        headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, self.normalHeight - interval))
        headerSprie:ignoreAnchorPointForPosition(false);
        headerSprie:setAnchorPoint(ccp(0,0));
        headerSprie:setTag(1000+idx)
        headerSprie:setIsSallow(false)
        headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
        cell:addChild(headerSprie)

        local pic = nil
        local title = "activity_luckUp_sub"..(idx + 1)
        local des = nil
        if idx == 0 then
            pic = "item_shuji_04.png"
            des = getlocal("activity_luckUp_des1",{acLuckUpVoApi:getAddTroops()})
        elseif idx == 1 then
            pic = "player_exp.png"
            des = getlocal("activity_luckUp_des2",{acLuckUpVoApi:getAddExp()})
        else
            pic = "tech_fight_exp_up.png"
            des = getlocal("activity_luckUp_des3",{acLuckUpVoApi:getAddDrop()})
        end
        local mIcon=CCSprite:createWithSpriteFrameName(pic)
        mIcon:setAnchorPoint(ccp(0,0.5))
        mIcon:setPosition(ccp(20,headerSprie:getContentSize().height/2))
        headerSprie:addChild(mIcon)

        local titleLb=GetTTFLabel(getlocal(title),25)
        titleLb:setAnchorPoint(ccp(0,0.5))
        titleLb:setPosition(ccp(20,mIcon:getPositionY()+mIcon:getContentSize().height/2+30))
        headerSprie:addChild(titleLb,5)
        titleLb:setColor(G_ColorGreen)

        local descLabel=GetTTFLabelWrap(des,txtSize,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLabel:setAnchorPoint(ccp(0,0.5))
        descLabel:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+20,headerSprie:getContentSize().height/2-20))
        headerSprie:addChild(descLabel,5)
        
        local buttonstr=getlocal("activity_heartOfIron_goto")

        local function onClick(tag,object)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
            -- 跳转到相应的功能模块
                if tag == 1 then
                    activityAndNoteDialog:gotoByTag(3)
                elseif tag == 2 then
                    activityAndNoteDialog:closeAllDialog()
                    storyScene:setShow()
                else
                    activityAndNoteDialog:closeAllDialog()
                    mainUI:changeToWorld()
                end
            end
        end
        local confirmItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onClick,idx + 1,buttonstr,25)
        confirmItem:setScale(0.8)
        self.confirmBtn=CCMenu:createWithItem(confirmItem)
        self.confirmBtn:setPosition(ccp(headerSprie:getContentSize().width-confirmItem:getContentSize().width/2+10,headerSprie:getContentSize().height/2))
        if G_getIphoneType() == G_iphoneX then
            self.confirmBtn:setPosition(ccp(headerSprie:getContentSize().width-confirmItem:getContentSize().width/2+15,headerSprie:getContentSize().height/2))
        end
        self.confirmBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:addChild(self.confirmBtn)

        return cell

   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acLuckUpDialog:tick()
    self:updateAcTime()
end

function acLuckUpDialog:updateAcTime()
    local acVo=acLuckUpVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acLuckUpDialog:update()
    local acVo = acLuckUpVoApi:getAcVo()
    if acVo ~= nil then
        if activityVoApi:isStart(acVo) == false and self ~= nil then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            self:close()
        end
    end
end

function acLuckUpDialog:dispose()
    self.normalHeight=nil
    self=nil
end
