--
-- Author: Kumo.Wang
-- 仙品养成穿戴界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbCheckroom = class("QUIDialogMagicHerbCheckroom", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")
local QUIWidgetMagicHerbCheckroomCell = import("..widgets.QUIWidgetMagicHerbCheckroomCell")
local QActorProp = import("...models.QActorProp")

QUIDialogMagicHerbCheckroom.TAB_WEAR = "TAB_WEAR"
QUIDialogMagicHerbCheckroom.TAB_NO_WEAR = "TAB_NO_WEAR"

function QUIDialogMagicHerbCheckroom:ctor(options)
	local ccbFile = "ccb/Dialog_MagicHerb_Checkroom.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose",   callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerClickMenu1",  callback = handler(self, self._onTriggerClickNoWear)},
		{ccbCallbackName = "onTriggerClickMenu2",  callback = handler(self, self._onTriggerClickWear)},
		{ccbCallbackName = "onTriggerClickGoto",    callback = handler(self, self._onTriggerClickGoto)},
	}
	QUIDialogMagicHerbCheckroom.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_goto)
	self._ccbOwner.tf_content:setString("三哥，当前没有仙品，可以去仙品商城看看哟～")

    if options then
		self._pos = options.pos
		self._tab = options.tab or QUIDialogMagicHerbCheckroom.TAB_NO_WEAR
		self._actorId = options.actorId
		self._isReborn = options.isReborn
		self._rebornType = options.rebornType
		self._needMark = options.needMark
	end
	if self._isReborn then
		self._tab = nil
		self._ccbOwner.s9s_bg:setPreferredSize(CCSize(690, 500))
		self._ccbOwner.s9s_bg:setPosition(-3,-11)
		self._ccbOwner.sheet:setPosition(-347, 236)
		self._ccbOwner.sheet_layout:setPosition(-1, -496)
		self._ccbOwner.sheet_layout:setContentSize(CCSize(686, 496))
		self._ccbOwner.node_btn:setVisible(false)
	else
		self._ccbOwner.s9s_bg:setPreferredSize(CCSize(690, 456))
		self._ccbOwner.s9s_bg:setPosition(-4,-30)
		self._ccbOwner.sheet:setPosition(-347, 197)
		self._ccbOwner.sheet_layout:setPosition(-1, -453)
		self._ccbOwner.sheet_layout:setContentSize(CCSize(686, 452))
		self._ccbOwner.node_btn:setVisible(true)
	end
    self._tab = self._tab == nil and QUIDialogMagicHerbCheckroom.TAB_NO_WEAR or self._tab

    self._data = {}

	self:_initListView()
end

function QUIDialogMagicHerbCheckroom:viewDidAppear()
	QUIDialogMagicHerbCheckroom.super.viewDidAppear(self)

	self:selectTab()
end

function QUIDialogMagicHerbCheckroom:viewWillDisappear()
	QUIDialogMagicHerbCheckroom.super.viewWillDisappear(self)
end

function QUIDialogMagicHerbCheckroom:selectTab()
	self._ccbOwner.node_no:setVisible(false)
	self._data = {}
	self:_setButtonState()

	self._magicHerbItemList = remote.magicHerb:getMagicHerbItemList()
	local wearList = {}
	local noWearList = {}
	for _, value in ipairs(self._magicHerbItemList) do
		local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(value.itemId)
		local colorStrList = remote.magicHerb:getColorStrList(value)
		local data = {magicHerbInfo = value , magicHerbConfig = magicHerbConfig , colorStrList = colorStrList}
		if value and value.actorId and value.actorId ~= 0 and value.actorId ~= self._actorId then
			table.insert(wearList,data)
		elseif not value.actorId or value.actorId == 0 then

			if not self._isReborn then
				table.insert(noWearList,data)
			else
				if not value.isLock then
					if self._rebornType == 1 then
						-- 分解
						table.insert(noWearList,data)
					elseif self._rebornType == 2 and (value.level > 1 or value.grade > 1 or value.breedLevel > 0) then
						-- 重生
						table.insert(noWearList,data)
					end
				end
			end
		end
	end

	-- for _, value in ipairs(self._magicHerbItemList) do
	-- 	if value.magicHerbInfo and value.magicHerbInfo.actorId and value.magicHerbInfo.actorId ~= 0 and value.magicHerbInfo.actorId ~= self._actorId then
	-- 		wearList[#wearList+1] = value
	-- 	elseif not value.magicHerbInfo.actorId or value.magicHerbInfo.actorId == 0 then
	-- 		if not self._isReborn then
	-- 			noWearList[#noWearList+1] = value
	-- 		else
	-- 			if not value.magicHerbInfo.isLock then
	-- 				if self._rebornType == 1 then
	-- 					-- 分解
	-- 					noWearList[#noWearList+1] = value
	-- 				elseif self._rebornType == 2 then
	-- 					-- 重生
	-- 					if value.magicHerbInfo.level > 1 or value.magicHerbInfo.grade > 1 then
	-- 						noWearList[#noWearList+1] = value
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end

	if self._tab == QUIDialogMagicHerbCheckroom.TAB_WEAR then
		self._data = wearList
	elseif self._tab == QUIDialogMagicHerbCheckroom.TAB_NO_WEAR then
		self._data = noWearList
	end
	
	for _, data in ipairs(self._data) do
		-- if not data.colorStrList then
		-- 	data.colorStrList = self:_getColorStrList(data)
		-- end
		local uiHeroModle = remote.herosUtil:getUIHeroByID(self._actorId)
		local isCanTake = false
		if uiHeroModle and self._pos then
		 	isCanTake = uiHeroModle:checkMagicHerbCanWear(self._pos, data.magicHerbConfig.attribute_type,  data.magicHerbConfig.type)
		end
		data.isCanTake = isCanTake
	end

	if self._rebornType == 1 then
		table.sort( self._data, function(a, b)
				-- 由於現在增加了attribute_type作為限制，可配戴的仙品必成套裝，所以不需要判斷套裝優先了。
				if a.isCanTake ~= b.isCanTake then
					return a.isCanTake
				elseif a.magicHerbInfo.breedLevel ~= b.magicHerbInfo.breedLevel then
					return a.magicHerbInfo.breedLevel < b.magicHerbInfo.breedLevel
				elseif a.magicHerbConfig.aptitude ~= b.magicHerbConfig.aptitude then
					return a.magicHerbConfig.aptitude < b.magicHerbConfig.aptitude
				elseif a.magicHerbInfo.grade ~= b.magicHerbInfo.grade then
					return a.magicHerbInfo.grade < b.magicHerbInfo.grade
				elseif #a.colorStrList ~= #b.colorStrList then
					return #a.colorStrList > #b.colorStrList
				elseif #a.colorStrList > 0 and #b.colorStrList > 0 and a.colorStrList[1] ~= b.colorStrList[1] then
					return a.colorStrList[1] > b.colorStrList[1]
				elseif #a.colorStrList > 1 and #b.colorStrList > 1 and a.colorStrList[2] ~= b.colorStrList[2] then
					return a.colorStrList[2] > b.colorStrList[2]
				elseif a.magicHerbInfo.level ~= b.magicHerbInfo.level then
					return a.magicHerbInfo.level < b.magicHerbInfo.level
				else
					return a.magicHerbInfo.itemId < b.magicHerbInfo.itemId
				end
			end )
	else
		table.sort( self._data, function(a, b)
				-- 由於現在增加了attribute_type作為限制，可配戴的仙品必成套裝，所以不需要判斷套裝優先了。
				if a.isCanTake ~= b.isCanTake then
					return a.isCanTake
				elseif a.magicHerbInfo.breedLevel ~= b.magicHerbInfo.breedLevel then
					return a.magicHerbInfo.breedLevel > b.magicHerbInfo.breedLevel					
				elseif a.magicHerbConfig.aptitude ~= b.magicHerbConfig.aptitude then
					return a.magicHerbConfig.aptitude > b.magicHerbConfig.aptitude
				elseif a.magicHerbInfo.grade ~= b.magicHerbInfo.grade then
					return a.magicHerbInfo.grade > b.magicHerbInfo.grade
				elseif #a.colorStrList ~= #b.colorStrList then
					return #a.colorStrList > #b.colorStrList
				elseif #a.colorStrList > 0 and #b.colorStrList > 0 and a.colorStrList[1] ~= b.colorStrList[1] then
					return a.colorStrList[1] > b.colorStrList[1]
				elseif #a.colorStrList > 1 and #b.colorStrList > 1 and a.colorStrList[2] ~= b.colorStrList[2] then
					return a.colorStrList[2] > b.colorStrList[2]
				elseif a.magicHerbInfo.level ~= b.magicHerbInfo.level then
					return a.magicHerbInfo.level > b.magicHerbInfo.level
				else
					return a.magicHerbInfo.itemId > b.magicHerbInfo.itemId
				end
			end )
	end

	if self._data == nil or next(self._data) == nil then
		self._ccbOwner.node_no:setVisible(true)
	end

	self:_initListView()
end

-- function QUIDialogMagicHerbCheckroom:_getColorStrList(a)
-- 	local returnTBl = {}
-- 	if not a.magicHerbInfo or not a.magicHerbInfo.attributes or #a.magicHerbInfo.attributes == 0 then return returnTBl end

-- 	for _, value in ipairs(a.magicHerbInfo.attributes) do
-- 		local key = value.attribute
-- 		if key and QActorProp._field[key] then
-- 			local colorStr = remote.magicHerb:getRefineValueColorAndMax(key, value.refineValue, a.magicHerbConfig.additional_attributes)
-- 			table.insert(returnTBl, colorStr)
-- 		end
-- 	end

-- 	table.sort(returnTBl, function(a, b)
-- 			return a > b
-- 		end)

-- 	return returnTBl
-- end

function QUIDialogMagicHerbCheckroom:_initListView()
	local totalNumber = #self._data
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = totalNumber,
	        enableShadow = false,
	        spaceY = 0,
	        -- contentOffsetX = 3,
	        -- curOffset = 15,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = totalNumber})
	end
end

function QUIDialogMagicHerbCheckroom:renderFunHandler(list, index, info)
    local isCacheNode = true
    local data = self._data[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetMagicHerbCheckroomCell.new()
        isCacheNode = false
    end
    info.item = item
    if self._isReborn then
    	item:setInfo({isReborn = true, rebornType = self._rebornType, info = data, callback = handler(self, self._onSelect)})
    else
		item:setInfo({actorId = self._actorId, info = data, pos = self._pos, callback = handler(self, self._onWear)})
	end
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_icon", "_onTriggerClick")
    list:registerBtnHandler(index, "btn_wear", "_onTriggerWear",nil,true)
    list:registerBtnHandler(index, "btn_info", "_onTriggerInfo",nil,true)

	return isCacheNode
end

function QUIDialogMagicHerbCheckroom:_onWear(event)
	if event == nil or event.magicHerbItemInfo == nil or event.magicHerbItemInfo.magicHerbInfo == nil or self._isMoving then return end

	local magicHerbSid = event.magicHerbItemInfo.magicHerbInfo.sid
	if self._needMark then
		remote.magicHerb.donotShowSuit = true
	end
	remote.magicHerb:magicHerbLoadRequest(magicHerbSid, 1, self._actorId, self._pos, function(data)
			if self:safeCheck() then
				-- self:playEffectOut()
				self:popSelf()
			end
			remote.magicHerb:dispatchEvent({name = remote.magicHerb.EVENT_REFRESH_MAGIC_HERB, sid = magicHerbSid, isOnWear = true})
		end)
end

function QUIDialogMagicHerbCheckroom:_onSelect(event)
	if event == nil or event.magicHerbItemInfo == nil or event.magicHerbItemInfo.magicHerbInfo == nil or self._isMoving then return end

	remote.magicHerb:dispatchEvent({name = remote.magicHerb.EVENT_SELECTED_MAGIC_HERB, magicHerbInfo = event.magicHerbItemInfo.magicHerbInfo})
	if self:safeCheck() then
		self:playEffectOut()
	end
end

function QUIDialogMagicHerbCheckroom:_setButtonState()
	local wearState = self._tab == QUIDialogMagicHerbCheckroom.TAB_NO_WEAR
	self._ccbOwner.btn_menu_1:setEnabled(not wearState)
	self._ccbOwner.btn_menu_1:setHighlighted(wearState)

	local noWearState = self._tab == QUIDialogMagicHerbCheckroom.TAB_WEAR
	self._ccbOwner.btn_menu_2:setEnabled(not noWearState)
	self._ccbOwner.btn_menu_2:setHighlighted(noWearState)
end

function QUIDialogMagicHerbCheckroom:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMagicHerbCheckroom:_onTriggerClickWear(e)
	if e ~= nil then
		app.sound:playSound("common_menu")
	end
	if self._isReborn then
		app.tip:floatTip("不能选择携带中的仙品哦～")
		return
	end

	self._tab = QUIDialogMagicHerbCheckroom.TAB_WEAR
	self:selectTab()
end

function QUIDialogMagicHerbCheckroom:_onTriggerClickNoWear(e)
	if e ~= nil then
		app.sound:playSound("common_menu")
	end
	self._tab = QUIDialogMagicHerbCheckroom.TAB_NO_WEAR
	self:selectTab()
end

function QUIDialogMagicHerbCheckroom:_onTriggerClickGoto(e)
	if e ~= nil then
		app.sound:playSound("common_small")
	end

	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMall", options = {tab = "MAGICHERB_TYPE"}})
end

function QUIDialogMagicHerbCheckroom:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogMagicHerbCheckroom:viewAnimationOutHandler()
	self:popSelf()
end

return QUIDialogMagicHerbCheckroom