-- --------------------------------
-- 聊天扩展界面--历史
-- --------------------------------
ChatExtHistory = ChatExtHistory or BaseClass()

function ChatExtHistory:__init(gameObject, type)
    self.gameObject = gameObject

    self.itemTab = {}
    self.type = type

    -- 消息队列
    self.msgTab = {}
    self.pageMax = 1
    self.currentPageCount = 1

    self:InitPanel()
end

function ChatExtHistory:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function ChatExtHistory:InitPanel()
    self.transform = self.gameObject.transform
    self.gameObject.name = "ChatExtHistory"

    local content = self.transform:Find("Container")
    for i = 1, 9 do
        local item = content:Find(string.format("Item%s", i))
        local tab = {}
        local index = i
        tab["gameObject"] = item.gameObject
        tab["label"] = item:Find("TxtLev"):GetComponent(Text)
        tab["button"] = item.gameObject:GetComponent(Button)
        table.insert(self.itemTab, tab)
        tab["button"].onClick:AddListener(function() self:ClickBtn(index) end)

        local str = PlayerPrefs.GetString(string.format("ChatHistory%s", index))
        if str == nil then
            tab["gameObject"]:SetActive(false)
        else
            table.insert(self.msgTab, str)
        end
        str = str or ""
        tab["label"].text = str
    end
end

function ChatExtHistory:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    self:Refresh()
    if self.mainPanel ~= nil then
        self.mainPanel:UpdateToggleShow(self.pageMax)
        self.mainPanel:UpdateToggleIndex(self.currentPageCount)
    end
end

function ChatExtHistory:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function ChatExtHistory:ClickBtn(index)
    local tab = self.itemTab[index]
    local str = tab["label"].text
    if str ~= "" then
        local element = {}
        element.type = MsgEumn.AppendElementType.String
        element.showString = str
        element.sendString = str

        str = string.gsub(str, "%[", "%%[")
        str = string.gsub(str, "%]", "%%]")
        element.matchString = str

        ChatManager.Instance:AppendInputElement(element, self.type)

        -- if self.type == MsgEumn.ExtPanelType.Chat then
        --     ChatManager.Instance.model:AppendInputElement(element)
        -- elseif self.type == MsgEumn.ExtPanelType.Friend then
        --     FriendManager.Instance.model:AppendInputElement(element)
        -- end
        -- ChatManager.Instance.model:AppendInput(str)
    end
end

function ChatExtHistory:Refresh()
    for i,tab in ipairs(self.itemTab) do
        local str = ChatManager.Instance.inputHistoryTab[i]
        if str == nil then
            tab["label"].text = ""
            tab["gameObject"]:SetActive(false)
        else
            tab["label"].text = str
            tab["gameObject"]:SetActive(true)
        end
    end
end