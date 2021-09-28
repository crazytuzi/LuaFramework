require "Core.Module.Common.UIItem"

GuildSkillItem = UIItem:New();

function GuildSkillItem:_Init()
    local txts = UIUtil.GetComponentsInChildren(self.transform, "UILabel");
    self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
    self._txtLv = UIUtil.GetChildInComponents(txts, "txtLv");
    self._txtMax = UIUtil.GetChildInComponents(txts, "txtMax");
    self._txtEffect = UIUtil.GetChildInComponents(txts, "txtEffect");
    self._txtNextEffect = UIUtil.GetChildInComponents(txts, "txtNextEffect");
    self._txtCost = UIUtil.GetChildInComponents(txts, "txtCost");
    self._txtNoLevel = UIUtil.GetChildInComponents(txts, "txtNoLevel");

    self._icoCost = UIUtil.GetChildByName(self.transform, "UISprite", "icoCost");

    self._imgTaskIco = UIUtil.GetChildByName(self.transform, "UISprite", "imgTaskIco");
    self._imgHighLight = UIUtil.GetChildByName(self.transform, "UISprite", "imgHighLight");
    self._imgHighLight.gameObject:SetActive(false);

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self:UpdateItem(self.data);
end

function GuildSkillItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
end

function GuildSkillItem:_OnClickBtn()
    MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_SKILL_ITEM_SELECTED, self.data);
end

function GuildSkillItem:UpdateItem(data)
    self.data = data;
    if data then
        
        self._txtName.text = data.name;
        self._txtLv.text = data.level;

        if data._tabIdx == 1 then
            self._txtMax.text = GuildDataManager.GetSkillResLev(data.id);
            self._txtNoLevel.text = "";
            self._txtLv.gameObject:SetActive(true);
        else
            local max = GuildDataManager.GetSkillMaxByType(data.type);
            if max > 0 then
                self._txtLv.gameObject:SetActive(true);
                self._txtMax.text = GuildDataManager.GetSkillMaxByType(data.type);
                self._txtNoLevel.text = "";

            else
                self._txtMax.text = "";
                self._txtLv.gameObject:SetActive(false);
                self._txtNoLevel.text = LanguageMgr.Get("guild/skill/noLevel", {level = data.research_level});
            end
        end

        self._txtEffect.text = GuildSkillItem.GetEffectStr(data);
        if data.level < data.levelMax then
            local nextCfg = GuildDataManager.GetSkillInCache(data.type, data.level + 1);
            local nextEffStr = nextCfg and GuildSkillItem.GetEffectStr(nextCfg) or "";
            self._txtNextEffect.text = LanguageMgr.GetColor("d", nextEffStr);
        else
            self._txtNextEffect.text = LanguageMgr.Get("guild/skill/max");
        end
        

        local field = data._tabIdx == 1 and data.study_need_item or data.research_need_item;
        local cost = tonumber(string.split(field, "_")[2]);

        local myVal = data._tabIdx == 1 and GuildDataManager.GetSkillPoint() or GuildDataManager.GetMoney();

        if myVal >= cost then
            self._txtCost.text = LanguageMgr.GetColor("g", cost);    
        else
            self._txtCost.text = LanguageMgr.GetColor("r", cost);
        end
        

        self._icoCost.spriteName = data._tabIdx == 1 and "pvpPoint" or "xianmengzijin";
    end
    
end

function GuildSkillItem:UpdateSelected(val)
    if self._imgHighLight then
        self._imgHighLight.gameObject:SetActive(self.data == val);
    end
end

function GuildSkillItem.GetEffectStr(cfg)
    local attr = cfg.attr;
    -- if attr == "phy_att" and PlayerManager.GetMyCareerDmgType() == 2 then
    --     attr = "mag_att";
    -- end
    return LanguageMgr.Get("attr/" .. attr) .. "+" .. cfg.attrVal;
end