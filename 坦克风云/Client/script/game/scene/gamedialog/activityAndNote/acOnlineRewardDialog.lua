
acOnlineRewardDialog=commonDialog:new()

function acOnlineRewardDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    return nc
end


--设置对话框里的tableView
function acOnlineRewardDialog:initTableView()
    self.panelLineBg:setVisible(false)
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-500),nil)
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(10,20))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)


    local characterSp
    if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
        characterSp = CCSprite:create("public/guide.png")
    else
        characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
    end
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(10,self.bgLayer:getContentSize().height - 430))
    self.bgLayer:addChild(characterSp,5)

    local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSP:setAnchorPoint(ccp(0.5,0.5))
	lineSP:setScaleX(G_VisibleSizeWidth/lineSP:getContentSize().width)
	lineSP:setScaleY(1.2)
	lineSP:setPosition(ccp(G_VisibleSizeWidth/2,self.bgLayer:getContentSize().height - 440))
	self.bgLayer:addChild(lineSP,2)
    
    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg:setContentSize(CCSizeMake(410,200))
    girlDescBg:setAnchorPoint(ccp(0,0))
    girlDescBg:setPosition(ccp(180,self.bgLayer:getContentSize().height - 410))
    self.bgLayer:addChild(girlDescBg,4)
    
    local lbHight = 30
    if G_getCurChoseLanguage() =="fr" then
        lbHight=0
    end
    local descLabel=GetTTFLabelWrap(getlocal("activity_onlineReward_desc"),26,CCSizeMake(340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLabel:setAnchorPoint(ccp(0,0))
    descLabel:setPosition(70,girlDescBg:getContentSize().height/2+lbHight)
    girlDescBg:addChild(descLabel,5)
    descLabel:setColor(G_ColorYellow)


    local descTv,descLb=G_LabelTableView(CCSize(340,girlDescBg:getContentSize().height/2+10),getlocal("activity_onlineReward_content"),25,kCCTextAlignmentLeft)
    descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv:setAnchorPoint(ccp(0,0))
    descTv:setPosition(ccp(70,10))
    girlDescBg:addChild(descTv,2)
    descTv:setMaxDisToBottomOrTop(50)
    
    local function touch()
        local td=smallDialog:new()
        local tabStr={"\n",getlocal("activity_onlineReward_tip2"),getlocal("activity_onlineReward_tip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem);
    menu:setPosition(ccp(580,self.bgLayer:getContentSize().height-140));
    menu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(menu,5);
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-105))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local acVo = acOnlineRewardVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-140))
        self.bgLayer:addChild(timeLabel)
        self.timeLb=timeLabel
        G_updateActiveTime(acVo,self.timeLb)
    end

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acOnlineRewardDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-500)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local rewardLabelH = 20
        local rewardBtnH = 0
        local acCfg = acOnlineRewardVoApi:getRewardCfg()
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
         
        
        local onlineTime = acOnlineRewardVoApi:getOnlineTime()

        local per = 0
        local perWidth = 0
        local addContinue = true
        if acCfg ~= nil and acCfg ~= nil then
          local rewardLen = SizeOfTable(acCfg)
          if rewardLen ~= nil and rewardLen > 0 then
            local BtnX = self.bgLayer:getContentSize().width-120
              for i=1,rewardLen do
                local h = barH * (rewardLen - i) + rewardBtnH -- 每条奖励信息的y坐标起始位置
                local index = rewardLen - i+1
                local award=FormatItem(acOnlineRewardVoApi:getRewardByID(index),true)
                local needTime = acOnlineRewardVoApi:getNeedTimeByID(index)
                local canReward = acOnlineRewardVoApi:checkIfCanRewardById(index)
                local hadReward = acOnlineRewardVoApi:checkIfHadRewardById(index)
                if canReward == true and hadReward==false then
                    onlineTime = needTime
                end
                local showTime = 0
                if needTime>onlineTime then
                  showTime = needTime-onlineTime
                end

                local needTimeLb = GetTTFLabel(G_getTimeStr(showTime),25)
                needTimeLb:setAnchorPoint(ccp(0,1))
                needTimeLb:setPosition(70,h+barH-20)
                cell:addChild(needTimeLb) 
                
                if hadReward == true then
                  needTimeLb:setVisible(false)
                else
                  needTimeLb:setVisible(true)
                end
                if canReward == true then
                  
                  if hadReward == true then 
                    local spUrl ="SeniorBoxOpen.png"
                    if i == 1 then
                       spUrl ="SpecialBoxOpen.png"
                    end
                    local boxSp = CCSprite:createWithSpriteFrameName(spUrl)
                    boxSp:setAnchorPoint(ccp(0.5,0.5))
                    boxSp:setPosition(BtnX,h+barH/2)
                    cell:addChild(boxSp)

                    local hadLabel = GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    hadLabel:setAnchorPoint(ccp(0,0.5))
                    hadLabel:setPosition(ccp(70,h+barH/2))
                    cell:addChild(hadLabel,1)
                    hadLabel:setColor(G_ColorGreen)
                  else
                    local function rewardHandler()
                      if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
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
                            acOnlineRewardVoApi:addHadRewardByID(index)
                            self:refresh()
                            acOnlineRewardVoApi:updateShow()
                          end
                        end
                        socketHelper:activityOnlineReward(index,treeRewardCallback)
                      end
                        
                    end

                      local sp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                      sp:setAnchorPoint(ccp(0.5,0.5))
                      sp:setPosition(BtnX,h+barH/2)
                      cell:addChild(sp,1)

                      local btnUrl1 ="SeniorBox.png"
                      local btnUrl2 ="SeniorBoxOpen.png"
                      if i == 1 then
                        btnUrl1 ="SpecialBox.png"
                        btnUrl2 ="SpecialBoxOpen.png"
                      end

                     local rewardBtn = GetButtonItem(btnUrl1,btnUrl2,btnUrl2,rewardHandler)
                      --rewardBtn:setScale(0.6)
                      rewardBtn:setAnchorPoint(ccp(0.5,0.5))
                      local rewardMenu=CCMenu:createWithItem(rewardBtn)
                      --rewardMenu:setAnchorPoint(ccp(0,0))
                      rewardMenu:setPosition(ccp(BtnX,h+barH/2))
                      rewardMenu:setTouchPriority(-(self.layerNum-1)*20-3)
                      cell:addChild(rewardMenu,5)

                      local clickLabel = GetTTFLabelWrap(getlocal("activity_onlineReward_clickChose"),25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                      clickLabel:setAnchorPoint(ccp(0,0))
                      local clickLbHeight =h+20
                      if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="de" then
                        clickLbHeight =h+10
                      elseif G_getCurChoseLanguage() =="fr" then
                        clickLbHeight =h+5
                      end
                      clickLabel:setPosition(ccp(70,clickLbHeight))
                      cell:addChild(clickLabel,1)
                      clickLabel:setColor(G_ColorYellow)
                    end

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

                  local spUrl ="SeniorBox.png"
                    if i == 1 then
                       spUrl ="SpecialBox.png"
                    end
                  local boxSp = LuaCCSprite:createWithSpriteFrameName(spUrl,showReward)
                  boxSp:setAnchorPoint(ccp(0.5,0.5))
                  boxSp:setPosition(BtnX,h+barH/2)
                  cell:addChild(boxSp)
                  boxSp:setTouchPriority(-(self.layerNum-1)*20-3)

                  local noLabel = GetTTFLabelWrap(getlocal("activity_dayRecharge_no"),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                  noLabel:setAnchorPoint(ccp(0,0))
                  noLabel:setPosition(ccp(70,h+20))
                  cell:addChild(noLabel,9)
                  noLabel:setColor(G_ColorYellow)
                end

                --箭头
              local capInSet = CCRect(9, 6, 1, 1);
              local function touchClick(hd,fn,idx)
                   
               end
               local arrowWidth=(totalW - 160)

               local arrowSp1 =LuaCCScale9Sprite:createWithSpriteFrameName("heroArrowRight.png",capInSet,touchClick)
               arrowSp1:setContentSize(CCSizeMake(arrowWidth, 16))
               arrowSp1:setAnchorPoint(ccp(0.5,0.5))
               arrowSp1:setPosition(ccp((totalW - 80)/2,h+barH-2))
               arrowSp1:setIsSallow(false)
               arrowSp1:setTouchPriority(-(self.layerNum-1)*20-2)
               cell:addChild(arrowSp1,3)
               arrowSp1:setRotation(180)

              end
          end

          local programH = barH -- -5
          for j=1,rewardLen do
            local needTime = acOnlineRewardVoApi:getNeedTimeByID(j) -- 当前需要的金币
            if addContinue == true then
              if tonumber(onlineTime) >= tonumber(needTime) then
                perWidth = perWidth + programH
              else
                local lastPoint
                if j == 1 then
                  lastPoint = 0
                else
                  lastPoint = acOnlineRewardVoApi:getNeedTimeByID(j-1)
                end

                perWidth = perWidth + programH * ((onlineTime - lastPoint) / (needTime - lastPoint))
                addContinue = false
              end
            end
          end

        end

        local barWidth = totalH + rewardBtnH 

        AddProgramTimer(cell,ccp(40,barWidth/2),111,12,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",131,1,1)
        local per = tonumber(perWidth)/tonumber(barWidth) * 100
        local timerSpriteLv = cell:getChildByTag(111)
        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        timerSpriteLv:setRotation(-90)
        timerSpriteLv:setScaleX(barWidth/timerSpriteLv:getContentSize().width)
        local bg = cell:getChildByTag(131)
        -- bg:setVisible(false)
        bg:setRotation(-90)
        bg:setScaleX(barWidth/bg:getContentSize().width)

        return cell

   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acOnlineRewardDialog:refresh()
  if self ~= nil and self.tv ~= nil then
    local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
  end
end
function acOnlineRewardDialog:tick()
    self:refresh()
    if self.timeLb then
        local acVo = acOnlineRewardVoApi:getAcVo()
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acOnlineRewardDialog:update()
    local acVo = acOnlineRewardVoApi:getAcVo()
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

function acOnlineRewardDialog:dispose()
    self.normalHeight=nil
    self.extendSpTag=nil
    self.timeLbTab=nil
    self.isCloseing=nil
    self.buffTab=nil
    self=nil
end
