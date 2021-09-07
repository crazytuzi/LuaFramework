-- @author 黄耀聪
-- @date 2017年2月9日

OpenServerSeven = OpenServerSeven or BaseClass(BasePanel)

function OpenServerSeven:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "OpenServerSeven"

    self.resList = {
        {file = AssetConfig.openserverseven_bg, type = AssetType.Main}
        , {file = AssetConfig.openserverseven, type = AssetType.Main}
        , {file = AssetConfig.open_server_textures, type = AssetType.Dep}
        , {file = AssetConfig.effectbg, type = AssetType.Dep}
    }

    self.iconList = {22531, 22527}

    self.timeString = TI18N("%s月%s日")
    self.updateLister = function() self:ReloadList() end

    self.id1, self.id2 = OpenServerManager.Instance:CheckSeven()

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenServerSeven:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    self:AssetClearAll()
end

function OpenServerSeven:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.openserverseven))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.timeText = t:Find("DescArea/Time"):GetComponent(Text)

    UIUtils.AddBigbg(t:Find("DescArea/BigBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.openserverseven_bg)))

    -- local basedata = DataCampaign.data_list[self.campaignGroup.sub[1].id]
    -- local timeTab = BaseUtils.unserialize(basedata.timestr) or {}

    local ry = tonumber(os.date("%Y", RoleManager.Instance.RoleData.time_reg))
    local rm = tonumber(os.date("%m", RoleManager.Instance.RoleData.time_reg))
    local rd = tonumber(os.date("%d", RoleManager.Instance.RoleData.time_reg))

    local openTime = os.time{year = ry, month = rm, day = rd, hour = 0, min = 0, sec = 0}
    local closeTime = math.min(RoleManager.Instance.RoleData.time_reg + 6*24*3600 +86399, CampaignManager.Instance.open_srv_time + 14*24*3600 +86399)
    local month = os.date("%m", openTime)
    local day = os.date("%d", openTime)
    local endmonth = os.date("%m", closeTime)
    local endday = os.date("%d", closeTime)
    self.timeText.text = string.format(TI18N("活动时间:<color='#ffff00'>%s-%s</color>"),
            string.format(self.timeString, tostring(month), tostring(day)),
            string.format(self.timeString, tostring(endmonth), tostring(endday))
        )

    self.itemList = {
        OpenServerSevenItem.New(self.model, t:Find("Feet").gameObject),
        OpenServerSevenItem.New(self.model, t:Find("Unfeet").gameObject)
    }

    for i=1,2 do
        self.itemList[i].bg:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.effectbg, "EffectBg")
    end
end

function OpenServerSeven:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerSeven:OnOpen()
    self:RemoveListeners()
    SevendayManager.Instance.onUpdateDiscount:AddListener(self.updateLister)

    self:ReloadList()
end

function OpenServerSeven:OnHide()
    self:RemoveListeners()
end

function OpenServerSeven:RemoveListeners()
    SevendayManager.Instance.onUpdateDiscount:RemoveListener(self.updateLister)
end

function OpenServerSeven:ReloadList()
    for i=1,2 do
        if self.itemList[i] ~= nil then
            print(self.iconList[i])
            self.itemList[i].icon = self.iconList[i]
            self.itemList[i].isRotate = true
            self.itemList[i]:SetData(self["id"..i])
        end
    end
end

OpenServerSevenItem = OpenServerSevenItem or BaseClass()

function OpenServerSevenItem:__init(model, gameObject)
    self.gameObject = gameObject
    self.model = model
    local t = gameObject.transform
    self.transform = t
    self.slot = ItemSlot.New()
    NumberpadPanel.AddUIChild(t:Find("Slot").gameObject, self.slot.gameObject)
    self.descText = t:Find("Desc"):GetComponent(Text)
    self.timesText = t:Find("Times"):GetComponent(Text)
    self.button = t:Find("Button"):GetComponent(Button)
    self.buttonImage = self.button.gameObject:GetComponent(Image)
    self.buttonText = t:Find("Button/Text"):GetComponent(Text)
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.bg = t:Find("Bg")

    self.descText.transform.sizeDelta = Vector2(150, 76)

    self.priceObj = t:Find("Price").gameObject
    self.ownObj = t:Find("Own").gameObject

    self.priceText = t:Find("Price/TextBg/Text"):GetComponent(Text)
    self.ownText = t:Find("Own/TextBg/Text"):GetComponent(Text)
    self.priceImage = t:Find("Price/Image"):GetComponent(Image)
    self.ownImage = t:Find("Own/Image"):GetComponent(Image)
    self.priceDesc = t:Find("Price/I18N"):GetComponent(Text)
    self.ownDesc = t:Find("Own/I18N"):GetComponent(Text)
    self.priceObj = t:Find("Price").gameObject
    self.ownObj = t:Find("Own").gameObject

    if t:Find("Price/TextBg/Line") ~= nil then
        self.line = t:Find("Price/TextBg/Line").gameObject
    end

    self.slot.noTips = true
    self.slot.clickSelfFunc = function() self:ShowReward() end

    self.slot.gameObject:AddComponent(TransitionButton).scaleRate = 1.1

    self.isRotate = false

    self.timerId = LuaTimer.Add(0, 3000, function() self:Shake() end)
    self.rotateTimerId = LuaTimer.Add(0, 20, function() self:Rotate() end)
end

function OpenServerSevenItem:__delete()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
    if self.ownImage ~= nil then
        self.ownImage.sprite = nil
    end
    if self.priceImage ~= nil then
        self.priceImage.sprite = nil
    end
    if self.newPriceImage ~= nil then
        self.newPriceImage.sprite = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.buttonImage ~= nil then
        self.buttonImage.sprite = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.rotateTimerId ~= nil then
        LuaTimer.Delete(self.rotateTimerId)
        self.rotateTimerId = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
end

function OpenServerSevenItem:SetData(id)
    self.id = id
    self.gameObject:SetActive(true)
    local discountData = DataGoal.data_discount[id]
    local baseData = nil
    local num = 0
    local lev = RoleManager.Instance.RoleData.lev
    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex

    for _,v in ipairs(discountData.item_reward) do
        if #v == 2 then
            baseData = DataItem.data_get[v[1]]
            num = v[2]
            break
        elseif #v == 3 then
            baseData = DataItem.data_get[v[1]]
            num = v[3]
            break
        elseif #v == 4 then
            if (v[1] == 0 or v[1] == classes) and (v[2] == 2 or v[2] == sex) then
                baseData = DataItem.data_get[v[3]]
                num = v[4]
                break
            end
        elseif #v == 6 then
            if lev >= v[1] and lev <= v[2] and (v[3] == 0 or v[3] == classes) and (v[4] == 2 or v[4] == sex) then
                baseData = DataItem.data_get[v[5]]
                num = v[6]
                break
            end
        end
    end

    local itemdata = ItemData.New()
    if baseData ~= nil then
        itemdata:SetBase(baseData)
        self.slot:SetAll(itemdata, {inbag = false, nobutton = true, noselect = true})
    end
    if self.icon ~= nil then
        self.slot:SetImg(self.icon)
    end
    self.button.onClick:RemoveAllListeners()

    if self.effect ~= nil then
        self.effect:SetActive(false)
    end

    if discountData.price == 0 then
        self.nameText.text = string.format("<color='#c3692c'>%s</color>", discountData.name)
        self.ownObj:SetActive(false)

        self.descText.text = discountData.desc
        self.descText.gameObject:SetActive(true)
        self.priceObj:SetActive(false)
        self.timesText.gameObject:SetActive(false)

        -- self.slot:SetImg(29061)

        self.timesText.text = TI18N("今日限领 <color='#00ff00'>1</color>/%s次")
        self.button.onClick:RemoveAllListeners()
        if SevendayManager.Instance.model.discountTab[self.id] == nil then
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.buttonText.color = ColorHelper.DefaultButton3
            self.buttonText.text = TI18N("领取")
            self.button.onClick:AddListener(function() SevendayManager.Instance:send10239(self.id) end)
        else
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.buttonText.color = ColorHelper.DefaultButton4
            self.buttonText.text = TI18N("已领取")
            self.button.onClick:AddListener(function() self:ClickClose(true) end)
        end

        if SevendayManager.Instance.model.discountTab[self.id] == nil and SevendayManager.Instance:GetRechargeCount() >= discountData.day_charge then
            if self.effect == nil then
                self.effect = BibleRewardPanel.ShowEffect(20118, self.button.transform, Vector3(1, 0.75, 1), Vector3(-50, 20, -400))
            else
                self.effect:SetActive(true)
            end
        end
        if self.line ~= nil then
            self.line:SetActive(false)
        end
    else
        self.nameText.text = string.format("<color='#c3692c'>%s</color>",discountData.name)
        self.descText.gameObject:SetActive(false)
        self.priceObj:SetActive(true)

        self.button.onClick:RemoveAllListeners()
        if SevendayManager.Instance.model.discountTab[self.id] == nil then
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.buttonText.color = ColorHelper.DefaultButton3
            self.buttonText.text = TI18N("购买")
            self.button.onClick:AddListener(function()
                local discountData = DataGoal.data_discount[self.id]
                local confirmData = NoticeConfirmData.New()
                confirmData.sureCallback = function() SevendayManager.Instance:send10239(self.id) end
                confirmData.content = string.format(TI18N("是否花费{assets_1, %s, %s}购买%s？"), tostring(discountData.assets_type), tostring(discountData.price), ColorHelper.color_item_name(baseData.quality,discountData.name))
                NoticeManager.Instance:ConfirmTips(confirmData)
            end)
        else
            self.buttonText.text = TI18N("已购买")
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.buttonText.color = ColorHelper.DefaultButton4
            self.button.onClick:AddListener(function() self:ClickClose(false) end)
        end

        if SevendayManager.Instance.model.discountTab[self.id] == nil then
            self.slot.numTxt.text = "<color='#ff0000'>0</color>/1"
        else
            self.slot.numTxt.text = "<color='#00ff00'>1</color>/1"
        end
        -- self.slot:SetImg(29063)
        -- self.timesText.text = string.format(TI18N("今日限购 <color='#00ff00'>%s</color>/%s"), tostring(data.reward_can), tostring(data.reward_max))
        -- self.buttonText.text = TI18N("购买")

        self.priceImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[discountData.assets_type])
        self.ownImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[discountData.assets_type])

        -- 原价现价
        if self.line ~= nil then
            self.line:SetActive(true)
        end
        self.ownDesc.text = TI18N("现价")
        self.ownText.text = discountData.price
        self.priceDesc.text = TI18N("原价")
        self.priceText.text = discountData.show_price
    end
end

function OpenServerSevenItem:ClickClose(free)
    local str = nil
    if free == true then
        str = TI18N("领取")
    else
        str = TI18N("购买")
    end
    if self:CheckLast() then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("所有奖励已经%s完毕"), str))
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("今日奖励已经%s完毕"), str))
    end
end

function OpenServerSevenItem:ShowReward()
    if self.id == nil then return end

    local discountData = DataGoal.data_discount[self.id]
    local datalist = discountData.item_reward

    if #datalist > 0 then
        if self.model.mainWin ~= nil then
            if self.model.giftPreview == nil then
                self.model.giftPreview = GiftPreview.New(self.model.mainWin.gameObject)
            end

            if discountData.price > 0 then
                self.model.giftPreview:Show({reward = datalist, autoMain = true, text = TI18N("购买后直接获得以下所有道具"), width = 120, height = 120})
            else
                self.model.giftPreview:Show({reward = datalist, autoMain = true, text = TI18N("领取后直接获得以下所有道具"), width = 120, height = 120})
            end
        end
    end
end

function OpenServerSevenItem:Shake()
    if self.id == nil then
        return
    end
    local discountData = DataGoal.data_discount[self.id]
    if SevendayManager.Instance.model.discountTab[self.id] == nil
        and discountData.price == 0
        then
        self.button.transform.localScale = Vector3(1.2,1.1,1)
        if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
        end
        self.tweenId = Tween.Instance:Scale(self.button.gameObject, Vector3(1,1,1), 1.2, function() self.tweenId = nil end, LeanTweenType.easeOutElastic).id
    else
        self.button.transform.localScale = Vector3.one
    end
end

function OpenServerSevenItem:Rotate()
    if self.isRotate == true then
        self.rotateCount = (self.rotateCount or 0) + 1
        self.bg.rotation = Quaternion.Euler(0, 0, self.rotateCount * 3)
    end
end

-- 是否最后一天
function OpenServerSevenItem:CheckLast()
    local ry = tonumber(os.date("%Y", RoleManager.Instance.RoleData.time_reg))
    local rm = tonumber(os.date("%m", RoleManager.Instance.RoleData.time_reg))
    local rd = tonumber(os.date("%d", RoleManager.Instance.RoleData.time_reg))

    local openTime = os.time{year = ry, month = rm, day = rd, hour = 0, min = 0, sec = 0}
    local closeTime = math.min(RoleManager.Instance.RoleData.time_reg + 6*24*3600 +86399, CampaignManager.Instance.open_srv_time + 14*24*3600 +86399)
    return tonumber(os.date("%d", BaseUtils.BASE_TIME)) == tonumber(os.date("%d", closeTime)) and tonumber(os.date("%m", BaseUtils.BASE_TIME)) == tonumber(os.date("%m", closeTime))
end



