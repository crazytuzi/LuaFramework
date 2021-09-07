QuestKingProgressLevel = QuestKingProgressLevel or BaseClass()

function QuestKingProgressLevel:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject

    self.questList = {}
    self.slotList = {}

    self:InitPanel()
end

function QuestKingProgressLevel:__delete()
    if self.questList ~= nil then
        for _,v in ipairs(self.questList) do
            v:DeleteMe()
        end
    end
    if self.slotList ~= nil then
        for _,v in pairs(self.slotList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.data:DeleteMe()
            end
        end
    end
    if self.rewardLayout ~= nil then
        self.rewardLayout:DeleteMe()
        self.rewardLayout = nil
    end
end

function QuestKingProgressLevel:InitPanel()
    self.transform = self.gameObject.transform

    local t = self.transform
    local container = t:Find("QuestList")
    for i=1,container.childCount do
        self.questList[i] = QuestKingItem.New(self.model, container:GetChild(i - 1).gameObject)
    end

    self.rewardLayout = LuaBoxLayout.New(t:Find("Reward/Container"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 5})
    self.titleText = t:Find("Reward/RrewardTitle/Text"):GetComponent(Text)
    self.progressText = t:Find("Reward/RrewardTitle/Progress"):GetComponent(Text)
    self.questBtn = t:Find("QuestBg"):GetComponent(Button)

    self.questBtn.onClick:AddListener(function() self:OnNotice() end)
end

function QuestKingProgressLevel:SetRewardData(stage)
    local list = QuestKingManager.RewardFilter(DataQuestKing.data_stage[stage].item_reward)

    if self.rewardEffectTab == nil then
        self.rewardEffectTab = {}
        local tab = StringHelper.Split(DataQuestKing.data_stage[stage].effect_item, ",")
        if tab ~= nil then
            for _,v in pairs(tab) do
                if v ~= nil and v ~= "" then
                    self.rewardEffectTab[tonumber(v)] = 1
                end
            end
        end
    end
    self.rewardLayout:ReSet()
    for i,v in ipairs(list) do
        if self.slotList[i] == nil then
            self.slotList[i] = {}
            self.slotList[i].slot = ItemSlot.New()
            self.slotList[i].data = ItemData.New()
        end
        self.slotList[i].data:SetBase(DataItem.data_get[v[1]])
        self.slotList[i].slot:SetAll(self.slotList[i].data, {inbag = false, nobutton = true})
        self.slotList[i].slot:SetNum(v[2])
        self.rewardLayout:AddCell(self.slotList[i].slot.gameObject)

        if self.rewardEffectTab[v[1]] ~= nil then
            if self.slotList[i].effect ~= nil then
                self.slotList[i].effect:SetActive(true)
            else
                self.slotList[i].effect = BibleRewardPanel.ShowEffect(20223, self.slotList[i].slot.transform, Vector3(1, 1, 1), Vector3(31, 0.5, -400))
            end
        else
            if self.slotList[i].effect ~= nil then
                self.slotList[i].effect:SetActive(false)
            end
        end
    end
    for i=#list + 1,#self.slotList do
        self.slotList[i].slot.gameObject:SetActive(false)
    end
end

function QuestKingProgressLevel:SetData(stage)
    self.stage = stage

    local count = 0
    for i,envelop in ipairs(DataQuestKing.data_envelop[stage]) do
        self.questList[i]:SetData(stage, envelop)
        if self.model.finishTab[envelop] ~= nil and self.model.finishTab[envelop].status == 1 then
            count = count + 1
        end
    end
    self.progressText.text = string.format(TI18N("进度:<color='#00ff00'>%s/%s</color>"), count, DataQuestKing.data_stage[stage].lock_count)
    self.titleText.text = DataQuestKing.data_stage[stage].reward_title
    self:SetRewardData(stage)
end

function QuestKingProgressLevel:Unlock()
    for _,v in ipairs(self.questList) do
        v:Unlock()
    end
end

function QuestKingProgressLevel:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.questBtn.gameObject, itemData = {DataQuestKing.data_stage[self.stage].quest_desc}})
end
