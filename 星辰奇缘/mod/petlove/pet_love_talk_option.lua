-- ----------------------------
-- 剧情对话，兼容任务npc对话处理
-- hosr
-- ----------------------------
PetLoveTalkOption = PetLoveTalkOption or BaseClass()

function PetLoveTalkOption:__init(mainPanel)
    self.mainPanel = mainPanel

    -- 预创建的按钮
    self.buttons = {}
    -- 使用的数量
    self.useCount = 0

    -- 不显示按钮
    self.noButton = false

    self.effectPath = "prefabs/effect/20107.unity3d"
    self.effect = nil
end

function PetLoveTalkOption:__delete()
end

function PetLoveTalkOption:InitPanel(gameObject)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.titleTxt = self.transform:Find("Title"):GetComponent(Text)
    local container = self.transform:Find("Buttons")
    for i = 1, 5 do
        local tab = {}
        local btn = container:GetChild(i - 1)
        tab["transform"] = btn
        tab["gameObject"] = btn.gameObject
        tab["label"] = btn:Find("Text"):GetComponent(Text)
        tab["label"].fontSize = 18
        tab["rect"] = tab["label"].gameObject:GetComponent(RectTransform)
        tab["msgItemExt"] = MsgItemExt.New(tab["label"], 240, 18, 23)
        tab["button"] = btn.gameObject:GetComponent(Button)
        table.insert(self.buttons, tab)
    end
    self.gameObject:SetActive(false)
end

function PetLoveTalkOption:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
    self.noButton = false
end

function PetLoveTalkOption:Show(option)
    self.noButton = false
    self.special = false
    self.useCount = 0
    local npcData = option.base
    local tasks = option.tasks

    local ok = self:ShowOption(npcData, tasks)

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

function PetLoveTalkOption:ShowOption(base, tasks)
    self.base = base
    self:DoButtons(base.buttons)
    return true
end

function PetLoveTalkOption:DoButtons(buttons)
    for i,v in ipairs(buttons) do

        self.useCount = self.useCount + 1
        local action = v.button_id
        local args = v.button_args
        local rule = v.button_show

        local tab = self.buttons[self.useCount]
        tab["gameObject"]:SetActive(true)
        if tab["msgItemExt"] ~= nil then
            tab["msgItemExt"]:Reset()
        end
        tab["label"].text = v.button_desc
        if action == DialogEumn.ActionType.action3 then
            local val = QuestManager.Instance.time_cycle_max - QuestManager.Instance.time_cycle + 1
            if (QuestManager.Instance.time_cycle == QuestManager.Instance.time_cycle_max and QuestManager.Instance.round_cycle == 10) or QuestManager.Instance.time_cycle == 0 then
                val = 0
            end
            val = val >= 0 and val or 0
            if val == 0 then
                tab["label"].text = TI18N("今日已完成")
            else
                tab["label"].text = string.format(TI18N("%s<color='#66ff00'>(今日剩余%s轮)</color>"), v.button_desc, val)
            end
        elseif action == DialogEumn.ActionType.action31 then
            local num = 10 - DataAgenda.data_list[1011].engaged
            if num == 0 then
                tab["msgItemExt"]:SetData(TI18N("今日宝图已兑换"))
            else
                local star_gold = RoleManager.Instance.RoleData.star_gold
                if star_gold == 0 then
                    tab["msgItemExt"]:SetData(string.format(TI18N("兑换宝图({assets_1,90002,%s}兑%s张)"), num * tonumber(args[1]), num))
                elseif star_gold < num * tonumber(args[1]) then
                    tab["msgItemExt"]:SetData(string.format(TI18N("兑换宝图({assets_1,29255,%s}兑%s张)"), num * tonumber(args[1]), num))
                else
                    tab["msgItemExt"]:SetData(string.format(TI18N("兑换宝图({assets_1,90026,%s}兑%s张)"), num * tonumber(args[1]), num))
                end
            end
        elseif action == DialogEumn.ActionType.action37 then
            --参加活动，便捷组队，开始任务
            if PetLoveManager.Instance.model.pet_love_status_data.phase == 2 or PetLoveManager.Instance.model.pet_love_status_data.phase == 3 then
                if PetLoveManager.Instance.model.has_finish == 1 then
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
        elseif action == DialogEumn.ActionType.action15 and #args == 0 then
            local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.chain)
            if questData ~= nil then
                local preval = string.format("(%s/%s)", QuestManager.Instance.round_chain, QuestManager.Instance.round_chain_max)
                tab["label"].text = string.format("<color='%s'>[%s]%s</color>%s", QuestEumn.ColorName(questData.sec_type), QuestEumn.TypeName[questData.sec_type], questData.name, preval)
            end
        end

        tab["button"].onClick:RemoveAllListeners()
        tab["button"].onClick:AddListener(function() self:ClickOptionButton(action, args, rule) end)

        local w = tab["label"].preferredWidth
        local h = tab["label"].preferredHeight
        tab["rect"].sizeDelta = Vector2(w, h)
        tab["rect"].anchoredPosition = Vector2.zero

        -- 处理显示条件
        if action == DialogEumn.ActionType.action3 then
            local npc = self.cycle_npcs[RoleManager.Instance.RoleData.classes]
            if self.base.id ~= npc then
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
        end
    end
end

function PetLoveTalkOption:Layout()
    for i,tab in ipairs(self.buttons) do
        if i > self.useCount then
            tab["gameObject"]:SetActive(false)
        else
            tab["transform"].localPosition = Vector3(0, -(i - 1) * 48, 0)
            tab["gameObject"]:SetActive(true)
        end
    end
    self.rect.sizeDelta = Vector2(290, 90 + 48 * self.useCount)
    if self.useCount > 0 then
        self.gameObject:SetActive(true)
    else
        self.gameObject:SetActive(false)
    end
end

function PetLoveTalkOption:ClickOptionButton(action, args, rule)
    self.mainPanel.model:ButtonAction(action, args, rule)
    if self.effect ~= nil then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end
end