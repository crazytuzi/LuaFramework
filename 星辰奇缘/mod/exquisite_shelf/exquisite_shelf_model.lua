ExquisiteShelfModel = ExquisiteShelfModel or BaseClass(BaseModel)

function ExquisiteShelfModel:__init()
    self.shelfData = {}
end

function ExquisiteShelfModel:__delete()
end

function ExquisiteShelfModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = ExquisiteShelfWindow.New(self)
    end
    self.mainWin:Open(args)
end

function ExquisiteShelfModel:OpenShowWindow(args)
    if self.showWin == nil then
        self.showWin = ExquisiteShelfShowWindow.New(self)
    end
    self.showWin:Open(args)
end


function ExquisiteShelfModel:OpenReward(args)
    if self.rewardWin == nil then
        self.rewardWin = ExquisiteShelfReward.New(self)
    end
    self.rewardWin:Open(args)
end

function ExquisiteShelfModel:EnterScene()
    local mapId = SceneManager.Instance:CurrentMapId()
    if mapId == ExquisiteShelfManager.Instance.firstMapId or mapId == ExquisiteShelfManager.Instance.secondMapId then
        local t = MainUIManager.Instance.MainUIIconView
        if t ~= nil then
            t:Set_ShowTop(false, {107})
        end
    end
end

function ExquisiteShelfModel:OpenPreview(args)
    if self.previewWin == nil then
        self.previewWin = ExquisiteShelfRewardPreview.New(self)
    end
    self.previewWin:Open(args)
end

