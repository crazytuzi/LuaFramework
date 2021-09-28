require "Core.Module.Common.UIItem"

RankClsSubItem = UIItem:New();

function RankClsSubItem:_Init()
    self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "txtTitle");
    self._icoSelect = UIUtil.GetChildByName(self.transform, "UISprite", "icoSelect");
    self._icoSelect.gameObject:SetActive(false);

    self._onClick = function(go) self:_OnClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick); 

    self:UpdateItem(self.data);
end

function RankClsSubItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;
end

function RankClsSubItem:UpdateItem(data)
    self.data = data;
    
    if data then
        --self._phalanx
        self._txtTitle.text = LanguageMgr.Get("rank/item/" .. self.data);
    else
        self._txtTitle.text = "";
    end
end

function RankClsSubItem:_OnClick()
    MessageManager.Dispatch(RankNotes, RankNotes.ENV_CLS_SELECT, self.data);
end

function RankClsSubItem:UpdateSelected(data)
    local selected = false;
    if (self.data ~= nil) then
         selected = self.data == data;
    end
    self._icoSelect.gameObject:SetActive(selected);
end