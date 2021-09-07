-- @author 黄耀聪
-- @date 2016年12月8日

OpenServerContinueCharge = OpenServerContinueCharge or BaseClass(BasePanel)

function OpenServerContinueCharge:__init(model, parent)
    self.model = NewMoonManager.Instance.model
    self.parent = parent
    self.name = "OpenServerContinueCharge"
    self.mgr = NewMoonManager.Instance

    self.resList = {
        {file = AssetConfig.open_server_continuerecharge, type = AssetType.Main},
        {file = AssetConfig.guidesprite, type = AssetType.Main},
        {file = AssetConfig.newmoon_textures, type = AssetType.Dep},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
    }

    self.timeString = TI18N("时间:<color='#00ff00'>%s~%s</color>")
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
    for i,v in ipairs(DataCampSeriesRecharge.data_openserverdaily) do
        table.insert(self.datalist, v)
    end
end

function OpenServerContinueCharge:__delete()
    self.OnHideEvent:Fire()
    if self.msgExt ~= nil then
        self.msgExt:DeleteMe()
        self.msgExt = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.itemData:DeleteMe()
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

function OpenServerContinueCharge:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_continuerecharge))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.timeText = t:Find("Title/Time"):GetComponent(Text)
    self.container = t:Find("MaskScroll/List")

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
    -- text.fontSize = 18
    -- text.color = ColorHelper.colorObject[2]
    -- text.text = TI18N("充值<color='#ffa500'><size=20>一定金额</size></color>即可领取好礼(每天限1次)")

    local btnList = self.container:GetComponentsInChildren(Button)

    for i,v in ipairs(btnList) do
        local tab = {}
        tab.btn = v
        tab.gameObject = v.gameObject
        tab.transform = v.transform
        tab.slot = ItemSlot.New()
        NumberpadPanel.AddUIChild(v.transform:Find("Slot").gameObject, tab.slot.gameObject)
        tab.itemData = ItemData.New()
        tab.stateText = tab.transform:Find("State"):GetComponent(Text)
        tab.mark = tab.transform:Find("Mark").gameObject

        tab.transform:Find("I18N_Name"):GetComponent(Text).text = string.format(self.dateString, BaseUtils.NumToChn(i))
        local num = #DataCampSeriesRecharge.data_openserverdaily[i].reward
        local baseData = DataItem.data_get[DataCampSeriesRecharge.data_openserverdaily[i].reward[num][1]]
        tab.itemData:SetBase(baseData)
        tab.slot:SetAll(tab.itemData, {inbag = false, nobutton = true, noselect = true})
        tab.slot:SetNum(DataCampSeriesRecharge.data_openserverdaily[i].reward[num][3])
        tab.slot.noTips = true
        tab.slot.clickSelfFunc = function() tab.btn.onClick:Invoke() end
        self.itemList[i] = tab
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

    self.arrow = self.container:Find("Arrow")
    self.arrow:SetParent(self.transform)
    self.tabGroup = TabGroup.New(self.container, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = false, perWidth = 100, perHeight = 125, isVertical = false, spacing = 5})
    self.arrow:SetParent(self.container)
    self.arrow.anchorMax = Vector2(0, 0.5)
    self.arrow.anchorMin = Vector2(0, 0.5)
    self.arrow.pivot = Vector2(0.5, 0.5)
    self.arrow.localScale = Vector3.one

    t:Find("Reward/Scroll").sizeDelta = Vector2(344, 70)
    self.rewardContainer = t:Find("Reward/Scroll/Container")
    self.rewardLayout = LuaBoxLayout.New(self.rewardContainer, {axis = BoxLayoutAxis.X, cspacing = 35, border = 5})
    -- self.msgExt:SetData(self.campBaseData.cond_desc)
    self.noticeBtn = t:Find("Reward/Notice"):GetComponent(Button)
    self.noticeBtn.gameObject:SetActive(false)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    t:Find("Reward/Girl"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")

    self.rechargeBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) end)
end

function OpenServerContinueCharge:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerContinueCharge:OnOpen()
    self:RemoveListeners()
    self.mgr.chargeUpdateEvent:AddListener(self.reloadListener)

    self:ReloadList()

    self:OnTime()

    local select_index = 1
    for index=1,4 do
        local protoData = self.model.chargeData.reward[index]
        select_index = index
        if protoData == nil or protoData.day_status == 1 or protoData.day_status == 0 then
            break
        end
    end
    self.tabGroup:ChangeTab(select_index)
end

function OpenServerContinueCharge:OnHide()
    self:RemoveListeners()
end

function OpenServerContinueCharge:RemoveListeners()
    self.mgr.chargeUpdateEvent:RemoveListener(self.reloadListener)
end

function OpenServerContinueCharge:ReloadList()
    local count = 0
    local model = self.model
    model.chargeData.reward = model.chargeData.reward or {}

    for i,v in ipairs(self.itemList) do
        local data = self.datalist[i]
        local protoData = model.chargeData.reward[i] or {day_status = 0}
        if data ~= nil then
            if protoData.day_status == 1 then
                v.stateText.text = ColorHelper.Fill(ColorHelper.ButtonLabelColor.Blue, TI18N("<color='#00ff00'>领取</color>"))
                v.mark:SetActive(false)
                count = count + 1
            else
                if protoData.day_status == 0 then
                    v.mark:SetActive(false)
                    v.stateText.text = ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("待领取"))
                elseif protoData.day_status == 2 then
                    v.mark:SetActive(true)
                    v.stateText.text = ColorHelper.Fill(ColorHelper.ButtonLabelColor.Gray, TI18N("<color='#33ff33'>已领取</color>"))
                    count = count + 1
                end
            end
            if i == #self.datalist then
                if self.effectList[i] == nil then
                    self.effectList[i] = BibleRewardPanel.ShowEffect(20154, v.transform, Vector3(1.15, 1.1, 1), Vector3(-3, -60, -400))
                end
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

function OpenServerContinueCharge:OnTime()
    local model = self.model
    local start_time = self.campBaseData.cli_start_time[1]
    local end_time = self.campBaseData.cli_end_time[1]
    local openTime = CampaignManager.Instance.open_srv_time
    local chargeTime = NewMoonManager.Instance.model.chargeData.first_time
    local month = os.date("%m", chargeTime)
    local day = os.date("%d", chargeTime)

    local closeTime = openTime + end_time[2]*24*3600 + end_time[3]
    local endmonth = os.date("%m", closeTime)
    local endday = os.date("%d", closeTime)



    self.timeText.text = self.descString .. string.format(self.timeString, string.format(self.timeFormat, tostring(month), tostring(day)), string.format(self.timeFormat, tostring(endmonth), tostring(endday)))
    -- self.timeText.text = self.descString .. string.format(self.timeString, string.format(self.timeFormat, tostring(start_time[1][2]), tostring(start_time[1][3]), tostring(start_time[1][4]), tostring(start_time[1][5])), string.format(self.timeFormat, tostring(end_time[1][2]), tostring(end_time[1][3]), tostring(end_time[1][4]), tostring(end_time[1][5])))
    self.theDays = math.ceil((BaseUtils.BASE_TIME - tonumber(os.time{year = start_time[1], month = start_time[2], day = start_time[3], hour = start_time[4], minute = start_time[5], second = start_time[6]})) / 86400)
end

function OpenServerContinueCharge:ChangeTab(i)
    self:ReloadReward(i)
end

function OpenServerContinueCharge:ReloadReward(i)
    local model = self.model
    self.arrow.anchoredPosition = Vector2(self.itemList[i].transform.anchoredPosition.x, -75)
    self.rewardLayout:ReSet()

    local datalist = {}
    local lev = RoleManager.Instance.RoleData.lev
    for i,v in ipairs(DataCampSeriesRecharge.data_openserverdaily[i].show) do
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
        self.rewardLayout:AddCell(tab.slot.gameObject)
        tab.slot.transform.pivot = Vector2(0.5, 0.5)
    end
    for j=#DataCampSeriesRecharge.data_openserverdaily[i].show + 1,#self.rewardItemList do
        self.rewardItemList[j].slot.gameObject:SetActive(false)
    end
    self.rewardContainer.sizeDelta = Vector2(#datalist * 65 + 5, 60)

    if model.chargeData == nil or model.chargeData.reward == nil then
        return
    end

    if model.chargeData.reward[i] == nil then
        self.msgExt:SetData(TI18N("奖励将在完成前面充值后<color='#ffff00'>下一天</color>开启"))
    else
        self.msgExt:SetData(DataCampSeriesRecharge.data_openserverdaily[i].desc_after)
    end

    -- if self.theDays >= i then
    --     self.msgExt:SetData(DataCampSeriesRecharge.data_openserverdaily[i].desc_after)
    -- else
    --     self.msgExt:SetData(DataCampSeriesRecharge.data_openserverdaily[i].desc)
    -- end

    -- BaseUtils.dump(model.chargeData, "model.chargeData")

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
end

function OpenServerContinueCharge:OnNotice()
    if self.campBaseData ~= nil then
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {self.campBaseData.cond_desc}})
    end
end


