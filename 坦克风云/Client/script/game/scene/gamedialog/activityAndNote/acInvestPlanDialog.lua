acInvestPlanDialog=commonDialog:new()

function acInvestPlanDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

    -- self.layerTab1=nil
    -- self.layerTab2=nil
    
    -- self.userFundTab1=nil
    -- self.userFundTab2=nil

    self.isStop=false
    self.isToday=true
    
    return nc
end

function acInvestPlanDialog:initTableView()
    self.tvWidth=G_VisibleSizeWidth - 40

    local function callBack(...)
       -- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth-100,G_VisibleSizeHeight-490),nil)
    self.tv:setPosition(ccp(10,110))
    
    local acCfg = acInvestPlanVoApi:getAcCfg()
    if acCfg and acCfg.cost and SizeOfTable(acCfg.cost)>0 and acCfg.extra and SizeOfTable(acCfg.extra)>0 then
        self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
        self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight - 395 + 50))
        self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 20))

        local ifInRechargeDay,ifInRewardDay=acInvestPlanVoApi:getIfInDays()
        if ifInRechargeDay==true then
            self:initDesc()
            self:initTableView1()
        elseif ifInRewardDay==true then
            self:initDesc()
            self:initRewardDesc()
        end
    end
end

function acInvestPlanDialog:initTableView1()
    local totalLabel = GetTTFLabelWrap(getlocal("activity_userFund_total"),25,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    totalLabel:setAnchorPoint(ccp(0.5,0.5))
    totalLabel:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-355))
    self.bgLayer:addChild(totalLabel,1)
    totalLabel:setColor(G_ColorGreen)

    local acVo = acInvestPlanVoApi:getAcVo()
    self.numLabel = GetTTFLabel(tonumber(acVo.v),28)
    self.numLabel:setAnchorPoint(ccp(0.5,0.5))
    self.numLabel:setPosition(ccp(G_VisibleSizeWidth/2-40,G_VisibleSizeHeight-395))
    self.bgLayer:addChild(self.numLabel,1)
    self.numLabel:setColor(G_ColorYellowPro)

    local iconSize=45
    local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon:setScale(iconSize/goldIcon:getContentSize().width)
    goldIcon:setPosition(ccp(G_VisibleSizeWidth/2+40,G_VisibleSizeHeight-395))
    self.bgLayer:addChild(goldIcon,1)

    
    local totalW = self.tvWidth
    local function cellClick()
    end
    local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),cellClick)
    backSprie2:setContentSize(CCSizeMake(totalW, 40))
    backSprie2:setAnchorPoint(ccp(0.5,0.5))
    backSprie2:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight-350-90))
    self.bgLayer:addChild(backSprie2)

    local goldLabel=GetTTFLabel(getlocal("gem"),25)
    goldLabel:setPosition(ccp(180 ,20))
    goldLabel:setColor(G_ColorGreen)
    backSprie2:addChild(goldLabel)

    local rewardLabel=GetTTFLabel(getlocal("award"),25)
    rewardLabel:setPosition(ccp(totalW-140,20))
    rewardLabel:setColor(G_ColorGreen)
    backSprie2:addChild(rewardLabel)  

    local function rechargeHandler(tag,object)
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      PlayEffect(audioCfg.mouseClick)
      vipVoApi:showRechargeDialog(self.layerNum+2)
    end
    self.rechargeBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rechargeHandler,0,getlocal("recharge"),28)
    self.rechargeBtn:setAnchorPoint(ccp(0.5, 0)) 
    local rechargeMenu=CCMenu:createWithItem(self.rechargeBtn)
    rechargeMenu:setPosition(ccp(G_VisibleSizeWidth/2,30))
    rechargeMenu:setTouchPriority(-(self.layerNum-1)*20-4) 

    self.bgLayer:addChild(rechargeMenu,1) 


    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)

    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,G_VisibleSizeHeight-570),nil)
    self.bgLayer:addChild(self.tv,1)
    self.tv:setPosition(ccp(10,110))
    self.tv:setAnchorPoint(ccp(0,0))
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(120)

    local acCfg = acInvestPlanVoApi:getAcCfg()
    if acCfg ~= nil and acCfg.extra ~= nil then
        if 95 * SizeOfTable(acCfg.extra) + 20 > G_VisibleSizeHeight - 570 then
            local recordPoint = self.tv:getRecordPoint()
            recordPoint.y = 0
            self.tv:recoverToRecordPoint(recordPoint)
        end
    end

end

function acInvestPlanDialog:initRewardDesc()
    local totalW = self.tvWidth+10
    local acVo = acInvestPlanVoApi:getAcVo()
    local chargeDays,rewardDays,totalDays,leftDays=acInvestPlanVoApi:getAcDays()
    local ifInRechargeDay,ifInRewardDay=acInvestPlanVoApi:getIfInDays()
    local rewardNum=acInvestPlanVoApi:getRewardNum()
    local lastRewardTs=acVo.rt

    local spSize=145*1.3
    local lbHeight=G_VisibleSizeHeight-350
    local totalLabel = GetTTFLabelWrap(getlocal("activity_userFund_total"),25,CCSizeMake(totalW, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    totalLabel:setAnchorPoint(ccp(0.5,0.5))
    totalLabel:setPosition(ccp(G_VisibleSizeWidth/2,lbHeight-totalLabel:getContentSize().height/2))
    self.bgLayer:addChild(totalLabel,1)
    totalLabel:setColor(G_ColorGreen)

    local iconSize=40
    local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon:setScale(iconSize/goldIcon:getContentSize().width)
    goldIcon:setPosition(ccp(G_VisibleSizeWidth/2+40,lbHeight-totalLabel:getContentSize().height-40/2-10))
    self.bgLayer:addChild(goldIcon,1)

    local numLabel = GetTTFLabel(tonumber(acVo.v),25)
    numLabel:setAnchorPoint(ccp(0.5,0.5))
    numLabel:setPosition(ccp(G_VisibleSizeWidth/2-40,lbHeight-totalLabel:getContentSize().height-40/2-10))
    self.bgLayer:addChild(numLabel,1)
    numLabel:setColor(G_ColorYellowPro)

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
    lineSprite:setPosition(ccp(G_VisibleSizeWidth/2,lbHeight-40/2-totalLabel:getContentSize().height-40))
    self.bgLayer:addChild(lineSprite,5)

    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"

    -- local lbWidth=totalW/2+50
    local px,py=lineSprite:getPosition()
    local totalRewardLabel = GetTTFLabelWrap(getlocal("activity_userFund_total_reward",{rewardDays}),25,CCSizeMake(totalW, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    totalRewardLabel:setAnchorPoint(ccp(0.5,0.5))
    totalRewardLabel:setPosition(ccp(G_VisibleSizeWidth/2,py-totalRewardLabel:getContentSize().height/2-20))
    self.bgLayer:addChild(totalRewardLabel,1)

    local goldIcon1=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon1:setScale(iconSize/goldIcon1:getContentSize().width)
    goldIcon1:setPosition(ccp(G_VisibleSizeWidth/2+40,py-totalRewardLabel:getContentSize().height-40/2-30))
    self.bgLayer:addChild(goldIcon1,1)

    local numLabel1 = GetTTFLabel(tonumber(rewardNum*rewardDays),25)
    numLabel1:setAnchorPoint(ccp(0.5,0.5))
    numLabel1:setPosition(ccp(G_VisibleSizeWidth/2-40,py-totalRewardLabel:getContentSize().height-40/2-30))
    self.bgLayer:addChild(numLabel1,1)
    numLabel1:setColor(G_ColorYellowPro)


    local px2,py2=goldIcon1:getPosition()
    -- local dayRewardLabel = GetTTFLabelWrap(str,25,CCSizeMake(totalW-spSize-50, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    local dayRewardLabel = GetTTFLabelWrap(getlocal("activity_userFund_day_reward"),25,CCSizeMake(totalW-spSize-20, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    dayRewardLabel:setAnchorPoint(ccp(0.5,0.5))
    dayRewardLabel:setPosition(ccp(G_VisibleSizeWidth/2,py2-40/2-dayRewardLabel:getContentSize().height/2-10))
    self.bgLayer:addChild(dayRewardLabel,1)

    local goldIcon2=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon2:setScale(iconSize/goldIcon2:getContentSize().width)
    goldIcon2:setPosition(ccp(G_VisibleSizeWidth/2+40,py2-dayRewardLabel:getContentSize().height-30-20))
    self.bgLayer:addChild(goldIcon2,1)

    local numLabel2 = GetTTFLabel(tonumber(rewardNum),25)
    numLabel2:setAnchorPoint(ccp(0.5,0.5))
    numLabel2:setPosition(ccp(G_VisibleSizeWidth/2-40,py2-dayRewardLabel:getContentSize().height-30-20))
    self.bgLayer:addChild(numLabel2,1)
    numLabel2:setColor(G_ColorYellowPro)


    local px3,py3=goldIcon2:getPosition()
    -- local leftDayLabel = GetTTFLabelWrap(str,25,CCSizeMake(totalW-spSize-50, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    local leftDayLabel = GetTTFLabelWrap(getlocal("activity_userFund_left_day"),25,CCSizeMake(totalW, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    leftDayLabel:setAnchorPoint(ccp(0.5,0.5))
    leftDayLabel:setPosition(ccp(G_VisibleSizeWidth/2,py3-40/2-leftDayLabel:getContentSize().height/2-10))
    self.bgLayer:addChild(leftDayLabel,1)

    local dayStr
    if leftDays<=1 then
        local leftTime=acVo.et-base.serverTime
        dayStr=G_getTimeStr(leftTime)
    else
        dayStr=getlocal("signRewardDay",{leftDays-1})
    end
    self.dayLabel = GetTTFLabelWrap(dayStr,25,CCSizeMake(totalW-spSize-20, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.dayLabel:setAnchorPoint(ccp(0.5,0.5))
    self.dayLabel:setPosition(ccp(G_VisibleSizeWidth/2,py3-leftDayLabel:getContentSize().height-40-20))
    self.bgLayer:addChild(self.dayLabel,1)
    self.dayLabel:setColor(G_ColorYellowPro)


    -- local goldSp=CCSprite:createWithSpriteFrameName("iconGold6.png")
    -- goldSp:setScale(spSize/goldSp:getContentSize().width)
    -- goldSp:setPosition(ccp(totalW-120/2-40,lbHeight-250))
    -- self.bgLayer:addChild(goldSp,1)
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
    if acInvestPlanVoApi:canRewardExtra() == true then
      self.rewardBtn:setEnabled(true)
    else
      self.rewardBtn:setEnabled(false)
      if G_isToday(lastRewardTs)==true then
        tolua.cast(self.rewardBtn:getChildByTag(1001),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
      end   
    end  
    self.bgLayer:addChild(menuAward,1) 
end

function acInvestPlanDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local acCfg = acInvestPlanVoApi:getAcCfg()
    if acCfg ~= nil and acCfg.extra ~= nil then
      return  CCSizeMake(self.tvWidth,95 * SizeOfTable(acCfg.extra) + 20)
    end
    return  CCSizeMake(self.tvWidth,95)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local chargeDays,rewardDays,totalDays,leftDays=acInvestPlanVoApi:getAcDays()

    local rewardLabelH = 20
    local rewardBtnH = 0
    local barH = 95

    local totalH  -- 总高度

    local acCfg = acInvestPlanVoApi:getAcCfg()
    if acCfg ~= nil and acCfg.extra ~= nil then
      totalH = barH * SizeOfTable(acCfg.extra)
    else
      totalH = barH
    end

    local totalW = self.tvWidth
    local leftW = totalW * 0.3
    local rightW = totalW * 0.7
     
    
    local todayMoney = acInvestPlanVoApi:getTodayMoney()

    local acVo = acInvestPlanVoApi:getAcVo()
    local rechargeNum=tonumber(acVo.v)

    self.bgTab={}

    local per = 0
    local perWidth = 0
    local addContinue = true
    if acCfg ~= nil and acCfg.extra ~= nil then
      local rewardLen = SizeOfTable(acCfg.extra)
      if rewardLen ~= nil and rewardLen > 0 then
          for i=1,rewardLen do
            local h = barH * (rewardLen - i) + rewardBtnH -- 每条奖励信息的y坐标起始位置

            local isCurrent=false
            local needMoney

            local needMoney = self:initNeedMoney(rewardLen - i + 1)
            needMoney:setAnchorPoint(ccp(1,1))
            needMoney:setPosition(ccp(leftW+20,h+barH-10))
            cell:addChild(needMoney,2)

            local iconSize=45
            local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
            goldIcon:setScale(iconSize/goldIcon:getContentSize().width)
            goldIcon:setPosition(ccp(leftW+60,h+barH-iconSize/2-5))
            cell:addChild(goldIcon,2)


            local rewardMoney = acCfg.extra[rewardLen - i + 1]
            local rewardMoneyLabel=GetTTFLabel((rewardMoney*rewardDays),28)
            rewardMoneyLabel:setColor(G_ColorYellowPro)
            rewardMoneyLabel:setAnchorPoint(ccp(1,1))
            rewardMoneyLabel:setPosition(ccp(self.tvWidth-110,h+barH-10))
            cell:addChild(rewardMoneyLabel,2)

            local goldIcon1=CCSprite:createWithSpriteFrameName("IconGold.png")
            goldIcon1:setScale(iconSize/goldIcon1:getContentSize().width)
            goldIcon1:setPosition(ccp(self.tvWidth-70,h+barH-iconSize/2-5))
            cell:addChild(goldIcon1,2)

            
            local wSpace=100
            local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSprite:setScaleX((totalW + 30+wSpace)/lineSprite:getContentSize().width)
            lineSprite:setPosition(ccp((totalW + 30+wSpace)/2 + 30,h + barH))
            cell:addChild(lineSprite,5)
            if i == rewardLen then
              local lineSprite2 = CCSprite:createWithSpriteFrameName("LineCross.png")
              lineSprite2:setScaleX((totalW + 30+wSpace)/lineSprite:getContentSize().width)
              lineSprite2:setPosition(ccp((totalW + 30+wSpace)/2 + 30,h))
              cell:addChild(lineSprite2,5)
            end

            local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
            bgSp:setPosition(ccp(self.tvWidth/2+40,h+(barH-5)/2+3))
            bgSp:setScaleY((barH-5)/bgSp:getContentSize().height)
            bgSp:setScaleX((self.tvWidth-40)/bgSp:getContentSize().width)
            cell:addChild(bgSp,1)
            bgSp:setVisible(false)
            self.bgTab[rewardLen-i+1]=bgSp
          end
      end

      for k,v in pairs(acCfg.cost) do
            local costNum=tonumber(v)
            if rechargeNum>=costNum and (acCfg.cost[k+1]==nil or rechargeNum<acCfg.cost[k+1]) then
                if self.bgTab[k] then
                    self.bgTab[k]:setVisible(true)
                end
            end
      end


      for j=1,rewardLen do
        local money = acInvestPlanVoApi:getNeedMoneyById(j) -- 当前需要的金币
        if addContinue == true then
          if tonumber(todayMoney) >= tonumber(money) then
            perWidth = perWidth + barH
          else
            local lastMoney
            if j == 1 then
              lastMoney = 0
            else
              lastMoney = acInvestPlanVoApi:getNeedMoneyById(j - 1)
            end
            perWidth = perWidth + barH * ((todayMoney - lastMoney) / (money - lastMoney))
            addContinue = false
          end
        end
      end

    end    

    local barWidth = totalH + rewardBtnH
    local function click(hd,fn,idx)
    end
    local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("HelpBgBottom.png", CCRect(20,20,1,1),click)
    barSprie:setContentSize(CCSizeMake(barWidth, 50))
    barSprie:setRotation(90)
    barSprie:setPosition(ccp(50,barWidth/2))
    cell:addChild(barSprie,1)

    AddProgramTimer(cell,ccp(50,barWidth/2),11,12,nil,"AllBarBg.png","AllXpBar.png",13,1,1)
    local per = tonumber(perWidth)/tonumber(barWidth) * 100
    local timerSpriteLv = cell:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)
    timerSpriteLv:setRotation(-90)
    timerSpriteLv:setScaleX(barWidth/timerSpriteLv:getContentSize().width)
    local bg = cell:getChildByTag(13)
    bg:setVisible(false)
    -- bg:setRotation(-90)
    -- bg:setScaleX(barWidth/bg:getContentSize().width)


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

function acInvestPlanDialog:getReward()
  if acInvestPlanVoApi:canRewardExtra() == true then
    local function getRawardCallback(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
          local addNum=acInvestPlanVoApi:getRewardNum()
          local award={u={gems=addNum}}
          local reward = FormatItem(award, true)
          for k,v in pairs(reward) do
            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
          end
          G_showRewardTip(reward,true)
          if sData.ts then
            acInvestPlanVoApi:afterGetRewardExtra(sData.ts)
          end
          if self.rewardBtn then
            self.rewardBtn:setEnabled(false)
            tolua.cast(self.rewardBtn:getChildByTag(1001),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
          end
      end
    end
    socketHelper:activeInvestplan(getRawardCallback)
  end
end

function acInvestPlanDialog:getAwardStr(reward)
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


function acInvestPlanDialog:initNeedMoney(id)
  local needMoney = acInvestPlanVoApi:getNeedMoneyById(id)
  local needMoneyLabel=GetTTFLabel(tostring(needMoney),28)
  needMoneyLabel:setColor(G_ColorGreen)
  return needMoneyLabel
end

function acInvestPlanDialog:initDesc()
  local chargeDays,rewardDays,totalDays,leftDays=acInvestPlanVoApi:getAcDays()

    local function cellClick()

    end

    local function touch(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self:openInfo()
    end

    local acLabel = GetTTFLabelWrap(getlocal("activity_timeLabel"),25,CCSizeMake(self.tvWidth-120, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    acLabel:setAnchorPoint(ccp(0.5,0.5))
    acLabel:setPosition(ccp((self.tvWidth)/2,G_VisibleSizeHeight-105))
    self.bgLayer:addChild(acLabel)
    acLabel:setColor(G_ColorGreen)

    local acVo = acInvestPlanVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,22)
    messageLabel:setAnchorPoint(ccp(0.5,0.5))
    messageLabel:setPosition(ccp((self.tvWidth)/2,G_VisibleSizeHeight-140))
    self.bgLayer:addChild(messageLabel)

    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(0.5,0.5))
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(self.tvWidth-menuItemDesc:getContentSize().width/2-10,G_VisibleSizeHeight-125))
    self.bgLayer:addChild(menuDesc)


    local iHeight=G_VisibleSizeHeight-255
    local iSize=100
    local icon=GetBgIcon("iconGold6.png",nil,nil,iSize-30,iSize)
    icon:setAnchorPoint(ccp(0.5,0.5))
    icon:setPosition(ccp(iSize/2+20,iHeight))
    self.bgLayer:addChild(icon)

    local ruleLabel = GetTTFLabelWrap(getlocal("activity_ruleLabel"),25,CCSizeMake(self.tvWidth-iSize-40, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    ruleLabel:setAnchorPoint(ccp(0,0.5))
    ruleLabel:setPosition(ccp(20,iHeight+iSize/2+30))
    self.bgLayer:addChild(ruleLabel)
    ruleLabel:setColor(G_ColorGreen)

    local desLabel = GetTTFLabelWrap(getlocal("activity_investPlan_desc",{chargeDays,rewardDays}),20,CCSizeMake(self.tvWidth-iSize-40, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLabel:setAnchorPoint(ccp(0,0.5))
    desLabel:setPosition(ccp(iSize+30,iHeight))
    self.bgLayer:addChild(desLabel)

end

function acInvestPlanDialog:openInfo()
  local chargeDays,rewardDays,totalDays=acInvestPlanVoApi:getAcDays()
  local sampleNum,costNum=acInvestPlanVoApi:getSampleNum()
  local td=smallDialog:new()
  local tabStr = {"\n",getlocal("activity_investPlan_tip_4",{sampleNum,costNum}),"\n",getlocal("activity_investPlan_tip_3"),"\n",getlocal("activity_investPlan_tip_2"),"\n",getlocal("activity_investPlan_tip_1",{chargeDays,rewardDays}),"\n"}
  local colorTab = {nil,G_ColorWhite,nil,G_ColorWhite,nil,G_ColorWhite,nil,G_ColorWhite,nil}
  local dialog=td:init("PanelPopup.png",CCSizeMake(600,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTab,nil,true)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acInvestPlanDialog:tick()
    local vo=acInvestPlanVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    if self and self.dayLabel then
        local dayStr
        local acVo = acInvestPlanVoApi:getAcVo()
        local chargeDays,rewardDays,totalDays,leftDays=acInvestPlanVoApi:getAcDays()
        if leftDays<=1 then
            local leftTime=acVo.et-base.serverTime
            dayStr=G_getTimeStr(leftTime)
        else
            dayStr=getlocal("signRewardDay",{leftDays-1})
        end
        self.dayLabel:setString(dayStr)
    end

    -- if self then
    --     if vo and self.numLabel then
    --         self.numLabel:setString(tonumber(vo.v))
    --     end
    -- end

end

function acInvestPlanDialog:refresh(type)

end

function acInvestPlanDialog:dispose()
    self.bgLayer=nil
    self.layerNum=nil

    self.todayMoneyLabel = nil
    self.rewardBtn = nil

    -- self.layerTab1=nil
    -- self.layerTab2=nil

    -- self.userFundTab1=nil
    -- self.userFundTab2=nil

    self.isStop=nil
    self.isToday=nil

end

