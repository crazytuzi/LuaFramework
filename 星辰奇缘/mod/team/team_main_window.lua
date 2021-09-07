-- -------------------------
-- 组队主面板
-- hosr
-- -------------------------
TeamMainWindow = TeamMainWindow or BaseClass(BaseWindow)

function TeamMainWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.team
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.closelistener = function(arg) self:OnClose(arg) end
    self.formationlistener = function() self:FormationUpdate() end
    self.listener = function() self:Update() end
    self.matchlistener = function() self:MatchStateChange() end
    self.infoListener = function() self:InfoUpdate() end
    self.crossListener = function() self:CheckCross() end

    self.formationAttrs = {}

    self.resList = {
        {file = AssetConfig.teamwindow, type = AssetType.Main},
        {file = AssetConfig.teamres, type = AssetType.Dep},
    }

    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.isInitOther = false
    self.openArgs = {}

    self.ttId = 0
    self.dotListener = function() self:DotDotDot() end

    self.loopListener = function() self:LoopTime() end

    self.hasInit = false
end

function TeamMainWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.team_update_match, self.matchlistener)
    EventMgr.Instance:RemoveListener(event_name.formation_update, self.formationlistener)
    EventMgr.Instance:RemoveListener(event_name.team_create, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_info_update, self.infoListener)
    EventMgr.Instance:RemoveListener(event_name.team_cross_change, self.crossListener)

    self:StopMatchCount()

    if self.membersArea ~= nil then
        self.membersArea:DeleteMe()
        self.membersArea = nil
    end
    if self.listArea ~= nil then
        self.listArea:DeleteMe()
        self.listArea = nil
    end
    if self.buttonArea ~= nil then
        self.buttonArea:DeleteMe()
        self.buttonArea = nil
    end
    if self.teamOption ~= nil then
        self.teamOption:DeleteMe()
        self.teamOption = nil
    end
    if self.formationOption ~= nil then
        self.formationOption:DeleteMe()
        self.formationOption = nil
    end
    if self.changeGuard ~= nil then
        self.changeGuard:DeleteMe()
        self.changeGuard = nil
    end
    if self.teamCross ~= nil then
        self.teamCross:DeleteMe()
        self.teamCross = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
    self.isInitOther = false

    if self.ttId ~= 0 then
        LuaTimer.Delete(self.ttId)
        self.ttId = 0
    end
    self.openArgs = {}
end

function TeamMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teamwindow))
    self.gameObject.name = "TeamWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.main = self.transform:Find("Main").gameObject
    self.closeBtn = self.transform:Find("Main/CloseButton").gameObject
    self.formationBtn = self.transform:Find("Main/FormationBtn").gameObject
    self.formationRed = self.formationBtn.transform:Find("Red").gameObject
    self.formationRed:SetActive(false)
    self.formationImg = self.formationBtn:GetComponent(Image)
    self.formationTxt = self.formationBtn.transform:Find("Text"):GetComponent(Text)
    self.autoBtn = self.transform:Find("Main/AutoBtn").gameObject
    self.autoImg = self.autoBtn:GetComponent(Image)
    self.autoTxt = self.autoBtn.transform:Find("Text"):GetComponent(Text)
    self.optionArea = self.transform:Find("Main/OptionArea").gameObject
    self.targetTxt = self.optionArea.transform:Find("Target"):GetComponent(Text)
    self.levelTxt = self.optionArea.transform:Find("Level"):GetComponent(Text)
    self.noticeBtn = self.transform:Find("Main/Notice").gameObject
    self.noticeTxt = self.transform:Find("Main/Notice/NoticeTxt"):GetComponent(Text)

    self.worldMatch = self.transform:Find("Main/MatchWorld"):GetComponent(Toggle)
    self.worldMatch.onValueChanged:AddListener(function(val) self:ClickWorldMatch(val) end)
    self.worldMatchObj = self.worldMatch.gameObject

    self.tips = self.transform:Find("Main/Tips").gameObject
    self.tips:SetActive(false)
    self.waitTxt = self.transform:Find("Main/Wait"):GetComponent(Text)
    self.waitTxt.text = ""
    self.waitTxtObj = self.waitTxt.gameObject
    self.teamFormationTxt = self.transform:Find("Main/FormationTxt"):GetComponent(Text)
    self.teamFormationTxt.text = ""
    self.teamFormationTxt.gameObject:SetActive(false)

    self.formationTxt.text = TI18N("阵法")

    self.formationBtn:GetComponent(Button).onClick:AddListener(function() self:OpenFormationOption() end)
    self.optionArea:GetComponent(Button).onClick:AddListener(function() self:OpenTeamOption() end)
    self.autoBtn:GetComponent(Button).onClick:AddListener(function() self:ClickAuto() end)
    self.closeBtn:GetComponent(Button).onClick:AddListener(function() self.model:CloseMain() end)
    self.noticeBtn:GetComponent(Button).onClick:AddListener(function() self:ClickNotice() end)
    self.noticeTxt.gameObject:SetActive(true)
    self.noticeTxt.text = ""

    self.membersArea = TeamMemberPanel.New(self)
    self.listArea = TeamListPanel.New(self)
    self.buttonArea = TeamButtonPanel.New(self)
    self.teamOption = TeamOptionPanel.New(self)
    self.formationOption = TeamFormationOptionPanel.New(self)
    self.changeGuard = TeamChangeGuardPanel.New(self)
    self.teamCross = TeamCrossTips.New(self)

    EventMgr.Instance:AddListener(event_name.team_update_match, self.matchlistener)
    EventMgr.Instance:AddListener(event_name.formation_update, self.formationlistener)
    EventMgr.Instance:AddListener(event_name.team_create, self.listener)
    EventMgr.Instance:AddListener(event_name.team_update, self.listener)
    EventMgr.Instance:AddListener(event_name.team_leave, self.listener)
    EventMgr.Instance:AddListener(event_name.team_info_update, self.infoListener)
    EventMgr.Instance:AddListener(event_name.team_cross_change, self.crossListener)
end

function TeamMainWindow:OnInitCompleted()
    self:Update()
    self:FormationUpdate()
    self:OnOpen()
end

function TeamMainWindow:OnClose(arg)
    if self.membersArea ~= nil then
        self.membersArea:OnClose()
    end
    if self.listArea ~= nil then
        self.listArea:OnClose()
    end
    if self.buttonArea ~= nil then
        self.buttonArea:OnClose()
    end
    if self.formationOption ~= nil then
        self.formationOption:OnClose()
    end
    if self.teamOption ~= nil then
        self.teamOption:OnClose()
    end
    if self.changeGuard ~= nil then
        self.changeGuard:OnClose()
    end

    -- bugly #29737013 hosr 2060722
    if self.membersArea ~= nil then
        self.membersArea:DeleteMe()
        self.membersArea = nil
    end
    if self.listArea ~= nil then
        self.listArea:DeleteMe()
        self.listArea = nil
    end
    if self.buttonArea ~= nil then
        self.buttonArea:DeleteMe()
        self.buttonArea = nil
    end
    if self.teamOption ~= nil then
        self.teamOption:DeleteMe()
        self.teamOption = nil
    end
    if self.formationOption ~= nil then
        self.formationOption:DeleteMe()
        self.formationOption = nil
    end

    self.membersArea = nil
    self.listArea = nil
    self.buttonArea = nil
    self.teamOption = nil
    self.formationOption = nil
    self.formationAttrs = {}

    EventMgr.Instance:RemoveListener(event_name.formation_update, self.formationlistener)
    EventMgr.Instance:RemoveListener(event_name.close_window, self.closelistener)
    EventMgr.Instance:RemoveListener(event_name.team_create, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_cross_change, self.crossListener)
end

function TeamMainWindow:Update()
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        self.autoImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.autoTxt.color = ColorHelper.DefaultButton2
        self.formationImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")

        if not self.isInitOther then
            self.isInitOther = true
            if TeamManager.Instance:HasApply() or TeamManager.Instance:HasRequest() or (self.openArgs ~= nil and self.openArgs[2] == 1) then
                self:OpenCloseList()
            else
                self:ChangeToMember()
            end
        end
    else
        self.autoImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.autoTxt.color = ColorHelper.DefaultButton1
        self.formationImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self:ChangeToMember()
    end

    self:TipsShowUpdate()
    self:MatchStateChange()
    self:UpdateTeamFormation()
end

function TeamMainWindow:FormationUpdate()
    local id = FormationManager.Instance.formationId
    local lev = 1
    for i,v in ipairs(FormationManager.Instance.formationList) do
        if v.id == id then
            lev = v.lev
        end
    end
    local fdata = DataFormation.data_list[string.format("%s_%s", id, lev)]
    if fdata ~= nil then
        self.formationAttrs = {fdata.attr_1, fdata.attr_2, fdata.attr_3, fdata.attr_4, fdata.attr_5}
        if fdata.id == FormationEumn.Type.None then
            self.formationTxt.text = fdata.name
        else
            self.formationTxt.text = string.format("%sLv.%s", fdata.name, lev)
        end
    end
end

-- 更新队伍战法
function TeamMainWindow:UpdateTeamFormation()
    if not TeamManager.Instance:HasTeam() then
        self.teamFormationTxt.text = ""
        self.teamFormationTxt.gameObject:SetActive(false)
        return
    end

    local id = TeamManager.Instance.TypeData.team_formation
    local lev = TeamManager.Instance.TypeData.team_formation_lev
    local fdata = DataFormation.data_list[string.format("%s_%s", id, lev)]
    if fdata ~= nil then
        if id == 1 then
            self.teamFormationTxt.text = string.format(TI18N("队伍阵法:%s"), fdata.name)
        else
            self.teamFormationTxt.text = string.format(TI18N("队伍阵法:%sLv.%s"), fdata.name, lev)
        end
        self.teamFormationTxt.gameObject:SetActive(true)
    else
        self.teamFormationTxt.text = ""
        self.teamFormationTxt.gameObject:SetActive(false)
    end

    if self.membersArea ~= nil and self.membersArea.isInit then
        self.membersArea:UpdateFormationAttr()
    end
end

--关闭或打开列表界面
function TeamMainWindow:OpenCloseList(force)
    if not self.listArea.isOpen or force then
        self.membersArea:Hiden()
        self.listArea:Show()
        self:ChangeButtonType("list")
    else
        self:ChangeToMember()
    end
end

function TeamMainWindow:ChangeToMember()
    self.listArea:Hiden()
    self.membersArea:Show()
    self:ChangeButtonType("normal")
end

function TeamMainWindow:ChangeButtonType(type)
    -- if self.buttonArea.gameObject == nil then
    if not self.buttonArea.isInit then
        self.buttonArea:Show(type)
    else
        self.buttonArea:ShowType(type)
    end
end

function TeamMainWindow:OpenTeamOption()
    if RoleManager.Instance.RoleData.lev < 18 then
        NoticeManager.Instance:FloatTipsByString(TI18N("18级开启匹配"))
        return
    end
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        self.teamOption:Show()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("只有队长可进行此操作"))
    end
end

function TeamMainWindow:OpenFormationOption()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.formation)
    -- if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
    --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.formation)
    -- else
    --     NoticeManager.Instance:FloatTipsByString("只有队长可进行此操作")
    -- end
end

function TeamMainWindow:SetTeamOption()
    local types = {}
    local range = nil
    local roleLev = RoleManager.Instance.RoleData.lev
    local tdata = nil

    if roleLev >= 18 or (TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.None and TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.Leader) then
        for first,second in pairs(TeamManager.Instance.TypeOptions) do
            if second == 0 then
                -- 因为自己没有高级的队伍配置数据
                if roleLev < 18 then
                    tdata = DataTeam.data_match[first * 10 + 1]
                else
                    tdata = TeamManager.Instance:FirstTab(first)
                end
                if tdata ~= nil then
                    table.insert(types, tdata.tab_name)
                end
            else
                tdata = DataTeam.data_match[second]
                if tdata ~= nil then
                    table.insert(types, tdata.type_name)
                else
                    Log.Error(string.format("组队类型错误， id:%s", second))
                end
            end
        end

        if tdata ~= nil then
            local lev_recruit = {}
            if RoleManager.Instance.RoleData.cross_type == 1 then
                lev_recruit = tdata.cross_lev_recruit
            else
                lev_recruit = tdata.lev_recruit
            end
            if TeamManager.Instance.LevelOption ~= 0 and #lev_recruit > 0 then
                for i,lev in ipairs(lev_recruit) do
                    if lev.flag == TeamManager.Instance.LevelOption then
                        if lev.lev == TeamEumn.MatchLevType.Fixed then
                            range = {lev.val1, lev.val2}
                        elseif lev.lev == TeamEumn.MatchLevType.Dynamic then
                            range = {math.max(tdata.open_lev, roleLev + lev.val1), roleLev + lev.val2}
                        end
                        break
                    end
                end
            end
        end

        if #types > 1 then
            self.targetTxt.text = TI18N("自定义")
        elseif #types == 0 then
            self.targetTxt.text = "---"
        elseif #types == 1 then
            self.targetTxt.text = types[1]
        end

        self.levelTxt.text = "---"
        if TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.None then
            if TeamManager.Instance.LevelOption == 3 then
                self.levelTxt.text = TI18N("带新人")
            else
                if range ~= nil then
                    local max = math.min(RoleManager.Instance.world_lev + 8, range[2])
                    if RoleManager.Instance.RoleData.cross_type == 1 then
                        max = range[2]
                    end
                    max = math.min(max, 130)
                    self.levelTxt.text = string.format(TI18N("%s级~%s级"), range[1], max)
                end
            end
        end

        self.optionArea:SetActive(true)
        self.noticeBtn.gameObject:SetActive(true)
        self.autoBtn.gameObject:SetActive(true)
    else
        -- 小于18级不现实队伍设置
        self.optionArea:SetActive(false)
        self.noticeBtn.gameObject:SetActive(false)
        self.autoBtn.gameObject:SetActive(false)
    end
end

--点击匹配
function TeamMainWindow:ClickAuto(force)
    if RoleManager.Instance.RoleData.lev < 18 then
        return
    end

    if TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.Leader and TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.None then
        NoticeManager.Instance:FloatTipsByString(TI18N("只有队长可进行此操作"))
        return
    end

    local lev = TeamManager.Instance.LevelOption
    local types = {}
    for first,second in pairs(TeamManager.Instance.TypeOptions) do
        if second == 0 then
            local id = TeamManager.Instance.FirstList[first].id
            table.insert(types, {type = id})
        else
            local id = DataTeam.data_match[second].id
            table.insert(types, {type = id})
        end
    end

    if #types == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先进行队伍匹配类型设置"))
        return
    end

    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        if not force and TeamManager.Instance:MyMatchStatus() == TeamEumn.MatchStatus.Recruiting then
            TeamManager.Instance:Send11719()
        else
            TeamManager.Instance:Send11711(types[1].type, lev)
        end
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        if not force and TeamManager.Instance:MyMatchStatus() == TeamEumn.MatchStatus.Matching then
            TeamManager.Instance:Send11720()
        else
            TeamManager.Instance:Send11714(types)
        end
    end
end

function TeamMainWindow:OpenChangeGuard(args)
    self.changeGuard:Show(args)
end

function TeamMainWindow:ClickNotice()
    if RoleManager.Instance:CanConnectCenter() then
        -- -- 可以跨服才打开界面
        -- if RoleManager.Instance.RoleData.cross_type == 1 then
        --     NoticeManager.Instance:FloatTipsByString(TI18N("当前已在跨服状态"))
        -- else
        --     self.teamCross:Show()
        -- end

        -- 现在改为无论什么状态逗可以打开界面 20180414
        self.teamCross:Show()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("暂未连接跨服，请留意公告"))
    end
end

function TeamMainWindow:MatchStateChange()
    if self.ttId ~= 0 then
        LuaTimer.Delete(self.ttId)
        self.ttId = 0
    end
    self:StopMatchCount()
    if TeamManager.Instance:HasTeam() then
        if TeamManager.Instance:MyMatchStatus() == TeamEumn.MatchStatus.Recruiting then
            self.tc = 0
            self.autoTxt.text = TI18N("招募中")
            self.ttId = LuaTimer.Add(0, 500, self.dotListener)
        else
            self.autoTxt.text = TI18N("开始招募")
        end
    else
        if TeamManager.Instance:MyMatchStatus() == TeamEumn.MatchStatus.Matching then
            self.tc = 0
            self.autoTxt.text = TI18N("匹配中")
            self.ttId = LuaTimer.Add(0, 500, self.dotListener)
            self:StartMatchCount()
        else
            self.autoTxt.text = TI18N("自动匹配")
        end
    end
end

function TeamMainWindow:DotDotDot()
    if self.tc == 3 then
        self.tc = 0
        if TeamManager.Instance:MyMatchStatus() == TeamEumn.MatchStatus.Recruiting then
            self.autoTxt.text = TI18N("招募中")
        elseif TeamManager.Instance:MyMatchStatus() == TeamEumn.MatchStatus.Matching then
            self.autoTxt.text = TI18N("匹配中")
        end
    else
        self.tc = self.tc + 1
        self.autoTxt.text = self.autoTxt.text .. "."
    end
end

-- 匹配持续时间
function TeamMainWindow:StartMatchCount()
    self.worldMatchObj:SetActive(false)
    self.waitTxtObj:SetActive(true)
    self.waitTxt.text = string.format(TI18N("等待时间:00秒"))
    self.matchTimeId = LuaTimer.Add(500, 1000, self.loopListener)
end

function TeamMainWindow:LoopTime()
    local time = BaseUtils.BASE_TIME - TeamManager.Instance.TypeData.match_time
    if time <= 0 then
        time = TI18N("00秒")
    elseif time < 60 then
        time = string.format(TI18N("%s秒"), os.date("%S", time))
    else
        time = string.format(TI18N("%s分%s秒"), os.date("%M", time), os.date("%S", time))
    end
    self.waitTxt.text = string.format(TI18N("等待时间:%s"), time)
end

function TeamMainWindow:StopMatchCount()
    self.worldMatchObj:SetActive(true)
    self.waitTxtObj:SetActive(false)
    self.waitTxt.text = ""
    if self.matchTimeId ~= nil then
        LuaTimer.Delete(self.matchTimeId)
        self.matchTimeId = nil
    end
end

function TeamMainWindow:OnOpen()
    self:CheckCross()
    self:UpdateFormationRed()

    -- 第一个参数是是否开启匹配 0:否 1:是
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        if self.openArgs[1] == 1 then
            self:ClickAuto(true)
        end
    elseif TeamManager.Instance.matchStatus == TeamEumn.MatchStatus.None then
        -- 根据所在场景选中默认类型
        local map = SceneManager.Instance:CurrentMapId()
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.Match then
            -- 段位赛
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[6] = 63
            TeamManager.Instance.LevelOption = 1
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.Event_fairyland then
            -- 幻境
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[6] = 62
            TeamManager.Instance.LevelOption = 1
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.TopCompete then
            -- 巅峰
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[6] = 64
            TeamManager.Instance.LevelOption = 1
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.StarChallenge then
            -- 龙王
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[15] = StarChallengeManager.Instance.model:GetTeamType()
            TeamManager.Instance.LevelOption = 1
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.ApocalypseLord then
            -- 天启
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[16] = ApocalypseLordManager.Instance.model:GetTeamType()
            TeamManager.Instance.LevelOption = 1
        elseif map == 42000 then
            -- 多人副本夺宝奇兵
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[4] = 47
            TeamManager.Instance.LevelOption = 1
        elseif map == 42100 then
            -- 无尽挑战
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[4] = 48
            TeamManager.Instance.LevelOption = 1
        elseif map == 41001 then
            -- 天空塔1层
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[7] = 71
            TeamManager.Instance.LevelOption = 1
        elseif map == 41002 then
            -- 天空塔2层
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[7] = 72
            TeamManager.Instance.LevelOption = 1
        elseif map == 41003 then
            -- 天空塔3层
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[7] = 73
            TeamManager.Instance.LevelOption = 1
        elseif map == 50001 or map == 50002 or map == 50003 or map == 50011 or map == 50012 or map == 50013 or map == 50021 or map == 50022 or map == 50023 then
            -- 挂机
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[2] = 0
            TeamManager.Instance.LevelOption = 1
        elseif (map == 30009 or map == 30010 or map == 30011) and HeroManager.Instance.model.myInfo ~= nil and HeroManager.Instance.model.myInfo.group ~= nil then
            -- 荣耀试炼
            TeamManager.Instance.TypeOptions = {}
            local group = HeroManager.Instance.model.myInfo.group
            local lev = RoleManager.Instance.RoleData.lev
            TeamManager.Instance.TypeOptions[6] = 99 + group
            TeamManager.Instance.LevelOption = 1
        elseif map == ExquisiteShelfManager.Instance.readyMapId then
            -- 玲珑宝阁
            local cfgData = DataTeam.data_match[ExquisiteShelfManager.Instance:GetTeamType()]
            TeamManager.Instance.TypeOptions = {}
            TeamManager.Instance.TypeOptions[cfgData.tab_id] = cfgData.id
            TeamManager.Instance.LevelOption = 1
        -- elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon then 
        --     -- 峡谷之巅
        --     TeamManager.Instance.TypeOptions = {}
        --     local group = CanYonManager.Instance.group_id
        --     local lev = RoleManager.Instance.RoleData.lev
        --     TeamManager.Instance.TypeOptions[20] = CanYonManager.Instance:GetTeamTypeID()
        --     TeamManager.Instance.LevelOption = 1
        else
            -- 不在活动场景里面了，把特定的活动匹配取消
            TeamManager.Instance.TypeOptions[6] = nil
            TeamManager.Instance.TypeOptions[7] = nil
            TeamManager.Instance.TypeOptions[2] = nil
            TeamManager.Instance.TypeOptions[20] = nil

            -- 如果没有设置的，默认设置问悬赏
            local has = false
            for k,v in pairs(TeamManager.Instance.TypeOptions) do
                has = true
            end
            if not has then
                TeamManager.Instance.TypeOptions = {}
                TeamManager.Instance.TypeOptions[5] = 0
                TeamManager.Instance.LevelOption = 1
            end
        end
    end

    self:SetTeamOption()

    self:UpdateWorldMatchFlag(true)
end

function TeamMainWindow:OnHide()
    self.openArgs = {}
    if self.ttId ~= 0 then
        LuaTimer.Delete(self.ttId)
        self.ttId = 0
    end
end

function TeamMainWindow:UpdateFormationRed()
    if FormationManager.Instance:Check() then
        self.formationRed:SetActive(true)
    else
        self.formationRed:SetActive(false)
    end
end

function TeamMainWindow:InfoUpdate()
    self:SetTeamOption()
    self:MatchStateChange()
    self:UpdateTeamFormation()
end

function TeamMainWindow:TipsShowUpdate()
    if TeamManager.Instance:HasTeam() then
        self.tips:SetActive(false)
    else
        self.tips:SetActive(true)
    end
end

function TeamMainWindow:CheckCross()
    -- if RoleManager.Instance:CanConnectCenter() then
    --     self.noticeTxt.gameObject:SetActive(true)
        -- if TeamManager.Instance.IsCross == 1 then
            -- 进入跨服
            -- self.noticeTxt.text = TI18N("跨服组队")
        -- else
            -- 不进入跨服
            -- self.noticeTxt.text = TI18N("跨服组队")
        -- end
    -- else
    --     self.noticeTxt.gameObject:SetActive(false)
    --     self.noticeTxt.text = ""
    -- end
end

function TeamMainWindow:ClickWorldMatch(val)
    if not self.hasInit then
        return
    end

    if val == (self.flag == 1) then
        return
    end

    self.worldMatch.isOn = val

    if val then
        self.flag = 1
    else
        self.flag = 0
    end

    if val then
        TeamManager.Instance:SetWorldMatchFlag(1)
    else
        TeamManager.Instance:SetWorldMatchFlag(0)
    end
    self:UpdateWorldMatchFlag()
end

function TeamMainWindow:UpdateWorldMatchFlag(isInit)
    if self.flag == nil then
        self.flag = TeamManager.Instance:GetWorldMatchFlag()
    end

    local str = ""
    if self.flag == 1 then
        if isInit then
            self.worldMatch.isOn = true
        end
        str = TI18N("世界喊话开启，招募时将在世界频道发送招募信息")
    else
        if isInit then
            self.worldMatch.isOn = false
        end
        str = TI18N("世界喊话关闭，招募时将不会在世界频道发送招募信息")
    end
    self.hasInit = true

    if not isInit then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = str
        NoticeManager.Instance:ConfirmTips(data)
    end
end