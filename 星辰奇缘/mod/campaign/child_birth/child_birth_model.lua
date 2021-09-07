ChildBirthModel = ChildBirthModel or BaseClass(BaseModel)

function ChildBirthModel:__init()
    self.history = {}

    self.currentFloor = nil
    self.rewardCount = nil
    self.next_times = nil
    self.rewardList = nil
    
    self.curRewardLevel = 1
    self.curRewardShowLevel = 1
end

function ChildBirthModel:__delete()
end

function ChildBirthModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = ChildBirthWindow.New(self)
    end
    self.mainWin:Open(args)
end

function ChildBirthModel:OpenSubWindow(args)
    if self.subWin == nil then
        self.subWin = ChildBirthSubWindow.New(self)
    end
    self.subWin:Open(args)
end

function ChildBirthModel:OpenShop(args)
    local datalist = {}
    local lev = RoleManager.Instance.RoleData.lev
    for i,v in pairs(ShopManager.Instance.model.datalist[2][12]) do
        table.insert(datalist, v)
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {args = args, datalist = datalist, title = TI18N("孕育商店")})
end

