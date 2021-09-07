GivePresentModule = GivePresentModule or BaseClass(BaseModel)


function GivePresentModule:__init()
    self.giveWin = nil
    self.giveMgr = GivepresentManager.Instance
end

function GivePresentModule:__delete()
    if self.giveWin then
        self.giveWin = nil
    end
end

function GivePresentModule:OpenMainWin(args)
    if self.giveWin == nil then
        self.giveWin = GivePresentWindow.New(self)
    end
    self.giveWin:Open(args)
end

function GivePresentModule:CloseMain()
    WindowManager.Instance:CloseWindow(self.giveWin)
    -- self.giveWin = nil
end

function GivePresentModule:RefreshItemPanel()
    if self.giveWin ~= nil then
        self.giveWin:InitGiveItemPanel()
    end
end

function GivePresentModule:RefreshItemNum()
    if self.giveWin ~= nil then
        self.giveWin:SetItemNum()
    end
end

function GivePresentModule:RefreshFriendShip()
    if self.giveWin ~= nil then
        self.giveWin:RefreshFriendShip()
    end
end