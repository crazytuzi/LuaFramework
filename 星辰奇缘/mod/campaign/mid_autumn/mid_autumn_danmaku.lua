-- @author 黄耀聪
-- @date 2016年9月11日

MidAutumnDanmaku = MidAutumnDanmaku or BaseClass(BaseWindow)

function MidAutumnDanmaku:__init(model)
    self.model = model
    self.name = "MidAutumnDanmaku"
    self.windowId = WindowConfig.WinID.mid_autumn_danmaku

    self.depPath = "textures/ui/forceimprove.unity3d"
    self.resList = {
        {file = AssetConfig.midAutumn_danmaku, type = AssetType.Main},
        {file = self.depPath, type = AssetType.Dep}
    }

    self.defaultString = {
        TI18N("幸福杯中酒，举杯邀明月，月圆人团圆，共享中秋月"),
        TI18N("中秋愉快！阖家欢乐！"),
        TI18N("一轮圆月挂天边，满心祝福涌心间"),
        TI18N("月圆人圆花好，事顺业顺家兴"),
        TI18N("皓月闪烁，星光闪耀，中秋佳节，美满快乐！"),
        TI18N("祝福阖家团团圆圆！"),
    }
    self.numString = TI18N("剩余:%s")
    self.itemBaseIdList = {23597, 23596}
    self.effectIdList = {20182, 20183}
    self.itemList = {}
    self.infoListener = function() self:OnInfo() end
    self.effectList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.itemDesc = {
        TI18N("祝福将有一定几率被系统抽选"),
        TI18N("必然发送一条特殊祝福"),
    }
    self.coolId = nil
end

function MidAutumnDanmaku:__delete()
    self.btnImg.sprite = nil
    self.OnHideEvent:Fire()
    if self.effectList ~= nil then
        for i,v in ipairs(self.effectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.effectList = nil
    end
    for k,v in pairs(self.itemList) do
        if v.slot ~= nil then
            v.slot:DeleteMe()
        end
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MidAutumnDanmaku:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.midAutumn_danmaku))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.inputField = t:Find("Main/InputField"):GetComponent(InputField)
    self.button = t:Find("Main/Button"):GetComponent(Button)
    self.btnImg = t:Find("Main/Button"):GetComponent(Image)
    self.btnTxt = t:Find("Main/Button/Text"):GetComponent(Text)

    self.descTxt = t:Find("Main/Desc"):GetComponent(Text)

    local use = t:Find("Main/Use")
    for i,v in ipairs(self.itemBaseIdList) do
        local tab = {}
        tab.transform = use:GetChild(i - 1)
        tab.slot = ItemSlot.New()
        NumberpadPanel.AddUIChild(tab.transform:Find("Slot").gameObject, tab.slot.gameObject)
        local data = ItemData.New()
        data:SetBase(DataItem.data_get[v])
        tab.slot:SetAll(data, {inbag = false, nobutton = true})
        tab.numText = tab.transform:Find("Num"):GetComponent(Text)
        tab.select = tab.transform:Find("Select").gameObject
        local h = i
        tab.transform:Find("Name"):GetComponent(Text).text = data.name
        self.itemList[i] = tab
        local btn = tab.transform.gameObject:GetComponent(Button)
        btn.onClick:AddListener(function() self:OnValueChanged(h) end)
        tab.slot.clickSelfFunc = function() self:OnValueChanged(h) end
    end

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self.button.onClick:AddListener(function() self:OnClick() end)
end

function MidAutumnDanmaku:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MidAutumnDanmaku:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.infoListener)

    self.inputField.text = self.defaultString[BaseUtils.BASE_TIME % #self.defaultString + 1]
    self:OnInfo()
    self:OnValueChanged(1)

    MidAutumnFestivalManager.Instance.dammakuCoolDownCallBack = function() self:UpdateBtnText() end
end

function MidAutumnDanmaku:OnHide()
    self:RemoveListeners()
    MidAutumnFestivalManager.Instance.dammakuCoolDownCallBack = nil
end

function MidAutumnDanmaku:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.infoListener)
end

function MidAutumnDanmaku:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function MidAutumnDanmaku:OnValueChanged(i)
    self.selectIndex = i
    for _,v in ipairs(self.itemList) do
        v.select:SetActive(false)
    end
    self.itemList[i].select:SetActive(true)
    self.descTxt.text = self.itemDesc[self.selectIndex]
end

function MidAutumnDanmaku:OnClick()
    if MidAutumnFestivalManager.Instance.dammakuCoolDown > 0 then
        -- 冷却中
        -- NoticeManager.Instance:FloatTipsByString(TI18N("冷却中"))
        return
    end

    local str = self.inputField.text or ""
    if str ~= nil then
        if BackpackManager.Instance:GetItemCount(self.itemBaseIdList[self.selectIndex]) > 0 then
            local baseid = self.effectIdList[self.selectIndex]
            if self.effectList[baseid] == nil then
                self.effectList[baseid] = BibleRewardPanel.ShowEffect(baseid, self.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
            else
                self.effectList[baseid].gameObject:SetActive(false)
                self.effectList[baseid].gameObject:SetActive(true)
            end
            MidAutumnFestivalManager.Instance:send14062(self.selectIndex, self.inputField.text or "")

            self.inputField.text = self.defaultString[BaseUtils.BASE_TIME % #self.defaultString + 1]
        else
            local baseid = self.itemBaseIdList[self.selectIndex]
            local baseData = DataItem.data_get[baseid]
            local msgStr = string.format(TI18N("[%s]不足，无法进行祈福"), ColorHelper.color_item_name(baseData.quality, baseData.name))
            NoticeManager.Instance:FloatTipsByString(msgStr)

            local info = {itemData = baseData, gameObject = self.button.gameObject}
            TipsManager.Instance:ShowItem(info)
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请输入祝福语{face_1,3}"))
    end
end

function MidAutumnDanmaku:OnInfo()
    for i,v in ipairs(self.itemBaseIdList) do
        local tab = self.itemList[i]
        local num = BackpackManager.Instance:GetItemCount(v)
        if num == 0 then
            tab.numText.text = string.format(self.numString, "<color='#ff0000'>0</color>")
        else
            tab.numText.text = string.format(self.numString, tostring(num))
        end
    end
end

function MidAutumnDanmaku:UpdateBtnText()
    if MidAutumnFestivalManager.Instance.dammakuCoolDown == 0 then
        self.btnTxt.text = TI18N("祈福")
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
    else
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.btnTxt.text = string.format(TI18N("祈福(%s秒)"), MidAutumnFestivalManager.Instance.dammakuCoolDown)
    end
end
