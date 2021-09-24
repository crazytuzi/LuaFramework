playerCustomDialogTab1={}

function playerCustomDialogTab1:new(parentDialog)
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.tvTb={}
	self.tvTb2={}
	self.bgLayer=nil
	self.layerNum=nil
	self.unlockHidTb = {}
	self.parentDialog=parentDialog
	return nc
end

function playerCustomDialogTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum =layerNum
	self:initTableView()

	-- 添加监听事件
	local function playerIconChange(event,data)
        self:refresh(data)
    end
    self.playerIconChangeListener=playerIconChange
    eventDispatcher:addEventListener("playerCustomDialogTab1.playerIconChange",playerIconChange)
	return self.bgLayer
end

function playerCustomDialogTab1:initTableView()
	local topBgSprite=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function()end)
    topBgSprite:setContentSize(CCSizeMake(616,187))
    topBgSprite:setAnchorPoint(ccp(0.5,1))
    topBgSprite:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-165)
    self.bgLayer:addChild(topBgSprite)
    self.topBgSprite=topBgSprite

    self.curSelectedHeadId=playerVoApi:getPic()
    self.curSelectedHeadFrameId=playerVoApi:getHfid()
    self:setTopInfo(playerVoApi:getPic(),playerVoApi:getHfid())

    local titleTab={getlocal("player_icon"),getlocal("head_frame")}
    self.allTabBtn={}
    local tabBtn=CCMenu:create()
    for i,v in pairs(titleTab) do
        local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0,1))
        tabBtnItem:setPosition(12+(i-1)*(tabBtnItem:getContentSize().width+4),topBgSprite:getPositionY()-topBgSprite:getContentSize().height-10)
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(i)
        local strsize = 24
        if G_getCurChoseLanguage() == "de" and i == 2 then
        	strsize = 20
        end
        local lb=GetTTFLabelWrap(v,strsize,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
        tabBtnItem:addChild(lb,1)

        local function tabClick(idx)
            PlayEffect(audioCfg.mouseClick)
            return self:tabBtnClick(idx)
        end
        tabBtnItem:registerScriptTapHandler(tabClick)
        self.allTabBtn[i]=tabBtnItem
    end
    tabBtn:setPosition(0,0)
    tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tabBtn)

	-- self:setTvNum()
	self:setHeadCellHeight()
	self:setHeadFrameCellHeight()

	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    tvBg:setContentSize(CCSizeMake(616,G_VisibleSizeHeight-topBgSprite:getContentSize().height-320))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(G_VisibleSizeWidth/2,topBgSprite:getPositionY()-topBgSprite:getContentSize().height-60)
    self.bgLayer:addChild(tvBg)

	local function callBack(...)
    	-- return self:eventHandler(...)
    	return self:eventHandlerNew(...)
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
    -- if tostring(self.curSelectedHeadId)==tostring(playerVoApi:getPic()) then
    -- 	self.saveBtn:setEnabled(false)
    -- else
    -- 	self.saveBtn:setEnabled(true)
    -- end

    self:tabBtnClick(1)
end

function playerCustomDialogTab1:tabBtnClick(idx)
    for k,v in pairs(self.allTabBtn) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabBtnIndex=idx
        else
            v:setEnabled(true)
        end
    end
    if self.tv then
        self.tv:reloadData()
        local cellHeight
        if self.selectedTabBtnIndex==1 then
			cellHeight=self.headCellHeight
		elseif self.selectedTabBtnIndex==2 then
			cellHeight=self.headFrameCellHeight
		end
        local tvSize = self.tv:getViewSize()
        local posY=self.curSelectedCellItemPosY or 0
        if cellHeight - posY>tvSize.height then
	        local tvPoint = self.tv:getRecordPoint()
	        if tvPoint.y < 0 then
	        	tvPoint.y=-self.curSelectedCellItemPosY
		    	self.tv:recoverToRecordPoint(tvPoint)
	        end
    	end
    	playerVoApi:delNewUnlockTb(idx)
    end
end

function playerCustomDialogTab1:setTopInfo(headId,headFrameId)
	-- self.topBgSprite:removeAllChildrenWithCleanup(true)
	self.timeValue=nil
	self.ftimeValue=nil
	self.timeLb=nil
	self.ftimeLb=nil
	local bgNode = self.topBgSprite:getChildByTag(100)
	if bgNode and tolua.cast(bgNode,"CCNode") then
		bgNode:removeFromParentAndCleanup(true)
		bgNode=nil
	end
	bgNode=CCNode:create()
	bgNode:setContentSize(self.topBgSprite:getContentSize())
	bgNode:setTag(100)
	self.topBgSprite:addChild(bgNode)

	local personPhotoName=playerVoApi:getPersonPhotoName(headId)
	local photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName)
	photoSp:setPosition(85,self.topBgSprite:getContentSize().height/2)
	photoSp:setScale(140/photoSp:getContentSize().height)
	bgNode:addChild(photoSp)

	local fontSize = 20
	local spaceH = 8
	local cfg = headCfg.list[tostring(headId)]

	local _lbPosX=photoSp:getPositionX()+photoSp:getContentSize().width*photoSp:getScale()/2+15
	local headLb=GetTTFLabel(getlocal("player_icon").."：",fontSize)
	headLb:setAnchorPoint(ccp(0,1))
	headLb:setPosition(_lbPosX,photoSp:getPositionY()+photoSp:getContentSize().height*photoSp:getScale()/2-10)
	bgNode:addChild(headLb)

	local nameLb=GetTTFLabel(getlocal(cfg.name),fontSize)
	nameLb:setAnchorPoint(ccp(0,1))
	nameLb:setPosition(headLb:getPositionX()+headLb:getContentSize().width,headLb:getPositionY())
	bgNode:addChild(nameLb)

	local maxVip=tonumber(playerVoApi:getMaxLvByKey("maxVip"))
	local _txtColor=G_ColorGreen
	local _timeStr=nil
	local headUnLockData=playerVoApi:getUnLockData(1)
	local unLockHead=playerVoApi:getUnLockHead()
	local _islock = true
	if headUnLockData then
		for k, v in pairs(headUnLockData) do
			if tostring(v[1])==tostring(headId) then
				if cfg.time then
					_txtColor=G_ColorRed
					if v[2]<=base.serverTime then
						_timeStr=getlocal("expireDesc")
					else
						_timeStr=G_formatActiveDate(v[2] - base.serverTime)
						self.timeValue=v[2]
						_islock = false
					end
				else
					_islock = false
				end
				break
			end
		end
	end
	if _timeStr == nil then
		if cfg.time then
			_timeStr = getlocal("signRewardDay",{G_formatSecond(cfg.time, 1)})
		else
			_timeStr = getlocal("foreverTime")
		end
	end
	if cfg.type == 6 and unLockHead and _islock then
		for m,q in pairs(unLockHead) do
            if tostring(q)==tostring(headId) then
                _islock = false
                do break end
            end
        end
    elseif cfg.type == 5 then
    	if(cfg.vip==nil or tonumber(cfg.vip)<=maxVip)then
			_islock = false
		end
	end
	self.curAddIsLock = _islock
	local timeLb=GetTTFLabel("(".._timeStr..")",fontSize)
	timeLb:setAnchorPoint(ccp(0,1))
	timeLb:setPosition(nameLb:getPositionX()+nameLb:getContentSize().width,nameLb:getPositionY())
	timeLb:setColor(_txtColor)
	bgNode:addChild(timeLb)
	self.timeLb=timeLb

	local deblockingLb=GetTTFLabel(getlocal("deblocking_condition"),fontSize)
	deblockingLb:setAnchorPoint(ccp(0,1))
	deblockingLb:setPosition(_lbPosX,headLb:getPositionY()-headLb:getContentSize().height-spaceH)
	bgNode:addChild(deblockingLb)

	local conditionStr=getlocal("alliance_info_content")
	if cfg.type==1 and cfg.gemCost>0 then
		conditionStr=tostring(cfg.gemCost)..getlocal("gem")
	elseif cfg.type==3 then
		conditionStr=getlocal("activity_get")
	elseif cfg.type==4 then
		conditionStr=getlocal("fightLevel",{cfg.level})
	elseif cfg.type==5 then
		conditionStr=getlocal("VIPStr1",{cfg.vip})
	elseif cfg.type==6 then
		conditionStr=getlocal("getInAc")
	elseif cfg.type==7 then
		conditionStr=getlocal("getInWar")
	end
	local conditionLb=GetTTFLabel(conditionStr,fontSize)
	conditionLb:setAnchorPoint(ccp(0,1))
	conditionLb:setPosition(deblockingLb:getPositionX()+deblockingLb:getContentSize().width,deblockingLb:getPositionY())
	bgNode:addChild(conditionLb)

	if (cfg.type == 6 or cfg.type == 5) and _islock then-- 有新增需要加逻辑
		conditionLb:setColor(G_ColorRed)
	end

	local function createButton(btnStr,btnIsEnabled,pos,callback,btnType)
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
	    bgNode:addChild(menu)
	    button:setEnabled(btnIsEnabled)
	end
	-- local btnPos=ccp(conditionLb:getPositionX()+conditionLb:getContentSize().width+5,conditionLb:getPositionY()-conditionLb:getContentSize().height/2)
	local btnPos=ccp(bgNode:getContentSize().width-5,conditionLb:getPositionY()-conditionLb:getContentSize().height/2)
	if cfg.type==1 and cfg.gemCost>0 then
		local function buyHandler()
			if playerVoApi:getGems()<cfg.gemCost then
	            GemsNotEnoughDialog(nil,nil,cfg.gemCost-playerVoApi:getGems(),self.layerNum+1,cfg.gemCost)
	            return
	        end
	        local function buyHeadIcon()
				local function callback1(fn,data)
					local ret,sData = base:checkServerData(data)
					if ret==true then
						playerVoApi:setGems(playerVoApi:getGems()-cfg.gemCost)
						self:setTopInfo(self.curSelectedHeadId,self.curSelectedHeadFrameId)
						local recordPoint=self.tv:getRecordPoint()
						self.tv:reloadData()
						self.tv:recoverToRecordPoint(recordPoint)
						local tipStr=getlocal("vip_tequanlibao_goumai_success")
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30,nil,true)
					end
				end
				socketHelper:buyHeadIcon(headId,callback1)
			end
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyHeadIcon,getlocal("dialog_title_prompt"),getlocal("player_buyIcon_tip",{cfg.gemCost}),nil,self.layerNum+1)
		end
		local btnIsEnabled=false
		local btnStr=getlocal("hasBuy")
		local count=self:checkJiesuo(headId,1)
		if count==0 then
			conditionLb:setColor(G_ColorRed)
			btnIsEnabled=true
			btnStr=getlocal("buy")
		end
		createButton(btnStr,btnIsEnabled,btnPos,buyHandler)
	elseif cfg.type==4 and playerVoApi:getPlayerLevel()<cfg.level then
		conditionLb:setColor(G_ColorRed)
		createButton(getlocal("upgradeBuild"),true,btnPos,function()
			-- print("cjl --------->>> 跳转到升级...")
			G_goToDialog("cn",self.layerNum+1,true)
		end,1)
	elseif cfg.type==5 and playerVoApi:getVipLevel()<cfg.vip then
		conditionLb:setColor(G_ColorRed)
		createButton(getlocal("recharge"),true,btnPos,function()
			-- print("cjl --------->>> 跳转到VIP...")
			G_goToDialog("gb",self.layerNum+1,true)
		end)
	end

	local hfCfg = headFrameCfg.list[tostring(headFrameId)]

	if "icon_bg_gray.png"~=hfCfg.pic then
		local frameSp=playerVoApi:getPlayerHeadFrameSp(headFrameId)
		frameSp:setPosition(photoSp:getContentSize().width/2,photoSp:getContentSize().height/2)
		frameSp:setScale((photoSp:getContentSize().width+7)/frameSp:getContentSize().width)
		photoSp:addChild(frameSp)
	end

	local frameLb=GetTTFLabel(getlocal("head_frame").."：",fontSize)
	frameLb:setAnchorPoint(ccp(0,1))
	frameLb:setPosition(_lbPosX,deblockingLb:getPositionY()-deblockingLb:getContentSize().height-spaceH)
	bgNode:addChild(frameLb)

	local fnameLb=GetTTFLabel(getlocal(hfCfg.name),fontSize)
	fnameLb:setAnchorPoint(ccp(0,1))
	fnameLb:setPosition(frameLb:getPositionX()+frameLb:getContentSize().width,frameLb:getPositionY())
	bgNode:addChild(fnameLb)

	local _ftxtColor=G_ColorGreen
	local _ftimeStr=nil
	local headFrameUnLockData=playerVoApi:getUnLockData(2)
	local _hfIsLock = true
	if headFrameUnLockData then
		for k, v in pairs(headFrameUnLockData) do
			if tostring(v[1])==tostring(headFrameId) then
				if hfCfg.time then
					_ftxtColor=G_ColorRed
					if v[2]<=base.serverTime then
						_ftimeStr=getlocal("expireDesc")
					else
						_ftimeStr=G_formatActiveDate(v[2] - base.serverTime)
						self.ftimeValue=v[2]
						_hfIsLock = false
					end
				else
					_hfIsLock = false
				end
				break
			end
		end
	end
	if _ftimeStr == nil then
		if hfCfg.time then
			_ftimeStr = getlocal("signRewardDay",{G_formatSecond(hfCfg.time, 1)})
		else
			_ftimeStr = getlocal("foreverTime")
		end
	end
	if hfCfg.type == 5 then
    	if(hfCfg.vip==nil or tonumber(hfCfg.vip)<=maxVip)then
			_hfIsLock = false
		end
	end
	-- print("self.curhfAddIsLock=============>>>>>>",self.curhfAddIsLock)
	self.curhfAddIsLock = _hfIsLock
	local ftimeLb=GetTTFLabel("(".._ftimeStr..")",fontSize)
	ftimeLb:setAnchorPoint(ccp(0,1))
	ftimeLb:setPosition(fnameLb:getPositionX()+fnameLb:getContentSize().width,fnameLb:getPositionY())
	ftimeLb:setColor(_ftxtColor)
	bgNode:addChild(ftimeLb)
	self.ftimeLb=ftimeLb

	local fdeblockingLb=GetTTFLabel(getlocal("deblocking_condition"),fontSize)
	fdeblockingLb:setAnchorPoint(ccp(0,1))
	fdeblockingLb:setPosition(_lbPosX,frameLb:getPositionY()-frameLb:getContentSize().height-spaceH)
	bgNode:addChild(fdeblockingLb)

	local fconditionStr=getlocal("alliance_info_content")
	if hfCfg.getPath then
		fconditionStr=getlocal("getFrom", {getlocal(hfCfg.getPath)})
	else
		if hfCfg.type==1 and hfCfg.gemCost>0 then
			fconditionStr=tostring(hfCfg.gemCost)..getlocal("gem")
		elseif hfCfg.type==3 then
			fconditionStr=getlocal("activity_get")
		elseif hfCfg.type==4 then
			fconditionStr=getlocal("fightLevel",{hfCfg.level})
		elseif hfCfg.type==5 then
			fconditionStr=getlocal("VIPStr1",{hfCfg.vip})
		elseif hfCfg.type==6 then
			fconditionStr=getlocal("getInAc")
		elseif hfCfg.type==7 then
			fconditionStr=getlocal("getInWar")
		end
	end
	local fconditionLb=GetTTFLabel(fconditionStr,fontSize)
	fconditionLb:setAnchorPoint(ccp(0,1))
	fconditionLb:setPosition(fdeblockingLb:getPositionX()+fdeblockingLb:getContentSize().width,fdeblockingLb:getPositionY())
	bgNode:addChild(fconditionLb)

	if (hfCfg.type == 5 or hfCfg.type == 6 or hfCfg.type == 7) and _hfIsLock then
		fconditionLb:setColor(G_ColorRed)
	end

	-- btnPos=ccp(fconditionLb:getPositionX()+fconditionLb:getContentSize().width+5,fconditionLb:getPositionY()-fconditionLb:getContentSize().height/2)
	btnPos=ccp(bgNode:getContentSize().width-5,fconditionLb:getPositionY()-fconditionLb:getContentSize().height/2)
	if hfCfg.type==1 and hfCfg.gemCost>0 then
		local btnIsEnabled=false
		local btnStr=getlocal("hasBuy")
		local count=self:checkJiesuo(headFrameId,2)
		if count==0 then
			fconditionLb:setColor(G_ColorRed)
			btnIsEnabled=true
			btnStr=getlocal("buy")
		end
		createButton(btnStr,btnIsEnabled,btnPos,function()
			print("cjl --------->>> 购买头像框逻辑...")
			local tipStr=getlocal("system_not_open",{getlocal("buy")})
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30,nil,true)
		end)
	elseif hfCfg.type==4 and playerVoApi:getPlayerLevel()<hfCfg.level then
		fconditionLb:setColor(G_ColorRed)
		createButton(getlocal("upgradeBuild"),true,btnPos,function()
			-- print("cjl --------->>> 跳转到升级...")
			G_goToDialog("cn",self.layerNum+1,true)
		end,1)
	elseif hfCfg.type==5 and playerVoApi:getVipLevel()<hfCfg.vip then
		fconditionLb:setColor(G_ColorRed)
		createButton(getlocal("recharge"),true,btnPos,function()
			-- print("cjl --------->>> 跳转到VIP...")
			G_goToDialog("gb",self.layerNum+1,true)
		end)
	end
end

function playerCustomDialogTab1:saveEvent()
	local cfg = headCfg.list[tostring(self.curSelectedHeadId)]
	local _isCanSave=true --是否可以保存
	if cfg.type==1 and cfg.gemCost>0 then
		local count=self:checkJiesuo(self.curSelectedHeadId,1)
		if count==0 then
			_isCanSave=false
		end
	elseif cfg.type==4 and playerVoApi:getPlayerLevel()<cfg.level then
		_isCanSave=false
	elseif cfg.type==5 and playerVoApi:getVipLevel()<cfg.vip then
		_isCanSave=false
	end
	if (cfg.type == 5 or cfg.type == 6) and self.curAddIsLock then
		_isCanSave = false
	end
	if not _isCanSave then --头像未解锁
		local tipStr=getlocal("head_undeblocking")
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30,nil,true)
		do return end
	end

	local hfCfg = headFrameCfg.list[tostring(self.curSelectedHeadFrameId)]
	local _isCanSave=true --是否可以保存
	if hfCfg.type==1 and hfCfg.gemCost>0 then
		local count=self:checkJiesuo(headFrameId,2)
		if count==0 then
			_isCanSave=false
		end
	elseif hfCfg.type==4 and playerVoApi:getPlayerLevel()<hfCfg.level then
		_isCanSave=false
	elseif hfCfg.type==5 and playerVoApi:getVipLevel()<hfCfg.vip then
		_isCanSave=false
	end
	if (hfCfg.type == 7 or hfCfg.type == 6) and self.curhfAddIsLock then
		_isCanSave = false
	end
	if not _isCanSave then --头像框未解锁
		local tipStr=getlocal("head_frame_undeblocking")
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30,nil,true)
		do return end
	end

	local function callback2(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			playerVoApi:setPic(self.curSelectedHeadId)
			playerVoApi:setHfid(self.curSelectedHeadFrameId)
			local recordPoint=self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
			eventDispatcher:dispatchEvent("playerIcon.Change",{})
			if self.parentDialog and self.parentDialog.acTab3 and self.parentDialog.acTab3.setTopInfo then
				self.parentDialog.acTab3:setTopInfo()
			end
			local tipStr=getlocal("save_success")
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30,nil,true)
		end
	end
	socketHelper:setHeadIcon(self.curSelectedHeadId,self.curSelectedHeadFrameId,callback2)
end

function playerCustomDialogTab1:eventHandlerNew(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		if self.selectedTabBtnIndex==1 then
			return CCSizeMake(611,self.headCellHeight)
		elseif self.selectedTabBtnIndex==2 then
			return CCSizeMake(611,self.headFrameCellHeight)
		else
			return CCSizeMake(0,0)
		end
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellWidth=611
		local selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("newSelectKuang.png",CCRect(30, 30, 1, 1),function()end)
		selectSp:setContentSize(CCSizeMake(106,106))
		selectSp:setPosition(99999,99999)
		selectSp:setVisible(false)
		cell:addChild(selectSp,10)

		local _posY,_tvTb
		if self.selectedTabBtnIndex==1 then
			_posY=self.headCellHeight
			_tvTb=self.tvTb
		elseif self.selectedTabBtnIndex==2 then
			_posY=self.headFrameCellHeight
			_tvTb=self.tvTb2
		end
		if _posY==nil or _tvTb==nil then
			do return cell end
		end
		for k,v in pairs(_tvTb) do
			local cellType=1
			for i,j in pairs(v) do
				cellType=j.value.type
				break
			end

			local titleStr = ""
			if self.selectedTabBtnIndex==1 then
				if cellType==1 then
					titleStr = getlocal("player_common_icon")
				elseif cellType==2 then
					titleStr = getlocal("player_hero_icon")
				elseif cellType==3 then
					titleStr = getlocal("player_special_icon")
				elseif cellType==4 then
					titleStr = getlocal("RankScene_level")..getlocal("player_icon")
				elseif cellType==5 then
					titleStr = getlocal("vipTitle")..getlocal("player_icon")
				elseif cellType == 6 then
		            titleStr = getlocal("activity")..getlocal("player_icon")
		        elseif cellType == 7 then
		            titleStr = getlocal("warStr")..getlocal("player_icon")
				end
			elseif self.selectedTabBtnIndex==2 then
				if cellType==1 then
					titleStr = getlocal("defalut")..getlocal("head_frame")
				elseif cellType==2 then
				elseif cellType==3 then
					titleStr = getlocal("time_limit")..getlocal("head_frame")
				elseif cellType==4 then
					titleStr = getlocal("RankScene_level")..getlocal("head_frame")
				elseif cellType==5 then
					titleStr = getlocal("vipTitle")..getlocal("head_frame")
				elseif cellType == 6 then
		            titleStr = getlocal("activity")..getlocal("head_frame")
		        elseif cellType == 7 then
		            titleStr = getlocal("warStr")..getlocal("head_frame")
				end
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

			local startX=64
			local startY=_posY-80
			local addW=120
			local addH=120

		    for i,j in pairs(v) do
		    	local photoSp
		    	local function changeIcon()
					if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		                if G_checkClickEnable()==false then
		                    do
		                        return
		                    end
		                else
		                    base.setWaitTime=G_getCurDeviceMillTime()
		                end
		                -- if tostring(j.key)==tostring(playerVoApi:getPic()) then 
						-- 	return
						-- end
						PlayEffect(audioCfg.mouseClick)

						selectSp:setPosition(photoSp:getPosition())
						selectSp:setVisible(true)
						if self.selectedTabBtnIndex==1 then
							self.curSelectedHeadId=j.key
						elseif self.selectedTabBtnIndex==2 then
							self.curSelectedHeadFrameId=j.key
						end
						self:setTopInfo(self.curSelectedHeadId,self.curSelectedHeadFrameId)
						
						-- if tostring(self.curSelectedHeadId)==tostring(playerVoApi:getPic()) then
					    	-- self.saveBtn:setEnabled(false)
					    -- else
					    	-- self.saveBtn:setEnabled(true)
					    -- end
					end
				end

				if self.selectedTabBtnIndex==1 then
			    	local personPhotoName=playerVoApi:getPersonPhotoName(j.key)
					photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName,changeIcon)
				elseif self.selectedTabBtnIndex==2 then
					local newUnlockTb=playerVoApi:getNewUnlockTb(self.selectedTabBtnIndex)
					local unLockData=playerVoApi:getUnLockData(self.selectedTabBtnIndex)
					local isStopAc = false
					if j.value.time then-- 只针对限时的边框，其他逻辑未包含在内
						isStopAc = true
						if newUnlockTb then
							for k,v in pairs(newUnlockTb) do
								if tostring(v) == tostring(j.key) then
									isStopAc = false
									do break end
								end
							end
						end
						if isStopAc and unLockData then
							for k,v in pairs(unLockData) do
								if tostring(v[1]) == tostring(j.key) and v[2]>base.serverTime then
									isStopAc = false
									do break end
								end
							end
						end
					end

					photoSp=playerVoApi:getPlayerHeadFrameSp(tostring(j.key),changeIcon,isStopAc)
					if photoSp==nil then
						photoSp = LuaCCSprite:createWithSpriteFrameName(j.value.pic,changeIcon)
					end
					-- photoSp = LuaCCSprite:createWithSpriteFrameName(j.value.pic,changeIcon)
				end
				photoSp:setScale(100/photoSp:getContentSize().height)
				cell:addChild(photoSp)
				photoSp:setTouchPriority(-(self.layerNum-1)*20-2)

				local num2 = math.floor(i/5)
				local num1 = i%5
				if num1==0 then
					num1=5
					num2=num2-1
				end
				photoSp:setPosition(startX+(num1-1)*addW, startY-num2*addH)
				local _id,_selectedId
				if self.selectedTabBtnIndex==1 then
					_id = playerVoApi:getPic()
					_selectedId = self.curSelectedHeadId
				elseif self.selectedTabBtnIndex==2 then
					_id = playerVoApi:getHfid()
					_selectedId = self.curSelectedHeadFrameId
				end
				if tostring(j.key)==tostring(_selectedId) then
					selectSp:setPosition(photoSp:getPosition())
					selectSp:setVisible(true)
					self.curSelectedCellItemPosY=photoSp:getPositionY()-70
				end
				if tostring(j.key)==tostring(_id) then
					local useSp=LuaCCScale9Sprite:createWithSpriteFrameName("fi_used.png",CCRect(1,1,7,7),function()end)
					useSp:setContentSize(CCSizeMake(photoSp:getContentSize().width*photoSp:getScale(),26))
					useSp:setAnchorPoint(ccp(0.5,0))
					useSp:setPosition(photoSp:getPositionX(),photoSp:getPositionY()-photoSp:getContentSize().height*photoSp:getScale()/2)
					cell:addChild(useSp)
					useSp:setOpacity(255*0.8)
					local useLb=GetTTFLabel(getlocal("in_use"),18,true)
					useLb:setPosition(useSp:getContentSize().width/2,useSp:getContentSize().height/2)
					useSp:addChild(useLb)
				end
				--判断是否有‘新’的标志
				local newUnlockTb=playerVoApi:getNewUnlockTb(self.selectedTabBtnIndex)
				local unLockData=playerVoApi:getUnLockData(self.selectedTabBtnIndex)
				local unLockHead=playerVoApi:getUnLockHead()
				if newUnlockTb then
					for m,q in pairs(newUnlockTb) do
						if tostring(q)==tostring(j.key) then
							--此处添加‘新’的图片和文字
							local newSp=CCSprite:createWithSpriteFrameName("fi_newFlag.png")
							newSp:setAnchorPoint(ccp(0,1))
							newSp:setPosition(0,photoSp:getContentSize().height)
							photoSp:addChild(newSp,10)
							newSp:setScale(0.7)
							local newLb=GetTTFLabel(getlocal("new_text"),14/newSp:getScale(),true)
							newLb:setPosition(newSp:getContentSize().width/2-12,newSp:getContentSize().height/2+15)
							newLb:setRotation(-47)
							newLb:setColor(G_ColorYellow)
							newSp:addChild(newLb)
							break
						end
					end
				end
				local _isLock = false --是否上锁
				if cellType==1 and j.value.gemCost>0 then
					local count=self:checkJiesuo(j.key,self.selectedTabBtnIndex)
					if count==0 then
						_isLock=true
					end
				elseif cellType==4 and playerVoApi:getPlayerLevel()<j.value.level then
					_isLock=true
				elseif cellType==5 and playerVoApi:getVipLevel()<j.value.vip then
					_isLock=true
				elseif cellType==6 or cellType==7 then
					_isLock=true
				end

				if self.selectedTabBtnIndex == 1 then
					if unLockHead and j.value.type == 6 then--目前只有活动头像有，
						_isLock = true
						for m,q in pairs(unLockHead) do
			                if tostring(q)==tostring(j.key) then
			                    _isLock = false
			                    do break end
			                end
			            end
					end
				end
				if unLockData then
					for k,v in pairs(unLockData) do
						if tostring(v[1]) == tostring(j.key) then
							if j.value.time then
								if v[2]>base.serverTime then
									_isLock = false
								end
							else
								_isLock = false
							end
							do break end
						end
					end
				end
				if _isLock then
					local sp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
					sp:setContentSize(CCSizeMake(photoSp:getContentSize().width*photoSp:getScale(),photoSp:getContentSize().height*photoSp:getScale()))
					sp:setPosition(photoSp:getPosition())
					sp:setOpacity(140)
					cell:addChild(sp)
					local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
					lockSp:setAnchorPoint(ccp(1,0))
					lockSp:setPosition(sp:getContentSize().width,0)
					lockSp:setScale(0.5)
					sp:addChild(lockSp)
				end
				_posY=photoSp:getPositionY()-70
		    end
		end

		return cell
	elseif fn=="ccTouchBegan" then
		return true
	elseif fn=="ccTouchMoved" then
	elseif fn=="ccTouchEnded" then
	end
end

function playerCustomDialogTab1:checkJiesuo(key,_type)
	local count=0
	if _type==1 then
		local unLockHead = playerVoApi:getUnLockHead()
		for q,m in pairs(unLockHead) do
			if tostring(m)==tostring(key) then
				count=1
				return count
			end
		end
	end
	local headUnLockData=playerVoApi:getUnLockData(_type)
	if headUnLockData then
		for q,m in pairs(headUnLockData) do
			if tostring(m[1])==tostring(key) then
				count=1
				return count
			end
		end
	end
	return count
end

function playerCustomDialogTab1:setHeadCellHeight()
	self.tvTb={}
	self.headCellHeight=0
	local commonHeadTb 	 = {}
	local levelHeadTb 	 = {}
	local vipHeadTb 	 = {}
	local heroHeadTb 	 = {}
	local activityHeadTb = {}
	local warTb    		 = {}
	local unLockHead=playerVoApi:getUnLockHead()
	local headUnLockData=playerVoApi:getUnLockData(1)
	local maxVip=tonumber(playerVoApi:getMaxLvByKey("maxVip"))
	for k,v in pairs(headCfg.list) do
		if v.type==1 then
			table.insert(commonHeadTb,{key=k,value=v})
		elseif v.type==2 then
			for m,q in pairs(unLockHead) do
                if tostring(q)==tostring(k) then
                    table.insert(heroHeadTb,{key=k,value=v})
                    break
                end
            end
		elseif v.type==3 then
			for m,q in pairs(unLockHead) do
                if tostring(q)==tostring(k) then
                    table.insert(activityHeadTb,{key=k,value=v})
                    break
                end
            end
            if headUnLockData then
	            for m,q in pairs(headUnLockData) do
	            	if tostring(q[1])==tostring(k) and q[2]>base.serverTime then
	            		table.insert(activityHeadTb,{key=k,value=v})
	            		break
	            	end
	            end
        	end
		elseif v.type==4 then
			table.insert(levelHeadTb,{key=k,value=v})
		elseif v.type==5 and playerVoApi:getMaxLvByKey("maxVip") >= v.vip then
			-- if(v.vip==nil or tonumber(v.vip)<=maxVip)then
				table.insert(vipHeadTb,{key=k,value=v})
			-- end
		elseif v.type == 6 then
			if v.isShow == 1 then-- 有些活动是特殊平台用的 需要用isShow区别
				table.insert(activityHeadTb,{key=k,value=v})
			else
				for m,q in pairs(unLockHead) do
	                if tostring(q)==tostring(k) then
	                    table.insert(activityHeadTb,{key=k,value=v})
	                    break
	                end
	            end
	            if headUnLockData then
		            for m,q in pairs(headUnLockData) do
		            	if tostring(q[1])==tostring(k) and q[2]>base.serverTime then
		            		table.insert(activityHeadTb,{key=k,value=v})
		            		break
		            	end
		            end
	        	end
			end
		elseif v.type == 7 then
			table.insert(warTb,{key=k,value=v})
		end
	end

	--基础头像
	if commonHeadTb and SizeOfTable(commonHeadTb)~=0 then
		table.insert(self.tvTb,commonHeadTb)
		self.headCellHeight=self.headCellHeight+50
	end
	--等级头像
	if levelHeadTb and SizeOfTable(levelHeadTb)~=0 then
		table.insert(self.tvTb,levelHeadTb)
		self.headCellHeight=self.headCellHeight+50
	end

	--VIP头像
	if vipHeadTb and SizeOfTable(vipHeadTb)~=0 then
		table.insert(self.tvTb,vipHeadTb)
		self.headCellHeight=self.headCellHeight+50
	end

	--英雄头像
	if heroVoApi:heroHonorIsOpen() and heroHeadTb and SizeOfTable(heroHeadTb)~=0 then
		table.insert(self.tvTb,heroHeadTb)
		self.headCellHeight=self.headCellHeight+50
	end

	--活动头像(限时)
	if activityHeadTb and SizeOfTable(activityHeadTb)~=0 then
		table.insert(self.tvTb,activityHeadTb)
		self.headCellHeight=self.headCellHeight+50
	end

	if SizeOfTable(warTb)~=0 then
		table.insert(self.tvTb,warTb)
		self.cellHegith=self.cellHegith+50
	end

	for k,v in pairs(self.tvTb) do
		local num = SizeOfTable(v)
		self.headCellHeight=self.headCellHeight+130*math.ceil(num/5)
	end
end

function playerCustomDialogTab1:setHeadFrameCellHeight()
	self.tvTb2={}
	self.headFrameCellHeight=0
	local commonFrameTb = {}
	local limitFrameTb  = {}
	local levelFrameTb  = {}
	local vipFrameTb 	= {}
	local acTb 	   		= {}
	local warTb    		= {}
	local unLockData=playerVoApi:getUnLockData(2)
	local maxVip=tonumber(playerVoApi:getMaxLvByKey("maxVip"))
	for k, v in pairs(headFrameCfg.list) do
		if v.type==1 then
			table.insert(commonFrameTb,{key=k,value=v})
		elseif v.type==3 then --好像无效了
			if unLockData then
	            for m,q in pairs(unLockData) do
	            	if tostring(q[1])==tostring(k) and q[2]>base.serverTime then
	            		table.insert(limitFrameTb,{key=k,value=v})
	            		break
	            	end
	            end
        	end
		elseif v.type==4 then
			table.insert(levelFrameTb,{key=k,value=v})
		elseif v.type==5 and playerVoApi:getMaxLvByKey("maxVip") >= v.vip then
			-- if(v.vip==nil or tonumber(v.vip)<=maxVip)then
				table.insert(vipFrameTb,{key=k,value=v})
			-- end
		elseif v.type == 6 then
			if (k == "h6001" or k == "h6002") then --俩周年相关的头像框只在国服显示
				if G_isChina() == true then
					table.insert(acTb,{key=k,value=v})
				end
			else
				table.insert(acTb,{key=k,value=v})
			end
		elseif v.type == 7 then
			table.insert(warTb,{key=k,value=v})
		end
	end

	--基础头像框
	if commonFrameTb and SizeOfTable(commonFrameTb)~=0 then
		table.insert(self.tvTb2,commonFrameTb)
		self.headFrameCellHeight=self.headFrameCellHeight+50
	end

	--限时头像框
	if limitFrameTb and SizeOfTable(limitFrameTb)~=0 then
		table.insert(self.tvTb2,limitFrameTb)
		self.headFrameCellHeight=self.headFrameCellHeight+50
	end

	--等级头像框
	if levelFrameTb and SizeOfTable(levelFrameTb)~=0 then
		table.insert(self.tvTb2,levelFrameTb)
		self.headFrameCellHeight=self.headFrameCellHeight+50
	end

	--VIP头像框
	if vipFrameTb and SizeOfTable(vipFrameTb)~=0 then
		table.insert(self.tvTb2,vipFrameTb)
		self.headFrameCellHeight=self.headFrameCellHeight+50
	end

	if SizeOfTable(acTb)~=0 then
		table.insert(self.tvTb2,acTb)
		self.headFrameCellHeight=self.headFrameCellHeight+50
	end

	if SizeOfTable(warTb)~=0 then
		table.insert(self.tvTb2,warTb)
		self.headFrameCellHeight=self.headFrameCellHeight+50
	end

	for k,v in pairs(self.tvTb2) do
		local num = SizeOfTable(v)
		self.headFrameCellHeight=self.headFrameCellHeight+130*math.ceil(num/5)
	end
	self.headFrameCellHeight = self.headFrameCellHeight + 10 + 15
end

function playerCustomDialogTab1:refresh(data)
	if self then
		local _index=tonumber(data[1])
		local _id=tostring(data[2])
		if _index==1 then --头像过期
			if _id==tostring(self.curSelectedHeadId) then --如果当前选择的头像过期
				self.curSelectedHeadId=playerVoApi:getPic()
				self:setTopInfo(self.curSelectedHeadId,self.curSelectedHeadFrameId)
			end
			self:setHeadCellHeight()
			if self.selectedTabBtnIndex==1 then
				self:tabBtnClick(1)
			end
		elseif _index==2 then --头像框过期
			if _id==tostring(self.curSelectedHeadFrameId) then --如果当前选择的头像框过期
				self.curSelectedHeadFrameId=playerVoApi:getHfid()
				self:setTopInfo(self.curSelectedHeadId,self.curSelectedHeadFrameId)
			end
			self:setHeadFrameCellHeight()
			if self.selectedTabBtnIndex==2 then
				self:tabBtnClick(2)
			end
		end
	end
end

function playerCustomDialogTab1:tick()
	if self then
		if self.timeValue and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
			self.timeLb:setString("("..G_formatActiveDate(self.timeValue - base.serverTime)..")")
		end
		if self.ftimeValue and self.ftimeLb and tolua.cast(self.ftimeLb,"CCLabelTTF") then
			self.ftimeLb:setString("("..G_formatActiveDate(self.ftimeValue - base.serverTime)..")")
		end
	end
end

function playerCustomDialogTab1:setTvNum()
	self.tvNum=0 
	self.tvTb={}
	local flag = false
	local commonIconTb,heroIconTb,teshuIconTb = playerVoApi:getCommonAndTeshuIconTb()
	if commonIconTb and SizeOfTable(commonIconTb)~=0 then
		table.insert(self.tvTb,commonIconTb)
	end
	if heroVoApi:heroHonorIsOpen() and heroIconTb and SizeOfTable(heroIconTb)~=0 then
	-- if heroIconTb and SizeOfTable(heroIconTb)~=0 then
		table.insert(self.tvTb,heroIconTb)
		flag=true
	end
	if teshuIconTb and SizeOfTable(teshuIconTb)~=0 then
		table.insert(self.tvTb,teshuIconTb)
	end
	self.tvNum=SizeOfTable(self.tvTb)
	for i=1,self.tvNum do
		local num = SizeOfTable(self.tvTb[i])
		self["tv" .. i .. "hei"]= 150*math.ceil(num/4)+50
		if flag and i==2 then
			self["tv" .. i .. "hei"]= 150*math.ceil(num/4)+100
		end
	end
end

function playerCustomDialogTab1:dispose()
	eventDispatcher:removeEventListener("playerCustomDialogTab1.playerIconChange",self.playerIconChangeListener)
	self.timeValue=nil
	self.timeLb=nil
	self.ftimeValue=nil
	self.ftimeLb=nil
	self.tvNum=nil
	self.bgLayer=nil
	self.layerNum=nil
	self.tvTb=nil
	self.tvTb2=nil
	self.unlockHidTb = nil
end

 