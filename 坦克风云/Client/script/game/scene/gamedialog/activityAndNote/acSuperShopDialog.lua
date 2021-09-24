--超级秒杀活动主面板
acSuperShopDialog=commonDialog:new()
function acSuperShopDialog:new()
	local nc={}
	nc.tab1=nil
	nc.tab2=nil
	nc.tab1Index=1
	nc.tab2Index=1
	nc.tab1Arr={}
	nc.tab2Arr={}
	nc.tv1=nil
	nc.tv2=nil
	nc.shopCfg1=nil
	nc.shopCfg2=nil
	nc.nextCfg1=nil
	nc.nextCfg2=nil
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acSuperShopDialog:resetTab()

	local index=0
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,G_VisibleSizeHeight - tabBtnItem:getContentSize().height/2 - 75)
		elseif index==1 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,G_VisibleSizeHeight - tabBtnItem:getContentSize().height/2 - 75)
		end
		if index==self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end 
		index=index+1
	end
	self.panelLineBg:setVisible(false)
	local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
	topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
	topBorder:setAnchorPoint(ccp(0,1))
	topBorder:setPosition(0,G_VisibleSizeHeight - 155)
	self.bgLayer:addChild(topBorder)

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/acSuperShopImage.plist")
	spriteController:addTexture("public/acSuperShopImage.png")
	spriteController:addPlist("public/acDouble11_NewImage.plist")
	spriteController:addTexture("public/acDouble11_NewImage.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	local function callback()
		self.requesting=false
		self:initTab(self.selectedTabIndex)
	end
	self.requesting=true
	acSuperShopVoApi:requestShop(callback)
	self.refreshTs=acSuperShopVoApi:getRefreshTime()
end

function acSuperShopDialog:resetForbidLayer()
	self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,410))
	self.topforbidSp:setAnchorPoint(ccp(0,1))
	self.topforbidSp:setPosition(0,G_VisibleSizeHeight)
	self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,40))
	self.bottomforbidSp:setAnchorPoint(ccp(0,0))
	self.bottomforbidSp:setPosition(0,0)
end

function acSuperShopDialog:tabClick(idx)
	if(self.requesting)then
		do return end
	end
	PlayEffect(audioCfg.mouseClick)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
			self:doUserHandler()            
		else
			v:setEnabled(true)
		end
	end
	if(idx==1)then
		if(self.tab2==nil)then
			self:initTab(1)
		elseif(self.tv2 and tolua.cast(self.tv2,"CCTableView"))then
			tolua.cast(self.tv2,"CCTableView"):reloadData()
		end
		self.tab1:setVisible(false)
		self.tab1:setPositionX(999333)
		self.tab2:setVisible(true)
		self.tab2:setPositionX(0)
	else
		if(self.tab1==nil)then
			self:initTab(0)
		elseif(self.tv1 and tolua.cast(self.tv1,"CCTableView"))then
			tolua.cast(self.tv1,"CCTableView"):reloadData()
		end
		self.tab1:setVisible(true)
		self.tab1:setPositionX(0)
		self.tab2:setVisible(false)
		self.tab2:setPositionX(999333)
	end
end

function acSuperShopDialog:initTab(index)
	if(self.requesting)then
		do return end
	end
	local tab=CCLayer:create()
	local tabArr=self["tab"..(index + 1).."Arr"]
	local vo=acSuperShopVoApi:getAcVo()
	self["shopCfg"..(index + 1)]=acSuperShopVoApi:getCurShopList(index)
	self["nextCfg"..(index + 1)]=acSuperShopVoApi:getNextShopList(index)
	self["tab"..(index + 1)]=tab
	local tabBg
	if(index==0)then
		local timeLb1=GetTTFLabel(getlocal("activity_timeLabel"),25)
		timeLb1:setColor(G_ColorGreen)
		timeLb1:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 195)
		self.tab1:addChild(timeLb1)
		local timeLb=GetTTFLabel(activityVoApi:getActivityTimeStr(vo.st, vo.acEt),25)
		timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 220))
		tab:addChild(timeLb)
		self.timeLb=timeLb
		self:updateAcTime()
		local function showInfo()
			if G_checkClickEnable()==false then
				do return end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end
			PlayEffect(audioCfg.mouseClick)
			local tabStr = {"\n",getlocal("activity_cjms_info"),"\n"}
			local tabColor = {nil,G_ColorYellow,nil}
			local td=smallDialog:new()
			local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
			sceneGame:addChild(dialog,self.layerNum + 1)
		end
		local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
		infoItem:setScale(0.8)
		local infoBtn = CCMenu:createWithItem(infoItem)
		infoBtn:setPosition(ccp(G_VisibleSizeWidth - 80,G_VisibleSizeHeight - 210))
		infoBtn:setTouchPriority(-(self.layerNum-1)*20-5)
		tab:addChild(infoBtn,1)
		tabBg=LuaCCScale9Sprite:createWithSpriteFrameName("greenBlackBg.png",CCRect(10,10,12,12),function ( ... )end)
	else
		self:refreshRecharge()
		tabBg=LuaCCScale9Sprite:createWithSpriteFrameName("blueBlackBg.png",CCRect(10,10,12,12),function ( ... )end)
		local function onLoadIcon(fn,icon)
			if(self and self.tab2 and tolua.cast(self.tab2,"CCLayer"))then
				icon:setScale(0.98)
				icon:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 388)
				self.tab2:addChild(icon,1)
			end
		end
		local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/starBg.jpg"),onLoadIcon)
	end
	tabBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 280))
	tabBg:setAnchorPoint(ccp(0,0))
	tabBg:setPosition(20,20)
	tab:addChild(tabBg)

	local countdownLb
	local status=acSuperShopVoApi:getShopStatus()
	local strSize2 ,subHeight= 17,272
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" then
		strSize2 ,subHeight= 25,287
	end
	if(status==0)then
		countdownLb=GetTTFLabel(getlocal("activity_double11_countdownStr").." "..GetTimeStr(acSuperShopVoApi:getRefreshTime() - base.serverTime),25)
	elseif(status==-1)then
		countdownLb=GetTTFLabel(getlocal("activity_cjms_shopOver"),25)
	else
		
		countdownLb=GetTTFLabel(getlocal("activity_cjms_countdown",{GetTimeStr(acSuperShopVoApi:getRefreshTime() - base.serverTime)}),strSize2)
	end
	countdownLb:setTag(101)
	countdownLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - subHeight)
	tab:addChild(countdownLb,10)

	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self["tv"..(index + 1)]=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 470),nil)
	self["tv"..(index + 1)]:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self["tv"..(index + 1)]:setPosition(30,40)
	tab:addChild(self["tv"..(index + 1)],2)
	self["tv"..(index + 1)]:setMaxDisToBottomOrTop(40)
	local function onClickSubTab(object,name,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(self.selectedTabIndex==0)then
			if(self.tab1Index==tag)then
				do return end
			end
		else
			if(self.tab2Index==tag)then
				do return end
			end
		end
		PlayEffect(audioCfg.mouseClick)
		self:switchSubTab(tag)
	end
	local tvUp=LuaCCScale9Sprite:createWithSpriteFrameName("blackBg1.png",CCRect(10,10,10,10),function ( ... )end)
	tvUp:setContentSize(CCSizeMake(80,120))
	tvUp:setAnchorPoint(ccp(0.5,1))
	tvUp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 335)
	tab:addChild(tvUp,1)
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("blackBg1.png",CCRect(10,10,10,10),function ( ... )end)
	tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50,G_VisibleSizeHeight - 460))
	tvBg:setAnchorPoint(ccp(0.5,0))
	tvBg:setPosition(G_VisibleSizeWidth/2,35)
	tab:addChild(tvBg,1)
	local lineBg=LuaCCScale9Sprite:createWithSpriteFrameName("blackBg1.png",CCRect(10,10,10,10),function ( ... )end)
	lineBg:setContentSize(CCSizeMake(400,70))
	lineBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 335)
	tab:addChild(lineBg,1)
	local downArrow=CCSprite:createWithSpriteFrameName("arrowGreen.png")
	downArrow:setScaleX(1.2)
	downArrow:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 400)
	tab:addChild(downArrow,1)
	local line=CCSprite:createWithSpriteFrameName("lineBgBlack.png")
	line:setScaleX(400/line:getContentSize().width)
	line:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 335)
	tab:addChild(line,2)
	local tabBg=CCSprite:createWithSpriteFrameName("roundBlackBg.png")
	tabBg:setPosition(G_VisibleSizeWidth/2 - 200,G_VisibleSizeHeight - 335)
	tab:addChild(tabBg,2)
	local tabBtn=LuaCCSprite:createWithSpriteFrameName("acRoundBg.png",onClickSubTab)
	tabBtn:setTag(1)
	tabArr[1]=tabBtn
	tabBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	tabBtn:setPosition(G_VisibleSizeWidth/2 - 200,G_VisibleSizeHeight - 335)
	tab:addChild(tabBtn,2)

	local titleFontSize=18
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        titleFontSize= 22
        
    end
	local titleStr,tabIcon=acSuperShopVoApi:getCurShopTitleAndPic(index)
	local titleLb=GetTTFLabelWrap(titleStr,titleFontSize,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleLb:setTag(11)
	titleLb:setAnchorPoint(ccp(0,0.5))
	titleLb:setPosition(tabBg:getContentSize().width,tabBtn:getContentSize().width/2)
	tabBtn:addChild(titleLb)
	tabIcon:setTag(12)
	tabIcon:setPosition(tabBtn:getContentSize().width/2,tabBtn:getContentSize().height/2)
	tabBtn:addChild(tabIcon)
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),onClickSubTab)
	titleBg:setTag(1)
	titleBg:setOpacity(0)
	titleBg:setTouchPriority(-(self.layerNum-1)*20-5)
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setContentSize(CCSizeMake(titleLb:getContentSize().width,70))
	titleBg:setPosition(titleLb:getPosition())
	tabBg:addChild(titleBg)
	local tabBg=CCSprite:createWithSpriteFrameName("roundBlackBg.png")
	tabBg:setPosition(G_VisibleSizeWidth/2 + 200,G_VisibleSizeHeight - 335)
	tab:addChild(tabBg,2)
	local nextLb=GetTTFLabel(getlocal("funcWillOpen"),23)
	nextLb:setPosition(G_VisibleSizeWidth/2 + 200,G_VisibleSizeHeight - 410)
	tab:addChild(nextLb,2)
	local tabBtn=LuaCCSprite:createWithSpriteFrameName("acRoundBg.png",onClickSubTab)
	tabBtn:setTag(2)
	tabArr[2]=tabBtn
	tabBtn:setColor(ccc3(100,100,100))
	tabBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	tabBtn:setPosition(G_VisibleSizeWidth/2 + 200,G_VisibleSizeHeight - 335)
	tab:addChild(tabBtn,2)
	local titleStr,tabIcon=acSuperShopVoApi:getNextShopTitleAndPic(index)
	local titleLb=GetTTFLabelWrap(titleStr,titleFontSize,CCSizeMake(110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	titleLb:setTag(11)
	titleLb:setAnchorPoint(ccp(1,0.5))
	titleLb:setColor(ccc3(100,100,100))
	titleLb:setPosition(0,tabBtn:getContentSize().width/2)
	tabBtn:addChild(titleLb)
	tabIcon:setTag(12)
	tabIcon:setColor(ccc3(100,100,100))
	tabIcon:setPosition(tabBtn:getContentSize().width/2,tabBtn:getContentSize().height/2)
	tabBtn:addChild(tabIcon)
	local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),onClickSubTab)
	titleBg:setTag(2)
	titleBg:setOpacity(0)
	titleBg:setTouchPriority(-(self.layerNum-1)*20-5)
	titleBg:setAnchorPoint(ccp(1,0.5))
	titleBg:setContentSize(CCSizeMake(titleLb:getContentSize().width,70))
	titleBg:setPosition(titleLb:getPosition())
	tabBg:addChild(titleBg)
	local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
	lockSp:setScale(0.5)
	lockSp:setAnchorPoint(ccp(1,0.5))
	lockSp:setPosition( - titleLb:getContentSize().width,tabBtn:getContentSize().height/2)
	tabBtn:addChild(lockSp)

	if(self.bgLayer and tolua.cast(self.bgLayer,"CCLayer"))then
		self.bgLayer:addChild(tab)
	end
end

function acSuperShopDialog:switchSubTab(index)
	local tabArr
	if(self.selectedTabIndex==0)then
		tabArr=self.tab1Arr
	else
		tabArr=self.tab2Arr
	end
	if(tabArr==nil or type(tabArr)~="table")then
		do return end
	end
	local curStatus=acSuperShopVoApi:getShopStatus()
	if((curStatus==-1 or acSuperShopVoApi:isLastShop()) and index==2)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_cjms_noNext"),30)
		do return end
	end
	local tv
	if(self.selectedTabIndex==0)then
		self.tab1Index=index
		tv=self.tv1
	else
		self.tab2Index=index
		tv=self.tv2
	end
	for k,v in pairs(tabArr) do
		local tabItem=tolua.cast(v,"CCSprite")
		if(tabItem==nil)then
			do return end
		end
		local tabColor
		if(k==index)then
			tabColor=G_ColorWhite
		else
			tabColor=ccc3(100,100,100)
		end
		tabItem:setColor(tabColor)
		for i=11,12 do
			local node
			if(i==11)then
				node=tolua.cast(tabItem:getChildByTag(i),"CCLabelTTF")
			else
				node=tolua.cast(tabItem:getChildByTag(i),"CCSprite")
			end
			node:setColor(tabColor)
		end
	end
	if(self.selectedTabIndex)then
		local tab=tolua.cast(self["tab"..(self.selectedTabIndex + 1)],"CCLayer")
		if(tab)then
			local lb=tolua.cast(tab:getChildByTag(101),"CCLabelTTF")
			if(lb and lb.setVisible)then
				if(index==1)then
					lb:setVisible(true)
				else
					lb:setVisible(false)
				end
			end
		end
	end
	if(tv and tolua.cast(tv,"CCTableView"))then
		tolua.cast(tv,"CCTableView"):reloadData()
	end
end

function acSuperShopDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local cfg
		if(self.selectedTabIndex==0)then
			if(self.tab1Index==1)then
				cfg=self.shopCfg1
			else
				cfg=self.nextCfg1
			end
		else
			if(self.tab2Index==1)then
				cfg=self.shopCfg2
			else
				cfg=self.nextCfg2
			end
		end
		if(cfg)then
			return math.ceil(SizeOfTable(cfg)/3)
		else
			return 0
		end
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth - 60,220)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local cfg
		local prefix
		if(self.selectedTabIndex==0)then
			if(self.tab1Index==2)then
				cfg=acSuperShopVoApi:getNextShopList(0)
			else
				cfg=self.shopCfg1
			end
			prefix="i"
		else
			if(self.tab2Index==2)then
				cfg=acSuperShopVoApi:getNextShopList(1)
			else
				cfg=self.shopCfg2
			end
			prefix="s"
		end
		local function onClickBuy(tag,object)
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			if self["tv"..(self.selectedTabIndex + 1)]:getScrollEnable()==true and self["tv"..(self.selectedTabIndex + 1)]:getIsScrolled()==true then
				do return end
			end
			if(self and self.bgLayer and tolua.cast(self.bgLayer,"CCLayer"))then
				if(tolua.cast(self.bgLayer,"CCLayer"):getParent()==nil)then
					do return end
				end
			end
			local id=prefix..tostring(tag)
			local itemCfg=cfg[id]
			local status1=acSuperShopVoApi:getShopStatus()
			if(status1==-1)then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_cjms_shopOver"),30)
				do return end
			end
			local function confirmBuy( ... )
				self.sellDialog=nil
				if(self==nil or self.bgLayer==nil)then
					do return end
				end
				if(tolua.cast(self.bgLayer,"CCLayer")==nil)then
					do return end
				end
				if(tolua.cast(self.bgLayer,"CCLayer"):getParent()==nil)then
					do return end
				end
				if(self["tab"..(self.selectedTabIndex + 1).."Index"]==2)then
					do return end
				end
				local canBuy=acSuperShopVoApi:checkCanBuy(self.selectedTabIndex,id)
				if(canBuy==1)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage14006"),30)
					do return end
				elseif(canBuy==2)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dailyAnswer_tab1_question_title1"),30)
					do return end
				elseif(canBuy==3)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_cjms_rechargeNotEnough"),30)
					do return end
				elseif(canBuy==4)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_cjms_only1"),30)
					do return end
				end
				local status2=acSuperShopVoApi:getShopStatus()
				if(status1~=status2)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_cjms_fail1"),30)
					do return end
				end
				if(playerVoApi:getGems()<itemCfg.g)then
					GemsNotEnoughDialog(nil,nil,itemCfg.g - playerVoApi:getGems(),self.layerNum + 1,itemCfg.g)
					do return end
				end
				local function callback(success)
					if(success)then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
						G_showRewardTip(FormatItem(itemCfg.r))
						if(self.selectedTabIndex)then
							self["shopCfg"..(self.selectedTabIndex + 1)]=acSuperShopVoApi:getCurShopList(self.selectedTabIndex)
							self["nextCfg"..(self.selectedTabIndex + 1)]=acSuperShopVoApi:getNextShopList(self.selectedTabIndex)
							local tv=self["tv"..(self.selectedTabIndex + 1)]
							if(tv and tolua.cast(tv,"LuaCCTableView"))then
								tv=tolua.cast(tv,"LuaCCTableView")
								local recordPoint = tv:getRecordPoint()
								tv:reloadData()
								tv:recoverToRecordPoint(recordPoint)
							end
						end
					else
						self:refreshShop()
					end
				end
				acSuperShopVoApi:buy(self.selectedTabIndex + 1,id,callback)
			end
			local function cancelCallback()
				self.sellDialog=nil
			end
			require "luascript/script/game/scene/gamedialog/activityAndNote/sellShowSureDialog"
			local td=sellShowSureDialog:new()
			local rewardCfg=FormatItem(itemCfg.r)[1]
			rewardCfg.pic=G_getItemIcon(rewardCfg,100,false)
			local leftStr
			if(self["tab"..(self.selectedTabIndex + 1).."Index"]==2)then
				leftStr=getlocal("confirm")
			end
			td:init(confirmBuy,cancelCallback,false,itemCfg.p,itemCfg.g,false,0,sceneGame,rewardCfg,self.layerNum+1,nil,nil,nil,nil,nil,nil,nil,true,nil,leftStr)
			self.sellDialog=td
		end
		local strSize2 = 18
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
  				strSize2 = 22
		end
		for i=1,3 do
			local id=prefix..tostring(idx*3 + i)
			local itemCfg=cfg[id]
			if(itemCfg)then
				local rewardCfg=FormatItem(itemCfg.r)
				rewardCfg=rewardCfg[1]
				local menuSpName
				if(self.selectedTabIndex==0)then
					menuSpName="superShopBg1.png"
				else
					menuSpName="superShopBg2.png"
				end
				local menuSp1=CCSprite:createWithSpriteFrameName(menuSpName)
				local menuSp2=CCSprite:createWithSpriteFrameName(menuSpName)
				local menuSp3=GraySprite:createWithSpriteFrameName(menuSpName)
				local upSp=CCSprite:createWithSpriteFrameName("superShopBg_down.png")
				upSp:setAnchorPoint(ccp(0,0))
				menuSp2:addChild(upSp)
				local itemBg=CCMenuItemSprite:create(menuSp1,menuSp2,menuSp3)
				itemBg:setTag(idx*3 + i)
				itemBg:registerScriptTapHandler(onClickBuy)
				local itemMenu=CCMenu:createWithItem(itemBg)
				itemMenu:setTouchPriority(-(self.layerNum-1)*20-1)
				itemMenu:setAnchorPoint(ccp(0.5,0))
				itemMenu:setPosition((G_VisibleSizeWidth - 60)/6 + (G_VisibleSizeWidth - 60)/3*(i - 1),itemBg:getContentSize().height/2)
				cell:addChild(itemMenu)
				local icon=G_getItemIcon(rewardCfg,100,false,self.layerNum + 1,nil,nil,nil,nil,nil,nil,true)
				icon:setPosition(itemBg:getContentSize().width/2,138)
				itemBg:addChild(icon)
				local numLb=GetTTFLabel("×"..rewardCfg.num,23)
				numLb:setAnchorPoint(ccp(1,0))
				numLb:setPosition(itemBg:getContentSize().width/2 + 45,93)
				itemBg:addChild(numLb)
				local redBg=CCSprite:createWithSpriteFrameName("saleRedBg.png")
				redBg:setPosition(itemBg:getContentSize().width/2 + 40,168)
				redBg:setRotation(20)
				itemBg:addChild(redBg)
				local discount=100 - itemCfg.g/itemCfg.p*100
				local discountLb=GetTTFLabel("-"..G_keepNumber(discount,0).."%",20)
				discountLb:setPosition(redBg:getContentSize().width/2,redBg:getContentSize().height/2)
				redBg:addChild(discountLb)
				local leftNum
				if(self["tab"..tostring(self.selectedTabIndex + 1).."Index"]==2)then
					leftNum=itemCfg.bn
				else
					leftNum=acSuperShopVoApi:getLeftNum(self.selectedTabIndex,id)
				end
				local numLb
				if(leftNum==0)then
					numLb=GetTTFLabel(getlocal("activity_double11_buyEndNums"),22)
				else
					numLb=GetTTFLabel(getlocal("activity_double11_lastNums",{leftNum}),strSize2)
				end
				numLb:setColor(G_ColorYellowPro)
				numLb:setPosition(itemBg:getContentSize().width/2,63)
				itemBg:addChild(numLb)
				local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
				iconGold:setAnchorPoint(ccp(0,0.5))
				iconGold:setPosition(10,20)
				itemBg:addChild(iconGold)
				local originPriceLb=GetTTFLabel(itemCfg.p,25)
				originPriceLb:setColor(G_ColorRed)
				originPriceLb:setAnchorPoint(ccp(0,0.5))
				originPriceLb:setPosition(15 + iconGold:getContentSize().width,20)
				itemBg:addChild(originPriceLb)
				local lineWhite=CCSprite:createWithSpriteFrameName("white_line.png")
				lineWhite:setColor(G_ColorRed)
				lineWhite:setScale((originPriceLb:getContentSize().width + 10)/lineWhite:getContentSize().width)
				lineWhite:setPosition(originPriceLb:getPositionX() + originPriceLb:getContentSize().width/2,20)
				itemBg:addChild(lineWhite)
				local priceLb=GetTTFLabel(itemCfg.g,25)
				priceLb:setAnchorPoint(ccp(1,0.5))
				priceLb:setPosition(itemBg:getContentSize().width - 10,20)
				itemBg:addChild(priceLb)
				if(self["tab"..tostring(self.selectedTabIndex + 1).."Index"]==1)then
					local canBuy=acSuperShopVoApi:checkCanBuy(self.selectedTabIndex,id)
					local curStatus=acSuperShopVoApi:getShopStatus()
					if(canBuy==1 or canBuy==4 or curStatus==-1)then
						local function showTip()
							if G_checkClickEnable()==false then
								do return end
							else
								base.setWaitTime=G_getCurDeviceMillTime()
							end
							if self["tv"..(self.selectedTabIndex + 1)]:getScrollEnable()==true and self["tv"..(self.selectedTabIndex + 1)]:getIsScrolled()==true then
								do return end
							end
							if(curStatus==-1)then
								smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_cjms_shopOver"),30)
							elseif(canBuy==1)then
								smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_cjms_allClear",{rewardCfg.name}),30)
							else
								smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_cjms_only1"),30)
							end
						end
						local blackBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),showTip)
						blackBg:setTouchPriority(-(self.layerNum-1)*20-2)
						blackBg:setContentSize(itemBg:getContentSize())
						blackBg:setAnchorPoint(ccp(0,0))
						blackBg:setPosition(0,0)
						blackBg:setOpacity(100)
						itemBg:addChild(blackBg)
					end
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

function acSuperShopDialog:tick()
	self:updateAcTime()
	if(self.selectedTabIndex and self["tab"..(self.selectedTabIndex + 1)])then
		local tab=tolua.cast(self["tab"..(self.selectedTabIndex + 1)],"CCLayer")
		if(tab)then
			local lb=tolua.cast(tab:getChildByTag(101),"CCLabelTTF")
			if(lb)then
				local status=acSuperShopVoApi:getShopStatus()
				if(status==0)then
					lb:setString(getlocal("activity_double11_countdownStr").." "..GetTimeStr(acSuperShopVoApi:getRefreshTime() - base.serverTime))
				elseif(status==-1)then
					lb:setString(getlocal("activity_cjms_shopOver"))
				else
					lb:setString(getlocal("activity_cjms_countdown",{GetTimeStr(acSuperShopVoApi:getRefreshTime() - base.serverTime)}))
				end
			end
		end
	end
	if(base.serverTime>=self.refreshTs)then
		self.refreshTs=base.serverTime + 60
		self:refreshShop()
	end
	local vo=acSuperShopVoApi:getAcVo()
	if(vo==nil or (vo.et and activityVoApi:isStart(vo)==false))then
		self:close()
	end
end

function acSuperShopDialog:refreshShop()
	for i=1,2 do
		local tabArr=self["tab"..i.."Arr"]
		for k,v in pairs(tabArr) do
			local tabBtn=tolua.cast(v,"LuaCCSprite")
			if(tabBtn)then
				local titleLb=tolua.cast(tabBtn:getChildByTag(11),"CCLabelTTF")
				local tabIcon=tolua.cast(tabBtn:getChildByTag(12),"CCSprite")
				local titleStr,newIcon
				if(k==1)then
					titleStr,newIcon=acSuperShopVoApi:getCurShopTitleAndPic(1)
				else
					titleStr,newIcon=acSuperShopVoApi:getNextShopTitleAndPic(1)
				end
				if(titleLb)then
					titleLb:setString(titleStr)
				end
				if(tabIcon)then
					tabIcon:removeFromParentAndCleanup(true)
				end
				newIcon:setTag(12)
				newIcon:setPosition(tabBtn:getContentSize().width/2,tabBtn:getContentSize().height/2)
				tabBtn:addChild(newIcon)
			end
		end
	end
	self:refreshRecharge()
	self.requesting=true
	local function callback()
		self.refreshTs=acSuperShopVoApi:getRefreshTime()
		self.requesting=false
		self.shopCfg1=acSuperShopVoApi:getCurShopList(0)
		self.shopCfg2=acSuperShopVoApi:getCurShopList(1)
		self.nextCfg1=acSuperShopVoApi:getNextShopList(0)
		self.nextCfg2=acSuperShopVoApi:getNextShopList(1)
		if(self.selectedTabIndex)then
			local tv=self["tv"..(self.selectedTabIndex + 1)]
			if(tv and tolua.cast(tv,"CCTableView"))then
				tolua.cast(tv,"CCTableView"):reloadData()
			end
		end
	end
	acSuperShopVoApi:requestShop(callback)
end

function acSuperShopDialog:refreshRecharge()
	if(self.tab2 and tolua.cast(self.tab2,"CCLayer"))then
		for i=201,203 do
			local node=self.tab2:getChildByTag(i)
			if(node)then
				node=tolua.cast(node,"CCNode")
				node:removeFromParentAndCleanup(true)
			end
		end
		if(acSuperShopVoApi:checkRechargeEnabled())then
			local rechargeBg=CCSprite:createWithSpriteFrameName("greenBg1.png")
			rechargeBg:setTag(201)
			rechargeBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 210)
			self.tab2:addChild(rechargeBg)
			local rechargeLb=GetTTFLabel(getlocal("activity_cjms_rechargeEnough"),25)
			rechargeLb:setTag(202)
			rechargeLb:setColor(G_ColorYellowPro)
			rechargeLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 210)
			self.tab2:addChild(rechargeLb)
		else
			local rechargeBg=LuaCCScale9Sprite:createWithSpriteFrameName("newTitlesDesBg.png",CCRect(50,20,1,1),function ( ... )end)
			rechargeBg:setTag(201)
			rechargeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,100))
			rechargeBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 210)
			self.tab2:addChild(rechargeBg)
			local vo=acSuperShopVoApi:getAcVo()
			local rechargeLb=GetTTFLabel(getlocal("activity_openyear_recharge_des",{acSuperShopVoApi:getTodayRecharge().."/"..vo.rechargeLimit}),25)
			rechargeLb:setTag(202)
			rechargeLb:setAnchorPoint(ccp(0,0.5))
			rechargeLb:setPosition(50,G_VisibleSizeHeight - 210)
			self.tab2:addChild(rechargeLb)
			local function onGotoRecharge()
				if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				PlayEffect(audioCfg.mouseClick)
				activityAndNoteDialog:closeAllDialog()
				vipVoApi:showRechargeDialog(self.layerNum - 1)
			end
			local rechargeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onGotoRecharge,11,getlocal("recharge"),25,12)
			rechargeItem:setScale(0.8)
			local rechargeBtn=CCMenu:createWithItem(rechargeItem)
			rechargeBtn:setTag(203)
			rechargeBtn:setTouchPriority(-(self.layerNum-1)*20-5)
			rechargeBtn:setPosition(G_VisibleSizeWidth - 130,G_VisibleSizeHeight - 210)
			self.tab2:addChild(rechargeBtn)
		end
	end
end

function acSuperShopDialog:updateAcTime()
    local acVo=acSuperShopVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acSuperShopDialog:initTableView()
end

function acSuperShopDialog:dispose()
	self.tab1=nil
	self.tab2=nil
	if(self.sellDialog)then
		if(self.sellDialog.bgLayer and self.sellDialog.close and type(self.sellDialog.close)=="function")then
			self.sellDialog:close()
		end
		self.sellDialog=nil
	end
	spriteController:removePlist("public/acSuperShopImage.plist")
	spriteController:removeTexture("public/acSuperShopImage.png")
    spriteController:removePlist("public/acDouble11_NewImage.plist")
    spriteController:removeTexture("public/acDouble11_NewImage.png")
end