-- -------------------------------------------------------
-- 聊天界面，消息容器
-- hosr
-- 对应频道对应容器，每个频道最多30条，超过复用
-- -------------------------------------------------------
ChatMsgContainer = ChatMsgContainer or BaseClass(BasePanel)

function ChatMsgContainer:__init(parent, mainPanel)
    self.mainPanel = mainPanel
    self.parent = parent
    self.effect = nil
    self.effectPath = "prefabs/effect/20009.unity3d"
    self.path = "prefabs/ui/chat/chatmsgcontainer.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
    }

    -- 窗口隐藏事件
    self.OnHideEvent:Add(function() self:OnHide() end)
    -- 窗口打开事件
    self.OnOpenEvent:Add(function() self:OnShow() end)

    self.Top = Vector2(0.5, 1)
    self.Bottom = Vector2(0.5, 0)

    self.channel = 0

    self.elementTab = {}
    self.matchItemTab = {}
    self.matchCount = 0
    self.helpItemTab = {}
    self.trialHelp = {}
    self.teamDungeon = {}
    self.crossArenaTab = {}

    self.allHeight = 0

    self.isTop = true
    self.newCount = 0
    self.isLock = false

    self.isShow = false
    self.isHide = false
end

function ChatMsgContainer:__delete()
end

function ChatMsgContainer:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "ChatMsgContainer"
    self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.transform:SetAsFirstSibling()

    self.scroll = self.gameObject:GetComponent(ScrollRect)
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchorMax = Vector2.one
    self.rect.anchorMin = Vector2.zero
    self.rect.offsetMin = Vector2(5,5)
    self.rect.offsetMax = Vector2(3,7)
    self.rect.localScale = Vector3.one
    self.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2.zero

    self.baseChatItem = self.transform:Find("ChatItem").gameObject
    self.baseChatItem:SetActive(false)
    self.baseNoticeItem = self.transform:Find("ChatNoticeItem").gameObject
    self.baseNoticeItem:SetActive(false)
    self.baseMatchItem = self.transform:Find("ChatMatchItem").gameObject
    self.baseMatchItem:SetActive(false)
    self.baseRedpackItem = self.transform:Find("ChatRedpackNoticeItem").gameObject
    self.baseRedpackItem:SetActive(false)
    self.container = self.transform:Find("ItemContainer").gameObject
    self.containerRect = self.container:GetComponent(RectTransform)
    self.slider = self.transform:Find("Scrollbar"):GetComponent(Scrollbar)
    self.slider.onValueChanged:AddListener(function() self:OnScroll() end)

    self.newNotice = self.transform:Find("FleshCon").gameObject
    self.newNotice:GetComponent(Button).onClick:AddListener(function() self:ClickNew() end)
    self.newNoticeTxt = self.newNotice.transform:Find("TxtNewMsgNum"):GetComponent(Text)
    self:ShowNew(false)

    self.joinGuild = self.transform:Find("JoinGuild").gameObject
    self.joinGuild:SetActive(false)
    self.joinGuild.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:OpenFindGuild() end)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effectTrans = self.effect.transform
    self.effect:SetActive(false)
    self.effect.name = "HoldEffect"
    self.effect.transform:SetParent(self.transform)
    self.effect.transform.localScale = Vector3.one * 0.7
    self.effect.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")

    self:ClearMainAsset()

    self:ShowHistory()

    self:OnShow()

    self.gameObject:SetActive(not self.isHide)
end

function ChatMsgContainer:OnScroll()
    self:Check()
end

-- ------------------------------
-- 处理新消息提示
-- ------------------------------
function ChatMsgContainer:ShowNewNum(num)
    self.newNoticeTxt.text = string.format(TI18N("未读消息<color='#4dd52b'>%s</color>条"), num)
    self:ShowNew(true)
end

function ChatMsgContainer:ShowNew(bool)
    self.newNotice:SetActive(bool)
end

function ChatMsgContainer:ClickNew()
    self:OnShow()
end

-- ----------------------------
-- 显示隐藏
-- ----------------------------
function ChatMsgContainer:OnHide()
    self.isShow = false
    self.newCount = 0
    self:ShowNew(false)
    self.containerRect.anchoredPosition = Vector3.zero
end

function ChatMsgContainer:OnShow()
    self.isShow = true
    self:PivotTop()
    self.newCount = 0
    self:ShowNewNum(self.newCount)
    self:ShowNew(false)
    self.containerRect.anchoredPosition = Vector3.zero
    self.mainPanel:ShowLock(self.allHeight > self.rect.rect.height)
    self.mainPanel:IsLock(false)

    self.joinGuild:SetActive(false)
    if self.channel == MsgEumn.ChatChannel.Guild then
        -- 判断是否有公会
        if not GuildManager.Instance.model:check_has_join_guild() then
            self:Clear()
            self.joinGuild:SetActive(true)
        end
    end

    local topPanelMsg = ChatManager.Instance.model:GetTopPanelMsg(self.channel)
    if ChatManager.Instance.model:GetTopPanelMsg(self.channel) ~= nil then
        self.rect.offsetMin = Vector2(1,-2)
        self.rect.offsetMax = Vector2(1,topPanelMsg.height)
    else
        self.rect.offsetMin = Vector2(1,-2)
        self.rect.offsetMax = Vector2(1,-2)
    end
end

-- ---------------------------------
-- 数据处理
-- ---------------------------------
function ChatMsgContainer:ShowItem(data)
    if data.showType == MsgEumn.ChatShowType.Match then
        -- 匹配消息有队伍大面板不显示,其实到这里的只是队长的处理
        if TeamManager.Instance:HasTeam() then
            return
        end
        if self.matchCount >= 5 then
            -- 招募信息只显示5个到大面板
            return
        end
    end

    if string.find(data.msgData.sourceString, "{match_1,") ~= nil then
        -- 检查是否符合本身等级条件
        if not self:CheckMatchLimit(data) then
            return
        end
    end

    self.data = data

    local item = self:GetItem()
    item:SetData(data)

    if (self.channel == MsgEumn.ChatChannel.MixWorld
        or (self.channel == MsgEumn.ChatChannel.Scene and RoleManager.Instance:CanConnectCenter() and RoleManager.Instance.RoleData.cross_type == 1 ))
        and (self.data.showType == MsgEumn.ChatShowType.Normal or self.data.showType == MsgEumn.ChatShowType.Voice) then
        -- 跨服不显示角色等级
        -- item:HideLev()
    end
    table.insert(self.elementTab, item)
    self:ChangeOtherAnchorBottom()

    if self.data.showType == MsgEumn.ChatShowType.Match then
        self.matchItemTab[self.data.extraData.id] = item
        self.matchCount = self.matchCount + 1
    elseif self.data.showType == MsgEumn.ChatShowType.QuestHelp then
        self.helpItemTab[self.data.extraData.id] = item
    elseif self.data.showType == MsgEumn.ChatShowType.TrialHelp then
        self.trialHelp[self.data.extraData.id] = item
    elseif self.data.showType == MsgEumn.ChatShowType.TeamDungeon then
        self.teamDungeon[self.data.extraData.id] = item
    elseif self.data.showType == MsgEumn.ChatShowType.CrossArena then
        self.crossArenaTab[self.data.extraData.id] = item
    end

    self.allHeight = self:GetHeight()
    self.containerRect.sizeDelta = Vector2(345, self.allHeight)

    if not self.isTop then
        self.containerRect.anchoredPosition = Vector2(0, self.containerRect.anchoredPosition.y + item.selfHeight)
        self.newCount = self.newCount + 1
        self:ShowNewNum(self.newCount)
    end

    if self.isShow then
        self.mainPanel:ShowLock(self.allHeight > self.rect.rect.height)
    end
end

-- 检查是否需要做一下元素的参数设定
function ChatMsgContainer:Check()
    if self.slider.value >= 0.97 or self.allHeight < self.rect.rect.height then
        -- 当前显示在最上面，或者没满一屏
        self:PivotTop()
        if not self.isTop then
            self.newCount = 0
            self:ShowNew(false)
        end
        self.isTop = true
        self.mainPanel:IsLock(false)
    else
        -- 查看历史消息中
        -- self:PivotBottom()
        self.isTop = false
        self.mainPanel:IsLock(true)
    end
end

function ChatMsgContainer:Lock(bool)
    if bool then
        self.isTop = false
    else
        self.isTop = true
        self.newCount = 0
        self:ShowNewNum(self.newCount)
        self:ShowNew(false)
        self.containerRect.anchoredPosition = Vector3.zero
    end
end

-- --------------------------
-- 聊天item
-- --------------------------
function ChatMsgContainer:GetItem()
    local item = nil
    if #self.elementTab >= 30 then
        -- 达到最大条数，复用前面的
        -- 复用的，从列表中移除，等处理完了在加回去,因为这个有特殊处理
        item = table.remove(self.elementTab, 1)
        if item.showType ~= self.data.showType then
            -- 复用时拿到了不是自己想要的，kill him
            if item.showType == MsgEumn.ChatShowType.Match then
                self.matchCount = math.max(self.matchCount - 1, 0)
            end
            item:DeleteMe()
            item = nil
            item = self:NewOne()
        end
    else
        item = self:NewOne()
    end
    item:Reset()
    return item
end

function ChatMsgContainer:NewOne()
    local item = nil
    if self.data.showType == MsgEumn.ChatShowType.System then
        -- 系统提示
        item = ChatNoticeItem.New(self)
    elseif self.data.showType == MsgEumn.ChatShowType.QuestHelp then
        -- 求助
        item = ChatNoticeItem.New(self)
    elseif self.data.showType == MsgEumn.ChatShowType.Water then
        -- 浇水
        item = ChatNoticeItem.New(self)
    elseif self.data.showType == MsgEumn.ChatShowType.Match then
        -- 招募
        item = ChatMatchItem.New(self)
    elseif self.data.showType == MsgEumn.ChatShowType.MatchWorld then
        -- 招募世界提示
        item = ChatItem.New(self)
    elseif self.data.showType == MsgEumn.ChatShowType.Redpack then
        -- 红包领取,更换底图，显示图标，其他样式一样
        item = ChatItem.New(self)
    elseif self.data.showType == MsgEumn.ChatShowType.RedpackNotice then
        -- 通知红包领取
        item = ChatRedpackNoticeItem.New(self)
    elseif self.data.showType == MsgEumn.ChatShowType.TrialHelp then
        -- 求助
        item = ChatNoticeItem.New(self)
    elseif self.data.showType == MsgEumn.ChatShowType.TeamDungeon then
        -- 组队副本招募
        item = ChatNoticeItem.New(self)
    elseif self.data.showType == MsgEumn.ChatShowType.CrossArena then
        -- 跨服约战招募
        item = ChatNoticeItem.New(self)
    else
        -- 玩家聊天
        item = ChatItem.New(self)
    end
    return item
end

function ChatMsgContainer:GetHeight()
    local h = 0
    for i,item in ipairs(self.elementTab) do
        h = h + item.selfHeight
    end
    return h
end

-- 当滚到位置在最上面时，容器 ====注册点==== 在上方，这样保证了在新增元素容器拉大时，位置往下移
function ChatMsgContainer:PivotTop()
    self.containerRect.pivot = self.Top
end

-- 当滚动位置在中间时，玩家查看历史消息时，容器 ====注册点==== 在下方，保证了在新增元素容器拉大时当前位置不变，容器往上增大
function ChatMsgContainer:PivotBottom()
    self.containerRect.pivot = self.Bottom
end

-- 把其他已有元素锚点改变
function ChatMsgContainer:ChangeOtherAnchorBottom()
    local h = -8
    for i,item in ipairs(self.elementTab) do
        h = h + item.selfHeight
        item:AnchorBottom(h)
    end
end

-- --------------------------
-- 处理未打开前的历史消息
-- --------------------------
function ChatMsgContainer:ShowHistory()
    local historyList = ChatManager.Instance.model:GetHistoryMsg(self.channel)
    for i,chatData in ipairs(historyList) do
        if chatData.showType == MsgEumn.ChatShowType.Match then
            -- 队伍招募的信息，在读取历史记录是要和当前最新的数据进行比对更新
            local nowChatData = TeamManager.Instance.chatShowMatchTab[chatData.extraData.id]
            if nowChatData ~= nil then
                chatData = nowChatData
                self:ShowItem(chatData)
            end
            self:ShowItem(chatData)
        elseif chatData.showType == MsgEumn.ChatShowType.QuestHelp then
            if SosManager.Instance.chatShowTab[chatData.extraData.id] ~= nil then
                self:ShowItem(chatData)
            end
        else
            self:ShowItem(chatData)
        end
    end
end

-- 重排所有元素
function ChatMsgContainer:ReLayoutAll()
    local h = -8
    local tempList = {}
    local delList = {}
    for i,item in ipairs(self.elementTab) do
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

    self.elementTab = tempList
    tempList = nil

    self.allHeight = self:GetHeight()
    self.containerRect.sizeDelta = Vector2(345, self.allHeight)
end

-- 招募信息更新或删除
function ChatMsgContainer:UpdateMatchItem()
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
        item.needDelete = true
        self.matchItemTab[id] = nil
        self.matchCount = self.matchCount - 1
    end
    self.matchCount = math.max(self.matchCount, 0)
    self:ReLayoutAll()
end

function ChatMsgContainer:Clear()
    for i,item in ipairs(self.elementTab) do
        item:DeleteMe()
    end
    self.elementTab = {}
    self.matchItemTab = {}
    self.matchCount = 0
    self.helpItemTab = {}
    TeamManager.Instance.chatShowMatchTab = {}
end

function ChatMsgContainer:ClearMatch()
    for k,item in pairs(self.matchItemTab) do
        item.needDelete = true
    end
    self.matchItemTab = {}
    self.matchCount = 0
    self:ReLayoutAll()
end

function ChatMsgContainer:UpdateHelpItem()
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

function ChatMsgContainer:UpdateCrossArenaItem()
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

function ChatMsgContainer:OpenFindGuild()
    if RoleManager.Instance.RoleData.lev < 10 then
        NoticeManager.Instance:FloatTipsByString(TI18N("公会将在角色等级达到10级开放加入，赶紧升级吧！"))
        return
    end
    self.mainPanel:JustHide()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildwindow)
end

function ChatMsgContainer:OnUp(item)
    if self.effectTimd ~= nil then
        LuaTimer.Delete(self.effectTimd)
        self.effectTimd = nil
    end
    if self.effect ~= nil then
        self.effectTrans:SetParent(self.transform)
        self.effectTrans.localScale = Vector3.one
        self.effect:SetActive(false)
    end
end

function ChatMsgContainer:OnDown(item)
    local func = function()
        if self.effect ~= nil then
            self.effectTrans:SetParent(item.transform)
            self.effectTrans.localScale = Vector3.one * 0.7
            self.effectTrans.localPosition = Vector3(28, -5, -400)
            self.effect:SetActive(true)
        end
    end
    if self.effectTimd ~= nil then
        LuaTimer.Delete(self.effectTimd)
        self.effectTimd = nil
    end
    self.effectTimd = LuaTimer.Add(200, func)
end

function ChatMsgContainer:CheckMatchLimit(data)
    local matchId = 0
    for val in string.gmatch(data.msgData.sourceString, "{match_1,(.-)}") do
        local args = StringHelper.Split(val, ",")
        matchId = tonumber(args[5])
    end
    local roleLev = data.lev
    local selfLev = RoleManager.Instance.RoleData.lev
    local td = DataTeam.data_match[matchId]
    if td ~= nil then
        local max = 0
        local min = 0
        local md = td.lev_recruit[1]
        if md.lev == TeamEumn.MatchLevType.Fixed then
            min = md.val1
            max = md.val2
        elseif md.lev == TeamEumn.MatchLevType.Dynamic then
            min = math.max(18, roleLev + md.val1)
            max = math.min(RoleManager.Instance.world_lev + 8, roleLev + md.val2)
        end

        if selfLev >= min and selfLev <= max then
            return true
        else
            return false
        end
    else
        return false
    end
end