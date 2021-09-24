acLuckyCatDialog=commonDialog:new()

function acLuckyCatDialog:new()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	   spriteController:addPlist("public/acLuckyCat.plist")  
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.costLabel = nil
    self.rewardBtn = nil

    self.bar = nil -- 右侧把手
    self.leftIcon = nil -- 把手左侧黄色的箭头图标
    self.rightIcon = nil -- 把手右侧黄色的箭头图标
    self.backSprie = nil -- 上方的背景
    self.downBgSp =nil
    self.lastSt = nil -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
    self.lastIndex = nil -- 上一次把手上的黄色箭头在第几个位置
    
    self.turnSingleAreaH = 180 -- 转动区域每个图标占的高度
    self.turnNum = 9 -- 转动区域个数

    self.particleS = nil -- 粒子效果
    self.addParticlesTs = nil -- 添加粒子效果的时间
    self.playIds = {} -- 播放动画最终停止的位置

    self.selectBg = nil -- 播放动画最终获得物品的背景
    self.state = 0 -- 0 正常 1 点击抽取 2 后台返回结果 3 动画播放结束

    self.spTb1={}
    self.spTb2={}
    self.spTb3={}
    self.spTb4={}
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
    self.showTimeAndMone=nil
    self.currBySelfGold=nil
    self.currNeedGold=nil
    self.recordlist={}
    self.pointNum =nil
    return nc
end

function acLuckyCatDialog:initTableView()
  local function touchDialog()
      if self.state == 2 then
        PlayEffect(audioCfg.mouseClick)
        self.state = 3
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
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 95))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
  
  local bgW = 380
  local machineBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(20, 20, 10, 10),function () do return end end)--拉霸动画背景
  machineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.6+30,180))
  machineBg:setOpacity(0)
  machineBg:setAnchorPoint(ccp(0,0.5))
  machineBg:setPosition(20,self.backSprie:getContentSize().height/2 -10)
  self.backSprie:addChild(machineBg,7)

  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(machineBg:getContentSize().width,machineBg:getContentSize().height),nil)
  machineBg:addChild(self.tv,1)
  self.tv:setAnchorPoint(ccp(0,0))
  self.tv:setPosition(ccp(0,0))
  self.tv:setMaxDisToBottomOrTop(220)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)

  local recordPoint = self.tv:getRecordPoint()
  recordPoint.y = -self.turnSingleAreaH
  self.tv:recoverToRecordPoint(recordPoint)

  local showSpPosHeight = 30
  if G_isIphone5() then
  	showSpPosHeight =80
  end
  local showSp = LuaCCScale9Sprite:createWithSpriteFrameName("deepColorBg.png",CCRect(20, 20, 10, 10),function () do return end end)--拉霸动画背景
  showSp:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.3))
  showSp:setAnchorPoint(ccp(0,0))
  showSp:setPosition(ccp(20,showSpPosHeight))
  self.downBgSp:addChild(showSp,1)

  local function callBack2(...)
       return self:eventHandler2(...)
  end
  local hd2= LuaEventHandler:createHandler(callBack2)

  self.tv2=LuaCCTableView:createWithEventHandler(hd2,CCSizeMake(showSp:getContentSize().width,showSp:getContentSize().height),nil)
  showSp:addChild(self.tv2,4)
  self.tv2:setAnchorPoint(ccp(0,0))
  self.tv2:setPosition(ccp(0,0))
  self.tv2:setMaxDisToBottomOrTop(120)
end

function acLuckyCatDialog:eventHandler2( handler,fn,idx,cel )
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.3)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local needheight2 = G_VisibleSizeHeight*0.3-10
    local recordlistNow = acLuckyCatVoApi:getRecordList()
    local listSize = SizeOfTable(recordlistNow)
    local needNum = 0
    for i=0,6 do
		if recordlistNow[i] then
			local showListPosHeight = 5-listSize+i
			local showPlayer = recordlistNow[i][1]
			local showGold = recordlistNow[i][2]
			local showPlayerStr = GetTTFLabel(getlocal("activity_xinfulaba_PlayerName",{showPlayer}),25)
			showPlayerStr:setAnchorPoint(ccp(0,0))
			showPlayerStr:setPosition(ccp(20,20+10*showListPosHeight+needheight2*0.13*showListPosHeight))
			cell:addChild(showPlayerStr,1)

			local gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
			gemIcon:setAnchorPoint(ccp(0,0))
			gemIcon:setPosition(ccp(G_VisibleSizeWidth*0.3+25,20+10*showListPosHeight+needheight2*0.13*showListPosHeight))
			cell:addChild(gemIcon,1)

			local showGoldStr = GetTTFLabel(showGold,25)
			showGoldStr:setAnchorPoint(ccp(0,0))
			showGoldStr:setPosition(ccp(gemIcon:getContentSize().width+gemIcon:getPositionX(),20+10*showListPosHeight+needheight2*0.13*showListPosHeight))
			cell:addChild(showGoldStr,1)
			showGoldStr:setColor(G_ColorYellowPro)
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

function acLuckyCatDialog:eventHandler( handler,fn,idx,cel )
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    return  CCSizeMake(G_VisibleSizeWidth*0.6+30,self.turnSingleAreaH * self.turnNum)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local picX = nil
    local totalH = self.turnSingleAreaH * self.turnNum
    local picY = totalH - self.turnSingleAreaH * 5 + 20
    for i=1,4 do
        local startId = acLuckyCatVoApi:getLastResultByLine(i)
        for i2=1,2 do
          if startId == 0 then
            startId = 9
          else
            startId = startId - 1
          end
        end
        for id=0,self.turnNum do
          picY = totalH - self.turnSingleAreaH * id + 35
          local numPic = CCSprite:createWithSpriteFrameName("numb_"..startId..".png")
          picX = 8 + (4-i) * 110
          numPic:setAnchorPoint(ccp(0,0))
          numPic:setPosition(ccp(picX, picY))
          cell:addChild(numPic)
          if id==8 then
            self.selectPositionY=numPic:getPositionY()
          end
          self["spTb"..i][startId]={}
          self["spTb"..i][startId].id=startId
          self["spTb"..i][startId].sp=numPic
          

          startId = startId - 1
          if startId > self.turnNum  then
            startId = 0
          elseif startId < 0 then
          	startId =9
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

function acLuckyCatDialog:firstSendReward( )
      local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
        	if sData.data and sData.data.xinfulaba then
        		if sData.data.xinfulaba.recordlist then
        			acLuckyCatVoApi:setRecordList(sData.data.xinfulaba.recordlist)
        			acLuckyCatVoApi:setShowNow(true)
        		end              
            end
        end
      end
      socketHelper:willLottering(1,getRawardCallback)
end

function acLuckyCatDialog:doUserHandler()
	acLuckyCatVoApi:setLotteryTimes( )
	self:firstSendReward()

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
		end
	end

	local w = nil
	local h = G_VisibleSizeHeight - 95

	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
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

	local acVo = acLuckyCatVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,28)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp(G_VisibleSizeWidth/2+20, h-30))
	self.bgLayer:addChild(messageLabel,3)

	local function desHd( ... )
		do return end
	end 
	local desBgSp = CCSprite:createWithSpriteFrameName("orangeMask.png")
	desBgSp:setScaleY(60/desBgSp:getContentSize().height)
  desBgSp:setScaleX(900/desBgSp:getContentSize().width)
	desBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,messageLabel:getPositionY()-60))
	desBgSp:ignoreAnchorPointForPosition(false)
	desBgSp:setAnchorPoint(ccp(0.5,1))
	self.bgLayer:addChild(desBgSp,2)

	local needWidth = 80
	local needWidth2 = 80
	local needheight = 10
	local strSize1 = 22
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
		strSize1 =25
		needWidth2 =180
	end
	local showDec1 = GetTTFLabel(getlocal("activity_xinfulaba_desShow1"),38)
	showDec1:setAnchorPoint(ccp(0,0.5))
	showDec1:setPosition(ccp(needWidth2,desBgSp:getPositionY()-desBgSp:getContentSize().height*0.5-needheight))
	showDec1:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(showDec1,3)
	local showDec2 = GetTTFLabel(getlocal("activity_xinfulaba_desShow2"),24)
	showDec2:setAnchorPoint(ccp(0,1))
	showDec2:setPosition(ccp(showDec1:getContentSize().width+needWidth2+5,desBgSp:getPositionY()-desBgSp:getContentSize().height+10+needheight))
	showDec2:setColor(G_ColorWhite)
	self.bgLayer:addChild(showDec2,3)

	local bgHeigh1 = 20
	local bgHeigh2 = 40
	local blueScaleY = 300
	local posHeight2 = -20
	local girScale = 0.9
	local girlNeedPosWidht = 20
	if G_isIphone5() then
		bgHeigh1 =40
		bgHeigh2 =15
		blueScaleY =450
		posHeight2 = 10
		girScale= 1.2
		girlNeedPosWidht=0
	end
	self.backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),function () do return end end)
	self.backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-22,G_VisibleSizeHeight*0.4-50))
	self.backSprie:setAnchorPoint(ccp(0.5,1))
	self.backSprie:setPosition(G_VisibleSizeWidth*0.5+1,desBgSp:getPositionY()-desBgSp:getContentSize().height-bgHeigh1)
	self.bgLayer:addChild(self.backSprie,3)
	self.backSprie:setTag(111)

	self.downBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function () do return end end)--拉霸动画背景
	self.downBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-28,G_VisibleSizeHeight*0.4-bgHeigh2))
	self.downBgSp:setAnchorPoint(ccp(0.5,1))
	self.downBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.4+posHeight2))
	self.bgLayer:addChild(self.downBgSp,3)
	self.downBgSp:setTag(112)
  
	local girlPic = CCSprite:createWithSpriteFrameName("ShapeCharacter.png")
	girlPic:setAnchorPoint(ccp(0,0))
	girlPic:setPosition(ccp(G_VisibleSizeWidth*0.6+girlNeedPosWidht,25))
	girlPic:setFlipX(true)
	girlPic:setScale(girScale)
	self.bgLayer:addChild(girlPic,4)

	local blueGroup = CCSprite:createWithSpriteFrameName("blueGroup.png")
	blueGroup:setScaleY(blueScaleY/blueGroup:getContentSize().height)
  blueGroup:setScaleX(600/blueGroup:getContentSize().width)
	blueGroup:setAnchorPoint(ccp(0.5,0.5))
	blueGroup:ignoreAnchorPointForPosition(false)
	blueGroup:setPosition(self.backSprie:getContentSize().width*0.5,self.backSprie:getContentSize().height*0.5)
	self.backSprie:addChild(blueGroup,2)

	for i=1,4 do
		local needWidth2 = 10
		local goldSp = CCSprite:createWithSpriteFrameName("goldSpr.png")
		goldSp:setAnchorPoint(ccp(0,0.5))
		goldSp:setPosition(ccp((i-1)*(goldSp:getContentSize().width+5)+needWidth2,self.backSprie:getContentSize().height*0.5-10))
		self.backSprie:addChild(goldSp,3)
	end
	
	local numTIme,currReward = acLuckyCatVoApi:getTimesAndMoney( )--
	if numTIme and currReward then
		self.showTimeAndMone = GetTTFLabel(getlocal("activity_xinfulaba_desShow3",{numTIme,currReward}),strSize1)
		self.showTimeAndMone:setAnchorPoint(ccp(0,0.5))
		self.showTimeAndMone:setPosition(ccp(needWidth,self.backSprie:getContentSize().height*0.8+20))
		self.backSprie:addChild(self.showTimeAndMone,3)
		local gemIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
		gemIcon:setAnchorPoint(ccp(0,0.5))
		gemIcon:setPosition(ccp(self.showTimeAndMone:getContentSize().width+5+needWidth, self.showTimeAndMone:getPositionY()))
		self.backSprie:addChild(gemIcon,3)
		gemIcon:setTag(200)
	end
	local currNeedGold =acLuckyCatVoApi:getNeedGold()
	local currBySelfGold =playerVoApi:getGems()
	
	self.currBySelfGold=GetTTFLabel(getlocal("activity_xinfulaba_currSelfGold",{currBySelfGold}),strSize1)
	self.currBySelfGold:setAnchorPoint(ccp(0,0))
	self.currBySelfGold:setPosition(ccp(needWidth,20))
	self.backSprie:addChild(self.currBySelfGold,3)

		local gemIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
		gemIcon1:setAnchorPoint(ccp(0,0))
		gemIcon1:setPosition(ccp(self.currBySelfGold:getContentSize().width+5+needWidth, 20))
		self.backSprie:addChild(gemIcon1,3)
		gemIcon1:setTag(201)

	self.currNeedGold = GetTTFLabel(getlocal("activity_xinfulaba_needGold",{currNeedGold}),strSize1)
	self.currNeedGold:setAnchorPoint(ccp(0,0))
	self.currNeedGold:setPosition(ccp(needWidth+250,20))
	self.backSprie:addChild(self.currNeedGold,3)
	self.currNeedGold:setColor(G_ColorYellowPro)

		local gemIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
		gemIcon2:setAnchorPoint(ccp(0,0))
		gemIcon2:setPosition(ccp(self.currNeedGold:getContentSize().width+needWidth+255, 20))
		self.backSprie:addChild(gemIcon2,3)
		gemIcon2:setTag(202)

	if currBySelfGold<currNeedGold then
		self.currBySelfGold:setColor(G_ColorRed)
	else
		self.currBySelfGold:setColor(G_ColorYellowPro)
	end

	local barX = self.backSprie:getContentSize().width - 90
	local barY = nil

	self.bar=GetButtonItem("SlotBtn.png","SlotBtn.png","SlotBtn.png",touch,4,nil,0)
	barY = self.backSprie:getContentSize().height*0.5-10
	self.bar:setAnchorPoint(ccp(0.5, 0.5))
	local bar2=CCMenu:createWithItem(self.bar)
	bar2:setPosition(ccp(barX,barY))
	bar2:setTouchPriority(-(self.layerNum-1)*20-5)
	self.backSprie:addChild(bar2,3)

  local leftArrowX = barX - self.bar:getContentSize().width / 2 
  local rightArrowX = barX + self.bar:getContentSize().width / 2 
  local arrowY = nil
  local single = (self.bar:getContentSize().height - 10)/5

  for i=1,5 do
    arrowY = barY + self.bar:getContentSize().height / 2 + 10 - single/2 - single * (i - 1)-10
    local leftArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
    leftArrow:setPosition(ccp(leftArrowX,arrowY))
    self.backSprie:addChild(leftArrow,3)

    local rightArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
    rightArrow:setPosition(ccp(rightArrowX,arrowY))
    self.backSprie:addChild(rightArrow,3)
  end
  -- 把手左侧黄色的箭头图标
  self.leftIcon = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
  self.leftIcon:setPosition(ccp(leftArrowX,arrowY))
  self.leftIcon:setVisible(false)
  self.backSprie:addChild(self.leftIcon,3)
  -- 把手右侧黄色的箭头图标
  self.rightIcon = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
  self.rightIcon:setPosition(ccp(rightArrowX,arrowY))
  self.rightIcon:setVisible(false)
  self.backSprie:addChild(self.rightIcon,3)
end
function acLuckyCatDialog:getReward()
  self.state = 1
  local consumeTimes = acLuckyCatVoApi:getLocalLotteryTimes() --消耗次数
  local nextLotteryTimes = acLuckyCatVoApi:getLotteryTimes()
  local largeTimesLoc,largestTimes = acLuckyCatVoApi:getlargeTimes( )
  local cost = acLuckyCatVoApi:getNeedGold( )
  
  local function touchBuy()
      local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
        	playerVoApi:setGems(playerVoApi:getGems()-acLuckyCatVoApi:getNeedGold())
        	local currBySelfGold =getlocal("activity_xinfulaba_currSelfGold",{playerVoApi:getGems()})
        	if currBySelfGold then
      				self.currBySelfGold:setString(currBySelfGold)
      				tolua.cast(self.backSprie:getChildByTag(201),"CCSprite"):setPosition(ccp(self.currBySelfGold:getContentSize().width+85, self.currBySelfGold:getPositionY()))
			    end
        	if sData.data and sData.data.xinfulaba then
        		if sData.data.xinfulaba.t then
        			acLuckyCatVoApi:setLocalLotteryTimes(sData.data.xinfulaba.t)
        		end
        		if sData.data.xinfulaba.pointNum then
        			local pointNum = tonumber(sData.data.xinfulaba.pointNum)
        			self.pointNum = tonumber(sData.data.xinfulaba.pointNum)
              playerVoApi:setGems(playerVoApi:getGems()+self.pointNum)
        			self.playIds={}
        			for i=1,4 do
        				table.insert(self.playIds,math.floor(pointNum%10))
        				pointNum=pointNum/10
        			end
        			self:startPalyAnimation()
        		end
    		    acLuckyCatVoApi:updateLastResult(self.playIds)--数值不对！！
          end
        end
      end
      socketHelper:willLottering(2,getRawardCallback)
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
  elseif consumeTimes >=largeTimesLoc then
  	if largeTimesLoc == largestTimes then
  		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_xinfulaba_tip2",{tonumber(consumeTimes)}),30)
  	else
  		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_xinfulaba_tip",{tonumber(consumeTimes)}),30)
  	end
  elseif tonumber(cost) > 0 then
      touchBuy()
  end
end

function acLuckyCatDialog:updataNewData()
	acLuckyCatVoApi:setLotteryTimes( )
	local nextTimes,nextGolds = acLuckyCatVoApi:getTimesAndMoney( )
	local showTimeMone 	= getlocal("activity_xinfulaba_desShow3",{nextTimes,nextGolds})
	local currNeedGold 	=getlocal("activity_xinfulaba_needGold",{acLuckyCatVoApi:getNeedGold()})
  self.pointNum=0
	local currBySelfGoldStr = playerVoApi:getGems()
	local currBySelfGold =getlocal("activity_xinfulaba_currSelfGold",{currBySelfGoldStr})

	if self.showTimeAndMone then
		self.showTimeAndMone:setString(showTimeMone)
		tolua.cast(self.backSprie:getChildByTag(200),"CCSprite"):setPosition(ccp(self.showTimeAndMone:getContentSize().width+85, self.showTimeAndMone:getPositionY()))
	end
	if currBySelfGold and currNeedGold then
		self.currBySelfGold:setString(currBySelfGold)
		self.currNeedGold:setString(currNeedGold)
		tolua.cast(self.backSprie:getChildByTag(201),"CCSprite"):setPosition(ccp(self.currBySelfGold:getContentSize().width+85, self.currBySelfGold:getPositionY()))
		tolua.cast(self.backSprie:getChildByTag(202),"CCSprite"):setPosition(ccp(self.currNeedGold:getContentSize().width+335, self.currNeedGold:getPositionY()))

  local currNeedGoldNum =acLuckyCatVoApi:getNeedGold()
  local currBySelfGoldNum =playerVoApi:getGems()
    if currBySelfGoldNum<currNeedGoldNum then
      self.currBySelfGold:setColor(G_ColorRed)
    else
      self.currBySelfGold:setColor(G_ColorYellowPro)
    end
	end
end

function acLuckyCatDialog:startPalyAnimation()
  self.spTb1Speed=math.random(2,4) 
  self.spTb2Speed=math.random(5,8)
  self.spTb3Speed=math.random(9,13)
  self.spTb4Speed=math.random(14,18)
  self.moveDis=0
  self.isStop1=false
  self.isStop2=false
  self.isStop3=false
  self.isStop4=false
  self.state = 2
  self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
  print("得到抽取结果~")
  self.lastSt = 0 -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  self.lastIndex = 1 -- 上一次把手上的黄色箭头在第几个位置
  self.leftIcon:setVisible(true)
  self.rightIcon:setVisible(true)
  self.bar:setEnabled(false)
  self.bar:setRotation(180)
end
function acLuckyCatDialog:stopPlayAnimation()
  print("正常~")
  self.state = 0
  self.lastSt = 0 -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
  self.lastIndex = 0 -- 上一次把手上的黄色箭头在第几个位置
  self:stopBarPlay()
  self.bar:setEnabled(true)
  self.bar:setRotation(0)
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
  local showNum = tonumber(acLuckyCatVoApi:getShowRecGold( ))
  local cosuGold = acLuckyCatVoApi:getNeedGold( )
  local shwoMessage = getlocal("activity_xinlulaba_chatShow",{playerVoApi:getPlayerName(),getlocal("activity_xinfulaba_title"),self.pointNum})
  if showNum<= self.pointNum then
  	chatVoApi:sendSystemMessage(shwoMessage)
  	local prams={name=playerVoApi:getPlayerName(),point=self.pointNum}
  	chatVoApi:sendUpdateMessage(26,prams)
  	self:playParticles()
  end
  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("rechargeGifts_recMone",{tonumber(self.pointNum)}),30)
  
  self:updataNewData()
end

function acLuckyCatDialog:result(tb)
  self.spTb1Speed=0
  self.spTb2Speed=0
  self.spTb3Speed=0
  self.spTb4Speed=0
  self.isStop1=true
  self.isStop2=true
  self.isStop3=true
  self.isStop4=true
  for i=1,4 do
    for k,v in pairs(self["spTb"..i]) do
      if v.id==tb[i] then
         v.sp:setPositionY(self.selectPositionY)
         self:fuwei(v.id, self["spTb"..i])
      end
    end
  end
end

function acLuckyCatDialog:fuwei(key,tb)
  local tbP = {30,210,390,570,750,930,1110,1290,1470,1650}--0,6,3,9

  local sp1Key = key+1
  if sp1Key==10 then
    sp1Key=0
  end
  local sp1 = tolua.cast(tb[sp1Key].sp,"CCNode")
  sp1:setPosition(ccp(sp1:getPositionX(),tbP[3]))

  local sp2Key = key+2
  if key >7 then
	  if sp2Key==10 then
	    sp2Key=0
	  elseif sp2Key ==11 then
	  	sp2Key =1
	  end
  end
  local sp2 = tolua.cast(tb[sp2Key].sp,"CCNode")
  sp2:setPosition(ccp(sp2:getPositionX(),tbP[4]))

  local sp3Key = key+3
  if key >6 then
	  if sp3Key==10 then
	    sp3Key=0
	  elseif sp3Key ==11 then
	  	sp3Key =1
	  elseif sp3Key ==12 then
	  	sp3Key =2
	  end
  end
  local sp3 = tolua.cast(tb[sp3Key].sp,"CCNode")
  sp3:setPosition(ccp(sp3:getPositionX(),tbP[5]))

  local sp4Key = key+4
  if key >5 then
	  if sp4Key==10 then
	    sp4Key=0
	  elseif sp4Key ==11 then
	  	sp4Key =1
	  elseif sp4Key ==12 then
	  	sp4Key =2
	  elseif sp4Key ==13 then
	  	sp4Key =3
	  end
  end
  local sp4 = tolua.cast(tb[sp4Key].sp,"CCNode")
  sp4:setPosition(ccp(sp4:getPositionX(),tbP[6]))

  local sp5Key = key+5
  if key >4 then
	  if sp5Key==10 then
	    sp5Key=0
	  elseif sp5Key ==11 then
	  	sp5Key =1
	  elseif sp5Key ==12 then
	  	sp5Key =2
	  elseif sp5Key ==13 then
	  	sp5Key =3
	  elseif sp5Key ==14 then
	  	sp5Key =4
	  end
  end
  local sp5 = tolua.cast(tb[sp5Key].sp,"CCNode")
  sp5:setPosition(ccp(sp5:getPositionX(),tbP[7]))

  local sp6Key = key+6
  if key >3 then
  	if sp6Key <13 then
	  if sp6Key==10 then
	    sp6Key=0
	  elseif sp6Key ==11 then
	  	sp6Key =1
	  elseif sp6Key ==12 then
	  	sp6Key =2
	  end
	else
	  if sp6Key ==13 then
	  	sp6Key =3
	  elseif sp6Key ==14 then
	  	sp6Key =4
	  elseif sp6Key ==15 then
	  	sp6Key =5
	  end
	end
  end
  local sp6 = tolua.cast(tb[sp6Key].sp,"CCNode")
  sp6:setPosition(ccp(sp6:getPositionX(),tbP[8]))

  local sp7Key = key+7
  if key >2 then
  	if sp7Key <=13 then
	  if sp7Key==10 then
	    sp7Key=0
	  elseif sp7Key ==11 then
	  	sp7Key =1
	  elseif sp7Key ==12 then
	  	sp7Key =2
	  elseif sp7Key ==13 then
	  	sp7Key =3
	  end
	else
	  if sp7Key ==14 then
	  	sp7Key =4
	  elseif sp7Key ==15 then
	  	sp7Key =5
	  elseif sp7Key ==16 then
	  	sp7Key =6
	  end
	end
  end
  local sp7 = tolua.cast(tb[sp7Key].sp,"CCNode")
  sp7:setPosition(ccp(sp7:getPositionX(),tbP[9]))

  local sp8Key = key+8
  if key >1 then
  	if sp8Key <=14 then
	  if sp8Key==10 then
	    sp8Key=0
	  elseif sp8Key ==11 then
	  	sp8Key =1
	  elseif sp8Key ==12 then
	  	sp8Key =2
	  elseif sp8Key ==13 then
	  	sp8Key =3
	  elseif sp8Key ==14 then
	  	sp8Key =4
	  end
	else
	  if sp8Key ==15 then
	  	sp8Key =5
	  elseif sp8Key ==16 then
	  	sp8Key =6
	  elseif sp8Key ==17 then
	  	sp8Key =7
	  end
	end
  end
  local sp8 = tolua.cast(tb[sp8Key].sp,"CCNode")
  sp8:setPosition(ccp(sp8:getPositionX(),tbP[10]))

  local sp9Key = key-1
  if sp9Key==-1 then
    sp9Key=9
  end
  local sp9 = tolua.cast(tb[sp9Key].sp,"CCNode")
  sp9:setPosition(ccp(sp9:getPositionX(),tbP[1]))
end

function acLuckyCatDialog:tick()
	if acLuckyCatVoApi:getShowNow() ==true then
		if self.tv2 then
			self.tv2:reloadData()
			acLuckyCatVoApi:setShowNow(false)
		end
	end
  if self.particleS ~= nil and base.serverTime - self.addParticlesTs > 10 then
    self:removeParticles()
  end
end

function acLuckyCatDialog:fastTick()
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

function acLuckyCatDialog:moveSp(tb)
  self.moveDis=self.moveDis+1
  for i=1,4 do
    if self.moveDis>self.moveDisNum and self["isStop"..5-i]==false then
      if self.moveDis%50==0 then
            self["spTb"..5-i.."Speed"]=self["spTb"..5-i.."Speed"]-1        
        if self["spTb"..5-i.."Speed"]<=1 then
            self["spTb"..5-i.."Speed"]=1
        end
      end
    end
  end
  
  for i=1,4 do
    for k,v in pairs(self["spTb"..5-i]) do
        v.sp:setPosition(ccp(v.sp:getPositionX(),v.sp:getPositionY()-self["spTb"..5-i.."Speed"]))
        if v.sp:getPositionY()<=-self.turnSingleAreaH then -- 位置到最下面隐藏的位置后，需要把位置调到最上面
          local key = k+1
          if key==10 then
            key=0
          end

          v.sp:setPosition(ccp(v.sp:getPositionX(),self["spTb"..5-i][key].sp:getPositionY()+self.turnSingleAreaH*9))
        end
        if self.moveDis>self.moveDisNum and v.id==tb[5-i] and v.sp:getPositionY()==self.selectPositionY and self["isStop"..5-i]== false  then
        	local stopI = 4-i--按从右向左顺序停止拉霸
        	if  (stopI > 0 and self["isStop"..stopI]== true) or stopI ==0 then
	           self["spTb"..5-i.."Speed"]=0
	           self["isStop"..5-i]=true
	           self:fuwei(v.id,self["spTb"..5-i])
	       	end
        end
    end
  end

  if self["isStop1"]==true and self["isStop2"]==true and self["isStop3"]==true and self["isStop4"] == true then
    self.state = 3
    print("动画播放结束： ", self.state)
  end
end

function acLuckyCatDialog:barPaly()
  if self ~= nil then
    local barX = self.backSprie:getContentSize().width - 90
    local leftArrowX = barX - self.bar:getContentSize().width / 2 
    local rightArrowX = barX + self.bar:getContentSize().width / 2
    local arrowY = nil
    local single = (self.bar:getContentSize().height - 10)/5
    arrowY = self.backSprie:getContentSize().height/2 -20 + self.bar:getContentSize().height / 2 + 10 - single/2 - single * (self.lastIndex - 1)
    self.leftIcon:setPosition(ccp(leftArrowX,arrowY))
    self.rightIcon:setPosition(ccp(rightArrowX,arrowY))
    self.lastIndex = self.lastIndex + 1
    if self.lastIndex > 5 then
      self.lastIndex = 1
    end
  end
end

function acLuckyCatDialog:stopBarPlay()
  self.leftIcon:setVisible(false)
  self.rightIcon:setVisible(false)
end

function acLuckyCatDialog:update()
  local acVo = acLuckyCatVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子

    end
  end
end

function acLuckyCatDialog:openInfo()
  local td=smallDialog:new()
  local tabStr = {"\n",getlocal("activity_xinfulaba_addTip"),"\n",getlocal("activity_xinfulaba_tipIn2"),"\n",getlocal("activity_xinfulaba_tipIn1"),"\n"}
  local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acLuckyCatDialog:playParticles()
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

function acLuckyCatDialog:removeParticles()
  for k,v in pairs(self.particleS) do
    v:removeFromParentAndCleanup(true)
  end
  self.particleS = nil
  self.addParticlesTs = nil
end

function acLuckyCatDialog:dispose( )
    self.costLabel = nil
    self.rewardBtn = nil

    self.bar = nil -- 右侧把手
    self.leftIcon = nil -- 把手左侧黄色的箭头图标
    self.rightIcon = nil -- 把手右侧黄色的箭头图标
    self.backSprie = nil -- 上方的背景
    self.downBgSp =nil
    self.lastSt = nil -- 上一次设置动画时间点（用于计算tick中设置动画播放时间间隔）
    self.lastIndex = nil -- 上一次把手上的黄色箭头在第几个位置
    
    self.turnSingleAreaH = nil -- 转动区域每个图标占的高度
    self.turnNum = nil -- 转动区域个数

    self.particleS = nil -- 粒子效果
    self.addParticlesTs = nil -- 添加粒子效果的时间
    self.playIds = nil -- 播放动画最终停止的位置

    self.selectBg = nil -- 播放动画最终获得物品的背景
    self.state = nil -- 0 正常 1 点击抽取 2 后台返回结果 3 动画播放结束

    self.spTb1=nil
    self.spTb2=nil
    self.spTb3=nil
    self.spTb4=nil
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
    self.moveDisNum=200

    self.desTv = nil -- 面板上的说明信息
    self.metalSpTable = nil -- 边框动画效果
    self.touchDialogBg = nil

    self.currentCanGetReward = nil
    self.lastMul = nil -- 抽取后后台返回的模式
    self.showTimeAndMone=nil
    self.currBySelfGold=nil
    self.currNeedGold=nil
    self.recordlist=nil
    self.pointNum =nil
    spriteController:removePlist("public/acLuckyCat.plist")  
end