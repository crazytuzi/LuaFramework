acLeveling2Dialog=commonDialog:new()

function acLeveling2Dialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end


function acLeveling2Dialog:initTableView()
  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 330))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 430),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,100))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acLeveling2Dialog:doUserHandler()
  local titleW = G_VisibleSizeWidth - 20
  local titileH = 230
  local function cellClick(hd,fn,idx)
  end
  
  local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),cellClick)
  backSprie:setAnchorPoint(ccp(0.5,1))
  backSprie:setContentSize(CCSizeMake(titleW, titileH))
  backSprie:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 90));
  self.bgLayer:addChild(backSprie)
  
  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setPosition(ccp(titleW/2, titileH -10))
  backSprie:addChild(acLabel)
  acLabel:setColor(G_ColorGreen)

  local acVo = acLeveling2VoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,28)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp(titleW/2, titileH - 50))
  backSprie:addChild(messageLabel)

  print("G_curPlatName(): ", G_curPlatName())
  print("platFormCfg.gameName: ",platFormCfg.gameName)
  local gameName = ""
  if type(platFormCfg.gameName)=="table" then
    print("G_getCurChoseLanguage(): ",G_getCurChoseLanguage())
    for k,v in pairs(platFormCfg.gameName) do
      print("k: ",k)
      print("v: ",v)
    end
    gameName=platFormCfg.gameName[G_getCurChoseLanguage()]
  else
    gameName=platFormCfg.gameName
  end

  local desTv, desLabel = G_LabelTableView(CCSizeMake(G_VisibleSizeWidth-240, 130),getlocal("activity_leveling_content",{gameName}),25,kCCTextAlignmentLeft)
  desTv:setAnchorPoint(ccp(0,0))
  desTv:setPosition(ccp(210, 10))
  backSprie:addChild(desTv,5)
  backSprie:setTouchPriority(-(self.layerNum-1) * 20 - 4)
  desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
  desTv:setMaxDisToBottomOrTop(100)

  local sp=CCSprite:createWithSpriteFrameName("zhu_ji_di_building.png")
  sp:setScale(0.5)
  sp:setAnchorPoint(ccp(0,0))
  sp:setPosition(ccp(10, 20))
  backSprie:addChild(sp,7)
  
  -- 去升级按钮
  local function btnCallback(tag,object)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end

    PlayEffect(audioCfg.mouseClick)
    local maxLv = tonumber(playerVoApi:getMaxLvByKey("buildingMaxLevel"))
    if acLeveling2VoApi:getCurrentLev() >= maxLv then -- 指挥中心已达到满级
      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_leveling_fullLev"),28)
    else
      activityAndNoteDialog:gotoByTag(6)
    end
  end

  local btn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,4,getlocal("activity_leveling_btn"),25)
  btn:setAnchorPoint(ccp(0.5,0.5))
  local menu=CCMenu:createWithItem(btn)
  menu:setPosition(ccp(self.bgLayer:getContentSize().width/2,60))
  menu:setTouchPriority(-(self.layerNum-1)*20-5)
  self.bgLayer:addChild(menu,2)
  
end

function acLeveling2Dialog:eventHandler(handler,fn,idx,cel)
local autoHeight --自适应高度
if  G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" then 
        autoHeight=200
else
        autoHeight=270
end
  if fn=="numberOfCellsInTableView" then
    return 3
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(G_VisibleSizeWidth - 40,autoHeight)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local function bgClick(hd,fn,idx)
    end

    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),bgClick)
    titleBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, 40))
    titleBg:ignoreAnchorPointForPosition(false)
    titleBg:setAnchorPoint(ccp(0,1))
    titleBg:setPosition(ccp(0,autoHeight))
    cell:addChild(titleBg,1)

    local titleLabel=GetTTFLabel(getlocal("activity_leveling_lab"..(idx+1)),30)
    titleLabel:setAnchorPoint(ccp(0,0.5))
    titleLabel:setPosition(20,titleBg:getContentSize().height/2)
    titleBg:addChild(titleLabel)

    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, autoHeight-44))
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setPosition(ccp(10,4))
    cell:addChild(backSprie,1)
    
    -- "Leveling2":{"st":"1407218280","desVate":0.5,"type":1,"sortId":197,"reward":{"l70":{"u":[{"index":1,"gems":1000}]},"l60":{"u":[{"index":1,"r1":100000000},{"index":2,"r2":100000000},{"r3":100000000,"index":3},{"index":4,"r4":100000000},{"gold":100000000,"index":5}]}},"et":"1421992680","condition":[60,70]}

    local pic = nil
    local title = ""
    local desc = ""
    local descY = 0
    local descW = 0
    local desc_detail = ""
    if idx == 0 then
      pic = "tech_build_speed_up.png"
      local min,max = acLeveling2VoApi:getLvLimit()
      desc = getlocal("activity_leveling2_des1",{min, max})
    elseif idx == 1 then
      pic = "item_baoxiang_05.png"
      title = getlocal("activity_leveling_t2")
      local needLv = acLeveling2VoApi:getNeedLevel(idx)
      local k,rewardCfg,reward1,rewardNum = acLeveling2VoApi:getRewardCfgByLev(needLv)
      local reward2 = FormatItem(reward1, true)
      local rewardTip = G_showRewardTip(reward2, false, true)
      desc_detail = getlocal("activity_leveling_des2_detail",{rewardTip})
      desc = getlocal("activity_leveling_des2",{needLv,rewardNum})
    elseif idx == 2 then
      pic = "resourse_normal_gem.png"
      local needLv = acLeveling2VoApi:getNeedLevel(idx)
      local k,rewardCfg,reward1,rewardNum = acLeveling2VoApi:getRewardCfgByLev(needLv)
      local reward2 = FormatItem(reward1, true)
      local rewardTip = G_showRewardTip(reward2, false, true)
      title = getlocal("daily_award_tip_3",{rewardNum})
      desc_detail = getlocal("activity_leveling_des3",{needLv, rewardTip})
      desc = desc_detail
    end

    local function showInfoHandler(hd,fn,idx)
      if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        PlayEffect(audioCfg.mouseClick)
        local show = {name = title, pic = pic, desc = desc_detail}
        propInfoDialog:create(sceneGame,show,self.layerNum+1,true,nil,nil,nil,nil,nil,true)
      end
    end
    local icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(ccp(20 ,backSprie:getContentSize().height/2))
    backSprie:addChild(icon)
    if idx ~= 0 then
      icon:setTouchPriority(-(self.layerNum-1)*20-2)
      G_addRectFlicker(icon, 1.4,1.4)
    
      local titleLb=GetTTFLabel(title,25)
      titleLb:setAnchorPoint(ccp(0,1))
      titleLb:setPosition(ccp(icon:getPositionX() + icon:getContentSize().width + 10,backSprie:getContentSize().height - 10))
      backSprie:addChild(titleLb)
      titleLb:setColor(G_ColorGreen)
      
      
      local currentLev = acLeveling2VoApi:getCurrentLev()
      local needLv = acLeveling2VoApi:getNeedLevel(idx)

      descY = (backSprie:getContentSize().height - titleLb:getContentSize().height - 10)/2
      descW = backSprie:getContentSize().width - icon:getContentSize().width - 200

      -- 进度
      
      local schedule = GetTTFLabel(getlocal("scheduleChapter",{currentLev,needLv}),26)
      schedule:setAnchorPoint(ccp(0.5,1))
      schedule:setPosition(ccp(backSprie:getContentSize().width - 90,backSprie:getContentSize().height - 20))
      backSprie:addChild(schedule)
      if currentLev < needLv then
        schedule:setColor(G_ColorRed)
      else
        schedule:setColor(G_ColorYellowPro)
      end
      
      -- 领奖按钮
      local canReward = acLeveling2VoApi:checkIfCanReward(idx)
      local hadReward = acLeveling2VoApi:checkIfHadReward(idx)
      
      -- local flag =0
      if hadReward == true then
        local hadLabel = GetTTFLabel(getlocal("activity_hadReward"),25)
        hadLabel:setAnchorPoint(ccp(0.5,0))
        hadLabel:setPosition(ccp(backSprie:getContentSize().width - 90,30))
        backSprie:addChild(hadLabel)
      else
        local function rewardHandler(tag,object)
          if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then

            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            -- if flag ==0 then
            --   flag=1
              self:getReward(tag)
            -- elseif flag ==1 then
            --   do return end
            -- end
          end
        end   
        local rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardHandler,idx,getlocal("daily_scene_get"),25)
        rewardBtn:setAnchorPoint(ccp(0.5,0))
        local rewardMenu=CCMenu:createWithItem(rewardBtn)
        rewardMenu:setPosition(ccp(backSprie:getContentSize().width - 90,10))
        rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:addChild(rewardMenu)
        if canReward == true then 
          rewardBtn:setEnabled(true)
        else
          rewardBtn:setEnabled(false)
        end
      end
    else
      descY = backSprie:getContentSize().height/2
      descW = backSprie:getContentSize().width - icon:getContentSize().width - 30
    end

    local descLabel=GetTTFLabelWrap(desc,25,CCSizeMake(descW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLabel:setAnchorPoint(ccp(0,0.5))
    descLabel:setPosition(ccp(icon:getPositionX() + icon:getContentSize().width + 10,descY))
    backSprie:addChild(descLabel)

    if idx == 0 then
      local descLabel3 = GetTTFLabel(desc,25)
      local lastW = descLabel3:getContentSize().width % descW

      local descLabel2=GetTTFLabel(getlocal("activity_leveling_des1_2"),32)
      local py = descY - descLabel:getContentSize().height/2 - 10

      if lastW + 160 + descLabel2:getContentSize().width >= backSprie:getContentSize().width then
        lastW = 0
        py = py - 25
      end
      if G_getCurChoseLanguage()=="ru" then
        py =py-30
      end
      local changeWidth=lastW+170
      if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" then
        changeWidth=lastW+160
      elseif G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="de" then
        changeWidth=lastW+230
      elseif G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage()=="thai" then
        changeWidth=lastW+190
      elseif G_getCurChoseLanguage() =="ar" then
        changeWidth =150
        py = py -30
      end
      if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
        changeWidth=lastW+165
      end

      descLabel2:setAnchorPoint(ccp(0,0))
      descLabel2:setPosition(ccp(changeWidth,py))---------------
      backSprie:addChild(descLabel2)
      descLabel2:setColor(G_ColorYellowPro)
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

function acLeveling2Dialog:getReward(id)
  if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
    local function getRawardCallback(fn,data)
      if base:checkServerData(data)==true then
        local needLv = acLeveling2VoApi:getNeedLevel(id)
        local k,rewardCfg,reward1,rewardNum = acLeveling2VoApi:getRewardCfgByLev(needLv)

        local award=FormatItem(reward1,true)
        for k,v in pairs(award) do
          G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
        end
        G_showRewardTip(award,true)
        acLeveling2VoApi:afterGetReward(id)
      end
    end
    local needLv = acLeveling2VoApi:getNeedLevel(id)
    local cfg = acLeveling2VoApi:getRewardCfgByLev(needLv)
    socketHelper:getLeveling2Reward(cfg, getRawardCallback)
  end
end


function acLeveling2Dialog:tick()
end

function acLeveling2Dialog:update()
  local acVo = acLeveling2VoApi:getAcVo()
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


function acLeveling2Dialog:dispose()
  self=nil
end





