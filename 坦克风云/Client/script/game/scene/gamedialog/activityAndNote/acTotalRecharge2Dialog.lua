acTotalRecharge2Dialog=commonDialog:new()

function acTotalRecharge2Dialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.totalMoneyLabel = nil
    self.goldIcon = nil
    self.moneyX = nil
    self.rewardBtn = nil
    return nc
end

function acTotalRecharge2Dialog:initTableView()
  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 395))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 100))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 460),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,110))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)


  local acCfg = acTotalRecharge2VoApi:getAcRewardCfg()
  if acCfg ~= nil then
    if 120 * SizeOfTable(acCfg) + 20 > G_VisibleSizeHeight - 460 then
      local recordPoint = self.tv:getRecordPoint()
      recordPoint.y = 0
      self.tv:recoverToRecordPoint(recordPoint)
    end
  end 

end

function acTotalRecharge2Dialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local acCfg = acTotalRecharge2VoApi:getAcRewardCfg()
    if acCfg ~= nil then
      return  CCSizeMake(G_VisibleSizeWidth - 20,120 * SizeOfTable(acCfg) + 20)
    end
    return  CCSizeMake(G_VisibleSizeWidth - 20,120)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local rewardLabelH = 20
    local rewardBtnH = 0
    local barH = 120

    local totalH  -- 总高度

    local acCfg = acTotalRecharge2VoApi:getAcRewardCfg()
    if acCfg ~= nil then
      totalH = barH * SizeOfTable(acCfg)
    else
      totalH = barH
    end

    local totalW = G_VisibleSizeWidth - 20
    local leftW = totalW * 0.3
    local rightW = totalW * 0.7
     
    
    local totalMoney = acTotalRecharge2VoApi:getTotalMoney()


    local per = 0
    local perWidth = 0
    local addContinue = true
    if acCfg ~= nil then
      local rewardLen = SizeOfTable(acCfg)
      if rewardLen ~= nil and rewardLen > 0 then
          for i=1,rewardLen do

            local h = barH * (rewardLen - i) + rewardBtnH -- 每条奖励信息的y坐标起始位置

            local award=FormatItem(acTotalRecharge2VoApi:getRewardById(rewardLen - i + 1),true)
            
            if award ~= nil then
               for k,v in pairs(award) do
                local icon, iconScale = G_getItemIcon(v, 100, true, self.layerNum)
                icon:ignoreAnchorPointForPosition(false)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(ccp(10+(k-1)*110 + leftW ,h+barH/2))
                icon:setIsSallow(false)
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(icon,1)
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
            

            local canReward = acTotalRecharge2VoApi:checkIfCanRewardById(rewardLen - i + 1)
            if canReward == true then
              local hadReward = acTotalRecharge2VoApi:checkIfHadRewardById(rewardLen - i + 1)
              if hadReward == true then 
                local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
                rightIcon:setAnchorPoint(ccp(1,0.5))
                rightIcon:setPosition(ccp(totalW - 10,h+barH/2))
                cell:addChild(rightIcon,1)
              else
                local strSize2 = 28
                if G_getCurChoseLanguage() =="ko" then
                  strSize2 = 24
                end
                local rewardLabel = GetTTFLabel(getlocal("canReward"),strSize2)
                rewardLabel:setAnchorPoint(ccp(1,0.5))
                rewardLabel:setPosition(ccp(totalW - 20,h+barH/2))
                rewardLabel:setColor(G_ColorGreen)
                cell:addChild(rewardLabel,1)
                end

            else
              local noLabel = GetTTFLabelWrap(getlocal("activity_totalRecharge_no"),28,CCSizeMake(28*7,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
              noLabel:setAnchorPoint(ccp(1,0.5))
              noLabel:setPosition(ccp(totalW - 20,h+barH/2))
              cell:addChild(noLabel,1)
            end

            local needMoney = self:initNeedMoney(rewardLen - i + 1)

            needMoney:setAnchorPoint(ccp(1,0))
            needMoney:setPosition(ccp(leftW-10,h+barH - 30))
            cell:addChild(needMoney,2)
            

            local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSprite:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
            lineSprite:setPosition(ccp((totalW + 30)/2 + 30,h + barH))
            cell:addChild(lineSprite,5)
            if i == rewardLen then
              local lineSprite2 = CCSprite:createWithSpriteFrameName("LineCross.png")
              lineSprite2:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
              lineSprite2:setPosition(ccp((totalW + 30)/2 + 30,h))
              cell:addChild(lineSprite2,5)
            end

          end
      end

      for j=1,rewardLen do
        local money = acTotalRecharge2VoApi:getNeedMoneyById(j) -- 当前需要的金币
        if addContinue == true then
          if tonumber(totalMoney) >= tonumber(money) then
            perWidth = perWidth + barH
          else
            local lastMoney
            if j == 1 then
              lastMoney = 0
            else
              lastMoney = acTotalRecharge2VoApi:getNeedMoneyById(j - 1)
            end
            perWidth = perWidth + barH * ((totalMoney - lastMoney) / (money - lastMoney))
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


    local verticalLine = CCSprite:createWithSpriteFrameName("LineCross.png")
    verticalLine:setScaleX(totalH/verticalLine:getContentSize().width)
    verticalLine:setRotation(90)
    verticalLine:setPosition(ccp(leftW ,totalH/2 + rewardBtnH))
    cell:addChild(verticalLine,2)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acTotalRecharge2Dialog:getReward()
  if acTotalRecharge2VoApi:canReward() == true then
    local function getRawardCallback(fn,data)
      if base:checkServerData(data)==true then
          if self==nil or self.tv==nil then
              do return end
          end
          local currentCanGetReward,index = acTotalRecharge2VoApi:getCurrentCanGetReward()
          local reward = FormatItem(currentCanGetReward, true)
          for k,v in pairs(reward) do
            G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num), nil, true)
          end
          G_showRewardTip(reward,true)

          acTotalRecharge2VoApi:afterGetReward(index)
          
          -- 刷新tv后tv仍然停留在当前位置
          local recordPoint = self.tv:getRecordPoint()
          self.tv:reloadData()
          self.tv:recoverToRecordPoint(recordPoint)
          
      end
    end
    socketHelper:getTotalRecharge2Reward(getRawardCallback)
  end
end

function acTotalRecharge2Dialog:getAwardStr(reward)
  local awardTab = reward
  local str = getlocal("daily_lotto_tip_10")
  if awardTab then
    for k,v in pairs(awardTab) do
      if k==SizeOfTable(awardTab) then
        str = str .. v.name .. "x" .. v.num
      else
        str = str .. v.name .. "x" .. v.num .. ","
      end
    end
  end
  return str
end


function acTotalRecharge2Dialog:initNeedMoney(id)
  local needMoney = acTotalRecharge2VoApi:getNeedMoneyById(id)
  local needMoneyLabel=GetTTFLabel(tostring(needMoney),28)
  needMoneyLabel:setColor(G_ColorGreen)
  return needMoneyLabel
end

function acTotalRecharge2Dialog:doUserHandler()
  local function cellClick(hd,fn,index)
  end
  
  local w = G_VisibleSizeWidth - 20 -- 背景框的宽度
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
  backSprie:setContentSize(CCSizeMake(w, 200))
  backSprie:setAnchorPoint(ccp(0,0))
  backSprie:setPosition(ccp(10, G_VisibleSizeHeight - 290))
  self.bgLayer:addChild(backSprie)
  
  
  
  local function touch(tag,object)
    self:openInfo()
  end

  w = w - 10 -- 按钮的x坐标
  local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,0.5))
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(w, 50))
  backSprie:addChild(menuDesc)
  
  w = w - menuItemDesc:getContentSize().width

  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 190))
  backSprie:addChild(acLabel)

  local acVo = acTotalRecharge2VoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,28)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 150))
  backSprie:addChild(messageLabel)
  self.timeLb=messageLabel
  G_updateActiveTime(acVo,self.timeLb)


   local desLabel = GetTTFLabelWrap(getlocal("activity_totalRecharge_des"),23,CCSizeMake(w, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  desLabel:setAnchorPoint(ccp(0,0.5))
  desLabel:setPosition(ccp(10, 80))
  backSprie:addChild(desLabel)


  local rechargeLabel = GetTTFLabel(getlocal("activity_totalRecharge_totalMoney"),28)
  rechargeLabel:setAnchorPoint(ccp(0,0))
  rechargeLabel:setPosition(ccp(10, 10))
  backSprie:addChild(rechargeLabel)
  
  self.moneyX = 20 + rechargeLabel:getContentSize().width
  self.totalMoneyLabel = GetTTFLabel(tostring(acTotalRecharge2VoApi:getTotalMoney()), 30)
  self.totalMoneyLabel:setAnchorPoint(ccp(0,0))
  self.totalMoneyLabel:setPosition(ccp(self.moneyX, 10))
  self.totalMoneyLabel:setColor(G_ColorYellowPro)
  backSprie:addChild(self.totalMoneyLabel)

  self.goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
  self.goldIcon:setAnchorPoint(ccp(0,0))
  self.goldIcon:setPosition(ccp(self.moneyX + self.totalMoneyLabel:getContentSize().width + 20,10))
  backSprie:addChild(self.goldIcon)

 
  local totalW = G_VisibleSizeWidth - 20

  local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),cellClick)
  backSprie2:setContentSize(CCSizeMake(totalW, 40))
  backSprie2:setAnchorPoint(ccp(0.5,0.5))
  backSprie2:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 320))
  self.bgLayer:addChild(backSprie2)

  local goldLabel=GetTTFLabel(getlocal("gem"),28)
  goldLabel:setPosition(ccp(100 ,20))
  goldLabel:setColor(G_ColorGreen)
  backSprie2:addChild(goldLabel)

  local rewardLabel=GetTTFLabel(getlocal("award"),28)
  rewardLabel:setPosition(ccp(totalW - 180,20))
  rewardLabel:setColor(G_ColorGreen)
  backSprie2:addChild(rewardLabel)  


  local function rewardHandler(tag,object)
      PlayEffect(audioCfg.mouseClick)
      self:getReward()
    end

    self.rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardHandler,0,getlocal("daily_scene_get"),28)
    self.rewardBtn:setAnchorPoint(ccp(0.5, 0))
    local menuAward=CCMenu:createWithItem(self.rewardBtn)
    menuAward:setPosition(ccp(G_VisibleSizeWidth/2,20))
    menuAward:setTouchPriority(-(self.layerNum-1)*20-4)
    if acTotalRecharge2VoApi:canReward() == true then
      self.rewardBtn:setEnabled(true)
    else
      self.rewardBtn:setEnabled(false)
    end  

    self.bgLayer:addChild(menuAward,1) 
end

-- 更新今日充值金额
function acTotalRecharge2Dialog:updatetotalMoneyLabel()
  if self == nil then
    do 
     return
    end
  end

  if self.totalMoneyLabel ~= nil then
    self.totalMoneyLabel:setString(tostring(acTotalRecharge2VoApi:getTotalMoney()))
    if self.moneyX ~= nil and self.goldIcon ~= nil then
      self.goldIcon:setPosition(ccp(self.moneyX + self.totalMoneyLabel:getContentSize().width + 20,10))
    end
  end
  if self.rewardBtn ~= nil then
    if acTotalRecharge2VoApi:canReward() == true then
      self.rewardBtn:setEnabled(true)
    else
      self.rewardBtn:setEnabled(false)
    end
  end

end

function acTotalRecharge2Dialog:openInfo()
  local td=smallDialog:new()
  local tabStr = {"\n",getlocal("activity_totalRecharge_detail3"),"\n",getlocal("activity_totalRecharge_detail2"),"\n", getlocal("activity_totalRecharge_detail1"),"\n"}
  local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acTotalRecharge2Dialog:tick()
  if self.timeLb then
    local acVo = acTotalRecharge2VoApi:getAcVo()
    G_updateActiveTime(acVo,self.timeLb)
  end
end

function acTotalRecharge2Dialog:update()
  local acVo = acTotalRecharge2VoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      self:updatetotalMoneyLabel()
      local recordPoint = self.tv:getRecordPoint()
      self.tv:reloadData()
      self.tv:recoverToRecordPoint(recordPoint)
    end
  end
end

function acTotalRecharge2Dialog:dispose()
  self.totalMoneyLabel = nil
  self.goldIcon = nil
  self.moneyX = nil
  self.rewardBtn = nil
  self.timeLb = nil
  self=nil
end





