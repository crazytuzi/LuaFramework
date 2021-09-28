require "Core.Module.Common.UIComponent"

SkillItemButton = class("SkillItemButton", UIComponent)
 
function SkillItemButton:New()
    self = { };
    setmetatable(self, { __index = SkillItemButton });
    return self;
end 

function SkillItemButton:_Init()
    local txts = UIUtil.GetComponentsInChildren(self._transform, "UILabel");
    local imgs = UIUtil.GetComponentsInChildren(self._transform, "UISprite");

    self._button = UIUtil.GetComponent(self._gameObject, "UIButton");
    self._toggle = UIUtil.GetComponent(self._gameObject, "UIToggle");
    self._txtLock = UIUtil.GetChildInComponents(txts, "txtLock");
    self._txtLevel = UIUtil.GetChildInComponents(txts, "txtLevel");
    self._imgIcon = UIUtil.GetChildInComponents(imgs, "imgIcon");
    self._imgSymbol1 = UIUtil.GetChildInComponents(imgs, "imgSymbol1");
    self._imgSymbol2 = UIUtil.GetChildInComponents(imgs, "imgSymbol2");

    self._txtLock.gameObject:SetActive(false);
    self._imgSymbol1.gameObject:SetActive(false);
    self._imgSymbol2.gameObject:SetActive(false);

    self._onClick = function(go) self:_OnClick() end
    UIUtil.GetComponent(self._button, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
end

function SkillItemButton:Select(selected)
    if (self._toggle) then
        self._toggle.value = (selected);
    end
end

function SkillItemButton:SetEnable(enabled)
    if (self._button) then
        self._button.isEnabled = enabled;
    end
end

function SkillItemButton:_OnClick()
    if (self._clickCallback) then
        self._clickCallback(self);
    end
end

function SkillItemButton:SetSkill(skill)
    if (self._skill ~= skill and skill) then
        self._skill = skill;
        self._imgIcon.spriteName = skill.icon_id;
    end
    self:Refresh();
end

function SkillItemButton:GetSkill()
    return self._skill;
end

function SkillItemButton:AddClickListener(func)
    self._clickCallback = func;
end

function SkillItemButton:Refresh()
    local skill = self._skill;
    local heroInfo = PlayerManager.GetPlayerInfo();
    if (skill) then
        self._txtLevel.text = GetLvDes(skill.skill_lv);
        if (skill.req_lv <= heroInfo.level) then
            self._txtLock.gameObject:SetActive(false);
            self._button.isEnabled = true;
        else
            self._txtLock.text = "角色" .. skill.req_lv .. "级开放";
            self._txtLock.gameObject:SetActive(true);
            self._button.isEnabled = false;
        end
    else
        self._button.isEnabled = false;
    end
end