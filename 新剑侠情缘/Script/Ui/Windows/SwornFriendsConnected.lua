local tbLevelUpPopup = Ui:CreateClass("SwornFriendsConnected")

function tbLevelUpPopup:OnOpenEnd()
    self.szType = "jiebaichenggong"
    self:Update()
end

function tbLevelUpPopup:Update()
    self:Clear()

    self.pPanel:SetActive(self.szType, true)
    self.nTimer = Timer:Register(Env.GAME_FPS * 2, self.FinishAnimation, self)
end

function tbLevelUpPopup:Clear()
    if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil
    end
    self.pPanel:SetActive(self.szType, false)
end

function tbLevelUpPopup:OnClose()
    self:Clear()
end

function tbLevelUpPopup:FinishAnimation()
    if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil
    end
    Ui:CloseWindow(self.UI_NAME)
end

function tbLevelUpPopup:OnLeaveMap()
    if self.pPanel:IsActive(self.szType) then
        Ui:CloseWindow(self.UI_NAME)
    end
end

function tbLevelUpPopup:RegisterEvent()
    local tbRegEvent = {
        {UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveMap},
    }
    return tbRegEvent
end