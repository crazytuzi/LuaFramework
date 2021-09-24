
moscowGamblingGaiDialog=commonDialog:new()

function moscowGamblingGaiDialog:new()
    local nc=commonDialog:new()
    setmetatable(nc,self)
    self.__index=self
	
	self.characterSp=nil
	self.descBg=nil
	self.descLabel=nil
	self.rewardBg=nil
	self.tankPic=nil
	self.isMoving=nil
	self.goldSp1=nil
	self.goldSp2=nil
	self.gemsLabel1=nil
	self.gemsLabel2=nil
	self.lotteryOneBtn=nil
	self.lotteryTenBtn=nil
	self.make1Btn=nil
	self.make2Btn=nil
	self.tank1progress=nil
	self.tank2progress=nil
	self.pieceSp1=nil
	self.pieceSp2=nil
	self.tank1Label=nil
	self.tank2Label=nil
	self.selectedBox=nil
	self.lightSp=nil
	self.tanksName={}
	self.isToday=nil
	self.choseTicknum=1
	self.vipLevel=nil
	self.vippIcon=nil
    return nc
end
function moscowGamblingGaiDialog:initTableView( )
	require "luascript/script/game/scene/tank/tankAnimationBySelf"
	self.version=acMoscowGamblingGaiVoApi:getVersion()
	local  panelBgHeight = G_VisibleSize.height-110
	self.vipLevel = playerVoApi:getVipLevel()
	self.price1=acMoscowGamblingGaiVoApi:getGemOneCost()
	self.panelLineBg:setAnchorPoint(ccp(0,0))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSize.width-40,panelBgHeight))
	self.panelLineBg:setPosition(ccp(20,20))

	self:initUp()
	self:initMiddle()
	self:initDown()

	self.tanksName =acMoscowGamblingGaiVoApi:getTanks()
	local space1 = ccp(self.panelLineBg:getContentSize().width*0.2,self.panelLineBg:getContentSize().height*0.4-40)
	self.tankAni1 =tankAnimationBySelf:new(self.tanksName[1],1,space1,1,self.layerNum)
	self.panelLineBg:addChild(self.tankAni1.container,2)
	local space2 = ccp(self.panelLineBg:getContentSize().width*0.8,self.panelLineBg:getContentSize().height*0.4-40)
	self.tankAni2 = tankAnimationBySelf:new(self.tanksName[2],1,space2,2,self.layerNum)
	self.panelLineBg:addChild(self.tankAni2.container,2)

    self.lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    self.lightSp:setAnchorPoint(ccp(0.5,0.5))
    self.lightSp:setPosition(ccp(self.panelLineBg:getContentSize().width*0.5,self.backSprie:getPositionY()-self.backSprie:getContentSize().height*0.5))
    self.panelLineBg:addChild(self.lightSp,1)
    self.lightSp:setScale(0.6)
	self.lightSp:setVisible(false)
end

function moscowGamblingGaiDialog:initUp( )
	self.animationBg = CCSprite:create("scene/cityR2_mi.jpg")
	self.animationBg:setScaleX((self.panelLineBg:getContentSize().width-6)/self.animationBg:getContentSize().width)
	self.animationBg:setScaleY(self.panelLineBg:getContentSize().height*0.3/self.animationBg:getContentSize().height)
	self.animationBg:setAnchorPoint(ccp(0.5,1))
	self.animationBg:setPosition(ccp(self.panelLineBg:getContentSize().width*0.5,self.panelLineBg:getContentSize().height-5))
	self.panelLineBg:addChild(self.animationBg)

	local firstBorder = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
	firstBorder:setScaleX((self.panelLineBg:getContentSize().width-2)/firstBorder:getContentSize().width)
	firstBorder:setScaleY((self.panelLineBg:getContentSize().height*0.3+4)/firstBorder:getContentSize().height)
	firstBorder:setAnchorPoint(ccp(0.5,1))
	firstBorder:setPosition(ccp(self.panelLineBg:getContentSize().width*0.5,self.panelLineBg:getContentSize().height-3))
	self.panelLineBg:addChild(firstBorder)

	local function touch()
	end
	local capInSet = CCRect(20, 20, 10, 10)
    self.descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
    self.descBg:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width*0.7+50, self.panelLineBg:getContentSize().height*0.2-50))
    self.descBg:setAnchorPoint(ccp(0,1))
    self.descBg:setPosition(ccp(self.panelLineBg:getContentSize().width*0.2,self.panelLineBg:getContentSize().height-120))
    self.panelLineBg:addChild(self.descBg)

	local upLb = getlocal("active_lottery_desc")
	local desTv, desLabel = G_LabelTableView(CCSizeMake(self.descBg:getContentSize().width*0.6, self.descBg:getContentSize().height*0.8),upLb,25,kCCTextAlignmentLeft)
	self.descBg:addChild(desTv)
	desTv:setPosition(ccp(self.descBg:getContentSize().width*0.3,20))
	desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(100)
	desLabel:setColor(G_ColorGreen)

	local girlPosH
	if(G_isIphone5())then
		self.girlHeight=250
		girlPosH=self.panelLineBg:getContentSize().height-70
	else
		self.girlHeight=210
		girlPosH=self.panelLineBg:getContentSize().height-55
	end
    local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
	girlImg:setScale(self.girlHeight/girlImg:getContentSize().height)
	girlImg:setAnchorPoint(ccp(0.5,1))
	girlImg:setPosition(ccp(self.panelLineBg:getContentSize().width*0.2,girlPosH))
	self.panelLineBg:addChild(girlImg)

	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp((self.panelLineBg:getContentSize().width - 20)*0.5, self.panelLineBg:getContentSize().height-10))
	self.panelLineBg:addChild(acLabel)
	acLabel:setColor(G_ColorGreen)

	local acVo = acMoscowGamblingGaiVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,25)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp((self.panelLineBg:getContentSize().width - 20)*0.5, self.panelLineBg:getContentSize().height-40))
	self.panelLineBg:addChild(messageLabel)
	self.timeLb=messageLabel
	G_updateActiveTime(acVo,self.timeLb)

	local function tipTouch()
		local ver = acMoscowGamblingGaiVoApi:getVersion()
        local sd=smallDialog:new()
        local labelTab={"\n",getlocal("moscowGamblingGai_desc_1_4"),"\n",getlocal("moscowGamblingGai_desc_1_3"),"\n",getlocal("moscowGamblingGai_desc_1_2"),"\n",getlocal("moscowGamblingGai_desc_"..tostring(ver).."_1"),"\n",}
        local colorTab={nil,G_ColorRed,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro}
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(580,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,colorTab,nil,true)
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
    tipItem:setScale(1)
    local tipMenu = CCMenu:createWithItem(tipItem)
    tipMenu:setPosition(ccp(self.panelLineBg:getContentSize().width-50,self.panelLineBg:getContentSize().height-65))
    tipMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.panelLineBg:addChild(tipMenu,1)
end

function moscowGamblingGaiDialog:initMiddle( )
	local function bgClick()
	end
	self.backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
	self.backSprie:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width-8,self.panelLineBg:getContentSize().height*0.2+20))
	self.backSprie:setAnchorPoint(ccp(0.5,1))
	self.backSprie:setPosition(ccp(self.panelLineBg:getContentSize().width*0.5,self.panelLineBg:getContentSize().height*0.7-6))
	self.panelLineBg:addChild(self.backSprie)
	local function cellClick(hd,fn,idx)
	end	
	self.rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationAwardsBox.png",CCRect(40, 40, 1, 1),cellClick)
	self.rewardBg:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width-4,self.panelLineBg:getContentSize().height*0.2+20))
	self.rewardBg:ignoreAnchorPointForPosition(false)
	self.rewardBg:setAnchorPoint(ccp(0.5,1))
	self.rewardBg:setIsSallow(false)
	self.rewardBg:setTouchPriority(-(self.layerNum-1)*20-2)
	self.backSprie:addChild(self.rewardBg)
	self.rewardBg:setPosition(ccp(self.panelLineBg:getContentSize().width*0.5-4,self.backSprie:getContentSize().height))

	local function touch1(hd,fn,idx)
	end 
	self.vippIcon=LuaCCScale9Sprite:createWithSpriteFrameName("VipIconYellow.png",CCRect(110, 60, 1, 1),touch1)
  	--self.vippIcon:setContentSize(CCSizeMake(150,74))
  	self.vippIcon:setScale(0.8)
  	if G_getCurChoseLanguage() =="en" then
  		self.vippIcon:setScaleX(1.5)
  		self.vippIcon:setScaleY(1)
  	end
    self.vippIcon:setAnchorPoint(ccp(0.5,0.5))
    self.vippIcon:setPosition(ccp(self.backSprie:getContentSize().width*0.5,self.backSprie:getContentSize().height-10))
    self.backSprie:addChild(self.vippIcon,1)

    local vipNum =30
  	-- if G_getCurChoseLanguage() =="en" then
  	-- 	vipNum =20
  	-- end
   	local vipLevel=GetTTFLabel(getlocal("VIPStr1",{self.vipLevel}),vipNum)
	vipLevel:setAnchorPoint(ccp(0.5,0.5))
	vipLevel:setPosition(ccp(self.backSprie:getContentSize().width*0.5,self.backSprie:getContentSize().height-10))
	--vipLevel:setPosition(ccp(self.vippIcon:getContentSize().width*0.5,self.vippIcon:getContentSize().height*0.5))
	self.backSprie:addChild(vipLevel,1)
	vipLevel:setColor(G_ColorYellow)


------
	self.backSprieHeight =self.backSprie:getContentSize().height
	self.iconGold1=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.iconGold1:setAnchorPoint(ccp(0.5,0))
	self.iconGold1:setPosition(ccp(100,self.backSprieHeight/2+10))
	self.backSprie:addChild(self.iconGold1)
	self.iconGold1:setVisible(false)

	self.iconGold3=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.iconGold3:setAnchorPoint(ccp(0.5,0))
	self.iconGold3:setPosition(ccp(100,self.backSprieHeight/2+50))
	self.backSprie:addChild(self.iconGold3)
	self.iconGold3:setVisible(false)

	local price1=self.price1  ------
	self.price1Lb=GetTTFLabel(price1,25)
	self.price1Lb:setAnchorPoint(ccp(0,0))
	self.price1Lb:setPosition(ccp(130,self.backSprieHeight/2+10))
	self.backSprie:addChild(self.price1Lb)
	self.price1Lb:setColor(G_ColorRed)
	self.price1Lb:setVisible(false)

    self.line1 = CCSprite:createWithSpriteFrameName("redline.jpg")
    self.line1:setScaleX(8)
    self.line1:setAnchorPoint(ccp(0,0.5))
    self.line1:setPosition(ccp(130,self.backSprieHeight/2+20))
    self.backSprie:addChild(self.line1,2)
    self.line1:setVisible(false)

	local price3 = price1-self.vipLevel
	self.price3Lb=GetTTFLabel(price3,25)
	self.price3Lb:setAnchorPoint(ccp(0,0))
	self.price3Lb:setPosition(ccp(130,self.backSprieHeight/2+50))
	self.backSprie:addChild(self.price3Lb)
	self.price3Lb:setColor(G_ColorYellow)
	self.price3Lb:setVisible(false)

	self.iconGold2=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.iconGold2:setAnchorPoint(ccp(0.5,0))
	self.iconGold2:setPosition(ccp(440,self.backSprieHeight/2+10))
	self.backSprie:addChild(self.iconGold2)
	self.iconGold2:setVisible(false)

	self.iconGold4=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.iconGold4:setAnchorPoint(ccp(0.5,0))
	self.iconGold4:setPosition(ccp(440,self.backSprieHeight/2+50))
	self.backSprie:addChild(self.iconGold4)
	self.iconGold4:setVisible(false)

	local price2 = self.price1*9-14
	self.price2Lb=GetTTFLabel(price2,25)
	self.price2Lb:setAnchorPoint(ccp(0,0))
	self.price2Lb:setPosition(ccp(470,self.backSprieHeight/2+10))
	self.backSprie:addChild(self.price2Lb)
	self.price2Lb:setColor(G_ColorRed)
	self.price2Lb:setVisible(false)

    self.line3 = CCSprite:createWithSpriteFrameName("redline.jpg")
    self.line3:setScaleX(9)
    self.line3:setAnchorPoint(ccp(0,0.5))
    self.line3:setPosition(ccp(470,self.backSprieHeight/2+20))
    self.backSprie:addChild(self.line3,2)
    self.line3:setVisible(false)

	local price4 = (self.price1-self.vipLevel)*9-14-----
	self.price4Lb=GetTTFLabel(price4,25)
	self.price4Lb:setAnchorPoint(ccp(0,0))
	self.price4Lb:setPosition(ccp(470,self.backSprieHeight/2+50))
	self.backSprie:addChild(self.price4Lb)
	self.price4Lb:setColor(G_ColorYellow)
	self.price4Lb:setVisible(false)

	self.selectedBox=CCSprite:createWithSpriteFrameName("SeniorBox.png")
    self.selectedBox:setAnchorPoint(ccp(0.5,0.5))
    self.selectedBox:setPosition(ccp(self.backSprie:getContentSize().width*0.5,self.backSprie:getContentSize().height*0.5-30))
    self.backSprie:addChild(self.selectedBox)

    local leftPosX=self.backSprie:getContentSize().width/2-180
    local rightPosX=self.backSprie:getContentSize().width/2+180

    local function btnCallback( tag,object)
    	self:btnCallback(tag,object)
    end
	self.lotteryOneBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,1,getlocal("active_lottery_btn1"),25,333)
	self.lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
	self.lotteryOneBtn:setScaleX(0.7)
	local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn)
	lotteryMenu:setPosition(ccp(leftPosX,60))
	lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-5)
	self.backSprie:addChild(lotteryMenu,2)
	tolua.cast(self.lotteryOneBtn:getChildByTag(333),"CCLabelTTF"):setScaleX(1/0.8)

	local tenBtnStrSize = 25
	if G_getCurChoseLanguage() =="de" then
		tenBtnStrSize =20
	end
	self.lotteryTenBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",btnCallback,2,getlocal("active_lottery_btn2"),tenBtnStrSize,334)
    self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
    self.lotteryTenBtn:setScaleX(0.7)
    local lotteryMenu1=CCMenu:createWithItem(self.lotteryTenBtn)
    lotteryMenu1:setPosition(ccp(rightPosX,60))
    lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-5)
    self.backSprie:addChild(lotteryMenu1,2)
   	tolua.cast(self.lotteryTenBtn:getChildByTag(334),"CCLabelTTF"):setScaleX(1/0.8)
   	self.lotteryTenBtn:setEnabled(false)
end

function moscowGamblingGaiDialog:initDown( )
	local function bgClick()
	end
	self.backSprieDown = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
	self.backSprieDown:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width-8,self.panelLineBg:getContentSize().height*0.5-34))
	self.backSprieDown:setAnchorPoint(ccp(0.5,1))
	self.backSprieDown:setPosition(ccp(self.panelLineBg:getContentSize().width*0.5,self.panelLineBg:getContentSize().height*0.7-(self.panelLineBg:getContentSize().height*0.2+26)))
	self.panelLineBg:addChild(self.backSprieDown)

	local version =acMoscowGamblingGaiVoApi:getVersion()

	if version ==1 then
	self.tankTitle1=GetTTFLabel(getlocal("sample_ship_name_e4"),25)
	self.tankTitle2=GetTTFLabel(getlocal("sample_ship_name_f4"),25)
	self.tankDes1=getlocal("sample_ship_des_e4")
	self.tankDes2=getlocal("sample_ship_des_f4")
	self.tankcfg1 = getlocal("active_lottery_tank2")
	self.tankcfg2 = getlocal("active_lottery_tank1")
	elseif version ==2 then
	self.tankTitle1=GetTTFLabel(getlocal("sample_ship_name_g4"),25)
	self.tankTitle2=GetTTFLabelWrap(getlocal("sample_ship_name_h4"),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.tankDes1=getlocal("sample_ship_des_g4")
	self.tankDes2=getlocal("sample_ship_des_h4")
	self.tankcfg1 = getlocal("moscowGamblingGai_g4")
	self.tankcfg2 = getlocal("moscowGamblingGai_h4")
	elseif version ==3 then
	self.tankTitle1=GetTTFLabel(getlocal("tank_name_10113"),25)
	self.tankTitle2=GetTTFLabelWrap(getlocal("tank_name_10123"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.tankDes1=getlocal("tank_des_10113")
	self.tankDes2=getlocal("tank_des_10123")
	self.tankcfg1 = getlocal("moscowGamblingGai_113")
	self.tankcfg2 = getlocal("moscowGamblingGai_123")
	end

	self.tankTitle1:setAnchorPoint(ccp(0.5,1))
	self.tankTitle1:setPosition(ccp(self.backSprieDown:getContentSize().width*0.25-30,self.backSprieDown:getContentSize().height-10))
	self.backSprieDown:addChild(self.tankTitle1)

	self.tankTitle2:setAnchorPoint(ccp(0.5,1))
	self.tankTitle2:setPosition(ccp(self.backSprieDown:getContentSize().width*0.75+30,self.backSprieDown:getContentSize().height-10))
	self.backSprieDown:addChild(self.tankTitle2)	

	local desTv1, desLabel1 = G_LabelTableView(CCSizeMake(self.backSprieDown:getContentSize().width*0.4, self.backSprieDown:getContentSize().height*0.25),self.tankDes1,23,kCCTextAlignmentLeft)
	desTv1:setAnchorPoint(ccp(0,1))
	desTv1:setPosition(ccp(20,self.backSprieDown:getContentSize().height*0.3+20))
	desTv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv1:setMaxDisToBottomOrTop(50)
	self.backSprieDown:addChild(desTv1)

	local desTv2, desLabel2 = G_LabelTableView(CCSizeMake(self.backSprieDown:getContentSize().width*0.4, self.backSprieDown:getContentSize().height*0.25),self.tankDes2,23,kCCTextAlignmentLeft)
	desTv2:setAnchorPoint(ccp(1,1))
	desTv2:setPosition(ccp(self.backSprieDown:getContentSize().width*0.6+10,self.backSprieDown:getContentSize().height*0.3+20))
	desTv2:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv2:setMaxDisToBottomOrTop(50)
	self.backSprieDown:addChild(desTv2)

	local cfgSize = 25
	if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" then
		cfgSize =22
	end
	self.tankPartTitle1=GetTTFLabel(self.tankcfg1,cfgSize)
	self.tankPartTitle1:setAnchorPoint(ccp(0.5,1))
	self.tankPartTitle1:setPosition(ccp(self.backSprieDown:getContentSize().width*0.25-30,self.backSprieDown:getContentSize().height*0.3+20))
	self.backSprieDown:addChild(self.tankPartTitle1)
	self.tankPartTitle1:setColor(G_ColorYellow)

	self.tankPartTitle2=GetTTFLabelWrap(self.tankcfg2,cfgSize,CCSizeMake(260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.tankPartTitle2:setAnchorPoint(ccp(0.5,1))
	self.tankPartTitle2:setPosition(ccp(self.backSprieDown:getContentSize().width*0.75+10,self.backSprieDown:getContentSize().height*0.3+20))
	self.backSprieDown:addChild(self.tankPartTitle2)	
	self.tankPartTitle2:setColor(G_ColorYellow)

	self.tankSmallIcon1=CCSprite:createWithSpriteFrameName("BattleParts1.png")
	self.tankSmallIcon1:setAnchorPoint(ccp(0,0))
	self.tankSmallIcon1:setPosition(ccp(15,self.backSprieDown:getContentSize().height*0.1+40))
	self.backSprieDown:addChild(self.tankSmallIcon1)
	--self.tankSmallIcon1:setScale(0.3)
	--self.tankSmallIcon1:setFlipX(true) --图片镜像

	self.tankSmallIcon2=CCSprite:createWithSpriteFrameName("BattleParts2.png")
	self.tankSmallIcon2:setAnchorPoint(ccp(0,0))
	self.tankSmallIcon2:setPosition(ccp(self.backSprieDown:getContentSize().width*0.6-10,self.backSprieDown:getContentSize().height*0.1+40))
	self.backSprieDown:addChild(self.tankSmallIcon2)
	--self.tankSmallIcon2:setScale(0.3)

	-----

    local function btnCallback( tag,object)
    	self:btnCallback(tag,object)
    end
	self.make1Btn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,3,getlocal("active_lottery_makeup"),25)
	self.make1Btn:setAnchorPoint(ccp(0.5,0.5))
	local lotteryMenu2=CCMenu:createWithItem(self.make1Btn)
	lotteryMenu2:setPosition(ccp(self.backSprieDown:getContentSize().width*0.25-20,40))
	lotteryMenu2:setTouchPriority(-(self.layerNum-1)*20-5)
	self.backSprieDown:addChild(lotteryMenu2)
	self.make1Btn:setScaleX(0.8)

	self.make2Btn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",btnCallback,4,getlocal("active_lottery_makeup"),25)
	self.make2Btn:setAnchorPoint(ccp(0.5,0.5))
	local lotteryMenu3=CCMenu:createWithItem(self.make2Btn)
	lotteryMenu3:setPosition(ccp(self.backSprieDown:getContentSize().width*0.75+20,40))
	lotteryMenu3:setTouchPriority(-(self.layerNum-1)*20-5)
	self.backSprieDown:addChild(lotteryMenu3)
	self.make2Btn:setScaleX(0.8)

	self:refresh()
end

function moscowGamblingGaiDialog:btnCallback(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 
        print("self.isMoving.....",self.isMoving)
		if self.isMoving==true then
			do return end
		end		
        PlayEffect(audioCfg.mouseClick)

        local lotteryVo=acMoscowGamblingGaiVoApi:getAcVo()
		local isFree=true							--是否是第一次免费
		if acMoscowGamblingGaiVoApi:isToday()==true then
			isFree=false
		end
		local oneGems=lotteryVo.gemCost-self.vipLevel 			--一次抽奖需要金币
		local tenGems=(lotteryVo.gemCost-self.vipLevel)*9-14 			--十次抽奖需要金币
		local pieceNeed=lotteryVo.makeupCost 		--合成一次需要碎片数量
		local oldTank1Num=lotteryVo.rart1Num 		--黑鹰坦克碎片数量
		local oldTank2Num=lotteryVo.rart2Num 		--T90坦克碎片数量

		local action
		local part
		local num
		if tag==1 or tag==2 then
			action=1
			if tag==1 then
				if isFree==false and playerVoApi:getGems()<oneGems then
					GemsNotEnoughDialog(nil,nil,oneGems-playerVoApi:getGems(),self.layerNum+1,oneGems)
					do return end
				end
				num=1
			elseif tag==2 then
				if playerVoApi:getGems()<tenGems then
					GemsNotEnoughDialog(nil,nil,tenGems-playerVoApi:getGems(),self.layerNum+1,tenGems)
					do return end
				end
				num=10
			end
		elseif tag==3 or tag==4 then
			action=2
			if tag==3 then
				part=1
			elseif tag==4 then
				part=2
			end
		end
		
		local function moscowgamblingGaiCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
            	if sData.data==nil then
            		do return end
            	end
            	self.isMoving=true

            	if tag==1 then
            		if isFree==false then
	            		playerVoApi:setValue("gems",playerVoApi:getGems()-oneGems)
	            	end
	            elseif tag==2 then
					playerVoApi:setValue("gems",playerVoApi:getGems()-tenGems)
				end

				--刷新活动数据
            	local tipStr=""
            	local getTank1=false
            	local getTank2=false

            	if sData.data.reward and (tag==1 or tag==2) then
					local award=FormatItem(sData.data.reward) or {}
					for k,v in pairs(award) do
						G_addPlayerAward(v.type,v.key,v.id,v.num)
					end
					tipStr=G_showRewardTip(award,false)
				end

				local useractive=sData.data.useractive
				if useractive and useractive.moscowGamblingGai then
					local acticeData=useractive.moscowGamblingGai
					if acticeData then
						if acticeData.t then--当前已抽到的碎片
							if acticeData.t.part1 then
								local part1Num=tonumber(acticeData.t.part1)
								if part1Num and part1Num>oldTank1Num then
									getTank1=true
									if tipStr~="" then
										tipStr=tipStr..","
									else
										tipStr=getlocal("daily_lotto_tip_10")
									end
									tipStr=tipStr..self.tankcfg1.." x"..(part1Num-oldTank1Num)
									acMoscowGamblingGaiVoApi:setTankPartNum(1,part1Num)
								end
							end
							if acticeData.t.part2 then
								local part2Num=tonumber(acticeData.t.part2)
								if part2Num and part2Num>oldTank2Num then
									getTank2=true
									if tipStr~="" then
										tipStr=tipStr..","
									else
										tipStr=getlocal("daily_lotto_tip_10")
									end
									tipStr=tipStr..self.tankcfg2.." x"..(part2Num-oldTank2Num)
								end
								acMoscowGamblingGaiVoApi:setTankPartNum(2,part2Num)
							end
							
						end
						if acticeData.d then
							-- acticeData.d.n--抽奖总次数
							-- acticeData.d.ts--上一次抽奖所在天的凌晨时间戳
							if acticeData.d.ts then
								acMoscowGamblingGaiVoApi:setLastTime(acticeData.d.ts)
							end
						end
					end
				end

				if (tag==1 or tag==2) and tipStr~="" then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,28)
				end

				if (tag==3 or tag==4) then
					local makeTankTip=""
					local getTankNum=0
					local tankName1,tankName2
					if self.version ==1 or self.version ==nil then
						tankName1 = tankCfg[10043].name
						tankName2 = tankCfg[10053].name
					elseif self.version ==2 then
						tankName1 = tankCfg[10063].name
						tankName2 = tankCfg[10073].name
					elseif self.version ==3 then
						tankName1 = tankCfg[10113].name
						tankName2 = tankCfg[10123].name	
					end										
					if tag==3 then
						getTankNum=math.floor(oldTank1Num/20)*10
						if getTankNum>0 and tankName1 then
							local tankName=getlocal(tankName1)
							-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage6",{playerVoApi:getPlayerName(),tankName}))
							local nameData={key=tankName1,param={}}
							local message={key="chatSystemMessage6",param={playerVoApi:getPlayerName(),nameData}}
                			chatVoApi:sendSystemMessage(message)
							makeTankTip=makeTankTip..getlocal("active_lottery_reward_tank",{tankName," x"..getTankNum})
						end
					elseif tag==4 then
						getTankNum=math.floor(oldTank2Num/20)*10
						if getTankNum>0 and tankName2 then
							local tankName=getlocal(tankName2)
							-- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage6",{playerVoApi:getPlayerName(),tankName}))
							local nameData={key=tankName2,param={}}
							local message={key="chatSystemMessage6",param={playerVoApi:getPlayerName(),nameData}}
                			chatVoApi:sendSystemMessage(message)
							makeTankTip=makeTankTip..getlocal("active_lottery_reward_tank",{tankName," x"..getTankNum})
						end
					end
					if makeTankTip~="" then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),makeTankTip,28)
					end
				end
				
				if (getTank1==true or getTank2==true) and (tag==1 or tag==2) then
					local leftPosX=self.rewardBg:getContentSize().width/2-150+10
					local rightPosX=self.rewardBg:getContentSize().width/2+150+10
					if getTank1==true and (tag==1 or tag==2) then
						self.lightSp:setVisible(true)
						local pointY=self.panelLineBg:getContentSize().width*0.5,self.backSprie:getPositionY()-self.backSprie:getContentSize().height*0.5

					    local pieceSp=CCSprite:createWithSpriteFrameName("BattleParts1.png")
					    pieceSp:setAnchorPoint(ccp(0.5,0.5))
					    pieceSp:setPosition(ccp(self.panelLineBg:getContentSize().width*0.5,self.backSprie:getPositionY()-self.backSprie:getContentSize().height*0.5))
					    self.panelLineBg:addChild(pieceSp,4)

					    local function playEndCallback1()
							pieceSp:removeFromParentAndCleanup(true)
							pieceSp=nil

							self.isMoving=false

							self:refresh()
						end
						local callFunc=CCCallFuncN:create(playEndCallback1)

						local function hideLight()
							if self.lightSp then
								self.lightSp:setVisible(false)
							end
						end
						local callFunc1=CCCallFuncN:create(hideLight)

						local delay=CCDelayTime:create(0.5)
						local mvTo0=CCMoveTo:create(0.5,ccp(leftPosX+15,95))
						if G_isIphone5()==true then
							mvTo0=CCMoveTo:create(0.5,ccp(leftPosX+15,85+60))
						end
					    local scaleTo=CCScaleTo:create(0.2,2)
						local scaleTo1=CCScaleTo:create(0.3,0.2)

					    local acArr=CCArray:create()
					    acArr:addObject(delay)
					    acArr:addObject(callFunc1)
						acArr:addObject(mvTo0)

						acArr:addObject(scaleTo)
						acArr:addObject(scaleTo1)
					    acArr:addObject(callFunc)
					    local seq=CCSequence:create(acArr)
					    pieceSp:runAction(seq)
					end

					if getTank2==true and (tag==1 or tag==2) then 
						self.lightSp:setVisible(true)           		
						local pointY=self.panelLineBg:getContentSize().width*0.5,self.backSprie:getPositionY()-self.backSprie:getContentSize().height*0.5

					    local pieceSp=CCSprite:createWithSpriteFrameName("BattleParts2.png")
					    pieceSp:setAnchorPoint(ccp(0.5,0.5))
					    pieceSp:setPosition(ccp(self.panelLineBg:getContentSize().width*0.5,self.backSprie:getPositionY()-self.backSprie:getContentSize().height*0.5))
					    self.panelLineBg:addChild(pieceSp,4)
					    local function playEndCallback1()
							pieceSp:removeFromParentAndCleanup(true)
							pieceSp=nil

							self.isMoving=false
							self:refresh()
						end
						local callFunc=CCCallFuncN:create(playEndCallback1)

						local function hideLight()
							if self.lightSp then
								self.lightSp:setVisible(false)
							end
						end
						local callFunc1=CCCallFuncN:create(hideLight)

						local delay=CCDelayTime:create(0.5)
						local mvTo0=CCMoveTo:create(0.5,ccp(rightPosX+15,95))
						if G_isIphone5()==true then
							mvTo0=CCMoveTo:create(0.5,ccp(rightPosX+15,95+60))
						end
					    local scaleTo=CCScaleTo:create(0.2,2)
						local scaleTo1=CCScaleTo:create(0.3,0.2)

					    local acArr=CCArray:create()
					    acArr:addObject(delay)
					    acArr:addObject(callFunc1)
						acArr:addObject(mvTo0)

						acArr:addObject(scaleTo)
						acArr:addObject(scaleTo1)
					    acArr:addObject(callFunc)
					    local seq=CCSequence:create(acArr)
					    pieceSp:runAction(seq)
	            	end
	            else
	            	self.isMoving=false
					self:refresh()
	            end
            end
		end
        socketHelper:activeMoscowgamblingGai(action,part,num,moscowgamblingGaiCallback)
	
end

function moscowGamblingGaiDialog:refresh( )
    local lotteryVo=acMoscowGamblingGaiVoApi:getAcVo()
	local isFree=true							--是否是第一次免费
	if acMoscowGamblingGaiVoApi:isToday()==true then
		isFree=false	
	end
	if isFree ==false then
		tolua.cast(self.lotteryOneBtn:getChildByTag(333),"CCLabelTTF"):setString(getlocal("active_lottery_btn1"))
		self.iconGold1:setVisible(true)
		self.iconGold2:setVisible(true)
		self.iconGold3:setVisible(true)
		self.iconGold4:setVisible(true)
		self.price1Lb:setVisible(true)
		self.price2Lb:setVisible(true)
		self.price3Lb:setVisible(true)
		self.price4Lb:setVisible(true)
		self.line1:setVisible(true)
		self.line3:setVisible(true)
		self.lotteryTenBtn:setEnabled(true)	
		if self.vipLevel == 0 then
			self.iconGold3:setVisible(false)
			self.iconGold4:setVisible(false)
			self.price1Lb:setColor(G_ColorYellow)
			self.price2Lb:setColor(G_ColorYellow)
			self.price3Lb:setVisible(false)
			self.price4Lb:setVisible(false)
			self.line1:setVisible(false)
			self.line3:setVisible(false)	
		end		
	elseif isFree==true then
		tolua.cast(self.lotteryOneBtn:getChildByTag(333),"CCLabelTTF"):setString(getlocal("daily_lotto_tip_2"))
		self.iconGold1:setVisible(false)
		self.iconGold2:setVisible(false)
		self.iconGold3:setVisible(false)
		self.iconGold4:setVisible(false)
		self.price1Lb:setVisible(false)
		self.price2Lb:setVisible(false)
		self.price3Lb:setVisible(false)
		self.price4Lb:setVisible(false)
		self.line1:setVisible(false)
		self.line3:setVisible(false)
		self.lotteryTenBtn:setEnabled(false)	
	end		
	local oneGems=lotteryVo.gemCost 			--一次抽奖需要金币
	local tenGems=lotteryVo.gemCost*10 			--十次抽奖需要金币
	local pieceNeed=lotteryVo.makeupCost 		--合成一次需要碎片数量
	local tank1Num=lotteryVo.rart1Num 			--黑鹰坦克碎片数量
	local tank2Num=lotteryVo.rart2Num 			--T90坦克碎片数量
------
-----
	if tank1Num>=pieceNeed then
		self.make1Btn:setEnabled(true)
	else
		self.make1Btn:setEnabled(false)
	end
	if tank2Num>=pieceNeed then
		self.make2Btn:setEnabled(true)
	else
		self.make2Btn:setEnabled(false)
	end


    local percentStr1=tank1Num.."/"..pieceNeed
    local percent1=(tank1Num/pieceNeed)*100
    if percent1>100 then
    	percent1=100
    end
    local percentStr2=tank2Num.."/"..pieceNeed
    local percent2=(tank2Num/pieceNeed)*100
    if percent2>100 then
    	percent2=100
    end

    local proScaleX=0.5
    if self.tank1progress==nil then
	    AddProgramTimer(self.backSprieDown,ccp(self.backSprieDown:getContentSize().width*0.25+10,self.backSprieDown:getContentSize().height*0.1+55),101,201,percentStr1,"skillBg.png","skillBar.png",301,proScaleX)
	    self.tank1progress=self.backSprieDown:getChildByTag(101)
	    self.tank1progress=tolua.cast(self.tank1progress,"CCProgressTimer")
	end
	self.tank1progress:setPercentage(percent1)
	tolua.cast(self.tank1progress:getChildByTag(201),"CCLabelTTF"):setString(percentStr1)

	if self.tank2progress==nil then
		AddProgramTimer(self.backSprieDown,ccp(self.backSprieDown:getContentSize().width*0.75+45,self.backSprieDown:getContentSize().height*0.1+55),102,202,percentStr2,"skillBg.png","skillBar.png",302,proScaleX)
		self.tank2progress=self.backSprieDown:getChildByTag(102)
		self.tank2progress=tolua.cast(self.tank2progress,"CCProgressTimer")
	end
	self.tank2progress:setPercentage(percent2)
	tolua.cast(self.tank2progress:getChildByTag(202),"CCLabelTTF"):setString(percentStr2)


end



--点击tab页签 idx:索引
function moscowGamblingGaiDialog:tabClick(idx)

end

function moscowGamblingGaiDialog:tick()
	self.choseTicknum=self.choseTicknum+1
	if self and self.bgLayer then 
		local today=acMoscowGamblingGaiVoApi:isToday()
		if self.isToday~=today then
			self:refresh()
			self.isToday=today
		end
	end
	if self.choseTicknum==2 then
		if self.tankAni1 then
			self.tankAni1:tick()
		end
	elseif self.choseTicknum==4 then
		if self.tankAni2 then
			self.tankAni2:tick()
		end
	end
	if self.choseTicknum >=5 then
		self.choseTicknum=1
	end
	if self.timeLb then
		local acVo = acMoscowGamblingGaiVoApi:getAcVo()
		G_updateActiveTime(acVo,self.timeLb)
	end
end

function moscowGamblingGaiDialog:update()
	-- body
end

function moscowGamblingGaiDialog:dispose()
	if self.tankAni1 then
		self.tankAni1:dispose()
	end
	if self.tankAni2 then
		self.tankAni2:dispose()
	end
	self.characterSp=nil
	self.descBg=nil
	self.descLabel=nil
	self.rewardBg=nil
	self.tankPic=nil
	self.isMoving=nil
	self.goldSp1=nil
	self.goldSp2=nil
	self.gemsLabel1=nil
	self.gemsLabel2=nil
	self.lotteryOneBtn=nil
	self.lotteryTenBtn=nil
	self.make1Btn=nil
	self.make2Btn=nil
	self.tank1progress=nil
	self.tank2progress=nil
	self.pieceSp1=nil
	self.pieceSp2=nil
	self.tank1Label=nil
	self.tank2Label=nil
	self.selectedBox=nil
	self.lightSp=nil
	self.tanksName=nil
	self.isToday=nil
	self.choseTicknum=nil
	self.vipLevel=nil
	self.vippIcon=nil
end




