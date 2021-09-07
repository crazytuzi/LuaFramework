-- -----------------------------
-- 聊天小界面项
-- hosr
-- -----------------------------
ChatMiniItem = ChatMiniItem or BaseClass(MsgItem)

function ChatMiniItem:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = mainPanel.msgContainer

    self.data = nil
    -- 文本最大宽度
    self.txtMaxWidth = 235
    -- 文本每行的高度
    self.lineSpace = 22
    self.wholeOffsetX = 0
    self.wholeOffsetChar = 0
    self.extraWidth = 0
    self.extraHeight = 0
    self.btnOffestY = 0

    self.isChatMiniItem = true

    self:InitPanel()
end

function ChatMiniItem:__delete()
    self.mainPanel = nil
    self.parent = nil
    self.data = nil
    self.txtMaxWidth = nil
    self.lineSpace = nil
    self.wholeOffsetX = nil
    self.wholeOffsetChar = nil
    self.extraWidth = nil
    self.extraHeight = nil
    self.btnOffestY = nil

    self.transform = nil
    self.rect = nil
    self.button = nil
    self.prefixImg = nil
    self.prefixRect = nil
    self.contentTxt = nil
    self.contentRect = nil
    self.contentTrans = nil
    self.extraBtnObj = nil
    self.extraBtnTxt = nil
    self.extraBtnRect = nil
    self.redpackIcon = nil
    self.voiceIcon = nil
    self.voiceIconRect = nil
    self.msgData = nil
end

function ChatMiniItem:InitPanel()
    self.gameObject = GameObject.Instantiate(self.mainPanel.baseNoticeItem)
    self.transform = self.gameObject.transform
    self.gameObject.name = "ChatMiniItem"
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.rect = self.gameObject:GetComponent(RectTransform)

    self.button = self.gameObject:GetComponent(Button)
    self.prefixImg = self.transform:Find("ChannelImg"):GetComponent(Image)
    self.prefixRect = self.prefixImg.gameObject:GetComponent(RectTransform)
    self.contentTxt = self.transform:Find("txtCon"):GetComponent(Text)
    self.contentTxt.verticalOverflow = VerticalWrapMode.Overflow
    self.contentTrans = self.contentTxt.gameObject.transform
    self.contentRect = self.transform:Find("txtCon"):GetComponent(RectTransform)
    self.extraBtnObj = self.transform:Find("BtnJoin").gameObject
    self.extraBtnRect = self.extraBtnObj:GetComponent(RectTransform)
    self.extraBtn = self.extraBtnObj:GetComponent(Button)
    self.extraBtnTxt = self.extraBtnObj.transform:Find("Text"):GetComponent(Text)
    self.extraBtnTxt.text = TI18N("加入")
    self.extraBtnObj:SetActive(false)
    self.redpackIcon = self.transform:Find("Redpack").gameObject
    self.redpackIcon:SetActive(false)
    self.redpackRect = self.redpackIcon.gameObject:GetComponent(RectTransform)
    self.voiceIcon = self.transform:Find("VoiceIcon").gameObject
    self.voiceIconRect = self.voiceIcon:GetComponent(RectTransform)
    self.voiceIcon:SetActive(false)
    self.markObj = self.transform:Find("Mark").gameObject
    self.markRect = self.markObj:GetComponent(RectTransform)
    self.markObj:SetActive(false)
    self.markImg = self.markObj:GetComponent(Image)

    self.gameObject:SetActive(false)
end

function ChatMiniItem:Reset()
    self.needDelete = false
    if self.data ~= nil and self.data.showType == MsgEumn.ChatShowType.Voice then
        ChatManager.Instance.model:DelAudioClip(self.data.cacheId, self.data.platform, self.data.zone_id)
    end
    self:HideImg()
    self:AnchorTop()
    self.msgData = nil
    self.contentTxt.text = ""
    self.contentRect.sizeDelta = Vector2(self.txtMaxWidth, self.lineSpace)
    self.wholeOffsetX = 0
    self.markObj:SetActive(false)
end

function ChatMiniItem:SetData(data)
    if BaseUtils.is_null(self.gameObject) or BaseUtils.is_null(self.contentTxt) then
    	return
    end
    self.data = data

    local showName = self.data.name
    local isGm = false
    local isDirector = false
    local hasSing = false
    if self.data.special ~= nil then
        for i,v in ipairs(self.data.special) do
            if v.type == MsgEumn.SpecialType.label then
                if v.val == 1 then
                    isGm = true
                    isDirector = false
                elseif v.val == 2 then
                    isGm = false
                    isDirector = true
                end
                break
            end
        end
    end

    self.contentTxt.text = ""
    self.contentRect.sizeDelta = Vector2(self.txtMaxWidth, self.lineSpace)
    self.msgData = self:GetMsgData(data.msgData.sourceString)
    self.data.msgData = self.msgData
    if data.prefix == 10 then
        self.prefixImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, string.format("I18NChannelIcon%s", "Activity"))
    elseif data.prefix == 11 then
        self.prefixImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, string.format("I18NChannelIcon%s", "Activity1"))
    elseif data.prefix == 12 then
        if CanYonManager.Instance.self_side == 1 then 
            self.prefixImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, string.format("I18NChannelIcon%s", "camp1"))
        else
            self.prefixImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, string.format("I18NChannelIcon%s", "camp2"))
        end
    elseif data.prefix == 3 then 
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then 
            self.prefixImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, string.format("I18NChannelIcon%s", "Canyon"))
        else
            self.prefixImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, string.format("I18NChannelIcon%s", data.prefix))
        end
    else
        self.prefixImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, string.format("I18NChannelIcon%s", data.prefix))
    end
    self.prefixImg.gameObject.transform.localScale = Vector3.one
    self.prefixRect.sizeDelta = Vector2(48, 20)

    self.wholeOffsetX = 0
    self.wholeOffsetChar = 0
    self.extraWidth = 0
    self.extraHeight = 0
    self.btnOffestY = 0
    self.voiceIcon:SetActive(false)
    self.extraBtnObj:SetActive(false)
    self.redpackIcon:SetActive(false)
    self.extraBtn.onClick:RemoveAllListeners()

    if self.data.showType == MsgEumn.ChatShowType.Match then
        self.contentTxt.text = self.msgData.pureString
        self.extraBtnObj:SetActive(true)
        self.extraBtnTxt.text = TI18N("加入")
        self.btnOffestY = self.data.extraData.btnOffestY
        local rid = self.data.extraData.rid
        local platform = self.data.extraData.platform
        local zone_id = self.data.extraData.zone_id
        self.extraBtn.onClick:AddListener(function()
                TeamManager.Instance:JoinRecruitTeam(rid, platform, zone_id)
                --TeamManager.Instance:Send11724(rid, platform, zone_id)
            end)
    elseif self.data.extraData ~= nil and (self.data.extraData.helpId == 4 or self.data.extraData.helpId == 5) then
        self.contentTxt.text = self.msgData.pureString
        self.extraBtnObj:SetActive(true)
        self.extraBtnTxt.text = TI18N("帮助")
        self.extraBtn.onClick:AddListener(function() BibleManager.Instance.model:OpenToHelpWin(self.data) end)
    elseif self.data.showType == MsgEumn.ChatShowType.QuestHelp then
        self.contentTxt.text = self.msgData.pureString
        self.extraBtnObj:SetActive(true)
        self.extraBtnTxt.text = TI18N("帮助")

        self.extraBtn.onClick:AddListener(function() SosManager.Instance:Send16003(self.data.extraData.id) end)
    elseif self.data.showType == MsgEumn.ChatShowType.Voice then
        self.msgData.showString = string.format("<color='%s'>%s</color>", MsgEumn.ChannelColor[data.channel], data.msgData.showString)
        self.voiceIcon:SetActive(true)
        if showName ~= "" then
            NoticeManager.Instance.model.calculator:ChangeFoneSize(17)
            self.wholeOffsetX = NoticeManager.Instance.model.calculator:SimpleGetWidth(string.format("%s:", showName))
            self.msgData.showString = string.format("%s:　　<color='#ffff00'>%ss</color>%s", showName, self.data.time, self.msgData.showString)
            self.msgData.pureString = string.format("%s:　　%ss%s", showName, self.data.time, self.msgData.pureString)
            self.wholeOffsetChar = #StringHelper.ConvertStringTable(string.format("%s:　　%ss", showName, self.data.time))
            self.contentTxt.text = self.msgData.pureString
        else
            self.msgData.showString = string.format("　　%s", self.msgData.showString)
            self.msgData.pureString = string.format("　　%s", self.msgData.pureString)
            self.wholeOffsetChar = 2
            self.contentTxt.text = self.msgData.pureString
        end
    elseif self.data.showType == MsgEumn.ChatShowType.Redpack then
        self.msgData.showString = string.format("<color='%s'>%s</color>", MsgEumn.ChannelColor[data.channel], data.msgData.showString)
        self.redpackIcon:SetActive(true)
        if showName ~= "" then
            NoticeManager.Instance.model.calculator:ChangeFoneSize(17)
            self.wholeOffsetX = NoticeManager.Instance.model.calculator:SimpleGetWidth(string.format("%s:", showName))
            self.msgData.showString = string.format("%s:　%s", showName, self.msgData.showString)
            self.msgData.pureString = string.format("%s:　%s", showName, self.msgData.pureString)
            self.wholeOffsetChar = #StringHelper.ConvertStringTable(string.format("%s:　", showName))
            self.contentTxt.text = self.msgData.pureString
        else
            self.msgData.showString = string.format("　%s", showName, self.msgData.showString)
            self.msgData.pureString = string.format("　%s", self.msgData.pureString)
            self.wholeOffsetChar = 1
            self.contentTxt.text = self.msgData.pureString
        end
    elseif self.data.showType == MsgEumn.ChatShowType.RedpackNotice then
        self.msgData.showString = string.format("<color='%s'>%s</color>", MsgEumn.ChannelColor[data.prefix], self.msgData.showString)
        self.contentTxt.text = self.msgData.pureString
    elseif self.data.showType == MsgEumn.ChatShowType.TrialHelp then
        self.contentTxt.text = self.msgData.pureString
        self.extraBtnObj:SetActive(true)
        self.extraBtnTxt.text = TI18N("帮助")
        self.btnOffestY = self.data.extraData.btnOffestY
        local rid = self.data.extraData.rid
        local platform = self.data.extraData.platform
        local zone_id = self.data.extraData.zone_id
        local type = self.data.extraData.type
        self.extraBtn.onClick:AddListener(function() TrialManager.Instance:Send13107(rid, platform, zone_id, type) end)
    elseif self.data.showType == MsgEumn.ChatShowType.TeamDungeon then
        self.contentTxt.text = self.msgData.pureString
        self.extraBtnObj:SetActive(true)
        self.extraBtnTxt.text = TI18N("加入")
        self.btnOffestY = self.data.extraData.btnOffestY
        local rid = self.data.extraData.rid
        local platform = self.data.extraData.platform
        local zone_id = self.data.extraData.zone_id
        local type = self.data.extraData.type
        self.extraBtn.onClick:AddListener(function() TrialManager.Instance:Send13107(rid, platform, zone_id, type) end)
    else
        -- 处理特殊标签显示
        if MessageParser.ContainTag(self.msgData.elements, "flower_1") ~= nil then
            local element = MessageParser.ContainTag(self.msgData.elements, "flower_1")
            self.extraBtnObj:SetActive(true)
            self.extraBtnTxt.text = TI18N("浇水")
            local idata = {unitId = element.unitId, battleId = element.battleId}
            self.extraBtn.onClick:AddListener(function() GuildManager.Instance.model:GoToGuildAreaForWaterFlower(idata) end)
        elseif MessageParser.ContainTag(self.msgData.elements, "ship_1") ~= nil then
            local element = MessageParser.ContainTag(self.msgData.elements, "ship_1")
            self.extraBtnObj:SetActive(true)
            self.extraBtnTxt.text = TI18N("帮助")
            local rid = element.rid
            local platform = element.platform
            local zone_id = element.zoneId
            local cell_id = element.cellId
            local name = element.content
            self.extraBtn.onClick:AddListener(
                function()
                    local shipData = {role_id = rid, platform = platform, zone_id = zone_id, cell_id = cell_id, name = name}
                    ShippingManager.Instance.guildhelp_info = shipData
                    ShippingManager.Instance:Req13710(1, rid, platform, zone_id, cell_id)
                end)
        elseif MessageParser.ContainTag(self.msgData.elements, "team_1") ~= nil then
            local element = MessageParser.ContainTag(self.msgData.elements, "team_1")
            self.extraBtnObj:SetActive(true)
            self.extraBtnTxt.text = element.content
            local rid = element.rid
            local platform = element.platform
            local zone_id = element.zoneId
            self.extraBtn.onClick:AddListener(function()
                                                if RoleManager.Instance.RoleData.lev >= 40 then
                                                    TeamManager.Instance:JoinRecruitTeam(rid, platform, zone_id)
                                                    -- TeamManager.Instance:Send11724(rid, platform, zone_id)
                                                else
                                                    NoticeManager.Instance:FloatTipsByString(TI18N("当前还没足够能力帮助他人，先提升等级吧{face_1,18}"))
                                                end
                                            end)
        elseif MessageParser.ContainTag(self.msgData.elements, "panel_3") ~= nil then
            local element = MessageParser.ContainTag(self.msgData.elements, "panel_3")
            self.extraBtnObj:SetActive(true)
            self.extraBtnTxt.text = element.content
            self.extraBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(element.panelId) end)
        elseif MessageParser.ContainTag(self.msgData.elements, "unit_4") ~= nil then
            local element = MessageParser.ContainTag(self.msgData.elements, "unit_4")
            local battleId = element.battleId
            local unitId = element.unitId
            local unitBaseId = element.unitBaseId
            local key = BaseUtils.get_unique_npcid(unitId, battleId)

            self.holdAction = nil

            self.extraBtnObj:SetActive(true)
            self.extraBtnTxt.text = TI18N("前往")

            local func = function()
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_PathToTarget(key)

                if battleId == 32 then
                    -- 捉迷藏处理
                    SummerManager.Instance:request14037(unitBaseId)
                end
            end
            self.extraBtn.onClick:AddListener(func)
        elseif self.data.showType == MsgEumn.ChatShowType.CrossArena then
            self.contentTxt.text = self.msgData.pureString
            self.extraBtnObj:SetActive(true)
            self.extraBtnTxt.text = TI18N("查看")

            self.extraBtn.onClick:AddListener(function() CrossArenaManager.Instance:Send20729(self.data.r_crossarena_roomid) end)
        end

        if showName ~= "" then
            if isGm and isDirector == false then
                self.msgData.pureString = string.format("%s[GM]:%s", showName, self.msgData.pureString)
                self.wholeOffsetChar = #StringHelper.ConvertStringTable(string.format("%s[GM]:", showName))
                showName = string.format("%s<color='#df3435'>[GM]</color>", showName)
            elseif isGm == false and isDirector then
                self.msgData.pureString = string.format("%s[%s]:%s", showName, TI18N("指导员"), self.msgData.pureString)
                self.wholeOffsetChar = #StringHelper.ConvertStringTable(string.format("%s[%s]:", showName, TI18N("指导员")))
                showName = string.format("%s<color='#ff00ff'>[%s]</color>", showName, TI18N("指导员"))
            else
                self.msgData.pureString = string.format("%s:%s", showName, self.msgData.pureString)
                self.wholeOffsetChar = #StringHelper.ConvertStringTable(string.format("%s:", showName))
            end
            self.msgData.showString = string.format("%s:<color='%s'>%s</color>", showName, MsgEumn.ChannelColor[data.channel], self.msgData.showString)
            self.contentTxt.text = self.msgData.pureString

            NoticeManager.Instance.model.calculator:ChangeFoneSize(17)
            self.wholeOffsetX = NoticeManager.Instance.model.calculator:SimpleGetWidth(string.format("%s:", showName))
        else
            self.msgData.showString = string.format("<color='%s'>%s</color>", MsgEumn.ChannelColor[data.channel], self.msgData.showString)
            self.contentTxt.text = self.msgData.pureString
        end
    end

    -- 处理点击消息进入对应大面板频道
    local channel = data.channel
    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function() self:OnClick() end)

    for k,v in pairs(self.msgData.atTab) do
        local lastTime = ChatManager.Instance.atLimitTab[k]
        if lastTime == nil or (lastTime ~= nil and BaseUtils.BASE_TIME - lastTime >= 60) then
            ChatManager.Instance.atLimitTab[k] = BaseUtils.BASE_TIME
            NoticeManager.Instance:FloatTipsByString(v)
        end
    end
    self.msgData.atTab = {}

    self:Layout()
end

function ChatMiniItem:Layout()
    self.gameObject:SetActive(true)
    local width = math.ceil(self.contentTxt.preferredWidth)
    if width > self.txtMaxWidth then
        width = self.txtMaxWidth
    end

    -- 因为宽高都是动态变的，要宽确定下来了才能知道高，所以这里要sizeDelta两次
    self.contentRect.sizeDelta = Vector2(width, 22)
    local height = math.ceil(self.contentTxt.preferredHeight)
    self.contentRect.sizeDelta = Vector2(width, height)

    self:Generator()

    self.extraWidth = 0
    self.extraHeight = 0
    local btnX = 0
    local btnY = 0
    if self.extraBtnObj.activeSelf then
        -- local line = math.ceil(self.msgData.allWidth / self.txtMaxWidth)
        -- if self.msgData.allWidth + 60 < self.txtMaxWidth + 20 then
        --     self.extraWidth = 60
        -- end
        -- if self.msgData.allWidth + 60 > (self.txtMaxWidth * line + 20) then
        --     self.extraHeight = 24
        -- end
        btnX = self.lastCharPos.x
        btnY = self.lastCharPos.y

        -- local origin = 960 / 540
        -- local currentScale = ctx.ScreenWidth / ctx.ScreenHeight
        -- local cw = 0
        -- local ch = 0
        -- if currentScale > origin then
        --     -- 以宽为准
        --     cw = 960 * currentScale / origin
        --     ch = 540
        -- else
        --     -- 以高为准
        --     cw = 960
        --     ch = 540 * origin / currentScale
        -- end
        -- btnX = btnX * cw / ctx.ScreenWidth

        if btnX + 60 > self.txtMaxWidth + 20 then--按钮超过背景界面需要换行
            self.extraHeight = 24
            btnX = 0
            btnY = btnY - self.lineSpace
        end
    end

    -- 总大小
    self.selfWidth = 59 + width + self.extraWidth
    self.selfHeight = height + 5 + self.extraHeight - self.btnOffestY
    self.rect.sizeDelta = Vector2(self.selfWidth, self.selfHeight)

    if self.data ~= nil then
        if self.data.showType == MsgEumn.ChatShowType.Voice then
            self.voiceIconRect.anchoredPosition = Vector2(self.contentRect.anchoredPosition.x + self.wholeOffsetX, -2)
        elseif self.data.showType == MsgEumn.ChatShowType.Redpack then
            self.redpackRect.anchoredPosition = Vector2(self.contentRect.anchoredPosition.x + self.wholeOffsetX, -2)
        elseif self.data.showType == MsgEumn.ChatShowType.Match then
            self.extraBtnRect.anchoredPosition = Vector2(btnX + 59, -2 + self.btnOffestY + btnY)
        else
            self.extraBtnRect.anchoredPosition = Vector2(btnX + 59, -2 + self.btnOffestY + btnY)
        end
    end
end

function ChatMiniItem:OnClick()
    if self.data.showType == MsgEumn.ChatShowType.Voice then
        ChatManager.Instance.model:PlayVoice(self.data)
    elseif self.data.showType == MsgEumn.ChatShowType.Redpack then
        if self.data.channel == MsgEumn.ChatChannel.Guild then
            GuildManager.Instance:request11132(self.data.rid, self.data.zone_id, self.data.platform)
        elseif self.data.channel == MsgEumn.ChatChannel.World then
            RedBagManager.Instance.model:OpenRedBag(self.data.rid, self.data.zone_id, self.data.platform)
        end
    else
        if self.data.prefix == MsgEumn.ChatChannel.Hearsay then
            ChatManager.Instance.model:ShowChatWindow({MsgEumn.ChatChannel.World})
        else
            if self.data.channel == MsgEumn.ChatChannel.MixWorld then
                if RoleManager.Instance.RoleData.cross_type == 1 then
                    ChatManager.Instance.model:ShowChatWindow({self.data.channel})
                else
                    ChatManager.Instance.model:ShowChatWindow({MsgEumn.ChatChannel.World})
                end
            else
                ChatManager.Instance.model:ShowChatWindow({self.data.channel})
            end
        end
    end
end
