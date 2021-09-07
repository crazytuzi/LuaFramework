SoloEndlessModel = SoloEndlessModel or BaseClass()


function SoloEndlessModel:__init()
    self.Mgr = SoloEndlessManager.Instance
end

function SoloEndlessModel:__delete()

end

function SoloEndlessModel:OpenMainWindow()
    if self.window == nil then
        self.window = SoloEndlessWindow.New(self)
    end
    self.window:Open()
end

function SoloEndlessModel:CloseMainWindow()
    if self.window ~= nil then
        WindowManager.Instance:CloseWindow(self.window)
    end
end

function SoloEndlessModel:OpenRankPanel()
    if self.rankpanel ~= nil then
        self.rankpanel = SoloEndlessRankpanel.New(self)
    end
    self.rankpanel:Show()
end