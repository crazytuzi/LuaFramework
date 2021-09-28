require "Core.Module.Common.Panel"

MobaoActivePanel = class("MobaoActivePanel", Panel);
function MobaoActivePanel:New()
    self = { };
    self.count = 0
    setmetatable(self, { __index = MobaoActivePanel });
    return self
end

function MobaoActivePanel:_Opened()
    UpdateBeat:Add(self.Update, self)
end
 
 function MobaoActivePanel:GetUIOpenSoundName( )
    return UISoundManager.ui_win
end
 
function MobaoActivePanel:Update()
    self.count = self.count + 1
    if self.count > 2 then     
        UpdateBeat:Remove(self.Update, self)
        self._uiEffect = UIUtil.GetUIEffect("ui_trump_show", self._trsImgRole, self._bg, 1);
    end
end

function MobaoActivePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function MobaoActivePanel:_InitReference()
    self._txtSkillDes = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtSkillDes");
    self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
    self._txtPower = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtPower")
    self._txtProperty1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtProperty1");
    self._txtProperty2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtProperty2");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._bg = UIUtil.GetChildByName(self._trsContent, "UISprite", "bg")
    self._trsImgRole = UIUtil.GetChildByName(self._trsContent, "TexturePanel/imgRole")
    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsRoleParent = UIUtil.GetChildInComponents(trss, "trsRoleParent");
end

  

function MobaoActivePanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function MobaoActivePanel:IsPopup()
    return false
end


function MobaoActivePanel:_OnClickBtn_close()
    ModuleManager.SendNotification(NewTrumpNotes.CLOSE_MOBAO_ACTIVE)
end

function MobaoActivePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    if (self._uiEffect) then
        Resourcer.Recycle(self._uiEffect, false);
        self._uiEffect = nil;
    end
end

function MobaoActivePanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function MobaoActivePanel:_DisposeReference()
    self._btn_close = nil;
    self._txtSkillDes = nil;
    self._txtName = nil;
    self._txtProperty1 = nil;
    self._txtProperty2 = nil;
    self._trsRoleParent = nil;
    if (self._uiAnimationModel ~= nil) then
        self._uiAnimationModel:Dispose()
        self._uiAnimationModel = nil
    end
end


function MobaoActivePanel:UpdatePanel(data)
    self.data = data
    if (self.data) then
        if (self._uiAnimationModel == nil) then
            self._uiAnimationModel = UIAnimationModel:New(self.data, self._trsRoleParent, MobaoModeCreater)
        else
            self._uiAnimationModel:ChangeModel(self.data, self._trsRoleParent)
        end
        local attr = NewTrumpManager.GetMobaoAttrs(self.data)
        local propertyData = attr:GetPropertyAndDes()

        if (propertyData[1]) then
            self._txtProperty1.text = propertyData[1].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), "+" .. propertyData[1].property)
        else
            self._txtProperty1.text = ""
        end

        if (propertyData[2]) then
            self._txtProperty2.text = propertyData[2].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), "+" .. propertyData[2].property)
        else
            self._txtProperty2.text = ""
        end

        self._txtName.text = self.data.name
        self._txtPower.text = "+" .. self.data.fighting_capacity
        self._txtSkillDes.text = self.data.effect_name .. ":" .. NewTrumpManager.GetMobaoEffectDes(self.data)
    end

end