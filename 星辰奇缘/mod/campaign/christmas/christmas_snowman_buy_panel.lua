ChristmasSnowmanBuyPanel = ChristmasSnowmanBuyPanel or BaseClass(BasePanel)

function ChristmasSnowmanBuyPanel:__init(model, gameObject, campaign_id)
    self.gameObject = gameObject
    self.model = model
    self.transform = gameObject.transform

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.campId = campaign_id

    self.costItems = self.model:GetSnowManData(campaign_id)
    self.stringFormat = TI18N("自动使用背包的%s堆雪人，并获得以下奖励")

    self.gift_one = 0
    self.gift_two = 0

    self.itemList = {}
    self.reloadListener = function() self:Reload() end

    self:InitPanel()
end

function ChristmasSnowmanBuyPanel:__delete()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            v.data:DeleteMe()
            v.slot:DeleteMe()
        end
        self.itemList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
end

function ChristmasSnowmanBuyPanel:InitPanel()
    local t = self.transform

    t:GetComponent(Button).onClick:AddListener(function() self:HideSelf() end)

    local main = t:Find("BuyArea")
    self.cloner = main:Find("Cloner").gameObject
    self.layout = LuaBoxLayout.New(main:Find("Container"), {axis = BoxLayoutAxis.X, border = 25, cspacing = 5})

    self.descText = main:Find("Desc"):GetComponent(Text)
    self.showBtn = main:Find("BtnArea/More"):GetComponent(Button)
    self.sureBtn = main:Find("BtnArea/Sure"):GetComponent(Button)
    self.cancelBtn = main:Find("BtnArea/Cancel"):GetComponent(Button)

    self.cancelBtn.transform.anchoredPosition = Vector2(-75.9, 4)
    self.sureBtn.transform.anchoredPosition = Vector2(64.9, 4)

    self.showBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_uniwin,{self.campId - 1}) end)
    self.cancelBtn.onClick:AddListener(function() self:HideSelf() end)

    self.cloner:SetActive(false)

    self:OnOpen()
end

function ChristmasSnowmanBuyPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.reloadListener)

    self.gift_one = DataCampaign.data_list[self.campId].rewardgift[1][1]
    self.gift_two = DataCampaign.data_list[self.campId].rewardgift[2][1]

    self:Reload()
end

function ChristmasSnowmanBuyPanel:OnHide()
    self:RemoveListeners()
end

function ChristmasSnowmanBuyPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.reloadListener)
end

function ChristmasSnowmanBuyPanel:HideSelf()
    self:Hiden()
end

function ChristmasSnowmanBuyPanel:Reload()
    local hasDic = {}
    local _count = 0
    for _,base_id in ipairs(self.costItems) do
        local count = BackpackManager.Instance:GetItemCount(base_id)
        if count > 0 then
            hasDic[base_id] = count
            _count = _count + 1
        end
    end
    self.layout:ReSet()
    if _count == 0 then
        for i,base_id in ipairs(self.costItems) do
            local tab = self.itemList[i]
            if tab == nil then
                tab = {}
                tab.gameObject = GameObject.Instantiate(self.cloner)
                tab.transform = tab.gameObject.transform
                tab.slot = ItemSlot.New()
                tab.data = ItemData.New()
                NumberpadPanel.AddUIChild(tab.transform:Find("Slot"), tab.slot.gameObject)
                tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
                self.itemList[i] = tab
            end
            local baseData = DataItem.data_get[base_id]
            tab.data:SetBase(baseData)
            tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
            tab.slot:SetNum(1)
            self.layout:AddCell(tab.gameObject)
            tab.nameText.text = baseData.name
        end
        for i=#self.costItems + 1,#self.itemList do
            self.itemList[i].gameObject:SetActive(false)
        end
        self.descText.text = TI18N("需要以下道具才能堆雪人哦\n（查看更多活动获取吧）")
        self.sureBtn.gameObject:SetActive(false)
        self.cancelBtn.gameObject:SetActive(false)
        self.showBtn.gameObject:SetActive(true)
    else
        local index = 0
        local str = ""
        local showList = {}
        for base_id,count in pairs(hasDic) do
            str = str .. ColorHelper.color_item_name(DataItem.data_get[base_id].quality, string.format("%s*%s", DataItem.data_get[base_id].name, tostring(count)))
            index = index + 1
            if base_id == tonumber(self.costItems[#self.costItems]) then
                showList[self.gift_two] = showList[self.gift_two] or 0
                showList[self.gift_two] = showList[self.gift_two] + count
            else
                showList[self.gift_one] = showList[self.gift_one] or 0
                showList[self.gift_one] = showList[self.gift_one] + count
            end
            if index ~= _count then
                str = str .. TI18N("、")
            end
        end

        local i = 0
        for base_id, count in pairs(showList) do
            i = i + 1
            local tab = self.itemList[i]
            if tab == nil then
                tab = {}
                tab.gameObject = GameObject.Instantiate(self.cloner)
                tab.transform = tab.gameObject.transform
                tab.slot = ItemSlot.New()
                tab.data = ItemData.New()
                NumberpadPanel.AddUIChild(tab.transform:Find("Slot"), tab.slot.gameObject)
                tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
                self.itemList[i] = tab
            end
            local baseData = DataItem.data_get[base_id]
            tab.data:SetBase(baseData)
            tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
            tab.slot:SetNum(count)
            self.layout:AddCell(tab.gameObject)
            tab.nameText.text = baseData.name
        end
        for i=_count+1,#self.itemList do
            self.itemList[i].gameObject:SetActive(false)
        end
        self.descText.text = string.format(self.stringFormat, str)
        self.sureBtn.gameObject:SetActive(true)
        self.cancelBtn.gameObject:SetActive(true)
        self.showBtn.gameObject:SetActive(false)

        self.sureBtn.onClick:RemoveAllListeners()
        self.sureBtn.onClick:AddListener(function()
            -- for base_id, count in pairs(hasDic) do
            --     if count ~= nil and count > 0 then
            --         for i,v in ipairs(self.costItems) do
            --             if v == base_id then
            --                 DoubleElevenManager.Instance:Send17820(i)
            --                 break
            --             end
            --         end
            --     end
            -- end
            -- self:HideSelf()
            DoubleElevenManager.Instance:Send17820(1)
            WindowManager.Instance:CloseWindowById(WindowConfig.WinID.christmas_snowman, {self.campId})
        end)
    end
end
