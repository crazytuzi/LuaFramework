acQuanmintankeDialog=commonDialog:new()

function acQuanmintankeDialog:new()
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
    self.limitX=nil
    self.startX=nil
    self.startY1=nil
    self.startY2=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acTianjiangxiongshi.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acQuanmintanke.plist")
    return nc
end

function acQuanmintankeDialog:initTableView()
  
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

  if(G_isIphone5())then
    myBg:setPosition(10,self.backSprie:getContentSize().height/2-30)
    machineBg:setPosition(20,self.backSprie:getContentSize().height/2-30)
  end
  
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
  -- self.maybeBorder:addChild(leftMask,4)
  leftMask:setRotation(-90)

  local rightMask=LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  leftMask:setAnchorPoint(ccp(1,1))
  rightMask:setContentSize(CCSizeMake(self.maybeBorder:getContentSize().height-15,self.maybeBorder:getContentSize().height-10))
  rightMask:setPosition(self.maybeBorder:getContentSize().width-70,self.maybeBorder:getContentSize().height/2)
  rightMask:setRotation(90)
  -- self.maybeBorder:addChild(rightMask,4)

end


function acQuanmintankeDialog:eventHandler(handler,fn,idx,cel)
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
        local startId = acQuanmintankeVoApi:getLastResultByLine(i)
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
            pic = acQuanmintankeVoApi:getPicById(1)
          else
            pic = acQuanmintankeVoApi:getPicById(startId)
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

function acQuanmintankeDialog:eventHandler2(handler,fn,idx,cel)
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
  local startX=100
  local startY1
  local startY2
  if(G_isIphone5())then
    startY1=self.maybeBorder:getContentSize().height/4*3-15
    startY2=self.maybeBorder:getContentSize().height/4+15
  else
     startY1=self.maybeBorder:getContentSize().height/4*3-20
      startY2=self.maybeBorder:getContentSize().height/4+20
  end
	for i=1,tankNum do
		local tankId = tonumber(RemoveFirstChar(self.tankTb[i]))
		local pic = tankCfg[tankId].icon
		-- local sp = CCSprite:createWithSpriteFrameName(pic)
    local function tankInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        local tankID = tonumber(RemoveFirstChar(self.tankTb[i]))
        tankInfoDialog:create(nil,tankID,self.layerNum+1, nil)
    end
    local sp = LuaCCSprite:createWithSpriteFrameName(pic,tankInfo)
    sp:setTouchPriority(-(self.layerNum-1)*20-4)
		cell:addChild(sp)
		sp:setScale(0.5)
    if i<=4 then
      sp:setPosition(startX+(i-1)*120,startY1)
    else
      sp:setPosition(startX+(i-5)*120,startY2)
    end
		self.tankTable[i]=sp
	end

  self.limitX=startX+3*120
  self.startX=startX
  self.startY1=startY1
  self.startY2=startY2

  self.upDengTb={}
  self.downDengTb={}
  for i=1,4 do
    local sp1,sp2
    if i==1 then
      sp1=CCSprite:createWithSpriteFrameName("qmtk_y.png")
      sp2=CCSprite:createWithSpriteFrameName("qmtk_g.png")
    end
    if i==2 then
      sp1=CCSprite:createWithSpriteFrameName("qmtk_r.png")
      sp2=CCSprite:createWithSpriteFrameName("qmtk_b.png")
    end
    if i==3 then
      sp1=CCSprite:createWithSpriteFrameName("qmtk_b.png")
      sp2=CCSprite:createWithSpriteFrameName("qmtk_r.png")
    end
    if i==4 then
      sp1=CCSprite:createWithSpriteFrameName("qmtk_g.png")
      sp2=CCSprite:createWithSpriteFrameName("qmtk_y.png")
    end
    cell:addChild(sp1)
    cell:addChild(sp2)
    if(G_isIphone5())then
      sp1:setPosition(startX+(i-1)*120,startY1+54)
      sp2:setPosition(startX+(i-1)*120,startY2-60)
    else
        sp1:setPosition(startX+(i-1)*120,startY1+54)
        sp2:setPosition(startX+(i-1)*120,startY2-58)
    end

    
    self.upDengTb[i]=sp1
    self.downDengTb[i]=sp2
  end

   self.blackTb={}
   for k,v in pairs(self.tankTable) do
     local posX,posY = v:getPosition()
     local sp = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
     sp:setPosition(posX, posY)
     sp:setScale(1.9)
     sp:setOpacity(255)
     cell:addChild(sp)
      self.blackTb[k]=sp
      sp:setVisible(false)
  end


	local function touchPaihang()
		if G_checkClickEnable()==false then
	        do
	            return
	        end
	    else
	        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
	    end

	 --    PlayEffect(audioCfg.mouseClick)
	 --    local tankID = tonumber(RemoveFirstChar(acQuanmintankeVoApi:getRewardTank()))
		-- tankInfoDialog:create(nil,tankID,self.layerNum+1, nil)
	end
	self.hungK = LuaCCScale9Sprite:createWithSpriteFrameName("qmtk_kuang.png",CCRect(20, 20, 10, 10),touchPaihang)
	self.hungK:setContentSize(CCSizeMake(150*0.54,150*0.54))
	self.hungK:setPosition(ccp(270,self.height/2))
	self.hungK:setTouchPriority(-(self.layerNum-1)*20-1)
	cell:addChild(self.hungK)
	self.hungK:setVisible(false)

  self.hungK1 = LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(20, 20, 10, 10),touchPaihang)
  self.hungK1:setContentSize(CCSizeMake(150*0.57,150*0.57))
  self.hungK1:setPosition(ccp(270,self.height/2))
  self.hungK1:setTouchPriority(-(self.layerNum-1)*20-1)
  cell:addChild(self.hungK1)
  self.hungK1:setVisible(true)

 

	self:resertKuangPos()

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acQuanmintankeDialog:iconFlicker(icon)
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
function acQuanmintankeDialog:resetMetalSps()
  for k,v in pairs(self.metalSpTable) do
    if v ~= nil then
      v:stopAllActions()
      v:removeFromParentAndCleanup(true)
    end
  end
  self.metalSpTable = {}
end

function acQuanmintankeDialog:initSp()
  
end

function acQuanmintankeDialog:moveSp(tb)
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

        if self.moveDis>self.moveDisNum and v.id==tb[i] and v.sp:getPositionY()==self.selectPositionY and self["isStop"..i]== false and self["isStop4"]== true then
           self["spTb"..i.."Speed"]=0
           self["isStop"..i]=true
           self:fuwei(v.id,self["spTb"..i])
        end
    end
  end

  if self.suoFlag==false then
    if self["isStop4"]==false and self.moveDis>150 then
      local i
      for k,v in pairs(self.tankTb) do
        if tostring(v)==tostring(self.tanktype) then
          i=k
          break
        end
      end
      if i and self.tankTb[i] then
        local x,y=self.tankTable[i]:getPosition()
         local x1,y1 = self.hungK:getPosition()
         if tonumber(x)==tonumber(x1) and tonumber(y)==tonumber(y1) then
          self["isStop4"]=true
          self:stopAction()
          self:resertKuangPos()
         end
      end
    end
  else
    self["isStop4"]=true
	end


  if self["isStop1"]==true and self["isStop2"]==true and self["isStop3"]==true and  self["isStop4"]==true then
    self.state = 3
    -- print("动画播放结束： ", self.state)
  end
end

function acQuanmintankeDialog:fuwei(key,tb)
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

function acQuanmintankeDialog:result(tb)
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
  -- self:resertTankPos()
end


function acQuanmintankeDialog:fastTick()
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


function acQuanmintankeDialog:tick()
  self:updateAcTime()  
  self:update()
  if self.particleS ~= nil and base.serverTime - self.addParticlesTs > 10 then
    self:removeParticles()
  end

  if acQuanmintankeVoApi:isToday()==false and self.isToday==true then
  	-- self.isToday=acQuanmintankeVoApi:isToday()
    self.isToday=false
  	self:refresh()
  end
end

function acQuanmintankeDialog:updateAcTime()
    local acVo=acQuanmintankeVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acQuanmintankeDialog:refresh()
	self.suoFlag = false
	
	if self.suoSp then
		self.suoSp:setVisible(false)
	end
	self.selectMul = false
	if self.mulSp then
		self.mulSp:setVisible(false)
	end  
	
	if self.gemIcon then
		self.gemIcon:setVisible(false)
	end  
	
  if  self.hungK then
     self.hungK:setVisible(false)
  end
  if self.hungK1 then
    self.hungK1:setVisible(true)
  end

  
   if self.costLabel then
    self.costLabel:setString(getlocal("daily_lotto_tip_2"))
    self.costLabel:setVisible(false)
  end
  

  if self.vipcostLabel then
    self.vipcostLabel:setString(getlocal("daily_lotto_tip_2"))
  end

  if self.vipgemIcon then
    self.vipgemIcon:setVisible(false)
  end
  self:setMengban()
  
end



function acQuanmintankeDialog:startPalyAnimation()
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
  -- self.hungK:setVisible(false)
  self:resetMetalSps()
  self:startAction()
end

function acQuanmintankeDialog:startAction()
  local function callBack()
    if self.suoFlag==false then
        for i=1,4 do
            local posX1=self.upDengTb[i]:getPositionX()
            local posX2=self.downDengTb[i]:getPositionX()
            if posX1==self.limitX then
              self.upDengTb[i]:setPositionX(self.startX)
            else
              self.upDengTb[i]:setPositionX(posX1+120)
            end

             if posX2==self.limitX then
              self.downDengTb[i]:setPositionX(self.startX)
            else
              self.downDengTb[i]:setPositionX(posX2+120)
            end
        end
       
      end

  end

   local callFunc=CCCallFunc:create(callBack)
   local delay=CCDelayTime:create(0.5)
   local seq=CCSequence:createWithTwoActions(callFunc,delay)

   local function callback2()
      if self.suoFlag==false then
          local x,y = self.hungK:getPosition()
          if x==self.limitX and y==self.startY1 then
             self.hungK:setPosition(self.startX, self.startY2)
             self.hungK1:setPosition(self.startX, self.startY2)
          elseif x==self.limitX and y==self.startY2 then
             self.hungK:setPosition(self.startX, self.startY1)
             self.hungK1:setPosition(self.startX, self.startY1)
          else
            self.hungK:setPositionX(x+120)
            self.hungK1:setPositionX(x+120)
          end
      end
   end
   local callFunc1=CCCallFunc:create(callback2)
   local delay1=CCDelayTime:create(0.7)
   local seq1=CCSequence:createWithTwoActions(callFunc1,delay1)

   self.bgLayer:runAction(CCRepeatForever:create(seq))
   self.bgLayer:runAction(CCRepeatForever:create(seq1))
end

function acQuanmintankeDialog:stopAction()
  self.bgLayer:stopAllActions()
end

function acQuanmintankeDialog:stopPlayAnimation()
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
  self:resertKuangPos()
  self:stopAction()
end

-- 把手播放动画
function acQuanmintankeDialog:barPaly()
  if self ~= nil then
    local barX = self.backSprie:getContentSize().width - 90
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

function acQuanmintankeDialog:stopBarPlay()
  self.leftIcon:setVisible(false)
  self.rightIcon:setVisible(false)
end

-- 抽取奖励
function acQuanmintankeDialog:getReward()
	local method=1
	local free=false
	if acQuanmintankeVoApi:canReward()==true then
		method=1
		free=true
	else
		local num=self:getChoujiangType()
		method=num
		local cost = acQuanmintankeVoApi:getVipCost(num)
		if cost>playerVoApi:getGems() then
			GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost,nil)
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
				acQuanmintankeVoApi:updateLastResult(self.playIds)
			end
			if sData and sData.data and sData.data.reward then
				local reward = FormatItem(sData.data.reward)
				
				self.reward=reward
			end
      if sData and sData.data and sData.data.tanktype then
        self.tanktype=sData.data.tanktype
        acQuanmintankeVoApi:setRewardTank(sData.data.tanktype)
      end
			if free then
				acQuanmintankeVoApi:setLastTime(sData.ts)
        self.isToday=true
			end
			self:addRewardAndCostMoney(free,method)
			self:startPalyAnimation()
			self:updateBySelectMul()
			
		end
	end
	socketHelper:acQuanmintankeChoujiang(method,getRawardCallback)
end



-- 后台返回结果之后马上扣除金币并且给予奖励
function acQuanmintankeDialog:addRewardAndCostMoney(free,num)
	if free then
	else
		local playerGem=playerVoApi:getGems()
		local cost = acQuanmintankeVoApi:getVipCost(num)
		playerVoApi:setGems(playerGem-cost)
	end
end
-- 根据后台返回的结果{2，3，3}得到个数累加的格式
function acQuanmintankeDialog:resetData(data)
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
function acQuanmintankeDialog:aftetGetReward(getTable)
  -- 遍历得到所有可获得的奖励并整合
  for k,v in pairs(getTable) do
    if v ~= nil and v > 0 then
        -- 根据最终获得奖励的特效处理
        if tonumber(v) == 3 then
          self:playParticles()
          local message={key="activity_tianjiangxiongshi_reward",param={playerVoApi:getPlayerName(),self.reward[1].name,self.reward[1].num}}
          chatVoApi:sendSystemMessage(message)
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

function acQuanmintankeDialog:playParticles()
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

function acQuanmintankeDialog:removeParticles()
  for k,v in pairs(self.particleS) do
    v:removeFromParentAndCleanup(true)
  end
  self.particleS = nil
  self.addParticlesTs = nil
end

function acQuanmintankeDialog:doUserHandler()
  local function onRechargeChange(event,data)
    self:updateBySelectMul()
  end
  self.qmtkListener=onRechargeChange
  eventDispatcher:addEventListener("acQuanmintanke.recharge",onRechargeChange)
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

  self.tankTb = acQuanmintankeVoApi:getTankTb()

  local w = nil
  local h = G_VisibleSizeHeight - 105

  local acLabel = GetTTFLabel(getlocal("activity_timeLabel") .. ": ",25)
  acLabel:setAnchorPoint(ccp(0.5,1))
  acLabel:setColor(G_ColorGreen)
  acLabel:setColor(G_ColorYellowPro)
  self.bgLayer:addChild(acLabel,1)

  local acVo = acQuanmintankeVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,25)
  messageLabel:setAnchorPoint(ccp(0,0.5))
  messageLabel:setPosition(ccp(acLabel:getContentSize().width, acLabel:getContentSize().height/2))
  acLabel:addChild(messageLabel,3)
  self.timeLb=messageLabel
  self:updateAcTime()

  acLabel:setPosition(ccp(G_VisibleSizeWidth/2-messageLabel:getContentSize().width/2, h))

  if(G_isIphone5())then
    acLabel:setPosition(ccp(G_VisibleSizeWidth/2-messageLabel:getContentSize().width/2, h-15))
  end
 
  h = h - 30
  
	local function nilFunc( )
	end 
	local maybeBorder = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(10, 10, 1, 1),nilFunc);
	maybeBorder:setContentSize(CCSizeMake(600,100))
	maybeBorder:setAnchorPoint(ccp(0.5,1))
	maybeBorder:setOpacity(190)
	maybeBorder:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-140))
	self.bgLayer:addChild(maybeBorder,1)

  if(G_isIphone5())then
    maybeBorder:setContentSize(CCSizeMake(600,130))
    maybeBorder:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-160))
  end
  local needWidth = 0
  if G_getCurChoseLanguage() =="ar" then
    needWidth =20
  end

	local upLb = getlocal("activity_quanmintanke_des")
	local desTv, desLabel
  if(G_isIphone5())then
    desTv, desLabel= G_LabelTableView(CCSizeMake(maybeBorder:getContentSize().width*0.8+needWidth, 100),upLb,25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(20,10))
  else
    desTv, desLabel= G_LabelTableView(CCSizeMake(maybeBorder:getContentSize().width*0.8+needWidth, 80),upLb,25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(20,10))
    
  end
   
	maybeBorder:addChild(desTv)
	desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(130)

  local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch,1,nil,0)
  menuItemDesc:setAnchorPoint(ccp(1,0.5))
  menuItemDesc:setScale(0.8)
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  menuDesc:setPosition(ccp(maybeBorder:getContentSize().width-15, maybeBorder:getContentSize().height/2))
  maybeBorder:addChild(menuDesc,2)

	local maybeBorder1 = LuaCCScale9Sprite:createWithSpriteFrameName("tianjiangxiongshi_kuang.png",CCRect(67, 35, 1, 1),nilFunc);
	maybeBorder1:setContentSize(CCSizeMake(600,250))
	maybeBorder1:setAnchorPoint(ccp(0.5,1))
	maybeBorder1:setOpacity(190)
	maybeBorder1:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-245))
	self.bgLayer:addChild(maybeBorder1,1)
	self.maybeBorder=maybeBorder1

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
	    if acQuanmintankeVoApi:canReward() == true then
	    	-- 加提示文字
	    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("isfree"),30)
	    	return
	    end

	    if self.suoFlag == false then
	    	self.suoFlag = true
	    	self.suoSp:setVisible(true)
        self.hungK:setVisible(true)
        self.hungK1:setVisible(false)
        self:setMengban()
	    else
	    	self.suoFlag = false
	    	self.suoSp:setVisible(false)
        self.hungK:setVisible(false)
        self.hungK1:setVisible(true)
        self:setMengban()
	    end
	    self:updateBySelectMul()
	end
  local adaH = 0
  if G_getIphoneType() == G_iphoneX then
    adaH = 50
  end
	local suoItem = GetButtonItem("LegionCheckBtnUn.png","LegionCheckBtnUn.png","LegionCheckBtnUn.png",touchSuoItem,5,nil)
	suoItem:setAnchorPoint(ccp(0,0.5))
	self.suoBtn=CCMenu:createWithItem(suoItem)
	self.suoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.suoBtn:setPosition(30,self.bgLayer:getContentSize().height-523-adaH)
	self.bgLayer:addChild(self.suoBtn)

	-- 选中状态
	self.suoSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
	self.suoSp:setAnchorPoint(ccp(0,0.5))
	self.suoSp:setPosition(30,self.bgLayer:getContentSize().height-523-adaH)
	self.bgLayer:addChild(self.suoSp)
	self.suoSp:setVisible(false)

	local suoX = 30 + self.suoSp:getContentSize().width + 10
  local desWidthPos = 0
  if G_getCurChoseLanguage()=="ar" then
      desWidthPos=350
  end
	local suoDesc=GetTTFLabelWrap(getlocal("activity_tianjiangxiongshi_tankdes"),25,CCSizeMake(G_VisibleSizeWidth - suoX-10-desWidthPos,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	suoDesc:setAnchorPoint(ccp(0,0.5))
	suoDesc:setPosition(suoX,self.bgLayer:getContentSize().height-523-adaH)
	self.bgLayer:addChild(suoDesc)
  local  adaH = 0
  if G_getIphoneType() == G_iphoneX then
    adaH = 50
    maybeBorder1:setContentSize(CCSizeMake(600,330))
    maybeBorder1:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-310))
    self.suoBtn:setPosition(30,self.bgLayer:getContentSize().height-685)
    self.suoSp:setPosition(30,self.bgLayer:getContentSize().height-685)
    suoDesc:setPosition(suoX,self.bgLayer:getContentSize().height-685)
  elseif (G_isIphone5()) then
    maybeBorder1:setContentSize(CCSizeMake(600,280))
    maybeBorder1:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-310))
    self.suoBtn:setPosition(30,self.bgLayer:getContentSize().height-635)
    self.suoSp:setPosition(30,self.bgLayer:getContentSize().height-635)
    suoDesc:setPosition(suoX,self.bgLayer:getContentSize().height-635)
  end



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
    if acQuanmintankeVoApi:canReward() == true then
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
  self.selectBtn:setPosition(mulX-80,mulY+adaH)
  self.backSprie:addChild(self.selectBtn)


  -- 选中状态
  self.mulSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
  self.mulSp:setAnchorPoint(ccp(0,0.5))
  self.mulSp:setPosition(mulX-80,mulY+adaH)
  self.backSprie:addChild(self.mulSp)
  self.mulSp:setVisible(false)
  
  mulX = mulX + bgSp:getContentSize().width + 10
  self.mulDesc=GetTTFLabelWrap(getlocal("activity_tianjiangxiongshi_tencostdes"),25,CCSizeMake(G_VisibleSizeWidth - mulX-10-desWidthPos,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.mulDesc:setAnchorPoint(ccp(0,0.5))
  self.mulDesc:setPosition(mulX-80,mulY+adaH)
  self.backSprie:addChild(self.mulDesc)
  

  	-- 金币和数量
	local costX = 450
	local costY = 35-15
	self.costLabel = GetTTFLabel(tostring(0), 25)
	self.costLabel:setAnchorPoint(ccp(0,0))
	self.costLabel:setPosition(ccp(costX, costY+adaH))
	self.costLabel:setColor(G_ColorYellowPro)
	self.backSprie:addChild(self.costLabel)
	

	local gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
	gemIcon:setAnchorPoint(ccp(1,0))
	gemIcon:setPosition(ccp(costX, costY+adaH))
	self.backSprie:addChild(gemIcon)
	self.gemIcon=gemIcon

  costX=545
  strPosWidth =costX
  if G_getCurChoseLanguage() =="ru" then
    strPosWidth =strPosWidth-30
  end
  self.vipcostLabel = GetTTFLabel(tostring(0), 25)
  self.vipcostLabel:setAnchorPoint(ccp(0,0))
  self.vipcostLabel:setPosition(ccp(strPosWidth, costY+adaH))
  self.vipcostLabel:setColor(G_ColorYellowPro)
  self.backSprie:addChild(self.vipcostLabel)
  

  local vipgemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
  vipgemIcon:setAnchorPoint(ccp(1,0))
  vipgemIcon:setPosition(ccp(strPosWidth, costY+adaH))
  self.backSprie:addChild(vipgemIcon)
  self.vipgemIcon=vipgemIcon

  local line = CCSprite:createWithSpriteFrameName("redline.jpg")
  -- line:setAnchorPoint(ccp(0,0))
  line:setScaleX((self.costLabel:getContentSize().width+20)/line:getContentSize().width)
  line:setPosition(ccp(self.costLabel:getContentSize().width/2+10,self.costLabel:getContentSize().height/2))
  self.costLabel:addChild(line)
  self.line=line

  if acQuanmintankeVoApi:getVipdiscoun()~=0 then
    self.costLabel:setColor(G_ColorRed)
  end

	self:updateBySelectMul()

	local barX = self.backSprie:getContentSize().width - 90
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

function acQuanmintankeDialog:resertKuangPos()
	local tankId = acQuanmintankeVoApi:getRewardTank()
	local i=1
	local num=SizeOfTable(self.tankTb)
	for k,v in pairs(self.tankTb) do
		if tostring(v)==tostring(tankId) then
			i=k
			break
		end
	end

	local x,y=self.tankTable[i]:getPosition()
  self.hungK:setPosition(ccp(x,y))
  self.hungK1:setPosition(ccp(x,y))

end

-- 选择或取消收益倍数后相关ui刷新
function acQuanmintankeDialog:updateBySelectMul()
  if self.costLabel ~= nil and self.vipcostLabel then
    local cost = 99999
    local num=self:getChoujiangType()
    if acQuanmintankeVoApi:canReward() == true then
      cost = 0
    else
        cost = acQuanmintankeVoApi:getCost(num)
    end  
    if tonumber(cost)==0 then
    	self.costLabel:setString(getlocal("daily_lotto_tip_2"))
    	self.gemIcon:setVisible(false)
      self.costLabel:setVisible(false)

      self.vipcostLabel:setString(getlocal("daily_lotto_tip_2"))
      self.vipgemIcon:setVisible(false)
    else
    	self.costLabel:setString(tostring(cost))
      self.costLabel:setVisible(true)
    	self.gemIcon:setVisible(true)
      self.line:setScaleX((self.costLabel:getContentSize().width+20)/self.line:getContentSize().width)

      self.vipcostLabel:setString(acQuanmintankeVoApi:getVipCost(num))
      self.vipgemIcon:setVisible(true)
    end

    local vipLevel = playerVoApi:getVipLevel()
    if vipLevel<1 then
      self.gemIcon:setVisible(false)
      self.costLabel:setVisible(false)
    end

    if acQuanmintankeVoApi:getVipdiscoun()==0 then
      self.costLabel:setVisible(false)
      self.gemIcon:setVisible(false)
      self.line:setVisible(false)
    end
  end

end

-- 得到抽奖类型 1，普通单价2，普通十倍3，锁定单价4，锁定十倍
function acQuanmintankeDialog:getChoujiangType()
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

function acQuanmintankeDialog:openInfo()
  local strSize2 = 24
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" then
    strSize2 =28
  end
	local td=smallDialog:new()
	local tabStr = {getlocal("activity_quanmintanke_tip8"),getlocal("activity_quanmintanke_tip7"),getlocal("activity_quanmintanke_tip6"),getlocal("activity_quanmintanke_tip5"),getlocal("activity_tianjiangxiongshi_tip4"),getlocal("activity_quanmintanke_tip3"),getlocal("activity_tianjiangxiongshi_tip2"), getlocal("activity_tianjiangxiongshi_tip1"),"\n"}
  local disCount = acQuanmintankeVoApi:getVipdiscoun()
  if disCount>=2 then
    table.insert(tabStr,1,getlocal("activity_quanmintanke_tip9",{"*" .. disCount}))
  elseif disCount==1 then
     table.insert(tabStr,1,getlocal("activity_quanmintanke_tip9",{""}))
  end
  table.insert(tabStr,1,"\n")
	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,strSize2,nil)
	sceneGame:addChild(dialog,self.layerNum+1)
end

function acQuanmintankeDialog:update()
  local acVo = acQuanmintankeVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    end
  end
end

function acQuanmintankeDialog:setMengban()
  local tankId = acQuanmintankeVoApi:getRewardTank()
  local i=1
  local num=SizeOfTable(self.tankTb)
  for k,v in pairs(self.tankTb) do
    if tostring(v)==tostring(tankId) then
      i=k
      break
    end
  end

  if self.suoFlag then
    for k,v in pairs(self.blackTb) do
      if k==i then
        v:setVisible(false)
      else
        v:setVisible(true)
      end
    end
  else
    for k,v in pairs(self.blackTb) do
      v:setVisible(false)
    end
    
  end
  
end


function acQuanmintankeDialog:dispose()
  eventDispatcher:removeEventListener("acQuanmintanke.recharge",self.qmtkListener)
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
  self.maybeBorder=nil
  self.limitX=nil
  self.startX=nil
  self.startY1=nil
  self.startY2=nil
  self.line=nil
  self.blackTb=nil
  self.timeLb=nil
  self=nil
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acTianjiangxiongshi.plist")
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acQuanmintanke.plist")
end






