local BaseNextPropertyItem =require "Core.Module.Common.BaseNextPropertyItem"
local RideNextPropertyItem = class("RideNextPropertyItem", BaseNextPropertyItem);

function RideNextPropertyItem:New()
	self = {};
	setmetatable(self, {__index = RideNextPropertyItem});
	return self
end

 

return RideNextPropertyItem
