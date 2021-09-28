require "Core.Module.Common.UIItem"

DaysTargetItem = UIItem:New();
local itemCount = 2;

function DaysTargetItem:_Init()

	--self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtDesc = UIUtil.GetChildByName(self.transform, "UILabel", "txtDesc");
    self._txtTips = UIUtil.GetChildByName(self.transform, "UILabel", "txtTips");
    self._icon = UIUtil.GetChildByName(self.transform, "UISprite", "icon");
    self._btnAward = UIUtil.GetChildByName(self.transform, "UIButton", "btnAward");
    self._txtAward = UIUtil.GetChildByName(self.transform, "UILabel", "txtAward");
    self._onClickBtnAward = function(go) self:_OnClickBtnAward() end
    UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAward);
    self._btnAward.gameObject:SetActive(false);

    self._btnGoto = UIUtil.GetChildByName(self.transform, "UIButton", "btnGoto");
    self._onClickBtnGoto = function(go) self:_OnClickBtnGoto() end
    UIUtil.GetComponent(self._btnGoto, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGoto);
    self._btnGoto.gameObject:SetActive(false);

    self._txtProgress = UIUtil.GetChildByName(self.transform, "UILabel", "txtProgress");
    self._progress = UIUtil.GetChildByName(self.transform, "UISlider", "icoProgress");
    self._progress.value = 0;

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

function DaysTargetItem:SetSelect(v)
	self._icon_select.gameObject:SetActive(self.data == v);
end

function DaysTargetItem:_Dispose()
    for i = 1, itemCount do
        self._items[i]:Dispose();
        Resourcer.Recycle(self._itemGos[i], true);
    end

    UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAward = nil;
    self._btnAward = nil;

    UIUtil.GetComponent(self._btnGoto, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGoto = nil;
    self._btnGoto = nil;
end

local insert = table.insert;

function DaysTargetItem:UpdateItem(data)
    self.data = data;
    
    if data then

        local awards = {};
        local kind = PlayerManager.GetPlayerKind();
        for i, v in ipairs(data.reward) do
            local item = string.split(v, "_");
            if tonumber(item[3]) == kind then
                local d = ProductInfo:New();
                d:Init({spId = tonumber(item[1]), am = tonumber(item[2])});
                insert(awards, d);
            end
        end
        --[[
        local cItem = TaskUtils.GetCareerAward(data.career_reward);
        if cItem then
            insert(awards, cItem);
        end
        ]]
        for i = 1, itemCount do 
            if awards[i] then
                self._items[i]:UpdateItem(awards[i]);
                self._items[i]:SetVisible(true);
            else
                self._items[i]:UpdateItem(nil);
                self._items[i]:SetVisible(false);
            end
        end

        local cfg = SystemManager.GetCfg(data.icon);
        self._icon.spriteName = cfg and cfg.icon or data.icon;
        self._icon:MakePixelPerfect();

        self._txtDesc.text = data.des or "";
        self._txtTips.text = data.reward_des or "";
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

function DaysTargetItem:UpdateStatus()
    local award = DaysTargetProxy.GetAwrad(self.data.id);
    
    local st = award and award.st or 0;
    self._btnAward.gameObject:SetActive(st == 1);
    self._txtAward.gameObject:SetActive(st > 1);
    --Warning(st .. " - " .. tostring(SystemManager.IsOpen(self.data.fun_id)))
    self._btnGoto.gameObject:SetActive(st == 0 and SystemManager.IsOpen(self.data.fun_id));
    self._canGetAward = st == 1;

    local cur = award and award.num or 0;
    local p = cur / self.data.parameter;
    self._progress.value = p;

    self._txtProgress.text = cur .. "/" .. self.data.parameter;

end

function DaysTargetItem:_OnClickBtnAward()
    if self._canGetAward then
        DaysTargetProxy.ReqGetAward(self.data.id);
    end
end

function DaysTargetItem:_OnClickBtnGoto()
    if self.data then
        DaysTargetPanel.OpenSys(self.data.fun_id);
        ModuleManager.SendNotification(DaysTargetNotes.CLOSE_DAYSTARGET_PANEL);
    end
end