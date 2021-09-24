acGrabRedDialog=commonDialog:new()

function acGrabRedDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum
    self.bgLayer1=nil
    self.bgLayer2=nil
    self.bgLayer3=nil
    self.selectedTabIndex=0
    self.lbTab={}
    self.cellHeight=nil
    self.isToday=true

    self.pointLb = nil
    self.priceLb = nil
    self.priceGoldIcon = nil
    self.priceLbX = nil
    self.redid = 0 -- 测试使用
    return nc
end

function acGrabRedDialog:initTableView()
    -- self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSize.height-105))
    -- self.panelLineBg:setAnchorPoint(ccp(0,0))
    -- self.panelLineBg:setPosition(ccp(15,15))
    self.panelLineBg:setVisible(false)


    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg:setContentSize(CCSizeMake(410,200))
    girlDescBg:setAnchorPoint(ccp(0,0))
    girlDescBg:setPosition(ccp(180,G_VisibleSizeHeight/2+70))
    self.bgLayer:addChild(girlDescBg,1)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(410,200-20),nil)
    girlDescBg:addChild(self.tv)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(0,10))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setMaxDisToBottomOrTop(60)
    
    self:initBox()
    self:initBg()
end

function acGrabRedDialog:initBg()
    -- local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),25)
    local timeTime=GetTTFLabelWrap(getlocal("activity_timeLabel"),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    timeTime:setAnchorPoint(ccp(0.5,0.5))
    timeTime:setColor(G_ColorYellowPro)
    timeTime:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-115))
    self.bgLayer:addChild(timeTime)

    -- local timeLb=GetTTFLabel(acGrabRedVoApi:getTimeStr(),25)
    local timeLb=GetTTFLabelWrap(acGrabRedVoApi:getTimeStr(),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    timeLb:setAnchorPoint(ccp(0.5,0.5))
    timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
    self.bgLayer:addChild(timeLb)
    local acVo = acGrabRedVoApi:getAcVo()
    self.timeLb=timeLb
    G_updateActiveTime(acVo,self.timeLb)
    
    local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
    girlImg:setScale((G_VisibleSizeHeight/2-85)/girlImg:getContentSize().height*0.6)
    girlImg:setAnchorPoint(ccp(0,0))
    girlImg:setPosition(ccp(20,G_VisibleSizeHeight/2+50))
    self.bgLayer:addChild(girlImg,2)

    local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSP:setAnchorPoint(ccp(0.5,0.5))
    lineSP:setScaleX((self.bgLayer:getContentSize().width - 50)/lineSP:getContentSize().width)
    lineSP:setScaleY(1.2)
    lineSP:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight/2+50))
    self.bgLayer:addChild(lineSP,3)

    local function showInfo()
        local tabStr={" ",getlocal("activity_GrabRed_desc_5"),getlocal("activity_GrabRed_desc_4",{acGrabRedVoApi:getInitPoint()}),getlocal("activity_GrabRed_desc_3",{acGrabRedVoApi:getPointUseDiscount() * 100}),getlocal("activity_GrabRed_desc_2"),getlocal("activity_GrabRed_desc_1")," "}
        local tabColor ={}
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,G_VisibleSizeHeight-140));
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn)
end


function acGrabRedDialog:initBox()
    local strSize2 = 23
    if G_getCurChoseLanguage() =="ru" then
        strSize2 =20
    end
    local desc=getlocal("activity_grabRed_propDesc")

    local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
    background:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight - 105))
    background:setAnchorPoint(ccp(0.5,0))
    background:setPosition(ccp(G_VisibleSizeWidth/2,15))
    self.bgLayer:addChild(background)

    local bgSize=background:getContentSize()
    
    local chestIconY = 400
    local chestIcon=CCSprite:createWithSpriteFrameName("SeniorBox.png")
    local chestIconX = bgSize.width - 30
    chestIcon:setAnchorPoint(ccp(1,0))
    chestIcon:setPosition(chestIconX, chestIconY)
    background:addChild(chestIcon)

    local addX = 40
    local descY = chestIconY

    local chestDesc=GetTTFLabelWrap(desc,strSize2,CCSizeMake(350, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    chestDesc:setAnchorPoint(ccp(0,1))
    chestDesc:setPosition(ccp(addX,descY+80))
    background:addChild(chestDesc)
    
    local propId = acGrabRedVoApi:getPropId()
    local packageCfg = propCfg[propId]
    if packageCfg ~= nil then
        local chestTitle = GetTTFLabel(getlocal(packageCfg.name), 25)
        chestTitle:setAnchorPoint(ccp(0,1))
        chestTitle:setPosition(ccp(addX, descY+115))
        chestTitle:setColor(G_ColorGreen)
        background:addChild(chestTitle)
    end
    
    local awardBgW = bgSize.width-40
    local awardBgH = 140
    local awardBgY = 210
    local awardBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationAwardsBox.png",CCRect(40, 40, 1, 1),function () end)
    awardBg:setContentSize(CCSizeMake(awardBgW,awardBgH))
    awardBg:setAnchorPoint(ccp(0.5,0))
    awardBg:setPosition(ccp(bgSize.width/2,awardBgY))
    background:addChild(awardBg)

    local infoCenter = awardBg:getContentSize().height/2
    local reward = acGrabRedVoApi:getRewardsInPackage()
    local rewardCfg=FormatItem(reward,true,true)
    if rewardCfg ~= nil then
        local oneLen = 120
        local firstX = (awardBg:getContentSize().width - oneLen * SizeOfTable(rewardCfg))/2
        for k,v in pairs(rewardCfg) do
            local icon, iconScale = G_getItemIcon(v, 100, true, self.layerNum)
            iconX = (k-1) * oneLen + oneLen/2 + firstX
            icon:ignoreAnchorPointForPosition(false)
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(iconX,infoCenter))
            icon:setIsSallow(false)
            icon:setTouchPriority(-(self.layerNum-1)*20-4)
            awardBg:addChild(icon,1)
            icon:setTag(k)

            if tostring(v.name)~=getlocal("honor") then
                local numLabel=GetTTFLabel("x"..v.num,25)
                numLabel:setAnchorPoint(ccp(1,0))
                numLabel:setPosition(icon:getContentSize().width-10,0)
                icon:addChild(numLabel,1)
                numLabel:setScaleX(1/iconScale)
                numLabel:setScaleY(1/iconScale)
            end
        end
    end

    
    -- 原价
    local priceX = 10
    local listPriceY = 150
    local jiange = 5 -- 文字和数量和金币图标之间的间隔

    local listPriceTitleLb = GetTTFLabel(getlocal("activity_grabRed_listPrice"), 25)
    listPriceTitleLb:setAnchorPoint(ccp(0,0.5))
    listPriceTitleLb:setPosition(ccp(priceX,listPriceY))
    background:addChild(listPriceTitleLb)
    
    local  listPriceLbX = priceX + listPriceTitleLb:getContentSize().width + jiange
    local listPriceLb=GetTTFLabel(acGrabRedVoApi:getPackageCost(),28)
    listPriceLb:setAnchorPoint(ccp(0,0.5))
    listPriceLb:setPosition(ccp(listPriceLbX,listPriceY))
    background:addChild(listPriceLb)
    listPriceLb:setColor(G_ColorRed)
    
    local listPriceGoldIconX = listPriceLbX  + listPriceLb:getContentSize().width + jiange
    local listPriceGoldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
    listPriceGoldIcon:setAnchorPoint(ccp(0,0.5))
    listPriceGoldIcon:setPosition(listPriceGoldIconX,listPriceY)
    background:addChild(listPriceGoldIcon)

    local line = CCSprite:createWithSpriteFrameName("redline.jpg")
    line:setScaleX((listPriceLb:getContentSize().width+20)/line:getContentSize().width)
    line:setAnchorPoint(ccp(0,0.5))
    line:setPosition(ccp(listPriceLbX-10,listPriceY))
    background:addChild(line)
    
    -- 代币
    listPriceY = 100

    local pointTitleLb = GetTTFLabel(getlocal("activity_grabRed_point"), 25)
    pointTitleLb:setAnchorPoint(ccp(0,0.5))
    pointTitleLb:setPosition(ccp(priceX,listPriceY))
    background:addChild(pointTitleLb)
    
    local  pointLbX = priceX + pointTitleLb:getContentSize().width + jiange
    local pointLb=GetTTFLabel(acGrabRedVoApi:getCurrentPoint(),28)
    pointLb:setAnchorPoint(ccp(0,0.5))
    pointLb:setPosition(ccp(pointLbX,listPriceY))
    background:addChild(pointLb)
    pointLb:setColor(G_ColorYellowPro)
    self.pointLb = pointLb


    -- 现价
    listPriceY = 50

    local priceTitleLb = GetTTFLabel(getlocal("activity_grabRed_price"), 25)
    priceTitleLb:setAnchorPoint(ccp(0,0.5))
    priceTitleLb:setPosition(ccp(priceX,listPriceY))
    background:addChild(priceTitleLb)
    
    local  priceLbX = priceX + priceTitleLb:getContentSize().width + jiange
    local priceLb=GetTTFLabel(acGrabRedVoApi:getNowCost(),28)
    priceLb:setAnchorPoint(ccp(0,0.5))
    priceLb:setPosition(ccp(priceLbX,listPriceY))
    background:addChild(priceLb)
    priceLb:setColor(G_ColorYellowPro)
    self.priceLb = priceLb
    
    priceGoldIconX = priceLbX  + priceLb:getContentSize().width + jiange
    local priceGoldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
    priceGoldIcon:setAnchorPoint(ccp(0,0.5))
    priceGoldIcon:setPosition(priceGoldIconX,listPriceY)
    background:addChild(priceGoldIcon)
    self.priceGoldIcon = priceGoldIcon
    self.priceLbX = priceLbX
    

    local function onBuy(tag,object)
        local function touchBuy()
            local function buyCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    self.redid = sData.data.redid
                    local reward = FormatItem(acGrabRedVoApi:getAcRewardCfg(), true)
                    for k,v in pairs(reward) do
                        G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
                        local message={key="activity_grabRed_message",param={playerVoApi:getPlayerName(),v.name}}
                        chatVoApi:sendSystemMessage(message, {redid = sData.data.redid})
                    end
                    G_showRewardTip(reward,true)
                    acGrabRedVoApi:afterBuyPackage()
                    self:update()
                    
                end
            end
            socketHelper:buyGrabRedBox(buyCallback)
        end
        
        local costGems=tonumber(acGrabRedVoApi:getPackageCost())
        local hadPoints = tonumber(acGrabRedVoApi:getCurrentPoint())
        local costPoints = 0
        if hadPoints > 0 then
            local pointDiscount = costGems * acGrabRedVoApi:getPointUseDiscount()
            if hadPoints > pointDiscount then
                costPoints = pointDiscount
            else
                costPoints = hadPoints
            end
            costGems = costGems - costPoints
        end

        if playerVoApi:getGems()<costGems then
            GemsNotEnoughDialog(nil,nil,costGems-playerVoApi:getGems(),self.layerNum+1,costGems)
            do return end
        else
            local smallD=smallDialog:new()
            local propId = acGrabRedVoApi:getPropId()
            if propId ~= nil then
                local packageCfg = propCfg[propId]
                if packageCfg ~= nil then
                    smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("activity_grabRed_buyTip",{costGems,costPoints,getlocal(packageCfg.name)}),nil,self.layerNum+1)
                end           
            end
        end

        
    end

    local buyItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onBuy,nil,getlocal("buy"),25)

    buyItem:setAnchorPoint(ccp(0.5,0.5))
    local buyBtn=CCMenu:createWithItem(buyItem)
    buyBtn:setAnchorPoint(ccp(0.5,0.5))
    buyBtn:setPosition(ccp(bgSize.width-buyItem:getContentSize().width/2-20,100))
    buyBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    background:addChild(buyBtn)

    return self.bgLayer
end

function acGrabRedDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.cellHeight==nil then
            local spScale=((G_VisibleSizeHeight/2-85)/262*0.6)
            local descLb=GetTTFLabelWrap(getlocal("activity_grabRed_desc"),22,CCSizeMake(260*1/spScale,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            self.cellHeight=descLb:getContentSize().height
        end
        if self.cellHeight<200-20 then
            self.cellHeight=200-20
        end
        tmpSize=CCSizeMake(410,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local spScale=((G_VisibleSizeHeight/2-85)/262*0.6)
        local descLb=GetTTFLabelWrap(getlocal("activity_grabRed_desc"),22,CCSizeMake(260*1/spScale,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if self.cellHeight==nil then
            self.cellHeight=descLb:getContentSize().height
        end
        if self.cellHeight<200-20 then
            self.cellHeight=200-20
        end
        descLb:setPosition(ccp(100*spScale+140,self.cellHeight/2))
        cell:addChild(descLb)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acGrabRedDialog:updateMoneyLabel()
    if self.pointLb ~= nil then
        self.pointLb:setString(acGrabRedVoApi:getCurrentPoint())
    end

    if self.priceLb ~= nil then
        self.priceLb:setString(acGrabRedVoApi:getNowCost())
        if self.priceGoldIcon ~= nil and self.priceLbX ~= nil then
            self.priceGoldIcon:setPosition(ccp(self.priceLbX  + self.priceLb:getContentSize().width + 5, 50))
        end
    end
end

function acGrabRedDialog:update()
    local acVo = acGrabRedVoApi:getAcVo()
    if acVo ~= nil then
        if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
          if self ~= nil then
            self:close()
          end
        elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
          self:updateMoneyLabel()
        end
    end
end

function acGrabRedDialog:tick()
    if self.timeLb then
        local acVo = acGrabRedVoApi:getAcVo()
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acGrabRedDialog:dispose()
    self.pointLb = nil
    self.priceLb = nil
    self.priceGoldIcon = nil
    self.priceLbX = nil

    self = nil
end