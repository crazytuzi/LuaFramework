acTankjianianhuaDialog=commonDialog:new()

function acTankjianianhuaDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.costLabel = nil

    self.selectOnlyMul = false -- 是否勾选单排模式
    self.mulOnlySp = nil -- 单排模式图标
    self.mulOnlyDesc = nil -- 单排模式说明文字
    self.selectOnlyBtn = nil -- 单排模式收益按钮

    self.selectAllMul = false -- 是否勾选火力全开
    self.mulAllSp = nil -- 火力全开图标
    self.mulAllDesc = nil -- 火力全开说明文字
    self.selectAllBtn = nil --火力全开按钮

    self.bar = nil -- 右侧把手
    self.backSprie = nil -- 下方的背景
    self.lastSt = nil -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
    self.lastIndex = nil -- 上一次把手上的黄色箭头在第几个位置
    
    self.turnSingleAreaH = 120 -- 转动区域每个图标占的高度
    self.turnNum = 5 -- 转动区域个数

    self.particleS = nil -- 粒子效果
    self.addParticlesTs = nil -- 添加粒子效果的时间

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

    self.showIcon={}
    self.showLines={}
    self.lineList ={}

    self.clickStop = false

    self.iconSpList={}
    self.numspList={}

    return nc
end

function acTankjianianhuaDialog:initTableView()
  self.isToday = acTankjianianhuaVoApi:isToday()
  
  local function touchDialog()
      if self.state == 2 then
        self.clickStop = true
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

  --iphoneX适配
  local  adaH = 0
  if G_getIphoneType() == G_iphoneX then
    adaH = 1250 - 1136
  end
  local headBs=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
	headBs:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,150+adaH/2))
	headBs:setAnchorPoint(ccp(0.5,1))
	headBs:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height - 95))
	self.bgLayer:addChild(headBs,4)

	local actTime=GetTTFLabel(getlocal("activity_timeLabel"),25)
	actTime:setPosition(ccp(headBs:getContentSize().width/2,headBs:getContentSize().height-20-adaH/4))
	headBs:addChild(actTime,5)
	actTime:setColor(G_ColorGreen)

	local acVo = acTankjianianhuaVoApi:getAcVo()
	if acVo then
		local timeStr = activityVoApi:getActivityTimeStr(acVo.st,acVo.et)
		local timeLabel = GetTTFLabel(timeStr,25)
		timeLabel:setPosition(ccp(headBs:getContentSize().width/2,headBs:getContentSize().height-20-actTime:getContentSize().height-adaH/4))
		headBs:addChild(timeLabel,5)
    self.timeLb=timeLabel
    self:updateAcTime()
	end

	local desctv = G_LabelTableView(CCSize(headBs:getContentSize().width-130,80),getlocal("activity_tankjianianhua_content"),25,kCCTextAlignmentLeft)
	desctv:setPosition(ccp(10,10))
	desctv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	desctv:setAnchorPoint(ccp(0,0))
	headBs:addChild(desctv,2)
	desctv:setMaxDisToBottomOrTop(50)

	local function explainTouch( ... )
		acTankjianianhuaExplain:create(self.layerNum+1)
	end
  local tableX = headBs:getContentSize().width - 80
--说明图标
  local tableItem=GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",explainTouch,3,nil,0)
  tableItem:setAnchorPoint(ccp(0.5,0))
  local tableBtn=CCMenu:createWithItem(tableItem)
  tableBtn:setTouchPriority(-(self.layerNum-1)*20-5)
  tableBtn:setPosition(ccp(tableX, headBs:getContentSize().height/2-10))
  headBs:addChild(tableBtn)
--说明TTF
  local smSize = 25
  if G_getCurChoseLanguage() =="ru" then
    smSize =22
  end
  local tableLb = GetTTFLabelWrap(getlocal("shuoming"), smSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  tableLb:setAnchorPoint(ccp(0.5,1))
  tableLb:setColor(G_ColorYellowPro)
  tableLb:setPosition(ccp(tableX, headBs:getContentSize().height/2-10))
  headBs:addChild(tableLb)

  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 105))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
  
  local bgW = self.bgLayer:getContentSize().width-40
  self.machineBg=LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),function () do return end end)
  self.machineBg:setContentSize(CCSizeMake(bgW,self.bgLayer:getContentSize().height-450-adaH))
  self.machineBg:setAnchorPoint(ccp(0,0))
  self.machineBg:setPosition(20,200+adaH/2)
  self.bgLayer:addChild(self.machineBg,7)

  --local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  local tvBg = CCSprite:createWithSpriteFrameName("SlotMask.png")
  tvBg:setScaleX(440/tvBg:getContentSize().width)
  tvBg:setScaleY(380/tvBg:getContentSize().height)
  tvBg:setAnchorPoint(ccp(0.5,0.5))
  tvBg:setPosition(self.machineBg:getContentSize().width/2,self.machineBg:getContentSize().height/2-20)
  --tvBg:setContentSize(CCSizeMake(400,380))
  self.machineBg:addChild(tvBg)

  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.machineBg:getContentSize().width-100,self.machineBg:getContentSize().height-100),nil)
  self.machineBg:addChild(self.tv,1)
  self.tv:setAnchorPoint(ccp(0,0))
  self.tv:setPosition(ccp(50,50))
  self.tv:setMaxDisToBottomOrTop(0)
  --self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)

  -- local recordPoint = self.tv:getRecordPoint()
  -- recordPoint.y = -self.turnSingleAreaH
  -- self.tv:recoverToRecordPoint(recordPoint)
  
  local maskH = 150
  if G_isIphone5() == false then
    maskH = 70
  end
  self.topMask=LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  self.topMask:setContentSize(CCSizeMake(bgW,maskH))
  self.topMask:setAnchorPoint(ccp(0.5,1))
  self.topMask:setPosition(bgW/2, self.machineBg:getContentSize().height-20)
  self.machineBg:addChild(self.topMask,11)

  self.bottomMask=LuaCCScale9Sprite:createWithSpriteFrameName("SlotMask.png",CCRect(20, 20, 10, 10),function () do return end end)
  self.bottomMask:setContentSize(CCSizeMake(bgW,maskH))
  self.bottomMask:setAnchorPoint(ccp(0.5,1))
  self.bottomMask:setPosition(bgW/2,20)
  self.bottomMask:setRotation(180)
  self.machineBg:addChild(self.bottomMask,11)

  


  local maskPosY = 200
  if G_isIphone5() == false then
    maskPosY=140
  end

  self.mask1 = CCSprite:createWithSpriteFrameName("jianianhuaMask.png")
  -- self.mask1:setContentSize(CCSizeMake(440,120))
  self.mask1:setScaleX(440/self.mask1:getContentSize().width)
  self.mask1:setScaleY((self.mask1:getContentSize().height+50)/self.mask1:getContentSize().height)
  self.mask1:setAnchorPoint(ccp(0.5,0.5))
  self.mask1:setPosition(self.machineBg:getContentSize().width/2,self.machineBg:getContentSize().height-maskPosY)
  self.machineBg:addChild(self.mask1,10)

  self.mask2 = CCSprite:createWithSpriteFrameName("jianianhuaMask.png")
  -- self.mask2:setContentSize(CCSizeMake(440,120))
  self.mask2:setScaleX(440/self.mask2:getContentSize().width)
  self.mask2:setScaleY((self.mask2:getContentSize().height+50)/self.mask2:getContentSize().height)
  self.mask2:setRotation(180)
  self.mask2:setAnchorPoint(ccp(0.5,0.5))
  self.mask2:setPosition(self.machineBg:getContentSize().width/2,maskPosY)
  self.machineBg:addChild(self.mask2,10)



  local lineCross1 = CCSprite:createWithSpriteFrameName("jianianhua_line.png")
  lineCross1:setColor(ccc3(14, 30, 24))
  lineCross1:setScaleX(360/lineCross1:getContentSize().width)
  lineCross1:setScaleY(1.2)
  lineCross1:setAnchorPoint(ccp(0.5,0.5))
  lineCross1:setPosition(self.machineBg:getContentSize().width/2-75,self.machineBg:getContentSize().height/2)
  lineCross1:setRotation(90)
  self.machineBg:addChild(lineCross1,2)

  local lineCross2 = CCSprite:createWithSpriteFrameName("jianianhua_line.png")
  lineCross2:setColor(ccc3(14, 30, 24))
  lineCross2:setScaleY(1.2)
  lineCross2:setScaleX(360/lineCross2:getContentSize().width)
  lineCross2:setAnchorPoint(ccp(0.5,0.5))
  lineCross2:setPosition(self.machineBg:getContentSize().width/2+75,self.machineBg:getContentSize().height/2)
  lineCross2:setRotation(90)
  self.machineBg:addChild(lineCross2,2)


  local leftX = 50
  local rightX = self.machineBg:getContentSize().width-55
  local topY = self.machineBg:getContentSize().height-140
  local buttomY = 150

  if G_isIphone5() == false then
     topY = self.machineBg:getContentSize().height-60
     buttomY = 70
  end
 

  for i=1,8 do
    local lineSP =CCSprite:createWithSpriteFrameName("jianianhua_line.png");
    lineSP:setColor(G_ColorYellowPro)
    lineSP:setAnchorPoint(ccp(0.5,0.5))
    
    lineSP:setScaleY(1.2)
    self.machineBg:addChild(lineSP,12)
    if i == 1 then
      lineSP:setScaleX((self.machineBg:getContentSize().width-100)/lineSP:getContentSize().width)
      lineSP:setPosition(ccp(self.machineBg:getContentSize().width/2,self.machineBg:getContentSize().height/2))
    elseif i== 2 then
      lineSP:setScaleX((self.machineBg:getContentSize().width-100)/lineSP:getContentSize().width)
      lineSP:setPosition(ccp(self.machineBg:getContentSize().width/2,self.machineBg:getContentSize().height/2+120))
    elseif i== 3 then
      lineSP:setScaleX((self.machineBg:getContentSize().width-100)/lineSP:getContentSize().width)
      lineSP:setPosition(ccp(self.machineBg:getContentSize().width/2,self.machineBg:getContentSize().height/2-120))
    elseif i== 4 then
      lineSP:setRotation(90)
      lineSP:setScaleX((self.machineBg:getContentSize().width-180)/lineSP:getContentSize().width)
      lineSP:setPosition(ccp(self.machineBg:getContentSize().width/2,self.machineBg:getContentSize().height/2))
    elseif i== 5 then
      lineSP:setRotation(90)
      lineSP:setScaleX((self.machineBg:getContentSize().width-180)/lineSP:getContentSize().width)
      lineSP:setPosition(ccp(self.machineBg:getContentSize().width/2-150,self.machineBg:getContentSize().height/2))
    elseif i== 6 then
      lineSP:setRotation(90)
      lineSP:setScaleX((self.machineBg:getContentSize().width-180)/lineSP:getContentSize().width)
      lineSP:setPosition(ccp(self.machineBg:getContentSize().width/2+150,self.machineBg:getContentSize().height/2))
    elseif i== 7 then
      lineSP:setRotation(39)
      lineSP:setScaleX((self.machineBg:getContentSize().width+40)/lineSP:getContentSize().width)
      lineSP:setPosition(ccp(self.machineBg:getContentSize().width/2,self.machineBg:getContentSize().height/2))
    elseif i== 8 then
      lineSP:setRotation(141)
      lineSP:setScaleX((self.machineBg:getContentSize().width+40)/lineSP:getContentSize().width)
      lineSP:setPosition(ccp(self.machineBg:getContentSize().width/2,self.machineBg:getContentSize().height/2))
    end
     lineSP:setVisible(false)
    
    self.lineList[i]=lineSP
  end
  for i=1,16 do
    -- local capInSet1 = CCRect(17, 17, 1, 1)
    local function touchClick()
    end
    -- local numSP =LuaCCScale9Sprite:createWithSpriteFrameName("jianianhua_circle.png",capInSet1,touchClick)
    -- numSP:ignoreAnchorPointForPosition(false)
    -- numSP:setAnchorPoint(CCPointMake(0.5,0.5))
    -- self.machineBg:addChild(numSP,12)

    local numitem=GetButtonItem("jianianhua_circle.png","jianianhua_circle.png","jianianhua_circle.png",touchClick,2,"",25,10101)

   -- local numitem = GetButtonItem("jianianhua_circle.png","jianianhua_circle.png","jianianhua_circle.png",nil,5,"",25,10101)
    self.numspList[i]=numitem
    local numSP = CCMenu:createWithItem(numitem)
    numSP:setAnchorPoint(CCPointMake(0.5,0.5))
    self.machineBg:addChild(numSP,12)
    local numStr
    
    if i == 1 then
      numStr=tostring(i)
      numSP:setPosition(leftX,self.machineBg:getContentSize().height/2)
    elseif i==2 then
      numStr=tostring(i)
      numSP:setPosition(leftX,self.machineBg:getContentSize().height/2+120)
    elseif i==3 then
      numStr=tostring(i)
      numSP:setPosition(leftX,self.machineBg:getContentSize().height/2-120)
    elseif i==4 then
      numStr=tostring(i)
      numSP:setPosition(self.machineBg:getContentSize().width/2,topY)
    elseif i==5 then
      numStr=tostring(i)
      numSP:setPosition(self.machineBg:getContentSize().width/2-150,topY)
    elseif i==6 then
      numStr=tostring(i)
      numSP:setPosition(self.machineBg:getContentSize().width/2+150,topY)
    elseif i==7 then
      numStr=tostring(i)
      numSP:setPosition(leftX,topY)
    elseif i==8 then
      numStr=tostring(i)
      numSP:setPosition(leftX,buttomY)
    elseif i==9 then
      numStr=tostring(i-8)
      numSP:setPosition(rightX,self.machineBg:getContentSize().height/2)
    elseif i==10 then
      numStr=tostring(i-8)
      numSP:setPosition(rightX,self.machineBg:getContentSize().height/2+120)
    elseif i==11 then
      numStr=tostring(i-8)
      numSP:setPosition(rightX,self.machineBg:getContentSize().height/2-120)
    elseif i==12 then
      numStr=tostring(i-8)
      numSP:setPosition(self.machineBg:getContentSize().width/2,buttomY)
    elseif i==13 then
      numStr=tostring(i-8)
      numSP:setPosition(self.machineBg:getContentSize().width/2-150,buttomY)
    elseif i==14 then
      numStr=tostring(i-8)
      numSP:setPosition(self.machineBg:getContentSize().width/2+150,buttomY)
    elseif i==15 then
      numStr=tostring(i-8)
      numSP:setPosition(rightX,buttomY)
    elseif i==16 then
      numStr=tostring(i-8)
      numSP:setPosition(rightX,topY)
    end

    if numSP then
      local numLb = tolua.cast(numitem:getChildByTag(10101),"CCLabelTTF")--GetTTFLabel(numStr,25)
      -- numLb:setAnchorPoint(ccp(0.5,0.5))
      -- numLb:setPosition(numSP:getContentSize().width/2,numSP:getContentSize().height/2)
      -- numSP:addChild(numLb,10)
      numLb:setString(numStr)
      numLb:setColor(G_ColorBlack)
    end

  end


    self:updateMask()
end


function acTankjianianhuaDialog:updateMask()
  -- local maskH
  -- if self.selectAllMul == true then
  --   maskH = 150
  --   if G_isIphone5() == false then
  --     maskH = 70
  --   end
  -- elseif self.selectOnlyMul == true then
  --   maskH = 230
  --   if G_isIphone5() == false then
  --     maskH = 150
  --   end
  -- end
  -- self.topMask:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,maskH))
  -- self.bottomMask:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,maskH))
  if self.numspList then
    for k,v in pairs(self.numspList) do
      if self.selectOnlyMul ==true then
        if k == 1 or k==9 then
          v:setEnabled(true)
        else
          v:setEnabled(false)
        end
      elseif self.selectAllMul == true then
         v:setEnabled(true)
      end
    end
  end

  if self.selectAllMul == true then
    self.mask1:setVisible(false)
    self.mask2:setVisible(false)
  elseif self.selectOnlyMul == true then
    self.mask1:setVisible(true)
    self.mask2:setVisible(true)
  end
end

function acTankjianianhuaDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(self.machineBg:getContentSize().width-100,self.machineBg:getContentSize().height-100)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local pic = nil
    local picX = nil

    local totalH = self.machineBg:getContentSize().height-100
    if G_isIphone5() == false then
      totalH = self.machineBg:getContentSize().height-100+80
    end
    local picY = totalH - self.turnSingleAreaH * 3 + 20
    -- if self.selectBg == nil then
    --   self.selectBg=LuaCCScale9Sprite:createWithSpriteFrameName("SlotSelect.png",CCRect(10, 10, 1, 1),function () do return end end)
    --   self.selectBg:setContentSize(CCSizeMake(self.machineBg:getContentSize().width-170,self.turnSingleAreaH))
    --   self.selectBg:setAnchorPoint(ccp(0.5,0))
    --   self.selectBg:setPosition((self.machineBg:getContentSize().width-115)/2,picY)
    --   cell:addChild(self.selectBg)
    -- end
    local iconList = acTankjianianhuaVoApi:getAllShowIconID()
    for i=1,3 do
        local startId = 1
        for i2=1,2 do
          if startId == 1 then
            startId = 5
          else
            startId = startId - 1
          end
        end

        for id=1,self.turnNum do
          picY = totalH - self.turnSingleAreaH * id + 22
          local iconSp = CCSprite:createWithSpriteFrameName("alpha.png")
          local icon
          local iconId

          picX = 45 + (i-1) * 150
          iconSp:setAnchorPoint(ccp(0,0))
          iconSp:setPosition(ccp(picX, picY))
          cell:addChild(iconSp,3)

          if i == 1 then
             if id == 2 then
              iconId = 1
             elseif id== 3 then
              iconId = 4 
             elseif id== 4 then
              iconId = 7
             end
          elseif i == 2 then
             if id == 2 then
              iconId = 2
             elseif id== 3 then
              iconId = 5 
             elseif id== 4 then
              iconId = 8
             end
          elseif i == 3 then
             if id == 2 then
              iconId = 3
             elseif id== 3 then
              iconId = 6 
             elseif id== 4 then
              iconId = 9
             end
          end
          if iconId == nil then
            iconId= math.random(1,SizeOfTable(iconList))
          else
            local lightSP = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
            lightSP:setAnchorPoint(ccp(0.5,0.5))
            lightSP:setPosition(picX+60, picY+50)
            cell:addChild(lightSP,2)
            lightSP:setVisible(false)
            self.iconSpList[iconId]=lightSP
          end
          --iconSp:setScale(100/iconSp:getContentSize().width)
          if iconList[iconId] then
            icon = acTankjianianhuaVoApi:getShowIconById(iconList[iconId])
            icon:setPosition(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2)
            iconSp:addChild(icon)
            icon:setTag(1010)
          end

          
          if id==3 then
            self.selectPositionY=iconSp:getPositionY()
          end
          self["spTb"..i][startId]={}
          self["spTb"..i][startId].id=startId
          self["spTb"..i][startId].sp=iconSp

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

function acTankjianianhuaDialog:clearLightSp()
  if self.iconSpList then
    for k,v in pairs(self.iconSpList) do
      if v then
        v:setVisible(false)
      end
    end
  end
end

function acTankjianianhuaDialog:showLightSp()
  if self.showLines then
    local checkLine = {{4,5,6},{1,2,3},{7,8,9},{2,5,8},{1,4,7},{3,6,9},{1,5,9},{3,5,7}}
    local showlight = {}
    for k,v in pairs(self.showLines) do
      if v then
        table.insert(showlight,checkLine[v])
      end
    end

    if showlight and SizeOfTable(showlight)>0 then
      for k,v in pairs(showlight) do
        if v and type(v)=="table" then
          for m,n in pairs(v) do
            if n then
              if self.iconSpList[n] then
                self.iconSpList[n]:setVisible(true)
              end
            end
          end
        end
      end
    end
  end
end

-- 删除所有的边框效果
function acTankjianianhuaDialog:resetMetalSps()
  for k,v in pairs(self.metalSpTable) do
    if v ~= nil then
      v:stopAllActions()
      v:removeFromParentAndCleanup(true)
    end
  end
  self.metalSpTable = {}
end


function acTankjianianhuaDialog:moveSp()
  self.moveDis=self.moveDis+1
  for i=1,3 do
    if self.moveDis>self.moveDisNum and self["isStop"..i]==false then
      --if self.moveDis%10==0 then
            self["spTb"..i.."Speed"]=self["spTb"..i.."Speed"]-1        
        if self["spTb"..i.."Speed"]<=1 then
            self["spTb"..i.."Speed"]=1
        end
      -- end
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
           

          if self.selectOnlyMul == true then
             
            local icon = v.sp:getChildByTag(1010)
            if icon then
              icon:removeFromParentAndCleanup(true)
            end
            local showIDList = acTankjianianhuaVoApi:getAllShowIconID()
            local randomId = math.random(1,SizeOfTable(showIDList))
            local icon = acTankjianianhuaVoApi:getShowIconById(showIDList[randomId])
            if self.moveDis>self.moveDisNum then 
                if k == 3 then
                  icon = acTankjianianhuaVoApi:getShowIconById(self.showIcon[i])
                  self["isCanStop"..i]=true
                end
            end 
              
              
              icon:setPosition(v.sp:getContentSize().width/2,v.sp:getContentSize().height/2)
              v.sp:addChild(icon)
              icon:setTag(1010)
              v.sp:setPosition(ccp(v.sp:getPositionX(),self["spTb"..i][key].sp:getPositionY()+self.turnSingleAreaH))
              -- v.sp:setPosition(ccp(v.sp:getPositionX(),v.sp:getPositionY() + self.turnSingleAreaH * (self.turnNum - 1)))
            
             
         elseif self.selectAllMul == true then

             local icon = v.sp:getChildByTag(1010)
              if icon then
                icon:removeFromParentAndCleanup(true)
              end
              local showIDList = acTankjianianhuaVoApi:getAllShowIconID()
              local randomId = math.random(1,SizeOfTable(showIDList))
              local icon = acTankjianianhuaVoApi:getShowIconById(showIDList[randomId])
              if self.moveDis>self.moveDisNum then 
                  if self["isChange"..i] == nil  then
                    self["isChange"..i]=0
                  end
                  if self["isChange"..i]<3 then
                    self["isChange"..i]=self["isChange"..i]+1

                    local iconID
                    if i == 1 then
                      if self["isChange"..i] == 1 then
                        iconID=7
                      elseif self["isChange"..i] == 2 then
                        iconID=4
                        self["select"..i]=k
                      elseif self["isChange"..i] == 3 then
                        iconID=1
                      end
                    elseif i==2 then
                      if self["isChange"..i] == 1 then
                        iconID=8
                      elseif self["isChange"..i] == 2 then
                        iconID=5
                        self["select"..i]=k
                      elseif self["isChange"..i] == 3 then
                        iconID=2
                      end
                    elseif i==3 then
                      if self["isChange"..i] == 1 then
                        iconID=9
                      elseif self["isChange"..i] == 2 then
                        iconID=6
                        self["select"..i]=k
                      elseif self["isChange"..i] == 3 then
                        iconID=3
                      end
                    end

                    print(iconID,self.showIcon[iconID])

                    icon = acTankjianianhuaVoApi:getShowIconById(self.showIcon[iconID])
                  end
                  
              end
                
                
                icon:setPosition(v.sp:getContentSize().width/2,v.sp:getContentSize().height/2)
                v.sp:addChild(icon)
                icon:setTag(1010)
                v.sp:setPosition(ccp(v.sp:getPositionX(),self["spTb"..i][key].sp:getPositionY()+self.turnSingleAreaH))

                -- v.sp:setPosition(ccp(v.sp:getPositionX(),v.sp:getPositionY() + self.turnSingleAreaH * (self.turnNum - 1)))
              
          end
      end

      if self.selectOnlyMul == true then
         if self.moveDis>self.moveDisNum and self["isCanStop"..i]==true and k== 3 and v.sp:getPositionY()==self.selectPositionY and self["isStop"..i]== false then
             self["spTb"..i.."Speed"]=0
             self["isStop"..i]=true
             self:fuwei(v.id,self["spTb"..i])
          end
      elseif self.selectAllMul == true then
        if self.moveDis>self.moveDisNum and self["isChange"..i]==3 and k==self["select"..i] then
          print(i,k,v.sp:getPositionY(),self.selectPositionY)
        end

        if self.moveDis>self.moveDisNum and self["isChange"..i]==3 and k==self["select"..i] and v.sp:getPositionY()==self.selectPositionY and self["isStop"..i]== false then
           self["spTb"..i.."Speed"]=0
           self["isStop"..i]=true
           --self:fuwei(v.id,self["spTb"..i])
        end

      end
    end
  end

  if self["isStop1"]==true and self["isStop2"]==true and self["isStop3"]==true then
    self.state = 3
    print("动画播放结束： ", self.state)
  end
end

function acTankjianianhuaDialog:fuwei(key,tb)
  local tbP = {8,128,248,368,488}
  if G_isIphone5() == false then
    tbP = {-88,32,152,272,392}
  end
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
  if sp2Key==7 then
    sp2Key = 2
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

function acTankjianianhuaDialog:result()
  self.spTb1Speed=0
  self.spTb2Speed=0
  self.spTb3Speed=0
  self.isStop1=true
  self.isStop2=true
  self.isStop3=true
  self.isCanStop1=false
  self.isCanStop2=false
  self.isCanStop3=false
  self.isChange1=0
  self.isChange2=0
  self.isChange3=0
  self.select1=0
  self.select2=0
  self.select3=0
  
  for i=1,3 do
    for k,v in pairs(self["spTb"..i]) do
        if self.clickStop == true then
          if v.id==3 then
             v.sp:setPositionY(self.selectPositionY)
             self:fuwei(v.id, self["spTb"..i])
          end

          local iconId

          local icon = v.sp:getChildByTag(1010)
          
          if self.selectOnlyMul == true then
            if k == 3 then
              if icon then
                icon:removeFromParentAndCleanup(true)
              end
              icon = acTankjianianhuaVoApi:getShowIconById(self.showIcon[i])

              icon:setPosition(v.sp:getContentSize().width/2,v.sp:getContentSize().height/2)
              v.sp:addChild(icon)
              icon:setTag(1010)


            end
          elseif self.selectAllMul == true then
            if i == 1 then
               if k == 2 then
                iconId = 1
               elseif k== 3 then
                iconId = 4 
               elseif k== 4 then
                iconId = 7
               end
            elseif i == 2 then
               if k == 2 then
                iconId = 2
               elseif k== 3 then
                iconId = 5 
               elseif k== 4 then
                iconId = 8
               end
            elseif i == 3 then
               if k == 2 then
                iconId = 3
               elseif k== 3 then
                iconId = 6 
               elseif k== 4 then
                iconId = 9
               end
            end
            if iconId then
              if icon then
                icon:removeFromParentAndCleanup(true)
              end
              icon = acTankjianianhuaVoApi:getShowIconById(self.showIcon[iconId])
              icon:setPosition(v.sp:getContentSize().width/2,v.sp:getContentSize().height/2)
              v.sp:addChild(icon)
              icon:setTag(1010)
            end
          end
        end
      end
    end
    self:showLightSp()
end


function acTankjianianhuaDialog:fastTick()
  if self.state == 2 then
    -- print("动画播放中： ", self.state)
        self:moveSp()
        self.lastSt = self.lastSt + 1
        if self.lastSt >= 10 then
          self:barPaly()
          self.lastSt = 0
        end
  elseif self.state == 3 then
    -- print("动画播放结束： ", self.state)
    self:result()
    self:stopPlayAnimation()
  end
  self:updateAcTime()
end


function acTankjianianhuaDialog:tick()
  if self.particleS ~= nil and base.serverTime - self.addParticlesTs > 10 then
    self:removeParticles()
  end
  local istoday = acTankjianianhuaVoApi:isToday()
  if istoday~=self.isToday then
    self:clearLine()
    self:clearLightSp()
    self:updateFree()
    self.isToday = istoday
    acTankjianianhuaVoApi:updateShow()
  end
end

function acTankjianianhuaDialog:startPalyAnimation()
  self.spTb1Speed=math.random(5,10) 
  self.spTb2Speed=math.random(7,15)
  self.spTb3Speed=math.random(10,20)
  self.moveDis=0
  self.isStop1=false
  self.isStop2=false
  self.isStop3=false
  self.isCanStop1=false
  self.isCanStop2=false
  self.isCanStop3=false
  self.isChange1=0
  self.isChange2=0
  self.isChange3=0
  self.select1=0
  self.select2=0
  self.select3=0

  self.clickStop = false

  self.state = 2
  self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
  print("得到抽取结果~")
  self.lastSt = 0 -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  self.lastIndex = 1 -- 上一次把手上的黄色箭头在第几个位置
  self.bar:setEnabled(false)
  self.bar:setRotation(180)
  --self.selectBg:setVisible(false)
  self:resetMetalSps()
end

function acTankjianianhuaDialog:stopPlayAnimation()
  print("正常~")
  self.state = 0
  self.lastSt = 0 -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  self.lastIndex = 0 -- 上一次把手上的黄色箭头在第几个位置
  self:stopBarPlay()
  self.bar:setEnabled(true)
  self.bar:setRotation(0)
  --self.selectBg:setVisible(true)
  self:aftetGetReward()
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
end

-- 把手播放动画
function acTankjianianhuaDialog:barPaly()
  if self ~= nil then
    local barX = self.backSprie:getContentSize().width - 110
    local arrowY = nil
    local single = (self.bar:getContentSize().height - 10)/5
    arrowY = self.backSprie:getContentSize().height/2 + 80 + self.bar:getContentSize().height / 2 + 10 - single/2 - single * (self.lastIndex - 1)
    self.lastIndex = self.lastIndex + 1
    if self.lastIndex > 5 then
      self.lastIndex = 1
    end
  end
end

function acTankjianianhuaDialog:stopBarPlay()

end

-- 抽取奖励
function acTankjianianhuaDialog:getReward()
  self.state = 1
  local free = nil
  local num = nil
  local cost = nil
  if acTankjianianhuaVoApi:checkIfFreeGame() == true then
    free = 0
    num = 3
    cost = 0
  else
    free = 1
    if self.selectAllMul == true then
      num = 9
      cost = acTankjianianhuaVoApi:getCfgMulCost()
    elseif self.selectOnlyMul == true then
      num = 3
      cost = acTankjianianhuaVoApi:getCfgCost()
    end
  end
  
  local function touchBuy()
    if free ~= nil and num ~= nil then
      local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
          -- 这里数据包了slotMachine和show两层，是为了防止每次后台返回数据，前台自动通过
          --base:formatPlayerData(data)这个方法同步数据时有不同数据用了同一个标识的情况
          self:clearLine()
          self:clearLightSp()
          if acTankjianianhuaVoApi:checkIfFreeGame() == false then
            local playerGem=playerVoApi:getGems()
            playerGem=playerGem - cost
            playerVoApi:setGems(playerGem)
          end
            if sData.data ~= nil and sData.data.tankjianianhua~= nil then
              -- if free==0 then
              --   acTankjianianhuaVoApi:updateLastTime()
              --   self.isToday = acTankjianianhuaVoApi:isToday()
              -- end
              if sData.data.tankjianianhua.selectIcons then
                self.showIcon = sData.data.tankjianianhua.selectIcons
              end
              if sData.data.tankjianianhua.showLine then
                self.showLines = sData.data.tankjianianhua.showLine
              end
              if sData.data.tankjianianhua.clientReward then
                local reward = sData.data.tankjianianhua.clientReward
                self.content = {}
                for k,v in pairs(reward) do
                  if v and type(v)=="table" then
                    for m,n in pairs(v) do
                      local award = {}
                      local pType = n[1]
                      local pid = n[2]
                      local pnum = n[3]

                      local name,pic,desc,id,noUseIdx,eType,equipId=getItem(pid,pType)
                      award={name=name,num=pnum,pic=pic,desc=desc,id=id,type=pType,index=index,key=pid,eType=eType,equipId=equipId}
                     G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                     --table.insert(self.content,award)
                     table.insert(self.content,{award=award})
                    end
                  end
                end
              end
              -- if free == 0 then
              --   self:updateFree()
              --   acTankjianianhuaVoApi:updateShow()
              -- end
              self:chatMessege()
              self:startPalyAnimation()
            end
        end
      end
      socketHelper:activityTankjianianhuaReward(num,getRawardCallback)
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

function acTankjianianhuaDialog:chatMessege()
  if self.showLines then
    local checkLine = {{4,5,6},{1,2,3},{7,8,9},{2,5,8},{1,4,7},{3,6,9},{1,5,9},{3,5,7}}
    local chatTb = {}
    if self.selectOnlyMul == true then
      local id
      if SizeOfTable(self.showLines)>0 then
        if self.showIcon[1]=="a10" and self.showIcon[2]=="a10" and self.showIcon[3]=="a10" then
          id = "a10"
        else
          for k,v in pairs(self.showIcon) do
            if v and v~="a10" then
              id = v
            end
          end
        end
        table.insert(chatTb,id)
      end
    elseif self.selectAllMul == true then
      for k,v in pairs(self.showLines) do
        if v then
          local indexs = checkLine[v]
          local id
          if self.showIcon[indexs[1]]=="a10" and self.showIcon[indexs[2]]=="a10" and self.showIcon[indexs[3]]=="a10" then
            id = "a10"
          else
            for m,n in pairs(indexs) do
              if self.showIcon[n]~="a10" then
                id=self.showIcon[n]
              end
            end
          end
          table.insert(chatTb,id)
        end
      end
    end
    local str = ""
    if chatTb and SizeOfTable(chatTb)>0 then
      for k,v in pairs(chatTb) do
        if v then
          local id = v.."-3"
          local rewardCfg = acTankjianianhuaVoApi:getRewardListByID(id)
          if rewardCfg then
            local reward = FormatItem(rewardCfg)
            if reward then
              for m,n in pairs(reward) do
                local nameStr=n.name
                if n.type=="c" then
                    nameStr=getlocal(n.name,{n.num})
                end
                if k==SizeOfTable(chatTb) then
                    str = str .. nameStr .. " x" .. n.num
                else
                    str = str .. nameStr .. " x" .. n.num .. ","
                end
              end
            end
          end
        end
      end
     local message={key="activity_tankjianianhua_chatSystemMessage",param={playerVoApi:getPlayerName(),getlocal("activity_tankjianianhua_title"),str}}
     chatVoApi:sendSystemMessage(message)
   end
  end
end
function acTankjianianhuaDialog:clearLine()
  if self.lineList then
    for k,v in pairs(self.lineList) do
      if v then
        v:setVisible(false)
      end
    end
  end
end

-- 处理后台得到返回抽取结构后前台的处理
function acTankjianianhuaDialog:aftetGetReward()

  if acTankjianianhuaVoApi:isToday()==false then
    acTankjianianhuaVoApi:updateLastTime()
    self.isToday = acTankjianianhuaVoApi:isToday()
    self:updateFree()
    acTankjianianhuaVoApi:updateShow()
  end

  if self.showLines then
    for k,v in pairs(self.showLines) do
      if v and self.lineList[v] then
        if self.lineList and self.lineList[v] then
          self.lineList[v]:setVisible(true)
        end
      end
    end
  end
  --if self.selectOnlyMul == true then
local function confirmHandler( ... )
  -- body
end
smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),self.content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,true)  --   G_showRewardTip(self.content,true)
  -- end
end

function acTankjianianhuaDialog:playParticles()
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

function acTankjianianhuaDialog:removeParticles()
  for k,v in pairs(self.particleS) do
    v:removeFromParentAndCleanup(true)
  end
  self.particleS = nil
  self.addParticlesTs = nil
end

function acTankjianianhuaDialog:doUserHandler()
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
      local exchangeDialog= acSlotMachineExchangeCommonDialog:new()
      local infoBg = exchangeDialog:init(self.layerNum+1)
    elseif tag == 5 then

      if acTankjianianhuaVoApi:isToday()==false then
        do return end
      end
      if self.selectOnlyMul == true then
         self.selectOnlyMul = false
         self.mulOnlySp:setVisible(false)

         self.selectAllMul = true
          self.mulAllSp:setVisible(true)
      else
          self.selectAllMul = false
          self.mulAllSp:setVisible(false)

          self.selectOnlyMul = true
          self.mulOnlySp:setVisible(true)
      end
      self:clearLine()
      self:clearLightSp()
      self:updateByselectOnlyMul()
      self:updateMask()
    elseif tag == 6 then
      if acTankjianianhuaVoApi:isToday()==false then
        do return end
      end
      if self.selectAllMul == true then
         self.selectOnlyMul = true
         self.mulOnlySp:setVisible(true)
         self.selectAllMul = false
         self.mulAllSp:setVisible(false)
      else

          self.selectOnlyMul = false
          self.mulOnlySp:setVisible(false)
          self.selectAllMul = true
          self.mulAllSp:setVisible(true)
      end
      self:clearLine()
      self:clearLightSp()
      self:updateByselectAllMul()
      self:updateMask()
    end
  end
  
  local function cellClick(hd,fn,index)
  end

  local adaH = 0
  if G_getIphoneType() == G_iphoneX then
    adaH = 1250 - 1136
  end
  local rect = CCRect(0, 0, 50, 50)
  local capInSet = CCRect(20, 20, 10, 10)
  self.backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
  self.backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, 180+adaH/2))
  self.backSprie:setAnchorPoint(ccp(0.5,0))
  self.backSprie:setPosition(ccp(G_VisibleSizeWidth/2, 20))
  self.bgLayer:addChild(self.backSprie,6)
  
  -- 10倍模式显示
  local mulX = 100
  local mulY = 120
  if G_getIphoneType() == G_iphoneX then
    mulY = mulY + adaH/4
  end
  --  单排模式
  -- local bgSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch2)
  local onlybgSp = GetButtonItem("LegionCheckBtnUn.png","LegionCheckBtnUn.png","LegionCheckBtnUn.png",touch,5,nil)
  onlybgSp:setAnchorPoint(ccp(0,0.5))
  self.selectOnlyBtn=CCMenu:createWithItem(onlybgSp)
  self.selectOnlyBtn:setTouchPriority(-(self.layerNum-1)*20-4)
  self.selectOnlyBtn:setPosition(mulX-80,mulY)
  self.backSprie:addChild(self.selectOnlyBtn)


  -- 选中状态
  self.mulOnlySp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
  self.mulOnlySp:setAnchorPoint(ccp(0,0.5))
  self.mulOnlySp:setPosition(mulX-80,mulY)
  self.backSprie:addChild(self.mulOnlySp)
  
  mulX = mulX + onlybgSp:getContentSize().width + 10
  self.mulOnlyDesc=GetTTFLabelWrap(getlocal("activity_tankjianianhua_onlyMode"),25,CCSizeMake(G_VisibleSizeWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.mulOnlyDesc:setAnchorPoint(ccp(0,0.5))
  self.mulOnlyDesc:setPosition(mulX-80,mulY)
  self.backSprie:addChild(self.mulOnlyDesc)

--火力全开
  local allMulX = 100
  local allMulY = 50
  if G_getIphoneType() == G_iphoneX then
    allMulY = allMulY + adaH/4
  end
  -- local bgSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch2)
  local allbgSp = GetButtonItem("LegionCheckBtnUn.png","LegionCheckBtnUn.png","LegionCheckBtnUn.png",touch,6,nil)
  allbgSp:setAnchorPoint(ccp(0,0.5))
  self.selectAllBtn=CCMenu:createWithItem(allbgSp)
  self.selectAllBtn:setTouchPriority(-(self.layerNum-1)*20-4)
  self.selectAllBtn:setPosition(allMulX-80,allMulY)
  self.backSprie:addChild(self.selectAllBtn)


  -- 选中状态
  self.mulAllSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
  self.mulAllSp:setAnchorPoint(ccp(0,0.5))
  self.mulAllSp:setPosition(allMulX-80,allMulY)
  self.backSprie:addChild(self.mulAllSp)
  
  allMulX = allMulX + allbgSp:getContentSize().width + 10
  self.mulAllDesc=GetTTFLabelWrap(getlocal("activity_allianceDonate_title"),25,CCSizeMake(G_VisibleSizeWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.mulAllDesc:setAnchorPoint(ccp(0,0.5))
  self.mulAllDesc:setPosition(allMulX-80,allMulY)
  self.backSprie:addChild(self.mulAllDesc)

  self.costLb=GetTTFLabelWrap(getlocal("activity_tankjianianhua_Consume"),25,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  self.costLb:setAnchorPoint(ccp(0.5,0))
  self.costLb:setPosition(self.backSprie:getContentSize().width-160,self.backSprie:getContentSize().height/2+adaH/4)
  self.backSprie:addChild(self.costLb)

  local costSP = LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),function ()end)
  costSP:setIsSallow(true)
  costSP:setTouchPriority(-(self.layerNum-1)*20-1)
  local rect=CCSizeMake(150,60)
  costSP:setContentSize(rect)
  costSP:ignoreAnchorPointForPosition(false)
  costSP:setAnchorPoint(CCPointMake(0.5,0.5))
  costSP:setPosition(self.backSprie:getContentSize().width-160,50+adaH/4)
  self.backSprie:addChild(costSP)

  self.costLabel = GetTTFLabel(tostring(0), 30)
  self.costLabel:setAnchorPoint(ccp(0.5,0.5))
  self.costLabel:setPosition(ccp(costSP:getContentSize().width/2, costSP:getContentSize().height/2))
  self.costLabel:setColor(G_ColorYellowPro)
  costSP:addChild(self.costLabel)

  self.gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
  self.gemIcon:setAnchorPoint(ccp(0,0.5))
  self.gemIcon:setPosition(ccp(costSP:getContentSize().width-50, costSP:getContentSize().height/2))
  costSP:addChild(self.gemIcon)


  self.freeLb=GetTTFLabelWrap(getlocal("daily_lotto_tip_2"),25,CCSizeMake(costSP:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  self.freeLb:setAnchorPoint(ccp(0.5,0.5))
  self.freeLb:setPosition(costSP:getContentSize().width/2,costSP:getContentSize().height/2)
  costSP:addChild(self.freeLb)
  self.freeLb:setColor(G_ColorGreen)

  self.selectAllMul = false
  self.mulAllSp:setVisible(false)
  self.selectOnlyMul=true
  self.mulOnlySp:setVisible(true)

  self:updateByselectOnlyMul()
  self:updateFree()
  

  
  local barX = self.backSprie:getContentSize().width - 50
  local barY = self.backSprie:getContentSize().height/2

  self.bar=GetButtonItem("SlotBtn.png","SlotBtn.png","SlotBtn.png",touch,4,nil,0)
  self.bar:setScale(0.7)
  self.bar:setAnchorPoint(ccp(0.5, 0.5))
  local bar2=CCMenu:createWithItem(self.bar)
  bar2:setPosition(ccp(barX,barY))
  bar2:setTouchPriority(-(self.layerNum-1)*20-5)
  self.backSprie:addChild(bar2,2)

end

-- 选择或取消收益倍数后相关ui刷新
function acTankjianianhuaDialog:updateByselectOnlyMul()
  if self.costLabel ~= nil then
    local cost = 99999
    if acTankjianianhuaVoApi:checkIfFreeGame() == true then
      cost = 0
    else
      if self.selectOnlyMul == true then
        cost = acTankjianianhuaVoApi:getCfgCost()
      else
        cost = acTankjianianhuaVoApi:getCfgMulCost()
      end
    end  
    self.costLabel:setString(tostring(cost))
  end
end

-- 选择或取消收益倍数后相关ui刷新
function acTankjianianhuaDialog:updateByselectAllMul()
  if self.costLabel ~= nil then
    local cost = 99999
    if acTankjianianhuaVoApi:checkIfFreeGame() == true then
      cost = 0
    else
      if self.selectAllMul == true then
        cost = acTankjianianhuaVoApi:getCfgMulCost()
      else
         cost = acTankjianianhuaVoApi:getCfgCost()
      end
    end  
    self.costLabel:setString(tostring(cost))
  end
end

-- 刷新领奖按钮
function acTankjianianhuaDialog:updateFree()
  if acTankjianianhuaVoApi:isToday()==false then
    self.freeLb:setVisible(true)
    self.costLabel:setVisible(false)
    self.gemIcon:setVisible(false)
    if self.selectOnlyMul == false then
     self.selectAllMul = false
     self.mulAllSp:setVisible(false)

     self.selectOnlyMul = true
     self.mulOnlySp:setVisible(true)
   end
  else
    self.freeLb:setVisible(false)
    self.costLabel:setVisible(true)
    self.gemIcon:setVisible(true)
  end
end

function acTankjianianhuaDialog:openInfo()

end



function acTankjianianhuaDialog:update()
  local acVo = acTankjianianhuaVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      self:updateByselectOnlyMul()
      self:updateFree()
    end
  end
end

function acTankjianianhuaDialog:updateAcTime()
  local acVo=acTankjianianhuaVoApi:getAcVo()
  if acVo and self.timeLb then
    G_updateActiveTime(acVo,self.timeLb)
  end
end

function acTankjianianhuaDialog:dispose()
  self.costLabel = nil

  self.selectOnlyMul = nil
  self.mulOnlySp = nil
  self.mulOnlyDesc = nil
  self.selectOnlyBtn = nil

  self.bar = nil -- 右侧把手
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

  self.showIcon=nil
  self.showLines=nil
  self.lineList =nil
  self.timeLb=nil
  self=nil
end






