acAllianceFightTab1={
   rewardBtnState = nil,
}

function acAllianceFightTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil

    self.des = nil -- 活动说明信息
    self.desH = nil -- 活动说明信息的高度
    self.rewardMenu = nil

    return nc;

end

function acAllianceFightTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum

    local function click(hd,fn,idx)
    end
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight - 300))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25, 130))
    self.bgLayer:addChild(tvBg)
    self.des = {}
    self.desH = {}
    for i=1,4 do
      local tip
      if i == 1 then
        tip = getlocal("activity_allianceFight_acContent")
      else
        tip = getlocal("activity_allianceFight_rule"..(i - 1))
      end
      local desH,des = self:getDes(tip,24)
      table.insert(self.desH, desH)
      table.insert(self.des, des)
    end
    
    self:initTableView()
    
    self:updateRewardBtn()


    return self.bgLayer
end

function acAllianceFightTab1:getDes(content, size)
  local showMsg=content or ""
  local width=G_VisibleSizeWidth - 100
  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return tonumber(height), messageLabel
end

-- 更新领奖按钮显示
function acAllianceFightTab1:updateRewardBtn()

  local state = 1
  if acAllianceFightVoApi:hadReward() == true then
      state = 3
  elseif acAllianceFightVoApi:canReward() == true then
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
      rewardBtn:setAnchorPoint(ccp(0.5, 0))
      self.rewardMenu=CCMenu:createWithItem(rewardBtn)
      self.rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,40))
      self.rewardMenu:setTouchPriority(-(self.layerNum-1)*20-8)
      self.bgLayer:addChild(self.rewardMenu) 
  end

end

function acAllianceFightTab1:initTableView()
  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  local height=0;
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-320),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(25,140))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)

end

function acAllianceFightTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 4
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    if idx == 0 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,100)
    elseif idx == 1 then
      if self.desH ~= nil and self.desH[1] ~= nil then
        tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[1] + 50)
      else
        tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,150)
      end
    elseif idx == 2 then
        if self.desH ~= nil and self.desH[2] ~= nil and self.desH[3] ~= nil and self.desH[4] ~= nil then
          local desH = self.desH[2] + self.desH[3] + self.desH[4]
          tmpSize = CCSizeMake(G_VisibleSizeWidth - 50, desH + 50)
        else
          tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,150)
        end
    else
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,100 * SizeOfTable(acAllianceFightVoApi:getAcCfg()) + 40)
    end
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local bgH
    if idx == 0 then
      bgH = 100
      local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),28)
      timeTime:setAnchorPoint(ccp(0,0.5))
      timeTime:setColor(G_ColorGreen)
      timeTime:setPosition(ccp(10,bgH - 30))
      cell:addChild(timeTime)

      local rewardTimeStr = GetTTFLabel(getlocal("recRewardTime"),28)
      rewardTimeStr:setAnchorPoint(ccp(0,0.5))
      rewardTimeStr:setColor(G_ColorYellowPro)
      rewardTimeStr:setPosition(ccp(10,bgH - 80))
      cell:addChild(rewardTimeStr)

      local acVo = acAllianceFightVoApi:getAcVo()
      if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setAnchorPoint(ccp(0,0.5))
        timeLabel:setPosition(ccp(150,bgH - 30))
        cell:addChild(timeLabel)

        local timeStr2=activityVoApi:getActivityRewardTimeStr(acVo.acEt,60,86400)
        local timeLabel2=GetTTFLabel(timeStr2,26)
        timeLabel2:setAnchorPoint(ccp(0,0.5))
        timeLabel2:setPosition(ccp(150,bgH - 80))
        cell:addChild(timeLabel2)

        self.timeLb=timeLabel
        self.rewardTimeLb=timeLabel2
        G_updateActiveTime(acVo,self.timeLb,self.rewardTimeLb)
      end
    elseif idx == 1 then
      if self.desH ~= nil and self.desH[1] ~= nil then
        bgH = self.desH[1] + 50
      else
        bgH = 150
      end
      local contentLabel = GetTTFLabel(getlocal("activity_contentLabel"),28)
      contentLabel:setAnchorPoint(ccp(0,1))
      contentLabel:setColor(G_ColorYellowPro)
      contentLabel:setPosition(ccp(10,bgH - 10))
      cell:addChild(contentLabel)

      if self.des ~= nil and self.des[1] ~= nil then
        local desLabel = self.des[1]
        desLabel:setAnchorPoint(ccp(0,0))
        desLabel:setPosition(ccp(35,10))
        cell:addChild(desLabel)
      end
      
    elseif idx == 2 then
      if self.desH ~= nil and self.desH[2] ~= nil and self.desH[3] ~= nil and self.desH[4] ~= nil then
        bgH = self.desH[2] + self.desH[3] + self.desH[4] + 50

        local contentLabel = GetTTFLabel(getlocal("activity_ruleLabel"),28)
        contentLabel:setAnchorPoint(ccp(0,1))
        contentLabel:setColor(G_ColorYellowPro)
        contentLabel:setPosition(ccp(10,bgH - 10))
        cell:addChild(contentLabel)
        

        if self.des ~= nil and self.des[1] ~= nil then
          local theH = bgH - 50
          for i=2,4 do
            local desLabel = self.des[i]
            theH = theH - self.desH[i]
            desLabel:setAnchorPoint(ccp(0,0))
            desLabel:setPosition(ccp(35,theH))
            cell:addChild(desLabel)
          end
        end

      end
      
    elseif idx == 3 then
      local acCfg = acAllianceFightVoApi:getAcCfg()
      local rewardLen = SizeOfTable(acCfg)
      local sigleH = 100
      bgH = sigleH * rewardLen
      local titleH = 40
      
      local contentLabel = GetTTFLabel(getlocal("activity_awardLabel"),28)
      contentLabel:setAnchorPoint(ccp(0,1))
      contentLabel:setColor(G_ColorYellowPro)
      contentLabel:setPosition(ccp(10,bgH + titleH - 10))
      cell:addChild(contentLabel)

      local cfg
      local rank
      local award
      local h = 0
      local awardTitleLabel
      local rewardLabel
      local gemIcon
      for i=1,rewardLen do
          h = sigleH * (rewardLen - i)
          cfg = acCfg[i]
          rank = tonumber(cfg.rank)
          award = cfg.award
          awardTitleLabel = GetTTFLabel(getlocal("activity_allianceFight_awardTitle"..rank), 26)
          awardTitleLabel:setAnchorPoint(ccp(0,1))
          awardTitleLabel:setPosition(ccp(35, h + sigleH - 10))
          cell:addChild(awardTitleLabel)
          
          rewardLabel = GetTTFLabel(tostring(award["u"]["gems"]), 26)
          rewardLabel:setAnchorPoint(ccp(1,0))
          rewardLabel:setPosition(ccp(200, h + 10))
          rewardLabel:setColor(G_ColorYellowPro)
          cell:addChild(rewardLabel)


          gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
          gemIcon:setAnchorPoint(ccp(0,0))
          gemIcon:setPosition(ccp(210, h + 10))
          cell:addChild(gemIcon)
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


function acAllianceFightTab1:getReward()
  local function getRewardSuccess(fn,data)
    self:getRewardSuccess(fn,data)
  end
  PlayEffect(audioCfg.mouseClick)
  if acAllianceFightVoApi:canReward() == true then
    socketHelper:getAllianceFightReward(acAllianceFightVoApi.myRankInAlliance, getRewardSuccess)
  end
end

function acAllianceFightTab1:getRewardSuccess(fn,data)
  local ret,sData=base:checkServerData(data)
  if ret==true then        
    local reward = acAllianceFightVoApi:getMyReward()
    local awardTab=FormatItem(reward,true)
    for k,v in pairs(awardTab) do
      v.num = v.num/10
      G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
    end
    G_showRewardTip(awardTab, true)

    acAllianceFightVoApi:afterGetReward()
    self:updateRewardBtn() -- 更新领奖按钮
  elseif sData.ret==-1975 then
    acAllianceFightVoApi:update()
  -- 下面代码是初始时设计的，只要玩家所在军团达到领奖要求，领奖按钮就可以点击，flag == 0 表示玩家军团内战力排名不在前10名，不能领奖
  -- elseif sData.flag ~= nil and sData.flag == 0 then
  --   local sd=smallDialog:new()
  --   local labelTab={"\n",getlocal("activity_allianceLevel_getRewardWrong"),"\n"}
  --   local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,nil,nil)
  --   sceneGame:addChild(dialogLayer,self.layerNum+1)
  end
end

function acAllianceFightTab1:tick()
    if self.timeLb and self.rewardTimeLb then
        local acVo = acAllianceFightVoApi:getAcVo()
        G_updateActiveTime(acVo,self.timeLb,self.rewardTimeLb)
    end
end

function acAllianceFightTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.rewardMenu =nil
    self.des = nil
    self.desH = nil -- 活动说明信息的高度
    self.tv=nil
    self.rewardBtnState = nil
    self.timeLb=nil
    self = nil
end
