
acFirstRechargenewDialog=activityDialog:new()

function acFirstRechargenewDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.des = nil
    self.desH = nil
    self.flag = nil  -- 状态判断
    -- self.rewardMenu = nil
    self.rewardRow = nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
    return nc
end

function acFirstRechargenewDialog:initVo(acVo)
    self.acVo = acVo
end

function acFirstRechargenewDialog:initTableView()
    self:doSomething()
    self:setTv(G_VisibleSizeWidth/2,G_VisibleSizeHeight-180)
end

function acFirstRechargenewDialog:doSomething( ... )
    local acVo=acFirstRechargenewVoApi:getAcVo()
    -- self.desH,self.des = self:getDes(getlocal("activity_"..acVo.type.."_des"))

    if self == nil then
        return
    end

    local hotSp=CCSprite:createWithSpriteFrameName("hotItem.png")
    hotSp:setAnchorPoint(ccp(1,1))
    hotSp:setPosition(ccp(self.panelLineBg:getContentSize().width+25,self.panelLineBg:getContentSize().height+5))
    self.panelLineBg:addChild(hotSp,2)

    -- if self.rewardMenu ~= nil then
    --   self.bgLayer:removeChild(self.rewardMenu,true)
    --   self.rewardMenu = nil
    -- end
    -- local function hadReward(tag,object)
    -- end

    -- local function getReward(tag,object)
    --   self:getFirstRechargeReward()
    -- end
    
    local function gotoCharge(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        vipVoApi:showRechargeDialog(self.layerNum+1)
    end

  -- self.flag = tonumber(self.acVo.c)
    local rewardBtn
  -- if self.flag >= tonumber(self.acVo.v) then
  --     rewardBtn =GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",getReward,nil,getlocal("newGiftsReward"),28)
  -- else
  --   if self.flag < 0 then
  --     rewardBtn =GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",hadReward,nil,getlocal("activity_hadReward"),28)
  --     rewardBtn:setEnabled(false)
  --   else
    rewardBtn =GetButtonItem("BtnRecharge.png","BtnRecharge.png","BtnRecharge.png",gotoCharge,nil,getlocal("recharge"),28);
  --   end
  -- end

    local rewardMenu=CCMenu:createWithItem(rewardBtn)
    rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,55))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.bgLayer:addChild(rewardMenu)  

    -- local giftData=FormatItem(acVo.reward,true)
    -- self.rewardRow =   math.ceil(SizeOfTable(giftData)/4)
end

function acFirstRechargenewDialog:setTv(bgPosx, bgHeight)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    -- self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, bgHeight - 110))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, bgHeight))
    self.panelLineBg:setPosition(ccp(bgPosx, 100))

    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 40,bgHeight - 20),nil)
    self.bgLayer:addChild(self.tv)
    self.tv:setPosition(ccp(20,110))
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acFirstRechargenewDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
    -- if idx == 1 then
    --   tmpSize=CCSizeMake(G_VisibleSizeWidth - 40,self.desH)
    -- else
    --   tmpSize=CCSizeMake(G_VisibleSizeWidth - 40,220 * self.rewardRow + 10)
    -- end
        tmpSize=CCSizeMake(G_VisibleSizeWidth - 40,self.bgLayer:getContentSize().height-200)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local posx=(G_VisibleSizeWidth - 40)/2
        local posy=self.bgLayer:getContentSize().height-230
        local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
        titleBg:setPosition(ccp(posx+20,posy))
        titleBg:setScaleY(60/titleBg:getContentSize().height)
        titleBg:setScaleX(600/titleBg:getContentSize().width)
        cell:addChild(titleBg)
        local titleLb=GetTTFLabel(getlocal("activity_firstRechargenew_title"),30)
        titleLb:setPosition(ccp(posx,posy))
        cell:addChild(titleLb,1)
        titleLb:setColor(G_ColorYellowPro)

        posy=posy-80
        local descLb1=GetTTFLabelWrap(getlocal("activity_firstRechargenew_desc1"),30,CCSizeMake(280, 0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        -- descLb1=GetTTFLabelWrap(str,30,CCSizeMake(280, 0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        descLb1:setAnchorPoint(ccp(1,0.5))
        descLb1:setPosition(ccp(posx-90,posy))
        cell:addChild(descLb1,1)
        descLb1:setColor(G_ColorYellowPro)
        local descLb2=GetTTFLabelWrap(getlocal("activity_firstRechargenew_desc2"),30,CCSizeMake(280, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        -- descLb2=GetTTFLabelWrap(str,30,CCSizeMake(280, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLb2:setAnchorPoint(ccp(0,0.5))
        descLb2:setPosition(ccp(posx+90,posy))
        cell:addChild(descLb2,1)
        descLb2:setColor(G_ColorYellowPro)
        local acVo=acFirstRechargenewVoApi:getAcVo()
        local numLb=GetBMLabel(acVo.pvalue or 0,G_GoldFontSrc,20)
        numLb:setPosition(ccp(posx-10,posy-5))
        cell:addChild(numLb,1)
        local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        goldSp:setPosition(ccp(posx+75,posy))
        cell:addChild(goldSp,1)

        posy=posy-50
        local rewardBg = self:initFirstRecharge()
        rewardBg:setAnchorPoint(ccp(0.5,1))
        rewardBg:setPosition(ccp(posx,posy))
        cell:addChild(rewardBg)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
   
    end
end

function acFirstRechargenewDialog:initFirstRecharge()
    local function cellClick( ... )

    end
    local firstRechargeBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
    firstRechargeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-360))

    local acVo=acFirstRechargenewVoApi:getAcVo()
    local rewardCfg=acFirstRechargenewVoApi:getAcCfg()
    local giftData=FormatItem(rewardCfg,true,true)

    local bgWidth=firstRechargeBg:getContentSize().width
    local bgHeight=firstRechargeBg:getContentSize().height
    local spaceW=180
    local spaceH=180
    local iconSize=100
    for k,v in pairs(giftData) do
        if v and v.pic and v.name then
            -- local function showInfoHandler()
            --     if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            --         if G_checkClickEnable()==false then
            --             do
            --                 return
            --             end
            --         else
            --             base.setWaitTime=G_getCurDeviceMillTime()
            --         end
            --         if v and v.name and v.pic and v.num and v.desc then
            --             if v.key=="gems" or v.key=="gem" then
            --             else
            --                 propInfoDialog:create(sceneGame,v,self.layerNum+1)
            --             end
            --         end
            --     end
            -- end
            local icon
            local scale=1
            if v.key=="gems" or v.key=="gem" then
                icon = LuaCCSprite:createWithSpriteFrameName(v.pic,function ()end)
            else
                icon,scale = G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv)
            end
            -- local icon = LuaCCSprite:createWithSpriteFrameName(v.pic,showInfoHandler)
            -- local scale=1
            -- if icon:getContentSize().width>iconSize then
            --     scale=iconSize/icon:getContentSize().width
            -- end
            -- icon:setScale(scale)
            local posx,posy=bgWidth/2-spaceW+spaceW*((k-1)%3),bgHeight/2+spaceH-spaceH*math.floor((k-1)/3)+20
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(posx,posy))
            firstRechargeBg:addChild(icon,1)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            
            local name  
            if v.key=="gems" or v.key=="gem" then
                name = getlocal("doubleGems")
                G_addRectFlicker(icon,1.4,1.4)
            else
                name = v.name--.." x"..v.num

                local numLb=GetTTFLabel("x"..v.num,25)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(icon:getContentSize().width-10,5))
                icon:addChild(numLb)
                numLb:setScale(1/scale)
            end

            local nameLable = GetTTFLabelWrap(name,25,CCSizeMake(spaceW, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            nameLable:setAnchorPoint(ccp(0.5,1))
            nameLable:setPosition(ccp(posx,posy-60))
            firstRechargeBg:addChild(nameLable,1)
            nameLable:setColor(G_ColorYellowPro)
        end
    end
    return firstRechargeBg
end

function acFirstRechargenewDialog:getFirstRechargeReward()

  -- local function getRewardSuccess(fn,data)

  --   local ret,sData=base:checkServerData(data)
  --   if ret==true then

  --       PlayEffect(audioCfg.mouseClick)
  --       local acVo=acFirstRechargenewVoApi:getAcVo()
  --       local awardTab=FormatItem(acVo.reward,true)
  --       -- 添加奖励
  --       for k,v in pairs(awardTab) do
  --           print("数值是",k,v.key)
  --           if v.key=="gem" or v.key=="gems" then
  --               awardTab[k].num=tonumber(acVo.c)
  --           end
  --           G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
  --       end

  --       acVo.c = -1
  --       acVo.over = true
  --       acVo.hasData=false
  --       activityVoApi:updateVoByType(acVo)

  --       eventDispatcher:dispatchEvent("activity.firstRechargeComplete")
  --       eventDispatcher:dispatchEvent("activity.firstRechargeComplete2")
  --       self.tick()
  --       smallDialog:showRewardDialog("TankInforPanel.png",CCSizeMake(500,600),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,self.layerNum+1,{getlocal("activity_getReward")},25,awardTab)  
  --   end
  -- end
  -- socketHelper:activityFinished("firstRecharge", getRewardSuccess)
end

function acFirstRechargenewDialog:tick()
    if self ~= nil then
        local acVo=acFirstRechargenewVoApi:getAcVo()
        if acVo and acVo.c and tonumber(acVo.c) then
            local flag = tonumber(acVo.c)
            if flag and flag<0 then
                activityVoApi:updateShowState(acVo)
                self:close()
            end
        end
    end 
end

function acFirstRechargenewDialog:update()
  -- body
end

function acFirstRechargenewDialog:getDes(content)
    -- local showMsg=content or ""
    -- local width=G_VisibleSizeWidth - 40
    -- local messageLabel=GetTTFLabelWrap(showMsg,24,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- local height=messageLabel:getContentSize().height+20
    -- messageLabel:setDimensions(CCSizeMake(width, height+50))
    -- return height, messageLabel
end

function acFirstRechargenewDialog:dispose()
    self.acVo = nil
    self.flag = nil
    -- self.rewardMenu = nil
    self.des = nil
    self.desH = nil
    self=nil
end





