local CLockScreenView = class("CLockScreenView", CViewBase)

function CLockScreenView.ctor(self, cb)
    CViewBase.ctor(self, "UI/SystemSettings/LockScreenView.prefab", cb)
    self.m_DepthType = "LockScreen"
    self.m_ExtendClose = "Shelter"
end

function CLockScreenView.OnCreateView(self)
    self.m_Slider = self:NewUI(1, CSlider)
    self.m_OnChange = self:NewUI(2, CObject)
    self.m_TipsLabel = self:NewUI(3, CLabel)
    self:InitContent()
end

function CLockScreenView.InitContent(self)
    self.m_Slider:SetValue(0)
    self.m_OnChange:SetActive(false)
    self.m_TipsLabel:SetActive(true)
    self.m_Slider:AddUIEvent("click", callback(self, "OnSliderClick"))
    self.m_Slider:AddUIEvent("drag", callback(self, "OnSliderChang"))
    self.m_Slider:AddUIEvent("dragend", callback(self, "OnSliderChanged"))
    main.ChangeFrameRate(30)
    self.m_IsUpdate = true
    self.m_Timer = Utils.AddTimer(callback(self, "Update"), 0.1, 0.1)
    self:CheckWorldMapBookView()
end

function CLockScreenView.Update(self)
    if Utils.IsNil(self) then
        return
    end
    local value = self.m_Slider:GetValue()
    if value > 0.9 then
        self:CloseView()
    elseif self.m_IsUpdate then
        self.m_Slider:SetValue(0)
        self.m_OnChange:SetActive(false)
        self.m_TipsLabel:SetActive(true)
    end
    return true
end

function CLockScreenView.OnSliderClick(self, oSlider)
    self.m_Slider:SetValue(0)
end

function CLockScreenView.OnSliderChang(self, oSlider)
    local value = self.m_Slider:GetValue()
    self.m_OnChange:SetActive(value > 0)
    self.m_TipsLabel:SetActive(value == 0)
    self.m_IsUpdate = value > 0.9
end

function CLockScreenView.OnSliderChanged(self, oSlider)
    self.m_IsUpdate = true
end

function CLockScreenView.CheckWorldMapBookView(self)
    local oView = CWorldMapBookView:GetView()
    if oView then
        local oPage = oView.m_TimePage
        if oPage then
            if oPage.OnBack then
                oPage:OnBack()
            end
        end
    end
end

function CLockScreenView.CloseView(self)
    main.ChangeFrameRate(30)
    CViewBase.CloseView(self)
end

return CLockScreenView