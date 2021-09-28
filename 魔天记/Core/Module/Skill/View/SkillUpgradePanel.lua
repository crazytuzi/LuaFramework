require "Core.Module.Common.UISubPanel";
require "Core.Module.Skill.View.Item.SkillItem"


SkillUpgradePanel = class("SkillUpgradePanel", UISubPanel)

function SkillUpgradePanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._transform, "UILabel");
    self._btnUpgrade = UIUtil.GetChildByName(self._transform, "UIButton", "btnUpgrade");
    self._txtSkillName = UIUtil.GetChildInComponents(txts, "txtSkillName");
    self._txtDesc = UIUtil.GetChildInComponents(txts, "txtDesc");
    self._txtEffect = UIUtil.GetChildInComponents(txts, "txtEffect");

    self._txtCost1 = UIUtil.GetChildInComponents(txts, "txtCost1");
    self._txtCost2 = UIUtil.GetChildInComponents(txts, "txtCost2");

    self._txtLevelNotEnough = UIUtil.GetChildInComponents(txts, "txtLevelNotEnough");

    self._listTr = UIUtil.GetChildByName(self._transform, "Transform", "skillList")
    self._phalanxInfo = UIUtil.GetChildByName(self._listTr, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, SkillItem);

    self._onUpgradeButtonClick = function(go) self:_OnUpgradeButtonClick() end
    UIUtil.GetComponent(self._btnUpgrade, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onUpgradeButtonClick);
    
end

function SkillUpgradePanel:_InitListener()
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_ITEMCLICK, SkillUpgradePanel._OnItemClick, self);
    MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_UPGRADE, SkillUpgradePanel.OnSkillUpgrade, self);
    MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, SkillUpgradePanel.OnSkillUpgrade, self);
    MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, SkillUpgradePanel.UpdateMyNum, self);
end

function SkillUpgradePanel:_DisposeListener()
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_ITEMCLICK, SkillUpgradePanel._OnItemClick);
    MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_UPGRADE, SkillUpgradePanel.OnSkillUpgrade);
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, SkillUpgradePanel.OnSkillUpgrade);
    MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, SkillUpgradePanel.UpdateMyNum);
end

function SkillUpgradePanel:_DisposeReference()
    --UpdateBeat:Remove(self.OnUpdate, self);
    self._phalanx:Dispose();

    UIUtil.GetComponent(self._btnUpgrade, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onUpgradeButtonClick = nil;
    self._btnUpgrade = nil;
end

function SkillUpgradePanel:_OnEnable()
    self:UpdateDisplay();
end

function SkillUpgradePanel:UpdateDisplay()
    local heroInfo = PlayerManager.GetPlayerInfo();
    local skills = heroInfo:GetSkills();
    
    self._phalanx:Build(1, #skills, skills);
    if self._curSkill == nil then
        self:SetSelectSkill(skills[1]);
    end
end

function SkillUpgradePanel:_OnItemClick(data)
    self:SetSelectSkill(data);
end

function SkillUpgradePanel:SetSelectSkill(skill)
    if (self._curSkill ~= skill) then
        self._curSkill = skill;
        local items = self._phalanx:GetItems()
        for i, v in ipairs(items) do
            v.itemLogic:SetSelect(v.itemLogic.data == skill or v.itemLogic.skill == skill);
        end

        self:_Refresh();
    end
end

function SkillUpgradePanel:_Refresh()
    local skill = self._curSkill;
    if (skill) then
        local heroInfo = PlayerManager.GetPlayerInfo();
        self._txtSkillName.text = LanguageMgr.Get("skill/nameDesc", {name = skill.name, lv = skill.skill_lv});
        self._txtDesc.text = LanguageMgr.GetColor("d", skill.skill_desc);

        local nextLvCfg = ConfigManager.GetSkillById(skill.id, skill.skill_lv + 1);
        if nextLvCfg then
            self._txtEffect.text = LanguageMgr.GetColor("d", nextLvCfg.skill_desc);
        else
            self._txtEffect.text = "";
        end

        self._txtCost1.text = skill.coin_cost;

        if skill.skill_lv < skill.max_lv then
            if skill.req_lv <= heroInfo.level then
                self._txtLevelNotEnough.gameObject:SetActive(false);
                self._btnUpgrade.isEnabled = true;
            else
                self._txtLevelNotEnough.text = LanguageMgr.Get("skill/upgrade/notLv", {lv = skill.req_lv});
                self._txtLevelNotEnough.gameObject:SetActive(true);
                self._btnUpgrade.isEnabled = false;
            end
        else
            self._txtLevelNotEnough.text = LanguageMgr.Get("skill/upgrade/max");
            self._txtLevelNotEnough.gameObject:SetActive(true);
            self._btnUpgrade.isEnabled = false;
        end
        self:UpdateMyNum();
    else
        self._txtSkillName.text = "";
        self._txtDesc.text = "";
        self._txtEffect.text = "";
        self._btnUpgrade.isEnabled = false;
    end
end

function SkillUpgradePanel:UpdateMyNum()
    local need = self._curSkill.coin_cost;
    local money = MoneyDataManager.Get_money();
    if money >= need then
        self._txtCost2.text = LanguageMgr.GetColor(1, money);
    else
        self._txtCost2.text = LanguageMgr.GetColor(6, money);
    end
end

function SkillUpgradePanel:_OnUpgradeButtonClick()
    local skill = self._curSkill;
    if (skill) then
        --self._btnUpgrade.isEnabled = false;

        if MoneyDataManager.Get_money() >= skill.coin_cost then            
            SkillProxy.ReqUpgrade(SkillManager.InverseRefSkillId(skill.id));
        else
            ProductGetProxy.TryShowGetUI(1, SkillNotes.CLOSE_SKILLPANEL);
            MsgUtils.ShowTips("common/lingshibuzu");
        end

        
    end
    SequenceManager.TriggerEvent(SequenceEventType.Guide.SKILL_UPGRADE);
end

function SkillUpgradePanel:OnSkillUpgrade()
    --self._btnUpgrade.isEnabled = true;
    self:_Refresh();

    local items = self._phalanx:GetItems()
    for i, v in ipairs(items) do
        v.itemLogic:UpdateItem(v.itemLogic.data);
    end
end


