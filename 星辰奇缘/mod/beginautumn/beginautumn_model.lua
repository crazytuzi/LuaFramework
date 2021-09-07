BeginAutumnModel = BeginAutumnModel or BaseClass(BaseModel)


function BeginAutumnModel:__init(manager)
    self.mgr = manager
    self.mainWin = nil
    self.win = nil
    self.openArgs = args
    self.tabWin = nil
    self.discountshopWin = nil

    self.dollar = 0

end

function BeginAutumnModel:OpenMainWindow(args)
    if self.mainWin == nil then
        self.mainWin = BeginAutumnMainWindow.New(self,self.mgr)
    end
    self.mainWin:Open(args)
end

function BeginAutumnModel:CloseMainWindow()
    WindowManager.Instance:CloseWindow(self.mainWin)
end


function BeginAutumnModel:OpenDisCountShopWindow(args)
    if self.discountshopWin == nil then
        self.discountshopWin = DisCountShopWindow.New(self,self.mgr)
    end
    self.discountshopWin:Open(args)
end

function BeginAutumnModel:OpenDisCountShopWindow2(args)
    if self.discountshopWin2 == nil then
        self.discountshopWin2 = DisCountShopWindowHalloween.New(self,self.mgr)
    end
    self.discountshopWin2:Open(args)
end

function BeginAutumnModel:CloaseDisCountShopWindow()
    WindowManager.Instance:CloseWindow(self.discountshopWin)
end

function BeginAutumnModel:__delete()
    ---不能清理从页
    if self.mainWin ~= nil then
        self.mainWin:DeleteMe()
    end

end

