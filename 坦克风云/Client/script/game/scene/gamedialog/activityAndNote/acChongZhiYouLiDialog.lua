acChongZhiYouLiDialog = commonDialog:new()

function acChongZhiYouLiDialog:new(layerNum )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.backSprie=nil

	return nc
end

function acChongZhiYouLiDialog:initTableView( )
	--self.panelLineBg:setVisible(false)
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSize.width-20,G_VisibleSize.height-105))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2+20))
	local capInSetNew=CCRect(20, 20, 10, 10)
	local function cellClick(hd,fn,idx)
	end
	self.backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSetNew,cellClick)
	self.backSprie:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width-10, self.panelLineBg:getContentSize().height-150))
	self.backSprie:setAnchorPoint(ccp(0,1))
	self.backSprie:setPosition(ccp(5,self.panelLineBg:getContentSize().height-5))
	self.panelLineBg:addChild(self.backSprie)

    local titleStr=getlocal("activity_timeLabel")
    local titleLb=GetTTFLabelWrap(titleStr,35,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    titleLb:setAnchorPoint(ccp(0.5,1))
    titleLb:setPosition(ccp(self.backSprie:getContentSize().width*0.5,self.backSprie:getContentSize().height-10))
    self.backSprie:addChild(titleLb,1)
    titleLb:setColor(G_ColorGreen)

    local vo=acChongZhiYouLiVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(vo.st,vo.acEt)
    local timeLb=GetTTFLabelWrap(timeStr,30,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    timeLb:setAnchorPoint(ccp(0.5,1))
    timeLb:setPosition(ccp(self.backSprie:getContentSize().width*0.5,titleLb:getPositionY()-45))
    self.backSprie:addChild(timeLb,1)
    timeLb:setColor(G_ColorYellow)
	self.timeLb=timeLb
	self:updateAcTime()

    local rechargeMone = acChongZhiYouLiVoApi:getRechargeMone()
    local rechargeStr,rechargeLabel,iconGold
    if rechargeMone > 0 then
    	 rechargeStr = getlocal("rechargeGifts_label",{rechargeMone})
    else
    	rechargeStr = getlocal("rechargeGifts_labeld")
    end
    local rechargeStrSize = 30
    if G_getCurChoseLanguage() =="ru" then
    	rechargeStrSize =25
    end
    rechargeLabel = GetTTFLabelWrap(rechargeStr,rechargeStrSize,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    rechargeLabel:setAnchorPoint(ccp(0.5,1))
    rechargeLabel:setPosition(ccp(self.backSprie:getContentSize().width*0.6+10,timeLb:getPositionY()-60))
    self.backSprie:addChild(rechargeLabel,1)
    rechargeLabel:setColor(G_ColorYellow)

	iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
	iconGold:setAnchorPoint(ccp(0.5,1))
	iconGold:setPosition(ccp(self.backSprie:getContentSize().width*0.6+rechargeLabel:getContentSize().width*0.5+25,timeLb:getPositionY()-60))
	self.backSprie:addChild(iconGold,1)    
	if rechargeMone <=0 then
		iconGold:setVisible(false)
	end

	local function bgClick()
  	end
	local upLabelSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
	upLabelSp:setContentSize(CCSizeMake(self.backSprie:getContentSize().width*0.8, 150))
	upLabelSp:setAnchorPoint(ccp(0,1))
	upLabelSp:setPosition(ccp(self.panelLineBg:getContentSize().width*0.2-10, self.panelLineBg:getContentSize().height-320))
	self.backSprie:addChild(upLabelSp)

	local strSize =45
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="tu" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="ru"then
    	strSize = 30

    end
	local giveStr = getlocal("rechargeGifts_giveLabel")
	local giveLabel = GetTTFLabel(giveStr,strSize)
	if G_getCurChoseLanguage() =="tu" then
		giveLabel = GetTTFLabelWrap(giveStr,strSize,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	end
	giveLabel:setColor(G_ColorYellow)
	giveLabel:setAnchorPoint(ccp(0,0.5))
	giveLabel:setPosition(ccp(90,upLabelSp:getContentSize().height*0.5))
	upLabelSp:addChild(giveLabel)

	local goldNumStr = acChongZhiYouLiVoApi:getRecMone()
    local getStrSize = 90
    if goldNumStr >=1000 and goldNumStr <=10000 then
    	getStrSize =80
    elseif goldNumStr >=10000 then
    	getStrSize =60
    end
    if (G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="tu" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="ru" )and goldNumStr >=1000 and goldNumStr <=10000 then
    	getStrSize = 50
    end
	local goldNumLabel = GetTTFLabel(goldNumStr,getStrSize)
	goldNumLabel:setColor(G_ColorYellowPro)
	goldNumLabel:setAnchorPoint(ccp(0,0.5))
	goldNumLabel:setPosition(ccp(100+giveLabel:getContentSize().width,upLabelSp:getContentSize().height*0.5-goldNumLabel:getContentSize().height*0.2))
	goldNumLabel:setRotation(-25)
	upLabelSp:addChild(goldNumLabel)

	local gemIcon= CCSprite:createWithSpriteFrameName("iconGold6.png")
	gemIcon:setAnchorPoint(ccp(0,0.5))
	local gemIconWidth = 90
	if G_getCurChoseLanguage() =="ru" then
		gemIconWidth =70
	end
    gemIcon:setPosition(ccp(gemIconWidth+giveLabel:getContentSize().width+goldNumLabel:getContentSize().width,upLabelSp:getContentSize().height*0.5))
    upLabelSp:addChild(gemIcon)

	local girlPosH
	if(G_isIphone5())then
		self.girlHeight=250
		girlPosH=self.panelLineBg:getContentSize().height-130
	else
		self.girlHeight=210
		girlPosH=self.panelLineBg:getContentSize().height-115
	end
    local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter_new.png")
	girlImg:setScale(self.girlHeight/girlImg:getContentSize().height)
	girlImg:setAnchorPoint(ccp(0.5,1))
	girlImg:setPosition(ccp(self.panelLineBg:getContentSize().width*0.2-10,girlPosH))
	self.panelLineBg:addChild(girlImg)

	local locaheight = 205
	local tvheight	 = 30
	if(G_isIphone5())then
		locaheight=245
		tvheight = 50
	end
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setPosition(ccp(self.panelLineBg:getContentSize().width*0.5,girlPosH-locaheight))
    self.panelLineBg:addChild(lineSp,4)

    local posX = 8
    if G_getCurChoseLanguage() == "ar" then
    	posX = 300
    end
    local ruleStr = getlocal("activity_ruleLabel")
    local ruleLabel = GetTTFLabel(ruleStr,35)
    ruleLabel:setColor(G_ColorGreen)
    ruleLabel:setAnchorPoint(ccp(0,1))
    ruleLabel:setPosition(ccp(posX,lineSp:getPositionY()-15))
    if G_getIphoneType() == G_iphoneX then
    	ruleLabel:setPosition(ccp(8,lineSp:getPositionY()-45))
    end
    self.panelLineBg:addChild(ruleLabel,1)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.backSprie:getContentSize().width-30,self.backSprie:getContentSize().height*0.4),nil)
    self.backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setPosition(ccp(19,self.backSprie:getContentSize().height*0.1-tvheight))
    self.tv:setAnchorPoint(ccp(0,0))
    self.backSprie:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(100)



    local adaH1 = 0

    if G_getIphoneType() == G_iphoneX then
    	adaH1 = 22
    else
    	adaH1 = 15
    end

    local lastStr = getlocal("activity_dayRecharge_todayMoney")
    local lastStrSize = 30
    if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="ru"then
    	lastStrSize =25
    end
    self.lastLabel = GetTTFLabel(lastStr,lastStrSize)
    self.lastLabel:setAnchorPoint(ccp(0,0.5))
    self.lastLabel:setPosition(ccp(self.panelLineBg:getContentSize().width*0.2,self.panelLineBg:getContentSize().height*0.1+30-adaH1))
    self.panelLineBg:addChild(self.lastLabel,1)

    local getStr = acChongZhiYouLiVoApi:getHadRechargeMone()
    self.getLabel = GetTTFLabel(getStr,30)
    self.getLabel:setAnchorPoint(ccp(0,0.5))
    self.getLabel:setPosition(ccp(self.lastLabel:getContentSize().width,self.lastLabel:getContentSize().height/2))
    self.lastLabel:addChild(self.getLabel,1)

	self.iconGold2=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.iconGold2:setAnchorPoint(ccp(0,0.5))
	self.getLabel:addChild(self.iconGold2,1) 
	self.iconGold2:setPosition(ccp(self.getLabel:getContentSize().width,self.getLabel:getContentSize().height/2))

	if acChongZhiYouLiVoApi:getRechargeMone() <=0 or  acChongZhiYouLiVoApi:getHadRechargeMone() <=0 then
		self.lastLabel:setVisible(false)
		self.getLabel:setVisible(false)
		self.iconGold2:setVisible(false)
	end

    local function rechargeCallback(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        --activityAndNoteDialog:closeAllDialog()
    	vipVoApi:showRechargeDialog(self.layerNum+1)
    end
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
    	adaH = 20
    end
    local rewardBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",rechargeCallback,nil,getlocal("recharge"),25,11)
    rewardBtn:setAnchorPoint(ccp(0.5,0))
    local rewardMenu=CCMenu:createWithItem(rewardBtn)
    rewardMenu:setPosition(ccp(self.panelLineBg:getContentSize().width*0.3,10+adaH))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.panelLineBg:addChild(rewardMenu,2)

    local function rewardBtnCallback( )
    	if acChongZhiYouLiVoApi:getHadRecTime()==false then
    		local function recBtnCallback(fn,data)
    			local ret,sData = base:checkServerData(data)
    			if ret == true then
	                local gold=playerVoApi:getGems()+acChongZhiYouLiVoApi:getRecMone()
	                playerVoApi:setGems(gold) --设置金币
	                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("rechargeGifts_recMone",{acChongZhiYouLiVoApi:getRecMone()}),30)
                    
                    acChongZhiYouLiVoApi:setHadRecTime()
                end
    		end
    		socketHelper:activeChongZhiYouLi(recBtnCallback)
    	else
	        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("rechargeGifts_hadRecMone"),30)
    	end
    end 
	self.lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",rewardBtnCallback,1,getlocal("activity_continueRecharge_reward"),25)
	self.lotteryBtn:setAnchorPoint(ccp(0.5,0))
	local lotteryMenu=CCMenu:createWithItem(self.lotteryBtn)
	lotteryMenu:setPosition(ccp(self.panelLineBg:getContentSize().width*0.7,10+adaH))
	lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.panelLineBg:addChild(lotteryMenu,2)
	self.lotteryBtn:setEnabled(false)

	if acChongZhiYouLiVoApi:getHadRechargeMone()> 0 then 
		self:refresh()
	end
end

function acChongZhiYouLiDialog:tick( )
	if acChongZhiYouLiVoApi:isToday() ==false then
		self:refresh()

	end
	if acChongZhiYouLiVoApi:getRechargeMone() ~= 0 and acChongZhiYouLiVoApi:getHadRechargeMone() >= acChongZhiYouLiVoApi:getRechargeMone() then
		self:refresh()
	end

	if acChongZhiYouLiVoApi.addRechargeTrue ==true then
		self:refresh()
	end
	if acChongZhiYouLiVoApi:getRechargeMone() ==0 and (acChongZhiYouLiVoApi:getHadRechargeMone()>0 or acChongZhiYouLiVoApi.addRechargeTrue ==true) then
		self:refresh()
	end
	if acChongZhiYouLiVoApi:getRechargeMone() ~= 0 and acChongZhiYouLiVoApi:getHadRechargeMone() < acChongZhiYouLiVoApi:getRechargeMone() then
		self:refresh()
	end
    local vo=acChongZhiYouLiVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    self:updateAcTime()
end

function acChongZhiYouLiDialog:updateAcTime()
    local acVo=acChongZhiYouLiVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acChongZhiYouLiDialog:refresh( )
	if acChongZhiYouLiVoApi:isToday() ==false then
		self.lastLabel:setVisible(false)
		self.getLabel:setVisible(false)
		self.iconGold2:setVisible(false)
		self.lotteryBtn:setEnabled(false)	
		acChongZhiYouLiVoApi:refreshData()
		acChongZhiYouLiVoApi:updateLastTime()
		--acChongZhiYouLiVoApi:setHadRecTime()
	end
	if acChongZhiYouLiVoApi:getRechargeMone() ~= 0 and acChongZhiYouLiVoApi:getHadRechargeMone() >= acChongZhiYouLiVoApi:getRechargeMone() then
		self.lotteryBtn:setEnabled(true)		
	end
	-- if acChongZhiYouLiVoApi:getRechargeMone() ~= 0 and acChongZhiYouLiVoApi:getHadRechargeMone() < acChongZhiYouLiVoApi:getRechargeMone() then
	-- 	--acChongZhiYouLiVo.hadRecTime=nil
	-- end
	if acChongZhiYouLiVoApi:getRechargeMone() ==0 and (acChongZhiYouLiVoApi.addRechargeTrue ==true or acChongZhiYouLiVoApi:getHadRechargeMone( )>0) then
		self.lotteryBtn:setEnabled(true)
		-- if acChongZhiYouLiVoApi:getHadRecTime() and acChongZhiYouLiVoApi:getHadRechargeMone() ==0 then
		-- 	--acChongZhiYouLiVo.hadRecTime=0
		-- end
	end

	if acChongZhiYouLiVoApi.addRechargeTrue ==true or acChongZhiYouLiVoApi:getHadRechargeMone()> 0 then
		tolua.cast(self.getLabel,"CCLabelTTF"):setString(acChongZhiYouLiVoApi:getHadRechargeMone())
		self.lastLabel:setVisible(true)
		self.getLabel:setVisible(true)
		self.iconGold2:setVisible(true)
		self.iconGold2:setPosition(ccp(self.getLabel:getContentSize().width,self.getLabel:getContentSize().height/2))
		acChongZhiYouLiVoApi.addRechargeTrue=false
	end	

end

function acChongZhiYouLiDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.backSprie:getContentSize().width-35,self.backSprie:getContentSize().height*0.4)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        self.cellHeight = self.backSprie:getContentSize().height*0.4

	local function bgClick()
  	end
	local upLabelSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
	upLabelSp:setContentSize(CCSizeMake(self.backSprie:getContentSize().width-40,self.backSprie:getContentSize().height*0.4))
	upLabelSp:setAnchorPoint(ccp(0,0))
	upLabelSp:setPosition(ccp(0,0))
	cell:addChild(upLabelSp)
	upLabelSp:setVisible(false)
		local PosW = 10
		local explainStr = getlocal("rechargeGifts_explain_1")
		local explainLabel1 = GetTTFLabelWrap(explainStr,30,CCSizeMake(self.backSprie:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		explainLabel1:setColor(G_ColorYellow)
		explainLabel1:setAnchorPoint(ccp(0,0.5))
		explainLabel1:setPosition(ccp(PosW,self.cellHeight-30))
		cell:addChild(explainLabel1,1)
		local str2PosHeight = self.cellHeight-120
		if G_getCurChoseLanguage() =="tu" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="ru" then
			str2PosHeight =self.cellHeight-150
		elseif G_getCurChoseLanguage() == "de" then
			str2PosHeight =self.cellHeight-135
		end
		local explainStr2 = getlocal("rechargeGifts_explain_2")
		local explainLabel2 = GetTTFLabelWrap(explainStr2,30,CCSizeMake(self.backSprie:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		explainLabel2:setColor(G_ColorYellow)
		explainLabel2:setAnchorPoint(ccp(0,0.5))
		explainLabel2:setPosition(ccp(PosW,str2PosHeight-10))
		cell:addChild(explainLabel2,1)

		local explainStr3 = getlocal("rechargeGifts_explain_3")
		local explainLabel3 = GetTTFLabelWrap(explainStr3,30,CCSizeMake(self.backSprie:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		explainLabel3:setColor(G_ColorYellow)
		explainLabel3:setAnchorPoint(ccp(0,0.5))
		local exStrSize3 = 240
		if G_getCurChoseLanguage() =="de" then
			exStrSize3 = 260
		elseif G_getCurChoseLanguage() =="tu" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="ru" then
			exStrSize3 =290
		elseif G_getCurChoseLanguage() =="en" then
			exStrSize3 =320
		end
		explainLabel3:setPosition(ccp(PosW,self.cellHeight-exStrSize3))
		cell:addChild(explainLabel3,1)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end