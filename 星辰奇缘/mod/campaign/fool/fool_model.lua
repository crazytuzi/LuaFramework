-- @author 黄耀聪
-- @date 2017年3月17日

FoolModel = FoolModel or BaseClass(BaseModel)

function FoolModel:__init()
end

function FoolModel:__delete()
end

function FoolModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = FoolWindow.New(self)
    end
    self.mainWin:Open(args)
end

function FoolModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
end


