-- @author 黄耀聪
-- @date 2016年9月8日

MidAutumnFestivalModel = MidAutumnFestivalModel or BaseClass(BaseModel)

function MidAutumnFestivalModel:__init()
    self.hideStatus = false
    self.mainuiText = {
        [MidAutumnFestivalManager.Instance.skyLanternStatus.Nobegin] = {time = TI18N("剩余出现时间:%s"), ext = TI18N("孔明灯即将刷新 场内人数:<color='#ffff00'>%s</color>"),},
        [MidAutumnFestivalManager.Instance.skyLanternStatus.FirstWave] = {time = TI18N("剩余出现时间:%s"), ext = TI18N("孔明灯即将刷新 场内人数:<color='#ffff00'>%s</color>")},
        [MidAutumnFestivalManager.Instance.skyLanternStatus.Fight] = {time = TI18N("本轮剩余时间:%s"), lantern = TI18N("剩余孔明灯:<color='#ffff00'>%s</color>"), ext = TI18N("场内人数:<color='#ffff00'>%s</color>")},
        [MidAutumnFestivalManager.Instance.skyLanternStatus.Clean] = {time = TI18N("正在清场:%s"), ext = TI18N("孔明灯即将刷新 场内人数:<color='#ffff00'>%s</color>")},
        [MidAutumnFestivalManager.Instance.skyLanternStatus.Wait] = {time = TI18N("准备刷新:%s"), ext = TI18N("孔明灯即将刷新 场内人数:<color='#ffff00'>%s</color>")},
        [MidAutumnFestivalManager.Instance.skyLanternStatus.Finish] = {time = TI18N("活动结束"), ext = TI18N("")},
    }
    self.TraceText = {
        -- [MidAutumnFestivalManager.Instance.skyLanternStatus.Nobegin] = {time = TI18N("剩余出现时间:%s"), ext = TI18N("孔明灯即将刷新 场内人数:%s"),},
        [MidAutumnFestivalManager.Instance.skyLanternStatus.FirstWave] = {time = TI18N("剩余出现时间:%s")},
        [MidAutumnFestivalManager.Instance.skyLanternStatus.Fight] = {time = TI18N("存活剩余时间:%s")},
        [MidAutumnFestivalManager.Instance.skyLanternStatus.Clean] = {time = TI18N("准备刷新:%s"), ext = TI18N("孔明灯即将刷新 场内人数:<color='#ffff00'>%s</color>")},
        [MidAutumnFestivalManager.Instance.skyLanternStatus.Wait] = {time = TI18N("准备刷新:%s"), ext = TI18N("孔明灯即将刷新 场内人数:<color='#ffff00'>%s</color>")},
        [MidAutumnFestivalManager.Instance.skyLanternStatus.Finish] = {time = TI18N("活动结束"), ext = TI18N("")},
    }
end

function MidAutumnFestivalModel:__delete() end

function MidAutumnFestivalModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = MidAutumnFestivalWindow.New(self)
    end
    self.mainWin:Open(args)
end

function MidAutumnFestivalModel:CloseWindow()
end

function MidAutumnFestivalModel:OpenQuestion(args)
    if self.questionWin == nil then
        self.questionWin = MidAutumnQuestionWindow.New(self)
    end
    self.questionWin:Open(args)
end

function MidAutumnFestivalModel:OnQuestionPlayEffect()
    if self.questionWin ~= nil then
        self.questionWin:OnPlayRightEffect()
    end
end

function MidAutumnFestivalModel:OpenSettle(args)
    if self.settleWin == nil then
        self.settleWin = MidAutumnSettleWindow.New(self)
    end
    self.settleWin:Open(args)
end

function MidAutumnFestivalModel:OpenLetItGo(args)
    if self.letItGoWin == nil then
        self.letItGoWin = MidAutumnLetItGo.New(self)
    end
    self.letItGoWin:Open(args)
end

function MidAutumnFestivalModel:ShowLanternMainUI()
    if self.lanternPanel == nil then
        self.lanternPanel = LanternMainUIPanel.New(self, ctx.CanvasContainer)
    end
    self.lanternPanel:Show()

    local t = MainUIManager.Instance.MainUIIconView

    if t ~= nil then
        t:Set_ShowTop(false, {312})
    end

    -- if RoleManager.Instance.RoleData.event == RoleEumn.Event.SkyLantern and self.hasShowTalk ~= true then
    --     local npcBase = BaseUtils.copytab(DataUnit.data_unit[74141])
    --     MainUIManager.Instance:OpenDialog({baseid = 74141, name = npcBase.name}, {base = npcBase}, true, true)

    --     self.hasShowTalk = true
    -- end
end

function MidAutumnFestivalModel:CloseLanternMainUI()
    if self.lanternPanel ~= nil then
        self.lanternPanel:DeleteMe()
        self.lanternPanel = nil
        self.lantern_target_time = nil

        local t = MainUIManager.Instance.MainUIIconView

        if t ~= nil then
            t:Set_ShowTop(true, {312})
        end

        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.mid_autumn_letitgo)
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.mid_autumn_danmaku)

        DanmakuManager.Instance.CloseNormal = false
    end
end

function MidAutumnFestivalModel:ShowEnjoyMoonMainUI()
    local t = self["enjoymoon_left_time"] or 0
    if t <= 5 * 60 then
        return
    end

    if self.enjoyMainUI == nil then
        self.enjoyMainUI = MidAutumnEnjoyMainui.New(self)
    end
    self.enjoyMainUI:Show()

    local t = MainUIManager.Instance.MainUIIconView
    if t ~= nil then
        t:Set_ShowTop(false, {312})
    end
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(self.hideStatus)
end

function MidAutumnFestivalModel:CloseEnjoyMoonMainUI()
    if self.enjoyMainUI ~= nil then
        self.enjoyMainUI:DeleteMe()
        self.enjoyMainUI = nil

        local t = MainUIManager.Instance.MainUIIconView
        if t ~= nil then
            t:Set_ShowTop(true, {312})
        end
        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson) == true)
    end
end

function MidAutumnFestivalModel:OpenExchange(args)
    if self.exchangeWin == nil then
        self.exchangeWin = MidAutumnExchangeWindow.New(self)
    end
    self.exchangeWin:Open(args)
end

function MidAutumnFestivalModel:CloseExchange(args)
    if self.exchangeWin ~= nil then
        WindowManager.Instance:CloseWindow(self.exchangeWin)
    end
end

function MidAutumnFestivalModel:OpenDanmaku(args)
    if self.danmakuWin == nil then
        self.danmakuWin = MidAutumnDanmaku.New(self)
    end
    self.danmakuWin:Open(args)
end

function MidAutumnFestivalModel:AskRankData()
    self.rankDataList = self.rankDataList or {}
    MidAutumnFestivalManager.Instance:send14068()
end

