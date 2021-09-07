-- ---------------------------------------
-- 聊天小界面
-- hosr
-- ---------------------------------------
ChatMini = ChatMini or BaseClass(BasePanel)

function ChatMini:__init(model)
    self.model = model
    self.prefabPath = AssetConfig.chat_mini_window

    self.originPos = Vector2.zero

    -- 第二字体现在不用了，安卓直接把第一字体改为静态，ios就独立用动态
    -- if Application.platform == RuntimePlatform.Android
    --     or Application.platform == RuntimePlatform.WindowsEditor
    --     or Application.platform == RuntimePlatform.WindowsPlayer
    --     then
    --     self.prefabPath = AssetConfig.chat_mini_window_android
    -- end

    self.resList = {
        {file = AssetConfig.chat_window_res, type = AssetType.Dep},
        {file = self.prefabPath, type = AssetType.Main}
    }

    -- 头上按钮列表
    self.buttonTab = nil

    -- 标志当前界面大小
    self.isNormal = true
    self.normalSize = Vector2(320, 155)
    self.maxSize = Vector2(320, 255)
    self.normalRotate = Vector3(0,0,0)
    self.maxRotate = Vector3(0,0,180)
    self.hidePos = -270
    self.showPos = 10

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.listener = function() self:UpdateButton() end

    self.guildEnterListener = function() self:UpdateGuildButton(true) end
    self.guildExitListener = function() self:UpdateGuildButton(false) end

    self.flyListener = function() self:ChangeFly() end
    self.adaptListener = function() self:AdaptIPhoneX() end

    self.isFull = false
    self.maxMsgCount = 10
    self.itemTab = {}
    self.reuseIndex = 0

    self.Top = Vector2(0, 1)
    self.Bottom = Vector2(0, 0)
    self.allHeight = 0

    self.matchItemTab = {}
    self.helpItemTab = {}
    self.crossArenaTab = {}

    self.isInit = false
end

function ChatMini:ShowCanvas(bool)
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

function ChatMini:__delete()
    EventMgr.Instance:RemoveListener(event_name.team_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_create, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.listener)
    EventMgr.Instance:RemoveListener(event_name.role_event_change, self.listener)
    EventMgr.Instance:RemoveListener(event_name.role_ride_change, self.flyListener)
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener)

    EventMgr.Instance:RemoveListener(event_name.enter_guild_succ, self.guildEnterListener)
    EventMgr.Instance:RemoveListener(event_name.leave_guild_succ, self.guildExitListener)

    if self.buttonLayout ~= nil then
        self.buttonLayout:DeleteMe()
        self.buttonLayout = nil
    end
    BaseUtils.CancelIPhoneXTween(self.transform)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ChatMini:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.prefabPath))
    self.gameObject.name = "ChatMini"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.model.chatCanvas, self.gameObject)
    self.transform:SetSiblingIndex(2)

    local mainTrasform = self.transform:Find("MainContent")
    self.mainObj = mainTrasform.gameObject
    self.mainRect = self.mainObj:GetComponent(RectTransform)
    self.mainRect.anchoredPosition = Vector2(0, self.hidePos)

    local btnContainer = mainTrasform:Find("ButtonContainer")
    local chatBtn = btnContainer:Find("ChatButton"):GetComponent(Button)
    local worldBtn = btnContainer:Find("WorldVoiceButton"):GetComponent(CustomEnterExsitButton)
    local guildBtn = btnContainer:Find("GuildVoiceButton"):GetComponent(CustomEnterExsitButton)
    local teamBtn = btnContainer:Find("TeamVoiceButton"):GetComponent(CustomEnterExsitButton)
    local flyBtn = btnContainer:Find("FlyButton"):GetComponent(Button)
    local surrenderBtn = btnContainer:Find("Surrender"):GetComponent(Button)

    self.buttonLayout = LuaBoxLayout.New(btnContainer, {axis = BoxLayoutAxis.X, cspacing = 10, border = 10})
    self.buttonTab = {chatBtn, worldBtn, guildBtn, teamBtn, flyBtn, surrenderBtn}

    chatBtn.onClick:AddListener(function() self:ClickChat() end)
    flyBtn.onClick:AddListener(function() self:ClickFly() end)

    worldBtn.onDown:AddListener(function() self:DownVoice(MsgEumn.ChatChannel.World) end)
    worldBtn.onUp:AddListener(function() self:UpVoice() end)
    worldBtn.onEnter:AddListener(function() self:EnterVoice() end)
    worldBtn.onExsit:AddListener(function() self:ExitVoice() end)

    guildBtn.onDown:AddListener(function() self:DownVoice(MsgEumn.ChatChannel.Guild) end)
    guildBtn.onUp:AddListener(function() self:UpVoice() end)
    guildBtn.onEnter:AddListener(function() self:EnterVoice() end)
    guildBtn.onExsit:AddListener(function() self:ExitVoice() end)

    teamBtn.onDown:AddListener(function() self:DownVoice(MsgEumn.ChatChannel.Team) end)
    teamBtn.onUp:AddListener(function() self:UpVoice() end)
    teamBtn.onEnter:AddListener(function() self:EnterVoice() end)
    teamBtn.onExsit:AddListener(function() self:ExitVoice() end)

    surrenderBtn.onClick:AddListener(function() AnimalChessManager.Instance:OnSurrender() end)

    self.chatBtnObj = chatBtn.gameObject
    self.worldBtnObj = worldBtn.gameObject
    self.guildBtnObj = guildBtn.gameObject
    self.teamBtnObj = teamBtn.gameObject
    self.flyBtnObj = flyBtn.gameObject
    self.surrenderBtnObj = surrenderBtn.gameObject

    self.flyBtnRed = self.flyBtnObj.transform:Find("redpoint").gameObject
    self.flyBtnRed:SetActive(false)
    self.flyImg = self.flyBtnObj:GetComponent(Image)

    local arrowBtn = mainTrasform:Find("ArrowButton"):GetComponent(Button)
    self.arrowTrans = arrowBtn.gameObject.transform:Find("Image")
    local settingBtn = mainTrasform:Find("SettingButton"):GetComponent(Button)
    arrowBtn.onClick:AddListener(function() self:ClickArrow() end)
    settingBtn.onClick:AddListener(function() self:ClickSetting() end)

    mainTrasform:Find("MsgContainer"):GetComponent(Button).onClick:AddListener(function() self:ClickAll() end)
    self.msgContainer = mainTrasform:Find("MsgContainer/Con_item").gameObject
    self.containerRect = self.msgContainer:GetComponent(RectTransform)
    self.baseNoticeItem = self.msgContainer.transform:Find("msgItem").gameObject
    self.baseNoticeItem:SetActive(false)

    self:UpdateButton()

    self:ClearMainAsset()
    self:ChangeFly()

    -- if RoleManager.Instance.RoleData.drama_status ~= RoleEumn.DramaStatus.Running then
        self:TweenShow()
    -- end


    EventMgr.Instance:AddListener(event_name.team_update, self.listener)
    EventMgr.Instance:AddListener(event_name.team_create, self.listener)
    EventMgr.Instance:AddListener(event_name.team_leave, self.listener)
    EventMgr.Instance:AddListener(event_name.role_event_change, self.listener)
    EventMgr.Instance:AddListener(event_name.role_ride_change, self.flyListener)

    EventMgr.Instance:AddListener(event_name.enter_guild_succ, self.guildEnterListener)
    EventMgr.Instance:AddListener(event_name.leave_guild_succ, self.guildExitListener)
    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)

    self.isInit = true
end

function ChatMini:OnInitCompleted()
    for i,v in ipairs(self.model.miniAppendList) do
        self:ShowMsg(v)
    end
    self.model.miniAppendList = {}
    self:AdaptIPhoneX()
end

-- 对显示的按钮进行排序
function ChatMini:LayoutButton()
    self.buttonLayout:ReSet()
    for _,btn in ipairs(self.buttonTab) do
        if btn.gameObject.activeSelf then
            self.buttonLayout:AddCell(btn.gameObject)
        end
    end
end

-- -----------------------------------
-- 按钮操作
-- -----------------------------------
function ChatMini:ClickChat()
    self:ClickAll()
end


function ChatMini:ClickFly()
    if WingsManager.Instance.grade ~= nil and WingsManager.Instance.grade < 2 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack, {3,2})
        NoticeManager.Instance:FloatTipsByString(TI18N("二阶翅膀就可以飞行了哦，快去进阶翅膀吧~"))
    elseif SceneManager.Instance.sceneElementsModel.self_data ~= nil and SceneManager.Instance.sceneElementsModel.self_data.isDriver == 1 and SceneManager.Instance.sceneElementsModel.self_data.ride == SceneConstData.unitstate_ride and not RideManager.Instance.model:CheckFly() then
        NoticeManager.Instance:FloatTipsByString(TI18N("共乘状态下坐骑需要佩戴<color='#00ff00'>逐风彩云</color>才能飞行"))
    else
        SceneManager.Instance.sceneElementsModel:Self_RideChange()
    end
end

function ChatMini:ClickArrow()
    -- 如果是正常的就变大，如果是大的就变小,箭头跟着转
    if self.isNormal then
        self.isNormal = false
        self.mainRect.sizeDelta = self.maxSize
        self.arrowTrans.localRotation = Quaternion.identity
        self.arrowTrans:Rotate(self.maxRotate)
    else
        self.isNormal = true
        self.mainRect.sizeDelta = self.normalSize
        self.arrowTrans.localRotation = Quaternion.identity
        self.arrowTrans:Rotate(self.normalRotate)
    end
    EventMgr.Instance:Fire(event_name.chat_mini_size_change, self.isNormal)
end

function ChatMini:ClickSetting()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.setting_window)
end

function ChatMini:ClickAll()
    self.model:ShowChatWindow()
    -- self.model:HideChatMini()
end

function ChatMini:DownVoice(channel)
    self.model:DownVoice(channel)
end

function ChatMini:UpVoice()
    self.model:UpVoice()
end

function ChatMini:ExitVoice()
    self.model:ExitVoice()
end

function ChatMini:EnterVoice()
    self.model:EnterVoice()
end

-- --------------------------------------
-- 显示隐藏
-- --------------------------------------
function ChatMini:OnShow()
    self:TweenShow()
end

function ChatMini:OnHide()
    self:TweenHide()
end

function ChatMini:TweenShow()
    Tween.Instance:MoveY(self.mainRect, self.showPos, 0.2)
end

function ChatMini:TweenHide()
    Tween.Instance:MoveY(self.mainRect, self.hidePos, 0.2)
end

-- --------------------------------------
-- 外部更新
-- --------------------------------------
function ChatMini:UpdateButton()
    self.surrenderBtnObj:SetActive(false)
    self.flyBtnObj:SetActive(true)
    self.worldBtnObj:SetActive(true)
    self.guildBtnObj:SetActive(GuildManager.Instance.model:has_guild())
    self.teamBtnObj:SetActive(TeamManager.Instance:HasTeam() or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionStart or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.WorldChampionSuccess)
    self:LayoutButton()
end

function ChatMini:UpdateGuildButton(bool)
    self.guildBtnObj:SetActive(bool)
    self:LayoutButton()
end

function ChatMini:ShowFlyRed(bool)
    self.flyBtnRed:SetActive(bool)
end

function ChatMini:ChangeFly()
    if BaseUtils.IsVerify then
        return
    end
    
    if RoleManager.Instance.RoleData.ride == RoleEumn.Ride.Fly then
        self.flyImg.sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatTopBtn4")
    else
        self.flyImg.sprite = self.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatTopBtn3")
    end
end

-- --------------------------------------
-- 处理消息
-- --------------------------------------
function ChatMini:ShowMsg(data)
    if data.showType == MsgEumn.ChatShowType.QuestHelp and SosManager.Instance.chatShowTab[data.extraData.id] == nil then
        return
    end
    if data.prefix == 8 and RoleManager.Instance.RoleData.event == RoleEumn.Event.StarChallenge then
        return
    end
    
    if string.find(data.msgData.sourceString, "{match_1,") ~= nil then
        --- 不显示这类型的匹配信息
        return
    end

    self.data = data
    self:PivotTop()

    local item = self:GetItem()
    item:SetData(data)

    self:ChangeOtherAnchorBottom()

    if self.data.showType == MsgEumn.ChatShowType.Match then
        self.matchItemTab[self.data.extraData.id] = item
    elseif self.data.showType == MsgEumn.ChatShowType.QuestHelp then
        self.helpItemTab[self.data.extraData.id] = item
    elseif self.data.showType == MsgEumn.ChatShowType.CrossArena then
        self.crossArenaTab[self.data.extraData.id] = item
    end
    table.insert(self.itemTab, item)
    self.allHeight = self:GetHeight()
    self.containerRect.sizeDelta = Vector2(290, self.allHeight)
end

function ChatMini:GetItem()
    local item = nil
    if #self.itemTab >= self.maxMsgCount then
        item = table.remove(self.itemTab, 1)
        if item.data.showType == MsgEumn.ChatShowType.Match then
            self.matchItemTab[item.data.extraData.id] = nil
            item:DeleteMe()
            item = nil
            item = ChatMiniItem.New(self)
        end
    else
        item = ChatMiniItem.New(self)
    end
    item:Reset()
    return item
end

function ChatMini:GetHeight()
    local h = 0
    for i,item in ipairs(self.itemTab) do
        h = h + item.selfHeight
    end
    return h
end

-- 检查是否需要做一下元素的参数设定
function ChatMini:Check()
    if self.slider.value >= 0.98 or self.allHeight < self.containerRect.rect.height then
        -- 当前显示在最上面，或者没满一屏
        self:PivotTop()
    else
        -- 查看历史消息中
        self:PivotBottom()
    end
end

-- 当滚到位置在最上面时，容器 ====注册点==== 在上方，这样保证了在新增元素容器拉大时，位置往下移
function ChatMini:PivotTop()
    self.containerRect.pivot = self.Top
end

-- 当滚动位置在中间时，玩家查看历史消息时，容器 ====注册点==== 在下方，保证了在新增元素容器拉大时当前位置不变，容器往上增大
function ChatMini:PivotBottom()
    self.containerRect.pivot = self.Bottom
end

-- 把其他已有元素锚点改变
function ChatMini:ChangeOtherAnchorBottom()
    local h = 0
    for i,item in ipairs(self.itemTab) do
        h = h + item.selfHeight
        item:AnchorBottom(h)
    end
end

function ChatMini:ReLayoutAll()
    local h = 0
    local tempList = {}
    local delList = {}
    for i,item in ipairs(self.itemTab) do
        if not item.needDelete then
            h = h + item.selfHeight
            item:AnchorBottom(h)
            table.insert(tempList, item)
        else
            table.insert(delList, item)
        end
    end

    for i,item in ipairs(delList) do
        item:DeleteMe()
        item = nil
    end
    delList = nil

    self.itemTab = tempList
    tempList = nil

    self.allHeight = self:GetHeight()
    self.containerRect.sizeDelta = Vector2(290, self.allHeight)
end

function ChatMini:UpdateMatch()
    local delList = {}
    for id,item in pairs(self.matchItemTab) do
        local matchData = TeamManager.Instance.chatShowMatchTab[id]
        if matchData == nil then
            -- 删除
            table.insert(delList, id)
        else
            -- 更新
            item:SetData(matchData)
        end
    end
    for _,id in ipairs(delList) do
        local item = self.matchItemTab[id]
        if item ~= nil and item.data ~= nil and item.data.showType == MsgEumn.ChatShowType.Match then
            -- 当前还是匹配的才删，不是的就已经被复用成常规消息了不需要删除
            item.needDelete = true
        end
        self.matchItemTab[id] = nil
    end
    self:ReLayoutAll()
end

function ChatMini:ClearAll()
    for i,item in ipairs(self.itemTab) do
        item:DeleteMe()
    end
    self.itemTab = {}

    for k,item in pairs(self.matchItemTab) do
        item:DeleteMe()
    end
    self.matchItemTab = {}

    for k,item in pairs(self.helpItemTab) do
        item:DeleteMe()
    end
    self.helpItemTab = {}
end

function ChatMini:UpdateHelp()
    local delList = {}
    for id,item in pairs(self.helpItemTab) do
        local matchData = SosManager.Instance.chatShowTab[id]
        if matchData == nil then
            -- 删除
            table.insert(delList, id)
        else
            -- 更新
            item:SetData(matchData)
        end
    end
    for _,id in ipairs(delList) do
        local item = self.helpItemTab[id]
        if item.data ~= nil and item.data.showType == MsgEumn.ChatShowType.QuestHelp then
            item.needDelete = true
        end
        self.helpItemTab[id] = nil
    end
    self:ReLayoutAll()
end

function ChatMini:UpdateCrossArena()
    local delList = {}
    for id,item in pairs(self.crossArenaTab) do
        local matchData = SosManager.Instance.chatShowTab[id]
        if matchData == nil then
            -- 删除
            table.insert(delList, id)
        else
            -- 更新
            item:SetData(matchData)
        end
    end
    for _,id in ipairs(delList) do
        local item = self.crossArenaTab[id]
        if item.data ~= nil and item.data.showType == MsgEumn.ChatShowType.CrossArena then
            item.needDelete = true
        end
        self.crossArenaTab[id] = nil
    end
    self:ReLayoutAll()
end

function ChatMini:AdaptIPhoneX()
    BaseUtils.AdaptIPhoneX(self.transform)
end
