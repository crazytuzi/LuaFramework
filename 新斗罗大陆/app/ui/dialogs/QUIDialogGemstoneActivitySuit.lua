local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGemstoneActivitySuit = class("QUIDialogGemstoneActivitySuit", QUIDialog)

local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogGemstoneActivitySuit:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_taozhuangjihuo.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
    }
	QUIDialogGemstoneActivitySuit.super.ctor(self, ccbFile, callBacks, options)

	app.sound:playSound("hero_grow_up")
	self._isEnd = false
	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
	self._animationManager:connectScriptHandler(function()
			if self._isEnd == false then
				self._isEnd = true
			end
		end)

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	self.callback = options.callback
	local suits = options.suits
	local count = #suits
	local suitstype = options.suitstype or ""
	
	self._ccbOwner.node_icon:setPositionX(-(count - 1) * 115 + 345)
	for i=1,4 do
		self._ccbOwner["node_"..i]:setVisible(false)
		self._ccbOwner["node_suit"..i]:setVisible(false)
		self._ccbOwner["tf_name"..i]:setVisible(false)
		if self._ccbOwner["node_plus"..i] ~= nil then
			self._ccbOwner["node_plus"..i]:setVisible(false)
		end
	end
	for index,gemstone in ipairs(suits) do
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstone.itemId)
		local box = QUIWidgetGemstonesBox.new()
		box:setItemId(gemstone.itemId)
		box:setQuality(remote.gemstone:getSABC(itemConfig.gemstone_quality).lower)
		box:setStrengthVisible(false)
		self._ccbOwner["node_"..index]:addChild(box)
		self._ccbOwner["node_"..index]:setVisible(true)
		self._ccbOwner["tf_name"..index]:setString(itemConfig.name)
		self._ccbOwner["tf_name"..index]:setVisible(true)
		if self._ccbOwner["node_plus"..index] ~= nil then
			self._ccbOwner["node_plus"..index]:setVisible(true)
		end
	end

	if count > 0 then
		local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(suits[1].itemId)
		local suitInfos = QStaticDatabase:sharedDatabase():getGemstoneSuitEffectBySuitId(itemConfig.gemstone_set_index)
		for index,config in ipairs(suitInfos) do
			if config.set_number <= count then
				self._ccbOwner["node_suit"..index]:setVisible(true)
	        	self._ccbOwner["tf_num"..index]:setString(config.set_number)
	        	-- local newDesc = string.gsub(config.set_desc, "攻速提升200", "\n攻速提升200")
	        	self._ccbOwner["tf_value"..index]:setString(config.set_desc)	        	
			end
	    end
	end

	self._successTip = options.successTip
	self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())
    self._isSelected = false
    self:showSelectState()
end

function QUIDialogGemstoneActivitySuit:viewWillDisappear()
	QUIDialogGemstoneActivitySuit.super.viewWillDisappear(self)
end

function QUIDialogGemstoneActivitySuit:_backClickHandler()
	if self._isEnd == false then 
		return 
	end
	self:_onTriggerClose()
end

function QUIDialogGemstoneActivitySuit:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogGemstoneActivitySuit:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogGemstoneActivitySuit:_onTriggerClose()
	if self.callback ~= nil then 
		self.callback()
	end
    if self._isSelected == true then
		app.master:setMasterShowState(self._successTip)
    end
	self:popSelf()
end

return QUIDialogGemstoneActivitySuit