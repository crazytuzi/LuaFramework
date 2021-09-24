acShareHappinessTab2={

}

function acShareHappinessTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.timeLabels = {}
    self.noTips = nil
    return nc
end

function acShareHappinessTab2:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    local function click(hd,fn,idx)
    end
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight - 230))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25, 30))
    self.bgLayer:addChild(tvBg)

    self:initTitles()
    self:initRewardBtn()
    self.noTips = GetTTFLabelWrap(getlocal("activity_shareHappiness_noGift"), 28,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noTips:setAnchorPoint(ccp(0.5,0.5))
    self.noTips:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight/2))
    self.bgLayer:addChild(self.noTips)
    self:updateTipsAndRewardBtn()

    self:initTableView()
    return self.bgLayer
end



function acShareHappinessTab2:initTableView()
  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-330),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
  self.tv:setAnchorPoint(ccp(0,0))
  self.tv:setPosition(ccp(25,120))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acShareHappinessTab2:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    local giftPackage = acShareHappinessVoApi:getGiftList()
    local len = 0
    if giftPackage ~= nil then
      len = SizeOfTable(giftPackage)
    end
    return len
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize = CCSizeMake(G_VisibleSizeWidth-50,150)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    
    local acVo = acShareHappinessVoApi:getAcVo()
    local giftPackage = acShareHappinessVoApi:getGiftList()
    local gift = nil
    if giftPackage ~= nil and SizeOfTable(giftPackage) > idx then
      gift = giftPackage[idx + 1]
    end
    if acVo then
      local bgH = 145
      local capInSetNew=CCRect(20, 20, 10, 10)
      local capInSet = CCRect(40, 40, 10, 10)
      local function cellClick1(hd,fn,idx)
      end

      local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
      backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-70, bgH))
      backSprie:ignoreAnchorPointForPosition(false)
      backSprie:setAnchorPoint(ccp(0,0))
      backSprie:setIsSallow(false)
      backSprie:setPosition(ccp(10,0))
      cell:addChild(backSprie,1)
      local w = (G_VisibleSizeWidth-60) / 3
      local function getX(index)
        return 5 + w * index+ w/2
      end
      
      local sid = acShareHappinessVoApi:getPropReward(gift.cd)
      local pCfg = propCfg[sid]
      if pCfg == nil then
        do
          return
        end
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

          local item = {name = getlocal(pCfg.name), pic= pCfg.icon, num = 1, desc = pCfg.description}
          propInfoDialog:create(sceneGame,item,self.layerNum+1)
        end
      end

      local boxIcon=LuaCCSprite:createWithSpriteFrameName(pCfg.icon,showInfoHandler)
      boxIcon:setAnchorPoint(ccp(0.5,0.5))
      boxIcon:setPosition(ccp(getX(0),bgH/2))
      boxIcon:setTouchPriority(-(self.layerNum-1)*20-2)
      cell:addChild(boxIcon,3)
    
      local nameLabel=GetTTFLabel(gift.um,25)
      nameLabel:setAnchorPoint(ccp(0.5,0.5))
      nameLabel:setPosition(getX(1),bgH/2)
      cell:addChild(nameLabel,2)
      
      local time = gift.st + 86400 - base.serverTime
      if time < 0 then
        time = 0
      end

      local timeLabel=GetTTFLabel(G_getTimeStr(time),25)
      timeLabel:setAnchorPoint(ccp(0.5,0.5))
      timeLabel:setPosition(getX(2),bgH/2)
      if time > 3600 then
        timeLabel:setColor(G_ColorYellowPro)
      else
        timeLabel:setColor(G_ColorRed)
      end
      cell:addChild(timeLabel,2)
      table.insert(self.timeLabels, {lb = timeLabel, t = gift.st + 86400})
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

function acShareHappinessTab2:initRewardBtn()
  local function getReward(tag,object)
    if self.tv ~= nil and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==true then
      do
        return
      end
    end

    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end

    PlayEffect(audioCfg.mouseClick)
    --领取奖励
    self:getAllGift()
  end

  local rewardBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",getReward,3,getlocal("activity_shareHappiness_getAll"),28)
  rewardBtn:setAnchorPoint(ccp(0.5, 0))
  self.rewardMenu=CCMenu:createWithItem(rewardBtn)
  self.rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,40))
  self.rewardMenu:setTouchPriority(-(self.layerNum-1)*20-5)
  self.bgLayer:addChild(self.rewardMenu) 

end

function acShareHappinessTab2:getAllGift()
  local function getRewardSuccess(fn,data)
    local ret,sData=base:checkServerData(data)
    if ret==true then
      if sData.clientReward ~= nil and sData.errorId == 0 then
        local clientReward = sData.clientReward
        local reward = {}
        reward["p"] = {}
        for k,v in pairs(clientReward) do
          if v ~= nil then
            table.insert(reward["p"], v)
          end
        end

        local awardTab=FormatItem(reward,true)
        for k,v in pairs(awardTab) do

          G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
        end
        G_showRewardTip(awardTab, true)
      elseif sData.errorId == 1 then
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_shareHappiness_notInAlliance"),nil,20)
      elseif sData.errorId > 0 then
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_shareHappiness_error"),nil,20)
      end
      if sData.data ~= nil then
        self.timeLabels = {}
        acShareHappinessVoApi:updateListData(sData.data)
      end
    end

  end
  if acShareHappinessVoApi:canReward() == true then
      socketHelper:getShareHappinessAllGifts(getRewardSuccess)
  end
end

function acShareHappinessTab2:update()
  self:updateTipsAndRewardBtn()
  self.timeLabels = {}
  self.tv:reloadData()
end

function acShareHappinessTab2:updateTipsAndRewardBtn()
  if acShareHappinessVoApi:canReward() == true then
    self.noTips:setVisible(false)
    self.rewardMenu:setVisible(true)
  else
    self.noTips:setVisible(true)
    self.rewardMenu:setVisible(false)
  end
end

function acShareHappinessTab2:tick()
  local hasEnd = false

  for k,v in pairs(self.timeLabels) do
    if v ~= nil and v.t ~= nil and v.lb ~= nil then
      local time = v.t - base.serverTime
      if time < 0 then
        hasEnd = true
        time = 0
      end
      if tolua.cast(v.lb,"CCLabelTTF") ~= nil then
        tolua.cast(v.lb,"CCLabelTTF"):setString(G_getTimeStr(time))
        if time >= 3600 then
          tolua.cast(v.lb,"CCLabelTTF"):setColor(G_ColorYellowPro)
        elseif time > 0 and time < 3600 then
          tolua.cast(v.lb,"CCLabelTTF"):setColor(G_ColorRed)
        end
      end
    end
  end

  if hasEnd == true then
    self.timeLabels = {}
    acShareHappinessVoApi:removeGift()
  end
end


--用户处理特殊需求,没有可以不写此方法
function acShareHappinessTab2:initTitles()
    local w = (G_VisibleSizeWidth - 40) / 3
    local function getX(index)
      return 20 + w * index+ w/2
    end

    local height=G_VisibleSizeHeight-180
    local lbSize=22
    local widthSpace=80
    
    local giftLabel=GetTTFLabel(getlocal("activity_shareHappiness_sub2_gift"),lbSize)
    giftLabel:setPosition(getX(0),height)
    self.bgLayer:addChild(giftLabel,1)
    giftLabel:setColor(G_ColorGreen)

    local playerNameLabel=GetTTFLabel(getlocal("activity_shareHappiness_sub2_sharer"),lbSize)
    playerNameLabel:setPosition(getX(1),height)
    self.bgLayer:addChild(playerNameLabel,1)
    playerNameLabel:setColor(G_ColorGreen)
    
    local valueLabel=GetTTFLabel(getlocal("activity_shareHappiness_sub2_time"),lbSize)
    valueLabel:setPosition(getX(2),height)
    self.bgLayer:addChild(valueLabel,1)
    valueLabel:setColor(G_ColorGreen)

end

function acShareHappinessTab2:dispose()
  self.bgLayer:removeFromParentAndCleanup(true)
  self.bgLayer=nil
  self.tv=nil
  self.layerNum=nil
  self.timeLabels = nil
  self.noTips = nil
  self = nil 
end
