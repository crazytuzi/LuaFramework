-- -----------------
-- 对话框任务
-- hosr
-- -----------------
DialogQuest = DialogQuest or BaseClass(BasePanel)

function DialogQuest:__init(main, gameObject)
    self.main = main
    self.gameObject = gameObject
    self.transform = self.gameObject.transform

    self.special = false
    self.currentQuest = nil
    self.itemCellTab = {}

    self:InitPanel()
end

function DialogQuest:__delete()
    self.special = false
    self.currentQuest = nil
    self.itemCellTab = {}
end

function DialogQuest:InitPanel()
    self.taskName = self.transform:Find("Name"):GetComponent(Text)
    self.taskContent = self.transform:Find("Content"):GetComponent(Text)
    self.taskAwardContainer = self.transform:Find("AwardContainer").gameObject
    self.taskBtn = self.transform:Find("Button"):GetComponent(Button)
    self.taskBtnTxt = self.transform:Find("Button/Text"):GetComponent(Text)

    self.taskBtn.onClick:AddListener(function() self:ClickTaskButton() end)
end

function DialogQuest:ShowQuest(task)
    self.special = false
    if task.finish == 2 and task.sec_type == QuestEumn.TaskType.cycle then
        --所有职业任务可提交都不打开对话框，直接提交
        QuestManager.Instance:Send10206(task.id)
        self.special = true
        return true
    end

    self.currentQuest = task

    self.taskName.text = string.format("<color='%s'>[%s]%s</color><color='%s'>%s</color>", QuestEumn.ColorNameDialog(task.sec_type), QuestEumn.TypeName[task.sec_type], task.name, ColorHelper.color[1], QuestEumn.StateName[task.finish + 1])

    if #task.progress == 0 then
        if task.trace_msg ~= "" then
            self.taskContent.text = task.trace_msg
        else
            local npc = DataUnit.data_unit[task.npc_commit].name
            self.taskContent.text = string.format(TI18N(" 拜访<color='#287d2c'>%s</color>"), npc)
        end
    else
        local str = ""
        for i,v in ipairs(task.progress) do
            if i > 1 and i < #task.progress then
                -- 处理文本换行，避免多换行导致高度错误
                str = str .. "\n"
            end
            if v.is_hide == 0 then
                local preval = string.format("(%d/%d)", task.progress_ser == nil and 0 or task.progress_ser[i].value, v.target_val)
                if v.desc == nil or v.desc == "[]" then
                    local target_id = v.target
                    if task.progress_ser ~= nil and task.progress_ser[i] ~= nil then
                        target_id = task.progress_ser[i].target
                    end
                    local tar_name = QuestManager.Instance.GetTargetByLabel(v.cli_label, target_id)
                    str = string.format("%s%s", QuestEumn.RequireName[v.cli_label], tar_name)
                else
                    str = StringHelper.MatchBetweenSymbols(v.desc, "%[", "%]")[1]
                end
            end
        end
        self.taskContent.text = string.format("%s<color='%s'>%s</color>", str, ColorHelper.color[1], preval)
    end

    self:ShowAward(task.rewards_commit)

    if task.finish == 2 then --可提交
        self.main:ShowContent(string.gsub(QuestEumn.FilterContent(task.talk_commit), "%[role%]", RoleManager.Instance.RoleData.name))
        self.taskBtnTxt.text = TI18N("领取奖励")
    elseif task.finish == 0 then --可接受
        self.main:ShowContent(string.gsub(QuestEumn.FilterContent(task.talk_accpet), "%[role%]", RoleManager.Instance.RoleData.name))
        self.taskBtnTxt.text = TI18N("接受任务")
    elseif task.finish == 1 then --进行任务
        self.main:ShowContent(string.gsub(QuestEumn.FilterContent(task.talk_commit), "%[role%]", RoleManager.Instance.RoleData.name))
        self.taskBtnTxt.text = TI18N("前往任务")
    end

    self.gameObject:SetActive(true)
    return true
end

function DialogQuest:ShowAward(awards)
    for _,cell in ipairs(self.itemCellTab) do
        cell.gameObject:SetActive(false)
    end
    local count = 0
    for i,v in ipairs(awards) do
        local item = QuestEumn.AwardItemInfo(v)
        if item ~= nil then
            local baseid = item.baseid
            local count = item.count
            local bind = item.bind

            local item = BackpackManager.Instance:GetItemBase(baseid)
            item.quantity = count
            item.bind = bind

            local cell = self.itemCellTab[i]
            if cell == nil then
                cell = ItemSlot.New()
                local trans = cell.gameObject.transform
                trans:SetParent(self.taskAwardContainer.transform)
                trans.localScale = Vector3.one
                table.insert(self.itemCellTab, cell)
            end
            cell:SetAll(item)
            cell.transform.localPosition = Vector3(32 + count * 70, 0, 0)
            cell.gameObject:SetActive(true)
            count = count + 1
        end
    end
end

function DialogQuest:ClickTaskButton()
    if self.currentQuest.finish == 2 then
        -- 提交
        QuestManager.Instance:Send10206(self.currentQuest.id)
    elseif self.currentQuest.finish == 0 then
        -- 接取
        QuestManager.Instance:Send10202(self.currentQuest.id)
    elseif self.currentQuest.finish == 1 then
        -- 前往
        QuestManager.Instance.DoQuest(self.currentQuest)
    end
    self.main:Hiden()
end