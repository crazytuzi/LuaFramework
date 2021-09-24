--require "luascript/script/componet/commonDialog"
acOpenGiftDialog=commonDialog:new()

function acOpenGiftDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.normalHeight=220
    self.extendSpTag=113
    self.timeLbTab={}
    self.isCloseing=false
    self.buffTab={}

    return nc
end


--设置对话框里的tableView
function acOpenGiftDialog:initTableView()
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
        characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
    end
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(10,self.bgLayer:getContentSize().height - 430))
    self.bgLayer:addChild(characterSp,5)
    
    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg:setContentSize(CCSizeMake(410,200))
    girlDescBg:setAnchorPoint(ccp(0,0))
    girlDescBg:setPosition(ccp(180,self.bgLayer:getContentSize().height - 410))
    self.bgLayer:addChild(girlDescBg,4)
    
    local descLabel=GetTTFLabelWrap(getlocal("activity_openGift_des"),26,CCSizeMake(340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2+100,self.bgLayer:getContentSize().height-310))
    self.bgLayer:addChild(descLabel,5)
    
    local function touch()
        local td=smallDialog:new()
        local tabStr={" ",getlocal("activity_openGift_des4"),getlocal("activity_openGift_des3"),getlocal("activity_openGift_des2"),getlocal("activity_openGift_des1")," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem);
    menu:setPosition(ccp(580,self.bgLayer:getContentSize().height-140));
    menu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(menu,5);
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-105))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local acVo = acOpenGiftVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-140))
        self.bgLayer:addChild(timeLabel)
    end

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acOpenGiftDialog:eventHandler(handler,fn,idx,cel)
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
        if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="ru" or G_getCurChoseLanguage()=="pt" then
            txtSize = 20
        end
        local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
        headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, self.normalHeight-4))
        headerSprie:ignoreAnchorPointForPosition(false);
        headerSprie:setAnchorPoint(ccp(0,0));
        headerSprie:setTag(1000+idx)
        headerSprie:setIsSallow(false)
        headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
        cell:addChild(headerSprie)
        
        if idx==0 then
           local mIcon=CCSprite:createWithSpriteFrameName("item_buff_gold_up2.png")
           mIcon:setAnchorPoint(ccp(0,0.5));
           mIcon:setPosition(ccp(20,headerSprie:getContentSize().height/2))
           headerSprie:addChild(mIcon)
           
           local titleLb=GetTTFLabel(getlocal("openGift1"),25)
           titleLb:setAnchorPoint(ccp(0,0.5));
            titleLb:setPosition(ccp(20,mIcon:getPositionY()+mIcon:getContentSize().height/2+30))
            headerSprie:addChild(titleLb,5);
            titleLb:setColor(G_ColorGreen)
            
            local descLabel=GetTTFLabelWrap(getlocal("openGift_desc1",{acOpenGiftVoApi:getBaseGoldNum()}),txtSize,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLabel:setAnchorPoint(ccp(0,0.5));
            descLabel:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+20,headerSprie:getContentSize().height/2))
            headerSprie:addChild(descLabel,5)
            

            local timesLb=GetTTFLabel("(0/1)",25)
            timesLb:setAnchorPoint(ccp(0,0.5));
            timesLb:setPosition(ccp(headerSprie:getContentSize().width-120,110))
            headerSprie:addChild(timesLb,5)

            local buttonstr=getlocal("daily_scene_get")
            if acOpenGiftVoApi:isTodayReceive()==false then
                buttonstr=getlocal("activity_hadReward")
                timesLb:setString("(1/1)")
            end

            local function onClickSell()
                local function raidCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        local canGetGold = playerVoApi:getPlayerLevel()*acOpenGiftVoApi:getBaseGoldNum()
                        local gold=playerVoApi:getGold()+canGetGold
                        playerVoApi:setGold(gold) --设置金币
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_openGift_getGold",{canGetGold}),30)
                        acOpenGiftVoApi:setIsReceive()
                        self:update()
                    end
                end
                socketHelper:getOpenGift(raidCallback,2)
            end

            local confirmItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickSell,2,buttonstr,25)
            self.confirmBtn=CCMenu:createWithItem(confirmItem)
            self.confirmBtn:setPosition(ccp(headerSprie:getContentSize().width-confirmItem:getContentSize().width/2-10,50))
            self.confirmBtn:setTouchPriority(-(self.layerNum-1)*20-2)
            headerSprie:addChild(self.confirmBtn)
            
            if acOpenGiftVoApi:isTodayReceive()==false then
                confirmItem:setEnabled(false)
            end

        else

            local discountData = acOpenGiftVoApi:getAcCfg()
            if discountData == nil then
                return cell
            end

            local giftCfg = discountData[idx] -- 礼包的配置
            if giftCfg == nil then
                return cell
            end
            local giftInfo = propCfg[tostring(giftCfg.gift)] -- 礼包的具体信息
            if giftInfo == nil then
                return cell
            end
            
            local function showInfoHandler()
              if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                local item={name = getlocal(giftInfo.name), pic = giftInfo.icon, num = 1, desc = giftInfo.description}
                if item and item.name and item.pic and item.num and item.desc then
                  propInfoDialog:create(self.bgLayer,item,self.layerNum+1)
                end
              end
            end

            local mIcon=LuaCCSprite:createWithSpriteFrameName(giftInfo.icon,showInfoHandler)
            mIcon:setAnchorPoint(ccp(0,0.5));
            mIcon:setPosition(ccp(20,headerSprie:getContentSize().height/2))
            mIcon:setTouchPriority(-(self.layerNum-1)*20-4)
            headerSprie:addChild(mIcon)
           
            local titleLb=GetTTFLabel(getlocal(giftInfo.name),25)
            titleLb:setAnchorPoint(ccp(0,0.5));
            titleLb:setPosition(ccp(20,mIcon:getPositionY()+mIcon:getContentSize().height/2+30))
            headerSprie:addChild(titleLb,5);
            titleLb:setColor(G_ColorGreen)
            local timesStr="("..acOpenGiftVoApi:getBuyCountById(giftCfg.id).."/"..giftCfg.num..")"
            local timesLb=GetTTFLabel(timesStr,25)
            timesLb:setAnchorPoint(ccp(0,0.5));
            timesLb:setPosition(ccp(titleLb:getPositionX()+titleLb:getContentSize().width+10,titleLb:getPositionY()))
            headerSprie:addChild(timesLb,5)

            
            local descLabel=GetTTFLabelWrap(getlocal(giftInfo.description),txtSize,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLabel:setAnchorPoint(ccp(0,0.5));
            descLabel:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+20,headerSprie:getContentSize().height/2))
            headerSprie:addChild(descLabel,5)
            
            local oldGoldLb=GetTTFLabel(giftInfo.gemCost,30)
            oldGoldLb:setPosition(ccp(headerSprie:getContentSize().width-90,150))
            headerSprie:addChild(oldGoldLb,5)
            oldGoldLb:setColor(G_ColorRed)
            
            local line = CCSprite:createWithSpriteFrameName("redline.jpg")
            line:setScaleX((oldGoldLb:getContentSize().width  + 30) / line:getContentSize().width)
            --line:setAnchorPoint(ccp(0, 0))
            line:setPosition(getCenterPoint(oldGoldLb))
            oldGoldLb:addChild(line,2)

            local cellNum=math.ceil(giftInfo.gemCost*giftCfg.discount)
            local newGoldLb=GetTTFLabel(cellNum,30)
            newGoldLb:setPosition(ccp(headerSprie:getContentSize().width-90,110))
            headerSprie:addChild(newGoldLb,5)
            newGoldLb:setColor(G_ColorYellowPro)
            
            local goldIcon1=CCSprite:createWithSpriteFrameName("IconGold.png");
            goldIcon1:setPosition(ccp(oldGoldLb:getPositionX()+50,oldGoldLb:getPositionY()));
            headerSprie:addChild(goldIcon1)
            
            local goldIcon2=CCSprite:createWithSpriteFrameName("IconGold.png");
            goldIcon2:setPosition(ccp(newGoldLb:getPositionX()+50,newGoldLb:getPositionY()));
            headerSprie:addChild(goldIcon2)

            local function touch1(tag,object)
                if self.tv:getIsScrolled()==true then
                    return
                end

                -- 已经达到购买上限
                if acOpenGiftVoApi:getBuyCountById(giftCfg.id)==giftCfg.num then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_discount_maxNum"),30)
                    do
                        return
                    end
                end

                PlayEffect(audioCfg.mouseClick)
                local function touchBuy()
                    local function callbackBuyprop(fn,data)
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data)==true then
                            --统计购买物品
                            local cellNum=math.ceil(giftInfo.gemCost*giftCfg.discount)
                            statisticsHelper:buyItem(giftInfo.sid,cellNum,1,cellNum)
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("buyPropPrompt",{getlocal(giftInfo.name)}),28)
                            acOpenGiftVoApi:addBuyCountById(giftCfg.id)
                            self:update()
                        end

                    end
                    socketHelper:buyProc(giftInfo.sid,callbackBuyprop,1,"openGift")
                end
                local function buyGems()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    end
                        vipVoApi:showRechargeDialog(self.layerNum+1)

                end

                local cellNum=math.ceil(giftInfo.gemCost * giftCfg.discount) -- 购买一个需要花费的金币

                if playerVo.gems<tonumber(cellNum) then
                    local num=tonumber(cellNum)-playerVo.gems
                    local smallD=smallDialog:new()
                         smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(cellNum),playerVo.gems,num}),nil,self.layerNum+1)
                else
                    local smallD=smallDialog:new()
                         smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("prop_buy_tip",{cellNum,getlocal(giftInfo.name)}),nil,self.layerNum+1)
                end
            end
            
            local confirmItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touch1,id,getlocal("buy"),25)
            local confirmBtn=CCMenu:createWithItem(confirmItem);
            confirmBtn:setPosition(ccp(headerSprie:getContentSize().width-confirmItem:getContentSize().width/2-10,50))
            confirmBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            headerSprie:addChild(confirmBtn)
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

function acOpenGiftDialog:tick()

end

function acOpenGiftDialog:update()
    local acVo = acOpenGiftVoApi:getAcVo()
    if acVo ~= nil then
        if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self ~= nil then
            self:close()
        end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
  end


end

function acOpenGiftDialog:dispose()
    self.normalHeight=nil
    self.extendSpTag=nil
    self.timeLbTab=nil
    self.isCloseing=nil
    self.buffTab=nil
    self=nil
end
