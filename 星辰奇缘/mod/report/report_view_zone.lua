ReportViewZone = ReportViewZone or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function ReportViewZone:__init(model)
    self.model = model
    -- self.windowId = WindowConfig.WinID.ReportViewZone
    self.name = "ReportViewZone"
    self.friendMgr = self.model.friendMgr
    self.resList = {
        {file = AssetConfig.reportzonewindow, type = AssetType.Main}
    }

    -----------------------------------------
    self.Layout = nil
    self.CopyItem = nil
    self.noFriend = nil
    self.input_field = nil
    self.toggleList = {}

    self.data = nil
    self.chatDataList = {}
    self.chatItemList = {}

     self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    -----------------------------------------
end

function ReportViewZone:__delete()
    self:ClearDepAsset()
end

function ReportViewZone:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.reportzonewindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.CopyItem = self.transform:Find("Main/CopyItem").gameObject

    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.transform:Find("Main/Con")
    }
    self.Layout = LuaBoxLayout.New(self.transform:Find("Main/Con/Layout"), setting)

    self.noFriend = self.transform:Find("Main/Con/NoFriend").gameObject

    self.toggleList = {}
    for i=1, 6 do
        local toggle = self.transform:Find("Main/TogglePanel/Toggle"..i):GetComponent(Toggle)
        table.insert(self.toggleList, toggle)
    end

    self.input_field = self.transform:FindChild("Main/InputCon"):FindChild("InputField"):GetComponent(InputField)
    self.input_field.textComponent = self.transform:FindChild("Main/InputCon/InputField/Text"):GetComponent(Text)
    self.input_field.placeholder = self.transform:FindChild("Main/InputCon/InputField/Placeholder"):GetComponent(Text)
    self.input_field.placeholder.text = TI18N("点击这里输入原因，最多100字")
    self.input_field.characterLimit = 100

    self.noticeText = self.transform:FindChild("Main/NoticeText")
    self.noticeText.gameObject:SetActive(false)

    self.okButton = self.transform:Find("Main/OkButton")
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:OnOkButton() end)

    self.descButton = self.transform:Find("Main/DescButton")
    self.descButton:GetComponent(Button).onClick:AddListener(function()
            TipsManager.Instance:ShowText({gameObject = self.descButton.gameObject
                , itemData = {TI18N("1.系统<color='#ffff00'>不会</color>以任何形式透露举报人信息。")
                                , TI18N("2.举报属实，给予<color='#ffff00'>首名</color>举报人奖励。")
                                , TI18N("3.根据情节轻重，给予被举报人相应<color='#ffff00'>惩罚</color>。")}})
        end)

    -- self.transform:Find("Main/DescText"):GetComponent(Text).text = ""


    self:OnOpen()
end

function ReportViewZone:Close()
    self.model:CloseZoneWindow()
end

function ReportViewZone:OnOpen()
    --  BaseUtils.dump(self.openArgs,"我们的数据=====================================================================================================")
    if self.openArgs ~= nil  then
        self.data = self.openArgs
    end

    if self.data == nil then return end
    self.transform:Find("Main/NameText"):GetComponent(Text).text = string.format(TI18N("被举报玩家：<color='#ffff00'>%s</color>"), self.data.name)

    self:UpdateChatList()
end

function ReportViewZone:UpdateChatList()
    self.chatDataList = {}
    table.insert(self.chatDataList,self.data)
    self.chatItemList = {}
    for k,v in ipairs(self.chatDataList) do
        local item = GameObject.Instantiate(self.CopyItem)
        self:SetChatItem(item, v)
        self.Layout:AddCell(item.gameObject)
        table.insert(self.chatItemList, item:GetComponent(Toggle))
    end

    self.Layout:ReSize()
end

function ReportViewZone:SetChatItem(item, data)
    local its = item.transform
    item.transform:Find("Background").gameObject:SetActive(false)
    local label = its:Find("Label"):GetComponent(Text)
    local str = data.content
    str = string.gsub(str, "{.-}", "##")
    if MsgEumn.ChatChannelName[data.channel] == nil then
        label.text = string.format("<color='%s'>%s：%s</color>", MsgEumn.ChannelColor[1], self.data.name, str)
    else
        label.text = string.format("<color='%s'>[%s]%s：%s</color>", MsgEumn.ChannelColor[data.channel], MsgEumn.ChatChannelName[data.channel], self.data.name, str)
    end

    its.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(360, label.preferredHeight + 2)
end

function ReportViewZone:OnOkButton()
    if self.data == nil then return end
    local type = 0
    for k,v in pairs(self.toggleList) do
        if v.isOn then
            type = k
            break
        end
    end

    local rid = self.data.role_id
    local platform = self.data.platform
    local zone_id = self.data.zone_id
    local reason = self.input_field.text
    ReportManager.Instance:Send14702(rid, platform, zone_id, reason, {{title = TI18N("留言板"), content = self.data.content, chat_time = self.data.ctime}}, type, 1)
    self:Close()
end