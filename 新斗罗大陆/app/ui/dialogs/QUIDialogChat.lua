--
-- Author: Qinyuanji
-- Date: 2015-02-09 
-- This class is for chat window

local QUIDialog = import(".QUIDialog")
local QUIDialogChat = class("QUIDialogChat", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetChatBar = import("..widgets.QUIWidgetChatBar")
local QUIWidgetPrivateChat = import("..widgets.QUIWidgetPrivateChat")
local QScrollView = import("...views.QScrollView")
local QChatData = import("...models.chatdata.QChatData")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTeamChat = import("..widgets.QUIWidgetTeamChat")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetChatTime = import("..widgets.QUIWidgetChatTime")
local QUIWidgetChatFace = import("..widgets.QUIWidgetChatFace")
local QColorLabel = import("...utils.QColorLabel")

QUIDialogChat.TOP_POSITION = 5
QUIDialogChat.ACTION_DURATION = 0.3
QUIDialogChat.MAX_MESSAGE = 100
QUIDialogChat.MAX_CHATTER = 50
QUIDialogChat.SEND_CD = 10
QUIDialogChat.CHAR_OFFSETY = -10

QUIDialogChat.NO_INPUT_ERROR = "不能发送空信息"
QUIDialogChat.NO_ROOM_ERROR = "该频道未建立"
QUIDialogChat.NO_CHATTER_ERROR = "未找到您的私聊对象"
QUIDialogChat.DEFAULT_PROMPT = "请输入聊天内容"
QUIDialogChat.NOT_AUTHORIZED = "战队等级%d级后才能在世界频道发言"
QUIDialogChat.NO_PRIVATE_CHATTER = "NO_PRIVATE_CHATTER"

QUIDialogChat.BACKGROUNDCOLORS = {ccc3(139, 98, 74), ccc3(109, 72, 51)}
QUIDialogChat.InBoxPlaceholderCOLOR = ccc3(137, 97, 57)
QUIDialogChat.InBoxTextCOLOR =  ccc3(198, 187, 179)

QUIDialogChat.LIMIT_TIMES_SECTION = 10

local lastClosedTab = nil

function QUIDialogChat:ctor(options)
	local ccbFile = "ccb/Dialog_Chat.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSend", callback = handler(self, self._onTriggerSend)},
		{ccbCallbackName = "onTriggerBulletin", callback = handler(self, self._onTriggerBulletin)},
		{ccbCallbackName = "onTriggerGlobal", callback = handler(self, self._onTriggerGlobal)},
		{ccbCallbackName = "onTriggerUnion", callback = handler(self, self._onTriggerUnion)},
		{ccbCallbackName = "onTriggerPrivate", callback = handler(self, self._onTriggerPrivate)},
		{ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},
		{ccbCallbackName = "onTriggerTeamInfo", callback = handler(self, self._onTriggerTeamInfo)},
		{ccbCallbackName = "onTriggerDynamic", callback = handler(self, self._onTriggerDynamic)},
		{ccbCallbackName = "onTriggerLock", callback = handler(self, self._onTriggerLock)},
		{ccbCallbackName = "onTriggerMood", callback = handler(self, self._onTriggerMood)},
		{ccbCallbackName = "onTriggerGotoUnion",callback = handler(self,self._onTriggerGotoUnion)},
		{ccbCallbackName = "onTriggerCrossTeam",callback = handler(self,self._onTriggerCrossTeam)},
		{ccbCallbackName = "onPrivateChatterRemove",callback = handler(self,self._onPrivateChatterRemove)},
		{ccbCallbackName = "onPrivateAddblack", callback = handler(self,self._onPrivateAddblack)},
	}
	QUIDialogChat.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
    self._isHaveUnion = true

    q.setButtonEnableShadow(self._ccbOwner.btn_del)

    -- add input box
    self._inputWidth = self._ccbOwner.inputArea:getContentSize().width
    self._inputHeight = self._ccbOwner.inputArea:getContentSize().height
    -- if device.platform ~= "android" and device.platform ~= "ios" then self._inputWidth = 150 end 
    self._inputMsg = ui.newEditBox({image = "ui/none.png", listener = handler(self, self.onEdit), size = CCSize(self._inputWidth - 10, self._inputHeight-4)})
    self._inputMsg:setFont(global.font_default, 20)
    self._inputMsg:setMaxLength(50)
    self._inputMsg:setFontName(global.font_name)
    self._inputMsg:setPlaceholderFontName(global.font_name)
    self._inputMsg:setAnchorPoint(ccp(0, 0.5))

    self._inputMsg:setPlaceHolder(QUIDialogChat.DEFAULT_PROMPT)
    self._inputMsg:setFontColor(QUIDialogChat.InBoxTextCOLOR ) 
    self._inputMsg:setPlaceholderFontColor(QUIDialogChat.InBoxPlaceholderCOLOR) --mac上没实现方法 需要上手机测试

    self._ccbOwner.input:addChild(self._inputMsg)
    self:showChatWithoutUnion()
	self._ccbOwner.sheetP1:setVisible(false)
	self._ccbOwner.face_node:setVisible(false)
	self._ccbOwner.face_node:removeAllChildren()
	self._chatFaceWidget = QUIWidgetChatFace.new()
	self._chatFaceWidget:addEventListener(QUIWidgetChatFace.CHOOSE_FACE_EVENT_CLICK, handler(self, self._clickChooseFace))
	self._ccbOwner.face_node:addChild(self._chatFaceWidget)


	self._chats = {}
	self._chatsAndTime = {}
  	self._data = app:getServerChatData() -- app:getXMPPData() 
  	self._data:retrieveHistoryData()
  	
  	if options.force and options.initTab then
  		self._initTab = options.initTab
  	else
    	self._initTab = lastClosedTab or options.initTab
    end
    self._isMain = options.isMain or false
    self._isInUnion = options.isInUnion or false
    self._isInBlackRock = options.isInBlackRock or false
    self._initChatter = options.initChatter
    self._closeCallback = options.closeCallback

	self._chatDataProxy = cc.EventProxy.new(self._data)

    if CCNode.wakeup then
        self._root:wakeup()
    end
    
    -- 设置为组队频道
    self._isTeamChannel = options.isTeamChannel or false
    self._inChannelState = options.inChannelState or CHAT_CHANNEL_INTYPE.CHANNEL_IN_NORMAL
 	self._teamChatter = {}

 	self._ccbOwner.team_tip:setVisible(false)
    self:initTabPosition()
end

function QUIDialogChat:viewDidAppear( ... )
	QUIDialogChat.super.viewDidAppear(self)

	-- 希尔维斯大斗场
	if remote.silvesArena:checkUnlock() and self._inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
		if remote.silvesArena:checkCanChat() and not self._chatSilvesDataProxy then
			self._chatSilvesDataProxy = cc.EventProxy.new(remote.silvesArena)
    		self._chatSilvesDataProxy:addEventListener(remote.silvesArena.NEW_MESSAGE_RECEIVED, handler(self, self._onSilvesMessageReceived))
    	end

    	local updateSilvesCorssTeamChatHistory = function ()
			if self:safeCheck() then
				if not self._isMain then
    				app:getServerChatData():refreshSilvesCorssTeamChatHistory(true)
    			end
			end
		end
		local initChatHistory = function()
			if remote.silvesArena:checkCanChat() then
	    		app:getServerChatData():refreshSilvesTeamChatHistory(true, updateSilvesCorssTeamChatHistory)
	    		if not self._isMain and not self._timeChatHistoryScheduler then
	    			self._timeChatHistoryScheduler = scheduler.scheduleGlobal(updateSilvesCorssTeamChatHistory, 10)
	    		end
			end
		end
		
		if self._isMain then
			remote.silvesArena:silvesArenaGetMainInfoRequest(function()
				if self:safeCheck() then
					self:initTabPosition()
					initChatHistory()

					if self._initTab == "tabTeam" then
						self:_onTriggerTeam()
					end
				end
			end)
		end
		
		initChatHistory()

	    if self._isMain then
	    	self._ccbOwner.tabTeam:setTitleTTFSizeForState(22, CCControlStateNormal)
		    self._ccbOwner.tabTeam:setTitleTTFSizeForState(22, CCControlStateHighlighted)
		    self._ccbOwner.tabTeam:setTitleTTFSizeForState(22, CCControlStateDisabled)
			self._ccbOwner.tabTeam:setTitleForState(CCString:create("西尔维斯"), CCControlStateNormal)
		    self._ccbOwner.tabTeam:setTitleForState(CCString:create("西尔维斯"), CCControlStateHighlighted)
		    self._ccbOwner.tabTeam:setTitleForState(CCString:create("西尔维斯"), CCControlStateDisabled)
		else
			self._ccbOwner.tabCrossTeam:setTitleTTFSizeForState(22, CCControlStateNormal)
		    self._ccbOwner.tabCrossTeam:setTitleTTFSizeForState(22, CCControlStateHighlighted)
		    self._ccbOwner.tabCrossTeam:setTitleTTFSizeForState(22, CCControlStateDisabled)
			self._ccbOwner.tabCrossTeam:setTitleForState(CCString:create("西尔维斯"), CCControlStateNormal)
		    self._ccbOwner.tabCrossTeam:setTitleForState(CCString:create("西尔维斯"), CCControlStateHighlighted)
		    self._ccbOwner.tabCrossTeam:setTitleForState(CCString:create("西尔维斯"), CCControlStateDisabled)
	    end

	    if remote.silvesArena:getNewMessageState() then
	    	self._ccbOwner.team_tip:setVisible(true)
	    else
	    	self._ccbOwner.team_tip:setVisible(false)
	    end
	else
		self._remoteBlackRockProxy = cc.EventProxy.new(remote.blackrock)
		self._remoteBlackRockProxy:addEventListener(remote.blackrock.EVENT_UPDATE_TEAM_INFO, handler(self, self.refreshTeamChatList))
	end

	self._remoteProxy = cc.EventProxy.new(remote)
	self._remoteProxy:addEventListener(QUIWidgetChatBar.DETAIL_INFO, handler(self, self._onFriendDetailInfo))

	self._data:setSensitivity(0.1)
end

function QUIDialogChat:viewAnimationInHandler( ... )
	scheduler.performWithDelayGlobal(self:safeHandler(function ( ... )
		self._ccbOwner[self._initTab](true)
	end), 0.01)
end

function QUIDialogChat:viewWillDisappear()
	QUIDialogChat.super.viewWillDisappear(self)
	self._chatDataProxy:removeAllEventListeners()
	self._chatDataProxy = nil

	if self._remoteBlackRockProxy then
		self._remoteBlackRockProxy:removeAllEventListeners()
		self._remoteBlackRockProxy = nil
	end
	if self._chatSilvesDataProxy then
		self._chatSilvesDataProxy:removeAllEventListeners()
		self._chatSilvesDataProxy = nil
	end

	self._remoteProxy:removeAllEventListeners()
	self._remoteProxy = nil

	self._data:setSensitivity()

	if self._sendCDId then
		scheduler.unscheduleGlobal(self._sendCDId)
		self._sendCDId = nil
	end
	if self._timeChatHistoryScheduler then
		scheduler.unscheduleGlobal(self._timeChatHistoryScheduler)
		self._timeChatHistoryScheduler = nil
	end

 	self._data:serializePrivateChannel()

end

function QUIDialogChat:showChatWithoutUnion()
	-- body
	self._ccbOwner.gotoUnion:setVisible(false)
	self._ccbOwner.chatNode:setVisible(true)
	self._isHaveUnion = true
	self._inputMsg:setEnabled(true)
	self._inputMsg:setVisible(true)
end
function QUIDialogChat:hideChatWithoutUnion()
	-- body
	self._ccbOwner.gotoUnion:setVisible(true)
	self._ccbOwner.sysNode:setVisible(true)
	self._ccbOwner.chatNode:setVisible(false)
	self._isHaveUnion = false
	self._inputMsg:setEnabled(false)
	self._inputMsg:setVisible(false)
end

function QUIDialogChat:initScrollBar(private, isTeam)
	if self._scrollViewP then 
		self._scrollViewP:removeFromParent() 
		self._scrollViewP = nil
	end

	local sheetNode1 = CCNode:create()
	self._ccbOwner.sheetP1:addChild(sheetNode1)
	
	if private then
		self._scrollViewP = QScrollView.new(sheetNode1, self._ccbOwner.sheet_layoutP1:getContentSize(), {sensitiveDistance = 10})
		self._scrollViewP:setHorizontalBounce(true)

	    self._scrollViewP:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onPScrollViewMoving))
	    self._scrollViewP:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onPScrollViewBegan))
	end

	self._privateChatWidget = nil
	if self._locked then return end

	self:initListView(private,isTeam)
end

function QUIDialogChat:insetChatTime( )
	table.sort(self._chats,function( a,b )
		if a.body.stamp ~= b.body.stamp then
			return a.body.stamp < b.body.stamp
		end
	end)
	
	self._chatsAndTime = {}
	local timeInterval = MIN*5
	local curTime = q.serverTime()
	local compareChat = nil
	for index,chatInfo in pairs(self._chats) do
		local switchTime = false
		if chatInfo.body.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_GLOBAL or chatInfo.body.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM_SHARE or chatInfo.body.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM  then
			switchTime = true
		end
		if switchTime then
			if compareChat == nil and curTime - chatInfo.body.stamp/1000 >= timeInterval then
				compareChat = chatInfo
				table.insert(self._chatsAndTime,{opType = "chatTime",time = chatInfo.body.stamp/1000})
			elseif compareChat and chatInfo.body.stamp/1000 - compareChat.body.stamp/1000 >= timeInterval then
				compareChat = chatInfo
				table.insert(self._chatsAndTime,{opType = "chatTime",time = chatInfo.body.stamp/1000})
			end
		else
			if compareChat == nil and curTime - chatInfo.body.stamp >= timeInterval then
				compareChat = chatInfo
				table.insert(self._chatsAndTime,{opType = "chatTime",time = chatInfo.body.stamp})
			elseif compareChat and chatInfo.body.stamp - compareChat.body.stamp >= timeInterval then
				compareChat = chatInfo
				table.insert(self._chatsAndTime,{opType = "chatTime",time = chatInfo.body.stamp})
			end			
		end
		table.insert(self._chatsAndTime,{opType = "chatmsg",chatInfo = chatInfo})
	end
end
function QUIDialogChat:initListView(private,isTeam)
	-- body
	self._ccbOwner.sheetP1:setVisible(private)
	self._ccbOwner.sheet_layoutP1:setVisible(private)
	local teamSilvesChat = (self._currentChannelId == self._data:teamSilvesChannelId())
	local sheetLayout = self._ccbOwner.sheet_layout
	if private then
		self._ccbOwner.sheet_layout:setContentSize(CCSize(626,385))
		self._ccbOwner.sheet_layout:setPositionY(-185)
		self._ccbOwner.node_private_cell:setVisible(true)	
	elseif isTeam or teamSilvesChat then
		self._ccbOwner.sheet_layout:setContentSize(CCSize(626,415))
		self._ccbOwner.sheet_layout:setPositionY(-150)	
		self._ccbOwner.node_private_cell:setVisible(false)	
	else
		self._ccbOwner.sheet_layout:setPositionY(0)
		self._ccbOwner.sheet_layout:setContentSize(CCSize(626,565))	
		self._ccbOwner.node_private_cell:setVisible(false)
	end
	
	self:insetChatTime()

	self._ccbOwner.sheet_layout:setVisible(true)
	if self._listViewLayout then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_layout:getContentSize())
		self._listViewLayout:resetTouchRect()
	end

    local _scrollEndCallback
    local _scrollBeginCallback
    local _scrollMogveinggCallback
    _scrollEndCallback = function ()
    	print("_scrollEndCallback")
        if self:safeCheck() then
			self._locked = false
			self:setLockState(false)
           self._ccbOwner.face_node:setVisible(false)
        end
    end

    _scrollBeginCallback = function ()
    	print("_scrollBeginCallback")
        if self:safeCheck() then
    		if self._listViewLayout and self._listViewLayout:getIsExceedRect() then
				self._locked = true
				self:setLockState(true)    		
			end      	
            self._ccbOwner.face_node:setVisible(false)
        end
    end
    _scrollMogveinggCallback = function(isleft,offestY)
    	if self:safeCheck() then
    		if self._listViewLayout and self._listViewLayout:getIsExceedRect() then
				self._locked = true
				self:setLockState(true)    		
			end
    		self._ccbOwner.face_node:setVisible(false)
    	end
    end

	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._chatsAndTime[index]

	            local item = list:getItemFromCache(itemData.opType)
	            if not item then
	            	if itemData.opType == "chatmsg" then
	            		item = QUIWidgetChatBar.new()
	            	else
	            		item = QUIWidgetChatTime.new()
		            end
		            isCacheNode = false
	            end
	            if itemData.opType == "chatmsg" then
		            item:setInfo(self._currentChannelId, itemData.chatInfo.body.from, itemData.chatInfo.body.to, itemData.chatInfo.body.message, itemData.chatInfo.body.stamp, 
					 		itemData.chatInfo.body.misc, false, self, self._currentChannelType, self._isTeamChannel)
		            info.item = item
		            info.size = item:getContentSize()

		            local showAppbtn = item:getAplybtnVisible()
		            local assistBtn = item:getAssistbtnVisible()
		            local goBtn = item:getGobtnVisible()
		       		
		       		list:unRegisterTouchHandler(index)
		       		list:registerBtnHandler(index, "btn_head1", "_onAvatarClicked")
		       		list:registerBtnHandler(index, "btn_head2", "_onAvatarClicked")
		       		list:registerBtnHandler(index, "replay2", "_onTriggerReplay", nil, true)
		       		list:registerBtnHandler(index, "replay1", "_onTriggerReplay", nil, true)

		       		if assistBtn then
		       			list:registerBtnHandler(index, "btn_assist_btn", "_onTriggerAssist", nil, true)
		       		end

		       		if showAppbtn then
		       			list:registerBtnHandler(index, "btn_apply_btn", "_onTriggerApply", nil, true)
		       		end
		       
		       		if goBtn then
		       			list:registerBtnHandler(index, "btn_goto_btn", "_onTriggerGoto", nil, true)
		       		end
		       	else
		       		item:setInfo(itemData.time)
		            info.item = item
		            info.size = item:getContentSize()
		       	end

	            return isCacheNode
	        end,
	        curOriginOffset = 20,
	        curOffset = 20,
	        enableShadow = false,
	      	ignoreCanDrag = true,		      	
	      	spaceY = 10,
	        scrollEndCallBack = _scrollEndCallback,
            scrollBeginCallBack = _scrollBeginCallback,
            scrollMogveinggCallback = _scrollMogveinggCallback,	      	
	        totalNumber = #self._chatsAndTime,
	        tailIndex = #self._chatsAndTime,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listViewLayout:reload({totalNumber = #self._chatsAndTime,tailIndex=#self._chatsAndTime})
	end		

	if private then
		self:refreshPrivateChatList()
	end
end


function QUIDialogChat:initTabPosition()
	local tabList = { 
			{name = "tabSys", callback = "onTriggerBulletin"}, 
			{name = "node_world", callback = "onTriggerGlobal"}, 
			{name = "node_union", callback = "onTriggerUnion"}, 
		  	{name = "node_private", callback = "onTriggerPrivate"},
		  	{name = "tabTeamInfo", callback = "onTriggerTeamInfo"}, 
		  	{name = "node_team", callback = "onTriggerTeam"},
		  	{name = "tabDynamic", callback = "onTriggerDynamic"},
		  	{name = "tabCrossTeam", callback = "onTriggerCrossTeam"}
		}
	local startPosY = 275
	local gapY = 70
	local index = 0

	local tabIndex = {1, 2, 3, 4, 7}
	if self._isMain and not self._isInUnion then
		tabIndex = {1, 2, 3, 4, 6, 7}
	end
	-- 希尔维斯大斗场
	if not self._isMain and self._inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
		tabIndex = {2, 3, 6, 8}
	else
		if self._isTeamChannel then 
			tabIndex = {2, 3, 6}
		end 
	end
    -- print("tabIndex ---",tabIndex)
    -- printTable(tabIndex)

	for i = 1, #tabList do
		self._ccbOwner[tabList[i].name]:setVisible(false)
	end

	local isHaveTab = false
	local addTab = function (tab)
		print("<ADD> ", tabList[tab].name)
		self._ccbOwner[tabList[tab].name]:setVisible(true)
		self._ccbOwner[tabList[tab].name]:setPositionY(startPosY - index*gapY)
		index = index + 1
		if self._initTab == tabList[tab].callback then
			isHaveTab = true
		end
	end

	for i = 1, #tabIndex do
		if tabIndex[i] == 3 then
			if app.unlock:checkLock("UNLOCK_UNION", false) and remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
				addTab(tabIndex[i])
			end
		elseif tabIndex[i] == 5 then
			if app.unlock:checkLock("UNLOCK_BLACKROCK", false) then
				addTab(tabIndex[i])
			end
		elseif tabIndex[i] == 6 then
			if self._isInBlackRock or self._isInUnion then
				addTab(tabIndex[i])
			elseif remote.silvesArena:checkUnlock() and remote.silvesArena:checkCanChat() and remote.silvesArena:getCompleteTeam() then
				addTab(tabIndex[i])
			end
		elseif tabIndex[i] == 7 then
			if app.unlock:checkLock("UNLOCK_FRIEND", false) then
				addTab(tabIndex[i])
			end
		elseif tabIndex[i] == 8 then
			if remote.silvesArena:checkUnlock() and remote.silvesArena:checkCanChat() then
				addTab(tabIndex[i])
			end
		else
			addTab(tabIndex[i])
		end
	end
	
	if isHaveTab == false then
		self._initTab = self:getOptions().initTab
	end
end

function QUIDialogChat:refreshPrivateChatList(maxChatter, resetPos)
	if not self._scrollViewP then 
		return nil
	end
	self._scrollViewP:clear(resetPos)

	self._privateChatWidget = {}

	local latestChatter = self:getLatestPrivateChats(maxChatter or 10)
	self._ccbOwner.tf_private_name:setString("")
	local index = 1
	local totalWidth = 0

	for k, v in ipairs(latestChatter) do
		local chatter = QUIWidgetPrivateChat.new({nickName = v.nickName, userId = v.channelId, avatar = v.avatar, championCount = v.championCount, parent = self})
		chatter:setScale(0.8)
		chatter:addEventListener(QUIWidgetPrivateChat.CLICK, handler(self, self._onPrivateChatterChanged))
		chatter:setPosition(ccp(totalWidth, -10))
		chatter:setHighlighted(self._currentChatter == v.channelId)
		chatter:setRedTip(self._data:getLastMessageReadTime(v.channelId) < v.stamp)

		self._scrollViewP:addItemBox(chatter)
		table.insert(self._privateChatWidget, {widget = chatter, channelId = v.channelId})

		totalWidth = totalWidth + chatter:getContentSize().width + 30
		index = index + 1

		if self._currentChatter == v.channelId then
			self._ccbOwner.tf_private_name:setString(v.nickName)
		end
	end

	for i = index, 5 do
		local chatter = QUIWidgetPrivateChat.new({})
		chatter:setScale(0.8)
		chatter:setPosition(ccp(totalWidth, 0))
		chatter:setRedTip(false)

		self._scrollViewP:addItemBox(chatter)

		totalWidth = totalWidth + chatter:getContentSize().width + 30
	end
	self._scrollViewP:setRect(0, self._ccbOwner.sheet_layoutP1:getContentSize().height, 0, totalWidth)
	
	return latestChatter
end

function QUIDialogChat:refreshTeamChatList()
	if self:safeCheck() == false then return end

	if self._inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
		if self._currentChannelId ~= self._data:teamSilvesChannelId() then
			return 
		end
	else
		if self._currentChannelId ~= self._data:teamChannelId() then
			return 
		end
	end
 
	self._ccbOwner.sheetP1:setVisible(true)
	self._teamChatWidget = {}

	local teamsInfo = remote.blackrock:getTeamInfo()
	if self._inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
		teamsInfo = remote.silvesArena:getMyCrossTeamInfo()
	end

	if teamsInfo == nil or next(teamsInfo) == nil then return end
	local totalWidth = 80

	for i = 1, 3 do
		if self._teamChatter[i] == nil then
			self._teamChatter[i] = QUIWidgetTeamChat.new({index = i})
			self._teamChatter[i]:setScale(0.8)
			self._teamChatter[i]:setPosition(ccp(totalWidth, -60))
			self._ccbOwner.node_team_client:addChild(self._teamChatter[i])
			totalWidth = totalWidth + 180
		end
		self._teamChatter[i]:setInfo(nil,nil,nil)
	end

	local index = 1
	if not q.isEmpty(teamsInfo.leader) then
		self._teamChatter[index]:setInfo(teamsInfo.leader,true,true)
		index = index + 1
	end

	if not q.isEmpty(teamsInfo.member1) then
		self._teamChatter[index]:setInfo(teamsInfo.member1,false,true)
		index = index + 1
	end

	if not q.isEmpty(teamsInfo.member2) then
		self._teamChatter[index]:setInfo(teamsInfo.member2,false,true)
	end
end

function QUIDialogChat:getLatestPrivateChatter()
	local latestChatters = self:getLatestPrivateChats(1)
	if latestChatters[1] then
		return latestChatters[1].channelId
	else
		return nil, nil
	end
end

-- Init all the private chatter and sort by last message
function QUIDialogChat:getLatestPrivateChats(maxChatter)
	local latestMsg = {}
	for k, v in pairs(self._data:getMsgAll()) do
		if k ~= self._data:globalChannelId() and k ~= self._data:unionChannelId() and k ~= self._data:privateChannelId() and 
			k ~= self._data:teamChannelId() and k ~= self._data:teamSilvesChannelId() and k ~= self._data:crossTeamChannelId() and k ~= self._data:teamInfoChannelId() and 
			k ~= self._data:userDynamicChannelId() then
				
			local avatar, nickName, championCount = self:getChatterAvatarNickName(k)
			table.insert(latestMsg, {channelId = k, avatar = avatar, nickName = nickName, championCount = championCount,
				-- stamp = math.max(self._data:getLastMessageSentTime(k), self._data:getLastMessageReceiveTime(k))})
				stamp = self._data:getLastMessageReceiveTime(k)})
		end
	end

	table.sort(latestMsg, function (x, y)
		return x.stamp > y.stamp
	end)

	local index = 1
	local latestChatter = {}
	local topChatter = self._initChatter and self._initChatter.userId or nil
	if topChatter then
		table.insert(latestChatter, {channelId = topChatter, avatar = self._initChatter.avatar, championCount = self._initChatter.championCount, nickName = self._initChatter.nickName, stamp = 0})
		index = index + 1
	end

	for k, v in ipairs(latestMsg) do
		if v.channelId ~= topChatter then
			if index > maxChatter then break end
			table.insert(latestChatter, {channelId = v.channelId, avatar = v.avatar, championCount = v.championCount, nickName = v.nickName, stamp = v.stamp})
			index = index + 1
		end
	end

	return latestChatter
end

-- ChanneId equals nickname in private channel
function QUIDialogChat:getChatterAvatarNickName(channelId)
	local avatar, nickName, championCount
	local stamp = 0
	-- First, check if this user has spoken in private channel and get the latest information
	if next(self._data:getMsgReceived(channelId)) then
		local misc = self._data:getMsgReceived(channelId)[#self._data:getMsgReceived(channelId)].misc
		stamp = self._data:getMsgReceived(channelId)[#self._data:getMsgReceived(channelId)].stamp
		avatar, nickName, championCount = misc.avatar, misc.nickName, misc.championCount
	end

	-- Second, check if this user has spoken in global channel
	for k, v in ipairs(self._data:getMsgReceived(self._data:globalChannelId())) do
		if v.from == channelId and v.stamp > stamp then
			avatar, nickName, championCount = v.misc.avatar, v.misc.nickName, v.misc.championCount
			stamp = v.stamp
		end
	end

	-- Thirdly, check if this user has spoken in union channel
	for k, v in ipairs(self._data:getMsgReceived(self._data:unionChannelId())) do
		if v.from == channelId and v.stamp > stamp then
			avatar, nickName, championCount = v.misc.avatar, v.misc.nickName, v.misc.championCount
			stamp = v.stamp
		end
	end

	-- If can't find corresponding information, get from sent message but not realtime
	if not nickName and next(self._data:getMsgSent(channelId)) then
		if self._data:getMsgSent(channelId)[#self._data:getMsgSent(channelId)].stamp > stamp then
			avatar, nickName, championCount = self._data:getMsgSent(channelId)[#self._data:getMsgSent(channelId)].avatar, self._data:getMsgSent(channelId)[#self._data:getMsgSent(channelId)].nickName, self._data:getMsgSent(channelId)[#self._data:getMsgSent(channelId)].championCount
		end
	end

	return avatar or -1, nickName or "", championCount
end

function QUIDialogChat:refresh()
	if self._currentChannelId == self._data:privateChannelId() then
		if self._currentChatter then
			self:updatePage(self._currentChatter,true,false)
			self:refreshPrivateChatList()
		end
	elseif self._currentChannelId == self._data:teamChannelId() or self._currentChannelId == self._data:teamSilvesChannelId() then
		self:updatePage(self._currentChannelId,false,true)
	else
		self:updatePage(self._currentChannelId,false,false)
	end
end

function QUIDialogChat:updatePage(channelId,private,isTeam)
	self._onBottom = true

	if self._chats ~= nil then
		for i = 1, #self._chats do
			self._chats[i] = nil
		end
	end
	self._chats = {}
	self:retrieveData(channelId, self._maxMessage)
	self._data:setLastMessageReadTime(channelId, q.OSTime())

	self._locked = false
	self:setLockState(false)
	self._ccbOwner.sysNode:setVisible(self._data:onlyReceiveMessage(channelId))
	self._ccbOwner.chatNode:setVisible(not self._data:onlyReceiveMessage(channelId))
	self._inputMsg:setVisible(not self._data:onlyReceiveMessage(channelId))
    self._ccbOwner.sheet_team:setVisible(self._data:teamChannelId() == self._currentChannelId or self._data:teamSilvesChannelId() == self._currentChannelId)
    self._ccbOwner.tf_system:setVisible(nil == self._currentChannelId)
    self._ccbOwner.tf_dynamic:setVisible(self._data:userDynamicChannelId() == self._currentChannelId)

	-- Send CD 
	if self._sendCDId then
		scheduler.unscheduleGlobal(self._sendCDId)
		self._sendCDId = nil
	end
	self._sendCDTime = self._CD - (q.OSTime() - self._data:getLastMessageSentTime(channelId))
	self._sendCDTime = math.max(0, math.min(self._sendCDTime, 10))
	if self._sendCDTime > 0 then
		self._sendCDId = scheduler.scheduleGlobal(handler(self, self._onSendCD), 1)
		makeNodeFromNormalToGray(self._ccbOwner.send)
		self._ccbOwner.sendButton:setEnabled(false)
		self._ccbOwner.buttonText:setString(tostring(self._sendCDTime) .. "秒")
	else
		makeNodeFromGrayToNormal(self._ccbOwner.send)
		self._ccbOwner.sendButton:setEnabled(true)
		self._ccbOwner.buttonText:setString("发送")
	end

	self:checkChannelRedTips()

	self:initScrollBar(private,isTeam)

end

function QUIDialogChat:setLockState(state)
	if state == nil then return end

	local lockColor = ccc3(157, 116, 77)
	local openColor = ccc3(255, 255, 255)
	if state == true then
		self._ccbOwner.tf_lock:setColor(lockColor)
		self._ccbOwner.tf_open:setColor(openColor)
		self._ccbOwner.sp_lock_state:setPositionX(-292)
	else
		self._ccbOwner.tf_lock:setColor(openColor)
		self._ccbOwner.tf_open:setColor(lockColor)
		self._ccbOwner.sp_lock_state:setPositionX(-334)

		self:initListView(self._currentChannelId == self._data:privateChannelId(),self._currentChannelId == self._data:teamChannelId())
	end
end

-- Chat dialog may receive data from more than one source. e.g. XMPP, System board
function QUIDialogChat:retrieveData(channelId, maxMessage)
	local index = 1
	for i = #self._data:getMsgAll(channelId), 1, -1 do
		local chat = {}
		chat.body = self._data:getMsgAll(channelId)[i]
		chat.read = true
		if channelId == CHANNEL_TYPE.TEAM_CHANNEL or channelId == CHANNEL_TYPE.TEAM_SILVES_CHANNEL or channelId == CHANNEL_TYPE.TEAM_CROSS_CHANNEL then

			if self._inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
				-- if self._currentChannelId == self._data:teamSilvesChannelId() then
				-- 	type = SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM
				-- elseif self._currentChannelId == self._data:crossTeamChannelId() then
				-- 	type = SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_GLOBAL
				-- end

				--- 需要判断组队信息
				table.insert(self._chats, chat)
			else
				if chat.body.stamp >= remote.blackrock:getJoinTeamTime() then
					table.insert(self._chats, chat)
				end
			end

		else
			table.insert(self._chats, chat)
		end

		index = index + 1
		if maxMessage and index > maxMessage then 
			break 
		end
	end 

	table.sort(self._chats, function (x, y)
		return x.body.stamp < y.body.stamp
	end)
end

function QUIDialogChat:checkPrivateChannelRedTips()
	local channels = {app:getServerChatData():privateChannelId(),app:getServerChatData():globalChannelId(),app:getServerChatData():unionChannelId()}

	for _,v in pairs(channels) do
		local lastReadTime = app:getServerChatData():getLastMessageReadTime(app:getServerChatData():privateChannelId())
		local lastOperationTime = math.max(app:getServerChatData():getLastMessageSentTime(app:getServerChatData():privateChannelId()), 
											app:getServerChatData():getLastMessageReceiveTime(app:getServerChatData():privateChannelId()))		
	end


	self._ccbOwner.private_tip:setVisible(lastReadTime < lastOperationTime)
end

function QUIDialogChat:checkChannelRedTips( )
	local channels = {app:getServerChatData():privateChannelId(),app:getServerChatData():globalChannelId(),app:getServerChatData():unionChannelId()}
	QKumo(channels)
	for _,v in pairs(channels) do
		local lastReadTime = app:getServerChatData():getLastMessageReadTime(v)
		local lastOperationTime = math.max(app:getServerChatData():getLastMessageSentTime(v), 
											app:getServerChatData():getLastMessageReceiveTime(v))
		if v == app:getServerChatData():privateChannelId() then 
			self._ccbOwner.private_tip:setVisible(lastReadTime < lastOperationTime)
		elseif v == app:getServerChatData():globalChannelId() then 		
			print("[QUIDialogChat:checkChannelRedTips()]", lastReadTime, lastOperationTime, app:getServerChatData():getLastMessageSentTime(v), app:getServerChatData():getLastMessageReceiveTime(v))
			self._ccbOwner.world_tip:setVisible(lastReadTime < lastOperationTime)
		elseif v == app:getServerChatData():unionChannelId() then 
			self._ccbOwner.union_tip:setVisible(lastReadTime < lastOperationTime)	
		end	
	end
end

--聊天禁言判定。包含提示语
function QUIDialogChat:checkForbiddenWords()
	local today_words_times = remote.user:getPropForKey("todayChatCount") or 0
	today_words_times = today_words_times + 1 -- 判定的是已发言次数 + 1次
	local roleVip = app.vipUtil:VIPLevel() or 0
	local roleLevel = remote.user.level or 0

    local limits = QStaticDatabase:sharedDatabase():getConfigurationValue("SPEAK_FORBID_AUTO")
    limits = string.split(limits, ";")

	local roleVipLimit = tonumber(limits[1]) or 0
	local roleLevelLimit = tonumber(limits[2])  or 40
	--限制条件 小于等于 x等级 且 vip小于等于x
	if roleVip <= roleVipLimit and roleLevel <= roleLevelLimit then

		local roleMaxWordsTimes = tonumber(limits[3]) or 50
		--超过当日最大聊天限制提示
		if today_words_times > roleMaxWordsTimes then
			local limit_lv= roleLevelLimit + 1
			local str_ = string.format("今日已达发言上限，%s级后可解除发言限制",tostring(limit_lv))
			app.tip:floatTip(str_, -100, 50)
			return true
		--即将超过聊天上线预提示
		elseif (today_words_times + tonumber(QUIDialogChat.LIMIT_TIMES_SECTION)) >= roleMaxWordsTimes then
			local times = roleMaxWordsTimes - today_words_times 
			local str_ = string.format("今日还可发送%s条消息",tostring(times))
			app.tip:floatTip(str_, -100, 50)	
			return false
		end
	end
	return false
end


function QUIDialogChat:_onMessage(chat, delayed)

	local bar = QUIWidgetChatBar.new()
	bar:addEventListener(QUIWidgetChatBar.CLOSE_DIALOG, handler(self, self._onTriggerClose))
	bar:setInfo(self._currentChannelId, chat.body.from, chat.body.to, chat.body.message, chat.body.stamp, chat.body.misc, true)
	chat.height = bar:getHeight()
	-- chat.x = 0
	-- chat.y = self._bottom
	-- self._bottom = self._bottom - chat.height
	chat.read = delayed or false
	table.insert(self._chats, chat)

	local private = false
	local isTeam = false
	if self._currentChannelId == self._data:privateChannelId() then
		private = true
	end
	if self._currentChannelId == self._data:teamChannelId() or self._currentChannelId == self._data:teamSilvesChannelId() then
		isTeam = true
	end

	self:initScrollBar(private,isTeam)
end

function QUIDialogChat:_onSilvesMessageReceived(event)
	local chatLists = event.chatInfoList
	if not chatLists then
		return
	end
	local chatHistory = {}
	local chatCount = 0
	for i,v in ipairs(chatLists) do
		chatCount = chatCount + 1
		local misc = self._data:parseMisc(v)
		if type(misc) == "table" then
			misc.seq = tonumber(misc.seq)
			misc.stamp = misc.seq
			if misc.uid == remote.user.userId then
				event.delayed = true
			end
			if misc.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_GLOBAL then
				event.channelId = self._data:crossTeamChannelId()
			elseif misc.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM_SHARE then
				event.channelId = self._data:crossTeamChannelId()
	    		local num, unit = q.convertLargerNumber(misc.teamMinForce or 0)
	    		local forceLimit = num..(unit or "")
	    		misc.chat_content = "##n我的小队：##e"..misc.teamName.."##n邀请你来和我组成队伍。最低战力要求：##e"..forceLimit.."##n，快来和我一起争夺西尔维斯斗魂场的冠军吧～"
			elseif misc.type == SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM then
				event.channelId = self._data:teamSilvesChannelId()
			end
		-- 模拟队伍加载
		-- event.channelId = self._data:crossTeamChannelId()
		-- misc.type = SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM_SHARE
		-- misc.teamId = "02de0395-8be8-4b11-a6f2-7415ca6f6ed7"
			table.insert(chatHistory,misc)
		end
	end

	if chatCount >= 2 then
		table.sort(chatHistory,function ( a ,b )
			return a.seq < b.seq
		end)
	end

	for i,misc in ipairs(chatHistory) do
		local chat = {}
		chat.body = {from = misc.uid, stamp = misc.seq, misc = misc, message = misc.chat_content}
		if misc.uid == remote.user.userId then
			chat.body.to = misc.uid
			chat.body.from = nil
		end

		if self._data:_onSilvesTeamMessageIsNew(event.channelId, misc) then
			self._data:_onSilvesTeamMessageReceived(event.channelId,chat.body.to, chat.body.from, misc.nickName, misc.chat_content, misc.seq, misc)
			self._data:setLastMessageReadTime(event.channelId, q.OSTime())
			
			if event.channelId == self._currentChannelId then
				self:_onMessage(chat, event.delayed)
				remote.silvesArena:modifyNewMessageState(false)
			end
		end

	end
end

function QUIDialogChat:_onMessageReceived(event)
	self:checkChannelRedTips()

	if event.channelId == nil then
	else
		if event.channelId ~= self._currentChannelId then return end
	end
	-- if event.channelId ~= self._currentChannelId then return end
	
	local chat = {}
	-- In private channel, refresh list but don't show content if it's not the target chatter
	if self._currentChannelId == self._data:privateChannelId() then
		self._currentChatter = not self._currentChatter and event.from or self._currentChatter
		if event.from ~= self._currentChatter then 
			self:refreshPrivateChatList(QUIDialogChat.MAX_CHATTER)
			return
		else
			self._data:setLastMessageReadTime(self._currentChatter, q.OSTime())
			self:checkChannelRedTips()
			self:refreshPrivateChatList(QUIDialogChat.MAX_CHATTER)
		end			
	elseif self._currentChannelId == self._data:teamChannelId() then
		if event.from == remote.user.userId then
			return
		end
		self._data:setLastMessageReadTime(event.channelId, q.OSTime())
	elseif self._currentChannelId == self._data:teamSilvesChannelId() or self._currentChannelId == self._data:crossTeamChannelId() then

	else
		self._data:setLastMessageReadTime(event.channelId, q.OSTime())
	end	

	if self._currentChannelId == self._data:teamSilvesChannelId() or self._currentChannelId == self._data:crossTeamChannelId()  then
	else
		chat.body = {from = event.from, message = event.message, stamp = event.stamp, misc = event.misc}
	end

	self:_onMessage(chat, event.delayed)
end

function QUIDialogChat:_onMessageSent(event)
	if event.channelId ~= self._currentChannelId then return end

	-- In private channel, refresh list but don't show content if it's not the target chatter
	if self._currentChannelId == self._data:privateChannelId() then
		self:refreshPrivateChatList(QUIDialogChat.MAX_CHATTER)		
	end	

	local chat = {}
	chat.body = {to = event.to, message = event.message, stamp = event.stamp, misc = event.misc}
	self:_onMessage(chat, false)

end

function QUIDialogChat:onEdit(event, editbox)
    if event == "began" then

    elseif event == "changed" then
        if device.platform == "android" or device.platform == "windows" then
			local msg = self._inputMsg:getText()
            msg = QReplaceEmoji(msg)
	        self._inputMsg:setText(msg)
        end
    elseif event == "ended" then
        if device.platform == "android" or device.platform == "windows" then
			local msg = self._inputMsg:getText()
            msg = QReplaceEmoji(msg)
	        self._inputMsg:setText(msg)
        end
    elseif event == "return" then
        -- 从输入框返回
    elseif event == "returnDone" then
        if device.platform == "ios" then
			local msg = self._inputMsg:getText()
            msg = QReplaceEmoji(msg)
	        self._inputMsg:setText(msg)
	    end
    end
end

function QUIDialogChat:_onTriggerSend(event)
	if q.buttonEventShadow(event, self._ccbOwner.sendButton) == false then return end

	if not self._isHaveUnion then return end

	local msg = self._inputMsg:getText()

	if msg == nil or msg == "" then
		app.tip:floatTip(QUIDialogChat.NO_INPUT_ERROR, -100, 50)
		return
	end


	if app.funny ~= nil then
		msg = app.funny:run(msg)
		if msg == "" then
			self._inputMsg:setText("")
			return
		end
	end

	if self._inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES and (self._currentChannelId == self._data:teamSilvesChannelId() or self._currentChannelId == self._data:crossTeamChannelId()) then
		if not remote.silvesArena:getCompleteTeam() and self._currentChannelId == self._data:teamSilvesChannelId() then
			app.tip:floatTip(QUIDialogChat.NO_ROOM_ERROR, -100, 50)
			return
		end
	else
		if not self._data:canSendMessage(self._currentChannelId) then
			app.tip:floatTip(QUIDialogChat.NO_ROOM_ERROR, -100, 50)
			return
		end
	end
	if self._currentChannelId == self._data:privateChannelId() and self._currentChatter == nil then
		app.tip:floatTip(QUIDialogChat.NO_CHATTER_ERROR, -100, 50)
		return
	end
	if not app.unlock:checkLock("UNLOCK_CHAT", false) then
		local config = app.unlock:getConfigByKey("UNLOCK_CHAT")
		app.unlock:tipsDungeon(config, config.vip_level) 
		return
	end
	if not self._data:messageValid(msg, self._currentChannelId) then
		app.tip:floatTip("包含非法字符无法发送！", -100, 50)
		return
	end

	--禁言机制判定
	if self:checkForbiddenWords() then
		return 
	end

    if self._currentChannelId == CHANNEL_TYPE.GLOBAL_CHANNEL then
        msg = app:getServerChatData():checkMessageLength(msg)
    end

	local nickName, avatar, championCount = self:getChatterInfo(self._currentChatter)
	if ((self._isMain and not self._isInUnion) or self._inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES) and (self._currentChannelId == self._data:teamSilvesChannelId() or 
		self._currentChannelId == self._data:crossTeamChannelId()) then
		-- type = 1; //聊天类型 1是跨服 2是队伍分享 3组队聊天
    	-- SILVERS_ARENA_GLOBAL = 1; // 1是跨服
    	-- SILVERS_ARENA_TEAM_SHARE = 2; // 2是队伍分享
    	-- SILVERS_ARENA_TEAM = 3; // 3组队聊天
		local type = nil
		if self._currentChannelId == self._data:teamSilvesChannelId() then
			type = SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_TEAM
		elseif self._currentChannelId == self._data:crossTeamChannelId() then
			type = SILVES_ARENA_CHAT_TYPE.SILVERS_ARENA_GLOBAL
		end
		if not type then
			return
		end
		
		remote.silvesArena:silvesArenaChatRequest(type, msg, function ( data )
			if self:safeCheck() then
				self._initChatter = nil
				self._inputMsg:setText("")

				self._data:saveSendTimeInfo(self._currentChannelId, userId)

				local currentChannelId = (self._currentChannelId == self._data:privateChannelId()) and self._currentChatter or self._currentChannelId
				if self._currentChannelId == self._data:teamSilvesChannelId() then
					-- self:updatePage(currentChannelId,false,true)
				elseif self._currentChannelId == self._data:crossTeamChannelId() then
					-- self:updatePage(currentChannelId,false,false)
				end

			end
		end)
	else
		print("self._currentChannelId=",self._currentChannelId)
		self._data:sendMessage(msg, self._currentChannelId, self._currentChatter, nickName, avatar, nil, function (code)
			if code == 0 then
				self._initChatter = nil
				self._inputMsg:setText("")
	
				local currentChannelId = (self._currentChannelId == self._data:privateChannelId()) and self._currentChatter or self._currentChannelId
				if self._currentChannelId == self._data:teamChannelId() then
					self:updatePage(currentChannelId,false,true)
				elseif self._currentChannelId == self._data:privateChannelId() then
					self:updatePage(currentChannelId,true,false)
				else
					self:updatePage(currentChannelId,false,false)
				end
			else
				local errorCode = QStaticDatabase:sharedDatabase():getErrorCode(code)
				local errorStr = errorCode.desc or code
				app.tip:floatTip(errorStr, -100, 50)
			end
		end)
	end

end

function QUIDialogChat:_onTriggerBulletin(force )
  	app.sound:playSound("common_others")

	if self._currentChannelId == nil and force ~= true then return end
	self:showChatWithoutUnion()

	self._chatDataProxy:removeAllEventListeners()
  	self._data = app:getBulletinData()
  	self._data:setMaxCount(20)
	self._chatDataProxy = cc.EventProxy.new(self._data)
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))
  	
	self._CD = QUIDialogChat.SEND_CD
	self._currentChannelId = nil
	self._currentChannelType = nil
	self._currentChatter = nil
	self._maxMessage = self._data:getMaxCount()
	lastClosedTab = "onTriggerBulletin"
	
	self:setTabSelectState()
	self._initChatter = nil
	self:updatePage(self._currentChannelId,false,false)
	self:setOptions({initTab = "onTriggerBulletin", effectInName = "showDialogLeftSmooth", effectOutName = "hideDialogLeftSmooth"})
	-- app:getNavigationManager():getController(app.middleLayer):setDialogOptions({initTab = "onTriggerBulletin", effectInName = "showDialogLeftSmooth", effectOutName = "hideDialogLeftSmooth"})
end

function QUIDialogChat:_onTriggerGlobal(force)
	QUIDialogChat.NOT_AUTHORIZED = "战队等级%d级后才能在世界频道发言"
	app.sound:playSound("common_others")

	if self._currentChannelId == self._data:globalChannelId() and force ~= true then return end
	self:showChatWithoutUnion()
 	
	self._chatDataProxy:removeAllEventListeners()
  	self._data = app:getServerChatData() -- app:getXMPPData() 
  	self._data:setMaxCount(QUIDialogChat.MAX_MESSAGE)
	self._chatDataProxy = cc.EventProxy.new(self._data)
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_SENT, handler(self, self._onMessageSent))

	self._CD = QUIDialogChat.SEND_CD
	self._unlockLevel = app.unlock:getConfigByKey("UNLOCK_CHAT").team_level
	self._currentChannelId = self._data:globalChannelId()
	self._currentChannelType = 1
	self._currentChatter = nil
	self._maxMessage = self._data:getMaxCount()
	lastClosedTab = "onTriggerGlobal"

	self:setTabSelectState()
	self._initChatter = nil
	self:updatePage(self._currentChannelId,false,false)
	self:setOptions({initTab = "onTriggerGlobal", effectInName = "showDialogLeftSmooth", effectOutName = "hideDialogLeftSmooth"})
	-- app:getNavigationManager():getController(app.middleLayer):setDialogOptions({initTab = "onTriggerGlobal", effectInName = "showDialogLeftSmooth", effectOutName = "hideDialogLeftSmooth"})
end

function QUIDialogChat:_onTriggerUnion(force)  	
  	app.sound:playSound("common_others")

	if self._currentChannelId == self._data:unionChannelId() and force ~= true then return end
  	
	self._chatDataProxy:removeAllEventListeners()
  	self._data = app:getServerChatData() -- app:getXMPPData() 
  	self._data:setMaxCount(20)
	self._chatDataProxy = cc.EventProxy.new(self._data)
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_SENT, handler(self, self._onMessageSent))

	self._CD = 0
	self._unlockLevel = 1
	self._currentChannelId = self._data:unionChannelId()
	self._currentChannelType = 2
	self._currentChatter = nil
	self._maxMessage = self._data:getMaxCount()
	lastClosedTab = "onTriggerUnion"

	self:setTabSelectState()
	self._initChatter = nil
	self:updatePage(self._currentChannelId,false,false)
	if remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
		self._ccbOwner.gotoUnion:setVisible(false)
		self:showChatWithoutUnion()
	else
		self._ccbOwner.gotoUnion:setVisible(true)
		self:hideChatWithoutUnion()
	end
	self:setOptions({initTab = "onTriggerUnion", effectInName = "showDialogLeftSmooth", effectOutName = "hideDialogLeftSmooth"})
	-- app:getNavigationManager():getController(app.middleLayer):setDialogOptions({initTab = "onTriggerUnion", effectInName = "showDialogLeftSmooth", effectOutName = "hideDialogLeftSmooth"})
end

function QUIDialogChat:_onTriggerGotoUnion( ... )
	-- body
	print("go to union")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnion", options = {initButton = "onTriggerJoin"}})

end

function QUIDialogChat:_onTriggerPrivate(force)  	
	QUIDialogChat.NOT_AUTHORIZED = "战队等级%d级后才能在私聊频道发言"
  	app.sound:playSound("common_others")
	
	if self._currentChannelId == self._data:privateChannelId() and force ~= true then return end
	self:showChatWithoutUnion()
  	
	self._chatDataProxy:removeAllEventListeners()
  	self._data = app:getServerChatData() -- app:getXMPPData() 
  	self._data:setMaxCount(10)
	self._chatDataProxy = cc.EventProxy.new(self._data)
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_SENT, handler(self, self._onMessageSent))

	self._CD = 0
	self._unlockLevel = app.unlock:getConfigByKey("UNLOCK_CHAT").team_level
	self._currentChannelId = self._data:privateChannelId()
	self._currentChannelType = 3
	self._maxMessage = self._data:getMaxCount()
	self._currentChatter = self:getLatestPrivateChatter()
	lastClosedTab = "onTriggerPrivate"

	self:setTabSelectState()
	self:updatePage(self._currentChatter or QUIDialogChat.NO_PRIVATE_CHATTER,true,false)
	self:refreshPrivateChatList(QUIDialogChat.MAX_CHATTER)
	self:setOptions({initTab = "onTriggerPrivate", effectInName = "showDialogLeftSmooth", effectOutName = "hideDialogLeftSmooth"})

	-- app:getNavigationManager():getController(app.middleLayer):setDialogOptions({initTab = "onTriggerPrivate", effectInName = "showDialogLeftSmooth", effectOutName = "hideDialogLeftSmooth"})
end

function QUIDialogChat:_onTriggerTeam()
  	app.sound:playSound("common_others")

	if self._inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
		-- 	关闭新信息提示
		remote.silvesArena:modifyNewMessageState(false)
		self._ccbOwner.team_tip:setVisible(false)
	else
		-- 感觉可以不要，不知道为什么前面人没有删除
		if self._currentChannelId == self._data:teamChannelId() and force ~= true then return end
	end
	self:showChatWithoutUnion()

	self._chatDataProxy:removeAllEventListeners()
  	self._data = app:getServerChatData() -- app:getXMPPData() 
  	self._data:setMaxCount(20)

	if self._inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
		self._currentChannelId = self._data:teamSilvesChannelId()
		self._currentChannelType = 7
	else
		self._chatDataProxy = cc.EventProxy.new(self._data)
    	self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))
    	self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_SENT, handler(self, self._onMessageSent))

		self._currentChannelId = self._data:teamChannelId()
		self._currentChannelType = 4
	end

	self._CD = 0
	self._unlockLevel = 1
	self._maxMessage = self._data:getMaxCount()

	self:setTabSelectState()
	self._initChatter = nil
	self:updatePage(self._currentChannelId,false,true)
	self:refreshTeamChatList()
	lastClosedTab = "onTriggerTeam"
end

function QUIDialogChat:_onTriggerCrossTeam()
  	app.sound:playSound("common_others")

	if self._inChannelState == CHAT_CHANNEL_INTYPE.CHANNEL_IN_SILVES then
	else
		-- 感觉可以不要，不知道为什么前面人没有删除
		if self._currentChannelId == self._data:teamChannelId() and force ~= true then return end
	end
	self:showChatWithoutUnion()

	self._chatDataProxy:removeAllEventListeners()
  	self._data = app:getServerChatData() -- app:getXMPPData() 
  	self._data:setMaxCount(20)

	self._currentChannelId = self._data:crossTeamChannelId()
	self._currentChannelType = 8

	self._CD = 0
	self._unlockLevel = 1
	self._maxMessage = self._data:getMaxCount()

	self:setTabSelectState()
	self._initChatter = nil
	self:updatePage(self._currentChannelId,false,false)
	lastClosedTab = "onTriggerCrossTeam"
end

function QUIDialogChat:_onTriggerTeamInfo()
  	app.sound:playSound("common_others")

	if self._currentChannelId == self._data:teamInfoChannelId() and force ~= true then return end
	self:showChatWithoutUnion()

	self._chatDataProxy:removeAllEventListeners()
  	self._data = app:getServerChatData() -- app:getXMPPData() 
  	self._data:setMaxCount(20)
	self._chatDataProxy = cc.EventProxy.new(self._data)
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_SENT, handler(self, self._onMessageSent))

	self._CD = 0
	self._unlockLevel = 1
	self._currentChannelId = self._data:teamInfoChannelId()
	self._currentChannelType = 4
	self._maxMessage = self._data:getMaxCount()

	self:setTabSelectState()
	self._initChatter = nil
	self:updatePage(self._currentChannelId,false,false)
	lastClosedTab = "onTriggerTeamInfo"
end

function QUIDialogChat:_onTriggerDynamic()
  	app.sound:playSound("common_others")

	if self._currentChannelId == self._data:userDynamicChannelId() and force ~= true then return end
	self:showChatWithoutUnion()

	self._chatDataProxy:removeAllEventListeners()
  	self._data = app:getServerChatData() -- app:getXMPPData() 
  	self._data:setMaxCount(20)
	self._chatDataProxy = cc.EventProxy.new(self._data)
    self._chatDataProxy:addEventListener(QChatData.NEW_MESSAGE_RECEIVED, handler(self, self._onMessageReceived))

	self._CD = 0
	self._unlockLevel = 1
	self._currentChannelId = self._data:userDynamicChannelId()
	self._currentChannelType = nil
	self._maxMessage = self._data:getMaxCount()

	self:setTabSelectState()
	self._initChatter = nil
	self:updatePage(self._currentChannelId,false,false)

	lastClosedTab = "onTriggerDynamic"
end

function QUIDialogChat:setTabSelectState()
	local systeamState = self._currentChannelId == nil
	self._ccbOwner.tabSys:setEnabled(not systeamState)
	self._ccbOwner.tabSys:setHighlighted(systeamState)

	local unionState = self._currentChannelId== self._data:unionChannelId()
	self._ccbOwner.tabUnion:setEnabled(not unionState)
	self._ccbOwner.tabUnion:setHighlighted(unionState)

	local worldState = self._currentChannelId == self._data:globalChannelId()
	self._ccbOwner.tabWorld:setEnabled(not worldState)
	self._ccbOwner.tabWorld:setHighlighted(worldState)

	local privateState = self._currentChannelId == self._data:privateChannelId()
	self._ccbOwner.tabPrivate:setEnabled(not privateState)
	self._ccbOwner.tabPrivate:setHighlighted(privateState)

	local teamState = self._currentChannelId == self._data:teamChannelId() or self._currentChannelId == self._data:teamSilvesChannelId()
	self._ccbOwner.tabTeam:setEnabled(not teamState)
	self._ccbOwner.tabTeam:setHighlighted(teamState)

	local teamInfoState = self._currentChannelId == self._data:teamInfoChannelId()
	self._ccbOwner.tabTeamInfo:setEnabled(not teamInfoState)
	self._ccbOwner.tabTeamInfo:setHighlighted(teamInfoState)

	local dynamicState = self._currentChannelId == self._data:userDynamicChannelId()
	self._ccbOwner.tabDynamic:setEnabled(not dynamicState)
	self._ccbOwner.tabDynamic:setHighlighted(dynamicState)

	local crossTeamInfoState = self._currentChannelId == self._data:crossTeamChannelId()
	self._ccbOwner.tabCrossTeam:setEnabled(not crossTeamInfoState)
	self._ccbOwner.tabCrossTeam:setHighlighted(crossTeamInfoState)

	self._ccbOwner.face_node:setVisible(false)
end

function QUIDialogChat:_onTriggerLock(eventType)
	if tonumber(eventType) == CCControlEventTouchUpInside then
		self._locked = not self._locked
		self:setLockState(self._locked == true)
		-- if not self._locked then
		-- 	self._scrollView:stopAllActions()
		-- 	self._scrollView:runToBottom(true)
		-- end
	else
		self:setLockState(self._locked == true)
	end
end

function QUIDialogChat:_onTriggerMood(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_mood) == false then return end
	-- app.tip:floatTip("敬请期待", -100, 50)
	local isShow = self._ccbOwner.face_node:isVisible()
	self._ccbOwner.face_node:setVisible(not isShow)

end

function QUIDialogChat:_clickChooseFace(event)
	if event.index == nil then return end
	local msg = self._inputMsg:getText()
	local faceStr = QColorLabel.FACE_NAME[event.index] or ""
    local newMsg = msg..faceStr
    self._inputMsg:setText(newMsg)
end
function QUIDialogChat:_onSendCD()
	self._sendCDTime = self._sendCDTime - 1
	self._ccbOwner.buttonText:setString(tostring(self._sendCDTime) .. "秒")
	if self._sendCDTime == 0 then
		makeNodeFromGrayToNormal(self._ccbOwner.send)
		self._ccbOwner.sendButton:setEnabled(true)
		self._ccbOwner.buttonText:setString("发送")
		scheduler.unscheduleGlobal(self._sendCDId)
		self._sendCDId = nil
	end
end

function QUIDialogChat:_onPScrollViewBegan()
	self._isPMoving = false
end

function QUIDialogChat:_onPScrollViewMoving( ... )
	self._isPMoving = true
end

function QUIDialogChat:_onPrivateChatterChanged(event)
	if self._currentChatter == event.userId then return end

	self._currentChatter = event.userId

	for k, v in ipairs(self._privateChatWidget) do
		v.widget:setHighlighted(v.channelId == self._currentChatter)
	end

	self:updatePage(self._currentChatter,true,false)
	self:refreshPrivateChatList(QUIDialogChat.MAX_CHATTER, false)
end

function QUIDialogChat:_onPrivateChatterRemove(event)
	if self._currentChatter == nil then return end
	app:alert({content="是否移除该好友的私聊记录？", title="系统提示", 
        callback=function(state)
            if state == ALERT_TYPE.CONFIRM then
               self._data:deleteMessage(self._currentChatter)
				-- if self._initChatter == self._currentChatter then
					self._initChatter = nil
					self:_onTriggerPrivate(true)
				-- else
				-- 	self:refreshPrivateChatList(QUIDialogChat.MAX_CHATTER, false)
				-- end
            end
        end,
        callBack=function(state)
            
        end, confirmText = "确 定", isAnimation = false}, false, true)	
end

function QUIDialogChat:_onPrivateAddblack(event)
	if self._currentChatter == nil then return end
	if not app.unlock:getUnlockFriend() then
		app.tip:floatTip("魂师大人，您的好友功能尚未开启，暂时无法使用该功能")
		return
	end
	if remote.friend:checkIsBlackedByUserId(self._currentChatter) == true then
		app.tip:floatTip("该玩家已经在您的黑名单中")
		return
	end
	app:alert({content="拉入黑名单？",title="系统提示",callback=function (state)
		if state == ALERT_TYPE.CONFIRM then
			remote.friend:apiUserDeleteFriendRequest(self._currentChatter, true)
			self._data:deleteMessage(self._currentChatter,self._currentChatter)
			self._initChatter = nil
			self:_onTriggerPrivate(true)			
		end
	end}, false)
end

function QUIDialogChat:getChatterInfo(userId)
	for k, v in ipairs(self._privateChatWidget or {}) do
		if v.widget:getUserId() == userId then
			return v.widget:getNickName(), v.widget:getAvatar(), v.widget:getChampionCount()
		end
	end

	return "", -1
end

function QUIDialogChat:_onFriendDetailInfo(event)
	if event.type == 1 then
		self._initChatter = {userId = event.userId, avatar = event.avatar, nickName = event.nickName}
		self:_onTriggerPrivate(true)
	elseif event.type == 2 then
		self:refresh()
	end
end

function QUIDialogChat:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogChat:viewAnimationOutHandler()
	if self._closeCallback then
		self._closeCallback()
	end

    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogChat:_backClickHandler()
    self:_onTriggerClose()
end

return QUIDialogChat