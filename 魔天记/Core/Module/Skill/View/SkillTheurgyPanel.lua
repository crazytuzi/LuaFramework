require "Core.Module.Common.UISubPanel";
require "Core.Module.Skill.View.Item.TheurgyListItem"

local skillCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILL);

SkillTheurgyPanel = class("SkillTheurgyPanel", UISubPanel)

function SkillTheurgyPanel:_InitReference()
    self._realmLevel = RealmManager.GetRealmLevel();

    self._btnTog1 = UIUtil.GetChildByName(self._transform, "UIButton", "trsToggle/btnTog1");
    self._btnTog2 = UIUtil.GetChildByName(self._transform, "UIButton", "trsToggle/btnTog2");

    self._trsList = UIUtil.GetChildByName(self._transform, "Transform", "trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._scrollPanel = UIUtil.GetComponent(self._trsList, "UIPanel");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, TheurgyListItem);

    self._onTogClick = function(go) self:_OnTogClick(go) end
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTogClick);
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTogClick);
    
    self._index = 1;
    InstanceDataManager.UpData(function()
    self:_BuildList(self._index);
    end, self)
end

function SkillTheurgyPanel:_GetAllRealmSkillData(sks, index)
    local skills = { };
    local xlCeng = RealmProxy.GetXLTier()
    for i = 1, 7 do
 
        local info = RealmManager.GetFairy(i, 1)
        local info2 = RealmManager.GetFairy(i, 2)
        skills[i] = { }
        if info and info2 then
            local rsk = skills[i]
            rsk.layer = i;
            rsk.name = info.name
            rsk.skills = { };
            local sid = info.skill
            local s = self:_GetSkillById(sid)
            s.enabled = info.num <= xlCeng
            rsk.enabled = s.enabled
            if rsk.enabled and sks[i] == 0 then
                RealmManager.SetRealmSkill(i, sid, index)
                sks[i] = sid
            end
            rsk.skills[1] = s
            sid = info2.skill
            s = self:_GetSkillById(sid)
            s.enabled = info2.num <= xlCeng
            if not rsk.enabled then rsk.enabled = s.enabled end
            if rsk.enabled and sks[i] == 0 then
                RealmManager.SetRealmSkill(i, sid, index)
                sks[i] = sid
            end
            --Warning(sks[i] .. ','..xlCeng .. '___' .. info.num .. '_' ..info2.num)
            rsk.skills[2] = s
        end
    end
    return skills;
end

function SkillTheurgyPanel:_GetSkillById(id)
    local heroInfo = PlayerManager.hero.info;
    if (heroInfo) then
        local skill = heroInfo:GetSkill(id);
        if (skill) then
            return skill;
        end
    end
    return skillCfg[id .. "_1"];
end

function SkillTheurgyPanel:_GetList(index, blCreate)
    local skills = RealmManager.GetRealmSkills(index);
    if (blCreate) then
        if (self._allRealmSkillDatas) then
            self._allRealmSkillDatas = nil;
        end
        self._allRealmSkillDatas = self:_GetAllRealmSkillData(skills, index);
    end
    for i, v in ipairs(self._allRealmSkillDatas) do
        v.idx = index;
        if (skills[i] ~= 0) then
            local sks = v.skills;
            if (sks) then
                for j, jv in pairs(sks) do
                    if (skills[i] == jv.id) then
                        v.currSkill = jv;
                    end
                end
            end
        end
    end
    return self._allRealmSkillDatas;
end

function SkillTheurgyPanel:_BuildList(index)
    local allRealmSkillDatas = self:_GetList(index, true);
    local count = #allRealmSkillDatas;
    self._phalanx:Build(count, 1, allRealmSkillDatas);
end

function SkillTheurgyPanel:_UpdateList()
    local allRealmSkillDatas = self:_GetList(self._index, false);
    local items = self._phalanx:GetItems();
    for ii, vv in ipairs(items) do
        vv.itemLogic:UpdateItem();
    end
end

function SkillTheurgyPanel:OnChooseRealmSkill()
    self:_UpdateList();
end 

function SkillTheurgyPanel:_InitListener()
    MessageManager.AddListener(RealmNotes, RealmNotes.EVENT_CHOOSEREALMSKILL, SkillTheurgyPanel.OnChooseRealmSkill, self);
end

function SkillTheurgyPanel:_DisposeListener()
    MessageManager.RemoveListener(RealmNotes, RealmNotes.EVENT_CHOOSEREALMSKILL, SkillTheurgyPanel.OnChooseRealmSkill, self);
end

function SkillTheurgyPanel:_DisposeReference()
    self._allRealmSkillDatas = nil;
    self._realmLevel = nil;
    self._btnTog1 = nil;
    self._btnTog2 = nil;
    self._trsList = nil;
    self._scrollView = nil;
    self._scrollPanel = nil;
    self._phalanxInfo = nil;
    self._phalanx:Dispose();
    self._phalanx = nil;
end

function SkillTheurgyPanel:_OnEnable()

end


function SkillTheurgyPanel:_Refresh()

end

function SkillTheurgyPanel:_OnTogClick(go)
    local idx = go and(go.name == "btnTog1" and 1 or 2) or 1;
    if idx ~= self._index then
        self._index = idx;
        self:_BuildList(self._index);
    end
end