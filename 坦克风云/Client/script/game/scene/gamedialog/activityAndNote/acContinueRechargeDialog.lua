acContinueRechargeDialog=commonDialog:new()

function acContinueRechargeDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.rewardBtn = nil
    self.currentDay = nil -- 当前是第几天
    return nc
end

function acContinueRechargeDialog:initTableView()
  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 425))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 100))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 450),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,110))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(20)

end

function acContinueRechargeDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(G_VisibleSizeWidth - 20,100 * acContinueRechargeVoApi:getTotalDays())
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local barH = 100

    local totalH = barH * acContinueRechargeVoApi:getTotalDays()-- 总高度

    local totalW = G_VisibleSizeWidth - 20
    local leftW = totalW * 0.2
    local rightW = totalW * 0.8

    local per = 0
    local perWidth = 0
    local addContinue = true
    local days = acContinueRechargeVoApi:getTotalDays()
    local need=acContinueRechargeVoApi:getNeedMoneyByDay()
    if days > 0 then
        for i=1,days do

          local h = barH * (days - i) -- 每条奖励信息的y坐标起始位置
          local titleH = h+barH - 25 
          local titleW = leftW + 10
          print("self.currentDay: ",self.currentDay)
          if i == self.currentDay then
            local function nilFunc(hd,fn,idx)
            end

            local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(20, 20, 10, 10),nilFunc)
            titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,barH))
            titleBg:setScaleX((G_VisibleSizeWidth - 20)/titleBg:getContentSize().width)
            titleBg:setAnchorPoint(ccp(0.5,0.5))
            titleBg:setPosition(ccp((G_VisibleSizeWidth - 20)/2,h + barH/2))
            cell:addChild(titleBg)
          end

          local rechargeLabel = GetTTFLabelWrap(getlocal("activity_continueRecharge_dayRecharge"),25,CCSizeMake(200, 0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
          rechargeLabel:setAnchorPoint(ccp(0,0.5))
          rechargeLabel:setPosition(ccp(titleW,titleH))
          cell:addChild(rechargeLabel)
          
          titleW = titleW + rechargeLabel:getContentSize().width
          local had=acContinueRechargeVoApi:getRechargeByDay(i)
          local showHad = nil
          if had > need then
            showHad = need
          else
            showHad = had
          end

          local moneyLabel = GetTTFLabel(tostring(showHad),30)
          moneyLabel:setAnchorPoint(ccp(0,0.5))
          moneyLabel:setPosition(ccp(titleW, titleH))
          moneyLabel:setColor(G_ColorYellowPro)
          cell:addChild(moneyLabel)
          
          titleW = titleW + moneyLabel:getContentSize().width
          local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
          iconGold:setAnchorPoint(ccp(0,0.5))
          iconGold:setPosition(ccp(titleW,titleH))
          cell:addChild(iconGold)

          -- 充值进度条
          AddProgramTimer(cell,ccp(leftW + 160,h+25),i,nil,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",11,0.7)
          local timerSprite = tolua.cast(cell:getChildByTag(i),"CCProgressTimer")
          local percentage=0
          
          percentage=had/need
          if percentage<0 then
            percentage=0
          end
          if percentage>1 then
            percentage=1
          end
          timerSprite:setPercentage(percentage*100)
          
          if had < need then
            local day = acContinueRechargeVoApi:getCurrentDay() -- 当前是第几天
            if i < day then 
              local function touch(tag,object)
                PlayEffect(audioCfg.mouseClick)
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                  if G_checkClickEnable()==false then
                      do
                          return
                      end
                  else
                      base.setWaitTime=G_getCurDeviceMillTime()
                  end
                  self:revisePanel(i)
                end
              end

              local menuItemDesc=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touch,0,getlocal("addSignBtn"),28)
              menuItemDesc:setAnchorPoint(ccp(0.5,0.5))
              menuItemDesc:setScale(0.8)
              local menuDesc=CCMenu:createWithItem(menuItemDesc)
              menuDesc:setTouchPriority(-(self.layerNum-1)*20-2)
              menuDesc:setPosition(ccp(totalW - 95, h+barH/2))
              cell:addChild(menuDesc)
            end

          else
            local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
            rightIcon:setAnchorPoint(ccp(0.5,0.5))
            rightIcon:setPosition(ccp(totalW - 95,h+barH/2))
            cell:addChild(rightIcon,1)
          end

          local dayLabel = GetTTFLabelWrap(getlocal("activity_continueRecharge_dayDes",{i}),30,CCSizeMake(leftW, 0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
          dayLabel:setAnchorPoint(ccp(1,0.5))
          dayLabel:setPosition(ccp(leftW-10,h+barH/2))
          dayLabel:setColor(G_ColorGreen)
          cell:addChild(dayLabel)
          

          local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
          lineSprite:setScaleX((totalW + 50)/lineSprite:getContentSize().width)
          lineSprite:setPosition(ccp(totalW/2,h + barH))
          cell:addChild(lineSprite,5)
          if i == days then
            local lineSprite2 = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSprite2:setScaleX((totalW + 50)/lineSprite:getContentSize().width)
            lineSprite2:setPosition(ccp(totalW/2,h))
            cell:addChild(lineSprite2,5)
          end

        end
    end
    local verticalLine = CCSprite:createWithSpriteFrameName("LineCross.png")
    verticalLine:setScaleX((totalH + 100)/verticalLine:getContentSize().width)
    verticalLine:setRotation(90)
    verticalLine:setPosition(ccp(leftW ,totalH/2))
    cell:addChild(verticalLine)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acContinueRechargeDialog:getReward()
  if acContinueRechargeVoApi:canReward() == true then
    local function getRawardCallback(fn,data)
      if base:checkServerData(data)==true then
          if self==nil or self.tv==nil then
              do return end
          end
          local id,num = acContinueRechargeVoApi:getBigReward()
          local bigRe = {p={{index = 1}}}
          bigRe.p[1][id] = num
          local reward = FormatItem(bigRe, true)
          for k,v in pairs(reward) do
            G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
          end
          G_showRewardTip(reward,true)

          acContinueRechargeVoApi:afterGetReward()
      end
    end
    socketHelper:getContinueRechargeReward(getRawardCallback)
  end
end

function acContinueRechargeDialog:iconFlicker(icon)
  local m_iconScaleX,m_iconScaleY=1.4,1.4
  local pzFrameName="RotatingEffect1.png"
  local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
  local pzArr=CCArray:create()
  for kk=1,20 do
      local nameStr="RotatingEffect"..kk..".png"
      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
      pzArr:addObject(frame)
  end
  local animation=CCAnimation:createWithSpriteFrames(pzArr)
  animation:setDelayPerUnit(0.1)
  local animate=CCAnimate:create(animation)
  metalSp:setAnchorPoint(ccp(0.5,0.5))
  if m_iconScaleX~=nil then
    metalSp:setScaleX(m_iconScaleX)
  end
  if m_iconScaleY~=nil then
    metalSp:setScaleY(m_iconScaleY)
  end
  metalSp:setPosition(getCenterPoint(icon))
  icon:addChild(metalSp)
  local repeatForever=CCRepeatForever:create(animate)
  metalSp:runAction(repeatForever)
end


function acContinueRechargeDialog:doUserHandler()
  self.currentDay = acContinueRechargeVoApi:getCurrentDay()

  local function cellClick(hd,fn,index)
  end
  
  local w = G_VisibleSizeWidth - 20 -- 背景框的宽度
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
  backSprie:setContentSize(CCSizeMake(w, 240))
  backSprie:setAnchorPoint(ccp(0,0))
  backSprie:setPosition(ccp(10, G_VisibleSizeHeight - 325))
  self.bgLayer:addChild(backSprie)
  
  
  
  local function touch(tag,object)
    PlayEffect(audioCfg.mouseClick)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    self:openInfo()
  end

  w = w - 10 -- 按钮的x坐标
  local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,1))
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(w, 220))
  backSprie:addChild(menuDesc)
  
  w = w - menuItemDesc:getContentSize().width

  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
  acLabel:setColor(G_ColorGreen)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 220))
  backSprie:addChild(acLabel)

  local acVo = acContinueRechargeVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,28)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 170))
  backSprie:addChild(messageLabel)
  
  local pid = acContinueRechargeVoApi:getBigReward()
  if pid ~= nil then
    local pcf = propCfg[pid]
    if pcf ~= nil then
      local function showInfoHandler(hd,fn,idx)
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local item={name=getlocal(pcf.name), desc=pcf.description, pic = pcf.icon}
        propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
      end

      local reIcon = LuaCCSprite:createWithSpriteFrameName(pcf.icon,showInfoHandler)
      reIcon:setTouchPriority(-(self.layerNum-1)*20-5)
      -- local scale=(100/tankIcon:getContentSize().width)
      -- reIcon:setScale(scale)
      reIcon:setAnchorPoint(ccp(0,0.5))
      reIcon:setPosition(ccp(20,75))
      backSprie:addChild(reIcon,1)
      self:iconFlicker(reIcon)
    end
  end

  w = w - 130 + menuItemDesc:getContentSize().width
  local lbStr = nil
  local ver = acContinueRechargeVoApi:getVersion()
  if ver==nil or ver==1 then
    lbStr = "activity_continueRecharge_des"
  else
    lbStr = "activity_continueRecharge_desB"
  end
  local desTv, desLabel = G_LabelTableView(CCSizeMake(w, 120),getlocal(lbStr,{acContinueRechargeVoApi:getTotalDays(),acContinueRechargeVoApi:getNeedMoneyByDay(),acContinueRechargeVoApi:getBigRewardValue()}),25)

  backSprie:addChild(desTv)
  desTv:setPosition(ccp(130,10))
  desTv:setAnchorPoint(ccp(0,0))
  backSprie:setTouchPriority(-(self.layerNum-1) * 20 - 4)
  desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
  desTv:setMaxDisToBottomOrTop(100)

  local function rewardHandler(tag,object)
    PlayEffect(audioCfg.mouseClick)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    self:getReward()
  end

  self.rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler,0,getlocal("activity_continueRecharge_reward"),28)
  self.rewardBtn:setAnchorPoint(ccp(0, 0))
  local menuAward=CCMenu:createWithItem(self.rewardBtn)
  menuAward:setPosition(ccp(G_VisibleSizeWidth/2 + 30,20))
  menuAward:setTouchPriority(-(self.layerNum-1)*20-4)
  if acContinueRechargeVoApi:canReward() == true then
    self.rewardBtn:setEnabled(true)
  else
    self.rewardBtn:setEnabled(false)
  end  

  self.bgLayer:addChild(menuAward,1) 


  local function onConfirmRecharge()
    PlayEffect(audioCfg.mouseClick)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    activityAndNoteDialog:closeAllDialog()
    vipVoApi:showRechargeDialog(self.layerNum+1)
  end
  local rechargeItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onConfirmRecharge,0,getlocal("recharge"),28)
  rechargeItem:setAnchorPoint(ccp(1,0))
  local rechargeBtn=CCMenu:createWithItem(rechargeItem)
  rechargeBtn:setTouchPriority(-(self.layerNum-1)*20-5)
  rechargeBtn:setPosition(ccp(G_VisibleSizeWidth/2 - 30,20))
  self.bgLayer:addChild(rechargeBtn)

end

-- 更新今日充值金额
function acContinueRechargeDialog:updateTodayMoneyLabel()
  if self == nil then
    do 
     return
    end
  end

  if self.rewardBtn ~= nil then
    if acContinueRechargeVoApi:canReward() == true then
      self.rewardBtn:setEnabled(true)
    else
      self.rewardBtn:setEnabled(false)
    end
  end

end
function acContinueRechargeDialog:revisePanel(day)
  local needGems = acContinueRechargeVoApi:getReviseNeedMoneyByDay()
  if needGems>playerVoApi:getGems() then
    GemsNotEnoughDialog(nil,nil,needGems-playerVoApi:getGems(),self.layerNum+1,needGems)
  else
    local function usePropHandler(tag1,object)
        PlayEffect(audioCfg.mouseClick)
        local function reviseSuccess(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                playerVoApi:setValue("gems",playerVoApi:getGems()-needGems)
                acContinueRechargeVoApi:updateState()
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_continueRecharge_reviseSuc"),28)
            end
        end

        socketHelper:continueRechargeRevise(day,reviseSuccess)
    end
    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),usePropHandler,getlocal("dialog_title_prompt"),getlocal("activity_continueRecharge_revise",{day,acContinueRechargeVoApi:getReviseNeedMoneyByDay(day)}),nil,self.layerNum+1)
  end
end

function acContinueRechargeDialog:openInfo()
  local td=smallDialog:new()
  local totalDay = acContinueRechargeVoApi:getTotalDays()
  local tabStr = {"\n",getlocal("activity_continueRecharge_rule3",{totalDay}),"\n",getlocal("activity_continueRecharge_rule2"),"\n", getlocal("activity_continueRecharge_rule1",{totalDay}),"\n"}
  local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acContinueRechargeDialog:tick()
  local day = acContinueRechargeVoApi:getCurrentDay()
  if self.currentDay ~= day then
    print("当前是第"..day.."天"..self.currentDay)
    self.currentDay = day
    self:update()
  end
end

function acContinueRechargeDialog:update()
  local acVo = acContinueRechargeVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      self:updateTodayMoneyLabel()
      local recordPoint = self.tv:getRecordPoint()
      self.tv:reloadData()
      self.tv:recoverToRecordPoint(recordPoint)
    end
  end
end

function acContinueRechargeDialog:dispose()
  self.rewardBtn = nil
  self.currentDay = nil
  self=nil
end





