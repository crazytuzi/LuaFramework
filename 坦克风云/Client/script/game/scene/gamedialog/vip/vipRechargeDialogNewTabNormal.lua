vipRechargeDialogNewTabNormal={}

function vipRechargeDialogNewTabNormal:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.vipRechargeLabel=nil
	self.firstRechargeLabel=nil
	self.tv=nil
	self.layerNum=nil
	self.gems=0
	
	self.selectIndex=2
	self.vipExp=-1
	self.vipDescLabel=nil
	self.gotoVipBtn=nil
	self.rechargeBtn=nil
	self.isFirstRecharge=false
	self.topforbidSp=nil 	--顶端遮挡层
	self.bottomforbidSp=nil --底部遮挡层
	self.vipLevel=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconGoldImage.plist")
	return nc
end

function vipRechargeDialogNewTabNormal:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()

	local buygems=playerVoApi:getBuygems()
	if buygems==0 then
		self.isFirstRecharge=true
	elseif buygems>0 then
		self.isFirstRecharge=false
	end
	
	local hotSellCfg=playerCfg.recharge.hotSell
	self.selectIndex=tonumber(hotSellCfg[1])
	
	self.vipLevel=playerVoApi:getVipLevel()
	self:doUserHandler()
	self:initTableView()
	
	local function forbidClick()
	end
	local capInSet1 = CCRect(20, 20, 10, 10);
	self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet1,forbidClick)
	self.topforbidSp:setTouchPriority(-(layerNum-1)*20-3)
	self.topforbidSp:setAnchorPoint(ccp(0,0))
	self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet1,forbidClick)
	self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-3)
	self.bottomforbidSp:setAnchorPoint(ccp(0,0))
	local tvX,tvY=self.tv:getPosition()
	local topY=tvY+self.tv:getViewSize().height
	local topHeight=G_VisibleSizeHeight-topY
	self.topforbidSp:setContentSize(CCSize(G_VisibleSizeWidth,topHeight))
	self.topforbidSp:setPosition(0,topY)
	self.bgLayer:addChild(self.topforbidSp)
	self.bgLayer:addChild(self.bottomforbidSp)
	self:resetForbidLayer()
	self.topforbidSp:setVisible(false)
	self.bottomforbidSp:setVisible(false)

	if G_curPlatName()=="androidlongzhong" or G_curPlatName()=="androidlongzhong2" or G_curPlatName()=="efunandroid360" or (G_curPlatName()=="efunandroidtw" and G_Version~=nil and G_Version>=2) then
		do
			return nil
		end
	end
    if G_getPlatAppID()==10315 or G_getPlatAppID()==10215 or G_getPlatAppID()==10615 or G_getPlatAppID()==11815  or G_getPlatAppID()==1028 then
        local url="http://tank-android-01.raysns.com/tankheroclient/clickpage.php?uid="..(playerVoApi:getUid()==nil and 0 or playerVoApi:getUid()).."&appid="..G_getPlatAppID().."&tm="..base.serverTime.."&tp=page"
        HttpRequestHelper:sendAsynHttpRequest(url,"")
        print("发送了*****",url)

    end
	return self.bgLayer
end
--顶部和底部的遮挡层
function vipRechargeDialogNewTabNormal:resetForbidLayer()
   local tvX,tvY=self.tv:getPosition()
   self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,tvY))
end

--设置对话框里的tableView
function vipRechargeDialogNewTabNormal:initTableView()
	local function callBack(...)
		return self:eventHandler(...)
	end
	local tvHight
	if G_curPlatName()=="androiduc" or G_curPlatName()=="androidmuzhiwan" then
		tvHight = G_VisibleSizeHeight-410
		local goldChargeLabel = GetTTFLabel(getlocal("chargeToGold",{1,8}),40)
		goldChargeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,125))
		self.bgLayer:addChild(goldChargeLabel,1)
	elseif G_curPlatName()=="5" or G_curPlatName()=="45" or G_curPlatName()=="58" then
		tvHight = G_VisibleSizeHeight-410
		local goldChargeLabel = GetTTFLabel(getlocal("uidIs",{playerVoApi:getUid()}),40)
		goldChargeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,125))
		self.bgLayer:addChild(goldChargeLabel,1)
	else
		tvHight = G_VisibleSizeHeight-360
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,tvHight),nil)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0.5,1))
	self.tv:setPosition(ccp(10,90+(G_VisibleSizeHeight-350-tvHight)))

	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(110)
end

function vipRechargeDialogNewTabNormal:initFirstRecharge()
	local firstRechargeBg = CCSprite:createWithSpriteFrameName("ActivityBg.png")

	local titleLable = GetTTFLabel(getlocal("firstRechargeReward"),28)
	titleLable:setPosition(ccp(firstRechargeBg:getContentSize().width/2,firstRechargeBg:getContentSize().height-20))
	firstRechargeBg:addChild(titleLable,1)
	local firstGift=playerCfg.recharge.firstChargeGift
	local giftData=FormatItem(firstGift,true)
	local tempHeight = 0
	for k,v in pairs(giftData) do
		if v and v.pic and v.name then
			local awidth = k*(130+15)-37-27
			local aheight =0
			if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="tw" then
				aheight=35
			else
				aheight = 65
			end
			local function showInfoHandler()
				if G_checkClickEnable()==false then
					do
						return
					end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				if v and v.name and v.pic and v.num and v.desc then
					if v.key=="gems" or v.key=="gem" then
					else
						propInfoDialog:create(sceneGame,v,self.layerNum+1)
					end
				end
			end
			local icon = LuaCCSprite:createWithSpriteFrameName(v.pic,showInfoHandler)
			icon:setAnchorPoint(ccp(0.5,0))
			icon:setPosition(ccp(awidth,aheight+40))
			firstRechargeBg:addChild(icon,1)
			if icon:getContentSize().width>100 then
				icon:setScaleX(100/150)
				icon:setScaleY(100/150)
			end
			icon:setTouchPriority(-(self.layerNum-1)*20-2)

			local nameLable = GetTTFLabelWrap(v.name.." x"..v.num,25,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			if k==1 then
				nameLable = GetTTFLabelWrap(getlocal("doubleGems"),25,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			end
			nameLable:setAnchorPoint(ccp(0.5,1))
			nameLable:setPosition(ccp(awidth,aheight+40))
			firstRechargeBg:addChild(nameLable,1)
				
			if v.key=="gems" or v.key=="gem" then
				G_addRectFlicker(icon,1.4,1.4)
			end

			nameLable:setColor(G_ColorYellowPro)
			if tempHeight<aheight+35+nameLable:getContentSize().height then
				tempHeight = aheight+35+nameLable:getContentSize().height
			end
		end
	end
	return firstRechargeBg
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function vipRechargeDialogNewTabNormal:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local sortCfg=playerCfg.recharge.indexSort
		return SizeOfTable(sortCfg)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,120)
		if self.isFirstRecharge==true then
			if idx==0 then
				tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,275+120)
			end
		end
		return tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		if self.isFirstRecharge==true then
			if idx==0 then
				local firstRechargeBg=self:initFirstRecharge()
				firstRechargeBg:setAnchorPoint(ccp(0,0))
				firstRechargeBg:setPosition(ccp(10,130))
				cell:addChild(firstRechargeBg,1)
			end
		end
		
		local index=idx
		local cellHeight=120-20
		local rect = CCRect(0, 0, 50, 50)
		local capInSet = CCRect(20, 20, 10, 10)
		local function cellClick(hd,fn,index1)
			if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				PlayEffect(audioCfg.mouseClick)
				self.selectIndex=tonumber(index1)-1000
				local recordPoint = self.tv:getRecordPoint()
				self.tv:reloadData()
				self.tv:recoverToRecordPoint(recordPoint)
			end
		end
		
		local vipRechargeSprie
		if self.selectIndex==(index+1) then
			vipRechargeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",CCRect(20, 20, 10, 10),cellClick)
		else
			vipRechargeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),cellClick)
		end
		vipRechargeSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 110))
		vipRechargeSprie:ignoreAnchorPointForPosition(false)
		vipRechargeSprie:setAnchorPoint(ccp(0,0))
		vipRechargeSprie:setPosition(ccp(10,10))
		vipRechargeSprie:setIsSallow(false)
		vipRechargeSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		vipRechargeSprie:setTag(1001+index)
		cell:addChild(vipRechargeSprie)
		
		local checkBg = CCSprite:createWithSpriteFrameName("BtnCheckBg.png")
		checkBg:setAnchorPoint(ccp(0,0.5))
		checkBg:setPosition(ccp(25,cellHeight/2))
		vipRechargeSprie:addChild(checkBg,1)
		local  tmpStoreCfg=G_getPlatStoreCfg()

		local mType=tmpStoreCfg["moneyType"][GetMoneyName()]
		local mPrice=tmpStoreCfg["money"][GetMoneyName()][idx+1]
		local priceStr =getlocal("buyGemsPrice",{mType,mPrice})
		if G_curPlatName()=="13" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_curPlatName()=="androidzhongshouyouko" or G_isKakao() then
			priceStr =getlocal("buyGemsPrice",{mPrice,mType})
		end
		local buyGemsPrice=GetTTFLabel(priceStr,28)
		buyGemsPrice:setAnchorPoint(ccp(1,0.5))
		buyGemsPrice:setPosition(ccp(self.bgLayer:getContentSize().width-60,cellHeight/2))
		vipRechargeSprie:addChild(buyGemsPrice,1)
		buyGemsPrice:setColor(G_ColorGreen)
		
		if tmpStoreCfg["goldPreferential"][idx+1]~="" then
			local buyGemsDiscount=GetTTFLabel(getlocal("buyGemsDiscount",{tmpStoreCfg["goldPreferential"][idx+1]}),28)
			buyGemsDiscount:setAnchorPoint(ccp(1,1))
			buyGemsDiscount:setPosition(ccp(self.bgLayer:getContentSize().width-60,35))
			buyGemsDiscount:setColor(G_ColorYellowPro)
			if platCfg.platCfgStoreShowDisCount[G_curPlatName()]==nil then
				vipRechargeSprie:addChild(buyGemsDiscount,1)
			end
		end
		
		if self.selectIndex==(index+1) then
			local checkIcon = CCSprite:createWithSpriteFrameName("BtnCheck.png")
			checkIcon:setPosition(getCenterPoint(checkBg))
			checkBg:addChild(checkIcon,1)
			buyGemsPrice:setColor(G_ColorWhite)
			if buyGemsDiscount~=nil then
				buyGemsDiscount:setColor(G_ColorWhite)
			end
		end

		local gemIcon
		if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
			local sortCfg=playerCfg.recharge.indexSort
			local curIdx = sortCfg[index+1]
			local imageStrName="iconGold"..curIdx..".png"
			gemIcon= CCSprite:createWithSpriteFrameName(imageStrName)
			 gemIcon:setPosition(ccp(320,cellHeight/2))
		else
			gemIcon = CCSprite:createWithSpriteFrameName("GoldImage.png")
			gemIcon:setPosition(ccp(280,cellHeight/2))
		end
		gemIcon:setAnchorPoint(ccp(0.5,0.5))
		vipRechargeSprie:addChild(gemIcon,1)
		local buyGemsNum=GetBMLabel(tmpStoreCfg["gold"][idx+1],G_GoldFontSrc,30)
		buyGemsNum:setAnchorPoint(ccp(0,0.5))
		buyGemsNum:setPosition(ccp(95,cellHeight/2-5))
		vipRechargeSprie:addChild(buyGemsNum,1)

		local hotSellCfg=playerCfg.recharge.hotSell
		local bestSellCfg=playerCfg.recharge.bestSell
		for k,v in pairs(hotSellCfg) do
			if tostring(index+1)==tostring(v) and (G_curPlatName()~="14" and G_curPlatName()~="androidkunlun1mobile" and G_curPlatName()~="androidkunlun" and G_curPlatName()~="androidkunlunz") and G_curPlatName()~="32" and G_curPlatName()~="androidklfy" then
				local hotIcon = CCSprite:createWithSpriteFrameName("BgHot.png")
				hotIcon:setAnchorPoint(ccp(1,1))
				hotIcon:setPosition(ccp(self.bgLayer:getContentSize().width-10,cellHeight+12))
				vipRechargeSprie:addChild(hotIcon)
				
				local hotStr=GetTTFLabel(getlocal("hotSell"),25)
				hotStr:setPosition(getCenterPoint(hotIcon))
				hotIcon:addChild(hotStr,1)
			end
		end
		for k,v in pairs(bestSellCfg) do
			
			if tostring(index+1)==tostring(v) and (G_curPlatName()~="14" and G_curPlatName()~="androidkunlun1mobile" and G_curPlatName()~="androidkunlun" and G_curPlatName()~="androidkunlunz") and G_curPlatName()~="32" and G_curPlatName()~="androidklfy" then
				local cheapIcon = CCSprite:createWithSpriteFrameName("BgCheap.png")
				cheapIcon:setAnchorPoint(ccp(1,1))
				cheapIcon:setPosition(ccp(self.bgLayer:getContentSize().width-10,cellHeight+14))
				vipRechargeSprie:addChild(cheapIcon)
				
				local cheapStr=GetTTFLabel(getlocal("bestSell"),25)
				cheapStr:setPosition(getCenterPoint(cheapIcon))
				cheapIcon:addChild(cheapStr,1)
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

function vipRechargeDialogNewTabNormal:doUserHandler()
	local function gotoVip(tag,object)
		if G_checkClickEnable()==false then
			do
				return
			end
		end
		if newGuidMgr:isNewGuiding() then
			do return end
		end
        require "luascript/script/game/scene/gamedialog/vipDialog"
		local vd1 = vipDialog:new();
		local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("vipTitle"),true,self.layerNum+1);
		sceneGame:addChild(vd,self.layerNum+1);
		PlayEffect(audioCfg.mouseClick)
		self.parent:close()
	end
	local textSize = 25
	if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
		textSize=20
	end
	self.gotoVipBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",gotoVip,nil,getlocal("gotoVip"),textSize);
	self.gotoVipBtn:setPosition(1,0)
	self.gotoVipBtn:setAnchorPoint(CCPointMake(0,0))

	local gotoVipBtnMenu = CCMenu:createWithItem(self.gotoVipBtn)
	gotoVipBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)	
	gotoVipBtnMenu:setPosition(ccp(G_VisibleSizeWidth-self.gotoVipBtn:getContentSize().width-25,G_VisibleSizeHeight-250))
	self.bgLayer:addChild(gotoVipBtnMenu)
	
	local function rechargeHandler(tag,object)
		if G_checkClickEnable()==false then
			do
				return
			end
		end
		PlayEffect(audioCfg.mouseClick)
		local specialFlag
		if(tag==333)then
			specialFlag=1
		else
			specialFlag=0
		end
		vipVoApi:gotoRecharge(self.selectIndex,self.layerNum,specialFlag)
	end


	if G_curPlatName()=="androidlongzhong" or G_curPlatName()=="androidlongzhong2" or G_curPlatName()=="efunandroid360" or (G_curPlatName()=="efunandroidtw" and G_Version~=nil and G_Version>=2) then
		AppStorePayment:shared():buyItemByTypeForAndroid("","","",0,1,"",base.curZoneID,"","");
		do
			return
		end
	end
	if G_curPlatName()=="qihoo" then
		self.rechargeBtn = GetButtonItem("BtnRecharge.png","BtnRecharge.png","BtnRecharge.png",rechargeHandler,nil,getlocal("recharge"),28);
	else
		self.rechargeBtn = GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge.png",rechargeHandler,nil,getlocal("recharge"),28);
	end
	local rechargeBtnMenu = CCMenu:createWithItem(self.rechargeBtn)
	rechargeBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	
	if G_curPlatName()=="efunandroidtw" or G_curPlatName()=="efunandroidnm" then --efun版
		rechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width/4,self.rechargeBtn:getContentSize().height/2+30))
		local function turnToOfficalHandler()
			local tmpTb={}
			tmpTb["action"]="toOfficalWebSite"
			tmpTb["parms"]={}
			tmpTb["parms"]["username"]=playerVoApi:getPlayerName()
			tmpTb["parms"]["uselv"]=playerVoApi:getPlayerLevel()
			tmpTb["parms"]["zoneid"]=tonumber(base.curZoneID)
			tmpTb["parms"]["gameid"]=playerVoApi:getUid()
			tmpTb["parms"]["svrname"]=base.curZoneServerName
			local cjson=G_Json.encode(tmpTb)
			G_accessCPlusFunction(cjson)
		end
		local turnToOfficalBtn=GetButtonItem("BtnRecharge.png","BtnRecharge.png","BtnRecharge.png",turnToOfficalHandler,nil,getlocal("turnToOffical"),28);

		local turnToOfficalBtnMenu=CCMenu:createWithItem(turnToOfficalBtn)
		turnToOfficalBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
		turnToOfficalBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width*3/4,self.rechargeBtn:getContentSize().height/2+30))
		self.bgLayer:addChild(turnToOfficalBtnMenu)
	else
		rechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.rechargeBtn:getContentSize().height/2+30))
	end
	if G_curPlatName()=="androidzhongshouyouru" and playerVoApi:getPlayerLevel()>=10 and G_Version>=2 then --俄罗斯安卓
		rechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width/4,self.rechargeBtn:getContentSize().height/2+20))
		local thirdRechargeBtn=GetButtonItem("BtnRecharge.png","BtnRecharge.png","BtnRecharge.png",rechargeHandler,333,getlocal("otherMethodForRecharge"),28)
		local thirdRechargeBtnMenu=CCMenu:createWithItem(thirdRechargeBtn)
		thirdRechargeBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
		thirdRechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width*3/4,self.rechargeBtn:getContentSize().height/2+30))
		self.bgLayer:addChild(thirdRechargeBtnMenu)
	end
	if G_curPlatName()=="efunandroiddny" and G_Version>=2 then --东南亚
		local thetmpTb={}
		thetmpTb["action"]="getChannel"
		local thecjson=G_Json.encode(thetmpTb)
		local thechannelid = G_accessCPlusFunction(thecjson)

		if thechannelid == "2" or thechannelid == "14" or thechannelid == "15" or thechannelid == "19"   then
			rechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width/4,self.rechargeBtn:getContentSize().height/2+30))
			local thirdRechargeBtn=GetButtonItem("BtnRecharge.png","BtnRecharge.png","BtnRecharge.png",rechargeHandler,333,getlocal("otherMethodForRecharge"),28);
			
			local thirdRechargeBtnMenu=CCMenu:createWithItem(thirdRechargeBtn)
			thirdRechargeBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
			thirdRechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width*3/4,self.rechargeBtn:getContentSize().height/2+30))
			self.bgLayer:addChild(thirdRechargeBtnMenu)
		end
	end
	self.bgLayer:addChild(rechargeBtnMenu)
	self:tick()
end

function vipRechargeDialogNewTabNormal:tick()
	if self.gems~=playerVoApi:getGems() then
		self.gems=playerVoApi:getGems()
		local vipRechargeStr = getlocal("have")..playerVoApi:getGems().."  "..getlocal("curVipLevel",{playerVoApi:getVipLevel()})
		if self.vipRechargeLabel==nil then
			self.vipRechargeLabel=GetTTFLabelWrap(vipRechargeStr,25,CCSizeMake(25*20, 30*6),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			self.vipRechargeLabel:setAnchorPoint(ccp(0,0.5))
			self.vipRechargeLabel:setPosition(ccp(30,G_VisibleSizeHeight-255))
			self.bgLayer:addChild(self.vipRechargeLabel)
		else
			self.vipRechargeLabel:setString(vipRechargeStr)
		end
	end
	
	local buygems=playerVoApi:getBuygems()
	local vipExp=playerVoApi:getVipExp()
	if self.vipExp~=vipExp then
		self.vipExp=vipExp	
		local vipLevel=playerVoApi:getVipLevel()
		local vipLevelCfg=Split(playerCfg.vipLevel,",")
		local gem4vipCfg=Split(playerCfg.gem4vip,",")
		local vipStr = ""
		if tostring(vipLevel) == tostring(playerVoApi:getMaxLvByKey("maxVip")) then
			vipStr = getlocal("richMan")
		else
			local nextVip=vipLevel+1
			local nextGem=gem4vipCfg[nextVip]
			local needGem=nextGem-self.vipExp
			--vipStr = getlocal("currentVip",{vipLevel})
			vipStr = vipStr..getlocal("nextVip",{needGem,nextVip})
		end
		if self.vipDescLabel==nil then
			self.vipDescLabel=GetTTFLabelWrap(vipStr,25,CCSizeMake(25*15, 30*5),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			self.vipDescLabel:setAnchorPoint(ccp(0,0.5))
			self.vipDescLabel:setPosition(ccp(30,self.bgLayer:getContentSize().height-280))
			self.bgLayer:addChild(self.vipDescLabel,1)
		else
 			self.vipDescLabel:setString(vipStr)
		end
	end

	local gem4vipCfg=Split(playerCfg.gem4vip,",")
	local nextVip=playerVoApi:getVipLevel()+1
    local nextGem=gem4vipCfg[nextVip]
    if(nextGem)then
	    local needGem=nextGem-self.vipExp
		if needGem<0 and playerVoApi:getVipLevel()<playerVoApi:getMaxLvByKey("maxVip") then
	    	local function callback(fn,data)
	            local ret,sData=base:checkServerData(data)
	            if ret==true then
	                local nextVip=playerVoApi:getVipLevel()+1
			        local nextGem=gem4vipCfg[nextVip]
			        local needGem=nextGem-self.vipExp
			        local vipStr = ""
			        vipStr = vipStr..getlocal("nextVip",{needGem,nextVip})
			        if tostring(playerVoApi:getVipLevel()) == tostring(playerVoApi:getMaxLvByKey("maxVip")) then
				        vipStr = getlocal("richMan")
				    end
			        self.vipDescLabel:setString(vipStr)
			        local vipRechargeStr = getlocal("have")..playerVoApi:getGems().."  "..getlocal("curVipLevel",{playerVoApi:getVipLevel()})
			        self.vipRechargeLabel:setString(vipRechargeStr)
	
	            end
	        end
	    	socketHelper:userefvip(callback)
	    end
	end
	
	if self.vipLevel and self.vipLevel~=playerVoApi:getVipLevel() then
		self.vipLevel=playerVoApi:getVipLevel()
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vipLevelUp",{playerVoApi:getVipLevel()}),28)
	end
	
	if buygems==0 and self.isFirstRecharge==false then
		if self.tv~=nil then
			self.isFirstRecharge=true
			self.tv:reloadData()
		end
	elseif buygems>0 and self.isFirstRecharge==true then
		if self.tv~=nil then
			self.isFirstRecharge=false
			self.tv:reloadData()
		end
	end
end

function vipRechargeDialogNewTabNormal:dispose()
	self.vipRechargeLabel=nil
	self.firstRechargeLabel=nil
	self.tv=nil
	self.layerNum=nil
	self.gems=nil
	self.selectIndex=nil
	self.vipExp=nil
	self.vipDescLabel=nil
	self.gotoVipBtn=nil
	self.rechargeBtn=nil
	self.isFirstRecharge=nil
	self.topforbidSp=nil
	self.bottomforbidSp=nil
	self.vipLevel=nil
end