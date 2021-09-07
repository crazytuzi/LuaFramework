ChristmasSnowmanWindow = ChristmasSnowmanWindow or BaseClass(BaseWindow)

function ChristmasSnowmanWindow:__init(model)
    self.model = model
    self.name = "ChristmasSnowmanWindow"
    self.windowId = WindowConfig.WinID.christmas_snowman

    self.resList = {
        {file = AssetConfig.christmas_snowman_window, type = AssetType.Main}
        , {file = AssetConfig.christmas_bg, type = AssetType.Main}
        , {file = AssetConfig.christmas_textures, type = AssetType.Dep}
        , {file = AssetConfig.textures_campaign, type = AssetType.Dep}
        , {file = AssetConfig.anniversary_textures, type = AssetType.Dep}
    }

    self.valueList = {0.3, 0.6, 1}
    self.valueList[0] = 0
    self.kList = {}
    self.bList = {}
    self.modelIdList = {}
    self.tweenList = {}

    self.txtYs = {
        [0] = 360,
        [1] = 320,
        [2] = 280,
        [3] = 240,
        [4] = 200,
        [5] = 160,
        [6] = 120,
        [7] = 80,
        [8] = 40,
        [9] = 0
    }

    self.npcId = 76678
    self.sliderTextList = {
        TI18N("完成度达到<color='#ffff00'>30%</color>，圣诞老人将于<color='#ffff00'>12月25日21:00</color>发放礼物{face_1,18}"),
        TI18N("完成度达到<color='#ffff00'>60%</color>，圣诞老人将于<color='#ffff00'>12月26日21:00</color>发放礼物{face_1,29}"),
        TI18N("完成度达到<color='#ffff00'>100%</color>，圣诞老人将于<color='#ffff00'>12月27日21:00</color>发放礼物{face_1,38}"),
    }

    for i,v in ipairs(self.valueList) do
        self.kList[i] = (v - self.valueList[i - 1]) / (DataCampaignWorldGift.data_progress[i].max_val - DataCampaignWorldGift.data_progress[i].min_val)
        self.bList[i] = v - self.kList[i] * DataCampaignWorldGift.data_progress[i].max_val
    end

    self.backpackListener = function() self:CheckRed() end
    self.setSliderListener = function() self:SetSliderValue((DoubleElevenManager.Instance.model.snowmanData or {}).val or 0) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ChristmasSnowmanWindow:__delete()
    self.OnHideEvent:Fire()
    if self.buyPanel ~= nil then
        self.buyPanel:DeleteMe()
        self.buyPanel = nil
    end
    if self.possibleReward ~= nil then
        self.possibleReward:DeleteMe()
        self.buyPanel = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.tweenList ~= nil then
        for _,v in pairs(self.tweenList) do
            if v ~= nil then
                Tween.Instance:Cancel(v)
            end
        end
        self.tweenList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ChristmasSnowmanWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.christmas_snowman_window))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local main = t:Find("Main")
    -- main:Find("Bg"):GetComponent(Image).enabled = false
    UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.christmas_bg)))

    self.modelCotnainer = main:Find("Content/Model")
    self.slider = main:Find("Content/Slider"):GetComponent(Slider)
    self.button = main:Find("Content/Button"):GetComponent(Button)
    self.notice = main:Find("Content/Notice"):GetComponent(Button)
    self.noticeBtn = main:Find("Content/Notice/Image"):GetComponent(Button)
    self.leftBtn = main:Find("Content/Left"):GetComponent(Button)
    self.rightBtn = main:Find("Content/Right"):GetComponent(Button)
    self.sliderText = main:Find("Content/Image1/Text"):GetComponent(Text)
    self.btnRed = main:Find("Content/Button/Red").gameObject

    for i=1,3 do
        local j = i
        main:Find("Content/Slider/Image" .. j):GetComponent(Button).onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(self.sliderTextList[j]) end)
    end

    local NumberCon = main:Find("Content/MemeberCon"):Find("NumberCon")
    self.numTextCon = {
        NumberCon:Find("Img0"):Find("TxtCon").gameObject,
        NumberCon:Find("Img1"):Find("TxtCon").gameObject,
        NumberCon:Find("Img2"):Find("TxtCon").gameObject,
        NumberCon:Find("Img3"):Find("TxtCon").gameObject,
        NumberCon:Find("Img4"):Find("TxtCon").gameObject,
    }
    for _,v in ipairs(self.numTextCon) do
        for i=0,9 do
            v.transform:Find("Txt" .. i).anchoredPosition = Vector2(16, -380 + i * 40)
        end
    end

    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    if self.openArgs ~= nil then 
        self.campId = self.openArgs[1]
    end

    self.buyPanel = ChristmasSnowmanBuyPanel.New(self.model, t:Find("HideArea").gameObject, self.campId)
    self.button.onClick:AddListener(function() self:OnClick() end)
    self.leftBtn.onClick:AddListener(function() self:ShowGiftPriview(DataCampaign.data_list[self.campId].rewardgift[1][1]) end)
    self.rightBtn.onClick:AddListener(function() self:ShowGiftPriview(DataCampaign.data_list[self.campId].rewardgift[2][1]) end)
    self.notice.onClick:AddListener(function() self:OnNotice() end)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
end

function ChristmasSnowmanWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ChristmasSnowmanWindow:OnOpen()
    self.buyPanel:Hiden()

    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.backpackListener)
    DoubleElevenManager.Instance.snowmanEvent:AddListener(self.setSliderListener)

    local temp_model = {}
    for _,v in ipairs(DataCampaign.data_list[self.campId].reward) do
        table.insert( temp_model, v[1])
    end
    self.modelIdList = temp_model

    DoubleElevenManager.Instance:Send17819()
    self:SetSliderValue((DoubleElevenManager.Instance.model.snowmanData or {}).val or 0)
    self:CheckRed()

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(10*1000, 10*1000, function() self:OnTick() end)
    end
    if self.updownTimerId == nil then
        self.updownTimerId = LuaTimer.Add(0, 30, function() self:UpDown() end)
    end
end

function ChristmasSnowmanWindow:RemoveListeners()
    DoubleElevenManager.Instance.snowmanEvent:RemoveListener(self.setSliderListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.backpackListener)
end

function ChristmasSnowmanWindow:OnHide()
    self:RemoveListeners()
    self.buyPanel:Hiden()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.updownTimerId ~= nil then
        LuaTimer.Delete(self.updownTimerId)
        self.updownTimerId = nil
    end
end

function ChristmasSnowmanWindow:SetSliderValue(value)
    -- local value = (DoubleElevenManager.Instance.model.snowmanData or {}).val or 0
    value = value or 0

    -- print(value)

    self:SetTweenNum(value)

    local index = 1
    for i,v in ipairs(DataCampaignWorldGift.data_progress) do
        if value >= v.min_val and value < v.max_val then
            index = i
            break
        end
    end

    self:ShowModel(index)

    if index == #DataCampaignWorldGift.data_progress then
        value = 1
    else
        value = self.kList[index] * value + self.bList[index]
    end
    if value > 1 then
        value = 1
    end
    self.slider.value = value
    if value < 1 then
        self.sliderText.text = string.format("%s%%", tostring(math.floor(value * 100)))
    else
        self.sliderText.text = "<color='#00ff00'>100%</color>"
    end
end

function ChristmasSnowmanWindow:ShowGiftPriview(base_id)
    print(base_id)
    local reward = {}
    local temp_reward = CampaignManager.ItemFilter((DataCampaignWorldGift.data_reward[base_id] or {}).reward)
    for _,v in ipairs(temp_reward or {}) do
        local temp = {}
        temp.item_id = v[1]
        temp.num = v[2]
        temp.is_effet = v[3]
        table.insert(reward, temp)
    end

    local callBack = function(myself) myself.gameObject.transform.localPosition = Vector3(myself.gameObject.transform.localPosition.x,myself.gameObject.transform.localPosition.y,200) end

    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self,callBack)
    end

    if base_id == 70506 then
        self.possibleReward:Show({reward,5,{110,110,110,90},"使用可获得以下道具中的一个"})
    else
        self.possibleReward:Show({reward,5,{125,120,100,100},"使用可获得以下道具中的一个"})
    end
end

function ChristmasSnowmanWindow:OnNotice()
    local extra = {}
    local npcData = DataUnit.data_unit[self.npcId]
    MainUIManager.Instance:OpenDialog({baseid = npcData.id, name = npcData.name}, {base = npcData}, true, true)
end

function ChristmasSnowmanWindow:OnClick()
    -- self.result = self.result or 0
    -- self.result = self.result + math.random(0, 100)
    -- self:SetSliderValue(self.result)

    self.buyPanel:Show()
end

function ChristmasSnowmanWindow:TweenJoinMemberNum(i, num)
    local tweenSpeed = 2-num*0.1
    local newY = self.txtYs[num]
    if self.tweenList[i] ~= nil then
        Tween.Instance:Cancel(self.tweenList[i])
    end
    self.tweenList[i] = Tween.Instance:MoveLocalY(self.numTextCon[i], newY, tweenSpeed, function() self.tweenList[i] = nil end, LeanTweenType.linear).id
end

function ChristmasSnowmanWindow:SetTweenNum(value)
    local count = #self.numTextCon
    for i=count,1,-1 do
        if self.numTextCon[i] ~= nil then
            self:TweenJoinMemberNum(i, value % 10)
            value = math.floor(value / 10)
        end
    end
end

function ChristmasSnowmanWindow:ShowModel(i)
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local baseData = DataUnit.data_unit[self.modelIdList[i]]
    local setting = {
        name = "Npc"
        ,orthographicSize = 0.55
        ,width = 341
        ,height = 300
        ,offsetY = -0.4
        , noDrag = true
    }
    local modelData = {type = PreViewType.Npc, skinId = baseData.skin, modelId = baseData.res, animationId = baseData.animation_id, scale = 1}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData, "ModelPreview")
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function ChristmasSnowmanWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.modelCotnainer.transform)
    rawImage.transform.localPosition = Vector3(1,1,1)
    rawImage.transform.localScale = Vector3(1,1,1)
    composite.tpose.transform.localRotation = Quaternion.Euler(346,0,0)
    self.modelCotnainer.gameObject:SetActive(true)
end

function ChristmasSnowmanWindow:OnTick()
    DoubleElevenManager.Instance:Send17819()
end

function ChristmasSnowmanWindow:UpDown()
    self.counter = self.counter or 0
    self.counter = self.counter + 1

    local T1 = 1
    local T2 = 0.8

    -- local x1 =
    self.leftBtn.transform.anchoredPosition = Vector2(-174, -18 + 10 * math.sin(self.counter * math.pi / 180 * math.pi / T1))
    self.rightBtn.transform.anchoredPosition = Vector2(174, -10 + 10 * math.sin(self.counter * math.pi / 180 * math.pi / T2))
end

function ChristmasSnowmanWindow:CheckRed()
    local bo = false
    for i,v in ipairs(self.model:GetSnowManData(self.campId)) do
        if BackpackManager.Instance:GetItemCount(v) > 0 then
            bo = true
            break
        end
    end
    self.btnRed:SetActive(bo == true)
end
