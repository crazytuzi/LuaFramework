acFbRewardTab1={
   rewardBtnState = 0,
}

function acFbRewardTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil;
    self.bgLayer=nil;
   
    self.layerNum=nil;

    self.des = nil -- 活动介绍信息集合
    self.rewardMenu = nil

    return nc;

end

function acFbRewardTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self:initTableView()
    
    self:updateRewardBtn()
    local function gotoFb(tag,object)
      if G_checkClickEnable()==false then
        do
          return
        end
      end
      local buildVo=buildingVoApi:getBuildingVoByBtype(15)[1]--军团建筑
      if base.isAllianceSwitch==0 then
        -- 军团功能未开放
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_willOpen"),nil,self.layerNum + 1)
      elseif buildVo == nil or buildVo.status > 0  then
        -- 军团等级不足
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_fbReward_lvLowTip"),nil,self.layerNum + 1)
      elseif allianceVoApi:isHasAlliance()==false then
        -- 玩家没有军团
        local function gotoAlliancePanel( ... )
          activityAndNoteDialog:gotoAlliance(false)   
        end
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_fbReward_noAllianceTip"),nil,self.layerNum + 1, nil, gotoAlliancePanel)
      else
        activityAndNoteDialog:gotoAlliance(true)
      end
    end

    local fbBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",gotoFb,1,getlocal("activity_fbReward_btnSwitch"),28,501)

    
    local fbMenu=CCMenu:createWithItem(fbBtn)
    fbMenu:setPosition(ccp(G_VisibleSizeWidth-180,70))
    fbMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.bgLayer:addChild(fbMenu)

    return self.bgLayer
end

-- 更新领奖按钮显示
function acFbRewardTab1:updateRewardBtn()

  local state = 0
  local selfAlliance = allianceVoApi:getSelfAlliance()
  if acFbRewardVoApi:hadReward() == true then
      state = 3
  elseif acFbRewardVoApi:canReward() == true then
      state = 2
  else
      state = 1
  end
  if self.rewardBtnState ~= state then
      if self.rewardMenu ~= nil then
        self.bgLayer:removeChild(self.rewardMenu,true)
        self.rewardMenu = nil
      end
      self.rewardBtnState = state
      local function hadReward(tag,object)
      end

      local function getReward(tag,object)
        if G_checkClickEnable()==false then
          do
            return
          end
        end
        --领取奖励
        self:getReward()
      end

      local rewardBtn
      if state == 3 then
          rewardBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",hadReward,3,getlocal("activity_hadReward"),28)
          rewardBtn:setEnabled(false)
      else
        rewardBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",getReward,3,getlocal("newGiftsReward"),28)
        if state == 2 then
          rewardBtn:setEnabled(true)
        elseif state == 1 then
          rewardBtn:setEnabled(false)
        end
      end
      self.rewardMenu=CCMenu:createWithItem(rewardBtn)
      self.rewardMenu:setPosition(ccp(180,70))
      self.rewardMenu:setTouchPriority(-(self.layerNum-1)*20-8)
      self.bgLayer:addChild(self.rewardMenu) 
  end

end


function acFbRewardTab1:initDesContent()
  self.des = {}
  local width = G_VisibleSizeWidth - 100
  local h, msg = self:getDes(getlocal("activity_fbReward_conDetail"),width,24,true)
  self.des[1] = {h = h, msg = msg}
  h, msg = self:getDes(getlocal("activity_fbReward_rulDetail"),width,24,true)
  self.des[2] = {h = h, msg = msg}
  h, msg = self:getDes(getlocal("activity_fbReward_rewDetail"),width,24,true)
  self.des[3] = {h = h, msg = msg}
  h, msg = self:getDes(getlocal("activity_fbReward_getDetail"),width,24,true)
  self.des[4] = {h = h, msg = msg}
  h, msg = self:getDes(getlocal("activity_fbReward_propDetail"),width,24,true)
  self.des[5] = {h = h, msg = msg}
  width = width - 30
  h, msg = self:getDes(getlocal("activity_fbReward_chestDes"),width,24,true)
  self.des[6] = {h = h, msg = msg}
  h, msg = self:getDes(getlocal("activity_fbReward_keyDes"),width,24,true)
  self.des[7] = {h = h, msg = msg}
end

function acFbRewardTab1:getDes(content, width,size, dimensions)
  local showMsg=content or ""
  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  local height=messageLabel:getContentSize().height+20
  if dimensions == true then
    messageLabel:setDimensions(CCSizeMake(width, height+50))
  end
  return height, messageLabel
end

function acFbRewardTab1:initTableView()
  self:initDesContent()
  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  local height=0;
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-300),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(10,120))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)

end

function acFbRewardTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 8
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    if idx == 0 then
      local cellhight = 130
       local acVo = acFbRewardVoApi:getAcVo()
        if acVo then
            local acTitle = GetTTFLabelWrap(getlocal("activity_fbReward_title"),40,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            local subTitle = GetTTFLabel(getlocal("activity_fbReward_time"),30)
            local timeLabel = GetTTFLabel(activityVoApi:getActivityTimeStr(acVo.st,acVo.et-86400),26)
            cellhight = acTitle:getContentSize().height+subTitle:getContentSize().height+timeLabel:getContentSize().height + 40
        end
        tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,cellhight)
    else
        tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.des[idx].h + 60)
    end
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local acVo = acFbRewardVoApi:getAcVo()
    if acVo then
      local subTitle
      local subTitle2
      local content
      if idx == 0 then

        local timeSize = 26
        local timeShowWidth = 0
        if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" then
            timeSize =23
            timeShowWidth =30
        end 

        local timeLabel = GetTTFLabel(activityVoApi:getActivityTimeStr(acVo.st,acVo.et-86400),timeSize)
        timeLabel:setAnchorPoint(ccp(0,0))
        timeLabel:setPosition(ccp(230+timeShowWidth, 20+timeLabel:getContentSize().height+10))
        cell:addChild(timeLabel)

        local rewardTimeLabel = GetTTFLabel(activityVoApi:getActivityRewardTimeStr(acVo.et-86400,60,86400),timeSize)
        rewardTimeLabel:setAnchorPoint(ccp(0,0))
        rewardTimeLabel:setPosition(ccp(230+timeShowWidth, 20+rewardTimeLabel:getContentSize().height-25))
        cell:addChild(rewardTimeLabel)
        self.timeLb=timeLabel
        self.rewardTimeLb=rewardTimeLabel
        G_updateActiveTime(acVo,self.timeLb,self.rewardTimeLb,nil,true)

        subTitle = GetTTFLabel(getlocal("activity_timeLabel"),timeSize)
        subTitle:setColor(G_ColorGreen)
        subTitle:setAnchorPoint(ccp(0,0))
        subTitle:setPosition(ccp(70, 20+timeLabel:getContentSize().height+10))
        cell:addChild(subTitle)

        subTitle2 = GetTTFLabel(getlocal("recRewardTime"),timeSize)
        subTitle2:setColor(G_ColorYellowPro)
        subTitle2:setAnchorPoint(ccp(0,0))
        subTitle2:setPosition(ccp(70, 20+timeLabel:getContentSize().height-25))
        cell:addChild(subTitle2)


        local acTitle = GetTTFLabelWrap(getlocal("activity_fbReward_title"),40,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        acTitle:setColor(G_ColorYellowPro)
        acTitle:setAnchorPoint(ccp(0.5,0))
        acTitle:setPosition(ccp(G_VisibleSizeWidth/2, 20+timeLabel:getContentSize().height+10+subTitle:getContentSize().height))
        cell:addChild(acTitle)
       
        
      else
        local spW = 0
        if idx == 1 then
          subTitle = GetTTFLabel(getlocal("activity_fbReward_con"),30)
        elseif idx == 2 then
          subTitle = GetTTFLabel(getlocal("activity_fbReward_rul"),30)
        elseif idx == 3 then
          subTitle = GetTTFLabel(getlocal("activity_fbReward_rew"),30)
        elseif idx == 4 then
          subTitle = GetTTFLabel(getlocal("activity_fbReward_get"),30)
        elseif idx == 5 then
          subTitle = GetTTFLabel(getlocal("activity_fbReward_prop"),30)
        elseif idx == 6 then
          local chestSp=CCSprite:createWithSpriteFrameName("SeniorBox.png")
          chestSp:setScale(0.5)
          spW = chestSp:getContentSize().width * 0.5
          chestSp:setPosition(ccp(20+spW/2,self.des[idx].h + 25))
          cell:addChild(chestSp)
          
          subTitle = GetTTFLabel(getlocal("activity_fbReward_chest"),30)
        elseif idx == 7 then
          local keySp=CCSprite:createWithSpriteFrameName("KeyIcon.png")
          keySp:setScale(0.7)
          spW = keySp:getContentSize().width * 0.5 + 10
          keySp:setPosition(ccp(28+spW/2,self.des[idx].h + 30))
          cell:addChild(keySp)
          spW = spW + 13
          subTitle = GetTTFLabel(getlocal("activity_fbReward_key"),30)
        end
        subTitle:setColor(G_ColorGreen)
        subTitle:setAnchorPoint(ccp(0,0))
        subTitle:setPosition(ccp(20+spW, self.des[idx].h +20))
        cell:addChild(subTitle)
        content = self.des[idx].msg
        content:setAnchorPoint(ccp(0,1))
        if spW > 0 then
          content:setPosition(ccp(spW,self.des[idx].h+10))
        else
          content:setPosition(ccp(45,self.des[idx].h+10))
        end
        cell:addChild(content)
      end
      if idx ~= 6 then
        local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSprite:setScaleX((G_VisibleSizeWidth - 50)/lineSprite:getContentSize().width)
        lineSprite:setAnchorPoint(ccp(0.5,0))
        lineSprite:setPosition(ccp((G_VisibleSizeWidth - 50)/2,0))
        cell:addChild(lineSprite,2)
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


function acFbRewardTab1:getReward()
  local function getRewardSuccess(fn,data)
    self:getRewardSuccess(fn,data)
  end
  PlayEffect(audioCfg.mouseClick)
  if acFbRewardVoApi.selfList ~= nil and acFbRewardVoApi.selfList.rank > 0 and acFbRewardVoApi.selfList.rank < 4 then
      socketHelper:getFbReward(acFbRewardVoApi.selfList.rank, getRewardSuccess)
  end
end

function acFbRewardTab1:getRewardSuccess(fn,data)
  -- local sData={data={alliData={alliance={
  --     level=1,
  --     level_point=10,
  --     skills={
  --         s1={1,10},
  --         s2={1,5},
  --         s3={1,2},

  --     },
  -- }}}}
  local ret,sData=base:checkServerData(data)
  if ret==true then        
      local getAexp = false

      if sData.data.alliData ~= nil and type(sData.data.alliData)=="table" then
          if SizeOfTable(sData.data.alliData) > 0 then
              getAexp = true
          end
          if sData.data.alliData.alliance then
              local aData=sData.data.alliData.alliance
              local selfAlliance=allianceVoApi:getSelfAlliance()
              if selfAlliance then
                  local aid=selfAlliance.aid
                  local uid=playerVoApi:getUid()

                  if aData.level and aData.level_point then
                      allianceVoApi:setAllianceExp(tonumber(aData.level))
                      allianceVoApi:setAllianceExp(tonumber(aData.level_point))

                      local params={uid,nil,nil,0,tonumber(aData.level),tonumber(aData.level_point),-1}
                      chatVoApi:sendUpdateMessage(9,params,aid+1)
                  end

                  if aData.skills then
                      for k,v in pairs(aData.skills) do
                          if v and tonumber(v[1]) and tonumber(v[2]) then
                              local skillId=tonumber(k) or tonumber(RemoveFirstChar(k))
                              allianceSkillVoApi:setSkillLevel(skillId,tonumber(v[1]))
                              allianceSkillVoApi:setSkillExp(skillId,tonumber(v[2]))
                              
                              local params={uid,nil,nil,skillId,tonumber(v[1]),tonumber(v[2]),-1}
                              chatVoApi:sendUpdateMessage(9,params,aid+1)
                          end
                      end
                  end

              end
          end
      end

      local reward = acFbRewardVoApi:getRewardByRank(getAexp)
      local awardTab=FormatItem(reward,true)
      G_showRewardTip(awardTab, true)

      acFbRewardVoApi:afterGetReward()
      self:updateRewardBtn() -- 更新领奖按钮
  end
end

function acFbRewardTab1:tick()
    if self.timeLb and self.rewardTimeLb then
        local acVo = acFbRewardVoApi:getAcVo()
        G_updateActiveTime(acVo,self.timeLb,self.rewardTimeLb,nil,true)
    end
end

function acFbRewardTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.rewardMenu =nil
    self.des = nil
    self.timeLb = nil
    self.rewardTimeLb = nil
    self = nil
end
