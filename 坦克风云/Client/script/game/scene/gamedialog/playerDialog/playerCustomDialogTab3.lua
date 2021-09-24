playerCustomDialogTab3={}

function playerCustomDialogTab3:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.tvTb={}
	return nc
end

function playerCustomDialogTab3:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initTableView()

	-- 添加监听事件
	local function playerIconChange(event,data)
        self:refresh(data)
    end
    self.playerIconChangeListener=playerIconChange
    eventDispatcher:addEventListener("playerCustomDialogTab3.playerIconChange",playerIconChange)

    playerVoApi:delNewUnlockTb(3)
	return self.bgLayer
end

function playerCustomDialogTab3:initTableView()
	local topBgSprite=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function()end)
    topBgSprite:setContentSize(CCSizeMake(616,187))
    topBgSprite:setAnchorPoint(ccp(0.5,1))
    topBgSprite:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-165)
    self.bgLayer:addChild(topBgSprite)
    self.topBgSprite=topBgSprite

    self.curSelectedChatFrameId=playerVoApi:getCfid()
    self:setTopInfo(playerVoApi:getCfid())

    self:setCellHegith()

    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    tvBg:setContentSize(CCSizeMake(616,G_VisibleSizeHeight-topBgSprite:getContentSize().height-275))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(G_VisibleSizeWidth/2,topBgSprite:getPositionY()-topBgSprite:getContentSize().height-15)
    self.bgLayer:addChild(tvBg)

    local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvBg:getContentSize().width-5,tvBg:getContentSize().height-5),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(2.5,2.5))
    tvBg:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)

    G_addForbidForSmallDialog2(self.bgLayer,tvBg,-(self.layerNum-1)*20-2,nil,1)

    local function saveHandler()
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:saveEvent()
    end
    local saveBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",saveHandler,11)
    saveBtn:setScale(0.8)
    saveBtn:setAnchorPoint(ccp(0.5,0.5))
    local menu=CCMenu:createWithItem(saveBtn)
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    menu:setPosition(ccp(G_VisibleSizeWidth/2,tvBg:getPositionY()-tvBg:getContentSize().height-15-saveBtn:getContentSize().height*saveBtn:getScale()/2))
    self.bgLayer:addChild(menu)
    local btnLb=GetTTFLabel(getlocal("collect_border_save"),24,true)
    btnLb:setPosition(menu:getPosition())
    self.bgLayer:addChild(btnLb)
    self.saveBtn=saveBtn
end

function playerCustomDialogTab3:setTopInfo(chatFrameId)
    -- self.topBgSprite:removeAllChildrenWithCleanup(true)
    self.timeValue=nil
	self.timeLb=nil
	local bgNode = self.topBgSprite:getChildByTag(100)
	if bgNode and tolua.cast(bgNode,"CCNode") then
		bgNode:removeFromParentAndCleanup(true)
		bgNode=nil
	end
	bgNode=CCNode:create()
	bgNode:setContentSize(self.topBgSprite:getContentSize())
	bgNode:setTag(100)
	self.topBgSprite:addChild(bgNode)

	if chatFrameId==nil then
		chatFrameId = self.curSelectedChatFrameId
	end
	local headId = playerVoApi:getPic()
    local headFrameId = playerVoApi:getHfid()

	local personPhotoName=playerVoApi:getPersonPhotoName(headId)
	local photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName,nil,nil,nil,nil,headFrameId)
	photoSp:setPosition(85,self.topBgSprite:getContentSize().height/2)
	photoSp:setScale(140/photoSp:getContentSize().height)
	bgNode:addChild(photoSp)

	local fontSize = 20
	-- local hfCfg = headFrameCfg.list[tostring(headFrameId)]

	-- if "icon_bg_gray.png"~=hfCfg.pic then
	-- 	local frameSp=CCSprite:createWithSpriteFrameName(hfCfg.pic)
	-- 	frameSp:setPosition(photoSp:getContentSize().width/2,photoSp:getContentSize().height/2)
	-- 	frameSp:setScale((photoSp:getContentSize().width+7)/frameSp:getContentSize().width)
	-- 	photoSp:addChild(frameSp)
	-- end

	local cfCfg = chatFrameCfg.list[tostring(chatFrameId)]
	local rect=CCRect(30,25,1,1)
	if cfCfg.pic[1]~="chat_bg_left.png" then
		rect=CCRect(48,25,1,1)
	end
	local subPosy = cfCfg.pic2 and 10 or 0
	local cfSp = LuaCCScale9Sprite:createWithSpriteFrameName(cfCfg.pic[1],rect,function()end)
	if G_isAsia() == false then
		cfSp:setContentSize(CCSizeMake(self.topBgSprite:getContentSize().width-photoSp:getContentSize().width*photoSp:getScale()-30,self.topBgSprite:getContentSize().height/2+10))
	else
		cfSp:setContentSize(CCSizeMake(self.topBgSprite:getContentSize().width-photoSp:getContentSize().width*photoSp:getScale()-30,self.topBgSprite:getContentSize().height/2))
	end
	cfSp:setAnchorPoint(ccp(0,0.5))
	cfSp:setPosition(photoSp:getPositionX()+photoSp:getContentSize().width*photoSp:getScale()/2+5,self.topBgSprite:getContentSize().height/2 - subPosy)
	bgNode:addChild(cfSp)

	if cfCfg.pic2 then
		local cfSp2 = CCSprite:createWithSpriteFrameName(cfCfg.pic2[1])
		cfSp2:setAnchorPoint(ccp(0,0))
		cfSp2:setPosition(10,cfSp:getContentSize().height - 8)
		cfSp:addChild(cfSp2)
	end

	local frameLb=GetTTFLabel(getlocal("use_deadline"),fontSize)
	frameLb:setAnchorPoint(ccp(0,1))
	frameLb:setPosition(25,cfSp:getContentSize().height-20)
	cfSp:addChild(frameLb)

	local _txtColor=G_ColorGreen
	local _islock = true
	local _timeStr=nil
	local unLockData=playerVoApi:getUnLockData(3)
	local unLockChatFrame = playerVoApi:getUnLockChatFrame()
	if unLockData then
		for k, v in pairs(unLockData) do
			if tostring(v[1])==tostring(chatFrameId) then
				_txtColor=G_ColorRed
				if v[2]<=base.serverTime then
					_timeStr=getlocal("expireDesc")
				else
					_timeStr=G_formatActiveDate(v[2] - base.serverTime)
					self.timeValue=v[2]
					_islock = false
				end
				break
			end
		end
	end
	if _timeStr == nil then
		if cfCfg.time then
			_timeStr = getlocal("signRewardDay",{G_formatSecond(cfCfg.time, 1)})
		else
			_timeStr = getlocal("foreverTime")
		end
	end
	local timeLb=GetTTFLabel(_timeStr,fontSize)
	timeLb:setAnchorPoint(ccp(0,1))
	timeLb:setPosition(frameLb:getPositionX()+frameLb:getContentSize().width,frameLb:getPositionY())
	timeLb:setColor(_txtColor)
	cfSp:addChild(timeLb)
	self.timeLb=timeLb

	local deblockingLb=GetTTFLabel(getlocal("deblocking_condition"),fontSize)
	deblockingLb:setAnchorPoint(ccp(0,1))
	deblockingLb:setPosition(frameLb:getPositionX(),frameLb:getPositionY()-frameLb:getContentSize().height-10)
	cfSp:addChild(deblockingLb)

	local conditionStr=getlocal("alliance_info_content")
	if cfCfg.type==1 and cfCfg.gemCost>0 then
		conditionStr=tostring(cfCfg.gemCost)..getlocal("gem")
	elseif cfCfg.type==3 then
		conditionStr=getlocal("activity_get")
	elseif cfCfg.type==4 then
		conditionStr=getlocal("fightLevel",{cfCfg.level})
	elseif cfCfg.type==5 then
		conditionStr=getlocal("VIPStr1",{cfCfg.vip})
	elseif cfCfg.type==6 then
		conditionStr=getlocal("getInAc")
	elseif cfCfg.type==7 then
		conditionStr=getlocal("getInWar")
	end
	local conditionLb=GetTTFLabel(conditionStr,fontSize)
	if (deblockingLb:getContentSize().width + conditionLb:getContentSize().width) > (cfSp:getContentSize().width - frameLb:getPositionX() - 15) then
		conditionLb = GetTTFLabelWrap(conditionStr,fontSize,CCSize(cfSp:getContentSize().width - frameLb:getPositionX() - deblockingLb:getContentSize().width - 15, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	end
	conditionLb:setAnchorPoint(ccp(0,1))
	conditionLb:setPosition(deblockingLb:getPositionX()+deblockingLb:getContentSize().width,deblockingLb:getPositionY())
	cfSp:addChild(conditionLb)

	if cfCfg.type == 6 and unLockChatFrame and _islock then
		for m,q in pairs(unLockChatFrame) do
            if tostring(q)==tostring(headId) then
                _islock = false
                do break end
            end
        end
    end
    if _isLock and cfCfg.type == 6 or cfCfg.type == 7 then-- 有新增需要加逻辑
    	conditionLb:setColor(G_ColorRed)
    end

	local function createButton(btnStr,btnIsEnabled,pos,callback)
		local function btnHandler(...)
			if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
			if callback then
				callback(...)
			end
		end
		-- local buttonScale=0.4
		local buttonScale=0.6
		local btnImage1,btnImage2,btnImage3="creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png"
		if btnType==1 then
			btnImage1,btnImage2,btnImage3="newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png"
		end
		local button=GetButtonItem(btnImage1,btnImage2,btnImage3,btnHandler,11,btnStr,24/buttonScale)
		button:setScale(buttonScale)
	    -- button:setAnchorPoint(ccp(0,0.5))
	    button:setAnchorPoint(ccp(1,0.5))
	    local menu=CCMenu:createWithItem(button)
	    menu:setTouchPriority(-(self.layerNum-1)*20-4)
	    menu:setPosition(pos)
	    cfSp:addChild(menu)
	    button:setEnabled(btnIsEnabled)
	end
	-- local btnPos=ccp(conditionLb:getPositionX()+conditionLb:getContentSize().width+5,conditionLb:getPositionY()-conditionLb:getContentSize().height/2)
	local btnPos=ccp(cfSp:getContentSize().width-10,conditionLb:getPositionY()-conditionLb:getContentSize().height/2+5)
	if cfCfg.type==1 and cfCfg.gemCost>0 then
		local btnIsEnabled=false
		local btnStr=getlocal("hasBuy")
		local count=self:checkJiesuo(chatFrameId)
		if count==0 then
			conditionLb:setColor(G_ColorRed)
			btnIsEnabled=true
			btnStr=getlocal("buy")
		end
		createButton(btnStr,btnIsEnabled,btnPos,function()
			print("cjl --------->>> 购买聊天框逻辑...")
			local tipStr=getlocal("system_not_open",{getlocal("buy")})
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30,nil,true)
		end)
	elseif cfCfg.type==4 and playerVoApi:getPlayerLevel()<cfCfg.level then
		conditionLb:setColor(G_ColorRed)
		createButton(getlocal("upgradeBuild"),true,btnPos,function()
			-- print("cjl --------->>> 跳转到升级...")
			G_goToDialog("cn",self.layerNum+1,true)
		end,1)
	elseif cfCfg.type==5 and playerVoApi:getVipLevel()<cfCfg.vip then
		conditionLb:setColor(G_ColorRed)
		createButton(getlocal("recharge"),true,btnPos,function()
			-- print("cjl --------->>> 跳转到VIP...")
			G_goToDialog("gb",self.layerNum+1,true)
		end)
	end
end

function playerCustomDialogTab3:saveEvent()
	local cfCfg = chatFrameCfg.list[tostring(self.curSelectedChatFrameId)]
	local unLockChatFrame = playerVoApi:getUnLockChatFrame()
	local _isCanSave=true --是否可以保存
	if cfCfg.type==1 and cfCfg.gemCost>0 then
		local count=self:checkJiesuo(self.curSelectedChatFrameId)
		if count==0 then
			_isCanSave=false
		end
	elseif cfCfg.type==4 and playerVoApi:getPlayerLevel()<cfCfg.level then
		_isCanSave=false
	elseif cfCfg.type==5 and playerVoApi:getVipLevel()<cfCfg.vip then
		_isCanSave=false
	elseif cfCfg.type==6 then
		_isCanSave=false
		if unLockChatFrame then
			for m,q in pairs(unLockChatFrame) do
	            if tostring(q)==tostring(self.curSelectedChatFrameId) then
	                _isCanSave = true
	                do break end
	            end
	        end
	    end
	elseif cfCfg.time then
		_isCanSave = false
		local newUnlockTb=playerVoApi:getNewUnlockTb(3)
		local unLockData=playerVoApi:getUnLockData(3)
		if newUnlockTb then
			for k,v in pairs(newUnlockTb) do
				if tostring(v) == tostring(self.curSelectedChatFrameId) then
					_isCanSave = true
					do break end
				end
			end
		end
		if _isCanSave == false and unLockData then
			for k,v in pairs(unLockData) do
				if tostring(v[1]) == tostring(self.curSelectedChatFrameId) and v[2]>base.serverTime then
					_isCanSave = true
					do break end
				end
			end
		end
	end

	if not _isCanSave then --聊天框未解锁
		local tipStr=getlocal("chat_buble_undeblocking")
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30,nil,true)
		do return end
	end

	local function callback2(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			playerVoApi:setCfid(self.curSelectedChatFrameId)
			local recordPoint=self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
			local tipStr=getlocal("save_success")
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30,nil,true)
		end
	end
	socketHelper:setChatBubble(self.curSelectedChatFrameId,callback2)
end

function playerCustomDialogTab3:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(616,self.cellHegith)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellWidth=611
		local selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("newSelectKuang.png",CCRect(30, 30, 1, 1),function()end)
		selectSp:setContentSize(CCSizeMake(134,134))
		selectSp:setPosition(99999,99999)
		selectSp:setVisible(false)
		cell:addChild(selectSp,10)

		local _posY = self.cellHegith
		for k,v in pairs(self.tvTb) do
			local cellType=1
			for i,j in pairs(v) do
				cellType=j.value.type
				break
			end

			local titleStr = ""
			if cellType==1 then
				titleStr = getlocal("defalut")..getlocal("chat_buble")
			elseif cellType==2 then
			elseif cellType==3 then
				titleStr = getlocal("time_limit")..getlocal("chat_buble")
			elseif cellType==4 then
				titleStr = getlocal("RankScene_level")..getlocal("chat_buble")
			elseif cellType==5 then
				titleStr = getlocal("vipTitle")..getlocal("chat_buble")
			elseif cellType == 6 then
	            titleStr = getlocal("activity")..getlocal("chat_buble")
	        elseif cellType == 7 then
	            titleStr = getlocal("warStr")..getlocal("chat_buble")
			end

			if k>1 then
				local topLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
				topLine:setContentSize(CCSizeMake(cellWidth,topLine:getContentSize().height))
				topLine:setPosition(cellWidth/2,_posY)
				cell:addChild(topLine)
				_posY=_posY-15
			end

			-- 标题
		    local lightSp1=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
		    lightSp1:setAnchorPoint(ccp(0.5,0.5))
		    lightSp1:setScaleX(4)
		    lightSp1:setPosition(cellWidth/2,_posY-25)
		    cell:addChild(lightSp1)
		    local nameLb1=GetTTFLabel(titleStr,24,true)
		    nameLb1:setAnchorPoint(ccp(0.5,0.5))
		    nameLb1:setPosition(cellWidth/2,lightSp1:getPositionY()+5)
		    cell:addChild(nameLb1)
		    local realNameW1=nameLb1:getContentSize().width
		    for i=1,2 do
		        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
		        local anchorX=1
		        local posX=cellWidth/2-(realNameW1/2+20)
		        local pointX=-7
		        if i==2 then
		            anchorX=0
		            posX=cellWidth/2+(realNameW1/2+20)
		            pointX=15
		        end
		        pointSp:setAnchorPoint(ccp(anchorX,0.5))
		        pointSp:setPosition(posX,nameLb1:getPositionY())
		        cell:addChild(pointSp)

		        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
		        pointLineSp:setAnchorPoint(ccp(0,0.5))
		        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
		        pointSp:addChild(pointLineSp)
		        if i==1 then
		            pointLineSp:setRotation(180)
		        end
		    end

		    _posY=_posY-25

		    local function sortFunc(a,b)
				return a.value.sortId<b.value.sortId
			end
			table.sort(v,sortFunc)

			local startX=85
			local startY=_posY-95
			local addW=145
			local addH=145

			for i,j in pairs(v) do
				local bgSp
				local function changeIcon()
					if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		                if G_checkClickEnable()==false then
		                    do return end
		                else
		                    base.setWaitTime=G_getCurDeviceMillTime()
		                end
						PlayEffect(audioCfg.mouseClick)

						selectSp:setPosition(bgSp:getPosition())
						selectSp:setVisible(true)
						self.curSelectedChatFrameId=j.key
						self:setTopInfo(self.curSelectedChatFrameId)
					end
				end
				bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("fi_bubble_bg.png",CCRect(4,4,1,1),changeIcon)
				bgSp:setContentSize(CCSizeMake(128,128))
				cell:addChild(bgSp)
				bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
				local rect=CCRect(30,25,1,1)
				if j.value.pic[1]~="chat_bg_left.png" then
					rect=CCRect(48,25,1,1)
				end
				local subPosy = j.value.pic2 and 5 or 0
				local frameSp=LuaCCScale9Sprite:createWithSpriteFrameName(j.value.pic[1],rect,function()end)
				frameSp:setContentSize(CCSizeMake(bgSp:getContentSize().width-40,bgSp:getContentSize().height/2))
				frameSp:setPosition(bgSp:getContentSize().width/2,bgSp:getContentSize().height/2 - subPosy)
				bgSp:addChild(frameSp)
				local msgLb=GetTTFLabelWrap(getlocal("hello"),20,CCSize(frameSp:getContentSize().width-25,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				msgLb:setAnchorPoint(ccp(0,0.5))
				msgLb:setPosition(25,frameSp:getContentSize().height/2)
				frameSp:addChild(msgLb)

				if j.value.pic2 then
					local frameSp2 = CCSprite:createWithSpriteFrameName(j.value.pic2[1])
					frameSp2:setAnchorPoint(ccp(0,0))
					frameSp2:setPosition(10,frameSp:getContentSize().height - 8)
					frameSp:addChild(frameSp2)
				end

				local num2 = math.floor(i/4)
				local num1 = i%4
				if num1==0 then
					num1=4
					num2=num2-1
				end
				bgSp:setPosition(startX+(num1-1)*addW, startY-num2*addH)
				if tostring(j.key)==tostring(self.curSelectedChatFrameId) then
					selectSp:setPosition(bgSp:getPosition())
					selectSp:setVisible(true)
					-- self.curSelectedCellItemPosY=bgSp:getPositionY()-70
				end
				if tostring(j.key)==tostring(playerVoApi:getCfid()) then
					local useSp=LuaCCScale9Sprite:createWithSpriteFrameName("fi_used.png",CCRect(1,1,7,7),function()end)
					useSp:setContentSize(CCSizeMake(bgSp:getContentSize().width,25))
					useSp:setAnchorPoint(ccp(0.5,0))
					useSp:setPosition(bgSp:getContentSize().width/2,0)
					bgSp:addChild(useSp)
					useSp:setOpacity(255*0.8)
					local useLb=GetTTFLabel(getlocal("in_use"),18,true)
					useLb:setPosition(useSp:getContentSize().width/2,useSp:getContentSize().height/2)
					useSp:addChild(useLb)
				end
				--判断是否有‘新’的标志
				local newUnlockTb=playerVoApi:getNewUnlockTb(3)
				local unLockData=playerVoApi:getUnLockData(3)
				local unLockChatFrame = playerVoApi:getUnLockChatFrame()
				if newUnlockTb then
					for m,q in pairs(newUnlockTb) do
						if tostring(q)==tostring(j.key) then
							--此处添加‘新’的图片和文字
							local newSp=CCSprite:createWithSpriteFrameName("fi_newFlag.png")
							newSp:setAnchorPoint(ccp(0,1))
							newSp:setPosition(0,bgSp:getContentSize().height)
							bgSp:addChild(newSp,5)
							newSp:setScale(0.8)
							local newLb=GetTTFLabel(getlocal("new_text"),14/newSp:getScale(),true)
							newLb:setPosition(newSp:getContentSize().width/2-12,newSp:getContentSize().height/2+15)
							newLb:setRotation(-47)
							newLb:setColor(G_ColorYellow)
							newSp:addChild(newLb)
							break
						end
					end
				end
				local _isLock = false--是否上锁
				if cellType==1 and j.value.gemCost>0 then
					local count=self:checkJiesuo(j.key)
					if count==0 then
						_isLock=true
					end
				elseif cellType==4 and playerVoApi:getPlayerLevel()<j.value.level then
					_isLock=true
				elseif cellType==5 and playerVoApi:getVipLevel()<j.value.vip then
					_isLock=true

				elseif cellType == 6 then
					_isLock=true
					if unLockChatFrame then
						for m,q in pairs(unLockChatFrame) do
				            if tostring(q)==tostring(j.key) then
				                _isLock = false
				                do break end
				            end
				        end
				    end
				end
				if _isLock == false and j.value.time then
					_isLock = true
					if newUnlockTb then
						for k,v in pairs(newUnlockTb) do
							if tostring(v) == tostring(j.key) then
								_isLock = false
								do break end
							end
						end
					end
					if _isLock and unLockData then
						for k,v in pairs(unLockData) do
							-- print("v-------j.key------>>>>",k,v,v[1],j.key)
							-- print("v[2]========>>>>>>",v[2])
							if tostring(v[1]) == tostring(j.key) and v[2]>base.serverTime then
								_isLock = false
								do break end
							end
						end
					end
				end

				if _isLock then
					local contentSize = bgSp:getContentSize()
					local sp = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
					sp:setPosition(contentSize.width/2, contentSize.height/2)
					sp:setScale(contentSize.width/sp:getContentSize().width)
					sp:setOpacity(140)
					bgSp:addChild(sp)

					local lockSp = CCSprite:createWithSpriteFrameName("LockIcon.png")
					lockSp:setPosition(contentSize.width, 0)
					lockSp:setAnchorPoint(ccp(1,0))
					lockSp:setScale(0.5)
					bgSp:addChild(lockSp)
				end
				_posY=bgSp:getPositionY()-90
			end
		end

		return cell
	elseif fn=="ccTouchBegan" then
		return true
	elseif fn=="ccTouchMoved" then
	elseif fn=="ccTouchEnded"  then
	end
end

function playerCustomDialogTab3:checkJiesuo(key)
	local count=0
	local unLockData=playerVoApi:getUnLockData(3)
	if unLockData then
		for q,m in pairs(unLockData) do
			if tostring(m[1])==tostring(key) then
				count=1
				return count
			end
		end
	end
	return count
end

function playerCustomDialogTab3:setCellHegith()
	self.tvTb={}
	self.cellHegith=0
	local commonTb = {}
	local limitTb  = {}
	local levelTb  = {}
	local vipTb    = {}
	local acTb 	   = {}
	local warTb    = {}
	local unLockData=playerVoApi:getUnLockData(3)
	for k, v in pairs(chatFrameCfg.list) do
		if v.type==1 then
			table.insert(commonTb,{key=k,value=v})
		elseif v.type==3 then
			if unLockData then
				for m,q in pairs(unLockData) do
					if tostring(q[1])==tostring(k) and q[2]>base.serverTime then
	            		table.insert(limitTb,{key=k,value=v})
	            		break
	            	end
				end
			end
		elseif v.type==4 then
			table.insert(levelTb,{key=k,value=v})
		elseif v.type==5 then
			table.insert(vipTb,{key=k,value=v})
		elseif v.type == 6 then
			table.insert(acTb,{key=k,value=v})
		elseif v.type == 7 then
			table.insert(warTb,{key=k,value=v})
		end
	end

	--基础聊天框
	if commonTb and SizeOfTable(commonTb)~=0 then
		table.insert(self.tvTb,commonTb)
		self.cellHegith=self.cellHegith+50
	end

	--限时聊天框
	if limitTb and SizeOfTable(limitTb)~=0 then
		table.insert(self.tvTb,limitTb)
		self.cellHegith=self.cellHegith+50
	end

	--等级聊天框
	if levelTb and SizeOfTable(levelTb)~=0 then
		table.insert(self.tvTb,levelTb)
		self.cellHegith=self.cellHegith+50
	end

	--VIP聊天框
	if vipTb and SizeOfTable(vipTb)~=0 then
		table.insert(self.tvTb,vipTb)
		self.cellHegith=self.cellHegith+50
	end

	if SizeOfTable(acTb)~=0 then
		table.insert(self.tvTb,acTb)
		self.cellHegith=self.cellHegith+50
	end

	if SizeOfTable(warTb)~=0 then
		table.insert(self.tvTb,warTb)
		self.cellHegith=self.cellHegith+50
	end

	for k,v in pairs(self.tvTb) do
		local num = SizeOfTable(v)
		self.cellHegith=self.cellHegith+160*math.ceil(num/4)
	end
end

function playerCustomDialogTab3:refresh(data)
	if self then
		local _index=tonumber(data[1])
		local _id=tostring(data[2])
		if _index==3 then --聊天气泡过期
			if _id==tostring(self.curSelectedChatFrameId) then --如果当前选择的聊天气泡过期
				self.curSelectedChatFrameId=playerVoApi:getCfid()
				self:setTopInfo(self.curSelectedChatFrameId)
			end
			self:setCellHegith()
			self.tv:reloadData()
		else --当前使用的头像或头像框过期，更新UI
			self:setTopInfo(self.curSelectedChatFrameId)
		end
	end
end

function playerCustomDialogTab3:tick()
	if self then
		if self.timeValue and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
			self.timeLb:setString(G_formatActiveDate(self.timeValue - base.serverTime))
		end
	end
end

function playerCustomDialogTab3:dispose()
	eventDispatcher:removeEventListener("playerCustomDialogTab3.playerIconChange",self.playerIconChangeListener)
	self.timeValue=nil
	self.timeLb=nil
end