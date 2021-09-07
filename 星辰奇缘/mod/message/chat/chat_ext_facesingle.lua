-- --------------------------------
-- 聊天扩展界面--标签
-- --------------------------------
ChatExtFaceSingle = ChatExtFaceSingle or BaseClass(ChatExtBase)

function ChatExtFaceSingle:__init(gameObject, ipf)
    self.gameObject = gameObject
    self.gameObject.name = "ChatExtFaceSingle"

    self.itemTab = {}
    self.currentPageCount = 1
    self.pageTab = {}
    self:InitPanel()
    self.inputField = ipf
    self.isInit = false
    self:Show()
    self.specialPage = 0

    -- self.listener = function()
    --     if self.isInit then
    --         self:Refresh(self:InitData())
    --     end
    -- end
    -- EventMgr.Instance:AddListener(event_name.privilege_lev_change, self.listener)
end

function ChatExtFaceSingle:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    if not self.isInit then
        self.isInit = true
        self:InitPage(self:InitData(), 560, 24)
    end
end

function ChatExtFaceSingle:GetItem(pageTransform)
    for i = 1, 24 do
        local item = pageTransform:GetChild(i - 1)
        local tab = {}
        tab["gameObject"] = item.gameObject
        tab["transform"] = item.transform
        tab["button"] = item.gameObject:GetComponent(Button)
        tab["face"] = FaceItem.New(item.transform)
        table.insert(self.itemTab, tab)
        local index = #self.itemTab
        tab["button"].onClick:RemoveAllListeners()
        tab["button"].onClick:AddListener(function() self:ClickBtn(index) end)
    end
end

function ChatExtFaceSingle:Refresh(list)
    local count = 0
    for i,id in ipairs(list) do
        count = count + 1
        local tab = self.itemTab[i]
        if id > 0 then
            tab["face"]:Show(id, Vector2(12, -15))
            tab["match"] = string.format("%%#%s", id)
            tab["append"] = string.format("#%s", id)
            tab["send"] = string.format("#%s", id)
            tab["gameObject"]:SetActive(true)
        else
            tab["gameObject"]:SetActive(false)
        end
    end

    -- 多出来的隐藏
    local allLen = #self.itemTab
    for i = count + 1, allLen do
        local tab = self.itemTab[i]
        tab["gameObject"]:SetActive(false)
    end

    self:ShowSpecial()
end

-- 检查是否显示特权
function ChatExtFaceSingle:ShowSpecial()
    for i,v in ipairs(self.pageTab) do
        v.transform:Find("Special").gameObject:SetActive(false)
    end

    if self.specialPage > 0 then
        local len = self.pageMax - self.specialPage
        for i = self.specialPage, self.specialPage + len do
            self.pageTab[i].transform:Find("Special").gameObject:SetActive(true)
        end
    end
end

function ChatExtFaceSingle:ClickBtn(index)
    local tab = self.itemTab[index]

    local _type = PrivilegeManager.Instance:GetValueByType(PrivilegeEumn.Type.specialFacePack)
    local cfg_data = DataChatFace.data_get_chat_face_privilege[tab["face"].faceId]
    if cfg_data ~= nil and _type < cfg_data.privilege then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("充值{string_2,#ffff00,1000}{assets_2,90002}即可使用{string_2,#ffff00,特权表情包}")
        data.sureLabel = TI18N("立刻充值")
        data.cancelLabel = TI18N("稍后再充")
        data.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3,1}) end
        NoticeManager.Instance:ConfirmTips(data)
        return
    end

    local str = tab["append"]
    if str ~= nil and str ~= "" then
        local element = {}
        element.showString = str
        element.sendString = tab["send"]
        element.matchString = tab["match"]
        if not BaseUtils.isnull(self.inputField) then
            self.inputField.text = self.inputField.text..tab["send"]
        end
    end
end

function ChatExtFaceSingle:InitData()
    local newList = {}
    local special = {}--特权列表
    for i = 1, DataChatFace.data_get_chat_face_privilege_length do
        local cfg_data = DataChatFace.data_get_chat_face_privilege[i]
        if cfg_data ~= nil then
            if cfg_data.privilege > 0 then
                table.insert(special, i)
            else
                table.insert(newList, i)
            end
        else
            table.insert(newList, i)
        end
    end

    self.specialPage = math.ceil(#newList / 24) + 1
    -- 计算普通的要补多少个才补满当前页
    local need = 24 - #newList % 24
    if need > 0 then
        for i = 1, need do
            table.insert(newList, 0)
        end
    end

    -- 加入特权表情，到新的一页开始
    for i,v in ipairs(special) do
        table.insert(newList, v)
    end

    return newList
end