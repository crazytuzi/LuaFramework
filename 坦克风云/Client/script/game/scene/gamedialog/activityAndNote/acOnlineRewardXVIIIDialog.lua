
acOnlineRewardXVIIIDialog=commonDialog:new()

function acOnlineRewardXVIIIDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    nc.upPosy =G_VisibleSizeHeight - 80
    nc.upHeight=220
    nc.curRefreshLastAwardType = acOnlineRewardXVIIIVoApi:getRefreshLastAwardType()
    return nc
end


--设置对话框里的tableView
function acOnlineRewardXVIIIDialog:initTableView()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/xsjx.plist")
    spriteController:addTexture("public/xsjx.png")
    spriteController:addPlist("public/acYwzq2018Image.plist")--acMjzx2Image
    spriteController:addTexture("public/acYwzq2018Image.png")
    spriteController:addPlist("public/acthreeyear_images.plist")
    spriteController:addTexture("public/acthreeyear_images.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local count=math.floor((G_VisibleSizeHeight-50)/80)+2
    for i=1,count do
        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setScaleX(G_VisibleSizeWidth/bgSp:getContentSize().width)
        bgSp:setScaleY(80/bgSp:getContentSize().height)
        bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-80)-(i-1)*bgSp:getContentSize().height)
        if i > 5 then
          self.bgLayer:addChild(bgSp,4)
        else
          self.bgLayer:addChild(bgSp)
        end
        if G_isIphone5()==false and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()))
        end
    end

    local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    timeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
    timeBg:setAnchorPoint(ccp(0.5,1))
    timeBg:setOpacity(255*0.6)
    timeBg:setPosition(G_VisibleSizeWidth * 0.5,self.upPosy)
    self.bgLayer:addChild(timeBg)

    local timeStrSize = G_isAsia() and 24 or 21
    local acLabel     = GetTTFLabel(acOnlineRewardXVIIIVoApi:getTimer(),22,"Helvetica-bold")
    acLabel:setPosition(ccp(G_VisibleSizeWidth *0.5, self.upPosy - 25))
    self.bgLayer:addChild(acLabel,1)
    acLabel:setColor(G_ColorYellowPro2)
    self.timeLb=acLabel

    local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBgBottom.png", CCRect(34, 32, 2, 6), function() end)
    bottomBg:setAnchorPoint(ccp(0.5, 0))
    bottomBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, bottomBg:getContentSize().height))
    bottomBg:setPosition(G_VisibleSizeWidth * 0.5, 0)
    self.bgLayer:addChild(bottomBg, 13)

    self.cellWidth,self.cellHeight = G_VisibleSizeWidth,self.bgLayer:getContentSize().height-500
    self.panelLineBg:setVisible(false)
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,self.bgLayer:getContentSize().height-500),nil)
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(0,20))
    self.bgLayer:addChild(self.tv,5)
    self.tv:setMaxDisToBottomOrTop(120)

    local characterSp = CCSprite:createWithSpriteFrameName("charater_beautyGirl.png") --姑娘
    characterSp:setScale(1.2)
    characterSp:setAnchorPoint(ccp(0,1))
    characterSp:setPositionY(self.upPosy - timeBg:getContentSize().height + 10)
    self.bgLayer:addChild(characterSp,3)

    local lineSP =LuaCCScale9Sprite:createWithSpriteFrameName("yellowGapLine1.png", CCRect(243,6,1,1), function() end)
    lineSP:setContentSize(CCSizeMake(G_VisibleSizeWidth -10, lineSP:getContentSize().height))
    lineSP:setPosition(ccp(G_VisibleSizeWidth *0.5,self.bgLayer:getContentSize().height - 475))
    self.bgLayer:addChild(lineSP,4)
    
    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("GuideNewPanel.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg:setContentSize(CCSizeMake(470,160))
    girlDescBg:setAnchorPoint(ccp(0,0))
    girlDescBg:setPosition(ccp(120,self.bgLayer:getContentSize().height - 350))
    self.bgLayer:addChild(girlDescBg,1)
    
    local lbHight = 30
    if G_getCurChoseLanguage() =="fr" then
        lbHight=0
    end
    local descLabel=GetTTFLabelWrap(getlocal("activity_onlineReward_desc"),26,CCSizeMake(340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    descLabel:setAnchorPoint(ccp(0,0))
    descLabel:setPosition(60,girlDescBg:getContentSize().height/2+lbHight)
    girlDescBg:addChild(descLabel,3)
    descLabel:setColor(G_ColorYellowPro2)


    local descTv,descLb=G_LabelTableView(CCSize(440,girlDescBg:getContentSize().height/2+10),getlocal("activity_onlineReward_content"),23,kCCTextAlignmentLeft)
    descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv:setAnchorPoint(ccp(0,0))
    descTv:setPosition(ccp(60,10))
    girlDescBg:addChild(descTv,3)
    descTv:setMaxDisToBottomOrTop(50)

    local function touch()
        local td=smallDialog:new()
        local tabStr={"\n",getlocal("activity_onlineRewardXVIII_tip4"),"\n",getlocal("activity_onlineReward_tip3"),getlocal("activity_onlineReward_tip2"),getlocal("activity_onlineReward_tip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local menuItem = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png",touch,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem);
    menu:setPosition(ccp(G_VisibleSizeWidth - 40,self.upPosy - 40));
    menu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(menu,5);

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acOnlineRewardXVIIIDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(self.cellWidth,self.cellHeight)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

        local checkBg = CCSprite:createWithSpriteFrameName("SquareLadder.png")
        checkBg:setAnchorPoint(ccp(0.5,0))
        checkBg:setScaleX(self.cellWidth * 0.8/checkBg:getContentSize().width)
        checkBg:setScaleY((self.cellHeight - 100)/checkBg:getContentSize().height)
        checkBg:setPosition(ccp(self.cellWidth * 0.4,0))
        cell:addChild(checkBg)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

        local rewardLabelH = 20
        local rewardBtnH = 0
        local acCfg = acOnlineRewardXVIIIVoApi:getRewardCfg()
        local barH = 120
        local totalH  -- 总高度

       
        if acCfg ~= nil then
          barH = (self.bgLayer:getContentSize().height-520)/SizeOfTable(acCfg)
          totalH = barH * SizeOfTable(acCfg)
        else
          totalH = barH
        end

        local totalW = G_VisibleSizeWidth - 20
        local leftW = totalW * 0.4
        local rightW = totalW * 0.7
         
        local oldLastTime = acOnlineRewardXVIIIVoApi:getOTime( )
        local onlineTime = acOnlineRewardXVIIIVoApi:getOnlineTime()
        local per = 0
        local perWidth = 0
        local addContinue = true
        local boxAddPosy = 40
        if acCfg ~= nil and acCfg ~= nil then
          local rewardLen = SizeOfTable(acCfg)
          if rewardLen ~= nil and rewardLen > 0 then
            local BtnX = self.bgLayer:getContentSize().width-120
              for i=1,rewardLen do
                local h = barH * (rewardLen - i) + rewardBtnH -- 每条奖励信息的y坐标起始位置
                local index = rewardLen - i+1
                local award=FormatItem(acOnlineRewardXVIIIVoApi:getRewardByID(index),true)
                local needTime = acOnlineRewardXVIIIVoApi:getNeedTimeByID(index)
                local canReward = acOnlineRewardXVIIIVoApi:checkIfCanRewardById(index)
                local hadReward = acOnlineRewardXVIIIVoApi:checkIfHadRewardById(index)
                if canReward == true and hadReward==false then
                    onlineTime = needTime
                end
                local showTime = 0
                if needTime>onlineTime then
                  showTime = needTime-onlineTime
                end
                if i == 1 and showTime > oldLastTime then
                    acOnlineRewardXVIIIVoApi:refreshHadReward()
                end
                local needTimeLb = GetTTFLabel(G_getTimeStr(showTime),25)
                needTimeLb:setAnchorPoint(ccp(0,1))
                needTimeLb:setPosition(self.cellWidth * 0.28,40 + h+barH-20)
                cell:addChild(needTimeLb,1) 
                
                local blackBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
                blackBg:setAnchorPoint(ccp(0.5,1))
                blackBg:setScaleX(180 / blackBg:getContentSize().width)
                blackBg:setScaleY(100 / blackBg:getContentSize().height)
                blackBg:setPosition(ccp(self.cellWidth * 0.37,40 + h+barH-20))
                blackBg:setOpacity(150)
                cell:addChild(blackBg) 

                if hadReward == true then
                  needTimeLb:setVisible(false)
                else
                  needTimeLb:setVisible(true)
                end
                if canReward == true then
                  
                  if hadReward == true then 

                    spUrl = "propBox"..6-i..".png"
                    local boxSp = CCSprite:createWithSpriteFrameName(spUrl)
                    boxSp:setAnchorPoint(ccp(0.5,0.5))
                    boxSp:setPosition(BtnX,h+barH/2 + boxAddPosy)
                    cell:addChild(boxSp,2)

                    local hadLabel = GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    hadLabel:setAnchorPoint(ccp(0,0.5))
                    hadLabel:setPosition(ccp(self.cellWidth * 0.28,40 + h+barH/2))
                    cell:addChild(hadLabel,2)
                    hadLabel:setColor(G_ColorGreen)
                  else
                    local function rewardHandler()
                      if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do return end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        
                        local function treeRewardCallback(fn,data)
                          local ret,sData=base:checkServerData(data)
                          if ret then
                            for k,v in pairs(award) do
                              G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                            end
                            G_showRewardTip(award, true)
                            acOnlineRewardXVIIIVoApi:addHadRewardByID(index)
                            self:refresh()
                            acOnlineRewardXVIIIVoApi:updateShow()
                          end
                        end
                        socketHelper:activityOnlineRewardXVIII(index,treeRewardCallback)
                      end
                        
                    end

                      local sp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                      sp:setAnchorPoint(ccp(0.5,0.5))
                      sp:setPosition(BtnX,h+barH/2 + boxAddPosy)
                      cell:addChild(sp,2)

                      btnUrl1 = "propBox"..6-i..".png"
                      btnUrl2 = "propBox"..6-i..".png"

                     local rewardBtn = GetButtonItem(btnUrl1,btnUrl2,btnUrl2,rewardHandler)
                      --rewardBtn:setScale(0.6)
                      rewardBtn:setAnchorPoint(ccp(0.5,0.5))
                      local rewardMenu=CCMenu:createWithItem(rewardBtn)
                      --rewardMenu:setAnchorPoint(ccp(0,0))
                      rewardMenu:setPosition(ccp(BtnX,h+barH/2 + boxAddPosy))
                      rewardMenu:setTouchPriority(-(self.layerNum-1)*20-3)
                      cell:addChild(rewardMenu,6)

                      local clickLabel = GetTTFLabelWrap(getlocal("activity_onlineReward_clickChose"),25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                      clickLabel:setAnchorPoint(ccp(0,0))
                      local clickLbHeight =h+20
                      if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="de" then
                        clickLbHeight =h+10
                      elseif G_getCurChoseLanguage() =="fr" then
                        clickLbHeight =h+5
                      end
                      clickLabel:setPosition(ccp(self.cellWidth * 0.28,40 + clickLbHeight))
                      cell:addChild(clickLabel,2)
                      clickLabel:setColor(G_ColorYellow)
                    end

                else
                  if hadReward == true then 
                      spUrl = "propBox"..6-i..".png"
                      local boxSp = CCSprite:createWithSpriteFrameName(spUrl)
                      boxSp:setAnchorPoint(ccp(0.5,0.5))
                      boxSp:setPosition(BtnX,h+barH/2 + boxAddPosy)
                      cell:addChild(boxSp,2)

                      local hadLabel = GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                      hadLabel:setAnchorPoint(ccp(0,0.5))
                      hadLabel:setPosition(ccp(self.cellWidth * 0.28,40 + h+barH/2))
                      cell:addChild(hadLabel,2)
                      hadLabel:setColor(G_ColorGreen)
                  else
                      local function showReward( ... )
                         if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                          local td = acFeixutansuoRewardTip:new()
                          td:init("PanelHeaderPopup.png",getlocal("award"),getlocal("activity_getRich_finishGoalReward"),award,nil,self.layerNum+1)
                        end
                      end

                      spUrl = "propBox"..6-i..".png"
                      local boxSp = LuaCCSprite:createWithSpriteFrameName(spUrl,showReward)
                      boxSp:setAnchorPoint(ccp(0.5,0.5))
                      boxSp:setPosition(BtnX,h+barH/2 + boxAddPosy)
                      cell:addChild(boxSp,2)
                      boxSp:setTouchPriority(-(self.layerNum-1)*20-3)

                      local noLabel = GetTTFLabelWrap(getlocal("activity_dayRecharge_no"),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                      noLabel:setAnchorPoint(ccp(0,0))
                      noLabel:setPosition(ccp(self.cellWidth * 0.28,40 + h+20))
                      cell:addChild(noLabel,10)
                      noLabel:setColor(G_ColorYellow)
                  end
                end
              end
          end
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

function acOnlineRewardXVIIIDialog:refresh()
  if self ~= nil and self.tv ~= nil then
    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
  end
end
function acOnlineRewardXVIIIDialog:tick()
    self:refresh()
    if self.timeLb then
      self.timeLb:setString(acOnlineRewardXVIIIVoApi:getTimer())
    end
    if self.curRefreshLastAwardType ~= acOnlineRewardXVIIIVoApi:getRefreshLastAwardType() then
      self.curRefreshLastAwardType = acOnlineRewardXVIIIVoApi:getRefreshLastAwardType()
      self:refresh()
      acOnlineRewardXVIIIVoApi:updateShow()
    else
        self:refresh()
    end
end

function acOnlineRewardXVIIIDialog:update()
    local acVo = acOnlineRewardXVIIIVoApi:getAcVo()
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

function acOnlineRewardXVIIIDialog:dispose()
    self.normalHeight=nil
    self.extendSpTag=nil
    self.timeLbTab=nil
    self.isCloseing=nil
    self.buffTab=nil
    self=nil
    spriteController:removePlist("public/xsjx.plist")
    spriteController:removeTexture("public/xsjx.png")
    spriteController:removePlist("public/acYwzq2018Image.plist")
    spriteController:removeTexture("public/acYwzq2018Image.png")
    spriteController:removePlist("public/acthreeyear_images.plist")
    spriteController:removeTexture("public/acthreeyear_images.png")
end
