-- ----------------------------
-- 聊天大面板人物说话用
-- hosr
-- ----------------------------

ChatItem = ChatItem or BaseClass(MsgItem)

function ChatItem:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = mainPanel.container

    self.extraWidth = 0
    self.extraHeight = 0
    -- 文本最大宽度
    self.txtMaxWidth = 250
    -- 文本每行的高度
    self.lineSpace = 22

    self.selfWidth = 0
    self.selfHeight = 0
    self.miniHeight = 40
    self.nameOffestX = 0

    self.headSlot = nil

    self.selfColor = Color(175/255,234/255,1,1)
    self.otherColor = Color(1,1,1,1)

    self.needTime = false

    self:InitPanel()

    self.holdAction = nil

    self.isHoldHead = false
end

function ChatItem:__delete()
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end

    self.mainPanel = nil
    self.parent = nil
    self.extraWidth = nil
    self.extraHeight = nil
    self.txtMaxWidth = nil
    self.lineSpace = nil
    self.selfWidth = nil
    self.selfHeight = nil
    self.miniHeight = nil

    self.selfColor = nil
    self.otherColor = nil

    self.msgData = nil
    self.data = nil
    self.transform = nil
    self.rect = nil
    self.headImg = nil
    self.levelTxt = nil
    self.nameTxt = nil
    self.msgButton = nil
    self.msgBgRect = nil
    self.voiceIcon = nil
    self.voiceTimeTxt = nil
    self.redpackIcon = nil
    self.extraBtnObj = nil
    self.extraBtnRect = nil
    self.extraBtn = nil
    self.contentTxt = nil
    self.msgTxtRect = nil
    self.contentRect = nil
    self.contentTrans = nil
    self.timeBgRect = nil
    self.timeTxt = nil
    self.hasImgObj = nil
    self.hasImgBtn = nil
    self.hasImgRect = nil
end

function ChatItem:InitPanel()
    self.gameObject = GameObject.Instantiate(self.mainPanel.baseChatItem)
    self.gameObject.name = "ChatItem"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.rect = self.gameObject:GetComponent(RectTransform)

    if self.transform:Find("HeadIconBackground"):GetComponent(Button) ~= nil then
        self.transform:Find("HeadIconBackground"):GetComponent(Button).onClick:AddListener(function() self:ClickHead() end)
    end

    if self.transform:Find("HeadIconBackground"):GetComponent(CustomButton) ~= nil then
        self.transform:Find("HeadIconBackground"):GetComponent(CustomButton).onClick:AddListener(function() self:ClickHead() end)
        self.transform:Find("HeadIconBackground"):GetComponent(CustomButton).onHold:AddListener(function() self:HoldHead() end)
        self.transform:Find("HeadIconBackground"):GetComponent(CustomButton).onDown:AddListener(function() self:DownHead() end)
        self.transform:Find("HeadIconBackground"):GetComponent(CustomButton).onUp:AddListener(function() self:UpHead() end)
    end
    self.HeadIconBackground = self.transform:Find("HeadIconBackground")
     self.HeadIconBackgroundImg = self.transform:Find("HeadIconBackground"):GetComponent(Image)
    self.MessageBackground = self.transform:Find("MessageBackground")
    self.TimeBackground = self.transform:Find("MessageBackground")

    self.headImg = self.transform:Find("HeadIconBackground/HeadIcon"):GetComponent(Image)
    self.headFrame = self.transform:Find("HeadIconBackground/Frame"):GetComponent(Image)
    self.levelTxt = self.transform:Find("HeadIconBackground/Level"):GetComponent(Text)
    self.levelBg = self.transform:Find("HeadIconBackground/LevelBackground").gameObject
    self.nameTxt = self.transform:Find("Name"):GetComponent(Text)
    self.nameRect = self.transform:Find("Name"):GetComponent(RectTransform)
    self.nameTxt.supportRichText = true
    self.msgButton = self.transform:Find("MessageBackground"):GetComponent(CustomButton)
    self.msgBg = self.transform:Find("MessageBackground"):GetComponent(Image)
    self.msgBgTransform = self.msgBg.gameObject.transform
    self.msgBgRect = self.transform:Find("MessageBackground"):GetComponent(RectTransform)
    self.voiceIcon = self.transform:Find("MessageBackground/Voice").gameObject
    self.voiceTimeTxt = self.transform:Find("MessageBackground/Voice/Text"):GetComponent(Text)
    self.redpackIcon = self.transform:Find("MessageBackground/Redpack").gameObject
    self.redpackIcon:SetActive(false)
    self.extraBtnObj = self.transform:Find("MessageBackground/Btn").gameObject
    self.extraBtn = self.extraBtnObj:GetComponent(Button)
    self.extraBtnRect = self.extraBtnObj:GetComponent(RectTransform)
    self.extraBtnTxt = self.extraBtnObj.transform:Find("Text"):GetComponent(Text)
    self.extraBtnTxt.text = TI18N("加入")
    self.extraBtnObj:SetActive(false)
    self.contentTxt = self.transform:Find("MessageBackground/Message"):GetComponent(Text)
    self.contentTxt.verticalOverflow = VerticalWrapMode.Overflow
    self.msgTxtRect = self.contentTxt.gameObject:GetComponent(RectTransform)
    self.contentTrans = self.contentTxt.gameObject.transform
    self.timeObj = self.transform:Find("TimeBackground").gameObject
    self.timeBgRect = self.transform:Find("TimeBackground"):GetComponent(RectTransform)
    self.timeTxt = self.transform:Find("TimeBackground/Time"):GetComponent(Text)
    self.hasImgObj = self.transform:Find("HasImg").gameObject
    self.hasImgRect = self.hasImgObj:GetComponent(RectTransform)
    self.hasImgBtn = self.transform:Find("HasImg"):GetComponent(Button)
    self.hasImgBtn.onClick:AddListener(function() self:ClickHasImg() end)
    self.hasImgObj:SetActive(false)
    self.markObj = self.transform:Find("Mark").gameObject
    self.markRect = self.markObj:GetComponent(RectTransform)
    self.markObj:SetActive(false)
    self.markImg = self.markObj:GetComponent(Image)
    self.markBtn = self.markObj:GetComponent(Button)
    self.markBtn.onClick:AddListener(function() self:ClickMark() end)

    self.SysMsg = self.transform:Find("SysMsg")
    if self.SysMsg ~= nil then
        self.SysMsgText = self.transform:Find("SysMsg/Text"):GetComponent(Text)
    end

    self.contentTxt.text = ""
    self.msgTxtRect.sizeDelta = Vector2(255, self.lineSpace)

    self.voiceIcon:SetActive(false)
    self.headImg.gameObject:SetActive(true)

    self.gameObject:SetActive(false)

    -- self.msgButton.onHold:AddListener(function() self:OnHold() end)
    -- self.msgButton.onUp:AddListener(function() self:OnUp() end)

    self.headSlot = HeadSlot.New(nil,true)
    self.headSlot:SetRectParent(self.headImg.gameObject)
end

function ChatItem:Reset()
    self.needDelete = false
    if self.data ~= nil and self.data.showType == MsgEumn.ChatShowType.Voice then
        ChatManager.Instance.model:DelAudioClip(self.data.cacheId, self.data.platform, self.data.zone_id)
    end
    self:HideImg()
    self:AnchorTop()
    self.msgData = nil
    self.data = nil
    self.contentTxt.text = ""
    self.msgTxtRect.sizeDelta = Vector2(255, self.lineSpace)
    self.wholeOffsetX = 0
    self.wholeOffsetChar = 0
    self.nameOffestX = 0
    self.posxDic = {}
    self.posyDic = {}
end

function ChatItem:SetData(data)
    -- BaseUtils.dump(data,"ChatItem:SetData(data) = ")
    local uniqueid = BaseUtils.get_unique_roleid(data.rid, data.zone_id, data.platform)

    self.showType = data.showType
    self.data = BaseUtils.copytab(data)
    self.msgData = self:GetMsgData(data.msgData.sourceString)
    self.data.msgData = self.msgData
    local name_str = self.data.name
    local levbreak = 0
    if self.data.special ~= nil then
        for i,v in ipairs(self.data.special) do
            if v.type == MsgEumn.SpecialType.label then
                if v.val == 1 then
                    name_str = string.format("%s<color='#df3435'>[GM]</color>", name_str)
                elseif v.val == 2 then
                    name_str = string.format("%s<color='#ff00ff'>[%s]</color>", name_str, TI18N("指导员"))
                end
            elseif v.type == MsgEumn.SpecialType.LevBreak then
                levbreak = v.val
            end
        end
    end



    self.nameTxt.text = name_str

    local dat = {id = data.rid, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}

    if self.mainPanel.channel == MsgEumn.ChatChannel.Guild then
        -- 公会频道显示人物职位
        self.nameTxt.text = ChatManager.Instance:AppendGuildPost(name_str, data.rid, data.platform, data.zone_id)
        dat = {id = data.rid, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}
    elseif self.mainPanel.channel == MsgEumn.ChatChannel.Private then
        if data.isself then
            dat = {id = RoleManager.Instance.RoleData.id, platform = RoleManager.Instance.RoleData.platform, zone_id = RoleManager.Instance.RoleData.zone_id, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex}
        else
            dat = {id = data.id, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}
        end
    end

    self.levelTxt.gameObject:SetActive(true)
    self.levelBg:SetActive(true)
    if levbreak == 0 then
        self.levelTxt.text = tostring(self.data.lev)
    else
        self.levelTxt.text = string.format("<color='#31f2f9'>%s</color>", tostring(self.data.lev))
    end

    -- self.headImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", self.data.classes, self.data.sex))
    self.headImg.enabled = false

    self.headSlot:HideSlotBg(true)
    local myData = PortraitManager.Instance:GetInfos(dat.id, dat.platform, dat.zone_id)

    if myData ~= nil and myData[5] ~= nil then
        self.HeadIconBackgroundImg.enabled = false
    else
        self.HeadIconBackgroundImg.enabled = true
    end
    self.headSlot:SetAll(dat, {isSmall = true, clickCallback = function() self:ClickHead() end,myCallBack = function(myNewData)
        if not BaseUtils.isnull(self.HeadIconBackgroundImg) then
            if myNewData ~= nil and myNewData[5] ~= nil then
                    self.HeadIconBackgroundImg.enabled = false
            else
                    self.HeadIconBackgroundImg.enabled = true
            end
        end
    end
    })



    self.needTime = false
    local lastTime = ChatManager.Instance.lastMsgTime[self.mainPanel.channel]
    local nowTime = BaseUtils.BASE_TIME
    if data.recvTime ~= nil then
        nowTime = data.recvTime
    end
    if nowTime - lastTime > ChatManager.Instance.spaceTime and lastTime ~= 0 then
        self.needTime = true
        self.timeTxt.text = tostring(os.date("%H:%M", nowTime))
    end
    ChatManager.Instance.lastMsgTime[self.mainPanel.channel] = nowTime

    if data.group_id ~= nil and data.rid == 0 and self.SysMsg ~= nil then
        self.HeadIconBackground.gameObject:SetActive(false)
        self.MessageBackground.gameObject:SetActive(false)
        self.TimeBackground.gameObject:SetActive(false)
        self.nameTxt.gameObject:SetActive(false)
        self.hasImgObj:SetActive(false)
        self.markObj:SetActive(false)

        self.SysMsg.anchoredPosition = Vector2(0, 0)
        self.SysMsg.gameObject:SetActive(true)
        self.SysMsgText.text = data.msgData.sourceString
        self.SysMsg.sizeDelta = Vector2(self.SysMsgText.preferredWidth + 30, 32)
        self:Layout()
        return
    elseif self.SysMsg ~= nil then
        if not self.HeadIconBackground.gameObject.activeSelf then
            self.SysMsg.gameObject:SetActive(false)
            self.HeadIconBackground.gameObject:SetActive(true)
            self.MessageBackground.gameObject:SetActive(true)
            self.TimeBackground.gameObject:SetActive(true)
            self.nameTxt.gameObject:SetActive(true)
            self.hasImgObj:SetActive(true)
            self.markObj:SetActive(true)
        end
    end

    self.extraWidth = 0
    self.extraHeight = 0
    self.miniHeight = 0
    self.wholeOffsetChar = 0

    -- self.holdAction = function() self:FxxkHim() end
    self.holdAction = nil

    self.msgButton.onClick:RemoveAllListeners()
    self.voiceIcon:SetActive(false)
    self.redpackIcon:SetActive(false)
    self.extraBtnObj:SetActive(false)
    self.extraBtn.onClick:RemoveAllListeners()
    self.txtMaxWidth = 250
    if self.data.showType == MsgEumn.ChatShowType.Voice then
        self.voiceIcon:SetActive(true)
        self.voiceTimeTxt.text = string.format("%ss", self.data.time)
        self.extraHeight = 20
        self.msgButton.onClick:AddListener(function() self:ClickMsg() end)
    elseif self.data.showType == MsgEumn.ChatShowType.Redpack then
        self.extraWidth = 35
        self.miniHeight = 40
        self.redpackIcon:SetActive(true)
        self.txtMaxWidth = 220
        self.msgButton.onClick:AddListener(function() self:ClickMsg() end)
        self.holdAction = nil
    elseif MessageParser.ContainTag(self.msgData.elements, "flower_1") ~= nil then
        local element = MessageParser.ContainTag(self.msgData.elements, "flower_1")
        self.extraBtnObj:SetActive(true)
        self.extraBtnTxt.text = TI18N("浇水")
        local idata = {unitId = element.unitId, battleId = element.battleId}
        self.msgButton.onClick:AddListener(function() GuildManager.Instance.model:GoToGuildAreaForWaterFlower(idata) end)
        self.extraBtn.onClick:AddListener(function() GuildManager.Instance.model:GoToGuildAreaForWaterFlower(idata) end)
        self.holdAction = nil
    elseif MessageParser.ContainTag(self.msgData.elements, "ship_1") ~= nil then
        local element = MessageParser.ContainTag(self.msgData.elements, "ship_1")
        local rid = element.rid
        local platform = element.platform
        local zone_id = element.zoneId
        local cell_id = element.cellId
        local name = element.content
        self.msgButton.onClick:AddListener(
            function()
                local shipData = {role_id = rid, platform = platform, zone_id = zone_id, cell_id = cell_id, name = name}
                ShippingManager.Instance.guildhelp_info = shipData
                ShippingManager.Instance:Req13710(2, rid, platform, zone_id, cell_id)
            end)
        self.holdAction = nil
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
        self.msgButton.onClick:AddListener(func)
        self.extraBtn.onClick:AddListener(func)
    elseif MessageParser.ContainTag(self.msgData.elements, "panel_3") ~= nil then
        local element = MessageParser.ContainTag(self.msgData.elements, "panel_3")
        self.extraBtnTxt.text = element.content
        self.extraBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(element.panelId) end)
        self.holdAction = nil
    elseif self.data.showType == MsgEumn.ChatShowType.TrialHelp then
        local rid = self.data.rid
        local platform = self.data.platform
        local zone_id = self.data.zone_id
        local type = self.data.type
        self.msgButton.onClick:AddListener(function()
                            FriendManager.Instance.model:CloseMain()
                            TrialManager.Instance:Send13107(rid, platform, zone_id, type)
                        end)
        self.holdAction = nil
    elseif self.data.showType == MsgEumn.ChatShowType.TeamDungeon then
        local rid = self.data.rid
        local platform = self.data.platform
        local zone_id = self.data.zone_id
        local type = self.data.type
        self.msgButton.onClick:AddListener(function()
                            FriendManager.Instance.model:CloseMain()
                            TrialManager.Instance:Send13107(rid, platform, zone_id, type)
                        end)
        self.holdAction = nil
    -- elseif self.data.showType == MsgEumn.ChatShowType.MatchWorld then
    elseif MessageParser.ContainTag(self.msgData.elements, "match_1") ~= nil then
        local element = MessageParser.ContainTag(self.msgData.elements, "match_1")
        self.extraBtnTxt.text = TI18N("加入")
        self.extraBtnObj:SetActive(true)

        local func = function()
            TeamManager.Instance:JoinRecruitTeam(element.rid, element.platform, element.zoneId)
            -- TeamManager.Instance:Send11724(element.rid, element.platform, element.zoneId)
        end

        if func ~= nil then
            self.msgButton.onClick:AddListener(func)
            self.extraBtn.onClick:AddListener(func)
        end
        self.holdAction = nil
    elseif self.data.showType == MsgEumn.ChatShowType.QuestHelp then
        self.extraBtnTxt.text = TI18N("帮助")
        self.extraBtnObj:SetActive(true)

        local func = nil
        if self.data.extraData.helpId == 5 or self.data.extraData.helpId == 4 then
            if self.data.msgData ~= nil and self.data.msgData.elements ~= nil and self.data.msgData.elements[1] ~= nil then
                func = function() BibleManager.Instance.model:OpenToHelpWin(self.data) end
            else
                func = function() NoticeManager.Instance:FloatTipsByString(TI18N("该求助信息已失效 !")) end
            end
        else
            local temp_cfg_data = DataHelp.data_help[self.data.extraData.helpId]
            if temp_cfg_data ~=nil and temp_cfg_data.fun_type == SosEumn.FuncType.FruitPlant then
                func = function() SosManager.Instance:Send16003(self.data.extraData.id) end
                func = function() SosManager.Instance:Send16003(self.data.extraData.id) end
            end
        end

        if func ~= nil then
            self.msgButton.onClick:AddListener(func)
            self.extraBtn.onClick:AddListener(func)
        end

        self.holdAction = nil
    elseif self.data.extraData ~= nil and (self.data.extraData.helpId == 5 or self.data.extraData.helpId == 4) then
        if self.data.msgData ~= nil and self.data.msgData.elements ~= nil and self.data.msgData.elements[1] ~= nil then
            self.msgButton.onClick:AddListener(function()
                                BibleManager.Instance.model:OpenToHelpWin(self.data)
                            end)
        else
            self.msgButton.onClick:AddListener(function()
                                NoticeManager.Instance:FloatTipsByString(TI18N("该求助信息已失效 !"))
                            end)
        end
        self.holdAction = nil
    elseif MessageParser.ContainTag(self.msgData.elements, "crossarena_3") ~= nil then
        self.data.showType = MsgEumn.ChatShowType.CrossArena

        local element = MessageParser.ContainTag(self.msgData.elements, "crossarena_3")
        self.extraBtnObj:SetActive(true)
        self.extraBtnTxt.text = TI18N("查看")
        self.msgButton.onClick:AddListener(function() CrossArenaManager.Instance:Send20729(element.cross_arena_room_id) end)
        self.extraBtn.onClick:AddListener(function() CrossArenaManager.Instance:Send20729(element.cross_arena_room_id)  end)
        self.holdAction = nil
    end

    self.contentTxt.text = self.msgData.pureString

    if self.data.showType == MsgEumn.ChatShowType.Redpack then
        self.msgBg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, "ChatRedpackBg")
        self.msgBg.color = self.otherColor
    else
        self.msgBg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, "ChatItemBg1")
        if uniqueid == BaseUtils.get_self_id() then
            self.msgBg.color = self.selfColor
        else
            self.msgBg.color = self.otherColor
        end
    end

    -- self.data.special = {{type = MsgEumn.SpecialType.Picture, val = 1}}
    self.hasImgObj:SetActive(false)
    self.markObj:SetActive(false)
    self.headFrame.gameObject:SetActive(false)
    if self.data.special ~= nil then
        for i,v in ipairs(self.data.special) do
            if v.type == MsgEumn.SpecialType.Picture and v.val == 1 then
                -- 空间照片可查看
                self.hasImgObj:SetActive(true)
            elseif v.type == MsgEumn.SpecialType.Frame then
                self.headFrame.sprite = PreloadManager.Instance:GetSprite(AssetConfig.rolelev_frame, tostring(v.val))
                self.headFrame.gameObject:SetActive(true)
            elseif v.type == MsgEumn.SpecialType.prefix then
                self.markRect.anchoredPosition = Vector2(70, 0)
                self.markObj:SetActive(true)
                self.markImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_prefix, tostring(DataAchieveShop.data_list[v.val].source_id))
                local size = self.markImg.sprite.textureRect.size
                self.nameOffestX = size.x + 4
                self.markRect.sizeDelta = size

                local nameColorData = DataAchieveShop.data_name_color[DataAchieveShop.data_list[v.val].source_id]
                if nameColorData ~= nil then
                    self.nameTxt.text = string.format("<color='%s'>%s</color>", nameColorData.color, self.nameTxt.text)
                end
                -- if v.val == 501 then
                --     self.nameOffestX = 56
                --     self.markRect.sizeDelta = Vector2(62, 33)
                -- elseif v.val == 502 then
                --     self.nameOffestX = 78
                --     self.markRect.sizeDelta = Vector2(81, 29)
                -- elseif v.val == 503 then
                --     self.nameOffestX = 56
                --     self.markRect.sizeDelta = Vector2(65, 31)
                -- else
                --     self.nameOffestX = 48
                --     self.markRect.sizeDelta = Vector2(51, 29)
                -- end
            -- elseif v.type == MsgEumn.SpecialType.SingRank then
            --     self.nameOffestX = 56
            --     self.markObj:SetActive(true)
            --     self.markRect.anchoredPosition = Vector2(70, 0)
            --     self.markImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatSing")
            --     self.markRect.sizeDelta = Vector2(62, 33)
            -- elseif v.type == MsgEumn.SpecialType.godswar then --godswar
            --     self.nameOffestX = 78
            --     self.markObj:SetActive(true)
            --     self.markRect.anchoredPosition = Vector2(70, 0)
            --     self.markImg.sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, "I18NChatGodsWar")
            --     self.markRect.sizeDelta = Vector2(81, 29)
            end
        end
    end

    NoticeManager.Instance.model.calculator:ChangeFoneSize(18)
    local nameWidth = NoticeManager.Instance.model.calculator:SimpleGetWidth(self.nameTxt.text)
    self.hasImgRect.anchoredPosition = Vector2(nameWidth + 77 + self.nameOffestX ,0)
    self.nameRect.anchoredPosition = Vector2(self.nameOffestX + 77, 0)

    self:Layout()
end

function ChatItem:Layout()
    self.gameObject:SetActive(true)
    -- 因为宽高都是动态变的，要宽确定下来了才能知道高，所以这里要sizeDelta两次
    local width = math.ceil(math.min(self.txtMaxWidth, self.contentTxt.preferredWidth))
    self.msgTxtRect.sizeDelta = Vector2(width, 22)
    local height = math.ceil(self.contentTxt.preferredHeight)
    self.msgTxtRect.sizeDelta = Vector2(width, height)

    self:Generator()

    local offsetY = 0
    if self.miniHeight > height then
        offsetY = -(self.miniHeight - height) / 2
        height = self.miniHeight
    end

    self.msgTxtRect.anchoredPosition = Vector2(15 + self.extraWidth, -5 - self.extraHeight + offsetY)

    self.msgBgRect.sizeDelta = Vector2(width + 25 + self.extraWidth, height + 10 + self.extraHeight)

    -- 总大小
    self.selfWidth = width + 30 + 65 + self.extraWidth

    if self.needTime then
        self.timeBgRect.anchoredPosition = Vector2((350 - self.selfWidth) / 2, 0)
        self.timeObj:SetActive(true)
        self.selfHeight = height + 10 + 30 + 10 + self.extraHeight + 24
    else
        self.timeObj:SetActive(false)
        self.selfHeight = height + 10 + 30 + 10 + self.extraHeight
    end
    if self.data.group_id ~= nil and self.data.rid == 0 then
        -- BaseUtils.dump(self.data)
        -- if self.needTime then
        --     self.timeBgRect.anchoredPosition = Vector2((350 - self.selfWidth) / 2, 0)
        --     self.timeObj:SetActive(true)
        --     self.selfHeight = height + 10 + 30 + 10 + self.extraHeight + 24
        --     self.rect.sizeDelta = Vector2(407, 40)
        -- else
            self.timeObj:SetActive(false)
            self.rect.sizeDelta = Vector2(407, 40)
        -- end
        return
    end

    self.rect.sizeDelta = Vector2(self.selfWidth + 10, self.selfHeight)
end

function ChatItem:DownHead()
    if self.mainPanel.channel == MsgEumn.ChatChannel.Private then
        return
    end

    if BaseUtils.get_self_id() == BaseUtils.get_unique_roleid(self.data.rid, self.data.zone_id, self.data.platform) or self.data.isself then
        return
    end

    self.isHoldHead = false
    self.mainPanel:OnDown(self)
end

function ChatItem:UpHead()
    if self.mainPanel.channel == MsgEumn.ChatChannel.Private then
        return
    end

    if BaseUtils.get_self_id() == BaseUtils.get_unique_roleid(self.data.rid, self.data.zone_id, self.data.platform) or self.data.isself then
        return
    end

    self.mainPanel:OnUp(self)
end

-- 长按头像添加一个 @xx 前缀
function ChatItem:HoldHead()
    if self.mainPanel.channel == MsgEumn.ChatChannel.Private then
        return
    end

    if BaseUtils.get_self_id() == BaseUtils.get_unique_roleid(self.data.rid, self.data.zone_id, self.data.platform) or self.data.isself then
        return
    end

    self.isHoldHead = true
    local str = string.format("@%s", self.data.name)
    local element = {}
    element.type = MsgEumn.AppendElementType.Prefix1
    element.showString = string.format("@%s ", self.data.name)
    element.sendString = string.format("{prefix_1,%s,%s,%s,%s,%s,%s}", RoleManager.Instance.RoleData.name, self.data.name, self.data.rid, self.data.platform, self.data.zone_id, self.mainPanel.channel)
    element.matchString = str
    ChatManager.Instance:AppendInputElement(element, MsgEumn.ExtPanelType.Chat)
end

function ChatItem:ClickHead()
    if BaseUtils.get_self_id() == BaseUtils.get_unique_roleid(self.data.rid, self.data.zone_id, self.data.platform) or self.data.isself then
        return
    end

    if self.isHoldHead then
        return
    end

    TipsManager.Instance:ShowPlayer(self.data)
end

function ChatItem:ClickMsg()
    -- BaseUtils.dump(self.data)
    if self.data.showType == MsgEumn.ChatShowType.Voice then
        -- 请求语音数据
        ChatManager.Instance.model:PlayVoice(self.data)
    elseif self.data.showType == MsgEumn.ChatShowType.Redpack then
        if self.data.channel == MsgEumn.ChatChannel.Guild then
            GuildManager.Instance:request11132(self.data.rid, self.data.zone_id, self.data.platform)
        elseif self.data.channel == MsgEumn.ChatChannel.World then
            RedBagManager.Instance.model:OpenRedBag(self.data.rid, self.data.zone_id, self.data.platform)
        end
    end
end

function ChatItem:ClickHasImg()
    if self.data ~= nil then
        if self.data.rid ~= 0 then
            ZoneManager.Instance:OpenOtherZone(self.data.rid, self.data.platform, self.data.zone_id)
        else
            ZoneManager.Instance:OpenOtherZone(self.data.id, self.data.platform, self.data.zone_id)
        end
    end
end

function ChatItem:ClickMark()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.achievementshopwindow, {1,5})
end

function ChatItem:OnHold()
    if self.holdAction ~= nil then
        self.holdAction()
    end
end

function ChatItem:OnUp()
    if self.holdAction ~= nil then
        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
            self.timer = nil
        end
        self:HideEffect()
    end
end

function ChatItem:HideEffect()
    ChatManager.Instance.model.chatWindow:HideArrowEffect()
end

-- 长按特效
function ChatItem:HoldEffect()
    ChatManager.Instance.model.chatWindow:ShowArrowEffect(self.msgBgTransform.position, self.msgBgRect.rect.width, self.msgBgRect.rect.height)
end

-- 举报
function ChatItem:FxxkHim()
    self:HoldEffect()
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
    -- self.timer = LuaTimer.Add()
end

function ChatItem:HideLev()
    self.levelTxt.gameObject:SetActive(false)
    self.levelBg:SetActive(false)
end

-- function ChatItem:Delay()
--     local generator = self.contentTxt.cachedTextGeneratorForLayout
--     -- print("####################### begin ##########################")
--     -- print("text=\n" .. self.contentTxt.text)
--     -- print("lineCount=" .. generator.lineCount)
--     local lineDic = {}
--     self.posxDic = {}
--     self.posyDic = {}
--     for i = 1, generator.lineCount do
--         local lineInfo = generator.lines[i - 1]
--         -- UILineInfo
--         -- print("UILineInfo " .. i)
--         -- print("height=" .. lineInfo.height)
--         -- print("line=" .. i .. ",startCharIdx=" .. lineInfo.startCharIdx + 1)
--         table.insert(lineDic, lineInfo.startCharIdx + 1)
--     end

--     function func(idx)
--         for line,startIdx in ipairs(lineDic) do
--             if idx < startIdx then
--                 return line - 1
--             end
--         end
--         return #lineDic
--     end

--     function getWidth(element)
--         local gw = 0
--         for a = element.tagIndex, element.tagEndIndex do
--             gw = gw + generator.characters[a - 1].charWidth
--         end
--         return gw
--     end

--     -- print("characterCount=" .. generator.characterCount)
--     -- for i = 1, generator.characterCount do
--     --     local charInfo = generator.characters[i - 1]
--     --     print("charWidth=" .. charInfo.charWidth)
--     --     print("cursorPos=[" .. charInfo.cursorPos.x .. "," .. charInfo.cursorPos.y .. "]")
--     -- end

--     local needMore = {}
--     for i,element in ipairs(self.msgData.elements) do
--         local idx = element.tagIndex + element.offsetChar
--         local charInfo = generator.characters[idx - 1]
--         local line = func(idx)
--         local height = -self.lineSpace * (line - 1) + element.offsetY
--         local width = charInfo.cursorPos.x + element.offsetX
--         element.width = getWidth(element)
--         -- print("width=" .. width)
--         -- print("height=" .. height)
--         table.insert(self.posxDic, width)
--         table.insert(self.posyDic, height)

--         if element.tag == "item_1" or element.tag == "pet_1" or element.tag == "role_1" or element.tag == "unit_2" or element.tag == "honor_1" or element.tag == "panel_1" or element.tag == "panel_2" then
--             local firstWidth = 0
--             local secondWidth = 0
--             for j = idx, element.tagEndIndex do
--                 if secondWidth == 0 then
--                     if width + firstWidth + generator.characters[j - 1].charWidth >= self.txtMaxWidth then
--                         secondWidth = generator.characters[j - 1].charWidth
--                     else
--                         firstWidth = firstWidth + generator.characters[j - 1].charWidth
--                     end
--                 else
--                     secondWidth = secondWidth + generator.characters[j - 1].charWidth
--                 end
--             end
--             element.width = firstWidth

--             if secondWidth > 0 then
--                 local addOne = BaseUtils.copytab(element)
--                 addOne.width = secondWidth
--                 needMore[i + 1] = addOne
--                 table.insert(self.posxDic, 0)
--                 table.insert(self.posyDic, height - self.lineSpace)
--             end
--         end
--     end
--     -- print("####################### end  ##########################")

--     for idx,v in pairs(needMore) do
--         table.insert(self.msgData.elements, idx, v)
--     end

--     self:ShowElements(self.msgData.elements)
--     self.contentTxt.text = self.msgData.showString
-- end
