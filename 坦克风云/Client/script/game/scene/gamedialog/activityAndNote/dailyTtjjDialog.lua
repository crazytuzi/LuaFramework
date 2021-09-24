-- @Auhor hj
-- @天天基金

dailyTtjjDialog = commonDialog:new()

function dailyTtjjDialog:new(log)
    local nc={
    	--所有基金上限	
    	allLimt = nil,
    	--当日基金上限
    	todaylimit = nil,
    	upPosY = 0,
    	midPosY = nil,
    	tvNum = nil,
    	--采矿的记录
    	log = log,
    	collectSpeed = nil,
    	strSize = 25,
   		upTip = dailyTtjjVoApi:judgeAllLimit()==true and {"activity_ttjj_all_limit",G_ColorRed} or {"activity_ttjj_all_accumulate",G_ColorWhite},
		midTip =  dailyTtjjVoApi:judgeTodayLimit()==true and {"activity_ttjj_today_limit",G_ColorRed} or {"activity_ttjj_today_accumulate",G_ColorWhite},
		--所给艺术字的bm位图有问题，需要下移的坐标
		bmAdaH = 220,
		adaH = 0,
		adaH2 = 0,
		adaH3 = 0,
		adaH4 = 0,
		strSize2 = 20,
		strSize3 = 25,
		--设置闪时间间隔
		timeIntervalUp = base.serverTime + 2,
		timeIntervalMid = base.serverTime + 2
	}
    setmetatable(nc,self)
    self.__index=self

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("public/emblem/emblemImage.plist")
	spriteController:addTexture("public/emblem/emblemImage.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc

end

function dailyTtjjDialog:doUserHandler( ... )


    if G_isAsia() == false then
		self.strSize = 15
		self.adaH = 10
		if G_isIOS() == false or G_getCurChoseLanguage() == "de" then
			self.strSize2 = 18
		end
		if G_getCurChoseLanguage() == "ar" then
			self.adaH = 0
			self.strSize3 = 18
		end
    elseif G_getCurChoseLanguage() == "ko" then
    	if G_isIOS() == false then
    		self.strSize = 15
    		self.adaH2 = 20
    	else
    		self.strSize = 18
    		self.adaH3 = 5
    	end
    elseif G_getCurChoseLanguage() == "cn" then
    	if G_isIOS() == false then
    		self.adaH4 = 10
    	end
    end
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.panelLineBg:setVisible(false)
    local function nilFunc( ... )
    end 
    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),nilFunc)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)
   	-- self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height - 105))
   	-- self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,(self.bgLayer:getContentSize().height-105)/2+20))
	self:getTtjjCfg()
	self:initUp()
	self:initMid()
end

--显示纪录的滑动区域
function dailyTtjjDialog:initTableView( ... )
	self.logHeightTb={}
	self.cellNum = SizeOfTable(self.log)
	self:noLogTip()
    if dailyTtjjVoApi:judgeTodayLimit()== true and self.cellNum>0 then
		self.cellNum=self.cellNum+1
	end
	--适配所有机型获取自适应高，宽
    local tvHeight = self.midPosY - 30
    local tvWidth = G_VisibleSizeWidth - 20

	local function callBack(...)
    	return self:eventHandler(...)
    end
    local function nilFunc( ... )
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
   	self.bgLayer:addChild(tvBg)
   	tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
   	tvBg:setAnchorPoint(ccp(0,0))
   	tvBg:setPosition(ccp(10,20))

    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,(tvHeight-5)),nil)
 	self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    tvBg:addChild(self.tv)
    self.tv:setPosition(ccp(0,0))
    self.tv:setMaxDisToBottomOrTop(80) 
end

--滑动区域回调
function dailyTtjjDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
    	local height = self:getAdaHeight(idx,self.log)
        local tmpSize=CCSizeMake(600,height)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        self:initCell(idx,self.log,cell)
        cell:autorelease()
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccScrollEnable" then
    end
end

function dailyTtjjDialog:tick( ... )
	self:refreshFundLabel()
	self:refreshTips()
	self:noLogTip()
	self:flashStar()
end

----------局部方法

--初始化上部
function dailyTtjjDialog:initUp( ... )

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	--大背景
	local upBacksprie = CCSprite:create("public/dailyFund_1.jpg")
	self.bgLayer:addChild(upBacksprie)
	upBacksprie:setAnchorPoint(ccp(0.5,1))
	upBacksprie:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-85))
	upBacksprie:setScaleX(G_VisibleSizeWidth/upBacksprie:getContentSize().width)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local function nilFunc( ... )
    	-- body
    end
	--标题框
	local titleBacksprie = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),nilFunc)
	upBacksprie:addChild(titleBacksprie)
	titleBacksprie:setAnchorPoint(ccp(0.5,1))
	titleBacksprie:setContentSize(CCSizeMake(upBacksprie:getContentSize().width,85))
	titleBacksprie:setPosition(ccp(upBacksprie:getContentSize().width/2,upBacksprie:getContentSize().height))

	--标题
	local upTitleLabel = GetTTFLabelWrap(getlocal("activity_ttjj_title_up"),self.strSize,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	upBacksprie:addChild(upTitleLabel)
	upTitleLabel:setAnchorPoint(ccp(0.5,1))
	upTitleLabel:setPosition(ccp(upBacksprie:getContentSize().width/2,upBacksprie:getContentSize().height - 10+self.adaH))
	
	local numPosX = G_VisibleSizeWidth/2 + 100
	
	--小标题
	local upSubTitleLabel = GetTTFLabel(getlocal("activity_ttjj_allfund"),25,true)
	upBacksprie:addChild(upSubTitleLabel)
	upSubTitleLabel:setAnchorPoint(ccp(0.5,1))
	upSubTitleLabel:setPosition(ccp(numPosX,upTitleLabel:getPositionY()- upTitleLabel:getContentSize().height-25+self.adaH+self.adaH2/2+self.adaH4))
	local numPosY = upSubTitleLabel:getPositionY() - upSubTitleLabel:getContentSize().height - 60
	local allFundLabel = GetBMLabel(dailyTtjjVoApi:getAllFund(),G_GoldFontSrcNew)
	local allFundLimitLabel = GetBMLabel(self.allLimt,G_GoldFontSrcNew)
	local ratioLabel = GetTTFLabelWrap("/",55,CCSizeMake(30,60),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)

	upBacksprie:addChild(allFundLabel)
	upBacksprie:addChild(allFundLimitLabel)
	upBacksprie:addChild(ratioLabel)

	ratioLabel:setAnchorPoint(ccp(0,0.5))
	allFundLabel:setAnchorPoint(ccp(1,0.5))
	allFundLimitLabel:setAnchorPoint(ccp(0,0.5))

	ratioLabel:setPosition(ccp(numPosX,numPosY))
	allFundLabel:setPosition(ccp(numPosX - 15,numPosY-self.bmAdaH))
	allFundLimitLabel:setPosition(ccp(numPosX + ratioLabel:getContentSize().width + 15,numPosY-self.bmAdaH))

	self.allFundLabel,self.allFundLimitLabel = allFundLabel,allFundLimitLabel

	--提示文字
	local upTipLabel = GetTTFLabelWrap(getlocal(self.upTip[1]),20,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	upBacksprie:addChild(upTipLabel)
	upTipLabel:setAnchorPoint(ccp(0.5,1))
	upTipLabel:setPosition(ccp(ratioLabel:getPositionX(),numPosY-ratioLabel:getContentSize().height/2-10))
	upTipLabel:setColor(self.upTip[2])
	self.upTipLabel = upTipLabel

	--弹到充值页面
	local function rechargeCallback( ... )
        vipVoApi:showRechargeDialog(self.layerNum+1)
        self:close()
	end
	local btnPosY = upTipLabel:getPositionY()-upTipLabel:getContentSize().height-70
	local pos = ccp(G_VisibleSizeWidth/2,btnPosY)
	if G_getCurChoseLanguage() == "de" then
		G_createBotton(upBacksprie,pos,{getlocal("activity_ttjj_fund_now"),18},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rechargeCallback,0.8,-(self.layerNum-1)*20-4)
	else
		G_createBotton(upBacksprie,pos,{getlocal("activity_ttjj_fund_now"),self.strSize},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rechargeCallback,0.8,-(self.layerNum-1)*20-4)
	end
	
	--线条分割
	local lineSp=CCSprite:createWithSpriteFrameName("modifiersLine2.png")
	upBacksprie:addChild(lineSp)
	lineSp:setAnchorPoint(ccp(0.5,1))
	lineSp:setScaleX(G_VisibleSizeWidth/lineSp:getContentSize().width)
	lineSp:setPosition(ccp(G_VisibleSizeWidth/2,0))
	self.upPosY = G_VisibleSizeHeight - 85 - upBacksprie:getContentSize().height-2

end

--初始化中部
function dailyTtjjDialog:initMid( ... )

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	--大背景
	local midBacksprie = CCSprite:create("public/dailyFund_2.jpg")
	self.bgLayer:addChild(midBacksprie)
	midBacksprie:setAnchorPoint(ccp(0.5,1))
	midBacksprie:setPosition(ccp(G_VisibleSizeWidth/2,self.upPosY))
	midBacksprie:setScaleX(G_VisibleSizeWidth/midBacksprie:getContentSize().width)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local function nilFunc( ... )
    end
	--标题框
	local titleBacksprie = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),nilFunc)
	midBacksprie:addChild(titleBacksprie)
	titleBacksprie:setAnchorPoint(ccp(0.5,1))
	titleBacksprie:setContentSize(CCSizeMake(midBacksprie:getContentSize().width,85))
	titleBacksprie:setPosition(ccp(midBacksprie:getContentSize().width/2,midBacksprie:getContentSize().height))

	--标题
	local colorTab = {nil,G_ColorYellowPro,nil}
	local midTitleLabel,realH = G_getRichTextLabel(getlocal("activity_ttjj_title_mid",{self.todaylimit}),colorTab,self.strSize,500,kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	midBacksprie:addChild(midTitleLabel)
	midTitleLabel:setAnchorPoint(ccp(0.5,1))
	midTitleLabel:setPosition(ccp(midBacksprie:getContentSize().width/2,midBacksprie:getContentSize().height-10+self.adaH))

	local numPosX = G_VisibleSizeWidth/2 + 100

	--小标题
	local midSubTitleLabel = GetTTFLabel(getlocal("activity_ttjj_today_fund"),25,true)
	midBacksprie:addChild(midSubTitleLabel)
	midSubTitleLabel:setAnchorPoint(ccp(0.5,1))
	midSubTitleLabel:setPosition(ccp(numPosX,midTitleLabel:getPositionY()- realH - 25-self.adaH+self.adaH2+self.adaH4))
	local numPosY = midSubTitleLabel:getPositionY() - midSubTitleLabel:getContentSize().height - 60

	local todayFundLabel = GetBMLabel(dailyTtjjVoApi:getTodayFund(),G_GoldFontSrcNew)
	midBacksprie:addChild(todayFundLabel)
	todayFundLabel:setAnchorPoint(ccp(0.5,0.5))
	todayFundLabel:setPosition(ccp(numPosX,numPosY - self.bmAdaH))
	self.todayFundLabel = todayFundLabel

	--提示文字
	local midTipLabel = GetTTFLabelWrap(getlocal(self.midTip[1],{self.todaylimit - dailyTtjjVoApi:getTodayFund()}),self.strSize2,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	midBacksprie:addChild(midTipLabel)
	midTipLabel:setAnchorPoint(ccp(0.5,1))
	midTipLabel:setPosition(ccp(numPosX,numPosY - 50+self.adaH3+self.adaH2/2+self.adaH4))
	midTipLabel:setColor(self.midTip[2])
	self.midTipLabel = midTipLabel	

	--弹到世界地图
	local function resourceCallback( ... )
		local level = playerVoApi:getPlayerLevel()
		if level and level >= 3 then	
        	activityAndNoteDialog:closeAllDialog()
        	mainUI:changeToWorld()
    	else
    		--等级判断
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{3}),30)
    	end
	end

	local btnPosY = midTipLabel:getPositionY()-midTipLabel:getContentSize().height - 60
	local pos = ccp(G_VisibleSizeWidth/2,btnPosY)
	G_createBotton(midBacksprie,pos,{getlocal("activity_ttjj_fund_get"),self.strSize3},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",resourceCallback,0.8,-(self.layerNum-1)*20-4)
	self.midPosY = self.upPosY - midBacksprie:getContentSize().height
end

--动态获取自适应高度
function dailyTtjjDialog:getAdaHeight(idx,log)
	if self.logHeightTb[idx+1] then
		do return self.logHeightTb[idx+1] end
	end
	local tempLabel
	if dailyTtjjVoApi:judgeTodayLimit()==true then
		if idx == 0 then
			tempLabel = GetTTFLabelWrap(getlocal("activity_ttjj_resource_limit"),25,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		else
			if log[idx][2] == 0 then
				tempLabel = GetTTFLabelWrap(getlocal("activity_ttjj_resource_notGet",{log[idx][3],self.collectSpeed}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			else
				tempLabel = GetTTFLabelWrap(getlocal("activity_ttjj_resource_get",{log[idx][3],log[idx][1]}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			end
		end
	else
		if log[idx+1][2] == 0 then
			tempLabel = GetTTFLabelWrap(getlocal("activity_ttjj_resource_notGet",{log[idx+1][3],self.collectSpeed}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		else
			tempLabel = GetTTFLabelWrap(getlocal("activity_ttjj_resource_get",{log[idx+1][3],log[idx+1][1]}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		end
	end
	self.logHeightTb[idx+1]=tempLabel:getContentSize().height + 20
	return self.logHeightTb[idx+1]
	-- return tempLabel:getContentSize().height + 20
end

--初始化cell
function dailyTtjjDialog:initCell(idx,log,cell)
	
	local tempLabel
	local timeStampLabel
	local goldLabel
	local goldSpire 
	local iconGold = CCSprite:createWithSpriteFrameName("IconGold.png")
	local function nilFunc( ... )
	end
	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine3.png",CCRect(2,1,1,1),nilFunc)
	local height = self:getAdaHeight(idx,log)
    local tmpSize=CCSizeMake(620,height)
	cell:setContentSize(tmpSize)
	lineSp:setAnchorPoint(ccp(0.5,0))
	lineSp:setPosition(ccp(cell:getContentSize().width/2,0))
	lineSp:setContentSize(CCSizeMake(620,2))
	cell:addChild(lineSp)
	if dailyTtjjVoApi:judgeTodayLimit() == true then
		if idx == 0 then
			tempLabel = GetTTFLabelWrap(getlocal("activity_ttjj_resource_limit"),25,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			timeStampLabel = GetTTFLabel(log[1][4],25)

			tempLabel:setAnchorPoint(ccp(0,1))
			timeStampLabel:setAnchorPoint(ccp(1,0.5))

			tempLabel:setPosition(ccp(timeStampLabel:getContentSize().width+35,cell:getContentSize().height - 10))
			timeStampLabel:setPosition(ccp(-20,tempLabel:getContentSize().height/2))
			cell:addChild(tempLabel)
			tempLabel:addChild(timeStampLabel)

		else
			if log[idx][2] == 0 then
				tempLabel = GetTTFLabelWrap(getlocal("activity_ttjj_resource_notGet",{log[idx][3],self.collectSpeed}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				timeStampLabel = GetTTFLabel(log[idx][4],25)
				goldLabel = GetTTFLabel("+ "..tostring(log[idx][2]),25)

				tempLabel:setAnchorPoint(ccp(0,1))
				timeStampLabel:setAnchorPoint(ccp(1,0.5))
				iconGold:setAnchorPoint(ccp(1,0.5))
				goldLabel:setAnchorPoint(ccp(1,0.5))

				tempLabel:setPosition(ccp(timeStampLabel:getContentSize().width+35,cell:getContentSize().height - 10))
				timeStampLabel:setPosition(ccp(-20,tempLabel:getContentSize().height/2))
				iconGold:setPosition(ccp(cell:getContentSize().width - 10, cell:getContentSize().height - 10 - tempLabel:getContentSize().height/2))
				goldLabel:setPosition(ccp(cell:getContentSize().width - 10 - iconGold:getContentSize().width,iconGold:getPositionY()))

				cell:addChild(tempLabel)
				cell:addChild(iconGold)
				cell:addChild(goldLabel)
				tempLabel:addChild(timeStampLabel)

			else
				
				tempLabel = GetTTFLabelWrap(getlocal("activity_ttjj_resource_get",{log[idx][3],log[idx][1]}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				timeStampLabel = GetTTFLabel(log[idx][4],25)
				goldLabel = GetTTFLabel("+ "..tostring(log[idx][2]),25)

				tempLabel:setAnchorPoint(ccp(0,1))
				timeStampLabel:setAnchorPoint(ccp(1,0.5))
				iconGold:setAnchorPoint(ccp(1,0.5))
				goldLabel:setAnchorPoint(ccp(1,0.5))

				tempLabel:setColor(G_ColorYellowPro)
				timeStampLabel:setColor(G_ColorYellowPro)
				goldLabel:setColor(G_ColorYellowPro)

				tempLabel:setPosition(ccp(timeStampLabel:getContentSize().width+35,cell:getContentSize().height - 10))
				timeStampLabel:setPosition(ccp(-20,tempLabel:getContentSize().height/2))
				iconGold:setPosition(ccp(cell:getContentSize().width - 10, cell:getContentSize().height - 10 - tempLabel:getContentSize().height/2))
				goldLabel:setPosition(ccp(cell:getContentSize().width - 10 - iconGold:getContentSize().width,iconGold:getPositionY()))

				cell:addChild(tempLabel)
				cell:addChild(iconGold)
				cell:addChild(goldLabel)
				tempLabel:addChild(timeStampLabel)
			end
		end
	else
		if log[idx+1][2] == 0 then

			tempLabel = GetTTFLabelWrap(getlocal("activity_ttjj_resource_notGet",{log[idx+1][3],self.collectSpeed}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			timeStampLabel = GetTTFLabel(log[idx+1][4],25)
			goldLabel = GetTTFLabel("+ "..tostring(log[idx+1][2]),25)

			tempLabel:setAnchorPoint(ccp(0,1))
			timeStampLabel:setAnchorPoint(ccp(1,0.5))
			iconGold:setAnchorPoint(ccp(1,0.5))
			goldLabel:setAnchorPoint(ccp(1,0.5))

			tempLabel:setPosition(ccp(timeStampLabel:getContentSize().width+35,cell:getContentSize().height - 10))
			timeStampLabel:setPosition(ccp(-20,tempLabel:getContentSize().height/2))
			iconGold:setPosition(ccp(cell:getContentSize().width - 10, cell:getContentSize().height - 10 - tempLabel:getContentSize().height/2))
			goldLabel:setPosition(ccp(cell:getContentSize().width - 10 - iconGold:getContentSize().width,iconGold:getPositionY()))

			cell:addChild(tempLabel)
			cell:addChild(iconGold)
			cell:addChild(goldLabel)
			tempLabel:addChild(timeStampLabel)

		else
			tempLabel = GetTTFLabelWrap(getlocal("activity_ttjj_resource_get",{log[idx+1][3],log[idx+1][1]}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			timeStampLabel = GetTTFLabel(log[idx+1][4],25)
			goldLabel = GetTTFLabel("+ "..tostring(log[idx+1][2]),25)

			tempLabel:setAnchorPoint(ccp(0,1))
			timeStampLabel:setAnchorPoint(ccp(1,0.5))
			iconGold:setAnchorPoint(ccp(1,0.5))
			goldLabel:setAnchorPoint(ccp(1,0.5))

			tempLabel:setColor(G_ColorYellowPro)
			timeStampLabel:setColor(G_ColorYellowPro)
			goldLabel:setColor(G_ColorYellowPro)

			tempLabel:setPosition(ccp(timeStampLabel:getContentSize().width+35,cell:getContentSize().height - 10))
			timeStampLabel:setPosition(ccp(-20,tempLabel:getContentSize().height/2))
			iconGold:setPosition(ccp(cell:getContentSize().width - 10, cell:getContentSize().height - 10 - tempLabel:getContentSize().height/2))
			goldLabel:setPosition(ccp(cell:getContentSize().width - 10 - iconGold:getContentSize().width,iconGold:getPositionY()))

			cell:addChild(tempLabel)
			cell:addChild(iconGold)
			cell:addChild(goldLabel)
			tempLabel:addChild(timeStampLabel)
		end
	end
end

--获取基金上限
function dailyTtjjDialog:getTtjjCfg()
	local ttjjCfg = dailyTtjjVoApi:getTtjjCfg() 
	self.todaylimit = ttjjCfg["goldDayLimit"]
	self.allLimt = ttjjCfg["goldAllLimit"]
	self.collectSpeed = ttjjCfg["collectSpeed"]
end

--刷新提示文字
function dailyTtjjDialog:refreshTips( ... )
	-- 根据条件判断要显示的tip
   	self.upTip = dailyTtjjVoApi:judgeAllLimit()==true and {"activity_ttjj_all_limit",G_ColorRed} or {"activity_ttjj_all_accumulate",G_ColorWhite}
	self.midTip =  dailyTtjjVoApi:judgeTodayLimit()==true and {"activity_ttjj_today_limit",G_ColorRed} or {"activity_ttjj_today_accumulate",G_ColorWhite}
	self.upTipLabel:setString(getlocal(self.upTip[1]))
	self.upTipLabel:setColor(self.upTip[2])
	self.midTipLabel:setString(getlocal(self.midTip[1],{self.todaylimit - dailyTtjjVoApi:getTodayFund()}))
	self.midTipLabel:setColor(self.midTip[2])
	-- 判断是否跨天
end 

--刷新上下的基金
function dailyTtjjDialog:refreshFundLabel( ... )
	self.allFundLabel:setString(dailyTtjjVoApi:getAllFund())
	self.todayFundLabel:setString(dailyTtjjVoApi:getTodayFund())
end

--闪星动画
function dailyTtjjDialog:flashStar( ... )

	if self.timeIntervalUp <= base.serverTime then
		self:runStarAction("up")
		self.timeIntervalUp = base.serverTime + math.random(3,10)
	end
	if self.timeIntervalMid <= base.serverTime then
		self:runStarAction("mid")
		self.timeIntervalMid = base.serverTime + math.random(4,11)
	end

end

function dailyTtjjDialog:noLogTip( ... )
	if self.cellNum==0 then
		local tipLabel =  GetTTFLabel(getlocal("activity_tccx_no_record"),30)
		self.bgLayer:addChild(tipLabel,3)
		tipLabel:setAnchorPoint(ccp(0.5,1))
		tipLabel:setPosition(ccp(G_VisibleSizeWidth/2,(self.midPosY - 30)/2 + 35))
		tipLabel:setColor(G_ColorGray)
	end
end


function dailyTtjjDialog:runStarAction(flag)
	
	local posX
	local posY

	----上下闪光的坐标不同
	if flag == "up" then
		posX=math.random(30,160)
		posY=math.random(self.upPosY+90,self.upPosY+200)
	else
		posX=math.random(80,140)
		posY=math.random(self.midPosY+130,self.midPosY+170)
	end

	local blingSp=CCSprite:createWithSpriteFrameName("emblemBling.png")
	
	blingSp:setPosition(posX,posY)
	self.bgLayer:addChild(blingSp)
	blingSp:setOpacity(0)

	local fadeIn=CCFadeIn:create(0.5)
	local delay=CCDelayTime:create(2)
	local fadeOut=CCFadeOut:create(0.5)
	local arr1=CCArray:create()
	arr1:addObject(fadeIn)
	arr1:addObject(delay)
	arr1:addObject(fadeOut)
	local seque=CCSequence:create(arr1)
	
	local arr2=CCArray:create()
	local rotate=CCRotateBy:create(3,360)
	arr2:addObject(seque)
	arr2:addObject(rotate)
	local spawn=CCSpawn:create(arr2)

	local function callBack( ... )
		blingSp:removeFromParentAndCleanup(true)
		blingSp = nil
	end 
	local callFunc = CCCallFunc:create(callBack)

	local seq = CCSequence:createWithTwoActions(spawn,callFunc)

	blingSp:runAction(seq)

end

function dailyTtjjDialog:dispose( ... )
	
	self.todaylimit = nil
	self.allLimt = nil
	self.logHeightTb=nil

	spriteController:removePlist("public/emblem/emblemImage.plist")
	spriteController:removeTexture("public/emblem/emblemImage.png")

end
