acContinueRechargeNewGuidDialog=commonDialog:new()

function acContinueRechargeNewGuidDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.rewardBtn = nil
    self.currentDay = nil -- 当前是第几天
    self.rechargeLabel = nil
    self.bigAwardBlackPicTb = {}
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/activePicUseInNewGuid.plist")
    spriteController:addTexture("public/activePicUseInNewGuid.png")
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc
end

function acContinueRechargeNewGuidDialog:initTableView()
  local isAddHeight = 0
  if G_isIphone5() then
    isAddHeight = 40
  end
  local function noData( ) end
  local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),noData)
  tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 400-isAddHeight))
  tvBg:setAnchorPoint(ccp(0,0))
  -- tvBg:setOpacity(200)
  tvBg:setPosition(ccp(10,30))
  self.bgLayer:addChild(tvBg)

  local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
  goldLineSprite1:setAnchorPoint(ccp(0.5,1))
  goldLineSprite1:setScaleX(tvBg:getContentSize().width/goldLineSprite1:getContentSize().width)
  goldLineSprite1:setPosition(ccp(tvBg:getContentSize().width*0.5,tvBg:getContentSize().height-3))
  tvBg:addChild(goldLineSprite1,1)

  local curDay = acContinueRechargeNewGuidVoApi:getCurrentDay()
  local curRecharged = acContinueRechargeNewGuidVoApi:getRechargeByDay(curDay)
  self.needGems = acContinueRechargeNewGuidVoApi:getNeedMoneyByDay()
  self.rechargeLabel = GetTTFLabelWrap(getlocal("activity_lxcz_everyDayRecharge"),25,CCSizeMake(tvBg:getContentSize().width-20,40),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.rechargeLabel:setAnchorPoint(ccp(0,0.5))
  self.rechargeLabel:setPosition(ccp(15, goldLineSprite1:getPositionY()-45))
  tvBg:addChild(self.rechargeLabel)


  self.cellWidth = G_VisibleSizeWidth-20
  self.cellHeight = (G_VisibleSizeHeight - 480)/3

  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 15))
  
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 480-isAddHeight),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,40))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(20)

 local recordPoint = self.tv:getRecordPoint()
  -- self.tv:reloadData()
  local addCellIdx = acContinueRechargeNewGuidVoApi:getCurrentDay()-1
  if addCellIdx >= 5 then
    addCellIdx =4
  end
  self.tv:recoverToRecordPoint(ccp(recordPoint.x,recordPoint.y+self.cellHeight*addCellIdx))
end

function acContinueRechargeNewGuidDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    local cellNums = acContinueRechargeNewGuidVoApi:getTotalDays() or 0
    return cellNums
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(self.cellWidth,self.cellHeight)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local function noData( ) end
    local cellBackSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),noData)
    cellBackSprie:setContentSize(CCSizeMake(self.cellWidth-10,self.cellHeight-10))
    cellBackSprie:setAnchorPoint(ccp(0,0))
    cellBackSprie:setPosition(ccp(5, 5))
    cell:addChild(cellBackSprie)

    local cellDay = acContinueRechargeNewGuidVoApi:getCurrentDay()
    local curRecharged = acContinueRechargeNewGuidVoApi:getRechargeByDay(cellDay)
    local rechargedDays = 0
    local rechargedTb   = {}
    local stateStrColor = nil
    rechargedTb,rechargedDays = acContinueRechargeNewGuidVoApi:getRechargedTb( )
    local isGetTb= acContinueRechargeNewGuidVoApi:getAwardTbInDays()
    local stateStr = nil
        if cellDay >0 and idx+1 > cellDay then--还未开始的天数
            cellDay = idx+1
            stateStr = "notYetStr"
        elseif idx+1 ~=cellDay then
            cellDay = idx+1
            if rechargedTb == nil or rechargedTb[cellDay] < self.needGems then
                stateStr = "expiredStr"
                stateStrColor = G_ColorGray
            else
                if isGetTb == nil or isGetTb[cellDay] == nil or isGetTb[cellDay] == 0  then
                    -- print("isGetTb  is  nil 222 !!!!",rechargedTb[cellDay])
                    --显示按钮
                    local function rewardHandler(tag,object)
                      print("tag---22222-->",tag)
                      PlayEffect(audioCfg.mouseClick)
                      self:socketAward(tag)
                    end
                    local menuItemDesc=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,cellDay,getlocal("daily_scene_get"),28)
                    menuItemDesc:setAnchorPoint(ccp(0.5,0.5))
                    menuItemDesc:setScale(0.8)
                    menuDesc=CCMenu:createWithItem(menuItemDesc)
                    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
                    menuDesc:setPosition(ccp(self.cellWidth-75,(self.cellHeight-self.cellHeight*0.28)*0.5))
                    cell:addChild(menuDesc)
                elseif isGetTb[cellDay] > 0 then
                    stateStr = "activity_hadReward"
                    stateStrColor = G_ColorGreen
                end
            end
        elseif idx +1 == cellDay then
            local cellBackSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",CCRect(20, 20, 10, 10),noData)
            cellBackSprie2:setContentSize(CCSizeMake(self.cellWidth-10,self.cellHeight-10))
            cellBackSprie2:setAnchorPoint(ccp(0,0))
            cellBackSprie2:setOpacity(220)
            cellBackSprie2:setPosition(ccp(5, 5))
            cell:addChild(cellBackSprie2)
            
            local menuDesc = nil
            if rechargedTb == nil or rechargedTb[cellDay] < self.needGems then
                stateStr = "serverwar_battle_ing"
                stateStrColor = G_ColorYellowPro
            else
                if isGetTb == nil or isGetTb[cellDay] == nil or isGetTb[cellDay] == 0  then
                    -- print("isGetTb  is  nil 111 !!!!",rechargedTb[cellDay])
                    --显示按钮
                    local function rewardHandler(tag,object)
                      print("tag---111-->",tag)
                      PlayEffect(audioCfg.mouseClick)
                      self:socketAward(tag)
                    end
                    local menuItemDesc=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,cellDay,getlocal("daily_scene_get"),28)
                    menuItemDesc:setAnchorPoint(ccp(0.5,0.5))
                    menuItemDesc:setScale(0.8)
                    menuDesc=CCMenu:createWithItem(menuItemDesc)
                    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
                    menuDesc:setPosition(ccp(self.cellWidth-75,(self.cellHeight-self.cellHeight*0.28)*0.5))
                    cell:addChild(menuDesc)
                elseif isGetTb[cellDay] > 0 then
                    stateStr = "activity_hadReward"
                    stateStrColor = G_ColorGreen
                end
            end

        end

        
    -- end
    local showAward = acContinueRechargeNewGuidVoApi:getContinueRechargedAward(cellDay)

    local groupSelf = CCSprite:createWithSpriteFrameName("groupSelf.png")
    groupSelf:setScaleX((self.cellWidth-10)/groupSelf:getContentSize().width)
    groupSelf:setScaleY((self.cellHeight*0.28)/groupSelf:getContentSize().height)
    groupSelf:setAnchorPoint(ccp(0.5,1))
    groupSelf:setOpacity(200)
    groupSelf:setPosition(ccp(self.cellWidth*0.5+10,self.cellHeight-8))
    cell:addChild(groupSelf)    

    local dayStr,dayStr2,dayPic = nil
    if idx+1 == acContinueRechargeNewGuidVoApi:getCurrentDay() then
        if curRecharged > self.needGems then
            curRecharged = self.needGems
        end
        dayStr = GetTTFLabel(getlocal("activity_lxcz_rechargeIndays",{cellDay,curRecharged,self.needGems}),25)--{curDay,curRecharged,self.needGems}
        dayStr2 = GetTTFLabel(")",25)
        dayPic = CCSprite:createWithSpriteFrameName("IconGold.png")

    else
        dayStr = GetTTFLabel(getlocal("activity_lxcz_dayDes",{cellDay}),25)
    end
    local srtPosY = 15
    if G_isIphone5() then
        srtPosY = 25
    end
    dayStr:setAnchorPoint(ccp(0.5,1))
    dayStr:setPosition(ccp(self.cellWidth*0.5-15,self.cellHeight-srtPosY))
    cell:addChild(dayStr)

    if dayPic and dayStr2 then
        dayPic:setAnchorPoint(ccp(0.5,1))
        dayPic:setPosition(ccp(dayStr:getPositionX()+dayStr:getContentSize().width*0.5+12,dayStr:getPositionY()+2))
        cell:addChild(dayPic)

        dayStr2:setAnchorPoint(ccp(0.5,1))
        dayStr2:setPosition(ccp(dayPic:getPositionX()+dayPic:getContentSize().width*0.5,dayStr:getPositionY()))
        cell:addChild(dayStr2)
    end



    local leftStr=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),25,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    leftStr:setAnchorPoint(ccp(0,0.5))
    leftStr:setPosition(ccp(15,(self.cellHeight-self.cellHeight*0.28)*0.5))
    cell:addChild(leftStr)

    if showAward then
        for k,v in pairs(showAward) do
          local scale=1
          local propSp=G_getItemIcon(v,self.cellHeight*0.56,true,self.layerNum+1)
          propSp:setAnchorPoint(ccp(0,0.5))
          propSp:setTouchPriority(-(self.layerNum-1)*20-2)
          propSp:setPosition(ccp(leftStr:getPositionX()+leftStr:getContentSize().width+(k-1)*self.cellHeight*0.68+(k-1)*10,leftStr:getPositionY()))
          cell:addChild(propSp,1)

          local itemW=propSp:getContentSize().width*scale
          local itemH=propSp:getContentSize().height*scale

          local numLb=GetTTFLabel("x"..v.num,25)
          numLb:setAnchorPoint(ccp(1,0))
          numLb:setPosition(ccp(itemW-5,5))
          numLb:setScale(1/propSp:getScale())
          propSp:addChild(numLb,1)
        end
    end
    
    if stateStr then
        stateLb = GetTTFLabel(getlocal(stateStr),25,CCSizeMake(100,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        stateLb:setAnchorPoint(ccp(1,0.5))
        stateLb:setPosition(ccp(self.cellWidth-40,(self.cellHeight-self.cellHeight*0.28)*0.5))
        if stateStrColor then
          stateLb:setColor(stateStrColor)
        end
        cell:addChild(stateLb,1)
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

function acContinueRechargeNewGuidDialog:getReward()
  -- if acContinueRechargeNewGuidVoApi:canReward() == true then
    local function getRawardCallback(fn,data)
      local ret,sData = base:checkServerData(data)
      if ret == true then
          if sData.data.lxcz then
                  acContinueRechargeNewGuidVoApi:updateData(sData.data.lxcz)
          end

          local ooo,formatBigAward = acContinueRechargeNewGuidVoApi:getFinal( )
          for k,v in pairs(formatBigAward) do
            G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
          end
          G_showRewardTip(formatBigAward,true)

          acContinueRechargeNewGuidVoApi:afterGetReward()
          self:update()
      end
    end
    socketHelper:getContinueRechargeRewardNewGuid(getRawardCallback,"getReward")
  -- end
end

function acContinueRechargeNewGuidDialog:iconFlicker(icon)
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


function acContinueRechargeNewGuidDialog:doUserHandler()
  local strSize2 = 20
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
      strSize2 = 25
  end
  self.currentDay = acContinueRechargeNewGuidVoApi:getCurrentDay()

  local function cellClick(hd,fn,index) end
  CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  local blueBg =CCSprite:create("public/superWeapon/weaponBg.jpg")
  CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  blueBg:setAnchorPoint(ccp(0.5,0))
  blueBg:setScaleX((G_VisibleSizeWidth-24)/blueBg:getContentSize().width)
  blueBg:setScaleY((G_VisibleSizeHeight-122)/blueBg:getContentSize().height)
  blueBg:setPosition(ccp(G_VisibleSizeWidth*0.5, 32))
  self.bgLayer:addChild(blueBg)

  -- local w2 = G_VisibleSizeWidth - 26 -- 背景框的宽度
  -- local backSprie2 = CCSprite:createWithSpriteFrameName("goldAndTankBg_2.jpg")
  -- -- backSprie2:setContentSize(CCSizeMake(w2, 270))
  -- backSprie2:setScaleX(w2/backSprie2:getContentSize().width)
  -- backSprie2:setScaleY(270/backSprie2:getContentSize().height)
  -- backSprie2:setAnchorPoint(ccp(0.5,1))
  -- backSprie2:setPosition(ccp(G_VisibleSizeWidth*0.5, G_VisibleSizeHeight - 88))
  -- self.bgLayer:addChild(backSprie2)

  local w = G_VisibleSizeWidth - 20 -- 背景框的宽度
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
  backSprie:setContentSize(CCSizeMake(w, 130))
  backSprie:setAnchorPoint(ccp(0,1))
  backSprie:setOpacity(0)
  backSprie:setPosition(ccp(10, G_VisibleSizeHeight - 85))
  self.bgLayer:addChild(backSprie)
  

  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),24)
  acLabel:setColor(G_ColorGreen)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, backSprie:getContentSize().height-5))
  backSprie:addChild(acLabel)

  local acVo = acContinueRechargeNewGuidVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,23)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, acLabel:getPositionY()-24))
  backSprie:addChild(messageLabel)
  self.timeLb=messageLabel
  self:updateAcTime()
  
  local lbStr = "activity_lxcz_des"
  local needDay = acContinueRechargeNewGuidVoApi:getNeedDay( )
  local desTv, desLabel = G_LabelTableView(CCSizeMake(backSprie:getContentSize().width-50, 60),getlocal(lbStr,{acContinueRechargeNewGuidVoApi:getNeedMoneyByDay(),needDay}),24,kCCTextAlignmentLeft)
  backSprie:addChild(desTv)
  desTv:setPosition(ccp(25,10))
  desTv:setAnchorPoint(ccp(0,0))
  backSprie:setTouchPriority(-(self.layerNum-1) * 20 - 4)
  desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
  desTv:setMaxDisToBottomOrTop(100)

  local rewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("titlesDesBg.png",CCRect(50, 20, 1, 1),cellClick)
  rewardBg:setContentSize(CCSizeMake(backSprie:getContentSize().width-20, G_VisibleSizeHeight*0.16))
  rewardBg:setAnchorPoint(ccp(0,1))
  rewardBg:setPosition(ccp(20, backSprie:getPositionY() - backSprie:getContentSize().height+5))
  self.bgLayer:addChild(rewardBg)

  local rewardDaysDes = GetTTFLabel(getlocal("activity_lxcz_rewardDes",{needDay}),23)
  rewardDaysDes:setAnchorPoint(ccp(0,1))
  rewardDaysDes:setPosition(ccp(10,rewardBg:getContentSize().height-8))
  rewardBg:addChild(rewardDaysDes,1)

  local titlesBg = LuaCCScale9Sprite:createWithSpriteFrameName("titlesBG.png",CCRect(35, 16, 1, 1),cellClick)
  titlesBg:setContentSize(CCSizeMake(rewardDaysDes:getContentSize().width+25,rewardDaysDes:getContentSize().height+8))
  titlesBg:setAnchorPoint(ccp(0,1))
  titlesBg:setPosition(ccp(8,rewardBg:getContentSize().height-5))
  rewardBg:addChild(titlesBg)

  local leftStr=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),25,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  leftStr:setAnchorPoint(ccp(0,0.5))
  leftStr:setPosition(ccp(15,(rewardBg:getContentSize().height-titlesBg:getContentSize().height)*0.5))
  rewardBg:addChild(leftStr)

  local final,formatFinal = acContinueRechargeNewGuidVoApi:getFinal( )
  if final then
    for k,v in pairs(formatFinal) do
      local scale=1
      local propSp=G_getItemIcon(v,90,true,self.layerNum+1)
      propSp:setAnchorPoint(ccp(0,0.5))
      propSp:setTouchPriority(-(self.layerNum-1)*20-4)
      propSp:setPosition(ccp(leftStr:getPositionX()+leftStr:getContentSize().width+(k-1)*100,leftStr:getPositionY()))
      rewardBg:addChild(propSp,1)

      local itemW=propSp:getContentSize().width*scale
      local itemH=propSp:getContentSize().height*scale

      local numLb=GetTTFLabel("x"..v.num,25)
      numLb:setAnchorPoint(ccp(1,0))
      numLb:setPosition(ccp(itemW-5,5))
      numLb:setScale(1/propSp:getScale())
      propSp:addChild(numLb,1)

      G_addRectFlicker2(propSp,1.2,1.2,2,"p",nil,10)

      local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
      grayBgSp:setAnchorPoint(ccp(0.5,0.5))
      grayBgSp:setContentSize(CCSizeMake(92,92))
      grayBgSp:setPosition(getCenterPoint(propSp))
      propSp:addChild(grayBgSp)
      self.bigAwardBlackPicTb[k] = grayBgSp
      grayBgSp:setVisible(false)
      grayBgSp:setPositionY(grayBgSp:getPositionY()+2)
      local hadRewardStr = GetTTFLabel(getlocal("activity_hadReward"),25)
      hadRewardStr:setAnchorPoint(ccp(0.5,0.5))
      hadRewardStr:setPosition(getCenterPoint(grayBgSp))
      grayBgSp:addChild(hadRewardStr)

    end
  end
--activity_lxcz_continuRechargeDays 
  local rechargedTb,rechargedDays,isAgainLargeDay = acContinueRechargeNewGuidVoApi:getRechargedTb( )
  -- if acContinueRechargeNewGuidVoApi:getRechargedTb( ) then
  --   local rechargedTb = {}
    
  -- end
  self.continueDaysStr = GetTTFLabel(getlocal("activity_lxcz_continuRechargeDays",{rechargedDays}),24)
  self.continueDaysStr:setAnchorPoint(ccp(1,1))
  self.continueDaysStr:setPosition(ccp(rewardBg:getContentSize().width-20,rewardBg:getContentSize().height*0.8))
  rewardBg:addChild(self.continueDaysStr)


  local function rewardHandler(tag,object)
    print("hre??????????")
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

  self.rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler,0,getlocal("activity_lxcz_reward"),25)
  self.rewardBtn:setScale(0.9)
  self.rewardBtn:setAnchorPoint(ccp(0.5, 0))
  local menuAward=CCMenu:createWithItem(self.rewardBtn)
  menuAward:setPosition(ccp(self.continueDaysStr:getPositionX()-self.continueDaysStr:getContentSize().width*0.5,25))
  menuAward:setTouchPriority(-(self.layerNum-1)*20-5)
  rewardBg:addChild(menuAward,1) 


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
  self.rechargeItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onConfirmRecharge,0,getlocal("activity_continueRecharge_dayRecharge"),strSize2)
  self.rechargeItem:setScale(0.9)
  self.rechargeItem:setAnchorPoint(ccp(0.5,0))
  local rechargeBtn=CCMenu:createWithItem(self.rechargeItem)
  rechargeBtn:setTouchPriority(-(self.layerNum-1)*20-5)
  rechargeBtn:setPosition(ccp(self.continueDaysStr:getPositionX()-self.continueDaysStr:getContentSize().width*0.5,25))
  rewardBg:addChild(rechargeBtn)

  local hadBig = acContinueRechargeNewGuidVoApi:bigAwardHad( )
  if isAgainLargeDay >=4 and hadBig == 0 then
    self.rewardBtn:setEnabled(true)
    self.rechargeItem:setVisible(false)
  else
    self.rewardBtn:setEnabled(false)
    self.rewardBtn:setVisible(false)
    self.rechargeItem:setVisible(true)
    if hadBig > 0 then
        for k,v in pairs(self.bigAwardBlackPicTb) do
          v:setVisible(true)
        end
    end
  end 

end

-- 更新今日充值金额
function acContinueRechargeNewGuidDialog:updateTodayMoneyLabel()
  if self == nil then
    do  return end
  end

  if self.rewardBtn ~= nil then
    local rechargedDays = 0
    local rechargedTb = {}
    local hadBig = acContinueRechargeNewGuidVoApi:bigAwardHad( )
    rechargedTb,rechargedDays,isAgainLargeDay = acContinueRechargeNewGuidVoApi:getRechargedTb( )
    if isAgainLargeDay >=4 and hadBig == 0 then
      self.rewardBtn:setVisible(true)
      self.rewardBtn:setEnabled(true)
      self.rechargeItem:setVisible(false)
    else
      self.rewardBtn:setEnabled(false)
      self.rewardBtn:setVisible(false)
      self.rechargeItem:setVisible(true)
      if hadBig > 0 then
        for k,v in pairs(self.bigAwardBlackPicTb) do
          v:setVisible(true)
        end
      end
    end 
  end
  -- print("hadBig---isAgainLargeDay->",hadBig,isAgainLargeDay)
end
function acContinueRechargeNewGuidDialog:revisePanel(day)
  local needGems = acContinueRechargeNewGuidVoApi:getReviseNeedMoneyByDay()
  if needGems>playerVoApi:getGems() then
    GemsNotEnoughDialog(nil,nil,needGems-playerVoApi:getGems(),self.layerNum+1,needGems)
  else
    local function usePropHandler(tag1,object)
        PlayEffect(audioCfg.mouseClick)
        local function reviseSuccess(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                playerVoApi:setValue("gems",playerVoApi:getGems()-needGems)
                acContinueRechargeNewGuidVoApi:updateState()
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_lxcz_reviseSuc"),28)
            end
        end

        socketHelper:continueRechargeRevise(day,reviseSuccess)
    end
    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),usePropHandler,getlocal("dialog_title_prompt"),getlocal("activity_lxcz_revise",{day,acContinueRechargeNewGuidVoApi:getReviseNeedMoneyByDay(day)}),nil,self.layerNum+1)
  end
end


function acContinueRechargeNewGuidDialog:socketAward( idx )
    local function getAwardCallback(fn,data )
        local ret,sData = base:checkServerData(data)
        if ret == true then
            if sData.data.lxcz then
                acContinueRechargeNewGuidVoApi:updateData(sData.data.lxcz)
            end
            local reward = acContinueRechargeNewGuidVoApi:getContinueRechargedAward(idx)
            -- print("callback in socketAward~~~")
            for k,v in pairs(reward) do
              G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
            end
            G_showRewardTip(reward,true)
            acContinueRechargeNewGuidVoApi:afterGetReward()
            self:update()
        end
    end 
    socketHelper:getContinueRechargeRewardNewGuid(getAwardCallback,"getRewardDay",idx)
end

function acContinueRechargeNewGuidDialog:tick()
  local day = acContinueRechargeNewGuidVoApi:getCurrentDay()
  if self.currentDay ~= day then
    print("当前是第"..day.."天"..self.currentDay)
    self.currentDay = day
    self:update()
  end
  self:updateAcTime()
end

function acContinueRechargeNewGuidDialog:update()
  local acVo = acContinueRechargeNewGuidVoApi:getAcVo()
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

      local rechargedDays = 0
      local rechargedTb = {}
      rechargedTb,rechargedDays = acContinueRechargeNewGuidVoApi:getRechargedTb( )
      self.continueDaysStr:setString(getlocal("activity_lxcz_continuRechargeDays",{rechargedDays}))
    end
  end
end

function acContinueRechargeNewGuidDialog:updateAcTime()
  local acVo = acContinueRechargeNewGuidVoApi:getAcVo()
  if acVo and self.timeLb then
    G_updateActiveTime(acVo,self.timeLb)
  end
end

function acContinueRechargeNewGuidDialog:dispose()
  self.rewardBtn = nil
  self.currentDay = nil
  self.rechargeLabel = nil
  self.timeLb=nil
  self=nil

  spriteController:removePlist("public/activePicUseInNewGuid.plist")
  spriteController:removeTexture("public/activePicUseInNewGuid.png")
  spriteController:removePlist("public/acNewYearsEva.plist")
  spriteController:removeTexture("public/acNewYearsEva.png")
  spriteController:removePlist("public/purpleFlicker.plist")
  spriteController:removeTexture("public/purpleFlicker.png")
end





