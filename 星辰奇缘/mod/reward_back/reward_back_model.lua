RewardBackModel = RewardBackModel or BaseClass(BaseModel)

function RewardBackModel:__init()
end

function RewardBackModel:__delete()
end

function RewardBackModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = RewardBackWindow.New(self)
    end
    self.mainWin:Open(args)
end

function RewardBackModel:ShowConfirm(args)
    if self.mainWin ~= nil then
        if self.confirmPanel == nil then
            self.confirmPanel = RewardBackConfirm.New(self, self.mainWin)
        end
        self.confirmPanel:Show(args)
    end
end

