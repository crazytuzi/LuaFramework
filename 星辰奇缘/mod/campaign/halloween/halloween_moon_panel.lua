-- @author 黄耀聪
-- @date 2016年10月25日

HalloweenMoonPanel = HalloweenMoonPanel or BaseClass(BasePanel)

function HalloweenMoonPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "HalloweenMoonPanel"

    self.resList = {
        {file = AssetConfig.halloweenmoon, type = AssetType.Main}
        ,{ file = AssetConfig.newyeargoodstext1, type = AssetType.Main}
        ,{ file = AssetConfig.newyeargoodstext2, type = AssetType.Main}
        ,{ file = AssetConfig.halloween_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.halloween_i18n_bg1, type = AssetType.Main}
        ,{ file = AssetConfig.button1, type = AssetType.Dep}
        ,{ file = AssetConfig.effectbg, type = AssetType.Dep}
        ,{ file = AssetConfig.springfestival_texture, type = AssetType.Dep}
    }

    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.updateListener = function() self:Reload() end
    self.tipsPanel = nil
end

function HalloweenMoonPanel:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.model.giftPreview ~= nil then
        self.model.giftPreview:DeleteMe()
        self.model.giftPreview = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HalloweenMoonPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenmoon))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.timeText = t:Find("DescArea/Time"):GetComponent(Text)
    self.timeText.transform.anchoredPosition = Vector2(71, -114)
    self.NoticeText = t:Find("DescArea/Notice"):GetComponent(Text)
    self.iconLoader = SingleIconLoader.New(t:Find("DescArea/Title/Icon").gameObject)
    self.titleText = t:Find("DescArea/Title/Text"):GetComponent(Text)
    -- self.cloner = t:Find("MaskLayer/ScrollLayer/Cloner").gameObject
    self.cloner = t:Find("MaskLayer/ScrollLayer/ClonerThin").gameObject

    self.scrollRect = t:Find("MaskLayer/ScrollLayer")
    self.container = self.scrollRect:Find("Container")
    self.layout = LuaBoxLayout.New(self.container, {cspacing = -5, axis = BoxLayoutAxis.X, border = 10})

    if self.bg ~= nil then
        UIUtils.AddBigbg(t:Find("DescArea/Bg/BigBg"), GameObject.Instantiate(self:GetPrefab(self.bg)))
        t:Find("DescArea/Bg/BigBg").anchoredPosition = Vector2(-277,61)
    end
    t:Find("DescArea/Bg/BgText").anchoredPosition = Vector2(-216,52)
    UIUtils.AddBigbg(t:Find("DescArea/Bg/BgText"), GameObject.Instantiate(self:GetPrefab(AssetConfig.newyeargoodstext1)))
    t:Find("DescArea/Bg/BgText").gameObject:SetActive(true)
    --UIUtils.AddBigbg(t:Find("DescArea/Bg/BgText_two"), GameObject.Instantiate(self:GetPrefab(AssetConfig.newyeargoodstext2)))
    --t:Find("DescArea/LeftLantern"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.halloweenmoon," ")
    --t:Find("DescArea/RightLantern"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.halloweenmoon," ")

    self.scrollRect:GetComponent(ScrollRect).onValueChanged:AddListener(function(value)
        self:OnRectScroll(value)
    end)


    -- t:Find("DescArea/Info").gameObject:SetActive(true)
    -- self.timeText.text = basedata.timestr
    -- t:Find("MaskLayer/ScrollLayer"):GetComponent(ScrollRect).content = nil

    --self.timeText.gameObject:SetActive(false)
end

function HalloweenMoonPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
    if self.afterSprintFunc ~= nil then
        self.afterSprintFunc(self.iconLoader)
    else
        self.transform:Find("DescArea/Title").gameObject:SetActive(false)
    end
end

function HalloweenMoonPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListener)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.updateListener)

    -- BaseUtils.dump(self.protoData, "self.protoData")
    self:Reload()
end

function HalloweenMoonPanel:OnHide()
    self:RemoveListeners()
end

function HalloweenMoonPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.updateListener)
end

function HalloweenMoonPanel:Reload()
    local iconid = tonumber(DataCampaign.data_list[self.campId].iconid)
    local index = tonumber(DataCampaign.data_list[self.campId].index)
    self.protoData = CampaignManager.Instance.campaignTree[iconid][index] or {}
    --BaseUtils.dump(CampaignManager.Instance.campaignTree[77], "self.protoData")
    --BaseUtils.dump(self.protoData, "self.protoData")

    local basedata = DataCampaign.data_list[self.campId]
    local cli_start_time = basedata.cli_start_time[1]
    local cli_end_time = basedata.cli_end_time[1]

    self.timeText.text = string.format(TI18N("<color='#ffff9a'>%s年%s月%s日-%s年%s月%s日</color>"), tostring(cli_start_time[1]), tostring(cli_start_time[2]), tostring(cli_start_time[3]), tostring(cli_end_time[1]), tostring(cli_end_time[2]), tostring(cli_end_time[3]))
    self.NoticeText.text = basedata.timestr
    self.NoticeText.transform.anchoredPosition = Vector2(0, -352)

    self.titleText.text = basedata.timestr

    local list = {}
    --list = CampaignManager.Instance.model:GetIdsByType(CampaignEumn.ShowType.LuckyMoney)

    for k,v in pairs(self.protoData.sub) do
        table.insert(list, v)
    end
    table.sort(list, function(a,b) return a.id < b.id end)
    --BaseUtils.dump(list,"HalloweenMoonPanel活动id")
    self.layout:ReSet()
    local length = self.layout.spacing
    for i,v in ipairs(list) do
        if self.itemList[i] == nil then
            local obj = GameObject.Instantiate(self.cloner)
            self.itemList[i] = HalloweenMoonItem.New(self.model, obj , self)
            self.itemList[i].bg:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.effectbg, "EffectBg")
        end
        self.layout:AddCell(self.itemList[i].gameObject)
        self.itemList[i]:SetData(v)
        length = length + self.itemList[i].transform.sizeDelta.x
        length = length + self.layout.border
    end
    length = length - self.layout.border
    for i=#list + 1, #self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
    self.cloner:SetActive(false)
    if #self.protoData.sub > 2 then
        self.scrollRect.sizeDelta = Vector2(534, 298)
    else
        self.scrollRect.sizeDelta = Vector2(length, 298)
    end
end



function HalloweenMoonPanel:OnRectScroll(value)
    local Top = 510
    local Bot = -155

    for k,v in pairs(self.itemList) do
        local ax = v.transform.anchoredPosition.x + self.container.anchoredPosition.x
        local state = nil
        if ax  < Bot or ax > Top then
            state = false
        else
            state = v.showEft
        end
        if v.effect ~= nil then
            v.effect:SetActive(state)
        end
    end
end

HalloweenMoonItem = HalloweenMoonItem or BaseClass()

function HalloweenMoonItem:__init(model, gameObject, parent)
    self.gameObject = gameObject
    self.parent = parent
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

    t:Find("Price/TextBg/Line").sizeDelta = Vector2(60, 3)
    t:Find("Price/TextBg/Line"):GetComponent(Image).color = Color(197/255,42/255,18/255)

    if t:Find("Price/TextBg/Line") ~= nil then
        self.line = t:Find("Price/TextBg/Line").gameObject
    end

    -- self.slot.noTips = true
    -- self.slot.clickSelfFunc = function() self:ShowReward() end

    self.slot.gameObject:AddComponent(TransitionButton).scaleRate = 1.1

    self.isRotate = false
    self.showEft = false

    self.timerId = LuaTimer.Add(0, 3000, function() self:Shake() end)
    self.rotateTimerId = LuaTimer.Add(0, 20, function() self:Rotate() end)
end

function HalloweenMoonItem:__delete()
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

    self.assetWrapper = nil
end

function HalloweenMoonItem:SetData(data)
    self.data = data

    self.gameObject:SetActive(true)
    local campData = DataCampaign.data_list[data.id]
    local baseData = nil
    local num = 0
    local lev = RoleManager.Instance.RoleData.lev
    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex

    local hasInit = false
    local rewardList = {}

    local reward = CampaignManager.ItemFilter(campData.reward)[1]

    for _,v in ipairs(campData.rewardgift) do

        if #v == 2 then

            table.insert(rewardList,{v[1],0,v[2]})
        elseif #v == 3 then
            -- local table = {[1] = v[1],[3] = v[3]}
            table.insert(rewardList,{v[1],0,v[3]})
        elseif #v == 4 then
            if (v[1] == 0 or v[1] == classes) and (v[2] == 2 or v[2] == sex) then

                -- local table = {[1] = v[3],[3] = v[4]}
                table.insert(rewardList,{v[3],0,v[4]})
            end
        elseif #v == 6 then
            if lev >= v[1] and lev <= v[2] and (v[3] == 0 or v[3] == classes) and (v[4] == 2 or v[4] == sex) then

                -- local table = {[1] = v[5],[3] = v[6]}
                table.insert(rewardList,{v[5],0,v[6]})
            end
        elseif #v == 7 then
            if lev >= v[1] and lev <= v[2] and (v[3] == 0 or v[3] == classes) and (v[4] == 2 or v[4] == sex) then

                table.insert(rewardList,{v[5],0,v[6],is_effet = v[7]})
            end
        end

    end

    self.slot:SetAll(DataItem.data_get[tonumber(campData.cond_rew)], {inbag = false, nobutton = true})
    -- self.slot:SetImg(tonumber(campData.cond_rew) or 0)
    self.slot.button.onClick:RemoveAllListeners()
    self.slot.button.onClick:AddListener(function()
        if self.tipsPanel == nil then
            self.tipsPanel = SevenLoginTipsPanel.New(self)
        end

        self.tipsPanel:Show({rewardList,5,nil,campData.reward_content})
    end)

    if self.icon ~= nil then
        self.slot:SetImg(self.icon)
    end
    self.button.onClick:RemoveAllListeners()
    local id = data.id

    if self.effect ~= nil then
        self.effect:SetActive(false)
    end

    if #campData.loss_items == 0 then
        self.nameText.text = string.format("<color='#c3692c'>%s</color>",campData.reward_title)
        self.ownObj:SetActive(false)

        self.descText.text = campData.cond_desc -- .. string.format(TI18N("\n当前活跃度<color='#00ff00'>%s</color>/%s"), tostring(activePoint), "60")
        self.descText.gameObject:SetActive(true)
        self.priceObj:SetActive(false)
        self.timesText.gameObject:SetActive(false)

        self.slot:SetNum(data.reward_can, data.reward_max)
        if data.reward_can == 0 then
            self.slot.numTxt.text = string.format("<color='#ff0000'>%s</color>/%s", data.reward_can, data.reward_max)
        else
            self.slot.numTxt.text = string.format("<color='#00ff00'>%s</color>/%s", data.reward_can, data.reward_max)
        end
        -- self.slot:SetImg(29061)

        self.timesText.text = string.format(TI18N("今日限领 <color='#00ff00'>%s</color>/%s"), tostring(data.reward_can), tostring(data.reward_max))
        self.button.onClick:RemoveAllListeners()
        if data.status ~= CampaignEumn.Status.Accepted then
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.buttonText.color = ColorHelper.DefaultButton3
            self.buttonText.text = TI18N("领取")
            self.button.onClick:AddListener(function() CampaignManager.Instance:Send14001(id) end)
        else
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.buttonText.color = ColorHelper.DefaultButton4
            self.buttonText.text = TI18N("已领取")
        end

        if data.status == CampaignEumn.Status.Finish then
            if self.effect == nil then
                self.effect = BibleRewardPanel.ShowEffect(20118, self.button.transform, Vector3(1, 0.75, 1), Vector3(-50, 20, -400))
            else
                self.effect:SetActive(true)
            end
            self.showEft = true
        else
            self.showEft = false
        end
        if self.line ~= nil then
            self.line:SetActive(false)
        end
    else
        self.nameText.text = string.format("<color='#c3692c'>%s</color>",campData.reward_title)
        self.descText.gameObject:SetActive(false)
        self.priceObj:SetActive(true)
        self.ownObj:SetActive(true)

        self.button.onClick:RemoveAllListeners()
        if data.status ~= CampaignEumn.Status.Accepted then
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.buttonText.color = ColorHelper.DefaultButton3
            self.buttonText.text = TI18N("购买")
            self.button.onClick:AddListener(function()
                local campData = DataCampaign.data_list[id]
                local confirmData = NoticeConfirmData.New()
                confirmData.sureCallback = function() CampaignManager.Instance:Send14001(id) end
                confirmData.content = string.format(TI18N("是否花费{assets_1, %s, %s}购买%s？"), tostring(campData.loss_items[1][1]), tostring(campData.loss_items[1][2]), ColorHelper.color_item_name(reward[2],campData.reward_title))
                NoticeManager.Instance:ConfirmTips(confirmData)
            end)
        else
            self.buttonText.text = TI18N("已购买")
            self.buttonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.buttonText.color = ColorHelper.DefaultButton4
        end

        self.slot:SetNum(data.reward_can, data.reward_max)
        if data.reward_can == 0 then
            self.slot.numTxt.text = string.format("<color='#ff0000'>%s</color>/%s", data.reward_can, data.reward_max)
        else
            self.slot.numTxt.text = string.format("<color='#00ff00'>%s</color>/%s", data.reward_can, data.reward_max)
        end
        -- self.slot:SetImg(29063)
        -- self.timesText.text = string.format(TI18N("今日限购 <color='#00ff00'>%s</color>/%s"), tostring(data.reward_can), tostring(data.reward_max))
        self.buttonText.text = TI18N("购买")

        self.priceImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[campData.loss_items[1][1]])
        self.ownImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[campData.loss_items[1][1]])

        if (tonumber(campData.camp_cond_client) or 0) > 0 then
            -- 原价现价
            if self.line ~= nil then
                self.line:SetActive(true)
            end
            self.ownDesc.text = TI18N("现价")
            self.ownText.text = tostring(campData.loss_items[1][2])
            self.priceDesc.text = TI18N("原价")
            self.priceText.text = campData.camp_cond_client
        else
            if self.line ~= nil then
                self.line:SetActive(false)
            end
            self.priceDesc.text = TI18N("价格")
            self.priceText.text = tostring(campData.loss_items[1][2])

            self.ownDesc.text = TI18N("拥有")
            for k,v in pairs(KvData.assets) do
                if v == campData.loss_items[1][1] then
                    if campData.loss_items[1][2] > RoleManager.Instance.RoleData[k] then
                        self.ownText.text = string.format("<color='#ff0000'>%s</color>", tostring(RoleManager.Instance.RoleData[k]))
                    else
                        self.ownText.text = tostring(RoleManager.Instance.RoleData[k])
                    end
                    break
                end
            end
        end
    end
    self.parent:OnRectScroll({x = 0})
end

function HalloweenMoonItem:ShowReward()
    if self.data == nil then return end

    local basedata = DataCampaign.data_list[self.data.id]
    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex
    local datalist = CampaignManager.ItemFilter(basedata.reward)

    if #datalist > 0 then
        if self.model.mainWin ~= nil then
            if self.model.giftPreview == nil then
                self.model.giftPreview = GiftPreview.New(self.model.mainWin.gameObject)
            end

            if #basedata.loss_items > 0 then
                self.model.giftPreview:Show({reward = datalist, autoMain = true, text = TI18N("购买可直接获得以下所有道具"), width = 120, height = 120})
            else
                self.model.giftPreview:Show({reward = datalist, autoMain = true, text = TI18N("领取后直接获得以下所有道具"), width = 120, height = 120})
            end
        end
    else
        TipsManager.Instance:ShowItem({gameObject = self.slot.gameObject, itemData = DataItem.data_get[basedata.reward[1][1]]})
    end
end

function HalloweenMoonItem:Shake()
    if self.data == nil then
        return
    end
    local campData = DataCampaign.data_list[self.data.id]
    if #campData.loss_items == 0 and self.data.status ~= CampaignEumn.Status.Accepted then
        self.button.gameObject.transform.localScale = Vector3(1.2,1.1,1)
        if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
        end
        self.tweenId = Tween.Instance:Scale(self.button.gameObject, Vector3(1,1,1), 1.2, function() self.tweenId = nil end, LeanTweenType.easeOutElastic).id
    end
end

function HalloweenMoonItem:Rotate()
    if self.isRotate == true then
        self.rotateCount = (self.rotateCount or 0) + 1
        self.bg.rotation = Quaternion.Euler(0, 0, self.rotateCount * 3)
    end
end

