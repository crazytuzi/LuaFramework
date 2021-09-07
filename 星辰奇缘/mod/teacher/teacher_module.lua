-- @author zgs
TeacherModel = TeacherModel or BaseClass(BaseModel)

function TeacherModel:__init()
    self.gaWin = nil

    self.beTeacherState = 0 --0没有报名，1已经报名
    self.selectteacherList = nil --推荐师傅列表

    self.myTeacherInfo = nil --我的师徒信息
    self.teacherStudentList = nil --师徒信息
    self.teacherPhoto = 0 --师门师傅的头像

    self.noProblem = 1 --问卷调查题目ID
    self.answers = {} --问卷题目选择答案

    self.teachergiftMax = 0  --师傅最多礼包
    self.teachergiftReceived = 0  --师傅已领礼包

    self.dailyData = {}
    self.targetData = {}
    self.masterRewardList = {}

    self.levelChangeListener = function() self:OnLevelChangeListener() end
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levelChangeListener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levelChangeListener)
end

function TeacherModel:OnLevelChangeListener()
    if self.myTeacherInfo ~= nil and self.myTeacherInfo.status == 1 then
        local evaluatedDic = {}
        for i,v in ipairs(self.myTeacherInfo.evaluation) do
            evaluatedDic[v.lev] = v.lev
        end
        local needShowLev = 0
        local lev = RoleManager.Instance.RoleData.lev
        local levsDic = BaseUtils.copytab(DataTeacher.data_levs)
        table.sort(levsDic, function (a,b)
            return a.lev < b.lev
        end )
        -- BaseUtils.dump(levsDic,"--------------")
        for i,v in ipairs(levsDic) do
            if v.lev > self.myTeacherInfo.study_lev then
                if v.lev < lev then
                    --小于当前等级的所有等级中
                    if evaluatedDic[v.lev] == nil then
                        --没有评价过的等级
                        -- needShowLev = v.lev
                        print(v.lev)
                        TeacherManager.Instance:send15810(v.lev,3)
                    end
                elseif v.lev == lev then
                    if evaluatedDic[v.lev] == nil then
                        --没有评价过的等级
                        needShowLev = v.lev
                    end
                end
            end
        end
        evaluatedDic = nil
        if needShowLev > 0 then
            self:ShowEvaluatePanel(true,needShowLev)
        else
            self:ShowEvaluatePanel(false)
        end
    end
end

function TeacherModel:__delete()
    if self.gaWin then
        self.gaWin = nil
    end
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levelChangeListener)
end

function TeacherModel:OpenWindow(args)
    if self.gaWin == nil then
        self.gaWin = TeacherWindow.New(self)
    end
    self.gaWin:Open(args)
end

function TeacherModel:OpenDailyWindow(args)
    if self.dailyWin == nil then
        self.dailyWin = ApprenticeshipWindow.New(self)
    end
    self.dailyWin:Open(args)
end

function TeacherModel:CloseDailyWindow()
    WindowManager.Instance:CloseWindow(self.dailyWin)
end

-- function TeacherModel:UpdateWindow()
--     if self.gaWin ~= nil then
--         self.gaWin:updateTeacherWindow()
--     end
-- end

function TeacherModel:CloseMain()
    WindowManager.Instance:CloseWindow(self.gaWin, true)
end

function TeacherModel:OpenApprenticeSignUpWindow(args)
    if self.apprenticeSignUpWindow == nil then
        self.apprenticeSignUpWindow = ApprenticeSignUpWindow.New(self)
    end
    self.apprenticeSignUpWindow:Open(args)
end

function TeacherModel:CloseApprenticeSignUpWindow()
    if self.apprenticeSignUpWindow ~= nil then
        self.apprenticeSignUpWindow:DeleteMe()
        self.apprenticeSignUpWindow = nil
    end
end

function TeacherModel:OpenFindTeacherWindow(args)
    if self.findTeacherWindow == nil then
        self.findTeacherWindow = FindTeacherWindow.New(self)
    end
    self.findTeacherWindow:Open(args)
end

function TeacherModel:CloseFindTeacherWindow()
    if self.findTeacherWindow ~= nil then
        self.findTeacherWindow:DeleteMe()
        self.findTeacherWindow = nil
    end
end

--是否有师徒关系
function TeacherModel:IsHasTeahcerStudentRelationShip()
    if self.myTeacherInfo == nil or self.myTeacherInfo.status == 0 then
        return false
    end
    return true
end

--是不是我的徒弟
function TeacherModel:IsMyStudent(stu)
    -- BaseUtils.dump(stu,"self.teacherStudentList.list---stu")
    -- BaseUtils.dump(self.teacherStudentList.list,"self.teacherStudentList.list")
    if self.teacherStudentList == nil or self.teacherStudentList.list == nil then
        return false
    end
    for i,v in ipairs(self.teacherStudentList.list) do
        if v.rid == stu.id and v.platform == stu.platform and v.zone_id == stu.zone_id then
            return true, v.status
        end
    end
    return false
end
--返回我的指定徒弟的信息
function TeacherModel:MyStudentInfo(stu)
    -- BaseUtils.dump(stu,"self.teacherStudentList.list---stu")
    -- BaseUtils.dump(self.teacherStudentList.list,"self.teacherStudentList.list")
    if self.teacherStudentList == nil or self.teacherStudentList.list == nil then
        return nil
    end
    for i,v in ipairs(self.teacherStudentList.list) do
        if v.rid == stu.id and v.platform == stu.platform and v.zone_id == stu.zone_id then
            return v
        end
    end
    return nil
end
--是不是我的师傅
function TeacherModel:IsMyTeacher(tea)
    if self.myTeacherInfo ~= nil and tea.id == self.myTeacherInfo.rid and tea.platform == self.myTeacherInfo.platform and tea.zone_id == self.myTeacherInfo.zone_id then
        return true, self.myTeacherInfo.status
    end
    return false
end

--带徒拜师1
function TeacherModel:TakeStudentToMyStudent()
    -- -- print("-----------TakeStudentApprentice------------")
    if TeamManager.Instance.teamNumber == 2 then
        local myData = RoleManager.Instance.RoleData
        local stu = nil
        for key, value in pairs(TeamManager.Instance.memberTab) do
             if myData.id ~= value.rid and BaseUtils.IsTheSamePlatform(value.platform, value.zone_id) then -- and myData.platform == value.platform and myData.zone_id == value.zone_id then
                stu = value
                break
             end
        end
        -- BaseUtils.dump(stu,"stu===============")
        if stu ~= nil then
            local WorldLevData = DataTeacher.data_get_condition[RoleManager.Instance.world_lev]
            if BaseUtils.IsTheSamePlatform(stu.platform,stu.zone_id) == false then
                return TI18N("跨服区暂不支持师徒功能，敬请期待")
            elseif RoleManager.Instance.RoleData.lev >= WorldLevData.need_lev then
                if RoleManager.Instance.RoleData.lev - stu.lev >= 5 then
                    if stu.lev >= 20 then
                        if stu.lev <= WorldLevData.boundary_lev then
                            stu.id = stu.rid
                            stu.tsFlag = TeacherEnum.Type.Student --数据是学生的
                            self:ShowApprenticePanel(true,stu)
                            return ""
                        else
                            return string.format(TI18N("队员等级超过了<color='%s'>%d级</color>，无法拜师"),ColorHelper.color[1],WorldLevData.boundary_lev)
                        end
                    else
                        return string.format(TI18N("队员等级不足<color='%s'>20级</color>，无法拜师"),ColorHelper.color[1])
                    end
                else
                    return string.format(TI18N("队员与你的等级差<color='%s'>小于5级</color>， 无法拜师"),ColorHelper.color[1])
                end
            else
                return string.format(TI18N("你的等级不足<color='%s'>%d级</color>，无法收徒"),ColorHelper.color[1],WorldLevData.need_lev)
            end
        else
            return TI18N("数据错误")
        end
    elseif TeamManager.Instance.teamNumber > 2 then
        -- NoticeManager.Instance:FloatTipsByString("一次只能带一个玩家拜师")
        return TI18N("一次只能带一个玩家拜师")
    else
        -- NoticeManager.Instance:FloatTipsByString("拜师需要两人组队前来，你一个人来干什么")
        return TI18N("拜师需要两人组队前来，你一个人来干什么")
    end
    return TI18N("测试代码问题")
end
--带徒出师
function TeacherModel:TakeStudentBeTeacher()
    -- -- print("------------------")
    if TeamManager.Instance.teamNumber == 2 then
        local myData = RoleManager.Instance.RoleData
        local stu = nil
        for key, value in pairs(TeamManager.Instance.memberTab) do
            -- value.rid, value.platform, value.zone_id
             if myData.id ~= value.rid and BaseUtils.IsTheSamePlatform(value.platform, value.zone_id) then -- and myData.platform == value.platform and myData.zone_id == value.zone_id then
                stu = value
                break
             end
        end

        if stu ~= nil then
            stu.id = stu.rid
            if BaseUtils.IsTheSamePlatform(stu.platform,stu.zone_id) == false then
                return TI18N("跨服区暂不支持师徒功能，敬请期待")
            elseif self:IsMyStudent(stu) == true then
                local WorldLevData = DataTeacher.data_get_condition[RoleManager.Instance.world_lev]
                if stu.lev >= WorldLevData.graduate_lev then
                    local studentData = self:MyStudentInfo(stu)
                    if studentData.teacher_score < 200 then
                        local data = NoticeConfirmData.New()
                        data.type = ConfirmData.Style.Normal
                        data.content = string.format(TI18N("当前与徒弟<color='%s'>%s</color>的师道值<color='#ffff00'>不足200</color>，仅能获得保底奖励，是否继续出师？"),ColorHelper.color[5],stu.name)
                        data.sureLabel = TI18N("确定")
                        data.cancelLabel = TI18N("取消")
                        data.sureCallback = function ()
                            -- print("-========================================------------")
                            LuaTimer.Add(100,function ()
                                local data = NoticeConfirmData.New()
                                data.type = ConfirmData.Style.Normal
                                data.content = string.format(TI18N("你的徒弟<color='%s'>%s</color>已经达到<color='%s'>%d级</color>，出师后可获得大量奖励，确定让他出师呢？"),ColorHelper.color[5],stu.name,ColorHelper.color[1],stu.lev)
                                data.sureLabel = TI18N("确定")
                                data.cancelLabel = TI18N("取消")
                                data.sureCallback = function ()
                                    TeacherManager.Instance:send15811(stu.rid,stu.platform,stu.zone_id,3)
                                end
                                NoticeManager.Instance:ConfirmTips(data)
                            end)
                        end
                        NoticeManager.Instance:ConfirmTips(data)
                    else
                        local data = NoticeConfirmData.New()
                        data.type = ConfirmData.Style.Normal
                        data.content = string.format(TI18N("你的徒弟<color='%s'>%s</color>已经达到<color='%s'>%d级</color>，出师后可获得大量奖励，确定让他出师呢？"),ColorHelper.color[5],stu.name,ColorHelper.color[1],stu.lev)
                        data.sureLabel = TI18N("确定")
                        data.cancelLabel = TI18N("取消")
                        data.sureCallback = function ()
                            TeacherManager.Instance:send15811(stu.rid,stu.platform,stu.zone_id,3)
                        end
                        NoticeManager.Instance:ConfirmTips(data)
                    end
                else
                    return string.format(TI18N("徒弟等级尚未达到<color='%s'>%d级</color>，无法出师"),ColorHelper.color[1],WorldLevData.graduate_lev)
                end
            else
                -- NoticeManager.Instance:FloatTipsByString("你没有带来可以出师的徒弟，无法出师")
                return TI18N("队伍中的队员，不是你的徒弟，无法出师")
            end
        end
        return ""
    elseif TeamManager.Instance.teamNumber > 2 then
        -- NoticeManager.Instance:FloatTipsByString("一次只能带一个徒弟出师")
        return TI18N("一次只能带一个徒弟出师")
    else
        -- NoticeManager.Instance:FloatTipsByString("出师需要两人组队前来，你一个人来干什么")
        return TI18N("出师需要两人组队前来，你一个人来干什么")
    end
end

--显示/隐藏调查问卷
function TeacherModel:ShowApprenticeResearchPanel(bo)
    if bo == true then
        if self.arp == nil then
            self.arp = ApprenticeResearchPanel.New(self)
        end
        self.arp:Show()
    else
    end
end
--显示/隐藏师傅推荐列表
function TeacherModel:ShowSelectTeacherPanel(bo)
    if bo == true then
        if self.stp == nil then
            self.stp = SelectTeacherPanel.New(self)
        end
        self.stp:Show()
    else
    end
end
--是否同意成为师徒窗口
function TeacherModel:ShowApprenticePanel(bo,data)
    if bo == true then
        if self.ap == nil then
            self.ap = ApprenticePanel.New(self)
        end
        self.ap:Show(data)
    else
    end
end
--成功成为师徒提示窗口
function TeacherModel:ShowBeBSPanel(bo,data)
    if bo == true then
        if self.bbsp == nil then
            self.bbsp = BeBSPanel.New(self)
        end
        self.bbsp:Show(data)
    else
    end
end
--师傅解除师徒关系窗口
function TeacherModel:ShowBreakTSPanel(bo)
    if bo == true then
        if self.btsp == nil then
            self.btsp = BreakTSPanel.New(self)
        end
        self.btsp:Show()
    else
    end
end

--显示师傅评价窗口
function TeacherModel:ShowEvaluatePanel(bo,lev)
    if bo == true then
        if self.ep == nil then
            self.ep = EvaluatePanel.New(self)
        end
        self.ep:Show({lev})
    else
        if self.ep ~= nil then
            self.ep:Hiden()
        end
    end
end
--显示出师奖励界面
function TeacherModel:ShowBeTeacherFinishRewardPanel(bo,data)
    if bo == true then
        if self.btfrp == nil then
            self.btfrp = BeTeacherFinishRewardPanel.New(self)
        end
        self.btfrp:Show(data)
    else
        if self.btfrp ~= nil then
            self.btfrp:Hiden()
        end
    end
end

function TeacherModel:SpecialDaily(id)
    if id == 1 then     -- 职业任务
        QuestManager.Instance.model:DoCycle()
        self:CloseDailyWindow()
    elseif id == DataTeacher.data_get_daily_length + 1 then     -- 剧情任务
        for k,v in pairs(QuestManager.Instance.questTab) do
            if v.sec_type == 1 or v.sec_type == 2 or v.sec_type == 5 then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.taskwindow, v)
                return true
            end
        end
    elseif id == 10 then
        DungeonManager.Instance:EnterTower(1)
        self:CloseDailyWindow()
    elseif id == 7 then
        -- 上古妖魔
        local cmp = 9999
        local map_id = -1
        for k,v in ipairs(DataTreasure.data_map) do
            if map_id == -1 and RoleManager.Instance.RoleData.lev >= v.min_lev and RoleManager.Instance.RoleData.lev <= v.max_lev then
                map_id = v.map_base_id
            end
        end
        if map_id ~= -1 then
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            -- SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_Transport(map_id, 0, 0)
        end
        self:CloseDailyWindow()
    else
        return false
    end
    return true
end

function TeacherModel:OpenAccept(args)
    if self.acceptPanel == nil then
        self.acceptPanel = TeacherAcceptPanel.New(self)
    end
    self.acceptPanel:Show(args)
end

function TeacherModel:CloseAccept()
    if self.acceptPanel ~= nil then
        self.acceptPanel:DeleteMe()
        self.acceptPanel = nil
    end
end

