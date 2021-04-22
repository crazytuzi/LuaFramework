local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogNightmareBadge = class("QUIDialogNightmareBadge", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")

QUIDialogNightmareBadge.EVENT_CLOSE = "EVENT_CLOSE"

function QUIDialogNightmareBadge:ctor(options)
	local ccbFile = "ccb/Dialog_Nightmare_huodehuizhang.ccbi";
	local callBacks = {
	}
	QUIDialogNightmareBadge.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	app.sound:playSound("hero_grow_up")

	local oldConfig = options.oldConfig or {}
	local newConfig = options.newConfig
	if oldConfig.alphaicon ~= nil and newConfig.alphaicon ~= nil then
		self._ccbOwner.sp_badge1:setTexture(CCTextureCache:sharedTextureCache():addImage(oldConfig.alphaicon))
		self._ccbOwner.sp_badge2:setTexture(CCTextureCache:sharedTextureCache():addImage(newConfig.alphaicon))
	else
		self._ccbOwner.sp_badge1:setTexture(CCTextureCache:sharedTextureCache():addImage(newConfig.alphaicon))
		self._ccbOwner.sp_badge_arrow:setVisible(false)
		self._ccbOwner.sp_badge2:setVisible(false)
	end

	self._ccbOwner.old_prop_1:setString(oldConfig.hp_value or 0)
	self._ccbOwner.old_prop_2:setString(oldConfig.attack_value or 0)
	self._ccbOwner.old_prop_3:setString(oldConfig.armor_physical or 0)
	self._ccbOwner.old_prop_4:setString(oldConfig.armor_magic or 0)
	
	self._ccbOwner.new_prop_1:setString(newConfig.hp_value)
	self._ccbOwner.new_prop_2:setString(newConfig.attack_value)
	self._ccbOwner.new_prop_3:setString(newConfig.armor_physical)
	self._ccbOwner.new_prop_4:setString(newConfig.armor_magic)
	self._canClose = false
	self._schedulerHander = scheduler.performWithDelayGlobal(function ()
		self._canClose = true
	end, 2)
end

function QUIDialogNightmareBadge:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogNightmareBadge:_onTriggerClose()
	if self._canClose ~= true then return end
	self:playEffectOut()
end

function QUIDialogNightmareBadge:viewAnimationOutHandler()
	self:dispatchEvent({name = QUIDialogNightmareBadge.EVENT_CLOSE})
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogNightmareBadge