Demo2Model = Demo2Model or BaseClass(BaseModel)

function Demo2Model:__init()
    self.demoWin = nil
end

function Demo2Model:__delete()
    if demoWin ~= nil then
        self.demoWin:DeleteMe()
        self.demoWin = nil
    end
end

function Demo2Model:OpenWindow()
    if self.demoWin == nil then
        self.demoWin = Demo2Window.New(self)
    end
    self.demoWin:Open()
end

function Demo2Model:CloseMain()
    WindowManager.Instance:CloseWindow(self.demoWin)
    -- self.demoWin:DeleteMe()
    -- self.demoWin = nil
end
