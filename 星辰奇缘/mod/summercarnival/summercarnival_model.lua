SummerCarnivalModel = SummerCarnivalModel or BaseClass(BaseModel)


function SummerCarnivalModel:__init(manager)
    self.mgr = manager
    self.mainWin = nil
    self.win = nil
    self.openArgs = args
    self.tabWin = nil

    self.classList = {
        [1] = { name = TI18N("七彩冰沙"), nil, package = AssetConfig.campaign_icon, icon = "shabing" },
        [2] = { name = TI18N("冰动星辰"), nil, package = AssetConfig.campaign_icon, icon = "FlowerYellow" },
    }

    self.panelIdList =
    {
        [1] = 704,
        [2] = 706,
    }


    self.classListSecond = {
    }

    self.panelIdListSecond ={

    }
end

function SummerCarnivalModel:OpenMainWindow(args)
    if self.mainWin == nil then
        self.mainWin = SummerCarnivalMainWindow.New(self,self.mgr)
    end
    self.mainWin:Open(args)
end

function SummerCarnivalModel:CloseMainWindow()
    WindowManager.Instance:CloseWindow(self.mainWin)
end

function SummerCarnivalModel:CloseTabWindow()
    WindowManager.Instance:CloseWindow(self.tabWin)
end

function SummerCarnivalModel:CloseTabSecondWindow()
    WindowManager.Instance:CloseWindow(self.tabSecondWin)
end

function SummerCarnivalModel:__delete()
    if self.mainWin ~= nil then
        self.mainWin:DeleteMe()
    end

end

function SummerCarnivalModel:OpenTabWindow(args)
    if self.tabWin == nil then
        self.tabWin = SummercarnivalTabWindow.New(self)
    end
    self.tabWin:Open(args)
end

function SummerCarnivalModel:OpenTabSecondWindow(args)
    if self.tabSecondWin == nil then
        self.tabSecondWin = SummercarnivalTabSecondWindow.New(self)
    end
    self.tabSecondWin:Open(args)
end