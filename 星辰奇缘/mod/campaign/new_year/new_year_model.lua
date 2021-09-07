NewYearModel = NewYearModel or BaseClass(BaseModel)

function NewYearModel:__init()
end

function NewYearModel:__delete()
end

function NewYearModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = NewYearWindow.New(self)
    end
    self.mainWin:Open(args)
end

function NewYearModel:OpenExchange(args)
    local datalist = {}
    local lev = RoleManager.Instance.RoleData.lev
    local sex = RoleManager.Instance.RoleData.sex
    local classes = RoleManager.Instance.RoleData.classes
    for i,v in pairs(ShopManager.Instance.model.datalist[2][11]) do
        table.insert(datalist, v)
    end

    if self.exchangeWin == nil then
        self.exchangeWin = MidAutumnExchangeWindow.New(self)
    end
    self.exchangeWin:Open({datalist = datalist, title = TI18N("珍藏献礼"), extString = ""})
end
