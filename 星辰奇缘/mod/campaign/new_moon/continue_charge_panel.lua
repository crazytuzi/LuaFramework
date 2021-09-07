-- @author 黄耀聪
-- @date 2016年10月13日

ContinueChargePanel = ContinueChargePanel or BaseClass(BasePanel)

function ContinueChargePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ContinueChargePanel"
    --self.mgr = SummerGiftManager.Instance
    self.mgr = NewMoonManager.Instance

    self.resList = {
        {file = AssetConfig.newmoon_continuerecharge, type = AssetType.Main},
        {file = AssetConfig.guidesprite, type = AssetType.Main},
        {file = AssetConfig.newmoon_textures, type = AssetType.Dep},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
    }

    self.timeString = TI18N("时间:<color='#e8faff'>%s~%s</color>")
    self.timeFormat = TI18N("%s月%s日")
    self.descFormat = TI18N("活动描述:<color='#ccecf8'>%s</color>")
    self.dateString = TI18N("第%s天")
    self.descString = ""
    self.itemList = {}
    self.rewardItemList = {}
    self.effectList = {}
    self.reloadListener = function() self:ReloadList() end
    self.isMoving = false
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.campBaseData = DataCampaign.data_list[338]

    self.datalist = {}
    for i,v in ipairs(DataCampSeriesRecharge.data_daily) do
        table.insert(self.datalist, v)
    end
    --self.ItemList_cur = { }
    self.extra = {inbag = false, nobutton = true, noselect = true, noTips = true}
end

function ContinueChargePanel:__delete()
    self.OnHideEvent:Fire()
    if self.msgExt ~= nil then
        self.msgExt:DeleteMe()
        self.msgExt = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.data:DeleteMe()
                if v.effect ~= nil then
                    v.effect:DeleteMe()
                    v.effect = nil
                end
            end
        end
        self.itemList = nil
    end
    if self.rewardItemList ~= nil then
        for _,v in pairs(self.rewardItemList) do
            if v ~= nil then
                v.data:DeleteMe()
                v.slot:DeleteMe()
            end
        end
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.rewardLayout ~= nil then
        self.rewardLayout:DeleteMe()
        self.rewardLayout = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.rechargeImage ~= nil then
        self.rechargeImage.sprite = nil
        self.rechargeImage = nil
    end
    if self.effectList ~= nil then
        for _,v in pairs(self.effectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.effectList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ContinueChargePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.newmoon_continuerecharge))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.timeText = t:Find("Title/Time"):GetComponent(Text)
    self.container = t:Find("Mask/List")
    self.item = t:Find("Mask/Item").gameObject
    self.item:SetActive(false)

    self.scrollRect = self.transform:Find("Mask"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function(value)
        self:OnItemRectScroll(value)
    end)

    -- GameObject.Destroy(t:Find("Title/Title"):GetComponent(Image))
    -- t:Find("Title/Title").gameObject:SetActive(false)
    -- local textTrans = GameObject.Instantiate(self.timeText.gameObject).transform
    -- textTrans:SetParent(t:Find("Title"))
    -- textTrans.localScale = Vector3.one
    -- textTrans.anchorMax = Vector2(0,0.5)
    -- textTrans.anchorMin = Vector2(0,0.5)
    -- textTrans.pivot = Vector2(0, 0.5)
    -- textTrans.anchoredPosition = Vector2(14.23, 0)
    -- textTrans.sizeDelta = Vector2(312, 28)
    -- local text = textTrans:GetComponent(Text)
    -- text.alignment = 3
    -- text.color = ColorHelper.colorObject[2]

    --local btnList = self.container:GetComponentsInChildren(Button)
    
    -- for i,v in ipairs(btnList) do
    --     local tab = {}
    --     tab.btn = v
    --     tab.gameObject = v.gameObject
    --     tab.transform = v.transform
    --     tab.slot = ItemSlot.New()
    --     NumberpadPanel.AddUIChild(v.transform:Find("Slot").gameObject, tab.slot.gameObject)
    --     tab.itemData = ItemData.New()
    --     tab.stateText = tab.transform:Find("State"):GetComponent(Text)
    --     tab.mark = tab.transform:Find("Mark").gameObject

    --     tab.transform:Find("I18N_Name"):GetComponent(Text).text = string.format(self.dateString, BaseUtils.NumToChn(i))

    --     local baseData = DataItem.data_get[DataCampSeriesRecharge.data_daily[i].reward[1][1]]
    --     tab.itemData:SetBase(baseData)
    --     tab.slot:SetAll(tab.itemData, {inbag = false, nobutton = true, noselect = true})
    --     tab.slot:SetNum(DataCampSeriesRecharge.data_daily[i].reward[1][3])
    --     tab.slot.noTips = true
    --     tab.slot.clickSelfFunc = function() tab.btn.onClick:Invoke() end
    --     self.itemList[i] = tab
    -- end
    self.mainLayout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 15, border = 20})

    for i = 1,#self.datalist do 
         if self.itemList[i] == nil then
            local item = { }
            local curItem = GameObject.Instantiate(self.item)
            item.transform = curItem.transform
            item.slot = ItemSlot.New()
            UIUtils.AddUIChild(curItem.transform:Find("Slot").gameObject, item.slot.gameObject)

            item.stateText = curItem.transform:Find("State"):GetComponent(Text)
            item.mark = curItem.transform:Find("Mark").gameObject
            item.transform:Find("I18N_Name"):GetComponent(Text).text = string.format(self.dateString, BaseUtils.NumToChn(i))

            item.data = ItemData.New()
            item.data:SetBase(DataItem.data_get[self.datalist[i].reward[1][1]])
            item.slot:SetAll(item.data, self.extra)
            item.slot:SetNum(self.datalist[i].reward[1][3])
            self.itemList[i] = item
            --self.itemList[i].stateText = curItem.transform:Find("State"):GetComponent(Text)
            --self.itemList[i].mark = curItem.transform:Find("Mark").gameObject
            --self.itemList[i].transform:Find("I18N_Name"):GetComponent(Text).text = string.format(self.dateString, BaseUtils.NumToChn(i))
            self.mainLayout:AddCell(curItem)
         end
    end
    self.msgExt = MsgItemExt.New(t:Find("Reward/Desc"):GetComponent(Text), 355, 17, 20)
    self.msgExt.contentRect.pivot = Vector2(0,1)
    self.msgExt.contentRect.anchoredPosition = Vector2(-220.5, 88)
    self.receiveBtn = t:Find("Reward/Button"):GetComponent(Button)
    self.rechargeImage = t:Find("Reward/Button"):GetComponent(Image)
    self.rechargeText = t:Find("Reward/Button/Text"):GetComponent(Text)

    -- local trs = t:Find("Reward")
    -- local c  = trs.childCount
    -- for i=1,10 do
    --     print(trs:GetChild(i - 1).gameObject.name)
    -- end
    self.rechargeBtn = t:Find("Reward/Recharge"):GetComponent(Button)

    --self.arrow = t:Find("Arrow")
    --self.arrow:SetParent(self.transform)
    self.tabGroup = TabGroup.New(self.container, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = false, perWidth = 100, perHeight = 125, isVertical = false, spacing = 5})
    --self.arrow:SetParent(self.container)
    --self.arrow.anchorMax = Vector2(0, 0.5)
    --self.arrow.anchorMin = Vector2(0, 0.5)
    --self.arrow.pivot = Vector2(0.5, 0.5)
    --self.arrow.localScale = Vector3.one

    t:Find("Reward/Scroll").sizeDelta = Vector2(344, 70)
    t:Find("Reward/Scroll"):GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChange() end)
    self.rewardContainer = t:Find("Reward/Scroll/Container")
    self.rewardLayout = LuaBoxLayout.New(self.rewardContainer, {axis = BoxLayoutAxis.X, cspacing = 35, border = 5})
    -- self.msgExt:SetData(self.campBaseData.cond_desc)
    self.noticeBtn = t:Find("Reward/Notice"):GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    t:Find("Reward/Girl"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")

    self.rechargeBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) end)
end

function ContinueChargePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ContinueChargePanel:OnOpen()
    self:RemoveListeners()
    self.mgr.chargeUpdateEvent:AddListener(self.reloadListener)
    --self.mgr:send17869()
    self.mgr:send14091()
    self:ReloadList()

    self:OnTime()

    local select_index = 1
    for index=1,5 do
        local protoData = self.model.chargeData.reward[index]
        select_index = index
        if protoData == nil or protoData.day_status == 1 or protoData.day_status == 0 then
            break
        end
    end
    self.tabGroup:ChangeTab(select_index)
    self:OnItemRectScroll(1)
end

function ContinueChargePanel:OnHide()
    self:RemoveListeners()
end

function ContinueChargePanel:RemoveListeners()
    self.mgr.chargeUpdateEvent:RemoveListener(self.reloadListener)
end


function ContinueChargePanel:OnItemRectScroll(value)
    --print(self.scrollRect.content.sizeDelta.x)  --645
    --local Right = (value.x-1)*(self.scrollRect.content.sizeDelta.x - 135)

    if self.itemList[4] ~= nil and self.effectList[4] ~= nil then
        if self.scrollRect.content.anchoredPosition.x > 13 then
            self.effectList[4]:SetActive(false)
        else
            self.effectList[4]:SetActive(true)
            
        end
    end

end

function ContinueChargePanel:ReloadList()
    local count = 0
    local model = self.model
    model.chargeData.reward = model.chargeData.reward or {}

    for i,v in ipairs(self.itemList) do
        local data = self.datalist[i]
        local protoData = model.chargeData.reward[i] or {day_status = 0}
        --local stateText = v.transform:Find("State"):GetComponent(Text)
        --local mark = v.transform:Find("Mark").gameObject
        if data ~= nil then
            if protoData.day_status == 1 then
                v.stateText.text = ColorHelper.Fill(ColorHelper.color[2], TI18N("领取"))
                v.mark:SetActive(false)
                count = count + 1
            else
                if protoData.day_status == 0 then
                    v.mark:SetActive(false)
                    v.stateText.text = TI18N("待领取")
                    v.stateText.color = ColorHelper.Default
                elseif protoData.day_status == 2 then
                    v.mark:SetActive(true)
                    v.stateText.text = ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("<color='#33ff33'>已领取</color>"))
                    count = count + 1
                end
            end
            if i == 4 then
                if self.effectList[i] == nil then
                    self.effectList[i] = BibleRewardPanel.ShowEffect(20154, v.transform, Vector3(1.28, 1.1, 1), Vector3(52.8, -60, -400))
                end
                v.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newmoon_textures, "SpecilItemBg")
                v.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newmoon_textures, "guang")
                v.transform:Find("Title"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newmoon_textures, "SpecilTitleBg")
                v.transform:Find("Rare").gameObject:SetActive(true)

            else
                if self.effectList[i] ~= nil then
                    self.effectList[i]:DeleteMe()
                    self.effectList[i] = nil
                end
            end
        else
            v.gameObject:SetActive(false)
        end
    end

    if self.tabGroup.currentIndex ~= nil and self.tabGroup.currentIndex > 0 then
        self:ReloadReward(self.tabGroup.currentIndex)
    end
end
-- function ContinueChargePanel:ReloadList()
--     local count = 0
--     local model = self.model
--     model.chargeData.reward = model.chargeData.reward or {}

--     for i,v in ipairs(self.itemList) do
--         local data = self.datalist[i]
--         local protoData = model.chargeData.reward[i] or {day_status = 0}
--         if data ~= nil then
--             if protoData.day_status == 1 then
--                 v.stateText.text = ColorHelper.Fill(ColorHelper.color[2], TI18N("领取"))
--                 v.mark:SetActive(false)
--                 count = count + 1
--             else
--                 if protoData.day_status == 0 then
--                     v.mark:SetActive(false)
--                     v.stateText.text = TI18N("待领取")
--                     v.stateText.color = ColorHelper.Default
--                 elseif protoData.day_status == 2 then
--                     v.mark:SetActive(true)
--                     v.stateText.text = ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("<color='#33ff33'>已领取</color>"))
--                     count = count + 1
--                 end
--             end
--             if i == 4 then
--                 if self.effectList[i] == nil then
--                     self.effectList[i] = BibleRewardPanel.ShowEffect(20154, v.transform, Vector3(1.28, 1.1, 1), Vector3(-3, -60, -400))
--                 end
--             else
--                 if self.effectList[i] ~= nil then
--                     self.effectList[i]:DeleteMe()
--                     self.effectList[i] = nil
--                 end
--             end
--         else
--             v.gameObject:SetActive(false)
--         end
--     end

--     if self.tabGroup.currentIndex ~= nil and self.tabGroup.currentIndex > 0 then
--         self:ReloadReward(self.tabGroup.currentIndex)
--     end
-- end

function ContinueChargePanel:OnTime()
    local model = self.model
    local start_time = self.campBaseData.cli_start_time
    local end_time = self.campBaseData.cli_end_time

    self.timeText.text = self.descString .. string.format(self.timeString, string.format(self.timeFormat, tostring(start_time[1][2]), tostring(start_time[1][3]), tostring(start_time[1][4]), tostring(start_time[1][5])), string.format(self.timeFormat, tostring(end_time[1][2]), tostring(end_time[1][3]), tostring(end_time[1][4]), tostring(end_time[1][5])))
    self.theDays = math.ceil((BaseUtils.BASE_TIME - tonumber(os.time{year = start_time[1][1], month = start_time[1][2], day = start_time[1][3], hour = start_time[1][4], minute = start_time[1][5], second = start_time[1][6]})) / 86400)
end

function ContinueChargePanel:ChangeTab(i)
    self:ReloadReward(i)
end

function ContinueChargePanel:ReloadReward(i)
    local model = self.model
    --self.arrow.anchoredPosition = Vector2(self.itemList[i].transform.localPosition.x + 70, 27)
    self.rewardLayout:ReSet()

    local datalist = {}
    local lev = RoleManager.Instance.RoleData.lev
    for i,v in ipairs(DataCampSeriesRecharge.data_daily[i].show) do
        if v[4] == nil or (v[4] <= lev and v[5] >= lev) then
            table.insert(datalist, v)
        end
    end
    for id,item in ipairs(datalist) do
        local tab = self.rewardItemList[id]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            tab.data = ItemData.New()
            self.rewardItemList[id] = tab
        end
        tab.data:SetBase(DataItem.data_get[item[1]])
        tab.slot:SetAll(tab.data, {inbag = false, nobutton = true, noselect = true})
        tab.slot:SetNum(item[3])
        tab.slot.transform.sizeDelta = Vector2(60, 60)
        if tab.transitionBtn == nil then
            tab.transitionBtn = tab.slot.gameObject:GetComponent(TransitionButton)
            if tab.transitionBtn == nil then
                tab.transitionBtn = tab.slot.gameObject:AddComponent(TransitionButton)
            end
            tab.transitionBtn.scaleRate = 1.1
        end
        if tab.data.quality > 3 or id == 1 then
            if tab.effect == nil then
                tab.effect = BibleRewardPanel.ShowEffect(20223, tab.slot.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
            else
                tab.effect:SetActive(true)
            end
        else
            if tab.effect ~= nil then
                tab.effect:SetActive(false)
            end
        end
        self.rewardLayout:AddCell(tab.slot.gameObject)
        tab.slot.transform.pivot = Vector2(0.5, 0.5)
    end
    for j=#datalist + 1,#self.rewardItemList do
        self.rewardItemList[j].slot.gameObject:SetActive(false)
    end
    self.rewardContainer.sizeDelta = Vector2(#datalist * 65 + 5, 60)

    if model.chargeData == nil or model.chargeData.reward == nil then
        return
    end
    print("**************************************")
    if model.chargeData.reward[i] == nil then
        self.msgExt:SetData(TI18N("奖励将在完成前面充值后<color='#ffff00'>下一天</color>开启"))
    else
        self.msgExt:SetData(DataCampSeriesRecharge.data_daily[i].desc_after)
    end

    -- if self.theDays >= i then
    --     self.msgExt:SetData(DataCampSeriesRecharge.data_daily[i].desc_after)
    -- else
    --     self.msgExt:SetData(DataCampSeriesRecharge.data_daily[i].desc)
    -- end

    -- BaseUtils.dump(model.chargeData, "model.chargeData")
    BaseUtils.dump(model.chargeData)
    --print(model.chargeData.reward[i].day_status.."&&&&&&&&&&&&&&&&&&")
    self.receiveBtn.onClick:RemoveAllListeners()
    if model.chargeData.reward[i] == nil then
        self.rechargeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.rechargeText.text = TI18N("未开启")
        self.receiveBtn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("未开启")) end)
        if self.effect ~= nil then
            self.effect:DeleteMe()
            self.effect = nil
        end
        self.rechargeBtn.gameObject:SetActive(false)
        self.receiveBtn.gameObject:SetActive(true)
    elseif model.chargeData.reward[i].day_status == 0 then
        self.rechargeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.rechargeText.text = TI18N("充 值")
        self.receiveBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) end)
        if self.effect ~= nil then
            self.effect:DeleteMe()
            self.effect = nil
        end
        self.rechargeBtn.gameObject:SetActive(true)
        self.receiveBtn.gameObject:SetActive(false)
    elseif model.chargeData.reward[i].day_status == 1 then
        self.rechargeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.rechargeText.text = TI18N("领 取")
        --self.receiveBtn.onClick:AddListener(function() self.mgr:send17870(i) end)
        self.receiveBtn.onClick:AddListener(function() self.mgr:send14092(i) end)
        if self.effect == nil then
            self.effect = BibleRewardPanel.ShowEffect(20118, self.rechargeImage.transform, Vector3(1, 0.75, 1), Vector3(-50, 20, -400))
        end
        self.rechargeBtn.gameObject:SetActive(false)
        self.receiveBtn.gameObject:SetActive(true)
    elseif model.chargeData.reward[i].day_status == 2 then
        self.rechargeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.rechargeText.text = TI18N("已领取")
        self.receiveBtn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("奖励已领取~")) end)
        if self.effect ~= nil then
            self.effect:DeleteMe()
            self.effect = nil
        end
        self.rechargeBtn.gameObject:SetActive(false)
        self.receiveBtn.gameObject:SetActive(true)
    end
    -- self.receiveBtn.onClick:AddListener(function() self.noticeBtn.onClick:Invoke() end)
    self:OnValueChange()
end

function ContinueChargePanel:OnNotice()
    if self.campBaseData ~= nil then
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {self.campBaseData.cond_desc}})
    end
end

function ContinueChargePanel:OnValueChange()
    local w = self.rewardContainer.sizeDelta.x
    local x = self.rewardContainer.anchoredPosition.x
    for id,tab in ipairs(self.rewardItemList) do
        local tr = tab.slot.transform
        if (tr.anchoredPosition.x - tr.pivot.x * tr.sizeDelta.x > -x) and (tr.anchoredPosition.x + (1 - tr.pivot.x) * tr.sizeDelta.x < -x + 344) then
            if tab.data.quality > 3 or id == 1 then
                if tab.effect == nil then
                    tab.effect = BibleRewardPanel.ShowEffect(20223, tab.slot.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
                else
                    tab.effect:SetActive(true)
                end
            else
                if tab.effect ~= nil then
                    tab.effect:SetActive(false)
                end
            end
        else
            if tab.effect ~= nil then
                tab.effect:SetActive(false)
            end
        end
    end
end

