--EquipFragmentItem.lua

local AcquireInfoItem = require("app.scenes.common.acquireInfo.AcquireInfoItem")

local EquipFragmentItem = class("EquipFragmentItem",AcquireInfoItem)


function EquipFragmentItem:ctor( ... )
	self.super.ctor(self, ...)
end

return EquipFragmentItem
