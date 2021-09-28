require "Core.Module.Common.UIComponent"
require "Core.Module.Skill.View.Item.PostureSkillButton"

SelSkillPanel = class("SelSkillPanel", UIComponent)

function SelSkillPanel:New()
    self = { };
    setmetatable(self, { __index = SelSkillPanel });
    return self;
end 

function SelSkillPanel:_Init()
    local HeroInfo = PlayerManager.hero.info;

    self._bg = UIUtil.GetChildByName(self._gameObject, "UISprite", "bg");
    self._onBGClick = function(go) self:_OnBGClick() end
    UIUtil.GetComponent(self._bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onBGClick);

    self._onSkillButonClick = function(go)
        self:_OnSkillButonClick(go)
    end

    local sk1_go = UIUtil.GetChildByName(self._gameObject, "Transform", "skill1");
    local sk1 = SelSkillButton:New(1);
    sk1:Init(sk1_go);
    sk1:SetSkill(HeroInfo:GetDefSkillByIndex(1));
    sk1:AddClickListener(self._onSkillButonClick);

    local sk2_go = UIUtil.GetChildByName(self._gameObject, "Transform", "skill2");
    local sk2 = SelSkillButton:New(2);
    sk2:Init(sk2_go);
    sk2:SetSkill(HeroInfo:GetDefSkillByIndex(2));
    sk2:AddClickListener(self._onSkillButonClick);

    local sk3_go = UIUtil.GetChildByName(self._gameObject, "Transform", "skill3");
    local sk3 = SelSkillButton:New(3);
    sk3:Init(sk3_go);
    sk3:SetSkill(HeroInfo:GetDefSkillByIndex(3));
    sk3:AddClickListener(self._onSkillButonClick);

    local sk4_go = UIUtil.GetChildByName(self._gameObject, "Transform", "skill4");
    local sk4 = SelSkillButton:New(4);
    sk4:Init(sk4_go);
    sk4:SetSkill(HeroInfo:GetDefSkillByIndex(4));
    sk4:AddClickListener(self._onSkillButonClick);

    local sk5_go = UIUtil.GetChildByName(self._gameObject, "Transform", "skill5");
    local sk5 = SelSkillButton:New(5);
    sk5:Init(sk5_go);
    sk5:SetSkill(HeroInfo:GetDefSkillByIndex(5));
    sk5:AddClickListener(self._onSkillButonClick);

    local sk6_go = UIUtil.GetChildByName(self._gameObject, "Transform", "skill6");
    local sk6 = SelSkillButton:New(6);
    sk6:Init(sk6_go);
    sk6:SetSkill(HeroInfo:GetDefSkillByIndex(6));
    sk6:AddClickListener(self._onSkillButonClick);

    local sk7_go = UIUtil.GetChildByName(self._gameObject, "Transform", "skill7");
    local sk7 = SelSkillButton:New(7);
    sk7:Init(sk7_go);
    sk7:SetSkill(HeroInfo:GetDefSkillByIndex(7));
    sk7:AddClickListener(self._onSkillButonClick);

    local sk8_go = UIUtil.GetChildByName(self._gameObject, "Transform", "skill8");
    local sk8 = SelSkillButton:New(8);
    sk8:Init(sk8_go);
    sk8:SetSkill(HeroInfo:GetDefSkillByIndex(8));
    sk8:AddClickListener(self._onSkillButonClick);
end

function SelSkillPanel:AddSelectedListener(selectedFunc)
    self._selectedFunc = selectedFunc
end

function SelSkillPanel:_OnSkillButonClick(go)
    if (go) then
        if (self._selectedFunc) then
            self._selectedFunc(go:GetSkill());
        end
        self:SetActive(false);
    end
end

function SelSkillPanel:_OnBGClick()
    if (self._selectedFunc) then
        self._selectedFunc(nil);
    end
    self:SetActive(false);
end

function SelSkillPanel:_Dispose()
    UIUtil.GetComponent(self._bg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onBGClick = nil;
end