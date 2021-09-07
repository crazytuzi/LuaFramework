MainuiTraceNationalDay = MainuiTraceNationalDay or BaseClass()

local GameObject = UnityEngine.GameObject

function MainuiTraceNationalDay:__init(main)
    self.main = main
    self.isInit = false

    self.resList = {
        {file = AssetConfig.nationalday_content, type = AssetType.Main}
    }

    self.name = nil
    self.desc = nil
    self.clockTime = nil
    self.exitbtn = nil
    self.Point = nil
    self.LevMask = nil
    self.buffinfo = nil

    self._Update = function() self:Update() end
    self.endFightThenAutoGoOn = function ()
        self:autoGoOnFun()
    end
    self.initData = false
    self.selfRoleLoaded = function()
        if self.initData == false then
            self.initData = true
            -- print("----22222222222---------"..debug.traceback())
            self:Update()
        end
    end
    self.isFirstCircle = true

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceNationalDay:__delete()
    self.OnHideEvent:Fire()
end

function MainuiTraceNationalDay:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationalday_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    self.name = self.transform:FindChild("Panel/Name"):GetComponent(Text)
    self.desc = self.transform:FindChild("Panel/Desc"):GetComponent(Text)
	self.clockTime = self.transform:FindChild("Panel/Time"):GetComponent(Text)
    self.Point = self.transform:FindChild("Panel/taskItem2/point")
    self.LevMask = self.transform:FindChild("Panel/taskItem2/Mask")

    self.exitbtn = self.transform:Find("Panel/GiveUP/Button")
    self.exitbtn:GetComponent(Button).onClick:AddListener(function() NationalDayManager.Instance:Send14083() end)
   	self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:goto_target_unit() end)
    self.isInit = true

    self.levPointX = {
        [0] = -90,
        [1] = -35,
        [2] = 20,
        [3] = 90,
    }

    self.barW =
    {
        [0] = 40,
        [1] = 95,
        [2] = 152,
        [3] = 222
    }
end

function MainuiTraceNationalDay:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceNationalDay:autoGoOnFun()
    local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.defensecake)
    if questData ~= nil then
        QuestManager.Instance:DoQuest(questData)
    end
end

function MainuiTraceNationalDay:OnShow()
    self:RemoveListeners()

    EventMgr.Instance:AddListener(event_name.nationalday_defense_update, self._Update)
    EventMgr.Instance:AddListener(event_name.quest_update, self._Update)
    EventMgr.Instance:AddListener(event_name.buff_update, self._Update)
    EventMgr.Instance:AddListener(event_name.end_fight, self.endFightThenAutoGoOn)
    EventMgr.Instance:AddListener(event_name.self_loaded, self.selfRoleLoaded)

    NationalDayManager.Instance:Send14081()
    self:Update()
end

function MainuiTraceNationalDay:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.nationalday_defense_update, self._Update)
    EventMgr.Instance:RemoveListener(event_name.quest_update, self._Update)
    EventMgr.Instance:RemoveListener(event_name.buff_update, self._Update)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.endFightThenAutoGoOn)
    EventMgr.Instance:RemoveListener(event_name.self_loaded, self.selfRoleLoaded)
end

function MainuiTraceNationalDay:OnHide()
    self:RemoveListeners()
end

function MainuiTraceNationalDay:Update()
    local currfigure = QuestManager.Instance.round_defensecake - 1
    self.Point.localPosition = Vector3(self.levPointX[currfigure], 0, 0)
    self.LevMask.sizeDelta = Vector2(self.barW[currfigure], 29)

    local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.defensecake)
    if questData == nil then
        --print("没有找到保卫蛋糕任务数据"..debug.traceback())
        return
    end

    self.questData = questData

    if NationalDayManager.Instance.isSelfLoaded == false then
        -- print("----11111111---------"..debug.traceback())
        return
    end

    QuestManager.Instance.model:CreateDefenseCakeNpc(questData)

    local content = ""
    local len = #questData.progress
    local ccount = 0
    if len == 0 then
        if questData.trace_msg ~= "" then
            content = questData.trace_msg
        else
            local npc = ""
            if questData.finish == QuestEumn.TaskStatus.CanAccept then--可接
                if questData.npc_accept ~= 0 then
                    npc = DataUnit.data_unit[questData.npc_commit].name
                end
            elseif questData.finish == QuestEumn.TaskStatus.Doing then-- 进行中
                if questData.npc_commit ~= 0 then
                    npc = DataUnit.data_unit[questData.npc_commit].name
                end
            elseif questData.finish == QuestEumn.TaskStatus.Finish then -- 完成
                if questData.sec_type == QuestEumn.TaskType.chain then
                    local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
                    if npcData ~= nil then
                        npc = npcData.name
                    end
                else
                    if questData.npc_commit ~= 0 then
                        npc = DataUnit.data_unit[questData.npc_commit].name
                    end
                end
            end
            content = string.format(TI18N("拜访<color='#00ff12'>%s</color>"), npc)
        end
    else
        for i,v in ipairs(questData.progress) do
            -- 标志某些任务内容为战斗内容
            if v.cli_label == QuestEumn.CliLabel.fight or v.cli_label == QuestEumn.CliLabel.patrol then
                isfight = true
            elseif v.cli_label == QuestEumn.CliLabel.gain then
                isItem = true
            end
            -- 有些任务进度隐藏不显示
            if v.is_hide == 0 then
                ccount = ccount + 1
                if ccount > 1 and ccount < len then
                    -- 处理文本换行，避免多换行导致高度错误
                    content = content .. "\n"
                end
                local preval = ""
                if v.target_val > 1 then
                    preval = string.format("<color='#00ff12'>(%d/%d)</color>", (questData.progress_ser ~= nil and questData.progress_ser[i] ~= nil) and questData.progress_ser[i].value or 0, v.target_val)
                end
                if v.desc == nil or v.desc == "[]" then

                else
                    content = content .. string.format("%s%s", StringHelper.MatchBetweenSymbols(v.desc, "%[", "%]")[1], preval)
                end
            end
        end
    end

    self.desc.text = content

    -- self.clockTime.gameObject:SetActive(false)
    -- if self.timerId ~= nil then
    --     LuaTimer.Delete(self.timerId)
    -- end

    -- self.buffinfo = nil
    -- for _,questData in ipairs(DataCampCake.data_quest_list) do
    --     for i,v in ipairs(questData.buff) do--取任务的buff列表，只要有一个buffid检测到存在 就表明有幻化
    --         local buffinfo = BuffPanelManager.Instance.model.buffDic[v[1]]
    --         if buffinfo ~= nil then
    --             self.buffinfo = buffinfo
    --             self:DoCountDown()
    --             break
    --         end
    --     end

    --     if self.buffinfo then
    --         break
    --     end
    -- end
end

function MainuiTraceNationalDay:goto_target_unit()
    local defenseQuestData = NationalDayManager.Instance.model.defenseQuestData

    local remainCount = 0
    if defenseQuestData ~= nil then
        for i,v in ipairs(defenseQuestData) do
            if v.status == 0 then
                remainCount = remainCount + 1
            end
        end
    end

    if remainCount > 0 then
        NationalDayManager.Instance.model:InitDefenseQuestionUI()
    else
        if self.questData ~= nil then
            QuestManager.Instance:DoQuest(self.questData)
        end
    end
end

function MainuiTraceNationalDay:DoCountDown()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(0, 1000, function(id) self:RefreshNextTime(id) end)
end

function MainuiTraceNationalDay:RefreshNextTime(id)
    local time = self.buffinfo.duration - BaseUtils.BASE_TIME + self.buffinfo.start_time
    local msg = "00:00"

    if time > 0 then
        self.clockTime.gameObject:SetActive(true)
        msg = os.date("%M:%S", time)
    else
        self.clockTime.gameObject:SetActive(false)
        LuaTimer.Delete(self.timerId)
    end
    self.clockTime.text = msg
end
