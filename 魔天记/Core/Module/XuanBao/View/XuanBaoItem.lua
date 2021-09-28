require "Core.Module.Common.UIItem"

local XuanBaoItem = UIItem:New();

local itemCount = 5;

function XuanBaoItem:_Init()

	--self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtDesc = UIUtil.GetChildByName(self.transform, "UILabel", "txtDesc");
    self._icoAward = UIUtil.GetChildByName(self.transform, "UISprite", "icoAward");
    self._btnAward = UIUtil.GetChildByName(self.transform, "UIButton", "btnAward");
    self._icoStatus = UIUtil.GetChildByName(self.transform, "UISprite", "icoStatus");
    self._txtProgress = UIUtil.GetChildByName(self.transform, "UILabel", "txtProgress");
    self._txtRec = UIUtil.GetChildByName(self.transform, "UILabel", "txtRec");

    self._onClickBtnAward = function(go) self:_OnClickBtnAward() end
    UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAward);
    self._btnAward.gameObject:SetActive(false);

    self._btnGoto = UIUtil.GetChildByName(self.transform, "UIButton", "btnGoto");
    self._onClickBtnGoto = function(go) self:_OnClickBtnGoto() end
    UIUtil.GetComponent(self._btnGoto, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGoto);
    self._btnGoto.gameObject:SetActive(false);

    self._icoFlags = {};
    self._items = {};
    for i = 1, itemCount do
        local itemGo = UIUtil.GetChildByName(self.transform, "Transform", "trsItem" .. i).gameObject;
        self._items[i] = PropsItem:New();
        self._items[i]:Init(itemGo, nil);

        self._icoFlags[i] = UIUtil.GetChildByName(itemGo, "UISprite", "icoFlag");
    end

    self:UpdateItem(self.data);
end
--[[
function XuanBaoItem:SetSelect(v)
	self._icon_select.gameObject:SetActive(self.data == v);
end
]]
function XuanBaoItem:_Dispose()
    for i = 1, itemCount do
        self._items[i]:Dispose();
    end

    UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAward = nil;
    self._btnAward = nil;

    UIUtil.GetComponent(self._btnGoto, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGoto = nil;
    self._btnGoto = nil;
end

local insert = table.insert;
local careerIds = {
    [101000] = 1; [102000] = 2; [103000] = 3; [104000] = 4;
}

function XuanBaoItem:UpdateItem(data)
    self.data = data;
    
    if data then

      local type = data.type;

        local awards = {};
        local career = PlayerManager.GetPlayerKind();

        local p = data["recommend_"..careerIds[career]];
        for i, v in ipairs(p) do 
            local item = string.split(v, "_");
            local d = ProductInfo:New();
            d:Init({spId = tonumber(item[1]), am = tonumber(item[2])});
            insert(awards, d);
        end
        
        local award = XuanBaoManager.GetAwrad(self.data.id);
        
        local p = {};
        if award and award.p ~= "" then
            p = string.split(award.p, ",");
        end
        
        local count = 0;
        for i = 1, itemCount do 
            if awards[i] then
                self._icoFlags[i].alpha = XuanBaoItem.ShowFlag(data.condition[i], data, p) and 1 or 0;
                self._items[i]:UpdateItem(awards[i]);
                self._items[i]:SetClassType(type);
                self._items[i]:SetVisible(true);
                count = count + 1;
            else
                self._icoFlags[i].alpha = 0;
                self._items[i]:UpdateItem(nil);
                self._items[i]:SetVisible(false);
            end
        end

        if data.type ~= 3 then
            local posX = 150 - 90 * (5 - count);
            self._txtRec.transform.localPosition = Vector3.New(posX,-13,0);    
            self._txtRec.gameObject:SetActive(true);
        else
            self._txtRec.gameObject:SetActive(false);
        end
        
        self._icoAward.spriteName = data.reward_icon;
        self._txtDesc.text = data.des or "";

        local x = self._txtDesc.transform.localPosition.x + self._txtDesc.width + 10;
        local _pos = self._icoAward.transform.localPosition;
        _pos.x = x;
        self._icoAward.transform.localPosition = _pos;
        
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

local contains = table.contains;
function XuanBaoItem.ShowFlag(id, cfg, p)
    if cfg.type ~= 3 then
        return false;
    end

    return contains(p, tostring(id));
end

function XuanBaoItem:UpdateStatus()
    local award = XuanBaoManager.GetAwrad(self.data.id);
    
    local st = award and award.st or 0;
    self._btnAward.gameObject:SetActive(st == 1);
    self._icoStatus.gameObject:SetActive(st > 1);
    --Warning(st .. " - " .. tostring(SystemManager.IsOpen(self.data.fun_id)))
    self._btnGoto.gameObject:SetActive(st == 0 and self.data.fun_id > 0 and SystemManager.IsOpen(self.data.fun_id));
    self._canGetAward = st == 1;

    local cur = award and award.num or 0;
    if cur > self.data.parameter then
        cur = self.data.parameter;
    end

    if cur < self.data.parameter then
        self._txtProgress.text = LanguageMgr.Get("common/progress/0", {num = cur, max = self.data.parameter});
    else
        self._txtProgress.text = LanguageMgr.Get("common/progress/1", {num = cur, max = self.data.parameter});
    end
end

function XuanBaoItem:_OnClickBtnAward()
    SequenceManager.TriggerEvent(SequenceEventType.Guide.XUANBAO_AWARD);
    if self._canGetAward then
        XuanBaoProxy.ReqGetAward(self.data.id);
    end
end

function XuanBaoItem:_OnClickBtnGoto()
    if self.data then
        SystemManager.Nav(self.data.fun_id);
        --ModuleManager.SendNotification(DaysTargetNotes.CLOSE_DAYSTARGET_PANEL);
    end
end

return XuanBaoItem;