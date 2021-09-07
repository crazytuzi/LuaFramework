--region *.lua
--Date  jia 
-- 世界等级活动model
--endregion
WorldLevModel = WorldLevModel or BaseClass(BaseModel)

function WorldLevModel:__init()
end

function WorldLevModel:__delete()
end

function WorldLevModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = WorldLevWindow.New(self)
    end
    self.mainWin:Open(args)
end
