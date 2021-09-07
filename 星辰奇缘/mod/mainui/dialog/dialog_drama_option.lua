-- ----------------------------
-- 剧情对话，兼容任务npc对话处理
-- hosr
-- ----------------------------
DialogTalkOption = DialogTalkOption or BaseClass()

function DialogTalkOption:__init(mainPanel)
    self.mainPanel = mainPanel

    -- 预创建的按钮
    self.buttons = {}
    -- 使用的数量
    self.useCount = 0
    self.sceneData = nil

    -- 不显示按钮
    self.noButton = false

    -- 职业任务每个职业的npc不一样
    self.cycle_npcs = {20037, 20038, 20039, 20040, 20041}

    self.effectPath = "prefabs/effect/20107.unity3d"
    self.effect = nil
end

function DialogTalkOption:__delete()
end

function DialogTalkOption:InitPanel(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.titleTxt = self.transform:Find("Title"):GetComponent(Text)
    self.arrow = self.transform:Find("Arrow").gameObject
    self.scroll = self.transform:Find("Scroll"):GetComponent(ScrollRect)
    self.scrollRect = self.scroll.gameObject:GetComponent(RectTransform)
    self.container = self.transform:Find("Scroll/Buttons")
    self.containerRect = self.container:GetComponent(RectTransform)
    for i = 1, 10 do
        local tab = {}
        local btn = self.container:GetChild(i - 1)
        tab["transform"] = btn
        tab["btnsprite"] = btn:GetComponent(Image)
        tab["gameObject"] = btn.gameObject
        tab["label"] = btn:Find("Text"):GetComponent(Text)
        tab["rect"] = tab["label"].gameObject:GetComponent(RectTransform)
        tab["msgItemExt"] = MsgItemExt.New(tab["label"], 240, 18, 23)
        tab["button"] = btn.gameObject:GetComponent(Button)
        table.insert(self.buttons, tab)
    end
    self.gameObject:SetActive(false)
end

function DialogTalkOption:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
    self.noButton = false
end

function DialogTalkOption:Show(option)
    self.noButton = false
    self.special = false
    self.useCount = 0
    local npcData = option.base
    local tasks = option.tasks
    self.baseData = option.base
    self.sceneData = option.scenedata
    -- BaseUtils.dump(self.sceneData, "npc数据")
    if gm_cmd.auto_ancient and self.baseData.fun_type == SceneConstData.fun_type_treasure_ghost then
        -- 上古老司机
        SceneManager.Instance:Send10100(self.sceneData.battleid, self.sceneData.id)
        return false
    end
    if gm_cmd.auto2 then
        for k,btn in pairs(npcData.buttons) do
            if btn.button_id == DialogEumn.ActionType.action15 then
                QuestManager.Instance:Send10217(self.sceneData.battleid, self.sceneData.id)
            end
        end
    end

    -- inserted by 嘉俊 （自动历练，自动职业任务所需要）
    if AutoQuestManager.Instance.model.isOpen then
        for k,btn in pairs(npcData.buttons) do
            if btn.button_id == DialogEumn.ActionType.action15 and self.sceneData.battleid ~= nil and #btn.button_args > 0 and btn.button_args[1] == 1 then -- 历练中遇到的战斗npc
                QuestManager.Instance:Send10217(self.sceneData.battleid, self.sceneData.id)
            elseif btn.button_id == DialogEumn.ActionType.action6 and self.sceneData.battleid ~= nil then -- 职业任务中遇到的战斗npc
                SceneManager.Instance:Send10100(self.sceneData.battleid, self.sceneData.id)
            end
        end
    end
    -- end by 嘉俊

    local ok = true
    if #npcData.buttons == 0 then
        if #tasks == 1 then
            self.useCount = self.useCount + 1
            ok = self:ShowQuest(tasks[1], self.buttons[1])
        else
            ok = self:ShowOption(npcData, tasks)
        end
    else
        if #npcData.buttons == 1 and #tasks == 0 then
            --如果只有一个功能，没有任务，直接处理相关功能,不打开对话框
            local action = npcData.buttons[1].button_id
            if action == 5 then
                npcData.buttons = {}
                ok = self:ShowOption(npcData, tasks)
            elseif action == 4 or action == 6 or action == 8 or action == 9 or action == 11 or action == 15 or action == 16 or action == 17 or action == 22 or action == 23 or action == 30 or action == 35 or action == 48 or action == 50 or action == 97 or action == 101 or action == 102 or action == 998 or action == 999 then
                ok = self:ShowOption(npcData, tasks)
                self:ShowKillGuide()
            else
                local args = npcData.buttons[1].button_args
                local rule = npcData.buttons[1].button_show

                if  (action == 40 and args[1] == 2) or
                    (action == 51 and args[1] == 2) or
                    (action == 53 and (args[1] == 3 or args[1] == 4 or args[1] == 5))
                 then
                    ok = self:ShowOption(npcData, tasks)
                    self:ShowKillGuide()
                else
                    self.mainPanel.model:ButtonAction(action, args, rule)
                    return false
                end
            end
        else
            ok = self:ShowOption(npcData, tasks)
        end
    end

    if self.special then
        return false
    end

    if ok and not self.noButton then
        self:Layout()
    else
        self.gameObject:SetActive(false)
    end
    return ok
end

function DialogTalkOption:ShowOption(base, tasks)
    self.base = base
    self:ChangeText(base, tasks)

    local isover = false
    if #base.buttons == 0 then
        if #tasks == 0 then
        else
            isover = self:TaskButtons(tasks)
        end
    else
        if #tasks ~= 0 then
            isover = self:TaskButtons(tasks)
        end
        if not isover then
            self:DoButtons(base.buttons)
        end
    end

    return true
end

function DialogTalkOption:ChangeText(base, tasks)
    if base.id == 20075 then -- 如果是家园管家小暖
        self.mainPanel:ChangeText(string.format(base.plot_talk, HomeManager.Instance.model.cleanness))
    else
        self.mainPanel:ChangeText(base.plot_talk)
    end
end

function DialogTalkOption:DoButtons(buttons)
    -- BaseUtils.dump(buttons,"DialogTalkOption:DoButtons(buttons)--")
    for i,v in ipairs(buttons) do
        self.useCount = self.useCount + 1
        local action = v.button_id
        local args = v.button_args
        local rule = v.button_show

        local tab = self.buttons[self.useCount]
        if tab == nil then
            return
        end

        tab["gameObject"]:SetActive(true)
        if tab["msgItemExt"] ~= nil then
            tab["msgItemExt"]:Reset()
        end
        tab["label"].text = v.button_desc
        tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        if action == DialogEumn.ActionType.action3 then
            local val = QuestManager.Instance.time_cycle_max - QuestManager.Instance.time_cycle + 1
            if (QuestManager.Instance.time_cycle == QuestManager.Instance.time_cycle_max and QuestManager.Instance.round_cycle == 10) or QuestManager.Instance.time_cycle == 0 then
                val = 0
            end
            val = val >= 0 and val or 0
            if val == 0 then
                tab["label"].text = TI18N("今日已完成")
            else
                -- tab["label"].text = string.format("%s<color='#66ff00'>(今日剩余%s轮)</color>", v.button_desc, val)
                tab["label"].text = TI18N("<color='#66ff00'>前往任务</color>")
            end
        elseif action == DialogEumn.ActionType.action15 then
            if args[1] == 5 then
                tab["label"].text = string.format(TI18N("幸运值:<color='#00ff00'>%s</color>"), QuestManager.Instance.chainLucky)
            end
        elseif action == DialogEumn.ActionType.action55 and WorldChampionManager.Instance.currstatus ~= 0 then
            -- tab["label"].text = string.format("<color='#00ff00'>%s</color>", v.button_desc)
            tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                tab["label"].text = TI18N("<color='#ffff00'>参加比武</color>")
        elseif action == DialogEumn.ActionType.action31 then
            local num = 10 - DataAgenda.data_list[1011].engaged
            if num == 0 then
                tab["msgItemExt"]:SetData(TI18N("今日宝图已兑换"))
            else
                tab["msgItemExt"]:SetData(string.format(TI18N("兑换宝图({assets_1,90002,%s}兑%s张)"), num * tonumber(args[1]), num))
                -- local star_gold = RoleManager.Instance.RoleData.star_gold
                -- if star_gold == 0 then
                -- elseif star_gold < num * tonumber(args[1]) then
                --     tab["msgItemExt"]:SetData(string.format(TI18N("兑换宝图({assets_1,29255,%s}兑%s张)"), num * tonumber(args[1]), num))
                -- else
                --     tab["msgItemExt"]:SetData(string.format(TI18N("兑换宝图({assets_1,90026,%s}兑%s张)"), num * tonumber(args[1]), num))
                -- end
            end
        elseif action == DialogEumn.ActionType.action37 then
            --参加活动，便捷组队，开始任务
            tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            local status_data = PetLoveManager.Instance.model.pet_love_status_data
            if status_data ~= nil and (status_data.phase == 2 or status_data.phase == 3) then
                if PetLoveManager.Instance.model.has_sign == 1 or PetLoveManager.Instance.model.has_sign == 3 then
                    --还没有参加
                    tab["label"].text = TI18N("参加活动")
                else
                    --已经参加，则判断队伍规则满不满足
                    if TeamManager.Instance:HasTeam() then
                        local total_num = 0
                        for k, v in pairs(TeamManager.Instance.memberTab) do
                            total_num = total_num + 1
                        end
                        if total_num >= 2 then
                            --队伍人数符合
                            tab["label"].text = TI18N("开始任务")
                        else
                            --队伍人数不符合
                            tab["label"].text = TI18N("便捷组队")
                        end
                    else
                        --队伍人数不符合
                        tab["label"].text = TI18N("便捷组队")
                    end
                end
            else
                tab["label"].text = v.button_desc
            end
        elseif action == DialogEumn.ActionType.action38 then
            tab["msgItemExt"]:SetData(v.button_desc)
        elseif action == DialogEumn.ActionType.action109 then
            tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            tab["label"].text = string.format(ColorHelper.DefaultButton3Str, tab["label"].text)
        elseif action == DialogEumn.ActionType.action15 and #args == 0 then
            local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.chain)
            if questData ~= nil then
                local preval = string.format("(%s/%s)", QuestManager.Instance.round_chain, QuestManager.Instance.round_chain_max)
                tab["label"].text = string.format("<color='%s'>[%s]%s</color>%s", QuestEumn.ColorName(questData.sec_type), QuestEumn.TypeName[questData.sec_type], questData.name, preval)
            end
        elseif action == DialogEumn.ActionType.action40 then
            if args[1] == 3 then
                local currentMonth = tonumber(os.date("%m", BaseUtils.BASE_TIME))
                local currentDay = tonumber(os.date("%d", BaseUtils.BASE_TIME))
                local festivalList = FestivalManager.Instance.model.festivalList
                for i = 1, #festivalList do
                    if currentMonth == festivalList[i].mount and currentDay == festivalList[i].day then
                        tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                        tab["label"].text = string.format(ColorHelper.DefaultButton3Str, tab["label"].text)
                        break
                    end
                end
            end
        elseif action == DialogEumn.ActionType.action43 then
            --师徒
            -- Log.Error("-----------------"..args[1])
            if #args == 1 then
                if args[1] == 4 then
                    -- if RoleManager.Instance.RoleData.lev >= RoleManager.Instance.world_lev or RoleManager.Instance.RoleData.lev >= 70 then
                    if RoleManager.Instance.RoleData.lev >= 50 then
                        if TeacherManager.Instance.model.beTeacherState == 0 then
                            tab["label"].text = TI18N("我要报名师傅")
                        else
                            tab["label"].text = TI18N("取消自动收徒")
                        end
                    else--if RoleManager.Instance.RoleData > 19 then
                        tab["label"].text = TI18N("我要寻找师傅")
                    end
                elseif args[1] == 3 then
                    if TeacherManager.Instance.model:IsHasTeahcerStudentRelationShip() == true then
                        TeacherManager.Instance:send15807()
                    end
                end
            end
        elseif action == DialogEumn.ActionType.action35 then
            if args[1] == 0 and RoleManager.Instance.RoleData.wedding_status == 3 then
                tab["label"].text = TI18N("伴侣技能")
                args = { 2 }
            end
        elseif action == DialogEumn.ActionType.action51 then
            if args[1] ~= 4 then
                tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                tab["label"].text = string.format(ColorHelper.DefaultButton3Str, tab["label"].text)
            end
        elseif action == DialogEumn.ActionType.action56 then-- 创建家园
            tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        elseif action == DialogEumn.ActionType.action57 then-- 进入家园
            tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        elseif action == DialogEumn.ActionType.action63 then
            if args[1] == 2 then
                tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            end
        elseif action == DialogEumn.ActionType.action65 then
            local cfg_data = DataQuestPursue.data_cost[RoleManager.Instance.RoleData.lev]
            if cfg_data ~= nil then
                tab["label"].text = string.format("%s(<color='#ffff00'>%s</color>%s)", TI18N("领取任务"), cfg_data.cost[1][2], TI18N("银币"))
            end
        elseif action == DialogEumn.ActionType.action70 then
            tab["msgItemExt"]:SetData(v.button_desc)
        elseif action == DialogEumn.ActionType.action84 then
            if args[1] == 3 then
                tab["msgItemExt"]:SetData(v.button_desc)
                tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            end
        elseif action == DialogEumn.ActionType.action112 then
            local autoMode = AutoQuestManager.Instance.model.autoMode
            if autoMode == 1 then
                tab["label"].text = TI18N("当前状态：<color='#ffff00'>全自动</color>")
            else
                tab["label"].text = TI18N("当前状态：<color='#ffff00'>半自动</color>")
            end
        end

        tab["button"].onClick:RemoveAllListeners()
        tab["button"].onClick:AddListener(function() self:ClickOptionButton(action, args, rule) end)

        local w = tab["label"].preferredWidth
        local h = tab["label"].preferredHeight
        tab["rect"].sizeDelta = Vector2(w, h)
        -- tab["rect"].anchoredPosition = Vector2.zero
        tab["rect"].anchoredPosition = Vector2((240 - w) / 2, -(48 - h) / 2)

        -- 处理显示条件
        if action == DialogEumn.ActionType.action3 then
            local npc = self.cycle_npcs[RoleManager.Instance.RoleData.classes]
            if self.base.id ~= npc then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action6 then --单位是否处以战斗状态显示开战按钮

        elseif action == DialogEumn.ActionType.action0 and args[1] == 18601 then --子女任务购买瓶子按钮

            if QuestManager.Instance:GetQuest(83100) == nil then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action15 then
            if tonumber(args[1]) == 99 then
                -- 不现实继续任务链的按钮，点对话框任何地方跑任务链去
                self.mainPanel.AnywayDoChain = true
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action35 then
            if RoleManager.Instance.RoleData.wedding_status == 2 and RoleManager.Instance.RoleData.wedding_status == 3 and (args[1] == nil or tonumber(args[1]) == 0) then
                -- 不现实继续任务链的按钮，点对话框任何地方跑任务链去
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action42 then
            local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.plant)
            if questData == nil then
                tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                tab["label"].text = string.format(ColorHelper.DefaultButton3Str, TI18N("领取种植任务"))
            else
                tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                tab["label"].text = string.format(ColorHelper.DefaultButton4Str, TI18N("领取种植任务"))

            end

        elseif action == DialogEumn.ActionType.action43 then
            --师徒
            local Teachermodel = TeacherManager.Instance.model
            local conditional_data = DataTeacher.data_get_condition[RoleManager.Instance.world_lev]
            local stu = nil
            for key, value in pairs(TeamManager.Instance.memberTab) do
                 value.id = value.rid
                 if TeacherManager.Instance.model:IsMyStudent(value) then 
                    stu = value
                    break
                 end
            end
            if #args == 1 then 
                if (args[1] == 2 and (stu == nil)) 
                    or (args[1] == 3 and Teachermodel:IsHasTeahcerStudentRelationShip() == false) 
                        or (args[1] == 4 and RoleManager.Instance.RoleData.lev < conditional_data.need_lev) then 
                    self.useCount = self.useCount - 1
                    tab["gameObject"]:SetActive(false)
                end
            end
        elseif action == DialogEumn.ActionType.action52 then --单位是否处以战斗状态显示观战按钮
            -- BaseUtils.dump(self.sceneData)
            -- if self.baseData.fun_type == SceneConstData.fun_type_constellation and self.sceneData.status ~= 2 then
            --     self.useCount = self.useCount - 1
            --     tab["gameObject"]:SetActive(false)
            -- end
        elseif action == DialogEumn.ActionType.action56 then
            if RoleManager.Instance.RoleData.fid ~= 0 then
                -- 不现实继续任务链的按钮，点对话框任何地方跑任务链去
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action57 then
            if RoleManager.Instance.RoleData.fid == 0 then
                -- 不现实继续任务链的按钮，点对话框任何地方跑任务链去
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action58 then
            if RoleManager.Instance.RoleData.fid == 0  or not HomeManager.Instance.model:CanEditHome() then
                -- 不现实继续任务链的按钮，点对话框任何地方跑任务链去
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        -- elseif action == DialogEumn.ActionType.action59 then
        --     tab["label"].text = string.format("<color='#00ff00'>%s</color>",v.button_desc)
        --     tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        elseif action == DialogEumn.ActionType.action61 then
            if WorldChampionManager.Instance.currstatus ~= 2 then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action62 then
            if RoleManager.Instance.RoleData.fid == 0 or not HomeManager.Instance.model:CanEditHome() then
                -- 不现实继续任务链的按钮，点对话框任何地方跑任务链去
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action64 then
            if RoleManager.Instance.RoleData.fid == 0 or not HomeManager.Instance.model:CanEditHome() then
                -- 不现实继续任务链的按钮，点对话框任何地方跑任务链去
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action65 then
            --光速修炼
            local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.fineType)
            if RoleManager.Instance.world_lev < 60 or RoleManager.Instance.RoleData.lev < 65 or questData ~= nil then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action67 then
            if RoleManager.Instance.RoleData.wedding_status ~= 3 then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action68 then
            if RoleManager.Instance.RoleData.wedding_status ~= 3 then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action81 then
            -- 攻塔按钮判断阵营
            if (CanYonManager.Instance.self_side == 1 and self.sceneData.id <= 3) or (CanYonManager.Instance.self_side ~= 1 and self.sceneData.id > 3) then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action82 then
            if (CanYonManager.Instance.self_side == 1 and self.sceneData.id > 3) or (CanYonManager.Instance.self_side ~= 1 and self.sceneData.id <= 3) then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action1000 then
            -- 进入、退出 跨服
            if RoleManager.Instance.RoleData.lev < 20 then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            elseif not RoleManager.Instance:CanConnectCenter() then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            elseif RoleManager.Instance.RoleData.cross_type == 1 then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action72 or action == DialogEumn.ActionType.action74 then
            if LevelBreakManager.Instance.model:CheckWolrdCollected() then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action94 then
            local questid = tonumber(args[1])
            if QuestManager.Instance:GetQuest(questid) == nil then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action95 then
            local quest = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.child)
            if quest ~= nil then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif  action == DialogEumn.ActionType.action113 then
            if DoubleElevenManager.Instance.questGet == true then
                tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            else
                tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            end
        elseif action == DialogEumn.ActionType.action115 then
            local hour = os.date("%H",BaseUtils.BASE_TIME)

            local petEggConfig = DataCampPetEgg.data_get_extra_cfg[1]
            local timeFlag = false
            if petEggConfig ~= nil then
                timeFlag = tonumber(hour) >= petEggConfig.time[1][1] and tonumber(hour) < petEggConfig.time[1][4]
            end

            local achievebool = MagicEggManager.Instance.model.achievebool

            if achievebool == 1 then
                tab["label"].text = string.format(ColorHelper.DefaultButton3Str, TI18N("领取鸿福兔纸"))
                tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            elseif achievebool == 2 then
                if timeFlag and PetManager.Instance:HasEvolveEgg() then
                    tab["label"].text = string.format(ColorHelper.DefaultButton3Str, TI18N("开启瑞兔送福"))
                    tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                else
                    tab["label"].text = string.format(ColorHelper.DefaultButton1Str, TI18N("开启瑞兔送福"))
                    tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                end
            elseif achievebool == 3 then
                tab["label"].text = string.format(ColorHelper.DefaultButton4Str, TI18N("已开启"))
                tab["btnsprite"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            end
        elseif action == DialogEumn.ActionType.action125 then
            -- local StartTime = 0
            -- local EndTime = 0
            -- --BaseUtils.dump(GodsWarManager.Instance.godwarTimeData,"GodsWarManager.Instance.godwarTimeData")
            -- local endStatus = GodsWarManager.Instance.godwarTimeData[25]
            -- if endStatus == nil then
            --     endStatus = GodsWarManager.Instance.godwarTimeData[23]
            -- end
            -- local GodsChallTime = endStatus.end_time
            -- if GodsChallTime ~= nil then
            --     local y = tonumber(os.date("%Y",GodsChallTime))
            --     local m = tonumber(os.date("%m",GodsChallTime))
            --     local d = tonumber(os.date("%d",GodsChallTime))
            --     local h = tonumber(os.date("%H",GodsChallTime))
            --     StartTime = os.time({year =y, month = m, day =d, hour =h, min =0, sec = 0})
            --     EndTime = os.time({year =y, month = m, day =d+1, hour =23, min =59, sec = 59})
            -- end
            -- if BaseUtils.BASE_TIME < StartTime or BaseUtils.BASE_TIME > EndTime then
            --     self.useCount = self.useCount - 1
            --     tab["gameObject"]:SetActive(false)
            -- end
            --策划改需求了
            self.useCount = self.useCount - 1
            tab["gameObject"]:SetActive(false)
        elseif action == DialogEumn.ActionType.action126 and args[1] == 1 then
            local GodsWarWorshipStatus = GodsWarWorShipManager.Instance.godsWarStatus
            if not (GodsWarWorShipManager.Instance.isHasGorWarShip == 1 and (GodsWarWorshipStatus == 6 or GodsWarWorshipStatus == 8 or GodsWarWorshipStatus == 5)) then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action128 then
            local isOpen = (HalloweenManager.Instance.model.status ~= 0)
            if not isOpen then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action129 then
            local lev = RoleManager.Instance.RoleData.lev
            if lev < 65 then
                self.useCount = self.useCount - 1
                tab["gameObject"]:SetActive(false)
            end
        elseif action == DialogEumn.ActionType.action996 then 
            self.useCount = self.useCount - 1
            if CampaignManager.CheckCampaignStatus(args[1]) == 1 then
                local button_args = {}
                for i= 3, #args do
                    table.insert(button_args, args[i])
                end
                local buttons = {button_id = args[2], button_args = button_args, button_show = rule, button_desc = v.button_desc }
                self:DoButtons({buttons})
            end
        end
    end
end



function DialogTalkOption:TaskButtons(tasks)
    for i,task in ipairs(tasks) do
        self.useCount = self.useCount + 1
        local tab = self.buttons[self.useCount]
        if task.sec_type == QuestEumn.TaskType.cycle or task.sec_type == QuestEumn.TaskType.chain or task.sec_type == QuestEumn.TaskType.couple or task.sec_type == QuestEumn.TaskType.ambiguous or task.sec_type == QuestEumn.TaskType.teacher or task.sec_type == QuestEumn.TaskType.seekChild or task.sec_type == QuestEumn.TaskType.acquaintance then
            local ok = self:ShowQuest(task, tab)
            return ok
        elseif task.sec_type == QuestEumn.TaskType.offer and task.finish == 2 then
            self:ShowQuest(task, tab)
            return true
        elseif task.type == QuestEumn.TaskTypeSer.main and task.finish ~= 1 then
            self:ShowQuest(task, tab)
            return true
        elseif task.sec_type == QuestEumn.TaskType.guild and task.finish == 2 then
            self:ShowQuest(task, tab)
            return true
        elseif task.sec_type == QuestEumn.TaskType.treasuremap and task.finish == 2 then
            self:ShowQuest(task, tab)
            return true
        elseif task.sec_type == QuestEumn.TaskType.defensecake and task.finish == 2 then
            self:ShowQuest(task, tab)
            return true
        elseif #task.progress == 0 then
            self:ShowQuest(task, tab)
            return true
        else
            tab["label"].text = task.name
            local arg = task
            tab["button"].onClick:RemoveAllListeners()
            tab["button"].onClick:AddListener(function() self:ShowQuest(arg, tab) end)
        end
    end
    return false
end

function DialogTalkOption:ShowQuest(task, tab)
    self.noButton = false
    self.special = false
    if task.finish == 2 then
        if task.sec_type == QuestEumn.TaskType.cycle then
            --所有职业任务可提交都不打开对话框，直接提交
            QuestManager.Instance:Send10206(task.id)
            local plot = DataPlot.data_plot[task.id]
            if not (QuestManager.Instance.round_cycle == 0 and QuestManager.Instance.time_cycle == 2) and plot ~= nil then
                self.noButton = true
                self.mainPanel:ChangeText(BaseUtils.split(plot.data[1].val, ",")[4])
                self.special = false
                return true
            else
                self.special = true
                return true
            end
        elseif task.sec_type == QuestEumn.TaskType.chain then
            QuestManager.Instance:Send10206(task.id)
            self.special = true
            return true
        elseif task.sec_type == QuestEumn.TaskType.seekChild and task.talk_commit == "" then
            QuestManager.Instance:Send10206(task.id)
            self.noButton = true
            self.special = true
            return true
        elseif task.sec_type == QuestEumn.TaskType.couple or task.sec_type == QuestEumn.TaskType.ambiguous or task.sec_type == QuestEumn.TaskType.teacher then
            local clilabel = QuestManager.Instance:GetQuestCurrentLabel(task)
            if clilabel == QuestEumn.CliLabel.visit then
                QuestManager.Instance:Send10223(task.id, 3)
            else
                QuestManager.Instance:Send10206(task.id)
            end
            self.special = true
            return true
        elseif task.sec_type == QuestEumn.TaskType.acquaintance then
            QuestManager.Instance:Send10223(task.id, 3)
            self.special = true
            return true
        end
    end
    self.currentQuest = task

    tab["button"].onClick:RemoveAllListeners()
    tab["button"].onClick:AddListener(function() self:ClickTaskButton() end)

    if task.finish == 2 then --可提交
        self.mainPanel:ChangeText(task.talk_commit)
        if task.is_button_commit == 1 and task.button_commit ~= "" then
            tab["label"].text = task.button_commit
        else
            self.noButton = true
            self.mainPanel.AnywayCommitId = task.id
            tab["label"].text = TI18N("领取奖励")
            if RoleManager.Instance.RoleData.lev <= AutoRunManager.Instance.levLimit and AutoRunManager.Instance.isOpen then
                MainUIManager.Instance.dialogModel:SetTimeoutClose(AutoRunManager.Instance.timeLimit)
            end
            return true
        end
    elseif task.finish == 0 then --可接受
        self.mainPanel:ChangeText(task.talk_accpet)
        tab["label"].text = TI18N("接受任务")
    elseif task.finish == 1 then --进行任务
        self.mainPanel:ChangeText(task.talk_commit)
        tab["label"].text = TI18N("前往任务")
    end

    return true
end

function DialogTalkOption:Layout()
    for i,tab in ipairs(self.buttons) do
        if i > self.useCount then
            tab["gameObject"]:SetActive(false)
        else
            tab["transform"].localPosition = Vector3(0, -(i - 1) * 48, 0)
            tab["gameObject"]:SetActive(true)
        end
    end
    local count = math.min(self.useCount, 5)
    self.containerRect.localPosition = Vector2(0, 0)
    self.containerRect.sizeDelta = Vector2(240, 48 * self.useCount)
    self.scrollRect.sizeDelta = Vector2(290, 48 * count)
    self.scroll.enabled = (self.useCount > 5)
    self.arrow:SetActive(self.useCount > 5)
    self.rect.sizeDelta = Vector2(290, 90 + 48 * count)

    if count > 0 then
        self.gameObject:SetActive(true)
    else
        self.gameObject:SetActive(false)
    end
end

function DialogTalkOption:ClickTaskButton()
    if self.currentQuest.finish == 2 then
        -- 提交
        QuestManager.Instance:Send10206(self.currentQuest.id)
    elseif self.currentQuest.finish == 0 then
        -- 接取
        QuestManager.Instance:Send10202(self.currentQuest.id)
    elseif self.currentQuest.finish == 1 then
        -- 前往
        QuestManager.Instance:DoQuest(self.currentQuest)
    end
    self.mainPanel:Hiden()
end

function DialogTalkOption:ClickOptionButton(action, args, rule)
    self.mainPanel.model:ButtonAction(action, args, rule)
    if self.effect ~= nil then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end
end

function DialogTalkOption:ShowKillGuide()
    if RoleManager.Instance.RoleData.lev <= 15 and QuestManager.Instance.guideKillId == self.base.id then
        self.assetWrapper = AssetBatchWrapper.New()
        local func = function()
            if self.assetWrapper == nil then return end
            local tab = self.buttons[1]
            self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
            self.effect.name = "GuideEffect"
            local transform = self.effect.transform
            Utils.ChangeLayersRecursively(transform, "UI")
            transform:SetParent(tab.transform)
            transform.localScale = Vector3(1.15, 0.95, 1)
            transform.localPosition = Vector3(0, -23, 0)
            self.effect:SetActive(false)
            self.effect:SetActive(true)

            self.assetWrapper:DeleteMe()
            self.assetWrapper = nil
        end
        self.assetWrapper:LoadAssetBundle({{file = self.effectPath, type = AssetType.Main}}, func)
    end
end
