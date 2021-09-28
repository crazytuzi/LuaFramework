require "Core.Module.Common.UIItem"
--合成列表Item
ComposeListItem = UIItem:New();

function ComposeListItem:_Init()

	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
	self._trsItem = UIUtil.GetChildByName(self.transform, "Transform", "trsItem");
	self._item = PropsItem:New();
	self._itemGo = UIUtil.GetUIGameObject(ResID.UI_PropsItem);
	UIUtil.AddChild(self._trsItem, self._itemGo.transform);
	self._item:Init(self._itemGo, nil);

    self._redPoint = UIUtil.GetChildByName(self.transform, "UISprite", "redPoint");
    self._redPoint.alpha = 0;
	
    self._icon_select = UIUtil.GetChildByName(self.transform, "UISprite", "icon_select");
	self._icon_select.gameObject:SetActive(false);

	self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self:UpdateItem(self.data);
end

function ComposeListItem:SetSelect(v)
	self._icon_select.gameObject:SetActive(self.data == v);
end

function ComposeListItem:_Dispose()
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
    
    self._item:Dispose();
    Resourcer.Recycle(self._itemGo, true);
end

function ComposeListItem:_OnClickBtn()
    if self.data then
        MessageManager.Dispatch(ComposeNotes, ComposeNotes.ENV_COMPOSE_ITEM_CHG, self.data);
    end
end

function ComposeListItem:UpdateItem(data)
    self.data = data;
    
    if data then
    	local spId = data.target;
    	local d = ProductInfo:New();
        d:Init({spId = spId, am = 1});
        self._item:UpdateItem(d);

        self._txtName.text = LanguageMgr.GetColor(d:GetQuality(), d:GetName());
    else
    	self._txtName.text = "";
    end
end

function ComposeListItem:UpdateRedPoint()
    local enough = false;
    if self.data then
        local param = string.split(self.data.demand_item, "_");
        local spId = tonumber(param[1]);
        local num = tonumber(param[2]);
        enough = BackpackDataManager.GetProductTotalNumBySpid(spId) >= num;

        local needMoney = tonumber(string.split(self.data.demand_cost, "_")[2]);
        enough = enough and MoneyDataManager.Get_money() >= needMoney;
    end
    self._redPoint.alpha = enough and 1 or 0;
    return enough;
end
