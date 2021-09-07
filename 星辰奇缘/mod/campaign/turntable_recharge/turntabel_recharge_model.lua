TurntabelRechargeModel = TurntabelRechargeModel or BaseClass(BaseModel)

function TurntabelRechargeModel:__init()
end

function TurntabelRechargeModel:__delete()
end

function TurntabelRechargeModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = TurntabelRechargeWindow.New(self)
    end
    self.mainWin:Open(args)
end

function TurntabelRechargeModel:CloseWindow()
end
