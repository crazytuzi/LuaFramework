--
-- Author: Kumo
-- 老玩家回归特权界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetUserComeBackPrivilege = class("QUIWidgetUserComeBackPrivilege", QUIWidget)

local QUIWidgetUserComeBackPrivilegeCell = import("..widgets.QUIWidgetUserComeBackPrivilegeCell")

function QUIWidgetUserComeBackPrivilege:ctor(options)
	local ccbFile = "ccb/Widget_ComeBack_Privilege.ccbi"
	local callBacks = {}
	QUIWidgetUserComeBackPrivilege.super.ctor(self, ccbFile, callBacks, options)
	if options then
		self._data = options.data or {}
	end
end

function QUIWidgetUserComeBackPrivilege:onEnter()
	QUIWidgetUserComeBackPrivilege.super.onEnter()
	self:_init()
end

function QUIWidgetUserComeBackPrivilege:onExit()
    QUIWidgetUserComeBackPrivilege.super.onExit()
end

function QUIWidgetUserComeBackPrivilege:resetAll()
	local index = 1
	while true do
		local node = self._ccbOwner["node_"..index]
		if node then
			node:removeAllChildren()
			index = index + 1
		else
			break
		end
	end
end

function QUIWidgetUserComeBackPrivilege:_init()
	self:resetAll()
	if self._data and next(self._data) then
		for index, value in ipairs(self._data) do
			local node  = self._ccbOwner["node_"..index]
			if node then
				local widget = QUIWidgetUserComeBackPrivilegeCell.new({data = value})
				node:addChild(widget)
			end
		end
	end
end

return QUIWidgetUserComeBackPrivilege