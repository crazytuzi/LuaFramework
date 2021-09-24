 acCustomLotteryOneDialog=commonDialog:new()

function acCustomLotteryOneDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.costLabel = nil
    self.rewardBtn = nil

    self.selectMul = false -- 是否勾选关闭动画
    self.mulSp = nil -- 关闭动画选中图标
    self.mulDesc = nil -- 关闭动画说明文字
    self.selectBtn = nil -- 关闭动画收益按钮

    self.bar = nil -- 右侧把手
    self.leftIcon = nil -- 把手左侧黄色的箭头图标
    self.rightIcon = nil -- 把手右侧黄色的箭头图标
    self.backSprie = nil -- 下方的背景
    self.lastSt = nil -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
    self.lastIndex = nil -- 上一次把手上的黄色箭头在第几个位置
    
    self.turnSingleAreaH = 140 -- 转动区域每个图标占的高度
    self.turnNum = 5 -- 转动区域个数

    self.particleS = nil -- 粒子效果
    self.addParticlesTs = nil -- 添加粒子效果的时间
    self.playIds = nil -- 播放动画最终停止的位置

    self.selectBg = nil -- 播放动画最终获得物品的背景
    self.state = 0 -- 0 正常 1 点击抽取 2 后台返回结果 3 动画播放结束

    self.selectPositionY=0
    self.moveDis=0

    self.moveDisNum=300

    self.desTv = nil -- 面板上的说明信息
    self.metalSpTable = {} -- 边框动画效果
    self.touchDialogBg = nil

    self.currentCanGetReward = nil
    self.lastMul = nil -- 抽取后后台返回的模式

    self.iconTab={}
    self.hasLottery=false

    self.tv1Hight = nil


    return nc
end

function acCustomLotteryOneDialog:initTableView()
  
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

  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 105))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))

  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-100,190),nil)
  self.backSprie:addChild(self.tv,1)
  self.tv:setAnchorPoint(ccp(0,0))
  self.tv:setPosition(ccp(110,190))

  self.tv:setMaxDisToBottomOrTop(120)

  -- local recordPoint = self.tv:getRecordPoint()
  -- recordPoint.y = -self.turnSingleAreaH
  -- self.tv:recoverToRecordPoint(recordPoint)
  
  -- local maskH = 130
  -- local topMask=LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  -- topMask:setContentSize(CCSizeMake(bgW,maskH))
  -- topMask:setPosition(bgW/2, bgW - topMask:getContentSize().height/2)
  -- self.machineBg:addChild(topMask,2)

  -- local bottomMask=LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  -- bottomMask:setContentSize(CCSizeMake(bgW,maskH))
  -- bottomMask:setPosition(bgW/2,bottomMask:getContentSize().height/2)
  -- bottomMask:setRotation(180)
  -- self.machineBg:addChild(bottomMask,3)
end

function acCustomLotteryOneDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(380,150)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local pic = nil
    local picX = nil
    local totalH = self.turnSingleAreaH * self.turnNum
    local picY = 20
    if self.selectBg == nil then
      self.selectBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamRepairBtn.png",CCRect(30, 30, 1, 1),function () do return end end)
      self.selectBg:setContentSize(CCSizeMake(380,self.turnSingleAreaH))
      self.selectBg:setAnchorPoint(ccp(0.5,0.5))
      self.selectBg:setPosition(380/2,75)
      cell:addChild(self.selectBg)
    end
    if self.showItem then
    	self.showItem:removeFromParentAndCleanup(true)
    	self.showItem=nil
    end

    local scale = 1
    local descLb
    if self.selectItem ==nil then
    	self.showItem = CCSprite:createWithSpriteFrameName("Icon_BG.png")
    	scale=100 / self.showItem:getContentSize().width
    	self.showItem:setScale(scale)

    	local addIcon = CCSprite:createWithSpriteFrameName("questionMark.png")
    	addIcon:setPosition(getCenterPoint(self.showItem))
      	self.showItem:addChild(addIcon,1)
      	descLb= GetTTFLabelWrap(getlocal("activity_customLottery_randomReward"),30/scale,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)

    else
    	self.showItem=CCSprite:createWithSpriteFrameName(self.showItem.pic)
    end

    self.showItem:setAnchorPoint(ccp(0,0.5))
    self.showItem:setPosition(ccp(20,self.selectBg:getContentSize().height/2))
    self.selectBg:addChild(self.showItem)

	descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setPosition(ccp(10+self.showItem:getContentSize().width,self.showItem:getContentSize().height/2))
	self.showItem:addChild(descLb,101)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acCustomLotteryOneDialog:iconFlicker(icon)
  if newGuidMgr:isNewGuiding() then
    do return end
  end
  -- local m_iconScaleX,m_iconScaleY=1.65,0.95

  -- local m_iconScaleX,m_iconScaleY=1.5,1.5
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
  -- if m_iconScaleX~=nil then
  --   metalSp:setScaleX(m_iconScaleX)
  -- end
  -- if m_iconScaleY~=nil then
  --   metalSp:setScaleY(m_iconScaleY)
  -- end
  metalSp:setPosition(getCenterPoint(icon))
  metalSp:setScale((icon:getContentSize().width+8)/metalSp:getContentSize().width)
  icon:addChild(metalSp)

  local repeatForever=CCRepeatForever:create(animate)
  metalSp:runAction(repeatForever)
  table.insert(self.metalSpTable,metalSp)
end

-- 删除所有的边框效果
function acCustomLotteryOneDialog:resetMetalSps()
  for k,v in pairs(self.metalSpTable) do
    if v ~= nil then
      v:stopAllActions()
      v:removeFromParentAndCleanup(true)
    end
  end
  self.metalSpTable = {}
end

function acCustomLotteryOneDialog:initSp()
  
end
function acCustomLotteryOneDialog:changeItemSP() 
	self.moveDis=self.moveDis+1
  local list = acCustomLotteryOneVoApi:getRewardListCfg()
  local listSize = SizeOfTable(list)
  if listSize<=0 then
    do return end
  end
  local randomID = math.random(1,listSize)
	local types,key,pNum = acCustomLotteryOneVoApi:getRewardItemByID(randomID)
  if types==nil or key == nil then
    do return end
  end
  local name,pic,desc,id,index,eType,equipId = getItem(key,types)
	if self.showItem then
    	self.showItem:removeFromParentAndCleanup(true)
    end
    local item={name=name,num=num,pic=pic,desc=desc,id=id,type=types,index=index,key=key,eType=eType,equipId=equipId}
    -- self.showItem=G_getItemIcon(item)
    self.showItem=G_getItemIcon(item,100)
    -- self.showItem:setScale(120/self.showItem:getContentSize().width)
    self.showItem:setAnchorPoint(ccp(0,0.5))
    self.showItem:setPosition(ccp(20,self.selectBg:getContentSize().height/2))
    self.selectBg:addChild(self.showItem)

	local descLb = GetTTFLabelWrap(name.." x"..pNum,30,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0,0.5))
  descLb:setScale(0.8)
	descLb:setPosition(ccp(10+self.showItem:getContentSize().width,self.showItem:getContentSize().height/2))
	self.showItem:addChild(descLb,101)

	if self.moveDis>self.moveDisNum and self["isStop"]== false then
       self["isStop"]=true
    end
    if self["isStop"]==true then
    	self.state = 3
    	print("动画播放结束： ", self.state)
    end
end

function acCustomLotteryOneDialog:fastTick()
  if self.state == 2 then
    -- print("动画播放中： ", self.state)
    self.moveDis=self.moveDis+1
    self.changeSp=self.changeSp+1
    if self.moveDis<=(self.moveDisNum*1/3) then
    	if self.changeSp>=40 then
    		self.changeSp=0
    		self:changeItemSP()
    	end
    elseif self.moveDis>(self.moveDisNum*1/3) and self.moveDis<(self.moveDisNum*2/3) then
    	if self.changeSp>=20 then
    		self.changeSp=0
    		self:changeItemSP()
    	end
    elseif self.moveDis>(self.moveDisNum*2/3) then
    	if self.changeSp>=40 then
    		self.changeSp=0
    		self:changeItemSP()
    	end
    end
    --self.lastSt = self.lastSt + 1
    -- if self.lastSt >= 10 then
    --   self:barPaly()
    --   self.lastSt = 0
    -- end
  elseif self.state == 3 then
    self:stopPlayAnimation()
  end
end


function acCustomLotteryOneDialog:tick()
  if self.particleS ~= nil and base.serverTime - self.addParticlesTs > 10 then
    self:removeParticles()
  end
end

function acCustomLotteryOneDialog:startPalyAnimation()
  self.moveDis=0
  self.changeSp=0
  self.isStop=false
  self.state = 2
  self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
  print("得到抽取结果~")
  -- self.lastSt = 0 -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  -- self.lastIndex = 1 -- 上一次把手上的黄色箭头在第几个位置
  -- self.leftIcon:setVisible(true)
  -- self.rightIcon:setVisible(true)
  self.rewardBtn:setEnabled(false)
  -- self.bar:setEnabled(false)
  -- self.bar:setRotation(180)
  --self.selectBg:setVisible(false)
  self:resetMetalSps()
  --base:addNeedRefresh(self)
end

function acCustomLotteryOneDialog:stopPlayAnimation()
  print("正常~")
  self.state = 0
  -- self.lastSt = 0 -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  -- self.lastIndex = 0 -- 上一次把手上的黄色箭头在第几个位置
  -- self:stopBarPlay()
  self.rewardBtn:setEnabled(true)
  -- self.bar:setEnabled(true)
  -- self.bar:setRotation(0)
  self.selectBg:setVisible(true)
  self:afterGetReward()
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
  --base:removeFromNeedRefresh(self)
end

-- 把手播放动画
-- function acCustomLotteryOneDialog:barPaly()
--   if self ~= nil then
--     local barX = self.backSprie:getContentSize().width - 110
--     local leftArrowX = barX - self.bar:getContentSize().width / 2 - 10
--     local rightArrowX = barX + self.bar:getContentSize().width / 2 + 10
--     local arrowY = nil
--     local single = (self.bar:getContentSize().height - 10)/5
--     arrowY = self.backSprie:getContentSize().height/2 + 80 + self.bar:getContentSize().height / 2 + 10 - single/2 - single * (self.lastIndex - 1)
--     self.leftIcon:setPosition(ccp(leftArrowX,arrowY))
--     self.rightIcon:setPosition(ccp(rightArrowX,arrowY))
--     self.lastIndex = self.lastIndex + 1
--     if self.lastIndex > 5 then
--       self.lastIndex = 1
--     end
--   end
-- end

-- function acCustomLotteryOneDialog:stopBarPlay()
--   self.leftIcon:setVisible(false)
--   self.rightIcon:setVisible(false)
-- end

-- 抽取奖励
function acCustomLotteryOneDialog:getReward()
  self.state = 1
  local cost = acCustomLotteryOneVoApi:getCfgCost()
  
  -- local function touchBuy()
     
  -- end

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
  elseif tonumber(cost) >= 0 then
      -- local smallD=smallDialog:new()
      -- smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("activity_slotMachine_getTip",{tonumber(cost)}),nil,self.layerNum+1)
       local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData.data ~= nil and sData.data.customLottery1 then
              self:addRewardAndCostMoney()
              if sData.data.customLottery1.clientReward and type(sData.data.customLottery1.clientReward)=="table" and SizeOfTable(sData.data.customLottery1.clientReward)>0 then
                for k,v in pairs(sData.data.customLottery1.clientReward) do
                  if v then
                    if v.t then
                      self.propID=v.t
                    end
                    if v.p then
                      self.propType=v.p
                    end
                    if v.n then
                      self.propNum=v.n
                    end
                  end
                end
                acCustomLotteryOneVoApi:updateHadLotteryNum(1)
                acCustomLotteryOneVoApi:updateData(sData.data.customLottery1)
                if self.selectMul==true then
                  self:resetMetalSps()
                  self:stopPlayAnimation()
                  --self:stopPlayAnimation()
               else
                  self:startPalyAnimation()
                end
              end
              
            end
        end
      end
    socketHelper:activityCustomLottery(getRawardCallback,true)
  end

end

-- 后台返回结果之后马上扣除金币并且给予奖励
function acCustomLotteryOneDialog:addRewardAndCostMoney()

  local aNum = 1 -- 是否加倍模式
  local aCost = acCustomLotteryOneVoApi:getCfgCost() -- 花费的金币

  local playerGem=playerVoApi:getGems()
  playerGem=playerGem - aCost
  playerVoApi:setGems(playerGem)
end


-- 处理后台得到返回抽取结构后前台的处理
function acCustomLotteryOneDialog:afterGetReward()

  self.currentCanGetReward={}

  local name,pic,desc,id,noUseIdx,eType,equipId=getItem(self.propID,self.propType)
  table.insert(self.currentCanGetReward,{name=name,num=self.propNum,pic=pic,desc=desc,id=id,type=self.propType,index=index,key=self.propID,eType=eType,equipId=equipId})
  bagVoApi:addBag(id,self.propNum)
   if self.propID==nil or self.propType==nil then
    do return end
  end
   if self.showItem then
    	self.showItem:removeFromParentAndCleanup(true)
    	--self.showItem=nil
    end
    local item = {name=name,num=self.propNum,pic=pic,desc=desc,id=id,type=self.propType,index=index,key=self.propID,eType=eType,equipId=equipId}
    -- self.showItem=G_getItemIcon(item)
    self.showItem=G_getItemIcon(item,100)
    -- self.showItem:setScale(120/self.showItem:getContentSize().width)
    self.showItem:setAnchorPoint(ccp(0,0.5))
    self.showItem:setPosition(ccp(20,self.selectBg:getContentSize().height/2))
    self.selectBg:addChild(self.showItem)

	local descLb = GetTTFLabelWrap((name.." x"..self.propNum),30,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
  descLb:setScale(0.8)-------
	descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setPosition(ccp(10+self.showItem:getContentSize().width,self.showItem:getContentSize().height/2))
	self.showItem:addChild(descLb,101)
	self:iconFlicker(self.showItem)

  G_showRewardTip(self.currentCanGetReward,true)
  self:updateLotteryNum()
  self:updateRewardBtn()
  if acCustomLotteryOneVoApi:getIsChatMessegeByID(self.propType,self.propID) ==true then
    local message={key="chatSystemMessage13",param={playerVoApi:getPlayerName(),getlocal("activity_customLottery_title"),name," x"..self.propNum}}
    chatVoApi:sendSystemMessage(message)
  end

  self:showRewardList()
  

end

-- function acCustomLotteryOneDialog:playParticles()
--     --粒子效果
--   self.particleS = {}
--   local pX = nil
--   local PY = nil
--   for i=1,3 do
--     pX = self.backSprie:getContentSize().width/2 + (i - 2) * 200
--     PY = self.backSprie:getContentSize().height/2
--     if i ~= 2 then
--       PY = PY + 200
--     end
--     local p = CCParticleSystemQuad:create("public/SMOKE.plist")
--     p.positionType = kCCPositionTypeFree
--     p:setPosition(ccp(pX,PY))
--     self.backSprie:addChild(p,10)
--     table.insert(self.particleS,p)
--   end
--   self.addParticlesTs = base.serverTime
-- end

-- function acCustomLotteryOneDialog:removeParticles()
--   for k,v in pairs(self.particleS) do
--     v:removeFromParentAndCleanup(true)
--   end
--   self.particleS = nil
--   self.addParticlesTs = nil
-- end

function acCustomLotteryOneDialog:doUserHandler()
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
  local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,1,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,1))
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(w, h))
  self.bgLayer:addChild(menuDesc,2)
 
  h = h - 40

  local acVo = acCustomLotteryOneVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,28)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp(G_VisibleSizeWidth/2+20, h))
  self.bgLayer:addChild(messageLabel,3)
  self.timeLb=messageLabel
  self:updateAcTime()

  -- 
  -- local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
  -- --girlImg:setScale(0.7)
  -- girlImg:setAnchorPoint(ccp(0,0))
  -- girlImg:setPosition(ccp(20,h))
  -- self.bgLayer:addChild(girlImg,5)

  -- local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
  -- girlDescBg:setContentSize(CCSizeMake(400,200))
  -- girlDescBg:setAnchorPoint(ccp(0,0))
  -- girlDescBg:setPosition(200,h+30)
  -- self.bgLayer:addChild(girlDescBg,4)

  -- local descTv=G_LabelTableView(CCSize(280,180),getlocal("activity_customLottery_Desc"),25,kCCTextAlignmentCenter)
 	-- descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
 	-- descTv:setAnchorPoint(ccp(0,0))
  -- descTv:setPosition(ccp(70,10))
  -- girlDescBg:addChild(descTv,2)
  -- descTv:setMaxDisToBottomOrTop(50)

  h = h - 60

  
  local function cellClick(hd,fn,index)
  end
   
  self.backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(130, 50, 1, 1),cellClick)
  self.backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, h-20))
  self.backSprie:setAnchorPoint(ccp(0.5,1))
  self.backSprie:setPosition(ccp(G_VisibleSizeWidth/2, h))
  self.bgLayer:addChild(self.backSprie,6)

  local function cellClick(hd,fn,index)
  end
   

  self.rewardSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(130, 50, 1, 1),cellClick)
  self.rewardSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 80, h-430))
  self.rewardSprie:setAnchorPoint(ccp(0.5,1))
  self.rewardSprie:setPosition(ccp(self.backSprie:getContentSize().width/2, self.backSprie:getContentSize().height-10))
  self.backSprie:addChild(self.rewardSprie,7)
  self.rewardSprie:setIsSallow(false) -- 点击事件透下去

   -- --以下代码处理上下遮挡层
   -- local function forbidClick()
   
   -- end
   -- local rect2 = CCRect(0, 0, 50, 50);
   -- local capInSet = CCRect(20, 20, 10, 10);
   -- self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
   -- self.topforbidSp:setTouchPriority(-(self.layerNum-1)*20-4)
   -- self.topforbidSp:setIsSallow(false)
   -- self.topforbidSp:setAnchorPoint(ccp(0,1))
   -- self.topforbidSp:setContentSize(CCSize(10,300))
   -- self.topforbidSp:setPosition(500,self.bgLayer:getContentSize().height)
   -- self.bgLayer:addChild(self.topforbidSp)
   -- self.topforbidSp:setVisible(false)

   -- self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
   -- self.bottomforbidSp:setTouchPriority(-(self.layerNum-1)*20-4)
   -- self.bottomforbidSp:setAnchorPoint(ccp(0,0))
   -- self.bottomforbidSp:setContentSize(CCSize(500,400))
   -- self.bottomforbidSp:setPosition(10,0)
   -- self.bgLayer:addChild(self.bottomforbidSp)
   -- self.bottomforbidSp:setIsSallow(false)
   -- self.bottomforbidSp:setVisible(false)


  self.tv1Hight = h-510

  local reawrdTitleSp = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
  reawrdTitleSp:setContentSize(CCSizeMake(self.rewardSprie:getContentSize().width,60))
  reawrdTitleSp:setAnchorPoint(ccp(0,1))
  reawrdTitleSp:setPosition(0,self.rewardSprie:getContentSize().height-5)
  self.rewardSprie:addChild(reawrdTitleSp)


  local rewardTitleLb = GetTTFLabelWrap(getlocal("activity_customLottery_RewardRecode"),30,CCSizeMake(reawrdTitleSp:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  rewardTitleLb:setAnchorPoint(ccp(0,0.5))
  rewardTitleLb:setPosition(ccp(10,reawrdTitleSp:getContentSize().height/2))
  reawrdTitleSp:addChild(rewardTitleLb)

  self.noHadRewardLb = GetTTFLabelWrap(getlocal("activity_customLottery_NoRewardRecode"),30,CCSizeMake(self.rewardSprie:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  self.noHadRewardLb:setAnchorPoint(ccp(0.5,0.5))
  self.noHadRewardLb:setPosition(ccp(self.rewardSprie:getContentSize().width/2,(self.rewardSprie:getContentSize().height-60)/2))
  self.rewardSprie:addChild(self.noHadRewardLb)
  self.noHadRewardLb:setColor(G_ColorYellowPro)


  self:updateRewardList()


  local bgW = self.bgLayer:getContentSize().width-60
  local bgH = 230
  -- self.machineBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
  -- self.machineBg:setContentSize(CCSizeMake(bgW,bgH))
  -- self.machineBg:setAnchorPoint(ccp(0,0.5))
  -- self.machineBg:setPosition(10,self.backSprie:getContentSize().height/2 + 90)
  -- self.backSprie:addChild(self.machineBg)

  
  -- 10倍模式显示
  local mulX = 120
  local mulY = 170

  self.lotteryNumLb = GetTTFLabelWrap(getlocal("activity_customLottery_lotteryNum",{""}),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.lotteryNumLb:setAnchorPoint(ccp(0,0.5))
  self.lotteryNumLb:setPosition(ccp(20,mulY+25))
  self.backSprie:addChild(self.lotteryNumLb)
  self:updateLotteryNum()

  -- local bgSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch2)
  local bgSp = GetButtonItem("LegionCheckBtnUn.png","LegionCheckBtnUn.png","LegionCheckBtnUn.png",touch,5,nil)
  bgSp:setAnchorPoint(ccp(0,0.5))
  self.selectBtn=CCMenu:createWithItem(bgSp)
  self.selectBtn:setTouchPriority(-(self.layerNum-1)*20-5)
  self.selectBtn:setPosition(mulX-80,mulY)
  self.bgLayer:addChild(self.selectBtn)


  -- 选中状态
  self.mulSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
  self.mulSp:setAnchorPoint(ccp(0,0.5))
  self.mulSp:setPosition(mulX-80,mulY)
  self.bgLayer:addChild(self.mulSp)
  self.mulSp:setVisible(false)
  
  mulX = mulX + bgSp:getContentSize().width + 10
  self.mulDesc=GetTTFLabelWrap(getlocal("activity_customLottery_closePlay"),25,CCSizeMake(G_VisibleSizeWidth - mulX-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.mulDesc:setAnchorPoint(ccp(0,0.5))
  self.mulDesc:setPosition(mulX-80,mulY)
  self.mulDesc:setColor(G_ColorGreen)
  self.bgLayer:addChild(self.mulDesc)
  
  local costX = 200
  local costY = 100
  self.costLabel = GetTTFLabel(tostring(acCustomLotteryOneVoApi:getCfgCost()), 30)
  self.costLabel:setAnchorPoint(ccp(1,0))
  self.costLabel:setPosition(ccp(self.backSprie:getContentSize().width/2, costY))
  self.costLabel:setColor(G_ColorYellowPro)
  self.backSprie:addChild(self.costLabel)

  gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
  gemIcon:setAnchorPoint(ccp(0,0))
  gemIcon:setPosition(ccp(self.backSprie:getContentSize().width/2+10, costY))
  self.backSprie:addChild(gemIcon)
  
  self.rewardBtn=GetButtonItem("BtnRecharge.png","BtnRecharge.png","BtnRecharge.png",touch,2,getlocal("daily_lotto_tip_5"),28,11)
  self.rewardBtn:setAnchorPoint(ccp(0.5, 0))
  local menuAward=CCMenu:createWithItem(self.rewardBtn)
  menuAward:setPosition(ccp(self.backSprie:getContentSize().width/2,20))
  menuAward:setTouchPriority(-(self.layerNum-1)*20-5)
  self.backSprie:addChild(menuAward,1) 

  self:updateRewardBtn()

  -- local tableX = self.backSprie:getContentSize().width - 100
-- --兑奖表图标
--   local tableItem=GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",touch,3,nil,0)
--   tableItem:setAnchorPoint(ccp(0.5,0))
--   local tableBtn=CCMenu:createWithItem(tableItem)
--   tableBtn:setTouchPriority(-(self.layerNum-1)*20-5)
--   tableBtn:setPosition(ccp(tableX-30, 30))
--   self.backSprie:addChild(tableBtn)
-- --兑奖表TTF
--   local tableLb = GetTTFLabelWrap(getlocal("activity_slotMachine_tableLb"), 27,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
--   tableLb:setAnchorPoint(ccp(0.5,0))
--   tableLb:setColor(G_ColorYellowPro)
--   tableLb:setPosition(ccp(tableX-30, 30 + tableItem:getContentSize().height))
--   self.backSprie:addChild(tableLb)

  
  -- local barX = self.backSprie:getContentSize().width - 110
  -- local barY = nil
  -- -- self.bar=CCSprite:createWithSpriteFrameName("SlotBtn.png")
  -- -- self.bar:setPosition(ccp(barX,barY))
  -- -- self.backSprie:addChild(self.bar,2)

  -- self.bar=GetButtonItem("SlotBtn.png","SlotBtn.png","SlotBtn.png",touch,4,nil,0)
  -- -- barY = self.backSprie:getContentSize().height - self.bar:getContentSize().height / 2 - 110
  -- barY = self.backSprie:getContentSize().height/2 + 80
  -- self.bar:setAnchorPoint(ccp(0.5, 0.5))
  -- local bar2=CCMenu:createWithItem(self.bar)
  -- bar2:setPosition(ccp(barX,barY))
  -- bar2:setTouchPriority(-(self.layerNum-1)*20-5)
  -- self.backSprie:addChild(bar2,2)

  -- self:updateRewardBtn()
  
  
  -- local leftArrowX = barX - self.bar:getContentSize().width / 2 - 10
  -- local rightArrowX = barX + self.bar:getContentSize().width / 2 + 10
  -- local arrowY = nil
  -- local single = (self.bar:getContentSize().height - 10)/5

  -- for i=1,5 do
  --   arrowY = barY + self.bar:getContentSize().height / 2 + 10 - single/2 - single * (i - 1)
  --   local leftArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
  --   leftArrow:setPosition(ccp(leftArrowX,arrowY))
  --   self.backSprie:addChild(leftArrow)

  --   local rightArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
  --   rightArrow:setPosition(ccp(rightArrowX,arrowY))
  --   self.backSprie:addChild(rightArrow)
  -- end

  -- -- 把手左侧黄色的箭头图标
  -- self.leftIcon = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
  -- self.leftIcon:setPosition(ccp(leftArrowX,arrowY))
  -- self.leftIcon:setVisible(false)
  -- self.backSprie:addChild(self.leftIcon)


  -- -- 把手右侧黄色的箭头图标
  -- self.rightIcon = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
  -- self.rightIcon:setPosition(ccp(rightArrowX,arrowY))
  -- self.rightIcon:setVisible(false)
  -- self.backSprie:addChild(self.rightIcon)

end

function acCustomLotteryOneDialog:updateRewardList( ... )
  local list = acCustomLotteryOneVoApi:getHadRewardList()
  if list == nil then
    local function callBack(fn,data)
       local ret,sData = base:checkServerData(data)
        if ret==true then
          if sData.data.customLottery1 then
            acCustomLotteryOneVoApi:updateData(sData.data.customLottery1)
            self:showRewardList()
          end
        end
    end
    socketHelper:activityCustomLotteryList(callBack,true)
  else
    self:showRewardList()
  end
end

function acCustomLotteryOneDialog:showRewardList( ... )
  local list = acCustomLotteryOneVoApi:getHadRewardList()
  if list and type(list)=="table" and SizeOfTable(list)==0 then
    self.noHadRewardLb:setVisible(true)
  elseif list and type(list)=="table" and SizeOfTable(list)>0 then
    self.noHadRewardLb:setVisible(false)

    if self.tv1 ~= nil then
      self.tv1:reloadData()
    else
      local function callBack(...)
       return self:eventHandler1(...)
      end
      local hd= LuaEventHandler:createHandler(callBack)

      self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-100,self.tv1Hight),nil)
      self.rewardSprie:addChild(self.tv1,1)
      self.tv1:setAnchorPoint(ccp(0,0))
      self.tv1:setPosition(ccp(10,10))
      self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
      self.tv1:setMaxDisToBottomOrTop(120)
    end
  end
end


function acCustomLotteryOneDialog:eventHandler1(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    local list = acCustomLotteryOneVoApi:getHadRewardList()
    return SizeOfTable(list)
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(self.bgLayer:getContentSize().width-100,120)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local list = acCustomLotteryOneVoApi:getHadRewardList()

    local types,key,pNum = acCustomLotteryOneVoApi:getHadRewardItemByID(SizeOfTable(list)-idx)
    if types==nil or key == nil then
      do return end
    end
    local name,pic,desc,id,index,eType,equipId = getItem(key,types)
    local item={name=name,num=pNum,pic=pic,desc=desc,id=id,type=types,index=index,key=key,eType=eType,equipId=equipId}
    --local icon =G_getItemIcon(item,100)
    -- local iconSize=100

    -- local function showInfoHandler()
    --     if G_checkClickEnable()==false then
    --         do
    --             return
    --         end
    --     else
    --         base.setWaitTime=G_getCurDeviceMillTime()
    --     end
    --     if self.tv1:getScrollEnable()==true and self.tv1:getIsScrolled()==false then
    --         PlayEffect(audioCfg.mouseClick)
    --         if item.type=="e" then
    --             if item.eType=="a" or item.eType=="f" then
    --                 local isAccOrFrag=true
    --                 propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,isAccOrFrag)
    --             else
    --                 propInfoDialog:create(sceneGame,item,self.layerNum+1)
    --             end
    --         elseif item.name then
    --             if item.key == "energy" then
    --                 propInfoDialog:create(sceneGame,item,self.layerNum+1,nil, true)
    --             else
    --                 propInfoDialog:create(sceneGame,item,self.layerNum+1)
    --             end
                
    --         end
    --     end
        
    -- end
    -- local icon
    -- if item.type and item.type=="e" then
    --     if item.eType then
    --         if item.eType=="a" then
    --             icon = accessoryVoApi:getAccessoryIcon(item.key,iconSize/100*80,iconSize,showInfoHandler)
    --         elseif item.eType=="f" then
    --             icon = accessoryVoApi:getFragmentIcon(item.key,iconSize/100*80,iconSize,showInfoHandler)
    --         elseif item.pic and item.pic~="" then
    --             icon = LuaCCSprite:createWithSpriteFrameName(item.pic,showInfoHandler)
    --         end
    --     end
    -- elseif item.equipId then
    --     local eType=string.sub(item.equipId,1,1)
    --     if eType=="a" then
    --         icon = accessoryVoApi:getAccessoryIcon(item.equipId,iconSize/100*80,iconSize,showInfoHandler)
    --     elseif eType=="f" then
    --         icon = accessoryVoApi:getFragmentIcon(item.equipId,iconSize/100*80,iconSize,showInfoHandler)
    --     elseif eType=="p" then
    --         icon = LuaCCSprite:createWithSpriteFrameName(accessoryCfg.propCfg[award.equipId].icon,showInfoHandler)
    --     end
    -- elseif item.pic and item.pic~="" then
    --     if item.key == "energy" then
    --         icon = G_getItemIcon(item,100)
    --     else
    --         icon = LuaCCSprite:createWithSpriteFrameName(item.pic,showInfoHandler)
    --     end
    -- end
   
    local icon = G_getItemIcon(item)
    icon:setIsSallow(false)
    icon:ignoreAnchorPointForPosition(false)
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(ccp(10,60))
    icon:setTouchPriority(-(self.layerNum-1)*20-3)
    cell:addChild(icon,1)

    local iconBg = CCSprite:createWithSpriteFrameName("Icon_BG.png")
    -- iconBg:setScale(icon:getContentSize().width/iconBg:getContentSize().width)
    iconBg:setScale(1.3)
    iconBg:setAnchorPoint(ccp(0,0.5))
    iconBg:setPosition(ccp(10,60))
    cell:addChild(iconBg)

  local descLb = GetTTFLabelWrap(name.." x"..pNum,30,CCSizeMake(self.bgLayer:getContentSize().width-250,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
  descLb:setAnchorPoint(ccp(0,0.5))
  descLb:setPosition(ccp(50+iconBg:getContentSize().width,60))
  cell:addChild(descLb)

  local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
  lineSP:setAnchorPoint(ccp(0.5,0.5))
  lineSP:setScaleX((G_VisibleSizeWidth-100)/lineSP:getContentSize().width)
  lineSP:setScaleY(1.2)
  lineSP:setPosition(ccp((G_VisibleSizeWidth-100)/2,3))
  cell:addChild(lineSP,2)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end
-- 更新剩余次数
function acCustomLotteryOneDialog:updateLotteryNum()
	if self.lotteryNumLb ~= nil then
		local num = acCustomLotteryOneVoApi:getLeftLotteryNum()
    print(num)
		if num==tonumber(-1) then
			self.lotteryNumLb:setVisible(false)
		else
			self.lotteryNumLb:setVisible(true)
			local str = getlocal("activity_customLottery_lotteryNum",{tostring(num)})
			self.lotteryNumLb:setString(str)
			if num>0 then
				self.lotteryNumLb:setColor(G_ColorWhite)
			else
				self.lotteryNumLb:setColor(G_ColorRed)
			end
		end
		
	end
end

-- 刷新领奖按钮
function acCustomLotteryOneDialog:updateRewardBtn()
  if self.rewardBtn ~= nil then --and self.bar~=nil  then
		if acCustomLotteryOneVoApi:getLeftLotteryNum() == 0 then
			 self.rewardBtn:setEnabled(false)
        --self.bar :setEnabled(false)
		else
		   self.rewardBtn:setEnabled(true)
      --self.bar:setEnabled(true)
		end
	end
end

function acCustomLotteryOneDialog:openInfo()
  local td=smallDialog:new()
  local tabStr = {"\n",getlocal("activity_customLottery_Tip3"),"\n",getlocal("activity_customLottery_Tip2"),"\n",getlocal("activity_customLottery_Tip1"),"\n"}
  local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acCustomLotteryOneDialog:update()
  local acVo = acCustomLotteryOneVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      self:updateRewardBtn()
    end
  end
end

function acCustomLotteryOneDialog:updateAcTime()
  local acVo=acCustomLotteryOneVoApi:getAcVo()
  if acVo and self.timeLb then
    G_updateActiveTime(acVo,self.timeLb)
  end
end


function acCustomLotteryOneDialog:dispose()
  self.costLabel = nil
  self.rewardBtn = nil

  self.selectMul = nil
  self.mulSp = nil
  self.mulDesc = nil
  self.selectBtn = nil

  -- self.bar = nil -- 右侧把手
  -- self.leftIcon = nil -- 把手左侧黄色的箭头图标
  -- self.rightIcon = nil -- 把手右侧黄色的箭头图标
  -- self.backSprie = nil -- 下方的背景
  -- self.lastSt = nil -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  -- self.lastIndex = nil -- 上一次把手上的黄色箭头在第几个位置

  self.turnSingleAreaH = nil
  self.turnNum = nil
  
  self.particleS = nil -- 粒子效果
  self.addParticlesTs = nil -- 添加粒子效果的时间
  self.selectBg = nil
  self.state = nil

  self.selectPositionY=nil
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

  self.iconTab=nil
  self.hasLottery=nil
  self.tv1Hight = nil
  self.tv1=nil
  self.timeLb=nil

  self=nil
end






