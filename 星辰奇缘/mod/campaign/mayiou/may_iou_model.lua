-- @author 黄耀聪
-- @date 2017年5月12日

MayIOUModel = MayIOUModel or BaseClass(BaseModel)

function MayIOUModel:__init()
end

function MayIOUModel:__delete()
end

function MayIOUModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = MayIOUWindow.New(self)
    end
    self.mainWin:Open(args)
end



