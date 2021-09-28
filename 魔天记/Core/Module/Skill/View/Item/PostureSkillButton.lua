require "Core.Module.Common.UIComponent"

PostureSkillButton = class("PostureSkillButton", UIComponent)
 
function PostureSkillButton:New(index)
    self = { };
    setmetatable(self, { __index = PostureSkillButton });
    self.index = index or 1;
    return self;
end 

function PostureSkillButton:_Init()
    local txts = UIUtil.GetComponentsInChildren(self._transform, "UILabel");
    local imgs = UIUtil.GetComponentsInChildren(self._transform, "UISprite");

    self._button = UIUtil.GetComponent(self._gameObject, "UIButton");
    self._imgIcon = UIUtil.GetChildInComponents(imgs, "imgIcon");
    self._imgIcon.gameObject:SetActive(false);
    self._onClick = function(go) self:_OnClick() end
    UIUtil.GetComponent(self._button, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
end

function PostureSkillButton:_OnClick()
    if (self._clickCallback) then
        self._clickCallback(self);
    end
end

function PostureSkillButton:SetSkill(skill)
    if (self._skill ~= skill) then
        self._skill = skill;
        if (skill) then
            self._imgIcon.spriteName = skill.icon_id;
            self._imgIcon.gameObject:SetActive(true);
        else
            self._imgIcon.gameObject:SetActive(false);
        end
    end
end

function PostureSkillButton:GetSkill()
    return self._skill;
end

function PostureSkillButton:AddClickListener(func)
    self._clickCallback = func;
end