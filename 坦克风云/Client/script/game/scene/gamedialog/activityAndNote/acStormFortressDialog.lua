acStormFortressDialog = commonDialog:new()

function acStormFortressDialog:new(layerNum)
	local nc = {}
	setmetatable(nc,self)
	self.__index = self
	
	spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
	self.layerNum =layerNum
	self.touchDialogBg =nil
	self.bgWidth=nil
	self.bgHeight=nil
	--按钮
	self.fortressPic1=nil
	self.fortressPic2=nil
	self.bombardBtn=nil
	self.attOneBtn=nil
	self.attTenBtn=nil
	self.freeBtn=nil
	self.bombardIcon =nil
	self.bombardNumsShow=nil -- 持有数量/开炮消耗的数量（恒量：1）
	self.OnceNeedGold =nil
	self.IconGoldInOne=nil
	self.IconGoldTen=nil
	self.tenNeedGold=nil
	self.isToday=nil
  self.isTaskRefToday=acStormFortressVoApi:isTaskRefTimeToday()
  self.getAwardBg=nil
  self.iconTip=nil
  self.BulletsDia =nil
  self.getAwardDia =nil
	return nc
end
function acStormFortressDialog:dispose()
  if self.BulletsDia ~=nil then
    self.BulletsDia:dispose(true)
    self.BulletsDia:close()
  end
  if self.getAwardDia then
    self.getAwardDia:close(true)
  end
	self.touchDialogBg =nil
	self.layerNum =nil
	self.bombardBtn=nil
	self.fortressPic1=nil
	self.fortressPic2=nil
	self.attOneBtn=nil
	self.attTenBtn=nil
	self.freeBtn=nil
	self.bombardIcon =nil
	self.bombardNumsShow=nil
	self.OnceNeedGold =nil
	self.IconGoldInOne=nil
	self.IconGoldTen=nil
	self.tenNeedGold=nil
	self.isToday=nil
  self.isTaskRefToday=nil
	self.bgLayer=nil
  self.iconTip=nil
  self.BulletsDia =nil
  self.getAwardBg=nil
  self.getAwardDia =nil
  self =nil
	
	spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
	spriteController:removeTexture("public/allianceWar2/allianceWar2.png")
end
function acStormFortressDialog:initTableView()
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 95))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))

  self.isToday = acStormFortressVoApi:isToday()
  local function noData() end
  self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),noData);
  self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
  local rect=CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-100)
  self.touchDialogBg:setContentSize(rect)
  self.touchDialogBg:setOpacity(0)
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
  self.touchDialogBg:setAnchorPoint(ccp(0.5,0))
  self.touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
  self.bgLayer:addChild(self.touchDialogBg,1)

  self.getAwardBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),noData);
  self.getAwardBg:setTouchPriority(-(self.layerNum-1)*20-10)
  local rect=CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-100)
  self.getAwardBg:setContentSize(rect)
  self.getAwardBg:setOpacity(200)
  self.getAwardBg:setIsSallow(false) -- 点击事件透下去
  self.getAwardBg:setAnchorPoint(ccp(0.5,0))
  self.getAwardBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
  self.bgLayer:addChild(self.getAwardBg,2)
  self.getAwardBg:setVisible(false)
  self.bgWidth = G_VisibleSizeWidth-20
  self.bgHeight =G_VisibleSizeHeight-100

  self:initUpDia()
  self:initDownDia()

  return self.bgLayer
end

function acStormFortressDialog:initUpDia( )
  local strSize2 = 22
  local posHeight2 = 0
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
    	strSize2 =27
      posHeight2 =30
  end
  local function noData() end
  local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),noData)
  backSprie:setContentSize(CCSizeMake(self.bgWidth-20, self.bgHeight*0.21))
  backSprie:setAnchorPoint(ccp(0.5,1))
  backSprie:setOpacity(0)
  backSprie:setPosition(ccp(self.bgWidth*0.5, self.bgHeight))
  self.touchDialogBg:addChild(backSprie)

  local bgWidth = backSprie:getContentSize().width
  local bgHeight = backSprie:getContentSize().height
  	local function touch(tag,object)
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		self:openInfo()
	end

	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp(bgWidth*0.5, bgHeight-2))
	acLabel:setColor(G_ColorYellow)
	backSprie:addChild(acLabel,1)

	local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,1,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,1))
	menuItemDesc:setScale(0.8)
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(bgWidth-15,bgHeight-5))
	backSprie:addChild(menuDesc,2)

	local acVo = acStormFortressVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,28)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp(bgWidth*0.5, bgHeight-35))
	backSprie:addChild(messageLabel,3)

    local isDied = acStormFortressVoApi:getIsDied()
    local upDec = "activity_stormFortress_Up_Dec1"-----------------------------------------
    if isDied ==1 then
    	upDec ="activity_stormFortress_Up_Dec2"
    end
	  local titleLb = GetTTFLabelWrap(getlocal(upDec),strSize2,CCSizeMake(bgWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  	titleLb:setAnchorPoint(ccp(0,1))
  	titleLb:setPosition(ccp(5,bgHeight-70-posHeight2))
  	backSprie:addChild(titleLb)

    if isDied ==1 then
      titleLb:setColor(G_ColorYellowPro)
    end

  	-- local fortressPic1 = CCSprite:createWithSpriteFrameName("panelItemBg.png")-------------------------要替图
  	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
   	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
   	self.fortressPic1=CCSprite:create("public/acStormFortressImage/stormFortressBg1.jpg")
   	self.fortressPic2=CCSprite:create("public/acStormFortressImage/stormFortressBg2.jpg")
   	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
   	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    self.fortressPic1:setAnchorPoint(ccp(0.5,0))
    self.fortressPic1:setScaleX((self.bgWidth-10)/self.fortressPic1:getContentSize().width)
    self.fortressPic1:setScaleY(self.bgHeight*0.3/self.fortressPic1:getContentSize().height)
    self.fortressPic1:setPosition(ccp(self.bgWidth*0.5, self.bgHeight*0.5+5))
    self.touchDialogBg:addChild(self.fortressPic1,1)

    self.fortressPic2:setAnchorPoint(ccp(0.5,0))
    self.fortressPic2:setScaleX((self.bgWidth-10)/self.fortressPic2:getContentSize().width)
    self.fortressPic2:setScaleY(self.bgHeight*0.3/self.fortressPic2:getContentSize().height)
    self.fortressPic2:setPosition(ccp(self.bgWidth*0.5, self.bgHeight*0.5+5))
    self.touchDialogBg:addChild(self.fortressPic2,1)

    local ALLhp = acStormFortressVoApi:getStormFortressHP( )
    local deHp = acStormFortressVoApi:getFortressHp( )
    if ALLhp*0.3<= deHp then
    	self.fortressPic1:setVisible(false)
    	self.fortressPic2:setVisible(true)
    else
    	self.fortressPic1:setVisible(true)
    	self.fortressPic2:setVisible(false)
    end
    local needHeight2 = 15
    if G_isIphone5() ==true then
        needHeight2 =68
    end
  local goldLine1=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
  goldLine1:setAnchorPoint(ccp(0.5,0))
	goldLine1:setPosition(ccp(self.bgWidth*0.5, self.fortressPic1:getPositionY()+self.fortressPic1:getContentSize().height+needHeight2))
	goldLine1:setScaleX((self.bgWidth+20)/self.fortressPic1:getContentSize().width)
    -- self.fortressPic1:setScaleY(self.bgHeight*0.3/self.fortressPic1:getContentSize().height)
	self.touchDialogBg:addChild(goldLine1,1)
	local goldLine2=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
	goldLine2:setAnchorPoint(ccp(0.5,1))
	goldLine2:setRotation(180)
	goldLine2:setPosition(ccp(self.bgWidth*0.5, self.fortressPic1:getPositionY()))
	goldLine2:setScaleX((self.bgWidth+20)/self.fortressPic1:getContentSize().width)
	self.touchDialogBg:addChild(goldLine2,1)
    -----------需要 添加爆炸粒子效果

    -----------需要添加进度条
    --ALLhp-deHp
  local isDied = acStormFortressVoApi:getIsDied()
  if isDied ==1 then
    deHp = ALLhp
    if deHp >=ALLhp then
      acStormFortressVoApi:setWillDied(true)
    end
  end
  local percentStr=(ALLhp-deHp).."/"..ALLhp
	local per = tonumber(ALLhp-deHp)/tonumber(ALLhp) * 100
	AddProgramTimer(self.touchDialogBg,ccp(self.bgWidth*0.5,goldLine2:getPositionY()+40),999,12,percentStr,"skillBg.png","skillBar.png",13,1.3,1)
  local timerSpriteLv = self.touchDialogBg:getChildByTag(999)
  timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
  timerSpriteLv:setPercentage(per)
	tolua.cast(timerSpriteLv:getChildByTag(12),"CCLabelTTF"):setString(percentStr)
	tolua.cast(timerSpriteLv:getChildByTag(12),"CCLabelTTF"):setScaleX(1/1.3)
end

function acStormFortressDialog:initDownDia( )
	
  local strSize2 = 22
  local strSize3 = 21
  local strPosHeight2 = 50
  if G_isIphone5() then
      strPosHeight2 =80
      strSize3 =23
  end
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" then
    	strSize2 =25
      strPosHeight2 =40
      strSize3 =23
  elseif G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="ru" then
      strSize3 =16
  end

  local function noData( ) end 
  local backSprie1 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),noData)
  backSprie1:setContentSize(CCSizeMake(self.bgWidth*0.5, self.bgHeight*0.24))
  backSprie1:setAnchorPoint(ccp(1,1))
  backSprie1:setPosition(ccp(self.bgWidth*0.5, self.bgHeight*0.5))
  self.touchDialogBg:addChild(backSprie1)

  local bgWidth = backSprie1:getContentSize().width
  local bgHeight = backSprie1:getContentSize().height

  local attOverLb = GetTTFLabelWrap(getlocal("activity_stormFortress_stormReward"),strSize2,CCSizeMake(bgWidth-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
  attOverLb:setAnchorPoint(ccp(0.5,1))
  attOverLb:setColor(G_ColorYellowPro)
  attOverLb:setPosition(ccp(bgWidth*0.5,bgHeight-15))
  backSprie1:addChild(attOverLb)

  ----------------------------------------需要格式化大奖图标
  local bigReward = acStormFortressVoApi:getBigReward( )
  for k,v in pairs(bigReward) do
  	-- print("v.name---->",v.name,v.pic,v.key)
  	local reward,scale = G_getItemIcon(v,100,true,self.layerNum+1)
  	reward:setAnchorPoint(ccp(0,1))
    reward:setTouchPriority(-(self.layerNum-1)*20-3)
  	reward:setPosition(ccp((k-1)*reward:getContentSize().width+35*k,bgHeight-55))
    backSprie1:addChild(reward)

    local numLabel=GetTTFLabel("x"..v.num,21)
    numLabel:setAnchorPoint(ccp(1,0))
    numLabel:setPosition(reward:getContentSize().width-5, 5)
    numLabel:setScale(1/scale)
    reward:addChild(numLabel,1)
  end

  local attOverLb2 = GetTTFLabelWrap(getlocal("activity_stormFortress_stromRewardLb"),strSize3,CCSizeMake(bgWidth-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
  attOverLb2:setAnchorPoint(ccp(0.5,1))
  -- attOverLb2:setColor(G_ColorYellowPro)
  attOverLb2:setPosition(ccp(bgWidth*0.5,strPosHeight2))
  backSprie1:addChild(attOverLb2)

  local function bgClick( )
  		-- print("bgClick----in bg2")
  		self:normRewardShow()---------弹板 需要展示普通奖励可获得的奖励
  end

  local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
  backSprie2:setContentSize(CCSizeMake(self.bgWidth*0.5, self.bgHeight*0.24))
  backSprie2:setAnchorPoint(ccp(0,1))
  backSprie2:setPosition(ccp(self.bgWidth*0.5, self.bgHeight*0.5))
  backSprie2:setTouchPriority(-(self.layerNum-1)*20-2)
  self.touchDialogBg:addChild(backSprie2)

  local attNormLb = GetTTFLabelWrap(getlocal("activity_stormFortress_stormNormReward"),strSize2,CCSizeMake(bgWidth-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
  attNormLb:setAnchorPoint(ccp(0.5,1))
  attNormLb:setColor(G_ColorYellowPro)
  attNormLb:setPosition(ccp(bgWidth*0.5,bgHeight-15))
  backSprie2:addChild(attNormLb)

  local normRewardTb = acStormFortressVoApi:getPoolReward( ) ----获取普通奖励库的前几个
  local showNums = 6--SizeOfTable(normRewardTb)---6
  local wI=0
  local hI=1
  if SizeOfTable(normRewardTb) > 0 then
	  for i=1,showNums do----默认6个 如果有需求 可修正
	  	if wI > showNums/2-1 then
	  		wI =0
	  		hI =0.55
	  	end
	  	local reward,scale = G_getItemIcon(normRewardTb[i],60,false,self.layerNum+1)
      reward:setScale(65/reward:getContentSize().width)
	  	reward:setAnchorPoint(ccp(0,1))
	  	reward:setPosition(ccp(wI*75+45,hI*(bgHeight-50)))
      backSprie2:addChild(reward)
	  	wI =wI+1

      local numLabel=GetTTFLabel("x"..normRewardTb[i].num,21)
      numLabel:setAnchorPoint(ccp(1,0))
      numLabel:setPosition(reward:getContentSize().width-5, 5)
      numLabel:setScale(1/scale)
      reward:addChild(numLabel,1)
	  end
  end
   
  local backSprie3 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),noData)
  backSprie3:setContentSize(CCSizeMake(self.bgWidth, self.bgHeight*0.12))
  backSprie3:setAnchorPoint(ccp(0.5,1))
  backSprie3:setOpacity(0)
  backSprie3:setPosition(ccp(self.bgWidth*0.5, self.bgHeight*0.28))
  self.touchDialogBg:addChild(backSprie3)

  local function bulletsShow(tag,object)
  	self:bulletsShow()--弹药库展示
  end
  -- local menuItemDesc=GetButtonItem("RechargeBg.png","RechargeBgSelect.png","RechargeBg.png",bulletsShow,nil,nil,0)
  local menuItemDesc = GetButtonItem("acNewYearFadeLight.png","acNewYearFadeLight.png","acNewYearFadeLight.png",bulletsShow,nil,nil,0)
  menuItemDesc:setAnchorPoint(ccp(0.5,0.5))
  menuItemDesc:setScaleX(self.bgWidth/menuItemDesc:getContentSize().width)
  menuItemDesc:setScaleY(self.bgHeight*0.12*0.8/menuItemDesc:getContentSize().height)
  local menuDesc=CCMenu:createWithItem(menuItemDesc)
  menuDesc:setTouchPriority(-(self.layerNum-1)*20-3)
  menuDesc:setPosition(ccp(backSprie3:getContentSize().width*0.5,backSprie3:getContentSize().height*0.4))
  backSprie3:addChild(menuDesc)

  local getBulletsLb = GetTTFLabelWrap(getlocal("activity_stormFortress_bulletGetLabl"),strSize2,CCSizeMake(bgWidth-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  getBulletsLb:setAnchorPoint(ccp(0.5,0.5))
  getBulletsLb:setPosition(ccp(backSprie3:getContentSize().width*0.5,backSprie3:getContentSize().height*0.4))
  backSprie3:addChild(getBulletsLb)


  self.iconTip = CCSprite:createWithSpriteFrameName("IconTip.png")
  self.iconTip:setAnchorPoint(ccp(0.5,0.5))
  self.iconTip:setPosition(ccp(backSprie3:getContentSize().width*0.68,backSprie3:getContentSize().height*0.52))
  backSprie3:addChild(self.iconTip)
  self.iconTip:setVisible(false)

  local allNumsTb=acStormFortressVoApi:getTaskAllTb( )
  local taskRecedTb=acStormFortressVoApi:getTaskRecedTb()
  if taskRecedTb and SizeOfTable(taskRecedTb)>0 then
    for i=1,SizeOfTable(allNumsTb) do
      -- print("---init----->",taskRecedTb["t"..i],allNumsTb["t"..i][1])
      if taskRecedTb["t"..i] and taskRecedTb["t"..i] >= allNumsTb["t"..i][1] then
        self.iconTip:setVisible(true)
        do break end
      end
      self.iconTip:setVisible(false)
    end
  end
	local function getReward(tag,object)
		-- print("tag----->",tag)
		self:getReward(tag,object)
	end 
	local isShowBtnTb = {0,0,0,0}--------4个按钮显示判断值 :setEnabled(false)
	local needBullet = acStormFortressVoApi:getNeedBullet( )
	local currBullet = acStormFortressVoApi:getCurrentBullet( )
	local costOneInGold = acStormFortressVoApi:getOneCostNeedGold( )
	local costTenInGold = acStormFortressVoApi:getTenCostNeedGold()
	local playerHasGold = playerVoApi:getGems()
	if currBullet >=needBullet then
		isShowBtnTb[1] = 1
	end
	if playerHasGold >=costOneInGold then
    -- print("playerHasGold,costOneInGold---",playerHasGold,costOneInGold)
		isShowBtnTb[2] =1
	end
	if playerHasGold >=costTenInGold then
		isShowBtnTb[3] =1
	end
	if self.isToday ==false or (self.isToday==true and acStormFortressVoApi:getFN() ==0)then
		isShowBtnTb[4] =1
	end
	local btnNeedHeight = 0
  local thisStrSize = strSize2
  if G_getCurChoseLanguage() =="de" then
    thisStrSize =18
  end
	local bombardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",getReward,nil,getlocal("activity_stormFortress_bombardLabelBtn"),thisStrSize)
	bombardBtn:setAnchorPoint(ccp(0.5,0.5))
	bombardBtn:setTag(111)
	self.bombardBtn=bombardBtn
	local bombardBtnMenu=CCMenu:createWithItem(bombardBtn);
	bombardBtnMenu:setTouchPriority(-(self.layerNum-1)*20-3);
	bombardBtnMenu:setPosition(ccp(self.bgWidth*0.2,self.bgHeight*0.1+btnNeedHeight))
	bombardBtnMenu:setTag(111)
	self.touchDialogBg:addChild(bombardBtnMenu)
	if isShowBtnTb[1] ==0 then
		bombardBtn:setEnabled(false)
	end

	self.bombardIcon=CCSprite:createWithSpriteFrameName("dartPic.png")-------------缺炮弹图片
	self.bombardIcon:setAnchorPoint(ccp(0,0.5))
	self.bombardIcon:setPosition(ccp(self.bgWidth*0.22,self.bgHeight*0.03))
	self.touchDialogBg:addChild(self.bombardIcon)
	------------------------------持有数量/开炮消耗的数量（恒量：1）
	self.bombardNumsShow =GetTTFLabelWrap(getlocal("scheduleChapter",{currBullet,needBullet}),23,CCSizeMake(50,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
	self.bombardNumsShow:setAnchorPoint(ccp(1,0.5))
	self.bombardNumsShow:setColor(G_ColorYellowPro)
	self.bombardNumsShow:setPosition(ccp(self.bombardIcon:getPositionX(),self.bombardIcon:getPositionY()))
	self.touchDialogBg:addChild(self.bombardNumsShow)


	local attOneBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",getReward,nil,getlocal("activity_stormFortress_singleAttBtn"),strSize2)
	attOneBtn:setAnchorPoint(ccp(0.5,0.5))
	attOneBtn:setTag(112)
	self.attOneBtn=attOneBtn
	local attOneBtnMenu=CCMenu:createWithItem(attOneBtn);
	attOneBtnMenu:setTouchPriority(-(self.layerNum-1)*20-3);
	attOneBtnMenu:setPosition(ccp(self.bgWidth*0.5,self.bgHeight*0.1+btnNeedHeight))
	attOneBtnMenu:setTag(112)
	self.touchDialogBg:addChild(attOneBtnMenu)
	if isShowBtnTb[2] ==0 then
		attOneBtn:setEnabled(false)
	end

	self.IconGoldInOne=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.IconGoldInOne:setAnchorPoint(ccp(0,0.5))
	self.IconGoldInOne:setPosition(ccp(self.bgWidth*0.52,self.bgHeight*0.03))
	self.touchDialogBg:addChild(self.IconGoldInOne)
	---------------------------------需要单抽金币数量
	self.OnceNeedGold =GetTTFLabelWrap(costOneInGold,23,CCSizeMake(50,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
	self.OnceNeedGold:setAnchorPoint(ccp(1,0.5))
	self.OnceNeedGold:setColor(G_ColorYellowPro)
	self.OnceNeedGold:setPosition(ccp(self.IconGoldInOne:getPositionX(),self.IconGoldInOne:getPositionY()))
	self.touchDialogBg:addChild(self.OnceNeedGold)


  local attTenBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",getReward,nil,getlocal("activity_stormFortress_TenAttBtn"),strSize2)
	attTenBtn:setAnchorPoint(ccp(0.5,0.5))
	attTenBtn:setTag(113)
	self.attTenBtn=attTenBtn
	local attTenBtnMenu=CCMenu:createWithItem(attTenBtn);
	attTenBtnMenu:setTouchPriority(-(self.layerNum-1)*20-3);
	attTenBtnMenu:setPosition(ccp(self.bgWidth*0.8,self.bgHeight*0.1+btnNeedHeight))
	attTenBtnMenu:setTag(113)
	self.touchDialogBg:addChild(attTenBtnMenu)
	if isShowBtnTb[3] ==0 then
		attTenBtn:setEnabled(false)
	end

	self.IconGoldTen=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.IconGoldTen:setAnchorPoint(ccp(0,0.5))
	self.IconGoldTen:setPosition(ccp(self.bgWidth*0.82,self.bgHeight*0.03))
	self.touchDialogBg:addChild(self.IconGoldTen)
	---------------------------------需要十连抽金币数量
	self.tenNeedGold =GetTTFLabelWrap(costTenInGold,23,CCSizeMake(50,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
	self.tenNeedGold:setAnchorPoint(ccp(1,0.5))
	self.tenNeedGold:setColor(G_ColorYellowPro)
	self.tenNeedGold:setPosition(ccp(self.IconGoldTen:getPositionX(),self.IconGoldTen:getPositionY()))
	self.touchDialogBg:addChild(self.tenNeedGold)


	--free
	local freeBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",getReward,nil,getlocal("activity_stormFortress_freeAttBtn"),strSize2)
	freeBtn:setAnchorPoint(ccp(0.5,0.5))
	freeBtn:setTag(114)
	self.freeBtn=freeBtn
	local freeBtnMenu=CCMenu:createWithItem(freeBtn);
	freeBtnMenu:setTouchPriority(-(self.layerNum-1)*20-3);
	freeBtnMenu:setPosition(ccp(self.bgWidth*0.5,self.bgHeight*0.1+btnNeedHeight))
	freeBtnMenu:setTag(114)
	self.touchDialogBg:addChild(freeBtnMenu)
  -- print("isShowBtnTb[2]--->",isShowBtnTb[2])
	if isShowBtnTb[4] ==0 then
		freeBtn:setEnabled(false)
    freeBtn:setVisible(false)
		if isShowBtnTb[2] ==1 then
			attOneBtn:setEnabled(true)
    else
      self.OnceNeedGold:setColor(G_ColorRed)
		end
		if isShowBtnTb[3] ==1 then
			attTenBtn:setEnabled(true)
    else
      self.tenNeedGold:setColor(G_ColorRed)
		end
		if isShowBtnTb[1] ==1 then
			bombardBtn:setEnabled(true)
    else
      self.bombardNumsShow:setColor(G_ColorRed)
		end
	else
		attOneBtn:setEnabled(false)
		self.IconGoldInOne:setVisible(false)
		self.OnceNeedGold:setVisible(false)

		attTenBtn:setEnabled(false)
		self.IconGoldTen:setVisible(false)
		self.tenNeedGold:setVisible(false)

		bombardBtn:setEnabled(false)
		self.bombardIcon:setVisible(false)
		self.bombardNumsShow:setVisible(false)
	end
end

function acStormFortressDialog:getReward(tag,object)
	-- print("tag----->",tag)
	local choseNum = tag-110
  local needMoney,myAllMoney
	local paramTb = {} ---1-4 :action(1为金币抽奖 2为道具抽奖 3为领取任务奖励导弹 ),num(抽奖次数),free(是否免费抽奖，不是就别传这个参数),taskid(要领取奖励的任务ID)
  local isDied = acStormFortressVoApi:getIsDied()
	 if tag ==111 then --巨炮打击  使用道具
		paramTb ={2,1,nil,nil}
    needMoney = acStormFortressVoApi:getNeedBullet( )
    myAllMoney = acStormFortressVoApi:getCurrentBullet( )
   elseif tag ==112 then --单次 金币
   	paramTb ={1,1,nil,nil}
    needMoney =acStormFortressVoApi:getOneCostNeedGold( )
    myAllMoney = playerVoApi:getGems()
   elseif tag ==113 then --十次
   	paramTb ={1,10,nil,nil}
    myAllMoney =playerVoApi:getGems()
    needMoney =acStormFortressVoApi:getTenCostNeedGold()
   elseif tag ==114 then --免费
   	paramTb ={1,1,1,nil}
    needMoney =0
    myAllMoney=playerVoApi:getGems()
   end
  	 if SizeOfTable(paramTb) >0 then
  	 	local function callback(fn,data)
	    	local ret,sData = base:checkServerData(data)
	        if ret==true then
              if choseNum==1 then
                acStormFortressVoApi:setCurrentBullet(myAllMoney-needMoney )
              else
                playerVoApi:setGems(myAllMoney - needMoney )
              end
		        	if sData and sData.data and sData.data.stormFortress and sData.data.stormFortress.info then
		        		local info = sData.data.stormFortress.info
		        		acStormFortressVoApi:updateLastTime(info.t)--刷新最后一次时间
		        		acStormFortressVoApi:setCurrentBullet(info.missile)--重置炮弹数量
                acStormFortressVoApi:setFortressHp(info.deHp) --击破的总血量
                acStormFortressVoApi:setIsDied(info.destroyed) --是否死亡
                acStormFortressVoApi:setNowRewardTb(sData.data.stormFortress.report)
                acStormFortressVoApi:setFN(1)
                if info.destroyed ~=nil and  isDied ~= info.destroyed then
                        local bigAwardTb = acStormFortressVoApi:getBigReward()
                        strs = G_showRewardTip(bigAwardTb,false,true)
                        local message={key="chatSystemMessage13",param={playerVoApi:getPlayerName(),getlocal("activity_stormFortress_title"),strs,""}}
                        chatVoApi:sendSystemMessage(message)
                end
                if isDied ==1 then
                  acStormFortressVoApi:setWillDied(true)
                end
                self.getAwardDia=acStormFortressGetRewardDialog:new(self.layerNum + 1,self,choseNum)
                local dialog= self.getAwardDia:init(nil)
	              self:refresh()
                acStormFortressVoApi:updateShow()
                self.getAwardBg:setVisible(true)
	            end
	        end
	    end
  	 	socketHelper:stormFortressSock(callback,paramTb[1],paramTb[2],paramTb[3],paramTb[4] )
  	 end

 	  
end

function acStormFortressDialog:refresh( )
	
	local isShowBtnTb = {0,0,0,0}--------4个按钮显示判断值 :setEnabled(false)
  local needBullet = acStormFortressVoApi:getNeedBullet( )
	local currBullet = acStormFortressVoApi:getCurrentBullet( )
	local costOneInGold = acStormFortressVoApi:getOneCostNeedGold( )
	local costTenInGold = acStormFortressVoApi:getTenCostNeedGold()
	local playerHasGold = playerVoApi:getGems()
  self.isToday =acStormFortressVoApi:isToday()
  local isDied = acStormFortressVoApi:getIsDied()

-----
	local ALLhp = acStormFortressVoApi:getStormFortressHP( )
  local deHp = acStormFortressVoApi:getFortressHp( )
  if isDied ==1 then
    deHp = ALLhp
  end
	local percentStr=(ALLhp-deHp).."/"..ALLhp
	local per = tonumber((ALLhp-deHp))/tonumber(ALLhp) * 100
	local timerSpriteLv = self.touchDialogBg:getChildByTag(999)
	timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
  timerSpriteLv:setPercentage(per)
	tolua.cast(timerSpriteLv:getChildByTag(12),"CCLabelTTF"):setString(percentStr)

    if ALLhp*0.3<= deHp then
      self.fortressPic1:setVisible(false)
      self.fortressPic2:setVisible(true)
    else
      self.fortressPic1:setVisible(true)
      self.fortressPic2:setVisible(false)
    end

-----
	if currBullet >=needBullet then
		isShowBtnTb[1] = 1
	end
	if playerHasGold >=costOneInGold then
		isShowBtnTb[2] =1
	end
	if playerHasGold >=costTenInGold then
		isShowBtnTb[3] =1
	end
	if self.isToday ==false or (self.isToday==true and acStormFortressVoApi:getFN() ==0)then
		isShowBtnTb[4] =1
	end

	if isShowBtnTb[4] ==0 then--不是免费的情况下
		self.freeBtn:setEnabled(false)
		self.freeBtn:setVisible(false)

		if isShowBtnTb[2] ==1 then
			self.attOneBtn:setEnabled(true)
			self.OnceNeedGold:setColor(G_ColorYellowPro)
		else
			self.attOneBtn:setEnabled(false)
			self.OnceNeedGold:setColor(G_ColorRed)
		end
		self.IconGoldInOne:setVisible(true)
		self.OnceNeedGold:setVisible(true)

		if isShowBtnTb[3] ==1 then
			self.attTenBtn:setEnabled(true)
			self.tenNeedGold:setColor(G_ColorYellowPro)
		else
			self.attTenBtn:setEnabled(false)
			self.tenNeedGold:setColor(G_ColorRed)
		end
		self.IconGoldTen:setVisible(true)
		self.tenNeedGold:setVisible(true)

		if isShowBtnTb[1] ==1 then
			self.bombardBtn:setEnabled(true)
			self.bombardNumsShow:setColor(G_ColorYellowPro)
		else
			self.bombardBtn:setEnabled(false)
			self.bombardNumsShow:setColor(G_ColorRed)
		end
		self.bombardIcon:setVisible(true)
		self.bombardNumsShow:setVisible(true)

    self.bombardNumsShow:setString(getlocal("scheduleChapter",{currBullet,needBullet}))
	else
		self.freeBtn:setEnabled(true)
		self.freeBtn:setVisible(true)

		self.attOneBtn:setEnabled(false)
		self.IconGoldInOne:setVisible(false)
		self.OnceNeedGold:setVisible(false)

		self.attTenBtn:setEnabled(false)
		self.IconGoldTen:setVisible(false)
		self.tenNeedGold:setVisible(false)

		self.bombardBtn:setEnabled(false)
		self.bombardIcon:setVisible(false)
		self.bombardNumsShow:setVisible(false)
	end

  local allNumsTb=acStormFortressVoApi:getTaskAllTb( )
  local taskRecedTb=acStormFortressVoApi:getTaskRecedTb()
  if taskRecedTb and SizeOfTable(taskRecedTb)>0 then
    for i=1,SizeOfTable(allNumsTb) do
      -- print("-----ref--->",taskRecedTb["t"..i],allNumsTb["t"..i][1])
      if taskRecedTb["t"..i] and taskRecedTb["t"..i] >= allNumsTb["t"..i][1] then
        self.iconTip:setVisible(true)
        do break end
      end
      self.iconTip:setVisible(false)
    end
  end
end

function acStormFortressDialog:tick( )
  local vo=acStormFortressVoApi:getAcVo()
  if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self then
          self:close()
          do return end
      end
  end
	-- print("tick~~~~~~")
	if acStormFortressVoApi:isToday() ~= self.isToday then --不是免费情况
		self.isToday =acStormFortressVoApi:isToday()
		self:refresh()
    if acStormFortressVoApi:isToday() ==false and self.getAwardDia ~=nil then
      self.getAwardDia.againItem:setEnabled(false)
    end
	end
  -- print("self.isTaskRefToday ~=acStormFortressVoApi:isTaskRefTimeToday()",self.isTaskRefToday ,acStormFortressVoApi:isTaskRefTimeToday())
  if self.isTaskRefToday ~=acStormFortressVoApi:isTaskRefTimeToday() then
     self.isTaskRefToday =acStormFortressVoApi:isTaskRefTimeToday()
  end
   if self.isTaskRefToday ==false and SizeOfTable(acStormFortressVoApi:getTaskRecedTb( ))>0 then
    -- print("self.isTaskRefToday---------SizeOfTable(acStormFortressVoApi:getTaskRecedTb( ))>0---->",self.isTaskRefToday,SizeOfTable(acStormFortressVoApi:getTaskRecedTb( )))
     self.iconTip:setVisible(false)
     acStormFortressVoApi:setTaskRecedTb(nil)
     
      if self.BulletsDia and self.BulletsDia.tv then
        self.isTaskRefToday =true
        self.BulletsDia.taskRecedTb={}
        self.BulletsDia.tv:reloadData()
      end
   end

  if acStormFortressVoApi:getIsMissile() ==true then
    -- self.iconTip:setVisible(true)
    if self.BulletsDia and self.BulletsDia.tv then
      self.BulletsDia.tv:reloadData()
    end
    acStormFortressVoApi:updateMissile(false,base.serverTime)
  end
end


function acStormFortressDialog:normRewardShow( )
	-- local normRewardTb = {} ------------------------------------取到攻击奖励
	local sd=acStormFortressRewardDialog:new(self.layerNum + 1)
  local dialog= sd:init(nil)
end

function acStormFortressDialog:bulletsShow( )
	self.BulletsDia = acStormFortressBulletsDialog:new(self);
	local vd = self.BulletsDia:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("activity_stormFortress_getBulletsTitle"),true,self.layerNum + 1)       
	sceneGame:addChild(vd,self.layerNum + 1);
end

function acStormFortressDialog:openInfo( )--
	   
   local sd=smallDialog:new()
   local labelTab={"\n",getlocal("activity_stormFortress_labelIn_i2"),"\n",getlocal("activity_stormFortress_labelIn_i1",{acStormFortressVoApi:getPicPrice( )}),"\n"}
   local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,nil,getlocal("dialog_title_prompt"))
   sceneGame:addChild(dialogLayer,self.layerNum+1)
   dialogLayer:setPosition(ccp(0,0))
end