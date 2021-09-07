-- 划龙舟
-- @ljh 2017.05.18

DragonBoatModel = DragonBoatModel or BaseClass(BaseModel)

function DragonBoatModel:__init()
    self.dragonBoatStartWindow = nil
    self.dragonBoatRankScoreWindow = nil
    self.dragonBoatIcon = nil
end

function DragonBoatModel:__delete()
    if self.dragonBoatStartWindow ~= nil then
        self.dragonBoatStartWindow:DeleteMe()
        self.dragonBoatStartWindow = nil
    end
    if self.dragonBoatRankScoreWindow ~= nil then
        self.dragonBoatRankScoreWindow:DeleteMe()
        self.dragonBoatRankScoreWindow = nil
    end
end

function DragonBoatModel:OpenStartWindow(args)
    if self.dragonBoatStartWindow == nil then
        self.dragonBoatStartWindow = DragonBoatStartWindow.New(self)
    end
    self.dragonBoatStartWindow:Open(args)
end

function DragonBoatModel:CloseStartWindow()
    if self.dragonBoatStartWindow ~= nil then
        self.dragonBoatStartWindow:DeleteMe()
        self.dragonBoatStartWindow = nil
    end
end

function DragonBoatModel:OpenRankScoreWindow(args)
    if self.dragonBoatRankScoreWindow == nil then
        self.dragonBoatRankScoreWindow = DragonBoatRankScoreWindow.New(self)
    end
    self.dragonBoatRankScoreWindow:Show(args)
end

function DragonBoatModel:CloseRankScoreWindow()
    if self.dragonBoatRankScoreWindow ~= nil then
        self.dragonBoatRankScoreWindow:DeleteMe()
        self.dragonBoatRankScoreWindow = nil
    end
end

function DragonBoatModel:ShowIcon()
    if self.dragonBoatIcon == nil then
        self.dragonBoatIcon = DragonBoatIcon.New(self)
    end
    self.dragonBoatIcon:Show()
end

function DragonBoatModel:HideIcon()
    if self.dragonBoatIcon ~= nil then
        self.dragonBoatIcon:DeleteMe()
        self.dragonBoatIcon = nil
    end
end