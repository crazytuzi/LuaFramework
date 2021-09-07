CampBoxModel = CampBoxModel or BaseClass(BaseModel)


function CampBoxModel:__init()
    self.mainWin = nil
    self.tabWin = nil
    self.win = nil
    self.openArgs = args



    self.classList = {
        [1] = { name = TI18N("冰激凌"), nil, package = AssetConfig.campbox_texture, icon = "TabIcon1" },
        [2] = { name = TI18N("翻翻乐"), nil, package = AssetConfig.campbox_texture, icon = "TabIcon2" },
    }

    self.panelIdList =
    {
        [1] = 687,
        [2] = 689
    }
end

function CampBoxModel:OpenMainWindow(args)
    if self.mainWin == nil then
        self.mainWin = CampBoxMainWindow.New(self)
    end
    self.mainWin:Open(args)
end

function CampBoxModel:OpenTabWindow(args)
    if self.tabWin == nil then
        self.tabWin = CampBoxTabWindow.New(self)
    end
    self.tabWin:Open(args)
end

function CampBoxModel:CloseMainWindow()
    WindowManager.Instance:CloseWindow(self.mainWin)
end

function CampBoxModel:CloseTabWindow()
    WindowManager.Instance:CloseWindow(self.tabWin)
end

function CampBoxModel:__delete()
    if self.mainWin ~= nil then
        self.mainWin:DeleteMe()
    end

    if self.tabWin ~= nil then
        self.tabWin:DeleteMe()
    end
end