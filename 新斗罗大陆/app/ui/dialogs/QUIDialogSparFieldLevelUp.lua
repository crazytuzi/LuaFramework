local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSparFieldLevelUp = class("QUIDialogSparFieldLevelUp", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogSparFieldLevelUp:ctor(options)
	local ccbFile = "ccb/Dialog_sparfield_tansuojihuo.ccbi"
	local callBacks = {
        -- {ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},     
	}
	QUIDialogSparFieldLevelUp.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示
	app.sound:playSound("hero_breakthrough")
	self._isEnd = false

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

	self._sparLevel = options.sparLevel
	self._callback = options.callback
	self._ccbOwner.old_prop_1:setString(self._sparLevel - 1)
	self._ccbOwner.new_prop_1:setString(self._sparLevel)

	local oldStarConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelById(self._sparLevel - 1)
	local starConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelById(self._sparLevel)
	local oldAdd = 0
	if oldStarConfig ~= nil then
		oldAdd = oldStarConfig.reward_coefficient
	end
	local newAdd = 0
	if starConfig ~= nil then
		newAdd = starConfig.reward_coefficient
	end
	self._ccbOwner.old_prop_2:setString((oldAdd*100).."%")
	self._ccbOwner.new_prop_2:setString((newAdd*100).."%")

	local awards = QStaticDatabase:sharedDatabase():getluckyDrawById(starConfig.reward)
	for index,award in ipairs(awards) do
		local box = QUIWidgetItemsBox.new()
		box:setGoodsInfo(award.id, award.typeName, award.count)
		box:setPositionX((index - 1) * 120)
		self._ccbOwner.node_item:addChild(box)
	end
end

function QUIDialogSparFieldLevelUp:animationEndHandler()
	self._isEnd = true
end

function QUIDialogSparFieldLevelUp:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogSparFieldLevelUp:_onTriggerClose()
	if self._isEnd == false then return end
	self:playEffectOut()
end

function QUIDialogSparFieldLevelUp:viewAnimationOutHandler()
	local callback = self._callback
    self:popSelf()
    if callback ~= nil then
    	callback()
    end
end

return QUIDialogSparFieldLevelUp