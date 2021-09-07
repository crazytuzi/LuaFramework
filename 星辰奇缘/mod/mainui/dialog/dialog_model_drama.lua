-- --------------------------
-- npc对话框管理   剧情对话方式
-- hosr
-- --------------------------
DialogModelDrama = DialogModelDrama or BaseClass(DialogModel)

function DialogModelDrama:__init()
    self.currentNpcData = nil

    self.dramaTalk = DialogDramaPanel.New(self)

    self.TimeoutClose = 0

    self.isOpenning = false
    self.timerId = 0
    self.timeOpenGuildBox = 0

    self.curShowTimeContent = false

    self.loopCall = function() self:Loop() end
    self.loopStr = nil
    self.loopAllTime = nil
end

function DialogModelDrama:__delete()
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
    if self.dramaTalk ~= nil then
        self.dramaTalk:DeleteMe()
        self.dramaTalk = nil
    end
end

function DialogModelDrama:SetAnywayCallback(callback)
    if self.dramaTalk ~= nil and callback ~= nil then
        self.dramaTalk.AnywayCallback = callback
    end
end

function DialogModelDrama:SetTimeoutClose(time)
    self.TimeoutClose = time
end

function DialogModelDrama:Open(npcData, extra, notask, special, isPlant)
    self.currentNpcData = npcData
    if self:CheckGuidePetBook() then
        DramaManager.Instance.model:JustPlayPlot(30130)
        return
    end

    if npcData.baseid == 20042 and gm_cmd.auto == true then
        QuestManager.Instance:Send10211(QuestEumn.TaskType.offer)
        return
    end
    if not special and (self:CheckChainQuestCommit() or self:CheckFineQuestCommit()) then
        return
    end

    self.isOpenning = true

    local base = nil
    local newNpcBase = self:CheckChainQuestFight(npcData)
    if newNpcBase ~= nil then
        base = BaseUtils.copytab(newNpcBase)
        base.looks = npcData.looks
        base.classes = npcData.classes
        base.sex = npcData.sex
    else
        if extra ~= nil and extra.base ~= nil then
            base = BaseUtils.copytab(extra.base)
        else
            base = BaseUtils.copytab(DataUnit.data_unit[npcData.baseid])
            base.looks = npcData.looks
            base.classes = npcData.classes
            base.sex = npcData.sex
            base.name = npcData.name
        end
    end

    local tasks = {}
    if not notask and (npcData.baseid == 20032 or npcData.battleid == 1 or npcData.battleid == 0 or npcData.battleid == 32 or npcData.baseid == 71150) then
        -- 处理普通剧情创建单位和固定场景单位之外，其他的都不会有任务,加上公会的特殊单位..
        tasks = QuestManager.Instance:GetNpcQuest(npcData.id, npcData.battleid, npcData.baseid)
    end

    local ok = self.dramaTalk:ShowOption({base = base, tasks = tasks, scenedata = npcData})
    if gm_cmd.auto2 then
        self.dramaTalk:OnClickNext()
    end

    -- inserted by 嘉俊 自动历练，自动职业任务
    if AutoQuestManager.Instance.model.isOpen then
        self.dramaTalk:OnClickNext()
    end

    -- 峡谷之巅活动备战阶段、不显示水晶塔对话
    if npcData.baseid == 79571 or npcData.baseid == 79572 or npcData.baseid == 79573 or npcData.baseid == 79574 or npcData.baseid == 79575 or npcData.baseid == 79576 or npcData.baseid == 79577 then 
        if CanYonManager.Instance.currstatus == CanYonEumn.Status.Preparing then
            ok = false
        end
    end

    -- end by 嘉俊
    if ok then
        self.dramaTalk:ShowPreview(base)
    end

    self.loopStr = ""
    self.loopAllTime = 0
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end

    if npcData.baseid == 79713 or npcData.baseid == 79722 then
        self.curShowTimeContent = false
        if special == nil or special == false then
            self.curShowTimeContent = true
            GuildManager.Instance:request11177()
        end
    elseif npcData.baseid == 71150 and special then
        self.loopStr = TI18N("今日已完成孕育任务，倒计时结束后可得知结果：")
        self.loopAllTime = QuestManager.Instance.childPlantData.last_commited+7200 - BaseUtils.BASE_TIME
        if self.loopAllTime > 0 then
            self:LoopShow()
        end
    elseif not special and isPlant and QuestManager.Instance.plantData ~= nil and npcData.id == QuestManager.Instance.plantData.unit_id and tonumber(QuestManager.Instance.round_plant) ~= 6 then
        self.loopStr = string.format(TI18N("谢谢你精心的播种，小树苗等会就可以快高长大结出丰硕果实了！<color='#7FFF00'>离下一阶段</color>还有"), QuestEumn.PlantName[QuestManager.Instance.plantData.phase])
        self.loopAllTime = QuestEumn.PlantTime[QuestManager.Instance.plantData.phase] - (BaseUtils.BASE_TIME - QuestManager.Instance.plantData.last_commited)
        if self.loopAllTime <= 0 then
            self.dramaTalk:ChangeText(string.format("%s<color='#00ff00'>00:00:00</color>", self.loopStr))
        else
            self:LoopShow()
        end
    elseif ConstellationManager.Instance.currentData ~= nil
        and ConstellationManager.Instance.currentData.summoned ~= nil
        and npcData.battleid == 0
        and ConstellationManager.Instance.currentData.summoned.base_id == npcData.baseid then
        self.loopStr = string.format("%s\n%s", base.plot_talk, TI18N("星座剩余存在时间:"))
        self.loopAllTime = 60 * 60 - (BaseUtils.BASE_TIME - ConstellationManager.Instance.currentData.summoned.time)
        if self.loopAllTime > 0 then
            self:LoopShow()
        end
    end

    self.dramaTalk:ShowFinger(#tasks > 0)
end

function DialogModelDrama:LoopShow()
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
    self.timerId = LuaTimer.Add(0, 1000, self.loopCall)
end

function DialogModelDrama:Loop()
    if self.loopAllTime <= 0 then
        if self.timerId ~= 0 then
            LuaTimer.Delete(self.timerId)
            self.timerId = 0
            self.dramaTalk:ChangeText(string.format("%s<color='#00ff00'>00:00:00</color>", self.loopStr))
            self:Hide()
        end
        return
    end
    self.loopAllTime = self.loopAllTime - 1
    local timestr = BaseUtils.formate_time_gap(self.loopAllTime, ":", 0, BaseUtils.time_formate.HOUR)
    self.dramaTalk:ChangeText(string.format("%s<color='#00ff00'>%s</color>", self.loopStr, timestr))
    -- self.dramaTalk:ChangeText(string.format("%s<color='#00ff00'>%s</color>", self.loopStr, os.date("%H:%M:%S", self.loopAllTime)))
end

function DialogModelDrama:UpdateDialogData()
    if GuildManager.Instance.model.guildTreasure.setting_chance > 0 then
        --未设定
        self.dramaTalk:ChangeText(TI18N("会长可与公会成员协商后设定开启时间。"))
    else
        --已设定
        local dayTemp = tonumber(os.date("%d", BaseUtils.BASE_TIME))
        local dayTempH = tonumber(os.date("%H", BaseUtils.BASE_TIME))
        local dayTempM = tonumber(os.date("%M", BaseUtils.BASE_TIME))
        local dayTempSet = tonumber(os.date("%d", GuildManager.Instance.model.guildTreasure.setting_time))
        local dayTempSetm = tonumber(os.date("%m", GuildManager.Instance.model.guildTreasure.setting_time))
        local dayTempSetH = tostring(os.date("%H", GuildManager.Instance.model.guildTreasure.setting_time))
        local dayTempSetM = tostring(os.date("%M", GuildManager.Instance.model.guildTreasure.setting_time))
        if BaseUtils.BASE_TIME < GuildManager.Instance.model.guildTreasure.setting_time then
            --时间未到
            self.dramaTalk:ChangeText(string.format(TI18N("开启时间已设定，请准时参与开启，共同守护公会秘藏并分享荣誉。　　　　　　　开启时间 <color='#ffff00'>%d月%d日 %s：%s</color>")
                ,dayTempSetm,dayTempSet,dayTempSetH,dayTempSetM))
        elseif BaseUtils.BASE_TIME - GuildManager.Instance.model.guildTreasure.setting_time > 1200 then
            print(GuildManager.Instance.model.guildTreasure.setting_time.."GuildManager.Instance.model.guildTreasure.setting_time"..debug.traceback())
            self.dramaTalk:ChangeText(TI18N("时间已过"))
        else
            --进行中
            -- print(debug.traceback())
            -- BaseUtils.dump(GuildManager.Instance.model.guildTreasure,"DialogModelDrama:UpdateDialogData() --")
            if self.timerId ~= 0 then
                LuaTimer.Delete(self.timerId)
                self.timerId = 0
            end
            self.timeOpenGuildBox = 1200 - (BaseUtils.BASE_TIME - GuildManager.Instance.model.guildTreasure.setting_time) --剩余时间
            self.dramaTalk:ChangeText(string.format(TI18N("宝箱正在开启，期间将会不定期有夺宝小妖入侵抢夺宝物，请在开启前守住秘藏宝箱！　　　　　　　　　　　　　　　　　　　　　　开启剩余时间 <color='#ffff00'>%s</color>")
                ,BaseUtils.formate_time_gap(self.timeOpenGuildBox,":",0,BaseUtils.time_formate.MIN)))
            self.timerId = LuaTimer.Add(0, 1000, function()
                --print(self.clickInterval)
                if self.timeOpenGuildBox > 0 then
                    self.timeOpenGuildBox = self.timeOpenGuildBox - 1
                    if self.curShowTimeContent == true then
                        self.dramaTalk:ChangeText(string.format(TI18N("宝箱正在开启，期间将会不定期有夺宝小妖入侵抢夺宝物，请在开启前守住秘藏宝箱！　　　　　　　　　　　　　　　　　　　　　　开启剩余时间 <color='#ffff00'>%s</color>")
                        ,BaseUtils.formate_time_gap(self.timeOpenGuildBox,":",0,BaseUtils.time_formate.MIN)))
                    end
                else
                    self.timeOpenGuildBox = 0
                    LuaTimer.Delete(self.timerId)
                    self.timerId = 0
                end
            end)
        end
    end
end

function DialogModelDrama:Hide()
    if self.dramaTalk ~= nil then
        self.isOpenning = false
        self.dramaTalk:Hiden()
    end

    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
end

-- 检查是否是任务链有关的提交npc，如果任务完成的，直接提交任务
function DialogModelDrama:CheckChainQuestCommit()
    if self.currentNpcData.id == QuestManager.Instance.chainUnitId and self.currentNpcData.battleid == 1 then
        local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.chain)
        if questData ~= nil and questData.finish == QuestEumn.TaskStatus.Finish then
            QuestManager.Instance:Send10206(questData.id)
            return true
        end
    end
    return false
end

-- 检查是否是任务链的战斗任务，显示额外的按钮
function DialogModelDrama:CheckChainQuestFight(npcData)
    local base = nil
    if npcData.id == QuestManager.Instance.chainFightNpcId and npcData.battleid == 1 then
        local func = function(atask)
            for i,cp in ipairs(atask.progress) do
                local sp = atask.progress_ser
                if sp[i].finish ~= 1 then
                    return cp.cli_label
                end
            end
            return nil
        end
        local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.chain)
        local cli_label = func(questData)
        if questData ~= nil and questData.finish == QuestEumn.TaskStatus.Doing and cli_label == QuestEumn.CliLabel.fight then
            base = BaseUtils.copytab(DataUnit.data_unit[npcData.baseid])
            -- base.buttons = {}
            local fight_talk = DataQuestChain.data_plot[npcData.id].talk_fight
            base.plot_talk = fight_talk[math.random(1, #fight_talk)].talk_val
            local preval = string.format("(%s/%s)", QuestManager.Instance.round_chain, QuestManager.Instance.round_chain_max)
            local label = string.format("<color='%s'>[%s]%s</color>%s", QuestEumn.ColorName(questData.sec_type), QuestEumn.TypeName[questData.sec_type], questData.name, preval)
            table.insert(base.buttons, {button_id = DialogEumn.ActionType.action15, button_args = {1, 1, QuestManager.Instance.chainFightNpcId}, button_desc = label, button_show = ""})
            table.insert(base.buttons, {button_id = DialogEumn.ActionType.action15, button_args = {3, SosEumn.FuncType.Chain}, button_desc = TI18N("公会求援"), button_show = ""})
            table.insert(base.buttons, {button_id = DialogEumn.ActionType.action15, button_args = {2}, button_desc = TI18N("跳过战斗"), button_show = ""})
        end
    end
    return base
end

function DialogModelDrama:CheckGuidePetBook()
    if RoleManager.Instance.RoleData.lev >= 40 and self.currentNpcData.id == 3 and self.currentNpcData.battleid == 1
        and QuestManager.Instance.questTab[41558] ~= nil and QuestManager.Instance.questTab[41558].finish ~= QuestEumn.TaskStatus.Finish
    then
        return true
    end
    return false
end

-- 检查是否是游侠任务提交

function DialogModelDrama:CheckFineQuestCommit()
    if self.currentNpcData.id == 11 and self.currentNpcData.battleid == 1 then
        local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.fineType)
        if questData ~= nil and questData.finish == QuestEumn.TaskStatus.Finish and QuestManager.Instance.questStatsCanCommit == 1 then
            QuestManager.Instance:Send10206(questData.id)
            return true
        end
    end
    return false
end
