require "Core.Module.Common.Panel";

OtherSkillPanel = Panel:New();

function OtherSkillPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function OtherSkillPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");

    -- self._trsTalent = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTalent");    
    -- self._talents = {};
    self._talentIcons = {};
    self._talentLocks = {};
    self._talentLvs = {};
    for i = 1, 4 do 
        -- local item = UIUtil.GetChildByName(self._trsTalent, "Transform", "talent"..i);
        local ico = UIUtil.GetChildByName(item, "UISprite", "icon");
        local lock = UIUtil.GetChildByName(item, "Transform", "ico_lock");
        local lv = UIUtil.GetChildByName(item, "UILabel", "txtLv");
        -- self._talents[i] = item;
        self._talentIcons[i] = ico;
        self._talentLocks[i] = lock;
        self._talentLvs[i] = lv;
    end

    self._trsRealm = UIUtil.GetChildByName(self._trsContent, "Transform", "trsRealm");
    
    self._trsSetting = UIUtil.GetChildByName(self._trsContent, "Transform", "trsSetting");
    self._settings = {};
    self._settingIcons = {};
    self._settingLvs = {};
    for i = 0, 4 do
        local item = UIUtil.GetChildByName(self._trsSetting, "Transform", "setting"..i);
        local ico = UIUtil.GetChildByName(item, "UISprite", "icon");
        local lv = UIUtil.GetChildByName(item, "UILabel", "txtLv");
        self._settings[i] = item;
        self._settingIcons[i] = ico;
        self._settingLvs[i] = lv;
    end

    self._trsSkills = UIUtil.GetChildByName(self._trsContent, "Transform", "trsSkills");
    self._skills = {};
    self._skillIcons = {};
    self._skillLocks = {};
    self._skillLvs = {};
    for i = 1, 8 do
        local item = UIUtil.GetChildByName(self._trsSkills, "Transform", "skill"..i);
        local ico = UIUtil.GetChildByName(item, "UISprite", "icon");
        local lock = UIUtil.GetChildByName(item, "Transform", "ico_lock");
        local lv = UIUtil.GetChildByName(item, "UILabel", "txtLv");
        self._skills[i] = item;
        self._skillIcons[i] = ico;
        self._skillLocks[i] = lock;
        self._skillLvs[i] = lv;
    end

    self._trsSkillInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsSkillInfo");
    self._detailClose = UIUtil.GetChildByName(self._trsSkillInfo, "UIButton", "btnClose");
    self._dtTxtName = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "txtName");
    self._dtIcoSkill = UIUtil.GetChildByName(self._trsSkillInfo, "UISprite", "icoSkill");
    self._dtIcoTalent = UIUtil.GetChildByName(self._trsSkillInfo, "UISprite", "icoTalent");
    self._dtTxtLevel = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "titleLevel/txtLevel");
    self._dtTxtKind = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "titleKind/txtKind");
    self._dtTxtCd = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "titleCd/txtCd");
    self._dtTxtDis = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "titleDis/txtDis");
    self._dtTxtDesc = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "titleDesc/txtDesc");
    self._trsSkillInfo.gameObject:SetActive(false);
end

function OtherSkillPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    self._onClickDetailClose = function(go) self:_OnClickDetailClose(self) end
    UIUtil.GetComponent(self._detailClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickDetailClose);

    self._onTalentClick = function(go) self:_OnTalentClick(go) end
    -- for i, v in ipairs(self._talents) do 
    --     UIUtil.GetComponent(v, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTalentClick);
    -- end

    self._onSettingClick = function(go) self:_OnSettingClick(go) end
    for i, v in ipairs(self._settings) do 
        UIUtil.GetComponent(v, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onSettingClick);
    end

    self._onSkillClick = function(go) self:_OnSkillClick(go) end
    for i, v in ipairs(self._skills) do 
        UIUtil.GetComponent(v, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onSkillClick);
    end
end

function OtherSkillPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function OtherSkillPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;

    UIUtil.GetComponent(self._detailClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickDetailClose = nil;

    -- for i, v in ipairs(self._talents) do 
    --     UIUtil.GetComponent(v, "LuaUIEventListener"):RemoveDelegate("OnClick");
    -- end
    self._onTalentClick = nil;

    for i, v in ipairs(self._settings) do 
        UIUtil.GetComponent(v, "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    self._onSettingClick = nil;

    for i, v in ipairs(self._skills) do 
        UIUtil.GetComponent(v, "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    self._onSkillClick = nil;
end

function OtherSkillPanel:_DisposeReference()
    
end

function OtherSkillPanel:Update(d)
	self.data = d;
    self:UpdateDisplay();
end

function OtherSkillPanel:UpdateDisplay()
	local d = self.data;
    local role = OtherInfoProxy.cache;
    local kind = role.kind;
    local level = role.level;

    --构建天赋数据.
    self.tData = {};
    for i = 1, 4 do
        self.tData[i] = {id = 0, lv = 0};
    end
    local curTalent = d.talent["conf"..d.talent.idx];
    for i,v in ipairs(curTalent) do
        local tmpIdx = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TALENT_MAIN)[v.id].phase;
        self.tData[tmpIdx].id = v.id;
        self.tData[tmpIdx].lv = v.num;
    end

    --==========[天赋设置]=========
    local careerCfg = ConfigManager.GetCareerByKind(kind);
    for i = 1, 4 do 
        if level < careerCfg.talentLv[i] then
            self._talentIcons[i].spriteName = "";
            self._talentLocks[i].gameObject:SetActive(true);
            self._talentLvs[i].text = "";
        else
            local tCfg = SkillManager.GetTalentCfg(self.tData[i].id);
            self._talentIcons[i].spriteName = tCfg and tCfg.icon or "";
            self._talentLocks[i].gameObject:SetActive(false);
            self._talentLvs[i].text = self.tData[i].lv;
        end
    end

    --==========[技能列表]=========
    for i = 1, 8 do
        local sklId = d.skill[i] and d.skill[i].id or 0;
        local sklLv = d.skill[i] and d.skill[i].level or 0;
        local sklCfg = ConfigManager.GetSkillById(sklId, sklLv);
        if d.skill[i] == nil or level < sklCfg.req_lv then
            self._skillIcons[i].spriteName = "";
            self._skillLocks[i].gameObject:SetActive(true);    
            self._skillLvs[i].text = "";
        else
            self._skillIcons[i].spriteName = sklCfg.icon_id;
            self._skillLocks[i].gameObject:SetActive(false);
            self._skillLvs[i].text = sklLv;
        end
    end

    --==========[技能设置]=========
    self.sData = nil;
    if d.skill_set == "" then
        self.sData = careerCfg.default_skill;
    else
        local tmp = string.split(d.skill_set, "_");
        if tmp[1] == "1" then
            self.sData = {tmp[2],tmp[3],tmp[4],tmp[5]};
        else
            self.sData = {tmp[8],tmp[9],tmp[10],tmp[11]};
        end
    end
    --找到技能等级。
    local lvCache = {};
    for i,v in ipairs(self.sData) do
        --如果技能是空改成默认技能.
        if tonumber(v) == 0 then
            self.sData[i] = careerCfg.default_skill[i];
        end
        for n, m in ipairs(d.skill) do
            if m.id == tonumber(self.sData[i]) then
                lvCache[m.id] = m.level;
                break;
            end
        end
    end

    for i = 1, 4 do
        local setId = tonumber(self.sData[i]);
        local sklCfg = ConfigManager.GetSkillById(setId, 1);
        if sklCfg then
            --有等级的才显示.
            local setlv = lvCache[setId] or 0;
            self._settingIcons[i].spriteName = setlv > 0 and sklCfg.icon_id or "";
            self._settingLvs[i].text = setlv;
        else
            self._settingIcons[i].spriteName = "";
            self._settingLvs[i].text = "";
        end
    end

    
end

function OtherSkillPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(OtherInfoNotes.CLOSE_SKILL_PANEL);
end

function OtherSkillPanel:_OnClickDetailClose()
    self._trsSkillInfo.gameObject:SetActive(false);
end

function OtherSkillPanel:_OnTalentClick(go)
    
    local idx = tonumber(string.sub(go.name, -1));
    local curTalent = self.data.talent["conf"..self.data.talent.idx];
    local tId = self.tData[idx].id or 0;
    if tId > 0 then
        local d = {talent = tId, lv = self.tData[idx].lv};
        self:ShowTalentInfo(d);
    end
    
end

function OtherSkillPanel:_OnSettingClick(go)
    local idx = tonumber(string.sub(go.name, -1));
    if self.sData[idx] then
        --要在技能列表里面找等级.
        for i, v in ipairs(self.data.skill) do
            if v.id == tonumber(self.sData[idx]) then 
                local d = {skill = v.id, lv = v.level};
                self:ShowSkillInfo(d);
                return;
            end
        end
    end
    
end

function OtherSkillPanel:_OnSkillClick(go)
    local idx = tonumber(string.sub(go.name, -1));
    local skl = self.data.skill[idx];
    if skl then
        local d = {skill = skl.id, lv = skl.level};
        self:ShowSkillInfo(d);
    end
end

function OtherSkillPanel:ShowSkillInfo(data)
    local cfg = ConfigManager.GetSkillById(data.skill, data.lv);
    if cfg == nil then
        log("can't find skill cfg .. ");
        return;
    end
    self._trsSkillInfo.gameObject:SetActive(true);
    
    self._dtTxtName.text = cfg.name;
    self._dtIcoSkill.gameObject:SetActive(true);
    self._dtIcoTalent.gameObject:SetActive(false);
    self._dtIcoSkill.spriteName = cfg.icon_id;
    self._dtTxtLevel.text = data.lv .. "/" .. cfg.max_lv;
    local cId = string.sub(data.skill, 3, 3);
    self._dtTxtKind.text = LanguageMgr.Get("career/"..cId);
    self._dtTxtCd.text = LanguageMgr.Get("skill/cd", {s = cfg.cd / 100});
    self._dtTxtDis.text = LanguageMgr.Get("skill/dis", {s = cfg.distance / 100});
    self._dtTxtDesc.text = LanguageMgr.GetColor("d", cfg.skill_desc);
end

function OtherSkillPanel:ShowTalentInfo(data)
    local cfg = SkillManager.GetTalentCfg(data.talent);
    local detailCfg = SkillManager.GetTalentDetailCfg(data.talent, data.lv);
    if cfg == nil or detailCfg == nil then
        log("can't find talent cfg .. ");
        return;
    end

    self._trsSkillInfo.gameObject:SetActive(true);

    self._dtTxtName.text = cfg.name;
    self._dtIcoSkill.gameObject:SetActive(false);
    self._dtIcoTalent.gameObject:SetActive(true);
    self._dtIcoTalent.spriteName = cfg.icon;
    self._dtTxtLevel.text = data.lv .. "/" .. cfg.talent_maxlv;

    local cId = string.sub(cfg.career, 3, 3);
    self._dtTxtKind.text = LanguageMgr.Get("career/"..cId);
    self._dtTxtCd.text = "";
    self._dtTxtDis.text = "";
    self._dtTxtDesc.text = LanguageMgr.GetColor("d", SkillManager.GetTalentDesc(detailCfg));
end