require "Core.Module.Common.BasePropertyItem"
RidePropretyItem = class("RidePropretyItem", BasePropertyItem);

function RidePropretyItem:New()
    self = { };
    setmetatable(self, { __index = RidePropretyItem });
    return self
end

 