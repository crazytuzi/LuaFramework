require "Core.Module.Common.UIComponent"

TheurgySkillItem = class("TheurgySkillItem", UIComponent)

function TheurgySkillItem:New(transform)
    self = { };
    setmetatable(self, { __index = TheurgySkillItem });
    if (transform) then
        self:Init(transform);
    end
    return self;
end

function TheurgySkillItem:_Init()
    self._imgIcon = UIUtil.GetChildByName(self._transform, "UISprite", "imgIcon");
    self._txtName = UIUtil.GetChildByName(self._transform, "UILabel", "txtName");
    self._txtType = UIUtil.GetChildByName(self._transform, "UILabel", "txtType");
    self._txtDesc = UIUtil.GetChildByName(self._transform, "UILabel", "txtDesc");

    self._txtUsed = UIUtil.GetChildByName(self._transform, "UILabel", "txtUsed");
    self._btnUse = UIUtil.GetChildByName(self._transform, "UIButton", "btnUse");


    self._onClickUseHandler = function(go) self:_OnClickUseHandler() end
    UIUtil.GetComponent(self._btnUse, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickUseHandler);
end

function TheurgySkillItem:_Dispose()
    UIUtil.GetComponent(self._btnUse, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickUseHandler = nil;
    self._btnUse = nil;
    self._imgIcon = nil;
    self._txtName = nil;
    self._txtType = nil;
    self._txtDesc = nil;
    self._txtUsed = nil;
end

function TheurgySkillItem:SetData(idx, layer, skill, blLearn, blUsed)
    if (layer and skill) then
        local isLearn = blLearn or false;
        local isUsed = isLearn and(blUsed or false);
        self._imgIcon.spriteName = skill.icon_id;
        self._txtName.text = skill.name .. "  Lv." .. skill.skill_lv;
        self._txtType.text = LanguageMgr.Get("skill/type" .. skill.skill_type);
        self._txtDesc.text = skill.skill_desc;
        if (isLearn) then
            self._imgIcon.color = Color.New(1, 1, 1)
            if (isUsed) then
                self._txtUsed.gameObject:SetActive(true)
                self._btnUse.gameObject:SetActive(false)
            else
                self._txtUsed.gameObject:SetActive(false)
                self._btnUse.gameObject:SetActive(true)
            end
        else
            self._imgIcon.color = Color.New(0, 0, 0)
            self._txtUsed.gameObject:SetActive(false)
            self._btnUse.gameObject:SetActive(false)
        end
    end
    self._idx = idx
    self._layer = layer;
    self._skill = skill;    
end

function TheurgySkillItem:_OnClickUseHandler()
    if (self._layer and self._skill) then        
        RealmProxy.ChooseSkill(self._layer, self._skill.id, self._idx)
    end
end

function TheurgySkillItem:SetSkill(skill)

end

function TheurgySkillItem:GetSkill()

end

