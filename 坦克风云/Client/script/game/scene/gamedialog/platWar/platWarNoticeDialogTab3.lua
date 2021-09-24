platWarNoticeDialogTab3={}

function platWarNoticeDialogTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
	self.selectedTabIndex=2
	self.chatDialog=nil
	self.cellBgTab={}
    self.isFirst=true
    self.fastTickId=0
    self.noticeShowSeq={} 	--需要显示的新消息的序列
    self.showNotice=nil		--当前显示的消息
    -- self.firstShowNum=10	--刚打开板子显示公告条数
    return nc
end

function platWarNoticeDialogTab3:initShowNotice()
	local list=G_clone(platWarVoApi:getNoticeListByType(self.selectedTabIndex+1))
	-- local msgNum=SizeOfTable(list)
	-- if msgNum>self.firstShowNum then
	-- 	for k,v in pairs(list) do
	-- 		if k>10 then
	-- 			table.insert(self.noticeShowSeq,v)
	-- 		else
	-- 			table.insert(self.showNotice,v)
	-- 		end
	-- 	end
	-- else
		self.showNotice=list
	-- end
end

function platWarNoticeDialogTab3:init(layerNum,selectedTabIndex,chatDialog)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
	self.selectedTabIndex=selectedTabIndex
	self.chatDialog=chatDialog
	self:initShowNotice()
    self:initTableView()
    return self.bgLayer
end

--设置对话框里的tableView
function platWarNoticeDialogTab3:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-15,self.bgLayer:getContentSize().height-270-10),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,100))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function platWarNoticeDialogTab3:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		-- local list=platWarVoApi:getNoticeListByType(self.selectedTabIndex+1)
		local msgNum=0
		if self.showNotice then
			local list=self.showNotice
			msgNum=SizeOfTable(list)
		end
		return msgNum
	elseif fn=="tableCellSizeForIndex" then
		-- local list=platWarVoApi:getNoticeListByType(self.selectedTabIndex+1)
		if self.showNotice==nil then
			do return end
		end
		local list=self.showNotice
		local noticeVo=list[idx+1]
		if noticeVo==nil then
			do return end
		end
		local msgData=noticeVo.msgData
		local height=msgData.height
		tmpSize=CCSizeMake(600,height+5)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		-- local list=platWarVoApi:getNoticeListByType(self.selectedTabIndex+1)
		if self.showNotice==nil then
			do return end
		end
		local list=self.showNotice
		local msgNum=SizeOfTable(list)
		if msgNum<=0 then
			do return end
		end
		local noticeVo=list[idx+1]
		if noticeVo==nil then
			do return end
		end
		local msgData=noticeVo.msgData
		local type=noticeVo.type
		local content=noticeVo.content
		--local showMsg=msgData.message
		local params=noticeVo.params
		--local width=tonumber(msgData.width)
		--local height=tonumber(msgData.rows)*35
		if type==nil then
			do return end
		end
		
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local vip=0
		if params and params.vip then
			vip=params.vip or 0
		end
		
		local wSpace=5
		local hSpace=5
		local width=msgData.width
		local height=msgData.height
		local color=msgData.color
		
		local typeWidth=55

		--平台图标
		local spSize=36
		local spaceX=10
		if noticeVo.platform then
			local platIcon=platWarVoApi:getPlatIcon(noticeVo.platform)
			if platIcon then
				local typeScale=spSize/platIcon:getContentSize().width
				platIcon:setAnchorPoint(ccp(0.5,0.5))
				platIcon:setPosition(ccp(wSpace+platIcon:getContentSize().width/2*typeScale+spaceX,height+hSpace-platIcon:getContentSize().height/2*typeScale))
				cell:addChild(platIcon,3)
				platIcon:setScale(typeScale)
			end
		end

		local timeStr=G_chatTime(noticeVo.time,true)
		timeLabel=GetTTFLabel(timeStr,26)
		timeLabel:setAnchorPoint(ccp(1,1))
		timeLabel:setPosition(ccp(590,height+hSpace-3))
		cell:addChild(timeLabel,3)
		timeLabel:setColor(color)
		
		local messageLabel
		local msgX=0
		local msgY=-1
		
		local rect = CCRect(0, 0, 50, 50)
		local capInSet = CCRect(20, 20, 10, 10)
		local senderLabel

		local function cellClick1(hd,fn,idx)
			if G_checkClickEnable()==false then
                do
                    return
                end
            end
			if self.tv:getIsScrolled()==true then
				do return end
			end
			base:setWait()
			if self.cellBgTab and self.cellBgTab[idx] then
				local function touchCallback()
					self:cellClick(noticeVo)
					base:cancleWait()
				end
				local fadeIn=CCFadeIn:create(0.2)
			    --local delay=CCDelayTime:create(2)
			    local fadeOut=CCFadeOut:create(0.2)
				local callFunc=CCCallFuncN:create(touchCallback)
			    local acArr=CCArray:create()
			    acArr:addObject(fadeIn)
			    --acArr:addObject(delay)
			    acArr:addObject(fadeOut)
			    acArr:addObject(callFunc)
			    local seq=CCSequence:create(acArr)
				self.cellBgTab[idx]:runAction(seq)
			end
		end
		local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSet,cellClick1)
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setTag(noticeVo.index)
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp(2,0))
		cell:addChild(backSprie,1)
		backSprie:setContentSize(CCSizeMake(596,height+hSpace))
		backSprie:setOpacity(0)
		table.insert(self.cellBgTab,noticeVo.index,backSprie)
	
		local function showPlayerInfoHandler(hd,fn,idx)
			if G_checkClickEnable()==false then
                do
                    return
                end
            end
			if self.tv:getIsScrolled()==true then
				do return end
			end
			base:setWait()
			if self.cellBgTab and self.cellBgTab[idx] then
				local function touchCallback()
					-- self:cellClick(idx,1)
					self:cellClick(noticeVo)
					base:cancleWait()
				end
				local fadeIn=CCFadeIn:create(0.2)
			    --local delay=CCDelayTime:create(2)
			    local fadeOut=CCFadeOut:create(0.2)
				local callFunc=CCCallFuncN:create(touchCallback)
			    local acArr=CCArray:create()
			    acArr:addObject(fadeIn)
			    --acArr:addObject(delay)
			    acArr:addObject(fadeOut)
			    acArr:addObject(callFunc)
			    local seq=CCSequence:create(acArr)
				self.cellBgTab[idx]:runAction(seq)
			end
		end

		if noticeVo.sender and noticeVo.senderName then	--普通聊天和战报
			-- local nameStr=chatVoApi:getNameStr(type,chatVo.platform,chatVo.senderName,chatVo.reciverName,chatVo.sender)
			local nameStr=noticeVo.senderName
			senderLabel=GetTTFLabel(nameStr,28)
			senderLabel:setAnchorPoint(ccp(0,1))
			senderLabel:setPosition(ccp(typeWidth+wSpace,height+hSpace-2))
			cell:addChild(senderLabel,3)
			senderLabel:setColor(color)
			
			local nameLabel=GetTTFLabel(nameStr,28)
			local nameBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,showPlayerInfoHandler)
			nameBgSp:ignoreAnchorPointForPosition(false)
			nameBgSp:setAnchorPoint(ccp(0,1))
			-- nameBgSp:setTag(noticeVo.index)
			nameBgSp:setIsSallow(true)
			nameBgSp:setTouchPriority(-(self.layerNum-1)*20-2)
			nameBgSp:setPosition(ccp(wSpace,height+hSpace-2))
			cell:addChild(nameBgSp,2)
			nameBgSp:setContentSize(CCSizeMake(nameLabel:getContentSize().width+wSpace+spSize+spaceX,nameLabel:getContentSize().height))
			nameBgSp:setOpacity(0)

			--军衔
			local rankSp=nil
			local spScale=0.6
			local showRank=platWarVoApi:isShowRank(params.rank)
			if showRank==true then
				local pic=playerVoApi:getRankIconName(params.rank)
				if pic then
					rankSp=CCSprite:createWithSpriteFrameName(pic)
					if rankSp then
		                rankSp:setScale(spScale)
		                rankSp:setPosition(wSpace+nameLabel:getContentSize().width+spSize+spaceX+20+rankSp:getContentSize().width/2*spScale,height+hSpace-2-nameLabel:getContentSize().height/2)
		                cell:addChild(rankSp,2)
		            end
	            end
			end

			--vip
			local vipIcon=nil
			if G_chatVip==true then
				if vip and vip~=0 then
                    if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
                        vipIcon = GetTTFLabel(getlocal("VIPStr1",{vip}),28)
                        vipIcon:setAnchorPoint(ccp(0,0.5))
                        vipIcon:setColor(G_ColorYellowPro)
                        vipIcon:setPosition(senderLabel:getContentSize().width+20,senderLabel:getContentSize().height/2-4)
                        if rankSp then
                        	vipIcon:setPosition(senderLabel:getContentSize().width+20+rankSp:getContentSize().width*spScale,senderLabel:getContentSize().height/2-4)
                        end
                        senderLabel:addChild(vipIcon,2)
                    else
                        vipIcon = CCSprite:createWithSpriteFrameName("chatVip"..vip..".png")
                        vipIcon:setAnchorPoint(ccp(0.5,0.5))
                        local scale=1
                        vipIcon:setScale(scale)
                        vipIcon:setPosition(wSpace+nameLabel:getContentSize().width+spSize+spaceX+20+30,height+hSpace-2-nameLabel:getContentSize().height/2)
                        if rankSp then
                        	vipIcon:setPosition(wSpace+nameLabel:getContentSize().width+spSize+spaceX+20+30+rankSp:getContentSize().width*spScale,height+hSpace-2-nameLabel:getContentSize().height/2)
                        end
                        cell:addChild(vipIcon,2)
                    end
				end
			end
		end

		local msgFont=nil
		--处理ios表情在安卓不显示问题
		if G_isIOS()==false then
			if platCfg.platCfgSameServerWithIos[G_curPlatName()] then
				local tmpTb={}
				tmpTb["action"]="EmojiConv"
				tmpTb["parms"]={}
				tmpTb["parms"]["str"]=tostring(content)
				local cjson=G_Json.encode(tmpTb)
				content=G_accessCPlusFunction(cjson)
				msgFont=G_EmojiFontSrc
			end
		end
		messageLabel=GetTTFLabelWrap(content,26,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,msgFont)
		msgX=msgX+typeWidth+wSpace
		msgY=msgY+messageLabel:getContentSize().height+hSpace

		messageLabel:setPosition(ccp(msgX,msgY))
		messageLabel:setAnchorPoint(ccp(0,1))
		cell:addChild(messageLabel,2)
		messageLabel:setColor(color)

        return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

--点击了cell或cell上某个按钮 type 1:用户信息,2:战报,3:军团战战报，5:远征战报
function platWarNoticeDialogTab3:cellClick(noticeVo)--(idx,type)
    PlayEffect(audioCfg.mouseClick)
    if noticeVo then
		local params=noticeVo.params
		local content1=getlocal("player_message_info_name",{noticeVo.senderName,params.level,playerVoApi:getRankName(params.rank)})
		local content2=getlocal("player_message_info_power").."    "..params.power
		--是否有联盟
		if params.allianceName then
			content3=getlocal("player_message_info_alliance").."    "..params.allianceName
		else
			content3=getlocal("player_message_info_alliance").."    "..getlocal("alliance_info_content")
		end
		local content={{content1,30},{content2,25},{content3,25}}
		local pic=params.pic
		local rank=params.rank
		local serverWarRank=params.wr or 0
		local startTime=params.st or 0
		if noticeVo.sender==playerVoApi:getUid() then
			smallDialog:showPlayerInfoSmallDialog("PanelHeaderPopup.png",CCSizeMake(550,450),CCRect(0, 0, 400, 400),CCRect(168, 86, 10, 10),getlocal("player_message_info_email"),emailCallBack,getlocal("player_message_info_whisper"),whisperCallBack,getlocal("player_message_info_title"),content,nil,self.layerNum+1,6,nil,resetBoxCallBack,nil,pic,nil,nil,nil,nil,rank,serverWarRank,startTime,params.title)
		else
			smallDialog:showPlayerInfoSmallDialog("PanelHeaderPopup.png",CCSizeMake(550,450),CCRect(0, 0, 400, 400),CCRect(168, 86, 10, 10),getlocal("player_message_info_email"),emailCallBack,getlocal("player_message_info_whisper"),whisperCallBack,getlocal("player_message_info_title"),content,nil,self.layerNum+1,6,nil,resetBoxCallBack,nil,pic,nil,nil,nil,nil,rank,serverWarRank,startTime,params.title)
		end
	end
end

function platWarNoticeDialogTab3:fastTick()
	-- self.fastTickId=self.fastTickId+1
	-- -- print("self.fastTickId",self.fastTickId)
	-- if self.fastTickId==99 then
	-- 	self.fastTickId=0
	-- end
	-- if self.fastTickId%3==0 then
	if self.showNotice then
		local seqNum1=SizeOfTable(self.noticeShowSeq)
		if seqNum1>0 then
			local recordPoint = self.tv:getRecordPoint()

			local addNotice=self.noticeShowSeq[1]
			table.insert(self.showNotice,addNotice)
			table.remove(self.noticeShowSeq,1)

			if SizeOfTable(self.showNotice)>=platWarCfg.noticeMaxNum then
				self.tv:removeCellAtIndex(0)
				table.remove(self.showNotice,1)
			end
			local showNum1=SizeOfTable(self.showNotice)
			self.tv:insertCellAtIndex(showNum1-1)

			self:resetTvPos()
			-- self.tv:recoverToRecordPoint(recordPoint)
		end
	end
end

function platWarNoticeDialogTab3:checkUpdate()
	if self.showNotice then
		local showNum=SizeOfTable(self.showNotice)
		local seqNum=SizeOfTable(self.noticeShowSeq)
		local showVo
		if seqNum>0 then
			showVo=self.noticeShowSeq[SizeOfTable(self.noticeShowSeq)]
		end
		if showVo==nil then
			if showNum>0 then
				showVo=self.showNotice[SizeOfTable(self.showNotice)]
			end
		end
		local list=G_clone(platWarVoApi:getNoticeListByType(self.selectedTabIndex+1))
		local lastVo=list[SizeOfTable(list)]
		if showVo and lastVo and lastVo.index~=showVo.index then
			for k,v in pairs(list) do
				if v and v.index>showVo.index then
					table.insert(self.noticeShowSeq,v)
				end
			end
		end
	end
end
function platWarNoticeDialogTab3:tick()
	local flag=platWarVoApi:getNoticeFlag(self.selectedTabIndex+1)
	local lastNoticeTime=platWarVoApi:getLastNoticeTime(self.selectedTabIndex+1)
	if flag==-1 or base.serverTime-lastNoticeTime>=15 then
		platWarVoApi:setLastNoticeTime(base.serverTime,self.selectedTabIndex+1)
		local isSuccess=platWarVoApi:initNoticeList(self.selectedTabIndex)
        if isSuccess==true then
        	if self.showNotice==nil or flag==-1 then
        		self:initShowNotice()
        		self:refresh()
        	else
        		self:checkUpdate()
        	end
        	platWarVoApi:setNoticeFlag(self.selectedTabIndex+1,1)
	    end
	elseif self.showNotice==nil then
		self:initShowNotice()
		self:refresh()
		-- self:checkUpdate()
	end
end

function platWarNoticeDialogTab3:resetTvPos()
	local recordPoint = self.tv:getRecordPoint()
	if recordPoint.y<0 then
		recordPoint.y=0
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function platWarNoticeDialogTab3:refresh()
	if self and self.tv then
		self.tv:reloadData()
		self:resetTvPos()
	end
end

--用户处理特殊需求,没有可以不写此方法
function platWarNoticeDialogTab3:doUserHandler()
	
end

function platWarNoticeDialogTab3:dispose()	
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
	self.selectedTabIndex=nil
	self.cellBgTab=nil
	self.fastTickId=0
	self.noticeShowSeq={} 	--需要显示的新消息的序列
    self.showNotice=nil		--当前显示的消息
    -- self.firstShowNum=10	--刚打开板子显示公告条数
    self=nil
end






