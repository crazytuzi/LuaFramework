require "Core.Module.Common.UISubPanel";
require "Core.Module.Skill.View.Item.SkillSettingItem";


SkillSettingPanel = class("SkillSettingPanel", UISubPanel);

function SkillSettingPanel:_InitReference()

    self._trsToggle = UIUtil.GetChildByName(self._transform, "Transform", "trsToggle");
    self._btnSetting1 = UIUtil.GetChildByName(self._trsToggle, "UIButton", "btnSetting1");
    self._btnSetting2 = UIUtil.GetChildByName(self._trsToggle, "UIButton", "btnSetting2");
    self._trsTalent1 = UIUtil.GetChildByName(self._trsToggle, "Transform", "trsTalent1");
    self._trsTalent2 = UIUtil.GetChildByName(self._trsToggle, "Transform", "trsTalent2");
    self._icoTalentSel1 = UIUtil.GetChildByName(self._trsTalent1, "UISprite", "icoSel");
    self._icoTalentSel2 = UIUtil.GetChildByName(self._trsTalent2, "UISprite", "icoSel");

    self._trsTheurgy1 = UIUtil.GetChildByName(self._trsToggle, "Transform", "trsTheurgy1");
    self._trsTheurgy2 = UIUtil.GetChildByName(self._trsToggle, "Transform", "trsTheurgy2");
    self._icoTheurgySel1 = UIUtil.GetChildByName(self._trsTheurgy1, "UISprite", "icoSel");
    self._icoTheurgySel2 = UIUtil.GetChildByName(self._trsTheurgy2, "UISprite", "icoSel");

    self._txtUsing = UIUtil.GetChildByName(self._transform, "UILabel", "txtUsing");
    self._btnApply = UIUtil.GetChildByName(self._transform, "UIButton", "btnApply");
    self._btnTuiJian = UIUtil.GetChildByName(self._transform, "UIButton", "btnTuijian");

    self._listTr = UIUtil.GetChildByName(self._transform, "Transform", "skillList")
    self._phalanxInfo = UIUtil.GetChildByName(self._listTr, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, SkillSettingItem);

    self._curSkillTr = UIUtil.GetChildByName(self._transform, "Transform", "curSkill");
    self._icoBaseAtk = UIUtil.GetChildByName(self._curSkillTr, "UISprite", "icoAtk");
    self._onCurSkillClick = function(index) self:_OnCurSkillClick(index) end;
    self.skillItems = { };
    for i = 1, 4 do
        local itemTr = UIUtil.GetChildByName(self._curSkillTr, "Transform", "skill" .. i);
        local item = SkillSettingItem:New();
        item:Init(itemTr.gameObject);
        item.index = i;
        self.skillItems[i] = item;
    end

    self._txtLevels = {};
    self._trsTxts = UIUtil.GetChildByName(self._transform, "Transform", "trsTxts")
    local txts = UIUtil.GetComponentsInChildren(self._trsTxts, "UILabel");
    for i=1,8 do
        self._txtLevels[i] = UIUtil.GetChildInComponents(txts, "txtLevel" .. i);
    end

    self._onToggleSetting = function(go) self:_OnToggleSetting(go) end;
    UIUtil.GetComponent(self._btnSetting1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onToggleSetting);
    UIUtil.GetComponent(self._btnSetting2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onToggleSetting);
    self._onTogTalent = function(go) self:_OnTogTalent(go) end;
    UIUtil.GetComponent(self._trsTalent1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTogTalent);
    UIUtil.GetComponent(self._trsTalent2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTogTalent);

    self._onTogTheurgy = function(go) self:_OnTogTheurgy(go) end;
    UIUtil.GetComponent(self._trsTheurgy1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTogTheurgy);
    UIUtil.GetComponent(self._trsTheurgy2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTogTheurgy);

    self._onApplyClick = function(go) self:_OnApplyClick() end;
    UIUtil.GetComponent(self._btnApply, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onApplyClick);
    self._onTuiJianClick = function(go) self:_OnTuiJianClick() end;
    UIUtil.GetComponent(self._btnTuiJian, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTuiJianClick);


    self.curIdx = 1;

    self:_OnChooseTheurgy();
end

function SkillSettingPanel:_InitListener()
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_TALENT_CHG, SkillSettingPanel._UpdateSkillInfo, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_SKILL_CHG, SkillSettingPanel._UpdateSettingInfo, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_ITEMCLICK, SkillSettingPanel._OnItemClick, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_ITEM_DRAGSTART, SkillSettingPanel._OnItemDragStart, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_ITEM_DRAGDROP, SkillSettingPanel._OnItemDrop, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_SKILL_SLOT_OPEN, SkillSettingPanel.OnSkillSlotOpen, self);
    MessageManager.AddListener(RealmNotes, RealmNotes.EVENT_CHOOSETHEURGY, SkillSettingPanel._OnChooseTheurgy, self);
    MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, SkillSettingPanel._UpdateSkillInfo, self);
end

function SkillSettingPanel:_DisposeListener()
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_TALENT_CHG, SkillSettingPanel._UpdateSkillInfo);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_SKILL_CHG, SkillSettingPanel._UpdateSettingInfo);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_ITEMCLICK, SkillSettingPanel._OnItemClick);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_ITEM_DRAGSTART, SkillSettingPanel._OnItemDragStart, self);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_ITEM_DRAGDROP, SkillSettingPanel._OnItemDrop);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_SKILL_SLOT_OPEN, SkillSettingPanel.OnSkillSlotOpen);
    MessageManager.RemoveListener(RealmNotes, RealmNotes.EVENT_CHOOSETHEURGY, SkillSettingPanel._OnChooseTheurgy);
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, SkillSettingPanel._UpdateSkillInfo);
end

function SkillSettingPanel:_DisposeReference()
    self._onCurSkillClick = nil;

    for i, v in ipairs(self.skillItems) do
        v:Dispose();
    end

    self._phalanx:Dispose();

    UIUtil.GetComponent(self._btnSetting1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnSetting2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onToggleSetting = nil;
    UIUtil.GetComponent(self._trsTalent1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._trsTalent2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onTogTalent = nil;
    UIUtil.GetComponent(self._trsTheurgy1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._trsTheurgy2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onTogTheurgy = nil;
    UIUtil.GetComponent(self._btnApply, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onApplyClick = nil;
    UIUtil.GetComponent(self._btnTuiJian, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onTuiJianClick = nil;
    self._btnTuiJian = nil;

    self._trsTheurgy1 = nil;
    self._trsTheurgy2 = nil;
    self._icoTheurgySel1 = nil;
    self._icoTheurgySel2 = nil;
end

function SkillSettingPanel:_OnEnable()
    self:UpdateDisplay();
end

function SkillSettingPanel:_OnToggleSetting(go)
    local idx = tonumber(string.sub(go.name, 11));

    if idx ~= self.curIdx then
        self.curIdx = idx;
        self:_UpdateSettingInfo();
    end
end

function SkillSettingPanel:UpdateDisplay()
    self:_UpdateSkillInfo();
    self:_UpdateSettingInfo();
end

function SkillSettingPanel:_UpdateSkillInfo()
    local heroInfo = PlayerManager.GetPlayerInfo();
    local skillIds = heroInfo:GetSkills();
    -- heroInfo:GetSkillList();
    local count = #skillIds;
    self._phalanx:Build(1, count, skillIds);

    for i = 1, 8 do
        if skillIds[i] then
            local skill = skillIds[i];
            if (skill) then
                local refSkill = SkillManager.RefSkillId(skill.id);
                if (refSkill ~= skill.id) then
                    skill = heroInfo:GetSkill(refSkill)
                end
            end
            self._txtLevels[i].text = LanguageMgr.Get("skill/itemDesc", {name = skill.name, lv = skill.skill_lv});
        else
            self._txtLevels[i].text = "";
        end
    end

    self._btnTuiJian.gameObject:SetActive(heroInfo.level >= 15);
end

function SkillSettingPanel:_UpdateSettingInfo()
    local heroInfo = PlayerManager.GetPlayerInfo();
    -- 更新技能信息
    for i = 1, 4 do
        local skill = heroInfo:GetSkillByIndex(i, self.curIdx);
        if skill then
            self.skillItems[i]:UpdateItem(skill);
        else
            self.skillItems[i]:UpdateItem(nil);
        end
    end

    self._icoBaseAtk.spriteName = heroInfo:GetBaseSkill().icon_id;

    -- 更新开关内容
    local setting = heroInfo:GetSkillSetInfo();
    self.curSetTid = setting["t" .. self.curIdx];
    self.curTheurgyTid = setting["s" .. self.curIdx];

    self._icoTalentSel1.gameObject:SetActive(self.curSetTid == 1);
    self._icoTalentSel2.gameObject:SetActive(self.curSetTid == 2);

    self._icoTheurgySel1.gameObject:SetActive(self.curTheurgyTid == 1);
    self._icoTheurgySel2.gameObject:SetActive(self.curTheurgyTid == 2);

    self._btnApply.gameObject:SetActive(setting.id ~= self.curIdx);
    self._txtUsing.gameObject:SetActive(setting.id == self.curIdx);

    self.skillSet = heroInfo:GetSkillSet();

end

function SkillSettingPanel:_OnChooseTheurgy()
    local idx = RealmManager.GetTheurgy();
    self._icoTheurgySel1.gameObject:SetActive(idx == 1);
    self._icoTheurgySel2.gameObject:SetActive(idx == 2);
end

function SkillSettingPanel:_OnApplyClick()
    self:_SetActSettingId();
end

function SkillSettingPanel:_OnTuiJianClick()
    local heroInfo = PlayerManager.GetPlayerInfo();
    local kind = heroInfo.kind;
    local level = heroInfo.level;
    local dict = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILL_RECOMMEND);
    local cfg = nil;
    for k, v in pairs(dict) do
        if v.career_id == kind and v.level_limit <= level then
            cfg = v;
        end
    end
    if cfg then
        local data = nil;
        local skSet = cfg["skill_" .. self.curIdx];
        for i, v in ipairs(skSet) do
            -- 检查技能id, 如果可用则替换位置.
            if SkillSettingPanel.SkillCanUse(v) then
                data = self:SetSkillToIndex(i, v, data);
            end
        end
        self:Save(data);
    else
        Error("can't find skill_recommend");
    end
end

-- 技能点击
function SkillSettingPanel:_OnItemClick(data)
    if data then
        --显示tips
        ModuleManager.SendNotification(SkillNotes.OPEN_SKILL_TIPS_PANEL, data);
    end
end

function SkillSettingPanel:_OnItemDragStart(item, go)
    SequenceManager.TriggerEvent(SequenceEventType.Guide.SKILL_SETTING_TOUCH_BEGIN);
end

-- 技能拖放
function SkillSettingPanel:_OnItemDrop(item, go)
    if go then
        local goName = go.name;
        if string.sub(goName, 1, 5) == "skill" then
            local sId = item.data.id;

            local toIdx = tonumber(string.sub(goName, 6));
            local heroInfo = PlayerManager.GetPlayerInfo();
            if heroInfo.level < heroInfo.skillslot_open[toIdx] then
                --等级未开放
                return;
            end

            local fromIdx = 0;
            local fromName = item.transform.name;
            if string.sub(fromName, 1, 5) == "skill" then
                fromIdx = tonumber(string.sub(fromName, 6));
            end

            if fromName == goName then
                SequenceManager.TriggerEvent(SequenceEventType.Guide.SKILL_SETTING_TOUCH_CANCEL);
                return;
            end

            local d = self:SetSkillToIndex(toIdx, sId);

            if fromIdx > 0 then
                local exId = self.skillItems[toIdx].data;
                exId = exId and exId.id or 0;
                d = self:SetSkillToIndex(fromIdx, exId, d);
            end
            self:Save(d);
            SequenceManager.TriggerEvent(SequenceEventType.Guide.SKILL_SETTING_TOUCH_END);
        else
            SequenceManager.TriggerEvent(SequenceEventType.Guide.SKILL_SETTING_TOUCH_CANCEL);
        end
    end
end

-- 天赋切换
function SkillSettingPanel:_OnTogTalent(go)
    local tId = tonumber(string.sub(go.name, 10));
    if tId ~= self.curSetTid then
        local a = self.curIdx == 1 and 6 or 12;
        local data = string.split(self.skillSet, "_");
        data[a] = tId;
        self:Save(data);
        if tonumber(data[1]) == self.curIdx then
            SkillProxy.ReqActiveTalent(tId);
        end
    end
end

-- 天赋切换
function SkillSettingPanel:_OnTogTheurgy(go)
    local tId = tonumber(string.sub(go.name, 11));
    if tId ~= self.curTheurgyTid then
        local a = self.curIdx == 1 and 7 or 13;
        local data = string.split(self.skillSet, "_");
        data[a] = tId;
        self:Save(data);
        if tonumber(data[1]) == self.curIdx then
            if (RealmManager.GetTheurgy() ~= tId) then
                RealmProxy.ChooseTheurgy(tId);
            end
        end
    end
end

function SkillSettingPanel.SkillCanUse(skillId)
    local heroInfo = PlayerManager.GetPlayerInfo();
    local skills = heroInfo:GetSkills();
    for i, v in ipairs(skills) do
        if skillId == v.id then
            return v.skill_lv > 1 or v.req_lv <= heroInfo.level;
        end
    end
    return false;
end

-- 设置技能位置.
function SkillSettingPanel:SetSkillToIndex(index, skillId, data)
    if data == nil then
        data = string.split(self.skillSet, "_");
    end
    local a = self.curIdx == 1 and 2 or 8;
    a = a + index - 1;
    --data[a] = skillId;
    data[a] = SkillManager.InverseRefSkillId(skillId);
    return data;
end

-- 设置当前配置为激活配置
function SkillSettingPanel:_SetActSettingId()
    local newStr = self.curIdx .. string.sub(self.skillSet, 2);
    self:Save(nil, newStr);
    SkillProxy.ReqActiveTalent(self.curSetTid);
    if (RealmManager.GetTheurgy() ~= self.curTheurgyTid) then
        RealmProxy.ChooseTheurgy(self.curTheurgyTid);
    end
end

function SkillSettingPanel:Save(data, str)
    if str == nil then
        str = table.concat(data, "_")
    end
    if str ~= self.lastStr then
        SkillProxy.ReqSaveSkillSet(str);
        self.lastStr = str;
    end
end

function SkillSettingPanel:OnSkillSlotOpen(index)
    if self.skillItems[index] then
        self.skillItems[index]:PlayUnlockEff();
    end
end
