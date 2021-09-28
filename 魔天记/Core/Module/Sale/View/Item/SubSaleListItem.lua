require "Core.Module.Common.UIItem"

SubSaleListItem = class("SubSaleListItem", UIItem);
function SubSaleListItem:New()
    self = { };
    setmetatable(self, { __index = SubSaleListItem });
    return self
end


function SubSaleListItem:_Init()
    self:_InitReference();
    self:_InitListener();
    self:UpdateItem(self.data)
end

function SubSaleListItem:_InitReference()
    self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
    self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "title")
end

function SubSaleListItem:_InitListener()
    self._onClickItem = function(go) self:_OnClickItem(self) end
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end

function SubSaleListItem:_OnClickItem()
    SaleManager.SetCurSelectKind(self.data.k)
    ModuleManager.SendNotification(SaleNotes.UPDATE_SCROLLVIEW)
    SaleProxy.SendGetSaleList()
end

function SubSaleListItem:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function SubSaleListItem:_DisposeReference()

end

function SubSaleListItem:_DisposeListener()
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;
end

function SubSaleListItem:UpdateItem(data)
    self.data = data
    if (self.data) then
        self._txtTitle.text = self.data.name
    end
end

function SubSaleListItem:SetToggleActive(enable)
    self._toggle.value = enable
    self:_OnClickItem()
end