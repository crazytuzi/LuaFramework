require "Core.Module.Common.UIItem"
require "Core.Module.Sale.View.Item.SubSaleListItem"

SubSaleList = class("SubSaleList", UIItem);
function SubSaleList:New()
    self = { };
    setmetatable(self, { __index = SubSaleList });
    return self
end


function SubSaleList:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SubSaleList:_InitReference()
    self._enable = false
    self._phalanxInfo = UIUtil.GetChildByName(self.transform, "LuaAsynPhalanx", "phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, SubSaleListItem)
    self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "title")
    self._trsArrow = UIUtil.GetChildByName(self.transform, "arrow")
    self._phalanxInfo.gameObject:SetActive(self._enable)
end

function SubSaleList:_InitListener()
    self._onClickItem = function(go) self:_OnClickItem() end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end 
local rotate1 = Quaternion.Euler(0, 0, 180)
local rotate2 = Quaternion.Euler(0, 0, 0)

function SubSaleList:_OnClickItem()
    self._enable = not self._enable

    self._trsArrow.transform.localRotation = self._enable and rotate1 or rotate2
    self._phalanxInfo.gameObject:SetActive(self._enable)
    if (self._enable) then
        SaleManager.SetCurSelectType(self.data.t)
        local item = self._phalanx:GetItem(1)
        if (item) then
            item.itemLogic:SetToggleActive(true)
        end
    end
    ModuleManager.SendNotification(SaleNotes.RESET_TABLE, self.index)
end 

function SubSaleList:SetPhalanxActive(enable)
    self._enable = enable
    self._trsArrow.transform.localRotation = self._enable and rotate1 or rotate2
    self._phalanxInfo.gameObject:SetActive(self._enable)
end

function SubSaleList:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function SubSaleList:_DisposeReference()

end

function SubSaleList:_DisposeListener()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;
end

function SubSaleList:UpdateItem(data)
    self.data = data
    if (self.data) then
        self._txtTitle.text = data.name
        self._phalanx:Build(table.getCount(self.data.datas), 1, self.data.datas)
    end
end

function SubSaleList:SetIndex(index)
    self.index = index
end