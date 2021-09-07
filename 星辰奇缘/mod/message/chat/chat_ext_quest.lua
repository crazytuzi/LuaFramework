-- --------------------------------
-- 聊天扩展界面--任务
-- --------------------------------
ChatExtQuest = ChatExtQuest or BaseClass(ChatExtBase)

function ChatExtQuest:__init(gameObject, type)
    self.gameObject = gameObject
    self.gameObject.name = "ChatExtQuest"

    -- 用任务id做key
    self.itemTab = {}
    self.currentPageCount = 1
    self.pageTab = {}
    self.type = type

    self:InitPanel()
end

function ChatExtQuest:GetItem(pageTransform)
    for i = 1, 9 do
        local item = pageTransform:GetChild(i - 1)
        local tab = {}
        tab["gameObject"] = item.gameObject
        tab["transform"] = item.transform
        tab["button"] = item.gameObject:GetComponent(Button)
        tab["label"] = item.transform:Find("TxtLev"):GetComponent(Text)
        table.insert(self.itemTab, tab)
        local index = #self.itemTab
        tab["button"].onClick:RemoveAllListeners()
        tab["button"].onClick:AddListener(function() self:ClickBtn(index) end)
    end
end

function ChatExtQuest:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    local list = QuestManager.Instance:GetAll()
    local newList = {}
    for k,v in pairs(list) do
        if v.lev <= RoleManager.Instance.RoleData.lev then
            table.insert(newList, v)
        end
    end
    table.sort(newList, function(a,b) return a.id < b.id end)
    self:InitPage(newList, 560, 9)
    if self.mainPanel ~= nil then
        self.mainPanel:UpdateToggleShow(self.pageMax)
        self.mainPanel:UpdateToggleIndex(self.currentPageCount)
    end
end

function ChatExtQuest:Refresh(list)
    local count = 0
    for i,quest in ipairs(list) do
        count = i
        local tab = self.itemTab[i]
        tab["label"].text = string.format("%s-%s", QuestEumn.TypeName[quest.sec_type], quest.name)
        tab["match"] = string.format("%%[%s%%-%s%%]", QuestEumn.TypeName[quest.sec_type], quest.name)
        tab["append"] = string.format("[%s-%s]", QuestEumn.TypeName[quest.sec_type], quest.name)
        tab["send"] = string.format("{quest_1,%s}", quest.id)
        tab["gameObject"]:SetActive(true)
    end
    -- 多出来的隐藏
    local allLen = #self.itemTab
    for i = count + 1, allLen do
        local tab = self.itemTab[i]
        tab["gameObject"]:SetActive(false)
    end
end

function ChatExtQuest:ClickBtn(index)
    local tab = self.itemTab[index]
    if self.type == MsgEumn.ExtPanelType.Chat then
        ChatManager.Instance:SendMsg(ChatManager.Instance:CurrentChannel(), tab["send"])
    elseif self.type == MsgEumn.ExtPanelType.Friend then
        FriendManager.Instance.model:SendQuest(tab["send"], self.type)
    elseif self.type == MsgEumn.ExtPanelType.Group then
        FriendManager.Instance.model:SendQuest(tab["send"], self.type)
    end
end