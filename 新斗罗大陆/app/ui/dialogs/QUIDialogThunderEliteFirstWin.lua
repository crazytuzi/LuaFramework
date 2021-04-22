--
-- Author: xurui
-- Date: 2015-08-18 17:37:28
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderEliteFirstWin = class("QUIDialogThunderEliteFirstWin", QUIDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogThunderEliteFirstWin:ctor(options)
	local ccbFile = "ccb/Dialog_ThunderKing_FirstAward.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickAvatar", callback = handler(self, self._onTriggerClickAvatar)}
	}
	QUIDialogThunderEliteFirstWin.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	if options ~= nil then
		self._itemInfo = options.itemInfo
	end

	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setGoodsInfo(nil, "thunderMoney", self._itemInfo.thunder_fd)
	self._ccbOwner.item_node:addChild(itemBox)

	local currencyInfo = remote.items:getWalletByType("thunderMoney")
	self._ccbOwner.item_name:setString(currencyInfo.nativeName)

	self:setAvatar()
end

function QUIDialogThunderEliteFirstWin:viewDidAppear()
	QUIDialogThunderEliteFirstWin.super.viewDidAppear(self)
end 

function QUIDialogThunderEliteFirstWin:viewWillDisappear()
	QUIDialogThunderEliteFirstWin.super.viewWillDisappear(self)
end 

function QUIDialogThunderEliteFirstWin:setAvatar()
	local monsterConfigs = QStaticDatabase:sharedDatabase():getMonstersById(self._itemInfo.monster_id)
	local monsterConfig = {}
	if monsterConfigs ~= nil and #monsterConfigs > 0 then
		for i,value in pairs(monsterConfigs) do
			-- TOFIX: SHRINK
			local value = q.cloneShrinkedObject(value)
			if value.is_boss then
				monsterConfig = value
			end
		end
	end
	if next(monsterConfig) == nil then
		monsterConfig = monsterConfigs[1]
	end
	if self._avatar == nil then 
		self._avatar = QUIWidgetHeroInformation.new()
		self._ccbOwner.node_avatar:addChild(self._avatar)
		self._avatar:setBackgroundVisible(false)
		self._avatar:setNameVisible(false)
		-- self._avatar:setProVisible(false)
	end
	self._avatar:setAvatarByHeroInfo(nil, monsterConfig.npc_id, self._itemInfo.box_boss_size or 1)

	-- self._ccbOwner.content:setString("伟大的魂师，感谢你把我解救出来，这是我的心意，请收下。")
	if FinalSDK.isHXShenhe() then
        self._ccbOwner.content:setString("感谢你把我解救出来，这是我的心意，请收下。")
    else
    	self._ccbOwner.content:setString("三哥好棒！这是被解救的堕落者送给我们的谢礼，小舞帮您收进背包了~")
    end

end

function QUIDialogThunderEliteFirstWin:_onTriggerClickAvatar()
	self:_onTriggerClose()
end

function QUIDialogThunderEliteFirstWin:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogThunderEliteFirstWin:_onTriggerClose()
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogThunderEliteFirstWin:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogThunderEliteFirstWin