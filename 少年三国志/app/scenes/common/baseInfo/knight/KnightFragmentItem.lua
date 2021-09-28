--KnightFragmentItem.lua

local AcquireInfoItem = require("app.scenes.common.acquireInfo.AcquireInfoItem")

local KnightFragmentItem = class("KnightFragmentItem",AcquireInfoItem)


function KnightFragmentItem:ctor( ... )
	self.super.ctor(self, ...)
end

return KnightFragmentItem
