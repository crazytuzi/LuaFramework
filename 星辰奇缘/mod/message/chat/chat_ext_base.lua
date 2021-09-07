-- --------------------------------
-- 聊天扩展界面--基类
-- hosr
-- --------------------------------
ChatExtBase = ChatExtBase or BaseClass()

function ChatExtBase:__init(gameObject, type, otherOption)
    self.gameObject = gameObject
    self.gameObject.name = "ChatExtBase"
    self.otherOption = otherOption
    self.itemTab = {}
    self.pageMax = 1
    self.currentPageCount = 1
    self.pageTab = {}
    self.type = type
    self:InitPanel()
    self.gameObject:SetActive(false)
    self.mainPanel = nil
    self.guide = nil
end

function ChatExtBase:__delete()
    if self.guide ~= nil then
        self.guide:DeleteMe()
        self.guide = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
end

function ChatExtBase:InitPanel()
    self.transform = self.gameObject.transform

    self.container = self.transform:Find("Container").gameObject
    self.rect = self.container:GetComponent(RectTransform)
    self.pageBase = self.container.transform:Find("ItemPage").gameObject
    self.pageBase:SetActive(false)
    self.pageTab = {self.pageBase}
    local pageTransform = self.pageBase.transform
    self:GetItem(pageTransform)
end

-- 外部重写
function ChatExtBase:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    -- self:InitPage(PetManager.Instance:Get_PetList(), 480, 5)
end

function ChatExtBase:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

-- 外部重写
function ChatExtBase:GetItem(pageTransform)
end

function ChatExtBase:InitPage(list, width, num)
    local len = #list
    local page = math.ceil(len / num)
    local len = #self.pageTab
    for i = 1, len do
        if i < self.currentPageCount - 1 or i > self.currentPageCount + 1 then
            self.pageTab[i]:SetActive(false)
        else
            self.pageTab[i]:SetActive(true)
        end
        -- if i <= page then
        --     self.pageTab[i]:SetActive(true)
        -- else
        --     self.pageTab[i]:SetActive(false)
        -- end
    end
    local newLen = page - len
    for i = 1, newLen do
        local newPage = GameObject.Instantiate(self.pageBase)
        local transform = newPage.transform
        transform:SetParent(self.container.transform)
        transform.localScale = Vector3.one
        transform.localPosition = Vector3(i * width, 0, 0)
        newPage:SetActive(true)
        self:GetItem(newPage.transform)
        table.insert(self.pageTab, newPage)
        if i >= 3 then
            newPage:SetActive(false)
        end
    end

    if self.tabbedPanel == nil then
        self.tabbedPanel = TabbedPanel.New(self.gameObject, page, width)
        self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnMoveEnd(currentPage, direction) end)
    else
        self.tabbedPanel:SetPageCount(page)
    end
    self.rect.sizeDelta = Vector2(page * width, 270)

    self.pageMax = page

    self:Refresh(list)
end

-- 外部重写
function ChatExtBase:Refresh(list)
end

function ChatExtBase:ClickBtn(index)
    local tab = self.itemTab[index]
    local str = tab["append"]
    if str ~= nil and str ~= "" then
        local element = {}
        element.showString = str
        element.sendString = tab["send"]
        element.matchString = tab["match"]
        if self.type == MsgEumn.ExtPanelType.Chat then
            ChatManager.Instance.model:AppendInputElement(element)
        elseif self.type == MsgEumn.ExtPanelType.Friend then
            FriendManager.Instance.model:AppendInputElement(element)
        elseif self.type == MsgEumn.ExtPanelType.Friend then
            self.otherOption.parent:AppendInputElement(element)
        end
    end
end

function ChatExtBase:OnMoveEnd(currentPage, direction)
    if self.pageTab[currentPage - 2] ~= nil then
        self.pageTab[currentPage - 2]:SetActive(false)
    end
    if self.pageTab[currentPage - 1] ~= nil then
        self.pageTab[currentPage - 1]:SetActive(true)
    end
    if self.pageTab[currentPage] ~= nil then
        self.pageTab[currentPage]:SetActive(true)
    end
    if self.pageTab[currentPage + 1] ~= nil then
        self.pageTab[currentPage + 1]:SetActive(true)
    end
    if self.pageTab[currentPage + 2] ~= nil then
        self.pageTab[currentPage + 2]:SetActive(false)
    end

    self.currentPageCount = currentPage
    if self.mainPanel ~= nil then
        if self.gameObject.name ~= "ChatExtHonor" then
            self.mainPanel:UpdateToggleIndex(currentPage)
        end
    end
end