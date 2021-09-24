acSlotMachineDialog=commonDialog:new()

function acSlotMachineDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.costLabel = nil
    self.rewardBtn = nil

    self.selectMul = false -- 是否勾选10倍收益
    self.mulSp = nil -- 10倍收益图标
    self.mulDesc = nil -- 10倍收益说明文字
    self.selectBtn = nil -- 10倍收益按钮

    self.bar = nil -- 右侧把手
    self.leftIcon = nil -- 把手左侧黄色的箭头图标
    self.rightIcon = nil -- 把手右侧黄色的箭头图标
    self.backSprie = nil -- 下方的背景
    self.lastSt = nil -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
    self.lastIndex = nil -- 上一次把手上的黄色箭头在第几个位置
    
    self.turnSingleAreaH = 120 -- 转动区域每个图标占的高度
    self.turnNum = 5 -- 转动区域个数

    self.particleS = nil -- 粒子效果
    self.addParticlesTs = nil -- 添加粒子效果的时间
    self.playIds = nil -- 播放动画最终停止的位置

    self.selectBg = nil -- 播放动画最终获得物品的背景
    self.state = 0 -- 0 正常 1 点击抽取 2 后台返回结果 3 动画播放结束

    self.spTb1={}
    self.spTb2={}
    self.spTb3={}
    self.selectPositionY=0
    self.spTb1Speed=nil
    self.spTb2Speed=nil
    self.spTb3Speed=nil
    self.moveDis=0
    self.isStop1=nil
    self.isStop2=nil
    self.isStop3=nil
    self.moveDisNum=200

    self.desTv = nil -- 面板上的说明信息
    self.metalSpTable = {} -- 边框动画效果
    self.touchDialogBg = nil

    self.currentCanGetReward = nil
    self.lastMul = nil -- 抽取后后台返回的模式

    return nc
end

function acSlotMachineDialog:initTableView()

  local function touchDialog()
      if self.state == 2 then
        PlayEffect(audioCfg.mouseClick)
        self.state = 3
        -- 暂停动画
        -- self:close()
      end
  end
  self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
  self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
  local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
  self.touchDialogBg:setContentSize(rect)
  self.touchDialogBg:setOpacity(0)
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
  self.touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
  self.dialogLayer:addChild(self.touchDialogBg,1)
  local adaH = 0
  if G_getIphoneType() == G_iphoneX then
    adaH = 75
  end
  local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
  girlDescBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 220,140))
  girlDescBg:setAnchorPoint(ccp(0,0))
  girlDescBg:setPosition(200,G_VisibleSizeHeight - 330-adaH/2)
  self.bgLayer:addChild(girlDescBg,4)
  --说明框文字
  local function desCallBack(...)
        return self:desEventHandler(...)
  end
  local desHd= LuaEventHandler:createHandler(desCallBack)
  self.desTv=LuaCCTableView:createWithEventHandler(desHd,CCSizeMake(400,120),nil)
  girlDescBg:addChild(self.desTv)
  self.desTv:setAnchorPoint(ccp(0,0))
  self.desTv:setPosition(ccp(20,10))
  self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
  self.desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  self.desTv:setMaxDisToBottomOrTop(60)

  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 105))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
  
  local bgW = 380
  local machineBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
  machineBg:setContentSize(CCSizeMake(bgW,350))
  machineBg:setAnchorPoint(ccp(0,0.5))
  machineBg:setPosition(20,self.backSprie:getContentSize().height/2 + 80)
  self.backSprie:addChild(machineBg,7)
  
  self:initSp()

  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(machineBg:getContentSize().width,machineBg:getContentSize().height),nil)
  -- self.backSprie:addChild(self.tv,8)
  machineBg:addChild(self.tv,1)
  self.tv:setAnchorPoint(ccp(0,0))
  -- self.tv:setPosition(ccp(20,self.backSprie:getContentSize().height - 410))
  self.tv:setPosition(ccp(0,0))
  -- self.backSprie:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  -- machineBg:setTouchPriority(-(self.layerNum-1) * 20 - 2)
  -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
  self.tv:setMaxDisToBottomOrTop(120)

  local recordPoint = self.tv:getRecordPoint()
  recordPoint.y = -self.turnSingleAreaH
  self.tv:recoverToRecordPoint(recordPoint)
  
  --上下遮挡物
  local maskH = 130
  local topMask=LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  topMask:setContentSize(CCSizeMake(bgW,maskH))
  topMask:setPosition(bgW/2, bgW - topMask:getContentSize().height/2)
  machineBg:addChild(topMask,2)

  local bottomMask=LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  bottomMask:setContentSize(CCSizeMake(bgW,maskH))
  bottomMask:setPosition(bgW/2,bottomMask:getContentSize().height/2)
  bottomMask:setRotation(180)
  machineBg:addChild(bottomMask,3)
end

function acSlotMachineDialog:desEventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local cellHeight = nil
        local descLb=GetTTFLabelWrap(getlocal("activity_slotMachine_desc"),25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        cellHeight=descLb:getContentSize().height
        if cellHeight<120 then
            cellHeight=120
        end
        tmpSize=CCSizeMake(400,cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellHeight = nil
        local descLb=GetTTFLabelWrap(getlocal("activity_slotMachine_desc"),25,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        
        if cellHeight==nil then
            cellHeight=descLb:getContentSize().height
        end
        if cellHeight<120 then
            cellHeight=120
        end
        descLb:setPosition(ccp(190,cellHeight/2))
        cell:addChild(descLb)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acSlotMachineDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(380,self.turnSingleAreaH * self.turnNum)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local pic = nil
    local picX = nil
    local totalH = self.turnSingleAreaH * self.turnNum
    local picY = totalH - self.turnSingleAreaH * 3 + 20
    if self.selectBg == nil then
      self.selectBg=LuaCCScale9Sprite:createWithSpriteFrameName("SlotSelect.png",CCRect(10, 10, 1, 1),function () do return end end)
      self.selectBg:setContentSize(CCSizeMake(380,self.turnSingleAreaH))
      self.selectBg:setAnchorPoint(ccp(0.5,0))
      self.selectBg:setPosition(380/2,picY)
      cell:addChild(self.selectBg)
    end

    for i=1,3 do
        local startId = acSlotMachineVoApi:getLastResultByLine(i)
        for i2=1,2 do
          if startId == 1 then
            startId = 5
          else
            startId = startId - 1
          end
        end

        for id=1,self.turnNum do
          picY = totalH - self.turnSingleAreaH * id + 22
          if startId == self.turnNum then
            pic = acSlotMachineVoApi:getPicById(1)
          else
            pic = acSlotMachineVoApi:getPicById(startId)
          end
          local icon = CCSprite:createWithSpriteFrameName(pic)
          icon:setScale(0.7)
          picX = 20 + (i-1) * 115
          icon:setAnchorPoint(ccp(0,0))
          icon:setPosition(ccp(picX, picY))
          cell:addChild(icon)
          if id==3 then
            self.selectPositionY=icon:getPositionY()
          end
          
          self["spTb"..i][startId]={}
          self["spTb"..i][startId].id=startId
          self["spTb"..i][startId].sp=icon
          
          -- local numLabel=GetTTFLabel("x"..startId,38)
          -- numLabel:setAnchorPoint(ccp(1,0))
          -- numLabel:setPosition(icon:getContentSize().width-10,0)
          -- icon:addChild(numLabel,1)

          startId = startId + 1
          if startId > self.turnNum then
            startId = 1
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

function acSlotMachineDialog:iconFlicker(icon)
  if newGuidMgr:isNewGuiding() then
    do return end
  end
  -- local m_iconScaleX,m_iconScaleY=1.65,0.95
  local m_iconScaleX,m_iconScaleY=2,2
  local pzFrameName="RotatingEffect1.png"
  local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
  local pzArr=CCArray:create()
  for kk=1,20 do
      local nameStr="RotatingEffect"..kk..".png"
      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
      pzArr:addObject(frame)
  end
  local animation=CCAnimation:createWithSpriteFrames(pzArr)
  animation:setDelayPerUnit(0.1)
  local animate=CCAnimate:create(animation)
  metalSp:setAnchorPoint(ccp(0.5,0.5))
  if m_iconScaleX~=nil then
    metalSp:setScaleX(m_iconScaleX)
  end
  if m_iconScaleY~=nil then
    metalSp:setScaleY(m_iconScaleY)
  end
  metalSp:setPosition(getCenterPoint(icon))
  icon:addChild(metalSp)
  local repeatForever=CCRepeatForever:create(animate)
  metalSp:runAction(repeatForever)
  table.insert(self.metalSpTable,metalSp)
end

-- 删除所有的边框效果
function acSlotMachineDialog:resetMetalSps()
  for k,v in pairs(self.metalSpTable) do
    if v ~= nil then
      v:stopAllActions()
      v:removeFromParentAndCleanup(true)
    end
  end
  self.metalSpTable = {}
end

function acSlotMachineDialog:initSp()
  
end

function acSlotMachineDialog:moveSp(tb)
  self.moveDis=self.moveDis+1
  for i=1,3 do
    if self.moveDis>self.moveDisNum and self["isStop"..i]==false then
      if self.moveDis%50==0 then
            self["spTb"..i.."Speed"]=self["spTb"..i.."Speed"]-1        
        if self["spTb"..i.."Speed"]<=1 then
            self["spTb"..i.."Speed"]=1
        end
      end
    end
  end
  
  


  for i=1,3 do
    for k,v in pairs(self["spTb"..i]) do
        v.sp:setPosition(ccp(v.sp:getPositionX(),v.sp:getPositionY()-self["spTb"..i.."Speed"]))
        if v.sp:getPositionY()<=-self.turnSingleAreaH then -- 位置到最下面隐藏的位置后，需要把位置调到最上面
          local key = k+1
          if key==6 then
            key=1
          end
          v.sp:setPosition(ccp(v.sp:getPositionX(),self["spTb"..i][key].sp:getPositionY()+self.turnSingleAreaH))

          -- v.sp:setPosition(ccp(v.sp:getPositionX(),v.sp:getPositionY() + self.turnSingleAreaH * (self.turnNum - 1)))
        end
        if self.moveDis>self.moveDisNum and v.id==tb[i] and v.sp:getPositionY()==self.selectPositionY and self["isStop"..i]== false then
           self["spTb"..i.."Speed"]=0
           self["isStop"..i]=true
           self:fuwei(v.id,self["spTb"..i])
        end
    end
  end

  if self["isStop1"]==true and self["isStop2"]==true and self["isStop3"]==true then
    self.state = 3
    print("动画播放结束： ", self.state)
  end
end

function acSlotMachineDialog:fuwei(key,tb)
  local tbP = {22,142,262,382,502}
  local sp1Key = key+1
  if sp1Key==6 then
    sp1Key=1
  end

  local sp1 = tolua.cast(tb[sp1Key].sp,"CCNode")
  sp1:setPosition(ccp(sp1:getPositionX(),tbP[2]))

  local sp2Key = key+2
  if sp2Key==6 then
    sp2Key=1
  end
  local sp2 = tolua.cast(tb[sp2Key].sp,"CCNode")
  sp2:setPosition(ccp(sp2:getPositionX(),tbP[1]))


  local sp3Key = key-1
  if sp3Key==0 then
    sp3Key=5
  end
  local sp3 = tolua.cast(tb[sp3Key].sp,"CCNode")
  sp3:setPosition(ccp(sp3:getPositionX(),tbP[4]))

  local sp4Key = key-2
  if sp4Key==0 then
    sp4Key=5
  end
  if sp4Key==-1 then
    sp4Key=4
  end
  local sp4 = tolua.cast(tb[sp4Key].sp,"CCNode")
  sp4:setPosition(ccp(sp4:getPositionX(),tbP[5]))
end

function acSlotMachineDialog:result(tb)
  self.spTb1Speed=0
  self.spTb2Speed=0
  self.spTb3Speed=0
  self.isStop1=true
  self.isStop2=true
  self.isStop3=true
  for i=1,3 do
    for k,v in pairs(self["spTb"..i]) do
      if v.id==tb[i] then
         v.sp:setPositionY(self.selectPositionY)
         self:fuwei(v.id, self["spTb"..i])
      end
    end
  end
end


function acSlotMachineDialog:fastTick()
  if self.state == 2 then
    -- print("动画播放中： ", self.state)
        if self.playIds ~= nil then
          self:moveSp(self.playIds)
        end
        self.lastSt = self.lastSt + 1
        if self.lastSt >= 10 then
          self:barPaly()
          self.lastSt = 0
        end
  elseif self.state == 3 then
    -- print("动画播放结束： ", self.state)
    self:result(self.playIds)
    self:stopPlayAnimation()
  end
end


function acSlotMachineDialog:tick()
  if self.particleS ~= nil and base.serverTime - self.addParticlesTs > 10 then
    self:removeParticles()
  end
  if self.timeLb then
      local acVo = acSlotMachineVoApi:getAcVo()
      if acVo then
          G_updateActiveTime(acVo,self.timeLb)
      end
  end
end

function acSlotMachineDialog:startPalyAnimation()
  self.spTb1Speed=math.random(5,10) 
  self.spTb2Speed=math.random(7,15)
  self.spTb3Speed=math.random(10,20)
  self.moveDis=0
  self.isStop1=false
  self.isStop2=false
  self.isStop3=false
  self.state = 2
  self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
  print("得到抽取结果~")
  self.lastSt = 0 -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  self.lastIndex = 1 -- 上一次把手上的黄色箭头在第几个位置
  self.leftIcon:setVisible(true)
  self.rightIcon:setVisible(true)
  self.rewardBtn:setEnabled(false)
  self.bar:setEnabled(false)
  self.bar:setRotation(180)
  self.selectBg:setVisible(false)
  self:resetMetalSps()
end

function acSlotMachineDialog:stopPlayAnimation()
  print("正常~")
  self.state = 0
  self.lastSt = 0 -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  self.lastIndex = 0 -- 上一次把手上的黄色箭头在第几个位置
  self:stopBarPlay()
  self.rewardBtn:setEnabled(true)
  self.bar:setEnabled(true)
  self.bar:setRotation(0)
  self.selectBg:setVisible(true)
  local getTable= self:resetData(self.playIds)
  self:aftetGetReward(getTable)
  acSlotMachineVoApi:afterGameOver()
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
end

-- 把手播放动画
function acSlotMachineDialog:barPaly()
  if self ~= nil then
    local barX = self.backSprie:getContentSize().width - 110
    local leftArrowX = barX - self.bar:getContentSize().width / 2 - 10
    local rightArrowX = barX + self.bar:getContentSize().width / 2 + 10
    local arrowY = nil
    local single = (self.bar:getContentSize().height - 10)/5
    arrowY = self.backSprie:getContentSize().height/2 + 80 + self.bar:getContentSize().height / 2 + 10 - single/2 - single * (self.lastIndex - 1)
    self.leftIcon:setPosition(ccp(leftArrowX,arrowY))
    self.rightIcon:setPosition(ccp(rightArrowX,arrowY))
    self.lastIndex = self.lastIndex + 1
    if self.lastIndex > 5 then
      self.lastIndex = 1
    end
  end
end

function acSlotMachineDialog:stopBarPlay()
  self.leftIcon:setVisible(false)
  self.rightIcon:setVisible(false)
end

-- 抽取奖励
function acSlotMachineDialog:getReward()
  self.state = 1
  local free = nil
  local num = nil
  local cost = nil
  if acSlotMachineVoApi:checkIfFreeGame() == true then
    free = 0
    num = 1
    cost = 0
  else
    free = 1
    if self.selectMul == true then
      num = acSlotMachineVoApi:getCfgMul()
      cost = acSlotMachineVoApi:getMulCost()
    else
      num = 1
      cost = acSlotMachineVoApi:getCfgCost()
    end
  end
  
  local function touchBuy()
    if free ~= nil and num ~= nil then
      local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
          -- 这里数据包了slotMachine和show两层，是为了防止每次后台返回数据，前台自动通过
          --base:formatPlayerData(data)这个方法同步数据时有不同数据用了同一个标识的情况
            if sData.data ~= nil and sData.data.slotMachine ~= nil and sData.data.slotMachine.show ~= nil and sData.data.slotMachine.free ~= nil and sData.data.slotMachine.num ~= nil then
              self.playIds = sData.data.slotMachine.show
              acSlotMachineVoApi:updateLastResult(self.playIds)
              self:addRewardAndCostMoney(sData.data.slotMachine.free,sData.data.slotMachine.num)
              self:startPalyAnimation()
            end
        end
      end
      socketHelper:getSlotMachineReward(free,num,getRawardCallback)
    end
  end

  local function buyGems()
      if G_checkClickEnable()==false then
          do
              return
          end
      end
      vipVoApi:showRechargeDialog(self.layerNum+1)
  end

  if playerVo.gems<tonumber(cost) then
      local num=tonumber(cost)-playerVo.gems
      local smallD=smallDialog:new()
      smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(cost),playerVo.gems,num}),nil,self.layerNum+1)
  elseif tonumber(cost) > 0 then
      local smallD=smallDialog:new()
      smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("activity_slotMachine_getTip",{tonumber(cost)}),nil,self.layerNum+1)
  elseif tonumber(cost) == 0 then
      touchBuy()
  end

end

-- 后台返回结果之后马上扣除金币并且给予奖励
function acSlotMachineDialog:addRewardAndCostMoney(free,num)

  local aNum = 10 -- 是否加倍模式
  local aCost = 1 -- 花费的金币

  if free == 0 then -- 免费的
    aNum = 1
    aCost = 0
  else
    if  num > 1 then
      aNum = acSlotMachineVoApi:getCfgMul()
      aCost = acSlotMachineVoApi:getMulCost()
    else
      aNum = 1
      aCost = acSlotMachineVoApi:getCfgCost()
    end
  end
  self.lastMul = aNum

  local getTable= self:resetData(self.playIds)

  local playerGem=playerVoApi:getGems()
  playerGem=playerGem - aCost
  playerVoApi:setGems(playerGem)

  self.currentCanGetReward = {o={}}

  -- 遍历得到所有可获得的奖励并整合
  for k,v in pairs(getTable) do
    if v ~= nil and v > 0 then
      local cfg = acSlotMachineVoApi:getCfgConversionTableByIdAndNum(tonumber(k),tonumber(v))

      if cfg ~= nil then
        -- table.insert(self.currentCanGetReward.o,cfg.reward.o[1])
        for k4,v4 in pairs(cfg.reward.o[1]) do
          local tb = {}
          tb[tostring(k4)] = tonumber(v4)
          table.insert(self.currentCanGetReward.o,tb)
        end
      end

    end
  end

  if aNum > 1 then
     for k2,v2 in pairs(self.currentCanGetReward.o) do
      for k3,v3 in pairs(v2) do
        if k3 ~= "index" then
          self.currentCanGetReward.o[k2][k3] = v3 * aNum
        end
      end
    end
  end

  -- local reward = FormatItem(self.currentCanGetReward, true)
  -- for k,v in pairs(reward) do
  --   G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
  -- end
end
-- 根据后台返回的结果{2，3，3}得到个数累加的格式
function acSlotMachineDialog:resetData(data)
  local getTable = {}
  for k,v in pairs(data) do
    if getTable[tonumber(v)] == nil then
      getTable[tonumber(v)] = 1
    else
      getTable[tonumber(v)] = getTable[tonumber(v)] + 1
    end
  end
  return getTable
end

-- 处理后台得到返回抽取结构后前台的处理
function acSlotMachineDialog:aftetGetReward(getTable)
  
  -- 遍历得到所有可获得的奖励并整合
  for k,v in pairs(getTable) do
    if v ~= nil and v > 0 then
      local cfg = acSlotMachineVoApi:getCfgConversionTableByIdAndNum(tonumber(k),tonumber(v))
      if cfg ~= nil then
        -- 根据最终获得奖励的特效处理
        if tonumber(v) == 3 then
          local tank, tankNum = acSlotMachineVoApi:getTankCfgAndNumByCfg(cfg.reward.o[1])
          self:playParticles()
          local message={key="activity_slotMachine_noteMsg",param={playerVoApi:getPlayerName(),getlocal(tank.name),tankNum * self.lastMul}}
          chatVoApi:sendSystemMessage(message)
        elseif tonumber(v) == 2 then
          -- 抽中2个一样的图标，该两个图标有金框特效。
          for kId,vId in pairs(self.playIds) do
            if tonumber(vId) == tonumber(k) then
               local lines = self["spTb"..kId]
               for ksp, vsp in pairs(lines) do
                  if vsp.id == vId then
                    local icon = vsp.sp
                    self:iconFlicker(icon)
                  end
               end
            end
          end

        end

      end

    end
  end

  local reward = FormatItem(self.currentCanGetReward, true)
  G_showRewardTip(reward,true)
end

function acSlotMachineDialog:playParticles()
    --粒子效果
  self.particleS = {}
  local pX = nil
  local PY = nil
  for i=1,3 do
    pX = self.backSprie:getContentSize().width/2 + (i - 2) * 200
    PY = self.backSprie:getContentSize().height/2
    if i ~= 2 then
      PY = PY + 200
    end
    local p = CCParticleSystemQuad:create("public/SMOKE.plist")
    p.positionType = kCCPositionTypeFree
    p:setPosition(ccp(pX,PY))
    self.backSprie:addChild(p,10)
    table.insert(self.particleS,p)
  end
  self.addParticlesTs = base.serverTime
end

function acSlotMachineDialog:removeParticles()
  for k,v in pairs(self.particleS) do
    v:removeFromParentAndCleanup(true)
  end
  self.particleS = nil
  self.addParticlesTs = nil
end

function acSlotMachineDialog:doUserHandler()
  local function touch(tag,object)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
    end

    PlayEffect(audioCfg.mouseClick)
    if tag == 1 then
      self:openInfo()
    elseif tag == 2 or tag == 4 then
      self:getReward()
    elseif tag == 3 then
      local exchangeDialog= acSlotMachineExchangeDialog:new()
      local infoBg = exchangeDialog:init(self.layerNum+1)
    elseif tag == 5 then
      if self.selectMul == true then
         self.selectMul = false
         self.mulSp:setVisible(false)
      else
          self.selectMul = true
          self.mulSp:setVisible(true)
      end
      self:updateBySelectMul()
    end
  end

  local w = nil
  local h = G_VisibleSizeHeight - 100
  local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setPosition(ccp(G_VisibleSizeWidth/2, h))
  acLabel:setColor(G_ColorGreen)
  self.bgLayer:addChild(acLabel,1)
  
  w = G_VisibleSizeWidth - 20
  h = h - 10
  local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch,1,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,1))
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(w, h))
  self.bgLayer:addChild(menuDesc,2)
 
  h = h - 40

  local acVo = acSlotMachineVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,28)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp(G_VisibleSizeWidth/2+20, h))
  self.bgLayer:addChild(messageLabel,3)
  self.timeLb=messageLabel
  G_updateActiveTime(acVo,self.timeLb)

  --X适配
  if G_getIphoneType() == G_iphoneX then
    h = h - 75
  end
  
  h = h - 200
  local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter_new.png")
  girlImg:setScale(0.7)
  girlImg:setAnchorPoint(ccp(0,0))
  girlImg:setPosition(ccp(20,h))
  self.bgLayer:addChild(girlImg,5)

  
  local function cellClick(hd,fn,index)
  end
  

  self.backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),cellClick)
  self.backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, h + 10))
  self.backSprie:setAnchorPoint(ccp(0.5,1))
  self.backSprie:setPosition(ccp(G_VisibleSizeWidth/2, h + 20))
  self.bgLayer:addChild(self.backSprie,6)
  
  -- 10倍模式显示
  local mulX = 100
  local mulY = 180
  if G_getIphoneType() == G_iphoneX then
    mulY = mulY + 30
  end
  -- local bgSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch2)
  local bgSp = GetButtonItem("LegionCheckBtnUn.png","LegionCheckBtnUn.png","LegionCheckBtnUn.png",touch,5,nil)
  bgSp:setAnchorPoint(ccp(0,0.5))
  self.selectBtn=CCMenu:createWithItem(bgSp)
  self.selectBtn:setTouchPriority(-(self.layerNum-1)*20-4)
  self.selectBtn:setPosition(mulX-80,mulY)
  self.backSprie:addChild(self.selectBtn)


  -- 选中状态
  self.mulSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
  self.mulSp:setAnchorPoint(ccp(0,0.5))
  self.mulSp:setPosition(mulX-80,mulY)
  self.backSprie:addChild(self.mulSp)
  
  mulX = mulX + bgSp:getContentSize().width + 10
  self.mulDesc=GetTTFLabelWrap(getlocal("activity_slotMachine_selectLb",{acSlotMachineVoApi:getCfgMul()}),25,CCSizeMake(G_VisibleSizeWidth - mulX-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.mulDesc:setAnchorPoint(ccp(0,0.5))
  self.mulDesc:setPosition(mulX-80,mulY)
  self.backSprie:addChild(self.mulDesc)
  
  local costX = 200
  local costY = 110
  if G_getIphoneType() == G_iphoneX then
    costY = costY + 30
  end
  self.costLabel = GetTTFLabel(tostring(0), 30)
  self.costLabel:setAnchorPoint(ccp(1,0))
  self.costLabel:setPosition(ccp(costX, costY))
  self.costLabel:setColor(G_ColorYellowPro)
  self.backSprie:addChild(self.costLabel)
  self:updateBySelectMul()

  gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
  gemIcon:setAnchorPoint(ccp(0,0))
  gemIcon:setPosition(ccp(costX, costY))
  self.backSprie:addChild(gemIcon)
  local adaH = 30
  if G_getIphoneType() == G_iphoneX then
    adaH = 60
  end
  self.rewardBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touch,2,getlocal("activity_slotMachine_free"),28,11)
  self.rewardBtn:setAnchorPoint(ccp(0.5, 0))
  local menuAward=CCMenu:createWithItem(self.rewardBtn)
  menuAward:setPosition(ccp(costX,adaH))
  menuAward:setTouchPriority(-(self.layerNum-1)*20-4)
  self:updateRewardBtn()
  self.backSprie:addChild(menuAward,1) 

  local tableX = self.backSprie:getContentSize().width - 100
--兑奖表图标
  local tableItem=GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",touch,3,nil,0)
  tableItem:setAnchorPoint(ccp(0.5,0))
  local tableBtn=CCMenu:createWithItem(tableItem)
  tableBtn:setTouchPriority(-(self.layerNum-1)*20-5)
  tableBtn:setPosition(ccp(tableX-30, adaH))
  self.backSprie:addChild(tableBtn)
--兑奖表TTF
  local tableLb = GetTTFLabelWrap(getlocal("activity_slotMachine_tableLb"), 27,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  tableLb:setAnchorPoint(ccp(0.5,0))
  tableLb:setColor(G_ColorYellowPro)
  tableLb:setPosition(ccp(tableX-30, adaH + tableItem:getContentSize().height))
  self.backSprie:addChild(tableLb)

  
  local barX = self.backSprie:getContentSize().width - 110
  local barY = nil
  -- self.bar=CCSprite:createWithSpriteFrameName("SlotBtn.png")
  -- self.bar:setPosition(ccp(barX,barY))
  -- self.backSprie:addChild(self.bar,2)

  self.bar=GetButtonItem("SlotBtn.png","SlotBtn.png","SlotBtn.png",touch,4,nil,0)
  -- barY = self.backSprie:getContentSize().height - self.bar:getContentSize().height / 2 - 110
  barY = self.backSprie:getContentSize().height/2 + 80
  self.bar:setAnchorPoint(ccp(0.5, 0.5))
  local bar2=CCMenu:createWithItem(self.bar)
  bar2:setPosition(ccp(barX,barY))
  bar2:setTouchPriority(-(self.layerNum-1)*20-5)
  self.backSprie:addChild(bar2,2)

  
  
  local leftArrowX = barX - self.bar:getContentSize().width / 2 - 10
  local rightArrowX = barX + self.bar:getContentSize().width / 2 + 10
  local arrowY = nil
  local single = (self.bar:getContentSize().height - 10)/5

  for i=1,5 do
    arrowY = barY + self.bar:getContentSize().height / 2 + 10 - single/2 - single * (i - 1)
    local leftArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
    leftArrow:setPosition(ccp(leftArrowX,arrowY))
    self.backSprie:addChild(leftArrow)

    local rightArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
    rightArrow:setPosition(ccp(rightArrowX,arrowY))
    self.backSprie:addChild(rightArrow)
  end

  -- 把手左侧黄色的箭头图标
  self.leftIcon = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
  self.leftIcon:setPosition(ccp(leftArrowX,arrowY))
  self.leftIcon:setVisible(false)
  self.backSprie:addChild(self.leftIcon)


  -- 把手右侧黄色的箭头图标
  self.rightIcon = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
  self.rightIcon:setPosition(ccp(rightArrowX,arrowY))
  self.rightIcon:setVisible(false)
  self.backSprie:addChild(self.rightIcon)

end

-- 选择或取消收益倍数后相关ui刷新
function acSlotMachineDialog:updateBySelectMul()
  if self.costLabel ~= nil then
    local cost = 99999
    if acSlotMachineVoApi:checkIfFreeGame() == true then
      cost = 0
    else
      if self.selectMul == true then
        cost = acSlotMachineVoApi:getMulCost()
      else
        cost = acSlotMachineVoApi:getCfgCost()
      end
    end  
    self.costLabel:setString(tostring(cost))
  end
end

-- 刷新领奖按钮
function acSlotMachineDialog:updateRewardBtn()
  if self.rewardBtn ~= nil then
    local txt = nil
    if acSlotMachineVoApi:checkIfFreeGame() == true then
      txt = getlocal("activity_slotMachine_free")
      self.selectBtn:setVisible(false)
      self.mulSp:setVisible(false)
      self.mulDesc:setVisible(false)
    else
      txt = getlocal("daily_lotto_tip_5")
      self.selectBtn:setVisible(true)
      if self.selectMul == true then
         self.mulSp:setVisible(true)
      else
          self.mulSp:setVisible(false)
      end
      self.mulDesc:setVisible(true)
    end  
    tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(txt)
  end
end

function acSlotMachineDialog:openInfo()
  local td=smallDialog:new()
  local tabStr = {"\n",getlocal("activity_slotMachine_rule4",{acSlotMachineVoApi:getCfgMul(),acSlotMachineVoApi:getCfgMulCost(),acSlotMachineVoApi:getCfgMul()}),"\n",getlocal("activity_slotMachine_rule3"),"\n",getlocal("activity_slotMachine_rule2"),"\n", getlocal("activity_slotMachine_rule1",{acSlotMachineVoApi:getCfgFree()}),"\n"}
  local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acSlotMachineDialog:update()
  local acVo = acSlotMachineVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      self:updateBySelectMul()
      self:updateRewardBtn()
    end
  end
end

function acSlotMachineDialog:dispose()
  self.costLabel = nil
  self.rewardBtn = nil

  self.selectMul = nil
  self.mulSp = nil
  self.mulDesc = nil
  self.selectBtn = nil

  self.bar = nil -- 右侧把手
  self.leftIcon = nil -- 把手左侧黄色的箭头图标
  self.rightIcon = nil -- 把手右侧黄色的箭头图标
  self.backSprie = nil -- 下方的背景
  self.lastSt = nil -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  self.lastIndex = nil -- 上一次把手上的黄色箭头在第几个位置

  self.turnSingleAreaH = nil
  self.turnNum = nil
  
  self.particleS = nil -- 粒子效果
  self.addParticlesTs = nil -- 添加粒子效果的时间
  self.selectBg = nil
  self.state = nil

  self.spTb1=nil
  self.spTb2=nil
  self.spTb3=nil
  self.selectPositionY=nil
  self.spTb1Speed=nil
  self.spTb2Speed=nil
  self.spTb3Speed=nil
  self.moveDis=nil
  self.isStop1=nil
  self.isStop2=nil
  self.isStop3=nil
  self.moveDisNum=nil

  self.desTv = nil -- 面板上的说明信息
  self.metalSpTable = nil
  self.touchDialogBg = nil

  self.currentCanGetReward = nil
  self.lastMul = nil
  self.timeLb = nil

  self=nil
end






