-- 说话
TalkBubbleAction = TalkBubbleAction or BaseClass(CombatBaseAction)

function TalkBubbleAction:__init(brocastCtx, fighterId, msg, BubbleID)
    self.fighterCtrl = nil
    self.brocastCtx = brocastCtx
    self.fighterId = fighterId
    self.msg = msg
    self.BubbleID = BubbleID
    self.mainPanel = brocastCtx.controller.mainPanel
    self.isrole = true
    self.fighterCtrl = self:FindFighter(self.fighterId)
    if self.msg == "" then
        return
    end
    local talkBase = self.mainPanel.mixPanel.TalkBubblePanel
    if self.fighterCtrl ~= nil and (self.fighterCtrl.fighterData.type ~= FighterType.Role or BubbleID == nil or DataAchieveShop.data_list[BubbleID] == nil or DataAchieveShop.data_list[BubbleID].source_id == 0) then
        talkBase = self.mainPanel.mixPanel.UnitTalkBubblePanel
        self.isrole = false
        self.bubble = GameObject.Instantiate(talkBase)
        self.bubble:SetActive(false)
        self.TextEXT = MsgItemExt.New(self.bubble.transform:FindChild("Content"):GetComponent(Text), 147.2, 17, 20)
    else
        self.bubble = GameObject.Instantiate(talkBase)
        self.bubble:SetActive(false)
        self.TextEXT = MsgItemExt.New(self.bubble.transform:FindChild("Content"):GetComponent(Text), 135, 17, 20)
    end
    self.bubble.transform:SetParent(self.mainPanel.mixPanel.PlayerInfoCanvas, true)
end

function TalkBubbleAction:Play()
    if self.msg == "" then
        self:OnActionEnd()
        return
    end
    if DataAchieveShop.data_list[self.BubbleID] ~= nil then
        self:SetIcon(DataAchieveShop.data_list[self.BubbleID].source_id)
    end
    self.TextEXT:SetData(self.msg)
    self.fighterCtrl = self:FindFighter(self.fighterId)
    if self.fighterCtrl == nil or BaseUtils.is_null(self.bubble) then
        if self.bubble ~= nil then
            GameObject.DestroyImmediate(self.bubble)
        end
        self:OnActionEnd()
        return
    end
    if self.isrole then
        local PH = self.bubble.transform:FindChild("Content"):GetComponent(Text).preferredHeight
        local addHeight = (PH-37.408)>0 and (PH-37.408) or 0
        self.bubble.transform.sizeDelta = Vector2(164.1, 83.21952+addHeight)
    else
        self.bubble.transform.sizeDelta = Vector2(168.6, self.bubble.transform:FindChild("Content"):GetComponent(Text).preferredHeight + 18)
    end

     if self.TextEXT.msgData.elements ~= nil then
        for i,msg in ipairs(self.TextEXT.msgData.elements) do
            if msg.faceId ~= 0 and msg.faceId ~= nil then
                if DataChatFace.data_new_face[msg.faceId] ~= nil and DataChatFace.data_new_face[msg.faceId].type == FaceEumn.FaceType.Big then
                    self.bubble.transform.sizeDelta = Vector2(115,self.bubble.transform.sizeDelta.y)
                end
            end
        end
    end
    -- self.bubble.transform:FindChild("Content"):GetComponent(Text).text = self.msg
    if self.mainPanel == nil or self.mainPanel.extendPanel == nil then
        Log.Info("战斗内说话气泡找不到扩展面板依附")
        if self.bubble ~= nil then
            GameObject.DestroyImmediate(self.bubble)
        end
        self:OnActionEnd()
        return
    end
    self.bubble.transform:SetParent(self.mainPanel.mixPanel.PlayerInfoCanvas)
    self.bubble:SetActive(true)
    self.bubble.transform.localScale = Vector3(1, 1, 1)
    local H = self.bubble.transform.sizeDelta.y
    local id = self.fighterCtrl:SetTalkBubblePanel(self.bubble)
    if BaseUtils.isnull(self.bubble) then
        self:OnActionEnd()
        return
    end
    local endpos = self.bubble.transform.localPosition
    local canvasgroup = self.bubble.transform:GetComponent(CanvasGroup)
    local fun1 = function(val)
        if not BaseUtils.isnull(canvasgroup) then
            canvasgroup.alpha = val
        end
        if not BaseUtils.isnull(self.bubble) then
            self.bubble.transform.localPosition = endpos + Vector3(0, (val-1)*H, 0)
        end
    end
    Tween.Instance:ValueChange(0, 1, 0.2, nil, LeanTweenType.easeOutQuart, fun1)
    -- self:InvokeDelay(function()self.fighterCtrl:DestroyTalkBubble(id)end, 3)
    self:OnActionEnd()
    if self.brocastCtx.controller.enterData.combat_type ~= 8 and self.fighterCtrl.fighterData.type ~= FighterType.Role and self.fighterCtrl.fighterData.type ~= FighterType.Pet then
        -- 不是玩家讲话显示到系统频道
        local str = string.format("<color='%s'>%s</color>:%s", ColorHelper.colorScene[2], self.fighterCtrl.fighterData.name, self.msg)
        local msgData = MessageParser.GetMsgData(str)
        local noticeData = ChatData.New()
        noticeData.channel = MsgEumn.ChatChannel.Scene
        noticeData.prefix = 3
        -- noticeData.showType = MsgEumn.ChatShowType.Scene
        noticeData.showType = MsgEumn.ChatShowType.System
        -- -- 添加默认颜色
        msgData.showString = str

        noticeData.msgData = msgData
        ChatManager.Instance.model:ShowMsg(noticeData)
    end
end

function TalkBubbleAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function TalkBubbleAction:SetIcon(id)
    local cfg_data
    for i,v in ipairs(DataFriendZone.data_bubble) do
        if v.id == id then
            cfg_data = v
        end
    end
    if cfg_data ~= nil then
        local r,g,b = CombatUtil.TryParseHtmlString("#"..cfg_data.color)
        self.bubble:GetComponent(Image).color = Color(r/255,g/255,b/255)
        if cfg_data.outcolor ~= "" then
            local r,g,b = CombatUtil.TryParseHtmlString("#"..cfg_data.outcolor)
            self.bubble:GetComponent(Outline).effectColor = Color(r/255,g/255,b/255)
            self.bubble:GetComponent(Outline).enabled = true
        end
        for i,v in ipairs(cfg_data.location) do
            local spriteid = tostring(v[1])
            local x = v[2]
            local y = v[3]
            local item = self.bubble.transform:Find(tostring(i))
            local sprite = PreloadManager.Instance:GetSprite(AssetConfig.bubble_icon, spriteid)
            local img = item.transform:GetComponent(Image)
            img.sprite = sprite
            img:SetNativeSize()
            item.transform.anchoredPosition = Vector2(x,y)
            item.transform.sizeDelta = Vector2(item.transform.sizeDelta.x, item.transform.sizeDelta.y)
            item.gameObject:SetActive(true)
            if cfg_data.id == 30016 then
                if i == 1 then
                    item.transform.anchoredPosition = Vector2(0,-47.4)
                    item.transform.sizeDelta = Vector2(42,55.3)
                elseif i == 2 then
                    item.transform.anchoredPosition = Vector2(157,75)
                end
            end
        end
        return true
    else
        return false
    end
end