acBaseLevelingDialog=commonDialog:new()

function acBaseLevelingDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.cd = nil
    return nc
end


function acBaseLevelingDialog:initTableView()
  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 360))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 380),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,20))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acBaseLevelingDialog:doUserHandler()
  local titleW = G_VisibleSizeWidth - 20
  local titileH = 260
  local function cellClick(hd,fn,idx)
  end
  
  local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),cellClick)
  backSprie:setAnchorPoint(ccp(0.5,1))
  backSprie:setContentSize(CCSizeMake(titleW, titileH))
  backSprie:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 90));
  self.bgLayer:addChild(backSprie)

  local function touch(tag,object)
    self:openInfo()
  end

  local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,1))
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(titleW - 10, titileH -10))
  backSprie:addChild(menuDesc,1)
  


  local cdLabel = GetTTFLabel(getlocal("acCD"),30)
  cdLabel:setAnchorPoint(ccp(0.5,1))
  cdLabel:setPosition(ccp(titleW/2, titileH -10))
  backSprie:addChild(cdLabel,2)

  local vo = acBaseLevelingVoApi:getAcVo()
  if vo ~= nil then
    local timeLabel
    if vo.acEt >  base.serverTime then
      local showTime = G_getTimeStr(vo.acEt - base.serverTime)
      timeLabel = tostring(showTime)
    else
      timeLabel = getlocal("acOver")
    end
    self.cd = GetTTFLabel(timeLabel, 34)
    self.cd:setAnchorPoint(ccp(0.5,1))
    self.cd:setPosition(ccp(titleW/2, titileH - 50))
    self.cd:setColor(G_ColorYellowPro)
    backSprie:addChild(self.cd,3)
  end

  local desLabel = GetTTFLabelWrap(getlocal("activity_baseLeveling_des"),28,CCSizeMake(G_VisibleSizeWidth-230, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  desLabel:setAnchorPoint(ccp(0,0.5))
  desLabel:setPosition(ccp(200, titileH/2-30))
  backSprie:addChild(desLabel,5)

  local sp=CCSprite:createWithSpriteFrameName("zhu_ji_di_building.png")
  sp:setScale(0.5)
  sp:setPosition(ccp(100, titileH/2))
  backSprie:addChild(sp,7)

  
end

function acBaseLevelingDialog:openInfo()
  local sd=smallDialog:new()
  local labelTab={"",getlocal("activity_baseLeveling_ruleTip"),"\n",getlocal("activity_baseLeveling_rule")}
  local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,nil,getlocal("activity_baseLeveling_ruleTitle"))
  sceneGame:addChild(dialogLayer,self.layerNum+1)
  dialogLayer:setPosition(ccp(0,0))

end

function acBaseLevelingDialog:updateCd()
  if self.cd ~= nil then
    local vo = acBaseLevelingVoApi:getAcVo()
    if vo ~= nil then
      local timeLabel
      if vo.acEt >  base.serverTime then
        local showTime = G_getTimeStr(vo.acEt - base.serverTime)
        timeLabel = tostring(showTime)
      else
        timeLabel = getlocal("acOver")
      end
      self.cd:setString(timeLabel)
    end    
  end
end

function acBaseLevelingDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(acBaseLevelingVoApi:getAcCfg())
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(G_VisibleSizeWidth - 40,120)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local len = SizeOfTable(acBaseLevelingVoApi:getAcCfg())
    local CenterY = 60
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, 116))
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setPosition(ccp(10,4))
    cell:addChild(backSprie,1)

    local canReward = acBaseLevelingVoApi:checkIfCanRewardById(idx + 1)
    local hadReward = acBaseLevelingVoApi:checkIfHadRewardById(idx + 1)
    -- 添加对号或叉号
    -- local signSp
    -- if canReward == true then
    --   signSp = CCSprite:createWithSpriteFrameName("IconCheck.png")
    -- else
    --   signSp = CCSprite:createWithSpriteFrameName("IconFault.png")
    -- end
    -- signSp:setAnchorPoint(ccp(0,0.5))
    -- signSp:setPosition(ccp(10,CenterY))
    -- backSprie:addChild(signSp,1)
    

    local needLv = acBaseLevelingVoApi:getNeedCenterLevById(idx + 1)
    
    local lvLabel = GetTTFLabel(getlocal("fightLevel",{needLv}),25)
    lvLabel:setAnchorPoint(ccp(0,0.5))
    lvLabel:setPosition(ccp(20,CenterY))
    backSprie:addChild(lvLabel,2)

    if hadReward == true then
      local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
      rightIcon:setAnchorPoint(ccp(1,0.5))
      rightIcon:setPosition(ccp(backSprie:getContentSize().width - 10,CenterY))
      backSprie:addChild(rightIcon)

      -- 显示已领取文字
      -- local hadLabel = GetTTFLabel(getlocal("activity_hadReward"),25)
      -- hadLabel:setAnchorPoint(ccp(1,0.5))
      -- hadLabel:setPosition(ccp(backSprie:getContentSize().width - 10,CenterY))
      -- backSprie:addChild(hadLabel)
    else
      local function rewardHandler(tag,object)
        PlayEffect(audioCfg.mouseClick)
        self:getReward(tag)
      end   
      local rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardHandler,idx + 1,getlocal("daily_scene_get"),25)
      rewardBtn:setAnchorPoint(ccp(1,0.5))
      local rewardMenu=CCMenu:createWithItem(rewardBtn)
      rewardMenu:setPosition(ccp(backSprie:getContentSize().width - 10,CenterY))
      rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
      backSprie:addChild(rewardMenu)
      if canReward == true then 
        rewardBtn:setEnabled(true)
      else
        rewardBtn:setEnabled(false)
      end
    end
 
    
    local award=FormatItem(acBaseLevelingVoApi:getRewardById(idx+1),true)

    local function showInfoHandler(hd,fn,idx)
      if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        local item=award[idx]
        if item and item.name and item.pic and item.num and item.desc then
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
        icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
        if icon:getContentSize().width>100 then
          iconScaleX=0.78*100/150
          iconScaleY=0.78*100/150
        else
          iconScaleX=0.78
          iconScaleY=0.78
        end
        icon:setScaleX(iconScaleX)
        icon:setScaleY(iconScaleY)
        icon:ignoreAnchorPointForPosition(false)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(ccp(100+(k-1)*85 ,CenterY))
        icon:setIsSallow(false)
        icon:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:addChild(icon,1)
        icon:setTag(k)

        if tostring(v.name)~=getlocal("honor") then
          local numLabel=GetTTFLabel("x"..v.num,25)
          numLabel:setAnchorPoint(ccp(1,0))
          numLabel:setPosition(icon:getContentSize().width-10,0)
          icon:addChild(numLabel,1)
          numLabel:setScaleX(1/iconScaleX)
          numLabel:setScaleY(1/iconScaleY)
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

function acBaseLevelingDialog:getReward(id)
  if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
    local function getRawardCallback(fn,data)
      if base:checkServerData(data)==true then
        local award=FormatItem(acBaseLevelingVoApi:getRewardById(id),true)
        for k,v in pairs(award) do
          G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
        end
        G_showRewardTip(award,true)
        acBaseLevelingVoApi:afterGetReward(id)
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
      end
    end
    socketHelper:getBaseLevelingReward(acBaseLevelingVoApi:getNeedCenterLevById(id), getRawardCallback)
  end
end


function acBaseLevelingDialog:tick()
   self:updateCd()
end

function acBaseLevelingDialog:update()
  local acVo = acBaseLevelingVoApi:getAcVo()
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


function acBaseLevelingDialog:dispose()
  self.cd = nil
  self=nil
end





