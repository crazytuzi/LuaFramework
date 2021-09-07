RegressionLoginChestboxView = RegressionLoginChestboxView or BaseClass(BaseWindow)

function RegressionLoginChestboxView:__init(model)
    self.model = model
    self.name = "RegressionLoginChestboxView"
    self.windowId = WindowConfig.WinID.chest_box_win
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.regressionloginchestboxwindow, type = AssetType.Main}
        , {file = AssetConfig.arena_textures, type = AssetType.Dep}
        , {file = AssetConfig.national_day_res, type = AssetType.Dep}
        , {file = AssetConfig.midAutumn_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------
    self.is_open = false
    self.MainCon = nil
    self.MidCon = nil
    self.Item = nil
    self.ImgConfirmBtn = nil

    self.item_list = nil
    self.run_type = 0
    self.total_count = 1
    self.ttime = 0.4
    self.result_idx = nil

    self.count_add = 0
    self.index_count = 1
    self.total_item_num = 18
    self.reward_index = nil
    self.notify_scroll_msg = nil
    self.last_item = nil

    self.noticeList = {}
    self.noticeIndex = 1
    self.hasNoticeStart = false

    self.itemSlotList = {}
    self.itemSlotList2 = {}
	------------------------------------------------

    ------------------------------------------------
    self._chestbox_update = function(result_index, notify_scroll_msg)
        self:chestbox_update(result_index, notify_scroll_msg)
    end
    self._ShowNotice = function(isInit)
        self:ShowNotice(isInit)
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function RegressionLoginChestboxView:__delete()
    self:OnHide()

    for k,v in pairs(self.itemSlotList) do
        v:DeleteMe()
        v = nil
    end
    for k,v in pairs(self.itemSlotList2) do
        v:DeleteMe()
        v = nil
    end

    for i,v in ipairs(self.noticeList) do
        v:DeleteMe()
    end
    self.noticeList = nil

    if self.run_type ~= 3 then
        RegressionManager.Instance:Send9941()
    end
    self.is_open = false
    if self.model.chest_box_data ~= nil and self.model.chest_box_data.has_get == nil then
        RegressionManager.Instance:Send9940()
    else
        if self.notify_scroll_msg ~= nil then
            NoticeManager.Instance:FloatTipsByString(self.notify_scroll_msg)
            self.notify_scroll_msg = nil
        end
    end
    self.last_item = nil
    self.result_idx = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RegressionLoginChestboxView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.regressionloginchestboxwindow))
    self.gameObject.name = "RegressionLoginChestboxView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.MainCon = self.transform:FindChild("MainCon").gameObject
    self.MidCon = self.MainCon.transform:Find("MidCon").gameObject

    self.closeBtn = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.ImgConfirmBtn = self.MainCon.transform:Find("ImgConfirmBtn").gameObject
    self.ImgConfirmBtn:GetComponent(Button).onClick:AddListener(function() self:on_click_confirm_btn() end)
    self.ImgConfirmBtn:SetActive(false)

    self.MainCon.transform:Find("Desc"):GetComponent(Text).text = TI18N("点击<color='#ffff00'>开始抽奖</color>惊喜等着你！\n<color='#ffff00'>回归登陆</color>免费道具很给力！")

    local notice = self.MainCon.transform:Find("Reward/Mask")
    local len = notice.childCount
    for i = 1, len do
        local item = RegressionLoginChestboxNoticeItem.New(notice:GetChild(i - 1).gameObject, function() self:NoticeNext() end)
        table.insert(self.noticeList, item)
    end
    ---------------------------------------------
    self:OnShow()
end

function RegressionLoginChestboxView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function RegressionLoginChestboxView:OnShow()
    self.is_open = true

    RegressionManager.Instance:Send9944()

    self:update_view()

    RegressionManager.Instance.luckDrawUpdate:Add(self._chestbox_update)
    RegressionManager.Instance.luckDrawRollNoticeUpdate:Add(self._ShowNotice)

    self:ShowNotice()
end

function RegressionLoginChestboxView:OnHide()
    RegressionManager.Instance.luckDrawUpdate:Remove(self._chestbox_update)
    RegressionManager.Instance.luckDrawRollNoticeUpdate:Remove(self._ShowNotice)

    for i,v in ipairs(self.noticeList) do
        v:Reset()
    end
    self.hasNoticeStart = false
end

--更新界面列表
function RegressionLoginChestboxView:update_view()
    if self.is_open == false then
        return
    end

    for k,v in pairs(self.itemSlotList) do
        v:DeleteMe()
        v = nil
    end

    local data_list = {}

    for i = 1, #DataFriend.data_get_reward_draw do
        table.insert(data_list, DataFriend.data_get_reward_draw[i].reward_client[1])
    end

    self.item_list = {}
    for i = 1, #data_list do
        local data = data_list[i]
        local item = self:create_item(self.MidCon.transform:Find(tostring(i)).gameObject)
        self:set_item_data(item, data)
        table.insert(self.item_list, item)
    end

    self.ImgConfirmBtn:SetActive(true)
end

--抽取结果返回
function RegressionLoginChestboxView:result_back(result_index)
    if self.is_open == false then
        return
    end

    self.result_idx = result_index
    --走五秒五秒后没有点确定就
    self.run_type = 1
    self.total_count = 1
    self:run_wait()
end


--确定按钮监听
function RegressionLoginChestboxView:on_click_confirm_btn(g)
    RegressionManager.Instance:Send9940()

    local fun = function()
        self.ImgConfirmBtn:GetComponent(Image).color = Color.grey
        -- self.ImgConfirmBtn.transform:Find("Image"):GetComponent(Image).color = Color.grey
        self.ImgConfirmBtn:GetComponent(Button).enabled = false

        self:play_random_effect(self.result_idx)
    end

    self.ImgConfirmBtn.gameObject.transform.localScale = Vector3(1.3,1.2,1)
    Tween.Instance:Scale(self.ImgConfirmBtn.gameObject, Vector3(1,1,1), 1.2, fun, LeanTweenType.easeOutElastic)
end

function RegressionLoginChestboxView:play_random_effect(index)
    if self.is_open == false then
        return
    end

    self.reward_index = index --第八个是中奖
end

function RegressionLoginChestboxView:run_wait()
    if self.is_open == false then
        return
    end

    self.index_count = self.index_count%self.total_item_num
    self.index_count = self.index_count == 0 and self.total_item_num or self.index_count
    self:set_selected_state(self.item_list[self.index_count], true)

    if self.run_type == 1 then
        self.total_count = self.total_count + self.ttime/10

        if self.total_count >= 2 and self.reward_index == nil then
            self.total_count = 1
            -- self:on_click_confirm_btn()
            self:play_random_effect(self.result_idx)
        elseif self.index_count == self.reward_index then
            self.ttime = 0.4
            self.count_add = 0
            local circle = 1 --utils.random_by_list({2, 3}) --随机转几圈
            self.count_add = (1.8 - self.ttime)/(circle*self.total_item_num)
            self.run_type = 2
        end
        self.index_count = self.index_count + 1
        LuaTimer.Add(self.ttime / 10 * 1000, function() self:run_wait() end)

    elseif self.run_type == 2 then
        self.ttime = self.ttime + self.count_add

        if self.index_count == self.reward_index then
            self.ttime = 0.4
            self.count_add = 0

            if self.notify_scroll_msg ~= nil then
                NoticeManager.Instance:FloatTipsByString(self.notify_scroll_msg)
                self.notify_scroll_msg = nil
            end
            LuaTimer.Add(50, function() RegressionManager.Instance:Send9941() end)
            self.notify_scroll_msg = nil
            self.total_count = 0
            self.run_type = 3
            LuaTimer.Add(1000, function() self:run_wait() end)
        else
            self.index_count = self.index_count + 1
            LuaTimer.Add(self.ttime / 5 * 1000, function() self:run_wait() end)
        end
    elseif self.run_type == 3 then
        -- self.total_count = self.total_count + 1
        -- if self.total_count >= 3 then
        --     self.total_count = 1
        --     -- self:close_my_self()
        -- else
        --     LuaTimer.Add(1000, function() self:run_wait() end)
        -- end

        self.item_list[self.index_count].Got:SetActive(true)
        self.item_list[self.index_count].ItemSlot:SetGrey(true)

        self:ShowRewardPanel()
    end
end

--创建新的item
function RegressionLoginChestboxView:create_item(itemObject)
    local item = {}
    item.go = itemObject
    item.go:SetActive(true)

    item.SlotItemCon = item.go.transform:FindChild("SlotItemCon").gameObject
    item.ImgSelect = item.go.transform:FindChild("ImgSelect").gameObject
    item.ImgSelect:SetActive(false)
    item.Got = item.go.transform:FindChild("Got").gameObject
    item.go.transform:FindChild("Mask").gameObject:SetActive(false)

    return item
end

--设置item的data
function RegressionLoginChestboxView:set_item_data(item, data)
    local equipSlot = ItemSlot.New()
    UIUtils.AddUIChild(item.SlotItemCon, equipSlot.gameObject)
    local itemData = ItemData.New()
    itemData:SetBase(BackpackManager.Instance:GetItemBase(data[1]))
    itemData.quantity = data[2]
    equipSlot:SetAll(itemData, {nobutton = true})
    -- equipSlot:SetNotips(false)
    equipSlot.gameObject:AddComponent(TransitionButton)

    item.data = itemData
    item.ItemSlot = equipSlot

    if DataFriend.data_get_recalled_effect[data[1]] then
        local fun = function(effectView)
            local effectObject = effectView.gameObject
            effectObject.transform:SetParent(equipSlot.transform)
            effectObject.name = "Effect"
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localPosition = Vector3.zero
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        end
        BaseEffectView.New({effectId = 20223, callback = fun})
    end

    table.insert(self.itemSlotList, equipSlot)
end

--设置选中状态
function RegressionLoginChestboxView:set_selected_state(item, state)
    if self.last_item ~= nil then
        self.last_item.ImgSelect:SetActive(false)
    end
    item.ImgSelect:SetActive(state)
    self.last_item = item
end

--关掉自己
function RegressionLoginChestboxView:close_my_self(g)
    if self.is_open == false then
        return
    end

    print("Close ui_chest_box_win")
    -- self.model:ClosePracSkillChestbox()
    WindowManager.Instance:CloseWindow(self)
end

function RegressionLoginChestboxView:chestbox_update(result_index, notify_scroll_msg)
    if result_index ~= nil then
        self:result_back(result_index)
    end

    if notify_scroll_msg ~= nil then
        self.notify_scroll_msg = notify_scroll_msg
    end
end

function RegressionLoginChestboxView:ShowNotice()
    if #RegressionManager.Instance.model.rainbow_notice_list == 0 then
        return
    end

    if self.hasNoticeStart then
        return
    end

    self.hasNoticeStart = true
    self:NoticeNext()
end

function RegressionLoginChestboxView:NoticeNext()
    local notice = self.noticeList[self.noticeIndex]
    self.noticeIndex = self.noticeIndex + 1
    if self.noticeIndex >= #self.noticeList then
        self.noticeIndex = 1
    end
    notice:Run()
end




----------------------------------------------
function RegressionLoginChestboxView:ShowRewardPanel()
    for k,v in pairs(self.itemSlotList2) do
        v:DeleteMe()
        v = nil
    end

    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(self.gameObject.transform)
        effectObject.name = "Effect"
        effectObject.transform.localScale = Vector3.one
        effectObject.transform.localPosition = Vector3(0, 0, -400)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    end
    BaseEffectView.New({effectId = 20152, callback = fun})

    local rewardPanel = self.transform:FindChild("RewardPanel").gameObject
    rewardPanel:SetActive(true)

    rewardPanel.transform:Find("MainCon").localPosition = Vector3(0, 0, -100)
    local closeBtn = rewardPanel.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function() self:HideRewardPanel() end)

    rewardPanel.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:HideRewardPanel() end)
    rewardPanel.transform:FindChild("MainCon/OkButton"):GetComponent(Button).onClick:AddListener(function() self:HideRewardPanel() end)

    local item1 = rewardPanel.transform:FindChild("MainCon/Item1")
    local item2 = rewardPanel.transform:FindChild("MainCon/Item2")
    local item3 = rewardPanel.transform:FindChild("MainCon/Item3")
    local item4 = rewardPanel.transform:FindChild("MainCon/Item4")

    local rewardData1 = DataFriend.data_get_reward_draw[self.result_idx].reward_client[1]

    local itembase = BackpackManager.Instance:GetItemBase(rewardData1[1])
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.quantity = rewardData1[2]
    local itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(item1, itemSlot.gameObject)
    itemSlot:SetAll(itemData, {nobutton = true})
    table.insert(self.itemSlotList2, itemSlot)

    if DataFriend.data_get_recalled_effect[rewardData1[1]] then
        local fun = function(effectView)
            local effectObject = effectView.gameObject
            effectObject.transform:SetParent(itemSlot.transform)
            effectObject.name = "Effect"
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localPosition = Vector3.zero
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        end
        BaseEffectView.New({effectId = 20223, callback = fun})
    end

    item1.transform:FindChild("Text"):GetComponent(Text).text = itemData.name

    local rewardData2 = nil
    local roleData = RoleManager.Instance.RoleData
    if roleData.lev >= 50 and roleData.lev <= 59 then
        rewardData2 = {22243,1}
    elseif roleData.lev >= 60 and roleData.lev <= 69 then
        rewardData2 = {22244,1}
    elseif roleData.lev >= 70 and roleData.lev <= 79 then
        rewardData2 = {22244,1}
    elseif roleData.lev >= 80 and roleData.lev <= 999 then
        rewardData2 = {22246,1}
    end

    itembase = BackpackManager.Instance:GetItemBase(rewardData2[1])
    itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.quantity = rewardData2[2]
    itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(item2, itemSlot.gameObject)
    itemSlot:SetAll(itemData, {nobutton = true})
    table.insert(self.itemSlotList2, itemSlot)

    if DataFriend.data_get_recalled_effect[rewardData2[1]] then
        local fun = function(effectView)
            local effectObject = effectView.gameObject
            effectObject.transform:SetParent(itemSlot.transform)
            effectObject.name = "Effect"
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localPosition = Vector3.zero
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        end
        BaseEffectView.New({effectId = 20223, callback = fun})
    end

    item2.transform:FindChild("Text"):GetComponent(Text).text = itemData.name

    local rewardData3 = {20505,2}
    itembase = BackpackManager.Instance:GetItemBase(rewardData3[1])
    itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.quantity = rewardData3[2]
    itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(item3, itemSlot.gameObject)
    itemSlot:SetAll(itemData, {nobutton = true})
    table.insert(self.itemSlotList2, itemSlot)

    if DataFriend.data_get_recalled_effect[rewardData3[1]] then
        local fun = function(effectView)
            local effectObject = effectView.gameObject
            effectObject.transform:SetParent(itemSlot.transform)
            effectObject.name = "Effect"
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localPosition = Vector3.zero
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        end
        BaseEffectView.New({effectId = 20223, callback = fun})
    end

    item3.transform:FindChild("Text"):GetComponent(Text).text = itemData.name

    local rewardData4 = {20076,1}
    itembase = BackpackManager.Instance:GetItemBase(rewardData4[1])
    itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.quantity = rewardData4[2]
    itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(item4, itemSlot.gameObject)
    itemSlot:SetAll(itemData, {nobutton = true})
    table.insert(self.itemSlotList2, itemSlot)

    if DataFriend.data_get_recalled_effect[rewardData4[1]] then
        local fun = function(effectView)
            local effectObject = effectView.gameObject
            effectObject.transform:SetParent(itemSlot.transform)
            effectObject.name = "Effect"
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localPosition = Vector3.zero
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        end
        BaseEffectView.New({effectId = 20223, callback = fun})
    end

    item4.transform:FindChild("Text"):GetComponent(Text).text = itemData.name
end

function RegressionLoginChestboxView:HideRewardPanel()
    -- self.transform:FindChild("RewardPanel").gameObject:SetActive(false)
    self:OnClickClose()
end