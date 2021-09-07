-- @author 黄耀聪
-- @date 2016年11月1日

SwornDescWindow = SwornDescWindow or BaseClass(BaseWindow)

function SwornDescWindow:__init(model)
    self.model = model
    self.name = "SwornDescWindow"
    self.mgr = SwornManager.Instance

    self.windowId = WindowConfig.WinID.sworn_desc_window

    self.resList = {
        {file = AssetConfig.sworn_desc_window, type = AssetType.Main},
        {file = AssetConfig.sworn_textures, type = AssetType.Dep},
        {file = AssetConfig.ridebg, type = AssetType.Main},
    }

    self.assetListener = function() self:OnAsset() end
    self.skillList = {}

    self.descString = TI18N("1.结拜需要<color='#13fc60'>2-5名</color>好友组队，等级<color='#13fc60'>≥50级</color>，每两人之间<color='#13fc60'>亲密度≥300</color>\n2.通过结拜试炼（战斗）考验后，可获得结拜资格\n3.规定的时间内，确定长幼排序、签订结拜契约后即可完成结拜\n4.结拜后仍可接纳新成员，最多<color='#13fc60'>10人</color>")

    self.assetString = TI18N("消耗:<color='#%s'>1000000</color>{assets_2, 90000}\n(结拜成员每人消耗)")
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornDescWindow:__delete()
    self.OnHideEvent:Fire()
    if self.ownExt ~= nil then
        self.ownExt:DeleteMe()
        self.ownExt = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.skillList ~= nil then
        for _,v in pairs(self.skillList) do
            if v ~= nil and v.slot ~= nil then
                v.slot:DeleteMe()
            end
        end
        self.skillList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SwornDescWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sworn_desc_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    self.titleText = main:Find("Title/Text"):GetComponent(Text)
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.noticeBtn = main:Find("Bg/Notice"):GetComponent(Button)

    self.descExt = MsgItemExt.New(main:Find("Desc/Desc"):GetComponent(Text), 292, 16, 19)
    self.timeText = main:Find("Buy/CountDown/Time"):GetComponent(Text)
    self.timeObj = main:Find("Buy/CountDown").gameObject

    self.ownExt = MsgItemExt.New(main:Find("Buy/Own"):GetComponent(Text), 197.7, 17, 26)
    self.ownExt.contentTxt.lineSpacing = 1.3
    self.button = main:Find("Buy/Button"):GetComponent(Button)

    self.preview = main:Find("Bg/Preview").gameObject

    local skillContainer = main:Find("Desc/Scroll/Container")
    local childCount = skillContainer.childCount
    for i=1,childCount do
        local tab = {}
        tab.transform = skillContainer:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        if i ~= 3 then
            tab.slot = SkillSlot.New()
            NumberpadPanel.AddUIChild(tab.transform:Find("Bg"), tab.slot.gameObject)
        end
        tab.btn = tab.gameObject:GetComponent(Button)
        tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
        self.skillList[i] = tab
    end

    self.button.onClick:AddListener(function() self:OnClick() end)
    main:Find("Bg/BigBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ridebg, "RideBg")
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.tipsLayout = main:Find("TipsLayout").gameObject
    self.tipsImage = main:Find("TipsLayout/Tips/Image"):GetComponent(Image)
    self.tipsNameText = main:Find("TipsLayout/Tips/Name"):GetComponent(Text)
    self.tipsLevelText = main:Find("TipsLayout/Tips/Lev"):GetComponent(Text)
    self.tipsDescText = main:Find("TipsLayout/Tips/Desc"):GetComponent(Text)
    self.tipsLayout:GetComponent(Button).onClick:AddListener(function() self:FakeTips(false) end)

    self.titleText.text = TI18N("结 拜")
    self.descExt:SetData(self.descString)

    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
end

function SwornDescWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornDescWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetListener)

    self:OnAsset()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(0, 1000, function() self:OnTick() end)

    self:UpdatePreview()
    self:ReloadSkill()

    self:FakeTips(false)
end

function SwornDescWindow:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function SwornDescWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
end

function SwornDescWindow:OnClick()
    if not TeamManager.Instance:HasTeam() then
        NoticeManager.Instance:FloatTipsByString("结拜需要2-5人组队进行{face_1,26}")
    elseif TeamManager.Instance:IsSelfCaptin() then
        local confirmData = NoticeConfirmData.New()
        confirmData.content = TI18N("是否邀请所有队员参与结拜？\n\n(每人需消耗<color='#00ff00'>1000000</color>{assets_2,90000})")
        confirmData.sureLabel = TI18N("发起结拜")
        confirmData.sureCallback = function() self.mgr:send17714() end
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        NoticeManager.Instance:FloatTipsByString("等待队长发起结拜吧{face_1,26}")
    end
end

function SwornDescWindow:OnAsset()
    if RoleManager.Instance.RoleData.coin >= 1000000 then
        self.ownExt:SetData(string.format(self.assetString, "00ff00"))
    else
        self.ownExt:SetData(string.format(self.assetString, "ff0000"))
    end
end

function SwornDescWindow:OnTick()
    local swornData = SwornManager.Instance.model.swornData or {}
    local timeout = swornData.timeout or BaseUtils.BASE_TIME

    local m = nil
    local s = nil
    local _ = nil

    local t = timeout - BaseUtils.BASE_TIME
    if t < 0 then t = 0 end
    _,_,m,s = BaseUtils.time_gap_to_timer(t)
    if SwornManager.Instance.status == SwornManager.Instance.statusEumn.Want then
        self.timeObj:SetActive(true)
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
    else
        self.timeObj:SetActive(false)
    end
end

function SwornDescWindow:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "SwornRole"
        ,orthographicSize = 1.0
        ,width = 400
        ,height = 600
        ,offsetY = -0.3
        ,offsetX = 0.05
        ,noDrag = true
    }
    local llooks = {}
    local BaseData = DataUnit.data_unit[20097]
    local modelData = {type = PreViewType.Npc, skinId = BaseData.skin, modelId = BaseData.res, animationId = BaseData.animation_id, scale = 1}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function SwornDescWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
end

function SwornDescWindow:OnNotice()
    local textList = {
        "1.结拜<color='#ffff00'>称号前缀</color>为队长设定",
        "2.结拜<color='#ffff00'>称号后缀</color>为个人设定",
        "3.后续可消耗银币进行修改"
    }
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = textList})
end

function SwornDescWindow:ReloadSkill()
    local model = self.model
    for i,v in ipairs(self.skillList) do
        local data = model.skillData[i]
        if i ~= 3 then
            local skillData = DataSkill.data_skill_other[data.id]
            v.slot:SetAll(Skilltype.swornskill, skillData)
            v.nameText.text = skillData.name
            v.btn.onClick:RemoveAllListeners()
            local slot = v.slot
            v.btn.onClick:AddListener(function() slot.button.onClick:Invoke() end)
        else
            v.nameText.text = data.name
            v.btn.onClick:RemoveAllListeners()
            v.btn.onClick:AddListener(function() self:FakeTips(true) end)
        end
    end
end

function SwornDescWindow:FakeTips(bool)
    if bool then
        local data = self.model.skillData[3]
        self.tipsImage.sprite = self.assetWrapper:GetSprite(AssetConfig.sworn_textures, "Unit")
        self.tipsNameText.text = data.name
        self.tipsDescText.text = data.desc
        self.tipsLevelText.text = data.about
        self.tipsLayout:SetActive(true)
    else
        self.tipsLayout:SetActive(false)
    end
end
