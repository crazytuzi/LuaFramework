--
-- Author: Kumo
-- Date: 2014-07-17 14:08:11
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRewardRecover = class("QUIDialogRewardRecover", QUIDialog)

local QUIWidgetRewardRecover = import("..widgets.QUIWidgetRewardRecover")
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")

local AWARD_ROWDISTANCE = 5
local AWARD_LINEDISTANCE = 0

function QUIDialogRewardRecover:ctor(options) 
	assert(options ~= nil, "alert dialog options is nil !")
 	local ccbFile = "ccb/Dialog_fulizhuihui.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
			{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		}
	QUIDialogRewardRecover.super.ctor(self, ccbFile, callBacks, options)

	self.isAnimation = true
	self._callBack = options.callBack

    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    q.setButtonEnableShadow(self._ccbOwner.btn_confirm)
		
	self._isOnTriggerConfirm = false
	self._freeItemList = {}

	self:_init()
end

function QUIDialogRewardRecover:viewWillDisappear()
	QUIDialogRewardRecover.super.viewWillDisappear(self)
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	if self._schedulerDelayGlobal then
		scheduler.unscheduleGlobal(self._schedulerDelayGlobal)
		self._schedulerDelayGlobal = nil
	end
end

function QUIDialogRewardRecover:_init()
	self._ccbOwner.tf_countdown:setString("")

	self._freeAwardList = remote.rewardRecover:getFreeAwardList()
	self._tokenAwardList = remote.rewardRecover:getTokenAwardList()

	self:_updateInfo()
	self:_updateFreeRewards()
	self:_updateTokenRewards()
end

function QUIDialogRewardRecover:_updateInfo()
	-- 和时间有关的数据
	self:_updateTime()
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._scheduler = scheduler.scheduleGlobal(function ()
		self:_updateTime()
	end, 1)
end

function QUIDialogRewardRecover:_updateTime()
	local isOvertime, timeStr, color = remote.rewardRecover:updateTime()
	self._isOvertime = isOvertime
	if not isOvertime then
		self._ccbOwner.tf_countdown:setString("剩余时间："..timeStr)
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_receive)
		self._ccbOwner.node_receive:setVisible(true)
		self._ccbOwner.sp_received:setVisible(false)

		if self._contentListView then
			for i = 1, #self._tokenAwardList, 1 do
				local member = self._contentListView:getItemByIndex( i )
				if member then
					member:overTime()
				end
			end
		end
		-- self._ccbOwner.btn_confirm:setEnabled(false)
		self._ccbOwner.tf_countdown:setString("剩余时间：00:00:00")

		if self._scheduler then
			scheduler.unscheduleGlobal(self._scheduler)
			self._scheduler = nil
		end
	end
	-- self._ccbOwner.tf_countdown:setColor( color )
end

function QUIDialogRewardRecover:_updateFreeRewards()
	local index = 1
	for _, award in pairs(self._freeAwardList) do
		local itemBox = QUIWidgetItemsBox.new()
		if tonumber(award.item) then
			local itemType = ITEM_TYPE.ITEM
			local itemTypeNum = remote.rewardRecover:getItemTypeById(award.item)
			if itemTypeNum == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
		        itemType = ITEM_TYPE.GEMSTONE_PIECE
		    elseif itemTypeNum == ITEM_CONFIG_TYPE.GEMSTONE then
		    	itemType = ITEM_TYPE.GEMSTONE
		    end
			itemBox:setGoodsInfo(tonumber(award.item), itemType, tonumber(award.num))
		else
			itemBox:setGoodsInfo(nil, award.item, tonumber(award.num))
		end
		itemBox:setPromptIsOpen(true)
		-- itemBox:showEffect()
		itemBox:setGloryTowerType(false)
		table.insert(self._freeItemList, itemBox)
		local node = self._ccbOwner["node_free_"..index]
		if node then
			node:addChild( itemBox )
		end
		index = index + 1
	end

	if remote.rewardRecover:getIsFreeRewardTaken() then
		makeNodeFromGrayToNormal(self._ccbOwner.node_receive)
		self._ccbOwner.node_receive:setVisible(false)
		self._ccbOwner.sp_received:setVisible(true)
	elseif self._isOvertime then
		makeNodeFromNormalToGray(self._ccbOwner.node_receive)
		self._ccbOwner.node_receive:setVisible(true)
		self._ccbOwner.sp_received:setVisible(false)
		-- self._ccbOwner.btn_confirm:setEnabled(false)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.node_receive)
		self._ccbOwner.node_receive:setVisible(true)
		self._ccbOwner.sp_received:setVisible(false)
		-- self._ccbOwner.btn_confirm:setEnabled(true)
	end
end

function QUIDialogRewardRecover:_updateTokenRewards()
	if not self._contentListView then
        local cfg = {
            renderItemCallBack = handler(self, self._reandFunHandler),
            ignoreCanDrag = false,
            autoCenter = true,
            isVertical = false,
            totalNumber = #self._tokenAwardList,
            spaceY = AWARD_LINEDISTANCE,
            spaceX = AWARD_ROWDISTANCE,
            curOffset = 15,
        }  
        self._contentListView = QListView.new(self._ccbOwner.content_sheet_layout, cfg)
    else
    	-- xurui: 不涉及到物品数量变化以及大小变化，可使用 refreshData() 直接更新物品信息
        -- self._contentListView:reload({totalNumber = #self._tokenAwardList})
        self._contentListView:refreshData()
    end
end

function QUIDialogRewardRecover:_reandFunHandler( list, index, info )
    local isCacheNode = true
    local masterConfig = self._tokenAwardList[index]
    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetRewardRecover.new()
        isCacheNode = false
        item:addEventListener(QUIWidgetRewardRecover.EVENT_CLICK, handler(self, self._onEvent))
    end
    item:init( masterConfig, self , index) 
    item:ininGLLayer()
    info.item = item
    info.size = item:getContentSize()
    list:registerBtnHandler(index, "btn_buy", "_onTriggerConfirm", nil, true)
    list:registerBtnHandler(index, "btn_itemInfo", "_onTriggerItemInfo")

    return isCacheNode
end

function QUIDialogRewardRecover:_onEvent(event)
    if event.name == QUIWidgetRewardRecover.EVENT_CLICK then
    	app.sound:playSound("common_small")
    	-- print("[Kumo] QUIDialogRewardRecover:_onEvent()  id = ", event.id)
    	if event.energyNum then
    		if (remote.user.energy + event.energyNum) > 999 then
    			app.tip:floatTip("体力已达上限，请先消耗后再购买") 
    			return
    		end
    	end

    	if self._contentListView then
			for i = 1, #self._tokenAwardList, 1 do
				local member = self._contentListView:getItemByIndex( i )
				if member then
					member:setCanShowItemInfo(false)
				end
			end
		end
		if self._freeItemList then
			for _, itemBox in ipairs(self._freeItemList) do
				itemBox:setPromptIsOpen(false)
			end
		end
    	remote.rewardRecover:playerRecoverGetRewardRequest("PAY_TYPE", event.id, self:safeHandler(function(data)
				-- QPrintTable(data)
				-- event.widget:updateCount()
				remote.user:update( data.wallet )
				if data.items then remote.items:setItems(data.items) end

				-- 刷新面板信息
				self._tokenAwardList = remote.rewardRecover:getTokenAwardList(event.id)
				self:_updateTokenRewards()
				-- 展示奖励页面
				if data.playerRecoverGetRewardResponse then
					local awards = {}
					local tbl = string.split(data.playerRecoverGetRewardResponse.awardStr or {}, ";")
					for _, awardStr in pairs(tbl or {}) do
						local id, typeName, count = remote.rewardRecover:getItemBoxParaMetet(awardStr)
						table.insert(awards, {id = id, count = count, typeName = typeName})
					end
					app.tip:awardsTip(awards, "恭喜您获得追回奖励", self:safeHandler(function()
							if self._contentListView then
								for i = 1, #self._tokenAwardList, 1 do
									local member = self._contentListView:getItemByIndex( i )
									if member then
										member:setCanShowItemInfo(true)
									end
								end
							end
							if self._freeItemList then
								for _, itemBox in ipairs(self._freeItemList) do
									itemBox:setPromptIsOpen(true)
								end
							end
							remote.user:checkTeamUp()
						end))
					-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
			  --           options = {awards = awards}}, {isPopCurrentDialog = false} )
				end
			end))
    end
end

function QUIDialogRewardRecover:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogRewardRecover:_onTriggerClose()
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogRewardRecover:_onTriggerConfirm()
	if self._isOnTriggerConfirm then return end
	self._isOnTriggerConfirm = true

	if not remote.rewardRecover:getIsFreeRewardTaken() and not self._isOvertime then
		app.sound:playSound("common_small")
		if self._schedulerDelayGlobal then
			scheduler.unscheduleGlobal(self._schedulerDelayGlobal)
			self._schedulerDelayGlobal = nil
		end
		self._schedulerDelayGlobal = scheduler.performWithDelayGlobal(function()
			self._isOnTriggerConfirm = false
		end, 1)

		if self._contentListView then
			for i = 1, #self._tokenAwardList, 1 do
				local member = self._contentListView:getItemByIndex( i )
				if member then
					member:setCanShowItemInfo(false)
				end
			end
		end
		if self._freeItemList then
			for _, itemBox in ipairs(self._freeItemList) do
				itemBox:setPromptIsOpen(false)
			end
		end
		remote.rewardRecover:playerRecoverGetRewardRequest("FREE_TYPE", nil, self:safeHandler(function(data)
				-- QPrintTable(data)
				if remote.rewardRecover:getIsFreeRewardTaken() then
					-- makeNodeFromNormalToGray(self._ccbOwner.node_receive)
					self._ccbOwner.node_receive:setVisible(false)
					self._ccbOwner.sp_received:setVisible(true)
					self._ccbOwner.btn_confirm:setEnabled(false)
				else
					makeNodeFromGrayToNormal(self._ccbOwner.node_receive)
					self._ccbOwner.node_receive:setVisible(true)
					self._ccbOwner.sp_received:setVisible(false)
					self._ccbOwner.btn_confirm:setEnabled(true)
				end

				remote.user:update( data.wallet )
				if data.items then remote.items:setItems(data.items) end

				-- 展示奖励页面
				if data.playerRecoverGetRewardResponse then
					local awards = {}
					local tbl = string.split(data.playerRecoverGetRewardResponse.awardStr or {}, ";")
					for _, awardStr in pairs(tbl or {}) do
						local id, typeName, count = remote.rewardRecover:getItemBoxParaMetet(awardStr)
						table.insert(awards, {id = id, count = count, typeName = typeName})
					end

					app.tip:awardsTip(awards, "恭喜您获得追回奖励", self:safeHandler(function()
							remote.user:checkTeamUp()
							self._isOnTriggerConfirm = false
							if self._contentListView then
								for i = 1, #self._tokenAwardList, 1 do
									local member = self._contentListView:getItemByIndex( i )
									if member then
										member:setCanShowItemInfo(false)
									end
								end
							end
							if self._freeItemList then
								for _, itemBox in ipairs(self._freeItemList) do
									itemBox:setPromptIsOpen(true)
								end
							end
						end))
					-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
			  --           options = {awards = awards}}, {isPopCurrentDialog = false} )
				end
			end))
	else
		self._isOnTriggerConfirm = false
		if self._isOvertime then
			app.tip:floatTip("魂师大人，福利追回已结束～")
		else
			app.tip:floatTip("魂师大人，您已经领取过奖励啦～")
		end
	end
end

function QUIDialogRewardRecover:viewAnimationOutHandler()
	remote.rewardRecover:setIsShowRedTips(false)
	local callBack = self._callBack
	self:popSelf()
	if callBack ~= nil then
		callBack()
	end
end

return QUIDialogRewardRecover