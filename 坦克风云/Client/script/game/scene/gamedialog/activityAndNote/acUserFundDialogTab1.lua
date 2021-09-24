acUserFundDialogTab1=commonDialog:new()

function acUserFundDialogTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.todayMoneyLabel = nil
    self.rewardBtn = nil
    return nc
end

function acUserFundDialogTab1:init(layerNum,selectedTabIndex,parentDialog)
  self.bgLayer=CCLayer:create()
  self.layerNum=layerNum
  self.selectedTabIndex=selectedTabIndex
  self.parentDialog=parentDialog
  self.tvWidth=G_VisibleSizeWidth - 40
  local acCfg = acUserFundVoApi:getAcCfg()
  if acCfg and acCfg.reward and SizeOfTable(acCfg.reward)>0 then
      self:initTableView()
      self:doUserHandler()
  end
  return self.bgLayer
end

function acUserFundDialogTab1:initTableView()
  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  -- self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  -- self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 395))
  -- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 100))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,G_VisibleSizeHeight - 460 - 30),nil)
  self.bgLayer:addChild(self.tv,1)
  self.tv:setPosition(ccp(10,110))
  self.tv:setAnchorPoint(ccp(0,0))
  -- self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)

  local acCfg = acUserFundVoApi:getAcCfg()
  if acCfg ~= nil and acCfg.reward ~= nil then
      if 120 * SizeOfTable(acCfg.reward) + 20 > G_VisibleSizeHeight - 460 then
          local recordPoint = self.tv:getRecordPoint()
          recordPoint.y = 0
          self.tv:recoverToRecordPoint(recordPoint)
      end
  end

end

function acUserFundDialogTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local acCfg = acUserFundVoApi:getAcCfg()
    if acCfg ~= nil and acCfg.reward ~= nil then
      return  CCSizeMake(self.tvWidth,120 * SizeOfTable(acCfg.reward) + 20)
    end
    return  CCSizeMake(self.tvWidth,120)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local rewardLabelH = 20
    local rewardBtnH = 0
    local barH = 120

    local totalH  -- 总高度

    local acCfg = acUserFundVoApi:getAcCfg()
    if acCfg ~= nil and acCfg.reward ~= nil then
      totalH = barH * SizeOfTable(acCfg.reward)
    else
      totalH = barH
    end

    local totalW = self.tvWidth
    local leftW = totalW * 0.3
    local rightW = totalW * 0.7
     
    
    local todayMoney = acUserFundVoApi:getTodayMoney()


    local per = 0
    local perWidth = 0
    local addContinue = true
    if acCfg ~= nil and acCfg.reward ~= nil then
      local rewardLen = SizeOfTable(acCfg.reward)
      if rewardLen ~= nil and rewardLen > 0 then
          for i=1,rewardLen do

            local h = barH * (rewardLen - i) + rewardBtnH -- 每条奖励信息的y坐标起始位置

            local award=FormatItem(acUserFundVoApi:getRewardById(rewardLen - i + 1),true)

            local function showInfoHandler(hd,fn,index)
              if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                local item=award[index]
                if item.type=="e" then
                  if item.eType=="a" or item.eType=="f" then
                    local isAccOrFrag=true
                    propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,isAccOrFrag)
                  else
                    propInfoDialog:create(sceneGame,item,self.layerNum+1)
                  end
                elseif item and item.name then
                  propInfoDialog:create(sceneGame,item,self.layerNum+1)
                end
              end
            end
            
            if award ~= nil then
               for k,v in pairs(award) do
                local icon
                local pic=v.pic
                local iconScaleX=1
                local iconScaleY=1
                if v.type=="e" then
                  if v.eType=="a" then
                    icon=accessoryVoApi:getAccessoryIcon(v.id,60,80,showInfoHandler)
                  elseif v.eType=="f" then
                    icon=accessoryVoApi:getFragmentIcon(v.id,60,80,showInfoHandler)
                    iconScaleX=0.8
                    iconScaleY=0.8
                  elseif v.eType=="p" then
                    icon=GetBgIcon(pic,showInfoHandler,nil,80,80)
                  end
                elseif v.type=="p" and v.equipId then
                  local eType=string.sub(v.equipId,1,1)
                  if eType=="a" then
                      icon=accessoryVoApi:getAccessoryIcon(v.equipId,60,80,showInfoHandler)
                  elseif eType=="f" then
                      icon=accessoryVoApi:getFragmentIcon(v.equipId,60,80,showInfoHandler)
                  else
                      icon=GetBgIcon(pic,showInfoHandler,nil,80,80)
                  end
                else
                  icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
                  if icon:getContentSize().width>100 then
                    iconScaleX=0.8*100/150
                    iconScaleY=0.8*100/150
                  else
                    iconScaleX=0.8
                    iconScaleY=0.8
                  end
                  icon:setScaleX(iconScaleX)
                  icon:setScaleY(iconScaleY)
                end
                icon:ignoreAnchorPointForPosition(false)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(ccp(10+(k-1)*85 + leftW ,h+barH/2))
                icon:setIsSallow(false)
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(icon,1)
                icon:setTag(k)

                if tostring(v.name)~=getlocal("honor") then
                  if v.type=="p" and v.key=="p30" then
                  else
                    local numLabel=GetTTFLabel("x"..v.num,25)
                    numLabel:setAnchorPoint(ccp(1,0))
                    numLabel:setPosition(icon:getContentSize().width-10,0)
                    icon:addChild(numLabel,1)
                    numLabel:setScaleX(1/iconScaleX)
                    numLabel:setScaleY(1/iconScaleY)
                  end
                end
              end
            end
            

            local canReward = acUserFundVoApi:checkIfCanRewardById(rewardLen - i + 1)
            if canReward == true then
              local hadReward = acUserFundVoApi:checkIfHadRewardById(rewardLen - i + 1)
              if hadReward == true then 
                local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
                rightIcon:setAnchorPoint(ccp(0.5,0.5))
                rightIcon:setPosition(ccp(totalW - 120,h+barH/2))
                cell:addChild(rightIcon,1)
              else
                local rewardLabel = GetTTFLabel(getlocal("canReward"),28)
                rewardLabel:setAnchorPoint(ccp(0.5,0.5))
                rewardLabel:setPosition(ccp(totalW - 120,h+barH/2))
                rewardLabel:setColor(G_ColorGreen)
                cell:addChild(rewardLabel,1)
                end

            else
              local noLabel = GetTTFLabelWrap(getlocal("activity_dayRecharge_no"),28,CCSizeMake(28*7,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
              noLabel:setAnchorPoint(ccp(0.5,0.5))
              noLabel:setPosition(ccp(totalW - 120,h+barH/2))
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
        local money = acUserFundVoApi:getNeedMoneyById(j) -- 当前需要的金币
        if addContinue == true then
          if tonumber(todayMoney) >= tonumber(money) then
            perWidth = perWidth + barH
          else
            local lastMoney
            if j == 1 then
              lastMoney = 0
            else
              lastMoney = acUserFundVoApi:getNeedMoneyById(j - 1)
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

function acUserFundDialogTab1:getReward()
  if acUserFundVoApi:canRewardRecharge() == true then
    local function getRawardCallback(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
          if self==nil or self.tv==nil then
              do return end
          end
          local currentCanGetReward,index = acUserFundVoApi:getCurrentCanGetReward()
          local reward = FormatItem(currentCanGetReward, true)
          for k,v in pairs(reward) do
            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
          end
          G_showRewardTip(reward,true)

          acUserFundVoApi:afterGetReward()
          
          -- 刷新tv后tv仍然停留在当前位置
          local recordPoint = self.tv:getRecordPoint()
          self.tv:reloadData()
          self.tv:recoverToRecordPoint(recordPoint)

          if self.rewardBtn then
            if acUserFundVoApi:canRewardRecharge() == true then
              self.rewardBtn:setEnabled(true)
            else
              self.rewardBtn:setEnabled(false)
            end
          end
      end
    end
    -- socketHelper:getDayRechargeReward(getRawardCallback)
    socketHelper:activeUserfund(getRawardCallback)
  end
end

function acUserFundDialogTab1:getAwardStr(reward)
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


function acUserFundDialogTab1:initNeedMoney(id)
  local needMoney = acUserFundVoApi:getNeedMoneyById(id)
  local needMoneyLabel=GetTTFLabel(tostring(needMoney),28)
  needMoneyLabel:setColor(G_ColorGreen)
  return needMoneyLabel
end

function acUserFundDialogTab1:doUserHandler()
  local function cellClick(hd,fn,index)
  end
  
  local w = self.tvWidth -- 背景框的宽度
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
  backSprie:setContentSize(CCSizeMake(w, 150))
  backSprie:setAnchorPoint(ccp(0,0))
  backSprie:setPosition(ccp(20, G_VisibleSizeHeight - 290 - 25))
  self.bgLayer:addChild(backSprie)


  local function callBack(...)
       return self:eventHandler1(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.descTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,backSprie:getContentSize().height-10),nil)
  backSprie:addChild(self.descTv,1)
  self.descTv:setPosition(ccp(0,5))
  self.descTv:setAnchorPoint(ccp(0,0))
  if self.descHeight and self.descHeight+10<backSprie:getContentSize().height-10 then
      self.descTv:setAnchorPoint(ccp(0,(backSprie:getContentSize().height-self.descHeight-20)/2))
  end
  self.descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
  self.descTv:setMaxDisToBottomOrTop(50)


  -- local rechargeLabel = GetTTFLabel(getlocal("activity_dayRecharge_todayMoney"),28)
  -- rechargeLabel:setAnchorPoint(ccp(0,0))
  -- rechargeLabel:setPosition(ccp(10, 10))
  -- backSprie:addChild(rechargeLabel)

  -- self.todayMoneyLabel = GetTTFLabel(tostring(acUserFundVoApi:getTodayMoney()), 30)
  -- self.todayMoneyLabel:setAnchorPoint(ccp(0,0))
  -- self.todayMoneyLabel:setPosition(ccp(20 + rechargeLabel:getContentSize().width, 10))
  -- self.todayMoneyLabel:setColor(G_ColorYellowPro)
  -- backSprie:addChild(self.todayMoneyLabel)
 
  local totalW = self.tvWidth

  local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),cellClick)
  backSprie2:setContentSize(CCSizeMake(totalW, 40))
  backSprie2:setAnchorPoint(ccp(0.5,0.5))
  backSprie2:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 320 -30))
  self.bgLayer:addChild(backSprie2)

  local goldLabel=GetTTFLabel(getlocal("gem"),25)
  goldLabel:setPosition(ccp(100 ,20))
  goldLabel:setColor(G_ColorGreen)
  backSprie2:addChild(goldLabel)

  local rewardLabel=GetTTFLabel(getlocal("award"),25)
  rewardLabel:setPosition(ccp(totalW - 180,20))
  rewardLabel:setColor(G_ColorGreen)
  backSprie2:addChild(rewardLabel)  


  local function rewardHandler(tag,object)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)
    self:getReward()
  end
  self.rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardHandler,0,getlocal("daily_scene_get"),28)
  self.rewardBtn:setAnchorPoint(ccp(0.5, 0)) 
  local menuAward=CCMenu:createWithItem(self.rewardBtn)
  menuAward:setPosition(ccp(G_VisibleSizeWidth/2-150,30))
  menuAward:setTouchPriority(-(self.layerNum-1)*20-4)
  if acUserFundVoApi:canRewardRecharge() == true then
    self.rewardBtn:setEnabled(true)
  else
    self.rewardBtn:setEnabled(false)
  end  

  self.bgLayer:addChild(menuAward,1) 

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
  rechargeMenu:setPosition(ccp(G_VisibleSizeWidth/2+150,30))
  rechargeMenu:setTouchPriority(-(self.layerNum-1)*20-4) 

  self.bgLayer:addChild(rechargeMenu,1) 

  local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
  if ifInRechargeDay==true then
      self.rechargeBtn:setEnabled(true)
  else
      self.rechargeBtn:setEnabled(false)
  end

end

function acUserFundDialogTab1:eventHandler1(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    if self.descHeight==nil then
        local w = self.tvWidth -- 背景框的宽度
        local hSpace=55
        w = w - 10 -- 按钮的x坐标
        local function touch(tag,object)
        end
        local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
        
        local acVo = acUserFundVoApi:getAcVo()
        -- local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeStr=acUserFundVoApi:getTimeStr()
        local messageLabel=GetTTFLabel(timeStr,25)
        -- local acLabel = GetTTFLabelWrap(getlocal("activity_timeLabel"),25,CCSizeMake(w-100, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- local desLabel = GetTTFLabelWrap(getlocal("activity_userFund_desc_1"),22,CCSizeMake(w-80, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        local acLabel
        local desLabel
        local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
        if ifInRechargeDay==true then
            acLabel = GetTTFLabelWrap(getlocal("activity_userFund_pert_1"),25,CCSizeMake(w-100, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            desLabel = GetTTFLabelWrap(getlocal("activity_userFund_desc_1_1"),22,CCSizeMake(w-90, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        else
            acLabel = GetTTFLabelWrap(getlocal("activity_userFund_pert_2"),25,CCSizeMake(w-100, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            desLabel = GetTTFLabelWrap(getlocal("activity_userFund_desc_1_2"),22,CCSizeMake(w-90, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        end

        if self.descHeight==nil then
            self.descHeight=acLabel:getContentSize().height+messageLabel:getContentSize().height+desLabel:getContentSize().height+50
            if self.descHeight<acLabel:getContentSize().height+messageLabel:getContentSize().height+menuItemDesc:getContentSize().height+20 then
                self.descHeight=acLabel:getContentSize().height+messageLabel:getContentSize().height+menuItemDesc:getContentSize().height+50
            end
        end
    end
    return  CCSizeMake(self.tvWidth,self.descHeight)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local w = self.tvWidth -- 背景框的宽度

    local hSpace=55
    w = w - 10 -- 按钮的x坐标

    local function touch(tag,object)
      if self.descTv and self.descTv:getScrollEnable()==true and self.descTv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self:openInfo()
      end
    end
    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    
    local acVo = acUserFundVoApi:getAcVo()
    -- local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeStr=acUserFundVoApi:getTimeStr()
    self.timeLb=GetTTFLabel(timeStr,25)
    -- self.acLabel = GetTTFLabelWrap(getlocal("activity_timeLabel"),25,CCSizeMake(w-100, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- self.desLb = GetTTFLabelWrap(getlocal("activity_userFund_desc_1"),22,CCSizeMake(w-80, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
    if ifInRechargeDay==true then
        self.acLabel = GetTTFLabelWrap(getlocal("activity_userFund_pert_1"),25,CCSizeMake(w-100, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.desLb = GetTTFLabelWrap(getlocal("activity_userFund_desc_1_1"),22,CCSizeMake(w-90, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    else
        self.acLabel = GetTTFLabelWrap(getlocal("activity_userFund_pert_2"),25,CCSizeMake(w-100, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.desLb = GetTTFLabelWrap(getlocal("activity_userFund_desc_1_2"),22,CCSizeMake(w-90, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    end
    if self.descHeight==nil then
        self.descHeight=self.acLabel:getContentSize().height+self.timeLb:getContentSize().height+self.desLb:getContentSize().height+50
        if self.descHeight<self.acLabel:getContentSize().height+self.timeLb:getContentSize().height+menuItemDesc:getContentSize().height+20 then
            self.descHeight=self.acLabel:getContentSize().height+self.timeLb:getContentSize().height+menuItemDesc:getContentSize().height+50
        end
    end

    local cellHeight=self.descHeight

    w = w - menuItemDesc:getContentSize().width

    self.acLabel:setAnchorPoint(ccp(0.5,1))
    self.acLabel:setPosition(ccp((self.tvWidth)/2, cellHeight-5))
    cell:addChild(self.acLabel)

    self.timeLb:setAnchorPoint(ccp(0.5,1))
    self.timeLb:setPosition(ccp((self.tvWidth)/2, cellHeight-self.acLabel:getContentSize().height-10))
    cell:addChild(self.timeLb)


    menuItemDesc:setAnchorPoint(ccp(0.5,0.5))
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(self.tvWidth-menuItemDesc:getContentSize().width/2-10, cellHeight-self.acLabel:getContentSize().height-self.timeLb:getContentSize().height-10))
    cell:addChild(menuDesc)

    self.desLb:setAnchorPoint(ccp(0,1))
    self.desLb:setPosition(ccp(10, cellHeight-self.acLabel:getContentSize().height-self.timeLb:getContentSize().height-10))
    cell:addChild(self.desLb)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end

end

-- 更新今日充值金额
-- function acUserFundDialogTab1:updateTodayMoneyLabel()
--   if self == nil then
--     do 
--      return
--     end
--   end

--   if self.todayMoneyLabel ~= nil then
--     self.todayMoneyLabel:setString(tostring(acUserFundVoApi:getTodayMoney()))
--   end
--   if self.rewardBtn ~= nil then
--     if acUserFundVoApi:canRewardRecharge() == true then
--       self.rewardBtn:setEnabled(true)
--     else
--       self.rewardBtn:setEnabled(false)
--     end
--   end

-- end

function acUserFundDialogTab1:openInfo()
  local chargeDays,rewardDays,totalDays=acUserFundVoApi:getAcDays()
  local sampleNum,costNum=acUserFundVoApi:getSampleNum()
  local td=smallDialog:new()
  local tabStr = {"\n",getlocal("activity_userFund_tip_5"),"\n",getlocal("activity_userFund_tip_4"),"\n",getlocal("activity_userFund_tip_3",{rewardDays}),"\n",getlocal("activity_userFund_tip_2",{sampleNum,costNum}),"\n",getlocal("activity_userFund_tip_1",{chargeDays}),"\n"}
  local colorTab = {nil,G_ColorRed,nil,G_ColorWhite,nil,G_ColorWhite,nil,G_ColorWhite,nil,G_ColorWhite,nil}
  local dialog=td:init("PanelPopup.png",CCSizeMake(600,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTab,nil,true)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acUserFundDialogTab1:tick()
    local ifInRechargeDay,ifInRewardDay=acUserFundVoApi:getIfInDays()
    local chargeDays,rewardDays,totalDays,leftDays=acUserFundVoApi:getAcDays()
    if self.timeLb then
        local timeStr=acUserFundVoApi:getTimeStr()
        self.timeLb:setString(timeStr)
    end
    if ifInRechargeDay==true then
        if self.rechargeBtn then
            self.rechargeBtn:setEnabled(true)
        end
        if self.acLabel then
            self.acLabel:setString(getlocal("activity_userFund_pert_1"))
        end
        if self.desLb then
            self.desLb:setString(getlocal("activity_userFund_desc_1_1"))
        end
    else
        if self.rechargeBtn then
            self.rechargeBtn:setEnabled(false)
        end
        if ifInRewardDay==true then
            if self.acLabel then
                self.acLabel:setString(getlocal("activity_userFund_pert_2"))
            end
            if self.desLb then
                self.desLb:setString(getlocal("activity_userFund_desc_1_2"))
            end
        end
    end

end

function acUserFundDialogTab1:refresh()
  
end

-- function acUserFundDialogTab1:update()
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

function acUserFundDialogTab1:dispose()
  self.todayMoneyLabel = nil
  self.rewardBtn = nil
end





