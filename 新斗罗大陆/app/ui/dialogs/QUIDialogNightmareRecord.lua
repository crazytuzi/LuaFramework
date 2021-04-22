local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogNightmareRecord = class("QUIDialogNightmareRecord", QUIDialog)
local QUIWidgetNightmareRecord = import("..widgets.QUIWidgetNightmareRecord")

QUIDialogNightmareRecord.TAB_BETTER = "TAB_BETTER"
QUIDialogNightmareRecord.TAB_FIRST = "TAB_FIRST"

function QUIDialogNightmareRecord:ctor(options)
 	local ccbFile = "ccb/Dialog_Nightmare_zuizaojisha.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogNightmareRecord._onTriggerClose)},
	    {ccbCallbackName = "onTriggerBetter", callback = handler(self, QUIDialogNightmareRecord._onTriggerBetter)},
	    {ccbCallbackName = "onTriggerFirst", callback = handler(self, QUIDialogNightmareRecord._onTriggerFirst)},
	}
	QUIDialogNightmareRecord.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._info = options.info or {}

	-- self._ccbOwner.btn_better
	-- setShadow5(self._ccbOwner.tf_better, ccc3(60, 28, 0))
	setShadow5(self._ccbOwner.tf_better_select, ccc3(60, 28, 0))
	-- setShadow5(self._ccbOwner.tf_first, ccc3(60, 28, 0))
	setShadow5(self._ccbOwner.tf_first_select, ccc3(60, 28, 0))
	-- self._ccbOwner.tf_better_select
	-- self._ccbOwner.btn_first
	-- self._ccbOwner.tf_first
	-- self._ccbOwner.tf_first_select
	-- self._ccbOwner.node1
	-- self._ccbOwner.node2
	-- self._ccbOwner.node3
	-- self._ccbOwner.node_first_tips
	-- self._ccbOwner.node_better_tips
	-- self._ccbOwner.node_no

	self:selectTab(QUIDialogNightmareRecord.TAB_BETTER)
end

function QUIDialogNightmareRecord:selectTab(tab)
	if self._tab == tab then return end
	self._tab = tab
	local isBetter = tab == QUIDialogNightmareRecord.TAB_BETTER
	self._ccbOwner.btn_better:setHighlighted(isBetter)
	self._ccbOwner.btn_better:setEnabled(not isBetter)
	self._ccbOwner.tf_better:setVisible(not isBetter)
	self._ccbOwner.tf_better_select:setVisible(isBetter)

	self._ccbOwner.btn_first:setHighlighted(not isBetter)
	self._ccbOwner.btn_first:setEnabled(isBetter)
	self._ccbOwner.tf_first:setVisible(isBetter)
	self._ccbOwner.tf_first_select:setVisible(not isBetter)

	self._ccbOwner.node_first_tips:setVisible(not isBetter)
	self._ccbOwner.node_better_tips:setVisible(isBetter)

	if self._tab == QUIDialogNightmareRecord.TAB_BETTER then
		self:refreshItemInfo(self._info.bestPassUserInfo or {})
	else
		self:refreshItemInfo(self._info.earliestPassUserInfo or {})
	end
end

function QUIDialogNightmareRecord:refreshItemInfo(fighters)
	self._ccbOwner.node_no:setVisible(#fighters == 0)
	for i = 1,3 do
		if fighters[i] ~= nil then
			if self["item"..i] == nil then
				self["item"..i] = QUIWidgetNightmareRecord.new()
				self._ccbOwner["node"..i]:addChild(self["item"..i])
			end
			self["item"..i]:setFighter(fighters[i], i, self._tab == QUIDialogNightmareRecord.TAB_BETTER)
			self["item"..i]:setVisible(true)
		else
			if self["item"..i] ~= nil then
				self["item"..i]:setVisible(false)
			end
		end
	end
end

function QUIDialogNightmareRecord:_backClickHandler( ... )
	self:_onTriggerClose()
end

function QUIDialogNightmareRecord:_onTriggerBetter(e)
	if e ~= nil then app.sound:playSound("common_switch") end
	self:selectTab(QUIDialogNightmareRecord.TAB_BETTER)
end

function QUIDialogNightmareRecord:_onTriggerFirst(e)
	if e ~= nil then app.sound:playSound("common_switch") end
	self:selectTab(QUIDialogNightmareRecord.TAB_FIRST)
end

function QUIDialogNightmareRecord:_onTriggerClose(e)
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogNightmareRecord