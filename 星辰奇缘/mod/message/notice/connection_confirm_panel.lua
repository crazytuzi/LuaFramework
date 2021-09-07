-- ------------------------
-- 消息提示确认框
-- hosr
-- ------------------------
ConnectionConfirmPanel = ConnectionConfirmPanel or BaseClass(BasePanel)

function ConnectionConfirmPanel:__init(model)
    self.model = model
    self.path = "prefabs/ui/notice/noticeconfirmpanel.unity3d"
    self.effectPath = string.format(AssetConfig.effect, 20118)
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Dep}
    }

    self.sureCall = nil
    self.cancelCall = nil
    self.toggleCall = nil

    self.timeId = 0
    self.sureCount = -1
    self.cancelCount = -1
    self.timeIdForContent = 0
    self.contentCount = -1
end

function ConnectionConfirmPanel:__delete()
end

function ConnectionConfirmPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.transform = self.gameObject.transform
    self.gameObject.name = "ConnectionConfirmPanel"
    UIUtils.AddUIChild(self.model.noticeCanvas, self.gameObject)
    self.gameObject:SetActive(false)

    self.panelBtn = self.transform:Find("Panel"):GetComponent(Button)
    self.mainRect = self.transform:Find("Main"):GetComponent(RectTransform)
    self.contentRect = self.transform:Find("Main/Content"):GetComponent(RectTransform)
    self.contentTxt_go = self.transform:Find("Main/Content/Text"):GetComponent(Text)
    self.contentTxt = MsgItemExt.New(self.contentTxt_go, 320, 18, 21)
    self.contentTxtRect = self.contentTxt_go.gameObject:GetComponent(RectTransform)
    self.toggleObj = self.transform:Find("Main/Toggle").gameObject
    self.toggle = self.toggleObj:GetComponent(Toggle)
    self.toggle.isOn = false
    self.toggle.onValueChanged:AddListener(function(bool) self:ClickToggle(bool) end)
    self.toggleLabel = self.transform:Find("Main/Toggle/Label"):GetComponent(Text)

    self.sureObj = self.transform:Find("Main/SureButton").gameObject
    self.sureImg = self.sureObj:GetComponent(Image)
    self.sureBtn = self.sureObj:GetComponent(Button)
    self.sureTrans = self.sureObj:GetComponent(RectTransform)
    self.sureLabel = self.sureTrans:Find("Text"):GetComponent(Text)
    self.sureLabelRect = self.sureLabel.gameObject:GetComponent(RectTransform)
    self.sureTxt = MsgItemExt.New(self.sureLabel, 130, 20, 22.5)

    self.cancelObj = self.transform:Find("Main/CancelButton").gameObject
    self.cancelImg = self.cancelObj:GetComponent(Image)
    self.cancelBtn = self.cancelObj:GetComponent(Button)
    self.cancelTrans = self.cancelObj:GetComponent(RectTransform)
    self.cancelLabel = self.cancelTrans:Find("Text"):GetComponent(Text)
    self.cancelLabelRect = self.cancelLabel.gameObject:GetComponent(RectTransform)
    self.cancelTxt = MsgItemExt.New(self.cancelLabel, 130, 20, 22.5)

    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)

    -- self.panelBtn.onClick:AddListener(function() self:Clear() end)
    self.sureBtn.onClick:AddListener(function() self:ClickSure() end)
    self.cancelBtn.onClick:AddListener(function() self:ClickCancel() end)
    self.CloseButton.onClick:AddListener(function() self:Clear() end)

    self:ClearMainAsset()

    self.sureEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
    self.sureEffect.transform:SetParent(self.sureObj.transform)
    Utils.ChangeLayersRecursively(self.sureEffect.transform, "UI")
    self.sureEffect.transform.localScale = Vector3(1.2, 1, 1)
    self.sureEffect.transform.localPosition = Vector3(-123, 51, -400)
    self.sureEffect:SetActive(false)

    self.cancelEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
    self.cancelEffect.transform:SetParent(self.cancelObj.transform)
    Utils.ChangeLayersRecursively(self.cancelEffect.transform, "UI")
    self.cancelEffect.transform.localScale = Vector3(1.2, 1, 1)
    self.cancelEffect.transform.localPosition = Vector3(5, 51, -400)
    self.cancelEffect:SetActive(false)
end

function ConnectionConfirmPanel:Reset()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
        self.timeId = 0
    end
    if self.timeIdForContent ~= 0 then
        LuaTimer.Delete(self.timeIdForContent)
        self.timeIdForContent = 0
    end
    -- self.sureLabel.text = "确定"
    -- self.cancelLabel.text = "取消"
    self.sureTxt:SetData(TI18N("确定"))
    self.cancelTxt:SetData(TI18N("取消"))
    self.gameObject:SetActive(false)
    self.toggleObj:SetActive(false)
    self.toggle.isOn = false

    self.confirmData = nil
    self.sureCall = nil
    self.cancelCall = nil
    self.toggleCall = nil
    self:SetPanelButtonEnabled(true)

    if not BaseUtils.is_null(self.sureEffect) then
        self.sureEffect:SetActive(false)
    end

    if not BaseUtils.is_null(self.cancelEffect) then
        self.cancelEffect:SetActive(false)
    end
end

function ConnectionConfirmPanel:SetData(confirmData)
    self:Reset()

    self.confirmData = confirmData

    -- self:Layout(self.confirmData.type)

    if self.confirmData.showClose == -1 then
        self.CloseButton.gameObject:SetActive(false)
    else
        self.CloseButton.gameObject:SetActive(true)
    end

    if self.confirmData.contentSecond == -1 then
        self.contentTxt:SetData(QuestEumn.FilterContent(self.confirmData.content))
    else
        self.contentCount = self.confirmData.contentSecond
        self.contentTxt:SetData(string.format(QuestEumn.FilterContent(self.confirmData.content),BaseUtils.formate_time_gap(self.contentCount, ":", 0, BaseUtils.time_formate.HOUR)))
        self.timeIdForContent = LuaTimer.Add(0, 1000, function() self:OnTickForContent() end)
    end

    self.sureTxt:SetData(self.confirmData.sureLabel)
    self.cancelTxt:SetData(self.confirmData.cancelLabel)
    self.sureLabelRect.anchoredPosition = Vector2((130 - self.sureTxt.selfWidth) / 2, -(48 - self.sureTxt.selfHeight) / 2)
    self.cancelLabelRect.anchoredPosition = Vector2((130 - self.cancelTxt.selfWidth) / 2, -(48 - self.cancelTxt.selfHeight) / 2)

    self.gameObject:SetActive(true)
    -- 需要倒计时
    if self.confirmData.sureSecond ~= -1 or self.confirmData.cancelSecond ~= -1 then
        self.sureCount = self.confirmData.sureSecond
        self.cancelCount = self.confirmData.cancelSecond
        self:UpdateLabel()
        self.timeId = LuaTimer.Add(0, 1000, function() self:OnTick() end)
    end

    self.sureCall = self.confirmData.sureCallback
    self.cancelCall = self.confirmData.cancelCallback

    if self.confirmData.blueSure then
        self.sureImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.sureLabel.text = string.format("<color='%s'>%s</color>", ColorHelper.ButtonLabelColor.Blue, self.sureLabel.text)
    else
        self.sureImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.sureLabel.text = string.format("<color='%s'>%s</color>", ColorHelper.ButtonLabelColor.Orange, self.sureLabel.text)
    end

    if self.confirmData.greenCancel then
        self.cancelImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.cancelLabel.text = string.format("<color='%s'>%s</color>", ColorHelper.ButtonLabelColor.Orange, self.cancelLabel.text)
    else
        self.cancelImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.cancelLabel.text = string.format("<color='%s'>%s</color>", ColorHelper.ButtonLabelColor.Blue, self.cancelLabel.text)
    end

    if not BaseUtils.is_null(self.sureEffect) then
        self.sureEffect:SetActive(self.confirmData.showSureEffect)
    end

    if not BaseUtils.is_null(self.cancelEffect) then
        self.cancelEffect:SetActive(self.confirmData.showCancelEffect)
    end

    if self.confirmData.showToggle then
        self.toggleObj:SetActive(true)
        self.toggleLabel.text = self.confirmData.toggleLabel
        self.toggleCall = self.confirmData.toggleCallback
        self.toggle.isOn = false
    end

    self:Layout(self.confirmData.type)
end

-- 根据类型来处理窗口样式，按钮个数，窗口大小
function ConnectionConfirmPanel:Layout(type)
    if type == ConfirmData.Style.Sure then
        self.sureObj:SetActive(true)
        self.cancelObj:SetActive(false)

        if self.confirmData.showToggle then
            self.sureTrans.anchoredPosition = Vector2(-130, 53)
        else
            self.sureTrans.anchoredPosition = Vector2(-130, 28)
        end
    else
        self.sureObj:SetActive(true)
        self.cancelObj:SetActive(true)

        if self.confirmData.showToggle then
            self.sureTrans.anchoredPosition = Vector2(-35, 53)
            self.cancelTrans.anchoredPosition = Vector2(35, 53)
        else
            self.sureTrans.anchoredPosition = Vector2(-35, 28)
            self.cancelTrans.anchoredPosition = Vector2(35, 28)
        end
    end


    local w = 386
    local h = 206
    if self.contentTxt.selfHeight > 100 then
        if self.confirmData.showToggle then
            h = self.contentTxt.selfHeight - 100 + 30 + 236
        else
            h = self.contentTxt.selfHeight - 100 + 30 + 206
        end
    else
        if self.confirmData.showToggle then
            h = 236
        else
            h = 206
        end
    end

    self.mainRect.sizeDelta = Vector2(w, h)
    self.mainRect.anchoredPosition = Vector2.zero
end

function ConnectionConfirmPanel:OnTickForContent()
    if self.contentCount == 0 then
        LuaTimer.Delete(self.timeIdForContent)
        self.timeIdForContent = 0
        self.contentCount = -1
        return
    end

    if self.contentCount ~= -1 then
        self.contentCount = self.contentCount - 1
    end
    self.contentTxt:SetData(string.format(QuestEumn.FilterContent(self.confirmData.content),BaseUtils.formate_time_gap(self.contentCount, ":", 0, BaseUtils.time_formate.HOUR)))
end

function ConnectionConfirmPanel:OnTick()
    if self.sureCount == 0 then
        self:TimeOut()
        self:ClickSure()
        return
    elseif self.cancelCount == 0 then
        self:TimeOut()
        if self.confirmData.cancelNoCancel then
            self:Clear()
        else
            self:ClickCancel()
        end
        return
    end

    if self.sureCount ~= -1 then
        self.sureCount = self.sureCount - 1
    elseif self.cancelCount ~= -1 then
        self.cancelCount = self.cancelCount - 1
    end
    self:UpdateLabel()
end

function ConnectionConfirmPanel:UpdateLabel()
    -- 不存在两个按钮都倒计时，如果有我就报警妈蛋
    if self.confirmData.sureSecond ~= -1 then
        self.sureTxt:SetData(string.format("%s(%s)", self.confirmData.sureLabel, self.sureCount))
    elseif self.confirmData.cancelSecond ~= -1 then
        self.cancelTxt:SetData(string.format("%s(%s)", self.confirmData.cancelLabel, self.cancelCount))
    end

    self.sureLabelRect.anchoredPosition = Vector2((130 - self.sureTxt.selfWidth) / 2, -(48 - self.sureTxt.selfHeight) / 2)
    self.cancelLabelRect.anchoredPosition = Vector2((130 - self.cancelTxt.selfWidth) / 2, -(48 - self.cancelTxt.selfHeight) / 2)
end

function ConnectionConfirmPanel:TimeOut()
    LuaTimer.Delete(self.timeId)
    self.timeId = 0
    self.sureCount = -1
    self.cancelCount = -1
end

function ConnectionConfirmPanel:ClickSure()
    if self.sureCall ~= nil then
        if self.confirmData.showToggle then
            self.sureCall(self.toggle.isOn)
        else
            self.sureCall()
        end
    end
    self:Clear()
end

function ConnectionConfirmPanel:ClickCancel()
    if self.cancelCall ~= nil then
        self.cancelCall()
    end
    RoleManager.Instance.jump_over_call = nil
    RoleManager.Instance.jump_over_find = nil
    self:Clear()
end

function ConnectionConfirmPanel:ClickToggle(bool)
    if self.toggleCall ~= nil then
        self.toggleCall(bool)
    end
end

function ConnectionConfirmPanel:Clear()
    self:Hiden()
    self:Reset()
    NoticeManager.Instance.isMatchNotice = false
end

function ConnectionConfirmPanel:SetPanelButtonEnabled(bool)
    if self.gameObject ~= nil then
        self.gameObject.transform:Find("Panel"):GetComponent(Button).enabled = bool
    end
end