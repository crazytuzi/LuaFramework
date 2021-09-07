-- @author 黄耀聪
-- @date 2016年9月10日

MidAutumnReward = MidAutumnReward or BaseClass(BasePanel)

function MidAutumnReward:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MidAutumnReward"

    self.resList = {
        {file = AssetConfig.midAutumn_reward, type = AssetType.Main},
        {file = AssetConfig.midAutumn_textures, type = AssetType.Dep},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
        {file = AssetConfig.bigatlas_midAutumnBg2, type = AssetType.Main},
        {file = AssetConfig.guidesprite, type = AssetType.Main},
    }
    self.assetToKey = {}
    for k,v in pairs(KvData.assets) do
        self.assetToKey[v] = k
    end

    self.limitString = TI18N("今日限兑%s/<color='#00ff00'>%s</color>次")
    self.itemList = {}
    self.reloadListener = function() self:ReloadList() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MidAutumnReward:__delete()
    self.numberpadSettingOne.textObject = nil
    self.numberpadSettingOne = nil
    self.numberpadSettingTwo.textObject = nil
    self.numberpadSettingTwo = nil

    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.itemList ~= nil then
        for i,v in ipairs(self.itemList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.data:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MidAutumnReward:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.midAutumn_reward))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    UIUtils.AddBigbg(t:Find("TitleBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_midAutumnBg2)))
    -- self.descExt = MsgItemExt.New(t:Find("Desc"):GetComponent(Text), 382, 14, 16)
    self.layout = LuaBoxLayout.New(t:Find("Bg/Scroll/Container"), {axis = BoxLayoutAxis.X, cspacing = 20, border = 20})
    self.cloner = t:Find("Bg/Scroll/Cloner").gameObject

    self.cloner:SetActive(false)

    self.max_result_one = 100
    self.max_result_two = 100
    self.updatePriceOne = function()
        local selectNum = NumberpadManager.Instance:GetResult()
        local tab = self.numberpadSettingOne.targetTab
        local baseData = DataCampaign.data_list[tab.id]
        local count = RoleManager.Instance.RoleData[self.assetToKey[baseData.loss_items[1][1]]] or 0
        tab.num = selectNum
        tab.countText.text = tostring(selectNum)
        if tab.num*tab.unitPrice <= count then
            tab.priceText.text = tostring(tab.num*tab.unitPrice)
        else
            tab.priceText.text = string.format("<color='#ff0000'>%s</color>",tostring(tab.num*tab.unitPrice))
        end
    end
    self.updatePriceTwo = function()
        local selectNum = NumberpadManager.Instance:GetResult()
        local tab = self.numberpadSettingTwo.targetTab
        local baseData = DataCampaign.data_list[tab.id]
        local count = RoleManager.Instance.RoleData[self.assetToKey[baseData.loss_items[1][1]]] or 0
        tab.num = selectNum
        tab.countText.text = tostring(selectNum)
        if tab.num*tab.unitPrice <= count then
            tab.priceText.text = tostring(tab.num*tab.unitPrice)
        else
            tab.priceText.text = string.format("<color='#ff0000'>%s</color>",tostring(tab.num*tab.unitPrice))
        end
    end
end

function MidAutumnReward:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MidAutumnReward:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.reloadListener)

    -- BaseUtils.dump(self.openArgs)
    self:ReloadList()
end

function MidAutumnReward:OnHide()
    self:RemoveListeners()
end

function MidAutumnReward:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.reloadListener)
end

function MidAutumnReward:ReloadList()
    local datalist = {}
    for i,v in ipairs(self.campaignData.sub) do
        table.insert(datalist, DataCampaign.data_list[v.id])
    end

    -- self.descExt:SetData(datalist[1].cond_desc)

    self.layout:ReSet()
    for i,v in ipairs(datalist) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.cloner)
            tab.gameObject.name = tostring(i)
            tab.transform = tab.gameObject.transform
            tab.slot = ItemSlot.New()
            tab.data = ItemData.New()
            tab.limitText = tab.transform:Find("Limit"):GetComponent(Text)
            tab.limitText.horizontalOverflow = 1
            NumberpadPanel.AddUIChild(tab.transform:Find("Item").gameObject, tab.slot.gameObject)
            tab.countBtn = tab.transform:Find("BuyArea/BuyCount/CountBg"):GetComponent(Button)
            tab.countText = tab.transform:Find("BuyArea/BuyCount/CountBg/Count"):GetComponent(Text)
            tab.addbtn = tab.transform:Find("BuyArea/BuyCount/AddBtn"):GetComponent(Button)
            tab.minusbtn = tab.transform:Find("BuyArea/BuyCount/MinusBtn"):GetComponent(Button)
            tab.priceText = tab.transform:Find("BuyArea/BuyPrice/PriceBg/Price"):GetComponent(Text)
            tab.priceImage = tab.transform:Find("BuyArea/BuyPrice/PriceBg/Currency"):GetComponent(Image)
            tab.btn = tab.transform:Find("BuyArea/BtnArea/Button"):GetComponent(Button)
            tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
            if i == 1 then
                self.numberpadSettingOne = {               -- 弹出小键盘的设置
                    gameObject = tab.countBtn.gameObject,
                    min_result = 1,
                    max_by_asset = self.max_result_one,
                    max_result = self.max_result_one,
                    textObject = tab.countText,
                    show_num = false,
                    funcReturn = function() NoticeManager.Instance:FloatTipsByString(TI18N("请确认购买")) end,
                    callback = self.updatePriceOne,
                    targetTab = tab
                }
                tab.countBtn.onClick:AddListener(function() self:OnNumberpadOne() end)
            elseif i == 2 then
                self.numberpadSettingTwo = {               -- 弹出小键盘的设置
                    gameObject = tab.countBtn.gameObject,
                    min_result = 1,
                    max_by_asset = self.max_result_two,
                    max_result = self.max_result_two,
                    textObject = tab.countText,
                    show_num = false,
                    funcReturn = function() NoticeManager.Instance:FloatTipsByString(TI18N("请确认购买")) end,
                    callback = self.updatePriceTwo,
                    targetTab = tab
                }
                tab.countBtn.onClick:AddListener(function() self:OnNumberpadTwo() end)
            end
            tab.num = 1
            self.itemList[i] = tab
        end

        local protoData = CampaignManager.Instance.campaignTab[v.id]
        if protoData.reward_can > 0 then
            tab.limitText.text = string.format(self.limitString, tostring(protoData.reward_can), tostring(protoData.reward_max))
        else
            tab.limitText.text = string.format(self.limitString, string.format("<color='#ff0000'>%s</color>",tostring(protoData.reward_can)), tostring(protoData.reward_max))
        end

        if i == 1 then
            self.max_result_one = protoData.reward_max
        elseif i == 2 then
            self.max_result_two = protoData.reward_max
        end

        tab.data:SetBase(DataItem.data_get[v.reward[1][1]])
        tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
        tab.slot:SetNum(v.reward[1][2])
        tab.num = 1
        tab.countText.text = tostring(tab.num)
        tab.id = protoData.id
        local loss = v.loss_items[1] or {}
        local count = RoleManager.Instance.RoleData[self.assetToKey[loss[1]]] or 0
        tab.unitPrice = loss[2] or 0
        if count > tab.unitPrice then
            tab.priceText.text = tostring(loss[2] or 0)
        else
            tab.priceText.text = string.format("<color='#ff0000'>%s</color>",tostring(loss[2] or 0))
        end
        tab.priceImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[loss[1] or 90002])
        tab.addbtn.onClick:RemoveAllListeners()
        tab.minusbtn.onClick:RemoveAllListeners()
        tab.addbtn.onClick:AddListener(function() self:AddOrMinus(true, i) end)
        tab.minusbtn.onClick:AddListener(function() self:AddOrMinus(false, i) end)
        tab.btn.onClick:RemoveAllListeners()
        tab.btn.onClick:AddListener(function() self:OnClick(i) end)
        tab.nameText.text = tab.data.name
        self.layout:AddCell(tab.gameObject)
    end
end

function MidAutumnReward:AddOrMinus(bool, i)
    local item = self.itemList[i]
    local protoData = CampaignManager.Instance.campaignTab[item.id]
    local baseData = DataCampaign.data_list[item.id]

    local count = RoleManager.Instance.RoleData[self.assetToKey[baseData.loss_items[1][1]]] or 0
    if bool == true then -- 加
        if item.num < protoData.reward_can then
            item.num = item.num + 1
        end
    else                -- 减
        if item.num > 1 then
            item.num = item.num - 1
        end
    end
    item.countText.text = tostring(item.num)
    if item.num*item.unitPrice <= count then
        item.priceText.text = tostring(item.num*item.unitPrice)
    else
        item.priceText.text = string.format("<color='#ff0000'>%s</color>",tostring(item.num*item.unitPrice))
    end
end

function MidAutumnReward:OnClick(i)
    local item = self.itemList[i]
    for i=1,item.num do
        CampaignManager.Instance:Send14001(item.id)
    end
end

function MidAutumnReward:OnNumberpadOne()
    local max_result = self.max_result_one
    self.numberpadSettingOne.max_result = max_result
    self.numberpadSettingOne.max_by_asset = max_result
    NumberpadManager.Instance:set_data(self.numberpadSettingOne)
end


function MidAutumnReward:OnNumberpadTwo()
    local max_result = self.max_result_two
    self.numberpadSettingOne.max_result = max_result
    self.numberpadSettingOne.max_by_asset = max_result
    NumberpadManager.Instance:set_data(self.numberpadSettingTwo)
end
