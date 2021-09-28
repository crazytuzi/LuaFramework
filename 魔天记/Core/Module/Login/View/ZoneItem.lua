require "Core.Module.Common.UIItem"

ZoneItem = UIItem:New();
 
function ZoneItem:UpdateItem(data)
    self.data = data
    if self.data and self.data.name then
        self._txtZoneName.text = self.data.name    
    end
end

function ZoneItem:Init(gameObject, data)
    self.gameObject = gameObject
    self._txtZoneName = UIUtil.GetChildByName(self.gameObject.transform, "UILabel", "Label");
    self._icoSelect = UIUtil.GetChildByName(self.gameObject.transform, "UISprite", "icoSelect");
    
    self.data = data;
    
    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
    
    self:UpdateItem(self.data)
    self:UpdateSelected();
end

function ZoneItem:_OnClickBtn()
    LoginProxy.currentZoneIndex = self.data.id;
    MessageManager.Dispatch(LoginNotes, LoginNotes.UPDATE_SELECTSERVER_PANEL);
end

function ZoneItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
end

function ZoneItem:UpdateSelected(id)
    self._icoSelect.gameObject:SetActive(self.data.id == id);
end
