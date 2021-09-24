friendDialogNew=friendDialog:new()

function friendDialogNew:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerTab1=nil
	self.layerTab2=nil
	self.friendTab1=nil
	self.friendTab2=nil
	self.pageUpBtn=nil
	self.pageDownBtn=nil
	return nc
end

function friendDialogNew:resetTab()
	local index=0
	local layerSize=self.bgLayer:getContentSize()
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		if index==0 then
			tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		elseif index==1 then
			tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		end
		if index==self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end
		index=index+1
	end
	local function showInfo()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		local tabStr={}
		local tabColor={}
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		tabStr = {"\n",getlocal("friend_desc"),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	infoItem:setScale(0.8)
	local infoBtn = CCMenu:createWithItem(infoItem)
	local tmp1=infoItem:getContentSize()
	infoBtn:setPosition(ccp(521,layerSize.height-120))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(infoBtn,3)
	self.selectedTabIndex=0
end

function friendDialogNew:initTableView()
	--邀请好友的按钮
	local function onInviteFriend()
		if((G_curPlatName()=="efunandroidtw" and G_Version<10) or (G_curPlatName()=="3" and G_Version<=4) or G_curPlatName()=="efunandroiddny" or G_curPlatName()=="4" or G_curPlatName()=="47")then
			local tmpTb={}
			tmpTb["action"]="showSocialView"
			tmpTb["parms"]={}
			tmpTb["parms"]["uid"]=tostring(G_getTankUserName())
			tmpTb["parms"]["zoneid"]=tostring(base.curZoneID)
			tmpTb["parms"]["gameid"]=tostring(playerVoApi:getUid())
			local cjson=G_Json.encode(tmpTb)
			G_accessCPlusFunction(cjson)
		elseif(friendVoApi:checkIfSimpleFriend())then
			friendVoApi:sendInviteFeed()
		else
			friendVoApi:showSocialView()
		end
	end
	local btnTextSize = 30
	if G_curPlatName()=="12" or G_curPlatName()=="androidzhongshouyouru" then
		btnTextSize = 25
	end
	local inviteItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onInviteFriend,nil,getlocal("friend_invite"),btnTextSize)
	inviteItem:setEnabled(true);
	local inviteBtn=CCMenu:createWithItem(inviteItem);
	if(friendVoApi:checkIfSimpleFriend())then
		inviteItem:setAnchorPoint(ccp(1,0.5))
		inviteBtn:setAnchorPoint(ccp(1,0.5))
		inviteBtn:setPosition(ccp(G_VisibleSizeWidth/2-20,70))
	else
		inviteBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,70))
	end
	inviteBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	self.bgLayer:addChild(inviteBtn,2)
    --kakao special code
    if(G_isKakao())then
    	inviteBtn:setVisible(false)
    end

	if(friendVoApi:checkIfSimpleFriend())then
		local function onGotoHomePage()
			if(platCfg.platHomePageCfg[G_curPlatName()])then
				local tmpTb={}
				tmpTb["action"]="openUrlInAppWithClose"
				tmpTb["parms"]={}
				tmpTb["parms"]["connect"]=platCfg.platHomePageCfg[G_curPlatName()]
				local cjson=G_Json.encode(tmpTb)
				G_accessCPlusFunction(cjson)
			end
		end
		local homePageItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGotoHomePage,nil,getlocal("homepage"),btnTextSize)
		local homePageBtn=CCMenu:createWithItem(homePageItem)
		homePageItem:setAnchorPoint(ccp(0,0.5))
		homePageBtn:setAnchorPoint(ccp(0,0.5))
		homePageBtn:setPosition(ccp(G_VisibleSizeWidth/2+20,70))
		homePageBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.bgLayer:addChild(homePageBtn)

		local feedDescTitle=GetTTFLabelWrap(getlocal("feedDesc4Title"),23,CCSizeMake(G_VisibleSizeWidth-70,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		feedDescTitle:setPosition(ccp(G_VisibleSizeWidth/2,140))
		self.bgLayer:addChild(feedDescTitle)
	end
	--上下翻页的按钮
	local function onPageUp()
		self:onPageChange(-1)
	end
	local pUpItem=GetButtonItem("letterBtnPlay.png","letterBtnPlay_Down.png","letterBtnPlay_Down.png",onPageUp,nil,nil,30)
	pUpItem:setRotation(-180)
	pUpItem:setEnabled(false);
	local pUpBtn=CCMenu:createWithItem(pUpItem);
	pUpBtn:setPosition(ccp(120,70))
	pUpBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	self.bgLayer:addChild(pUpBtn,2)
	self.pageUpBtn=pUpItem
	local function onPageDown()
		self:onPageChange(1)
	end
	local pDownItem=GetButtonItem("letterBtnPlay.png","letterBtnPlay_Down.png","letterBtnPlay_Down.png",onPageDown,nil,nil,30)
	pDownItem:setEnabled(false);
	local pDownBtn=CCMenu:createWithItem(pDownItem);
	pDownBtn:setPosition(ccp(G_VisibleSizeWidth-120,70))
	pDownBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	self.bgLayer:addChild(pDownBtn,2)
	self.pageDownBtn=pDownItem
	self:switchTab(1)
	local function pageChangeListener(event,data)
		self:pageChange(event,data)
	end
	self.pageChangeListener=pageChangeListener
	eventDispatcher:addEventListener("dialog.friend.page",pageChangeListener)
end

--翻页事件的监听，根据事件设置翻页按钮是置灰还是可用
function friendDialogNew:pageChange(event,data)
	if(event=="dialog.friend.page")then
		if(data.r==1)then
			self.pageDownBtn:setEnabled(true)
		elseif(data.r==0)then
			self.pageDownBtn:setEnabled(false)
		end
		if(data.l==1)then
			self.pageUpBtn:setEnabled(true)
		elseif(data.l==0)then
			self.pageUpBtn:setEnabled(false)
		end
	end
end

function friendDialogNew:tabClick(idx)
	local tab2HasInited=(self.friendTab2~=nil)
	self:switchTab(idx+1)
	self:resetForbidLayer()
	if(idx==0)then
		self.friendTab1:pageChange(0)
	elseif(tab2HasInited)then
		self.friendTab2:pageChange(0)
	end
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
		else
			v:setEnabled(true)
		end
	end
end

function friendDialogNew:switchTab(type)
	if type==nil then
		type=1
	end
	if type==1 then
		if self.friendTab1==nil then
			self.friendTab1=friendDialogNewTabG:new()
			self.layerTab1=self.friendTab1:init(self.layerNum,self)
			self.bgLayer:addChild(self.layerTab1)
		end
		if self.layerTab1 then
			self.layerTab1:setPosition(ccp(0,0))
			self.layerTab1:setVisible(true)
		end
		if self.layerTab2 then
			self.layerTab2:setPosition(ccp(999333,0))
			self.layerTab2:setVisible(false)
		end
	elseif type==2 then
		if self.friendTab2==nil then
			self.friendTab2=friendDialogNewTabF:new()
			self.layerTab2=self.friendTab2:init(self.layerNum,self)
			self.bgLayer:addChild(self.layerTab2)
		end
		if self.layerTab1 then
			self.layerTab1:setPosition(ccp(999333,0))
			self.layerTab1:setVisible(false)
		end
		if self.layerTab2 then
			self.layerTab2:setPosition(ccp(0,0))
			self.layerTab2:setVisible(true)
		end
	end
end

function friendDialogNew:onPageChange(p)
	if(self.selectedTabIndex == 0)then
		self.friendTab1:pageChange(p)
	elseif(self.selectedTabIndex==1)then
		self.friendTab2:pageChange(p)
	end
end

function friendDialogNew:dispose()
	eventDispatcher:removeEventListener("dialog.friend.page",self.pageChangeListener)
	self.pageChangeListener=nil
	if(self.friendTab1 and self.friendTab1.dispose)then
		self.friendTab1:dispose()
	end
	if(self.friendTab2 and self.friendTab2.dispose)then
		self.friendTab2:dispose()
	end
	self.layerTab1=nil
	self.layerTab2=nil
	self.friendTab1=nil
	self.friendTab2=nil
	self.pageUpBtn=nil
	self.pageDownBtn=nil
end
