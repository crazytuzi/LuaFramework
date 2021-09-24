acShareHappinessTab1={
   rechargeBtnState = nil,
}

function acShareHappinessTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil
    self.acTimeH = 260
    self.des = nil -- 活动说明信息
    self.desH = nil -- 活动说明信息的高度
    self.rechargeMenu = nil
    self.rechargeBtnState = nil

    self.currentPhase = nil -- 当前阶段

    self.timeTime = nil
    self.timeLabel = nil
    self.iconSp = nil
    self.tvBg = nil

    return nc

end

function acShareHappinessTab1:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    
    local function touch(tag,object)
      if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self:openInfo()
      end
    end

    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setScaleX(0.9)
    menuItemDesc:setScaleY(0.9)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)-- 此按钮的优先级一定要比topforbidSp上下遮盖层的优先级高，否则将不会被点击
    menuDesc:setPosition(ccp(G_VisibleSizeWidth - 100, G_VisibleSizeHeight - 220))
    self.bgLayer:addChild(menuDesc)

    self:updateInit()


    return self.bgLayer
end

function acShareHappinessTab1:updateInit()
  local phase = acShareHappinessVoApi:getCurrentPhase()
    self.currentPhase = phase

    local tip = getlocal("activity_shareHappiness_des_phase"..phase)
    self.desH,self.des = self:getDes(tip,24)
    
    self.timeTime = nil
    if phase == 1 then
      self.timeTime = GetTTFLabel(getlocal("activity_timeLabel"),28)
    elseif phase == 2 then
      self.timeTime = GetTTFLabel(getlocal("activity_shareHappiness_lastTimeTitle"),28)
    end
    self.timeTime:setAnchorPoint(ccp(0.5,1))
    self.timeTime:setColor(G_ColorYellowPro)
    self.timeTime:setPosition(ccp((G_VisibleSizeWidth - 50)/2,G_VisibleSizeHeight - 180))
    self.bgLayer:addChild(self.timeTime)

    local acVo = acShareHappinessVoApi:getAcVo()
    if acVo ~= nil then
      local timeStr = nil 
      if phase == 1 then
        timeStr = activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
      elseif phase == 2 then
        timeStr = getlocal("activity_shareHappiness_end",{G_getDataTimeStr(acVo.et)})
      end
      self.timeLabel=GetTTFLabel(timeStr,26)
      self.timeLabel:setAnchorPoint(ccp(0.5,0))
      self.timeLabel:setPosition(ccp((G_VisibleSizeWidth - 50)/2,G_VisibleSizeHeight - 250))
      self.bgLayer:addChild(self.timeLabel)
      self:updateAcTime()
    end
    


    self.iconSp=CCSprite:createWithSpriteFrameName("iconGold6.png")
    self.iconSp:setAnchorPoint(ccp(0,0))
    self.iconSp:setPosition(ccp(30, G_VisibleSizeHeight - self.acTimeH - self.desH))
    self.bgLayer:addChild(self.iconSp)
    
    self.des:setAnchorPoint(ccp(0,0))
    self.des:setPosition(ccp(180 ,G_VisibleSizeHeight - self.acTimeH - self.desH))
    self.bgLayer:addChild(self.des)

    
    self:initTableView()
    
    self:updateRechargeBtn()
end

function acShareHappinessTab1:getDes(content, size)
  local showMsg=content or ""
  local width=G_VisibleSizeWidth - 200
  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return height, messageLabel
end


-- 更新领奖按钮显示
function acShareHappinessTab1:updateRechargeBtn()

  local state = 0
  local buildVo=buildingVoApi:getBuildingVoByBtype(7)[1]

  if allianceVoApi:isHasAlliance()==false and buildVo ~= nil and buildVo.level >= 5 then
    state = 1 -- 无军团，主基地等级>= 5
  else
    state = 2-- 在军团中或无军团，主基地等级<5
  end

  if self.rechargeBtnState ~= state and acShareHappinessVoApi:getCurrentPhase() == 1 then
      self.rechargeBtnState = state
      if self.rechargeMenu ~= nil then
        self.bgLayer:removeChild(self.rechargeMenu,true)
        self.rechargeMenu = nil
      end
      local function gotoAlliancePanel(tag,object)
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
        activityAndNoteDialog:gotoAlliance(false)
      end

      local function rechargeClick(tag,object)
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
        vipVoApi:showRechargeDialog(self.layerNum+1)
      end

      local rechargeBtn
      if state == 1 then
          rechargeBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",gotoAlliancePanel,3,getlocal("alliance_list_scene_name"),28)
      elseif state == 2 then
          rechargeBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",rechargeClick,3,getlocal("recharge"),28)
      end
      rechargeBtn:setAnchorPoint(ccp(0.5, 0))
      self.rechargeMenu=CCMenu:createWithItem(rechargeBtn)
      self.rechargeMenu:setPosition(ccp(G_VisibleSizeWidth/2,40))
      self.rechargeMenu:setTouchPriority(-(self.layerNum-1)*20-5)
      self.bgLayer:addChild(self.rechargeMenu) 
  elseif acShareHappinessVoApi:getCurrentPhase() == 2 then
      if self.rechargeMenu ~= nil then
        self.bgLayer:removeChild(self.rechargeMenu,true)
        self.rechargeMenu = nil
      end
  end

end

function acShareHappinessTab1:initTableView()
  -- self.acTimeH 是活动说明文字以上的高度，20是说明文字与tv之间的间隔，tvBgY是tvBg下面预留的按钮的高度
  local phase = acShareHappinessVoApi:getCurrentPhase()
  
  local tvBgY = 30
  if phase == 1 then
    tvBgY = 130
  end

  local tvBgH = G_VisibleSizeHeight - self.acTimeH - 20 - self.desH - tvBgY
  

  local function click(hd,fn,idx)
  end
  self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
  self.tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,tvBgH))
  self.tvBg:ignoreAnchorPointForPosition(false)
  self.tvBg:setAnchorPoint(ccp(0,0))
  self.tvBg:setPosition(ccp(25, tvBgY))
  self.bgLayer:addChild(self.tvBg)

  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,tvBgH - 20),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
  self.tv:setAnchorPoint(ccp(0,0))
  self.tv:setPosition(ccp(25,tvBgY + 10))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acShareHappinessTab1:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return acShareHappinessVoApi:gradeNums()
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,200)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    
    local singleW = G_VisibleSizeWidth - 50
    local singleH = 200
    local sid = acShareHappinessVoApi:getPropReward(idx + 1)
    local pCfg = propCfg[sid]
    if pCfg == nil then
      do
        return
      end
    end
    
    -- 获取每一个档次的金币数
    local  tmpStoreCfg=acShareHappinessVoApi:gradeCfg()
    local gold = tmpStoreCfg[idx+1]
    -- 每一条的背景
    local function cellClick(hd,fn,index)
    end
    
    local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),cellClick)
    backSprie:setContentSize(CCSizeMake(singleW, singleH - 10))
    backSprie:setAnchorPoint(ccp(0.5,0.5))
    backSprie:setPosition(ccp(singleW/2, singleH/2))
    cell:addChild(backSprie)
    
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
    -- 宝箱图标
    local boxIcon = LuaCCSprite:createWithSpriteFrameName(pCfg.icon,showInfoHandler)
    boxIcon:setAnchorPoint(ccp(0,0.5))
    boxIcon:setPosition(ccp(20,singleH/2))
    boxIcon:setTouchPriority(-(self.layerNum-1)*20-2)
    cell:addChild(boxIcon)


    local boxName = GetTTFLabelWrap(getlocal(pCfg.name), 28,CCSizeMake(singleW - 130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
    boxName:setAnchorPoint(ccp(0,0))
    boxName:setPosition(ccp(120, singleH - 50))
    boxName:setColor(G_ColorGreen)
    cell:addChild(boxName)

    local desHeight = singleH - 70
    local boxDes1 = GetTTFLabelWrap(getlocal("activity_shareHappiness_itemDes",{gold}), 22,CCSizeMake(singleW - 130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    boxDes1:setAnchorPoint(ccp(0,1))
    boxDes1:setPosition(ccp(120, desHeight))
    cell:addChild(boxDes1)

    local boxDes2 = GetTTFLabelWrap(getlocal(pCfg.description), 22,CCSizeMake(singleW - 130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    boxDes2:setAnchorPoint(ccp(0,1))
    boxDes2:setPosition(ccp(120, desHeight - boxDes1:getContentSize().height - 2))
    cell:addChild(boxDes2)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acShareHappinessTab1:openInfo()
  local sd=smallDialog:new()
  local labelTab={"",getlocal("activity_shareHappiness_rule3"),"\n",getlocal("activity_shareHappiness_rule2"),"\n",getlocal("activity_shareHappiness_rule1")}
  local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,nil,getlocal("activity_baseLeveling_ruleTitle"))
  sceneGame:addChild(dialogLayer,self.layerNum+1)
end

function acShareHappinessTab1:updateAcTime()
    local acVo=acShareHappinessVoApi:getAcVo()
    if acVo and self.timeLabel then
        local phase=acShareHappinessVoApi:getCurrentPhase()
        if phase==1 then
          G_updateActiveTime(acVo,self.timeLabel)
        elseif phase==2 then
          G_updateActiveTime(acVo,nil,self.timeLabel)
        end
    end
end

function acShareHappinessTab1:tick()
  local phase = acShareHappinessVoApi:getCurrentPhase()
  if self.currentPhase ~= phase and self.bgLayer ~= nil then
    self.timeTime:removeFromParentAndCleanup(true)
    self.timeTime = nil
    self.timeLabel:removeFromParentAndCleanup(true)
    self.timeLabel = nil
    self.iconSp:removeFromParentAndCleanup(true)
    self.iconSp = nil
    self.tvBg:removeFromParentAndCleanup(true)
    self.tvBg = nil
    self.tv:removeFromParentAndCleanup(true)
    self.tv=nil
    self.rechargeMenu =nil
    self.des:removeFromParentAndCleanup(true)
    self.des = nil
    self.desH = nil -- 活动说明信息的高度
    self.rechargeMenu = nil
    self.rechargeBtnState = nil
    self.currentPhase = nil -- 当前阶段
    self:updateInit()
  end
  self:updateAcTime()
end

function acShareHappinessTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.acTimeH = nil
    self.rechargeMenu =nil
    self.des = nil
    self.desH = nil -- 活动说明信息的高度
    self.rechargeBtnState = nil

    self.currentPhase = nil -- 当前阶段

    self.timeTime = nil
    self.timeLabel = nil
    self.iconSp = nil
    self.tvBg = nil
    self = nil  
end
