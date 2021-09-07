FuseModel = FuseModel or BaseClass(BaseModel)

function FuseModel:__init()
    self.mainwin = nil
    self.fuseMgr = FuseManager.Instance
end

function FuseModel:OpenMain(args)
    if self.mainwin == nil then
        self.mainwin = FuseWindow.New(self)
    end
    if args ~= nil then
        self.index = args[1]
        self.sub_index = args[2]
    else
        self.index = nil
        self.sub_index = nil
    end
    self.mainwin:Open()
end

function FuseModel:CloseWin()
    if self.mainwin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainwin)
        self.mainwin = nil
    end
end

function FuseModel:UpdateWindow(id)
    if id ~= nil then
        local itemData = BackpackManager.Instance:GetItemById(id)
        if itemData ~= nil and itemData.type == BackpackEumn.ItemType.petsupergem then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petgenselect, {id})
            return
        end
    end
    if self.mainwin ~= nil then
        self.mainwin:UpdatePanel(id)
    end
end

function FuseModel:ShowEffect()
    if self.mainwin ~= nil then
        self.mainwin:ShowEffect()
    end
end

function FuseModel:ShowFuseItem(id)
    if self.mainwin ~= nil then
        print("FuseModel~~~~~~~~~~~~~~")
        self.mainwin:ShowFuseResultItem(id)
    end
end