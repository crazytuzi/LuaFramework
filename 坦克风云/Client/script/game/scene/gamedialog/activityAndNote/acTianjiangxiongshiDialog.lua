acTianjiangxiongshiDialog=commonDialog:new()

function acTianjiangxiongshiDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.costLabel = nil

    self.selectMul = false -- 是否勾选10倍收益
    self.suoFlag = false -- 是否勾选锁定坦克
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
    self.spTb4Speed=nil
    self.moveDis=0
    self.isStop1=nil
    self.isStop2=nil
    self.isStop3=nil
    self.isStop4=nil
    self.moveDisNum=200

    self.desTv = nil -- 面板上的说明信息
    self.metalSpTable = {} -- 边框动画效果
    self.touchDialogBg = nil

    self.currentCanGetReward = nil
    self.lastMul = nil -- 抽取后后台返回的模式
    self.isToday=true
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acTianjiangxiongshi.plist")
    return nc
end

function acTianjiangxiongshiDialog:initTableView()
  
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
  
  local bgW = 380

  local myBg=LuaCCScale9Sprite:createWithSpriteFrameName("tianjiangxiongshi_kuang.png",CCRect(67, 35, 1, 1),function () do return end end)
  myBg:setContentSize(CCSizeMake(bgW+20,330))
  myBg:setAnchorPoint(ccp(0,0.5))
  myBg:setPosition(10,self.backSprie:getContentSize().height/2+30)
  self.backSprie:addChild(myBg,6)

  local machineBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
  machineBg:setContentSize(CCSizeMake(bgW,300))
  machineBg:setAnchorPoint(ccp(0,0.5))
  machineBg:setPosition(20,self.backSprie:getContentSize().height/2+30)
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

	local function callBack2(...)
		return self:eventHandler2(...)
	end
	local hd1= LuaEventHandler:createHandler(callBack2)
	local height=0;
	self.tv1=LuaCCTableView:createHorizontalWithEventHandler(hd1,CCSizeMake(self.maybeBorder:getContentSize().width-40,self.maybeBorder:getContentSize().height),nil)
	-- self.tv1:setAnchorPoint(ccp(0,0))
	self.tv1:setPosition(ccp(20,0))
	self.tv1:setMaxDisToBottomOrTop(120)
	self.maybeBorder:addChild(self.tv1,3)

  
  local maskH = 80
  local topMask=LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  topMask:setAnchorPoint(ccp(0.5,1))
  topMask:setContentSize(CCSizeMake(bgW,maskH))
  topMask:setPosition(bgW/2,machineBg:getContentSize().height)
  machineBg:addChild(topMask,2)

  local bottomMask=LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  bottomMask:setContentSize(CCSizeMake(bgW,maskH))
  bottomMask:setPosition(bgW/2,bottomMask:getContentSize().height/2)
  bottomMask:setRotation(180)
  machineBg:addChild(bottomMask,3)


  local leftMask=LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  leftMask:setAnchorPoint(ccp(1,1))
  leftMask:setContentSize(CCSizeMake(self.maybeBorder:getContentSize().height-15,self.maybeBorder:getContentSize().height-10))
  leftMask:setPosition(10,self.maybeBorder:getContentSize().height-10)
  self.maybeBorder:addChild(leftMask,4)
  leftMask:setRotation(-90)

  local rightMask=LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  leftMask:setAnchorPoint(ccp(1,1))
  rightMask:setContentSize(CCSizeMake(self.maybeBorder:getContentSize().height-15,self.maybeBorder:getContentSize().height-10))
  rightMask:setPosition(self.maybeBorder:getContentSize().width-70,self.maybeBorder:getContentSize().height/2)
  rightMask:setRotation(90)
  self.maybeBorder:addChild(rightMask,4)

end


function acTianjiangxiongshiDialog:eventHandler(handler,fn,idx,cel)
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
    local picY = totalH - self.turnSingleAreaH * 3 + 10-40
    if self.selectBg == nil then
      self.selectBg=LuaCCScale9Sprite:createWithSpriteFrameName("SlotSelect.png",CCRect(10, 10, 1, 1),function () do return end end)
      self.selectBg:setContentSize(CCSizeMake(380,self.turnSingleAreaH))
      self.selectBg:setAnchorPoint(ccp(0.5,0))
      self.selectBg:setPosition(380/2,picY)
      cell:addChild(self.selectBg)
    end

    for i=1,3 do
        local startId = acTianjiangxiongshiVoApi:getLastResultByLine(i)
        for i2=1,2 do
          if startId == 1 then
            startId = 5
          else
            startId = startId - 1
          end
        end

        for id=1,self.turnNum do
          picY = totalH - self.turnSingleAreaH * id + 22-40
          if startId == self.turnNum then
            pic = acTianjiangxiongshiVoApi:getPicById(1)
          else
            pic = acTianjiangxiongshiVoApi:getPicById(startId)
          end
          local icon = CCSprite:createWithSpriteFrameName(pic)
          -- icon:setScale(0.7)
          picX = 20 + (i-1) * 115
          icon:setAnchorPoint(ccp(0,0))
          icon:setPosition(ccp(picX, picY))
          icon:setScale(1)
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

function acTianjiangxiongshiDialog:eventHandler2(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
  	self.height=self.maybeBorder:getContentSize().height
    return  CCSizeMake(540,self.maybeBorder:getContentSize().height)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

	local tankNum=SizeOfTable(self.tankTb)

	self.tankTable={}
	for i=1,tankNum do
		local tankId = tonumber(RemoveFirstChar(self.tankTb[i]))
		local pic = tankCfg[tankId].icon
		local sp = CCSprite:createWithSpriteFrameName(pic)
		cell:addChild(sp)
		sp:setScale(0.5)
		sp:setPosition(270,self.height/2)
		self.tankTable[i]=sp
	end

	local function touchPaihang()
		if G_checkClickEnable()==false then
	        do
	            return
	        end
	    else
	        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
	    end

	    PlayEffect(audioCfg.mouseClick)
	    local tankID = tonumber(RemoveFirstChar(acTianjiangxiongshiVoApi:getRewardTank()))
		tankInfoDialog:create(nil,tankID,self.layerNum+1, nil)
	end
	self.hungK = LuaCCScale9Sprite:createWithSpriteFrameName("arrange1.png",CCRect(20, 20, 10, 10),touchPaihang)
	self.hungK:setContentSize(CCSizeMake(150*0.7,150*0.7))
	self.hungK:setPosition(ccp(270,self.height/2))
	self.hungK:setTouchPriority(-(self.layerNum-1)*20-4)
	cell:addChild(self.hungK)
	self.hungK:setVisible(true)

	self:resertTankPos()

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acTianjiangxiongshiDialog:iconFlicker(icon)
  -- local m_iconScaleX,m_iconScaleY=1.65,0.95
  local m_iconScaleX,m_iconScaleY=1.3,1.3
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
function acTianjiangxiongshiDialog:resetMetalSps()
  for k,v in pairs(self.metalSpTable) do
    if v ~= nil then
      v:stopAllActions()
      v:removeFromParentAndCleanup(true)
    end
  end
  self.metalSpTable = {}
end

function acTianjiangxiongshiDialog:initSp()
  
end

function acTianjiangxiongshiDialog:moveSp(tb)
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

  	-- 横向速度
	if self.moveDis>120 and self["isStop4"]==false then
		if self.moveDis%10==0 then
			self["spTb4Speed"]=self["spTb4Speed"]-5 
			if self["spTb4Speed"]<=5 then
				self["spTb4Speed"]=5
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
        if self.moveDis>self.moveDisNum and v.id==tb[i] and v.sp:getPositionY()==self.selectPositionY and self["isStop"..i]== false and self["isStop4"]== true then
           self["spTb"..i.."Speed"]=0
           self["isStop"..i]=true
           self:fuwei(v.id,self["spTb"..i])
        end
    end
  end
  -- self.tankTable[i]
  if self.suoFlag==false then
	  local num = SizeOfTable(self.tankTable)
	  for k,v in pairs(self.tankTable) do
	  	v:setPosition(ccp(v:getPositionX()+self["spTb4Speed"],v:getPositionY()))
	  	if v:getPositionX()>=270+(num-3)*120 then
	  		v:setPosition(ccp(270-3*120,v:getPositionY()))
	  	end
	  	if v:getPositionX()>=240 and v:getPositionX()<=300 then
			v:setScale(0.7)
		else
			v:setScale(0.5)
		end
		if self.moveDis>120 and self.tankTb[k]==acTianjiangxiongshiVoApi:getRewardTank() and v:getPositionX()==270  and self["isStop4"]== false then
			self["spTb4Speed"]=0
			self["isStop4"]=true
			self:resertTankPos()
		end
	  end
  else
      self["spTb4Speed"]=0
      self["isStop4"]=true    
	end


  if self["isStop1"]==true and self["isStop2"]==true and self["isStop3"]==true and  self["isStop4"]==true then
    self.state = 3
    -- print("动画播放结束： ", self.state)
  end
end

function acTianjiangxiongshiDialog:fuwei(key,tb)
	local subH=40
	local tbP = {22-subH,142-subH,262-subH,382-subH,502-subH}
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

function acTianjiangxiongshiDialog:result(tb)
  self.spTb1Speed=0
  self.spTb2Speed=0
  self.spTb3Speed=0
  self.spTb4Speed=0
  self.isStop1=true
  self.isStop2=true
  self.isStop3=true
  self.isStop4=true
  for i=1,3 do
    for k,v in pairs(self["spTb"..i]) do
      if v.id==tb[i] then
         v.sp:setPositionY(self.selectPositionY)
         self:fuwei(v.id, self["spTb"..i])
      end
    end
  end
  self:resertTankPos()
end


function acTianjiangxiongshiDialog:fastTick()
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

function acTianjiangxiongshiDialog:updateAcTime()
    local acVo=acTianjiangxiongshiVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acTianjiangxiongshiDialog:tick()
  self:updateAcTime()
  self:update()
  if self.particleS ~= nil and base.serverTime - self.addParticlesTs > 10 then
    self:removeParticles()
  end

  if acTianjiangxiongshiVoApi:isToday()==false and self.isToday==true then
  	-- self.isToday=acTianjiangxiongshiVoApi:isToday()
    self.isToday=false
  	self:refresh()
  end
end

function acTianjiangxiongshiDialog:refresh()
	self.suoFlag = false
	if self.blackIcon1 then
		self.blackIcon1:setVisible(false)
	end
	if self.blackIcon2 then
		self.blackIcon2:setVisible(false)
	end
	if self.suoSp then
		self.suoSp:setVisible(false)
	end
	self.selectMul = false
	if self.mulSp then
		self.mulSp:setVisible(false)
	end  
	if self.costLabel then
		self.costLabel:setString(getlocal("daily_lotto_tip_2"))
	end
	if self.gemIcon then
		self.gemIcon:setVisible(false)
	end
	-- if self.upSp then
	-- 	self.upSp:setVisible(false)
	-- 	self.upSp:stopAllActions()
	-- 	self.upSp:setPosition(self.maybeBorder:getContentSize().width/2, self.maybeBorder:getContentSize().height)
	-- end
	-- if self.downSp then
	-- 	self.downSp:setVisible(false)
	-- 	self.downSp:stopAllActions()
	-- 	self.downSp:setPosition(self.maybeBorder:getContentSize().width/2,-20)
	-- end   
	if self.suo2 then
		self.suo2:setVisible(false)
	end
	if self.suo1 then
		self.suo1:setVisible(false)
	end
end



function acTianjiangxiongshiDialog:startPalyAnimation()
  self.spTb1Speed=math.random(10,15) 
  self.spTb2Speed=math.random(15,20)
  self.spTb3Speed=math.random(20,25)
  self.spTb4Speed=20
  self.moveDis=0
  self.isStop1=false
  self.isStop2=false
  self.isStop3=false
  self.isStop4=false
  self.state = 2
  self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
  -- print("得到抽取结果~")
  self.lastSt = 0 -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  self.lastIndex = 1 -- 上一次把手上的黄色箭头在第几个位置
  self.leftIcon:setVisible(true)
  self.rightIcon:setVisible(true)
  self.bar:setEnabled(false)
  self.bar:setRotation(180)
  self.selectBg:setVisible(false)
  self.hungK:setVisible(false)
  self:resetMetalSps()
end

function acTianjiangxiongshiDialog:stopPlayAnimation()
  -- print("正常~")
  self.state = 0
  self.lastSt = 0 -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  self.lastIndex = 0 -- 上一次把手上的黄色箭头在第几个位置
  self:stopBarPlay()
  self.bar:setEnabled(true)
  self.bar:setRotation(0)
  self.selectBg:setVisible(true)
  local getTable= self:resetData(self.playIds)
  self:aftetGetReward(getTable)
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
end

-- 把手播放动画
function acTianjiangxiongshiDialog:barPaly()
  if self ~= nil then
    local barX = self.backSprie:getContentSize().width - 110
    local leftArrowX = barX - self.bar:getContentSize().width / 2 - 10
    local rightArrowX = barX + self.bar:getContentSize().width / 2 + 10
    local arrowY = nil
    local single = (self.bar:getContentSize().height - 10)/5
    arrowY = self.backSprie:getContentSize().height/2  + self.bar:getContentSize().height / 2 + 10 - single/2 - single * (self.lastIndex - 1)
    self.leftIcon:setPosition(ccp(leftArrowX,arrowY))
    self.rightIcon:setPosition(ccp(rightArrowX,arrowY))
    self.lastIndex = self.lastIndex + 1
    if self.lastIndex > 5 then
      self.lastIndex = 1
    end
  end
end

function acTianjiangxiongshiDialog:stopBarPlay()
  self.leftIcon:setVisible(false)
  self.rightIcon:setVisible(false)
end

-- 抽取奖励
function acTianjiangxiongshiDialog:getReward()
	local method=1
	local free=false
	if acTianjiangxiongshiVoApi:canReward()==true then
		method=1
		free=true
	else
		local num=self:getChoujiangType()
		method=num
		local cost = acTianjiangxiongshiVoApi:getCost(num)
		if cost>playerVoApi:getGems() then
			GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
			return
		end
	end

	local function getRawardCallback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
		-- 这里数据包了slotMachine和show两层，是为了防止每次后台返回数据，前台自动通过
		--base:formatPlayerData(data)这个方法同步数据时有不同数据用了同一个标识的情况
			if sData and sData.data and sData.data.report then
				self.playIds = sData.data.report
				acTianjiangxiongshiVoApi:updateLastResult(self.playIds)
			end
			if sData and sData.data and sData.data.reward then
				local reward = FormatItem(sData.data.reward)
				acTianjiangxiongshiVoApi:setRewardTank(reward[1].key)
				self.reward=reward
			end
			if free then
				acTianjiangxiongshiVoApi:setLastTime(sData.ts)
        self.isToday=true
			end
			self:addRewardAndCostMoney(free,method)
			self:startPalyAnimation()
			self:updateBySelectMul()
			
		end
	end
	socketHelper:acTianjiangxiongshiChoujiang(method,getRawardCallback)
end



-- 后台返回结果之后马上扣除金币并且给予奖励
function acTianjiangxiongshiDialog:addRewardAndCostMoney(free,num)
	if free then
	else
		local playerGem=playerVoApi:getGems()
		local cost = acTianjiangxiongshiVoApi:getCost(num)
		playerVoApi:setGems(playerGem-cost)
	end
end
-- 根据后台返回的结果{2，3，3}得到个数累加的格式
function acTianjiangxiongshiDialog:resetData(data)
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
function acTianjiangxiongshiDialog:aftetGetReward(getTable)
  -- 遍历得到所有可获得的奖励并整合
  for k,v in pairs(getTable) do
    if v ~= nil and v > 0 then
        -- 根据最终获得奖励的特效处理
        if tonumber(v) == 3 then
          self:playParticles()
          local message={key="activity_tianjiangxiongshi_reward",param={playerVoApi:getPlayerName(),self.reward[1].name,self.reward[1].num}}
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
  G_addPlayerAward(self.reward[1].type,self.reward[1].key,self.reward[1].id,self.reward[1].num,nil,true)
  G_showRewardTip(self.reward,true)
end

function acTianjiangxiongshiDialog:playParticles()
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

function acTianjiangxiongshiDialog:removeParticles()
  for k,v in pairs(self.particleS) do
    v:removeFromParentAndCleanup(true)
  end
  self.particleS = nil
  self.addParticlesTs = nil
end

function acTianjiangxiongshiDialog:doUserHandler()
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

  self.tankTb = acTianjiangxiongshiVoApi:getTankTb()

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
  menuItemDesc:setScale(0.8)
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(w, h))
  self.bgLayer:addChild(menuDesc,2)
 
  h = h - 30
  local acVo = acTianjiangxiongshiVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,28)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp(G_VisibleSizeWidth/2+20, h))
  self.bgLayer:addChild(messageLabel,3)
  self.timeLb=messageLabel
  self:updateAcTime()

	local function nilFunc( )
	end 
	local maybeBorder = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(10, 10, 1, 1),nilFunc);
	maybeBorder:setContentSize(CCSizeMake(580,130))
	maybeBorder:setAnchorPoint(ccp(0.5,1))
	maybeBorder:setOpacity(190)
	maybeBorder:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-180))
	self.bgLayer:addChild(maybeBorder,1)

	local upLb = getlocal("activity_tianjiangxiongshi_des")
	local desTv, desLabel = G_LabelTableView(CCSizeMake(maybeBorder:getContentSize().width*0.8, 110),upLb,25,kCCTextAlignmentLeft)
	maybeBorder:addChild(desTv)
	desTv:setPosition(ccp(maybeBorder:getContentSize().width*0.1,10))
	desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(130)

	local maybeBorder1 = LuaCCScale9Sprite:createWithSpriteFrameName("tianjiangxiongshi_kuang.png",CCRect(67, 35, 1, 1),nilFunc);
	maybeBorder1:setContentSize(CCSizeMake(580,130))
	maybeBorder1:setAnchorPoint(ccp(0.5,1))
	maybeBorder1:setOpacity(190)
	maybeBorder1:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-330))
	self.bgLayer:addChild(maybeBorder1,1)
	self.maybeBorder=maybeBorder1


	-- 动画

	self.upSp=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
	self.upSp:setAnchorPoint(ccp(0.5,0.5))
	self.upSp:setRotation(-90)
	self.upSp:setPosition(self.maybeBorder:getContentSize().width/2, self.maybeBorder:getContentSize().height)
	self.maybeBorder:addChild(self.upSp,5)
	self.upSp:runAction(self:UpAction())

	self.downSp=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
	self.downSp:setAnchorPoint(ccp(1,0.5))
	self.downSp:setRotation(90)
	self.downSp:setPosition(self.maybeBorder:getContentSize().width/2,-20)
	self.maybeBorder:addChild(self.downSp,5)
	self.downSp:runAction(self:DownAction())
	  
	

	-- 锁定勾选坦克
	local function touchSuoItem()
		if G_checkClickEnable()==false then
	        do
	            return
	        end
	    else
	        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
	    end

	    PlayEffect(audioCfg.mouseClick)
	    if acTianjiangxiongshiVoApi:canReward() == true then
	    	-- 加提示文字
	    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("isfree"),30)
	    	return
	    end

	    if self.suoFlag == false then
	    	self.suoFlag = true
	    	self.suoSp:setVisible(true)
	    	if self.blackIcon1 then
	    		self.blackIcon1:setVisible(true)
	    	else
				self.blackIcon1 = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
				self.maybeBorder:addChild(self.blackIcon1,3)
				self.blackIcon1:setPosition(self.maybeBorder:getContentSize().width/2-120, self.maybeBorder:getContentSize().height/2)
				self.blackIcon1:setOpacity(255)
				self.blackIcon1:setScale(1.9)
	    	end

	    	if self.blackIcon2 then
	    		self.blackIcon2:setVisible(true)
	    	else
				self.blackIcon2 = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
				self.maybeBorder:addChild(self.blackIcon2,3)
				self.blackIcon2:setPosition(self.maybeBorder:getContentSize().width/2+120, self.maybeBorder:getContentSize().height/2)
				self.blackIcon2:setOpacity(255)
				self.blackIcon2:setScale(1.9)
	    	end
	    	 
	    	if self.suo1 then
	    		self.suo1:setVisible(true)
	    	else
	    		self.suo1=CCSprite:createWithSpriteFrameName("LockIcon.png")
	    		self.suo1:setPosition(self.maybeBorder:getContentSize().width/2-120, self.maybeBorder:getContentSize().height/2)
	    		self.maybeBorder:addChild(self.suo1,3)
	    	end
	    	if self.suo2 then
	    		self.suo2:setVisible(true)
	    	else
	    		self.suo2=CCSprite:createWithSpriteFrameName("LockIcon.png")
	    		self.suo2:setPosition(self.maybeBorder:getContentSize().width/2+120, self.maybeBorder:getContentSize().height/2)
	    		self.maybeBorder:addChild(self.suo2,3)
	    	end
	    	-- if self.upSp then
	    	-- 	self.upSp:setVisible(true)
	    	-- 	self.upSp:runAction(self:UpAction())
	    	-- else
	    	-- 	self.upSp=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
	    	-- 	self.upSp:setAnchorPoint(ccp(0.5,0.5))
	    	-- 	self.upSp:setRotation(-90)
	    	-- 	self.upSp:setPosition(self.maybeBorder:getContentSize().width/2, self.maybeBorder:getContentSize().height)
	    	-- 	self.maybeBorder:addChild(self.upSp,3)
	    	-- 	self.upSp:runAction(self:UpAction())
	    	-- end

	    	-- if self.downSp then
	    	-- 	self.downSp:setVisible(true)
	    	-- 	self.downSp:runAction(self:DownAction())
	    	-- else
	    	-- 	self.downSp=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
	    	-- 	self.downSp:setAnchorPoint(ccp(1,0.5))
	    	-- 	self.downSp:setRotation(90)
	    	-- 	self.downSp:setPosition(self.maybeBorder:getContentSize().width/2,-20)
	    	-- 	self.maybeBorder:addChild(self.downSp,3)
	    	-- 	self.downSp:runAction(self:DownAction())
	    	-- end


	    else
	    	self.suoFlag = false
	    	self.suoSp:setVisible(false)
	    	if self.blackIcon1 then
	    		self.blackIcon1:setVisible(false)
	    	end
	    	if self.blackIcon2 then
	    		self.blackIcon2:setVisible(false)
	    	end
	    	if self.suo1 then
	    		self.suo1:setVisible(false)
	    	end
	    	if self.suo2 then
	    		self.suo2:setVisible(false)
	    	end
	    	-- if self.upSp then
	    	-- 	self.upSp:setVisible(false)
	    	-- 	self.upSp:stopAllActions()
	    	-- 	self.upSp:setPosition(self.maybeBorder:getContentSize().width/2, self.maybeBorder:getContentSize().height)
	    	-- end
	    	-- if self.downSp then
	    	-- 	self.downSp:setVisible(false)
	    	-- 	self.downSp:stopAllActions()
	    	-- 	self.downSp:setPosition(self.maybeBorder:getContentSize().width/2,-20)
	    	-- end
	    end
	    self:updateBySelectMul()
	end
	local suoItem = GetButtonItem("LegionCheckBtnUn.png","LegionCheckBtnUn.png","LegionCheckBtnUn.png",touchSuoItem,5,nil)
	suoItem:setAnchorPoint(ccp(0,0.5))
	self.suoBtn=CCMenu:createWithItem(suoItem)
	self.suoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.suoBtn:setPosition(30,self.bgLayer:getContentSize().height-500)
	self.bgLayer:addChild(self.suoBtn)

	-- 选中状态
	self.suoSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
	self.suoSp:setAnchorPoint(ccp(0,0.5))
	self.suoSp:setPosition(30,self.bgLayer:getContentSize().height-500)
	self.bgLayer:addChild(self.suoSp)
	self.suoSp:setVisible(false)

	local suoX = 30 + self.suoSp:getContentSize().width + 10
  local suoWidthSize = G_VisibleSizeWidth - suoX-10
  if G_getCurChoseLanguage() =="ar" then
      suoWidthSize =suoX-30
  end
	local suoDesc=GetTTFLabelWrap(getlocal("activity_tianjiangxiongshi_tankdes"),25,CCSizeMake(suoWidthSize,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	suoDesc:setAnchorPoint(ccp(0,0.5))
	suoDesc:setPosition(suoX,self.bgLayer:getContentSize().height-500)
	self.bgLayer:addChild(suoDesc)



  local function cellClick(hd,fn,index)
  end
   
  self.backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("tianjiangxiongshi_kuang.png",CCRect(67,35, 1, 1),cellClick)
  self.backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, G_VisibleSizeHeight-550))
  self.backSprie:setAnchorPoint(ccp(0.5,0))
  self.backSprie:setPosition(ccp(G_VisibleSizeWidth/2, 10))
  self.bgLayer:addChild(self.backSprie,6)
  self.backSprie:setOpacity(0)
  
  -- 10倍模式显示
  local mulX = 100
  local mulY = 40

  local function touchMulItem()
  	if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
    end

    PlayEffect(audioCfg.mouseClick)
    if acTianjiangxiongshiVoApi:canReward() == true then
    	-- 加提示文字
    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("isfree"),30)
    	return
    end

    if self.selectMul == false then
    	self.selectMul = true
    	self.mulSp:setVisible(true)

    else
    	self.selectMul = false
    	self.mulSp:setVisible(false)
    end
    self:updateBySelectMul()
  end

  local bgSp = GetButtonItem("LegionCheckBtnUn.png","LegionCheckBtnUn.png","LegionCheckBtnUn.png",touchMulItem,5,nil)
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
  self.mulSp:setVisible(false)
  
  mulX = mulX + bgSp:getContentSize().width + 10
  local widthSize = G_VisibleSizeWidth - mulX-10
  local PosW = mulX-80
  if G_getCurChoseLanguage() =="ar" then
    widthSize =mulX+10
    PosW =mulX-150
  end
  self.mulDesc=GetTTFLabelWrap(getlocal("activity_tianjiangxiongshi_tencostdes"),25,CCSizeMake(widthSize,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.mulDesc:setAnchorPoint(ccp(0,0.5))
  self.mulDesc:setPosition(PosW,mulY)
  self.backSprie:addChild(self.mulDesc)
  

  	-- 金币和数量
	local costX = 450
	local costY = 35-10
	self.costLabel = GetTTFLabel(tostring(0), 30)
	self.costLabel:setAnchorPoint(ccp(0,0))
	self.costLabel:setPosition(ccp(costX, costY))
	self.costLabel:setColor(G_ColorYellowPro)
	self.backSprie:addChild(self.costLabel)
	

	local gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
	gemIcon:setAnchorPoint(ccp(1,0))
	gemIcon:setPosition(ccp(costX, costY))
	self.backSprie:addChild(gemIcon)
	self.gemIcon=gemIcon
	self:updateBySelectMul()
  
	local barX = self.backSprie:getContentSize().width - 110
	local barY = nil
	-- self.bar=CCSprite:createWithSpriteFrameName("SlotBtn.png")
	-- self.bar:setPosition(ccp(barX,barY))
	-- self.backSprie:addChild(self.bar,2)

	self.bar=GetButtonItem("SlotBtn.png","SlotBtn.png","SlotBtn.png",touch,4,nil,0)
	-- barY = self.backSprie:getContentSize().height - self.bar:getContentSize().height / 2 - 110
	barY = self.backSprie:getContentSize().height/2
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

function acTianjiangxiongshiDialog:resertTankPos()
	local tankId = acTianjiangxiongshiVoApi:getRewardTank()
	local i=1
	local num=SizeOfTable(self.tankTb)
	-- self.tankTable
	-- self.maybeBorder
	for k,v in pairs(self.tankTb) do
		if tostring(v)==tostring(tankId) then
			i=k
			break
		end
	end

	if self.hungK then
		self.hungK:setVisible(true)
	end

	local posX=270
	local posY=self.maybeBorder:getContentSize().height/2
	self.tankTable[i]:setPositionX(posX)
	self.tankTable[i]:setScale(0.7)
	if i>4 then
		for k=i+1,num do
			self.tankTable[k]:setPositionX(posX+(k-i)*120)
			self.tankTable[k]:setScale(0.5)
		end
		for k=1,i-4 do
			self.tankTable[k]:setPositionX(posX+(num-i+k)*120)
			self.tankTable[k]:setScale(0.5)
		end
		for k=i-1,i-3,-1 do
			self.tankTable[k]:setPositionX(posX-(i-k)*120)
			self.tankTable[k]:setScale(0.5)
		end
	elseif i==4 then
		for k=i+1,num do
			self.tankTable[k]:setPositionX(posX+(k-i)*120)
			self.tankTable[k]:setScale(0.5)
		end
		for k=i-1,1,-1 do
			self.tankTable[k]:setPositionX(posX-(i-k)*120)
			self.tankTable[k]:setScale(0.5)
		end
	else
		local chaNum = num-i
		for k=i+1,num+i-4 do
			self.tankTable[k]:setPositionX(posX+(k-i)*120)
			self.tankTable[k]:setScale(0.5)
		end
		for k=i-1,1,-1 do
			self.tankTable[k]:setPositionX(posX-(i-k)*120)
			self.tankTable[k]:setScale(0.5)
		end

		for k=num,num+i-3,-1 do
			self.tankTable[k]:setPositionX(posX-(num-k+i)*120)
			self.tankTable[k]:setScale(0.5)
		end
	end



end

-- 选择或取消收益倍数后相关ui刷新
function acTianjiangxiongshiDialog:updateBySelectMul()
  if self.costLabel ~= nil then
    local cost = 99999
    if acTianjiangxiongshiVoApi:canReward() == true then
      cost = 0
    else
    	local num=self:getChoujiangType()
        cost = acTianjiangxiongshiVoApi:getCost(num)
     
    end  
    if tonumber(cost)==0 then
    	self.costLabel:setString(getlocal("daily_lotto_tip_2"))
    	self.gemIcon:setVisible(false)
    else
    	self.costLabel:setString(tostring(cost))
    	self.gemIcon:setVisible(true)
    end
  end
end

-- 得到抽奖类型 1，普通单价2，普通十倍3，锁定单价4，锁定十倍
function acTianjiangxiongshiDialog:getChoujiangType()
	local num=1
	if self.selectMul == true and self.suoFlag==true then
		num=4
	elseif self.selectMul == false and self.suoFlag==false then
		num=1
	elseif self.selectMul == false and self.suoFlag==true then
		num=3
	else
		num=2
	end
	return num
end

function acTianjiangxiongshiDialog:DownAction()
	local moveBy1 = CCMoveBy:create(0.5, ccp(0,10))
	local moveBy2 = CCMoveBy:create(0.5, ccp(0,-10))
	local seq = CCSequence:createWithTwoActions(moveBy1,moveBy2)
	local forEver = CCRepeatForever:create(seq)
	return forEver
end

function acTianjiangxiongshiDialog:UpAction()
	local moveBy1 = CCMoveBy:create(0.5, ccp(0,-10))
	local moveBy2 = CCMoveBy:create(0.5, ccp(0,10))
	local seq = CCSequence:createWithTwoActions(moveBy1,moveBy2)
	local forEver = CCRepeatForever:create(seq)
	return forEver
end

function acTianjiangxiongshiDialog:openInfo()
  local strSize = 24
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" then
    strSize2 =28
  end
	local td=smallDialog:new()
	local tabStr = {"\n",getlocal("activity_tianjiangxiongshi_tip8"),getlocal("activity_tianjiangxiongshi_tip7"),getlocal("activity_tianjiangxiongshi_tip6"),getlocal("activity_tianjiangxiongshi_tip5"),getlocal("activity_tianjiangxiongshi_tip4"),getlocal("activity_tianjiangxiongshi_tip3"),getlocal("activity_tianjiangxiongshi_tip2"), getlocal("activity_tianjiangxiongshi_tip1"),"\n"}
	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,strSize,nil)
	sceneGame:addChild(dialog,self.layerNum+1)
end

function acTianjiangxiongshiDialog:update()
  local acVo = acTianjiangxiongshiVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    end
  end
end

function acTianjiangxiongshiDialog:dispose()
  self.costLabel = nil

  self.selectMul = nil
  self.suoFlag = nil
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
  self.spTb4Speed=nil
  self.moveDis=nil
  self.isStop1=nil
  self.isStop2=nil
  self.isStop3=nil
  self.isStop4=nil
  self.moveDisNum=nil

  self.desTv = nil -- 面板上的说明信息
  self.metalSpTable = nil
  self.touchDialogBg = nil

  self.currentCanGetReward = nil
  self.lastMul = nil
  self.tankTable=nil
  self.suo1=nil
  self.suo2=nil
  self.maybeBorder=nil
  self.downSp=nil
  self.upSp=nil
  self.timeLb=nil
  self=nil
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acTianjiangxiongshi.plist")
end






