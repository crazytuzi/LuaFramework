require "Core.Module.Common.UIComponent"

SelSkillButton = class("SelSkillButton", UIComponent)
 
function SelSkillButton:New(index)
    self = { };
    setmetatable(self, { __index = SelSkillButton });
    self.index = index or 1;
    return self;
end 

function SelSkillButton:_Init()
    local txts = UIUtil.GetComponentsInChildren(self._transform, "UILabel");
    local imgs = UIUtil.GetComponentsInChildren(self._transform, "UISprite");
    self._txtLevel = UIUtil.GetChildInComponents(txts, "txtLevel");
    self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
    self._button = UIUtil.GetComponent(self._gameObject, "UIButton");
    self._toggle = UIUtil.GetComponent(self._gameObject, "UIToggle");
    self._imgIcon = UIUtil.GetChildInComponents(imgs, "imgIcon");
    self.txtbg = UIUtil.GetChildInComponents(imgs, "txtbg");
    self._imgIcon.gameObject:SetActive(false);
    if (self._button) then
        self._onClick = function(go) self:_OnClick() end
        UIUtil.GetComponent(self._button, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
    end
end

function SelSkillButton:Select(selected)
    if (self._toggle) then
        self._toggle:Set(selected);
    end
end

function SelSkillButton:SetEnable(enabled)
    if (self._button) then
        self._button.isEnabled = enabled;
    end
end

function SelSkillButton:_OnClick()
    if (self._clickCallback) then
        self._clickCallback(self);
    end
end

function SelSkillButton:SetSkill(skill)
    -- if (self._skill ~= skill) then
    self._skill = skill;
    if (skill) then
        if (self._txtLevel) then
            self._txtLevel.text = skill.skill_lv;
        end
        if (self._txtName) then
            self._txtName.text = skill.name;
        end
        self._imgIcon.spriteName = skill.icon_id;
        self._imgIcon.gameObject:SetActive(true);


    else
        self._imgIcon.gameObject:SetActive(false);

        if self.txtbg ~= nil then
            self.txtbg.gameObject:SetActive(false);
        end

        if (self._txtLevel) then
            self._txtLevel.text = "";
        end
        if (self._txtName) then
            self._txtName.text = "";
        end
        -- end
    end
end

function SelSkillButton:GetSkill()
    return self._skill;
end

function SelSkillButton:AddClickListener(func)
    self._clickCallback = func;
end

function SelSkillButton:_Dispose()
    if (self._button) then
        UIUtil.GetComponent(self._button, "LuaUIEventListener"):RemoveDelegate("OnClick");
        self._onClick = nil;
    end
    self._clickCallback = nil;

    self._txtLevel = nil;
    self._txtName = nil;
    self._button = nil;
    self._toggle = nil;
    self._imgIcon = nil;
    self.txtbg = nil;


end
