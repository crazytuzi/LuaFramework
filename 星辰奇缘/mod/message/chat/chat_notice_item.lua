-- ------------------------------
-- 聊天大界面里面的消息提示项
-- hosr
-- ------------------------------
ChatNoticeItem = ChatNoticeItem or BaseClass(MsgItem)

function ChatNoticeItem:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = mainPanel.container

    self.data = nil
        -- 文本最大宽度
    self.txtMaxWidth = 280
    -- 文本每行的高度
    self.lineSpace = 22

    self.selfWidth = 0
    self.selfHeight = 0
    self.extraWidth = 0
    self.extraHeight = 0
    self.extraWidth = 0
    self.extraHeight = 0

    self:InitPanel()
    self.wholeOffsetX = 0

    self.needTime = false
end

function ChatNoticeItem:__delete()
    self.mainPanel = nil
    self.parent = nil
    self.data = nil
    self.txtMaxWidth = nil
    self.lineSpace = nil
    self.selfWidth = nil
    self.selfHeight = nil
    self.extraWidth = nil
    self.extraHeight = nil
    self.extraWidth = nil
    self.extraHeight = nil
    self.wholeOffsetX = nil

    self.transform = nil
    self.rect = nil
    self.prefixImg = nil
    self.prefixRect = nil
    self.contentTxt = nil
    self.contentRect = nil
    self.contentTrans = nil
    self.buttonObj = nil
    self.buttonTxt = nil
    self.buttonRect = nil
end

function ChatNoticeItem:InitPanel()
    self.gameObject = GameObject.Instantiate(self.mainPanel.baseNoticeItem)
    self.transform = self.gameObject.transform
    self.gameObject.name = "ChatNoticeItem"
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.transform.localPosition = Vector3.zero

    self.prefixImg = self.transform:Find("PrefixImg"):GetComponent(Image)
    self.prefixRect = self.prefixImg.gameObject:GetComponent(RectTransform)
    self.contentTxt = self.transform:Find("Text"):GetComponent(Text)
    self.contentRect = self.transform:Find("Text"):GetComponent(RectTransform)
    self.contentTrans = self.contentTxt.gameObject.transform

    self.buttonObj = self.transform:Find("Btn").gameObject
    self.buttonRect = self.buttonObj:GetComponent(RectTransform)
    self.buttonRect.anchoredPosition = Vector2(-10, 5)
    -- self.buttonRect.pivot = Vector2(0, 1)
    -- self.buttonRect.anchorMax = Vector2(0, 1)
    -- self.buttonRect.anchorMin = Vector2(0, 1)
    self.button = self.buttonObj:GetComponent(Button)
    self.buttonTxt = self.buttonObj.transform:Find("Text"):GetComponent(Text)
    self.buttonObj:SetActive(false)

    self.timeObj = self.transform:Find("TimeBackground").gameObject
    self.timeBgRect = self.transform:Find("TimeBackground"):GetComponent(RectTransform)
    self.timeTxt = self.transform:Find("TimeBackground/Time"):GetComponent(Text)

    self.gameObject:SetActive(false)
end

function ChatNoticeItem:Reset()
    self.needDelete = false
    self:HideImg()
    self:AnchorTop()
    self.contentTxt.text = ""
    self.contentRect.sizeDelta = Vector2(self.txtMaxWidth, self.lineSpace)
    self.wholeOffsetX = 0
    self.extraWidth = 0
    self.extraHeight = 0
    self.buttonObj:SetActive(false)
    self.button.onClick:RemoveAllListeners()
end

function ChatNoticeItem:SetData(data)
    if BaseUtils.is_null(self.gameObject) or BaseUtils.is_null(self.contentTxt) then
        return
    end

    self.extraWidth = 0
    self.extraHeight = 0
    self.showType = data.showType
    self.data = data
    self.contentTxt.text = ""
    self.contentRect.sizeDelta = Vector2(self.txtMaxWidth, self.lineSpace)
    -- self.msgData = data.msgData
    self.msgData = self:GetMsgData(data.msgData.sourceString)
    self.data.msgData = self.msgData

    if data.prefix == 12 then
        if CanYonManager.Instance.self_side == 1 then 
            self.prefixImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, string.format("I18NChannelIcon%s", "camp1"))
        else
            self.prefixImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, string.format("I18NChannelIcon%s", "camp2"))
        end
    else
        self.prefixImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, string.format("I18NChannelIcon%s", data.prefix))
    end
    self.prefixImg.gameObject.transform.localScale = Vector3.one
    self.prefixRect.sizeDelta = Vector2(48, 20)

    self.wholeOffsetX = 0
    -- self:ShowElements(data.msgData.elements)

    -- self.contentTxt.text = self.msgData.showString
    self.contentTxt.text = self.msgData.pureString
    self.buttonObj:SetActive(false)
    self.button.onClick:RemoveAllListeners()
    if self.data.showType == MsgEumn.ChatShowType.Water then
        self.buttonObj:SetActive(true)
        self.buttonTxt.text = TI18N("浇水")
        self.button.onClick:AddListener(function() GuildManager.Instance.model:GoToGuildAreaForWaterFlower(self.data) end)
    elseif self.data.showType == MsgEumn.ChatShowType.MatchWorld then
        self.buttonObj:SetActive(true)
        self.buttonTxt.text = TI18N("加入")
        self.button.onClick:AddListener(function()
            TeamManager.Instance:JoinRecruitTeam(self.data.extraData.rid, self.data.extraData.platform, self.data.extraData.zone_id)
            -- TeamManager.Instance:Send11724(self.data.extraData.rid, self.data.extraData.platform, self.data.extraData.zone_id)
        end)
    elseif self.data.extraData ~= nil and (self.data.extraData.helpId == 4 or self.data.extraData.helpId == 5) then
        -- print("公会求助4/好友求助5")
        self.buttonObj:SetActive(true)
        self.buttonTxt.text = TI18N("帮助")
        -- local s = self.data
        self.button.onClick:AddListener(function()
            BibleManager.Instance.model:OpenToHelpWin(self.data)
        end)
    elseif self.data.showType == MsgEumn.ChatShowType.QuestHelp then
        self.buttonObj:SetActive(true)
        self.buttonTxt.text = TI18N("帮助")

        self.button.onClick:AddListener(function() SosManager.Instance:Send16003(self.data.extraData.id) end)
    elseif MessageParser.ContainTag(self.msgData.elements, "ship_1") ~= nil then
        local element = MessageParser.ContainTag(self.msgData.elements, "ship_1")
        self.buttonObj:SetActive(true)
        self.buttonTxt.text = TI18N("帮助")
        local rid = element.rid
        local platform = element.platform
        local zone_id = element.zoneId
        local cell_id = element.cellId
        local name = element.content
        self.button.onClick:AddListener(
            function()
                local shipData = {role_id = rid, platform = platform, zone_id = zone_id, cell_id = cell_id, name = name}
                ShippingManager.Instance.guildhelp_info = shipData
                ShippingManager.Instance:Req13710(1, rid, platform, zone_id, cell_id)
            end)
    elseif MessageParser.ContainTag(self.msgData.elements, "team_1") ~= nil then
        local element = MessageParser.ContainTag(self.msgData.elements, "team_1")
        self.buttonObj:SetActive(true)
        self.buttonTxt.text = element.content
        local rid = element.rid
        local platform = element.platform
        local zone_id = element.zoneId
        self.button.onClick:AddListener(function()
                                            if RoleManager.Instance.RoleData.lev >= 40 then
                                                TeamManager.Instance:JoinRecruitTeam(rid, platform, zone_id)
                                                -- TeamManager.Instance:Send11724(rid, platform, zone_id)
                                            else
                                                NoticeManager.Instance:FloatTipsByString(TI18N("当前还没足够能力帮助他人，先提升等级吧{face_1,18}"))
                                            end
                                        end)
    elseif MessageParser.ContainTag(self.msgData.elements, "panel_3") ~= nil then
        local element = MessageParser.ContainTag(self.msgData.elements, "panel_3")
        self.buttonObj:SetActive(true)
        self.buttonTxt.text = element.content
        self.button.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(element.panelId) end)
    elseif self.data.showType == MsgEumn.ChatShowType.TrialHelp then
        self.buttonObj:SetActive(true)
        self.buttonTxt.text = TI18N("帮助")
        local rid = self.data.extraData.rid
        local platform = self.data.extraData.platform
        local zone_id = self.data.extraData.zone_id
        local type = self.data.extraData.type
        self.button.onClick:AddListener(function() TrialManager.Instance:Send13107(rid, platform, zone_id, type) end)
    elseif self.data.showType == MsgEumn.ChatShowType.TeamDungeon then
        self.buttonObj:SetActive(true)
        self.buttonTxt.text = TI18N("加入")
        local rid = self.data.extraData.rid
        local platform = self.data.extraData.platform
        local zone_id = self.data.extraData.zone_id
        local type = self.data.extraData.type
        self.button.onClick:AddListener(function() TrialManager.Instance:Send13107(rid, platform, zone_id, type) end)
    elseif self.data.showType == MsgEumn.ChatShowType.CrossArena then
        self.buttonObj:SetActive(true)
        self.buttonTxt.text = TI18N("查看")
        self.button.onClick:AddListener(function() CrossArenaManager.Instance:Send20729(self.data.r_crossarena_roomid) end)
        self.holdAction = nil
    end

    self.msgData.showString = string.format("<color='%s'>%s</color>", MsgEumn.ChannelColor[self.data.channel], self.msgData.showString)
    self.needTime = false
    local lastTime = ChatManager.Instance.lastMsgTime[self.mainPanel.channel]
    local nowTime = BaseUtils.BASE_TIME
    if nowTime - lastTime > ChatManager.Instance.spaceTime and lastTime ~= 0 then
        self.needTime = true
        self.timeTxt.text = tostring(os.date("%H:%M", lastTime))
    end
    ChatManager.Instance.lastMsgTime[self.mainPanel.channel] = nowTime

    self:Layout()
end

function ChatNoticeItem:Layout()
    self.gameObject:SetActive(true)
    local width = math.ceil(self.contentTxt.preferredWidth)
    if width > self.txtMaxWidth then
        width = self.txtMaxWidth
    end
    -- 第一次确定宽度，第二次以宽度来确定高度
    self.contentRect.sizeDelta = Vector2(width, math.ceil(self.contentTxt.preferredHeight))
    local height = math.ceil(self.contentTxt.preferredHeight)
    self.contentRect.sizeDelta = Vector2(width, height)

    self.extraWidth = 0
    self.extraHeight = 0
    -- if self.buttonObj.activeSelf then
    --     local line = math.ceil(self.msgData.allWidth / self.txtMaxWidth)
    --     if self.msgData.allWidth + 60 > (self.txtMaxWidth * line + 20) then
    --         self.extraWidth = 0
    --         self.extraHeight = 24
    --     end
    -- end
    if self.buttonObj.activeSelf then
        -- if self.lastCharPos.x + 60 > self.txtMaxWidth + 20 then
        if self.lastCharPos.x + 60 > self.txtMaxWidth + 5 then
            self.extraHeight = 24
        elseif width + 60 < self.txtMaxWidth then
            self.extraWidth = 60
        end
    end

    -- 总大小
    self.selfWidth = width + 55 + self.extraWidth

    if self.needTime then
        self.timeBgRect.anchoredPosition = Vector2((350 - self.selfWidth) / 2, 0)
        self.timeObj:SetActive(true)
        self.selfHeight = height + 10 + self.extraHeight + 24
    else
        self.timeObj:SetActive(false)
        self.selfHeight = height + 10 + self.extraHeight
    end

    self.rect.sizeDelta = Vector2(self.selfWidth + 10, self.selfHeight)

    self:Generator()
end
