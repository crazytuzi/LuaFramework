--
-- Author: wkwang
-- Date: 2014-09-22 17:01:05
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFriend = class("QUIDialogFriend", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
-- local QScrollContain = import("..QScrollContain")
local QUIWidgetFriendCell = import("..widgets.QUIWidgetFriendCell")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")

function QUIDialogFriend:ctor(options)
    local ccbFile = "ccb/Dialog_Friend_liebiao.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerFriend", callback = handler(self, QUIDialogFriend._onTriggerFriend)},
        {ccbCallbackName = "onTriggerSuggest", callback = handler(self, QUIDialogFriend._onTriggerSuggest)},
        {ccbCallbackName = "onTriggerBlacklist", callback = handler(self, QUIDialogFriend._onTriggerBlacklist)},
        {ccbCallbackName = "onTriggerApply", callback = handler(self, QUIDialogFriend._onTriggerApply)},
        {ccbCallbackName = "onTriggerAdd", callback = handler(self, QUIDialogFriend._onTriggerAdd)},
        {ccbCallbackName = "onTriggerGet", callback = handler(self, QUIDialogFriend._onTriggerGet)},
        {ccbCallbackName = "onTriggerSend", callback = handler(self, QUIDialogFriend._onTriggerSend)},
        {ccbCallbackName = "onTriggerChange", callback = handler(self, QUIDialogFriend._onTriggerChange)},
        {ccbCallbackName = "onTriggerBattle", callback = handler(self, QUIDialogFriend._onTriggerBattle)},
    }
    QUIDialogFriend.super.ctor(self, ccbFile, callBacks, options)
	app:getNavigationManager():getController(app.mainUILayer):getTopPage():setManyUIVisible()
    -- self.isAnimation = true
	self._ccbOwner.friend_tips:setVisible(remote.friend:checkFriendCanGetEnergy())
	self._ccbOwner.apply_tips:setVisible(remote.friend:checkFriendHasApply())
    if options == nil then
    	self:setOptions({})
    end

    self._posIndex = 0
    self._size = cc.size(672, 120)
    self._data = {}
    self:initPage()

    local options = self:getOptions()
    if options.typeName ~= nil then
    	self:selectTab(options.typeName)
    else
    	local friendList = remote.friend:getFriendList()
    	if #friendList > 0 then
    		self:selectTab(remote.friend.TYPE_LIST_FRIEND)
    	else
    		self:selectTab(remote.friend.TYPE_LIST_SUGGEST)
    	end
    end
    
    self._ccbOwner.frame_tf_title:setString("好  友")

    remote.friend:requestList()
    self._ccbOwner.btn_battle:setVisible(ENABLE_LOCAL_NET_BATTLE)
end

function QUIDialogFriend:viewDidAppear()
    QUIDialogFriend.super.viewDidAppear(self)
    self._friendProxy = cc.EventProxy.new(remote.friend)
    self._friendProxy:addEventListener(remote.friend.EVENT_UPDATE_FRIEND, handler(self, self._onFriendUpdateHandler))
    self._friendProxy:addEventListener(remote.friend.EVENT_UPDATE_APPLY_FRIEND, handler(self, self._onApplyFriendUpdateHandler))
    self._friendProxy:addEventListener(remote.friend.EVENT_UPDATE_BLACK_FRIEND, handler(self, self._onBlackFriendUpdateHandler))
    self._friendProxy:addEventListener(remote.friend.EVENT_UPDATE_SUGGEST_FRIEND, handler(self, self._onSuggestFriendUpdateHandler))
    self._friendProxy:addEventListener(remote.friend.EVENT_UPDATE_FRIEND_INFO, handler(self, self._onFriendInfoUpdateHandler))    
	self:addBackEvent()
end

function QUIDialogFriend:viewWillDisappear()
    QUIDialogFriend.super.viewWillDisappear(self)
    -- if self._cellContain ~= nil then
    -- 	local childs = self._cellContain:getAllChildren()
    -- 	for _,child in ipairs(childs) do
    -- 		child:removeAllEventListeners()
    -- 	end
    -- 	self._cellContain:disappear()
    -- 	self._cellContain = nil
    -- end
    if self._friendProxy ~= nil then
    	self._friendProxy:removeAllEventListeners()
    	self._friendProxy = nil
	end
	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
	self:removeBackEvent()
end

function QUIDialogFriend:initPage()
	self._ccbOwner.tf_tips:setString("")
    -- self._cellContain = QScrollContain.new({sheet = self._ccbOwner.content_sheet, sheet_layout = self._ccbOwner.content_sheet_layout, 
    -- 	direction = QScrollContain.directionY, renderFun = handler(self, self._onFrameHandler)})
    -- self._cellCaches = {}
    self:_initListView()
    self:showInfo()
end

function QUIDialogFriend:showInfo()
	local friendCount = table.nums(remote.friend:getFriendList())
	self._ccbOwner.tf_friend_count:setString(string.format("%s/%s", friendCount, remote.friend:getMaxCount()))
	self._friendCtlInfo = remote.friend:getFriendCtlInfo()
	self._ccbOwner.tf_engery:setString(string.format("%s/%s", self._friendCtlInfo.today_get_gift_times, remote.friend:getMaxEnergy()))
	local time = q.serverTime()
	local lastTime = self._friendCtlInfo.last_get_friend_suggest_last_time/1000
	if lastTime > 0 and time - lastTime < remote.friend:getRefreshTime() then
		local timeFun = function ()
			local time = q.serverTime()
			if time - lastTime > remote.friend:getRefreshTime() then
				if self._schedulerHandler ~= nil then
					scheduler.unscheduleGlobal(self._schedulerHandler)
					self._schedulerHandler = nil
				end
				self._ccbOwner.tf_change:setString("换一批")
				makeNodeFromGrayToNormal(self._ccbOwner.btn_change)
				self._ccbOwner.btn_change_btn:setEnabled(true)
			else
				self._ccbOwner.tf_change:setString(math.ceil(remote.friend:getRefreshTime() - (time - lastTime)).."秒")
				makeNodeFromNormalToGray(self._ccbOwner.btn_change)
				self._ccbOwner.btn_change_btn:setEnabled(false)
			end
		end
		timeFun()
		if self._schedulerHandler ~= nil then
			scheduler.unscheduleGlobal(self._schedulerHandler)
			self._schedulerHandler = nil
		end
		self._schedulerHandler = scheduler.scheduleGlobal(timeFun,1)
	end
	-- self._ccbOwner.btn_change:setVisible(false)
end

function QUIDialogFriend:selectTab(typeName, isReset)
	-- if self._typeName == typeName then return end
	local isReset = isReset or (self._typeName ~= typeName)
	self:resetAllTab()
	self._typeName = typeName
	self:getOptions().typeName = typeName
	self._data = {}
	if typeName == remote.friend.TYPE_LIST_FRIEND then
		self._ccbOwner.tab_friend:setEnabled(false)
		self._ccbOwner.tab_friend:setHighlighted(true)
		self._ccbOwner.tab_friend_select:setVisible(true)
		self._list = remote.friend:getFriendList()
		self._ccbOwner.btn_send:setVisible(true)
		self._ccbOwner.btn_get:setVisible(true)
    	self:showInfo()
	elseif typeName == remote.friend.TYPE_LIST_SUGGEST then
		self._ccbOwner.tab_suggest:setEnabled(false)
		self._ccbOwner.tab_suggest:setHighlighted(true)
		self._ccbOwner.tab_suggest_select:setVisible(true)
		self._list = remote.friend:getSuggestFriendList()
		self._ccbOwner.btn_change:setVisible(true)	
		self._ccbOwner.btn_add:setVisible(true)
	elseif typeName == remote.friend.TYPE_LIST_BLACKLIST then
		self._ccbOwner.tab_blacklist:setEnabled(false)
		self._ccbOwner.tab_blacklist:setHighlighted(true)
		self._ccbOwner.tab_blacklist_select:setVisible(true)
		self._list = remote.friend:getBlackFriendList()
	elseif typeName == remote.friend.TYPE_LIST_APPLY then
		self._ccbOwner.tab_apply:setEnabled(false)
		self._ccbOwner.tab_apply:setHighlighted(true)
		self._ccbOwner.tab_apply_select:setVisible(true)
		self._list = remote.friend:getApplyFriendList()
	end

	-- --回收frame
	-- if self._virtualFrames ~= nil then
	-- 	for _,frame in ipairs(self._virtualFrames) do
	-- 		if frame.widget ~= nil then
	-- 			table.insert(self._cellCaches, frame.widget)
	-- 			frame.widget = nil
	-- 		end
	-- 	end
	-- end
	-- self._virtualFrames = {}
	-- for _,value in ipairs(self._cellCaches) do
	-- 	value:setVisible(false)
	-- end
	if isReset == true then
		-- self._cellContain:moveTo(0,0,false)
		if self._listView then
			self._listView:clear()
			self._listView = nil
		end
		self._posIndex = 0
	end

	self._ccbOwner.node_empty:setVisible(false)
	-- local size = self._cellContain:getContentSize()
	-- size.height = 0
	if #self._list > 0 then
		for index,id in ipairs(self._list) do
			local value = remote.friend:getFriendInfoById(id)
			if value ~= nil then
				table.insert(self._data, value)
			end
		end
		-- size.height = #self._list * self._size.height
		-- self._cellContain:setContentSize(size.width, size.height)
		-- self:_onFrameHandler()
		self._ccbOwner.tf_tips:setString("")
	else
		self._data = {}
		self._ccbOwner.sp_top:setVisible(false)
		self._ccbOwner.sp_bottom:setVisible(false)
		if self._typeName == remote.friend.TYPE_LIST_FRIEND then
			self._ccbOwner.tf_tips:setString("好友多了，体力多，快去添加吧")
		elseif self._typeName == remote.friend.TYPE_LIST_SUGGEST then
			self._ccbOwner.tf_tips:setString("点一下“换一批”来找到更多的玩家加好友吧")
		elseif self._typeName == remote.friend.TYPE_LIST_BLACKLIST then
			self._ccbOwner.tf_tips:setString("当前没有玩家在您的黑名单")
		elseif self._typeName == remote.friend.TYPE_LIST_APPLY then
			self._ccbOwner.tf_tips:setString("还没有好友申请~或许可以去世界频道喊喊")
		end
		self._ccbOwner.node_empty:setVisible(true)
	end
	self:_initListView()
end

function QUIDialogFriend:_initListView()
	if self._listView == nil then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemCallBack),
            isVertical = true,
            ignoreCanDrag = true,
            enableShadow = true,
            spaceY = 0,
            headIndex = self._posIndex > 1 and self._posIndex - 1 or 0,
            totalNumber = #self._data
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._data, headIndex = self._posIndex > 1 and self._posIndex - 1 or 0 })
    end
end

function QUIDialogFriend:_renderItemCallBack(list, index, info)
    local isCacheNode = true
    local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetFriendCell.new()
        item:addEventListener(QUIWidgetFriendCell.EVENT_CLICK, handler(self, self._cellClickHandler))
        isCacheNode = false
    end
    item:setInfo(data, self._typeName,index)
    info.item = item
    info.size = item:getContentSize()
    -- list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
    list:registerBtnHandler(index, "btn_gift", "_onTriggerGift", nil, true)
    list:registerBtnHandler(index, "btn_get", "_onTriggerGet", nil, true)
    list:registerBtnHandler(index, "btn_add", "_onTriggerAdd", nil, true)
    list:registerBtnHandler(index, "btn_agree", "_onTriggerAgree", nil, true)
    list:registerBtnHandler(index, "btn_refuse", "_onTriggerRefuse", nil, true)
    list:registerBtnHandler(index, "btn_delete", "_onTriggerDelete", nil, true)

    return isCacheNode
end

function QUIDialogFriend:resetAllTab()
	self._ccbOwner.tab_friend:setEnabled(true)
	self._ccbOwner.tab_friend:setHighlighted(false)
	self._ccbOwner.tab_friend_select:setVisible(false)

	self._ccbOwner.tab_suggest:setEnabled(true)
	self._ccbOwner.tab_suggest:setHighlighted(false)
	self._ccbOwner.tab_suggest_select:setVisible(false)

	self._ccbOwner.tab_blacklist:setEnabled(true)
	self._ccbOwner.tab_blacklist:setHighlighted(false)
	self._ccbOwner.tab_blacklist_select:setVisible(false)

	self._ccbOwner.tab_apply:setEnabled(true)
	self._ccbOwner.tab_apply:setHighlighted(false)
	self._ccbOwner.tab_apply_select:setVisible(false)

	self._ccbOwner.btn_add:setVisible(false)
	self._ccbOwner.btn_send:setVisible(false)
	self._ccbOwner.btn_get:setVisible(false)
	self._ccbOwner.btn_change:setVisible(false)	

end

-- function QUIDialogFriend:_onFrameHandler()
-- 	local contentY = self._cellContain.content:getPositionY()
-- 	local sizeH = self._cellContain:getContentSize().height
-- 	local minValue = -(self._cellContain.size.height + self._size.height)
-- 	local maxValue = self._size.height
-- 	for _, frame in pairs(self._virtualFrames) do
-- 		local offsetY = frame.posY + contentY
-- 		if offsetY >= maxValue or offsetY <= minValue then  
-- 			self:_show(frame, false)
-- 		end
-- 	end
-- 	for _, frame in pairs(self._virtualFrames) do
-- 		local offsetY = frame.posY + contentY
-- 		if offsetY >= maxValue or offsetY <= minValue then  
-- 		else
-- 			self:_show(frame, true)
-- 		end
-- 	end
-- 	self._ccbOwner.sp_top:setVisible(contentY > 0)
-- 	self._ccbOwner.sp_bottom:setVisible((sizeH - contentY) > self._cellContain.size.height)
-- end

-- function QUIDialogFriend:_show(frame, isShow)
-- 	if frame.isShow == isShow then 
-- 		return 
-- 	end
-- 	frame.isShow = isShow
-- 	if isShow == false then
-- 		if frame.widget ~= nil then
-- 			self._cellCaches[#self._cellCaches+1] = frame.widget
-- 			frame.widget:setVisible(false)
-- 			frame.widget = nil
-- 		end
-- 	else
-- 		frame.widget = self:_getHeroFrames()
-- 		frame.widget:setVisible(true)
-- 		frame.widget:setPosition(ccp(0, frame.posY))
-- 		frame.widget:setInfo(frame.value, self._typeName)
-- 	end
-- end

-- function QUIDialogFriend:_getHeroFrames()
-- 	if self._cellCaches ~= nil and #self._cellCaches > 0 then
-- 		return table.remove(self._cellCaches)
-- 	else
-- 		local cell = QUIWidgetFriendCell.new()
-- 		cell:addEventListener(QUIWidgetFriendCell.EVENT_CLICK, handler(self, self._cellClickHandler))
-- 		cell:setVisible(false)
-- 		self._cellContain:addChild(cell)
-- 		return cell
-- 	end
-- end

--好友列表更新
function QUIDialogFriend:_onFriendUpdateHandler(event)
	if self._typeName == remote.friend.TYPE_LIST_FRIEND then
		self:selectTab(remote.friend.TYPE_LIST_FRIEND)
	end
	self._ccbOwner.friend_tips:setVisible(remote.friend:checkFriendCanGetEnergy())
	self._ccbOwner.apply_tips:setVisible(remote.friend:checkFriendHasApply())
end

--删除好友
-- function QUIDialogFriend:_onDeleteFriendUpdateHandler(event)
-- 	if self._typeName == remote.friend.TYPE_LIST_FRIEND then
-- 		self:selectTab(remote.friend.TYPE_LIST_FRIEND)
-- 	end
-- 	self._ccbOwner.friend_tips:setVisible(remote.friend:checkFriendCanGetEnergy())
-- 	self._ccbOwner.apply_tips:setVisible(remote.friend:checkFriendHasApply())
-- end

--好友申请列表更新
function QUIDialogFriend:_onApplyFriendUpdateHandler(event)
	if self._typeName == remote.friend.TYPE_LIST_APPLY then
		self:selectTab(remote.friend.TYPE_LIST_APPLY)
	end
	self._ccbOwner.apply_tips:setVisible(remote.friend:checkFriendHasApply())
end

--黑名单列表更新
function QUIDialogFriend:_onBlackFriendUpdateHandler(event)
	if self._typeName == remote.friend.TYPE_LIST_BLACKLIST then
		self:selectTab(remote.friend.TYPE_LIST_BLACKLIST)
	end
	self._ccbOwner.friend_tips:setVisible(remote.friend:checkFriendCanGetEnergy())
	self._ccbOwner.apply_tips:setVisible(remote.friend:checkFriendHasApply())
end

--推荐好友列表更新
function QUIDialogFriend:_onSuggestFriendUpdateHandler(event)
	if self._typeName == remote.friend.TYPE_LIST_SUGGEST then
		self:selectTab(remote.friend.TYPE_LIST_SUGGEST, event.isReset)
	end
end

--更新好友信息
function QUIDialogFriend:_onFriendInfoUpdateHandler(event)
	self:showInfo()
end

function QUIDialogFriend:_cellClickHandler(event)
	-- if self._cellContain.isMove == true then return end
	self._posIndex = event.posIndex or 0
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogFriendInfo", 
    	options = {info = event.info}}, {isPopCurrentDialog = false})
end

function QUIDialogFriend:_onTriggerFriend()
    app.sound:playSound("common_switch")
	self:selectTab(remote.friend.TYPE_LIST_FRIEND)
end

function QUIDialogFriend:_onTriggerSuggest()
    app.sound:playSound("common_switch")
	self:selectTab(remote.friend.TYPE_LIST_SUGGEST)
end

function QUIDialogFriend:_onTriggerBlacklist()
    app.sound:playSound("common_switch")
	self:selectTab(remote.friend.TYPE_LIST_BLACKLIST)
end

function QUIDialogFriend:_onTriggerApply()
    app.sound:playSound("common_switch")
	self:selectTab(remote.friend.TYPE_LIST_APPLY)
end

function QUIDialogFriend:_onTriggerAdd(event)
	if q.buttonEventShadow(event,self._ccbOwner.button_add) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionAnnouncement", 
        options = {type = QUIDialogUnionAnnouncement.TYPE_ADD_FRIEND, word = "", confirmCallback = function (word)
        	if #word > 0 then
        		if remote.friend:checkIsFriendByNickName(word) == true then
        			app.tip:floatTip("玩家已经在好友列表中！")
        			return
        		end
        		if remote.user.nickname == word then
        			app.tip:floatTip("不能添加自己为好友！")
        			return
        		end
        		remote.friend:apiUserApplyFriendRequest(nil,word,function ()
        			app.tip:floatTip("已经发送申请，等待批准！")
        		end)
            else
				app.tip:floatTip("请输入玩家名字！")
            end
        end}}, {isPopCurrentDialog = false})
end

--一键赠送
function QUIDialogFriend:_onTriggerSend(event)
	if q.buttonEventShadow(event,self._ccbOwner.button_send) == false then return end
    app.sound:playSound("common_small")
	local friendIds = {}
	for _,id in ipairs(self._list) do
		local friend = remote.friend:getFriendInfoById(id)
		if friend.alreadySendGift ~= true then
			table.insert(friendIds, friend.user_id)
		end
	end
	if #friendIds > 0 then
		remote.friend:apiUserSendAllFriendGiftRequest(false, function ()
			app.tip:floatTip("赠送成功~")
		end)
	else
		app.tip:floatTip("没有好友可以赠送！")
	end
end

function QUIDialogFriend:_onTriggerGet(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_get) == false then return end
    app.sound:playSound("common_small")
	local friendCtlInfo = remote.friend:getFriendCtlInfo()
	local count = math.floor((remote.friend:getMaxEnergy() - friendCtlInfo.today_get_gift_times)/FRIEND_GIFT_COUNT)
	if count > 0 then
		local friendIds = {}
		for _,id in ipairs(self._list) do
			if count == 0 then
				break
			end
			local friend = remote.friend:getFriendInfoById(id)
			if friend.alreadyGetGift == false and friend.existGift == true then
				table.insert(friendIds, friend.user_id)
				count = count - 1
			end
		end
		if #friendIds > 0 then
			remote.friend:apiUserGetFriendGiftRequest(friendIds, false, function ()
				app.tip:floatTip(string.format("成功领取%s点体力", #friendIds * FRIEND_GIFT_COUNT))
			end)
		else
			app.tip:floatTip("没有可领取的体力")
		end
	else
		app.tip:floatTip("今日领取好友体力已达上限！")
	end
end

function QUIDialogFriend:_onTriggerChange(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_change_btn) == false then return end
    app.sound:playSound("common_small")
	local time = q.serverTime()
	local lastTime = self._friendCtlInfo.last_get_friend_suggest_last_time/1000
	if time - lastTime < remote.friend:getRefreshTime() then
		return
	end
	remote.friend:requestSuggestList(true)
end

function QUIDialogFriend:_onTriggerBattle( event )
	if q.buttonEventShadow(event,self._ccbOwner.button_battle) == false then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogLocalBattle"}, {isPopCurrentDialog = false})
end

function QUIDialogFriend:onTriggerBackHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogFriend:onTriggerHomeHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogFriend