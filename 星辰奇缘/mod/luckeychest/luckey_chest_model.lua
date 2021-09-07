LuckeyChestModel = LuckeyChestModel or BaseClass(BaseModel)

function LuckeyChestModel:__init()
end

function LuckeyChestModel:__delete()
end

function LuckeyChestModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = LuckeyChestWindow.New(self)
    end
    self.mainWin:Open(args)
end

function LuckeyChestModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
end
