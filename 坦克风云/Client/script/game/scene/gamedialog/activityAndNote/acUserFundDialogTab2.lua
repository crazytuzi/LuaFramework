acUserFundDialogTab2=commonDialog:new()

function acUserFundDialogTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.todayMoneyLabel = nil
    self.rewardBtn = nil
    self.cellHeight=110
    return nc
end

function acUserFundDialogTab2:init(layerNum,selectedTabIndex,parentDialog)
  self.bgLayer=CCLayer:create()
  self.layerNum=layerNum
  self.selectedTabIndex=selectedTabIndex
  self.parentDialog=parentDialog
  self.tvWidth=G_VisibleSizeWidth - 40
  local acCfg = acUserFundVoApi:getAcCfg()
  if acCfg and acCfg.extra and SizeOfTable(acCfg.extra)>0 then
      self:initLayer()
      self:doUserHandler()
  end
  return self.bgLayer
end

function acUserFundDialogTab2:initLayer()
    local totalW = self.tvWidth+10
    local acVo = acUserFundVoApi:getAcVo()
    local chargeDays,rewardDays,totalDays,leftDays=acUserFundVoApi:getAcDays()
    local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
    local rewardNum=acUserFundVoApi:getRewardNum()
    local lastRewardTs=acVo.rt
    if ifInRechargeDay==true then
        local function cellClick(hd,fn,index)
        end
        local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),cellClick)
        backSprie2:setContentSize(CCSizeMake(totalW, 40))
        backSprie2:setAnchorPoint(ccp(0.5,0.5))
        backSprie2:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 320 -30))
        self.bgLayer:addChild(backSprie2)

        local goldLabel=GetTTFLabel(getlocal("activity_userFund_recharge_num"),25)
        goldLabel:setPosition(ccp(140 ,20))
        goldLabel:setColor(G_ColorGreen)
        backSprie2:addChild(goldLabel)

        local rewardLabel=GetTTFLabel(getlocal("activity_userFund_reward"),25)
        rewardLabel:setPosition(ccp(totalW - 160,20))
        rewardLabel:setColor(G_ColorGreen)
        backSprie2:addChild(rewardLabel)  


        self:initTableView()
    else
        local spSize=145*1.3
        local lbHeight=G_VisibleSizeHeight-350
        local totalLabel = GetTTFLabelWrap(getlocal("activity_userFund_total"),25,CCSizeMake(totalW, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        totalLabel:setAnchorPoint(ccp(0.5,0.5))
        totalLabel:setPosition(ccp(totalW/2,lbHeight-totalLabel:getContentSize().height/2))
        self.bgLayer:addChild(totalLabel,1)
        totalLabel:setColor(G_ColorGreen)

        local iconSize=40
        local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon:setScale(iconSize/goldIcon:getContentSize().width)
        goldIcon:setPosition(ccp(totalW/2+60,lbHeight-totalLabel:getContentSize().height-40/2-10))
        self.bgLayer:addChild(goldIcon,1)

        local numLabel = GetTTFLabel(tonumber(acVo.v),25)
        numLabel:setAnchorPoint(ccp(0.5,0.5))
        numLabel:setPosition(ccp(totalW/2-60,lbHeight-totalLabel:getContentSize().height-40/2-10))
        self.bgLayer:addChild(numLabel,1)
        numLabel:setColor(G_ColorYellowPro)

        local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSprite:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
        lineSprite:setPosition(ccp((totalW + 30)/2 + 30,lbHeight-40/2-totalLabel:getContentSize().height-40))
        self.bgLayer:addChild(lineSprite,5)

        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"

        -- local lbWidth=totalW/2+50
        local px,py=lineSprite:getPosition()
        local totalRewardLabel = GetTTFLabelWrap(getlocal("activity_userFund_total_reward",{rewardDays}),25,CCSizeMake(totalW-spSize-50, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        totalRewardLabel:setAnchorPoint(ccp(0,0.5))
        totalRewardLabel:setPosition(ccp(40,py-totalRewardLabel:getContentSize().height/2-20))
        self.bgLayer:addChild(totalRewardLabel,1)

        local goldIcon1=CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon1:setScale(iconSize/goldIcon1:getContentSize().width)
        goldIcon1:setPosition(ccp(150,py-totalRewardLabel:getContentSize().height-40/2-30))
        self.bgLayer:addChild(goldIcon1,1)

        local numLabel1 = GetTTFLabel(tonumber(rewardNum*rewardDays),25)
        numLabel1:setAnchorPoint(ccp(0,0.5))
        numLabel1:setPosition(ccp(60,py-totalRewardLabel:getContentSize().height-40/2-30))
        self.bgLayer:addChild(numLabel1,1)
        numLabel1:setColor(G_ColorYellowPro)


        local px2,py2=goldIcon1:getPosition()
        -- local dayRewardLabel = GetTTFLabelWrap(str,25,CCSizeMake(totalW-spSize-50, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        local dayRewardLabel = GetTTFLabelWrap(getlocal("activity_userFund_day_reward"),25,CCSizeMake(totalW-spSize-20, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        dayRewardLabel:setAnchorPoint(ccp(0,0.5))
        dayRewardLabel:setPosition(ccp(40,py2-40/2-dayRewardLabel:getContentSize().height/2-10))
        self.bgLayer:addChild(dayRewardLabel,1)

        local goldIcon2=CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon2:setScale(iconSize/goldIcon2:getContentSize().width)
        goldIcon2:setPosition(ccp(150,py2-dayRewardLabel:getContentSize().height-40-20))
        self.bgLayer:addChild(goldIcon2,1)

        local numLabel2 = GetTTFLabel(tonumber(rewardNum),25)
        numLabel2:setAnchorPoint(ccp(0,0.5))
        numLabel2:setPosition(ccp(60,py2-dayRewardLabel:getContentSize().height-40-20))
        self.bgLayer:addChild(numLabel2,1)
        numLabel2:setColor(G_ColorYellowPro)


        local px3,py3=goldIcon2:getPosition()
        -- local leftDayLabel = GetTTFLabelWrap(str,25,CCSizeMake(totalW-spSize-50, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        local leftDayLabel = GetTTFLabelWrap(getlocal("activity_userFund_left_day"),25,CCSizeMake(totalW-spSize-20, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        leftDayLabel:setAnchorPoint(ccp(0,0.5))
        leftDayLabel:setPosition(ccp(40,py3-40/2-leftDayLabel:getContentSize().height/2-10))
        self.bgLayer:addChild(leftDayLabel,1)

        local dayStr
        if leftDays<=1 then
            local leftTime=acVo.et-base.serverTime
            dayStr=G_getTimeStr(leftTime)
        else
            dayStr=getlocal("signRewardDay",{leftDays-1})
        end
        self.dayLabel = GetTTFLabelWrap(dayStr,25,CCSizeMake(totalW-spSize-20, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.dayLabel:setAnchorPoint(ccp(0,0.5))
        self.dayLabel:setPosition(ccp(60,py3-leftDayLabel:getContentSize().height-40-20))
        self.bgLayer:addChild(self.dayLabel,1)
        self.dayLabel:setColor(G_ColorYellowPro)


        local goldSp=CCSprite:createWithSpriteFrameName("iconGold6.png")
        goldSp:setScale(spSize/goldSp:getContentSize().width)
        goldSp:setPosition(ccp(totalW-120/2-40,lbHeight-250))
        self.bgLayer:addChild(goldSp,1)
        -- print("goldSp:getContentSize().width",goldSp:getContentSize().width)

        local function rewardHandler(tag,object)
          PlayEffect(audioCfg.mouseClick)
          self:getReward()
        end
        self.rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardHandler,101,getlocal("daily_scene_get"),28,1001)
        self.rewardBtn:setAnchorPoint(ccp(0.5, 0))
        local menuAward=CCMenu:createWithItem(self.rewardBtn)
        menuAward:setPosition(ccp(G_VisibleSizeWidth/2,30))
        menuAward:setTouchPriority(-(self.layerNum-1)*20-4)
        if acUserFundVoApi:canRewardExtra() == true then
          self.rewardBtn:setEnabled(true)
        else
          self.rewardBtn:setEnabled(false)
          if G_isToday(lastRewardTs)==true then
            tolua.cast(self.rewardBtn:getChildByTag(1001),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
          end   
        end  
        self.bgLayer:addChild(menuAward,1) 
    end
end

function acUserFundDialogTab2:initTableView()
  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  -- self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  -- self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 395))
  -- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 100))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth-10,G_VisibleSizeHeight - 460 + 50),nil)
  self.bgLayer:addChild(self.tv,1)
  self.tv:setPosition(ccp(30,30))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)

  -- local acCfg = acUserFundVoApi:getAcCfg()
  -- if acCfg ~= nil and acCfg.extra ~= nil then
  --     if 120 * SizeOfTable(acCfg.extra) + 20 > G_VisibleSizeHeight - 460 then
  --         local recordPoint = self.tv:getRecordPoint()
  --         recordPoint.y = 0
  --         self.tv:recoverToRecordPoint(recordPoint)
  --     end
  -- end

end

function acUserFundDialogTab2:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    local acCfg = acUserFundVoApi:getAcCfg()
    if acCfg and acCfg.extra and SizeOfTable(acCfg.extra)>0 then
      return SizeOfTable(acCfg.extra)
    else
      return 0
    end
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(self.tvWidth-10,self.cellHeight)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local function cellClick(hd,fn,index)
    end
    local w = self.tvWidth-20 -- 背景框的宽度
    local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
    backSprie:setContentSize(CCSizeMake(w,self.cellHeight-5))
    backSprie:setAnchorPoint(ccp(0,0.5))
    backSprie:setPosition(ccp(0,self.cellHeight/2))
    cell:addChild(backSprie)

    local acCfg = acUserFundVoApi:getAcCfg()
    if acCfg ~= nil and acCfg.cost ~= nil and acCfg.extra ~= nil then
        local cost=acCfg.cost[idx+1]
        local rewardNum=acCfg.extra[idx+1]
        local chargeDays,rewardDays,totalDays=acUserFundVoApi:getAcDays()

        local costLabel = GetTTFLabel(cost,35)
        costLabel:setAnchorPoint(ccp(0.5,0.5))
        costLabel:setPosition(ccp(120,self.cellHeight/2))
        costLabel:setColor(G_ColorGreen)
        cell:addChild(costLabel,1)

        local rewardNumLabel = GetTTFLabel(rewardNum*rewardDays,35)
        rewardNumLabel:setAnchorPoint(ccp(0.5,0.5))
        rewardNumLabel:setPosition(ccp(w-180,self.cellHeight/2))
        rewardNumLabel:setColor(G_ColorYellowPro)
        cell:addChild(rewardNumLabel,1)

        local iconSize=45
        local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon:setScale(iconSize/goldIcon:getContentSize().width)
        goldIcon:setPosition(ccp(w-100,self.cellHeight/2))
        cell:addChild(goldIcon)
    end


    -- local verticalLine = CCSprite:createWithSpriteFrameName("LineCross.png")
    -- verticalLine:setScaleX(totalH/verticalLine:getContentSize().width)
    -- verticalLine:setRotation(90)
    -- verticalLine:setPosition(ccp(leftW ,totalH/2 + rewardBtnH))
    -- cell:addChild(verticalLine,2)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acUserFundDialogTab2:getReward()
  if acUserFundVoApi:canRewardExtra() == true then
    local function getRawardCallback(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
          local addNum=acUserFundVoApi:getRewardNum()
          local award={u={gems=addNum}}
          local reward = FormatItem(award, true)
          for k,v in pairs(reward) do
            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
          end
          G_showRewardTip(reward,true)
          if sData.ts then
            acUserFundVoApi:afterGetRewardExtra(sData.ts)
          end
          if self.rewardBtn then
            self.rewardBtn:setEnabled(false)
            tolua.cast(self.rewardBtn:getChildByTag(1001),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
          end
      end
    end
    socketHelper:activeUserfundreward(getRawardCallback)
  end
end

function acUserFundDialogTab2:getAwardStr(reward)
  local awardTab = reward
  local str = getlocal("daily_lotto_tip_10")
  if awardTab then
    for k,v in pairs(awardTab) do
      if k==SizeOfTable(awardTab) then
        str = str .. v.name .. " x" .. v.num
      else
        str = str .. v.name .. " x" .. v.num .. ","
      end
    end
  end
  return str
end


function acUserFundDialogTab2:initNeedMoney(id)
  local needMoney = acUserFundVoApi:getNeedMoneyById(id)
  local needMoneyLabel=GetTTFLabel(tostring(needMoney),28)
  needMoneyLabel:setColor(G_ColorGreen)
  return needMoneyLabel
end

function acUserFundDialogTab2:doUserHandler()
  local function cellClick(hd,fn,index)
  end
  
  local w = self.tvWidth -- 背景框的宽度
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
  backSprie:setContentSize(CCSizeMake(w, 150))
  backSprie:setAnchorPoint(ccp(0,0))
  backSprie:setPosition(ccp(20, G_VisibleSizeHeight - 290 - 25))
  self.bgLayer:addChild(backSprie)


  local iconSp=CCSprite:createWithSpriteFrameName("Icon_grown.png")
  iconSp:setAnchorPoint(ccp(0.5,0.5))
  iconSp:setPosition(ccp(iconSp:getContentSize().width/2+10,backSprie:getContentSize().height/2))
  backSprie:addChild(iconSp,1)

  
  self.desLabel = GetTTFLabelWrap(getlocal("activity_userFund_desc_2"),25,CCSizeMake(w-130, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.desLabel:setAnchorPoint(ccp(0,0.5))
  self.desLabel:setPosition(ccp(iconSp:getContentSize().width+20,backSprie:getContentSize().height/2))
  backSprie:addChild(self.desLabel,1)

  local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
  if ifInRechargeDay==true then
      self.desLabel:setString(getlocal("activity_userFund_desc_2"))
  elseif ifInRewardDay==true then
      self.desLabel:setString(getlocal("activity_userFund_desc_3"))
  end

end

-- 更新今日充值金额
-- function acUserFundDialogTab2:updateTodayMoneyLabel()
--   if self == nil then
--     do 
--      return
--     end
--   end

--   if self.todayMoneyLabel ~= nil then
--     self.todayMoneyLabel:setString(tostring(acUserFundVoApi:getTodayMoney()))
--   end
--   if self.rewardBtn ~= nil then
--     if acUserFundVoApi:canReward() == true then
--       self.rewardBtn:setEnabled(true)
--     else
--       self.rewardBtn:setEnabled(false)
--     end
--   end

-- end

function acUserFundDialogTab2:tick()
    if self and self.dayLabel then
        local dayStr
        local acVo = acUserFundVoApi:getAcVo()
        local chargeDays,rewardDays,totalDays,leftDays=acUserFundVoApi:getAcDays()
        if leftDays<=1 then
            local leftTime=acVo.et-base.serverTime
            dayStr=G_getTimeStr(leftTime)
        else
            dayStr=getlocal("signRewardDay",{leftDays-1})
        end
        self.dayLabel:setString(dayStr)

        if self.desLabel then
            local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
            if ifInRechargeDay==true then
                self.desLabel:setString(getlocal("activity_userFund_desc_2"))
            elseif ifInRewardDay==true then
                self.desLabel:setString(getlocal("activity_userFund_desc_3"))
            end
        end
    end
end

function acUserFundDialogTab2:refresh()

end

-- function acUserFundDialogTab2:update()
--   local acVo = acUserFundVoApi:getAcVo()
--   if acVo ~= nil then
--     if self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
--       self:updateTodayMoneyLabel()
--       local recordPoint = self.tv:getRecordPoint()
--       self.tv:reloadData()
--       self.tv:recoverToRecordPoint(recordPoint)
--     end
--   end
-- end

function acUserFundDialogTab2:dispose()
  self.todayMoneyLabel = nil
  self.rewardBtn = nil
end





