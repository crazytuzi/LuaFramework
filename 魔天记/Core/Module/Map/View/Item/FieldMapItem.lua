require "Core.Module.Common.UIItem"

local FieldMapItem = class("FieldMapItem", UIItem);

function FieldMapItem:New()
    self = { };
    setmetatable(self, { __index = FieldMapItem });
    return self
end

function FieldMapItem:_Init()
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtname")
    self._txtlev = UIUtil.GetChildByName(self.transform, "UILabel", "txtlev")
    self.trsSelect = UIUtil.GetChildByName(self.transform, "UISprite", "trsSelect")
    self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
    self._onClickItem = function(go) self:_OnClickItem(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
    self:UpdateItem(self.data)
end 

function FieldMapItem:UpdateItem(data)
    self.data = data
    self._txtName.text = self.data.name
    self._txtlev.text = "Lv." .. self.data.lev
    if data.seleted then self:_OnClickItem() end
end

function FieldMapItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil
end
 
function FieldMapItem:_OnClickItem()
    self._toggle.value = true
    self.data.panel:SelectItem(self.data)
end
return FieldMapItem