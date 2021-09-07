-- @author zhouyijun
-- @date 2017年5月18日

DragonBoatFestivalModel = DragonBoatFestivalModel or BaseClass(BaseModel)

function DragonBoatFestivalModel:__init()
	self.mainWin = nil

    self.dumplingTab = {}
end

function DragonBoatFestivalModel:__delete()
end

function DragonBoatFestivalModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = DragonBoatFestivalWindow.New(self)
    end
    self.mainWin:Open(args)
end

function DragonBoatFestivalModel:CloseWindow()
	if self.mainWin ~= nil then
        self.mainWin:DeleteMe()
        self.mainWin = nil
    end
end
