require "Core.Module.Common.UIItem"
require "Core.Module.Rank.View.Item.RankClsSubItem"

RankClsItem = UIItem:New();

function RankClsItem:_Init()
    self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "txtTitle");

    self._phalanxTr = UIUtil.GetChildByName(self.transform, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxTr, RankClsSubItem);

    self._onClick = function(go) self:_OnClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick); 
   
    self._init = false;
    self._show = false;

    self:UpdateItem(self.data);
end

function RankClsItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;

    self._phalanx:Dispose();
    self._phalanx = nil;
end

function RankClsItem:UpdateItem(data)
    if self._init and self.data ~= data then
        self._init = false;
    end

    self.data = data;
    if data then
        if self._init == false then
            self:UpdateDisplay();
            self._init = true;
        end
        self:UpdateList();
        self._txtTitle.text = LanguageMgr.Get("rank/cls/" .. self.data.id);
    else
        self._txtTitle.text = "";
    end
end

function RankClsItem:_OnClick()
    MessageManager.Dispatch(RankNotes, RankNotes.ENV_CLS_REFRESH, self.data);
end

function RankClsItem:UpdateDisplay()
    if self.data then
        local data = self.data.d;
        local count = table.getn(data);
        self._phalanx:Build(count, 1, data);
    end
end

function RankClsItem:UpdateList()
    if self._show then
        self._phalanxTr.gameObject:SetActive(true);
    else
        self._phalanxTr.gameObject:SetActive(false);
    end
end

function RankClsItem:UpdateStatus(data)

    if self.data == data then
        self._show = not self._show;
        self:UpdateList();
    end
end

function RankClsItem:UpdateSelected(data)
    local items = self._phalanx:GetItems();
    for k, v in pairs(items) do
        v.itemLogic:UpdateSelected(data);
    end
end