--TreasureFragmentItem.lua

local AcquireInfoItem = require("app.scenes.common.acquireInfo.AcquireInfoItem")

local TreasureFragmentItem = class("TreasureFragmentItem",AcquireInfoItem)


function TreasureFragmentItem:ctor( ... )
	self.super.ctor(self, ...)
end

return TreasureFragmentItem
