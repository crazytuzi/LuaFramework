require "Core.Module.Common.UIComponent"
require "Core.Module.AutoFight.View.Item.SelSkillButton"

DefSkillPanel = class("DefSkillPanel", UIComponent)

function DefSkillPanel:New()
    self = { };
    setmetatable(self, { __index = DefSkillPanel });
    return self;
end 

function DefSkillPanel:_Init()
    self._bg = UIUtil.GetChildByName(self._gameObject, "UISprite", "bg");
    self._onBGClick = function(go) self:_OnBGClick() end
    UIUtil.GetComponent(self._bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onBGClick);

    self._onClickBtn1 = function(go) self:_OnClickBtn1(self) end
    self._onClickBtn2 = function(go) self:_OnClickBtn2(self) end
    self._onClickBtn3 = function(go) self:_OnClickBtn3(self) end

    local skills1 = UIUtil.GetChildByName(self._gameObject, "Transform", "skills1");
    self:_InitSkillPanel(skills1, 1);

    local skills2 = UIUtil.GetChildByName(self._gameObject, "Transform", "skills2");
    self:_InitSkillPanel(skills2, 2);

    local skills3 = UIUtil.GetChildByName(self._gameObject, "Transform", "skills3");
    self:_InitSkillPanel(skills3, 3);
end

function DefSkillPanel:_InitSkillPanel(skillPanel, index)
    local HeroInfo = PlayerManager.hero.info;
    local defSkills = HeroInfo["auto_skill" .. index];


    local sk1_go = UIUtil.GetChildByName(skillPanel.gameObject, "Transform", "skill1");
    local sk1 = SelSkillButton:New(1);
    sk1:Init(sk1_go);
    sk1:SetSkill(HeroInfo:GetSkill(defSkills[1]));

    local sk2_go = UIUtil.GetChildByName(skillPanel.gameObject, "Transform", "skill2");
    local sk2 = SelSkillButton:New(2);
    sk2:Init(sk2_go);
    sk2:SetSkill(HeroInfo:GetSkill(defSkills[2]));

    local sk3_go = UIUtil.GetChildByName(skillPanel.gameObject, "Transform", "skill3");
    local sk3 = SelSkillButton:New(3);
    sk3:Init(sk3_go);
    sk3:SetSkill(HeroInfo:GetSkill(defSkills[3]));

    local sk4_go = UIUtil.GetChildByName(skillPanel.gameObject, "Transform", "skill4");
    local sk4 = SelSkillButton:New(4);
    sk4:Init(sk4_go);
    sk4:SetSkill(HeroInfo:GetSkill(defSkills[4]));

    self["_btn" .. index] = UIUtil.GetChildByName(skillPanel.gameObject, "UIButton", "btnSelect");
    if (self["_btn" .. index]) then
        if (index == 1) then
            UIUtil.GetComponent(self["_btn" .. index], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn1);
        elseif (index == 2) then
            UIUtil.GetComponent(self["_btn" .. index], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn2);
        elseif (index == 3) then
            UIUtil.GetComponent(self["_btn" .. index], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn3);
        end
    end
end

function DefSkillPanel:AddChangeListener(changeFunc)
    self._changeFunc = changeFunc
end

function DefSkillPanel:_OnBGClick()
    self:SetActive(false);
end

function DefSkillPanel:_OnClickBtn1()
    if (self._changeFunc) then
        self._changeFunc(PlayerManager.hero.info.auto_skill1);
        self:SetActive(false);
    end
end

function DefSkillPanel:_OnClickBtn2()
    if (self._changeFunc) then
        self._changeFunc(PlayerManager.hero.info.auto_skill2);
        self:SetActive(false);
    end
end

function DefSkillPanel:_OnClickBtn3()
    if (self._changeFunc) then
        self._changeFunc(PlayerManager.hero.info.auto_skill3);
        self:SetActive(false);
    end
end

function DefSkillPanel:_Dispose()
    UIUtil.GetComponent(self._bg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onBGClick = nil;

    if (self["_btn1"]) then
        UIUtil.GetComponent(self["_btn1"], "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    if (self["_btn2"]) then
        UIUtil.GetComponent(self["_btn2"], "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    if (self["_btn3"]) then
        UIUtil.GetComponent(self["_btn3"], "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    self._onClickBtn1 = nil;
    self._onClickBtn2 = nil;
    self._onClickBtn3 = nil;

      self._bg = nil;
    self._onBGClick = nil;

end