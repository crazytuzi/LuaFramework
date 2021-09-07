-- @author 黄耀聪
-- @date 2017年6月19日, 星期一

IngotCrashModel = IngotCrashModel or BaseClass(BaseModel)

function IngotCrashModel:__init()
    self.personData = nil
    self.best16Tab = {}

    self.drugTimesTab = {}

    self:PreHandle()
end

function IngotCrashModel:__delete()
    if self.damakuPanel ~= nil then
        self.damakuPanel:DeleteMe()
        self.damakuPanel = nil
    end
end

function IngotCrashModel:PreHandle()
    for _,v in ipairs(DataGoldLeague.data_drug) do
        self.drugTimesTab[v.id] = self.drugTimesTab[v.id] or {}
        table.insert(self.drugTimesTab[v.id], v)
    end
    for id,v in pairs(self.drugTimesTab) do
        table.sort(v, function(a,b) return a.times_min < b.times_min end)
    end
end

function IngotCrashModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = IngotCrashWindow.New(self)
    end
    self.mainWin:Open(args)
end

function IngotCrashModel:OpenRank(args)
    if self.rankWin == nil then
        self.rankWin = IngotCrashRank.New(self)
    end
    self.rankWin:Open(args)
end

function IngotCrashModel:OpenVote(args)
    if self.voteWin == nil then
        self.voteWin = IngotCrashVote.New(self)
    end
    self.voteWin:Open(args)
end

function IngotCrashModel:EnterScene()
    if self.scenePanel == nil then
        self.scenePanel = IngotCrashMainUI.New(self, ChatManager.Instance.model.chatCanvas)
    end
    self.scenePanel:Show()

    local t = MainUIManager.Instance.MainUIIconView

    if t ~= nil then
        if IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Ready then
            t:Set_ShowTop(false, {17, 122, 107})
        elseif IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Kickout or IngotCrashManager.Instance.phase == IngotCrashEumn.Phase.Guess then
            t:Set_ShowTop(false, {17, 122})
        else
            t:Set_ShowTop(false, {17, 107})
        end
    end
end

function IngotCrashModel:ExitScene()
    if self.scenePanel ~= nil then
        self.scenePanel:DeleteMe()
        self.scenePanel = nil

        local t = MainUIManager.Instance.MainUIIconView
        if t ~= nil then
            t:Set_ShowTop(true, {17, 107})
        end
    end
end

function IngotCrashModel:OpenUse()
    if self.usePanel == nil then
        self.usePanel = IngotCrashUse.New(self, ctx.CanvasContainer)
    end
    self.usePanel:Show()
end

function IngotCrashModel:CloseUse()
    if self.usePanel ~= nil then
        self.usePanel:DeleteMe()
        self.usePanel = nil
    end
end

function IngotCrashModel:OpenSettle(args)
    if self.settleWin == nil then
        self.settleWin = IngotCrashSettle.New(self)
    end
    self.settleWin:Open(args)
end

function IngotCrashModel:OpenWatchList(args)
    if self.watchListWin == nil then
        self.watchListWin = IngotCrashWatch.New(self)
    end
    self.watchListWin:Open(args)
end

function IngotCrashModel:OpenReward(args)
    if self.rewardWin == nil then
        self.rewardWin = IngotCrashReward.New(self)
    end
    self.rewardWin:Open(args)
end

function IngotCrashModel:OpenShow(args)
    if self.showWin == nil then
        self.showWin = IngotCrashShow.New(self)
    end
    self.showWin:Open(args)
end

function IngotCrashModel:ShowChampions(args)
    if self.championsPanel == nil then
        self.championsPanel = IngotCrashShowBestPanel.New(self)
    end
    self.championsPanel:Show(args)
end

function IngotCrashModel:CloseChampions()
    if self.championsPanel ~= nil then
        self.championsPanel:DeleteMe()
        self.championsPanel = nil
    end
end

function IngotCrashModel:OpenReward(args)
    if self.rewardWin == nil then
        self.rewardWin = IngotCrashReward.New(self)
    end
    self.rewardWin:Open(args)
end

function IngotCrashModel:OpenDamaku()
    if self.damakuPanel == nil then
        self.damakuPanel = IngotCrashDamaku.New(self)
    end
    self.damakuPanel:Show()
end

function IngotCrashModel:CloseDamaku()
    if self.damakuPanel ~= nil then
        self.damakuPanel:DeleteMe()
        self.damakuPanel = nil
    end
end

function IngotCrashModel:AnalyzeRank()
    if self.model.rankData ~= nil then
        local roleData = RoleManager.Instance.RoleData
        for i,v in ipairs(self.model.rankData) do
            if v.rid == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
                self.model.personData.rank = i
                return
            end
        end
    else
    end
end
