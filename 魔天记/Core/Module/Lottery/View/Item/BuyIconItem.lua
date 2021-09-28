local BaseIconItem = require "Core.Module.Common.BaseIconItem"
local BuyIconItem = class("BuyIconItem", BaseIconItem);

function BuyIconItem:New()
    self = { };
    setmetatable(self, { __index = BuyIconItem });
    return self
end

function BuyIconItem:_InitOther()

    self._byuiEffect = UIEffect:New()
    self._byuiEffect:Init(self._imgQuality.transform.parent, self._imgQuality, 0, "ui_treasury3", 3)
    self._byuiEffect:Play()

end

function BuyIconItem:_DisposeOther()
    if self._byuiEffect then self._byuiEffect:Dispose() self._byuiEffect = nil end
end

function BuyIconItem:_UpdateOther()

end 

return BuyIconItem