acArmsRaceDialog=commonDialog:new()

function acArmsRaceDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end


function acArmsRaceDialog:initTableView()
  acArmsRaceVoApi:cfgSort() 
  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 360))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 470),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,110))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acArmsRaceDialog:doUserHandler()
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
  

  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),34)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setPosition(ccp(titleW/2, titileH -10))
  acLabel:setColor(G_ColorGreen)
  backSprie:addChild(acLabel)

  local acVo = acArmsRaceVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,30)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp(titleW/2, titileH -50))
  backSprie:addChild(messageLabel)
  self.timeLb=messageLabel
  self:updateAcTime()

  local desLabel = GetTTFLabelWrap(getlocal("activity_armsRace_des"),25,CCSizeMake(G_VisibleSizeWidth-230, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  desLabel:setAnchorPoint(ccp(0,0.5))
  desLabel:setPosition(ccp(200, titileH/2-30))
  backSprie:addChild(desLabel,5)

  local sp=CCSprite:createWithSpriteFrameName("tan_ke_gong_chang_bulding.png")
  sp:setScale(0.8)
  sp:setPosition(ccp(100, 100))
  backSprie:addChild(sp,7)

  local function showRecode(tag,object)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)
    local openDialog = recodeDialog:new()
    openDialog:init(self.layerNum + 1)
  end  

local textSize = 25
    if platCfg.platCfgBMImage[G_curPlatName()]~=nil or G_curPlatName()=="androidsevenga" then
        textSize=20
    end
  local recodeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",showRecode,nil,getlocal("activity_armsRace_recode"),textSize)
  local recodeBtn=CCMenu:createWithItem(recodeItem)
  recodeBtn:setTouchPriority(-(self.layerNum-1)*20-5)
  recodeBtn:setAnchorPoint(ccp(0,0))
  recodeBtn:setPosition(ccp(200,60))
  self.bgLayer:addChild(recodeBtn)


  local function prodeceTank(tag,object)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)
    activityAndNoteDialog:gotoByTag(2, self.layerNum)
  end  

  local prodeceItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",prodeceTank,nil,getlocal("activity_armsRace_produce"),textSize)
  local prodeceBtn=CCMenu:createWithItem(prodeceItem)
  prodeceBtn:setTouchPriority(-(self.layerNum-1)*20-4)
  prodeceBtn:setAnchorPoint(ccp(1,0))
  prodeceBtn:setPosition(ccp(G_VisibleSizeWidth - 200,60))
  self.bgLayer:addChild(prodeceBtn)


end

function acArmsRaceDialog:openInfo()
  local sd=smallDialog:new()
  local labelTab={"",getlocal("activity_armsRace_notice"),"",getlocal("activity_armsRace_rule3"),"",getlocal("activity_armsRace_rule2"),"",getlocal("activity_armsRace_rule1")}
  local colorTab = {nil,G_ColorYellow,nil,G_ColorWhite,nil,G_ColorWhite,nil,G_ColorWhite}
  local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,colorTab,getlocal("activity_baseLeveling_ruleTitle"))
  sceneGame:addChild(dialogLayer,self.layerNum+1)
  dialogLayer:setPosition(ccp(0,0))

end


function acArmsRaceDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(acArmsRaceVoApi:getAcCfg())
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(G_VisibleSizeWidth - 40,180)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local cfg = acArmsRaceVoApi:getCfgByIndex(idx + 1)
    if cfg == nil then
      return cell
    end
    local rewardTank = tankCfg[tonumber(RemoveFirstChar(cfg.r))]
    local tank = tankCfg[tonumber(RemoveFirstChar(cfg.tankId))]
    if rewardTank == nil or tank == nil then
      return cell
    end

    local itemH = 180
    local itemW = G_VisibleSizeWidth - 40
    local CenterY = itemH/2
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, itemH - 4))
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setPosition(ccp(10,4))
    cell:addChild(backSprie,1)
    
    local count = acArmsRaceVoApi:getProduceNumByType(cfg.tankId)
    local needCount = cfg.n
    local schedule = GetTTFLabel(getlocal("scheduleChapter",{count,needCount}),26)
    schedule:setAnchorPoint(ccp(1,0))
    schedule:setPosition(ccp(backSprie:getContentSize().width - 55,CenterY + 10))
    backSprie:addChild(schedule)


    local canReward = false
    if count >= needCount then
      canReward = true
    end

    local function rewardHandler(tag,object)
      PlayEffect(audioCfg.mouseClick)
      self:getReward(tag)
    end   
    local rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardHandler,cfg.id,getlocal("daily_scene_get"),25)
    rewardBtn:setAnchorPoint(ccp(1,1))
    local rewardMenu=CCMenu:createWithItem(rewardBtn)
    rewardMenu:setPosition(ccp(backSprie:getContentSize().width - 10,CenterY))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:addChild(rewardMenu)
    if canReward == true then 
      rewardBtn:setEnabled(true)
    else
      rewardBtn:setEnabled(false)
    end
 
    
    

    local function showInfoHandler(hd,fn,idx)
      if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        tankInfoDialog:create(nil,tonumber(RemoveFirstChar(cfg.r)),self.layerNum+1, true)
      end
    end
    
    local icon
    local iconScaleX=1
    local iconScaleY=1
    icon = LuaCCSprite:createWithSpriteFrameName(rewardTank.icon,showInfoHandler)
    if icon:getContentSize().width>125 then
      iconScaleX=0.78*125/150
      iconScaleY=0.78*125/150
    else
      iconScaleX=0.78
      iconScaleY=0.78
    end
    icon:setScaleX(iconScaleX)
    icon:setScaleY(iconScaleY)
    icon:ignoreAnchorPointForPosition(false)
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(ccp(10 ,CenterY))
    icon:setIsSallow(false)
    icon:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:addChild(icon,1)
    
    local nameLabel = GetTTFLabel(getlocal(rewardTank.name), 28)
    nameLabel:setAnchorPoint(ccp(0,1))
    nameLabel:setPosition(icon:getPositionY() + 30, itemH - 20)
    nameLabel:setColor(G_ColorGreen)
    backSprie:addChild(nameLabel)

    local descLabel = GetTTFLabelWrap(getlocal("activity_armsRace_getDesc",{cfg.n,getlocal(tank.name)}),22,CCSizeMake(itemW - 300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLabel:setAnchorPoint(ccp(0,1))
    descLabel:setPosition(icon:getPositionY() + 30, CenterY)
    backSprie:addChild(descLabel)

    local numLabel=GetTTFLabel("x"..cfg.num,25)
    numLabel:setAnchorPoint(ccp(1,0))
    numLabel:setPosition(icon:getContentSize().width-10,0)
    icon:addChild(numLabel,1)
    numLabel:setScaleX(1/iconScaleX)
    numLabel:setScaleY(1/iconScaleY)


    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acArmsRaceDialog:getReward(id)
  if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
    local function getRawardCallback(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
        if sData and sData.data and sData.data.reward then
          local awardCfg = sData.data.reward
          local award=FormatItem(awardCfg,true)
          for k,v in pairs(award) do
            G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
            acArmsRaceVoApi:afterGetReward(id, v.num)
          end
          G_showRewardTip(award,true)

          acArmsRaceVoApi:cfgSort()
          local recordPoint = self.tv:getRecordPoint()
          self.tv:reloadData()
          self.tv:recoverToRecordPoint(recordPoint)
        end
      end
    end
    if acArmsRaceVoApi:checkIfCanRewardById(id) == true then
      local cfg=acArmsRaceVoApi:getCfgById(id)
      socketHelper:getArmsRaceReward(cfg.tankId, getRawardCallback)
    end
    
  end
end

function acArmsRaceDialog:updateAcTime()
    local acVo=acArmsRaceVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acArmsRaceDialog:tick()
  local acVo = acArmsRaceVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
        do return end
      end
    end

    if acVo.flag==0 then
      self:update()
      acVo.flag=1
    end
  end
  self:updateAcTime()
end

function acArmsRaceDialog:update()
  local acVo = acArmsRaceVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      acArmsRaceVoApi:cfgSort()
      local recordPoint = self.tv:getRecordPoint()
      self.tv:reloadData()
      self.tv:recoverToRecordPoint(recordPoint)
    end
  end
end


function acArmsRaceDialog:dispose()
  self.timeLb=nil
  self=nil
end





