-- @author zgs
SatiationModel = SatiationModel or BaseClass(BaseModel)

function SatiationModel:__init()
    self.gaWin = nil
end

function SatiationModel:__delete()
    if self.gaWin then
        self.gaWin = nil
    end
end

function SatiationModel:OpenWindow(args)
    if self.gaWin == nil then
        self.gaWin = SatiationWindow.New(self)
    end
    self.gaWin:Show(args)
end

function SatiationModel:CloseMain()
    -- WindowManager.Instance:CloseWindow(self.gaWin, true)
    if self.gaWin ~= nil then
        self.gaWin:Hiden()
        self.gaWin:DeleteMe()
    end
    self.gaWin = nil
end

