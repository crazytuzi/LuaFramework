NewExamDescWindow  =  NewExamDescWindow or BaseClass(BasePanel)

function NewExamDescWindow:__init(model)
    self.name  =  "NewExamDescWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.newexamdescwindow, type  =  AssetType.Main}
        -- , {file = AssetConfig.exam_res, type = AssetType.Dep}
        , {file = AssetConfig.dailyicon, type = AssetType.Dep}
    }

    self.timerId = nil
    self.itemsoltList = {}

    self._UpdateTime = function() self:UpdateTime() end

    ------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function NewExamDescWindow:OnHide()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function NewExamDescWindow:OnShow()
    self:Update()
end

function NewExamDescWindow:__delete()
    self:OnHide()

    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    for k,v in pairs(self.itemsoltList) do
        v:DeleteMe()
        v = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end


function NewExamDescWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.newexamdescwindow))
    self.gameObject.name = "NewExamDescWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform.localPosition = Vector3(0, 0, -400)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    self.closeButton = self.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    self.closeButton.onClick:AddListener(function() self:OnClose() end)

    self.okButton = self.transform:Find("MainCon/OkButton"):GetComponent(Button)
    self.okButton.onClick:AddListener(function() self:OnClickOkButton() end)

    self.icon = self.transform:Find("MainCon/Icon/Image").gameObject
    self.nameText = self.transform:Find("MainCon/NameText"):GetComponent(Text)
    self.descText = self.transform:Find("MainCon/DescText"):GetComponent(Text)
    self.timeText = self.transform:Find("MainCon/TimeText"):GetComponent(Text)

    self.nameTextExt = MsgItemExt.New(self.transform:FindChild("MainCon/NameText"):GetComponent(Text), 200, 18, 30)

    self:OnShow()
end

function NewExamDescWindow:OnClose()
    -- WindowManager.Instance:CloseWindow(self)
    self.model:CloseDescPanel()
end

function NewExamDescWindow:OnClickOkButton()
    if self.openArgs.callback ~= nil then
        self.openArgs.callback()
    end

    self:OnClose()
end

function NewExamDescWindow:Update()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 200, self._UpdateTime)

    local agendaData = DataAgenda.data_list[self.openArgs.agenda_id]
    self.icon:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, agendaData.icon)
    -- self.nameText.text = agendaData.name
    self.nameTextExt:SetData(self.openArgs.title_text)
    self.descText.text = self.openArgs.desc_text

    for i=1, #agendaData.reward do
        if i <= 3 then
            local reward = agendaData.reward[i]
            local itemSolt = ItemSlot.New()
            UIUtils.AddUIChild(self.transform:Find("MainCon/Reward"..i).gameObject, itemSolt.gameObject)
            local itembase = BackpackManager.Instance:GetItemBase(reward.key)
            local itemData = ItemData.New()
            itemData:SetBase(itembase)
            itemData.quantity = reward.val
            itemSolt:SetAll(itemData)

            self.itemsoltList[i] = itemSolt
        end
    end

    if self.effect == nil then
        local fun = function(effectView)
            local effectObject = effectView.gameObject

            effectObject.transform:SetParent(self.okButton.transform)
            effectObject.transform.localScale = Vector3(1.9, 0.8, 1)
            effectObject.transform.localPosition = Vector3(-60, -18, -400)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            effectObject:SetActive(true)
        end
        self.effect = BaseEffectView.New({effectId = 20053, time = nil, callback = fun})
    else
        self.effect:SetActive(true)
    end

    self:UpdatePos()
end

function NewExamDescWindow:UpdatePos()
    local preferredHeight = self.descText.preferredHeight
    local offsetHeight = preferredHeight - 98.5

    local pos = self.transform:Find("MainCon/Givetxt").localPosition
    self.transform:Find("MainCon/Givetxt").localPosition = Vector2(pos.x, pos.y - offsetHeight)

    for i=1, 3 do
        pos = self.transform:Find("MainCon/Reward"..i).localPosition
        self.transform:Find("MainCon/Reward"..i).localPosition = Vector2(pos.x, pos.y - offsetHeight)
    end

    pos = self.transform:Find("MainCon/Timetxt1").localPosition
    self.transform:Find("MainCon/Timetxt1").localPosition = Vector2(pos.x, pos.y - offsetHeight)

    pos = self.timeText.transform.localPosition
    self.timeText.transform.localPosition = Vector2(pos.x, pos.y - offsetHeight)

    pos = self.okButton.transform.localPosition
    self.okButton.transform.localPosition = Vector2(pos.x, pos.y - offsetHeight)

    local sizeDelta = self.transform:Find("MainCon"):GetComponent(RectTransform).sizeDelta
    self.transform:Find("MainCon"):GetComponent(RectTransform).sizeDelta = Vector2(sizeDelta.x, sizeDelta.y + offsetHeight)
end

function NewExamDescWindow:UpdateTime()
    local diff = self.openArgs.endtime - BaseUtils.BASE_TIME
    if diff > 0 then
        self.timeText.text = tostring(os.date("%M:%S", diff))
    else
        self:OnClose()
    end
end