-- --------------------------------
-- 聊天扩展界面--背包
-- --------------------------------
ChatExtBag = ChatExtBag or BaseClass()

function ChatExtBag:__init(gameObject, type)
    self.gameObject = gameObject
    self.gameObject.name = "ChatExtBag"

    self.itemTab = {}
    self.currentPageCount = 1
    self.pageTab = {}
    self.type = type
    self.pageMax = 1

    self:InitPanel()
    self.gameObject:SetActive(false)
end

function ChatExtBag:__delete()
    for i,v in ipairs(self.itemTab) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.itemTab = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
end

function ChatExtBag:InitPanel()
    self.transform = self.gameObject.transform

    self.container = self.transform:Find("Container").gameObject
    self.rect = self.container:GetComponent(RectTransform)
    self.pageBase = self.container.transform:Find("ItemPage").gameObject
    self.pageBase:SetActive(false)
    self.pageTab = {self.pageBase}
    local pageTransform = self.pageBase.transform
    self:GetItem(pageTransform)
end

function ChatExtBag:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    local list = {}
    for k,v in pairs(BackpackManager.Instance.itemDic) do
        table.insert(list, v)
    end
    table.sort(list, function(a,b) return a.pos < b.pos end)
    self:InitPage(list, 560, 18)

    if self.mainPanel ~= nil then
        self.mainPanel:UpdateToggleShow(self.pageMax)
        self.mainPanel:UpdateToggleIndex(self.currentPageCount)
    end
end

function ChatExtBag:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function ChatExtBag:GetItem(pageTransform)
    for i = 1, 18 do
        local item = pageTransform:GetChild(i - 1)
        local tab = ItemSlot.New(item.gameObject)
        table.insert(self.itemTab, tab)
        local index = #self.itemTab
        tab.click_self_call_back = function() self:ClickBtn(index) end
    end
end

function ChatExtBag:Refresh(list)
    local count = 0
    for i,itemData in ipairs(list) do
        count = i
        local tab = self.itemTab[i]
        tab:SetAll(itemData, {nobutton = true})
        tab["itemData"] = itemData
        tab["match"] = string.format("%%[%s%%]", itemData.name)
        tab["append"] = string.format("[%s]", itemData.name)
        tab["send"] = string.format("{item_2,%s,%s,%s}", itemData.base_id, itemData.bind, itemData.quantity)
        tab["gameObject"]:SetActive(true)
    end
    -- 多出来的隐藏
    local allLen = #self.itemTab
    for i = count + 1, allLen do
        local tab = self.itemTab[i]
        tab["gameObject"]:SetActive(false)
    end
end

function ChatExtBag:InitPage(list, width, num)
    local len = #list
    local page = math.ceil(len / num)
    local len = #self.pageTab
    for i = 1, len do
        if i <= page then
            self.pageTab[i]:SetActive(true)
        else
            self.pageTab[i]:SetActive(false)
        end
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
    end

    if self.tabbedPanel == nil then
        self.tabbedPanel = TabbedPanel.New(self.gameObject, page, width)
        self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnMoveEnd(currentPage, direction) end)
    else
        self.tabbedPanel:SetPageCount(page)
    end
    self.rect.sizeDelta = Vector2(page * width, 270)

    self:Refresh(list)

    self.pageMax = page
end

function ChatExtBag:ClickBtn(index)
    local tab = self.itemTab[index]
    local str = tab["append"]
    if str ~= nil and str ~= "" then
        ChatManager.Instance:Send10406(MsgEumn.CacheType.Item, tab.itemData.id)
        local element = {}
        element.type = MsgEumn.AppendElementType.Bag
        element.id = tab.itemData.id
        element.base_id = tab.itemData.base_id
        element.num = tab.itemData.quantity
        element.cacheType = MsgEumn.CacheType.Item
        element.showString = str
        element.sendString = tab["send"]

        local mstr = tab["match"]
        mstr = string.gsub(mstr, "%+", "%%+")
        element.matchString = mstr

        ChatManager.Instance:AppendInputElement(element, self.type)

        -- if self.type == MsgEumn.ExtPanelType.Chat then
        --     ChatManager.Instance.model:AppendInputElement(element)
        -- elseif self.type == MsgEumn.ExtPanelType.Friend then
        --     FriendManager.Instance.model:AppendInputElement(element)
        -- end
    end
end

function ChatExtBag:OnMoveEnd(currentPage, direction)
    self.currentPageCount = currentPage
    if self.mainPanel ~= nil then
        self.mainPanel:UpdateToggleIndex(currentPage)
    end
end