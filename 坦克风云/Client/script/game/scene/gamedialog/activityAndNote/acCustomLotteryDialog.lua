 acCustomLotteryDialog=commonDialog:new()

function acCustomLotteryDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

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

    self.lastMul = nil -- 抽取后后台返回的模式

    self.iconTab={}
    self.hasLottery=false

    self.tv1Hight = nil


    return nc
end

function acCustomLotteryDialog:initTableView()
  
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
end

function acCustomLotteryDialog:eventHandler(handler,fn,idx,cel)
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

function acCustomLotteryDialog:iconFlicker(icon)
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
function acCustomLotteryDialog:resetMetalSps()
  for k,v in pairs(self.metalSpTable) do
    if v ~= nil then
      v:stopAllActions()
      v:removeFromParentAndCleanup(true)
    end
  end
  self.metalSpTable = {}
end

function acCustomLotteryDialog:initSp()
  
end
function acCustomLotteryDialog:changeItemSP() 
	self.moveDis=self.moveDis+1
  local list = acCustomLotteryVoApi:getRewardListCfg()
  local listSize = SizeOfTable(list)
  if listSize<=0 then
    do return end
  end
  local randomID = math.random(1,listSize)
	local types,key,pNum = acCustomLotteryVoApi:getRewardItemByID(randomID)
  if types==nil or key == nil then
    do return end
  end
  local name,pic,desc,id,index,eType,equipId = getItem(key,types)
	if self.showItem then
    	self.showItem:removeFromParentAndCleanup(true)
    end
    local item={name=name,num=num,pic=pic,desc=desc,id=id,type=types,index=index,key=key,eType=eType,equipId=equipId}
    self.showItem,scale=G_getItemIcon(item,100)
    -- self.showItem:setScale(120/self.showItem:getContentSize().width)
    self.showItem:setAnchorPoint(ccp(0,0.5))
    self.showItem:setPosition(ccp(20,self.selectBg:getContentSize().height/2))
    self.selectBg:addChild(self.showItem)

	local descLb = GetTTFLabelWrap(name.." x"..pNum,30,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0,0.5))
  descLb:setScale(1/scale*0.8)
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

function acCustomLotteryDialog:fastTick()
  if self.state == 2 then
    -- print("动画播放中： ", self.state)
    local cout1=40
    local count2=20
    if self.tag~=1 then
      cout1=20
      count2=10
    end
    self.moveDis=self.moveDis+1
    self.changeSp=self.changeSp+1
    if self.moveDis<=(self.moveDisNum*1/3) then
    	if self.changeSp>=cout1 then
    		self.changeSp=0
    		self:changeItemSP()
    	end
    elseif self.moveDis>(self.moveDisNum*1/3) and self.moveDis<(self.moveDisNum*2/3) then
    	if self.changeSp>=count2 then
    		self.changeSp=0
    		self:changeItemSP()
    	end
    elseif self.moveDis>(self.moveDisNum*2/3) then
    	if self.changeSp>=cout1 then
    		self.changeSp=0
    		self:changeItemSP()
    	end
    end
  elseif self.state == 3 then
    self:stopPlayAnimation()
  end
end


function acCustomLotteryDialog:tick()
  if self.particleS ~= nil and base.serverTime - self.addParticlesTs > 10 then
    self:removeParticles()
  end
  self:updateAcTime()
end

function acCustomLotteryDialog:startPalyAnimation()
  print("开始")
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
  -- self.rewardBtn:setEnabled(false)
  --self.selectBg:setVisible(false)
  self:resetMetalSps()
  --base:addNeedRefresh(self)
end

function acCustomLotteryDialog:stopPlayAnimation()
  print("正常~")
  self.state = 0
  -- self.lastSt = 0 -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  -- self.lastIndex = 0 -- 上一次把手上的黄色箭头在第几个位置
  -- self:stopBarPlay()
  -- self.rewardBtn:setEnabled(true)
  self.selectBg:setVisible(true)
  self:afterGetReward()
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
  --base:removeFromNeedRefresh(self)
end


-- function acCustomLotteryDialog:stopBarPlay()
--   self.leftIcon:setVisible(false)
--   self.rightIcon:setVisible(false)
-- end

-- 抽取奖励
function acCustomLotteryDialog:getReward(tag)
  self.tag=tag
  self.state = 1
  local cost = acCustomLotteryVoApi:getCfgCost(self.tag)

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
            if sData.data ~= nil and sData.data[self.activeName] then
              self:addRewardAndCostMoney()
              if sData.data[self.activeName].reward and type(sData.data[self.activeName].reward)=="table" and SizeOfTable(sData.data[self.activeName].reward)>0 then
                self.reward=sData.data[self.activeName].reward
                acCustomLotteryVoApi:updateHadLotteryNum(1)
                acCustomLotteryVoApi:updateData(sData.data[self.activeName])

                if self.tag==1 then
                  if self.selectMul==true then
                    self:resetMetalSps()
                    self:stopPlayAnimation()
                    --self:stopPlayAnimation()
                  else
                    self:startPalyAnimation()
                  end
                else
                  self.content={}
                  self.addDestr={}
                  self.msgContent={}
                  -- activity_customLottery_common_tvDes
                  for k,v in pairs(self.reward) do
                    local award=FormatItem(v[1])
                    award[1].num=award[1].num*v[2]
                    bagVoApi:addBag(award[1].id,award[1].num)
                    if acCustomLotteryVoApi:getIsChatMessegeByID(award[1].type,award[1].key) ==true then
                      local message={key="chatSystemMessage13",param={playerVoApi:getPlayerName(),getlocal("activity_customLottery_title"),award[1].name," x"..award[1].num}}
                      chatVoApi:sendSystemMessage(message)
                    end

                    table.insert(self.content,{award=award[1]})
                    table.insert(self.addDestr,"(" .. getlocal("activity_customLottery_common_btn",{v[2]}) .. ")")
                    table.insert(self.msgContent,getlocal("activity_customLottery_common_tvDes",{award[1].name .. "*" .. award[1].num}))
                  end
                  if self.selectMul==true then
                    self:resetMetalSps()
                    self:stopPlayAnimation()
                  else
                    self:startPalyAnimation()
                    self:addParticle()
                  end
                end
                
              end
              
            end
        end
      end
    socketHelper:activityCustomLottery(getRawardCallback,nil,self.tag,self.activeName)
  end

end

-- 后台返回结果之后马上扣除金币并且给予奖励
function acCustomLotteryDialog:addRewardAndCostMoney()

  local aNum = 1 -- 是否加倍模式
  local aCost = acCustomLotteryVoApi:getCfgCost(self.tag) -- 花费的金币

  local playerGem=playerVoApi:getGems()
  playerGem=playerGem - aCost
  playerVoApi:setGems(playerGem)
end


-- 处理后台得到返回抽取结构后前台的处理
function acCustomLotteryDialog:afterGetReward()

  local reward=FormatItem(self.reward[1][1])
  local item=reward[1]
   if self.showItem then
    	self.showItem:removeFromParentAndCleanup(true)
    	--self.showItem=nil
    end
    self.showItem,scale=G_getItemIcon(item,100)
    self.showItem:setAnchorPoint(ccp(0,0.5))
    self.showItem:setPosition(ccp(20,self.selectBg:getContentSize().height/2))
    self.selectBg:addChild(self.showItem)

	local descLb = GetTTFLabelWrap((item.name.." x"..item.num),30,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
  descLb:setScale(1/scale*0.8)-------
	descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setPosition(ccp(10+self.showItem:getContentSize().width,self.showItem:getContentSize().height/2))
	self.showItem:addChild(descLb,101)
	self:iconFlicker(self.showItem)

  if self.tag~=1 then
    if self.tag==10 or self.tag==50 then
      if self.display1 and self.display2 then
        self.display1:removeFromParentAndCleanup(true)
        self.display2:removeFromParentAndCleanup(true)
        self.display1=nil
        self.display2=nil
      end
      self:showRewardList()
      self:updateLotteryNum()
      smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),self.content,nil,true,self.layerNum+1,nil,true,true,nil,true,true,self.msgContent,nil,nil,nil,nil,nil,nil,self.addDestr,nil,255)
    end
    return
  end

  
  bagVoApi:addBag(item.id,item.num)

  G_showRewardTip(reward,true)
  self:updateLotteryNum()
  self:updateRewardBtn()
  if acCustomLotteryVoApi:getIsChatMessegeByID(item.type,item.key) ==true then
    local message={key="chatSystemMessage13",param={playerVoApi:getPlayerName(),getlocal("activity_customLottery_title"),item.name," x"..item.num}}
    chatVoApi:sendSystemMessage(message)
  end

  self:showRewardList()

end

function acCustomLotteryDialog:doUserHandler()
  self.activeName=acCustomLotteryVoApi:getActiveName()

  local function touch(tag,object)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
    end
    PlayEffect(audioCfg.mouseClick)
    if tag == 2 then
      self:openInfo()
    elseif tag == 1 or tag==10 or tag==50 then
      self:getReward(tag)
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
  local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,2,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,1))
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(w, h))
  self.bgLayer:addChild(menuDesc,2)
 
  h = h - 40

  local acVo = acCustomLotteryVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,28)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp(G_VisibleSizeWidth/2+20, h))
  self.bgLayer:addChild(messageLabel,3)
  self.timeLb=messageLabel
  self:updateAcTime()

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
  local mulY = 190

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


  local btnPosY=10
  local btnPosX=self.backSprie:getContentSize().width/2
  local btnTb={
    {num=50,pos=ccp(btnPosX+190,btnPosY),tag=50},
    {num=10,pos=ccp(btnPosX,btnPosY),tag=10},
    {num=1,pos=ccp(btnPosX-190,btnPosY),tag=1}
  }

  for k,v in pairs(btnTb) do
      local rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touch,v.tag,getlocal("activity_customLottery_common_btn",{v.num}),25,11)
      rewardBtn:setAnchorPoint(ccp(0.5, 0))
      local menuAward=CCMenu:createWithItem(rewardBtn)
      menuAward:setPosition(v.pos)
      menuAward:setTouchPriority(-(self.layerNum-1)*20-5)
      self.backSprie:addChild(menuAward,1) 

      local glodW=15
      if k==1 then
        glodW=25
      elseif k==2 then
        glodW=20
      elseif k==3 then
        glodW=15
      end
      local cost=tostring(acCustomLotteryVoApi:getCfgCost(v.tag))
      local costY=rewardBtn:getContentSize().height+25
      local costLabel = GetTTFLabel(cost, 30)
      costLabel:setAnchorPoint(ccp(1,0.5))
      costLabel:setPosition(ccp(rewardBtn:getContentSize().width/2+glodW-8, costY))
      costLabel:setColor(G_ColorYellowPro)
      rewardBtn:addChild(costLabel)

      local gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
      gemIcon:setAnchorPoint(ccp(0,0.5))
      gemIcon:setPosition(ccp(rewardBtn:getContentSize().width/2+glodW, costY))
      rewardBtn:addChild(gemIcon)
  end

  self:updateRewardBtn()

end

function acCustomLotteryDialog:updateRewardList( ... )
  local list = acCustomLotteryVoApi:getHadRewardList()
  if list == nil then
    local function callBack(fn,data)
       local ret,sData = base:checkServerData(data)
        if ret==true then
          if sData.data[self.activeName] then
            acCustomLotteryVoApi:updateData(sData.data[self.activeName])
            self:showRewardList()
          end
        end
    end
    socketHelper:activityCustomLotteryList(callBack,nil,self.activeName)
  else
    self:showRewardList()
  end
end

function acCustomLotteryDialog:showRewardList( ... )
  local list = acCustomLotteryVoApi:getHadRewardList()
  self.list=list
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


function acCustomLotteryDialog:eventHandler1(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(self.list)
  elseif fn=="tableCellSizeForIndex" then
    local totalnum=SizeOfTable(self.list)
    local num=0
    local item=self.list[totalnum-idx]
    for k,v in pairs(item[1]) do
      num=SizeOfTable(v)
    end
    return  CCSizeMake(self.bgLayer:getContentSize().width-100,120*num)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local list = self.list
    local totalNum=SizeOfTable(list)
    local item=FormatItem(list[totalNum-idx][1])
    
    local count=0
    for k,v in pairs(item) do
      local icon = G_getItemIcon(v)
      icon:setIsSallow(false)
      icon:ignoreAnchorPointForPosition(false)
      icon:setAnchorPoint(ccp(0,0.5))
      icon:setPosition(ccp(10,60+count*120))
      icon:setTouchPriority(-(self.layerNum-1)*20-3)
      cell:addChild(icon,1)

      local iconBg = CCSprite:createWithSpriteFrameName("Icon_BG.png")
      -- iconBg:setScale(icon:getContentSize().width/iconBg:getContentSize().width)
      iconBg:setScale(1.3)
      iconBg:setAnchorPoint(ccp(0,0.5))
      iconBg:setPosition(ccp(10,60+count*120))
      cell:addChild(iconBg)

      local descLb = GetTTFLabelWrap(v.name.." x"..v.num,30,CCSizeMake(self.bgLayer:getContentSize().width-250,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
      descLb:setAnchorPoint(ccp(0,0.5))
      descLb:setPosition(ccp(50+iconBg:getContentSize().width,60+count*120))
      cell:addChild(descLb)
      count=count+1
    end

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
function acCustomLotteryDialog:updateLotteryNum()
	if self.lotteryNumLb ~= nil then
		local num = acCustomLotteryVoApi:getLeftLotteryNum()
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
function acCustomLotteryDialog:updateRewardBtn()
 --  if self.rewardBtn ~= nil then --and self.bar~=nil  then
	-- 	if acCustomLotteryVoApi:getLeftLotteryNum() == 0 then
	-- 		 self.rewardBtn:setEnabled(false)
 --        --self.bar :setEnabled(false)
	-- 	else
	-- 	   self.rewardBtn:setEnabled(true)
 --      --self.bar:setEnabled(true)
	-- 	end
	-- end
end

function acCustomLotteryDialog:addParticle()
    for i=1,2 do
      local display = CCParticleSystemQuad:create("public/lineFLY.plist")
      display:setPositionType(kCCPositionTypeRelative)
      self.selectBg:addChild(display,4)
      display:setScaleX(1.8)
      local pos
      local angle
      if i==1 then
        angle=90
        pos=ccp(0,self.selectBg:getContentSize().height/2)
      else
        angle=-90
        pos=ccp(self.selectBg:getContentSize().width,self.selectBg:getContentSize().height/2)
      end
      display:setPosition(pos)
      display:setRotation(angle)
      self["display".. i]=display
    end
  
 
end



function acCustomLotteryDialog:openInfo()
  local td=smallDialog:new()
  local tabStr = {"\n",getlocal("activity_customLottery_Tip3"),"\n",getlocal("activity_customLottery_Tip2"),"\n",getlocal("activity_customLottery_Tip1"),"\n"}
  local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acCustomLotteryDialog:update()
  local acVo = acCustomLotteryVoApi:getAcVo()
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

function acCustomLotteryDialog:updateAcTime()
  local acVo=acCustomLotteryVoApi:getAcVo()
  if acVo and self.timeLb then
    G_updateActiveTime(acVo,self.timeLb)
  end
end

function acCustomLotteryDialog:dispose()

  self.selectMul = nil
  self.mulSp = nil
  self.mulDesc = nil
  self.selectBtn = nil

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

  self.lastMul = nil

  self.iconTab=nil
  self.hasLottery=nil
  self.tv1Hight = nil
  self.tv1=nil
  self.timeLb=nil
end






