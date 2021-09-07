-- @author hze
-- @date #19/02/25#
-- @开服新累充活动

OpenServerContinuousRecharge = OpenServerContinuousRecharge or BaseClass(BasePanel)

function OpenServerContinuousRecharge:__init(model, parent)
    self.parent = parent
    self.name = "OpenServerContinuousRecharge"

    self.mgr = OpenServerManager.Instance
    self.model = model

    self.resList = {
        {file = AssetConfig.open_server_continuousrecharge, type = AssetType.Main},
        {file = AssetConfig.open_server_continuousrecharge_bg, type = AssetType.Main},
        {file = AssetConfig.open_server_textures, type = AssetType.Dep},
        -- {file = AssetConfig.open_server_continuousrecharge_textures, type = AssetType.Dep},
    }

    self.setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        perWidth = 101,
        perHeight = 131,
        isVertical = false,
        spacing = 0
    }

    self.timeFormat = TI18N("活动时间：%s月%s日-%s月%s日")
    self.dateString = TI18N("第%s天")

    self.isMoving = false

    self.itemList = {}
    self.rewardItemList = {}
    self.campaignDataList = model.continuousRechargeData.reward_info 
    -- self.effectList = {}


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    
    self.reloadListener = function(data) self:ReloadData(data) end
end

function OpenServerContinuousRecharge:__delete()
    self.OnHideEvent:Fire()

    if self.layout ~= nil then
        self.layout:DeleteMe()
    end


    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.iconloader:DeleteMe()
                v.effect:DeleteMe()
            end
        end
    end

    if self.tabGroup ~= nil then 
        self.tabGroup:DeleteMe()
    end

    if self.rewardLayout ~= nil then 
        self.rewardLayout:DeleteMe()
    end

    if self.tabbedPanel ~= nil then 
        self.tabbedPanel:DeleteMe()
    end

    if self.rewardItemList ~= nil then
        for _,v in pairs(self.rewardItemList) do
            if v ~= nil then
                v.data:DeleteMe()
                v.slot:DeleteMe()
            end
        end
    end

    -- BaseUtils.ReleaseImage(self.iconImage)
    if self.iconloader then 
        self.iconloader:DeleteMe()
    end


    if self.btnEffect ~= nil then
        self.btnEffect:DeleteMe()
    end

    self:AssetClearAll()
end

function OpenServerContinuousRecharge:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_continuousrecharge))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    local t = self.transform:Find("Panel")

    UIUtils.AddBigbg(self.transform:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_continuousrecharge_bg)))

    self.scrollRect = t:Find("MaskScroll"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function()
        self:DealExtraEffect(self.scrollRect, self.itemList, {axis = BoxLayoutAxis.X, delta1 = 20, delta2 = 20})
    end)
    self.itemContainer = t:Find("MaskScroll/Container")
    self.itemCloner = t:Find("MaskScroll/Item").gameObject
    self.itemCloner:SetActive(false)

    self.iconImage = t:Find("IconImage"):GetComponent(Image)
    self.iconloader = SingleIconLoader.New(self.iconImage.gameObject)

    self.btn = t:Find("Button"):GetComponent(Button)
    self.prePageBtn = t:Find("LeftBtn"):GetComponent(Button)
    self.nextPageBtn = t:Find("RightBtn"):GetComponent(Button)

    self.timeText = t:Find("Time"):GetComponent(Text)
    self.titleTxt = t:Find("I18N_Title_Txt"):GetComponent(Text)
    self.sliderTxt = t:Find("Slider/SliderTxt"):GetComponent(Text)
    
    self.fillAreaTrans = t:Find("Slider/FillArea"):GetComponent(RectTransform)

    self.layout = LuaBoxLayout.New(self.itemContainer, {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})

    if self.model.continuousRechargeData == nil then 
        Log.Error("20471协议数据不正常")
        return
    end

    local campaignInfo = self.model.continuousRechargeData.reward_info or {} 
    -- local count = #self.campaignDataList
    for i,val in ipairs(self.campaignDataList) do
        local tab = {}
        tab.gameObject = GameObject.Instantiate(self.itemCloner)
        tab.transform = tab.gameObject.transform
        tab.gameObject.name = tostring(i)
        tab.iconloader = SingleIconLoader.New(tab.transform:Find("ItemIcon").gameObject)
        tab.dayText = tab.transform:Find("I18N_Day"):GetComponent(Text)
        tab.nameText = tab.transform:Find("I18N_Name"):GetComponent(Text)
        tab.slotbg = tab.transform:Find("SlotBg")
        tab.mark = tab.transform:Find("Mark").gameObject
        tab.mark:SetActive(false)
        tab.select = tab.transform:Find("Select").gameObject
        tab.select:SetActive(false)
        -- tab.specailIcon = tab.transform:Find("SpecailIcon").gameObject
        -- tab.specailIcon:SetActive(count == i)

        tab.dayText.text = string.format(self.dateString, val.recharge_day)
        tab.iconloader:SetSprite(SingleIconType.Item, DataItem.data_get[val.v_item_id].icon)
        if tab.effect == nil then
            tab.effect = BaseUtils.ShowEffect(20223, tab.slotbg, Vector3(1,1,1), Vector3(0,0,0))
        end
        tab.effect:SetActive(val.v_effect == 1)

        tab.nameText.text = val.desc

        self.layout:AddCell(tab.gameObject)
        self.itemList[i] = tab
    end

    self.tabGroup = TabGroup.New(self.itemContainer, function(index) self:ChangeTab(index) end, self.setting)
    
    self.rewardScrollRect = t:Find("Reward"):GetComponent(ScrollRect)
    self.rewardScrollRect.onValueChanged:AddListener(function()     
        self:DealExtraEffect(self.rewardScrollRect, self.rewardItemList, {axis = BoxLayoutAxis.X})
    end)
    self.rewardContainer = self.rewardScrollRect.transform:Find("Container")
    self.rewardLayout = LuaBoxLayout.New(self.rewardContainer, {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})

    self.pageCount = #self.campaignDataList - math.ceil(self.scrollRect:GetComponent(RectTransform).sizeDelta.x / self.setting.perWidth) + 1
    self.tabbedPanel = TabbedPanel.New(self.scrollRect.gameObject, self.pageCount, self.setting.perWidth, 0.5)
    self.tabbedPanel.MoveEndEvent:AddListener(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)

    self.scrollRect.onValueChanged:AddListener(function(data) self:OnDrag(data) end)
    self.prePageBtn.onClick:AddListener(function()
        if self.tabbedPanel.currentPage > 1 then
            self.tabbedPanel:TurnPage(self.tabbedPanel.currentPage - 1)
        end
    end)
    self.nextPageBtn.onClick:AddListener(function()
        if self.tabbedPanel.currentPage < self.pageCount then
            self.tabbedPanel:TurnPage(self.tabbedPanel.currentPage + 1)
        end
    end)
end

function OpenServerContinuousRecharge:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerContinuousRecharge:OnOpen()
    self:RemoveListeners()
    self.mgr.rechargeUpdateEvent:AddListener(self.reloadListener)

    local campData = DataCampaign.data_list[self.campId]
    local open_time = CampaignManager.Instance.open_srv_time
    local end_time = open_time + campData.cli_end_time[1][2] * 24 * 3600 + campData.cli_end_time[1][3]
    self.timeText.text = string.format( self.timeFormat, tonumber(os.date("%m", open_time)), tonumber(os.date("%d", open_time)), tonumber(os.date("%m", end_time)), tonumber(os.date("%d", end_time)))
    -- self.timeText.text = string.format( self.timeFormat, campData.cli_start_time[1][2], campData.cli_start_time[1][3], campData.cli_end_time[1][2], campData.cli_end_time[1][3])

    self:DealExtraEffect(self.scrollRect, self.itemList, {axis = BoxLayoutAxis.X, delta1 = 20, delta2 = 20})
    self:DealExtraEffect(self.rewardScrollRect, self.rewardItemList, {axis = BoxLayoutAxis.X})
    self.rewardContainer.transform.anchoredPosition = Vector2(1,-9)

    self:JumpImage()

    self.mgr:send20471()
end

function OpenServerContinuousRecharge:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then 
        LuaTimer.Delete(self.timerId)
    end 

    if self.tweenId ~= nil then 
        Tween.Instance:Cancel(self.tweenId)
    end
end

function OpenServerContinuousRecharge:RemoveListeners()
    self.mgr.rechargeUpdateEvent:RemoveListener(self.reloadListener)
end

function OpenServerContinuousRecharge:LoadItem()  
    
end

function OpenServerContinuousRecharge:ReloadData(data)  
    self.roleinfodata = data or {}
    self.tabGroup:ChangeTab(self.roleinfodata.vision_day)
    -- self:ChangeTab(self.roleinfodata.vision_day)
end



function OpenServerContinuousRecharge:ChangeTab(i)
    self.rewardContainer.transform.anchoredPosition = Vector2(0.1,-9)
    self:ReloadReward(i)
end

function OpenServerContinuousRecharge:ReloadReward(i)
    self.rewardLayout:ReSet()
    local campaignInfo = self.campaignDataList[i]
    local datalist = campaignInfo.items or {}
    local shownum = 0
    for id,item in ipairs(datalist) do
        local tab = self.rewardItemList[id]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            tab.data = ItemData.New()
        end
        tab.data:SetBase(DataItem.data_get[item.item_base_id])
        tab.slot:SetAll(tab.data, {inbag = false, nobutton = true, noselect = true})
        tab.slot:SetNum(item.num)
        tab.slot.transform.sizeDelta = Vector2(60, 60)
        tab.slot:ShowEffect(item.client_effect == 1,20223)
        tab.gameObject = tab.slot.gameObject
        tab.effect = tab.slot.effect
        self.rewardLayout:AddCell(tab.slot.gameObject)
        self.rewardItemList[id] = tab
        shownum = id
    end
    for j = shownum + 1,#self.rewardItemList do
        self.rewardItemList[j].slot.gameObject:SetActive(false)
    end
    self.rewardContainer.sizeDelta = Vector2(#datalist * 65 + 5, 60)

    local recharged_val = self.roleinfodata.recharged_val

    if i <= self.roleinfodata.recharged_day then 
        recharged_val = campaignInfo.lower
    end

    self.titleTxt.text = campaignInfo.lower - recharged_val
    self.sliderTxt.text = string.format( "%s/%s", recharged_val, campaignInfo.lower)
    self.fillAreaTrans.sizeDelta = Vector2((recharged_val / campaignInfo.lower) * 297, 18)

    -- self.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_continuousrecharge_textures, string.format( "conrec_%s", campaignInfo.v_item_id))
    self.iconloader:SetSprite(SingleIconType.Other, campaignInfo.v_item_id)

    --奖励是否已领取条件                                                                
    local flag = false
    for k,v in ipairs(self.roleinfodata.rewarded_list) do
        if v.day_id == i then 
            flag = true
        end 
        self.itemList[v.day_id].mark:SetActive(true)
    end

    self.btn.onClick:RemoveAllListeners()
    if flag then 
        self.btn.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "UnReceiveBtn")
        self.btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("奖励已领取")) end)
        if self.btnEffect ~= nil then
            self.btnEffect:SetActive(false)
        end

    elseif i > self.roleinfodata.vision_day then
        self.btn.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "UnOpenBtn")
        self.btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("将在完成前面的充值后的下一天开启哟{face_1,3}")) end)
        if self.btnEffect ~= nil then
            self.btnEffect:SetActive(false)
        end
    elseif i <= self.roleinfodata.recharged_day then 
        self.btn.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "ReceiveBtn")
        self.btn.onClick:AddListener(function() 
            self.mgr:send20472(i) 
        end)
        if self.btnEffect == nil then
            self.btnEffect = BaseUtils.ShowEffect(20053, self.btn.transform, Vector3(2, 0.75, 1), Vector3(-65, -16, -1000))
        end
        self.btnEffect:SetActive(true)
    elseif i == self.roleinfodata.vision_day and i ~= self.roleinfodata.recharged_day then 
        self.btn.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "RechargeBtn")
        self.btn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) end)
        if self.btnEffect ~= nil then
            self.btnEffect:SetActive(false)
        end
    end
end

function OpenServerContinuousRecharge:OnDrag(data)
    if self.isMoving == false then
        self.isMoving = true
        local x = math.ceil(data[1] * self.pageCount)
        if x > self.pageCount then
            x = self.pageCount
        elseif x < 1 then
            x = 1
        end
        self:OnDragEnd(x)
        self.tabbedPanel.currentPage = x
    end
end

function OpenServerContinuousRecharge:OnDragEnd(currentPage, direction)
    if currentPage < self.pageCount then 
        BaseUtils.SetGrey(self.nextPageBtn.transform:GetComponent(Image), false)
    else    
        BaseUtils.SetGrey(self.nextPageBtn.transform:GetComponent(Image), true)
    end

    if currentPage > 1 then 
        BaseUtils.SetGrey(self.prePageBtn.transform:GetComponent(Image), false)
    else
        BaseUtils.SetGrey(self.prePageBtn.transform:GetComponent(Image), true)
    end

    self.isMoving = false
end


function OpenServerContinuousRecharge:OnNotice()
    if self.campBaseData ~= nil then
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {self.campBaseData.cond_desc}})
    end
end


function OpenServerContinuousRecharge:JumpImage()
    local iconImgRect = self.iconImage.transform:GetComponent(RectTransform)
    local origin_x = iconImgRect.anchoredPosition.x
    local origin_y = iconImgRect.anchoredPosition.y
    local value = 0

    local callback = function()  
        if self.tweenId ~= nil then 
            Tween.Instance:Cancel(self.tweenId)
            self.tweenId = nil
        end
        self.tweenId = Tween.Instance:ValueChange(0, 360, 2
            ,function() self.tweenId = nil end
            ,LeanTweenType.linear
            ,function(value) iconImgRect.anchoredPosition = Vector2(origin_x, origin_y + math.sin((value/180) * math.pi) * 10) end
        ).id
    end
    self.timerId = LuaTimer.Add(0,2000,callback)
end

function OpenServerContinuousRecharge:DealExtraEffect(scrollRect,item_list,args)
    args = args or {}
    args.axis = args.axis or BoxLayoutAxis.X    --轴
    args.delta1 = args.delta1 or 0              --左方（上方）偏移量
    args.delta2 = args.delta2 or 0              --右方（下方）偏移量

    local __xy =  (args.axis == BoxLayoutAxis.X) and "x" or "y"
    local container = scrollRect.content

    local a_side = -container.anchoredPosition[__xy]                
    local b_side = a_side + scrollRect.transform.sizeDelta[__xy]    

    local a_xy,s_xy = 0,0
    for k,v in pairs(item_list) do
        a_xy = v.gameObject.transform.anchoredPosition[__xy] + args.delta1
        s_xy = v.gameObject.transform.sizeDelta[__xy] - args.delta1 - args.delta2
        if v.effect ~= nil then 
            v.effect:SetActive(a_xy > a_side and a_xy + s_xy < b_side)
        end
    end
end