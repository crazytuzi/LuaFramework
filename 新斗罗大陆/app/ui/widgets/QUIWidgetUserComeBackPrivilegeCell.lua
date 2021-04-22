--
-- Author: Kumo
-- 老玩家回归特权界面Cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetUserComeBackPrivilegeCell = class("QUIWidgetUserComeBackPrivilegeCell", QUIWidget)

local QQuickWay = import("...utils.QQuickWay")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetUserComeBackPrivilegeCell:ctor(options)
	local ccbFile = "ccb/Widget_ComeBack_Privilege_Cell.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
	}
	QUIWidgetUserComeBackPrivilegeCell.super.ctor(self, ccbFile, callBacks, options)
	if options then
		self._data = options.data or {}
	end
end

function QUIWidgetUserComeBackPrivilegeCell:onEnter()
	QUIWidgetUserComeBackPrivilegeCell.super.onEnter()
	self:_init()
end

function QUIWidgetUserComeBackPrivilegeCell:onExit()
    QUIWidgetUserComeBackPrivilegeCell.super.onExit()
end

function QUIWidgetUserComeBackPrivilegeCell:resetAll()
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.ccb_dazhe:setVisible(false)
	self._ccbOwner.tf_name:setVisible(false)
end

function QUIWidgetUserComeBackPrivilegeCell:_init()
	self:resetAll()
	if self._data and self._data.config then
		local unlockConfig = app.unlock:getConfigByKey(self._data.config.unlock)
		self._ccbOwner.tf_name:setString(unlockConfig.name)
		self._ccbOwner.tf_name:setVisible(true)
		local icon = CCSprite:create(unlockConfig.icon)
		self._ccbOwner.node_icon:addChild(icon)
		if self._data.config.wanfa_beilv > 1 then
			self._ccbOwner.discountStr:setString("货币"..self._data.config.wanfa_beilv.."倍")
			self._ccbOwner.chengDisCountBg:setVisible(false)
			self._ccbOwner.lanDisCountBg:setVisible(false)
			self._ccbOwner.ziDisCountBg:setVisible(false)
			self._ccbOwner.hongDisCountBg:setVisible(true)
			self._ccbOwner.ccb_dazhe:setVisible(true)
		end
	end
end

function QUIWidgetUserComeBackPrivilegeCell:_onTriggerGo(event)
	if event then
    	app.sound:playSound("common_small")
	end
	-- if self._data.config.shortcut_id ~= nil then
	-- 	QQuickWay:clickGoto(QStaticDatabase.sharedDatabase():getShortcutByID(self._data.config.shortcut_id))
	-- end
	if self._data.config.miao_shu ~= nil then
		app.tip:floatTip(self._data.config.miao_shu)
	end
end
return QUIWidgetUserComeBackPrivilegeCell