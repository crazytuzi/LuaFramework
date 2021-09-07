BigSummerModel = BigSummerModel or BaseClass(BaseModel)


function BigSummerModel:__init(manager)
    self.mgr = manager
    self.mainWin = nil
    self.win = nil
    self.openArgs = args

end

function BigSummerModel:OpenMainWindow(args)
    if self.mainWin == nil then
        self.mainWin = BigSummerMainWindow.New(self,self.mgr)
    end
    self.mainWin:Open(args)
end

function BigSummerModel:CloseMainWindow()
    WindowManager.Instance:CloseWindow(self.mainWin)
end

function BigSummerModel:__delete()
    if self.mainWin ~= nil then
        self.mainWin:DeleteMe()
    end

end