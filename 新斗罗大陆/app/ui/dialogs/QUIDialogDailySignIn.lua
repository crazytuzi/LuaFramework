local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDailySignIn = class("QUIDialogDailySignIn", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetDailySignInBox = import("..widgets.QUIWidgetDailySignInBox")
local QUIWidgetDialySignInStack = import("..widgets.QUIWidgetDialySignInStack")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QRemote = import("...models.QRemote")
local QStaticDatabase = import("...controllers.QStaticDatabase")
-- local QScrollView = import("...views.QScrollView")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QListView = import("...views.QListView")

QUIDialogDailySignIn.DAILY_TAB = "DAILY_TAB"
QUIDialogDailySignIn.DELUXE_TAB = "DELUXE_TAB"

function QUIDialogDailySignIn:ctor(options)
	local ccbFile = "ccb/Dialog_DailySignIn_New.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerDaily", callback = handler(self, self._onTriggerDaily)},
		{ccbCallbackName = "onTriggerDeluxe", callback = handler(self, self._onTriggerDeluxe)},
		{ccbCallbackName = "onTriggerClickGo", callback = handler(self, self._onTriggerClickGo)},
		{ccbCallbackName = "onTriggerClickReceive", callback = handler(self, self._onTriggerClickReceive)},
	}
	QUIDialogDailySignIn.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:showWithMainPage()
    page:setManyUIVisible()

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._selectTab = options.tab or QUIDialogDailySignIn.DAILY_TAB
	end

	-- self._ccbOwner.node_shadow_bottom:setVisible(true)
	-- self._ccbOwner.node_shadow_top:setVisible(false)

	--初始化累计签到
	self.stackSign = QUIWidgetDialySignInStack.new()
	self._ccbOwner.stack_node:addChild(self.stackSign)
    self.stackSign:addEventListener(QUIWidgetDialySignInStack.RECEIVE_SUCCEED, handler(self, self.signSuccess))
    local ccNode = CCLayer:create()
    ccNode:setNodeIsAutoBatchNode(false)
    self._ccbOwner.stack_node:addChild(ccNode)

	self.itemBox = {}
	self._awardsInfo = {}
	self._deluxeItemBoxs = {}
	self._reward = {}
	self._isFrist = true

	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	self._patchToken = configuration["BUQIAN_TOKEN"].value

	self:_setItemBox()

	self._ccbOwner.node_btn_deluxe:setVisible(ENABLE_DELUXE_SIGNIN)
	self._ccbOwner.title:setVisible(false)
end

function QUIDialogDailySignIn:viewDidAppear()
	QUIDialogDailySignIn.super.viewDidAppear(self)
	self:addBackEvent(true)

	self._isFrist = true
	self:selectTabs(self._selectTab)
	self:setBtnState()
	-- self:getNewDeluxeInfo()
	self:checkRedTip()

end

function QUIDialogDailySignIn:viewWillDisappear()
	QUIDialogDailySignIn.super.viewWillDisappear(self)
    if self.stackSign ~= nil then
        self.stackSign:removeAllEventListeners()
        self.stackSign = nil
    end

	if self._timeScheduler ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
	
end

function QUIDialogDailySignIn:getNewDeluxeInfo()
	remote.daily:deluxeCheckIn(function()
			if self:safeCheck() then
				self:setDeluxeItems()
				self:setBtnState()
				self:checkRedTip()
			end
		end)
end

function QUIDialogDailySignIn:selectTabs(tab)
	if self._selectTab == nil then return end
	self._selectTab = tab
	self:getOptions().tab = self._selectTab

	self._ccbOwner.btn_deluxe:setHighlighted(false)
	self._ccbOwner.btn_deluxe:setEnabled(true)
	self._ccbOwner.btn_daily:setHighlighted(false)
	self._ccbOwner.btn_daily:setEnabled(true)
	self._ccbOwner.tf_daily_name1:setVisible(false)
	self._ccbOwner.tf_deluxe_name1:setVisible(false)
	self._ccbOwner.state1:setVisible(false)
	self._ccbOwner.state2:setVisible(false)

	if self._selectTab == QUIDialogDailySignIn.DAILY_TAB then
		self._ccbOwner.state1:setVisible(true)
		self:setTitleInfo()
		self:_setItemBox()

		self._ccbOwner.btn_daily:setHighlighted(true)
		self._ccbOwner.btn_daily:setEnabled(false)
		self._ccbOwner.tf_daily_name1:setVisible(true)
	elseif self._selectTab == QUIDialogDailySignIn.DELUXE_TAB then 
		self._ccbOwner.state2:setVisible(true)
		self:setDeluxeItems()

		self._ccbOwner.btn_deluxe:setHighlighted(true)
		self._ccbOwner.btn_deluxe:setEnabled(false)
		self._ccbOwner.tf_deluxe_name1:setVisible(true)
	end
end 

function QUIDialogDailySignIn:setTitleInfo()
	remote.daily:checkSignTime()
	local currTime = q.date("*t", q.serverTime())
	local month = 0
	if currTime["month"] < 10 then
		month = "0"..currTime["month"]
	else
		month = currTime["month"]
	end
	self.time = currTime["year"].."_"..month

	local offsetTime = q.date("*t", q.serverTime())
	self.signNum, self.signTime = remote.daily:getDailySignIn()
	self._ccbOwner.sign_num:setString(self.signNum)
	self._ccbOwner.frame_tf_title:setString(offsetTime["month"].."月签到奖励")

	self._patchNum = remote.daily:getPatchNum()
	self._ccbOwner.tf_patch_num:setString(self._patchNum or "")
	self._ccbOwner.node_patch_num:setVisible(false)
	if self._patchNum > 0 then
		self._ccbOwner.node_patch_num:setVisible(true)
	end

	local reward = QStaticDatabase.sharedDatabase():getDailySignInItmeByMonth(self.time) or {}
	local index = 1
	while reward["type_"..index] ~= nil do
		self._reward[index] = {id = reward["id_"..index], typeName = reward["type_"..index], vipLevel = reward["vip_"..index], num = reward["num_"..index],
								effect = reward["effect_"..index]}
		index = index + 1
	end

	if self._titleAdd ~= true then
		self._ccbOwner.title:setVisible(false)
	end
end

function QUIDialogDailySignIn:_setItemBox()
	local signDoneIndex = 1
	local multiItems = 5
	local totalNumber = #self._reward
	for i, value in ipairs(self._reward) do
		local state = self:setItemBoxState(i, value.vipLevel)
		if state == QUIWidgetDailySignInBox.IS_DONE then
			signDoneIndex = i
		end
	end

	local speed = 20
	local moveToIndex = signDoneIndex + 1 + multiItems
	if moveToIndex > totalNumber then
		moveToIndex = totalNumber
	end
	if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self, self._renderItemCallBack),
	        enableShadow = false,
	        ignoreCanDrag = true,
	        curOriginOffset = 10,
	        totalNumber = totalNumber,
	        multiItems = 5,
	        spaceX = 10,
	        spaceY = 10,
	    }
	    self._listView = QListView.new(self._ccbOwner.sheet_layout_new, cfg)
	    self._listView:startScrollToIndex(moveToIndex, true, speed)
	elseif self._isFrist == false then
		self._listView:refreshData()
		self._listView:startScrollToIndex(moveToIndex, true, speed)
	else
		self._listView:reload({totalNumber = totalNumber})
		self._listView:startScrollToIndex(moveToIndex, true, speed)
		self._isFrist = false
	end
end

function QUIDialogDailySignIn:_renderItemCallBack(list, index, info)
	local isCacheNode = true
    local data = self._reward[index]

    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetDailySignInBox.new()
		item:addEventListener(QUIWidgetDailySignInBox.EVENT_CLICK, handler(self, self._onTriggerClickItme))
        isCacheNode = false
    end
    
	item:setVipInfo(index, data.vipLevel)
	local state = self:setItemBoxState(index, data.vipLevel)
	item:setItemBoxInfo(data.typeName, data.id, data.num, index, state, data.effect)
	item:setTitleStr(self.signNum)
    item:ininGLLayer()
    info.item = item
    info.size = item:getItemContentSize()

	list:registerBtnHandler(index, "btn_click", "_onTriggerClick")

    return isCacheNode
end

function QUIDialogDailySignIn:setItemBoxState(index, isVip)
	local state = QUIWidgetDailySignInBox.IS_DONE
	local signState = remote.daily:getCurrentSignInState()

	if index < self.signNum then -- 已签到过的物品
	elseif index == self.signNum then
		if isVip and signState == 1 then
			state = QUIWidgetDailySignInBox.IS_READY
		else
			state = QUIWidgetDailySignInBox.IS_DONE
		end
	elseif index == self.signNum + 1 then
		if remote.daily:checkTodaySignIn() == false then  -- 今天没有免费签到
			state = QUIWidgetDailySignInBox.IS_READY
		else      
			if self._patchNum > 0 then   -- 今天可以补签
				state = QUIWidgetDailySignInBox.IS_PATCH
			else
				state = QUIWidgetDailySignInBox.IS_WAITING
			end
		end
	elseif index > self.signNum + 1 then
		state = QUIWidgetDailySignInBox.IS_WAITING
	end
	return state
end

function QUIDialogDailySignIn:setDeluxeItems()
	local deluxeInfo = remote.daily:getDeluxeCheckInfo()
	if deluxeInfo.info == nil then return end
	local infos = string.split(deluxeInfo.info[1].reward, ";")

	for i = 1, #infos do
		self._awardsInfo[i] = {}
		infos[i] = string.split(infos[i], "^")
		self._awardsInfo[i].type = tonumber(infos[i][1]) ~= nil and tonumber(infos[i][1]) or infos[i][1]
		self._awardsInfo[i].count = tonumber(infos[i][2])
	end

	for i = 1, 2 do
		if self._awardsInfo[i] ~= nil then
			if self._deluxeItemBoxs[i] == nil then
				self._deluxeItemBoxs[i] = QUIWidgetItemsBox.new()
				self._ccbOwner["node_item_"..i]:addChild(self._deluxeItemBoxs[i])
			end
			local itemInfo = QStaticDatabase.sharedDatabase():getItemByID(self._awardsInfo[i].type) or {}
			local name = itemInfo.name or ""
			local itemType = ITEM_TYPE.ITEM
			if type(self._awardsInfo[i].type) ~= "number" then
				itemType = self._awardsInfo[i].type
				name = remote.items:getWalletByType(self._awardsInfo[i].type).nativeName or ""
			end
			self._deluxeItemBoxs[i]:setGoodsInfo(self._awardsInfo[i].type, itemType, self._awardsInfo[i].count)
			self._deluxeItemBoxs[i]:setPromptIsOpen(true)

			self._ccbOwner["tf_name_"..i]:setString(name)
		end
	end
end

function QUIDialogDailySignIn:setBtnState()
	self._ccbOwner.btn_go:setVisible(false)
	self._ccbOwner.button_receive:setVisible(false)
	self._ccbOwner.is_done:setVisible(false)

	local deluxeInfo = remote.daily:getDeluxeCheckInfo()
	if deluxeInfo == nil then return end

	if deluxeInfo.info and deluxeInfo.info[1].hasTaken then
		self._ccbOwner.is_done:setVisible(true)
	elseif deluxeInfo.info and deluxeInfo.info[1].isQualified then
		self._ccbOwner.button_receive:setVisible(true)
	else
		self._ccbOwner.btn_go:setVisible(true)
	end
end

--签到成功
function QUIDialogDailySignIn:_onRefreshInfo(data)
	if data.index ~= nil then
		self:setTitleInfo()

		self:_setItemBox()

		self:signSuccess()
	end
end

--领取累积签到成功
function QUIDialogDailySignIn:signSuccess()
	self.stackSign:setSignNum()
	self:checkRedTip()
end

function QUIDialogDailySignIn:checkRedTip()
	self._ccbOwner.daily_red_tip:setVisible(false)
	self._ccbOwner.deluxe_red_tip:setVisible(false)

	self._ccbOwner.daily_red_tip:setVisible(remote.daily:checkDailyRedTip())
	self._ccbOwner.deluxe_red_tip:setVisible(remote.daily:checkDeluxeRedTip())

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page._checkRedTip then 
		page:_checkRedTip()
	end
end 

function QUIDialogDailySignIn:_onTriggerClickItme(data)
	if data.items[1].typeName ~= nil then
		app.sound:playSound("common_item")

		if data.state == QUIWidgetDailySignInBox.IS_READY then
			if data.isVip == true and remote.daily:getCurrentSignInState() == 1 and QVIPUtil:VIPLevel() < data.vipLevel then
				app:vipAlert({content="VIP等级不足，VIP达到"..data.vipLevel.."级可领取双倍奖励，是否前往充值以提升VIP等级？"}, false)
			else
                local info = data
				app:getClient():dailySignIn(info.index, self:safeHandler(function()
                    if self.class ~= nil then
                        self:_onRefreshInfo(info)
                        self:showRewords(info)
                    end
				end))
			end
		elseif data.state == QUIWidgetDailySignInBox.IS_PATCH then
		 	local info = data
			app:alert({content = "是否花费"..self._patchToken.."钻石补签？", callback = function(state)
		           	if state == ALERT_TYPE.CONFIRM then
						app:getClient():dailySignIn(info.index, self:safeHandler(function()
			                if self.class ~= nil then
			                    self:_onRefreshInfo(info)
			                    self:showRewords(info)
			                end
						end))
					end
				end}, false)
		else
			app.tip:itemTip(data.items[1].typeName, data.items[1].id)
		end
	end
end

function QUIDialogDailySignIn:showRewords(data)
	local isVip = false
	if #data.items == 2 then
		isVip = true
	end
    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
            options = {awards = data.items, isVip = isVip}},{isPopCurrentDialog = false} )
    dialog:setTitle("恭喜您获得签到奖励")
end

function QUIDialogDailySignIn:_onTriggerDaily()
	if self._selectTab == QUIDialogDailySignIn.DAILY_TAB then return end
    app.sound:playSound("common_menu")

	self:selectTabs(QUIDialogDailySignIn.DAILY_TAB)
end

function QUIDialogDailySignIn:_onTriggerDeluxe()
	if self._selectTab == QUIDialogDailySignIn.DELUXE_TAB then return end
    app.sound:playSound("common_menu")
	
    if remote.daily:checkNeedRefreshDeluxeInfo() then
    	self:getNewDeluxeInfo()
    end

    local unlockTutorial = app.tip:getUnlockTutorial()
    unlockTutorial.daily = q.serverTime()
	app.tip:setUnlockTutorial(unlockTutorial)

	self:checkRedTip()

	self:selectTabs(QUIDialogDailySignIn.DELUXE_TAB)
end

function QUIDialogDailySignIn:_onTriggerClickGo()
	if ENABLE_CHARGE() then
    	app.sound:playSound("common_small")
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

function QUIDialogDailySignIn:_onTriggerClickReceive()
    app.sound:playSound("common_small")
    if self.receive == true then return end
    self.receive = true

	local deluxeInfo = remote.daily:getDeluxeCheckInfo()
	remote.daily:getDeluxeCheckInfoRequest(deluxeInfo.info[1].rechargeType, function(data)
			if self:safeCheck() then

		        local awards = {}
		        for i = 1, #self._awardsInfo do
					local itemType = ITEM_TYPE.ITEM
					if type(self._awardsInfo[i].type) ~= "number" then
						itemType = self._awardsInfo[i].type
					end
		            table.insert(awards, {id = self._awardsInfo[i].type, typeName = itemType, count = self._awardsInfo[i].count})
		        end
			    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
			            options = {awards = awards}},{isPopCurrentDialog = false} )
			    dialog:setTitle("恭喜获得豪华签到奖励")
				self.receive = false
				self:setBtnState()
				self:checkRedTip()
				self.stackSign:setSignNum()
			end
		end)
end

function QUIDialogDailySignIn:_onTriggerClose()
  	app.sound:playSound("common_close")
  	
	if self._timeScheduler ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end

	self:playEffectOut()
end

function QUIDialogDailySignIn:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogDailySignIn
