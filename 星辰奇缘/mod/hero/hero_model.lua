HeroModel = HeroModel or BaseClass(BaseModel)

function HeroModel:__init()
    self.mgr = HeroManager.Instance
    self.restTime = 0
    self.registerTime = 0
    self.myInfo = {}
    self.settleData = {}
    self.hideStatus = false
    self.campList = {{score = 0}, {score = 0}}
end

function HeroModel:__delete()
end

function HeroModel:OpenRankWindow(args)
    if self.rankWin == nil then
        self.rankWin = HeroRankWindow.New(self)
    end
    self.rankWin:Open(args)
end

function HeroModel:CloseRankWindow()
    if self.rankWin ~= nil then
        WindowManager.Instance:CloseWindow(self.rankWin)
    end
end

function HeroModel:SetTime(time)
    self.registerTime = BaseUtils.BASE_TIME + 15*60
    self.restTime = time - BaseUtils.BASE_TIME
    if self.restTime < 0 then
        self.restTime = 0
    end
end

function HeroModel:EnterScene()
    if self.scenePanel == nil then
        self.scenePanel = HeroMainUIPanel.New(self)
    end
    self.scenePanel:Show()

    local t = MainUIManager.Instance.MainUIIconView

    if t ~= nil then
        t:Set_ShowTop(false, {17, 107})
    end

    --print("<color=#FF0000>======================================</color>")
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(self.hideStatus)
end

function HeroModel:ExitScene()
    if self.scenePanel ~= nil then
        self.scenePanel:DeleteMe()
        self.scenePanel = nil

        local t = MainUIManager.Instance.MainUIIconView

        if t ~= nil then
            t:Set_ShowTop(true, {107})
        end
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson) == true)
    end
end

function HeroModel:OpenSettleWindow(args)
    if self.settleWin == nil then
        self.settleWin = HeroSettleWindow.New(self)
    end
    self.settleWin:Open(args)
end

function HeroModel:CloseSettleWindow()
    if self.settleWin ~= nil then
        WindowManager.Instance:CloseWindow(self.settleWin)
    end
end

