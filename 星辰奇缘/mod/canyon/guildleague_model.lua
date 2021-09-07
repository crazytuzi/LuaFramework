GuildLeagueModel = GuildLeagueModel or BaseClass()


function GuildLeagueModel:__init()
    self.Mgr = GuildLeagueManager.Instance
end

function GuildLeagueModel:__delete()

end

function GuildLeagueModel:OpenWindow(args)
    if self.win == nil then
        self.win = GuildLeagueWindow.New(self)
    end
    self.win:Open(args)
end

function GuildLeagueModel:CloseWindow()
    if self.win ~= nil then
        WindowManager.Instance:CloseWindow(self.win)
    end
end

function GuildLeagueModel:OpenFightInfoPanel()
    if self.fightinfopanel == nil then
        self.fightinfopanel = GuildLeagueFightInfoPanel.New(self)
    end
    self.fightinfopanel:Show()
end

function GuildLeagueModel:CloseFightInfoPanel()
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:DeleteMe()
        self.fightinfopanel = nil
    end
end

function GuildLeagueModel:OnAttackFire()
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:AttackFire()
    end
end


function GuildLeagueModel:OnDefend()
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:Defend()
    else
        NoticeManager.Instance:FloatTipsByString("比赛尚未开始，无需守塔哦")
    end
end

function GuildLeagueModel:EnterArea(data)
    -- BaseUtils.dump(data, "进入")
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:OnEnterArea(data)
    end
end

function GuildLeagueModel:FinishMotion(id)
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:LockBtn(id)
    end
end

function GuildLeagueModel:OpenMapWindow()
    if self.mapwindow == nil then
        self.mapwindow = GuildLeagueMapWindow.New(self)
    end
    self.mapwindow:Open()
end

function GuildLeagueModel:CloseMapWindow()
    if self.mapwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.mapwindow)
    end
end

function GuildLeagueModel:OpenTeamSetWindow()
    if self.teamsetwindow == nil then
        self.teamsetwindow = GuildLeagueTeamWindow.New(self)
    end
    self.teamsetwindow:Open()
end

function GuildLeagueModel:CloseTeamSetWindow()
    if self.teamsetwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.teamsetwindow)
    end
end

function GuildLeagueModel:OpenTeamLookWindow()
    if self.teamlookwindow == nil then
        self.teamlookwindow = GuildLeagueTeamLookWindow.New(self)
    end
    self.teamlookwindow:Open()
end

function GuildLeagueModel:CloseTeamLookWindow()
    if self.teamlookwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.teamlookwindow)
    end
end

function GuildLeagueModel:OpenLeaderSetWindow(bo, pos)
    if bo == true then
        if self.leadersetwindow == nil then
            self.leadersetwindow = GuildLeagueLeaderSetPanel.New(self)
        end
        self.leadersetwindow:Show({pos})
    else
        if self.leadersetwindow ~= nil then
            self.leadersetwindow:Hiden()
        end
    end
end

function GuildLeagueModel:CloseLeaderSetWindow()
    if self.leadersetwindow ~= nil then
        self.leadersetwindow:DeleteMe()
        self.leadersetwindow = nil
    end
end

function GuildLeagueModel:StartTowerControll()
    if self.towercontroller == nil then
        self.towercontroller = GuildLeagueTowerControl.New(self)
    end
end

function GuildLeagueModel:StopTowerControll()
    if self.towercontroller ~= nil then
        self.towercontroller:DeleteMe()
        self.towercontroller = nil
    end
end

function GuildLeagueModel:OpenResultCountWindow(args)
    if self.resultcountwindow == nil then
        self.resultcountwindow = GuildLeagueResultCountWindow.New(self)
    end
    self.resultcountwindow:Show(args)
end

function GuildLeagueModel:CloseResultCountWindow()
    if self.resultcountwindow ~= nil then
        self.resultcountwindow:DeleteMe()
        self.resultcountwindow = nil
        -- WindowManager.Instance:CloseWindow(self.resultcountwindow)
    end
end

function GuildLeagueModel:OpenMemberFightInfoRankPanel()
    if self.menberfight_rankpanel == nil then
        self.menberfight_rankpanel = GuildLeagueMenberFightRankPanel.New(self)
    end
    self.Mgr:Require17607()
    -- self.menberfight_rankpanel:Show()
end

function GuildLeagueModel:CloseMemberFightInfoRankPanel()
    if self.menberfight_rankpanel ~= nil then
        self.menberfight_rankpanel:DeleteMe()
        self.menberfight_rankpanel = nil
    end
end

function GuildLeagueModel:ChangeDefendIcon(Open)
    if self.fightinfopanel ~= nil then
        self.fightinfopanel:ChangeDefendIcon(Open)
    end
end

function GuildLeagueModel:OpenGuessWindow(args)
    if GuildManager.Instance.model:check_has_join_guild() == false then
        NoticeManager.Instance:FloatTipsByString("请先加入一个公会")
        return
    end
    if self.Mgr.kingGuildData ~= nil and self.Mgr.kingGuildData[1] == nil or #self.Mgr.kingGuildData[1] ~= 8 then
        NoticeManager.Instance:FloatTipsByString("竞猜将在<color='#ffff00'>8进4</color>比赛时开启")
        return
    end
    if self.guesswindow == nil then
        self.guesswindow = GuildLeagueGuessWindow.New(self)
    end
    self.guesswindow:Open(args)
end

function GuildLeagueModel:CloseGuessWindow()
    if self.guesswindow ~= nil then
        WindowManager.Instance:CloseWindow(self.guesswindow)
    end
end

function GuildLeagueModel:OpenHistoryPanel(args)
    if self.historyindow == nil then
        self.historyindow = GuildLeagueHistoryPanel.New(self)
    end
    self.historyindow:Show(args)
end

function GuildLeagueModel:CloseHistoryPanel()
    if self.historyindow ~= nil then
        self.historyindow:DeleteMe()
    end
end


function GuildLeagueModel:OpenLiveWindow(args)
    if self.livewindow == nil then
        self.livewindow = GuildLeagueLiveWindow.New(self)
    end
    self.livewindow:Open(args)
end

function GuildLeagueModel:CloseLivePanel()
    if self.livewindow ~= nil then
        WindowManager.Instance:CloseWindow(self.livewindow)
    end
end

function GuildLeagueModel:OpenShowCupWindow(args)
    if self.showcupwindow == nil then
        self.showcupwindow = GuildLeagueShowCupWindow.New(self)
    end
    self.showcupwindow:Open(args)
end

function GuildLeagueModel:CloseShowCupWindow()
    if self.showcupwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.showcupwindow)
    end
end

function GuildLeagueModel:OpenCupWindow(args)
    if self.cupwindow == nil then
        self.cupwindow = GuildLeagueCupWindow.New(self)
    end
    self.Mgr:Require17629()
    -- self.cupwindow:Open(args)
end

function GuildLeagueModel:CloseCupWindow()
    if self.cupwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.cupwindow)
    end
end