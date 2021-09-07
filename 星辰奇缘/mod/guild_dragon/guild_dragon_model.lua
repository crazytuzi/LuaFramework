-- @author 黄耀聪
-- @date 2017年11月13日, 星期一

GuildDragonModel = GuildDragonModel or BaseClass(BaseModel)

function GuildDragonModel:__init()
    self.rank_list = {}
    self.player_info = {}
    self.rewardList = {{}, {}}
    self.looks_list = {}
    self.loot_list = nil
end

function GuildDragonModel:__delete()
end

function GuildDragonModel:OpenMain(args)
    if self.mainWin == nil then
        self.mainWin = GuildDragonMain.New(self)
    end
    self.mainWin:Open(args)
end

function GuildDragonModel:OpenSettle(args)
    if self.settleWin == nil then
        self.settleWin = GuildDragonSettle.New(self)
    end
    self.settleWin:Open(args)
end

function GuildDragonModel:OpenRod(args)
    if self.rodWin == nil then
        self.rodWin = GuildDragonRod.New(self)
    end
    self.rodWin:Open(args)
end

function GuildDragonModel:OpenEndRod(args)
    if self.endRodPanel == nil then
        self.endRodPanel = GuildDragonEndRod.New(self, TipsManager.Instance.model.tipsCanvas)
    end
    self.endRodPanel:Open(args)
end

function GuildDragonModel:OpenEndFight(args)
    if self.endFightPanel == nil then
        self.endFightPanel = GuildDragonEndFight.New(self, TipsManager.Instance.model.tipsCanvas)
    end
    self.endFightPanel:Open(args)
end

function GuildDragonModel:GetLooks(id, platform, zone_id)
    local roleData = RoleManager.Instance.RoleData
    if self.looks_list[BaseUtils.Key(id, platform, zone_id)] == nil then
        GuildDragonManager.Instance:send20510(id, platform, zone_id)
        return nil
    else
        return self.looks_list[BaseUtils.Key(id, platform, zone_id)]
    end
end

function GuildDragonModel:StartCheck()
    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 500,
            function()
                GuildDragonManager.Instance:ChangeCD()
                GuildDragonManager.Instance:CheckOnArena()
                self:CheckTips()
            end
        )
    end
    self:EnterScene()
end

function GuildDragonModel:CheckTips()
    if GuildDragonManager.Instance.state == GuildDragonEnum.State.Ready then
        self:OpenMainUI(string.format(TI18N("<color='#00ff00'>%s</color>后才进入巨龙峡谷挑战巨龙！"), BaseUtils.formate_time_gap(GuildDragonManager.Instance.end_time - BaseUtils.BASE_TIME, ":", 1, BaseUtils.time_formate.MIN)))
    elseif GuildDragonManager.Instance.state == GuildDragonEnum.State.Close then
        self:CloseMainUI()
    elseif GuildDragonManager.Instance.state == GuildDragonEnum.State.Reward then
        self:OpenMainUI(TI18N("恭喜挑战成功！"))
    else
        if (not self.hasNotified) and GuildDragonManager.Instance.state == GuildDragonEnum.State.First and BaseUtils.BASE_TIME - GuildDragonManager.Instance.start_time == 5 then
            NoticeManager.Instance:FloatTipsByString(TI18N("巨龙已经苏醒，快去挑战吧！"))
            self.hasNotified = true
        end
        if self.myData ~= nil and self.myData.challenge_time > BaseUtils.BASE_TIME then
            self.noTips = true
            self:OpenMainUI(string.format(TI18N("受龙威影响，<color='#ffff00'>%s</color>后才能进入巨龙峡谷！"), BaseUtils.formate_time_gap(self.myData.challenge_time - BaseUtils.BASE_TIME, ":", 1, BaseUtils.time_formate.MIN)))
        else
            if self.noTips then
                NoticeManager.Instance:FloatTipsByString(TI18N("体力已经恢复，可继续挑战巨龙！"))
                self.noTips = false
            end
            self:OpenMainUI(TI18N("挑战巨龙可获得<color='#ffff00'>大量龙币</color>！"))
        end
    end
end

function GuildDragonModel:EndCheck()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self:ExitScene()
    MainUIManager.Instance:DeleteTracePanel(TraceEumn.BtnType.GuildDragon)
end

function GuildDragonModel:EnterScene()
    if GuildDragonManager.Instance.state == GuildDragonEnum.State.First
        or GuildDragonManager.Instance.state == GuildDragonEnum.State.Second
        or GuildDragonManager.Instance.state == GuildDragonEnum.State.Third
        then
        self:OpenMainUI()
    end

    local t = MainUIManager.Instance.MainUIIconView

    if t ~= nil then
        t:Set_ShowTop(false, {17, 107})
    end
end

function GuildDragonModel:ExitScene()
    self:CloseMainUI()
end

function GuildDragonModel:OpenMainUI(args)
    if self.mainuiPanel == nil then
        self.mainuiPanel = GuildDragonMainUI.New(self, ctx.CanvasContainer)
    end
    self.mainuiPanel:Show(args)
end

function GuildDragonModel:CloseMainUI()
    if self.mainuiPanel ~= nil then
        self.mainuiPanel:DeleteMe()
        self.mainuiPanel = nil


        local t = MainUIManager.Instance.MainUIIconView
        if t ~= nil then
            t:Set_ShowTop(true, {17, 107})
        end
    end

    self:CloseDamakuSetting()
end

function GuildDragonModel:OpenDamakuSetting()
    if self.damakuSetting == nil then
        self.damakuSetting = GuildDragonCloseDamaku.New(self, TipsManager.Instance.model.tipsCanvas)
    end
    self.damakuSetting:Show()
end

function GuildDragonModel:CloseDamakuSetting()
    if self.damakuSetting ~= nil then
        self.damakuSetting:DeleteMe()
        self.damakuSetting = nil
    end
end

