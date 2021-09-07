-- --------------------------------
-- 聊天扩展界面--自定义常用语句
-- hosr
-- --------------------------------
ChatExtCustom = ChatExtCustom or BaseClass()

function ChatExtCustom:__init(gameObject,type)
    self.gameObject = gameObject

    self.showItemTab = {}
    self.editItemTab = {}
    self.type = type
    self.pageMax = 1
    self.currentPageCount = 1

    self:InitPanel()
end

function ChatExtCustom:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function ChatExtCustom:InitPanel()
    self.transform = self.gameObject.transform
    self.gameObject.name = "ChatExtCustom"

    -- 正常显示
    self.normal = self.transform:Find("Container").gameObject
    -- 编辑模式
    self.editor = self.transform:Find("ContentEdit").gameObject

    local normalTransform = self.normal.transform
    for i = 1, 8 do
        local item = normalTransform:Find(string.format("Item%s", i))
        local tab = {}
        local index = i
        tab["gameObject"] = item.gameObject
        tab["transform"] = item.transform
        tab["button"] = item.gameObject:GetComponent(Button)
        tab["label"] = tab["button"].gameObject.transform:Find("TxtLev"):GetComponent(Text)
        tab["index"] = index
        table.insert(self.showItemTab, tab)

        local str = PlayerPrefs.GetString(string.format("ChatCustom%s", index))
        if str == nil or str == "" then
            local data = DataChat.data_get_chat_quick_data[index]
            if data ~= nil then
                str = data.msg
            end
        end
        tab["label"].text = str or TI18N("未定义")

        tab["button"].onClick:AddListener(function() self:ClickShowItem(index) end)
    end
    normalTransform:Find("EditBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickEdit() end)

    local editorTransform = self.editor.transform
    for i = 1, 8 do
        local item = editorTransform:Find(string.format("InputCon%s", i))
        local tab = {}
        local index = i
        tab["gameObject"] = item.gameObject
        tab["transform"] = item.transform
        local inputField = item:Find("InputField"):GetComponent(InputField)
        inputField.textComponent = inputField.gameObject.transform:Find("Text").gameObject:GetComponent(Text)
        inputField.placeholder = inputField.gameObject.transform:Find("Placeholder").gameObject:GetComponent(Graphic)
        tab["input"] = inputField
        tab["index"] = index
        table.insert(self.editItemTab, tab)
    end
    editorTransform:Find("SaveBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickSave() end)
end

function ChatExtCustom:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    if self.mainPanel ~= nil then
        self.mainPanel:UpdateToggleShow(self.pageMax)
        self.mainPanel:UpdateToggleIndex(self.currentPageCount)
    end
end

function ChatExtCustom:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

-- 点击编辑按钮，打开编辑
function ChatExtCustom:ClickEdit()
    self.normal:SetActive(false)
    self.editor:SetActive(true)
    self:RefreshEditor()
end

-- 点击保存，回到正常
function ChatExtCustom:ClickSave()
    self.normal:SetActive(true)
    self.editor:SetActive(false)
    self:RefreshNormal()
end

-- 刷新下正常显示内容
function ChatExtCustom:RefreshNormal()
    for i,tab in ipairs(self.editItemTab) do
        local showTab = self.showItemTab[i]
        showTab["label"].text = tab["input"].text
        PlayerPrefs.SetString(string.format("ChatCustom%s", i), tab["input"].text)
    end
end

-- 刷新下编辑显示内容
function ChatExtCustom:RefreshEditor()
    for i,tab in ipairs(self.showItemTab) do
        local editTab = self.editItemTab[i]
        editTab["input"].text = tab["label"].text
    end
end

-- 点击展示项，输入对应内容
function ChatExtCustom:ClickShowItem(index)
    local tab = self.showItemTab[index]
    if tab ~= nil then
        local str = tab["label"].text
        if str ~= TI18N("未定义") then
            local element = {}
            element.type = MsgEumn.AppendElementType.String
            element.showString = str
            element.sendString = str
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
end