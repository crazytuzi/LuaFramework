require "Core.Module.Common.UIComponent"
require "Core.Module.Skill.View.Item.PostureSkillButton"

PosturePanel = class("PosturePanel", UIComponent)
local insert = table.insert
 
function PosturePanel:New()
    self = { };
    setmetatable(self, { __index = PosturePanel });
    return self;
end 

function PosturePanel:_Init()
    local txts = UIUtil.GetComponentsInChildren(self._transform, "UILabel");
    local imgs = UIUtil.GetComponentsInChildren(self._transform, "UISprite");
    local heroInfo = PlayerManager.GetPlayerInfo();
    local bSkill = heroInfo:GetBaseSkill();

    self._onSkillButonClick = function(go)
        self._selSkillBtn = go;
        self:_SelectSkillButton(go)
    end

    self._txtPosturelName = UIUtil.GetChildInComponents(txts, "txtPosturelName");
    self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
    self._txtAttrib = UIUtil.GetChildInComponents(txts, "txtAttrib");
    self._txtDsc = UIUtil.GetChildInComponents(txts, "txtDsc");


    self._imgAttackIcon = UIUtil.GetChildInComponents(imgs, "imgAttackIcon");
    self._imgAttackIcon.spriteName = bSkill.icon_id;

    self._toggle = UIUtil.GetChildByName(self._gameObject, "UIToggle", "btnPosture");
    self._btnPosture = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnPosture");
    self._onChangePostureClick = function(go) self:_OnChangePostureClick() end
    UIUtil.GetComponent(self._btnPosture, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onChangePostureClick);

    self._skillButtons = { };

    local btnSkill1_go = UIUtil.GetChildByName(self._gameObject, "Transform", "btnStanceSkill1");
    local btnSkill1 = PostureSkillButton:New(1);
    btnSkill1:Init(btnSkill1_go);
    btnSkill1:AddClickListener(self._onSkillButonClick);
    insert(self._skillButtons, 1, btnSkill1);

    local btnSkill2_go = UIUtil.GetChildByName(self._gameObject, "Transform", "btnStanceSkill2");
    local btnSkill2 = PostureSkillButton:New(2);
    btnSkill2:Init(btnSkill2_go);
    btnSkill2:AddClickListener(self._onSkillButonClick);
    insert(self._skillButtons, 2, btnSkill2);

    local btnSkill3_go = UIUtil.GetChildByName(self._gameObject, "Transform", "btnStanceSkill3");
    local btnSkill3 = PostureSkillButton:New(3);
    btnSkill3:Init(btnSkill3_go);
    btnSkill3:AddClickListener(self._onSkillButonClick);
    insert(self._skillButtons, 3, btnSkill3);

    local btnSkill4_go = UIUtil.GetChildByName(self._gameObject, "Transform", "btnStanceSkill4");
    local btnSkill4 = PostureSkillButton:New(4);
    btnSkill4:Init(btnSkill4_go);
    btnSkill4:AddClickListener(self._onSkillButonClick);
    insert(self._skillButtons, 4, btnSkill4);
end

function PosturePanel:GetSkills()
    local skills = { };
    for i, v in pairs(self._skillButtons) do
        local skill = v:GetSkill();
        if (skill) then
            insert(skills, i, skill.id);
        else
            insert(skills, i, 0);
        end
    end
    return skills;
end

function PosturePanel:SetInfo(info)
    local heroInfo = PlayerManager.GetPlayerInfo();
    local skills = heroInfo:GetPostureSkills(info.id);
    self._info = info;
    self._txtPosturelName.text = self._info.name;
    self._txtName.text = "";
    self._txtAttrib.text = self._info.add_desc;
    self._txtDsc.text = self._info.desc;
    if (skills ~= nil) then
        for i, v in pairs(self._skillButtons) do
            v:SetSkill(skills[i]);
        end
    end
end

function PosturePanel:GetInfo()
    return self._info;
end

function PosturePanel:Select(selected)
    if (self._toggle) then
        self._toggle.value = (selected);
        -- self._btnPosture.isEnabled =(selected ~= true);
    end
end

function PosturePanel:_OnChangePostureClick()
    if (self._info) then
        self._changePosture(self._info.id);
    end
end

function PosturePanel:_SelectSkillButton(go)
    if (self._clickCallback and go) then
        self._selBtn = go;
        self._clickCallback(go, self._info.id);
    end
end

function PosturePanel:SetSkillByButton(go, skill)
    if (go) then
        go:SetSkill(skill);
        for i, v in pairs(self._skillButtons) do
            if (v ~= go and v:GetSkill() == skill) then
                v:SetSkill(nil);
            end
        end
    end
end

function PosturePanel:AddClickListener(selectButton, changePosture)
    self._clickCallback = selectButton;
    self._changePosture = changePosture
end


function PosturePanel:_Dispose()
    UIUtil.GetComponent(self._btnUpgrade, "LuaUIEventListener"):RemoveDelegate("OnClick");
end