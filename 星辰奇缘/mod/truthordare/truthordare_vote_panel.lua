-- ---------------------------------
-- 真心话大冒险，加入
-- ljh
-- ---------------------------------
TruthordareVotePanel = TruthordareVotePanel or BaseClass(BaseView)

function TruthordareVotePanel:__init(parent)
    self.parent = parent

    self.resList = {
        {file = AssetConfig.truthordarevotepanel, type = AssetType.Main}
        , {file = AssetConfig.truthordare_textures, type = AssetType.Dep}
        , {file = string.format(AssetConfig.effect, 20512), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20513), type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

    self.panelType = 3

    self.data = nil
    self.isActive = true

    self.isDelete = false

    self.answerNum = 0
    self.minNum = 0
    self.maxNum = 999

    self.time = 0
    self.timeMax = 20

    self.bar1_head = {}
    self.bar2_head = {}
    self.bar3_head = {}

    self.effTimerId = {}
    self.tweenId = {}

    self._Update = function() self:Update() end

    self:LoadAssetBundleBatch()
end

function TruthordareVotePanel:__delete()
    self.isDelete = true

    self:SetActive(false)

    TruthordareManager.Instance.OnUpdate:Remove(self._Update)

    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
    end

    if self.miniTweenId ~= nil then
        Tween.Instance:Cancel(self.miniTweenId)
        self.miniTweenId = nil
    end

    if self.answerPanelBoomMan ~= nil then
        self.answerPanelBoomMan.headSlot:DeleteMe()
    end
    self.answerPanelBoomMan = nil
    
    if self.votePanelBoomMan ~= nil then
        self.votePanelBoomMan.headSlot:DeleteMe()
    end
    self.votePanelBoomMan = nil
    
    if self.voteEndPanelBoomMan ~= nil then
        self.voteEndPanelBoomMan.headSlot:DeleteMe()
    end
    self.voteEndPanelBoomMan = nil

    for i, v in ipairs(self.bar1_head) do
        v:DeleteMe()
    end
    self.bar1_head = {}

    for i, v in ipairs(self.bar2_head) do
        v:DeleteMe()
    end
    self.bar2_head = {}

    for i, v in ipairs(self.bar3_head) do
        v:DeleteMe()
    end
    self.bar3_head = {}

    for k,v in pairs(self.effTimerId) do
        LuaTimer.Delete(v)
    end
    self.effTimerId = {}

    for k,v in pairs(self.tweenId) do
        Tween.Instance:Cancel(v)
    end
    self.tweenId = {}

    if self.passTweenId ~= nil then
        Tween.Instance:Cancel(self.passTweenId)
        self.passTweenId = nil
    end
end

function TruthordareVotePanel:InitPanel()
    if self.isDelete then
        return
    end

	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordarevotepanel))
    self.gameObject.name = "TruthordareVotePanel"
    self.transform = self.gameObject.transform

    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.transform:GetComponent(RectTransform).anchoredPosition = Vector2(355, 15)

    self.exitButtonText = self.transform:Find("ExitButton"):GetComponent(Text)
    self.exitButtonImage1 = self.transform:Find("ExitButton/Image1").gameObject
    self.exitButtonImage2 = self.transform:Find("ExitButton/Image2").gameObject
    self.transform:Find("ExitButton"):GetComponent(Button).onClick:AddListener(function() TruthordareManager.Instance.model:ExitRoom() end)
    self.transform:Find("MiniButton"):GetComponent(Button).onClick:AddListener(function() self.parent:MiniPanel(true) end)

    self.transform:Find("Button1"):GetComponent(Button).onClick:AddListener(function() self:OnRuleButton() end)
    self.transform:Find("Button2"):GetComponent(Button).onClick:AddListener(function() self:OnEditorButton() end)

    self.roundText = self.transform:Find("RoundText"):GetComponent(Text)
    
    self.textPanel = self.transform:Find("TextPanel")
    self.textPanelText = self.textPanel:Find("TextBg/Text"):GetComponent(Text)
    self.textPanelTextExt = MsgItemExt.New(self.textPanelText, 340, 16, 22)
    self.textPanelText1 = self.textPanel:Find("TextBg/Text1"):GetComponent(Text)
    self.textPanelText2 = self.textPanel:Find("TextBg/Text2"):GetComponent(Text)
    self.textPanelDescText = self.textPanel:Find("DescText"):GetComponent(Text)
    self.textPanelTimeText = self.textPanel:Find("TimeText"):GetComponent(Text)

    self.answerPanel = self.transform:Find("AnswerPanel")
    local answerPanelBoomMan = self.answerPanel:Find("BoomMan")
    local headSlot = HeadSlot.New()
    headSlot:SetRectParent(answerPanelBoomMan:Find("RoleImage"))
    headSlot:HideSlotBg(true, 0)
    local sexImage = answerPanelBoomMan:Find("Sex"):GetComponent(Image)
    local nameText = answerPanelBoomMan:Find("NameText"):GetComponent(Text)
    local bubble = answerPanelBoomMan:Find("Bubble").gameObject
    local bubbleText = answerPanelBoomMan:Find("Bubble/Text"):GetComponent(Text)
    local bubbleTextExt = MsgItemExt.New(bubbleText, 270, 16, 22)
    self.answerPanelBoomMan = { gameObject = answerPanelBoomMan.gameObject, headSlot = headSlot, sexImage = sexImage, nameText = nameText, bubble = bubble, bubbleText = bubbleText, bubbleTextExt = bubbleTextExt }
    self.answerPanelClockText = self.answerPanel:Find("Clock/Text"):GetComponent(Text)
    self.answerPanelText = self.answerPanel:Find("Text"):GetComponent(Text)
    self.answerPanelButton = self.answerPanel:Find("Button")
    self.answerPanelButton:GetComponent(Button).onClick:AddListener(function() self:OnAnswerButton() end)
    self.answerPanelPassButton = self.answerPanel:Find("PassButton")
    self.answerPanelPassButton:GetComponent(Button).onClick:AddListener(function() self:OnPassButton() end)

    self.votePanel = self.transform:Find("VotePanel")
    local votePanelBoomMan = self.votePanel:Find("BoomMan")
    local headSlot = HeadSlot.New()
    headSlot:SetRectParent(votePanelBoomMan:Find("RoleImage"))
    headSlot:HideSlotBg(true, 0)
    local sexImage = votePanelBoomMan:Find("Sex"):GetComponent(Image)
    local nameText = votePanelBoomMan:Find("NameText"):GetComponent(Text)
    local bubble = votePanelBoomMan:Find("Bubble").gameObject
    local bubbleText = votePanelBoomMan:Find("Bubble/Text"):GetComponent(Text)
    local bubbleTextExt = MsgItemExt.New(bubbleText, 270, 16, 22)
    self.votePanelBoomMan = { gameObject = votePanelBoomMan.gameObject, headSlot = headSlot, sexImage = sexImage, nameText = nameText, bubble = bubble, bubbleText = bubbleText, bubbleTextExt = bubbleTextExt }
    self.votePanelClockText = self.votePanel:Find("Clock/Text"):GetComponent(Text)
    self.votePanel:Find("Text").transform.sizeDelta = Vector2(307,48)
    self.votePanelText = self.votePanel:Find("Text"):GetComponent(Text)
    self.votePanelButton1 = self.votePanel:Find("VoteButton1")
    self.votePanelButton1:GetComponent(Button).onClick:AddListener(function() self:OnVoteButton(1) end)
    self.votePanelButton2 = self.votePanel:Find("VoteButton2")
    self.votePanelButton2:GetComponent(Button).onClick:AddListener(function() self:OnVoteButton(2) end)

    self.voteEndPanel = self.transform:Find("VoteEndPanel")
    local voteEndPanelBoomMan = self.voteEndPanel:Find("BoomMan")
    local headSlot = HeadSlot.New()
    headSlot:SetRectParent(voteEndPanelBoomMan:Find("RoleImage"))
    headSlot:HideSlotBg(true, 0)
    local sexImage = voteEndPanelBoomMan:Find("Sex"):GetComponent(Image)
    local nameText = voteEndPanelBoomMan:Find("NameText"):GetComponent(Text)
    local bubble = voteEndPanelBoomMan:Find("Bubble").gameObject
    local bubbleText = voteEndPanelBoomMan:Find("Bubble/Text"):GetComponent(Text)
    local bubbleTextExt = MsgItemExt.New(bubbleText, 125, 16, 22)
    self.voteEndPanelBoomMan = { gameObject = voteEndPanelBoomMan.gameObject, headSlot = headSlot, sexImage = sexImage, nameText = nameText, bubble = bubble, bubbleText = bubbleText, bubbleTextExt = bubbleTextExt }
    self.voteEndPanelClockText = self.voteEndPanel:Find("Clock/Text"):GetComponent(Text)
    self.voteEndPanelText = self.voteEndPanel:Find("Text"):GetComponent(Text)
    self.voteEndPanelPass = self.voteEndPanel:Find("Pass")
    self.voteEndPanelNotPass = self.voteEndPanel:Find("NotPass")
    self.voteEndPanelBar1 = self.voteEndPanel:Find("Bar1/BarBg/Bar")
    local votebar1Rect = self.voteEndPanel:Find("Bar1/BarBg/Bar"):GetComponent(RectTransform)
    votebar1Rect.anchorMax = Vector2(0, 0.5)
    votebar1Rect.anchorMin = Vector2(0, 0.5)
    votebar1Rect.anchoredPosition = Vector3(2, 1.5, 1)
    votebar1Rect.sizeDelta = Vector2(217,29)
    votebar1Rect.pivot = Vector2(0,0.5)
    local bar1btn = self.voteEndPanel:Find("Bar1/BarBg").gameObject:AddComponent(Button)
    bar1btn.onClick:RemoveAllListeners()
    bar1btn.onClick:AddListener(function() TruthordareManager.Instance.model:OpenVoteDetailsWindow() end)
    local bar2btn = self.voteEndPanel:Find("Bar2/BarBg").gameObject:AddComponent(Button)
    bar2btn.onClick:RemoveAllListeners()
    bar2btn.onClick:AddListener(function() TruthordareManager.Instance.model:OpenVoteDetailsWindow() end)

    local bar3btn = self.voteEndPanel:Find("Bar3/BarBg").gameObject:AddComponent(Button)
    bar3btn.onClick:RemoveAllListeners()
    bar3btn.onClick:AddListener(function() TruthordareManager.Instance.model:OpenVoteDetailsWindow() end)
    
    self.voteEndPanelBar2 = self.voteEndPanel:Find("Bar2/BarBg/Bar")
    local votebar2Rect = self.voteEndPanel:Find("Bar2/BarBg/Bar"):GetComponent(RectTransform)
    votebar2Rect.anchorMax = Vector2(0, 0.5)
    votebar2Rect.anchorMin = Vector2(0, 0.5)
    votebar2Rect.anchoredPosition = Vector3(2, 1.5, 1)
    votebar2Rect.sizeDelta = Vector2(217,29)
    votebar2Rect = Vector2(0,0.5)
    local BarNum1 = GameObject.Instantiate(self.voteEndPanel:Find("Bar1/BarBg/Text").gameObject)
    UIUtils.AddUIChild(self.voteEndPanel:Find("Bar1/BarBg").gameObject, BarNum1)
    local rect1 = BarNum1:GetComponent(RectTransform)
    rect1.anchorMax = Vector2(0.5, 0.5)
    rect1.anchorMin = Vector2(0.5, 0.5)
    rect1.anchoredPosition = Vector2(87.7,0)
    rect1.sizeDelta = Vector2(29,26)
    --BarNum1.transform:SetParent(self.voteEndPanel:Find("Bar1/BarBg"))
    self.BarNumText1 = BarNum1.transform:GetComponent(Text)

    local BarNum2 = GameObject.Instantiate(self.voteEndPanel:Find("Bar2/BarBg/Text").gameObject)
    UIUtils.AddUIChild(self.voteEndPanel:Find("Bar2/BarBg").gameObject, BarNum2)
    local rect2 = BarNum2:GetComponent(RectTransform)
    rect2.anchorMax = Vector2(0.5, 0.5)
    rect2.anchorMin = Vector2(0.5, 0.5)
    rect2.anchoredPosition = Vector2(87.7,0)
    rect2.sizeDelta = Vector2(29,26)

    self.BarNumText2 = BarNum2.transform:GetComponent(Text)

    local BarNum3 = GameObject.Instantiate(self.voteEndPanel:Find("Bar3/BarBg/Text").gameObject)
    UIUtils.AddUIChild(self.voteEndPanel:Find("Bar3/BarBg").gameObject, BarNum3)
    local rect3 = BarNum3:GetComponent(RectTransform)
    rect3.anchorMax = Vector2(0.5, 0.5)
    rect3.anchorMin = Vector2(0.5, 0.5)
    rect3.anchoredPosition = Vector2(87.7,0)
    rect3.sizeDelta = Vector2(29,26)
    --BarNum3.transform:SetParent(self.voteEndPanel:Find("Bar3/BarBg"))
    self.BarNumText3 = BarNum3.transform:GetComponent(Text)

    local head = nil
    for i = 1, 4 do 
        head = self.voteEndPanel:Find("Bar1/Head"..i)
        local headSlot = HeadSlot.New()
        headSlot:SetRectParent(head)
        headSlot:HideSlotBg(true, 0)
        headSlot.transform.localScale = Vector3.one
        self.bar1_head[i] = headSlot
    end
    for i = 1, 4 do 
        head = self.voteEndPanel:Find("Bar2/Head"..i)
        local headSlot = HeadSlot.New()
        headSlot:SetRectParent(head)
        headSlot:HideSlotBg(true, 0)
        headSlot.transform.localScale = Vector3.one
        self.bar2_head[i] = headSlot
    end
    for i = 1, 4 do 
        head = self.voteEndPanel:Find("Bar3/Head"..i)
        local headSlot = HeadSlot.New()
        headSlot:SetRectParent(head)
        headSlot:HideSlotBg(true, 0)
        headSlot.transform.localScale = Vector3.one
        self.bar3_head[i] = headSlot
    end
    -- self.transform:Find("JoinPanel/JoinButton"):GetComponent(Button).onClick:AddListener(function() self:OnJoinButton() end)
    -- self.timeText = self.transform:Find("JoinPanel/JoinText"):GetComponent(Text)

    -- 鲜花
    self.effect20512 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20512)))
    self.effect20512.transform:SetParent(self.voteEndPanelBoomMan.gameObject.transform)
    self.effect20512.transform.localScale = Vector3.one
    self.effect20512.transform.localPosition = Vector3(0, 0, -300)
    self.effect20512:SetActive(false)

    -- 鸡蛋
    self.effect20513 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20513)))
    self.effect20513.transform:SetParent(self.voteEndPanelBoomMan.gameObject.transform)
    self.effect20513.transform.localScale = Vector3.one
    self.effect20513.transform.localPosition = Vector3(0, 0, -300)
    self.effect20513:SetActive(false)

    ----------------------------
    self:SetData(self.data)
    self:ClearMainAsset()
end

function TruthordareVotePanel:MiniPanel(andCloseChatPanel)
    if self.miniTweenId == nil then
        self.miniTweenId = Tween.Instance:Scale(self.gameObject, Vector3.zero, 0.2, 
            function() 
                self.miniMark = true 
                self:SetActive(false) 
                self.miniTweenId = nil 
                if andCloseChatPanel then
                    if ChatManager.Instance.model.chatWindow ~= nil and not BaseUtils.isnull(ChatManager.Instance.model.chatWindow.transform) then
                        ChatManager.Instance.model.chatWindow:ClickShow()
                    end
                end
            end, LeanTweenType.easeOutQuart).id
    end
end

function TruthordareVotePanel:SetData(data)
    self.data = data
    if BaseUtils.isnull(self.gameObject) then
        return
    end

    self:SetActive(true)
end

function TruthordareVotePanel:SetActive(active)
    self.isActive = true
    if not BaseUtils.isnull(self.gameObject) then
        self.gameObject:SetActive(active)

        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
        end
    
        if active then
            self.transform.localScale = Vector3.one
    
            self.time = TruthordareManager.Instance.model.time - BaseUtils.BASE_TIME
            self.timer = LuaTimer.Add(1000, 1000, function() self:OnTimer() end)
           
            TruthordareManager.Instance.OnUpdate:Remove(self._Update)
            TruthordareManager.Instance.OnUpdate:Add(self._Update)

            self:Update()
        else
            TruthordareManager.Instance.OnUpdate:Remove(self._Update)
            
            for k,v in pairs(self.effTimerId) do
                LuaTimer.Delete(v)
            end
            self.effTimerId = {}
        
            for k,v in pairs(self.tweenId) do
                Tween.Instance:Cancel(v)
            end
            self.tweenId = {}

            if self.passTweenId ~= nil then
                Tween.Instance:Cancel(self.passTweenId)
                self.passTweenId = nil
            end
        end
    end
end

function TruthordareVotePanel:OnTimer()
    if self.time > 0 then
        self.time = self.time - 1

        local data = TruthordareManager.Instance.model
        if data.state == 5 then
            self.textPanelTimeText.text = BaseUtils.formate_time_gap(self.time, ":", 0, BaseUtils.time_formate.MIN)
            self.answerPanelClockText.text = tostring(self.time)
        elseif data.state == 6 then
            if TruthordareManager.Instance.model:CanVote() then
                self.textPanelTimeText.text = BaseUtils.formate_time_gap(self.time, ":", 0, BaseUtils.time_formate.MIN)
                self.votePanelClockText.text = tostring(self.time)
            else
                self.voteEndPanelClockText.text = tostring(self.time)
            end
        elseif data.state == 7 then
            self.voteEndPanelClockText.text = tostring(self.time)
        end
    else
        
    end
end

function TruthordareVotePanel:OnRuleButton()
    self.parent:OpenGuidePanelFun()
end

function TruthordareVotePanel:OnEditorButton()
    TruthordareManager.Instance.model:OpenEditorWindow()
end

function TruthordareVotePanel:Update()
    local data = TruthordareManager.Instance.model
    self.roundText.text = string.format(TI18N("当前第%s轮 共%s轮"), data.now_round, data.max_round)
    if data.state == 5 then
        self.textPanel.gameObject:SetActive(true)
        self.answerPanel.gameObject:SetActive(true)
        self.votePanel.gameObject:SetActive(false)
        self.voteEndPanel.gameObject:SetActive(false)

        self:UpdateTextPanel()
        self:UpdateAnswerPanel()
    elseif data.state == 6 then
        if TruthordareManager.Instance.model:CanVote() then
            self.textPanel.gameObject:SetActive(true)
            self.answerPanel.gameObject:SetActive(false)
            self.votePanel.gameObject:SetActive(true)
            self.voteEndPanel.gameObject:SetActive(false)

            self:UpdateTextPanel()
            self:UpdateVotePanel()
        else
            self.textPanel.gameObject:SetActive(false)
            self.answerPanel.gameObject:SetActive(false)
            self.votePanel.gameObject:SetActive(false)
            self.voteEndPanel.gameObject:SetActive(true)
    
            self:UpdateVoteEndPanel()
        end
    elseif data.state == 7 then
        self.textPanel.gameObject:SetActive(false)
        self.answerPanel.gameObject:SetActive(false)
        self.votePanel.gameObject:SetActive(false)
        self.voteEndPanel.gameObject:SetActive(true)

        self:UpdateVoteEndPanel()
    end

    if not TruthordareManager.Instance.model:GetInRoom() and TruthordareManager.Instance.model.vacancy > 0 and TruthordareManager.Instance.model.now_round ~= TruthordareManager.Instance.model.max_round then
        self:ShowDuangEffect(1, true)
    else
        self:ShowDuangEffect(1, false)
    end
    TruthordareManager.Instance.model:UpdateExitRoomButton(self.exitButtonText, self.exitButtonImage1, self.exitButtonImage2)
end

function TruthordareVotePanel:UpdateTextPanel()
    local data = TruthordareManager.Instance.model
    -- self.textPanelText.text = data.luckyQuestion
    if data.luckyQuestion ~= nil then
        self.textPanelTextExt:SetData(data.luckyQuestion)
    end
    self.textPanelText1.text = TI18N("任务内容:")
    if data.luckyQuestionRoleName == "" then
        self.textPanelText2.text = ""
    else
        self.textPanelText2.text = string.format(TI18N("(<color='#225ee7'>%s</color>出题)"), data.luckyQuestionRoleName)
    end
    if data.luckyMan ~= nil then
        self.textPanelDescText.text = string.format(TI18N("<color='#25EEF6'>%s</color>需要在限时内完成"), data.luckyMan.name)
    end
end

function TruthordareVotePanel:UpdateAnswerPanel()
    local luckyManData = TruthordareManager.Instance.model.luckyMan
    if luckyManData ~= nil then
        self.answerPanelBoomMan.headSlot:SetAll(luckyManData, {isSmall = true})
        self.answerPanelBoomMan.nameText.text = luckyManData.name
        self.answerPanelBoomMan.sexImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (luckyManData.sex == 0 and "IconSex0" or "IconSex1"))
        
        local talkList = DataGuildTruthDare.data_talk[5].talk_list
        if TruthordareManager.Instance.model.quest_round > 1 then
            talkList = DataGuildTruthDare.data_talk[9].talk_list
        end
        local talk = talkList[Random.Range(1, #talkList)]
        if talk == nil or talk == "" then
            self.answerPanelBoomMan.bubble:SetActive(false)
        else
            self.answerPanelBoomMan.bubble:SetActive(true)    
            -- self.answerPanelBoomMan.bubbleText.text = talk
            self.answerPanelBoomMan.bubbleTextExt:SetData(talk)
        end

        if TruthordareManager.Instance.model:IsLuckyMan() then
            self.answerPanelText.text = TI18N("你的作答将由其他玩家评分\n(时间到了将自动发起投票哦)")
            self.answerPanelButton.gameObject:SetActive(true)
            self.answerPanelPassButton.gameObject:SetActive(false)
        else
            self.answerPanelText.text = string.format(TI18N("幸运儿<color='#25EEF6'>%s</color>正在作答"), luckyManData.name)
            self.answerPanelButton.gameObject:SetActive(false)
            if TruthordareManager.Instance.model:GetInRoom() then
                self.answerPanelPassButton.gameObject:SetActive(true)
            else
                self.answerPanelPassButton.gameObject:SetActive(false)
            end
        end
    end
end

function TruthordareVotePanel:UpdateVotePanel()
    local luckyManData = TruthordareManager.Instance.model.luckyMan
    if luckyManData ~= nil then
        self.votePanelBoomMan.headSlot:SetAll(luckyManData, {isSmall = true})
        self.votePanelBoomMan.nameText.text = luckyManData.name
        self.votePanelBoomMan.sexImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (luckyManData.sex == 0 and "IconSex0" or "IconSex1"))
        local talkList = DataGuildTruthDare.data_talk[6].talk_list
        local talk = talkList[Random.Range(1, #talkList)]
        if talk == nil or talk == "" then
            self.votePanelBoomMan.bubble:SetActive(false)
        else
            self.votePanelBoomMan.bubble:SetActive(true)    
            -- self.votePanelBoomMan.bubbleText.text = talk
            self.votePanelBoomMan.bubbleTextExt:SetData(talk)
        end

        if TruthordareManager.Instance.model:IsLuckyMan() then
            self.votePanelText.text = TI18N("你正在焦急地等待大伙的投票，赶紧拉拉票吧")
            self.votePanelButton1.gameObject:SetActive(false)
            self.votePanelButton2.gameObject:SetActive(false)
        else
            self.votePanelText.text = string.format(TI18N("幸运儿<color='#25EEF6'>%s</color>的作答，你满意吗？"), luckyManData.name)
            self.votePanelButton1.gameObject:SetActive(true)
            self.votePanelButton2.gameObject:SetActive(true)
        end
    end
end

function TruthordareVotePanel:UpdateVoteEndPanel()
    local luckyManData = TruthordareManager.Instance.model.luckyMan
    if luckyManData ~= nil then
        self.voteEndPanelBoomMan.headSlot:SetAll(luckyManData, {isSmall = true})
        self.voteEndPanelBoomMan.nameText.text = luckyManData.name
        self.voteEndPanelBoomMan.sexImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (luckyManData.sex == 0 and "IconSex0" or "IconSex1"))
    end

    local data = TruthordareManager.Instance.model
    if #data.flower_list + #data.egg_list == 0 then
        --self.voteEndPanelBar1.localScale = Vector3(0, 1, 1)
        --self.voteEndPanelBar2.localScale = Vector3(0, 1, 1)
        self.voteEndPanelBar1.sizeDelta = Vector2(37,29)
        self.voteEndPanelBar2.sizeDelta = Vector2(37,29)
    else
        self.voteEndPanelBar1.sizeDelta = Vector2(#data.flower_list / (#data.flower_list + #data.egg_list) * 217,29)
        self.voteEndPanelBar2.sizeDelta = Vector2(#data.egg_list / (#data.flower_list + #data.egg_list) * 217,29)
        --self.voteEndPanelBar1.localScale = Vector3(#data.flower_list / (#data.flower_list + #data.egg_list), 1, 1)
        --self.voteEndPanelBar2.localScale = Vector3(#data.egg_list / (#data.flower_list + #data.egg_list), 1, 1)
    end
    self.BarNumText1.text = #data.flower_list
    self.BarNumText2.text = #data.egg_list
    self.BarNumText3.text = #data.call_list
    for i, v in ipairs(self.bar1_head) do 
        local headData = data.flower_list[i]
        if headData ~= nil then
            v:SetAll(headData, {isSmall = true, clickCallback = function() TruthordareManager.Instance.model:OpenVoteDetailsWindow() end})
            v.gameObject:SetActive(true)
        else
            v.gameObject:SetActive(false)
        end
    end

    for i, v in ipairs(self.bar2_head) do 
        local headData = data.egg_list[i]
        if headData ~= nil then
            v:SetAll(headData, {isSmall = true, clickCallback = function() TruthordareManager.Instance.model:OpenVoteDetailsWindow() end})
            v.gameObject:SetActive(true)
        else
            v.gameObject:SetActive(false)
        end
    end

    for i, v in ipairs(self.bar3_head) do 
        local headData = data.call_list[i]
        if headData ~= nil then
            v:SetAll(headData, {isSmall = true, clickCallback = function() TruthordareManager.Instance.model:OpenVoteDetailsWindow() end})
            v.gameObject:SetActive(true)
        else
            v.gameObject:SetActive(false)
        end
    end

    if TruthordareManager.Instance.model.state == 6 then
        self.voteEndPanelPass.gameObject:SetActive(false)
        self.voteEndPanelNotPass.gameObject:SetActive(false)

        local talkList = DataGuildTruthDare.data_talk[10].talk_list
        local talk = talkList[Random.Range(1, #talkList)]
        if talk == nil or talk == "" then
            self.voteEndPanelBoomMan.bubble:SetActive(false)
        else
            self.voteEndPanelBoomMan.bubble:SetActive(true)    
            -- self.voteEndPanelBoomMan.bubbleText.text = talk
            self.voteEndPanelBoomMan.bubbleTextExt:SetData(talk)
        end

        if luckyManData ~= nil then
            self.voteEndPanelText.text = TI18N("投票完成，请等待其他人的投票哦~")
        end
    else
        if data.is_pass == 1 then
            self.voteEndPanelPass.gameObject:SetActive(true)
            self.voteEndPanelNotPass.gameObject:SetActive(false)
            if self.passTweenId ~= nil then
                Tween.Instance:Cancel(self.passTweenId)
                self.passTweenId = nil
            end
            self.voteEndPanelPass.localScale = Vector3(5,5,1)
            self.passTweenId = Tween.Instance:Scale(self.voteEndPanelPass.gameObject, Vector3(1,1,1), 0.2, function()  end, LeanTweenType.easeInCubic).id
            SoundManager.Instance:Play(279)

            local talkList = DataGuildTruthDare.data_talk[8].talk_list
            local talk = talkList[Random.Range(1, #talkList)]
            if talk == nil or talk == "" then
                self.voteEndPanelBoomMan.bubble:SetActive(false)
            else
                self.voteEndPanelBoomMan.bubble:SetActive(true)    
                -- self.voteEndPanelBoomMan.bubbleText.text = talk
                self.voteEndPanelBoomMan.bubbleTextExt:SetData(talk)
            end

            if luckyManData ~= nil then
                self.voteEndPanelText.text = string.format(TI18N("<color='#25EEF6'>%s</color>顺利完成任务，即将进入下一轮"), luckyManData.name)
            end

            self.effect20512:SetActive(false)
            self.effect20513:SetActive(false)
            LuaTimer.Add(500, function() 
                if BaseUtils.isnull(self.gameObject) then
                    return
                end

                self.effect20512:SetActive(false)
                self.effect20513:SetActive(false)
                self.effect20512:SetActive(true)
            end)
        else
            self.voteEndPanelPass.gameObject:SetActive(false)
            self.voteEndPanelNotPass.gameObject:SetActive(true)
            if self.passTweenId ~= nil then
                Tween.Instance:Cancel(self.passTweenId)
                self.passTweenId = nil
            end
            self.voteEndPanelNotPass.localScale = Vector3(5,5,1)
            self.passTweenId = Tween.Instance:Scale(self.voteEndPanelNotPass.gameObject, Vector3(1,1,1), 0.2, function()  end, LeanTweenType.easeInCubic).id
            SoundManager.Instance:Play(280)

            local talkList = DataGuildTruthDare.data_talk[7].talk_list
            local talk = talkList[Random.Range(1, #talkList)]
            if talk == nil or talk == "" then
                self.voteEndPanelBoomMan.bubble:SetActive(false)
            else
                self.voteEndPanelBoomMan.bubble:SetActive(true)    
                -- self.voteEndPanelBoomMan.bubbleText.text = talk
                self.voteEndPanelBoomMan.bubbleTextExt:SetData(talk)
            end

            if luckyManData ~= nil then
                if TruthordareManager.Instance.model.quest_round == 1 then
                    self.voteEndPanelText.text = string.format(TI18N("<color='#25EEF6'>%s</color>还能战500回合！再给一次机会吧"), luckyManData.name)
                else
                    self.voteEndPanelText.text = TI18N("又不通过，不如发个红包压压惊？")
                end
            end

            self.effect20512:SetActive(false)
            self.effect20513:SetActive(false)
            LuaTimer.Add(500, function() 
                if BaseUtils.isnull(self.gameObject) then
                    return
                end

                self.effect20512:SetActive(false)
                self.effect20513:SetActive(false)
                self.effect20513:SetActive(true)
            end)
        end
    end
end

function TruthordareVotePanel:OnAnswerButton()
    TruthordareManager.Instance:Send19522()
end

function TruthordareVotePanel:OnPassButton()
    local luckyManData = TruthordareManager.Instance.model.luckyMan
    if luckyManData ~= nil then
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.content = string.format(TI18N("<color='#25EEF6'>%s</color>正在作答，是否要跳过本轮？<color='#ffff00'>（投票持续约20秒）</color>"), luckyManData.name)
        confirmData.sureLabel = TI18N("确认跳过")
        confirmData.sureCallback = function() TruthordareManager.Instance:Send19530() end
        confirmData.cancelLabel = TI18N("取消")

        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

function TruthordareVotePanel:OnVoteButton(type)
    TruthordareManager.Instance:Send19523(type)
    if type == 1 then
        SoundManager.Instance:Play(279)

        self.effect20512:SetActive(false)
        self.effect20513:SetActive(false)
        self.effect20512:SetActive(true)
    else
        SoundManager.Instance:Play(280)

        self.effect20512:SetActive(false)
        self.effect20513:SetActive(false)
        self.effect20513:SetActive(true)
    end
end

function TruthordareVotePanel:ShowDuangEffect(index, show)
	local gameObject = self.transform:Find("ExitButton").gameObject

	if show then
	    if self.effTimerId[index] == nil then
	       self.effTimerId[index] = LuaTimer.Add(index * 1000, 3000, function()
	           gameObject.transform.localScale = Vector3(1.2,1.2,1)
	           if self.tweenId[index] == nil then
	             	self.tweenId[index] = Tween.Instance:Scale(gameObject, Vector3(1,1,1), 1.2, function() self.tweenId[index] = nil end, LeanTweenType.easeOutElastic).id
	           end
	       end)
	    end
	else
		gameObject.transform.localScale = Vector3(1,1,1)

		if self.effTimerId[index] ~= nil then
			LuaTimer.Delete(self.effTimerId[index])
		end

		if self.tweenId[index] ~= nil then
			Tween.Instance:Cancel(self.tweenId[index])
		end
	end
end