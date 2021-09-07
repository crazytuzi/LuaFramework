-- ---------------------------------
-- 真心话大冒险，猜数字
-- ljh
-- ---------------------------------
TruthordareBoomPanel = TruthordareBoomPanel or BaseClass(BaseView)

function TruthordareBoomPanel:__init(parent)
    self.parent = parent

    self.resList = {
        {file = AssetConfig.truthordareboompanel, type = AssetType.Main}
        , {file = AssetConfig.truthordare_textures, type = AssetType.Dep}
        , {file = string.format(AssetConfig.effect, 20504), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20505), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20506), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20507), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20508), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20509), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20510), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20511), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20514), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20515), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20517), type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20518), type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

    self.panelType = 1

    self.data = nil
    self.isActive = true

    self.isDelete = false

    self.answerNum = 0
    self.minNum = 1
    self.maxNum = 200
    self.totalNum = 200

    self.time = 0
    self.timeMax = 20
    self.count = 0
    self.countMax = 10
    self.count_TalkIndex = 1

    self.memberList = {}

    self.numGruop = {}
    self.numGruop1 = {}
    self.numGruop2 = {}

    self.notUpdate_BoomManChooseNum = false

    self.effTimerId = {}
    self.tweenId = {}

    self._Update = function() self:Update() end

    self._Boom = function() self:Boom() end

    self._BoomManChooseNum = function(num, index, min, max) self:BoomManChooseNum(num, index, min, max) end

    self:LoadAssetBundleBatch()
end

function TruthordareBoomPanel:__delete()
    self.isDelete = true
    
    self:SetActive(false)
    TruthordareManager.Instance.OnUpdate:Remove(self._Update)
    TruthordareManager.Instance.OnUpdateState:Remove(self._Boom)

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

    if self.boomMan ~= nil then
        self.boomMan.headSlot:DeleteMe()
    end
    self.boomMan = nil

    if self.boomManTweenId ~= nil then
        Tween.Instance:Cancel(self.boomManTweenId)
        self.boomManTweenId = nil
    end

    if self.memberContainerTweenId ~= nil then
        Tween.Instance:Cancel(self.memberContainerTweenId)
        self.memberContainerTweenId = nil
    end

    if self.boomLineTweenId ~= nil then
        Tween.Instance:Cancel(self.boomLineTweenId)
        self.boomLineTweenId = nil
    end

    if self.boomNumTweenId ~= nil then
        Tween.Instance:Cancel(self.boomNumTweenId)
        self.boomNumTweenId = nil
    end

    for k,v in pairs(self.effTimerId) do
        LuaTimer.Delete(v)
    end
    self.effTimerId = {}

    for k,v in pairs(self.tweenId) do
        Tween.Instance:Cancel(v)
    end
    self.tweenId = {}
end

function TruthordareBoomPanel:InitPanel()
    if self.isDelete then
        return
    end

	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordareboompanel))
    self.gameObject.name = "TruthordareBoomPanel"
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
    self.boomText = self.transform:Find("TimeBg/TimeText"):GetComponent(Text)
    for i = 1, 3 do
        table.insert(self.numGruop1, self.transform:Find("TimeBg/NumGruop1/Num"..i):GetComponent(Image))
    end
    for i = 1, 3 do
        table.insert(self.numGruop2, self.transform:Find("TimeBg/NumGruop2/Num"..i):GetComponent(Image))
    end
    
    self.numPanel = self.transform:Find("NumberPanel").gameObject
    for i=0, 9 do
        local numButton = self.numPanel.transform:Find("Boom/Button"..i)
        numButton:Find("Text"):GetComponent(Text).text = tostring(i)
        numButton:GetComponent(Button).onClick:AddListener(function() self:InputNum(i) end)
    end
    self.numPanel.transform:Find("Boom/ButtonOk"):GetComponent(Button).onClick:AddListener(function() self:OnButtonOk() end)
    self.numPanel.transform:Find("Boom/ButtonCancel"):GetComponent(Button).onClick:AddListener(function() self:OnButtonCancel() end)
    
    self.transform:Find("BoomPanel/Boom/InputButton"):GetComponent(Button).onClick:AddListener(function() 
        if TruthordareManager.Instance.model:IsBoomMan() then
            self.answerNum = 0
            self.numPanel:SetActive(true) 
            self.effect20505:SetActive(false)
            self.effect20504:SetActive(false)
            self.effect20509:SetActive(false)
        else
            local boomManData = TruthordareManager.Instance.model.boomMan
            if boomManData ~= nil then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s正在拆弹，给ta出点好主意吧{face_1,15}"), boomManData.role_name))
            end
        end
    end)
    self.transform:Find("BoomPanel/Boom/OkButton"):GetComponent(Button).onClick:AddListener(function() self:SendBoom() end)

    self.inputTextImage = self.transform:Find("BoomPanel/Boom/InputTextImage").gameObject
    self.numGruopTransform = self.transform:Find("BoomPanel/Boom/NumGruop")
    for i = 1, 3 do
        table.insert(self.numGruop, self.numGruopTransform:Find("Num"..i):GetComponent(Image))
    end

    -- self.timeText = self.transform:Find("TimeBg/TimeText"):GetComponent(Text)
    self.clockTimeText = self.transform:Find("Clock/Text"):GetComponent(Text)
    self.timeBar = self.transform:Find("BoomPanel/Boom/BoomLine"):GetComponent(RectTransform)

    local memberContainer = self.transform:Find("MemberPanel/Container")
    local memberItem = self.transform:Find("MemberPanel/Item").gameObject
    memberItem:SetActive(true)
    self.transform:Find("MemberPanel"):GetComponent(ScrollRect).enabled = false
    for i=1, 6 do 
        local item = GameObject.Instantiate(memberItem).transform
        item:SetParent(memberContainer)
        item.localScale = Vector3(0.8, 0.8, 0.8)
        item.localPosition = Vector3.zero
        item:GetComponent(RectTransform).anchoredPosition = Vector2(-42 + 87 * (i-1), -66)

        local headSlot = HeadSlot.New()
        headSlot:SetRectParent(item:Find("RoleImage"))
        headSlot:HideSlotBg(true, 0)
        local sexImage = item:Find("Sex"):GetComponent(Image)
        local nameText = item:Find("NameText"):GetComponent(Text)
        local bubble = item:Find("Bubble").gameObject
        local bubbleText = item:Find("Bubble/Text"):GetComponent(Text)
        local bubbleTextExt = MsgItemExt.New(bubbleText, 200, 16, 22)
        local mask = item:Find("Mask").gameObject
        table.insert(self.memberList, { gameObject = item.gameObject, headSlot = headSlot, sexImage = sexImage, nameText = nameText, mask = mask, bubble = bubble, bubbleText = bubbleText, bubbleTextExt = bubbleTextExt } )
    end
    memberItem:SetActive(false)
    self.memberContainer = memberContainer

    local boomMan = self.transform:Find("BoomMan")
    local headSlot = HeadSlot.New()
    headSlot:SetRectParent(boomMan:Find("RoleImage"))
    headSlot:HideSlotBg(true, 0)
    local sexImage = boomMan:Find("Sex"):GetComponent(Image)
    local nameText = boomMan:Find("NameText"):GetComponent(Text)
    local bubble = boomMan:Find("Bubble").gameObject
    local bubbleText = boomMan:Find("Bubble/Text"):GetComponent(Text)
    local bubbleTextExt = MsgItemExt.New(bubbleText, 200, 16, 22)
    local animator = boomMan:Find("RoleImage"):GetComponent(Animator)
    self.boomMan = { gameObject = boomMan.gameObject, headSlot = headSlot, sexImage = sexImage, nameText = nameText, bubble = bubble, bubbleText = bubbleText, bubbleTextExt = bubbleTextExt, animator = animator }

    -- 特效
    -- 手指
    self.effect20504 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20504)))
    self.effect20504.transform:SetParent(self.transform:Find("BoomPanel/Boom"))
    self.effect20504.transform.localScale = Vector3.one
    self.effect20504.transform.localPosition = Vector3(-35, 45, -300)
    self.effect20504:SetActive(false)

    -- 心跳
    self.effect20505 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20505)))
    self.effect20505.transform:SetParent(self.transform:Find("BoomPanel/Boom"))
    self.effect20505.transform.localScale = Vector3.one
    self.effect20505.transform.localPosition = Vector3(108, 0, -300)

    -- 火花
    self.effect20506 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20506)))
    self.effect20506.transform:SetParent(self.transform:Find("BoomPanel/Boom/BoomLine/Effect"))
    self.effect20506.transform.localScale = Vector3.one
    self.effect20506.transform.localPosition = Vector3(4, 7, -300)

    -- 发抖
    self.effect20507 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20507)))
    self.effect20507.transform:SetParent(self.transform:Find("BoomMan"))
    self.effect20507.transform.localScale = Vector3.one
    self.effect20507.transform.localPosition = Vector3(0, 0, -300)

    -- 抓人
    self.effect20508 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20508)))
    self.effect20508.transform:SetParent(self.transform:Find("BoomMan"))
    self.effect20508.transform.localScale = Vector3.one
    self.effect20508.transform.localPosition = Vector3(0, -30, -300)
    self.effect20508:SetActive(false)
    
    -- 按钮
    self.effect20509 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20509)))
    self.effect20509.transform:SetParent(self.transform:Find("BoomPanel/Boom/OkButton"))
    self.effect20509.transform.localScale = Vector3(0.7, 0.7, 1)
    self.effect20509.transform.localPosition = Vector3(0, 0, -300)
    self.effect20509:SetActive(false)

    -- 爆炸
    self.effect20510 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20510)))
    self.effect20510.transform:SetParent(self.transform)
    self.effect20510.transform.localScale = Vector3.one
    self.effect20510.transform.localPosition = Vector3(276, -240, -300)
    self.effect20510:SetActive(false)

    -- 炸黑表情
    self.effect20511 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20511)))
    self.effect20511.transform:SetParent(self.transform:Find("BoomMan"))
    self.effect20511.transform.localScale = Vector3.one
    self.effect20511.transform.localPosition = Vector3(0, 0, -300)
    self.effect20511:SetActive(false)

    -- 安全过关
    self.effect20514 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20514)))
    self.effect20514.transform:SetParent(self.transform)
    self.effect20514.transform.localScale = Vector3.one
    self.effect20514.transform.localPosition = Vector3(200, -160, -300)
    self.effect20514:SetActive(false)

    -- 轮到你了
    self.effect20515 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20515)))
    self.effect20515.transform:SetParent(self.transform)
    self.effect20515.transform.localScale = Vector3.one
    self.effect20515.transform.localPosition = Vector3(200, -160, -300)
    self.effect20515:SetActive(false)

    -- 游戏开始
    self.effect20517 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20517)))
    self.effect20517.transform:SetParent(self.transform)
    self.effect20517.transform.localScale = Vector3.one
    self.effect20517.transform.localPosition = Vector3(200, -160, -300)
    self.effect20517:SetActive(false)

    self.effect20518 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20518)))
    self.effect20518.transform:SetParent(self.transform:Find("TimeBg"))
    self.effect20518.transform.localScale = Vector3.one
    self.effect20518.transform.localPosition = Vector3(0, 0, -300)
    self.effect20518:SetActive(false)

    ----------------------------
    self:SetData(self.data)
    self:ClearMainAsset()
end

function TruthordareBoomPanel:MiniPanel(andCloseChatPanel)
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

function TruthordareBoomPanel:SetData(data)
    self.data = data
    if BaseUtils.isnull(self.gameObject) then
        return
    end

    self:SetActive(true)
end

function TruthordareBoomPanel:SetActive(active)
    self.isActive = true
    if not BaseUtils.isnull(self.gameObject) then
        self.gameObject:SetActive(active)

        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
        end

        if active then
            self.transform.localScale = Vector3.one
    
            self.time = TruthordareManager.Instance.model.boomTime - BaseUtils.BASE_TIME
            self.timer = LuaTimer.Add(0, 200, function() self:OnTimer() end)

            TruthordareManager.Instance.OnUpdate:Remove(self._Update)
            TruthordareManager.Instance.OnUpdate:Add(self._Update)
            TruthordareManager.Instance.OnUpdateState:Remove(self._Boom)
            TruthordareManager.Instance.OnUpdateState:Add(self._Boom)
            TruthordareManager.Instance.OnBoomManChooseNumUpdate:Remove(self._BoomManChooseNum)
            TruthordareManager.Instance.OnBoomManChooseNumUpdate:Add(self._BoomManChooseNum)

            TruthordareManager.Instance:Send19517()

            self:Update()
        else
            TruthordareManager.Instance.OnUpdate:Remove(self._Update)
            TruthordareManager.Instance.OnUpdateState:Remove(self._Boom)
            TruthordareManager.Instance.OnBoomManChooseNumUpdate:Remove(self._BoomManChooseNum)

            if self.boomManTweenId ~= nil then
                Tween.Instance:Cancel(self.boomManTweenId)
                self.boomManTweenId = nil
            end

            if self.memberContainerTweenId ~= nil then
                Tween.Instance:Cancel(self.memberContainerTweenId)
                self.memberContainerTweenId = nil
            end

            if self.boomLineTweenId ~= nil then
                Tween.Instance:Cancel(self.boomLineTweenId)
                self.boomLineTweenId = nil
            end

            if self.boomNumTweenId ~= nil then
                Tween.Instance:Cancel(self.boomNumTweenId)
                self.boomNumTweenId = nil
            end

            self.notUpdate_BoomManChooseNum = false

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

function TruthordareBoomPanel:InputNum(num)
    local nowAnswerNum = self.answerNum
    nowAnswerNum = nowAnswerNum * 10 + num
    -- if nowAnswerNum < self.minNum then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("超出答案范围"))
    --     self.answerNum = self.minNum
    -- elseif nowAnswerNum > self.maxNum then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("超出答案范围"))
    --     self.answerNum = self.maxNum
    -- else
    --     self.answerNum = nowAnswerNum
    -- end
    if nowAnswerNum > self.maxNum then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请输入<color='#ffff00'>%s</color>至<color='#ffff00'>%s</color>中的一个数字吧！{face_1,11}"), self.minNum, self.maxNum))
        return
    end
    self.answerNum = nowAnswerNum
    self:ShowNumImage(self.answerNum)
end

function TruthordareBoomPanel:OnButtonOk()
    if self.answerNum < self.minNum then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请输入<color='#ffff00'>%s</color>至<color='#ffff00'>%s</color>中的一个数字吧！{face_1,11}"), self.minNum, self.maxNum))
    elseif self.answerNum > self.maxNum then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请输入<color='#ffff00'>%s</color>至<color='#ffff00'>%s</color>中的一个数字吧！{face_1,11}"), self.minNum, self.maxNum))
    else
        self.numPanel:SetActive(false)
        self.effect20505:SetActive(true)
        if TruthordareManager.Instance.model:IsBoomMan() then
            self.effect20509:SetActive(true)
        else
            self.effect20509:SetActive(false)
        end
    end
    -- self.numPanel:SetActive(false)
end

function TruthordareBoomPanel:OnButtonCancel()
    self.answerNum = math.floor(self.answerNum / 10)
    -- if self.answerNum < self.minNum then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("超出答案范围"))
    --     self.answerNum = self.minNum
    -- end
    self:ShowNumImage(self.answerNum)
end

function TruthordareBoomPanel:ShowNumImage(num)
    if num == nil then
        self.inputTextImage:SetActive(true)
        self:UpdateNumGruop(self.numGruop)
    else
        self.inputTextImage:SetActive(false)
        
        self:UpdateNumGruop(self.numGruop, num)
        self.numGruopTransform.localPosition = Vector3(-32, 40, 0)
    end
end

function TruthordareBoomPanel:SendBoom()
    if TruthordareManager.Instance.model:IsBoomMan() then
        if self.answerNum < self.minNum then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请输入<color='#ffff00'>%s</color>至<color='#ffff00'>%s</color>中的一个数字吧！{face_1,11}"), self.minNum, self.maxNum))
        elseif self.answerNum > self.maxNum then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请输入<color='#ffff00'>%s</color>至<color='#ffff00'>%s</color>中的一个数字吧！{face_1,11}"), self.minNum, self.maxNum))
        else
            TruthordareManager.Instance:Send19518(self.answerNum)
        end
    else
        local boomManData = TruthordareManager.Instance.model.boomMan
        if boomManData ~= nil then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#25EEF6'>%s</color>正在拆弹，给ta出点好主意吧{face_1,15}"), boomManData.role_name))
        end
    end
end

function TruthordareBoomPanel:OnTimer()
    -- if self.time > 0 then
    --     self.time = self.time - 1

    --     -- self.timeText.text = string.format(TI18N("剩余: %s秒"), self.time)
    --     self.clockTimeText.text = tostring(self.time)
    -- else
        
    -- end

    local time = TruthordareManager.Instance.model.boomTime - BaseUtils.BASE_TIME
    if time > 0 then
        self.clockTimeText.text = tostring(time)
    end

    if not TruthordareManager.Instance.model:IsBoomMan() then
        if not self.notUpdate_BoomManChooseNum then
            self:ShowNumImage(Random.Range(self.minNum, self.maxNum+1))
        end
    end

    self.count = self.count + 1
    if self.count > self.countMax then
        self.count = 0
        self:ShowTalk(self.count_TalkIndex)
        self.count_TalkIndex = self.count_TalkIndex + 1
        if self.count_TalkIndex > 6 then
            self.count_TalkIndex = 1
        end
    end
    
end

function TruthordareBoomPanel:OnRuleButton()
    self.parent:OpenGuidePanelFun()
end

function TruthordareBoomPanel:OnEditorButton()
    TruthordareManager.Instance.model:OpenEditorWindow()
end

function TruthordareBoomPanel:Update()
    if self.notUpdate_BoomManChooseNum then
        return
    end

    local data = TruthordareManager.Instance.model
    self.minNum = data.min_num
    self.maxNum = data.max_num
    self.time = data.boomTime - BaseUtils.BASE_TIME

    self.roundText.text = string.format(TI18N("当前第%s轮 共%s轮"), data.now_round, data.max_round)
    -- self.boomText.text = string.format(TI18N("爆炸范围：%s - %s"), self.minNum, self.maxNum)
    self.effect20518:SetActive(false)
    self.effect20518:SetActive(true)
    self:UpdateNumGruop(self.numGruop1, self.minNum)
    self:UpdateNumGruop(self.numGruop2, self.maxNum)
    -- self.timeBar.localScale = Vector3((self.maxNum - self.minNum) / self.totalNum, 1, 1)
    -- self.timeBar.sizeDelta = Vector2((self.maxNum - self.minNum) / self.totalNum * 250 + 10, 21)
    if self.boomLineTweenId ~= nil then
        Tween.Instance:Cancel(self.boomLineTweenId)
        self.boomLineTweenId = nil
    end
    local from = self.timeBar.sizeDelta.x
    local to = (self.maxNum - self.minNum) / self.totalNum * 250 + 10
    self.boomLineTweenId = Tween.Instance:ValueChange(from, to, 2, nil, LeanTweenType.easeOutQuart, function(value)
            self.timeBar.sizeDelta = Vector2(value, 21)
        end).id

    self:ShowNumImage()

    if TruthordareManager.Instance.model.boomMan ~= nil then
        self:UpdateMember()
    end

    if self.minNum == 1 and self.maxNum == 200 then
        self.effect20514:SetActive(false)
        self.effect20517:SetActive(false)
        self.effect20517:SetActive(true)
    else
        self.effect20517:SetActive(false)
    end

    if not TruthordareManager.Instance.model:GetInRoom() and TruthordareManager.Instance.model.vacancy > 0 and TruthordareManager.Instance.model.now_round ~= TruthordareManager.Instance.model.max_round then
        self:ShowDuangEffect(1, true)
    else
        self:ShowDuangEffect(1, false)
    end
    TruthordareManager.Instance.model:UpdateExitRoomButton(self.exitButtonText, self.exitButtonImage1, self.exitButtonImage2)
end

function TruthordareBoomPanel:UpdateMember()
    local boomManData = TruthordareManager.Instance.model.boomMan
    if boomManData ~= nil then
        self.boomMan.headSlot:SetAll(boomManData, {isSmall = true})
        self.boomMan.nameText.text = boomManData.role_name
        self.boomMan.sexImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (boomManData.sex == 0 and "IconSex0" or "IconSex1"))

        -- 调到特效后面再播放了
        -- local talkList = DataGuildTruthDare.data_talk[2].talk_list
        -- local talk = talkList[Random.Range(1, #talkList)]
        -- if talk == nil or talk == "" then
        --     self.boomMan.bubble:SetActive(false)
        -- else
        --     self.boomMan.bubble:SetActive(true)    
        --     self.boomMan.bubbleText.text = talk
        --     local w = self.boomMan.bubbleText.preferredWidth + 13
        --     self.boomMan.bubbleText:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
        --     self.boomMan.bubble:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
        -- end

        self.boomMan.bubble:SetActive(false)
    end

    if TruthordareManager.Instance.model:IsBoomMan() then
        -- self.effect20504:SetActive(true)
    else
        self.effect20504:SetActive(false)
        self.numPanel:SetActive(false)
        self.effect20505:SetActive(true)
        self.effect20509:SetActive(false)
    end

    local queue = TruthordareManager.Instance.model:GetRoomQueue()
    for i, v in ipairs(self.memberList) do
        local data = queue[i]
        if data ~= nil then 
            data.id = data.rid
            v.headSlot:SetAll(data, {isSmall = true, clickCallback = function() self:OnClickHead(i) end})
            v.nameText.text = data.role_name
            v.sexImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (data.sex == 0 and "IconSex0" or "IconSex1"))

            
            if i == 3 then
                v.gameObject.transform.localScale = Vector3(1, 1, 1)
                v.mask:SetActive(true)
                v.bubble:SetActive(false)
            end

            if i < 3 then
                local talkList = DataGuildTruthDare.data_talk[3].talk_list
                local talk = talkList[Random.Range(1, #talkList)]
                if talk == nil or talk == "" then
                    v.bubble:SetActive(false)
                else
                    v.bubble:SetActive(true)    
                    v.bubbleText.text = talk
                    local w = v.bubbleText.preferredWidth + 13
                    v.bubbleText:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
                    v.bubble:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
                end
            elseif i > 3 then
                local talkList = DataGuildTruthDare.data_talk[4].talk_list
                local talk = talkList[Random.Range(1, #talkList)]
                if talk == nil or talk == "" then
                    v.bubble:SetActive(false)
                else
                    v.bubble:SetActive(true)    
                    v.bubbleText.text = talk
                    local w = v.bubbleText.preferredWidth + 13
                    v.bubbleText:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
                    v.bubble:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
                end
            end
        end
    end

    if self.lastBoomManData ~= nil and boomManData ~= nil and self.lastBoomManData.rid == boomManData.id and self.lastBoomManData.platform == boomManData.platform and self.lastBoomManData.zone_id == boomManData.zone_id then
        -- self.boomMan.gameObject.transform.localPosition = Vector3(76, -230, 0)
        self.boomMan.gameObject:SetActive(true)
    else
        -- 显示下一个特效
        if self.lastBoomManData ~= nil then
            self.effect20514:SetActive(false)
            self.effect20514:SetActive(true)
        end

        -- 移动玩家队列
        self.boomMan.gameObject:SetActive(false)
        self.memberContainer.localPosition = Vector3(-215 + 87, 65, 0)
        if self.memberContainerTweenId ~= nil then
            Tween.Instance:Cancel(self.memberContainerTweenId)
            self.memberContainerTweenId = nil
        end
        self.memberContainerTweenId = Tween.Instance:MoveLocal(self.memberContainer.gameObject, Vector3(-215, 65, 0), 1.5, 
            function() 
                if BaseUtils.isnull(self.gameObject) then
                    return
                end
                
                -- 显示抓特效
                self.boomMan.animator.enabled = false
                self.boomMan.gameObject:SetActive(true)
                self.boomMan.gameObject.transform.position = self.memberList[3].gameObject.transform.position
                self.effect20508:SetActive(true)
                LuaTimer.Add(500, function() 
                    if BaseUtils.isnull(self.gameObject) then
                        return
                    end
                    -- 显示抓玩家起来特效
                    if self.boomManTweenId ~= nil then
                        Tween.Instance:Cancel(self.boomManTweenId)
                        self.boomManTweenId = nil
                    end
                    self.boomManTweenId = Tween.Instance:MoveLocal(self.boomMan.gameObject, Vector3(76, -230, 0), 0.5, 
                        function() 
                            if BaseUtils.isnull(self.gameObject) then
                                return
                            end
                            -- 放下玩家特效
                            LuaTimer.Add(400, function() 
                                if BaseUtils.isnull(self.gameObject) then
                                    return
                                end
                                self.effect20508:SetActive(false)
                                -- 显示轮到你啦特效
                                if TruthordareManager.Instance.model:IsBoomMan() then
                                    self.effect20515:SetActive(false)
                                    self.effect20515:SetActive(true)
                                else
                                    self.effect20515:SetActive(false)
                                end

                                self:ShowTalk(3)
                                self.boomMan.animator.enabled = true

                                LuaTimer.Add(1000, function() 
                                    if BaseUtils.isnull(self.gameObject) then
                                        return
                                    end
                                    if TruthordareManager.Instance.model:IsBoomMan() then
                                        self.effect20504:SetActive(false)
                                        self.effect20504:SetActive(true)
                                    end
                                end)
                                -- -- 到自己时直接打开数字输入面版
                                -- if TruthordareManager.Instance.model:IsBoomMan() then
                                --     self.answerNum = 0
                                --     self.numPanel:SetActive(true) 
                                --     self.effect20505:SetActive(false)
                                --     -- self.effect20504:SetActive(false)
                                --     self.effect20509:SetActive(false)
                                -- end
                            end)
                        end, LeanTweenType.easeOutQuart).id
                end)
            end, LeanTweenType.easeOutQuart).id
    end

    self.lastBoomManData = BaseUtils.copytab(boomManData)
end

function TruthordareBoomPanel:UpdateNumGruop(numGruop, num)
    if num == nil then
        numGruop[1].gameObject:SetActive(false)
        numGruop[2].gameObject:SetActive(false)
        numGruop[3].gameObject:SetActive(false)
    else
        numGruop[3].gameObject:SetActive(true)
        numGruop[3].sprite = self.assetWrapper:GetSprite(AssetConfig.truthordare_textures, "Num"..(num % 10))
        numGruop[3]:SetNativeSize()

        if num >= 10 then
            numGruop[2].gameObject:SetActive(true)
            numGruop[2].sprite = self.assetWrapper:GetSprite(AssetConfig.truthordare_textures, "Num"..(math.floor(num / 10) % 10))
            numGruop[2]:SetNativeSize()
        else
            numGruop[2].gameObject:SetActive(false)
        end

        if num >= 100 then
            numGruop[1].gameObject:SetActive(true)
            numGruop[1].sprite = self.assetWrapper:GetSprite(AssetConfig.truthordare_textures, "Num"..(math.floor(num / 100) % 10))
            numGruop[1]:SetNativeSize()
        else
            numGruop[1].gameObject:SetActive(false)
        end
    end
end

function TruthordareBoomPanel:Boom()
    if TruthordareManager.Instance.model.state == 4 then
        self.effect20510:SetActive(false)
        self.effect20510:SetActive(true)
        LuaTimer.Add(400, function() 
            if BaseUtils.isnull(self.gameObject) then
                return
            end
            self.effect20511:SetActive(false)
            self.effect20511:SetActive(true)

            LuaTimer.Add(2000, function() 
                if BaseUtils.isnull(self.gameObject) then
                    return
                end
                self.panelType = 0
                self.parent:OpenPanel()
            end)
        end)
    end
end

function TruthordareBoomPanel:BoomManChooseNum(num, index, min, max)
    local model = TruthordareManager.Instance.model
    if min ~= max then
        --玩家名输入了XX，轰的一声爆炸了{face_1,58}
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#25EEF6'>%s</color>输入了<color='#ffff00'>%s</color>，爆炸范围更新为<color='#ffff00'>%s</color>-<color='#ffff00'>%s</color>"), model.boomMan.role_name, num, min, max))
    else
        if num == min then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#25EEF6'>%s</color>输入了<color='#ffff00'>%s</color>，轰的一声爆炸了{face_1,58}"), model.boomMan.role_name, num))
        else
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#25EEF6'>%s</color>输入了<color='#ffff00'>%s</color>，爆炸范围更新为<color='#ffff00'>%s</color>-<color='#ffff00'>%s</color>"), model.boomMan.role_name, num, min, max))
        end
        
    end
    
    self:ShowNumImage(num)

    self.notUpdate_BoomManChooseNum = true
    if self.boomNumTweenId ~= nil then
        Tween.Instance:Cancel(self.boomNumTweenId)
        self.boomNumTweenId = nil
    end
    
    local toX = 12.5
    if index == 2 then 
        toX = 88
    end
    self.boomNumTweenId = Tween.Instance:MoveLocal(self.numGruopTransform.gameObject, Vector3(toX, 133, 0), 1, 
        function() 
            if BaseUtils.isnull(self.gameObject) then
                return
            end
            -- self:ShowNumImage(num)
            self.notUpdate_BoomManChooseNum = false
            self:Update()
        end, LeanTweenType.linear).id
end

function TruthordareBoomPanel:ShowTalk(index)
    if index == 3 then
        local talkList = DataGuildTruthDare.data_talk[2].talk_list
        local talk = talkList[Random.Range(1, #talkList)]
        if talk == nil or talk == "" then
            self.boomMan.bubble:SetActive(false)
        else
            self.boomMan.bubble:SetActive(true)    
            -- self.boomMan.bubbleText.text = talk
            self.boomMan.bubbleTextExt:SetData(talk)
            local w = self.boomMan.bubbleText.preferredWidth + 14
            self.boomMan.bubbleText:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
            self.boomMan.bubble:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
        end
    elseif index < 3 then
        local v = self.memberList[index]
        local talkList = DataGuildTruthDare.data_talk[3].talk_list
        local talk = talkList[Random.Range(1, #talkList)]
        if talk == nil or talk == "" then
            v.bubble:SetActive(false)
        else
            v.bubble:SetActive(true)    
            -- v.bubbleText.text = talk
            v.bubbleTextExt:SetData(talk)
            local w = v.bubbleText.preferredWidth + 14
            v.bubbleText:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
            v.bubble:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
        end
    elseif index > 3 then
        local v = self.memberList[index]
        local talkList = DataGuildTruthDare.data_talk[4].talk_list
        local talk = talkList[Random.Range(1, #talkList)]
        if talk == nil or talk == "" then
            v.bubble:SetActive(false)
        else
            v.bubble:SetActive(true)    
            -- v.bubbleText.text = talk
            v.bubbleTextExt:SetData(talk)
            local w = v.bubbleText.preferredWidth + 14
            v.bubbleText:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
            v.bubble:GetComponent(RectTransform).sizeDelta = Vector2(w, 30)
        end
    end
end

function TruthordareBoomPanel:OnClickHead(index)
    local queue = TruthordareManager.Instance.model:GetRoomQueue()
    local data = queue[index]
    if data ~= nil then
        local roleData = RoleManager.Instance.RoleData
        if data.rid == roleData.id and data.platform == roleData.platform and data.zone_id == roleData.zone_id then
        else
            TipsManager.Instance:ShowPlayer({ id = data.rid, zone_id = data.zone_id, platform = data.platform, sex = data.sex, classes = data.classes, name = data.role_name })
        end
    end
end

function TruthordareBoomPanel:ShowDuangEffect(index, show)
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