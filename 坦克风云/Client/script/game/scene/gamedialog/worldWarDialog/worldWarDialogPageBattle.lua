worldWarDialogPageBattle={}
function worldWarDialogPageBattle:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.rootTv=nil
	nc.rootCell=nil
	nc.rootCellHeight=1136 - 300
	nc.tvAll=nil
	nc.tvP=nil
	nc.tvTabs={}
	nc.recordsAll={}
	nc.recordsP={}
	nc.curRecordType=1
	nc.callbackNum=0
	nc.refreshingRecord=false
	return nc
end

function worldWarDialogPageBattle:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initListener()
	self.signStatus=worldWarVoApi:getSignStatus()
	if(self.signStatus~=nil)then
		self:initContent()
	end
	return self.bgLayer
end

function worldWarDialogPageBattle:initListener()
	local function onSignListener(event,data)
		self:initContent()
	end
	self.signListener=onSignListener
	eventDispatcher:addEventListener("worldwar.signup",onSignListener)
end

function worldWarDialogPageBattle:initContent()
	self.signStatus=worldWarVoApi:getSignStatus()
	local titleTxt
	if(self.signStatus==1)then
		titleTxt=getlocal("world_war_sub_title12")
	else
		titleTxt=getlocal("world_war_sub_title13")
	end
	local posY=G_VisibleSizeHeight - 250
	local titleLb=GetTTFLabel(titleTxt,33)
	titleLb:setColor(G_ColorYellowPro)
	titleLb:setPosition(G_VisibleSizeWidth/2,posY)
	self.bgLayer:addChild(titleLb)

	posY=posY - 30
	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setAnchorPoint(ccp(0.5,0))
	lineSp:setScale(0.95)
	lineSp:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(lineSp)
	self:initRootTv()
end

function worldWarDialogPageBattle:initRootTv()
	local function callback(...)
		return self:eventHandlerRoot(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.rootTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight - 300),nil)
	self.rootTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.rootTv:setPosition(0,20)
	self.rootTv:setMaxDisToBottomOrTop(0)
	self.bgLayer:addChild(self.rootTv)
end

function worldWarDialogPageBattle:eventHandlerRoot(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth,self.rootCellHeight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		self.rootCell=cell

		local posY=self.rootCellHeight - 15
		local battleTimeDescLb=GetTTFLabel(getlocal("serverwar_battleTime"),25)
		battleTimeDescLb:setColor(G_ColorGreen)
		battleTimeDescLb:setPosition(G_VisibleSizeWidth/2,posY)
		cell:addChild(battleTimeDescLb)

		local totalLbSiz = 18
		local recordLb2Siz = 20
		local recordLbSiz = 16
		local strSize2 = 20
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
	      totalLbSiz =22
	      recordLbSiz =25
	      recordLb2Siz=25
	      strSize2 =25
	    elseif G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="ru" then
	    	recordLb2Siz =16
	    end

		posY=posY - 30
		local battleTimeLb1=GetTTFLabel(G_getDataTimeStr(worldWarVoApi:getStarttime() + worldWarCfg.signuptime*86400,true,true).." - "..G_getDataTimeStr(worldWarVoApi:getStarttime() + worldWarCfg.signuptime*86400 + worldWarCfg.pmatchdays*86400 - 1,true,true),23)
		battleTimeLb1:setPosition(G_VisibleSizeWidth/2,posY)
		cell:addChild(battleTimeLb1)

		posY=posY - 30
		--因为没有现成的显示几点几分的方法，所以使用了G_getTimeStr来模拟，虽然本意不同但是可以返回正确的结果
		local battleTimeLb2=GetTTFLabel(getlocal("world_war_everyDayTime",{G_getTimeStr(worldWarCfg["pmatchstarttime"..self.signStatus][1]*60 + worldWarCfg["pmatchstarttime"..self.signStatus][2],1),G_getTimeStr(worldWarCfg["pmatchendtime"..self.signStatus][1]*60 + worldWarCfg["pmatchendtime"..self.signStatus][2],1)}),23)
		battleTimeLb2:setPosition(G_VisibleSizeWidth/2,posY)
		cell:addChild(battleTimeLb2)

		local function showInfo()
			PlayEffect(audioCfg.mouseClick)
			local tabStr={"\n",getlocal("world_war_pmatchInfo6"),"\n",getlocal("world_war_pmatchInfo5"),"\n",getlocal("world_war_pmatchInfo4"),"\n",getlocal("world_war_pmatchInfo3"),"\n",getlocal("world_war_pmatchInfo2"),"\n",getlocal("world_war_pmatchInfo1",{math.floor(worldWarCfg.breaktime/60),worldWarCfg.pmatchendtime1[1] - worldWarCfg.pmatchstarttime1[1]}),"\n"}
			local tabColor={}
			for k,v in pairs(tabStr) do
				tabColor[k]=G_ColorYellowPro
			end
			local td=smallDialog:new()
			local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
			sceneGame:addChild(dialog,self.layerNum+1)
		end
		local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
		infoItem:setScale(0.9)
		local infoBtn = CCMenu:createWithItem(infoItem)
		infoBtn:setPosition(ccp(G_VisibleSizeWidth - 80,posY + 20))
		infoBtn:setTouchPriority(-(self.layerNum - 1)*20 - 2)
		cell:addChild(infoBtn)


		local picName
		local bgName
		local logoName
		if(self.signStatus==1)then
			picName="ww_poster_1.png"
			bgName="ww_bg1.png"
			logoName="ww_logo_1.png"
		else
			picName="ww_poster_2.png"
			bgName="ww_bg2.png"
			logoName="ww_logo_2.png"
		end
		posY=posY - 40
		local picWidth=250
		local picHeight=350
		self.posterPic=CCSprite:createWithSpriteFrameName(picName)
		self.posterPic:setScaleX(picWidth/self.posterPic:getContentSize().width)
		self.posterPic:setScaleY(picHeight/self.posterPic:getContentSize().height)
		self.posterPic:setAnchorPoint(ccp(0.5,1))
		self.posterPic:setPosition(G_VisibleSizeWidth/4,posY)
		cell:addChild(self.posterPic)

		local gradualBg=CCSprite:createWithSpriteFrameName("jianianhuaMask.png")
		gradualBg:setScaleX(picWidth/gradualBg:getContentSize().width)
		gradualBg:setPosition(G_VisibleSizeWidth/4,posY - gradualBg:getContentSize().height/2)
		cell:addChild(gradualBg)

		local function nilFunc( ... )
		end
		local picBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgName,CCRect(70,30,10,10),nilFunc)
		picBg:setContentSize(CCSizeMake(picWidth + 6,picHeight + 6))
		picBg:setAnchorPoint(ccp(0.5,1))
		picBg:setPosition(G_VisibleSizeWidth/4,posY + 3)
		cell:addChild(picBg,1)

		self.matchStatus=worldWarVoApi:checkPMatchStatus(self.signStatus)
		if(self.matchStatus>=20 and self.matchStatus<29)then
			self:addFlameBorder()
		end

		local titleBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
		titleBg:setScaleX((picWidth - 40)/titleBg:getContentSize().width)
		titleBg:setScaleY(35/titleBg:getContentSize().height)
		titleBg:setPosition(G_VisibleSizeWidth/4,posY - 50)
		cell:addChild(titleBg)

		local titleLb=GetTTFLabel(getlocal("world_war_group_"..self.signStatus),25)
		titleLb:setPosition(G_VisibleSizeWidth/4,posY - 50)
		cell:addChild(titleLb)

		local totalLb=GetTTFLabel(getlocal("world_war_totalPlayers",{worldWarVoApi:getPMatchPlayers()}),totalLbSiz)
		totalLb:setColor(G_ColorGreen)
		totalLb:setPosition(G_VisibleSizeWidth/4,posY - 80)
		cell:addChild(totalLb)

		local logo=CCSprite:createWithSpriteFrameName(logoName)
		logo:setPosition(G_VisibleSizeWidth/4,posY)
		cell:addChild(logo,3)

		gradualBg=CCSprite:createWithSpriteFrameName("jianianhuaMask.png")
		gradualBg:setScaleX(picWidth/gradualBg:getContentSize().width)
		gradualBg:setPosition(G_VisibleSizeWidth/4,posY - picHeight + gradualBg:getContentSize().height/2)
		gradualBg:setFlipY(true)
		cell:addChild(gradualBg)

		self.battleStatusLb=GetTTFLabelWrap("",22,CCSizeMake(picWidth - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		self.battleStatusLb:setColor(G_ColorYellowPro)
		self.battleStatusLb:setAnchorPoint(ccp(0.5,0))
		self.battleStatusLb:setPosition(G_VisibleSizeWidth/4,posY - picHeight + 8)
		cell:addChild(self.battleStatusLb)
	
		local posX=G_VisibleSizeWidth/2
		local archivesTitle=GetTTFLabel(getlocal("world_war_archives"..self.signStatus),28)
		archivesTitle:setColor(G_ColorYellowPro)
		archivesTitle:setAnchorPoint(ccp(0,1))
		archivesTitle:setPosition(G_VisibleSizeWidth/2 + 15,posY)
		cell:addChild(archivesTitle)
	
		local function viewRecord()
	        worldWarVoApi:showReportListDialog(1,self.layerNum)
		end
		local rect = CCRect(44,33,1,1)
		local sNormal =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
		local sSelected =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue2.png",rect,nilFunc)
		local sDisabled =LuaCCScale9Sprite:createWithSpriteFrameName("btnBlue1.png",rect,nilFunc)
		sNormal:setContentSize(CCSizeMake(200,60))
		sSelected:setContentSize(CCSizeMake(200,60))
		sDisabled:setContentSize(CCSizeMake(200,60))
		local recordItem = CCMenuItemSprite:create(sNormal, sSelected, sDisabled)  
		recordItem:registerScriptTapHandler(viewRecord)
		local recordLb=GetTTFLabelWrap(getlocal("serverwarteam_record"),recordLbSiz,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		recordLb:setAnchorPoint(ccp(0.5,0.5))
		recordLb:setPosition(getCenterPoint(recordItem))
		recordItem:addChild(recordLb)
		local recordBtn=CCMenu:createWithItem(recordItem)
		recordBtn:setPosition(G_VisibleSizeWidth*3/4,posY - picHeight + 30)
		recordBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(recordBtn)
	
		local infoHeight=picHeight - archivesTitle:getContentSize().height - recordItem:getContentSize().height - 10
		local space=infoHeight/6
	
		posY=posY - archivesTitle:getContentSize().height - 5 - space/2
		local nameLb1=GetTTFLabel(getlocal("alliance_name"),strSize2)
		nameLb1:setColor(G_ColorGreen)
		nameLb1:setAnchorPoint(ccp(0,0.5))
		nameLb1:setPosition(posX,posY)
		cell:addChild(nameLb1)
		local nameLb2=GetTTFLabel(playerVoApi:getPlayerName(),strSize2)
		nameLb2:setAnchorPoint(ccp(0,0.5))
		nameLb2:setPosition(posX + nameLb1:getContentSize().width + 5,posY)
		cell:addChild(nameLb2)
		local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp1:setAnchorPoint(ccp(0.5,0))
		local lineScaleX=G_VisibleSizeWidth/2/lineSp1:getContentSize().width
		lineSp1:setScaleX(lineScaleX)
		lineSp1:setPosition(ccp(G_VisibleSizeWidth*3/4,posY - 20))
		cell:addChild(lineSp1)
	
		posY=posY - space
		local powerLb1=GetTTFLabel(getlocal("alliance_info_power"),strSize2)
		powerLb1:setColor(G_ColorGreen)
		powerLb1:setAnchorPoint(ccp(0,0.5))
		powerLb1:setPosition(posX,posY)
		cell:addChild(powerLb1)
		local powerLb2=GetTTFLabel(FormatNumber(playerVoApi:getPlayerPower()),strSize2)
		powerLb2:setAnchorPoint(ccp(0,0.5))
		powerLb2:setPosition(posX + powerLb1:getContentSize().width + 5,posY)
		cell:addChild(powerLb2)
		local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp2:setAnchorPoint(ccp(0.5,0))
		lineSp2:setScaleX(lineScaleX)
		lineSp2:setPosition(ccp(G_VisibleSizeWidth*3/4,posY - 20))
		cell:addChild(lineSp2)
	
		posY=posY - space
		local serverLb1=GetTTFLabel(getlocal("server",{""}),strSize2)
		serverLb1:setColor(G_ColorGreen)
		serverLb1:setAnchorPoint(ccp(0,0.5))
		serverLb1:setPosition(posX,posY)
		cell:addChild(serverLb1)
		local serverLb2=GetTTFLabel(GetServerNameByID(base.curZoneID),strSize2)
		serverLb2:setAnchorPoint(ccp(0,0.5))
		serverLb2:setPosition(posX + serverLb1:getContentSize().width + 5,posY)
		cell:addChild(serverLb2)
		local lineSp3=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp3:setAnchorPoint(ccp(0.5,0))
		lineSp3:setScaleX(lineScaleX)
		lineSp3:setPosition(ccp(G_VisibleSizeWidth*3/4,posY - 20))
		cell:addChild(lineSp3)
	
		posY=posY - space
		local recordLb1=GetTTFLabel(getlocal("alliance_war_record_title")..":",strSize2)
		recordLb1:setColor(G_ColorGreen)
		recordLb1:setAnchorPoint(ccp(0,0.5))
		recordLb1:setPosition(posX,posY)
		cell:addChild(recordLb1)
		if(base.serverTime>=worldWarVoApi:getDetailExpireTime())then
			self.recordLb2=GetTTFLabel("",recordLb2Siz)
		else
			self.recordLb2=GetTTFLabel(getlocal("world_war_winLoseNum",{worldWarVoApi:getPMatchWinMatch(),worldWarVoApi:getPMatchLoseMatch()}),recordLb2Siz)
		end
		self.recordLb2:setAnchorPoint(ccp(0,0.5))
		self.recordLb2:setPosition(posX + recordLb1:getContentSize().width + 5,posY)
		cell:addChild(self.recordLb2)
		local lineSp4=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp4:setAnchorPoint(ccp(0.5,0))
		lineSp4:setScaleX(lineScaleX)
		lineSp4:setPosition(ccp(G_VisibleSizeWidth*3/4,posY - 20))
		cell:addChild(lineSp4)
	
		posY=posY - space
		local pointLb1=GetTTFLabel(getlocal("world_war_report_point")..":",strSize2)
		pointLb1:setColor(G_ColorGreen)
		pointLb1:setAnchorPoint(ccp(0,0.5))
		pointLb1:setPosition(posX,posY)
		cell:addChild(pointLb1)
		if(base.serverTime>=worldWarVoApi:getDetailExpireTime())then
			self.pointLb2=GetTTFLabel("",25)
		else
			self.pointLb2=GetTTFLabel(worldWarVoApi:getPMatchScore(),strSize2)
		end
		self.pointLb2:setAnchorPoint(ccp(0,0.5))
		self.pointLb2:setPosition(posX + pointLb1:getContentSize().width + 5,posY)
		cell:addChild(self.pointLb2)
		local lineSp5=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp5:setAnchorPoint(ccp(0.5,0))
		lineSp5:setScaleX(lineScaleX)
		lineSp5:setPosition(ccp(G_VisibleSizeWidth*3/4,posY - 20))
		cell:addChild(lineSp5)
	
		posY=posY - space
		local rankingLb1=GetTTFLabel(getlocal("rank")..":",strSize2)
		rankingLb1:setColor(G_ColorGreen)
		rankingLb1:setAnchorPoint(ccp(0,0.5))
		rankingLb1:setPosition(posX,posY)
		cell:addChild(rankingLb1)
		if(base.serverTime>=worldWarVoApi:getDetailExpireTime())then
			self.rankingLb2=GetTTFLabel("",25)
		else
			self.rankingLb2=GetTTFLabel(worldWarVoApi:getPMatchRank(),strSize2)
		end
		self.rankingLb2:setAnchorPoint(ccp(0,0.5))
		self.rankingLb2:setPosition(posX + rankingLb1:getContentSize().width + 5,posY)
		cell:addChild(self.rankingLb2)
		local lineSp6=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp6:setAnchorPoint(ccp(0.5,0))
		lineSp6:setScaleX(lineScaleX)
		lineSp6:setPosition(ccp(G_VisibleSizeWidth*3/4,posY - 20))
		cell:addChild(lineSp6)
	
		posY=self.posterPic:getPositionY() - picHeight - 15 - 70
		self:initChat(posY)
		self:initTv(posY)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function worldWarDialogPageBattle:initChat(posY)
	local chatBg,chatMenu=G_initChat(self.rootCell,self.layerNum + 1,true,1,12,posY,G_VisibleSizeWidth - 40,0)
	chatBg:setTouchPriority(-(self.layerNum-1)*20-8)
	chatMenu:setTouchPriority(-(self.layerNum-1)*20-8)
	self.chatBg=chatBg
end

function worldWarDialogPageBattle:initTv(posY)
	local tabStr={getlocal("world_war_all"),getlocal("alliance_war_personal")}
	for k,v in pairs(tabStr) do
		local subTabBtn=CCMenu:create()
		local subTabItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
		subTabItem:setAnchorPoint(ccp(0,0))
		local function tabSubClick(idx)
			return self:switchRecordPage(idx)
		end
		subTabItem:registerScriptTapHandler(tabSubClick)
		local lb=GetTTFLabelWrap(v,20,CCSizeMake(subTabItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		lb:setPosition(CCPointMake(subTabItem:getContentSize().width/2,subTabItem:getContentSize().height/2))
		subTabItem:addChild(lb)
		self.tvTabs[k]=subTabItem
		subTabBtn:addChild(subTabItem)
		subTabItem:setTag(k)
		subTabBtn:setPosition(ccp((k-1)*(subTabItem:getContentSize().width+9)+50,posY - 50))
		subTabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.rootCell:addChild(subTabBtn)
	end
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function( ... )end)
	local adaH = 55
	if G_getIphoneType() == G_iphoneX then
		adaH = -50
	end
	tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,posY - adaH))
	tvBg:setAnchorPoint(ccp(0,1))
	tvBg:setPosition(30,posY - 45)
	tvBg:setIsSallow(true)
    tvBg:setTouchPriority(-(self.layerNum-1)*20-4)
	self.rootCell:addChild(tvBg)

	local function callback(...)
		return self:eventHandlerAll(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tvAll=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,posY - 65),nil)
	self.tvAll:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	self.tvAll:setPosition(0,15)
	self.tvAll:setMaxDisToBottomOrTop(30)
	self.rootCell:addChild(self.tvAll)

	local function callback(...)
		return self:eventHandlerP(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tvP=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,posY - 65),nil)
	self.tvP:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	self.tvP:setPosition(0,15)
	self.tvP:setMaxDisToBottomOrTop(30)
	self.rootCell:addChild(self.tvP)



	self:switchRecordPage(self.curRecordType)
end

function worldWarDialogPageBattle:switchRecordPage(pageIndex)
	for k,v in pairs(self.tvTabs) do
		if k==pageIndex then
			self.curRecordType=pageIndex
			v:setEnabled(false)
		else
			v:setEnabled(true)
		end
	end
	if(pageIndex==1)then
		self.tvAll:setVisible(true)
		self.tvAll:setPositionX(0)
		self.tvP:setVisible(false)
		self.tvP:setPositionX(999333)
	else
		self.tvAll:setVisible(false)
		self.tvAll:setPositionX(999333)
		self.tvP:setVisible(true)
		self.tvP:setPositionX(0)
	end
end

function worldWarDialogPageBattle:eventHandlerAll(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(worldWarVoApi:getMessageTab(1))
	elseif fn=="tableCellSizeForIndex" then
		local msgTab=worldWarVoApi:getMessageTab(1)
		local masData=msgTab[idx+1]
		local height=masData[2]
		return CCSizeMake(550,height)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local msgTab=worldWarVoApi:getMessageTab(1)
		local masData=msgTab[idx+1]
		local msg=masData[1]
		local height=masData[2]
		local color=masData[3]
		local msgLabel=GetTTFLabelWrap(msg,22,CCSizeMake(550,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		msgLabel:setAnchorPoint(ccp(0,1))
		cell:addChild(msgLabel,2)
		msgLabel:setPosition(40,height)
		if color then
			msgLabel:setColor(color)
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

function worldWarDialogPageBattle:eventHandlerP(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(worldWarVoApi:getMessageTab(2))
	elseif fn=="tableCellSizeForIndex" then
		local msgTab=worldWarVoApi:getMessageTab(2)
		local masData=msgTab[idx+1]
		local height=masData[2]
		return CCSizeMake(550,height)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local msgTab=worldWarVoApi:getMessageTab(2)
		local masData=msgTab[idx+1]
		local msg=masData[1]
		local height=masData[2]
		local color=masData[3]
		local msgLabel=GetTTFLabelWrap(msg,22,CCSizeMake(550,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		msgLabel:setAnchorPoint(ccp(0,1))
		cell:addChild(msgLabel,2)
		msgLabel:setPosition(40,height)
		if color then
			msgLabel:setColor(color)
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

function worldWarDialogPageBattle:addFlameBorder()
	local posY=self.posterPic:getPositionY()
	local picWidth=self.posterPic:getContentSize().width
	local picHeight=self.posterPic:getContentSize().height
	local borderFlame1 = CCParticleSystemQuad:create("worldWar/fireBorder.plist")
	borderFlame1.positionType=kCCPositionTypeFree
	borderFlame1:setPosition(ccp(G_VisibleSizeWidth/4,posY - picHeight))
	borderFlame1:setScaleX(0.65)
	self.rootCell:addChild(borderFlame1,1)
	local borderFlame2 = CCParticleSystemQuad:create("worldWar/fireBorder.plist")
	borderFlame2.positionType=kCCPositionTypeFree
	borderFlame2:setPosition(ccp(G_VisibleSizeWidth/4,posY - 10))
	borderFlame2:setScaleX(0.65)
	self.rootCell:addChild(borderFlame2,1)
	local borderFlame3 = CCParticleSystemQuad:create("worldWar/fireBorderVertical.plist")
	borderFlame3.positionType=kCCPositionTypeFree
	borderFlame3:setPosition(ccp(G_VisibleSizeWidth/4 - picWidth/2,posY - picHeight/2))
	borderFlame3:setScaleY(0.85)
	self.rootCell:addChild(borderFlame3,1)
	local borderFlame4 = CCParticleSystemQuad:create("worldWar/fireBorderVertical.plist")
	borderFlame4.positionType=kCCPositionTypeFree
	borderFlame4:setPosition(ccp(G_VisibleSizeWidth/4 + picWidth/2,posY - picHeight/2))
	borderFlame4:setScaleY(0.85)
	self.rootCell:addChild(borderFlame4,1)
	self.flameTb={borderFlame1,borderFlame2,borderFlame3,borderFlame4}
end

function worldWarDialogPageBattle:tick()
	if(self.signStatus==nil)then
		do return end
	end
	if self.chatBg then
		G_setLastChat(self.chatBg,false,1,12)
	end
	local eventType=self.curRecordType
	local messageExpireTime=worldWarVoApi:getMessageExpireTime(eventType)
	if self.callbackNum<3 and messageExpireTime>=0 and base.serverTime>messageExpireTime then
		local function callback(isSuccess)
			if isSuccess and isSuccess==true then
				if eventType==1 then
					if self.tvAll then
						-- local recordPoint = self.tvAll:getRecordPoint()
						self.tvAll:reloadData()
						-- self.tvAll:recoverToRecordPoint(recordPoint)
					end
				else
					if self.tvP then
						-- local recordPoint = self.tvP:getRecordPoint()
						self.tvP:reloadData()
						-- self.tvP:recoverToRecordPoint(recordPoint)
					end
				end
				self.callbackNum=0
			end
		end
		worldWarVoApi:formatMessageTab(eventType,callback)
		self.callbackNum=self.callbackNum+1
	end
	if(base.serverTime>=worldWarVoApi:getDetailExpireTime() and self.refreshingRecord==false)then
		self.refreshingRecord=true
		worldWarVoApi:setPointDetailFlag(-1)
		local function callback()
			self.refreshingRecord=false
			self.recordLb2:setString(getlocal("world_war_winLoseNum",{worldWarVoApi:getPMatchWinMatch(),worldWarVoApi:getPMatchLoseMatch()}))
			self.pointLb2:setString(worldWarVoApi:getPMatchScore())
			self.rankingLb2:setString(worldWarVoApi:getPMatchRank())
		end
		worldWarVoApi:formatPointDetail(callback)
	end
	self.matchStatus=worldWarVoApi:checkPMatchStatus(self.signStatus)
	if(self.matchStatus<20)then
		self.battleStatusLb:setString(getlocal("world_war_matchStatus1"))
		if(self.flameTb)then
			for k,v in pairs(self.flameTb) do
				v:removeFromParentAndCleanup(true)
			end
			self.flameTb=nil
		end
	elseif(self.matchStatus>=30)then
		self.battleStatusLb:setString(getlocal("world_war_matchStatus2"))
		if(self.flameTb)then
			for k,v in pairs(self.flameTb) do
				v:removeFromParentAndCleanup(true)
			end
			self.flameTb=nil
		end
	else
		self.battleStatusLb:setString(getlocal("serverwarteam_battleing"))
		if(self.flameTb==nil)then
			self:addFlameBorder()
		end
	end
end

function worldWarDialogPageBattle:dispose()
	eventDispatcher:removeEventListener("worldwar.signup",self.signListener)
	self.curRecordType=1
	self.bgLayer:removeFromParentAndCleanup(true)
	self.layerNum=nil
	self.bgLayer=nil
	self.callbackNum=0
end