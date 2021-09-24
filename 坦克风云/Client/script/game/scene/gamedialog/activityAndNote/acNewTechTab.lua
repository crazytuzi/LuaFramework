acNewTechTab={
   rechargeBtnState = nil,
}

function acNewTechTab:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil
    self.tabId = nil
    self.acTimeH = 360

    self.rechargeMenu = nil
    self.rechargeBtnState = nil

    self.tvBg = nil

    return nc

end

function acNewTechTab:init(tabId,layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.tabId = tabId

    local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),28)
    timeTime:setAnchorPoint(ccp(0.5,1))
    timeTime:setColor(G_ColorGreen)
    timeTime:setPosition(ccp((G_VisibleSizeWidth - 50)/2,G_VisibleSizeHeight - 180))
    self.bgLayer:addChild(timeTime)

    local acVo = acNewTechVoApi:getAcVo()
    if acVo ~= nil then
      local timeStr = acNewTechVoApi:getTimeStr()
      local timeLabel = GetTTFLabel(timeStr,26)
      timeLabel:setAnchorPoint(ccp(0.5,0))
      timeLabel:setPosition(ccp((G_VisibleSizeWidth - 50)/2,G_VisibleSizeHeight - 250))
      self.bgLayer:addChild(timeLabel)
      self.timeLb=timeLabel
      self:updateAcTime()
    end

    if self.tabId == 2 then
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
    end

    local desTv, desLabel = G_LabelTableView(CCSizeMake(G_VisibleSizeWidth-60, 100),getlocal("activity_newTech_content"..self.tabId),25,kCCTextAlignmentLeft)
    desTv:setAnchorPoint(ccp(0,0))
    desTv:setPosition(ccp(30, G_VisibleSizeHeight - self.acTimeH))
    self.bgLayer:addChild(desTv,5)
    self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 4)
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    desTv:setMaxDisToBottomOrTop(10)

    self:initTableView()
    
    return self.bgLayer
end

function acNewTechTab:getDes(content, size)
  local showMsg=content or ""
  local width=G_VisibleSizeWidth - 200
  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return height, messageLabel
end


function acNewTechTab:initTableView()
  -- self.acTimeH 是活动说明文字以上的高度，20是说明文字与tv之间的间隔，tvBgY是tvBg下面预留的按钮的高度  
  local tvBgY = 30

  local tvBgH = G_VisibleSizeHeight - self.acTimeH - 20 - tvBgY
  

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

function acNewTechTab:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return acNewTechVoApi:getTechNumByTab(self.tabId)
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,200)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local singleW = G_VisibleSizeWidth - 50
    local singleH = 200
    local cfg = acNewTechVoApi:getTechCfgByTab(self.tabId)[idx + 1]
    local pSid = cfg[1] -- 需要的道具
    local needNum = cfg[2] -- 需要的道具个数
    local ppCfg = propCfg[pSid]
    if ppCfg == nil then
      do
        return
      end
    end

    local pic = nil
    local name = nil
    local price = getlocal(ppCfg.name).."x"..needNum--需要的道具
    local ownNum = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pSid)))

    local sid = nil -- 奖励的道具
    local rewardNum = 1 -- 奖励1个道具
    local pCfg = nil
    local isAddBg = nil
    if self.tabId == 1 then
      sid = cfg[3]
      pCfg = propCfg[sid]
      pic = pCfg.icon
      name = getlocal(pCfg.name)
    else
      name = getlocal("activity_newTech_pname")
      pic = "questionMark.png"
      isAddBg = true
    end
    
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
        local desc = nil
        if self.tabId == 1 then
          desc = pCfg.description
        else
          desc = "activity_newTech_pdes"
        end

        local item = {name = name, pic= pic, num = 1, desc = desc}
        propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,isAddBg,nil,nil,nil,nil)
      end
    end
    -- 宝箱图标
    local iconSize = 100
    local boxIcon = nil
    if isAddBg == true then
      boxIcon = GetBgIcon(pic,showInfoHandler,nil,nil,iconSize)
    else
      boxIcon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
    end
    boxIcon:setScale(iconSize/boxIcon:getContentSize().width)
    boxIcon:setAnchorPoint(ccp(0,0.5))
    boxIcon:setPosition(ccp(20,singleH/2))
    boxIcon:setTouchPriority(-(self.layerNum-1)*20-2)
    cell:addChild(boxIcon)
    local des1Width = 300
    local des2Width = 130
    local boxNamePosWidth = 130
    if G_getCurChoseLanguage() =="ar" then
      des1Width =350
      des2Width = 350
      boxNamePosWidth =350
    end
    
    local boxName = GetTTFLabelWrap(name, 28,CCSizeMake(singleW - boxNamePosWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
    boxName:setAnchorPoint(ccp(0,0))
    boxName:setPosition(ccp(20, singleH - 50))
    boxName:setColor(G_ColorGreen)
    cell:addChild(boxName)

    local desHeight = singleH - 70

    local boxDes1 = GetTTFLabelWrap(getlocal("activity_newTech_price",{price}), 22,CCSizeMake(singleW - des1Width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    boxDes1:setAnchorPoint(ccp(0,1))
    boxDes1:setPosition(ccp(120, desHeight))
    cell:addChild(boxDes1)
    
    
    local boxDes2 = GetTTFLabelWrap(getlocal("activity_newTech_own",{ownNum}), 22,CCSizeMake(singleW - des2Width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    boxDes2:setAnchorPoint(ccp(0,1))
    boxDes2:setPosition(ccp(120, desHeight - boxDes1:getContentSize().height - 2))
    cell:addChild(boxDes2)

    local function rechargeClick1(tag,object)
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
      if ownNum < needNum then
         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newTech_pNotEnought"),30)
      else
        self:exchange(tag, 1)
      end
    end

    local btn1 = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rechargeClick1,idx + 1,getlocal("activity_newTech_times",{1}),28, 5)
    -- local lb = btn1:getChildByTag(5)
    -- if lb ~= nil and ownNum < needNum then
    --   lb:setColor(G_ColorRed)
    -- end
    if ownNum < needNum then
      btn1:setEnabled(false)
    end
    btn1:setAnchorPoint(ccp(1, 0))
    local menu1 = CCMenu:createWithItem(btn1)
    menu1:setPosition(ccp(singleW - 20,singleH/2 + 10))
    menu1:setTouchPriority(-(self.layerNum-1)*20-2)
    cell:addChild(menu1)

    
    local function rechargeClick2(tag,object)
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
      if ownNum < needNum * 10 then
         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newTech_pNotEnought"),30)
      else
        self:exchange(tag, 10)
      end
    end

    local btn2 = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rechargeClick2,idx+1,getlocal("activity_newTech_times",{10}),28,5)
    -- local lb2 = btn2:getChildByTag(5)
    -- if lb2 ~= nil and ownNum < needNum * 10 then
    --   lb2:setColor(G_ColorRed)
    -- end
    if ownNum < needNum * 10 then
      btn2:setEnabled(false)
    end
    
    btn2:setAnchorPoint(ccp(1, 1))
    local menu2 = CCMenu:createWithItem(btn2)
    menu2:setPosition(ccp(singleW - 20,singleH/2 - 10))
    menu2:setTouchPriority(-(self.layerNum-1)*20-2)
    cell:addChild(menu2)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

-- 点击兑换按钮 itemIndex 代表兑换哪个奖励  num代表兑换1个还是10个
function acNewTechTab:exchange(itemIndex, num)
  if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then

    local cfg = acNewTechVoApi:getTechCfgByTab(self.tabId)[itemIndex]
    if cfg == nil then
      do
         return
      end
    end

    local function getRawardCallback(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
        local getPid = sData.clientReward -- 得到的道具
        local reward = {p={}}
        local i = 1
        for k,v in pairs(getPid) do
          if v ~= nil and SizeOfTable(v) == 2 then
            reward.p[i] = {index = i}
            reward.p[i][v[1]] = v[2]
            i = i + 1
          end
        end
        local award=FormatItem(reward,true)
        for k,v in pairs(award) do
          G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
        end
        bagVoApi:useItemNumId(tonumber(RemoveFirstChar(cfg[1])),tonumber(cfg[2]) * num)

        if num == 1 or self.tabId == 1 then
          G_showRewardTip(award,true)
        else
          local content = {}
          for k,v in pairs(getPid) do
            local pCfg = propCfg[v[1]]
            table.insert(content,{icon= pCfg.icon,msg = getlocal(pCfg.name).."x"..v[2], addFlicker = acNewTechVoApi:checkIfIsStrong(v[1])})
          end
          smallDialog:showSearchDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("award"),content,nil,true,self.layerNum+1,nil,true,true)
        end
        acNewTechVoApi:afterExchange()
      end  
    end
    local action = "normal"
    if self.tabId == 2 then
      action = "rand"
    end
    socketHelper:getNewTechReward(action, cfg[1], num, getRawardCallback)
  end
end

function acNewTechTab:openInfo()
  local sd=smallDialog:new()
  local labelTab={"",getlocal("activity_newTech_rule","\n")}
  local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,nil)
  sceneGame:addChild(dialogLayer,self.layerNum+1)
end

function acNewTechTab:update()
  local acVo = acNewTechVoApi:getAcVo()
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

function acNewTechTab:tick()
    self:updateAcTime()
end

function acNewTechTab:updateAcTime()
    local acVo=acNewTechVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acNewTechTab:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.tabId = nil
    self.acTimeH = nil

    self.rechargeMenu = nil
    self.rechargeBtnState = nil

    self.tvBg = nil
    self = nil  
end
