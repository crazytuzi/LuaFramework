local BaseIconItem = require "Core.Module.Common.BaseIconItem"
local SaleIconItem = class("SaleIconItem", BaseIconItem);

function SaleIconItem:New()
    self = { };
    setmetatable(self, { __index = SaleIconItem });
    return self
end

function SaleIconItem:_InitOther()
 

end

function SaleIconItem:_DisposeOther()
  
end

function SaleIconItem:_UpdateOther()
   
end 

return SaleIconItem