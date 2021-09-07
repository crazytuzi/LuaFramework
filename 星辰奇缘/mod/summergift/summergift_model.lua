SummerGiftModel = SummerGiftModel or BaseClass(BaseModel)


function SummerGiftModel:__init()
    self.mainWin = nil
    self.tabWin = nil
    self.win = nil
    self.openArgs = args

end

function SummerGiftModel:OpenMainWindow(args)
    if self.mainWin == nil then
        self.mainWin = SummerGiftMainWindow.New(self)
    end
    self.mainWin:Open(args)
end

function SummerGiftModel:CloseMainWindow()
    WindowManager.Instance:CloseWindow(self.mainWin)
end

function SummerGiftModel:__delete()
    if self.mainWin ~= nil then
        self.mainWin:DeleteMe()
    end

end