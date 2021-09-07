-- ---------------------------------
-- 真心话大冒险，加入
-- ljh
-- ---------------------------------
TruthordareJoinPanel = TruthordareJoinPanel or BaseClass(BaseView)

function TruthordareJoinPanel:__init(parent)
    self.parent = parent

    self.resList = {
        {file = AssetConfig.truthordarejoinwindow, type = AssetType.Main}
        , {file = AssetConfig.truthordare_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.panelType = 1
    
    self.data = nil
    self.isActive = true

    self.isDelete = false

    self.memberList = {}

    self.time = 0
    self.timeMax = 20

    self.effTimerId = {}
    self.tweenId = {}
    
    self._Update = function() self:Update() end

    self:LoadAssetBundleBatch()
end

function TruthordareJoinPanel:__delete()
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

    for i, v in ipairs(self.memberList) do
        v.headSlot:DeleteMe()
    end
    self.memberList = {}

    for k,v in pairs(self.effTimerId) do
        LuaTimer.Delete(v)
    end
    self.effTimerId = {}

    for k,v in pairs(self.tweenId) do
        Tween.Instance:Cancel(v)
    end
    self.tweenId = {}
end

function TruthordareJoinPanel:InitPanel()
    if self.isDelete then
        return
    end

	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordarejoinwindow))
    self.gameObject.name = "TruthordareJoinPanel"
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

    -- self.answerText = self.transform:Find("Panel/AnswerText"):GetComponent(Text)
    
    self.transform:Find("JoinPanel/JoinButton"):GetComponent(Button).onClick:AddListener(function() self:OnJoinButton() end)
    self.transform:Find("JoinPanel"):GetChild(1).transform.anchoredPosition = Vector2(-70,12)
    local JoinArea = self.transform:Find("JoinPanel/JoinText")
    JoinArea.anchoredPosition = Vector2(53,10)
    JoinArea.sizeDelta = Vector2(204, 32)

    self.timeText = self.transform:Find("JoinPanel/JoinText"):GetComponent(Text)
    self.timeText.text = ""

    
    local container = self.transform:Find("MemberPanel/Container")
    local childNum = container.childCount
    for i=1, childNum do 
        local item = container:GetChild(i-1)
        local headSlot = HeadSlot.New()
        headSlot:SetRectParent(item:Find("RoleImage"))
        local sexImage = item:Find("Sex"):GetComponent(Image)
        local nameText = item:Find("NameText"):GetComponent(Text)
        local bubble = item:Find("Bubble").gameObject
        local bubbleText = item:Find("Bubble/Text"):GetComponent(Text)
        table.insert(self.memberList, { gameObject = item.gameObject, headSlot = headSlot, sexImage = sexImage, nameText = nameText, bubble = bubble, bubbleText = bubbleText } )

        item:GetComponent(Button).onClick:AddListener(function() self:OnClickMember(i) end)
    end

    ----------------------------
    self:SetData(self.data)
    self:ClearMainAsset()
end

function TruthordareJoinPanel:MiniPanel(andCloseChatPanel)
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

function TruthordareJoinPanel:SetData(data)
    self.data = data
    if BaseUtils.isnull(self.gameObject) then
        return
    end

    self:SetActive(true)
end

function TruthordareJoinPanel:SetActive(active)
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
        end
    end
end

function TruthordareJoinPanel:Update()
    self.time = TruthordareManager.Instance.model.time - BaseUtils.BASE_TIME

    local pos_info_list = TruthordareManager.Instance.model.next_pos_info
    if pos_info_list == nil then
        return
    end

    local talkList = DataGuildTruthDare.data_talk[1].talk_list
    for i=1,12 do
        local pos_info = pos_info_list[i] 
        local member = self.memberList[i]
        if pos_info == nil then
            member.headSlot.gameObject:SetActive(false)
            member.nameText.text = TI18N("虚位以待")
            member.sexImage.gameObject:SetActive(false)
            member.bubble:SetActive(false)
        else
            member.headSlot.gameObject:SetActive(true)
            member.headSlot:HideSlotBg(true, 0)
            pos_info.id = pos_info.rid
            member.headSlot:SetAll(pos_info, {isSmall = true})
            member.nameText.text = pos_info.role_name
            member.sexImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (pos_info.sex == 0 and "IconSex0" or "IconSex1"))
            member.sexImage.gameObject:SetActive(true)

            local talk = talkList[i]
            if talk == nil or talk == "" then
                member.bubble:SetActive(false)
            else
                member.bubble:SetActive(true)    
                member.bubbleText.text = talk
            end
        end
    end

    if not TruthordareManager.Instance.model:GetInRoom() and TruthordareManager.Instance.model.vacancy > 0 and TruthordareManager.Instance.model.now_round ~= TruthordareManager.Instance.model.max_round then
        self:ShowDuangEffect(1, true)
    else
        self:ShowDuangEffect(1, false)
    end

    TruthordareManager.Instance.model:UpdateExitRoomButton(self.exitButtonText, self.exitButtonImage1, self.exitButtonImage2)
end

function TruthordareJoinPanel:OnClickMember(index)
    local pos_info_list = TruthordareManager.Instance.model.next_pos_info
    if pos_info_list == nil then
        return
    end
    if pos_info_list[index] == nil then
        if TruthordareManager.Instance.model:GetInRoom() then
            TruthordareManager.Instance:Send19512(index)
        else
            local mySex = RoleManager.Instance.RoleData.sex
            local loss = DataGuildTruthDare.data_info[1].loss
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            if mySex == 0 then
                data.content = string.format(TI18N("消耗报名费{assets_1, %s, %s}参与（<color='#ffff00'>妹子减半哦~</color>），活动结束时，将作为公会红包发放"), loss[1][1], loss[1][2])
            else
                data.content = string.format(TI18N("消耗报名费{assets_1, %s, %s}参与，活动结束时，将作为公会红包发放"), loss[1][1], loss[1][2])
            end
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function() TruthordareManager.Instance:Send19510(index) end
            NoticeManager.Instance:ConfirmTips(data)
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("这位置已经有人了"))
    end
end

function TruthordareJoinPanel:OnJoinButton()
    if TruthordareManager.Instance.model:GetInRoom() then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经报名啦，快喊小伙伴一起玩吧！{face_1,3}"))
        return
    end
    local mySex = RoleManager.Instance.RoleData.sex
    local loss = DataGuildTruthDare.data_info[1].loss
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    if mySex == 0 then
        data.content = string.format(TI18N("消耗报名费{assets_1, %s, %s}参与（<color='#ffff00'>妹子减半哦~</color>），活动结束时，将作为公会红包发放"), loss[1][1], loss[1][2])
    else
        data.content = string.format(TI18N("消耗报名费{assets_1, %s, %s}参与，活动结束时，将作为公会红包发放"), loss[1][1], loss[1][2])
    end
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() TruthordareManager.Instance:Send19510(0) end
    NoticeManager.Instance:ConfirmTips(data)
end

function TruthordareJoinPanel:OnRuleButton()
    self.parent:OpenGuidePanelFun()
end

function TruthordareJoinPanel:OnEditorButton()
    -- self.parent:OpenEditorPanelFun()
    TruthordareManager.Instance.model:OpenEditorWindow()
end

function TruthordareJoinPanel:OnTimer()
    if TruthordareManager.Instance.model.time == 0 then
        self.timeText.text = TI18N("5人加入即可开始")
    end

    if self.time > 0 then
        self.time = self.time - 1

        self.timeText.text = string.format(TI18N("活动即将开始: %s"), BaseUtils.formate_time_gap(self.time, ":", 0, BaseUtils.time_formate.MIN))
    else
        
    end
end

function TruthordareJoinPanel:ShowDuangEffect(index, show)
	local gameObject = self.transform:Find("JoinPanel/JoinButton").gameObject
	if index == 2 then
		gameObject = self.transform:Find("ExitButton").gameObject
	end

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
        self.effTimerId[index] = nil

		if self.tweenId[index] ~= nil then
			Tween.Instance:Cancel(self.tweenId[index])
        end
        self.tweenId[index] = nil
	end
end