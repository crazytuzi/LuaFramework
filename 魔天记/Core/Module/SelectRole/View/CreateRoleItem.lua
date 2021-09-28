require "Core.Module.Common.UIItem"

CreateRoleItem = UIItem:New();
 
-- function CreateRoleItem:UpdateItem(data)
--    self.data = data
-- end

function CreateRoleItem:_Init()
    self.toggle = UIUtil.GetComponent(self.gameObject, "UIToggle");
    self._txtRoleName = UIUtil.GetChildByName(self.transform, "UILabel", "Label");
    self._imgHeroIcon = UIUtil.GetChildByName(self.transform, "UISprite", "heroIcon");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
    self._imgHeroIcon.spriteName = self:getKindIconName(self.data.id);
    self._txtRoleName.text = self.data.career;
    --    self:UpdateItem(self.data);
end

function CreateRoleItem:getKindIconName(kind)
    if kind == 101000 then
        return "heroIcon1";
    elseif kind == 102000 then
        return "heroIcon2";
    elseif kind == 103000 then
        return "heroIcon3";
    elseif kind == 104000 then
        return "heroIcon4";
    end

    return "";

end

-- function CreateRoleItem:SetSelect(v)
--    self.toggle:Set(v);
-- end

function CreateRoleItem:_OnClickBtn()
    ModuleManager.SendNotification(SelectRoleNotes.CREATEROLEITEM_CHANGE, self.data);
end

function CreateRoleItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
end

