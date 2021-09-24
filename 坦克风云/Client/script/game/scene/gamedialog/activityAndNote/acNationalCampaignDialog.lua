acNationalCampaignDialog=commonDialog:new()

function acNationalCampaignDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.normalHeight=200

    return nc
end


--设置对话框里的tableView
function acNationalCampaignDialog:initTableView()
    self.panelLineBg:setVisible(false)

    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-105))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local acVo = acNationalCampaignVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-140))
        self.bgLayer:addChild(timeLabel)
    end

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((G_VisibleSizeWidth)/lineSprite:getContentSize().width)
    lineSprite:setPosition(ccp((G_VisibleSizeWidth)/2,self.bgLayer:getContentSize().height - 168))
    self.bgLayer:addChild(lineSprite,6)
    
    local Desc1Bg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    Desc1Bg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,200))
    Desc1Bg:setAnchorPoint(ccp(0,1))
    Desc1Bg:setPosition(ccp(20,self.bgLayer:getContentSize().height - 180))
    self.bgLayer:addChild(Desc1Bg,4)

    local title1Desc = GetTTFLabelWrap(getlocal("activity_nationalCampaign_repairTitle"),30,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    title1Desc:setAnchorPoint(ccp(0,1))
    title1Desc:setPosition(ccp(10,Desc1Bg:getContentSize().height-10))
    Desc1Bg:addChild(title1Desc)
    title1Desc:setColor(G_ColorGreen)


    local icon1 = CCSprite:createWithSpriteFrameName("Icon_BG.png")
    icon1:setAnchorPoint(ccp(0,0.5))
    icon1:setPosition(ccp(10,Desc1Bg:getContentSize().height/2-20))
    icon1:setScale(100/78)
    Desc1Bg:addChild(icon1)
    

     local mIcon1=CCSprite:createWithSpriteFrameName("mainBtnAccessory.png")
     mIcon1:setScale(78/100)
     mIcon1:setPosition(ccp(icon1:getContentSize().width/2,icon1:getContentSize().height/2))
     icon1:addChild(mIcon1,2)

    local desc1Tv=G_LabelTableView(CCSize(Desc1Bg:getContentSize().width-140,140),getlocal("activity_nationalCampaign_repairDesc",{acNationalCampaignVoApi:getDestoryRate(),acNationalCampaignVoApi:getDestoryDownRate()}),25,kCCTextAlignmentLeft)
    desc1Tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    desc1Tv:setPosition(ccp(120,10))
    Desc1Bg:addChild(desc1Tv,2)
    desc1Tv:setMaxDisToBottomOrTop(50)

    local Desc2Bg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    Desc2Bg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,200))
    Desc2Bg:setAnchorPoint(ccp(0,1))
    Desc2Bg:setPosition(ccp(20,self.bgLayer:getContentSize().height - 390))
    self.bgLayer:addChild(Desc2Bg,4)

    local icon2 = CCSprite:createWithSpriteFrameName("player_exp.png")
    icon2:setAnchorPoint(ccp(0,0.5))
    icon2:setPosition(ccp(10,Desc2Bg:getContentSize().height/2-20))
    Desc2Bg:addChild(icon2)

    local title2Desc = GetTTFLabelWrap(getlocal("activity_nationalCampaign_addupTitle"),30,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    title2Desc:setAnchorPoint(ccp(0,1))
    title2Desc:setPosition(ccp(10,Desc2Bg:getContentSize().height-10))
    Desc2Bg:addChild(title2Desc)
    title2Desc:setColor(G_ColorGreen)

    local desc2Tv=G_LabelTableView(CCSize(Desc2Bg:getContentSize().width-140,140),getlocal("activity_nationalCampaign_addupDesc",{acNationalCampaignVoApi:getExpAddRate()}),25,kCCTextAlignmentLeft)
    desc2Tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    desc2Tv:setPosition(ccp(120,10))
    Desc2Bg:addChild(desc2Tv,2)
    desc2Tv:setMaxDisToBottomOrTop(50)

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height - 620))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(20,20))
    self.bgLayer:addChild(tvBg,2)

    local title3Desc = GetTTFLabelWrap(getlocal("activity_nationalCampaign_LimiteTitle"),30,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    title3Desc:setAnchorPoint(ccp(0,1))
    title3Desc:setPosition(ccp(10,tvBg:getContentSize().height-10))
    tvBg:addChild(title3Desc)
    title3Desc:setColor(G_ColorGreen)

    local cdLb = GetTTFLabel(getlocal("activity_nationalCampaign_CDTime"),27)
    cdLb:setAnchorPoint(ccp(0,1))
    cdLb:setPosition(ccp(20,tvBg:getContentSize().height-50))
    tvBg:addChild(cdLb)
    cdLb:setColor(G_ColorYellow)

    self.timeCDLb = GetTTFLabel(getlocal(""),27)
    self.timeCDLb:setAnchorPoint(ccp(0,1))
    self.timeCDLb:setPosition(ccp(30+cdLb:getContentSize().width,tvBg:getContentSize().height-50))
    tvBg:addChild(self.timeCDLb)
    self.timeCDLb:setColor(G_ColorYellow)


    local function inforTouch()
        local td=smallDialog:new()
        local tabStr={" ",getlocal("activity_nationalCampaign_Tip2"),getlocal("activity_nationalCampaign_Tip1")," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",inforTouch,11,nil,nil)
    --menuItem:setScale(0.8)
    local menu = CCMenu:createWithItem(menuItem);
    menu:setPosition(ccp(tvBg:getContentSize().width-50,tvBg:getContentSize().height-50));
    menu:setTouchPriority(-(self.layerNum-1)*20-4);
    tvBg:addChild(menu,5);

    local function socketCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData.data then
                acNationalCampaignVoApi:setbuyIDCfg(sData.data)
            end
            if sData.index then
                acNationalCampaignVoApi:setUpdateIndex(sData.index)
            end
            if sData.refreshTime then
                acNationalCampaignVoApi:setUpdateTime(sData.refreshTime)
            end
            acNationalCampaignVoApi:updateHadBuyNum()
            self:addTv(tvBg)
            self:updateCDTime()
        end
    end

    if acNationalCampaignVoApi:getUpdateTime()==nil or acNationalCampaignVoApi:getUpdateTime()<=base.serverTime then
        socketHelper:activityNationalCampaignProp(socketCallback)
    else
        self:addTv(tvBg)
        self:updateCDTime()
    end
end
function  acNationalCampaignDialog:updateCDTime()
    local time = acNationalCampaignVoApi:getUpdateTime()-base.serverTime
    local timestr = G_getTimeStr(time)
    self.timeCDLb=tolua.cast(self.timeCDLb,"CCLabelTTF")
    self.timeCDLb:setString(timestr)
end
function acNationalCampaignDialog:addTv(bg)
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,bg:getContentSize().height-100),nil)

    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setPosition(ccp(10,5))
    bg:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end


--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acNationalCampaignDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 2

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,self.normalHeight)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()
        cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
        
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        
        end
        local txtSize = 25

        local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
        headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight-4))
        headerSprie:ignoreAnchorPointForPosition(false);
        headerSprie:setAnchorPoint(ccp(0,0));
        headerSprie:setTag(1000+idx)
        headerSprie:setIsSallow(false)
        headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
        cell:addChild(headerSprie)

        local buyidCfg = acNationalCampaignVoApi:getbuyIDCfg()

        local giftCfg = acNationalCampaignVoApi:getGiftCfgByID(buyidCfg[idx+1])

        local giftInfo = propCfg[tostring(giftCfg.gift)] -- 礼包的具体信息

        local hadBuyNum = acNationalCampaignVoApi:getBuyCountById(giftCfg.gift)

        if giftInfo == nil then
            return cell
        end
        local propNameLb = GetTTFLabelWrap(getlocal(giftInfo.name),27,CCSizeMake(headerSprie:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        propNameLb:setAnchorPoint(ccp(0,0.5))
        propNameLb:setPosition(ccp(20,headerSprie:getContentSize().height-30))
        headerSprie:addChild(propNameLb,1)
        propNameLb:setColor(G_ColorGreen)

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
        mIcon:setPosition(ccp(20,headerSprie:getContentSize().height/2-10))
        mIcon:setTouchPriority(-(self.layerNum-1)*20-4)
        headerSprie:addChild(mIcon)


        local posX = mIcon:getContentSize().width+30
        local oldGoldLb=GetTTFLabel(giftInfo.gemCost,30)
        oldGoldLb:setPosition(ccp(posX,headerSprie:getContentSize().height-70))
        oldGoldLb:setAnchorPoint(ccp(0, 0.5))
        headerSprie:addChild(oldGoldLb,5)
        oldGoldLb:setColor(G_ColorRed)
        
        local line = CCSprite:createWithSpriteFrameName("redline.jpg")
        line:setScaleX((oldGoldLb:getContentSize().width  + 30) / line:getContentSize().width)
        --line:setAnchorPoint(ccp(0, 0))
        line:setPosition(getCenterPoint(oldGoldLb))
        oldGoldLb:addChild(line,2)

        local cellNum=math.ceil(giftInfo.gemCost*giftCfg.discount)
        local newGoldLb=GetTTFLabel(cellNum,30)
        newGoldLb:setPosition(ccp(posX,headerSprie:getContentSize().height/2-10))
        newGoldLb:setAnchorPoint(ccp(0, 0.5))
        headerSprie:addChild(newGoldLb,5)
        newGoldLb:setColor(G_ColorYellowPro)
        
        local goldIcon1=CCSprite:createWithSpriteFrameName("IconGold.png");
        goldIcon1:setPosition(ccp(oldGoldLb:getPositionX()+oldGoldLb:getContentSize().width+30,oldGoldLb:getPositionY()));
        headerSprie:addChild(goldIcon1)
        
        local goldIcon2=CCSprite:createWithSpriteFrameName("IconGold.png");
        goldIcon2:setPosition(ccp(newGoldLb:getPositionX()+newGoldLb:getContentSize().width+30,newGoldLb:getPositionY()));
        headerSprie:addChild(goldIcon2)


        --数量限制
        local numLb = GetTTFLabelWrap(getlocal("activity_nationalCampaign_LimiteNum",{hadBuyNum,giftCfg.num}), 25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        numLb:setAnchorPoint(ccp(0,1))
        numLb:setPosition(ccp(posX,60))
        headerSprie:addChild(numLb)
        
        local buttonstr=getlocal("buy")

        local function onClick(tag,object)
            if self.tv:getIsScrolled()==true then
                return
            end

            if hadBuyNum and hadBuyNum>=giftCfg.num then
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
                        acNationalCampaignVoApi:addBuyCountById(giftCfg.gift)
                        self.tv:reloadData()
                    end

                end
                socketHelper:buyProc(giftInfo.sid,callbackBuyprop,1,"nationalCampaign")
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


        local confirmItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onClick,idx + 1,buttonstr,25)
        self.confirmBtn=CCMenu:createWithItem(confirmItem)
        self.confirmBtn:setPosition(ccp(headerSprie:getContentSize().width-confirmItem:getContentSize().width/2-10,headerSprie:getContentSize().height/2-10))
        self.confirmBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:addChild(self.confirmBtn)

        if hadBuyNum and hadBuyNum>=tonumber(giftCfg.num) then
            confirmItem:setEnabled(false)
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

function acNationalCampaignDialog:tick()
    if acNationalCampaignVoApi:getUpdateTime()==nil or acNationalCampaignVoApi:getUpdateTime()<=base.serverTime and self.tv then
          local function socketCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
               if sData.data then
                    acNationalCampaignVoApi:setbuyIDCfg(sData.data)
                end
                if sData.index then
                    acNationalCampaignVoApi:setUpdateIndex(sData.index)
                end
                if sData.refreshTime then
                    acNationalCampaignVoApi:setUpdateTime(sData.refreshTime)
                end
                acNationalCampaignVoApi:updateHadBuyNum()
                self.tv:reloadData()
                self:updateCDTime()
            end
        end
         socketHelper:activityNationalCampaignProp(socketCallback)
     end
     if acNationalCampaignVoApi:getUpdateTime()~=nil and acNationalCampaignVoApi:getUpdateTime()>base.serverTime then
        self:updateCDTime()
    end
end

function acNationalCampaignDialog:update()
    local acVo = acNationalCampaignVoApi:getAcVo()
    if acVo ~= nil then
        if activityVoApi:isStart(acVo) == false and self ~= nil then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
            self:close()
        end
    end
end

function acNationalCampaignDialog:dispose()
    self.normalHeight=nil
    self=nil
end

