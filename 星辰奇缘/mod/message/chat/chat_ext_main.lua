-- -----------------------------
-- 聊天扩展界面--主界面
-- hosr
-- -----------------------------
ChatExtMainPanel = ChatExtMainPanel or BaseClass(BasePanel)

function ChatExtMainPanel:__init(mainPanel, type, otherOption, tab,isActiveBig)
    self.mainPanel = mainPanel
    self.otherOption = otherOption
    -- otherOption用于简单的表情接入，{parent 依附界面lua对象，sendcallback 发送回调}
    self.path = "prefabs/ui/chat/chatshow.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
        ,{file = AssetConfig.guard_head, type = AssetType.Dep}
        ,{file = AssetConfig.childhead, type = AssetType.Dep}
        ,{file = AssetConfig.face_textures, type = AssetType.Dep}
        --,{file = AssetConfig.no1inworld_textures,type = AssetType.Dep}
    }

    self.face = nil
    self.bag = nil
    self.pet = nil
    self.custom = nil
    self.friend = nil
    self.quest = nil
    self.history = nil
    self.type = type
    self.currentTab = nil
    self.initShowTabIndex = tab
    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.isActiveBig = isActiveBig
    self.toggleObjTab = {}
    self.toggleTab = {}
end

function ChatExtMainPanel:__delete()
    if self.face ~= nil then
        self.face:DeleteMe()
        self.face = nil
    end

    if self.bag ~= nil then
        self.bag:DeleteMe()
        self.bag = nil
    end

    if self.pet ~= nil then
        self.pet:DeleteMe()
        self.pet = nil
    end

    if self.custom ~= nil then
        self.custom:DeleteMe()
        self.custom = nil
    end

    if self.friend ~= nil then
        self.friend:DeleteMe()
        self.friend = nil
    end

    if self.quest ~= nil then
        self.quest:DeleteMe()
        self.quest = nil
    end

    if self.history ~= nil then
        self.history:DeleteMe()
        self.history = nil
    end

    if self.equip ~= nil then
        self.equip:DeleteMe()
        self.equip = nil
    end

    if self.guard ~= nil then
        self.guard:DeleteMe()
        self.guard = nil
    end

    if self.honor ~= nil then
        if self.honor.guide ~= nil then
            self.honor.guide:DeleteMe()
        end
        self.honor:DeleteMe()
        self.honor = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ChatExtMainPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "ChatExtMainPanel"
    self.transform = self.gameObject.transform

    self:InitToggle()

    if self.type == MsgEumn.ExtPanelType.Chat then
        UIUtils.AddUIChild(ChatManager.Instance.model.chatCanvas, self.gameObject)
    elseif self.type == MsgEumn.ExtPanelType.Friend or self.type == MsgEumn.ExtPanelType.Group then
        UIUtils.AddUIChild(FriendManager.Instance.model.friendWin.gameObject, self.gameObject)
    elseif self.type == MsgEumn.ExtPanelType.Zone then
        UIUtils.AddUIChild(self.mainPanel.gameObject, self.gameObject)
    elseif self.type == MsgEumn.ExtPanelType.Other then
        -- UIUtils.AddUIChild(self.otherOption.parent.gameObject, self.gameObject)
        UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    end
    if self.type == MsgEumn.ExtPanelType.Chat then
        self.transform:Find("MainCon/Send"):GetComponent(Button).onClick:AddListener(function() ChatManager.Instance.model.chatWindow:ClickSend() end)
    elseif self.type == MsgEumn.ExtPanelType.Friend then
        self.transform:Find("MainCon/Send"):GetComponent(Button).onClick:AddListener(function() FriendManager.Instance.model:ClickSend() end)
    elseif self.type == MsgEumn.ExtPanelType.Group then
        self.transform:Find("MainCon/Send"):GetComponent(Button).onClick:AddListener(function() FriendManager.Instance.model:ClickGroupSend() end)
    elseif self.type == MsgEumn.ExtPanelType.Zone then
        self.transform:Find("MainCon/Send"):GetComponent(Button).onClick:AddListener(function() self.mainPanel:OnButtonSend() end)
    elseif self.type == MsgEumn.ExtPanelType.Other then
        self.transform:Find("MainCon/Send"):GetComponent(Button).onClick:AddListener(function() self.otherOption.sendcallback() end)
    end

    self.red_bag_btn = self.transform:Find("MainCon/RedPack"):GetComponent(Button)
    self.red_bag_btn_text = self.transform:Find("MainCon/RedPack/Text"):GetComponent(Text)

    self.red_bag_btn.onClick:AddListener(function() self:ClickRedPack() end)

    self.CrossVoice_btn = self.transform:Find("MainCon/CrossVoice"):GetComponent(Button)
    self.CrossVoice_btn_text = self.transform:Find("MainCon/CrossVoice/Text"):GetComponent(Text)

    self.CrossVoice_btn.onClick:AddListener(function() self:ClickCrossVoice() end)

    local right = self.transform:Find("MainCon/RightCon")
    self.face = ChatExtFace.New(right:Find("FaceCon").gameObject, self.type, self.otherOption,self.isActiveBig)
    self.bag = ChatExtBag.New(right:Find("BagCon").gameObject, self.type, self.otherOption)
    self.pet = ChatExtPet.New(right:Find("PetCon").gameObject, self.type, self.otherOption)
    self.custom = ChatExtCustom.New(right:Find("BianjieCon").gameObject, self.type, self.otherOption)
    self.friend = ChatExtFriend.New(right:Find("FriendCon").gameObject, self.type, self.otherOption)
    self.quest = ChatExtQuest.New(right:Find("TaskCon").gameObject, self.type, self.otherOption)
    self.history = ChatExtHistory.New(right:Find("HistoryCon").gameObject, self.type, self.otherOption)
    self.equip = ChatExtEquip.New(right:Find("EquipCon").gameObject, self.type, self.otherOption)
    self.guard = ChatExtGuard.New(right:Find("GuardCon").gameObject, self.type, self.otherOption)
    self.honor = ChatExtHonor.New(right:Find("HonorCon").gameObject, self.type, self.otherOption)


    self.face.mainPanel =  self
    self.bag.mainPanel =  self
    self.pet.mainPanel =  self
    self.custom.mainPanel =  self
    self.friend.mainPanel = self
    self.quest.mainPanel = self
    self.history.mainPanel =  self
    self.equip.mainPanel = self
    self.guard.mainPanel = self
    self.honor.mainPanel = self

    self.tab = {self.face, self.custom, self.history, self.bag, self.pet, self.quest, self.friend, self.equip, self.guard, self.honor}

    self:ClearMainAsset()

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.tabGroup = TabGroup.New(self.transform:Find("MainCon/LeftCon").gameObject, function(index) self:ChangeTab(index) end)

    self:CheckCross()
    self:CheckRedpack()
    self:CheckType()

    if self.initShowTabIndex ~= nil then
        self.tabGroup:ChangeTab(self.initShowTabIndex)
    end
end

function ChatExtMainPanel:InitToggle()
    local toggle = self.transform:Find("MainCon/RightCon/ToggleGroup")
    local len = toggle.childCount
    for i = 1, len do
        local obj = toggle:GetChild(i - 1).gameObject
        obj:GetComponent(RectTransform).anchoredPosition = Vector2((i - 1) * 20, 0)
        obj:SetActive(true)
        table.insert(self.toggleObjTab, obj)
        table.insert(self.toggleTab, obj:GetComponent(Toggle))
    end
end

-- 更新显示
function ChatExtMainPanel:UpdateToggleShow(count)
    for i, v in ipairs(self.toggleObjTab) do
        if i > count then
            v:SetActive(false)
            if self.toggleTab[i] ~= nil then
                self.toggleTab[i].isOn = false
            end
        else
            v:SetActive(true)
        end
    end
end

-- 更新选中
function ChatExtMainPanel:UpdateToggleIndex(index)
    if self.toggleTab[index] ~= nil then
        self.toggleTab[index].isOn = true
    end
end

function ChatExtMainPanel:ChangeTab(index)
    if self.currentTab ~= nil and self.currentTab.index ~= index then
        self.currentTab:Hiden()
    end
    self.currentTab = self.tab[index]
    self.currentTab:Show()
end

function ChatExtMainPanel:OnOpen()
    if not self:CheckCross() then
        if self.currentTab ~= nil then
            self.currentTab:Show()
        end
        self:CheckRedpack()
    end
    if self.openArgs ~= nil then
        self.initShowTabIndex = self.openArgs.tab
        if self.initShowTabIndex ~= nil then
            self.tabGroup:ChangeTab(self.initShowTabIndex)
        end
    end
end

function ChatExtMainPanel:OnHide()
    ChatManager.Instance:ResetElementCount()
end

function ChatExtMainPanel:CheckRedpack()
    if self.mainPanel.currentChannel ~= nil and (self.mainPanel.currentChannel.channel == MsgEumn.ChatChannel.Guild or self.mainPanel.currentChannel.channel == MsgEumn.ChatChannel.World) then
        self.red_bag_btn.gameObject:SetActive(true)
        self.CrossVoice_btn.gameObject:SetActive(true)
        if self.mainPanel.currentChannel.channel == MsgEumn.ChatChannel.World then
            self.red_bag_btn_text.text = TI18N("世界红包")
        elseif self.mainPanel.currentChannel.channel == MsgEumn.ChatChannel.Guild then
            self.red_bag_btn_text.text = TI18N("公会红包")
        end
    else
        self.red_bag_btn.gameObject:SetActive(false)
        self.CrossVoice_btn.gameObject:SetActive(false)
    end
end

function ChatExtMainPanel:CheckType()
    if self.type == MsgEumn.ExtPanelType.Zone or self.type == MsgEumn.ExtPanelType.Other then
        for i,v in ipairs(self.tabGroup.buttonTab) do
            v.gameObject:SetActive(i==1)
        end
    end
end

function ChatExtMainPanel:CheckCross()
    -- 在跨服，并且在跨服频道打开，只显示表情和历史
    if RoleManager.Instance:CanConnectCenter() and RoleManager.Instance.RoleData.cross_type == 1
        and self.mainPanel.currentChannel ~= nil
        and (self.mainPanel.currentChannel.channel == MsgEumn.ChatChannel.MixWorld or self.mainPanel.currentChannel.channel == MsgEumn.ChatChannel.Scene) then
        for i,v in ipairs(self.tabGroup.buttonTab) do
            if i == 1 then
                v.gameObject:SetActive(true)
            elseif i == 3 then
                v.gameObject:SetActive(true)
            else
                v.gameObject:SetActive(false)
            end
        end
        self.tabGroup:ChangeTab(1)
        self.red_bag_btn.gameObject:SetActive(false)
        self.CrossVoice_btn.gameObject:SetActive(false)
        return true
    else
        if self.type == MsgEumn.ExtPanelType.Zone or self.type == MsgEumn.ExtPanelType.Other then
            for i,v in ipairs(self.tabGroup.buttonTab) do
                if i == 7 then
                    v.gameObject:SetActive(false)
                else
                    v.gameObject:SetActive(i==1)
                end
            end
        else
            for i,v in ipairs(self.tabGroup.buttonTab) do
                if i == 2 or i == 7 then
                    v.gameObject:SetActive(false)
                else
                    v.gameObject:SetActive(true)
                end
            end
        end
        return false
    end
end

function ChatExtMainPanel:ClickRedPack()
    if self.mainPanel.currentChannel == nil then
        return
    end

    if self.mainPanel.currentChannel.channel == MsgEumn.ChatChannel.Guild then
        if GuildManager.Instance.model:check_has_join_guild() then
            local guild_num = GuildManager.Instance.model.my_guild_data.MemNum + GuildManager.Instance.model.my_guild_data.FreshNum
            if guild_num < 5 then
                NoticeManager.Instance:FloatTipsByString(TI18N("公会成员大于5人才可发红包"))
                return
            end
            self:Hiden()
            GuildManager.Instance.model:InitRedBagSetUI()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("要加入公会才能发红包和抢红包~"))
        end
    elseif self.mainPanel.currentChannel.channel == MsgEumn.ChatChannel.World then
        RedBagManager.Instance.model:InitRedBagListUI()
    end
end

function ChatExtMainPanel:ClickCrossVoice()
    if self.mainPanel.currentChannel == nil then
        return
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.CrossVoiceWindow, {})
end
