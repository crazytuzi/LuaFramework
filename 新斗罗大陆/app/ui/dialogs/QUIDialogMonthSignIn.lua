-- 
-- zxs
-- 月度签到
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonthSignIn = class("QUIDialogMonthSignIn", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QVIPUtil = import("...utils.QVIPUtil")
local QListView = import("...views.QListView")
local QUIWidgetMonthSignInBox = import("..widgets.QUIWidgetMonthSignInBox")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetMonthSignInChestClient = import("..widgets.QUIWidgetMonthSignInChestClient")

function QUIDialogMonthSignIn:ctor(options)
	local ccbFile = "ccb/Dialog_DailySignIn_award.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerStore", callback = handler(self, self._onTriggerStore)},
		{ccbCallbackName = "onTriggerClickHelp", callback = handler(self, self._onTriggerClickHelp)},
    }
    QUIDialogMonthSignIn.super.ctor(self, ccbFile, callBacks, options)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.setManyUIVisible then page:setManyUIVisible() end
    if page.topBar then page.topBar:showWithMonthSignIn() end

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self.isAnimation = true

	local config = remote.items:getWalletByType(ITEM_TYPE.CHECK_IN_MONEY)
	local spf = QSpriteFrameByPath(config.alphaIcon)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 1)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 2)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 4)

    q.setButtonEnableShadow(self._ccbOwner.btn_help)
    q.setButtonEnableShadow(self._ccbOwner.btn_store)

	self:setSignInInfo()
	self:updateMonthSignIn()
end

function QUIDialogMonthSignIn:viewDidAppear()
	QUIDialogMonthSignIn.super.viewDidAppear(self)

    self._monthSignInProxy = cc.EventProxy.new(remote.monthSignIn)
    self._monthSignInProxy:addEventListener(remote.monthSignIn.MONTH_SINGIN_MAIN_EVENT, handler(self, self.setSignInInfo))
    self._monthSignInProxy:addEventListener(remote.monthSignIn.MONTH_SINGIN_UPDATE_EVENT, handler(self, self.updateMonthSignIn))

	self:addBackEvent(true)
end

function QUIDialogMonthSignIn:viewWillDisappear()
  	QUIDialogMonthSignIn.super.viewWillDisappear(self)

    self._monthSignInProxy:removeAllEventListeners()

	self:removeBackEvent()
end

function QUIDialogMonthSignIn:updateMonthSignIn()
	self:setSignInAwards()

	self:setSignInChestInfo()
end

function QUIDialogMonthSignIn:setSignInInfo( )
	self._ccbOwner.node_store:setVisible(remote.monthSignIn:isNewMonthSignInOpen())
	
	local signInConfig = remote.monthSignIn:getSignInConfigInfo()
	-- QKumo(signInConfig)
	local month = string.split(signInConfig.month, "_")
	self._ccbOwner.frame_tf_title:setString(tonumber(month[2]).."月签到奖励")
	self._ccbOwner.tf_desc:setString(signInConfig.txt or "")

	self._ccbOwner.node_title:setPositionX(-349)
	self._ccbOwner.sp_num_1:setVisible(false)
	local resIndex = tonumber(month[2])
	if tonumber(month[2]) > 9 then
		self._ccbOwner.node_title:setPositionX(-336)
		self._ccbOwner.sp_num_1:setVisible(true)
		if resIndex > 10 then
			resIndex = resIndex - 10
		end
	end
	QSetDisplayFrameByPath(self._ccbOwner.sp_nums, QResPath("monthSignInNums")[resIndex])

	if signInConfig.avatar then	
		if self._avatar == nil then
			self._avatar = QUIWidgetHeroInformation.new()
			self._ccbOwner.node_avatar:addChild(self._avatar)
		end
		local characterConfig = db:getCharacterByID(signInConfig.avatar)
		if characterConfig then
			if characterConfig.npc_type == NPC_TYPE.MOUNT then
				self._avatar:setPositionY(100)
			else
				self._avatar:setPositionY(0)
			end
		end
		self._avatar:setAvatarByHeroInfo(nil, signInConfig.avatar, 1)
		self._avatar:setBackgroundVisible(false)
		self._avatar:setNameVisible(false)
		self._avatar:setStarVisible(false)
	else
		if self._avatar then
			self._avatar:removeFromParent()
			self._avatar = nil
		end
	end
end

function QUIDialogMonthSignIn:setSignInAwards( )
	local currentNum = remote.monthSignIn:getCurrentPatchNum()
	self._ccbOwner.tf_num:setString(currentNum)

	self._awardsList = remote.monthSignIn:getSignInAwardList()
	local signedIndex = 1
	for i,v in pairs(self._awardsList) do
		if  v.stated == remote.monthSignIn.MONTH_SINGIN_IS_READY or 
			v.stated == remote.monthSignIn.MONTH_SINGIN_IS_READY_VIP or 
			v.stated == remote.monthSignIn.MONTH_SINGIN_IS_PATCH then
			signedIndex = i
			break
		elseif v.stated == remote.monthSignIn.MONTH_SINGIN_IS_DONE then
			signedIndex = i
		end
	end
	-- local multiItems = 5
	-- if signedIndex > multiItems * 2 then
	-- 	signedIndex = signedIndex + 5
	-- end
	-- if signedIndex > 36 then
	-- 	signedIndex = 31
	-- elseif signedIndex > 15 then
	-- 	signedIndex = 30
	-- end
	if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self, self._renderItemCallBack),
	        enableShadow = false,
	        ignoreCanDrag = true,
	        curOriginOffset = 10,
	        spaceX = 5,
	        spaceY = 5,
	        totalNumber = #self._awardsList,
	        multiItems = 5
	    }
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	    self._listView:startScrollToIndex(signedIndex, true, 20)
	else
		self._listView:refreshData()
	end
end

function QUIDialogMonthSignIn:_renderItemCallBack(list, index, info)
	local isCacheNode = true
    local data = self._awardsList[index]

    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetMonthSignInBox.new()
        item:addEventListener(QUIWidgetMonthSignInBox.EVENT_CLICK, handler(self, self._clickAwardBox))
        isCacheNode = false
    end
    
    item:setInfo(data)
    -- item:initGLLayer()
    info.item = item
    info.size = item:getContentSize()

	if 	data.stated == remote.monthSignIn.MONTH_SINGIN_IS_READY or 
		data.stated == remote.monthSignIn.MONTH_SINGIN_IS_READY_VIP or 
		data.stated == remote.monthSignIn.MONTH_SINGIN_IS_PATCH then
		list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
	else
    	item:registerItemBoxPrompt(index, list)
	end

    return isCacheNode
end

function QUIDialogMonthSignIn:setSignInChestInfo( ... )
	if self._chestClient == nil then
		self._chestClient = QUIWidgetMonthSignInChestClient.new()
		self._ccbOwner.node_chest:addChild(self._chestClient)
	end
	self._chestClient:setInfo()
end

function QUIDialogMonthSignIn:_clickAwardBox(event)
	if event == nil then return end

	local info = event.info
	if info.stated == remote.monthSignIn.MONTH_SINGIN_IS_PATCH then
		local currentNum = remote.monthSignIn:getCurrentPatchNum()
		if currentNum == 0 then
			QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, "check_in_yuedu")
			return
		end
	end

	local requestFunc = function()
		-- 使用签到之前的状态
		local oldStated = info.stated
		remote.monthSignIn:requestMonthSignIn(info.day, function()
				if self:safeCheck() then
					self:showRewords(info, oldStated)
				end
			end)
	end

	if info.stated == remote.monthSignIn.MONTH_SINGIN_IS_READY_VIP then
		if QVIPUtil:VIPLevel() < info.vipLevel then
			app:vipAlert({content="VIP等级不足，VIP达到"..info.vipLevel.."级可领取双倍奖励，是否前往充值以提升VIP等级？"}, false)
		else
			requestFunc()
		end
	else
		requestFunc()
	end
end

function QUIDialogMonthSignIn:showRewords(info, oldStated)
	local isVip = false
	local count = info.count
	if info.vipLevel and info.vipLevel <= QVIPUtil:VIPLevel() and oldStated ~= remote.monthSignIn.MONTH_SINGIN_IS_READY_VIP then
		isVip = true
		count = count * 2
	end

	local awards = {{id = info.id, typeName = info.itemType, count = count}}
    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = awards, isVip = isVip}},{isPopCurrentDialog = false} )
    dialog:setTitle("恭喜您获得月度签到奖励")

	self:updateMonthSignIn()
end

function QUIDialogMonthSignIn:_onTriggerClickHelp(event)
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthSignInHelp"})
end

function QUIDialogMonthSignIn:_onTriggerStore(event)
	app.sound:playSound("common_small")
	remote.stores:openShopDialog(SHOP_ID.monthSignInShop)
end

return QUIDialogMonthSignIn
