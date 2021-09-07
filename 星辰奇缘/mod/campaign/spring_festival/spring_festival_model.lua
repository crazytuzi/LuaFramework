SpringFestivalModel = SpringFestivalModel or BaseClass(BaseModel)

function SpringFestivalModel:__init()
end

function SpringFestivalModel:__delete()
end

function SpringFestivalModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = SpringFestivalWindow.New(self)
    end
    self.mainWin:Open(args)
end

function SpringFestivalModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
end

function SpringFestivalModel:OpenExchange(args)
    local datalist = {}
    for i,v in pairs(ShopManager.Instance.model.datalist[2][13]) do
        table.insert(datalist, v)
    end

    if self.exchangeWin == nil then
        self.exchangeWin = MidAutumnExchangeWindow.New(self)
    end
    self.exchangeWin:Open({datalist = datalist, title = TI18N("新春兑换"), extString = ""})
end

