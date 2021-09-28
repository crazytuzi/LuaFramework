require "Core.Module.Common.UIItem"
require "Core.Module.Compose.View.Item.ComposeListItem"

--合成分类Item
ComposeTypeItem = UIItem:New();

function ComposeTypeItem:_Init()
    self._icoBg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");
    self._icoFlag = UIUtil.GetChildByName(self.transform, "UISprite", "icoFlag");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    
    self._redPoint = UIUtil.GetChildByName(self.transform, "UISprite", "redPoint");
    self._redPoint.alpha = 1;

    self._phalanxInfo = UIUtil.GetChildByName(self.transform, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, ComposeListItem);

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self._icoBg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self:UpdateItem(self.data);
end

function ComposeTypeItem:SetItemSelect(default)
    self:OnItemChange(default);
end

function ComposeTypeItem:OnItemChange(data)
    local items = self._phalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        item:SetSelect(data);
    end
end

function ComposeTypeItem:_Dispose()

    self._phalanx:Dispose();

    UIUtil.GetComponent(self._icoBg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
    
end

function ComposeTypeItem:_OnClickBtn()
    if self._expand then
        self:SetExpand(false);
    else
        self:SetExpand(true);
    end
    MessageManager.Dispatch(ComposeNotes, ComposeNotes.ENV_COMPOSE_TYPE_CHG, self.data);
end

function ComposeTypeItem:SetExpand(v)
    self._expand = v;
    self._icoFlag.gameObject:SetActive(v);
    self._phalanxInfo.gameObject:SetActive(v);
end

function ComposeTypeItem:UpdateItem(data)
    self.data = data;
    
    if data then
        items = ComposeManager.GetListByType(data);

        local count = #items;
        self._phalanx:Build(count, 1, items);

        self._txtName.text = LanguageMgr.Get("compose/type/".. data);
    else
    	self._txtName.text = "";
    end
end

function ComposeTypeItem:UpdateRedPoint()
    local show = false;
    local items = self._phalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        show = item:UpdateRedPoint() or show;
    end
    self._redPoint.alpha = show and 1 or 0;
end
