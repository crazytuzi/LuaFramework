acMiBaoDialog=commonDialog:new()

function acMiBaoDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.des = {}
    self.desH = {}

    self.rule = {} -- 活动规则
    self.ruleH = {} -- 活动规则的高度
    self.pinHeBtn = nil
    self.pieceMasks = {}
    self.pieceDess = {}
    return nc
end

function acMiBaoDialog:initTableView()

  local desH,des = self:getDes(getlocal("activity_miBao_content"),24, nil)
  table.insert(self.desH, desH)
  table.insert(self.des, des)

  desH,des = self:getDes(getlocal("activity_miBao_contentTip"),24, nil)
  table.insert(self.desH, desH)
  table.insert(self.des, des)
  
  for i=1,2 do
    local pid = acMiBaoVoApi:getPinHeId()
    if i == 2 then
      pid = propCfg[pid].useConsume[1][1]
    end
    local pCfg = propCfg[pid]
    local nDesH,nDes = self:getDes(getlocal(pCfg.name),24, G_VisibleSizeWidth - 170)
    table.insert(self.desH, nDesH)
    table.insert(self.des, nDes)

    local dDesH,dDes = self:getDes(getlocal(pCfg.description),24,G_VisibleSizeWidth - 170)
    if nDesH + dDesH < 200 then
      dDesH = 200 - nDesH
    end
    table.insert(self.desH, dDesH)
    table.insert(self.des, dDes)
  end

  for i=1,5 do
    local ruleH,rule = self:getDes(getlocal("activity_miBao_rule"..i),24, nil)
    table.insert(self.ruleH, ruleH)
    table.insert(self.rule, rule)
  end
  
  local function gotoExplore(tag,object)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)
    activityAndNoteDialog:closeAllDialog()
    mainUI:changeToWorld()
  end  

  local explaoreItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",gotoExplore,nil,getlocal("activity_miBao_btn"),25)
  local exploreBtn=CCMenu:createWithItem(explaoreItem)
  exploreBtn:setTouchPriority(-(self.layerNum-1)*20-5)
  exploreBtn:setAnchorPoint(ccp(0,0))
  exploreBtn:setPosition(ccp(G_VisibleSizeWidth/2,60))
  self.bgLayer:addChild(exploreBtn)

  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,15))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 210),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,120))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acMiBaoDialog:getDes(content, size, width)
  local showMsg=content or ""
  local width= width
  if width == nil then
    width = G_VisibleSizeWidth - 80
  end

  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return height, messageLabel
end

function acMiBaoDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 14
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    if idx == 0 or idx == 1 or idx == 2 or idx == 8  then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,60)
    elseif idx == 3 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[1])
    elseif idx == 4 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,250)
    elseif idx == 5 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[2])
    elseif idx == 6 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[3]+self.desH[4])
    elseif idx == 7 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[5]+self.desH[6])
    elseif idx > 8 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.ruleH[idx - 8])
    end
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local desLabel
    if idx == 0 then
      desLabel = GetTTFLabel(getlocal("activity_timeLabel"),26)
      desLabel:setAnchorPoint(ccp(0,0))
      desLabel:setColor(G_ColorGreen)
      desLabel:setPosition(ccp(10,10))
      cell:addChild(desLabel)
    elseif idx == 1 then
      local acVo = acMiBaoVoApi:getAcVo()
      if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        desLabel=GetTTFLabel(timeStr,26)
        desLabel:setAnchorPoint(ccp(0,1))
        desLabel:setPosition(ccp(35,50))
        cell:addChild(desLabel)
      end
    elseif idx == 2 then
      desLabel = GetTTFLabel(getlocal("activity_contentLabel"),26)
      desLabel:setAnchorPoint(ccp(0,0))
      desLabel:setColor(G_ColorGreen)
      desLabel:setPosition(ccp(10,10))
      cell:addChild(desLabel)
    elseif idx == 3 then
      desLabel = self.des[1]
      desLabel:setAnchorPoint(ccp(0,0.5))
      desLabel:setPosition(ccp(35,self.desH[1]/2))
      cell:addChild(desLabel)
    elseif idx == 4 then -- 碎片图标
      local pCfg = nil
      local totalH = 250
      local hadNum = 0
      local needNum = 0
      for i=1,4 do
        local id,num = acMiBaoVoApi:getPieceCfgByIndex(i)
        pCfg = acMiBaoVoApi:getPieceCfgForShowBySid(id)
        hadNum = tonumber(acMiBaoVoApi:getPieceNum(id))
        needNum = tonumber(num)
        local pIcon = self:getIcon(pCfg,hadNum)
        pIcon:setAnchorPoint(ccp(0,1))
        local pIconX = 100
        local pIconY = 0
        if i == 2 or i == 4 then
          pIconX = pIconX + pIcon:getContentSize().width + 10
        end

        if i == 3 or i == 4 then
          pIconY = totalH/2 - 10
        else
          pIconY = totalH/2 + 10 + pIcon:getContentSize().height
        end

        pIcon:setPosition(ccp(pIconX,pIconY))
        pIcon:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(pIcon)
        
        desLabel =GetTTFLabel(getlocal("scheduleChapter",{hadNum,needNum}),25)
        desLabel:setAnchorPoint(ccp(1,0))
        desLabel:setPosition(ccp(pIcon:getContentSize().width-5,0))
        table.insert(self.pieceDess, desLabel)
        local function nilFunc()
        end
        local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
        local rect=CCSizeMake(pIcon:getContentSize().width,pIcon:getContentSize().height)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(180)
        touchDialogBg:setPosition(getCenterPoint(pIcon))
        pIcon:addChild(touchDialogBg,1)
        table.insert(self.pieceMasks, touchDialogBg)
        if hadNum < needNum then
          touchDialogBg:setVisible(true)
          desLabel:setColor(G_ColorYellowPro)
        else
          touchDialogBg:setVisible(false)
          desLabel:setColor(G_ColorWhite)
        end
        pIcon:addChild(desLabel,2)
      end

      local function pinHeHandler(tag,object)
        if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
          if G_checkClickEnable()==false then
              do
                  return
              end
          else
              base.setWaitTime=G_getCurDeviceMillTime()
          end
          PlayEffect(audioCfg.mouseClick)
          self:startPinHe()
        end
      end   
      self.pinHeBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",pinHeHandler,nil,getlocal("activity_miBao_pinHe"),25)
      self.pinHeBtn:setAnchorPoint(ccp(0,0.5))
      local pinHeMenu=CCMenu:createWithItem(self.pinHeBtn)
      pinHeMenu:setPosition(ccp(G_VisibleSizeWidth/2 + 30,totalH/2))
      pinHeMenu:setTouchPriority(-(self.layerNum-1)*20-2)
      cell:addChild(pinHeMenu)
      if acMiBaoVoApi:canReward() == true then
        self.pinHeBtn:setEnabled(true)
      else
        self.pinHeBtn:setEnabled(false)
      end


    elseif idx == 5 then -- 提示信息
      desLabel = self.des[2]
      desLabel:setAnchorPoint(ccp(0,0.5))
      desLabel:setPosition(ccp(35,self.desH[2]/2))
      desLabel:setColor(G_ColorRed)
      cell:addChild(desLabel)
    elseif idx == 6 then -- 道具名称、说明信息、图标
      local totalH = self.desH[3] + self.desH[4]
      local pCfg = propCfg[acMiBaoVoApi:getPinHeId()]

      local function cellClick(hd,fn,index)
      end

      local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
      backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, totalH))
      backSprie:setAnchorPoint(ccp(0,0))
      backSprie:setPosition(ccp(0,0))
      cell:addChild(backSprie,1)
      
      local pIcon = CCSprite:createWithSpriteFrameName(pCfg.icon)
      pIcon:setAnchorPoint(ccp(0,0.5))
      pIcon:setPosition(ccp(10,totalH/2))
      backSprie:addChild(pIcon)

      desLabel = self.des[4] -- 说明
      desLabel:setAnchorPoint(ccp(0,1))
      desLabel:setPosition(ccp(150,self.desH[4]+10))
      backSprie:addChild(desLabel)

      desLabel = self.des[3] -- 名称
      desLabel:setAnchorPoint(ccp(0,1))
      desLabel:setColor(G_ColorGreen)
      desLabel:setPosition(ccp(150,totalH))
      backSprie:addChild(desLabel)

    elseif idx == 7 then -- 道具名称、说明信息、图标
      local totalH = self.desH[5] + self.desH[6]
      local pCfg1 = propCfg[acMiBaoVoApi:getPinHeId()]
      local pCfg = propCfg[pCfg1.useConsume[1][1]]
      

      local function cellClick(hd,fn,index)
      end

      local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
      backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, totalH))
      backSprie:setAnchorPoint(ccp(0,0))
      backSprie:setPosition(ccp(0,0))
      cell:addChild(backSprie,1)
      
      local pIcon = CCSprite:createWithSpriteFrameName(pCfg.icon)
      pIcon:setAnchorPoint(ccp(0,0.5))
      pIcon:setPosition(ccp(10,totalH/2))
      backSprie:addChild(pIcon)
      
      desLabel = self.des[6] -- 说明
      desLabel:setAnchorPoint(ccp(0,1))
      desLabel:setPosition(ccp(150,self.desH[6]))
      backSprie:addChild(desLabel)

      desLabel = self.des[5] -- 名称
      desLabel:setAnchorPoint(ccp(0,1))
      desLabel:setColor(G_ColorGreen)
      desLabel:setPosition(ccp(150,totalH))
      backSprie:addChild(desLabel)
    elseif idx == 8 then
      desLabel = GetTTFLabel(getlocal("activity_ruleLabel"),26)
      desLabel:setAnchorPoint(ccp(0,0))
      desLabel:setColor(G_ColorGreen)
      desLabel:setPosition(ccp(10,10))
      cell:addChild(desLabel)
    elseif idx > 8 then
      desLabel = self.rule[idx - 8]
      desLabel:setAnchorPoint(ccp(0,0.5))
      desLabel:setPosition(ccp(35,self.ruleH[idx - 8]/2))
      cell:addChild(desLabel)
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

function acMiBaoDialog:getIcon(pCfg,hadNum)
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
      local item = {name = getlocal(pCfg.name), pic= pCfg.icon, num = hadNum, desc = pCfg.des}
      propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,nil,nil,true)
    end
  end

  local pIcon = LuaCCSprite:createWithSpriteFrameName(pCfg.icon,showInfoHandler)
  return pIcon
end

function acMiBaoDialog:startPinHe()
  if acMiBaoVoApi:canReward() == true then
    local function getPinHeSuccess(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
        local getNum = 0 -- 拼合成功的个数
        if sData.reward ~= nil then
          getNum = sData.reward
        end
        -- 添加奖励并提示信息
        if getNum > 0 then
          local getPid = acMiBaoVoApi:getPinHeId()
          local reward = {p={{index=1}}}
          reward.p[1][getPid] = getNum
          local awardTab=FormatItem(reward,true)
          for k,v in pairs(awardTab) do
            G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
          end
          smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_miBao_pinHeSucTip",{getNum}),28)
          
          if sData.data ~= nil then
            acMiBaoVoApi:afterPinHeSuccess(sData.data)
          end
        end
      end
    end
    socketHelper:miBaoPinHe(getPinHeSuccess)
  end
end

function acMiBaoDialog:tick()
  
end

function acMiBaoDialog:update()
  local acVo = acMiBaoVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      if acMiBaoVoApi:canReward() == true then
        self.pinHeBtn:setEnabled(true)
      else
        self.pinHeBtn:setEnabled(false)
      end

      local hadNum = 0
      local needNum = 0
      local pMask = nil
      for i=1,4 do
        local id,num = acMiBaoVoApi:getPieceCfgByIndex(i)
        pCfg = acMiBaoVoApi:getPieceCfgForShowBySid(id)
        hadNum = tonumber(acMiBaoVoApi:getPieceNum(id))
        needNum = tonumber(num)
        pMask = self.pieceMasks[i]
        if pMask ~= nil then
            if hadNum < needNum then
              pMask:setVisible(true)
            else
              pMask:setVisible(false)
            end
        end
        pDes = self.pieceDess[i]
        if pDes ~= nil then
          pDes:setString(getlocal("scheduleChapter",{hadNum,needNum}))
          if hadNum < needNum then
            pDes:setColor(G_ColorYellowPro)
          else
            pDes:setColor(G_ColorWhite)
          end
        end
      end
      -- local recordPoint = self.tv:getRecordPoint()
      -- self.tv:reloadData()
      -- self.tv:recoverToRecordPoint(recordPoint)
    end
  end
end

function acMiBaoDialog:dispose()
  self.des = nil
  self.desH = nil

  self.rule = nil -- 活动规则
  self.ruleH = nil -- 活动规则的高度

  self.pinHeBtn = nil
  self.pieceMasks = nil
  self.pieceDess = nil

  self=nil
end





