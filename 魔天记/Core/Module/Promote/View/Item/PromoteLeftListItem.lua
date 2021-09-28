require "Core.Module.Common.UIItem"

PromoteLeftListItem = UIItem:New();

function PromoteLeftListItem:_Init()
    self.isSelected = false
    self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "txtTitle");
    self._imgSelect = UIUtil.GetChildByName(self.transform, "UISprite", "imgSelect");

    self._onClickHandler = function(go) self:_OnClickHandler(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHandler);

    self:UpdateItem(self.data);
end

function PromoteLeftListItem:_OnClickHandler()
    if (self.isSelected ~= true) then
        self:SetSelected(true);
    end
end

function PromoteLeftListItem:_Dispose()
    self._txtTitle = nil;
    self._imgSelect = nil;

    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickHandler = nil;
end

function PromoteLeftListItem:SetSelected(val)
    if (val ~= nil) then
        if (self.isSelected ~= val) then
            self.isSelected = val;
            self:Refresh();
            if (val == true) then
                MessageManager.Dispatch(PromoteNotes, PromoteNotes.EVENT_CHOOSE_BRANCH, self)
            end
        end
    end
end

function PromoteLeftListItem:Refresh()
    if (self._imgSelect) then
        self._imgSelect.gameObject:SetActive(self.isSelected);
    end
end

function PromoteLeftListItem:UpdateItem(data)
    self.data = data;
    if (self._txtTitle) then
        if (data) then
            self._txtTitle.text = data.name;
        else
            self._txtTitle.text = "";
        end
    end
end
