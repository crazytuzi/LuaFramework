QuestKingItem = QuestKingItem or BaseClass()

function QuestKingItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    self.seroll = self.transform:Find("Img").gameObject
    self.open = self.transform:Find("Open").gameObject
    self.lock = self.transform:Find("Lock").gameObject
    self.resultSucc = self.transform:Find("ResultSucc").gameObject
    self.resultFail = self.transform:Find("ResultFail").gameObject
    self.notify = self.transform:Find("Notify").gameObject

    self.notify:SetActive(false)
    self.transform:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
end

function QuestKingItem:__delete()
    self.clickFunc = nil
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.canGetEffect ~= nil then
        self.canGetEffect:DeleteMe()
        self.canGetEffect = nil
    end
end

function QuestKingItem:SetRed(bool)
    self.notify:SetActive(bool)
end

function QuestKingItem:SetData(stage, envelop)
    self.envelop = envelop
    self.stage = stage

    if self.canGetEffect ~= nil then
        self.canGetEffect:SetActive(false)
    end
    self.open:SetActive(false)
    self.seroll:SetActive(false)
    self.resultSucc:SetActive(false)
    self.resultFail:SetActive(false)
    self.lock:SetActive(true)
    self.notify:SetActive(false)
    self.transform.anchoredPosition = Vector2(self.transform.anchoredPosition.x, 0)

    if self.model.finishTab[envelop] ~= nil then
        self.open:SetActive(true)
        if self.model.finishTab[envelop].status == 1 then
            self.resultSucc:SetActive(true)
        else
            self.resultFail:SetActive(true)
        end
        self.lock:SetActive(false)
    elseif #self.model.currentList ~= 0 and self.model.currentList[1].envelop == envelop then
        self.open:SetActive(true)
        self.lock:SetActive(false)
        self.transform.anchoredPosition = Vector2(self.transform.anchoredPosition.x, 5)

        local questData = QuestManager.Instance:GetQuest(self.model.currentList[1].quest_id)

        if questData.finish == QuestEumn.TaskStatus.Finish then
            self.notify:SetActive(true)
            if self.canGetEffect ~= nil then
                self.canGetEffect:SetActive(true)
            else
                self.canGetEffect = BibleRewardPanel.ShowEffect(20391, self.transform, Vector3(0.55, 0.55, 1), Vector3(-1, 1, 0))
            end
        end
    elseif self.model.stage < stage then
        self.seroll:SetActive(true)
    else
        self.seroll:SetActive(true)
        self.lock:SetActive(false)
    end

    if (#self.model.currentList == 0 and self.model.stage >= stage and self.model.finishTab[envelop] == nil) or (self.model.finishTab[envelop] == nil and #self.model.currentList ~= 0 and self.model.currentList[1].envelop == envelop) then
        self:Float()
    else
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
    end
end

function QuestKingItem:OnClick()
    -- self:Unlock()
    if self.envelop ~= nil then
        if self.model.finishTab[self.envelop] ~= nil then
            -- NoticeManager.Instance:FloatTipsByString(TI18N("!!!!!!!!!!!!!!!!!!!!!!!"))
            return
        end

        if #self.model.currentList ~= 0 and self.model.currentList[1].envelop == self.envelop then
            local questData = QuestManager.Instance:GetQuest(self.model.currentList[1].quest_id)
            if questData.finish == QuestEumn.TaskStatus.Finish then
                if questData.progress ~= nil and #questData.progress == 0 then
                    -- 拜访任务提交
                    WindowManager.Instance:CloseCurrentWindow()
                    QuestManager.Instance.model:FindNpc(BaseUtils.get_unique_npcid(questData.npc_commit_id, questData.npc_commit_battle))
                else
                    -- 完成直接提交
                    QuestManager.Instance:Send10206(questData.id)
                end
                return
            end
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.quest_king_scroll_mark, {self.envelop})
        else
            self.model.selectEnvelop = self.envelop
            QuestKingManager.Instance:send10211(self.envelop)
        end
    end
end

function QuestKingItem:Unlock()
    self.lock:SetActive(false)
    if self.effect ~= nil then
        self.effect:DeleteMe()
    end
    self.effect = BibleRewardPanel.ShowEffect(20390, self.transform, Vector3(0.5,0.5), Vector3(0, 0, 0))
end

function QuestKingItem:Float()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.counter = 0
    self.timerId = LuaTimer.Add(0, 22, function()
        self.counter = self.counter + 0.2
        self.transform.anchoredPosition = Vector2(self.transform.anchoredPosition.x, 3 * math.sin(self.counter))
    end)
end
