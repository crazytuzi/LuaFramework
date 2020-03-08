local tbUi = Ui:CreateClass("GatherBoxAnimation")

function tbUi:OnOpenEnd()
    self:CloseTimer()
    self.nCloseTimer = Timer:Register(Env.GAME_FPS * 2, self.CloseMyself, self)
end

function tbUi:CloseMyself()
    self.nCloseTimer = nil
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:OnClose()
    self:CloseTimer()
end

function tbUi:CloseTimer()
    if self.nCloseTimer then
        Timer:Close(self.nCloseTimer)
    end
end