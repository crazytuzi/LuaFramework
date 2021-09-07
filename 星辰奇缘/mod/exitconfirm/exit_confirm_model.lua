ExitConfirmModel = ExitConfirmModel or BaseClass(BaseModel)

function ExitConfirmModel:__init()
    self.window = nil
end

function ExitConfirmModel:__delete()
end

function ExitConfirmModel:OpenWindow()
    if self.window == nil then
        self.window = ExitConfirmWindow.New(self)
    end
    self.window:Open()
end

function ExitConfirmModel:CloseWindow()
    WindowManager.Instance:CloseWindow(self.window)
end
