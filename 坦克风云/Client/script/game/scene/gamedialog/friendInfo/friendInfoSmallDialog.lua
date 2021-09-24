--@Author hj
--@Description 好友改版小板子
--@Date 2018-04-19

friendInfoSmallDialog=smallDialog:new()

function friendInfoSmallDialog:new(layerNum)
	local nc={
		str = "",
		layerNum = layerNum,
		limit = friendInfoVoApi:getfriendCfg(2),
		sendApplyButtonList = {},
		curChose = 1,
		acceptList = {},
		timeInterval = 5,
        tickIndex = 0,
        cellInitIndex = 0,
        cellNum = 0,
        cellTb = {},
		searchList = {}	
	}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

-- 申请列表
function friendInfoSmallDialog:showApplyListDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum,parentTv)
	local sd = friendInfoSmallDialog:new(layerNum)
	sd:initApplyListDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum,parentTv)
end

function friendInfoSmallDialog:initApplyListDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum,parentTv	)
	
	base:addNeedRefresh(self)
	local function closeCallBack( ... )
		if parentTv then
			parentTv:reloadData()
		end
		return self:close()
	end
	-- 采用新式小板子
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setPosition(ccp(0,0)) 
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)
    
	local dialogBg = G_getNewDialogBg(size,titleStr,titleSize,nil,layerNum,true,closeCallBack,nil)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return #friendInfoVo.binviteTb
        elseif fn=="tableCellSizeForIndex" then
            return CCSizeMake(self.bgLayer:getContentSize().width-40,105)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            self:initCell(idx,cell,1)
            return cell
        elseif fn=="ccTouchBegan" then
        	return true
        elseif fn=="ccTouchMoved" then
        elseif fn=="ccTouchEnded"  then
        end
    end


    local tvWidth = self.bgLayer:getContentSize().width-40
    local tvHeight = self.bgLayer:getContentSize().height-66-10-130-10
    local hd=LuaEventHandler:createHandler(eventHandler)
    local resultTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight-6),nil)
    resultTv:setTableViewTouchPriority(-(layerNum-1)*20-2)
    resultTv:setPosition(20,130+10+3)
    resultTv:setMaxDisToBottomOrTop(80)
    self.resultTv = resultTv
    self.bgLayer:addChild(resultTv,2)
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-66-10)
    self.bgLayer:addChild(tvBg)

    local noApplyLabel = GetTTFLabelWrap(getlocal("friend_newSys_apply_tip"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noApplyLabel:setAnchorPoint(ccp(0.5,0.5))
    noApplyLabel:setPosition(ccp(tvBg:getContentSize().width/2,tvBg:getContentSize().height/2))
    noApplyLabel:setColor(G_ColorGray) 
    if #friendInfoVo.binviteTb == 0 then
   		noApplyLabel:setVisible(true)
    else
    	noApplyLabel:setVisible(false)
    end
	self.noApplyLabel = noApplyLabel
    tvBg:addChild(noApplyLabel)
  	 
    --设置tableview的遮罩
	local stencilBgUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
	stencilBgUp:setContentSize(CCSizeMake(tvWidth,G_VisibleSizeHeight-600-(G_VisibleSizeHeight/2-300)+70))
	stencilBgUp:setAnchorPoint(ccp(0.5,1))
	stencilBgUp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
	stencilBgUp:setTouchPriority(-(layerNum-1)*20-3)
	stencilBgUp:setVisible(false)
	stencilBgUp:setIsSallow(true)
	self.dialogLayer:addChild(stencilBgUp,10)
	local stencilBgDown=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
	stencilBgDown:setContentSize(CCSizeMake(tvWidth,G_VisibleSizeHeight/2-160))
	stencilBgDown:setAnchorPoint(ccp(0.5,0))
	stencilBgDown:setPosition(ccp(G_VisibleSizeWidth/2,0))
	stencilBgDown:setTouchPriority(-(layerNum-1)*20-3)
	stencilBgDown:setVisible(false)
	stencilBgDown:setIsSallow(true)
	self.dialogLayer:addChild(stencilBgDown,10)

	-- 接受回调
	local function applyCallBack( ... )
		self:applyAll()
	end
	-- 拒绝回调
	local function rejectCallBack( ... )
		self:rejectAll()
	end
	local strSize = 22
	-- 一键接受
    local applyButton = G_createBotton(self.bgLayer,ccp(20+self.bgLayer:getContentSize().width/3-40,60),{getlocal("friend_newSys_apply_b1"),strSize},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",applyCallBack,0.8,-(layerNum-1)*20-4)
    self.applyButton = applyButton
    -- 一键拒绝
    local rejectButton = G_createBotton(self.bgLayer,ccp(20+self.bgLayer:getContentSize().width/3*2,60),{getlocal("friend_newSys_apply_b2"),strSize},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",rejectCallBack,0.8,-(layerNum-1)*20-4)
    self.rejectButton = rejectButton

    if #friendInfoVo.binviteTb == 0 then
    	rejectButton:setEnabled(false)
    	applyButton:setEnabled(false)
    end
 	local numLabel = GetTTFLabel(getlocal("friend_newSys_apply",{#friendInfoVo.binviteTb,self.limit}),25)
 	numLabel:setAnchorPoint(ccp(0,1))
 	numLabel:setPosition(ccp(25,130))
 	self.numLabel = numLabel
 	self.bgLayer:addChild(numLabel)

    if isUseAmi then
        self:show()
    else
        table.insert(G_SmallDialogDialogTb,self)
    end

    --黑色遮挡层
    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(220)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

end


-- 查询结果集板子
function friendInfoSmallDialog:showSearchResultDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum,specialFlag,searchList,parentTv)
	local sd = friendInfoSmallDialog:new(layerNum)
	sd:initSearchResultDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum,specialFlag,searchList,parentTv)
end

function friendInfoSmallDialog:initSearchResultDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum,specialFlag,searchList,parentTv)
	self.searchList = searchList
	self.specialFlag = specialFlag	
	base:addNeedRefresh(self)
	local function closeCallBack( ... )
		-- 删除在这里统一添加	
		parentTv:reloadData()
		return self:close()
	end

	-- 采用新式小板子
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setPosition(ccp(0,0)) 
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)
    
	local dialogBg = G_getNewDialogBg(size,titleStr,titleSize,nil,layerNum,true,closeCallBack,nil)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    -- 查询结果集
    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
        	return #self.searchList
        elseif fn=="tableCellSizeForIndex" then
            return CCSizeMake(self.bgLayer:getContentSize().width-40,105)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            self:initCell(idx,cell,2)
            return cell
        elseif fn=="ccTouchBegan" then
        	return true
        elseif fn=="ccTouchMoved" then
        elseif fn=="ccTouchEnded"  then
        end
    end

    local tvWidth = self.bgLayer:getContentSize().width-40
    local tvHeight = self.bgLayer:getContentSize().height-66-10-20
    local hd=LuaEventHandler:createHandler(eventHandler)
    local displayTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight-6),nil)
    displayTv:setTableViewTouchPriority(-(layerNum-1)*20-2)
    displayTv:setPosition(20,20+3)
    displayTv:setMaxDisToBottomOrTop(80)
    self.displayTv = displayTv
    self.bgLayer:addChild(displayTv,2)

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-66-10)
    self.bgLayer:addChild(tvBg)

    --设置tableview的遮罩
	local stencilBgUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
	stencilBgUp:setContentSize(CCSizeMake(tvWidth,G_VisibleSizeHeight-600-(G_VisibleSizeHeight/2-300)+70))
	stencilBgUp:setAnchorPoint(ccp(0.5,1))
	stencilBgUp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
	stencilBgUp:setTouchPriority(-(layerNum-1)*20-3)
	stencilBgUp:setVisible(false)
	stencilBgUp:setIsSallow(true)
	self.dialogLayer:addChild(stencilBgUp,8)
	local stencilBgDown=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
	stencilBgDown:setContentSize(CCSizeMake(tvWidth,G_VisibleSizeHeight/2-280))
	stencilBgDown:setAnchorPoint(ccp(0.5,0))
	stencilBgDown:setPosition(ccp(G_VisibleSizeWidth/2,0))
	stencilBgDown:setTouchPriority(-(layerNum-1)*20-3)
	stencilBgDown:setVisible(false)
	stencilBgDown:setIsSallow(true)
	self.dialogLayer:addChild(stencilBgDown,8)

    if isUseAmi then
        self:show()
    else
        table.insert(G_SmallDialogDialogTb,self)
    end

    --黑色遮挡层
    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(220)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)
end


-- 通讯管理
function friendInfoSmallDialog:showMassageManagerDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum)
	local sd = friendInfoSmallDialog:new(layerNum)
	sd:initMassageManagerDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum)
end

function friendInfoSmallDialog:initMassageManagerDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum)
	base:addNeedRefresh(self)
	local function closeCallBack( ... )
		-- 删除在这里统一添加	
		return self:close()
	end

	-- 采用新式小板子
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setPosition(ccp(0,0)) 
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)
    
	local dialogBg = G_getNewDialogBg(size,titleStr,titleSize,nil,layerNum,true,closeCallBack,nil)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local function listHandler( ... )
        if self.curChose ~= 1 then
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab_down.png")
            if frame then
        		self.listSprite:setDisplayFrame(frame)
            end
            local frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab.png")
            if frame2 then
            	self.shieldSprite:setDisplayFrame(frame2)
            end
        	self.curChose = 1
            self.cellInitIndex = 0
            self.tickIndex = 0
            self.cellTb = {}
        	self:updatenoFriendLabel()
        	self.displayTv:reloadData()
        else
            do return end
        end
    end

    local function shieldHandler( ... )
        if self.curChose ~= 2 then
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab.png")
            if frame then
            	self.listSprite:setDisplayFrame(frame)
            end
            local frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("yh_ltzdzHelp_tab_down.png")
            if frame2 then
            	self.shieldSprite:setDisplayFrame(frame2)
            end
        	self.curChose = 2
            self.cellInitIndex = 0
            self.tickIndex = 0
            self.cellTb = {}
        	self:updatenoFriendLabel()
        	self.displayTv:reloadData()
        else
            do return end
        end
    end

    local listSprite = LuaCCSprite:createWithSpriteFrameName("yh_ltzdzHelp_tab_down.png",listHandler)
    local shieldSprite = LuaCCSprite:createWithSpriteFrameName("yh_ltzdzHelp_tab.png",shieldHandler)
    self.listSprite = listSprite
    self.shieldSprite = shieldSprite
    listSprite:setTouchPriority(-(self.layerNum-1)*20-4)
    shieldSprite:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(listSprite)
    self.bgLayer:addChild(shieldSprite)
    listSprite:setAnchorPoint(ccp(0,1))
    shieldSprite:setAnchorPoint(ccp(0,1))
    listSprite:setPosition(ccp(20,self.bgLayer:getContentSize().height-66-10))
    shieldSprite:setPosition(ccp(listSprite:getPositionX()+listSprite:getContentSize().width+5,self.bgLayer:getContentSize().height-66-10))

    for i=1,2 do
    	local strSize = 25
    	if G_getCurChoseLanguage() == "ja" then
    		strSize = 18
    	elseif G_isAsia() == false then
    		strSize = 20
    	end
    	if i == 2 then
    		i = 3
    	end
    	local subItemlabel = GetTTFLabelWrap(getlocal("friend_newSys_tab"..i),strSize,CCSizeMake(listSprite:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    	subItemlabel:setAnchorPoint(ccp(0.5,0.5))
    	if i == 3 then
    		i = 2
    	end
    	subItemlabel:setPosition(ccp(20+listSprite:getContentSize().width/2+(i-1)*listSprite:getContentSize().width,self.bgLayer:getContentSize().height-66-10-listSprite:getContentSize().height/2))
    	self.bgLayer:addChild(subItemlabel)
    end

	-- 查询结果集
    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
        	if self.curChose == 1 then
                self.cellNum = #friendInfoVo.friendTb
            	return self.cellNum
        	else
                self.cellNum = #friendInfoVo.shieldTb
        		return self.cellNum
        	end
        elseif fn=="tableCellSizeForIndex" then
            return CCSizeMake(self.bgLayer:getContentSize().width-40,105)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            self.cellTb[idx+1] = cell
            if idx == 0 then
                local cellSp = self:getCellSp(idx)
                cell:addChild(cellSp)
            end
            return cell
        elseif fn=="ccTouchBegan" then
        	return true
        elseif fn=="ccTouchMoved" then
        elseif fn=="ccTouchEnded"  then
        end
    end

    local tvWidth = self.bgLayer:getContentSize().width-40
    local tvHeight = self.bgLayer:getContentSize().height-66-10-listSprite:getContentSize().height-130-10
    local hd=LuaEventHandler:createHandler(eventHandler)
    local displayTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight-6),nil)
    displayTv:setTableViewTouchPriority(-(layerNum-1)*20-2)
    displayTv:setPosition(20,130+10+3)
    displayTv:setMaxDisToBottomOrTop(80)
    self.displayTv = displayTv
    self.bgLayer:addChild(displayTv,2)

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-66-10-listSprite:getContentSize().height)
    self.bgLayer:addChild(tvBg,1)

    --设置tableview的遮罩
	local stencilBgUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    -- 小板子的总高度是600 标题框加页签130 小板子中心点放置 多种机型都适配
	stencilBgUp:setContentSize(CCSizeMake(tvWidth,G_VisibleSizeHeight-600-(G_VisibleSizeHeight/2-300)+130))
	stencilBgUp:setAnchorPoint(ccp(0.5,1))
	stencilBgUp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
	stencilBgUp:setTouchPriority(-(layerNum-1)*20-3)
	stencilBgUp:setVisible(false)
	stencilBgUp:setIsSallow(true)
	self.dialogLayer:addChild(stencilBgUp,4)
	local stencilBgDown=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
	stencilBgDown:setContentSize(CCSizeMake(tvWidth,G_VisibleSizeHeight/2-160))
	stencilBgDown:setAnchorPoint(ccp(0.5,0))
	stencilBgDown:setPosition(ccp(G_VisibleSizeWidth/2,0))
	stencilBgDown:setTouchPriority(-(layerNum-1)*20-3)
	stencilBgDown:setVisible(false)
	stencilBgDown:setIsSallow(true)
	self.dialogLayer:addChild(stencilBgDown,4)
	
	local str = ""
	local param
	local str1 = ""
    local limit
	if self.curChose == 1 then
		str = "friend_newSys_desc1"
		str1 = "friend_newSys_list_tip"
		param = #friendInfoVo.friendTb
        limit = self.limit
	else
		str = "friend_newSys_desc3"
		str1 = "friend_newSys_shield_tip"
		param = #friendInfoVo.shieldTb
        limit = G_blackListNum
	end

 	local messageLabel = GetTTFLabel(getlocal(str,{param,limit}),25)
 	messageLabel:setAnchorPoint(ccp(0,1))
 	messageLabel:setPosition(ccp(25,115))
 	self.messageLabel = messageLabel
 	self.bgLayer:addChild(messageLabel)

 	local noFriendLabel = GetTTFLabel(getlocal(str1),25)
	self.bgLayer:addChild(noFriendLabel,3)
	noFriendLabel:setAnchorPoint(ccp(0.5,0.5))
	noFriendLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,130+10+tvHeight/2))
	noFriendLabel:setColor(G_ColorGray)	
	self.noFriendLabel = noFriendLabel

	self:updatenoFriendLabel()

    if isUseAmi then
        self:show()
    else
        table.insert(G_SmallDialogDialogTb,self)
    end

    --黑色遮挡层
    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(220)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

      -- 输入框
	local function nilFunc( ... )
		do return end
	end
    self.str1 = ""
	local editBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	editBoxBg:setTouchPriority(-(layerNum-1)*20-4)
	local function inputCallbcak(fn,eB,str,type)
    	-- 检测文本发生变化
    	self.descLabel:setVisible(false)
    	if type==1 then
    		-- 允许输入的最长字符串为12位
    		if string.len(str)<= 36 then
    			-- eB:setText(str)
    			self.str1 = str
    		else
    			eB:setText(self.str1) 
    		end
    	-- 检测文本输入结束
    	elseif type==2 then
    		if self.str1 == "" then
				self.descLabel:setString(getlocal("friend_newSys_research"))
    			self.descLabel:setColor(G_ColorGray)
    		else
    			self.descLabel:setString(self.str1)
    			self.descLabel:setColor(G_ColorWhite)
    		end
    		self.descLabel:setVisible(true)
    		self.editBox:setVisible(false)
    	end
    end
    local editBox=CCEditBox:createForLua(CCSize(425,50),editBoxBg,nil,nil,inputCallbcak)
    editBox:setAnchorPoint(ccp(0,0.5))
    editBox:setPosition(ccp(20,45))
   	editBox:setVisible(false)
    editBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
   	self.editBox = editBox
    self.bgLayer:addChild(editBox)
    local strSize = 27
    if G_isAsia() == false then
        strSize = 20
    end
   	local descLabel = GetTTFLabel(getlocal("friend_newSys_research"),strSize,true)
	descLabel:setAnchorPoint(ccp(0,0.5))
	descLabel:setPosition(ccp(20+10,45))
	descLabel:setColor(G_ColorGray)
	self.bgLayer:addChild(descLabel,2)
	self.descLabel = descLabel

	local function searchCallBack( ... )
		if self.str1 == "" then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_research_rule1"),30)
			do return end
		end
		if self.lastTime then
			if base.serverTime - self.lastTime <= self.timeInterval then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_research_rule3",{self.timeInterval}),30)
				do return end
			end
		end
		self.lastTime = base.serverTime
		local function callback(fn,data)
			local ret,sData = base:checkServerData(data)
			if ret == true then
				if sData.data.info then
					local searchList = {}
					for k,v in pairs(sData.data.info) do
						if self.curChose == 2 then
							-- 屏蔽搜索结果除了我自己以外都显示
							if tonumber(v[1]) ~= tonumber(playerVoApi:getUid()) then
								table.insert(searchList,v)
							end
						else
							-- 添加好友的搜索结果只显示非我自己且未屏蔽的非好友玩家，记得排序
							if tonumber(v[1]) ~= tonumber(playerVoApi:getUid()) and tonumber(v[12]) == 0  and friendInfoVoApi:juedgeIsMyfriend(tonumber(v[1])) == false then
								table.insert(searchList,v)
							end
						end

					end
					local specialStr = ""
					if self.curChose == 1 then
						specialStr = "add"
					else
						specialStr = "shield"
					end
					self:sortSearchList(searchList,specialStr)
                    if #searchList == 0 then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_research_rule2"),30)
                        do return end
                    end
					self:showSearchResultDialog("newSmallPanelBg",CCSizeMake(550,600),CCRect(170,80,22,10),nil,getlocal("alliance_list_scene_search"),30,layerNum+1,specialStr,searchList,self.displayTv) 
				else
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_research_rule2"),30)
				end
			end
		end
		socketHelper:friendsSearch(self.str1,callback)
		do return end
	end
    local searchButton = G_createBotton(self.bgLayer,ccp(20+400+45+25,45),nil,"newChat_find_btn.png","newChat_find_btn_down.png","newChat_find_btn.png",searchCallBack,1,-(layerNum-1)*20-4)

	local function clickFunc( ... )
        PlayEffect(audioCfg.mouseClick)
		self.editBox:setVisible(true)		
	end
	local editBoxRealBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),clickFunc)
	editBoxRealBg:setAnchorPoint(ccp(0,0.5))
	editBoxRealBg:setContentSize(CCSizeMake(425,50))
	editBoxRealBg:setPosition(ccp(20,20+25))
	editBoxRealBg:setTouchPriority(-(layerNum-1)*20-4)
	self.bgLayer:addChild(editBoxRealBg,1)

end


-- 添加好友
function friendInfoSmallDialog:showResearchDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum,parentTv,specialFlag)
	local sd = friendInfoSmallDialog:new(layerNum)
	sd:initResearchDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum,parentTv,specialFlag)
end
function friendInfoSmallDialog:initResearchDialog(bgSrc,size,inRect,isUseAmi,titleStr,titleSize,layerNum,parentTv,specialFlag)
	self.specialFlag = specialFlag
	base:addNeedRefresh(self)
	local function closeCallBack( ... )
		if parentTv then
			parentTv:reloadData()
		end
		return self:close()
	end
	-- 采用新式小板子
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setPosition(ccp(0,0)) 
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)

	local dialogBg = G_getNewDialogBg(size,titleStr,titleSize,nil,layerNum,true,closeCallBack,nil)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

	self.flag = 0

    -- 输入框
	local function nilFunc( ... )
		do return end
	end
	local editBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	editBoxBg:setTouchPriority(-(layerNum-1)*20-4)
	local function inputCallbcak(fn,eB,str,type)
    	-- 检测文本发生变化
    	self.descLabel:setVisible(false)
    	if type==1 then
    		-- 允许输入的最长字符串为12位
    		if string.len(str)<= 36 then
    			-- eB:setText(str)
    			self.str = str
    		else
    			eB:setText(self.str) 
    		end
    	-- 检测文本输入结束
    	elseif type==2 then
    		if self.str == "" then
				self.descLabel:setString(getlocal("friend_newSys_research"))
    			self.descLabel:setColor(G_ColorGray)
    		else
    			self.descLabel:setString(self.str)
    			self.descLabel:setColor(G_ColorWhite)
    		end
    		self.descLabel:setVisible(true)
    		self.editBox:setVisible(false)
    	end
    end
    local editBox=CCEditBox:createForLua(CCSize(425,50),editBoxBg,nil,nil,inputCallbcak)
    editBox:setAnchorPoint(ccp(0,0.5))
    editBox:setPosition(ccp(20,self.bgLayer:getContentSize().height-66-10-35))
   	editBox:setVisible(false)
    editBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
   	self.editBox = editBox
    self.bgLayer:addChild(editBox)
    local strSize = 27
    if G_isAsia() == false then
        strSize = 20
    end
   	local descLabel = GetTTFLabel(getlocal("friend_newSys_research"),strSize,true)
	descLabel:setAnchorPoint(ccp(0,0.5))
	descLabel:setPosition(ccp(20+10,self.bgLayer:getContentSize().height-66-10-35))
	descLabel:setColor(G_ColorGray)
	self.bgLayer:addChild(descLabel,2)
	self.descLabel = descLabel

	local function searchCallBack( ... )

		if self.str == "" then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_research_rule1"),30)
			do return end
		end
		if self.lastTime then
			if base.serverTime - self.lastTime <= self.timeInterval then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_research_rule3",{self.timeInterval}),30)
				do return end
			end
		end
		self.lastTime = base.serverTime

		local function callback(fn,data)
			local ret,sData = base:checkServerData(data)
			if ret == true then
				if sData.data.info then
					self.searchList = {}
					for k,v in pairs(sData.data.info) do
						if self.specialFlag == "shield" then
							-- 屏蔽搜索结果除了我自己以外都显示
							if tonumber(v[1]) ~= tonumber(playerVoApi:getUid()) then
								table.insert(self.searchList,v)
							end
						else
							-- 添加好友的搜索结果只显示非我自己且未屏蔽的非好友玩家，记得排序
							if tonumber(v[1]) ~= tonumber(playerVoApi:getUid()) and tonumber(v[12]) == 0  and friendInfoVoApi:juedgeIsMyfriend(tonumber(v[1])) == false then
								table.insert(self.searchList,v)
							end
						end

					end
					self:updateSearchTipLabel()
					self:sortSearchList(self.searchList,specialFlag)
                    if #self.searchList == 0 then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_research_rule2"),30) 
                        self.searchList = {}  
                    end
					self.searchTv:reloadData()
				else
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_research_rule2"),30)
					self.searchList = {}
					self.searchTv:reloadData()
				end
			end
		end
		socketHelper:friendsSearch(self.str,callback)
		do return end
	end
    local searchButton = G_createBotton(self.bgLayer,ccp(20+425+50,self.bgLayer:getContentSize().height-66-10-35),nil,"newChat_find_btn.png","newChat_find_btn_down.png","newChat_find_btn.png",searchCallBack,1,-(layerNum-1)*20-4)

	local function clickFunc( ... )
        PlayEffect(audioCfg.mouseClick)
		self.editBox:setVisible(true)		
	end
	local editBoxRealBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),clickFunc)
	editBoxRealBg:setAnchorPoint(ccp(0,0.5))
	editBoxRealBg:setContentSize(CCSizeMake(425,50))
	editBoxRealBg:setPosition(ccp(20,self.bgLayer:getContentSize().height-66-10-35))
	editBoxRealBg:setTouchPriority(-(layerNum-1)*20-4)
	self.bgLayer:addChild(editBoxRealBg,1)

	-- 查询结果集
    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return #self.searchList
        elseif fn=="tableCellSizeForIndex" then
            return CCSizeMake(self.bgLayer:getContentSize().width-40,105)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            self:initCell(idx,cell,2)
            return cell
        elseif fn=="ccTouchBegan" then
        elseif fn=="ccTouchMoved" then
        elseif fn=="ccTouchEnded"  then
        end
    end


    local tvWidth = self.bgLayer:getContentSize().width-40
    local tvHeight = self.bgLayer:getContentSize().height-66-10-70-10-30
    local hd=LuaEventHandler:createHandler(eventHandler)
    local searchTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight-6),nil)
    searchTv:setTableViewTouchPriority(-(layerNum-1)*20-2)
    searchTv:setPosition(20,33)
    searchTv:setMaxDisToBottomOrTop(80)
    self.searchTv = searchTv
    self.bgLayer:addChild(searchTv,2)
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight))
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setPosition(self.bgLayer:getContentSize().width/2,30)
    self.bgLayer:addChild(tvBg)

    local realStr 
    if self.specialFlag == "shield" then
    	realStr = "friend_newSys_research_tip1"
    else
    	realStr = "friend_newSys_research_tip"
    end
    local noResultLabel = GetTTFLabelWrap(getlocal(realStr),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noResultLabel:setAnchorPoint(ccp(0.5,0.5))
    noResultLabel:setPosition(ccp(tvBg:getContentSize().width/2,tvBg:getContentSize().height/2))
    noResultLabel:setColor(G_ColorGray)
    self.noResultLabel = noResultLabel
    tvBg:addChild(noResultLabel)

    --设置tableview的遮罩
	local stencilBgUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
	stencilBgUp:setContentSize(CCSizeMake(tvWidth,G_VisibleSizeHeight-600-(G_VisibleSizeHeight/2-300)+160))
	stencilBgUp:setAnchorPoint(ccp(0.5,1))
	stencilBgUp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
	stencilBgUp:setTouchPriority(-(layerNum-1)*20-3)
	stencilBgUp:setVisible(false)
	stencilBgUp:setIsSallow(true)
	self.dialogLayer:addChild(stencilBgUp,5)
	local stencilBgDown=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
	stencilBgDown:setContentSize(CCSizeMake(tvWidth,G_VisibleSizeHeight/2-280))
	stencilBgDown:setAnchorPoint(ccp(0.5,0))
	stencilBgDown:setPosition(ccp(G_VisibleSizeWidth/2,0))
	stencilBgDown:setTouchPriority(-(layerNum-1)*20-3)
	stencilBgDown:setVisible(false)
	stencilBgDown:setIsSallow(true)
	self.dialogLayer:addChild(stencilBgDown,5)

    if isUseAmi then
        self:show()
    else
        table.insert(G_SmallDialogDialogTb,self)
    end

    --黑色遮挡层
    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(220)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

end

function friendInfoSmallDialog:initCell(idx,cell,flag)
	local tempSize = CCSizeMake(self.bgLayer:getContentSize().width-40,105)
	cell:setContentSize(tempSize)
	if flag==1 then

		local function sendEmailCallback( ... )
            if friendInfoVo.binviteTb and  friendInfoVo.binviteTb[idx+1] then
                require "luascript/script/game/scene/gamedialog/emailDetailDialog"
                emailVoApi:showWriteEmailDialog(self.layerNum+1,getlocal("email_write"),friendInfoVo.binviteTb[idx+1].nickname,nil,nil,nil,nil,friendInfoVo.binviteTb[idx+1].uid)
            end
		end
		local function chatCallback( ... )
	      	chatVoApi:showChatDialog(self.layerNum+1,nil,friendInfoVo.binviteTb[idx+1].uid,friendInfoVo.binviteTb[idx+1].nickname,true)
		end
		-- 军衔
	 	local rankStr = playerVoApi:getRankIconName(tonumber(friendInfoVo.binviteTb[idx+1].rank))
		local mIcon=CCSprite:createWithSpriteFrameName(rankStr)
	    mIcon:setScale(65/mIcon:getContentSize().width)
	    mIcon:setAnchorPoint(ccp(0,0.5))
	    mIcon:setPosition(ccp(15,cell:getContentSize().height/2))	
	    cell:addChild(mIcon)
	    -- 头像和头像框
	    local function playerDetail( ... )

	    	-- 加入黑名单
			local function shieldCallback()
				do return end
			end

			local function nilFunc( ... )
				self.resultTv:reloadData()
			end

			local nameContent = friendInfoVo.binviteTb[idx+1].nickname
			local levelContent = getlocal("alliance_info_level").." Lv."..friendInfoVo.binviteTb[idx+1].level
			local fcContent=getlocal("player_message_info_power")..": "..FormatNumber(tonumber(friendInfoVo.binviteTb[idx+1].fc))
			local allianceContent
			if friendInfoVo.binviteTb[idx+1].alliancename then
				allianceContent=getlocal("player_message_info_alliance")..": "..friendInfoVo.binviteTb[idx+1].alliancename
			else
				allianceContent=getlocal("player_message_info_alliance")..": "..getlocal("alliance_info_content")
			end
			local content={{nameContent,28,G_ColorYellowPro},{levelContent,22},{fcContent,22},{allianceContent,27}}

			local vipPicStr = nil
			-- 日本平台特殊处理，不展示VIP的具体等级
			local isShowVip = chatVoApi:isJapanV()
			if friendInfoVo.binviteTb[idx+1].vip then
				if isShowVip then
					vipPicStr = "vipNoLevel.png"
				else
					vipPicStr = "Vip"..friendInfoVo.binviteTb[idx+1].vip..".png"
				end
			end
			smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png",CCSizeMake(550,530),nil,CCRect(170,80,22,10),"email",sendEmailCallback,"chat",chatCallback,getlocal("player_message_info_title"),content,nil,self.layerNum+1,1,nil,nil,nil,friendInfoVo.binviteTb[idx+1].pic,getlocal("shield"),shieldCallback,getlocal("friend_newSys_fr_apply"),nilFunc,friendInfoVo.binviteTb[idx+1].rank,nil,nil,friendInfoVo.binviteTb[idx+1].title,friendInfoVo.binviteTb[idx+1].nickname,vipPicStr,nil,nil,friendInfoVo.binviteTb[idx+1].bpic,friendInfoVo.binviteTb[idx+1].uid)
	    	do return end
	    end 
	    local personPhotoName=playerVoApi:getPersonPhotoName(friendInfoVo.binviteTb[idx+1].pic)
	    local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName,playerDetail,nil,nil,nil,friendInfoVo.binviteTb[idx+1].bpic)
	    playerPic:setAnchorPoint(ccp(0,0.5))
	    playerPic:setTouchPriority(-(self.layerNum-1)*20-2)
	    playerPic:setScale(85/playerPic:getContentSize().width)
	    playerPic:setPosition(ccp(15+65+15,cell:getContentSize().height/2))
	    cell:addChild(playerPic)
        
         -- 等级黑条
        local levelBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
        levelBg:setRotation(180)
        levelBg:setContentSize(CCSizeMake(70,20))
        levelBg:setAnchorPoint(ccp(0.5,0))
        levelBg:setPosition(ccp(playerPic:getContentSize().width/2,25))
        playerPic:addChild(levelBg)
		
		-- 等级
		local levelStr=friendInfoVo.binviteTb[idx+1].level
		local levelLabel=GetTTFLabelWrap(getlocal("fightLevel",{levelStr}),20,CCSizeMake(70,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
		levelLabel:setAnchorPoint(ccp(0.5,0))
		levelLabel:setPosition(playerPic:getContentSize().width/2,2)
		playerPic:addChild(levelLabel)

		-- 玩儿家名称
		local nameStr=friendInfoVo.binviteTb[idx+1].nickname
		local nameLabel=GetTTFLabel(nameStr,24,true)
		nameLabel:setAnchorPoint(ccp(0,0.5))
		nameLabel:setPosition(15+65+15+85+10,cell:getContentSize().height/3*2)
		cell:addChild(nameLabel)

		-- 战斗力
		local tankSp=CCSprite:createWithSpriteFrameName("ltzdzTankFight.png")
		tankSp:setAnchorPoint(ccp(0,0.5))
	    tankSp:setScale(1.2)
	    tankSp:setPosition(15+65+15+85+10,cell:getContentSize().height/3)
	    cell:addChild(tankSp)

		local valueStr=friendInfoVo.binviteTb[idx+1].fc
		local valueLabel=GetTTFLabelWrap(FormatNumber(tonumber(valueStr)),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		valueLabel:setAnchorPoint(ccp(0,0.5))
		valueLabel:setPosition(15+65+15+85+20+tankSp:getContentSize().width*1.2,cell:getContentSize().height/3)
		cell:addChild(valueLabel)

		local function rejectCallBack()
			local rejectList = {}
			table.insert(rejectList,friendInfoVo.binviteTb[idx+1].uid)
			local function callback(fn,data)
				local ret,sData = base:checkServerData(data)
				if ret == true then
					table.remove(friendInfoVo.binviteTb,idx+1)
					if #friendInfoVo.binviteTb == 0 then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_apply_reject"),30)
						return self:close()
					end
					self.resultTv:reloadData()
					self:updateButton()
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_apply_reject"),30)
				end
			end
			socketHelper:rejectApply(rejectList,callback)
		end
		local function applyCallBack( ... )
			-- 双方好友是否达到上限限制
			-- 判断我的好友是否达到上限,不需要请求
			self.acceptList = {}
			if #friendInfoVo.friendTb+1 > self.limit then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_apply_success_defeat1"),30)
			else
				table.insert(self.acceptList,friendInfoVo.binviteTb[idx+1].uid)
				local function callback(fn,data)
					local ret,sData = base:checkServerData(data)
					if ret == true then
						if sData.data.friends and sData.data.friends.user then
                            if #sData.data.friends.user == 0 then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_err_12008"),30)
                            else
    							if tonumber(sData.data.friends.user[1]) == friendInfoVo.binviteTb[idx+1].uid then
    							    -- 添加成功
    								friendInfoVo.binviteTb[idx+1]["sendFlag"] = 0
    								friendInfoVo.binviteTb[idx+1]["receiveFlag"] = 0
    								table.insert(friendInfoVo.friendTb,friendInfoVo.binviteTb[idx+1])
    								table.remove(friendInfoVo.binviteTb,idx+1)
    								if #friendInfoVo.binviteTb == 0 then
    									friendInfoVo.friendChanegFlag = 1
    									friendInfoVo.friendGiftFlag = 1
                                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_apply_success"),30)                  
    									return self:close()
    								end
    								self.resultTv:reloadData()
    								friendInfoVo.friendGiftFlag = 1
    								smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_apply_success"),30)					
    							end
                            end
						end
					end
				end
				socketHelper:agreefriendApply(self.acceptList,callback)
			end
		end
        local touchSp1= LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,5,5), rejectCallBack)
        touchSp1:setContentSize(CCSizeMake(100,105))
        cell:addChild(touchSp1)
        touchSp1:setAnchorPoint(ccp(1,1))
        touchSp1:setPosition(ccp(cell:getContentSize().width-80,cell:getContentSize().height))
        touchSp1:setTouchPriority(-(self.layerNum-1)*20-2)
        touchSp1:setVisible(false)

        local touchSp2= LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,5,5), applyCallBack)
        touchSp2:setContentSize(CCSizeMake(80,105))
        cell:addChild(touchSp2)
        touchSp2:setAnchorPoint(ccp(1,1))
        touchSp2:setPosition(ccp(cell:getContentSize().width,cell:getContentSize().height))
        touchSp2:setTouchPriority(-(self.layerNum-1)*20-2)
        touchSp2:setVisible(false)

		local rejectApplyButton = G_createBotton(cell,ccp(nameLabel:getPositionX()+210,cell:getContentSize().height/2),nil,"yh_BtnNo.png","yh_BtnNo_Down.png","yh_BtnNo.png",rejectCallBack,1,-(self.layerNum-1)*20-2)
		local acceptApplyButton = G_createBotton(cell,ccp(nameLabel:getPositionX()+280,cell:getContentSize().height/2),nil,"fr_confirm.png","fr_confirm_Down.png","fr_confirm.png",applyCallBack,1,-(self.layerNum-1)*20-2)
	elseif flag == 2 then

		-- 设置查询结果集的cell
		local function sendEmailCallback( ... )
            if self.searchList and self.searchList[idx+1] then
                require "luascript/script/game/scene/gamedialog/emailDetailDialog"
                emailVoApi:showWriteEmailDialog(self.layerNum+1,getlocal("email_write"),self.searchList[idx+1][2],nil,nil,nil,nil,self.searchList[idx+1][1]) 
            end
		end
		local function chatCallback( ... )
	      	chatVoApi:showChatDialog(self.layerNum+1,nil,self.searchList[idx+1][1],self.searchList[idx+1][2],true)
		end
		-- 军衔
	 	local rankStr = playerVoApi:getRankIconName(tonumber(self.searchList[idx+1][4]))
		local mIcon=CCSprite:createWithSpriteFrameName(rankStr)
	    mIcon:setScale(65/mIcon:getContentSize().width)
	    mIcon:setAnchorPoint(ccp(0,0.5))
	    mIcon:setPosition(ccp(15,cell:getContentSize().height/2))	
	    cell:addChild(mIcon)
	    -- 头像和头像框
	    local function playerDetail( ... )

	    	-- 加入黑名单
			local function shieldCallback()
				do return end
			end
			local function nilFunc( ... )
				self.searchTv:reloadData()
			end

			local nameContent = self.searchList[idx+1][2]
			local levelContent = getlocal("alliance_info_level").." Lv."..self.searchList[idx+1][8]
			local fcContent=getlocal("player_message_info_power")..": "..FormatNumber(tonumber(self.searchList[idx+1][7]))
			local allianceContent
			if self.searchList[idx+1][5] then
				allianceContent=getlocal("player_message_info_alliance")..": "..self.searchList[idx+1][5]
			else
				allianceContent=getlocal("player_message_info_alliance")..": "..getlocal("alliance_info_content")
			end
			local content={{nameContent,28,G_ColorYellowPro},{levelContent,22},{fcContent,22},{allianceContent,27}}

			local vipPicStr = nil
			-- 日本平台特殊处理，不展示VIP的具体等级
			local isShowVip = chatVoApi:isJapanV()
			if self.searchList[idx+1][3] then
				if isShowVip then
					vipPicStr = "vipNoLevel.png"
				else
					vipPicStr = "Vip"..self.searchList[idx+1][3]..".png"
				end
			end
			smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png",CCSizeMake(550,530),nil,CCRect(170,80,22,10),"email",sendEmailCallback,"chat",chatCallback,getlocal("player_message_info_title"),content,nil,self.layerNum+1,1,nil,nil,nil,self.searchList[idx+1][9],getlocal("shield"),shieldCallback,getlocal("friend_newSys_fr_apply"),nilFunc,tonumber(self.searchList[idx+1][4]),nil,nil,self.searchList[idx+1][6],self.searchList[idx+1][2],vipPicStr,nil,nil,self.searchList[idx+1][10],self.searchList[idx+1][1])
	    	do return end
	    end 
	    local personPhotoName=playerVoApi:getPersonPhotoName(self.searchList[idx+1][9])
	    local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName,playerDetail,nil,nil,nil,self.searchList[idx+1][10])
	    playerPic:setAnchorPoint(ccp(0,0.5))
	    playerPic:setTouchPriority(-(self.layerNum-1)*20-2)
	    playerPic:setScale(85/playerPic:getContentSize().width)
	    playerPic:setPosition(ccp(15+65+15,cell:getContentSize().height/2))
	    cell:addChild(playerPic)

	     -- 等级黑条
        local levelBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
        levelBg:setRotation(180)
        levelBg:setContentSize(CCSizeMake(70,20))
        levelBg:setAnchorPoint(ccp(0.5,0))
        levelBg:setPosition(ccp(playerPic:getContentSize().width/2,25))
        playerPic:addChild(levelBg)
		
		-- 等级
		local levelStr=self.searchList[idx+1][8]
		local levelLabel=GetTTFLabelWrap(getlocal("fightLevel",{levelStr}),20,CCSizeMake(70,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
		levelLabel:setAnchorPoint(ccp(0.5,0))
		levelLabel:setPosition(playerPic:getContentSize().width/2,2)
		playerPic:addChild(levelLabel)

		-- 玩儿家名称
		local nameStr=self.searchList[idx+1][2]
		local nameLabel=GetTTFLabel(nameStr,24,true)
		nameLabel:setAnchorPoint(ccp(0,0.5))
		nameLabel:setPosition(15+65+15+85+10,cell:getContentSize().height/3*2)
		cell:addChild(nameLabel)

		-- 战斗力
		local tankSp=CCSprite:createWithSpriteFrameName("ltzdzTankFight.png")
		tankSp:setAnchorPoint(ccp(0,0.5))
	    tankSp:setScale(1.2)
	    tankSp:setPosition(15+65+15+85+10,cell:getContentSize().height/3)
	    cell:addChild(tankSp)

		local valueStr=self.searchList[idx+1][7]
		local valueLabel=GetTTFLabelWrap(FormatNumber(tonumber(valueStr)),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		valueLabel:setAnchorPoint(ccp(0,0.5))
		valueLabel:setPosition(15+65+15+85+20+tankSp:getContentSize().width*1.2,cell:getContentSize().height/3)
		cell:addChild(valueLabel)
		local function sendApplyCallback( ... )
			if self.specialFlag == "shield" then
				local function confirmHandler( ... )

				local blackList=G_getBlackList()
                if SizeOfTable(G_getBlackList())>=G_blackListNum then
                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("blackListMax"),28)
                  do return end
                end
                local function saveBlackCallback()
                   smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{self.searchList[idx+1][2]}),28)
                   self.sendApplyButtonList[idx+1]:setEnabled(false)
		           local btnLabel = tolua.cast(self.sendApplyButtonList[idx+1]:getChildByTag(101),"CCLabelTTF")
		           btnLabel:setString(getlocal("friend_newSys_shield_already"))
                end
                local toBlackTb={uid=tonumber(self.searchList[idx+1][1]),name=self.searchList[idx+1][2]}
                G_saveNameAndUidInBlackList(toBlackTb,saveBlackCallback)
            	end
			    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("friend_newSys_shieldConfirm"),false,confirmHandler)
			else
                if #friendInfoVo.friendTb + 1 > self.limit then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_err_12003"),28)
                else
    				local function callback(fn,data)
    					local ret,sData=base:checkServerData(data)
    		            if ret==true then
    		               smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("addMailListSuccess",{self.searchList[idx+1][2]}),28)
    		               self.sendApplyButtonList[idx+1]:setEnabled(false)
    		               local btnLabel = tolua.cast(self.sendApplyButtonList[idx+1]:getChildByTag(101),"CCLabelTTF")
    		               btnLabel:setString(getlocal("friend_newSys_fr_already_apply"))
    		            end
    	        	end
    				socketHelper:sendfriendApply(self.searchList[idx+1][1],callback)
                end
			end  
        end
        local realStr
        if self.specialFlag == "shield" then
        	realStr = "friend_newSys_shield"
        else
        	realStr = "addFriendStr"
        end
		local sendApplyButton = G_createBotton(cell,ccp(nameLabel:getPositionX()+240,cell:getContentSize().height/2),{getlocal(realStr),20},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",sendApplyCallback,0.7,-(self.layerNum-1)*20-2)
		self.sendApplyButtonList[idx+1] = sendApplyButton

		if self.specialFlag == "shield" then
			local isShield = tonumber(self.searchList[idx+1][12])
			if isShield == 1 then
				sendApplyButton:setEnabled(false)
				local btnLabel = tolua.cast(sendApplyButton:getChildByTag(101),"CCLabelTTF")
	            btnLabel:setString(getlocal("friend_newSys_shield_already"))
			end

        else
        	local btb = self.searchList[idx+1][11]
			for k,v in pairs(btb) do
				if tonumber(v) == tonumber(playerVoApi:getUid()) then
					sendApplyButton:setEnabled(false)
					local btnLabel = tolua.cast(sendApplyButton:getChildByTag(101),"CCLabelTTF")
	                btnLabel:setString(getlocal("friend_newSys_fr_already_apply"))
				end
			end
        end
    else

    	local tempTb = {}
    	if self.curChose == 1 then
    		tempTb = friendInfoVo.friendTb
    	else
    		tempTb = friendInfoVo.shieldTb
    	end

    	local function sendEmailCallback( ... )
            if tempTb and tempTb[idx+1] then
                require "luascript/script/game/scene/gamedialog/emailDetailDialog"
                emailVoApi:showWriteEmailDialog(self.layerNum+1,getlocal("email_write"),tempTb[idx+1].nickname,nil,nil,nil,nil,tempTb[idx+1].uid)
            end
		end
		local function chatCallback( ... )
	      	chatVoApi:showChatDialog(self.layerNum+1,nil,tempTb[idx+1].uid,tempTb[idx+1].nickname,true)
		end

		-- 军衔
	 	local rankStr = playerVoApi:getRankIconName(tonumber(tempTb[idx+1].rank))
		local mIcon=CCSprite:createWithSpriteFrameName(rankStr)
	    mIcon:setScale(65/mIcon:getContentSize().width)
	    mIcon:setAnchorPoint(ccp(0,0.5))
	    mIcon:setPosition(ccp(15,cell:getContentSize().height/2))	
	    cell:addChild(mIcon)
	    -- 头像和头像框
	    local function playerDetail( ... )

	    	-- 加入黑名单
			local function shieldCallback()
				do return end
			end

			local function nilFunc( ... )
				self.displayTv:reloadData()
			end

			local nameContent = tempTb[idx+1].nickname
			local levelContent = getlocal("alliance_info_level").." Lv."..tempTb[idx+1].level
			local fcContent=getlocal("player_message_info_power")..": "..FormatNumber(tonumber(tempTb[idx+1].fc))
			local allianceContent
			if tempTb[idx+1].alliancename then
				allianceContent=getlocal("player_message_info_alliance")..": "..tempTb[idx+1].alliancename
			else
				allianceContent=getlocal("player_message_info_alliance")..": "..getlocal("alliance_info_content")
			end
			local content={{nameContent,28,G_ColorYellowPro},{levelContent,22},{fcContent,22},{allianceContent,27}}

			local vipPicStr = nil
			-- 日本平台特殊处理，不展示VIP的具体等级
			local isShowVip = chatVoApi:isJapanV()
			if tempTb[idx+1].vip then
				if isShowVip then
					vipPicStr = "vipNoLevel.png"
				else
					vipPicStr = "Vip"..tempTb[idx+1].vip..".png"
				end
			end
			local btnStr = ""
			if self.curChose == 1 then
				btnStr = "delFriend"
			else
				btnStr = "friend_newSys_fr_apply"
			end
			smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png",CCSizeMake(550,530),nil,CCRect(170,80,22,10),"email",sendEmailCallback,"chat",chatCallback,getlocal("player_message_info_title"),content,nil,self.layerNum+1,1,nil,nil,nil,tempTb[idx+1].pic,getlocal("shield"),shieldCallback,getlocal(btnStr),nilFunc,tempTb[idx+1].rank,nil,nil,tempTb[idx+1].title,tempTb[idx+1].nickname,vipPicStr,nil,nil,tempTb[idx+1].bpic,tempTb[idx+1].uid)
	    	do return end
	    end 
	    local personPhotoName=playerVoApi:getPersonPhotoName(tempTb[idx+1].pic)
	    local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName,playerDetail,nil,nil,nil,tempTb[idx+1].bpic)
	    playerPic:setAnchorPoint(ccp(0,0.5))
	    playerPic:setTouchPriority(-(self.layerNum-1)*20-2)
	    playerPic:setScale(85/playerPic:getContentSize().width)
	    playerPic:setPosition(ccp(15+65+15,cell:getContentSize().height/2))
	    cell:addChild(playerPic)

        -- 等级黑条
        local levelBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
        levelBg:setRotation(180)
        levelBg:setContentSize(CCSizeMake(70,20))
        levelBg:setAnchorPoint(ccp(0.5,0))
        levelBg:setPosition(ccp(playerPic:getContentSize().width/2,25))
        playerPic:addChild(levelBg)

		-- 等级
		local levelStr=tempTb[idx+1].level
		local levelLabel=GetTTFLabelWrap(getlocal("fightLevel",{levelStr}),20,CCSizeMake(70,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
		levelLabel:setAnchorPoint(ccp(0.5,0))
		levelLabel:setPosition(playerPic:getContentSize().width/2,2)
		playerPic:addChild(levelLabel)

		-- 玩儿家名称
		local nameStr=tempTb[idx+1].nickname
		local nameLabel=GetTTFLabel(nameStr,24,true)
		nameLabel:setAnchorPoint(ccp(0,0.5))
		nameLabel:setPosition(15+65+15+85+10,cell:getContentSize().height/3*2)
		cell:addChild(nameLabel)

		-- 战斗力
		local tankSp=CCSprite:createWithSpriteFrameName("ltzdzTankFight.png")
		tankSp:setAnchorPoint(ccp(0,0.5))
	    tankSp:setScale(1.2)
	    tankSp:setPosition(15+65+15+85+10,cell:getContentSize().height/3)
	    cell:addChild(tankSp)

		local valueStr=tempTb[idx+1].fc
		local valueLabel=GetTTFLabelWrap(FormatNumber(tonumber(valueStr)),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		valueLabel:setAnchorPoint(ccp(0,0.5))
		valueLabel:setPosition(15+65+15+85+20+tankSp:getContentSize().width*1.2,cell:getContentSize().height/3)
		cell:addChild(valueLabel)
	    local function deleteShieldCallback( ... )
	        local function callBack( ... )
	            self.tv:reloadData()
	        end
	        if self.curChose == 1 then
	        	local function confirmHandler( ... )
	            	local function callback(fn,data)
	                    local ret,sData=base:checkServerData(data)
	                    if ret==true then
	                       smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_fr_del"),28)
	                       friendInfoVoApi:removeFriend(tempTb[idx+1].uid)
	                       self.displayTv:reloadData()
	                    end   
	                end
                    if tempTb and tempTb[idx+1] then
                        socketHelper:friendsDel(tempTb[idx+1].uid,tempTb[idx+1].nickname,callback)
                    end
	            end
    			G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("friend_newSys_delConfirm"),false,confirmHandler) 
	        else
	        	local function confirmHandler( ... )
		        	local function callBack( ... )
	            		self.displayTv:reloadData()
	       			end
	        		G_removeMemberInBlackListByUid(tempTb[idx+1].uid,callBack)
	        	end
    			G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("friend_newSys_delshieldConfirm"),false,confirmHandler) 
	    	end
	    end 
	    -- 删除屏蔽按钮
	    local deleteShield = G_createBotton(cell,ccp((G_VisibleSizeWidth-40)/3*2+70,cell:getContentSize().height/2),nil,"yh_BtnNo.png","yh_BtnNo_Down.png","yh_BtnNo.png",deleteShieldCallback,1,-(self.layerNum-1)*20-2)
    end
	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
	lineSp:setAnchorPoint(ccp(0.5,0))
	lineSp:setPosition(ccp(cell:getContentSize().width/2,0))
	lineSp:setContentSize(CCSizeMake(cell:getContentSize().width-30,2))
	cell:addChild(lineSp)
end

function friendInfoSmallDialog:rejectAll()
	local rejectList = {}
	for k,v in pairs(friendInfoVo.binviteTb) do
		table.insert(rejectList,friendInfoVo.binviteTb[k].uid)
	end
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret == true then
			for i=#friendInfoVo.binviteTb,1,-1 do
				table.remove(friendInfoVo.binviteTb,i)
			end
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_apply_reject"),30)
			friendInfoVo.friendChanegFlag = 1
			friendInfoVo.friendGiftFlag = 1
			return self:close()
		end
	end
	socketHelper:rejectApply(rejectList,callback)
end


function friendInfoSmallDialog:getCellSp(idx)

    local cellSp=CCNode:create()
    cellSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,105))
    cellSp:setAnchorPoint(ccp(0,0))
    cellSp:setPosition(0,0)
    local tempTb = {}

        if self.curChose == 1 then
            tempTb = friendInfoVo.friendTb
        else
            tempTb = friendInfoVo.shieldTb
        end

        local function sendEmailCallback( ... )
            if tempTb and tempTb[idx+1] then
                require "luascript/script/game/scene/gamedialog/emailDetailDialog"
                emailVoApi:showWriteEmailDialog(self.layerNum+1,getlocal("email_write"),tempTb[idx+1].nickname,nil,nil,nil,nil,tempTb[idx+1].uid)
            end
        end
        local function chatCallback( ... )
            chatVoApi:showChatDialog(self.layerNum+1,nil,tempTb[idx+1].uid,tempTb[idx+1].nickname,true)
        end

        -- 军衔
        local rankStr = playerVoApi:getRankIconName(tonumber(tempTb[idx+1].rank))
        local mIcon=CCSprite:createWithSpriteFrameName(rankStr)
        mIcon:setScale(65/mIcon:getContentSize().width)
        mIcon:setAnchorPoint(ccp(0,0.5))
        mIcon:setPosition(ccp(15,cellSp:getContentSize().height/2))   
        cellSp:addChild(mIcon)
        -- 头像和头像框
        local function playerDetail( ... )

            -- 加入黑名单
            local function shieldCallback()
                do return end
            end

            local function nilFunc( ... )
                self.displayTv:reloadData()
            end

            local nameContent = tempTb[idx+1].nickname
            local levelContent = getlocal("alliance_info_level").." Lv."..tempTb[idx+1].level
            local fcContent=getlocal("player_message_info_power")..": "..FormatNumber(tonumber(tempTb[idx+1].fc))
            local allianceContent
            if tempTb[idx+1].alliancename then
                allianceContent=getlocal("player_message_info_alliance")..": "..tempTb[idx+1].alliancename
            else
                allianceContent=getlocal("player_message_info_alliance")..": "..getlocal("alliance_info_content")
            end
            local content={{nameContent,28,G_ColorYellowPro},{levelContent,22},{fcContent,22},{allianceContent,27}}

            local vipPicStr = nil
            -- 日本平台特殊处理，不展示VIP的具体等级
            local isShowVip = chatVoApi:isJapanV()
            if tempTb[idx+1].vip then
                if isShowVip then
                    vipPicStr = "vipNoLevel.png"
                else
                    vipPicStr = "Vip"..tempTb[idx+1].vip..".png"
                end
            end
            local btnStr = ""
            if self.curChose == 1 then
                btnStr = "delFriend"
            else
                btnStr = "friend_newSys_fr_apply"
            end
            smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png",CCSizeMake(550,530),nil,CCRect(170,80,22,10),"email",sendEmailCallback,"chat",chatCallback,getlocal("player_message_info_title"),content,nil,self.layerNum+1,1,nil,nil,nil,tempTb[idx+1].pic,getlocal("shield"),shieldCallback,getlocal(btnStr),nilFunc,tempTb[idx+1].rank,nil,nil,tempTb[idx+1].title,tempTb[idx+1].nickname,vipPicStr,nil,nil,tempTb[idx+1].bpic,tempTb[idx+1].uid)
            do return end
        end 
        local personPhotoName=playerVoApi:getPersonPhotoName(tempTb[idx+1].pic)
        local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName,playerDetail,nil,nil,nil,tempTb[idx+1].bpic)
        playerPic:setAnchorPoint(ccp(0,0.5))
        playerPic:setTouchPriority(-(self.layerNum-1)*20-2)
        playerPic:setScale(85/playerPic:getContentSize().width)
        playerPic:setPosition(ccp(15+65+15,cellSp:getContentSize().height/2))
        cellSp:addChild(playerPic)

        -- 等级黑条
        local levelBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
        levelBg:setRotation(180)
        levelBg:setContentSize(CCSizeMake(70,20))
        levelBg:setAnchorPoint(ccp(0.5,0))
        levelBg:setPosition(ccp(playerPic:getContentSize().width/2,25))
        playerPic:addChild(levelBg)

        -- 等级
        local levelStr=tempTb[idx+1].level
        local levelLabel=GetTTFLabelWrap(getlocal("fightLevel",{levelStr}),20,CCSizeMake(70,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        levelLabel:setAnchorPoint(ccp(0.5,0))
        levelLabel:setPosition(playerPic:getContentSize().width/2,2)
        playerPic:addChild(levelLabel)

        -- 玩儿家名称
        local nameStr=tempTb[idx+1].nickname
        local nameLabel=GetTTFLabel(nameStr,24,true)
        nameLabel:setAnchorPoint(ccp(0,0.5))
        nameLabel:setPosition(15+65+15+85+10,cellSp:getContentSize().height/3*2)
        cellSp:addChild(nameLabel)

        -- 战斗力
        local tankSp=CCSprite:createWithSpriteFrameName("ltzdzTankFight.png")
        tankSp:setAnchorPoint(ccp(0,0.5))
        tankSp:setScale(1.2)
        tankSp:setPosition(15+65+15+85+10,cellSp:getContentSize().height/3)
        cellSp:addChild(tankSp)

        local valueStr=tempTb[idx+1].fc
        local valueLabel=GetTTFLabelWrap(FormatNumber(tonumber(valueStr)),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        valueLabel:setAnchorPoint(ccp(0,0.5))
        valueLabel:setPosition(15+65+15+85+20+tankSp:getContentSize().width*1.2,cellSp:getContentSize().height/3)
        cellSp:addChild(valueLabel)
        local function deleteShieldCallback( ... )
            local function callBack( ... )
                self.tv:reloadData()
            end
            if self.curChose == 1 then
                local function confirmHandler( ... )
                    local function callback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                           smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_fr_del"),28)
                           friendInfoVoApi:removeFriend(tempTb[idx+1].uid)
                           self.displayTv:reloadData()
                        end   
                    end
                    if tempTb[idx+1] then
                        socketHelper:friendsDel(tempTb[idx+1].uid,tempTb[idx+1].nickname,callback)
                    end
                end
                G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("friend_newSys_delConfirm"),false,confirmHandler) 
            else
                local function confirmHandler( ... )
                    local function callBack( ... )
                        self.displayTv:reloadData()
                    end
                    G_removeMemberInBlackListByUid(tempTb[idx+1].uid,callBack)
                end
                G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("friend_newSys_delshieldConfirm"),false,confirmHandler) 
            end
        end 
        -- 删除屏蔽按钮
        local deleteShield = G_createBotton(cellSp,ccp((G_VisibleSizeWidth-40)/3*2+70,cellSp:getContentSize().height/2),nil,"yh_BtnNo.png","yh_BtnNo_Down.png","yh_BtnNo.png",deleteShieldCallback,1,-(self.layerNum-1)*20-2)
    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
    lineSp:setAnchorPoint(ccp(0.5,0))
    lineSp:setPosition(ccp(cellSp:getContentSize().width/2,0))
    lineSp:setContentSize(CCSizeMake(cellSp:getContentSize().width-30,2))
    cellSp:addChild(lineSp)

    return cellSp
end

function friendInfoSmallDialog:applyAll()
	-- 判断我的好友是否已经达到上限
	if #friendInfoVo.friendTb >= self.limit then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_apply_success_defeat1"),30)
        do return end
	elseif #friendInfoVo.binviteTb + #friendInfoVo.friendTb - self.limit >0 then
		for i=1,self.limit-#friendInfoVo.friendTb,1 do
			table.insert(self.acceptList,friendInfoVo.binviteTb[i].uid)
		end
	else
		for k,v in pairs(friendInfoVo.binviteTb) do
			table.insert(self.acceptList,friendInfoVo.binviteTb[k].uid)
		end
	end
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret == true then
			if sData.data.friends and sData.data.friends.user then
                if #sData.data.friends.user == 0 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_err_12008"),30)
                else
    				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_apply_successAll"),30)
    				for i=1,#sData.data.friends.user,1 do
    					-- 判断对方的好友是否达到上限
    					for k,v in pairs(friendInfoVo.binviteTb) do
    						if v.uid == sData.data.friends.user[i] then
    							v["sendFlag"] = 0
    							v["receiveFlag"] = 0
    							table.insert(friendInfoVo.friendTb,v)
    							table.remove(friendInfoVo.binviteTb,k)
    							friendInfoVo.friendGiftFlag = 1
    							break
    						end
    					end
    				end
                    friendInfoVo.friendChanegFlag = 1
                    friendInfoVo.friendGiftFlag = 1
                    return self:close()    				
                end
			end
		end
	end
	socketHelper:agreefriendApply(self.acceptList,callback)
end

function friendInfoSmallDialog:updateButton( ... )

	if self.applyButton then
		if #friendInfoVo.binviteTb == 0 then
			self.applyButton:setEnabled(false)
		else
			self.applyButton:setEnabled(true)
		end
	end

	if self.rejectButton then
		if #friendInfoVo.binviteTb == 0 then
			self.rejectButton:setEnabled(false)
		else
			self.rejectButton:setEnabled(true)
		end
	end

end

function friendInfoSmallDialog:updateApplyTipLabel( ... )
	if self.noApplyLabel then
		if #friendInfoVo.binviteTb == 0 then
			self.noApplyLabel:setVisible(true)
		else
			self.noApplyLabel:setVisible(false)
		end
	end
end


function friendInfoSmallDialog:updateSearchTipLabel( ... )
	if self.noResultLabel then
		if #self.searchList == 0 then
			self.noResultLabel:setVisible(true)
		else
			self.noResultLabel:setVisible(false)
		end
	end
end

function friendInfoSmallDialog:sortSearchList(searchList,specialflag)
	local flag = 0
	for k,v in pairs(searchList) do
		for i=1,#searchList - k,1 do
			if specialflag == "shield" then
        		local temp1 = tonumber(searchList[i][12])
        		local temp2 = tonumber(searchList[i+1][12])
        		if temp1 == 1 and temp2 == 0 then
        			local temp = searchList[i+1]
					searchList[i+1] = searchList[i]
					searchList[i] = temp
					flag = 1
				elseif temp1 == temp2 then
					if tonumber(searchList[i][8]) < tonumber(searchList[i+1][8]) then
						local temp = searchList[i+1]
						searchList[i+1] = searchList[i]
						searchList[i] = temp
						flag = 1
					end
        		end
			else
				local isApply1 = 0
				local isApply2 = 0
	        	local btb1 = searchList[i][11]
	        	local btb2 = searchList[i+1][11]
        		for k,v in pairs(btb1) do
        			if tonumber(v) == tonumber(playerVoApi:getUid()) then
        				isApply1 = 1
        			end
        		end
        		for k,v in pairs(btb2) do
        			if tonumber(v) == tonumber(playerVoApi:getUid()) then
        				isApply2 = 1
        			end
        		end
        		if  isApply1 == 1 and isApply2 == 0 then
        			local temp = searchList[i+1]
					searchList[i+1] = searchList[i]
					searchList[i] = temp
					flag = 1
				elseif isApply1 == isApply2 then
					if tonumber(searchList[i][8]) < tonumber(searchList[i+1][8]) then
						local temp = searchList[i+1]
						searchList[i+1] = searchList[i]
						searchList[i] = temp
						flag = 1
					end
        		end
			end

		end
		if flag == 0 then
			break
		end
	end
end


function friendInfoSmallDialog:updatenoFriendLabel( ... )
	if self.noFriendLabel then
 		if self.curChose == 1 and #friendInfoVo.friendTb == 0 then
 			self.noFriendLabel:setVisible(true)
 			self.noFriendLabel:setString(getlocal("friend_newSys_list_tip"))
 		elseif self.curChose == 2 and #friendInfoVo.shieldTb == 0 then
 			self.noFriendLabel:setVisible(true)
 			self.noFriendLabel:setString(getlocal("friend_newSys_shield_tip"))
 		else
 			self.noFriendLabel:setVisible(false)
 		end
 	end
end

function friendInfoSmallDialog:fastTick()
    if self.cellTb and self.cellInitIndex < self.cellNum-1  then
        self.tickIndex=self.tickIndex+1
        if(self.tickIndex%3==0)then
            self.cellInitIndex = self.cellInitIndex+1
            if(self.cellTb[self.cellInitIndex+1]) and self.cellInitIndex >= 1 then
                local cellSp=self:getCellSp(self.cellInitIndex)
                self.cellTb[self.cellInitIndex+1]:addChild(cellSp)
            end
        end
    end
end

function friendInfoSmallDialog:tick( ... )
	if self.numLabel then
 		tolua.cast(self.numLabel,"CCLabelTTF"):setString(getlocal("friend_newSys_apply",{#friendInfoVo.binviteTb,self.limit}))
 	end

 	self:updatenoFriendLabel()

 	if self.messageLabel then
 		local str = ""
		local param
        local limit
		if self.curChose == 1 then
			str = "friend_newSys_desc1"
			param = #friendInfoVo.friendTb
            limit = self.limit
		else
			str = "friend_newSys_desc3"
			param = #friendInfoVo.shieldTb
            limit = G_blackListNum
		end
 		tolua.cast(self.messageLabel,"CCLabelTTF"):setString(getlocal(str,{param,limit}))
 	end
	self:updateButton()
	self:updateApplyTipLabel()
	self:updateSearchTipLabel()
	if friendInfoVo.friendbiInviteFlag == 1 then
		if self.resultTv then
 			tolua.cast(self.numLabel,"CCLabelTTF"):setString(getlocal("friend_newSys_apply",{#friendInfoVo.binviteTb,self.limit}))
			self:updateButton()
			self:updateApplyTipLabel()
			self:updateSearchTipLabel()
			self.resultTv:reloadData()
		end
		friendInfoVo.friendbiInviteFlag = 0
	end
end