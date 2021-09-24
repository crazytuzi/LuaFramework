serverWarPersonalDialogSubTab12={}

function serverWarPersonalDialogSubTab12:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function serverWarPersonalDialogSubTab12:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initTableView()
	self:checkInitPlayerTip()
	return self.bgLayer
end

function serverWarPersonalDialogSubTab12:initTableView()
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-240),nil)
	tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	tableView:setPosition(ccp(30,30))
	tableView:setMaxDisToBottomOrTop(60)
	self.bgLayer:addChild(tableView)
end

function serverWarPersonalDialogSubTab12:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 2
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
			PlayEffect(audioCfg.mouseClick)
			local strTb
			local colorTb={}
			if(idx==0)then
				local playerNum=#(serverWarPersonalVoApi:getPlayerList())
				strTb={"\n",getlocal("serverwar_teamInfo5"),"\n",getlocal("serverwar_teamInfo4"),"\n",getlocal("serverwar_teamInfo3",{playerNum/2}),"\n",getlocal("serverwar_teamInfo2",{playerNum/2}),"\n",getlocal("serverwar_teamInfo1",{playerNum}),"\n"}
			else
				strTb={"\n",getlocal("serverwar_koInfo4"),"\n",getlocal("serverwar_koInfo3"),"\n",getlocal("serverwar_koInfo2"),"\n",getlocal("serverwar_koInfo1"),"\n"}
			end
			local td=smallDialog:new()
			local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTb,25,colorTb)
			sceneGame:addChild(dialog,self.layerNum+1)
		end
		local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
		local infoBtn = CCMenu:createWithItem(infoItem)
		infoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		infoBtn:setPosition(ccp(G_VisibleSizeWidth-280,90))
		cell:addChild(infoBtn)
		local function onClickEnter()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			self:clickHandler(idx)
		end
		local iconName
		local titleStr
		if(idx==0)then
			iconName="tankVSIcon.png"
			titleStr=getlocal("serverwar_groupMatch")
		else
			iconName="cupIcon.png"
			titleStr=getlocal("serverwar_knockoutMath")
		end
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

        local strSize =28
        if G_getCurChoseLanguage() =="ru" then
            strSize =16
        end

		local titleLb=GetTTFLabel(titleStr,strSize)
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

function serverWarPersonalDialogSubTab12:checkInitPlayerTip()
	if(serverWarPersonalVoApi:checkIsPlayer())then
		local function callback()
			if(serverWarPersonalVoApi:checkPlayerHasBattle())then
				for i=0,#(serverWarPersonalVoApi:getBattleTimeList())-1 do
					local roundStatus=serverWarPersonalVoApi:getRoundStatus(i)
					if(roundStatus>=10 and roundStatus<30)then
						self.playerCurRound=i
						base:addNeedRefresh(self)
						break
					end
				end
			end
		end
		serverWarPersonalVoApi:getScheduleInfo(callback)
	end
end

function serverWarPersonalDialogSubTab12:tick()
	if(self.playerCurRound)then
		if(serverWarPersonalVoApi.todayScheduleBtnHasClick~=playerVoApi:getUid().."-"..base.curZoneID)then
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

function serverWarPersonalDialogSubTab12:clickHandler(type)
	if((type==0 and self.playerCurRound==0) or (type==1 and self.playerCurRound and self.playerCurRound>0))then
		serverWarPersonalVoApi.todayScheduleBtnHasClick=playerVoApi:getUid().."-"..base.curZoneID
		self.newIcon1:setVisible(false)
		self.newIcon2:setVisible(false)
	end
	local function callback()
		if(type==0)then
			serverWarPersonalTeamScene:show(self.layerNum+1)
		else
			serverWarPersonalKnockOutScene:show(self.layerNum+1)
		end
	end
	serverWarPersonalVoApi:getScheduleInfo(callback)
end

function serverWarPersonalDialogSubTab12:dispose()
	base:removeFromNeedRefresh(self)
end