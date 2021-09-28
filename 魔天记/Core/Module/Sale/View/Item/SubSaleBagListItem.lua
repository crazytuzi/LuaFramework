require "Core.Module.Common.UIItem"
require "Core.Module.Sale.View.Item.SubSaleBagItem"

SubSaleBagListItem = class("SubSaleBagListItem", UIItem);
function SubSaleBagListItem:New()
    self = { };
    setmetatable(self, { __index = SubSaleBagListItem });
    return self
end


function SubSaleBagListItem:_Init()
    self:_InitReference();
    self:_InitListener();
    self:UpdateItem(self.data)
end

function SubSaleBagListItem:_InitReference()
    self._phalanxInfo = UIUtil.GetComponent(self.transform, "LuaAsynPhalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, SubSaleBagItem, true)
end

function SubSaleBagListItem:_InitListener()

end

function SubSaleBagListItem:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end 

function SubSaleBagListItem:_DisposeReference()
    if (self._phalanx) then
        self._phalanx:Dispose()
        self._phalanx = nil
    end
end

function SubSaleBagListItem:_DisposeListener()

end

function SubSaleBagListItem:UpdateItem(data)
    self.data = data
    self._phalanx:Build(6, 5, self.data)
end