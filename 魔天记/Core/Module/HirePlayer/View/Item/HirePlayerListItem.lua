require "Core.Module.Common.UIItem"

HirePlayerListItem = UIItem:New();

function HirePlayerListItem:_Init()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "imgIcon");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "txtLevel");
    self._txtFight = UIUtil.GetChildByName(self.transform, "UILabel", "txtFight");
    self._txtCost = UIUtil.GetChildByName(self.transform, "UILabel", "txtCost");
    self._togSelected = UIUtil.GetChildByName(self.transform, "UIToggle", "togSelected");

    self._onClickHandler = function(go) self:_OnClickHandler(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHandler);

    self:UpdateItem(self.data);
end

function HirePlayerListItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickHandler = nil
    self._togSelected = nil;
    self._imgIcon = nil;
    self._txtName = nil;
    self._txtLevel = nil;
    self._txtFight = nil;
    self._txtCost = nil;
end

function HirePlayerListItem:SetSelected(val)
    self._togSelected.value = val
end

function HirePlayerListItem:GetSelected()
    return self._togSelected.value;
end

function HirePlayerListItem:_OnClickHandler()
    MessageManager.Dispatch(HirePlayerNotes, HirePlayerNotes.EVENT_CLICK_LISTITEM, self);
end

function HirePlayerListItem:UpdateItem(data)
    self.data = data;
    if (data) then
        self._imgIcon.spriteName = data.k..""
        self._txtName.text = data.pn
        self._txtLevel.text = data.lv
        self._txtFight.text = data.ft
        self._txtCost.text = data.money
    end
end
