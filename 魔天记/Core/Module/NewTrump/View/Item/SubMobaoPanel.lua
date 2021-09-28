require "Core.Module.Common.UIComponent"
require "Core.Module.NewTrump.View.Item.SubMobaoSkillItem"
require "Core.Role.ModelCreater.MobaoModeCreater"
require "Core.Module.Common.UIAnimationModel"

SubMobaoPanel = class("SubMobaoPanel", UIComponent);
local pos = Vector3.New(65535, 65535, 0)
function SubMobaoPanel:New(transform)
    self = { };
    setmetatable(self, { __index = SubMobaoPanel });
    if (transform) then
        self:Init(transform);
    end
    return self
end


function SubMobaoPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SubMobaoPanel:_InitReference()
    self._txtPro1 = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtPro1");
    self._txtPro2 = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtPro2");
    self._txtCondition = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtActiveCondition")
    self._txtPower = UIUtil.GetChildByName(self._gameObject, "UILabel", "powerComponet/power")
    self._trsPassiveSkill = UIUtil.GetChildByName(self._gameObject, "Transform", "trsPassiveSkill");
    self._passiveSkillItem = SubMobaoSkillItem:New()
    self._passiveSkillItem:Init(self._trsPassiveSkill)
    self._trsRoleParent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsRoleParent", true)
    self._trsActived = UIUtil.GetChildByName(self._gameObject, "Transform", "trsActived")
end



function SubMobaoPanel:_InitListener()
end


function SubMobaoPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    if (self._passiveSkillItem) then
        self._passiveSkillItem:Dispose()
        self._passiveSkillItem = nil
    end
    NewTrumpManager.SetCurrentMobao(nil)
end

function SubMobaoPanel:_DisposeListener()
end

function SubMobaoPanel:_DisposeReference()
    self._txtPro1 = nil;
    self._txtPro2 = nil;
    self._trsPassiveSkill = nil;
    if (self._uiAnimationModel ~= nil) then
        self._uiAnimationModel:Dispose()
        self._uiAnimationModel = nil
    end
end

function SubMobaoPanel:UpdatePanel()
    self.data = NewTrumpManager.GetCurrentMobao()
    if (self.data) then
        if (self._uiAnimationModel == nil) then
            self._uiAnimationModel = UIAnimationModel:New(self.data, self._trsRoleParent, MobaoModeCreater)
        else
            self._uiAnimationModel:ChangeModel(self.data, self._trsRoleParent)
        end
        self._uiAnimationModel:Play(RoleActionName.stand)

        self._passiveSkillItem:UpdateItem(self.data)

        local attr = NewTrumpManager.GetMobaoAttrs(self.data)
        self._txtPower.text = self.data.fighting_capacity
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

        if NewTrumpManager.IsMobaoEnable(self.data.id) then
            self._trsActived.gameObject:SetActive(true)
            self._txtCondition.gameObject:SetActive(false)
        else
            self._trsActived.gameObject:SetActive(false)
            self._txtCondition.gameObject:SetActive(true)
            self._txtCondition.text = self.data.obtain_des
        end
    end
end
