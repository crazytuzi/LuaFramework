-- ---------------------------------
-- 聊天大界面
-- hosr
-- ---------------------------------
ChatPanel = ChatPanel or BaseClass(BasePanel)

function ChatPanel:__init(model)
    self.model = model
    self.name = "ChatPanel"
    self.resList = {
        {file = AssetConfig.chat_window, type = AssetType.Main}
        ,{file = AssetConfig.chat_window_res, type = AssetType.Dep}
    }

    -- 频道按钮tabgroup
    self.tabGroup = nil

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.hidePos = -500
    self.showPos = -5


    self.ChannelCount = 5
    -- 频道容器
    self.channelContainerTab = {}
    self.currentChannel = nil
    self.channelIdList = {
        MsgEumn.ChatChannel.World, 
        MsgEumn.ChatChannel.Guild, 
        MsgEumn.ChatChannel.Team, 
        MsgEumn.ChatChannel.Scene, 
        MsgEumn.ChatChannel.System, 
        MsgEumn.ChatChannel.MixWorld, 
        MsgEumn.ChatChannel.Activity, 
        MsgEumn.ChatChannel.Activity1, 
        MsgEumn.ChatChannel.Camp,
    }

    self.channelToIndex = {
       [MsgEumn.ChatChannel.World] = 1,
       [MsgEumn.ChatChannel.Guild] = 2,
       [MsgEumn.ChatChannel.Team] = 3,
       [MsgEumn.ChatChannel.Scene] = 4,
       [MsgEumn.ChatChannel.System] = 5,
       [MsgEumn.ChatChannel.MixWorld] = 6,
       [MsgEumn.ChatChannel.Activity] = 7,
       [MsgEumn.ChatChannel.Activity1] = 8,
       [MsgEumn.ChatChannel.Camp] = 9,
    }

    self.chatExtPanel = nil

    -- 点击扩展面板出来的元素
    self.appendTab = {}

    -- 组队更新
    self.teamListener = function(_) self:OnTeamUpdate() end

    self.crosstypeListener = function() self:OnCrossTypeChange() end

    self.eventListener = function() self:OnEventChange() self:OnEventChangeResetChanel(self.currentIndex)  self:OnCrossTypeChange() end
    self.adaptListener = function() self:AdaptIPhoneX() end
    self.updateTopPanelListener = function() self:UpdateTopPanel() end
    self.messageSendSuccessListener = function(data) self:MessageSendSuccess(data) end

    self.inTeam = false
    self.isInit = false

    self.textListenet = function(fromId, actionType, text) self:OnTextInput(fromId, actionType, text) end

    self.effectPathArrow = "prefabs/effect/20009.unity3d"
    self.effectArrow = nil

    table.insert(self.resList, {file = self.effectPathArrow, type = AssetType.Main})
end

function ChatPanel:ShowCanvas(bool)
    if self.gameObject == nil then
        return
    end

    if bool then
        BaseUtils.ChangeLayersRecursively(self.transform, "UI")
        if self.raycaster == nil then
            self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        end
        if self.raycaster ~= nil then
            self.raycaster.enabled = true
        end
    else
        BaseUtils.ChangeLayersRecursively(self.transform, "Water")
        if self.raycaster == nil then
            self.raycaster = self.gameObject:GetComponent(GraphicRaycaster)
        end
        if self.raycaster ~= nil then
            self.raycaster.enabled = false
        end
    end
end

function ChatPanel:__delete()
    BaseUtils.ReleaseImage(self.leftSelectImg)
    BaseUtils.ReleaseImage(self.leftNormalImg)    

    EventMgr.Instance:RemoveListener(event_name.input_dialog_callback, self.textListenet)
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener)
    EventMgr.Instance:RemoveListener(event_name.chat_main_top_update, self.updateTopPanelListener)
    EventMgr.Instance:RemoveListener(event_name.message_send_success, self.messageSendSuccessListener)

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ChatPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.chat_window))
    self.gameObject.name = "ChatMainPanel"
    self.baseRect = self.gameObject:GetComponent(RectTransform)
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.model.chatCanvas, self.gameObject)
    -- self.transform:SetSiblingIndex(3)
    self.transform:SetAsLastSibling()

    self.mainTransform = self.transform:Find("MainContent")
    self.mainObj = self.mainTransform.gameObject
    self.mainRect = self.mainObj:GetComponent(RectTransform)
    self.mainRect.anchoredPosition = Vector2(-500, 0)
    self.mainTransform:Find("ShowButton"):GetComponent(Button).onClick:AddListener(function() self:ClickShow() end)
    self.LeftPart = self.mainTransform:Find("LeftPart")

    self.leftSelectImg = self.LeftPart:Find("ButtonActivity2/Select/Select"):GetComponent(Image)
    self.leftNormalImg = self.LeftPart:Find("ButtonActivity2/Normal/Normal"):GetComponent(Image)

    self:InitTop()
    self:InitLeft()
    self:InitRight()

    self.shield = self.mainTransform:Find("ShieldCon").gameObject
    self.shieldTxt = self.shield.transform:Find("TxtShield"):GetComponent(Text)
    self.shield:SetActive(false)
    self.shield.transform.anchorMax = Vector2(1,1)
    self.shield.transform.anchorMin = Vector2(1,1)
    self.shield.transform.pivot = Vector2(1,1)
    self.shield.transform.anchoredPosition3D = Vector3(-14.5,-10)

    self.scrollLockObj = self.mainTransform:Find("ScrollLock").gameObject
    self.scrollLockToggle = ChatScrollToggle.New(self.scrollLockObj.transform:Find("Toggle").gameObject, self)
    self.scrollLockToggle:ToggleOn(false)

    self.effectArrow = GameObject.Instantiate(self:GetPrefab(self.effectPathArrow))
    self.effectArrow.name = "EffectArrow"
    Utils.ChangeLayersRecursively(self.effectArrow.transform, "UI")
    self.effectArrow.transform:SetParent(self.transform)
    self.effectArrow.transform.localScale = Vector3.one * 0.5
    self.effectArrow:SetActive(false)


    self:ClearMainAsset()

    self:OnShow()

    EventMgr.Instance:AddListener(event_name.team_update, self.teamListener)
    -- EventMgr.Instance:AddListener(event_name.cross_type_change, self.crosstypeListener) --先跨服，后改Event
    EventMgr.Instance:AddListener(event_name.team_leave, self.teamListener)
    EventMgr.Instance:AddListener(event_name.role_event_change, self.eventListener)
    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)
    EventMgr.Instance:AddListener(event_name.chat_main_top_update, self.updateTopPanelListener)
    EventMgr.Instance:AddListener(event_name.message_send_success, self.messageSendSuccessListener)

    self.isInit = true
    self:AdaptIPhoneX()
end

function ChatPanel:InitTop()
    local topTransform = self.mainTransform:Find("TopPart")
    self.topTransform = topTransform
    -- 语音输入块
    self.voiceInput = topTransform:Find("VoiceInput").gameObject
    -- 文字输入块
    self.textInput = topTransform:Find("TextInput").gameObject

    local voiceInputTrans = self.voiceInput.transform
    -- 切换到文字输入按钮
    voiceInputTrans:Find("TextTypeButton"):GetComponent(Button).onClick:AddListener(function() self:ChangeInputType(MsgEumn.InputType.Text) end)
    -- 语音输入按钮
    local voiceHoldBtn = voiceInputTrans:Find("VoiceInputButton"):GetComponent(CustomEnterExsitButton)
    voiceHoldBtn.onDown:AddListener(function() self:DownVoice() end)
    voiceHoldBtn.onUp:AddListener(function() self:UpVoice() end)
    voiceHoldBtn.onEnter:AddListener(function() self:EnterVoice() end)
    voiceHoldBtn.onExsit:AddListener(function() self:ExitVoice() end)

    local textInputTrans = self.textInput.transform
    -- 切换到语音输入按钮
    textInputTrans:Find("VoiceTypeButton"):GetComponent(Button).onClick:AddListener(function() self:ChangeInputType(MsgEumn.InputType.Voice) end)

    local inputField = textInputTrans:Find("Input/InputField").gameObject
    self.inputFieldText = inputField:GetComponent(InputField)
    -- self.inputFieldText.shouldHideMobileInput = true
    local inText = inputField.transform:Find("Text").gameObject:GetComponent(Text)
    inText.supportRichText = true
    inputField:GetComponent(InputField).textComponent = inText
    inputField:GetComponent(InputField).placeholder = inputField.transform:Find("Placeholder").gameObject:GetComponent(Graphic)
    inputField:GetComponent(InputField).characterLimit = 45

    self.placeholder = self.inputFieldText.placeholder.gameObject:GetComponent(Text)
    self.placeholder.color = Color(0,0,0,0.5)
    self.placeholder.text = TI18N("点击输入")

    if BaseUtils.CustomKeyboard() then
        -- 文字输入框
        self.inputFieldText.enabled = false
        textInputTrans:Find("Input"):GetComponent(Button).onClick:AddListener(function() self:OpenInputDialog() end)
        EventMgr.Instance:AddListener(event_name.input_dialog_callback, self.textListenet)
    else
        self.inputFieldText.enabled = true
    end

    -- 更多按钮
    topTransform:Find("MoreButton"):GetComponent(Button).onClick:AddListener(function() self:ClickMore() end)
    -- 发送按钮
    topTransform:Find("SendButton"):GetComponent(Button).onClick:AddListener(function() self:ClickSend() end)
end

function ChatPanel:InitLeft()
    local left = self.mainTransform:Find("LeftPart").gameObject
    self.leftTransform = left.transform
    local setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
    }
    self.tabGroup = TabGroup.New(left, function(index) self:ChangeChannel(index) end, setting)
    if self.isInit then
        self:OnEventChange()
    end
end

function ChatPanel:InitRight()
    local right = self.mainTransform:Find("RightPart")
    self.rightTransform = right
    local rightParent = self.mainTransform:Find("RightPart/RightParent")

    self.unOpen = right:Find("UnOpenCon").gameObject
    local unOpenTrans = self.unOpen.transform
    self.unOpenDesc = unOpenTrans:Find("TxtDesc1"):GetComponent(Text)
    unOpenTrans:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:UnOpenBtnClick() end)
    self.unOpenBtnTxt = unOpenTrans:Find("Button/Text"):GetComponent(Text)
    self.unOpen:SetActive(false)

    local container = ChatMsgContainer.New(rightParent, self)
    container.channel = MsgEumn.ChatChannel.World
    self.channelContainerTab[MsgEumn.ChatChannel.World] = container

    container = ChatMsgContainer.New(rightParent, self)
    container.channel = MsgEumn.ChatChannel.Team
    self.channelContainerTab[MsgEumn.ChatChannel.Team] = container

    container = ChatMsgContainer.New(rightParent, self)
    container.channel = MsgEumn.ChatChannel.Scene
    self.channelContainerTab[MsgEumn.ChatChannel.Scene] = container

    container = ChatMsgContainer.New(rightParent, self)
    container.channel = MsgEumn.ChatChannel.Guild
    self.channelContainerTab[MsgEumn.ChatChannel.Guild] = container

    container = ChatMsgContainer.New(rightParent, self)
    container.channel = MsgEumn.ChatChannel.Private
    self.channelContainerTab[MsgEumn.ChatChannel.Private] = container

    container = ChatMsgContainer.New(rightParent, self)
    container.channel = MsgEumn.ChatChannel.System
    self.channelContainerTab[MsgEumn.ChatChannel.System] = container

    container = ChatMsgContainer.New(rightParent, self)
    container.channel = MsgEumn.ChatChannel.MixWorld
    self.channelContainerTab[MsgEumn.ChatChannel.MixWorld] = container

    container = ChatMsgContainer.New(rightParent, self)
    container.channel = MsgEumn.ChatChannel.Activity
    self.channelContainerTab[MsgEumn.ChatChannel.Activity] = container

    container = ChatMsgContainer.New(rightParent, self)
    container.channel = MsgEumn.ChatChannel.Activity1
    self.channelContainerTab[MsgEumn.ChatChannel.Activity1] = container

    container = ChatMsgContainer.New(rightParent, self)
    container.channel = MsgEumn.ChatChannel.Camp
    self.channelContainerTab[MsgEumn.ChatChannel.Camp] = container

    self.topPanel = ChatMainTopPanel.New(self.model, rightParent)
end

-- ---------------------------------------------------
-- 根据消息数量对容器高度重设
-- 每条消息数据结构体里面带有高度宽度
-- ---------------------------------------------------
function ChatPanel:ReSizeContainer()
end

-- ---------------------------------------------------
-- 频道未开启时的显示处理
-- ---------------------------------------------------
function ChatPanel:UnOpen(channel)
    self.unOpenChannel = channel
    self.unOpenDesc.text = ""
    self.unOpenBtnTxt.text = ""
end

function ChatPanel:UnOpenBtnClick()
    if self.unOpenChannel ~= nil then

    end
end

-- ----------------------------------------
-- 按钮操作
-- ---------------------------------------
-- 切换频道显示
function ChatPanel:ChangeChannel(index)

    self.currentIndex = index

    local channel = self.channelIdList[index]
    self:HideChannelNotify(channel)

    if self.currentChannel ~= nil then
        if self.currentChannel.channel ~= channel then
            self.currentChannel.isHide = true
            self.currentChannel:Hiden()
        end
    end

    self.currentChannel = self.channelContainerTab[channel]
    self.currentChannel.isHide = false
    self.currentChannel:Show()
    self.shield:SetActive(false)
    if channel == MsgEumn.ChatChannel.Team then
        if TeamManager.Instance:HasTeam() or self:CanOpenTeamChanel() then
            self.shield:SetActive(false)
        else
            self.shield:SetActive(true)
            self.shieldTxt.text = TI18N("当前无队伍,不能发言")
        end
    elseif channel == MsgEumn.ChatChannel.Guild then
        if GuildManager.Instance.model:check_has_join_guild() then
            self.shield:SetActive(false)
        else
            self.shield:SetActive(true)
            self.shieldTxt.text = TI18N("当前无公会,不能发言")
        end
    elseif channel == MsgEumn.ChatChannel.System then
        self.shield:SetActive(true)
        self.shieldTxt.text = TI18N("系统频道不能发言，请切换到其他频道")
    elseif channel == MsgEumn.ChatChannel.MixWorld then
        -- 切换到跨服标签，清空当前输入
        self.inputFieldText.text = ""
        ChatManager.Instance:CleanSomeCache()
    elseif channel == MsgEumn.ChatChannel.Scene and RoleManager.Instance:CanConnectCenter() and RoleManager.Instance.RoleData.cross_type == 1 then
        self.inputFieldText.text = ""
        ChatManager.Instance:CleanSomeCache()
    elseif channel == MsgEumn.ChatChannel.Activity or channel == MsgEumn.ChatChannel.Activity1 or channel == CanyonResultPanel then
        -- 切换到活动专用标签，清空当前输入
        self.inputFieldText.text = ""
        ChatManager.Instance:CleanSomeCache()
    end

    if RoleManager.Instance.RoleData.lev < MsgEumn.ChannelLimit[channel] then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s级</color>才能在<color='#ffff00'>%s频道</color>说话，加油升级哦！"), MsgEumn.ChannelLimit[channel], MsgEumn.ChatChannelName[channel]))
    end

    self:OnTick()

    local topPanelMsg = ChatManager.Instance.model:GetTopPanelMsg(channel)
    if topPanelMsg ~= nil then
        self.topPanel:SetData(topPanelMsg)
        self.topPanel:SetActive(true)
    else
        self.topPanel:Clean()
    end
end

-- 切换输入方式  文字，语音
function ChatPanel:ChangeInputType(type)
    if type == MsgEumn.InputType.Text then
        self.voiceInput:SetActive(false)
        self.textInput:SetActive(true)
    elseif type == MsgEumn.InputType.Voice then
        self.voiceInput:SetActive(true)
        self.textInput:SetActive(false)
    end
end

-- 点击发送
function ChatPanel:ClickSend()
    local channel = self.currentChannel.channel
    if RoleManager.Instance.RoleData.lev < MsgEumn.ChannelLimit[channel] then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s级</color>才能在<color='#ffff00'>%s频道</color>说话，加油升级哦！"), MsgEumn.ChannelLimit[channel], MsgEumn.ChatChannelName[channel]))
        return
    end
    if not self:CheckElement() then
        local str = self.inputFieldText.text
        -- 去掉手动输入的控制符 如 \n
        str = string.gsub(str, "%c+", "　")
        str = string.gsub(str, "{(%l-_%d.-),(.-)}", "")
        ChatManager.Instance:AppendHistory(str)
        local ok = ChatManager.Instance:SendMsg(self.currentChannel.channel, str)
        if ok then
            local channel = self.currentChannel.channel
            if channel == MsgEumn.ChatChannel.World or channel == MsgEumn.ChatChannel.Scene or channel == MsgEumn.ChatChannel.MixWorld or channel == MsgEumn.ChatChannel.Activity or channel == MsgEumn.ChatChannel.Activity1 then
            
            else
                self.inputFieldText.text = ""
            end
        end
    end
    self:OnTick()
end

-- 点击更多
function ChatPanel:ClickMore()
    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Chat)
    end
    self.chatExtPanel:Show()
end

-- 语音按钮操作
function ChatPanel:DownVoice()
    local channel = self.currentChannel.channel
    self.model:DownVoice(channel)
end

function ChatPanel:UpVoice()
    self.model:UpVoice()
end

function ChatPanel:ExitVoice()
    self.model:ExitVoice()
end

function ChatPanel:EnterVoice()
    self.model:EnterVoice()
end

function ChatPanel:ClickShow()
    self.model:HideChatWindow()
    -- self.model:ShowChatMini()
    EventMgr.Instance:Fire(event_name.chat_main_show)

    if self.topPanel ~= nil then
        self.topPanel:SetActive(false)
    end
end
-- --------------------------------------
-- 显示隐藏
-- --------------------------------------
function ChatPanel:Hiden()
    self:TweenHide()
    if MainUIManager.Instance.MainUICanvasView ~= nil then 
        MainUIManager.Instance.MainUICanvasView:OutFPS(false)
    end
end

function ChatPanel:OnShow()
    local role = RoleManager.Instance.RoleData
    ChatManager.Instance.waitingCacheTab = {}
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        local index = self.channelToIndex[self.openArgs[1]]
        if (index == 7 and role.event ~= RoleEumn.Event.StarChallenge) 
            or (index == 8 and role.event ~= RoleEumn.Event.ApocalypseLord)   
                or (index == 9 and role.event ~= RoleEumn.Event.CanYon)   
                    or (index == 4 and role.event ~= RoleEumn.Event.CanYonReady) then
            index = 1
        end
        self.tabGroup:ChangeTab(index)
    else
        local index = 1
        if RoleManager.Instance:CanConnectCenter() and RoleManager.Instance.RoleData.cross_type == 1 then
            index = 6
        end
        if self.currentChannel ~= nil then
            index = self.channelToIndex[self.currentChannel.channel]
        end
        if (not RoleManager.Instance:CanConnectCenter() or RoleManager.Instance.RoleData.cross_type ~= 1) and index == 6 then
            index = 1
        end
        if index == 6
            and (role.event == RoleEumn.Event.WarriorReady or role.event == RoleEumn.Event.Warrior
                    or role.event == RoleEumn.Event.GuildFightReady or role.event == RoleEumn.Event.GuildFight
                    or role.event == RoleEumn.Event.Masquerade) then
            index = 1
        end

        if (index == 7 and role.event ~= RoleEumn.Event.StarChallenge) 
            or (index == 8 and role.event ~= RoleEumn.Event.ApocalypseLord)   
                or (index == 9 and role.event ~= RoleEumn.Event.CanYon) 
                    or (index == 4 and role.event ~= RoleEumn.Event.CanYonReady) then
            index = 1
        end

        --进入活动默认选中
        if role.event == RoleEumn.Event.CanYon then
            index = 9
        elseif role.event == RoleEumn.Event.CanYonReady then
            index = 4
        end
        
        self.tabGroup:ChangeTab(index)
    end
    

    self:TweenShow()
    if MainUIManager.Instance.MainUICanvasView ~= nil then 
        MainUIManager.Instance.MainUICanvasView:OutFPS(true)
    end
    self:OnEventChange(true)
    self:FirstShowNotify()
    self:AppendElementCache()

    EventMgr.Instance:Fire(event_name.chat_main_show, true)
end

-- 第一次打开显示红点
function ChatPanel:FirstShowNotify()
    if self.currentChannel ~= nil and self.currentChannel.channel ~= MsgEumn.ChatChannel.Guild and self.model:HasHistoryMsg(MsgEumn.ChatChannel.Guild) then
        self:ShowChannelNotify(MsgEumn.ChatChannel.Guild)
    end
    if self.currentChannel ~= nil and self.currentChannel.channel ~= MsgEumn.ChatChannel.Team and self.model:HasHistoryMsg(MsgEumn.ChatChannel.Team) then
        self:ShowChannelNotify(MsgEumn.ChatChannel.Team)
    end
end

function ChatPanel:OnHide()
    self.openArgs = nil
    self:TweenHide()
    EventMgr.Instance:Fire(event_name.chat_main_show, false)

    if self.topPanel ~= nil then
        self.topPanel:SetActive(false)
    end
end

function ChatPanel:TweenShow()
    self.baseRect.anchoredPosition = Vector2.zero
    Tween.Instance:MoveX(self.mainRect, self.showPos, 0.2)
end

function ChatPanel:TweenHide()
    local func = function()
        -- if self.gameObject ~= nil then
        --     self.gameObject:SetActive(false)
        -- end
        self.baseRect.anchoredPosition = Vector2(0, -2000)
    end
    Tween.Instance:MoveX(self.mainRect, self.hidePos, 0.2, func)
end

function ChatPanel:JustHide()
    self.mainRect.anchoredPosition = Vector2(self.hidePos, 0)
    -- if self.gameObject ~= nil then
    --     self.gameObject:SetActive(false)
    -- end
    self.baseRect.anchoredPosition = Vector2(0, -2000)
end

-- ----------------------------------------
-- 来信息处理
-- ----------------------------------------
function ChatPanel:ShowMsg(data)
    local channel = data.channel
    local container = self.channelContainerTab[channel]
    if container.gameObject ~= nil then
        container:ShowItem(data)
    else
        self.model:AppendHistoryMsg(data)
    end

    if self.currentChannel == nil or self.currentChannel.channel ~= channel then
        self:ShowChannelNotify(channel)
    end
end

-- 不是当前频道有新消息，显示红点
function ChatPanel:ShowChannelNotify(channel)
    if channel == MsgEumn.ChatChannel.Guild then
        local index = self.channelToIndex[channel]
        self.tabGroup:ShowRed(index, true)
    elseif channel == MsgEumn.ChatChannel.Team and TeamManager.Instance:HasTeam() then
        local index = self.channelToIndex[channel]
        self.tabGroup:ShowRed(index, true)
    end
end

function ChatPanel:HideChannelNotify(channel)
    local index = self.channelToIndex[channel]
    self.tabGroup:ShowRed(index, false)
end

-- 后加到输入
function ChatPanel:AppendInput(str)
    self.inputFieldText.text = self.inputFieldText.text .. str
end

function ChatPanel:AppendInputElement(element)
    -- 其他：同类只有一个，如果是自己，则过滤掉
    local delIndex = 0
    local srcStr = ""
    if element.type ~= nil and element.type ~= MsgEumn.AppendElementType.Face then
        for i,has in ipairs(self.appendTab) do
            if has.type == element.type then
                delIndex = i
                srcStr = has.matchString
            end
        end
    end

    local nowStr = self.inputFieldText.text
    if delIndex ~= 0 then
        table.remove(self.appendTab, delIndex)
        table.insert(self.appendTab, delIndex, element)
        if string.find(nowStr, srcStr) ~= nil then
            local repStr = element.matchString
            nowStr = string.gsub(nowStr, srcStr, repStr, 1)
        else
            nowStr = nowStr .. element.showString
        end
    else
        nowStr = nowStr .. element.showString
        table.insert(self.appendTab, element)
    end
    self.inputFieldText.text = nowStr
end

function ChatPanel:CheckElement()
    if #self.appendTab == 0 then
        return false
    end
    local role = RoleManager.Instance.RoleData
    local str = self.inputFieldText.text
    for i,v in ipairs(self.appendTab) do
        local newSendStr = v.sendString
        if v.cacheType == MsgEumn.CacheType.Item then
            local cacheId = ChatManager.Instance.itemCache[v.id]
            if cacheId ~= nil then
                newSendStr = string.format("{item_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, v.num)
            end
        elseif v.cacheType == MsgEumn.CacheType.Pet then
            local cacheId = ChatManager.Instance.petCache[v.id]
            if cacheId ~= nil then
                local myPetData = PetManager.Instance:GetPetById(v.id)
                newSendStr = string.format("{pet_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, myPetData.growth_type)
            end
        elseif v.cacheType == MsgEumn.CacheType.Equip then
            local cacheId = ChatManager.Instance.equipCache[v.id]
            if cacheId ~= nil then
                local shenqi_id = 0
                local shenqi_flag = 0
                shenqi_id, shenqi_flag = EquipStrengthManager.Instance.model:check_has_equip_is_shenqi(v.base_id)
                if shenqi_id ~= 0 then
                    --是神器
                    newSendStr = string.format("{item_3,%s,%s,%s,%s,%s, %s, %s}", role.platform, role.zone_id, cacheId, v.base_id, 1, shenqi_id, shenqi_flag)
                else
                    newSendStr = string.format("{item_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, 1)
                end
            end
        elseif v.cacheType == MsgEumn.CacheType.Guard then
            local cacheId = ChatManager.Instance.guardCache[v.id]
            if cacheId ~= nil then
                local myShData = ShouhuManager.Instance.model:get_my_shouhu_data_by_id(v.base_id)
                newSendStr = string.format("{guard_1,%s,%s,%s,%s, %s}", role.platform, role.zone_id, cacheId, v.base_id, myShData.quality)
            end
        elseif v.cacheType == MsgEumn.CacheType.Wing then
            local cacheId = ChatManager.Instance.wingCache[0]
            if cacheId ~= nil then
                newSendStr = string.format("{wing_1,%s,%s,%s,%s,%s,%s,%s,%s}", role.platform, role.zone_id, role.classes, v.grade, v.growth, cacheId, v.base_id, role.name)
            end
        elseif v.cacheType == MsgEumn.CacheType.Ride then
            local cacheId = ChatManager.Instance.rideCache[v.id]
            if cacheId ~= nil then
                local myRideData = RideManager.Instance.model:get_ride_data_by_id(v.base_id)
                newSendStr = string.format("{ride_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, myRideData.growth-1)
            end
        elseif v.cacheType == MsgEumn.CacheType.Child then
            local name = string.sub(v.showString, 2, -2)
            local cacheId = ChatManager.Instance.childCache[0]
            if cacheId ~= nil then
                local myChildData = ChildrenManager.Instance:GetChild(v.child_id, role.platform, role.zone_id)
                newSendStr = string.format("{child_1,%s,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, name, myChildData.growth_type)
            end
        elseif v.cacheType == MsgEumn.CacheType.WorldChampion then
            local rid = RoleManager.Instance.RoleData.id
            local platform = RoleManager.Instance.RoleData.platform
            local zone_id = RoleManager.Instance.RoleData.zone_id
            newSendStr = string.format("{honor_3,%s,%s,%s,%s,%s}", 1, rid, platform, zone_id, TI18N("武道战绩"))
            str = ""
        elseif v.cacheType == MsgEumn.CacheType.Talisman then
            local cacheId = ChatManager.Instance.talismanCache[v.id]
            local platform = RoleManager.Instance.RoleData.platform
            local zone_id = RoleManager.Instance.RoleData.zone_id
            newSendStr = string.format("{item_4,%s,%s,%s,%s}", platform, zone_id, v.base_id, cacheId)
            if v.base_id == nil or cacheId == nil then
                Log.Error("{item_4}类型base_id或cacheId参数为nil")
                return false
            end
        end
        str = string.gsub(str, v.matchString, newSendStr, 1)
    end
    ChatManager.Instance:AppendHistory(self.inputFieldText.text)
    -- 去掉手动输入的控制符 如 \n
    str = string.gsub(str, "%c+", "　")
    local ok = ChatManager.Instance:SendMsg(self.currentChannel.channel, str)
    if ok then
        if channel == MsgEumn.ChatChannel.World or channel == MsgEumn.ChatChannel.Scene or channel == MsgEumn.ChatChannel.MixWorld or channel == MsgEumn.ChatChannel.Activity or channel == MsgEumn.ChatChannel.Activity1 then
            
        else
            self.inputFieldText.text = ""
            self.appendTab = {}
        end
    end
    return true
end

function ChatPanel:UpdateMatch()
    local container = self.channelContainerTab[MsgEumn.ChatChannel.Team]
    if container ~= nil and container.gameObject ~= nil then
        container:UpdateMatchItem()
    end
end

function ChatPanel:OnTeamUpdate()
    local container = self.channelContainerTab[MsgEumn.ChatChannel.Team]
    if TeamManager.Instance:HasTeam() or self:CanOpenTeamChanel() then
        if not self.inTeam then
            if container.gameObject ~= nil then
                container:ClearMatch()
            end
            self.inTeam = true
        end
        if self.currentChannel ~= nil and self.currentChannel.channel == MsgEumn.ChatChannel.Team then
            self.shield:SetActive(false)
        end
    else
        self.inTeam = false
        if self.currentChannel ~= nil and self.currentChannel.channel == MsgEumn.ChatChannel.Team then
            self.shield:SetActive(true)
            self.shieldTxt.text = TI18N("当前无队伍,不能发言")
        end
        if container.gameObject ~= nil then
            container:ClearMatch()
        end
    end
end

function ChatPanel:UpdateHelp()
    local container = self.channelContainerTab[MsgEumn.ChatChannel.Guild]
    if container ~= nil and container.gameObject ~= nil then
        container:UpdateHelpItem()
    end
end

function ChatPanel:UpdateCrossArena()
    local container = self.channelContainerTab[MsgEumn.ChatChannel.World]
    if container ~= nil and container.gameObject ~= nil then
        container:UpdateCrossArenaItem()
    end

    container = self.channelContainerTab[MsgEumn.ChatChannel.Scene]
    if container ~= nil and container.gameObject ~= nil then
        container:UpdateCrossArenaItem()
    end

    container = self.channelContainerTab[MsgEumn.ChatChannel.Guild]
    if container ~= nil and container.gameObject ~= nil then
        container:UpdateCrossArenaItem()
    end

    container = self.channelContainerTab[MsgEumn.ChatChannel.MixWorld]
    if container ~= nil and container.gameObject ~= nil then
        container:UpdateCrossArenaItem()
    end
end

-- 显示冷却时间
function ChatPanel:OnTick()
    if Application.platform == RuntimePlatform.Android and ChatManager.Instance.customKeyboard then
        return
    end
    if self.currentChannel.channel == MsgEumn.ChatChannel.World then
        if ChatManager.Instance.worldCd ~= 0 then
            self.placeholder.text = string.format(TI18N("%s秒后可世界发言"), ChatManager.Instance.worldCd)
        else
            self.placeholder.text = TI18N("点击输入")
        end
    elseif self.currentChannel.channel == MsgEumn.ChatChannel.MixWorld then
        if ChatManager.Instance.mixworldCd ~= 0 then
            self.placeholder.text = string.format(TI18N("%s秒后可跨服世界发言"), ChatManager.Instance.mixworldCd)
        else
            self.placeholder.text = TI18N("点击输入")
        end
    elseif self.currentChannel.channel == MsgEumn.ChatChannel.Scene then
        if ChatManager.Instance.sceneCd ~= 0 then
            if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then 
                self.placeholder.text = string.format(TI18N("%s秒后可峽谷发言"), ChatManager.Instance.sceneCd)
            else
                self.placeholder.text = string.format(TI18N("%s秒后可场景发言"), ChatManager.Instance.sceneCd)
            end
        else
            self.placeholder.text = TI18N("点击输入")
        end
    elseif self.currentChannel.channel == MsgEumn.ChatChannel.Activity 
                or self.currentChannel.channel == MsgEumn.ChatChannel.Activity1 
                or self.currentChannel.channel == MsgEumn.ChatChannel.Camp then
        if ChatManager.Instance.activityCd ~= 0 then
            self.placeholder.text = string.format(TI18N("%s秒后可发言"), ChatManager.Instance.activityCd)
        else
            self.placeholder.text = TI18N("点击输入")
        end
    else
        self.placeholder.text = TI18N("点击输入")
    end
end

-- 是否锁定
function ChatPanel:IsLock(bool)
    if self.scrollLockToggle ~= nil then
        self.scrollLockToggle:ToggleOn(bool)
    end
end

function ChatPanel:ShowLock(bool)
    if self.scrollLockObj ~= nil then
        self.scrollLockObj:SetActive(bool)
    end
end

-- 清理所以聊天消息
function ChatPanel:ClearAll()
    for i,container in pairs(self.channelContainerTab) do
        container:Clear()
    end
end

-- 打开输入框
function ChatPanel:OpenInputDialog()
    ChatManager.Instance.customKeyboard = true
    self.tempInput = self.inputFieldText.text
    self.inputFieldText.text = ""
    self.placeholder.text = ""

    local width = 188 * (ctx.ScreenWidth / 960) -- 同上
    local fontSize = BaseUtils.FontSize(18)
    local cpos = BaseUtils.ConvertPosition(self.inputFieldText.gameObject.transform.position)
    local x = cpos.px
    local y = cpos.py
    SdkManager.Instance:ShowInputDialog(GlobalEumn.InputFormId.Chat, GlobalEumn.ShowType.Send, x, y, fontSize, GlobalEumn.GravityType.Left, width, self.tempInput)
end

function ChatPanel:OnTextInput(fromId, actionType, text)
    if tonumber(fromId) ~= GlobalEumn.InputFormId.Chat then
        return
    end

    ChatManager.Instance.customKeyboard = false

    local list = StringHelper.ConvertStringTable(text)
    local len = math.min(#list, 45)
    text = table.concat(list, nil, 1, len)

    self.inputFieldText.text = tostring(text)
    if tostring(text) == "" then
        self:OnTick()
    else
        if tonumber(actionType) == GlobalEumn.InputCallbackType.ClickReturn then
            -- 点击回车回调
            self:ClickSend()
        elseif tonumber(actionType) == GlobalEumn.InputCallbackType.ClickBlank then
            -- 点击空白回调
        end
    end
end

function ChatPanel:ShowArrowEffect(position, width, height)
    if BaseUtils.is_null(self.effectArrow) then
        self.effectArrow = nil
        return
    end

    local pos = ctx.UICamera.camera:WorldToScreenPoint(position)
    local scaleWidth = ctx.ScreenWidth
    local scaleHeight = ctx.ScreenHeight
    local origin = 960 / 540
    local currentScale = scaleWidth / scaleHeight
    local newx = 0
    local newy = 0
    local ch = 0
    local cw = 0
    local off_x = width / 2
    local off_y = height
    if currentScale > origin then
        -- 以宽为准
        ch = 540
        cw = 960 * currentScale / origin

        newx = pos.x * cw / scaleWidth
        newy = pos.y * ch / scaleHeight
    else
        -- 以高为准
        ch = 540 * origin / currentScale
        cw = 960

        newx = pos.x * cw / scaleWidth
        newy = pos.y * ch / scaleHeight
    end
    pos = Vector3(newx + off_x - cw / 2, newy + off_y - ch / 2, 0)
    self.effectArrow.transform.localPosition = Vector3(pos.x, pos.y, -1000)
    self.effectArrow:SetActive(false)
    self.effectArrow:SetActive(true)
end

function ChatPanel:HideArrowEffect()
    if not BaseUtils.is_null(self.effectArrow) then
        self.effectArrow:SetActive(false)
    end
end

function ChatPanel:OnCrossTypeChange()
    -- 公会战、勇士战场状态，屏蔽跨服频道
    local role = RoleManager.Instance.RoleData
    if role.cross_type == 1
        and role.event ~= RoleEumn.Event.WarriorReady and role.event ~= RoleEumn.Event.Warrior
        and role.event ~= RoleEumn.Event.GuildFightReady and role.event ~= RoleEumn.Event.GuildFight
        and role.event ~= RoleEumn.Event.Masquerade and role.event ~= RoleEumn.Event.StarChallenge 
        and role.event ~= RoleEumn.Event.ApocalypseLord and role.event ~= RoleEumn.Event.CanYon 
        and role.event ~= RoleEumn.Event.CanYonReady then
        self.LeftPart:Find("Button6").gameObject:SetActive(true)
    else
        self.LeftPart:Find("Button6").gameObject:SetActive(false)
    end
end

--mark 区分打开面板调用/event改变调用
function ChatPanel:OnEventChange(mark)
    -- 龙王状态，屏蔽跨服频道，开启活动专用频道
    local role = RoleManager.Instance.RoleData
    if role.event == RoleEumn.Event.StarChallenge then
        self.LeftPart:Find("ButtonActivity").gameObject:SetActive(true)
        self.LeftPart:Find("ButtonActivity1").gameObject:SetActive(false)
        self.LeftPart:Find("Button6").gameObject:SetActive(false)
        self.tabGroup.buttonTab[7].transform.localPosition = Vector2(40, 0)
        for i=1, 6 do
            self.tabGroup.buttonTab[i].transform.localPosition = Vector2(40, i * -60)
        end
        self.tabGroup.buttonTab[8].transform.localPosition = Vector2(40, -420)
    elseif role.event == RoleEumn.Event.ApocalypseLord then
        self.LeftPart:Find("ButtonActivity1").gameObject:SetActive(true)
        self.LeftPart:Find("ButtonActivity").gameObject:SetActive(false)
        self.LeftPart:Find("Button6").gameObject:SetActive(false)
        self.tabGroup.buttonTab[8].transform.localPosition = Vector2(40, 0)
        for i=1, 7 do
            self.tabGroup.buttonTab[i].transform.localPosition = Vector2(40, i * -60)   
        end
    elseif role.event == RoleEumn.Event.CanYonReady then--峡谷之巅准备区
        self.tabGroup.buttonTab[4].transform.localPosition = Vector2(40, 0)
        self.tabGroup.buttonTab[4].transform:Find("Select/Select"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatBtnCanyon_2")
        self.tabGroup.buttonTab[4].transform:Find("Normal/Normal"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatBtnCanyon_1")
        for i=1, 5 do
            if i > 4 then
                self.tabGroup.buttonTab[i].transform.localPosition = Vector2(40, (i - 1) * -60)
            elseif i < 4 then
                self.tabGroup.buttonTab[i].transform.localPosition = Vector2(40, i * -60)
            end
        end
        if not mark then 
            local container = self.channelContainerTab[MsgEumn.ChatChannel.Scene]
            if container ~= nil and container.gameObject ~= nil then
                container:Clear()
            end
        end
    elseif role.event == RoleEumn.Event.CanYon then--峡谷之巅战场内活动
        self.tabGroup.buttonTab[4].transform:Find("Select/Select"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatBtn3_1")
        self.tabGroup.buttonTab[4].transform:Find("Normal/Normal"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatBtn3_2")
        if CanYonManager.Instance.self_side == 1 then -- 联盟
            self.leftSelectImg.sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatBtn12_1")
            self.leftNormalImg.sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatBtn12_2")
        elseif CanYonManager.Instance.self_side == 2 then --部落
            self.leftSelectImg.sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatBtn12_3")
            self.leftNormalImg.sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatBtn12_4")
        end
        self.leftSelectImg:SetNativeSize()
        self.leftNormalImg:SetNativeSize()

        self.LeftPart:Find("ButtonActivity2").gameObject:SetActive(true)
        self.tabGroup.buttonTab[9].transform.localPosition = Vector2(40, 0)
        for i=1, 5 do
            self.tabGroup.buttonTab[i].transform.localPosition = Vector2(40, i * -60)
        end
    else
        self.LeftPart:Find("ButtonActivity").gameObject:SetActive(false)
        self.LeftPart:Find("ButtonActivity1").gameObject:SetActive(false)
        self.LeftPart:Find("ButtonActivity2").gameObject:SetActive(false)

        self.tabGroup.buttonTab[4].transform:Find("Select/Select"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatBtn3_1")
        self.tabGroup.buttonTab[4].transform:Find("Normal/Normal"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatBtn3_2")

        self:OnCrossTypeChange()
        for i=1, 6 do
            self.tabGroup.buttonTab[i].transform.localPosition = Vector2(40, (i-1) * -60)
        end
    end
end

function ChatPanel:OnEventChangeResetChanel(index)
    if index == nil then
        index = 1
    end
    local role = RoleManager.Instance.RoleData
    if index == 6
        and (role.event == RoleEumn.Event.WarriorReady or role.event == RoleEumn.Event.Warrior
                or role.event == RoleEumn.Event.GuildFightReady or role.event == RoleEumn.Event.GuildFight
                or role.event == RoleEumn.Event.Masquerade) then
        index = 1
    end
    if (index == 7 and role.event ~= RoleEumn.Event.StarChallenge) 
            or (index == 8 and role.event ~= RoleEumn.Event.ApocalypseLord) 
                or (index == 9 and role.event ~= RoleEumn.Event.CanYon)  
                or (index == 4 and role.event ~= RoleEumn.Event.CanYonReady) then
        index = 1
    end

    self.tabGroup:ChangeTab(index)
end

-- 队伍频道额外开启条件
function ChatPanel:CanOpenTeamChanel()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart
        or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess
        or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady
        or CombatManager.Instance.isFighting and MatchManager.Instance.currid == 1000 then
        return true
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.TeamDungeon_Recruit_Matching
        and TeamDungeonManager.Instance.model.dungeon_team ~= nil
        and TeamDungeonManager.Instance.model.dungeon_team.dungeon_mate ~= nil
        and #TeamDungeonManager.Instance.model.dungeon_team.dungeon_mate > 1 then
        return true
    else
        return false
    end
end

function ChatPanel:AppendElementCache()
    for i,v in ipairs(self.model.appendElementCache) do
        self:AppendInputElement(v)
    end
    self.model.appendElementCache = {}
end

function ChatPanel:AdaptIPhoneX()
    if MainUIManager.Instance.adaptIPhoneX and Screen.orientation ~= ScreenOrientation.LandscapeRight then
        self.mainTransform.sizeDelta = Vector2(505, self.mainTransform.sizeDelta.y)
        self.topTransform.sizeDelta = Vector2(445, 70)
        self.topTransform.anchoredPosition = Vector2(15, -10)
        self.rightTransform.offsetMin = Vector2(135, 15)
        self.leftTransform.offsetMin = Vector2(45, 98.5)
        self.shield.transform.sizeDelta = Vector2(445, 70)
    else
        self.mainTransform.sizeDelta = Vector2(465, self.mainTransform.sizeDelta.y)
        self.topTransform.sizeDelta = Vector2(435, 70)
        self.topTransform.anchoredPosition = Vector2(0, -10)
        self.rightTransform.offsetMin = Vector2(95, 15)
        self.leftTransform.offsetMin = Vector2(12, 98.5)
        self.shield.transform.sizeDelta = Vector2(435, 70)
        -- self.leftTransform.anchoredPosition = Vector2(12, 0)
    end
end

function ChatPanel:UpdateTopPanel()
    if self.currentChannel ~= nil then
        local topPanelMsg = ChatManager.Instance.model:GetTopPanelMsg(self.currentChannel.channel)
        if topPanelMsg ~= nil then
            if self.model.isChatShow then
                self.topPanel:SetData(topPanelMsg)
                self.topPanel:SetActive(true)

                local container = self.channelContainerTab[self.currentChannel.channel]
                if container ~= nil and not BaseUtils.isnull(container.gameObject) then
                    container.rect.offsetMin = Vector2(1,-2)
                    container.rect.offsetMax = Vector2(1,topPanelMsg.height)
                end
            end
        else
            self.topPanel:Clean()
            local container = self.channelContainerTab[self.currentChannel.channel]
            if container ~= nil and not BaseUtils.isnull(container.gameObject) then
                container.rect.offsetMin = Vector2(1,-2)
                container.rect.offsetMax = Vector2(1,-2)
            end
        end
    end
end

function ChatPanel:MessageSendSuccess(data)
    if data.code == 10400 then
        if data.flag == 1 then
            self.inputFieldText.text = ""
            self.appendTab = {}
        end 
    end
end