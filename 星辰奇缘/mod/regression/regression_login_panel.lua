-- ----------------------------------------------------------
-- UI - 老玩家回归窗口 回归登陆面板
-- ----------------------------------------------------------
RegressionLoginPanel = RegressionLoginPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

function RegressionLoginPanel:__init(parent, parentContainer)
	self.parent = parent
    self.model = parent.model
    self.parentContainer = parentContainer
    self.name = "RegressionLoginPanel"
    self.resList = {
        {file = AssetConfig.regression_panel1, type = AssetType.Main}
        , {file = AssetConfig.bigatlas_regression2, type = AssetType.Main}
        , {file = AssetConfig.regression_textures, type = AssetType.Dep}
        , {file = AssetConfig.doubleeleven_res, type = AssetType.Dep}
        , {file = AssetConfig.bible_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.item_list = {}
    self.timerId = nil
    ------------------------------------------------
    self._update = function()
        self:update()
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function RegressionLoginPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.regression_panel1))
    self.gameObject.name = "RegressionLoginPanel"
    self.gameObject.transform:SetParent(self.parentContainer.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    -----------------------------------------
    local transform = self.transform
    UIUtils.AddBigbg(transform:Find("Regression"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_regression2)))


    -- 按钮功能绑定
    local btn
    -- self.okBtuuton = transform:FindChild("BindText"):GetComponent(Button)
    -- self.okBtuuton.onClick:AddListener(function() self:OnOkButton() end)

    -----------------------------------------
    self.cloneItem = self.transform:FindChild("CloneItem").gameObject
    self.cloneItem:SetActive(false)
    self.container = self.transform:FindChild("Panel/Container")

    self.transform:FindChild("Panel"):GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChanged() end)

    -- local itemSlot = ItemSlot.New()
    -- UIUtils.AddUIChild(self.transform:FindChild("Item"), itemSlot.gameObject)
    -- local itembase = BackpackManager.Instance:GetItemBase(DataFriend.data_get_reward[0].reward[1][1])
    -- local itemData = ItemData.New()
    -- itemData:SetBase(itembase)
    -- itemData.quantity = DataFriend.data_get_reward[0].reward[1][2]
    -- itemSlot:SetAll(itemData)

    -- self.rewardButton = self.transform:FindChild("RewardButton")
    -- self.rewardButton:GetComponent(Button).onClick:AddListener(function() self:OnOkButton() end)

    self.transform:FindChild("DescText"):GetComponent(Text).text = TI18N("每日登陆<color='#00ff00'>免费奖励</color>等你拿，更有<color='#00ff00'>限时优惠礼包</color>机会难得！")
    -----------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function RegressionLoginPanel:__delete()
    for k,v in pairs(self.item_list) do
        v:DeleteMe()
        v = nil
    end

    self:OnHide()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.effect ~= nil then
        self.effect:DeleteMe()
    end

    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RegressionLoginPanel:OnShow()
    self:update()

    RegressionManager.Instance.loginUpdate:Add(self._update)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 1000, function() self:OnTimer() end)
end

function RegressionLoginPanel:OnHide()
    RegressionManager.Instance.loginUpdate:Remove(self._update)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.model:CloseGiftPreview()
end

function RegressionLoginPanel:update()
    -- self.sevenDayMark = true
    local returnDay = math.modf(BaseUtils.LocalTime(self.model.login_time_return) / 86400)
    local nowDay = math.modf(BaseUtils.LocalTime(BaseUtils.BASE_TIME) / 86400)
    
    local roleData = RoleManager.Instance.RoleData
    for i=1, 7 do 
        local item = self.item_list[i]
        if item == nil then
            local go = GameObject.Instantiate(self.cloneItem)
            go:SetActive(true)
            go.transform:SetParent(self.container)
            go:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)

            item = RegressionLoginItem.New(go, self)
            table.insert(self.item_list, item)
        end

        local data = nil
        for j=1, #DataFriend.data_get_reward do
            local reward = DataFriend.data_get_reward[j]
            if i == reward.day and roleData.lev >= reward.min and roleData.lev <= reward.max then
                data = BaseUtils.copytab(reward)
            end
        end
        data.receive = self.model.logins[i]
        data.time = self.model.loginsTime[i]
        -- if data.receive ~= 2 then
        --     self.sevenDayMark = false
        -- end
        if i == nowDay - returnDay + 1 then
            data.today = true
        end
        data.buy = self.model.limits[i]
        data.nowDay = nowDay

        item:update_my_self(data, i)
    end

    -- if self.sevenDayMark then
    -- if self.model.flag == 1 then
    --     self.rewardButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")

    --     if self.effect == nil then
    --         local fun = function(effectView)
    --             local effectObject = effectView.gameObject

    --             effectObject.transform:SetParent(self.rewardButton)
    --             effectObject.transform.localScale = Vector3(1.3, 0.58, 1)
    --             effectObject.transform.localPosition = Vector3(-42, -12.5, -1000)
    --             effectObject.transform.localRotation = Quaternion.identity

    --             Utils.ChangeLayersRecursively(effectObject.transform, "UI")

    --             self.effect = effectView
    --         end
    --         self.effect = BaseEffectView.New({effectId = 20053, time = nil, callback = fun})
    --     else
    --         self.effect:SetActive(true)
    --     end
    -- else
    --     self.rewardButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")

    --     if self.effect ~= nil then
    --         self.effect:SetActive(false)
    --     end
    -- end
end

function RegressionLoginPanel:OnOkButton()
    -- if self.sevenDayMark then
    if self.model.flag == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("需连续登陆满7天才能领取哦~"))
        return
    elseif self.model.flag == 2 then    
        NoticeManager.Instance:FloatTipsByString(TI18N("领过啦"))
        return
    end
    RegressionManager.Instance:Send9939(0)
end

function RegressionLoginPanel:ItemOkButtonClick(gameObject)
    local day = tonumber(gameObject.name)
    if self.model.logins[day] then
        if day ~= 7 then
            RegressionManager.Instance:Send9939(day)
        else
            self.model:OpenPracSkillChestbox()
        end
    end
end

function RegressionLoginPanel:ItemBuyButtonClick(gameObject, num)
    local day = tonumber(gameObject.name)
    if self.model.limits[day] == 5 then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经买过了"))
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("是否消耗{assets_1, 90002, %s}购买今日登陆限时优惠礼包？"), num)
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() RegressionManager.Instance:Send9942(tonumber(gameObject.name)) end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function RegressionLoginPanel:OnTimer()
    for i=1, #self.item_list do 
        self.item_list[i]:OnTimer()
    end
end

function RegressionLoginPanel:OnValueChanged()
    for i=1, #self.item_list do
        local item = self.item_list[i]
        item:OnValueChanged()
    end
end
