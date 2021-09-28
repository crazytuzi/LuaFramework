require "Core.Module.Common.UIComponent"
require "Core.Module.NewTrump.View.Item.SubNewTrumpSkillItem"
require "Core.Role.ModelCreater.NewTrumpModeCreater"
require "Core.Module.Common.UIAnimationModel"

SubNewTrumpPanel = class("SubNewTrumpPanel", UIComponent);
local pos = Vector3.New(65535, 65535, 0)
function SubNewTrumpPanel:New(transform)
    self = { };
    setmetatable(self, { __index = SubNewTrumpPanel });
    if (transform) then
        self:Init(transform);
    end
    return self
end


function SubNewTrumpPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SubNewTrumpPanel:_InitReference()
    self._tempName = ""
    self._state = { }
    for i = 1, 4 do
        self._state[i] = UIUtil.GetChildByName(self._gameObject, tostring(i - 1)).gameObject
        self._state[i]:SetActive(false)
    end
    self._txtPro1 = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtPro1");
    self._txtPro2 = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtPro2");
    self._btnEquip = UIUtil.GetChildByName(self._state[3], "UIButton", "btnEquip");
    self._btnActive = UIUtil.GetChildByName(self._state[2], "UIButton", "btnActive");
    self._txtCondition = UIUtil.GetChildByName(self._state[1], "UILabel", "txtActiveCondition")
    self._trsActiveSkill = UIUtil.GetChildByName(self._gameObject, "Transform", "trsActiveSkill");
    self._trsPassiveSkill = UIUtil.GetChildByName(self._gameObject, "Transform", "trsPassiveSkill");
    self._txtPower = UIUtil.GetChildByName(self._gameObject, "UILabel", "powerComponet/power")
    self._activeSkillItem = SubNewTrumpSkillItem:New()
    self._activeSkillItem:Init(self._trsActiveSkill)
    self._passiveSkillItem = SubNewTrumpSkillItem:New()
    self._passiveSkillItem:Init(self._trsPassiveSkill)
    -- self._txtCondition.color = ColorDataManager.Get()
    self._trsRoleParent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsRoleParent", true)
end


function SubNewTrumpPanel:_OnClickBtnActive()
    SequenceManager.TriggerEvent(SequenceEventType.Guide.TRUMP_ACTIVITY);
    NewTrumpProxy.SendActiveTrump(self.data.id)
end

function SubNewTrumpPanel:_InitListener()
    self._onClickBtnEquip = function(go) self:_OnClickBtnEquip(self) end
    UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnEquip);
    self._onClickBtnActive = function(go) self:_OnClickBtnActive(self) end
    UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnActive);
end

function SubNewTrumpPanel:_OnClickBtnEquip()
    SequenceManager.TriggerEvent(SequenceEventType.Guide.TRUMP_EQUIP);
    NewTrumpProxy.SendEquipTrump(self.data.id)
end

function SubNewTrumpPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    if (self._activeSkillItem) then
        self._activeSkillItem:Dispose()
        self._activeSkillItem = nil
    end

    if (self._passiveSkillItem) then
        self._passiveSkillItem:Dispose()
        self._passiveSkillItem = nil
    end

    for i = 4, 1, -1 do
        self._state[i] = nil
    end
    self._state = nil    

end

function SubNewTrumpPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnEquip = nil;

    UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnActive = nil;
end

function SubNewTrumpPanel:_DisposeReference()
    self._btnEquip = nil;
    self._btnActive = nil
    self._txtPro1 = nil;
    self._txtPro2 = nil;
    self._trsActiveSkill = nil;
    self._trsPassiveSkill = nil;
    if (self._uiAnimationModel ~= nil) then
        self._uiAnimationModel:Dispose()
        self._uiAnimationModel = nil
    end
end

function SubNewTrumpPanel:UpdatePanel()
    self.data = NewTrumpManager.GetCurrentSelectTrump()
    if (self.data) then
        if (self._uiAnimationModel == nil) then
            self._uiAnimationModel = UIAnimationModel:New(self.data, self._trsRoleParent, NewTrumpModeCreater)
        else
            self._uiAnimationModel:ChangeModel(self.data, self._trsRoleParent)
        end

        self._uiAnimationModel:Play(RoleActionName.stand)
                self._activeSkillItem:UpdateItem(self.data.activeSkill)
        self._passiveSkillItem:UpdateItem(self.data.passSkill)
        local attr = self.data:GetAllAttr()
        self._txtPower.text = CalculatePower(attr)
        local propertyData = attr:GetPropertyAndDes()

        if (propertyData[1]) then
            self._txtPro1.text = propertyData[1].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), "+" .. propertyData[1].property)
        else
            self._txtPro1.text = ""
        end

        if (propertyData[2]) then
            self._txtPro2.text = propertyData[2].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), "+" .. propertyData[2].property)
        else
            self._txtPro2.text = ""
        end

        for i = 1, 4 do
            if (i == self.data.state + 1) then
                self._state[i]:SetActive(true)
            else
                self._state[i]:SetActive(false)
            end
        end

        if (self.data.state == NewTrumpInfo.State.NotActive) then
            self._txtCondition.text = self.data.configData.obtain_des
        end


    end
end
