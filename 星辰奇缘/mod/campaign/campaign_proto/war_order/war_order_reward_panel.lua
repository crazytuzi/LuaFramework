-- @author hze
-- @date #19/08/19#
-- @战令奖励面板

WarOrderRewardPanel = WarOrderRewardPanel or BaseClass(BasePanel)

function WarOrderRewardPanel:__init(model, parent)
    self.resList = {
        {file = AssetConfig.war_order_reward_panel, type = AssetType.Main},
        {file = AssetConfig.warordertextures, type = AssetType.Dep},
    }
    self.model = model
    self.parent = parent
    self.mgr = CampaignProtoManager.Instance


    self.itemList = {}
    self.last_index = 0

    self.itemInitFlag = false    --item创建完成标志

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self._update_load_listener = function() self:ReloadData() end
end

function WarOrderRewardPanel:__delete()
    self.OnHideEvent:Fire()

    if self.itemList ~= nil then
        for i, list_item in ipairs(self.itemList) do
            list_item:DeleteMe()
        end
    end

    if self.endListItem ~= nil then 
        self.endListItem:DeleteMe()
    end

    if self.rewardIconLoader then 
        self.rewardIconLoader:DeleteMe()
    end

    self:AssetClearAll()
end

function WarOrderRewardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.war_order_reward_panel))
    self.gameObject.name = "WarOrderRewardPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    local t = self.transform

    local startTrans = t:Find("Left/Start")
    self.name1Txt = startTrans:Find("Name1"):GetComponent(Text)
    self.name2Txt = startTrans:Find("Name2"):GetComponent(Text)

    self.name1Txt.text = WarOrderConfigHelper.GetOrder(1).name
    self.name2Txt.text = WarOrderConfigHelper.GetOrder(2).name

    self.lockBtn = startTrans:Find("Lock"):GetComponent(Button)
    self.buyBtn = startTrans:Find("Button"):GetComponent(Button)

    self.lockBtn.onClick:AddListener(function() self:OnLockBuyClick() end)
    self.buyBtn.onClick:AddListener(function() self:OnLockBuyClick() end)

    -- local container = t:Find("Left/ScrollRect/Container")
    -- for i = 1, 5 do 
    --     self.itemList[i] = WarOrderRewardItem.New(self.model, container:GetChild(i - 1).gameObject)
    -- end

    -- self.proxy = LuaListCycle.Init(container, {cellX = 80, cellY = 310, spacingX = 0, spacingY = 0, left = 0, top = 0, itemList = self.itemList, column = 5, direct = LuaLayoutEnum.Direct.Horizontal})
    -- scrollRect.onValueChanged:AddListener( function() self:OnRectScroll() LuaListCycle.OnValueChanged(self.proxy) end)


    self.scroll = t:Find("Left/ScrollRect"):GetComponent(ScrollRect)
    self.scroll.onValueChanged:AddListener(function(val) self:OnRectScroll(val) end)

    self.container = self.scroll.transform:Find("Container")
    self.itemCloner = self.container:Find("ListItem").gameObject
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 0})

    local data = DataCampWarOrder.data_reward
    local count = 0
    for lev, v in ipairs(data) do
        count = count + 1
        if count <= 5 then 
            local item = self.itemList[count]
            if item == nil then
                item = WarOrderRewardItem.New(self.model, GameObject.Instantiate(self.itemCloner))
                self.itemList[count] = item
                self.layout:AddCell(item.gameObject)
            end
            item:SetData(v)
        else
            break
        end
    end

    self.itemCloner:SetActive(false)

    local late_callback = function()
        local count = 0
        for lev, v in ipairs(data) do
            -- local dat = WarOrderConfigHelper.GetReward(lev)
            count = count + 1
            if count > 5 then 
                local item = self.itemList[count]
                if item == nil then
                    item = WarOrderRewardItem.New(self.model, GameObject.Instantiate(self.itemCloner))
                    self.itemList[count] = item
                    self.layout:AddCell(item.gameObject)
                end
                item:SetData(v)
                item:SetActive(true)
            end
        end
        self.itemInitFlag = true   --item创建完成
    end

    LuaTimer.Add(300, late_callback)

    self.endListItem = WarOrderRewardItem.New(self.model, t:Find("Left/End").gameObject)

    local right = t:Find("Right")
    self.rewardIconLoader = SingleIconLoader.New(right:Find("RewardIcon").gameObject)
    self.rewardNameTxt = right:Find("NameBg/Text"):GetComponent(Text)
    self.rewardDescTxt = right:Find("DescText"):GetComponent(Text)

    self.previewBtn = t:Find("PreviewButton"):GetComponent(Button)
    self.obtainBtn = t:Find("ObtainButton"):GetComponent(Button)

    self.redObj = t:Find("ObtainButton/Red").gameObject

    self.previewBtn.onClick:AddListener(function() self:OnRewardPreviewClick() end)
    self.obtainBtn.onClick:AddListener(function() self:OnQuickObtainClick() end)
end

function WarOrderRewardPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WarOrderRewardPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    if not self.openArgs then
        return
    end
    self.campId = self.openArgs
    -- print(self.campId)

    --zhizhang
    local cfg = WarOrderConfigHelper.GetOrder(2)

    self.special_lev = cfg.special_lev
    self.special_desc = BaseUtils.split(cfg.special_desc, ",")
    self.special_item = cfg.special_item

    local callback = function()
        local perfect_lev = 1
        for lev, v in ipairs(DataCampWarOrder.data_reward) do
            if self.model:GetWarOrderObtainedStatus(v[1].id, lev) == 2 or (self.model:GetHighLevelWarStatus() and self.model:GetWarOrderObtainedStatus(v[2].id, lev) == 2) then
                perfect_lev = lev
            end
        end
        self.container.anchoredPosition = Vector2(-(perfect_lev - 1) * 80, -1.8)
    end

    if self.itemInitFlag then
        callback()
    else
        LuaTimer.Add(400, callback)
    end

    if self.itemInitFlag then
        self:ReloadData()
    end
    -- self:DealExtraEffect()
end

function WarOrderRewardPanel:OnHide()
    self:RemoveListeners()
end

function WarOrderRewardPanel:AddListeners()
    self.mgr.updateWarOrderEvent:AddListener(self._update_load_listener)
    self.mgr.updateWarOrderHasGetEvent:AddListener(self._update_load_listener)
end

function WarOrderRewardPanel:RemoveListeners()
    self.mgr.updateWarOrderEvent:RemoveListener(self._update_load_listener)
    self.mgr.updateWarOrderHasGetEvent:RemoveListener(self._update_load_listener)
end

--更新界面数据
function WarOrderRewardPanel:ReloadData()
    local data = DataCampWarOrder.data_reward
    local count = 0
    for lev, v in ipairs(data) do
        count = count + 1
        local item = self.itemList[count] 
        if item ~= nil then 
            item:SetData(v)
        end
    end
    
    self.redObj:SetActive(self.model:GetWarOrderRedStatus())

    if self.model:GetHighLevelWarStatus() then 
        self.lockBtn.gameObject:SetActive(false)
        self.buyBtn.gameObject:SetActive(false)
    else
        self.lockBtn.gameObject:SetActive(true)
        self.buyBtn.gameObject:SetActive(true)
    end

    self:OnRectScroll()
end

--解锁
function WarOrderRewardPanel:OnLockBuyClick()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warorderbuywindow)
end

--打开奖励总览界面
function WarOrderRewardPanel:OnRewardPreviewClick()
    -- WindowManager.Instance:CloseWindowById(WindowConfig.WinID.warorderwindow)
    self.model:OpenWarOrderPreviewPanel()
end

--一键领取
function WarOrderRewardPanel:OnQuickObtainClick()
    self.mgr:Send20490()
end

function WarOrderRewardPanel:OnRectScroll()
    --进入下一阶段的条件
    local val = - self.container.anchoredPosition.x
    local index = #self.special_lev
    for i, v in ipairs(self.special_lev) do
        if val < ((v * 80) - 341.8) then 
            index = i
            break
        end
    end
    if index ~= self.last_index then 
        local data = DataCampWarOrder.data_reward[self.special_lev[index]]
        self.endListItem:SetData(data)
    
        local descItemId = data[2].reward[1][1]
        local itemData = DataItem.data_get[descItemId]

        self.rewardIconLoader:SetSprite(SingleIconType.Other, self.special_item[index])
        self.rewardNameTxt.text = ColorHelper.color_item_name(itemData.qualify, itemData.name)
        self.rewardDescTxt.text = self.special_desc[index]

        self.last_index = index
    end

    --特效处理
    self:DealExtraEffect()    
end


-- --打开礼包
-- function WarOrderRewardPanel:ShowGift(gift_id)
--     -- print("打开礼包内容,gift_id:" .. gift_id)
--     local gift_list = DataItemGift.data_show_gift_list[gift_id]
    
--     local callBack = function(myself) myself.gameObject.transform.localPosition = Vector3(myself.gameObject.transform.localPosition.x,myself.gameObject.transform.localPosition.y,200) end

--     if self.possibleReward == nil then
--         self.possibleReward = SevenLoginTipsPanel.New(self,callBack)
--     end
--     self.possibleReward:Show({CampaignManager.ItemFilterForItemGift(gift_list),4,{140,140,120,120},TI18N("可获得以下道具")})
-- end

--处理特效
function WarOrderRewardPanel:DealExtraEffect()
    local delta1 = 10
    local delta2 = 10
    
    local scrollRect = self.scroll
    local container = scrollRect.content

    local a_side = -container.anchoredPosition.x
    local b_side = a_side + scrollRect.transform.sizeDelta.x

    local a_xy, s_xy = 0, 0
    for k, v in pairs(self.itemList) do
        a_xy = v.gameObject.transform.anchoredPosition.x + delta1
        s_xy = v.gameObject.transform.sizeDelta.x - delta1 - delta2

        v:ShowEffect(a_xy > a_side and a_xy + s_xy < b_side)
    end
end

--重写show，hiden方法,创建太多item，优化卡顿
function WarOrderRewardPanel:Show(arge)
    if self.loading then
        return
    end
    self.openArgs = arge
    if self.gameObject ~= nil then
        self.loading = false
        self.gameObject.transform.localScale = Vector3(1,1,1)
        -- self.gameObject:SetActive(true)
        if self.scroll ~= nil then
            self.scroll.enabled = true
        end
        self.OnOpenEvent:Fire()
    else
        -- 如果有资源则加载资源，否则直接调用初始化接口
        self.loading = true
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function WarOrderRewardPanel:Hiden()
    if self.gameObject ~= nil then
        if self.scroll ~= nil then 
            self.scroll.enabled = false
        end
        self.gameObject.transform.localScale = Vector3(0, 0, 0)
        -- self.gameObject:SetActive(false)
        self.OnHideEvent:Fire()
    end
end


