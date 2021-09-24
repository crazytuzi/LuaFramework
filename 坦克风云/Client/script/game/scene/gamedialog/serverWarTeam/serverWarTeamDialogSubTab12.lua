serverWarTeamDialogSubTab12={}

function serverWarTeamDialogSubTab12:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function serverWarTeamDialogSubTab12:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initTableView()
	-- self:checkInitPlayerTip()
	return self.bgLayer
end

function serverWarTeamDialogSubTab12:initTableView()
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-240),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(30,30))
	self.tv:setMaxDisToBottomOrTop(60)
	self.bgLayer:addChild(self.tv)
end

function serverWarTeamDialogSubTab12:eventHandler(handler,fn,idx,cel)
	local strSize2 = 22
	local strWidth2 = 150
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =28
        strWidth2 =150
    end
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-60,180)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function ( ... ) end)
		cellBg:setTouchPriority(-(self.layerNum-1)*20)
		cellBg:setAnchorPoint(ccp(0.5,0))
		cellBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,175))
		cellBg:setPosition(ccp((G_VisibleSizeWidth-60)/2,5))
		cell:addChild(cellBg)

		local function showInfo()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)
				local strTb
				local colorTb={}
				if(idx==0)then
					local serverNum=SizeOfTable(serverWarTeamVoApi:getServerList())
					local allianceNum=math.ceil(serverWarTeamCfg.sevbattleAlliance/serverNum)
					strTb={"\n",getlocal("serverwarteam_teamInfo4"),"\n",getlocal("serverwarteam_teamInfo3"),"\n",getlocal("serverwarteam_teamInfo2",{math.ceil(serverWarTeamCfg.warTime/60)}),"\n",getlocal("serverwarteam_teamInfo1",{serverNum,allianceNum}),"\n"}
				else
					strTb={"\n",getlocal("serverwar_koInfo4"),"\n",getlocal("serverwar_koInfo3"),"\n",getlocal("serverwar_koInfo2"),"\n",getlocal("serverwar_koInfo1"),"\n"}
				end
				local td=smallDialog:new()
				local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTb,25,colorTb)
				sceneGame:addChild(dialog,self.layerNum+1)
			end
		end
		local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
		local infoBtn = CCMenu:createWithItem(infoItem)
		infoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		infoBtn:setPosition(ccp(G_VisibleSizeWidth-280,90))
		cell:addChild(infoBtn)
		local function onClickEnter()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				self:clickHandler(idx)
			end
		end
		local iconName
		local titleStr
		-- if(idx==0)then
		-- 	iconName="tankVSIcon.png"
		-- 	-- iconName="serverWarTIcon.png"
		-- 	titleStr=getlocal("serverwar_groupMatch")
		-- else
			iconName="cupIcon.png"
			-- iconName="serverWarTIcon.png"
			titleStr=getlocal("serverwar_knockoutMath")
		-- end
		local enterItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickEnter,nil,getlocal("allianceWar_enter"),25)
		local enterBtn=CCMenu:createWithItem(enterItem)
		enterBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		enterBtn:setAnchorPoint(ccp(0,0.5))
		enterBtn:setPosition(ccp(G_VisibleSizeWidth-150,90))
		cell:addChild(enterBtn)
		local newsIcon=CCSprite:createWithSpriteFrameName("IconTip.png")
		newsIcon:setAnchorPoint(ccp(1,0.5))
		newsIcon:setPosition(ccp(160,60))
		newsIcon:setVisible(false)
		self["newIcon"..(idx+1)]=newsIcon
		enterItem:addChild(newsIcon,2)


		local icon=GetBgIcon(iconName,nil,nil,80,100)
		icon:setAnchorPoint(ccp(0,0.5))
		icon:setPosition(ccp(10,90))
		cell:addChild(icon)

		local titleLb=GetTTFLabelWrap(titleStr,strSize2,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		titleLb:setColor(G_ColorYellowPro)
		titleLb:setAnchorPoint(ccp(0,0))
		titleLb:setPosition(ccp(120,100))
		cell:addChild(titleLb)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function serverWarTeamDialogSubTab12:checkInitPlayerTip()
	if(serverWarTeamVoApi:checkIsPlayer())then
		local function callback()
			if(serverWarTeamVoApi:checkPlayerHasBattle())then
				for i=0,#(serverWarTeamVoApi:getBattleTimeList())-1 do
					local roundStatus=serverWarTeamVoApi:getRoundStatus(i)
					if(roundStatus>=10 and roundStatus<30)then
						self.playerCurRound=i
						base:addNeedRefresh(self)
						break
					end
				end
			end
		end
		serverWarTeamVoApi:getScheduleInfo(callback)
	end
end

function serverWarTeamDialogSubTab12:tick()
	if(self.playerCurRound)then
		if(serverWarTeamVoApi.todayScheduleBtnHasClick~=playerVoApi:getUid().."-"..base.curZoneID)then
			if(self.playerCurRound==0)then
				self.newIcon1:setVisible(true)
			else
				self.newIcon2:setVisible(true)
			end
		else
			self.newIcon1:setVisible(false)
			self.newIcon2:setVisible(false)
		end
	end
end

function serverWarTeamDialogSubTab12:clickHandler(type)
	local function getWarInfoHandler()
		if(type==0)then
			serverWarTeamOutScene:show(self.layerNum+1)
		end
	end
	serverWarTeamVoApi:getWarInfo(getWarInfoHandler)
end

function serverWarTeamDialogSubTab12:dispose()
	base:removeFromNeedRefresh(self)
end