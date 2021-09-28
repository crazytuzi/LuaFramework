require "Core.Module.Common.UIItem"

DaysRankItem = UIItem:New();
local itemCount = 3;

function DaysRankItem:_Init()

	--self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtDesc = UIUtil.GetChildByName(self.transform, "UILabel", "txtDesc");
    
    self._btnAward = UIUtil.GetChildByName(self.transform, "UIButton", "btnAward");
    self._txtAward = UIUtil.GetChildByName(self.transform, "UILabel", "txtAward");
    self._onClickBtnAward = function(go) self:_OnClickBtnAward() end
    UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAward);

    self._items = {};
    self._itemGos = {};
    for i = 1, itemCount do
        local trsItem = UIUtil.GetChildByName(self.transform, "Transform", "trsItem"..i);
        local itemGo = UIUtil.GetUIGameObject(ResID.UI_PropsItem);
        UIUtil.AddChild(trsItem, itemGo.transform);
        self._itemGos[i] = itemGo;
        self._items[i] = PropsItem:New();
        self._items[i]:Init(itemGo, nil);
        self._items[i]:AddBoxCollider();
    end

    self:UpdateItem(self.data);
end

function DaysRankItem:SetSelect(v)
	self._icon_select.gameObject:SetActive(self.data == v);
end

function DaysRankItem:_Dispose()
    for i = 1, itemCount do
        self._items[i]:Dispose();
        Resourcer.Recycle(self._itemGos[i], true);
    end

    UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAward = nil;
    self._btnAward = nil;
end

local insert = table.insert;

function DaysRankItem:UpdateItem(data)
    self.data = data;
    
    if data then
        local awards = {};

        local cItem = TaskUtils.GetCareerAward(data.career_reward);
        if cItem then
            insert(awards, cItem);
        end

        for i, v in ipairs(data.reward) do 
            local item = string.split(v, "_");
            local d = ProductInfo:New();
            d:Init({spId = tonumber(item[1]), am = tonumber(item[2])});
            insert(awards, d);
        end

        for i = 1, itemCount do 
            if awards[i] then
                self._items[i]:UpdateItem(awards[i]);
                self._items[i]:SetVisible(true);
            else
                self._items[i]:UpdateItem(nil);
                self._items[i]:SetVisible(false);
            end
        end

        --self._txtName.text = LanguageMgr.Get("daysRank/list/rank", data);
        self._txtDesc.text = data.desc or "";

        self:UpdateStatus();
    else
    	--self._txtName.text = "";
        self._txtDesc.text = "";
        for i = 1, itemCount do 
            self._items[i]:UpdateItem(nil);
            self._items[i]:SetVisible(false);
        end
    end
end

function DaysRankItem:UpdateStatus()
    local st = DaysRankProxy.GetAward(self.data.id, self.data.reward_rank);
    self._btnAward.gameObject:SetActive(st == 0);
    self._txtAward.gameObject:SetActive(st > 0);
    --local txt = st > 0 and LanguageMgr.Get("common/btn/noAward") or LanguageMgr.Get("common/btn/award");
    --self._btnLabel.text = txt;
    self._canGetAward = st == 0;
end

function DaysRankItem:_OnClickBtnAward()
    if self._canGetAward then
        DaysRankProxy.ReqRankAward(self.data.id);
    end
end