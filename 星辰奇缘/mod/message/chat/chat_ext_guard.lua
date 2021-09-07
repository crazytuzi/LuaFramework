-- --------------------------------
-- 聊天扩展界面--宠物
-- --------------------------------
ChatExtGuard = ChatExtGuard or BaseClass(ChatExtBase)

function ChatExtGuard:__init(gameObject, type)
    self.gameObject = gameObject
    self.gameObject.name = "ChatExtGuard"

    self.itemTab = {}
    self.currentPageCount = 1
    self.pageTab = {}
    self.type = type

    self:InitPanel()
end

function ChatExtGuard:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    self:InitPage(ShouhuManager.Instance.model.my_sh_list, 560, 6)
    if self.mainPanel ~= nil then
        self.mainPanel:UpdateToggleShow(self.pageMax)
        self.mainPanel:UpdateToggleIndex(self.currentPageCount)
    end
end

function ChatExtGuard:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function ChatExtGuard:GetItem(pageTransform)
    for i = 1, 6 do
        local item = pageTransform:GetChild(i - 1)
        local tab = {}
        tab["gameObject"] = item.gameObject
        tab["transform"] = item.transform
        tab["button"] = item.gameObject:GetComponent(Button)
        tab["levTxt"] = item:Find("TxtLev"):GetComponent(Text)
        tab["nameTxt"] = item:Find("TxtName"):GetComponent(Text)
        tab["select"] = item:Find("Img_Select").gameObject
        tab["headImg"] = item:Find("ImgHeadCon/ImgHead"):GetComponent(Image)
        tab["headImg"].gameObject:SetActive(true)
        table.insert(self.itemTab, tab)
        local index = #self.itemTab
        tab["button"].onClick:RemoveAllListeners()
        tab["button"].onClick:AddListener(function() self:ClickBtn(index) end)
    end
end

function ChatExtGuard:Refresh(list)
    local count = 0
    for i,guard in ipairs(list) do
        count = i
        local tab = self.itemTab[i]
        tab["guardData"] = guard
        tab["nameTxt"].text = guard.name
        tab["levTxt"].text = string.format(TI18N("等级:%s"), RoleManager.Instance.RoleData.lev)
        tab["headImg"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(guard.avatar_id))
        tab["match"] = string.format("%%[%s%%]", guard.name)
        tab["append"] = string.format("[%s]", guard.name)
        tab["send"] = string.format("{guard_2,%s}", guard.base_id)
        tab["gameObject"]:SetActive(true)
    end
    -- 多出来的隐藏
    local allLen = #self.itemTab
    for i = count + 1, allLen do
        local tab = self.itemTab[i]
        tab["gameObject"]:SetActive(false)
    end
end

function ChatExtGuard:ClickBtn(index)
    local tab = self.itemTab[index]
    local str = tab["append"]
    if str ~= nil and str ~= "" then
        ChatManager.Instance:Send10406(MsgEumn.CacheType.Guard, tab.guardData.base_id)
        local element = {}
        element.type = MsgEumn.AppendElementType.Guard
        element.id = tab.guardData.base_id
        element.base_id = tab.guardData.base_id
        element.cacheType = MsgEumn.CacheType.Guard
        element.showString = str
        element.sendString = tab["send"]
        element.matchString = tab["match"]

        ChatManager.Instance:AppendInputElement(element, self.type)
    end
end