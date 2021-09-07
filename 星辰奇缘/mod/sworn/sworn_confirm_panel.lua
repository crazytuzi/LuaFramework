-- @author 黄耀聪
-- @date 2016年10月25日

SwornConfirmPanel = SwornConfirmPanel or BaseClass(BasePanel)

function SwornConfirmPanel:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.name = "SwornConfirmPanel"
    self.mgr = SwornManager.Instance
    self.assetWrapper = assetWrapper
    self.rankResultList = {}
    self.confirmed = false
    self.statusListener = function(status) self:ReloadStatus() self:StatusChange(status) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornConfirmPanel:__delete()
    self.OnHideEvent:Fire()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.effect1 ~= nil then
        self.effect1:DeleteMe()
        self.effect1 = nil
    end
    if self.customEffect ~= nil then
        self.customEffect:DeleteMe()
        self.customEffect = nil
    end
    if self.swornEffect ~= nil then
        self.swornEffect:DeleteMe()
        self.swornEffect = nil
    end
    if self.singleEffect ~= nil then
        self.singleEffect:DeleteMe()
        self.singleEffect = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    self:AssetClearAll()
end

function SwornConfirmPanel:InitPanel()
    local t = self.gameObject.transform
    self.transform = t

    self.descObj = t:Find("Desc").gameObject
    self.titleObj = t:Find("Desc/Title").gameObject
    self.figureprint = t:Find("Desc/ConfirmArea"):GetComponent(CustomButton)
    self.highFigurePrint = t:Find("Desc/Figureprite/Confirm"):GetComponent(Image)
    self.descText = t:Find("Desc"):GetComponent(Text)
    self.descTitleText = t:Find("Desc/Title/Text"):GetComponent(Text)
    self.bg = t:Find("Bg")
    self.descTimeText = t:Find("Desc/Clock/Time"):GetComponent(Text)

    self.guideEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset("prefabs/effect/20103.unity3d"))
    self.guideEffect.transform:SetParent(t:Find("Desc/ConfirmArea"))
    self.guideEffect.transform.localScale = Vector3.one
    self.guideEffect.transform.localPosition = Vector3(229, -37, -500)
    Utils.ChangeLayersRecursively(self.guideEffect.transform, "UI")
    self.guideEffect:SetActive(true)

    local result = t:Find("Result")
    for i=1,5 do
        local tab = {}
        tab.transform = result:GetChild(i - 1)
        tab.transform:Find("Mask"):GetComponent(Image).color = Color(1, 1, 1, 5/255)
        tab.headImage = tab.transform:Find("Mask/Head"):GetComponent(Image)
        tab.gameObject = tab.transform.gameObject
        tab.select = tab.transform:Find("Select").gameObject
        tab.rankHonorText = tab.transform:Find("Rank/Text"):GetComponent(Text)
        tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
        tab.figure = tab.transform:Find("Figure").gameObject
        tab.tick = tab.transform:Find("Tick").gameObject
        self.rankResultList[i] = tab
        tab.figure:SetActive(false)
    end
    self.resultContainer = result

    self.honorContainer = t:Find("Honor")
    self.clockImage = self.honorContainer:Find("Title/Clock"):GetComponent(Image)
    self.timeText = self.honorContainer:Find("Title/Time"):GetComponent(Text)
    self.swornInputField = self.honorContainer:Find("Sworn"):GetComponent(InputField)
    self.swornSelectImage = self.honorContainer:Find("Sworn/Select"):GetComponent(Image)
    self.singleInputField = self.honorContainer:Find("Single"):GetComponent(InputField)
    self.singleSelectImage = self.honorContainer:Find("Single/Select"):GetComponent(Image)
    self.numText = self.honorContainer:Find("Text"):GetComponent(Text)
    self.numText1 = self.honorContainer:Find("Text1"):GetComponent(Text)
    self.swornBtn = self.honorContainer:Find("SwornBtn"):GetComponent(Button)
    self.swornText = self.honorContainer:Find("SwornBtn/Text"):GetComponent(Text)
    self.customInputField = self.honorContainer:Find("Custom"):GetComponent(InputField)
    self.customSelectImage = self.honorContainer:Find("Custom/Select"):GetComponent(Image)
    self.customBtn = self.honorContainer:Find("CustomBtn"):GetComponent(Button)
    self.honorTitleObj = self.honorContainer:Find("Title").gameObject
    self.honorTitleText = self.honorContainer:Find("Title/Text"):GetComponent(Text)
    self.button = self.honorContainer:Find("Button"):GetComponent(Button)
    self.finish = self.honorContainer:Find("Finish").gameObject
    self.dotObj = self.honorContainer:Find("Dot_I18N").gameObject
    self.descExt = MsgItemExt.New(self.honorContainer:Find("Desc"):GetComponent(Text), 600, 20, 23)

    self.figureprint.onDown:AddListener(function() self:OnDown() end)
    self.figureprint.onUp:AddListener(function() self:OnUp() end)

    self.button.onClick:AddListener(function() self:OnClick() end)
    self.swornBtn.onClick:AddListener(function() self:OnClick1() end)
    self.customBtn.onClick:AddListener(function() self:OnClick1() end)

    -- self.customEffect = BibleRewardPanel.ShowEffect(20138, self.customInputField.transform, Vector3(1, 1, 1), Vector3(0, 0, 0))
    -- self.swornEffect = BibleRewardPanel.ShowEffect(20138, self.swornInputField.transform, Vector3(1, 1, 1), Vector3(0, 0, 0))
    -- self.singleEffect = BibleRewardPanel.ShowEffect(20138, self.singleInputField.transform, Vector3(1, 1, 1), Vector3(0, 0, 0))
end

function SwornConfirmPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornConfirmPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.sworn_status_change, self.statusListener)

    if self.confirmed ~= true then
        self.highFigurePrint.color = Color(1, 1, 1, 0)
    end

    self:ReloadStatus()
    self:StatusChange(self.mgr.status)

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(0, 1000, function() self:OnTick() end)
end

function SwornConfirmPanel:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
end

function SwornConfirmPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.sworn_status_change, self.statusListener)
end

function SwornConfirmPanel:OnDown()
    if self.guideEffect ~= nil then
        self.guideEffect:SetActive(false)
    end
    if self.confirmed ~= true then
        if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
        end
        self.tweenId = Tween.Instance:Alpha(self.highFigurePrint.transform, 1, 3, function() self:Celebrate() self.mgr:send17704() self.confirmed = true self.tweenId = nil end).id
        if self.effect ~= nil then
            self.effect:DeleteMe()
        end
        self.effect = BibleRewardPanel.ShowEffect(20196, self.highFigurePrint.transform.parent, Vector3(1, 1, 1), Vector3(0, 0, -400))
    end
end

function SwornConfirmPanel:Celebrate()
    if self.effect1 ~= nil then
        self.effect1:DeleteMe()
    end
    self.effect1 = BibleRewardPanel.ShowEffect(20152, self.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))

    self.guideEffect:SetActive(false)
end

function SwornConfirmPanel:OnUp()
    if self.confirmed ~= true then
        if self.effect ~= nil then
            self.effect:DeleteMe()
        end
        if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
        end
        self.tweenId = Tween.Instance:Alpha(self.highFigurePrint.transform, 0, 0.5, function() self.tweenId = nil end).id

        NoticeManager.Instance:FloatTipsByString(TI18N("请<color='#ffff00'>长按</color>完成结拜契约{face_1,1}"))
    end
end

function SwornConfirmPanel:StatusChange(status)
    self.honorTitleText.alignment = 3
    self.swornBtn.gameObject:SetActive(false)
    self.dotObj:SetActive(true)
    if status == self.mgr.statusEumn.Honor then
        self.bg.sizeDelta = Vector2(585, 283.6)
        self.honorContainer.gameObject:SetActive(true)
        self.descObj:SetActive(false)
        self.swornInputField.gameObject:SetActive(true)
        self.singleInputField.gameObject:SetActive(true)
        self.customInputField.gameObject:SetActive(false)
        self.customBtn.gameObject:SetActive(true)
        if TeamManager.Instance:IsSelfCaptin() then
            self.honorTitleText.text = TI18N("当前操作剩余时间:")
            self.button.enabled = true
            BaseUtils.SetGrey(self.button.gameObject:GetComponent(Image), false)
            -- self.honorDescText.text = TI18N("（请输入结拜称号，以后可消耗一定钻石进行修改）")
            self.descExt:SetData(TI18N("你拥有结拜称号前缀的命名权，请输入结拜称号前缀{face_1,1}"))
        else
            self.honorTitleText.text = TI18N("当前操作剩余时间:")
            self.button.enabled = false
            BaseUtils.SetGrey(self.button.gameObject:GetComponent(Image), true)
            -- self.honorDescText.text = TI18N("（等待队长输入结拜称号，给TA点建议吧）")
            self.descExt:SetData(TI18N("等待队长输入<color='#ffff00'>结拜称号前缀</color>，给TA点建议吧{face_1,57}"))
        end
        self.honorTitleText.transform.anchoredPosition = Vector2(10, 0)
        self.numText.gameObject:SetActive(true)
        self.numText1.gameObject:SetActive(false)
        self.dotObj.transform.anchoredPosition = Vector2(42, 10)
        self.button.gameObject:SetActive(self.model.swornData.name == "")
        self.finish.gameObject:SetActive(self.model.swornData.name ~= "")
    elseif status == self.mgr.statusEumn.SubHonor then
        self.button.enabled = true
        BaseUtils.SetGrey(self.button.gameObject:GetComponent(Image), false)
        self.bg.sizeDelta = Vector2(585, 283.6)
        self.honorContainer.gameObject:SetActive(true)
        self.descObj:SetActive(false)
        self.swornText.text = self.model.swornData.name
        self.swornBtn.gameObject:SetActive(true)
        self.swornInputField.gameObject:SetActive(false)
        self.singleInputField.gameObject:SetActive(false)
        self.customInputField.gameObject:SetActive(true)
        self.customBtn.gameObject:SetActive(false)
        self.honorTitleText.transform.anchoredPosition = Vector2(10, 0)
        self.honorTitleText.text = TI18N("请输入<color='#ffff00'>结拜称号</color>:")
        self.numText.gameObject:SetActive(false)
        self.numText1.gameObject:SetActive(true)
        self.dotObj.transform.anchoredPosition = Vector2(11, 10)
        self.descExt:SetData(TI18N("请输入个人结拜称号（时间结束前未输入，系统将给予默认称号）"))
        self.button.gameObject:SetActive(self.model.swornData.members[self.model.myPos].name_defined == "")
        self.finish.gameObject:SetActive(self.model.swornData.members[self.model.myPos].name_defined ~= "")
    elseif status == self.mgr.statusEumn.Confirm then
        self.bg.sizeDelta = Vector2(585, 343.4)
        self.honorContainer.gameObject:SetActive(false)
        self.descObj:SetActive(true)

        self.descTitleText.text = string.format(TI18N("我<color='#00ff00'>%s</color>在此立誓:"), RoleManager.Instance.RoleData.name)

        for i,v in ipairs(self.rankResultList) do
            v.tick:SetActive(false)
            v.figure:SetActive(false)
        end
        for i,v in ipairs(self.model.swornData.votes) do
            local uid = BaseUtils.get_unique_roleid(v.v_id, v.v_zone_id, v.v_platform)
            self.rankResultList[self.model.menberTab[uid]].figure:SetActive(true)
        end

        local format = "<color='#00ff00'>%s</color>"
        local res = ""
        local roleData = RoleManager.Instance.RoleData
        local c = 0
        local myInfo = nil
        for i,v in ipairs(self.model.swornData.members) do
            if roleData.id ~= v.m_id or roleData.platform ~= v.m_platform or roleData.zone_id ~= v.m_zone_id then
                c = c + 1
                res = res .. string.format(format, v.name)
                if c ~= #self.model.swornData.members then
                    res = res .. TI18N("、")
                end
            else
                myInfo = v
            end
        end
        self.descText.text = string.format(TI18N("愿以<color='#ffff00'>%s</color>为名，与%s结为异姓兄弟姐妹，从此有福同享、有难同当！"), self.model.swornData.name .. "之" .. self.model.rankList[self.model.myPos] .. tostring(myInfo.name_defined), res)
    end

    local size = self.descExt.contentRect.sizeDelta
    self.descExt.contentRect.anchoredPosition = Vector2(-size.x / 2, -60)
end

function SwornConfirmPanel:ReloadStatus()
    local model = self.model
    local swornData = self.model.swornData or {}
    local teamMgr = TeamManager.Instance

    local memberData = swornData.members or {}

    self.numText.text = model.numList[#model.memberUidList]

    -- print("model.myPos = " .. tostring(model.myPos))
    self.numText1.text = model.rankList[model.myPos]

    if model.myPos ~= nil and model.myPos ~= 0 then
        for i,v in ipairs(self.rankResultList) do
            local member = memberData[i]
            if member ~= nil then
                v.gameObject:SetActive(true)
                v.select:SetActive(false)
                v.rankHonorText.text = model.nameTab[member.sex][model.myPos][i]
                v.nameText.text = member.name
                v.headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, member.classes .. "_" .. member.sex)
                v.tick:SetActive(member.name_defined ~= "")
            else
                v.gameObject:SetActive(false)
            end
        end
        self.resultContainer.sizeDelta = Vector2(110 * #memberData, 100)
    end

    if self.customInputField.text == "" then
        if RoleManager.Instance.RoleData.sex == 0 then
            self.customInputField.text = TI18N("姐")
        else
            self.customInputField.text = TI18N("哥")
        end
    end
    -- self.listTitleText.text = string.format(TI18N("投票选出<color='#00ff00'>%s</color>"), model.normalList[model.votePos])
end

function SwornConfirmPanel:OnTick()
    local swornData = SwornManager.Instance.model.swornData or {}
    local timeout = swornData.timeout or BaseUtils.BASE_TIME

    local m = nil
    local s = nil
    local _ = nil
    
    local t = timeout - BaseUtils.BASE_TIME
    if t < 0 then t = 0 end
    _,_,m,s = BaseUtils.time_gap_to_timer(t)
    if m < 10 then
        if s < 10 then
            self.timeText.text = string.format("0%s:0%s", tostring(m), tostring(s))
        else
            self.timeText.text = string.format("0%s:%s", tostring(m), tostring(s))
        end
    else
        if s < 10 then
            self.timeText.text = string.format("%s:0%s", tostring(m), tostring(s))
        else
            self.timeText.text = string.format("%s:%s", tostring(m), tostring(s))
        end
    end
    self.descTimeText.text = self.timeText.text
end

function SwornConfirmPanel:OnClick()
    if self.mgr.status == self.mgr.statusEumn.Honor then
        if self.swornInputField.text ~= "" and self.singleInputField.text ~= "" then
            self.mgr:send17702(self.swornInputField.text, self.singleInputField.text)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请输入前缀称号"))
        end
    elseif self.mgr.status == self.mgr.statusEumn.SubHonor then
        if self.customInputField.text ~= "" then
            self.mgr:send17703(self.customInputField.text)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请输入自定义称号"))
        end
    end
end

function SwornConfirmPanel:OnClick1()
    if self.mgr.status == self.mgr.statusEumn.Honor then
        NoticeManager.Instance:FloatTipsByString(TI18N(""))
    elseif self.mgr.status == self.mgr.statusEumn.SubHonor then
        NoticeManager.Instance:FloatTipsByString(TI18N(""))
    end
end

function SwornConfirmPanel:BlingCustomImage()
    if self.customBlingId ~= nil then
        LuaTimer.Delete(self.customBlingId)
    end
end
