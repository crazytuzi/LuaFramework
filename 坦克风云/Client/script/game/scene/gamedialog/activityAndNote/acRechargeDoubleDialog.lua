acRechargeDoubleDialog=commonDialog:new()

function acRechargeDoubleDialog:new(parent,layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.parent=parent
	self.layerNum=layerNum
	--iphoneX适配全局控制
	self.adaH = 0
	if G_getIphoneType() == G_iphoneX then
		self.adaH = 205
	end
	return nc
end

function acRechargeDoubleDialog:initTableView()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconGoldImage.plist")
	self:initBackground()
	--德国movga支付分语言特殊处理，调用底层获取语言
	if(G_curPlatName()=="11"or G_curPlatName()=="androidsevenga")then
		local tmpTb={}
		tmpTb["action"]="customAction"
		tmpTb["parms"]={}
		tmpTb["parms"]["value"]="getCurrency"
		local cjson=G_Json.encode(tmpTb)
		self.moneyName=G_accessCPlusFunction(cjson)
		if(self.moneyName~="EUR" and self.moneyName~="CHF")then
			self.moneyName="EUR"
		end
	else
		self.moneyName=GetMoneyName()
	end
	self.storeCfg=G_getPlatStoreCfg()
	local hd= LuaEventHandler:createHandler(function ()end)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight/2+60-110),nil)
	local function callback()
		self:realInitTableView()
	end
	acRechargeDoubleVoApi:init(callback)
end

function acRechargeDoubleDialog:realInitTableView()
	local function callback(...)
		return self:eventHandler(...)
	end
	--iphoneX适配 加高tv的整体高度
	local hd= LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight/2+60-110+self.adaH),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(30,110))
	self.tv:setMaxDisToBottomOrTop(110)
	self.bgLayer:addChild(self.tv)
end

function acRechargeDoubleDialog:initBackground()
	local strSize3,posX2 = 18,70
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="tw" then
            strSize3,posX2=23,50
    end
	local timeTime = GetTTFLabel(getlocal("activity_timeLabel"),28)
	timeTime:setAnchorPoint(ccp(0.5,1))
	timeTime:setColor(G_ColorYellowPro)
	timeTime:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-95))
	self.bgLayer:addChild(timeTime)

	local timeLb=GetTTFLabel(acRechargeDoubleVoApi:getTimeStr(),25)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-128))
	self.bgLayer:addChild(timeLb)
	self.timeLb=timeLb
	self:updateAcTime()
	
	local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter_new.png")
	girlImg:setAnchorPoint(ccp(0,0))
	girlImg:setPosition(ccp(20,G_VisibleSizeHeight/2+60))
	girlImg:setScale((G_VisibleSizeHeight/2-85)/girlImg:getContentSize().height*0.6)
	if G_getIphoneType() == G_iphoneX then
		girlImg:setPosition(ccp(20,G_VisibleSizeHeight/2+60+210))
		girlImg:setScale(0.85)
	end
	self.bgLayer:addChild(girlImg,2)

	local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	girlDescBg:setContentSize(CCSizeMake(410,(G_VisibleSizeHeight/2-85)*0.6-60))
	girlDescBg:setAnchorPoint(ccp(0,0))
	girlDescBg:setPosition(200,G_VisibleSizeHeight/2+90)
	if G_getIphoneType() == G_iphoneX then
		girlDescBg:setContentSize(CCSizeMake(410,(G_VisibleSizeHeight/2-85)*0.6-60-125))
		girlDescBg:setAnchorPoint(ccp(0,0))
		girlDescBg:setPosition(200,G_VisibleSizeHeight/2+90+225)
	end
	self.bgLayer:addChild(girlDescBg,1)

	local descTv=G_LabelTableView(CCSize(girlDescBg:getContentSize().width-100,girlDescBg:getContentSize().height-20),getlocal("activity_rechargeDouble_desc"),25,kCCTextAlignmentCenter)
	descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	descTv:setAnchorPoint(ccp(0,0))
	descTv:setPosition(ccp(posX2,10))
	girlDescBg:addChild(descTv,2)
	descTv:setMaxDisToBottomOrTop(50)

	--德国的第三方支付特殊处理，也要有双倍,加一个页签单独显示第三方支付的档位
	-- if(vipVoApi:checkThirdPayExists())then
	-- 	girlImg:setPositionY(girlImg:getPositionY() + 20)
	-- 	girlDescBg:setPositionY(girlDescBg:getPositionY() + 20)
	-- 	descTv:setPositionY(descTv:getPositionY() + 20)
	-- 	local tab1,tab2
	-- 	local function onSwitchTab(tag,object)
	-- 		if G_checkClickEnable()==false then
	-- 			do return end
	-- 		else
	-- 			base.setWaitTime=G_getCurDeviceMillTime()
	-- 		end
	-- 		if(tag and tag>0)then
	-- 			if(tag==2)then
	-- 				self.storeCfg=platCfg.platCfgStoreCfg3[G_curPlatName()]
	-- 				tab1:setEnabled(true)
	-- 				tab2:setEnabled(false)
	-- 			else
	-- 				self.storeCfg=G_getPlatStoreCfg()
	-- 				tab1:setEnabled(false)
	-- 				tab2:setEnabled(true)
	-- 			end
	-- 			if(self.tv)then
	-- 				self.tv:reloadData()
	-- 			end
	-- 		end
	-- 	end
	-- 	tab1=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
	-- 	tab1:setTag(1)
	-- 	tab1:registerScriptTapHandler(onSwitchTab)
	-- 	local tabLb=GetTTFLabel(getlocal("recharge"),23)
	-- 	tabLb:setPosition(getCenterPoint(tab1))
	-- 	tab1:addChild(tabLb)
	-- 	tab1:setEnabled(false)
	-- 	local tabBtn1=CCMenu:createWithItem(tab1)
	-- 	tabBtn1:setTouchPriority(-(self.layerNum-1)*20-5)
	-- 	tabBtn1:setPosition(G_VisibleSizeWidth/2 + 20,G_VisibleSizeHeight/2 + 60 + 23)
	-- 	self.bgLayer:addChild(tabBtn1,3)
	-- 	tab2=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
	-- 	tab2:setTag(2)
	-- 	tab2:registerScriptTapHandler(onSwitchTab)
	-- 	local tabLb=GetTTFLabelWrap(getlocal("otherMethodForRecharge"),strSize3,CCSizeMake(tab2:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- 	tabLb:setPosition(getCenterPoint(tab2))
	-- 	tab2:addChild(tabLb)
	-- 	local tabBtn2=CCMenu:createWithItem(tab2)
	-- 	tabBtn2:setTouchPriority(-(self.layerNum-1)*20-5)
	-- 	tabBtn2:setPosition(G_VisibleSizeWidth/2 + 160,G_VisibleSizeHeight/2 + 60 + 23)
	-- 	self.bgLayer:addChild(tabBtn2,3)
	-- end

	local function showInfo()
		local tabStr={"\n",getlocal("activity_rechargeDouble_info2"),"\n",getlocal("activity_rechargeDouble_info"),"\n",getlocal("activityDescription"),"\n"}
		local tabColor={nil,G_ColorRed,nil,G_ColorWhite,nil,G_ColorGreen,nil}
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setAnchorPoint(ccp(0.5,1))
	infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,G_VisibleSizeHeight-120))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(infoBtn)

	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function ( ... )	end)
	tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight/2+60-110))
	if G_getIphoneType() == G_iphoneX then
		tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight/2+60+100))
	end
	tvBg:setAnchorPoint(ccp(0.5,0))
	tvBg:setPosition(ccp(G_VisibleSizeWidth/2,110))
	self.bgLayer:addChild(tvBg)

	local function onGotoRecharge()
		self:close()
		local function onShowAccessory()
            vipVoApi:showRechargeDialog(self.layerNum+1)
		end
		local callFunc=CCCallFunc:create(onShowAccessory)
		local delay=CCDelayTime:create(0.4)
		local acArr=CCArray:create()
		acArr:addObject(delay)
		acArr:addObject(callFunc)
		local seq=CCSequence:create(acArr)
		sceneGame:runAction(seq)
	end
	local rechargeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onGotoRecharge,2,getlocal("recharge"),25)
	rechargeItem:setAnchorPoint(ccp(0.5,0))
	local rechargeBtn=CCMenu:createWithItem(rechargeItem)
	rechargeBtn:setAnchorPoint(ccp(0.5,0))
	rechargeBtn:setPosition(ccp(G_VisibleSizeWidth/2,30))
	rechargeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.panelLineBg:setVisible(false)
	self.bgLayer:addChild(rechargeBtn)
end

function acRechargeDoubleDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.storeCfg["gold"])
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-60,130)
		return tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local mType=self.storeCfg["moneyType"][self.moneyName]
		local mPrice=self.storeCfg["money"][self.moneyName][idx+1]
        local moneyStr=getlocal("activity_rechargeDouble_rechargeSingle",{mType..mPrice})
        if G_curPlatName()=="13" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="0" or G_isKakao() then
            moneyStr =getlocal("activity_rechargeDouble_rechargeSingle",{mPrice..mType})
        end
		local priceLb=GetTTFLabel(moneyStr,25)
		priceLb:setAnchorPoint(ccp(0,0))
		priceLb:setPosition(ccp(10,90))
		priceLb:setColor(G_ColorGreen)
		cell:addChild(priceLb)
		local getLb=GetTTFLabel(getlocal("activity_rechargeDouble_get"),25)
		getLb:setAnchorPoint(ccp(0,0))
		getLb:setPosition(ccp(10,50))
		cell:addChild(getLb)
		local rewardLb=GetTTFLabel(getlocal("activity_rechargeDouble_reward"),25)
		rewardLb:setAnchorPoint(ccp(0,0))
		rewardLb:setPosition(ccp(10,10))
		cell:addChild(rewardLb)
		local lbWidth1=getLb:getContentSize().width
		local lbWidth2=rewardLb:getContentSize().width
		local maxWidth
		if(lbWidth2>lbWidth1)then
			maxWidth=lbWidth2
		else
			maxWidth=lbWidth1
		end
		local moneyLb=GetTTFLabel(self.storeCfg["gold"][idx+1],25)
		moneyLb:setAnchorPoint(ccp(0,0))
		moneyLb:setPosition(ccp(15+maxWidth,50))
		moneyLb:setColor(G_ColorYellowPro)
		cell:addChild(moneyLb)
		local rewardMoneyLb=GetTTFLabel(self.storeCfg["gold"][idx+1],25)
		rewardMoneyLb:setAnchorPoint(ccp(0,0))
		rewardMoneyLb:setPosition(ccp(15+maxWidth,10))
		rewardMoneyLb:setColor(G_ColorYellowPro)
		cell:addChild(rewardMoneyLb)

        local goldIconPosWidth=(G_VisibleSizeWidth-60)/2
        if G_getCurChoseLanguage() == "ru" or G_getCurChoseLanguage() =="vi" then
            goldIconPosWidth=goldIconPosWidth+50
        end
		local goldIcon=CCSprite:createWithSpriteFrameName("iconGold"..tostring(6-idx)..".png")
		if(goldIcon==nil)then
			goldIcon=CCSprite:createWithSpriteFrameName("iconGold1.png")
		end
		goldIcon:setAnchorPoint(ccp(0.5,0))
		goldIcon:setPosition(ccp(goldIconPosWidth,10))
		cell:addChild(goldIcon)
		local function onGetReward(tag,object)
			local gem=tag-518
			self:getReward(gem)
		end
		local rechargeSize=SizeOfTable(self.storeCfg["gold"])
		local status=acRechargeDoubleVoApi:getChargeStatus("p"..self.storeCfg["gold"][idx+1])
		local statusSP
		if(status<0)then
			statusSP=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
		elseif(status>0)then
			local statusItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onGetReward,2,getlocal("daily_scene_get"),25)
			statusItem:setTag(518+tonumber(self.storeCfg["gold"][idx+1]))
			statusItem:setScale(0.8)
			statusSP=CCMenu:createWithItem(statusItem)
			statusSP:setTouchPriority(-(self.layerNum-1)*20-4)
		else
			statusSP=GetTTFLabelWrap(getlocal("activity_dayRecharge_no"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		end
		statusSP:setPosition(ccp(G_VisibleSizeWidth-60-100,65))
		cell:addChild(statusSP)
		if(idx<rechargeSize-1)then
			local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png")
			lineSP:setAnchorPoint(ccp(0.5,0.5))
			lineSP:setScaleX(G_VisibleSizeWidth/lineSP:getContentSize().width)
			lineSP:setScaleY(1.2)
			lineSP:setPosition(ccp((G_VisibleSizeWidth-60)/2,0))
			cell:addChild(lineSP)
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

function acRechargeDoubleDialog:getReward(gem)
	local type="p"..gem
	local function callback()
		local str=getlocal("daily_lotto_tip_10")
		str=str..getlocal("gem").." x"..gem

		local name,pic,desc,id,index,eType,equipId,bgname = getItem("gem","u")
		local num=gem
		local award={type="u",key="gem",pic=pic,name=name,num=num,desc=desc,id=id,bgname=bgname}
		local reward={award}

		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30,nil,nil,reward)
		self.tv:reloadData()
	end
	acRechargeDoubleVoApi:getReward(type,callback)
end

function acRechargeDoubleDialog:tick()
	self:updateAcTime()
end

function acRechargeDoubleDialog:updateAcTime()
    local acVo=acRechargeDoubleVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acRechargeDoubleDialog:dispose()
end