-- @author 黄耀聪
-- @date 2016年8月8日
-- 公测活动

OpenBetaModel = OpenBetaModel or BaseClass(BaseModel)

function OpenBetaModel:__init()
    self.turnplateList = {}
end

function OpenBetaModel:__delete()
end

function OpenBetaModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = OpenBetaWindow.New(self)
    end
    self.mainWin:Open(args)
end

function OpenBetaModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
        self.mainWin = nil
    end
end


