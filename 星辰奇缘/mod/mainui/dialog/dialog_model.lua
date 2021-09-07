 -- --------------------------
-- npc对话框管理
-- hosr
-- --------------------------
DialogModel = DialogModel or BaseClass(BaseModel)

function DialogModel:__init()
    self.currentNpcData = nil

    self.sureMatch = function()
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[5] = 0
        TeamManager.Instance.LevelOption = 1
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
    end

    self.createTeam = function()
        TeamManager.Instance.TypeOptions = {}
        TeamManager.Instance.TypeOptions[5] = 0
        TeamManager.Instance.LevelOption = 1
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
    end
    self.setDataFun = function() self:CheckIsActive() end

end

-- 按钮参数处理
function DialogModel:ButtonAction(action, args, rule)
    --print(debug.traceback())
    local actionType = DialogEumn.ActionType
    local notDoHide = false
    -- print("#########################")
    print("action = "..action)


    local campId = args.campId  --目前只有类型996调用的才有活动id

    if action == actionType.action0 then
        -- 打开UI
        local id = tonumber(args[1])
        local a = {}
        for i= 2, #args do
            table.insert(a, args[i])
        end
        a.campId = campId
        if id == 18601 and QuestManager.Instance:GetQuest(83100) == nil then
            --子女任务购买瓶子界面没任务不给打开
            return
        end
        WindowManager.Instance:OpenWindowById(id, a)
    elseif action == actionType.action1 then
        local basdundata = DataDungeon.data_get[tonumber(args[1])]
        if TeamManager.Instance:MemberCount() >= basdundata.need_num then
        --进入副本
            DungeonManager.Instance:EnterDungeon(tonumber(args[1]))
        else
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            -- extra.base.buttons = {} -- {extra.base.buttons[3]}
            extra.base.buttons = {{button_id = actionType.action22, button_args = {4,tonumber(args[2]),1,1}, button_desc = TI18N("便捷组队"), button_show = ""}}
            -- extra.base.buttons[1].button_id = actionType.action22
            -- -- extra.base.buttons[1].button_args = {4,args[2]}
            -- extra.base.buttons[1].button_args = {4,tonumber(args[2]),1,1}
            extra.base.plot_talk = string.format(TI18N("多人副本是一件危险的事情，还是队伍人数≥%s人以上再来吧!"), tostring(basdundata.need_num))
            self:Open(self.currentNpcData, extra, true)
            return
        end
    elseif action == actionType.action2 then
        --悬赏任务
        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            if TeamManager.Instance:MemberCount() >= 2 then
                AutoFarmManager.Instance:StopAncientDemons()
                QuestManager.Instance:Send10211(QuestEumn.TaskType.offer)
            else
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                extra.base.buttons = {extra.base.buttons[2]}
                extra.base.buttons[1].button_id = actionType.action22
                extra.base.buttons[1].button_args = {5}
                extra.base.plot_talk = TI18N("悬赏是一件危险的事情，还是队伍人数≥2人以上再来吧!")
                self:Open(self.currentNpcData, extra, true)
                return
            end
        elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            extra.base.buttons = {extra.base.buttons[2]}
            extra.base.buttons[1].button_id = actionType.action22
            extra.base.buttons[1].button_args = {5}
            extra.base.plot_talk = TI18N("悬赏是一件危险的事情，还是<color='#ffff00'>队伍人数≥2</color>以上再来吧!")
            self:Open(self.currentNpcData, extra, true)
            return
        end
    elseif action == actionType.action3 then
        --职业任务
        local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.cycle)
        if questData ~= nil then
            QuestManager.Instance.model:DoCycle()
        else

            QuestManager.Instance:Send10211(QuestEumn.TaskType.cycle)
        end
    elseif action == actionType.action4 or action == actionType.action74 then
        -- 规则说明


        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}


        extra.base.buttons = {btn}
        extra.base.plot_talk = rule
        self:Open(self.currentNpcData, extra, true, true)
        return
    elseif action == actionType.action6 then
        --检查等级
        if not self:CheckMonkey() then
            return
        end
        local sure = function()
            self:Hide()
            SceneManager.Instance:Send10100(self.currentNpcData.battleid, self.currentNpcData.id)
        end

        local npcBase = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        if npcBase ~= nil and npcBase.fun_type == SceneConstData.fun_type_quest_prac then
            local questData = QuestManager.Instance:GetQuestMain()
            if questData.sec_type == QuestEumn.TaskType.practice_pro and TeamManager.Instance:MemberCount() < 2 then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("本场战斗<color='#ffff00'>难度较大</color>，建议组队后再来，是否确定进入战斗？")
                data.sureLabel = TI18N("确定")
                data.cancelLabel = TI18N("发起匹配")
                data.sureCallback = sure
                -- data.cancelCallback = function() QuestManager.Instance:Send10218(questData.id) end
                data.cancelCallback = function()
                    -- 创建队伍,发起招募
                    TeamManager.Instance.TypeOptions = {}
                    TeamManager.Instance.TypeOptions[8] = 81
                    TeamManager.Instance.LevelOption = 1
                    TeamManager.Instance:Send11701()
                    LuaTimer.Add(500, function() TeamManager.Instance:AutoFind() end)
                end
                data.showClose = 1
                NoticeManager.Instance:ConfirmTips(data)
            else
                sure()
            end
        elseif npcBase ~= nil and npcBase.fun_type == SceneConstData.fun_type_constellation and self.currentNpcData.battleid == 0 then
            ConstellationManager.Instance:Send15204()
        elseif npcBase ~= nil and npcBase.fun_type == SceneConstData.fun_type_treasure_ghost then
            if AutoFarmManager.Instance.FarmingAncientDemons then
                local has = false
                local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
                for k,v in pairs(units) do
                    if v.battleid == self.currentNpcData.battleid and v.id == self.currentNpcData.id then
                        has = true
                         if v.status ~= 0 then
                            NoticeManager.Instance:FloatTipsByString(TI18N("目标正在战斗中，开始搜寻新目标"))
                            AutoFarmManager.Instance:StarAncientDemons()
                        else
                            sure()
                            return
                        end
                    end
                end
                if not has then
                    NoticeManager.Instance:FloatTipsByString(TI18N("当前目标已被消灭，开始搜寻新目标"))
                    AutoFarmManager.Instance:StarAncientDemons()
                end
            else
                sure()
            end
        else
            sure()
        end
    elseif action == actionType.action7 then
        QuestManager.Instance:Send10211(QuestEumn.TaskType.treasuremap)
    elseif action == actionType.action8 then
        if tonumber(args[1]) == 1 then
            TrialManager.Instance.model:dialog_button_click(args)
        elseif tonumber(args[1]) == 2 then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            local btn1 = {button_id = DialogEumn.ActionType.action8, button_args = { 1, battleid = args.battleid, id = args.id}, button_desc = TI18N("独自挑战"), button_show = "[]"}
            local btn2 = {button_id = DialogEumn.ActionType.action48, button_args = {1}, button_desc = string.format(TI18N("求助(%s/2)"), TrialManager.Instance.model.can_ask), button_show = "[]"}
            extra.base.buttons = { btn1, btn2 }
            extra.base.plot_talk = TI18N("你打不过我，去找个帮手再来挑战我吧！{face_1, 25}<color='#ffff00'>（本关已经失败过一次，建议向他人寻求帮助）</color>")
            self:Open(self.currentNpcData, extra, true)
            return
        end
    elseif action == actionType.action9 then
        --接取公会任务
        QuestManager.Instance:Send10211(QuestEumn.TaskType.guild)
    elseif action == actionType.action12 then
        if args[1] ~= 0 then
            DungeonManager.Instance:Require14301(args[1])
        else
            SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
        end
    elseif action == actionType.action11 then
        --段位赛npc

        if RoleManager.Instance.RoleData.cross_type == 1 then
            -- 如果处在中央服，先回到本服在参加活动
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.sureSecond = -1
            confirmData.cancelSecond = 180
            confirmData.sureLabel = TI18N("确认")
            confirmData.cancelLabel = TI18N("取消")
            RoleManager.Instance.jump_over_call = function()
                QualifyManager.Instance:request13512()
            end
            confirmData.sureCallback = SceneManager.Instance.quitCenter
            confirmData.content = string.format("<color='#ffff00'>%s</color>%s", TI18N("彩虹冒险"), TI18N("活动已开启，是否<color='#ffff00'>返回原服</color>参加？"))
            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            QualifyManager.Instance:request13512()
        end

    elseif action == actionType.action14 then
        --退出段位赛场景
        QualifyManager.Instance:request13513()
    elseif action == actionType.action15 then
        -- 任务链
        if #args == 0 then
            local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.chain)
            if questData ~= nil then
                QuestManager.Instance.model:DoChain()
            else
                AutoQuestManager.Instance.model:OpenAutoModeSelectWindow()
            end
        else
            if args[1] == 1 then
                -- 进入战斗
                local battleid = tonumber(args[2])
                local npcid = tonumber(args[3])
                QuestManager.Instance:Send10217(battleid, npcid)
            elseif args[1] == 2 then
                -- 跳过战斗
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("历练任务的战斗比较凶险，英雄可以花费一定的代价<color='#ffff00'>直接完成</color>任务，可从以下两种中选择一种：")
                data.sureLabel = TI18N("使用{assets_1,90007,300}")
                data.cancelLabel = TI18N("支付{assets_1,90002,50}")
                data.showClose = 1
                data.blueSure = true
                data.cancelCallback= function() QuestManager.Instance:Send10216(90002) end
                data.sureCallback = function() QuestManager.Instance:Send10216(90007) end
                NoticeManager.Instance:ConfirmTips(data)
            elseif args[1] == 3 then
                -- 公会求助
                local sec_type = tonumber(args[2])
                -- if not TeamManager.Instance:HasTeam() then
                --     TeamManager.Instance:Send11701()
                -- end
                -- local questData = QuestManager.Instance:GetQuestByType(sec_type)
                -- if questData ~= nil then
                --     QuestManager.Instance:Send10218(questData.id)
                -- end
                SosManager.Instance:Send16000(sec_type)
            elseif args[1] == 4 then
                -- 放弃任务
                local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.chain)
                if questData ~= nil then
                    QuestManager.Instance:GiveUp(questData)
                else
                    local extra = {}
                    extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                    local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                    extra.base.buttons = {btn}
                    extra.base.plot_talk = rule
                    extra.base.plot_talk = TI18N("您并未有接取任何历练环任务哦!")
                    self:Open(self.currentNpcData, extra, true)
                    return
                end
            elseif args[1] == 5 then
                -- 查看幸运值
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                extra.base.buttons = {btn}
                extra.base.plot_talk = rule
                extra.base.plot_talk = string.format(TI18N("当前的历练环任务幸运值为：<color='#00ff00'>%s</color>\n每次未获得护符的100环和200环历练任务均可获得幸运值，达到<color='#ffff00'>100</color>点幸运值可获得<color='#00ff00'>历练护符礼包</color>，直接获得一个<color='#00ff00'>月亮护符</color>或<color='#00ff00'>太阳护符</color>{face_1, 20}"), QuestManager.Instance.chainLucky)
                self:Open(self.currentNpcData, extra, true)
                return
            end
        end
    elseif action == actionType.action16 then
        --请求参与科举会试答题
        ExamManager.Instance:request14501(args[1])
    elseif action == actionType.action17 then
        local temp_data = ExamManager.Instance.model.cur_question_data
        if ExamManager.Instance.model.cur_exam_type == 3 then
            ExamManager.Instance:request14501(args[1])
        elseif temp_data ~= nil and temp_data.total ~= temp_data.answered then
            ExamManager.Instance:request14503()
        else
            if ExamManager.Instance.model.cur_exam_type == 2 and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.Exam then
                --会试,点了非主考官的考官，没报名，弹出确认框，确认后自动寻路到自考官
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("你当前尚未报名<color='#4dd52b'>智慧闯关-半决赛</color>，是否前往半决赛考官处报名？")
                data.sureLabel = TI18N("报名")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    local npc_data = ExamManager.Instance.model:get_npc_data_by_date()
                    local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)
                    SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id, nil, nil, true)
                end
                NoticeManager.Instance:ConfirmTips(data)
            else
                ExamManager.Instance:request14501(args[1])
            end
        end
    elseif action == actionType.action18 then
        --除会长以外的人都可以自荐做会长
        if GuildManager.Instance.model:get_my_guild_post() == GuildManager.Instance.model.member_positions.leader then
            NoticeManager.Instance:FloatTipsByString(TI18N("您已经是会长了"))
            return
        end
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否要消耗500000{assets_2,90000}自荐为会长")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.cancelSecond = 30
        data.sureCallback = function()
            GuildManager.Instance:request11158()
        end
        NoticeManager.Instance:ConfirmTips(data)
    elseif action == actionType.action19 then
        --传到指定地图
        SceneManager.Instance.sceneElementsModel:Self_Transport(tonumber(args[1]), 0, 0)
    elseif action == actionType.action20 then
        if args[1] == 1 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godanimal_window, {[1] = GodAnimalManager.Instance.SHOWTYPE_DRAGON})
        elseif args[1] == 2 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godanimal_window, {[1] = GodAnimalManager.Instance.SHOWTYPE_GOD})
        elseif args[1] == 3 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godanimal_window, {[1] = GodAnimalManager.Instance.SHOWTYPE_JANE})
        end
    elseif action == actionType.action21 then
        FairyLandManager.Instance:request14602()
    elseif action == actionType.action22 then
        if not self:CheckMonkey() then
            return
        end

        -- 便捷组队
        local first = tonumber(args[1])
        local second = 0
        local auto = 1
        if args[2] ~= nil then
            second = tonumber(args[2])
        end
        local level = 1
        if args[3] ~= nil then
            level = tonumber(args[3])
        end
        if args[4] ~= nil then
            auto = tonumber(args[4])
        end

        -- 新加一个逻辑 2016-12-16 hosr
        -- 悬赏的招募先弹出提示框
        if first == 5 and not TeamManager.Instance:HasTeam() then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            extra.base.buttons = {{},{}}
            extra.base.buttons[1].button_id = actionType.action220
            extra.base.buttons[1].button_args = {5, 51, 1, 1, 1}
            extra.base.buttons[1].button_desc = TI18N("做队长")
            extra.base.buttons[2].button_id = actionType.action220
            extra.base.buttons[2].button_args = {5, 51, 1, 1, 0}
            extra.base.buttons[2].button_desc = TI18N("做队员")
            self:Open(self.currentNpcData, extra, true)
            return
        else
            self:AutoMatch(first, second, level, auto, false)
        end
    elseif action == actionType.action220 then
        -- 便捷组队
        local first = tonumber(args[1])
        local second = 0
        local auto = 1
        if args[2] ~= nil then
            second = tonumber(args[2])
        end
        local level = 1
        if args[3] ~= nil then
            level = tonumber(args[3])
        end
        if args[4] ~= nil then
            auto = tonumber(args[4])
        end
        local doCaptin = false
        if args[5] ~= nil then
            doCaptin = tonumber(args[5]) == 1
        end
        self:AutoMatch(first, second, level, auto, doCaptin)
    elseif action == actionType.action23 then
        FairyLandManager.Instance:request14601()
    elseif action == actionType.action24 then
        ParadeManager.Instance:EatCheckIn()
        -- if RoleManager.Instance.RoleData.lev >= 30 then
        --     local confirm = function()
        --         ParadeManager.Instance:Require13301()
        --     end
        --     local data = NoticeConfirmData.New()
        --     data.type = ConfirmData.Style.Normal
        --     data.content = "是否参加吃货巡游?"
        --     data.sureLabel = "确定"
        --     data.cancelLabel = "取消"
        --     data.sureCallback = confirm
        --     NoticeManager.Instance:ConfirmTips(data)
        -- else
        --     NoticeManager.Instance:FloatTipsByString("30级方可参加巡游")
        -- end
    elseif action == actionType.action25 then
        ExamManager.Instance:request14506()
    elseif action == actionType.action26 then
        if args[1] == 1 then
            WarriorManager.Instance:CheckIn()
        elseif args[1] == 2 then
            WarriorManager.Instance:OnExit(1)
        elseif args[1] == 3 then
            WarriorManager.Instance:OnExit(2)
        end
    elseif action == actionType.action27 then

    elseif action == actionType.action28 then
        ExamManager.Instance:request14507()
    elseif action == actionType.action29 then
        local back_mem_num = 0
        for k, v in pairs(TeamManager.Instance.memberTab) do
            if v.status == RoleEumn.TeamStatus.Follow or v.status == RoleEumn.TeamStatus.Leader then
                back_mem_num = back_mem_num + 1
            end
        end
        if back_mem_num < 3 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("世界BOSS异常强大，三人及以上组队<color='#ffff00'>（且归队）</color>才可挑战")
            data.sureLabel = TI18N("便捷组队")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function ()
                self:ButtonAction(actionType.action22, args, rule)
            end
            NoticeManager.Instance:ConfirmTips(data)
        else
            SceneManager.Instance:Send10100(self.currentNpcData.battleid, self.currentNpcData.id)
        end
    elseif action == actionType.action30 then
        --智慧闯关决赛场内寻路到npc
        local next_cfg_data = DataExamination.data_get_examiner[7]
        local npc_data = next_cfg_data.location[2]
        local id_battle_id = BaseUtils.get_unique_npcid(npc_data[1], 12)
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(npc_data[2], id_battle_id, nil, nil, true)
    elseif action == actionType.action31 then
        local num = 10 - DataAgenda.data_list[1011].engaged
        if num > 0 then
            TreasuremapManager.Instance:Send13604()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("今日已获得10张藏宝图"))
        end
    elseif action == actionType.action32 then
        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            if TeamManager.Instance:MemberCount() >= 3 then
                ClassesChallengeManager.Instance:Send14801()
            else
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                extra.base.buttons = {extra.base.buttons[2]}
                extra.base.buttons[1].button_id = actionType.action22
                extra.base.buttons[1].button_args = {6, 61, 1, 1}
                extra.base.plot_talk = TI18N("职业挑战需要多职业互相配合进行，阵容越丰富越好。需要<color='#ffff00'>队伍人数≥3人</color>才能报名哦")
                self:Open(self.currentNpcData, extra, true)
                return
            end
        elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            extra.base.buttons = {extra.base.buttons[2]}
            extra.base.buttons[1].button_id = actionType.action22
            extra.base.buttons[1].button_args = {6, 61, 1, 1}
            extra.base.plot_talk = TI18N("职业挑战需要多职业互相配合进行，阵容越丰富越好。需要<color='#ffff00'>队伍人数≥3人</color>才能报名哦")
            self:Open(self.currentNpcData, extra, true)
            return
        end
    elseif action == actionType.action33 then
        local list = TeamManager.Instance:GetMemberByTeamStatus(RoleEumn.TeamStatus.Away)
        if #list == 0 then
            ClassesChallengeManager.Instance:Send14803(self.currentNpcData.battleid, self.currentNpcData.id, args[1])
        else
            local nameStr = ""
            for i = 1, #list do
                nameStr = string.format("%s%s", nameStr, list[i].name)
                if i ~= #list then string.format("%s、", nameStr) end
            end

            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("队伍中的<color='#00ff00'>%s</color>暂未归队，确定发起战斗吗？"), nameStr)
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function() ClassesChallengeManager.Instance:Send14803(self.currentNpcData.battleid, self.currentNpcData.id, args[1]) end
            NoticeManager.Instance:ConfirmTips(data)
        end
    elseif action == actionType.action34 then
        ClassesChallengeManager.Instance:Send14805()
    elseif action == actionType.action35 then
        if args[1] == 1 then

            if RoleManager.Instance:CheckCross() then
                return
            end
            if self:CheckIsCouple() then
                --伴侣任务
                local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.couple)
                if questData ~= nil then
                    QuestManager.Instance.model:DoCouple()
                else
                    QuestManager.Instance:Send10211(QuestEumn.TaskType.couple)
                end
            elseif RoleManager.Instance.RoleData.wedding_status <= 1 and self:CheckIsAmbiguous() then
                --情缘任务
                local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.ambiguous)
                if questData ~= nil then
                    QuestManager.Instance.model:DoAmbiguous()
                else
                    QuestManager.Instance:Send10211(QuestEumn.TaskType.ambiguous)
                end
            else
                return
            end
        elseif args[1] == 2 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marryskillwindow)
        else
            if RoleManager.Instance.RoleData.wedding_status == 1 then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_wedding_window)
            elseif RoleManager.Instance.RoleData.wedding_status == 3 then
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                extra.base.buttons = {}
                extra.base.plot_talk = TI18N("你已经结缘啦，不能再申请结缘哦")
                self:Open(self.currentNpcData, extra, true)
                return
            else
                if RoleManager.Instance.RoleData.cross_type == 1 then
                    NoticeManager.Instance:FloatTipsByString(TI18N("跨服区无法进行结缘"))
                    self:Hide()
                    return
                end

                local openMark = false
                if TeamManager.Instance.teamNumber == 2 then
                    for key, value in pairs(TeamManager.Instance.memberTab) do
                        local uid = BaseUtils.Key(value.rid, value.platform, value.zone_id)
                        if FriendManager.Instance.friend_List[uid] ~= nil and FriendManager.Instance.friend_List[uid].sex ~= RoleManager.Instance.RoleData.sex and FriendManager.Instance.friend_List[uid].intimacy >= 999 then
                            openMark = true
                        end
                    end
                end

                if openMark then
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_propose_window)
                else
                    local extra = {}
                    extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                    -- local btn = {button_id = actionType.action35, button_args = {2}, button_desc = "去结缘申请", button_show = ""}
                    -- extra.base.buttons = {btn}
                    extra.base.buttons = {}
                    extra.base.plot_talk = TI18N("<color='#ffff00'>结缘</color>条件：1.与另一半达到<color='#ffff00'>999亲密度</color>。\n2.二人组队后，由任一方使用<color='#ffff00'>喜结良缘戒指</color>发起结缘申请。\n3.喜结良缘戒指可在<color='#ffff00'>金币市场</color>中购买")
                    self:Open(self.currentNpcData, extra, true)
                    return
                end
            end
        end
    elseif action == actionType.action36 then
        if args[1] == 1 then
            --进入公会战
            -- GuildfightManager.Instance:send15502()
            GuildfightManager.Instance:GuildFightCheckIn()
        elseif args[1] == 2 then
            --退出公会战
            -- if TeamManager.Instance:HasTeam() == true then
            --     NoticeManager.Instance:FloatTipsByString("请先退出队伍，再尝试退出战场")
            -- else
            --     local data = NoticeConfirmData.New()
            --     data.type = ConfirmData.Style.Normal
            --     data.content = "战友们需要你！现在退出将无法再次进入！"
            --     data.sureLabel = "退出"
            --     data.cancelLabel = "取消"
            --     data.sureCallback = function ()
            --         GuildfightManager.Instance:send15503()
            --     end
            --     NoticeManager.Instance:ConfirmTips(data)
            -- end
            GuildfightManager.Instance:send15503()
        end
    elseif action == actionType.action37 then
        --参加活动，便捷组队，开始任务
        local status_data = PetLoveManager.Instance.model.pet_love_status_data
        if status_data ~= nil and (status_data.phase == 2 or status_data.phase == 3) then
            if PetLoveManager.Instance.model.has_sign == 1 then
                --还没有参加，则报名
                PetLoveManager.Instance:request15602()
            elseif PetLoveManager.Instance.model.has_sign == 3 then
                --已经提交了任务
                PetLoveManager.Instance:request15602()
            else
                --已经参加，则判断队伍规则满不满足
                if TeamManager.Instance:HasTeam() then
                    local leave_num = 0
                    local total_num = 0
                    for k, v in pairs(TeamManager.Instance.memberTab) do
                        total_num = total_num + 1
                    end
                    if total_num >= 2 then
                        --接收任务
                        PetLoveManager.Instance:request15607()
                    else
                        --便捷组队
                        TeamManager.Instance.TypeOptions = {}
                        TeamManager.Instance.TypeOptions[6] = 66
                        TeamManager.Instance.LevelOption = 1
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team,{1})
                    end
                else
                    --便捷组队
                    TeamManager.Instance.TypeOptions = {}
                    TeamManager.Instance.TypeOptions[6] = 66
                    TeamManager.Instance.LevelOption = 1
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team,{1})
                end
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启"))
        end
    elseif action == actionType.action38 then
        --宠物情缘形象变换
        PetLoveManager.Instance:request15610()
    elseif action == actionType.action39 then
        --退出宠物情缘活动
        PetLoveManager.Instance:request15604()
    elseif action == actionType.action40 then   -- 节日礼官
        local currentMonth = tonumber(os.date("%m", BaseUtils.BASE_TIME))
        local currentDay = tonumber(os.date("%d", BaseUtils.BASE_TIME))
        local extra = {}

        self.festivalList = FestivalManager.Instance.model.festivalList

        local festivalData = nil
        local nextData = nil
        local currentIndex = 0
        for i = 1, #self.festivalList do
            if currentMonth == self.festivalList[i].mount and currentDay == self.festivalList[i].day then
                festivalData = self.festivalList[i]
                currentIndex = i
                -- nextData = self.festivalList[i + 1]
                break
            end

            if nextData == nil and (tonumber(self.festivalList[i].mount) == currentMonth and tonumber(self.festivalList[i].day) >= currentDay or tonumber(self.festivalList[i].mount) > currentMonth) then
                nextData = self.festivalList[i]
            end
        end

        if festivalData ~= nil then
            nextData = self.festivalList[currentIndex % #self.festivalList + 1]
        end

        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.buttons = {}
        if args[1] == 1 then
            extra.base.buttons[1] = {}
            extra.base.buttons[1].button_id = actionType.action40
            extra.base.buttons[1].button_args = {2}
            extra.base.buttons[1].button_desc = TI18N("下次节日日期")

            if festivalData == nil then
                extra.base.plot_talk = TI18N("今天不是节日哦~所以没有礼物啦{face_1, 22}")
            else
                extra.base.buttons[2] = extra.base.buttons[1]
                extra.base.plot_talk = festivalData.desc
                extra.base.buttons[1] = {}
                extra.base.buttons[1].button_id = actionType.action40
                extra.base.buttons[1].button_args = {3}
                extra.base.buttons[1].button_desc = TI18N("领取节日礼物")
            end

            self:Open(self.currentNpcData, extra, true, true)
            return
        elseif args[1] == 2 then
            if nextData == nil then
                nextData = DataFestival.data_festival["1_1"]
            end
            extra.base.plot_talk = string.format(TI18N("下次节日礼物将于<color='#00ff00'>%s月%s日%s</color>发放哦~{face_1, 22}"), tostring(nextData.mount), tostring(nextData.day), nextData.name)
            self:Open(self.currentNpcData, extra, true)
            return
        elseif args[1] == 3 then
            SceneManager.Instance:Send10100(self.currentNpcData.battleid, self.currentNpcData.id)
        else
        end
    elseif action == actionType.action41 then
        if RoleManager.Instance.RoleData.wedding_status == 1 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_divorce_window, {1})
        elseif RoleManager.Instance.RoleData.wedding_status == 2 or RoleManager.Instance.RoleData.wedding_status == 3 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_divorce_window, {2})
        else
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            extra.base.buttons = {}
            extra.base.plot_talk = TI18N("你都还没结缘怎么就想着要解除结缘！{face_1,28}")
            self:Open(self.currentNpcData, extra, true)
            return
        end
    elseif action == actionType.action42 then
            -- 种植任务
            local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.plant)
            if questData ~= nil then
                -- QuestManager.Instance.model:DoPlant()
                NoticeManager.Instance:FloatTipsByString(TI18N("今天已领取了哟，明天再来吧{face_1,3}"))
            else
                QuestManager.Instance:Send10211(QuestEumn.TaskType.plant)
            end
    elseif action == actionType.action43 then
        --师徒
        if RoleManager.Instance.RoleData.cross_type == 1 then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
            extra.base.buttons = {btn}
            -- extra.base.plot_talk = rule
            extra.base.plot_talk = string.format(TI18N("跨服区暂不支持师徒功能，敬请期待"))
            self:Open(self.currentNpcData, extra, true)
            return
        end
        -- print(args[1].."----------------------=============================")
        if args[1] == 1 then
            --带徒拜师
            local strTemp = TeacherManager.Instance.model:TakeStudentToMyStudent()
            if strTemp ~= "" then
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                extra.base.buttons = {btn}
                -- extra.base.plot_talk = rule
                extra.base.plot_talk = string.format(TI18N(strTemp))
                self:Open(self.currentNpcData, extra, true)
                return
            end
        elseif args[1] == 2 then
            --带徒出师
            local strTemp = TeacherManager.Instance.model:TakeStudentBeTeacher()
            if strTemp ~= "" then
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                extra.base.buttons = {btn}
                extra.base.plot_talk = string.format(TI18N(strTemp))
                self:Open(self.currentNpcData, extra, true)
                return
            end
        elseif args[1] == 3 then
            --解除师徒关系
            if TeacherManager.Instance.model.myTeacherInfo ~= nil then
                if TeacherManager.Instance.model.myTeacherInfo.status == 1 then
                    --学生解除师徒关系
                    local timeTemp = BaseUtils.BASE_TIME - TeacherManager.Instance.model.teacherStudentList.login_time
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.sureLabel = TI18N("解除关系")
                    data.cancelLabel = TI18N("取消")
                    data.sureCallback = function ()
                        local info = TeacherManager.Instance.model.myTeacherInfo
                        TeacherManager.Instance:send15811(info.rid,info.platform,info.zone_id,2)
                    end
                    if timeTemp > 86400 then
                        --离线1天以上
                        data.content = string.format(TI18N("解除师徒关系后，<color='#00ff00'>6小时</color>内不能拜师，确定要解除与师傅<color='#00ff00'>%s</color>的师徒关系吗？"),
                            TeacherManager.Instance.model.myTeacherInfo.name)
                    else
                        data.content = string.format(TI18N("解除师徒关系后，<color='#00ff00'>6小时</color>内不能拜师，确定要解除与师傅<color='#00ff00'>%s</color>的师徒关系吗？"),TeacherManager.Instance.model.myTeacherInfo.name)
                    end
                    NoticeManager.Instance:ConfirmTips(data)
                elseif TeacherManager.Instance.model.myTeacherInfo.status == 3 then
                    --师傅解除师徒关系
                    local ishasStuInLearning = false
                    for i,v in ipairs(TeacherManager.Instance.model.teacherStudentList.list) do
                        if v.status == 1 then
                            ishasStuInLearning = true
                            break
                        end
                    end
                    if ishasStuInLearning == true then
                        TeacherManager.Instance.model:ShowBreakTSPanel(true)
                        ishasStuInLearning = nil
                    else
                        NoticeManager.Instance:FloatTipsByString(TI18N("你现在没有徒弟{face_1, 22}"))
                    end
                else
                    -- NoticeManager.Instance:FloatTipsByString("你没有师徒关系，无法解除")
                    local extra = {}
                    local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                    extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                    extra.base.buttons = {btn}
                    extra.base.plot_talk = string.format(TI18N("你没有师徒关系，无法解除"))
                    self:Open(self.currentNpcData, extra, true)
                    return
                end
            end
        elseif args[1] == 4 then
            -- if RoleManager.Instance.world_lev < 50 then
            if false then
                -- NoticeManager.Instance:FloatTipsByString("世界等级不足50级，暂未开放师徒功能!")
                local extra = {}
                local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                extra.base.buttons = {btn}
                extra.base.plot_talk = string.format(TI18N("世界等级不足50级，暂未开放师徒功能"))
                self:Open(self.currentNpcData, extra, true)
                return
            else
                if RoleManager.Instance.RoleData.lev > 49 then
                    if TeacherManager.Instance.model.beTeacherState == 0 then
                        --我要报名师傅
                        TeacherManager.Instance:send15814("")
                        -- TeacherManager.Instance.model:OpenApprenticeSignUpWindow()
                    else
                        --取消自动收徒
                        TeacherManager.Instance:send15814("")
                    end
                else--if RoleManager.Instance.RoleData.lev > 14 then
                    --我要寻找师傅
                    if RoleManager.Instance.RoleData.lev > 19 then
                        TeacherManager.Instance.model:ShowApprenticeResearchPanel(true)
                        -- TeacherManager.Instance.model:OpenFindTeacherWindow(true) --这个面板改为找徒弟了
                    else
                        -- NoticeManager.Instance:FloatTipsByString("您的等级不足15级，还无法进行拜师~")
                        local extra = {}
                        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                        local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                        extra.base.buttons = {btn}
                        extra.base.plot_talk = string.format(TI18N("您的等级不足20级，还无法进行拜师"))
                        self:Open(self.currentNpcData, extra, true)
                        return
                    end
                end
            end
        elseif args[1] == 5 then
            if RoleManager.Instance.RoleData.lev > 49 then
                TeacherManager.Instance.model:OpenFindTeacherWindow(true) --这个面板改为找徒弟了
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("你现在还不能找徒弟"))
            end
        end
    elseif action == actionType.action44 then
        --导师助理
        if tonumber(args[1]) == 1 then
            -- 师徒任务
            local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.teacher)
            if questData ~= nil then
                QuestManager.Instance.model:DoTeacher()
            else
                QuestManager.Instance:Send10211(QuestEumn.TaskType.teacher)
            end
        elseif tonumber(args[1]) == 2 then
            -- 查看日程
            if TeacherManager.Instance.model:IsHasTeahcerStudentRelationShip() == true then
                if TeacherManager.Instance.model.myTeacherInfo.status == TeacherEnum.Type.Teacher then
                    --师傅
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.teacher_window, {})
                else
                    --徒弟
                    local stuData = {rid = RoleManager.Instance.RoleData.id,platform = RoleManager.Instance.RoleData.platform,zone_id = RoleManager.Instance.RoleData.zone_id}
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.apprenticeship, {stuData, 1})
                end
            else
                -- NoticeManager.Instance:FloatTipsByString("您尚未加入师门，请先拜师或者收徒")
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                extra.base.buttons = {btn}
                extra.base.plot_talk = string.format(TI18N("您尚未加入师门，请先拜师或者收徒"))
                self:Open(self.currentNpcData, extra, true)
                return
            end
        end
    elseif action == actionType.action45 then
        -- 职业首席更新形象
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.buttons = {}
        extra.base.plot_talk = TI18N("你说更新就更新咯")
        self:Open(self.currentNpcData, extra, true)
    elseif action == actionType.action46 then
        -- 武道大会
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.buttons = {}
        extra.base.plot_talk = ""
        -- self:Open(self.currentNpcData, extra, true)
        HeroManager.Instance:HeroCheckIn()
        -- return
    elseif action == actionType.action47 then
        --公会精英战
        GuildFightEliteManager.Instance:send16204()
    elseif action == actionType.action48 then -- 极寒试炼求助
        if tonumber(args[1]) == 1 then
            if TrialManager.Instance.model.can_ask > 0 then
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                local btn1 = {button_id = actionType.action48, button_args = {2}, button_desc = TI18N("公会求助"), button_show = ""}
                local btn2 = {button_id = actionType.action48, button_args = {3}, button_desc = TI18N("好友求助"), button_show = ""}
                local btn3 = {button_id = actionType.action48, button_args = {4}, button_desc = TI18N("取消求助"), button_show = ""}
                local btn4 = {button_id = actionType.action48, button_args = {5}, button_desc = TI18N("返 回"), button_show = ""}
                extra.base.buttons = { btn1, btn2 }
                extra.base.plot_talk = TI18N("来再多人我也不怕，你们一起上吧！（帮助者将分享<color='#ffff00'>50%</color>银币收益）")

                local hasHelp = false
                for i=1, #SosManager.Instance.help_msg do
                    if SosManager.Instance.help_msg[i].help_id == 3 then
                        hasHelp = true
                        break
                    end
                end
                if hasHelp then
                    table.insert(extra.base.buttons, btn3)
                end
                table.insert(extra.base.buttons, btn4)
                self:Open(self.currentNpcData, extra, true)
            else
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                local btn4 = {button_id = actionType.action48, button_args = {5}, button_desc = TI18N("返 回"), button_show = ""}
                extra.base.buttons = { btn4 }
                extra.base.plot_talk = TI18N("别总依赖别人，堂堂正正面对挑战吧！")
                self:Open(self.currentNpcData, extra, true)
            end
            return
        elseif tonumber(args[1]) == 2 then
            -- TrialManager.Instance:Send13106()
            SosManager.Instance:Send16000(3)
        elseif tonumber(args[1]) == 3 then
            local callBack = function(data)
                                for k,v in pairs(data) do
                                    TrialManager.Instance:Send13105(v.id, v.platform, v.zone_id)
                                end
                            end
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, { callBack, 3 })
        elseif tonumber(args[1]) == 4 then
            SosManager.Instance:Send16005(3)
        elseif tonumber(args[1]) == 5 then
            TrialManager.Instance.model:open_dialog(self.currentNpcData)
            return
        end
    elseif action == actionType.action49 then
        if tonumber(args[1]) == 1 then
            local sure = function()
                SceneManager.Instance:Send10100(self.currentNpcData.battleid, self.currentNpcData.id)
            end
            if not TeamManager.Instance:HasTeam() or TeamManager.Instance:MemberCount() < 2 then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("建议<color='#ffff00'>组队前往</color>，多人组队<color='#ffff00'>奖励更丰厚</color>")
                data.sureLabel = TI18N("独立完成")
                data.cancelLabel = TI18N("创建队伍")
                data.sureCallback = sure
                data.blueSure = true
                data.greenCancel = true
                data.cancelCallback = function()
                    TeamManager.Instance:Send11701()
                    TeamManager.Instance.TypeOptions = {}
                    TeamManager.Instance.TypeOptions[10] = ShipMatchEumn[1]
                    TeamManager.Instance.LevelOption = 1
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
                end
                data.showClose = 1
                NoticeManager.Instance:ConfirmTips(data)
            elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Away then
                NoticeManager.Instance:FloatTipsByString(TI18N("只有队长才能完成此任务"))
            else
                sure()
            end
        elseif tonumber(args[1]) == 2 then
            local sure = function()
                DungeonManager.Instance:Require12100(30001)
            end
            if not TeamManager.Instance:HasTeam() or TeamManager.Instance:MemberCount() < 2 then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("建议<color='#ffff00'>组队前往</color>，多人组队<color='#ffff00'>奖励更丰厚</color>")
                data.sureLabel = TI18N("独立完成")
                data.cancelLabel = TI18N("创建队伍")
                data.sureCallback = sure
                data.blueSure = true
                data.greenCancel = true
                data.cancelCallback = function()
                    TeamManager.Instance:Send11701()
                    TeamManager.Instance.TypeOptions = {}
                    TeamManager.Instance.TypeOptions[10] = ShipMatchEumn[2]
                    TeamManager.Instance.LevelOption = 1
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
                end
                data.showClose = 1
                NoticeManager.Instance:ConfirmTips(data)
            elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Away then
                NoticeManager.Instance:FloatTipsByString(TI18N("只有队长才能完成此任务"))
            else
                sure()
            end

        end
    elseif action == actionType.action50 then
        -- 四季挑战
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        if tonumber(args[1]) == 1 then
            local btn1 = {button_id = actionType.action50, button_args = {4}, button_desc = TI18N("报 名"), button_show = ""}
            local teamData = DataTeam.data_match[69]
            local btn2 = {button_id = actionType.action22, button_args = {teamData.tab_id, teamData.id, teamData.lev_recruit[1].flag, 1}, button_desc = TI18N("便捷组队"), button_show = ""}
            local btn3 = {button_id = 999, button_args = {}, button_desc = TI18N("返 回"), button_show = ""}
            extra.base.buttons = {btn1, btn2, btn3}
            extra.base.plot_talk = TI18N("1.活动期间，<color='#00ff00'>三人及以上组队</color>可参与挑战四季挑战。\n2.四季挑战分为<color='#00ff00'>5</color>环，<color='#00ff00'>每天每环</color>只可获得<color='#00ff00'>1</color>次奖励，挑战次数<color='#00ff00'>不限</color>，奖励次数每日<color='#00ff00'>5点</color>刷新。3.退队、离线后需重头开始挑战")
            self:Open(self.currentNpcData, extra, true)
            return
        elseif tonumber(args[1]) == 2 then
            local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返 回"), button_show = ""}
            extra.base.buttons = {btn}
            self:Open(self.currentNpcData, extra, true)
            return
        elseif tonumber(args[1]) == 4 then
            if TeamManager.Instance:MemberCount() > 2 then
                ClassesChallengeManager.Instance:Send14807()    -- 报名四季挑战
            else
                local btn = {button_id = actionType.action50, button_args = {1}, button_desc = TI18N("返 回"), button_show = ""}
                extra.base.buttons = {btn}
                extra.base.plot_talk = TI18N("<color='#00ff00'>季节之王</color>与<color='#00ff00'>四季精灵</color>非常强大，需要<color='#00ff00'>三人及以上组队</color>方可参加。")
                self:Open(self.currentNpcData, extra, true)
                return
            end
        end
    elseif action == actionType.action51 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        if tonumber(args[1]) == 1 then
            local btn1 = {button_id = actionType.action51, button_args = {3}, button_desc = TI18N("准备好了，开始！"), button_show = ""}
            local btn2 = {button_id = actionType.action51, button_args = {4}, button_desc = TI18N("便捷组队"), button_show = ""}
            local btn3 = {button_id = 999, button_args = {}, button_desc = TI18N("没准备好"), button_show = ""}
            extra.base.buttons = {btn1, btn2, btn3}
            extra.base.plot_talk = TI18N("比赛正在如火如荼的举办中，<color='#ffff00'>3人或以上</color>组队即可参与。速度越快排名越高。\n每天举行3轮各3场比赛，总共9场。每场比赛<color='#ffff00'>持续20分钟</color>，越早达到终点，奖励越丰厚。\n活动时间到就<color='#ffff00'>立刻开始计时</color>咯。越早出发越有优势{face_1, 7}(在10分钟、15分钟之前抵达，均可<color='#ffff00'>额外获得</color>一份奖励哟）")
            self:Open(self.currentNpcData, extra, true)
            return
        elseif tonumber(args[1]) == 2 then      -- 踩点
            -- local btn = {button_id = 999, button_args = {}, button_desc = "踩 点", button_show = ""}
            -- extra.base.buttons = {btn}
            -- self:Open(self.currentNpcData, extra, true)
            DragonBoatManager.Instance:send19904()
        elseif tonumber(args[1]) == 3 then      -- 报名
            DragonBoatManager.Instance:send19902()
        elseif tonumber(args[1]) == 4 then      -- 便捷组队
            self:AutoMatch(6, 94, 1, 1)
        end
    elseif action == actionType.action52 then
        -- BaseUtils.dump(self.currentNpcData)
        CombatManager.Instance:Send10707(self.currentNpcData.battleid, self.currentNpcData.id)
    elseif action == actionType.action53 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        local mapid = SceneManager.Instance:CurrentMapId()
        local floor = nil
        if DataDungeon.data_dungeon_map[tostring(DungeonManager.Instance.currdungeonID).."_"..mapid] ~= nil then
            floor = DataDungeon.data_dungeon_map[DungeonManager.Instance.currdungeonID.."_"..mapid].floor
        end
        if tonumber(args[1]) == 1 then          -- Boss
            local btn1 = {button_id = 53, button_args = {3}, button_desc = TI18N("规则说明"), button_show = ""}
            local btn3 = {button_id = 6, button_args = {3}, button_desc = TI18N("开始战斗"), button_show = ""}
            extra.base.buttons = {btn1,btn3}
            if DungeonManager.Instance.killNum == nil then
                extra.base.plot_talk = TI18N("地狱火永生不灭，战斗将使我越燃越烈！")
            else
                local gra = DungeonManager.Instance.printIndex - 1
                if gra < 0 then gra = 0 end
                extra.base.plot_talk = string.format(TI18N("地狱火永生不灭，战斗将使我越燃越烈！\n\n本周被击败次数 <color='#00FF00'>%s</color>\n 当前进阶次数 <color='#00FF00'>%s</color>"), tostring(DungeonManager.Instance.killNum), tostring(gra))
            end
            self:Open(self.currentNpcData, extra, true)
            return
        elseif tonumber(args[1]) == 2 then          -- 雕像
            local touchNpcData = SceneManager.Instance.sceneElementsModel.touchNpcView.data
            extra.base.classes = touchNpcData.classes
            extra.base.sex = touchNpcData.sex
            extra.base.looks = BaseUtils.copytab(touchNpcData.looks)
            -- BaseUtils.dump(touchNpcData, "touchNpcData")
            DungeonManager.Instance.effigyNpcData = BaseUtils.copytab(self.currentNpcData)
            local npcData = DataUnit.data_unit[self.currentNpcData.baseid]
            local btn1 = BaseUtils.copytab(npcData.buttons[1])
            local btn2 = {button_id = 53, button_args = {7}, button_desc = TI18N("通关录像"), button_show = ""}
            btn1.button_args = {4}
            if RoleManager.Instance.RoleData.cross_type ~= 0 then
                extra.base.buttons = {btn1}
            else
                extra.base.buttons = {btn1, btn2}
            end
            if DungeonManager.Instance.rankText[floor] == nil or RoleManager.Instance.RoleData.cross_type ~= 0 then
                extra.base.plot_talk = npcData.plot_talk
            else
                extra.base.plot_talk = DungeonManager.Instance.rankText[floor]
            end
            if RoleManager.Instance.RoleData.cross_type == 0 then
                DungeonManager.Instance:Require12121(DungeonManager.Instance.currdungeonID, floor)
            end
            self:Open(self.currentNpcData, extra, true)
            return
        elseif tonumber(args[1]) == 3 then
            local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
            extra.base.buttons = {btn}
            extra.base.plot_talk = TI18N("进阶规则：深渊地狱火将随着玩家的挑战而<color='#ffff00'>不断变强</color>！\n每次成功挑战地狱火，被挑战次数+1，地狱火被挑战达一定次数则自动<color='#ffff00'>进阶</color>，获得更强力的属性！\n每周一<color='#ffff00'>5：00</color>地狱火恢复初始属性。请抓紧时机趁着地狱火尚未成长时进行击杀！")
            self:Open(self.currentNpcData, extra, true)
            return
        elseif tonumber(args[1]) == 4 then
            local touchNpcData = SceneManager.Instance.sceneElementsModel.touchNpcView.data
            extra.base.classes = touchNpcData.classes
            extra.base.sex = touchNpcData.sex
            extra.base.looks = BaseUtils.copytab(touchNpcData.looks)
            local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
            -- local btn = {button_id = 53, button_args = {6}, button_desc = "返回", button_show = ""}
            if DungeonManager.Instance.hasNoticeByFloor[floor] == nil then
                DungeonManager.Instance.hasNoticeByFloor[floor] = true
            end
            DungeonManager.Instance:Require10172(touchNpcData.battleid, touchNpcData.id, touchNpcData.baseid)
            -- BaseUtils.dump(touchNpcData, "touchNpcData")
            extra.base.buttons = {btn}
            extra.base.plot_talk = rule
            self:Open(self.currentNpcData, extra, true)
            return
        elseif tonumber(args[1]) == 5 then
            local btn1 = {button_id = 53, button_args = {4}, button_desc = TI18N("通关攻略"), button_show = ""}
            extra.base.buttons = {btn1}
            self:Open(self.currentNpcData, extra, true)
            return
        elseif tonumber(args[1]) == 6 then
            local touchNpcData = SceneManager.Instance.sceneElementsModel.touchNpcView.data
            extra.base.classes = touchNpcData.classes
            extra.base.sex = touchNpcData.sex
            extra.base.looks = BaseUtils.copytab(touchNpcData.looks)
            local btn = {button_id = 6, button_args = {3}, button_desc = TI18N("开始战斗"), button_show = ""}
            extra.base.buttons = {btn}
            extra.base.plot_talk = rule
            self:Open(self.currentNpcData, extra, true)
            -- self:Open(self.currentNpcData)
            return
        elseif tonumber(args[1]) == 7 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.dungeon_video_window, DungeonManager.Instance.dungeonData85)
        elseif tonumber(args[1]) == 8 then
            -- local btn = {button_id = 1, button_args = {10085}, button_desc = "", button_show = ""}
            -- extra.base.buttons = {btn}
            -- self:Open(self.currentNpcData, extra, true)
            DungeonManager.Instance:Require12122(10085)
            DungeonManager.Instance.request12122_id = 10085
        end
    elseif action == actionType.action54 then           -- 幻境争霸
        if tonumber(args[1]) == 1 then
            MasqueradeManager.Instance:send16501()
        elseif tonumber(args[1]) == 2 then
            MasqueradeManager.Instance:send16501()
        elseif tonumber(args[1]) == 3 then
            MasqueradeManager.Instance:send16502()
        end
    elseif action == actionType.action55 then           -- 天下第一武道会
        WorldChampionManager.Instance:Require16401()
    elseif action == actionType.action56 then
        if RoleManager.Instance.RoleData.fid == 0 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.createhomewindow)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("已创建家园"))
        end
    elseif action == actionType.action57 then
        HomeManager.Instance:EnterHome()
    elseif action == actionType.action58 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        local mapid = SceneManager.Instance:CurrentMapId()
        if tonumber(args[1]) == nil then
            local btn1 = {button_id = 58, button_args = {1}, button_desc = TI18N("清洁"), button_show = ""}
            local btn2 = {button_id = 58, button_args = {2}, button_desc = TI18N("许愿"), button_show = ""}
            local btn3 = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
            extra.base.buttons = {btn1,btn2}
            extra.base.plot_talk = TI18N("每日管家小暖可为主人服务<color='#00ff00'>1</color>次，服务内容为<color='#ffff00'>清洁</color>或者<color='#ffff00'>许愿</color>\n<color='#ffff00'>清洁:</color>打扫房屋，使家园清洁度+30~45\n<color='#ffff00'>许愿:</color>向星月宝树许愿，可使其获得1点许愿值")
            self:Open(self.currentNpcData, extra, true)
            return
        elseif tonumber(args[1]) == 1 or tonumber(args[1]) == 2 then
            if HomeManager.Instance.model.housekeeper_action_times > 0 then
                if tonumber(args[1]) == 1 then
                    HomeManager.Instance:Send11224()
                    local btn1 = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                    extra.base.buttons = {btn1}
                    extra.base.plot_talk = TI18N("报告主人，房屋打扫干净，清洁度提升啦{face_1,3}")
                    self:Open(self.currentNpcData, extra, true)
                    return
                elseif tonumber(args[1]) == 2 then
                    HomeManager.Instance:Send11230()
                    local btn1 = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                    extra.base.buttons = {btn1}
                    extra.base.plot_talk = TI18N("快快长大吧~成长值+1")
                    self:Open(self.currentNpcData, extra, true)
                    return
                end
            else
                local btn1 = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                extra.base.buttons = {btn1}
                extra.base.plot_talk = TI18N("管家今日的劳动次数已消耗完了哦，请明日再来")
                self:Open(self.currentNpcData, extra, true)
                return
            end
        end
    elseif action == actionType.action59 then
        -- 抓迷藏
        if tonumber(args[1]) == 2 then
            -- 规则说明
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            extra.base.buttons = {}
            table.insert(extra.base.buttons, {button_id = 0, button_args = {14022,4}, button_desc = TI18N("<color='#ffff00'>开始捉迷藏</color>"), button_show = ""})
            table.insert(extra.base.buttons, {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""})
            extra.base.plot_talk = rule
            self:Open(self.currentNpcData, extra, true, true)
            return
        else
            local isDone = false
            for i,v in ipairs(SummerManager.Instance.childrensGroupData.list) do
                if v.id == self.currentNpcData.baseid then
                    isDone = true
                    break
                end
            end
            if isDone == true then
                BaseUtils.ShowNpcDialog(self.currentNpcData.baseid,TI18N("你已经找到我咯，明天再来找我玩吧{face_1,9}"))
            else
                local isHadSeekChildTask = false
                local npcDataTemp = nil
                for k,v in pairs(DataCampHideSeek.data_child_task) do
                    if QuestManager.Instance.questTab[k] ~= nil then
                        isHadSeekChildTask = true
                        npcDataTemp = DataUnit.data_unit[DataCampHideSeek.data_child_task[k].unit_id]
                        break
                    end
                end
                if isHadSeekChildTask == false then
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = string.format(TI18N("<color='#ffff00'>捉迷藏</color>过程中不能飞行，领取后需在<color='#ffff00'>20分钟内</color>完成哟（可再次领取）"))
                    data.sureLabel = TI18N("立即领取")
                    data.cancelLabel = TI18N("取消")
                    data.sureCallback = function ()
                        QuestManager.Instance:Send10211(QuestEumn.TaskType.seekChild, self.currentNpcData.baseid)
                        self:Hide()
                    end
                    NoticeManager.Instance:ConfirmTips(data)
                else
                    if self.currentNpcData.baseid == npcDataTemp.id then
                        BaseUtils.ShowNpcDialog(self.currentNpcData.baseid,string.format(TI18N("你答应我的事情还没完成，不能耍赖皮喔{face_1,30}")))
                    else
                        BaseUtils.ShowNpcDialog(self.currentNpcData.baseid,string.format(TI18N("你先陪<color='#ffff00'>%s</color>玩耍吧，等会再来找我{face_1,2}"),npcDataTemp.name))
                    end
                end
            end
            return
        end
    elseif action == actionType.action60 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.visithomewindow, {})
    elseif action == actionType.action61 then -- 武道会随机观战
        if CombatManager.Instance.isFighting then
        else
            WorldChampionManager.Instance:Require16420()
            self:Hide()
        end
        return
    elseif action == actionType.action62 then -- 家园权限管理
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        local mapid = SceneManager.Instance:CurrentMapId()
        if tonumber(args[1]) == nil then
            extra.base.buttons = {
                {button_id = 62, button_args = {1}, button_desc = TI18N("所有人"), button_show = ""}
                -- ,{button_id = 62, button_args = {2}, button_desc = "好友", button_show = ""}
                -- ,{button_id = 62, button_args = {3}, button_desc = "公会成员", button_show = ""}
                ,{button_id = 62, button_args = {4}, button_desc = TI18N("好友与公会成员"), button_show = ""}
                -- ,{button_id = 62, button_args = {5}, button_desc = "仅自己", button_show = ""}
                ,{button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
            }
            local visit_lock = HomeManager.Instance.model.visit_lock
            local str = TI18N("所有人")
            if visit_lock == 2 then
                str = TI18N("好友")
            elseif visit_lock == 3 then
                str = TI18N("公会成员")
            elseif visit_lock == 4 then
                str = TI18N("好友与公会成员")
            elseif visit_lock == 5 then
                str = TI18N("仅自己")
            end
            extra.base.plot_talk = string.format(TI18N("当前设定：<color='#00ff00'>%s</color>，设置谁能访问我的家园：\n<color='#00ff00'>所有人：</color>所有人即可进入我的家园\n<color='#00ff00'>好友与公会成员：</color>只有我的好友以及我所在公会的成员方可进入我的家园")
                    , str)
            self:Open(self.currentNpcData, extra, true)
            return
        else
            HomeManager.Instance:Send11222(tonumber(args[1]))
            extra.base.buttons = { {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""} }
            local str = TI18N("所有人")
            if tonumber(args[1]) == 2 then
                str = TI18N("好友")
            elseif tonumber(args[1]) == 3 then
                str = TI18N("公会成员")
            elseif tonumber(args[1]) == 4 then
                str = TI18N("好友与公会成员")
            elseif tonumber(args[1]) == 5 then
                str = TI18N("仅自己")
            end
            extra.base.plot_talk = string.format(TI18N("已将当前家园访问权限设定为：<color='#00ff00'>%s</color>"), str)
            self:Open(self.currentNpcData, extra, true)
            return
        end
    elseif action == actionType.action63 then
        if tonumber(args[1]) == 1 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sing_main_window)
        elseif tonumber(args[1]) == 2 then
	       WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sing_signup_window)
        elseif tonumber(args[1]) == 3 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sing_time_window)
        end
    elseif action == actionType.action64 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {1, 1})
    elseif action == actionType.action65 then
        --五行修业任务
        local cfg_data = DataQuestPursue.data_cost[RoleManager.Instance.RoleData.lev]
        local exp_cfg_data = DataQuestPursue.data_reward[RoleManager.Instance.RoleData.lev]
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.sureLabel = TI18N("领取")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            QuestManager.Instance:Send10211(QuestEumn.TaskType.fineType)
        end
        data.content = string.format("%s<color='#2fc823'>%s</color>{assets_2, 90000}%s<color='#2fc823'>%s</color>%s", TI18N("是否确定消耗"), cfg_data.cost[1][2], TI18N("，领取游侠历练任务，总共可获得"), exp_cfg_data.ratio*10, TI18N("经验"))
        NoticeManager.Instance:ConfirmTips(data)
    elseif action == actionType.action66 then
        if RoleManager.Instance:CanConnectCenter() then
            if RoleManager.Instance.RoleData.cross_type ~= 1 then
                local accept = function ()
                    SceneManager.Instance.enterCenter()
                end
                local d = NoticeConfirmData.New()
                d.type = ConfirmData.Style.Normal
                d.content = TI18N("进入跨服可邀请其他服务器的玩家进行擂台切磋，是否进入跨服？")
                d.sureLabel = TI18N("进入跨服")
                d.cancelLabel = TI18N("取消")
                d.sureCallback = SceneManager.Instance.enterCenter
                d.cancelCallback = nil
                NoticeManager.Instance:ConfirmTips(d)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("您当前已经在跨服区！"))
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("当前服务器未连接跨服区，无法进入跨服区。"))
        end
    elseif action == actionType.action67 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marriage_certificate_window)
    elseif action == actionType.action68 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marryhonor_window)
    elseif action == actionType.action69 then
        UnlimitedChallengeManager.Instance:CheckReady()
    elseif action == actionType.action70 then
        if tonumber(args[1]) == 1 then
            EventMgr.Instance:Fire(event_name.pet_sure_useskillbook)
        elseif tonumber(args[1]) == 2 then

        elseif tonumber(args[1]) == 3 then
            PetManager.Instance.model.sure_useskillbook = true
        end
    elseif action == actionType.action71 then       -- 中秋答题
        if tonumber(args[1]) == 1 then
            MidAutumnFestivalManager.Instance:send14055(self.currentNpcData.battleid, self.currentNpcData.id)
        elseif tonumber(args[1]) == 2 then
        elseif tonumber(args[1]) == 3 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_letitgo)
        elseif tonumber(args[1]) == 4 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_window, {1, CampaignEumn.MidAutumnType.Exchange})
        elseif tonumber(args[1]) == 5 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_window)
        end
    elseif action == actionType.action72 then       --世界突破提交
        LevelBreakManager.Instance:send17402()
    elseif action == actionType.action73 then       --跳过心魔
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function() LevelBreakManager.Instance:send17403() end
        confirmData.content = TI18N("是否花费{assets_1, 90000, 10000000}请贤者净化心魔？")
        NoticeManager.Instance:ConfirmTips(confirmData)

    elseif action == actionType.action75 then       --五彩便河山
        notDoHide = true
        local touchNpcData = SceneManager.Instance.sceneElementsModel.touchNpcView.data
        if  RoleManager.Instance.RoleData.lev < 30 then
            NoticeManager.Instance:FloatTipsByString(TI18N("只有达到<color='#00ff00'>30级</color>才能参加活动哦，努力升级吧{face_1,3}"))
            return
        end

        local my_hour = tonumber(os.date("%H",BaseUtils.BASE_TIME))
        local my_minute =  tonumber(os.date("%M",BaseUtils.BASE_TIME))

        if my_hour < 9 or (my_hour == 9 and my_minute < 30)then
            NoticeManager.Instance:FloatTipsByString(TI18N("今天活动还没开始，请9：30再来"))
            self:Hide()
            return
        elseif my_hour > 22 and my_minute > 29 then
            NoticeManager.Instance:FloatTipsByString(TI18N("今天的活动已结束，请明天9：30再来"))
            self:Hide()
            return
        end
        if not TeamManager.Instance:HasTeam() then
            local teamData = DataTeam.data_match[118]
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[touchNpcData.baseid])
            extra.base.buttons = {}
            extra.base.plot_talk = TI18N("需要三人或三人以上组队才可参与挑战哦{face_1,22}")
            local buttons = {}
            buttons.button_id = DialogEumn.ActionType.action22
            buttons.button_args = {teamData.tab_id, teamData.id, teamData.lev_recruit[1].flag, 1}
            buttons.button_desc = TI18N("自动匹配")
            table.insert(extra.base.buttons, buttons)
            buttons = {}
            buttons.button_id = DialogEumn.ActionType.action999
            buttons.button_args = {}
            buttons.button_desc = TI18N("返回")
            table.insert(extra.base.buttons, buttons)
            MainUIManager.Instance:OpenDialog(touchNpcData, extra)
        elseif TeamManager.Instance:MemberCount() < 3 then
            local teamData = DataTeam.data_match[118]
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[touchNpcData.baseid])
            extra.base.buttons = {}
            extra.base.plot_talk = TI18N("需要三人或三人以上组队才可参与挑战哦{face_1,22}")
            local buttons = {}
            buttons.button_id = DialogEumn.ActionType.action22
            buttons.button_args = {teamData.tab_id, teamData.id, teamData.lev_recruit[1].flag, 1}
            buttons.button_desc = TI18N("招募队友")
            table.insert(extra.base.buttons, buttons)
            buttons = {}
            buttons.button_id = DialogEumn.ActionType.action999
            buttons.button_args = {}
            buttons.button_desc = TI18N("返回")
            table.insert(extra.base.buttons, buttons)
            MainUIManager.Instance:OpenDialog(touchNpcData, extra)
        else
            notDoHide = false
            NationalDayManager.Instance:Send14810()
        end
    elseif action == actionType.action76 then
        --没队伍或者有队伍，但人数低于3人时
        notDoHide = true
        local touchNpcData = SceneManager.Instance.sceneElementsModel.touchNpcView.data
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[touchNpcData.baseid])
        extra.base.buttons = {}
        local buttons = {}
        buttons.button_id = DialogEumn.ActionType.action75
        buttons.button_args = {}
        buttons.button_desc = TI18N("领取任务")
        table.insert(extra.base.buttons, buttons)
        buttons = {}
        buttons.button_id = DialogEumn.ActionType.action999
        buttons.button_args = {}
        buttons.button_desc = TI18N("返回")
        table.insert(extra.base.buttons, buttons)
        extra.base.plot_talk = TI18N("<color='#ffff00'>庆典使用的气球被一伙来历不明的人抢走了，组起来一起去夺回五彩气球吧，给他们点颜色瞧瞧</color>{face_1,30}\n1、<color='#00ff00'>30级</color>以上组成<color='#00ff00'>三人以上</color>队伍即可参与挑战\n3、每次任务<color='#00ff00'>共5环</color>，成功完成即可获得奖励\n3、活动时间为<color='#00ff00'>30号、2号、4号、6号</color>的<color='#00ff00'>9：00~23：30</color>，奖励丰厚，不要错过哦！")
        MainUIManager.Instance:OpenDialog(touchNpcData, extra)
    elseif action == actionType.action77 then
        notDoHide = true
        local touchNpcData = SceneManager.Instance.sceneElementsModel.touchNpcView.data
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[touchNpcData.baseid])
        extra.base.buttons = {}
        local buttons = {}
        buttons.button_id = DialogEumn.ActionType.action78
        buttons.button_args = {}
        buttons.button_desc = TI18N("领取任务")
        table.insert(extra.base.buttons, buttons)
        buttons = {}
        buttons.button_id = DialogEumn.ActionType.action999
        buttons.button_args = {}
        buttons.button_desc = TI18N("返回")
        table.insert(extra.base.buttons, buttons)
        extra.base.plot_talk = TI18N("祖国的生日到了，蛋糕师希望把蛋糕分享给朋友们，快来帮帮他吧 {face_1,7}\n1、将蛋糕分享给不同的NPC后，即可获得<color='#00ff00'>丰厚奖励</color>哦{face_1,29}\n2、护送蛋糕的路上可能遇到各种困难，甚至<color='#ffff00'>发生战斗</color>，加油\n3、活动时间为<color='#00ff00'>1号、3号、5号、7号</color>的<color='#00ff00'>9：00~23：30</color>，积极参与将快乐分享给更多的人{face_1,3}")
        MainUIManager.Instance:OpenDialog(touchNpcData, extra)
    elseif action == actionType.action78 then
        QuestManager.Instance:Send10211(QuestEumn.TaskType.defensecake, self.currentNpcData.baseid)
    elseif action == actionType.action79 then
        GuildManager.Instance:request11128()
    elseif action == actionType.action80 then
        --开炮
        CanYonManager.Instance.model:OnAttackFire()
    elseif action == actionType.action81 then
        -- 攻塔
        CanYonManager.Instance.model:OnAttackFire()
    elseif action == actionType.action82 then
        -- 守塔
        CanYonManager.Instance.model:OnDefend()
    elseif action == actionType.action83 then
        -- 转职后的宝石转换
        local last_classes_modify_time = RoleManager.Instance.RoleData.last_classes_modify_time
        local time = 604800 -- 7 * 24 * 3600
        if last_classes_modify_time == 0 then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
            extra.base.buttons = {btn}
            extra.base.plot_talk = rule
            extra.base.plot_talk = TI18N("你没有进行过<color='#00ff00'>转职</color>，无法进行宝石转换")
            self:Open(self.currentNpcData, extra, true)
            return
        elseif BaseUtils.BASE_TIME - last_classes_modify_time > time then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
            extra.base.buttons = {btn}
            extra.base.plot_talk = rule
            extra.base.plot_talk = TI18N("你距离上次转职<color='#00ff00'>超过7天</color>，无法进行宝石转换")
            self:Open(self.currentNpcData, extra, true)
            return
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.gemchangewindow)
        end
    elseif action == actionType.action84 then
        -- 星座召唤
        local times = ConstellationManager.Instance.currentData.today_summoned + 1
        times = math.min(times, DataConstellation.data_summon_length)
        local money = DataConstellation.data_summon[times].cost[1]
        if tonumber(args[1]) == 1 then
            if RoleManager.Instance.RoleData.lev < 70 then
                NoticeManager.Instance:FloatTipsByString(TI18N("召唤星座功能在70级后开放，加油升级吧{face_1,36}"))
            else
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                local btn = {button_id = actionType.action84, button_args = {3}, button_desc = string.format(TI18N("{assets_1,%s,%s}召唤"), money[1], money[2]), button_show = ""}
                extra.base.buttons = {btn}
                btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                table.insert(extra.base.buttons, btn)
                extra.base.plot_talk = TI18N("星座每逢半点将随机在<color='#00ff00'>2个场景</color>中刷新，如果花费<color='#00ff00'>一定的钻石</color>我也能为你召唤一只星数随机的<color='#00ff00'>专属星座</color>：\n1、不超过服务器可挑战等级\n2、不超过自身可挑战等级\n3、召唤出的星座最高为<color='#00ff00'>8星</color>\n4、召唤次数越多价格越高，召唤次数不限，但每天最多挑战2次召唤星座（失败不计）")
                self:Open(self.currentNpcData, extra, true)
                return
            end
        elseif tonumber(args[1]) == 2 then
            -- 查询
            ConstellationManager.Instance:Send15202(true)
        elseif tonumber(args[1]) == 3 then
            -- 召唤
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("本次召唤将消耗{assets_1,%s,%s}，星座召唤出来后将维持1小时，是否继续召唤？"), money[1], money[2])
            data.sureLabel = TI18N("召唤")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                ConstellationManager.Instance:Send15203()
            end
            data.cancelCallback = function()
                LuaTimer.Add(40, function() self:Open(self.currentNpcData) end)
            end
            NoticeManager.Instance:ConfirmTips(data)
        end
    elseif action == actionType.action85 then
        if RoleManager.Instance.RoleData.lev < 60 then
            NoticeManager.Instance:FloatTipsByString(TI18N("您的等级不足<color='#00ff00'>60级</color>，无法进行转职"))
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.classeschangewindow)
        end
    elseif action == actionType.action86 then
        if #args == 0 then
            SceneManager.Instance:Send10174()
        else
            if args[1] == 1 then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.taskdrama)
            end
        end
    elseif action == actionType.action87 then
        SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
    elseif action == actionType.action88 then
        if #args == 0 then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            extra.base.buttons = {
                {button_id = DialogEumn.ActionType.action88, button_args = { 1 }, button_desc = TI18N("<color='#ffff00'>进入活动</color>"), button_show = ""}
                , {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
            }
            extra.base.plot_talk = TI18N("1.每天<color='#ffff00'>16:00~18:00</color>为活动开启时间\n2.率先识破对方<color='#ffff00'>20次</color>的阵营获胜，每次活动时长为<color='#ffff00'>5分钟</color>\n3.获胜阵营<color='#ffff00'>积分最高</color>的选手将成为当场活动MVP并且获得<color='#ffff00'>额外宝箱奖励</color>{face_1,3}\n4.每人每天至多参加<color='#ffff00'>2场</color>活动")
            MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
            return
        else
            if args[1] == 1 then
                if HalloweenManager.Instance.model.less_times == HalloweenManager.Instance.pumpkingoblinTimes then
                    local extra = {}
                    extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                    extra.base.buttons = {
                        {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                    }
                    extra.base.plot_talk = TI18N("今天的活动次数用完了，明天再战吧！{face_1,7}")
                    MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
                    return
                else
                    -- local hour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
                    -- if hour >= 16 and hour <= 18 then
                    if HalloweenManager.Instance.model.status == 2 then
                        -- HalloweenManager.Instance:Send17801()
                        HalloweenManager.Instance.model:GoCheckIn()
                    else
                        local extra = {}
                        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                        extra.base.buttons = {
                            {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
                        }
                        extra.base.plot_talk = TI18N("活动开启时段为<color='#ffff00'>16:00-18:00</color>，请准时参加哦！{face_1,7}")
                        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
                        return
                    end
                end
            end
        end
    elseif action == actionType.action89 then
        local hour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
        if hour >= 9 and hour < 23 then
            if  RoleManager.Instance.RoleData.lev < 30 then
                NoticeManager.Instance:FloatTipsByString(TI18N("只有达到<color='#00ff00'>30级</color>才能参加活动哦，努力升级吧{face_1,3}"))
                return
            end
            --没队伍或者有队伍，但人数低于3人时
            notDoHide = true
            local touchNpcData = SceneManager.Instance.sceneElementsModel.touchNpcView.data
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[touchNpcData.baseid])
            extra.base.buttons = {}
            local buttons = {}

            local teamData = DataTeam.data_match[113]
            if not TeamManager.Instance:HasTeam() then
                extra.base.plot_talk = TI18N("1、<color='#ffff00'>09:00~23:00</color>期间<color='#ffff00'>每隔半小时</color>将刷出邪灵君主撒尔的手下\n2、组队将其击败即可获得不菲的奖励，还有机会得到神秘的<color='#ffff00'>南瓜之心</color>{face_1,6}")
                buttons.button_id = DialogEumn.ActionType.action22
                buttons.button_args = {teamData.tab_id, teamData.id, teamData.lev_recruit[1].flag, 1}
                buttons.button_desc = TI18N("自动匹配")
                table.insert(extra.base.buttons, buttons)
            elseif TeamManager.Instance:MemberCount() < 3 then
                extra.base.plot_talk = TI18N("需要<color='#00ff00'>三人</color>或<color='#00ff00'>三人以上</color>组队才可参与挑战哦{face_1,22}")
                buttons.button_id = DialogEumn.ActionType.action22
                buttons.button_args = {teamData.tab_id, teamData.id, teamData.lev_recruit[1].flag, 1}
                buttons.button_desc = TI18N("招募队友")
                table.insert(extra.base.buttons, buttons)
            else
                notDoHide = false
                HalloweenManager.Instance:Send14044()
                return
            end
            buttons = {}
            buttons.button_id = DialogEumn.ActionType.action999
            buttons.button_args = {}
            buttons.button_desc = TI18N("返回")
            table.insert(extra.base.buttons, buttons)
            MainUIManager.Instance:OpenDialog(touchNpcData, extra)
        else
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            extra.base.buttons = {
                {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
            }
            extra.base.plot_talk = TI18N("活动开启时段为<color='#ffff00'>09:00-23:00</color>，请准时参加哦！{face_1,7}")
            MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
            return
        end
    elseif action == actionType.action90 then
        if  RoleManager.Instance.RoleData.lev < 30 then
            NoticeManager.Instance:FloatTipsByString(TI18N("只有达到<color='#00ff00'>30级</color>才能参加活动哦，努力升级吧{face_1,3}"))
            return
        end
        --没队伍或者有队伍，但人数低于3人时
        notDoHide = true
        local touchNpcData = SceneManager.Instance.sceneElementsModel.touchNpcView.data
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[touchNpcData.baseid])
        extra.base.buttons = {}
        local buttons = {}
        local teamData = DataTeam.data_match[113]
        if not TeamManager.Instance:HasTeam() then
            extra.base.plot_talk = TI18N("就凭你一人之力就像挑战我？还是找些帮手吧！")
            buttons.button_id = DialogEumn.ActionType.action22
            buttons.button_args = {teamData.tab_id, teamData.id, teamData.lev_recruit[1].flag, 1}
            buttons.button_desc = TI18N("自动匹配")
            table.insert(extra.base.buttons, buttons)
        elseif TeamManager.Instance:MemberCount() < 3 then
            extra.base.plot_talk = TI18N("你们力量太弱，再多叫些人吧！")
            buttons.button_id = DialogEumn.ActionType.action22
            buttons.button_args = {teamData.tab_id, teamData.id, teamData.lev_recruit[1].flag, 1}
            buttons.button_desc = TI18N("招募队友")
            table.insert(extra.base.buttons, buttons)
        else
            SceneManager.Instance:Send10100(self.currentNpcData.battleid, self.currentNpcData.id)
            self:Hide()
            return
        end
        buttons = {}
        buttons.button_id = DialogEumn.ActionType.action999
        buttons.button_args = {}
        buttons.button_desc = TI18N("返回")
        table.insert(extra.base.buttons, buttons)
        self:Open(self.currentNpcData, extra, true)
    elseif action == actionType.action91 then       -- 结拜
        if RoleManager.Instance.RoleData.lev < 50 then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
            extra.base.buttons = {btn}
            extra.base.plot_talk = rule
            extra.base.plot_talk = TI18N("结拜等级达到<color='#00ff00'>50级</color>才开放")
            self:Open(self.currentNpcData, extra, true)
            return
        elseif SwornManager.Instance.status == SwornManager.Instance.statusEumn.Sworn then              -- 结拜完成
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.teacher_window, {3})
        elseif SwornManager.Instance.status == SwornManager.Instance.statusEumn.None then               -- 未结拜
            SwornManager.Instance:send17713()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_desc_window)
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_progress_window)
        end
    elseif action == actionType.action92 then -- 买回丢弃的宠物--云露
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("是否花费{assets_1, 90003,15000}找回放生的首充宠？\n（找回的宠物为龙猫君宠物蛋，<color='#ffff00'>不继承</color>之前的等级、装备、技能）")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() PetManager.Instance:Send10552() end
        NoticeManager.Instance:ConfirmTips(data)
    elseif action == actionType.action93 then   -- 感恩节
        if tonumber(args[1]) == 1 then
            ThanksgivingManager.Instance.model:OpenExchange()
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.thanksgiving)
        end
    elseif action == actionType.action94 then   -- 指定某个任务道具在某个任务id存在的时候弹出快捷使用  目前用于子女任务单人浇花
        local questid = tonumber(args[1])
        local item_id = tonumber(args[2])
        local questData = QuestManager.Instance:GetQuest(questid)
        local itemdata = BackpackManager.Instance:GetItemByBaseid(item_id)
        local basedata = DataItem.data_get[item_id]
        if questData ~= nil and itemdata ~= nil and next(itemdata) ~= nil then
            local autoUseData = AutoUseData.New()
            autoUseData.callback = function()
                if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
                    SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
                end
                QuestManager.Instance.model.lastType = 0
                local callback = function(effectview)
                    local key = BaseUtils.get_unique_npcid(self.currentNpcData.id, self.currentNpcData.battleid )
                    local go = SceneManager.Instance.sceneElementsModel.NpcView_List[key]
                    if go == nil or go.gameObject == nil then GameObject.DestroyImmediate(effectview.gameObject) return end
                    effectview.transform:SetParent(go.gameObject.transform)
                    effectview.transform.localPosition = Vector3(0, 0, -0.5)
                    LuaTimer.Add(3000, function()
                        -- BackpackManager.Instance:Use(itemdata[1].id, itemdata[1].quantity, item_id)
                        GameObject.DestroyImmediate(effectview.gameObject)
                    end)
                end
                LuaTimer.Add(2000, function()
                    BackpackManager.Instance:Use(itemdata[1].id, itemdata[1].quantity, item_id)
                end)
                BaseEffectView.New({effectId = 30180, time = nil, callback = callback})
            end
            autoUseData.title = TI18N("使用物品")
            autoUseData.label = TI18N("使用")
            autoUseData.itemData = basedata
            NoticeManager.Instance:AutoUse(autoUseData)
        elseif questData ~= nil and itemdata == nil or next(itemdata) == nil then
            print("缺少道具："..tostring(item_id))
        end
    elseif action == actionType.action95 then   -- 子女单人任务领取
        ChildrenManager.Instance.model:OpenGetWayPanel()
    elseif action == actionType.action96 then   -- 子女婴儿对话
        local F = {
            [1] = TI18N("粑粑的宠物好厉害，等我长大以后也要和粑粑并肩作战{face_1,56} "),
            [2] = TI18N("粑粑、粑粑，我的功课都在学习了，是不是很乖{face_1,57}"),
            [3] = TI18N("好想出去玩，但是宝宝知道，学好本领才能帮得上忙{face_1,25}"),
            [4] = TI18N("宝宝很乖的，肯定是花瓶先动的手{face_1,55}"),
            [5] = TI18N("金钟罩、羊皮卷、千年雪莲、闪电手、桃木剑…宝宝很厉害吧{face_1,56}"),
        }
        local M = {
            [1] = TI18N("最喜欢麻麻了，等我长大以后也要和麻麻并肩作战{face_1,56}"),
            [2] = TI18N("谁敢欺负麻麻，我就去揍谁，哼{face_1,41}"),
            [3] = TI18N("好想出去玩，但是宝宝知道，学好本领才能帮得上忙{face_1,25}"),
            [4] = TI18N("宝宝很乖的，肯定是花瓶先动的手{face_1,55}"),
            [5] = TI18N("金钟罩、羊皮卷、千年雪莲、闪电手、桃木剑…宝宝很厉害吧{face_1,56}"),
        }
        if HomeManager.Instance.model:CanEditHome() and HomeManager.Instance:IsAtHome() then
            local str = ""
            if RoleManager.Instance.RoleData.sex == 0 then
                local rand = math.random(1,#M)
                str = M[rand]
            else
                local rand = math.random(1,#F)
                str = F[rand]
            end
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            local btn = {button_id = 97, button_args = {1, 18604,1}, button_desc = TI18N("教育子女"), button_show = ""}
            extra.base.buttons = {btn, btn2}
            extra.base.plot_talk = str
            extra.base.name = self.currentNpcData.name
            MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
            return
        elseif HomeManager.Instance:IsAtHome() then
            local name = HomeManager.Instance.model.master_name
            local other = {
                [1] = string.format(TI18N("我是%s的孩子，长大后也会成为英雄哦{face_1,56}"), HomeManager.Instance.model.master_name),
                [2] = TI18N("粑粑麻麻不在家，你要陪我玩吗{face_1,38}"),
                [3] = TI18N("好多作业呀，你帮我做完，糖果分你一半哦{face_1,57}"),
                [4] = TI18N("花瓶…什么花瓶？宝宝不知道地毯下面有花瓶{face_1,28}"),
                [5] = TI18N("告诉你一个秘密哦，那边的许愿树会长出星星和月亮，不信你去点一下{face_1,36}")
            }
            local str = ""
            local rand = math.random(1,#other)
            str = other[rand]

            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            extra.base.buttons = {}
            extra.base.plot_talk = str
            extra.base.name = self.currentNpcData.name
            MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
            return
        end
    elseif action == actionType.action97 then   -- 子女孕育状态
        local Fetusnum = ChildrenManager.Instance:GetFetus()
        local Childhoodnum = ChildrenManager.Instance:GetChildhood()
        if tonumber(args[1]) == 1 then
            WindowManager.Instance:OpenWindowById(tonumber(args[2]), {})
        elseif tonumber(args[1]) == 2 then
            for k,v in pairs(self.currentNpcData.looks) do
                if v.looks_type == SceneConstData.looktype_child_id then
                    ChildrenManager.Instance:Require18624(v.looks_mode, v.looks_str, v.looks_val, ChildrenEumn.Status.Follow)
                    break
                end
            end
        elseif Fetusnum == nil and Childhoodnum == nil then
            if QuestManager.Instance.childPlantData.round == 0  then
                local day = os.date("%d", QuestManager.Instance.childPlantData.last_accepted)
                local currday = os.date("%d", BaseUtils.BASE_TIME)
                if day == currday then
                    if QuestManager.Instance.childPlantData.last_commited+7200 > BaseUtils.BASE_TIME then
                        local extra = {}
                        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                        extra.base.buttons = {btn, btn2}
                        local timestr = BaseUtils.formate_time_gap(QuestManager.Instance.childPlantData.last_commited+7200 - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.MIN)
                        extra.base.plot_talk = string.format(TI18N("今日已完成孕育任务，%s后可得知结果{face_1,9}"), timestr)
                        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true, true)
                    else
                        local extra = {}
                        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                        extra.base.buttons = {}
                        extra.base.plot_talk = TI18N("今天未能成功孕育子女，明天成功率更大哟{face_1,3}")
                        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
                    end
                else
                    local extra = {}
                    extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                    extra.base.buttons = {}
                    local btn = {button_id = 97, button_args = {1, 18600}, button_desc = TI18N("生儿育女"), button_show = ""}
                    extra.base.buttons = {btn}
                    extra.base.plot_talk = string.format("当前已孕育%s名子女，还可以孕育%s名<color='#00ff00'>（上限%s名）</color>", tostring(#ChildrenManager.Instance.childData), tostring(ChildrenManager.Instance.max_childNum-#ChildrenManager.Instance.childData), tostring(ChildrenManager.Instance.max_childNum))
                    MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
                end
            else
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                extra.base.buttons = {}
                local btn = {button_id = 97, button_args = {1, 18600}, button_desc = TI18N("生儿育女"), button_show = ""}
                extra.base.buttons = {btn}
                extra.base.plot_talk = string.format("当前已孕育%s名子女，还可以孕育%s名<color='#00ff00'>（上限%s名）</color>", tostring(#ChildrenManager.Instance.childData), tostring(ChildrenManager.Instance.max_childNum-#ChildrenManager.Instance.childData), tostring(ChildrenManager.Instance.max_childNum))
                MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
                -- local extra = {}
                -- extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                -- extra.base.buttons = {}
                -- extra.base.plot_talk = TI18N("正在进行孕育任务")
                -- MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
            end
            return
        elseif Fetusnum ~= nil then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            local btn = {button_id = 97, button_args = {1, 18600,1}, button_desc = TI18N("查看孕育进度"), button_show = ""}
            extra.base.buttons = {btn, btn2}
            extra.base.plot_talk = TI18N("胎儿正在健康成长，孕育值达到1000时就可以出生咯{face_1,38}")
            MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
            return
        elseif Childhoodnum ~= nil then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            local btn = {button_id = 97, button_args = {1, 18604,1}, button_desc = TI18N("前往幼年培养"), button_show = ""}
            extra.base.buttons = {btn, btn2}
            extra.base.plot_talk = TI18N("当前宝贝正处于幼年期，好好培养将来会成为少年英雄哦{face_1,25}")
            MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
            return
        end
    elseif action == actionType.action98 then   -- 子女长大家园对话
        local F = {
            [1] = TI18N("粑粑的宠物好厉害，等我长大以后也要和粑粑并肩作战{face_1,56} "),
            [2] = TI18N("粑粑、粑粑，我的功课都在学习了，是不是很乖{face_1,57}"),
            [3] = TI18N("好想出去玩，但是宝宝知道，学好本领才能帮得上忙{face_1,25}"),
            [4] = TI18N("宝宝很乖的，肯定是花瓶先动的手{face_1,55}"),
            [5] = TI18N("金钟罩、羊皮卷、千年雪莲、闪电手、桃木剑…宝宝很厉害吧{face_1,56}"),
        }
        local M = {
            [1] = TI18N("最喜欢麻麻了，等我长大以后也要和麻麻并肩作战{face_1,56}"),
            [2] = TI18N("谁敢欺负麻麻，我就去揍谁，哼{face_1,41}"),
            [3] = TI18N("好想出去玩，但是宝宝知道，学好本领才能帮得上忙{face_1,25}"),
            [4] = TI18N("宝宝很乖的，肯定是花瓶先动的手{face_1,55}"),
            [5] = TI18N("金钟罩、羊皮卷、千年雪莲、闪电手、桃木剑…宝宝很厉害吧{face_1,56}"),
        }
        if HomeManager.Instance.model:CanEditHome() and HomeManager.Instance:IsAtHome() then
            local str = ""
            if RoleManager.Instance.RoleData.sex == 0 then
                local rand = math.random(1,#M)
                str = M[rand]
            else
                local rand = math.random(1,#F)
                str = F[rand]
            end
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            local btn = {button_id = 97, button_args = {2, 18604,1}, button_desc = TI18N("携带子女"), button_show = ""}
            extra.base.buttons = {btn, btn2}
            extra.base.plot_talk = str
            extra.base.name = self.currentNpcData.name
            MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
            return
        elseif HomeManager.Instance:IsAtHome() then
            local name = HomeManager.Instance.model.master_name
            local other = {
                [1] = string.format(TI18N("我是%s的孩子，长大后也会成为英雄哦{face_1,56}"), HomeManager.Instance.model.master_name),
                [2] = TI18N("粑粑麻麻不在家，你要陪我玩吗{face_1,38}"),
                [3] = TI18N("好多作业呀，你帮我做完，糖果分你一半哦{face_1,57}"),
                [4] = TI18N("花瓶…什么花瓶？宝宝不知道地毯下面有花瓶{face_1,28}"),
                [5] = TI18N("告诉你一个秘密哦，那边的许愿树会长出星星和月亮，不信你去点一下{face_1,36}")
            }
            local str = ""
            local rand = math.random(1,#other)
            str = other[rand]

            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            extra.base.buttons = {}
            extra.base.plot_talk = str
            extra.base.name = self.currentNpcData.name
            MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
            return
        end
    elseif action == actionType.action99 then
        if args[1] == nil then -- 无参数
            notDoHide = true
            local touchNpcData = SceneManager.Instance.sceneElementsModel.touchNpcView.data
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[touchNpcData.baseid])
            local button1 = {button_id = actionType.action99, button_args = {1}, button_desc = string.format(TI18N("许愿(%s/1)"), 1 - ValentineManager.Instance.model.getWishItemCount), button_show = ""}
            local button2 = {button_id = actionType.action99, button_args = {2}, button_desc =string.format(TI18N("还愿(%s/2)"), 2 - ValentineManager.Instance.model.getVotiveItemCount), button_show = ""}
            local button3 = {button_id = actionType.action999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
            extra.base.buttons = {button1, button2, button3}
            self:Open(self.currentNpcData, extra, true)
        elseif tonumber(args[1]) == 1 then
            ValentineManager.Instance:send17832()
        elseif tonumber(args[1]) == 2 then
            ValentineManager.Instance:send17837()
        end
    elseif action == actionType.action100 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.buttons = {
            {button_id = 101, button_args = {1}, button_desc = TI18N("开始挑战"), button_show = ""}
        }

        -- print(GuildDungeonManager.Instance.model.bossData.challenge)
        if self.currentNpcData.status == 2 or (GuildDungeonManager.Instance.model.bossData ~= nil and GuildDungeonManager.Instance.model.bossData.challenge == 3) then
            extra.base.buttons[2] = {button_id = 101, button_args = {2}, button_desc = TI18N("观看战斗"), button_show = ""}
        end
        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
        return
    elseif action == actionType.action101 then
        if #args > 0 then
            local bossData = GuildDungeonManager.Instance.model.bossData
            if args[1] == 1 then
                if GuildDungeonManager.Instance.model:CheckTime() then
                    if GuildDungeonManager.Instance.model:CheckTeamMate(bossData) then
                        GuildDungeonManager.Instance:Send19501(bossData.chapter_id, bossData.strongpoint_id, bossData.unique)
                    end
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("勇士请于周一至周六11:00~23:00时间段进行挑战"))
                end
            elseif args[1] == 2 then
                GuildDungeonManager.Instance:Send19504(bossData.chapter_id, bossData.strongpoint_id, bossData.unique)
            end
        end
    elseif action == actionType.action102 then
        -- EquipStrengthManager.Instance:HeroFindBack()
        if #args == 0 then
            local result = EquipStrengthManager.Instance:GetCanFindHero()
            if result then
                EquipStrengthManager.Instance.findbackid = result.id

                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                extra.base.buttons = {
                    {button_id = actionType.action102, button_args = {1}, button_desc = TI18N("确 定"), button_show = ""}
                }
                extra.base.plot_talk = string.format(TI18N("每次找回英雄宝石需要消耗一张<color='#ffff00'>英雄卷轴</color>，本次可找回<color='#ffff00'>%s颗</color>英雄宝石，是否继续？\n<color='#00ff00'>根据装备条件，可找回%s次英雄宝石</color>"), result.num, result.total)
                extra.base.name = self.currentNpcData.name
                MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
                return
            else
                local extra = {}
                extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
                extra.base.buttons = {}
                extra.base.plot_talk = TI18N("身上已经没有可找回的英雄宝石了{face_1,24}")
                extra.base.name = self.currentNpcData.name
                MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
                return
            end
        else
            EquipStrengthManager.Instance:SureFindHero()
        end
    elseif action == actionType.action103 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.buttons = {
            {button_id = 55,button_args = {1},button_desc = TI18N("<color='#ffff00'>参加比武</color>"),button_show = "[]"}
            ,{button_id = 0,button_args = {16400,1},button_desc = TI18N("我的战绩"),button_show = "[]"}
            ,{button_id = 4,button_args = {},button_desc = TI18N("活动介绍"),button_show = TI18N("<color='#ffff00'>星辰英豪群雄四起，武道大会一战封神！</color>\n1、<color='#ffff00'>每天中午12：30-13：30晚上22：30-23：30</color>开启\n2、<color='#ffff00'>70</color>级以上玩家可参与，可单人应战或邀请一名<color='#ffff00'>好友双排</color>\n3、<color='#ffff00'>2V2模式</color>每周二开启，当天有<color='#ffff00'>5</color>次挑战机会，次数隔天不累计\n4、<color='#ffff00'>5V5模式</color>除周二外每天开启，当天有<color='#ffff00'>3</color>次挑战机会，最多累计<color='#ffff00'>6</color>次\n5、两种模式头衔和积分共享，每场比赛获胜将获得武道积分，累计满<color='#ffff00'>100点</color>武道积分将进入<color='#ffff00'>晋级战</color>，晋级战获胜可以晋升至下一武道头衔\n6、首次晋升头衔将获得<color='#ffff00'>晋升宝箱</color>，开启可以获得<color='#ffff00'>丰厚的奖励</color>{face_1,29}")}
            ,{button_id = 0,button_args = {11300,2,5},button_desc = TI18N("积分兑换"),button_show = "[]"}
            ,{button_id = 61,button_args = {1},button_desc = TI18N("<color='#00ff00'>随机观战</color>"),button_show = "[]"}
        }
        local aendaData = DataAgenda.data_list[2049].args
        local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
        if currentWeek == 0 then currentWeek = 7 end
        if table.containValue(aendaData, currentWeek) then
            extra.base.plot_talk = TI18N("<color='#ffff00'>星辰英豪群雄四起，武道大会一战封神！</color>\n今天将进行<color='#ffff00'>2V2</color>对决（每周二开启2V2，其他时间为5V5模式）\n温馨提示：可单人应战或邀请一名<color='#ffff00'>好友双排</color>匹配\n1、<color='#00ff00'>每天中午12：30-13：30</color>准时开战\n2、2V2模式当天可挑战<color='#ffff00'>5</color>次、隔天不累计，与5V5模式次数相独立\n3、<color='#00ff00'>晚上22:30-23:30</color>有剩余次数的英雄们可继续挑战{face_1,25}")
        end
        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
        return
    elseif action == actionType.action104 then -- 斗兽棋
        if AnimalChessManager.Instance.status == AnimalChessEumn.Status.Close then
            StarParkManager.Instance.model:OpenStarParkMainUI({3})
        else
            AnimalChessManager.Instance:GoMatch()
        end
    elseif action == actionType.action105 then
        IngotCrashManager.Instance:OnExit()
    elseif action == actionType.action106 then
        local spirit_treasure_unit = {
            [32004] = 1,
            [32000] = 2,
            [32001] = 3,
            [32002] = 4,
            [32003] = 5,
        }
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.buttons = {
            {button_id = 6,button_args = {1},button_desc = "开始挑战",button_show = "[]"}
            , {button_id = 107,button_args = {},button_desc = "便捷组队",button_show = "[]"}
            , {button_id = 0,button_args = {WindowConfig.WinID.starchallengewindow, 1, spirit_treasure_unit[self.currentNpcData.baseid]-2, 1},button_desc = "观看录像",button_show = "[]"}
        }

        local kill_times = 0
        local starString = ""
        local spiritTreasureUnit = StarChallengeManager.Instance.model:GetSpiritTreasureUnit(self.currentNpcData.baseid)
        if spiritTreasureUnit ~= nil then
            kill_times = spiritTreasureUnit.kill_times
            local dayStar = spiritTreasureUnit.now_star
            for i=1, dayStar do
                starString = string.format("%s★", starString)
            end
        end
        extra.base.plot_talk = string.format(TI18N("%s\n战斗难度： <color='#ffff00'>%s</color>    被战胜次数: %s"), extra.base.plot_talk, starString, kill_times)
        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
        return
    elseif action == actionType.action107 then
        self:ButtonAction(actionType.action22, {7,StarChallengeManager.Instance.model:GetTeamType(),1}, rule)
        return
    elseif action == actionType.action108 then
        if #args == 0 then
            Log.Error(string.format("unit表按钮数据配置错误，unitid = %s", self.currentNpcData.baseid))
        elseif tonumber(args[1]) == 1 then
            ConstellationManager.Instance:GetConstellationData(BaseUtils.copytab(self.currentNpcData), 1)
        elseif tonumber(args[1]) == 2 then
            ConstellationManager.Instance:GetConstellationData(BaseUtils.copytab(self.currentNpcData), 2)
        end
    elseif action == actionType.action109 then

        QiXiLoveManager.Instance.onUpdateActive:AddListener(self.setDataFun)
        QiXiLoveManager.Instance:send17880()

    elseif action == actionType.action110 then
        self:CheckIsAmbiguous()
        return
    elseif action == actionType.action111 then          -- 玲珑宝阁
        if #args > 0 then
            if tonumber(args[1]) == 1 then
                -- 进入
            elseif tonumber(args[1]) == 2 then
                -- 退出
                ExquisiteShelfManager.Instance:Exit()
            elseif tonumber(args[1]) == 3 then -- 内阁，进入战斗
                ExquisiteShelfManager.Instance:send20301(tonumber(args[2]))
            elseif tonumber(args[1]) == 4 then -- 内阁，进入战斗
                ExquisiteShelfManager.Instance:send20301(ExquisiteShelfManager.Instance.model.shelfData.wave or 1)
            elseif tonumber(args[1]) == 5 then
                ExquisiteShelfManager.Instance:OnTeam()
            end
        else
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])

            if ExquisiteShelfManager.Instance:GetCurrentLevel() == 1 then
                extra.base.buttons = {
                    {button_id = actionType.action111, button_args = {4},button_desc = "开始挑战",button_show = "[]"}
                    , {button_id = actionType.action998, button_args = {},button_desc = "返回",button_show = "[]"}
                }
            else
                extra.base.buttons = {}
                for i=ExquisiteShelfManager.Instance.firstWave+1,ExquisiteShelfManager.Instance.finalWave do
                    local j = i
                    if i < ExquisiteShelfManager.Instance.model.shelfData.wave or ExquisiteShelfManager.Instance.model.shelfData.status == ExquisiteShelfEumn.MosterStatus.Finish then
                        table.insert(extra.base.buttons, {button_id = actionType.action111, button_args = {3,j},button_desc = string.format(TI18N("挑战%s星难度（已完成）"), j - ExquisiteShelfManager.Instance.firstWave),button_show = "[]"})
                    else
                        if i == ExquisiteShelfManager.Instance.finalWave then
                            table.insert(extra.base.buttons, {button_id = actionType.action111, button_args = {3,j},button_desc = string.format(TI18N("挑战%s星难度（困难）"), j - ExquisiteShelfManager.Instance.firstWave),button_show = "[]"})
                        else
                            table.insert(extra.base.buttons, {button_id = actionType.action111, button_args = {3,j},button_desc = string.format(TI18N("挑战%s星难度"), j - ExquisiteShelfManager.Instance.firstWave),button_show = "[]"})
                        end
                    end
                end
                table.insert(extra.base.buttons, {button_id = actionType.action998, button_args = {},button_desc = "返回",button_show = "[]"})
            end
            MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
            return
        end
    elseif action == actionType.action112 then          -- 历练任务
        if #args == 0 then
            Log.Error(string.format("unit表按钮数据配置错误，unitid = %s", self.currentNpcData.baseid))
        elseif tonumber(args[1]) == 1 then
            AutoQuestManager.Instance.model:OpenAutoModeSelectWindow()
        end
    elseif action == actionType.action113 then  -- 单身狗任务
        local baseTime = BaseUtils.BASE_TIME
        local timeData = DataCampaign.data_list[780].cli_start_time[1]
        local startTime = tonumber(os.time{year = timeData[1], month = timeData[2], day = timeData[3], hour = timeData[4], min = timeData[5], sec = timeData[6]})
        local timeData = DataCampaign.data_list[780].cli_end_time[1]
        local endTime = tonumber(os.time{year = timeData[1], month = timeData[2], day = timeData[3], hour = timeData[4], min = timeData[5], sec = timeData[6]})
        if baseTime < startTime then
            NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，敬请期待"))
        elseif baseTime > endTime then
            NoticeManager.Instance:FloatTipsByString(TI18N("活动已结束"))
        elseif RoleManager.Instance.RoleData.lev < 30 then
            NoticeManager.Instance:FloatTipsByString(TI18N("等级大于30级的玩家方可领取活动任务哟~{face_1,107}"))
        elseif DoubleElevenManager.Instance.questGet == true then
            NoticeManager.Instance:FloatTipsByString("今天您已经领取任务了哟")
        else
            --local baseTime = BaseUtils.BASE_TIME
            -- local timeData = DataCampaign.data_list[780].cli_end_time[1]
            -- local endTime = tonumber(os.time{year = timeData[1], month = timeData[2], day = timeData[3], hour = timeData[4], min = timeData[5], sec = timeData[6]})
            local timestamp = endTime - baseTime
            local curDay = math.modf(timestamp / 3600 / 24)
            local startQuest = 83670 - 10 * curDay
            QuestManager.Instance:Send10211(29,startQuest)
            DoubleElevenManager.Instance.questGet = true
            NoticeManager.Instance:FloatTipsByString(TI18N("您已经成功领取任务，快帮他走出单身生活吧！"))
        end
    elseif action == actionType.action114 then  -- 魔龙
        GuildDragonManager.Instance:BeginFight()
    elseif action ==actionType.action115 then --神蛋任务
        local hour = os.date("%H",BaseUtils.BASE_TIME)
        local petEggConfig = DataCampPetEgg.data_get_extra_cfg[1]
        local timeFlag = false
        if petEggConfig ~= nil then
            timeFlag = tonumber(hour) >= petEggConfig.time[1][1] and tonumber(hour) < petEggConfig.time[1][4]
        end

        local achievebool = MagicEggManager.Instance.model.achievebool

        if RoleManager.Instance.RoleData.lev <= petEggConfig.incubate_lv then
            NoticeManager.Instance:FloatTipsByString(TI18N("等级大于30级的玩家方可领取哟{face_1,107}"))
        elseif achievebool == 1 then
            PetManager.Instance:Send10569()
        elseif achievebool == 2 then
            if PetManager.Instance:HasEvolveEgg() then
                if timeFlag then
                    PetManager.Instance.model:ShowUpdateEffect3()
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("每日<color='#ffff00'>21：00-23：00</color>方可进行开启哟~"))
                end
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("需进化为瑞兔送福后，方可进行开启哟{face_1,9}"))
            end
        elseif achievebool == 3 then
            NoticeManager.Instance:FloatTipsByString(TI18N("今天已成功开启鸿福兔纸，请明天再来吧{face_1,9}"))
        end
    elseif action == actionType.action116 then
        if #args == 0 or tonumber(args[1]) == 1 then -- 进入场景
            CrossArenaManager.Instance:EnterScene()
        elseif tonumber(args[1]) == 2 then      -- 退出
            CrossArenaManager.Instance:ExitScene()
        elseif tonumber(args[1]) == 3 then      -- 打开面版
            if RoleManager.Instance.RoleData.event == RoleEumn.Event.ProvocationRoom then
                CrossArenaManager.Instance.model:OpenCrossArenaRoomWindow()
            else
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.crossarenawindow)
            end
        end
    elseif action == actionType.action117 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.looks = self.currentNpcData.looks
        extra.base.buttons = {
            {button_id = 6,button_args = {1},button_desc = "开始挑战",button_show = "[]"}
            ,{button_id = 52,button_args = {},button_desc = "观看战斗",button_show = "[]"}
            ,{button_id = 22,button_args = {6,66,1,1},button_desc = "便捷组队",button_show = "[]"}
        }
        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
        return
    elseif action == actionType.action118 then
        local oracle_treasure_unit = {
            [32031] = 1,
            [32027] = 2,
            [32028] = 3,
            [32029] = 4,
            [32030] = 5,
        }
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.buttons = {
            {button_id = 6,button_args = {1},button_desc = "开始挑战",button_show = "[]"}
            , {button_id = 119,button_args = {},button_desc = "便捷组队",button_show = "[]"}
            , {button_id = 0,button_args = {WindowConfig.WinID.ApocalypseLordwindow, 1, oracle_treasure_unit[self.currentNpcData.baseid]-2, 1},button_desc = "观看录像",button_show = "[]"}
        }

        local kill_times = 0
        local starString = ""
        local spiritTreasureUnit = ApocalypseLordManager.Instance.model:GetSpiritTreasureUnit(self.currentNpcData.baseid)
        if spiritTreasureUnit ~= nil then
            kill_times = spiritTreasureUnit.kill_times
            local dayStar = spiritTreasureUnit.now_star
            for i=1, dayStar do
                starString = string.format("%s★", starString)
            end
        end
        extra.base.plot_talk = string.format(TI18N("%s\n战斗难度： <color='#ffff00'>%s</color>    被战胜次数: %s"), extra.base.plot_talk, starString, kill_times)
        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
        return
    elseif action == actionType.action119 then
        self:ButtonAction(actionType.action22, {7,ApocalypseLordManager.Instance.model:GetTeamType(),1}, rule)
        return
    elseif action == actionType.action120 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.buttons = {
            {button_id = 0,button_args = {14003,1110},button_desc = "参与活动",button_show = "[]"}
            , {button_id = 121,button_args = {},button_desc = "随便看看",button_show = "[]"}
        }
        local tempList = AnniversaryTyManager.Instance.model.LanternList
        math.randomseed(tostring(os.time()):reverse():sub(1,6))
        if next(tempList) == nil then
            local i = math.random(1,3)
            extra.base.plot_talk = AnniversaryTyManager.Instance.model.initLanternList[i]
        else
            local randomNum = math.random(1, #tempList)
            extra.base.plot_talk = TI18N(tempList[randomNum].content)
        end
        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
        return
    elseif action == actionType.action121 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.buttons = {
            {button_id = 0,button_args = {14003,1061},button_desc = "参与活动",button_show = "[]"}
            , {button_id = 121,button_args = {},button_desc = "随便看看",button_show = "[]"}
        }
        local tempList = AnniversaryTyManager.Instance.model.LanternList
        math.randomseed(tostring(os.time()):reverse():sub(1,6))
        if next(tempList) == nil then
            local i = math.random(1,3)
            extra.base.plot_talk = AnniversaryTyManager.Instance.model.initLanternList[i]
        else
            local randomNum = math.random(1,#tempList)
            extra.base.plot_talk = TI18N(tempList[randomNum].content)
        end
        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
        return
    elseif action == actionType.action122 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.buttons[1] = {button_id = 85,button_args = {},button_desc = "转换职业",button_show = "[]"}

        extra.base.buttons[2] = {button_id = 83,button_args = {},button_desc = "宝石转换",button_show = "[]"}

        extra.base.buttons[3] = {button_id = 129,button_args = {},button_desc = "宝物转换",button_show = "[]"}

        extra.base.buttons[4] = {button_id = 4,button_args = {},button_desc = "转职说明",button_show = "1.转职可选择消耗金币或钻石，<color='#ffff00'>转职消耗</color>与职业<color='#ffff00'>装备魂价格比例、转职次数</color>相关\n2.为确保转职体验，需拥有<color='#ffff00'>双倍金币</color>才可选择金币转职\n3.时装将<color='#ffff00'>保持原状态</color>，染色转为对应新职业染色\n4.转职后人物属性加点<color='#ffff00'>全部重置</color>，请重新分配加点\n5.装备强化等级将<color='#ffff00'>保留</color>，附带的职业天赋技能特效将随机为新职业天赋技能特效\n6.转职后<color='#ffff00'>装备精炼</color>属性类型将对应转换，属性值保持不变\n7.转职后<color='#00ff00'>7天内</color>，普通宝石和英雄宝石可进行一次<color='#ffff00'>免费转换</color>\n8.宝石将根据<color='#ffff00'>市场价格</color>进行转换，低价宝石转高价宝石，会进行<color='#ffff00'>降级</color>。多出的宝石<color='#ffff00'>邮件返还</color>。高价宝石转为低价宝石<color='#ffff00'>保留</color>原宝石等级，不会进行升级转换\n9.转职后的坐骑拥有的职业技能将转为对应新职业技能"}
        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
        return
    elseif action == actionType.action123 then
        local lastModifyClassTime = RoleManager.Instance.RoleData.last_classes_modify_time
        local StartTime = os.time({year =2018, month = 5, day =1, hour =0, min =0, sec = 0})
        local EndTime = os.time({year =2018, month = 5, day =25, hour =23, min =59, sec = 59})
        if lastModifyClassTime ~= 0 and lastModifyClassTime >= StartTime and lastModifyClassTime < EndTime then
            --规定时间转职过
            if ClassesChangeManager.Instance.model.IsChangedStone == false then
                --未转换过晶石 弹出
                local lastclass = ClassesChangeManager.Instance.model.lastClass
                local currclass = RoleManager.Instance.RoleData.classes
                --print(lastclass.."&&&&&"..currclass)
                local ItemData = DataItem.data_get
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = string.format(TI18N("1、您在<color='#ffff00'>5月1日至5月25日</color>转职，<color='#ffff00'>符合转换条件</color>\n2、上一职业为%s，当前职业为%s，背包和仓库的<color='#ffff00'>%s</color>将自动转换为<color='#ffff00'>%s</color>\n3、仅在上述时间内转职需手动转换晶石<color='#00ff00'>以后转职将自动转换</color>"),KvData.classes_name[lastclass], KvData.classes_name[currclass],ItemData[ClassesChangeManager.Instance.model.Stonetype[lastclass]].name, ItemData[ClassesChangeManager.Instance.model.Stonetype[currclass]].name)
                data.sureLabel = TI18N("确认转换")
                data.cancelLabel = TI18N("再考虑下")
                data.sureCallback = function()
                    --发协议
                    ClassesChangeManager.Instance:Send10039()
                end
                NoticeManager.Instance:ConfirmTips(data)
                self:Hide()
            else
                NoticeManager.Instance:FloatTipsByString("<color='#ffff00'>晶石已转换过一次</color>，无需再次转换{face_1,2}")
                self:Hide()
            end
        else
            NoticeManager.Instance:FloatTipsByString("<color='#ffff00'>5月1日至5月25日</color>期间转职才需要手动转换哟{face_1,3}")
            self:Hide()
        end
        return
    elseif action == actionType.action124 then -- 龙凤棋
        if DragonPhoenixChessManager.Instance.status == DragonChessEumn.Status.Close then
            -- NoticeManager.Instance:FloatTipsByString("当前不在<color='#ffff00'>龙凤棋</color>的活动时间段哦~{face_1,3}")
            StarParkManager.Instance.model:OpenStarParkMainUI({2})
        else
            DragonPhoenixChessManager.Instance:GoMatch()
        end
    elseif action == actionType.action125 then
        --GodsWarWorShipManager.Instance:Send17961()
    elseif action == actionType.action126 then
        if tonumber(args[1]) == 1 then
            -- if not GodsWarWorShipManager.Instance.model.isChampion then
            --     BaseUtils.dump(GodsWarWorShipManager.Instance.godsWarWorShipData,"tttt")
            --     --[GodsWarWorShipManager.Instance.nowChampionTeams]
            --     BaseUtils.dump(RoleManager.Instance.RoleData,"roleData")
            --     NoticeManager.Instance:FloatTipsByString(TI18N("只有王者组冠军的成员才能挑战哦"))
            --     return
            -- end
            SceneManager.Instance:Send10100(self.currentNpcData.battleid, self.currentNpcData.id)
        elseif tonumber(args[1]) == 2 then
            local combatId = GodsWarWorShipManager.Instance.BossCombatId
            GodsWarManager.Instance:Send17959(combatId)
        end
    elseif action == actionType.action127 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        extra.base.looks = self.currentNpcData.looks
        extra.base.buttons = {
            {button_id = 6,button_args = {1},button_desc = "开始挑战",button_show = "[]"}
            ,{button_id = 52,button_args = {},button_desc = "观看战斗",button_show = "[]"}
            ,{button_id = 22,button_args = {6,67,1,1},button_desc = "便捷组队",button_show = "[]"}
        }
        MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
        return    
    elseif action == actionType.action128 then
        local model = HalloweenManager.Instance.model
        if model.less_times < HalloweenManager.Instance.pumpkingoblinTimes then
            model:GoCheckIn()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("今日参与次数不足"))
        end
    elseif action == actionType.action129 then
        -- 转职后的宝物转换
        -- local last_classes_modify_time = RoleManager.Instance.RoleData.last_classes_modify_time

        -- local StartTime = os.time({year =2018, month = 10, day =1, hour =0, min =0, sec = 0})
        -- local EndTime = os.time({year =2018, month = 11, day =2, hour = 0, min = 0, sec = 0})
        -- --604800
        -- local time = 604800 -- 7 * 24 * 3600
        -- if last_classes_modify_time == 0 then
        --     --没转职过
        --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.gemchangewindow)
        -- elseif (BaseUtils.BASE_TIME - last_classes_modify_time < time) or (last_classes_modify_time >= StartTime and last_classes_modify_time < EndTime and BaseUtils.BASE_TIME - EndTime < time) then
        --     --转换的情况
        --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.gemchangewindow)
        -- else
        --     --时间上不符合
        --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.gemchangewindow)
        -- end
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.talismanchangewindow)
    elseif action == actionType.action996 then
        --(args[1]: 活动ID args[2]: ActionType args[...]:后续参数)
        -- 996:[1353,0,19922]:查看大奖:[]
        if CampaignManager.CheckCampaignStatus(args[1]) == 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启，敬请期待哟{face_1,3}"))
            self:Hide()
        elseif CampaignManager.CheckCampaignStatus(args[1]) == 3 then
            NoticeManager.Instance:FloatTipsByString(TI18N("活动已结束，感谢你的支持哟{face_1,3}"))
            self:Hide()
        elseif CampaignManager.CheckCampaignStatus(args[1]) == 1 then
            local actionType = args[2]
            local t_args = {}
            for i= 3, #args do
                table.insert(t_args, args[i])
            end
            t_args.campId = args[1]
            self:ButtonAction(actionType, t_args, rule)
        end
        return
    elseif action == actionType.action997 then
        if args ~= nil then
            args()
        end
    elseif action == actionType.action998 then
        -- 关闭对话框
        self:Hide()
        return
    elseif action == 999 then
        -- 返回上一层
        self:Open(self.currentNpcData)
        return
    elseif action == actionType.action1000 then
        -- 跨服进入/退出
        if RoleManager.Instance.RoleData.cross_type == 0 then
            -- 不在跨服,进入
            RoleManager.Instance.jump_match_type = nil
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("是否进入<color='#ffff00'>跨服练级</color>地图，可与其他服务器玩家一同组队完成")
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                LuaTimer.Add(100,
                    function()
                        if #args > 0 then
                            RoleManager.Instance.jump_match_type = {first = tonumber(args[1]), second = tonumber(args[2]), status = TeamManager.Instance:MyStatus()}
                        end
                        RoleManager.Instance:CheckEnterCenter()
                    end)
            end
            NoticeManager.Instance:ConfirmTips(data)
        else
            -- 在跨服,退出
            RoleManager.Instance:CheckQuitCenter()
        end
    end
    if not notDoHide then
        self:Hide()
    end
end

function DialogModel:CheckMonkey()
    if RoleManager.Instance.RoleData.lev >= 40 then
        return true
    end

    if self.currentNpcData.baseid == 76015 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
        extra.base.buttons = {btn}
        extra.base.plot_talk = rule
        extra.base.plot_talk = TI18N("少侠等级太低了点，先升到<color='#00ff00'>40</color>级再来找我吧{face_1,26}{face_1,26}{face_1,26}")
        self:Open(self.currentNpcData, extra, true)
        return false
    elseif self.currentNpcData.baseid == 76011 then
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        local btn = {button_id = 999, button_args = {}, button_desc = TI18N("返回"), button_show = ""}
        extra.base.buttons = {btn}
        extra.base.plot_talk = rule
        extra.base.plot_talk = TI18N("哇呀呀，这么低级抓不住我{face_1,10}{face_1,10}{face_1,10}（<color='#00ff00'>40</color>级以上才能挑战）")
        self:Open(self.currentNpcData, extra, true)
        return false
    else
        return true
    end
end


-- 检查是不是伴侣关系组队
function DialogModel:CheckIsCouple()
    if TeamManager.Instance:MemberCount() ~= 2 then
        NoticeManager.Instance:On9910({base_id = 20047, msg = TI18N("对不起，只有异性好友或伴侣2人才能接取情缘任务哦")})
        return false
    end

    local role = RoleManager.Instance.RoleData
    for uniqueid,member in pairs(TeamManager.Instance.memberTab) do
        if uniqueid ~= BaseUtils.get_self_id() then
            if member.rid == role.lover_id and member.platform == role.lover_platform and member.zone_id == role.lover_zone_id then
                if role.wedding_status >= 2 then
                    return true
                end
            end
        end
    end

    return false
end

-- function DialogModel:CheckIsLove()
--     if not TeamManager.Instance:HasTeam() or TeamManager.Instance:MemberCount() == 1 then
--         local extra = {}
--         extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
--         local btn = {button_id = DialogEumn.ActionType.action22, button_args = {9, 91, 1, 1}, button_desc = TI18N("招募情缘"), button_show = ""}
--         extra.base.buttons = {btn}
--         extra.base.plot_talk = TI18N("情缘任务只能与异性好友组队接取哟，不如我帮你物色一名异性知己{face_1,9}<color='#ffff00'>(结缘后完成可以额外获得恩爱值奖励)</color>")
--         self:Open(self.currentNpcData, extra, true)
--     end
-- end

-- 检查是不是暧昧关系组队
function DialogModel:CheckIsAmbiguous()
    if not TeamManager.Instance:HasTeam() or TeamManager.Instance:MemberCount() == 1 then
        print("sdfdsfffffff")
        local extra = {}
        extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
        local btn = {button_id = DialogEumn.ActionType.action22, button_args = {9, 91, 1, 1}, button_desc = TI18N("招募情缘"), button_show = ""}
        extra.base.buttons = {btn}
        extra.base.plot_talk = TI18N("情缘任务只能与异性好友组队接取哟，不如我帮你物色一名异性知己{face_1,9}<color='#ffff00'>(结缘后完成可以额外获得恩爱值奖励)</color>")
        self:Open(self.currentNpcData, extra, true)
        return false
    end

    if TeamManager.Instance:MemberCount() ~= 2 then
        NoticeManager.Instance:On9910({base_id = 20047, msg = TI18N("对不起，只有异性好友或伴侣2人才能接取情缘任务哦")})
        return false
    end

    if RoleManager.Instance.RoleData.lover_id ~= nil and RoleManager.Instance.RoleData.lover_id ~= 0 and RoleManager.Instance.RoleData.wedding_status >= 2 then
        NoticeManager.Instance:On9910({base_id = 20047, msg = TI18N("别闹，已婚人士只能跟自己的爱人一起接取情缘任务")})
        return false
    end

    for uniqueid,member in pairs(TeamManager.Instance.memberTab) do
        if uniqueid ~= BaseUtils.get_self_id() then
            if member.sex == RoleManager.Instance.RoleData.sex then
                NoticeManager.Instance:On9910({base_id = 20047, msg = TI18N("对不起，只有异性好友才能接取情缘任务哦")})
                return false
            end
            if FriendManager.Instance:IsFriend(member.rid , member.platform, member.zone_id) then
                return true
            else
                NoticeManager.Instance:On9910({base_id = 20047, msg = TI18N("对不起，只有异性好友才能接取情缘任务哦")})

                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("只有好友才能接取情缘任务，快将TA加为好友吧。")
                data.sureLabel = TI18N("加为好友")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function() FriendManager.Instance:AddFriend(member.rid , member.platform, member.zone_id) end
                NoticeManager.Instance:ConfirmTips(data)
                return false
            end
        end
    end

    NoticeManager.Instance:On9910({base_id = 20047, msg = TI18N("对不起，只有异性好友或伴侣2人才能接取情缘任务哦")})
    return false
end

function DialogModel:AutoMatch(first, second, level, auto, doCaptin)
    TeamManager.Instance.TypeOptions = {}
    TeamManager.Instance.TypeOptions[first] = second
    TeamManager.Instance.LevelOption = level
    if second == 91 or second == 92 or second == 93 or second == 94 or doCaptin then
        TeamManager.Instance:Send11701()
        LuaTimer.Add(500, function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {auto}) end)
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {auto})
    end
end

function DialogModel:CheckIsActive()
    QiXiLoveManager.Instance.onUpdateActive:RemoveListener(self.setDataFun)
    if QiXiLoveManager.Instance.checkData.status == 0 then
        local teamData = TeamManager.Instance:GetMemberByTeamStatus(RoleEumn.TeamStatus.Follow)
        if TeamManager.Instance:HasTeam() and TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            if TeamManager.Instance:MemberCount() == 2 and teamData[1].sex ~= RoleManager.Instance.RoleData.sex then
                if FriendManager.Instance:IsFriend(teamData[1].rid, teamData[1].platform, teamData[1].zone_id) == false then
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = string.format(TI18N("只有好友才能领取同心锁哦，快加他为好友吧."))
                    data.sureLabel = TI18N("确认")
                    data.cancelLabel = TI18N("取消")
                    data.sureCallback = function ()
                        FriendManager.Instance:AddFriend(teamData[1].rid, teamData[1].platform, teamData[1].zone_id)
                    end
                    NoticeManager.Instance:ConfirmTips(data)
                end
            end
        end

        if TeamManager.Instance:HasTeam() == false or (TeamManager.Instance:HasTeam() and TeamManager.Instance:MemberCount()== 1 and TeamManager.Instance:HasLeave() == false) then
            local extra = {}
            extra.base = BaseUtils.copytab(DataUnit.data_unit[self.currentNpcData.baseid])
            extra.base.buttons = {{button_id = 22,button_args = {16,94,1,1},button_desc = "便捷组队",button_show = "[]"}
            , {button_id = 0,button_args = {20208},button_desc = "缘分对碰",button_show = "[]"}
            }
            extra.base.plot_talk = TI18N("需要与一名<color='#ffff00'>异性</color>有缘人组队，才可以领取<color='#ffff00'>同心锁</color>信物哟，快通过<color='#ffff00'>[便捷组队]</color>或<color='#ffff00'>[缘分对碰]</color>寻找有缘人吧{face_1,29}")
            extra.base.name = self.currentNpcData.name
            MainUIManager.Instance.dialogModel:Open(self.currentNpcData, extra, true)
            return
        end
        QiXiLoveManager.Instance:send17881()
    else
        QiXiLoveManager.Instance:send17881()
    end
end


