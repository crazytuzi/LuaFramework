-- --------------------------------
-- 聊天扩展界面--好友
-- --------------------------------
ChatExtFriend = ChatExtFriend or BaseClass(ChatExtBase)

function ChatExtFriend:__init(gameObject, type)
    self.gameObject = gameObject
    self.gameObject.name = "ChatExtFriend"

    self.itemTab = {}
    self.currentPageCount = 1
    self.pageTab = {}
    self.type = type

    self:InitPanel()
end

function ChatExtFriend:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    local list = {}
    for k,v in pairs(FriendManager.Instance.friend_List) do
        table.insert(list, v)
    end
    table.sort(list, function(a,b) return a.lev > b.lev end)
    self:InitPage(list, 560, 6)

    if self.mainPanel ~= nil then
        self.mainPanel:UpdateToggleShow(self.pageMax)
        self.mainPanel:UpdateToggleIndex(self.currentPageCount)
    end
end

function ChatExtFriend:GetItem(pageTransform)
    for i = 1, 6 do
        local item = pageTransform:GetChild(i - 1)
        local tab = {}
        tab["gameObject"] = item.gameObject
        tab["transform"] = item.transform
        tab["button"] = item.gameObject:GetComponent(Button)
        tab["nameTxt"] = item:Find("TxtName"):GetComponent(Text)
        tab["select"] = item:Find("Img_Select").gameObject
        tab["headImg"] = item:Find("ImgHeadCon/ImgHead"):GetComponent(Image)
        tab["levTxt"] = item:Find("ImgHeadCon/TxtLev"):GetComponent(Text)
        tab["sexImg"] = item:Find("ImgSex0"):GetComponent(Image)
        tab["classesImg"] = item:Find("ImgCareer"):GetComponent(Image)
        tab["classesTxt"] = item:Find("TxtCareer"):GetComponent(Text)
        tab["select"] = item:Find("Img_Select").gameObject
        tab["select"]:SetActive(false)
        tab["headImg"].gameObject:SetActive(true)
        table.insert(self.itemTab, tab)
        local index = #self.itemTab
        tab["button"].onClick:RemoveAllListeners()
        tab["button"].onClick:AddListener(function() self:ClickBtn(index) end)
    end
end

function ChatExtFriend:Refresh(list)
    local count = 1
    for i,friend in ipairs(list) do
        count = i
        local tab = self.itemTab[i]
        tab["nameTxt"].text = friend.name
        tab["headImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", friend.classes, friend.sex))
        tab["sexImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("IconSex%s", friend.sex))
        tab["classesImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(friend.classes))
        tab["classesTxt"].text = KvData.classes_name[friend.classes]
        tab["levTxt"].text = friend.lev
        tab["gameObject"]:SetActive(true)
        tab["match"] = string.format("%%[%s%%]", friend.name)
        tab["append"] = string.format("[%s]", friend.name)
        tab["send"] = string.format("{role_1,%s,%s,%s,%s}", friend.id, friend.platform, friend.zone_id, friend.name)
    end
    -- 多出来的隐藏
    local allLen = #self.itemTab
    for i = count + 1, allLen do
        local tab = self.itemTab[i]
        tab["gameObject"]:SetActive(false)
    end
end

function ChatExtFriend:ClickBtn(index)
    local tab = self.itemTab[index]
    local str = tab["append"]
    if str ~= nil and str ~= "" then
        local element = {}
        element.type = MsgEumn.AppendElementType.Friend
        element.showString = str
        element.sendString = tab["send"]
        element.matchString = tab["match"]

        ChatManager.Instance:AppendInputElement(element, self.type)
    end
end