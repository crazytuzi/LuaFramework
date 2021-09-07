-- @author 黄耀聪
-- @date 2016年9月12日

MidAutumnBless = MidAutumnBless or BaseClass(BasePanel)

function MidAutumnBless:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.mgr = MidAutumnFestivalManager.Instance
    self.name = "MidAutumnBless"

    self.countString = TI18N("孔明灯火:<color='#00ff00'>%s</color>")
    self.descString = TI18N("1.达到特定进度后，可获得<color='#ffff00'>放飞奖励</color>\n2.贡献最大的公会，所有成员将额外获得一份奖励")

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.effectList = {}

    self.itemList = {}
    self.progressRewardList = {}
    local valueList = {0, 0.363, 0.645, 0.932, 1}
    self.valueList = valueList
    self.maxValue = DataCampMidAutumn.data_pivot[#valueList - 2].type_name

    self.valList0915 = {}
    local scoreList = {0}
    for i,v in ipairs(DataCampMidAutumn.data_pivot) do
        table.insert(scoreList, v.type_name)
        table.insert(self.valList0915, v.type_name)
    end
    table.sort(self.valList0915, function(a,b) return a < b end)
    table.insert(scoreList, self.maxValue)
    self.kList = {nil, nil, nil, nil}
    self.bList = {nil, nil, nil, nil}
    for i=1,#valueList - 1 do
        self.bList[i] = (valueList[i + 1] - valueList[i]) / (scoreList[i + 1] - scoreList[i])
        self.kList[i] = (valueList[i + 1] - self.bList[i]) / scoreList[i + 1]
    end

    self.infoListener = function() self:OnInfo() end

    self:InitPanel()
end

function MidAutumnBless:__delete()
    self.OnHideEvent:Fire()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.multiItemPanel ~= nil then
        self.multiItemPanel:DeleteMe()
        self.multiItemPanel = nil
    end
    if self.progressRewardList ~= nil then
        for _,v in pairs(self.progressRewardList) do
            if v ~= nil and v.slot ~= nil then
                v.slot:DeleteMe()
            end
        end
        self.progressRewardList = nil
    end
    if self.effectList ~= nil then
        for _,v in pairs(self.effectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.effectList = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil and v.slot ~= nil then
                v.slot:DeleteMe()
            end
        end
        self.itemList = nil
    end
    self.assetWrapper = nil
end

function MidAutumnBless:InitPanel()
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t

    local container = t:Find("Reward/Scroll/Container")
    for i=1,4 do
        self.itemList[i] = {transform = container:GetChild(i - 1)}
    end
    self.moreItemBtn = container:Find("More"):GetComponent(Button)

    self.slider = t:Find("ProgressI18N/Slider"):GetComponent(Slider)
    for i=3,5 do
        local tab = {slot = ItemSlot.New(), pivot = nil, btn = nil}
        local tr = self.slider.transform:GetChild(i - 1)
        NumberpadPanel.AddUIChild(tr.gameObject, tab.slot.gameObject)
        tab.pivot = tr:Find("Pivot"):GetComponent(Text)
        tab.btn = tr:GetComponent(Button)
        local h = i - 2
        tab.btn.onClick:AddListener(function() self:OnReward(h) end)
        self.progressRewardList[i - 2] = tab
    end

    self.modelContainer = t:Find("Model")
    self.modelContainer:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.topGuildText = t:Find("Top/Bg/Text"):GetComponent(Text)
    self.topGuild = t:Find("Top/Bg")
    self.button = t:Find("Button"):GetComponent(Button)
    self.red = t:Find("Button/Red").gameObject
    self.red:SetActive(false)

    for i,v in ipairs(self.progressRewardList) do
        local data = ItemData.New()
        data:SetBase(DataItem.data_get[DataCampMidAutumn.data_pivot[i].wish_reward[1][1]])
        v.slot:SetAll(data, {inbag = false, nobutton = true})
        v.slot:SetNum(DataCampMidAutumn.data_pivot[i].wish_reward[1][3])
        v.pivot.text = tostring(DataCampMidAutumn.data_pivot[i].type_name)
        local index = i
        v.slot.clickSelfFunc = function() self:OnReward(index) end
    end

    local datalist = DataCampaign.data_list[318].rewardgift
    for i=1,4 do
        if datalist[i] ~= nil then
            self.itemList[i].transform.gameObject:SetActive(true)
            self.itemList[i].slot = ItemSlot.New()
            NumberpadPanel.AddUIChild(self.itemList[i].transform.gameObject, self.itemList[i].slot.gameObject)
            local data = ItemData.New()
            data:SetBase(DataItem.data_get[datalist[i][1]])
            self.itemList[i].slot:SetAll(data, {inbag = false, nobutton = true})
            self.itemList[i].slot:SetNum(datalist[i][2])
        else
            self.itemList[i].transform.gameObject:SetActive(false)
        end
    end
    self.moreItemBtn.gameObject:SetActive(#datalist > 4)

    local callback = function(composite)
        self:SetRawImage(composite)
    end

    local BaseData = DataUnit.data_unit[74136]
    local setting = {
        name = BaseData.name
        ,orthographicSize = 0.6
        ,width = 200
        ,height = 341
        ,offsetY = -0.3
        ,noDrag = true
        ,noMaterial = true
    }
    local modelData = {type = PreViewType.Npc, skinId = BaseData.skin, modelId = BaseData.res, animationId = BaseData.animation_id, scale = 0.8}
    self.previewComp = PreviewComposite.New(callback, setting, modelData, "ModelPreview")

    self.button.onClick:AddListener(function() self:OnClick() end)
    self.moreItemBtn.onClick:AddListener(function() self:ShowMore() end)

    self:CheckRed()
end

function MidAutumnBless:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.modelContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.modelContainer.gameObject:SetActive(true)
    rawImage.transform.anchoredPosition = Vector2.zero
end

function MidAutumnBless:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MidAutumnBless:OnOpen()
    self:RemoveListeners()
    self.mgr.infoEvent:AddListener(self.infoListener)

    self:OnInfo()

    self:CheckRed()
end

function MidAutumnBless:OnHide()
    self:RemoveListeners()
end

function MidAutumnBless:RemoveListeners()
    self.mgr.infoEvent:RemoveListener(self.infoListener)
end

function MidAutumnBless:OnInfo()
    local model = self.model
    local part = 1
    local wish_val = model.enjoymoon_wish_val
    -- for i,v in ipairs(DataCampMidAutumn.data_pivot) do
    --     if wish_val > v.type_name then
    --         part = i + 1
    --         break
    --     end
    -- end
    -- self.slider.value = self.kList[part] * wish_val + self.bList[part]

    -- --------------------------------
    -- 中秋快乐
    -- --------------------------------
    if wish_val <= 0 then
        self.slider.value = 0
    elseif wish_val >= self.maxValue then
        self.slider.value = 1
    else
        part = 1
        local newVal = 0
        local lastVal = 0
        local nextVal = 0
        for i,val in ipairs(self.valList0915) do
            if wish_val >= val then
                lastVal = val
                part = part + 1
            else
                if nextVal == 0 then
                    nextVal = val
                end
            end
        end

        newVal = wish_val - lastVal
        local starVal = self.valueList[part]
        local addVal = self.bList[part] * newVal
        self.slider.value = starVal + addVal
    end


    local rankInfo = model.enjoymoon_rank_info or {}
    rankInfo = rankInfo[1] or {}
    self.topGuildText.text = rankInfo.guild_name or TI18N("未上榜")
    self.topGuild.sizeDelta = Vector2(self.topGuildText.preferredWidth + 20,35)

    model.enjoymoon_reward_list = model.enjoymoon_reward_list or {}
    for i,v in ipairs(self.progressRewardList) do
        v.slot:SetGrey(model.enjoymoon_reward_list[i] == true)
        if model.enjoymoon_reward_list[i] ~= true and model.enjoymoon_wish_val >= DataCampMidAutumn.data_pivot[i].type_name then
        -- if model.enjoymoon_reward_list[i] ~= true then
            if self.effectList[i] == nil then
                self.effectList[i] = BibleRewardPanel.ShowEffect(20110, v.slot.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
            end
        else
            if self.effectList[i] ~= nil then
                self.effectList[i]:DeleteMe()
                self.effectList[i] = nil
            end
        end
    end
end

function MidAutumnBless:OnClick()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_danmaku)
end

function MidAutumnBless:ShowMore()
    local datalist = DataCampaign.data_list[318].rewardgift
    local info = {column = 5, list = {}, extra = {horDirection = 0, verDirection = 0, context = ""}}

    local tab = {title = TI18N("祈福可能获得以下奖励:"), items = {}}
    for _,v in ipairs(datalist) do
        table.insert(tab.items, {base_id = v[1], num = v[2]})
    end
    info.list[1] = tab

    if self.multiItemPanel == nil then
        self.multiItemPanel = MultiItemPanel.New(self.transform.parent.parent.gameObject)
    end
    self.multiItemPanel:Show(info)
end

function MidAutumnBless:OnReward(i)
    local model = self.model
    model.enjoymoon_reward_index = i
    model.enjoymoon_reward_list = model.enjoymoon_reward_list or {}
    local a = model.enjoymoon_reward_list[i] or false
    if model.enjoymoon_wish_val >= DataCampMidAutumn.data_pivot[i].type_name then
        if a == true then
            NoticeManager.Instance:FloatTipsByString(TI18N("奖励已领取"))
        else
            MidAutumnFestivalManager.Instance:send14067(i)
        end
    end
end

function MidAutumnBless:CheckRed()
    local num = BackpackManager.Instance:GetItemCount(23596) + BackpackManager.Instance:GetItemCount(23597)
    if num > 0 then
        self.red:SetActive(true)
    else
        self.red:SetActive(false)
    end
end