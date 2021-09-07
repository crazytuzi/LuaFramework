-- @author 111
-- @date 2018年3月13日,星期二

AprilTurnRewardWindow = AprilTurnRewardWindow or BaseClass(BaseWindow)

function AprilTurnRewardWindow:__init(model)
    self.model = model
    self.name = "AprilTurnRewardWindow"
    self.windowId = WindowConfig.WinID.AprilReward_win
    self.resList = {
        {file = AssetConfig.aprilReward_win, type = AssetType.Main}
    }

    self._SetData = function()
        self:SetData()
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.rewardList = { }
end

function AprilTurnRewardWindow:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function AprilTurnRewardWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.aprilReward_win))
    self.gameObject.name = "AprilTurnRewardWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject,self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)


    self.ShowText = self.transform:Find("MainCon/ShowText"):GetComponent(Text)

    self.Container = self.transform:Find("MainCon/FashionScrollRect/FashionContainer")

    self.Item = self.transform:Find("MainCon/FashionScrollRect/FashionContainer/Item")
    self.Item.gameObject:SetActive(false)
    --self.littleLuaBox = LuaBoxLayout.New(self.littleContainer,{axis = BoxLayoutAxis.X, cspacing = 0, border = 10})

    self.scrollRect = self.transform:Find("MainCon/FashionScrollRect"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function()
        self:OnRectScroll()
    end)

    self.LuaBox = LuaBoxLayout.New(self.Container,{axis = BoxLayoutAxis.Y, cspacing = 0, border = 1})

    local TurnRewardList = DataZillionaireData.data_get_ring_reward
    if TurnRewardList ~= nil and next(TurnRewardList) ~= nil then
        for i = 1, #TurnRewardList do
            if self.rewardList[i] == nil then
                local tab = {}
                local go = GameObject.Instantiate(self.Item.gameObject)
                tab.gameObject = go
                tab.slot = { }
                for k =1, #TurnRewardList[i].rewards do
                    tab.slot[k] =ItemSlot.New(go.transform:Find("ItemSlot"..k).gameObject)
                end

                for k = #TurnRewardList[i].rewards + 1 , 3 do
                    go.transform:Find("ItemSlot"..k).gameObject:SetActive(false)
                end

                if #TurnRewardList[i].rewards == 1 then
                    tab.slot[1].gameObject.transform.localPosition = Vector3(-3.1, -39.5, 0)
                elseif #TurnRewardList[i].rewards == 2 then
                    tab.slot[1].gameObject.transform.localPosition = Vector3(-36, -39.5, 0)
                    tab.slot[2].gameObject.transform.localPosition = Vector3(30, -39.5, 0)
                end

                tab.logo = go.transform:Find("Text"):GetComponent(Text)
                tab.ButtonImage = go.transform:Find("GetBtn"):GetComponent(Image)
                tab.Button = go.transform:Find("GetBtn"):GetComponent(Button)
                tab.ButtonText = go.transform:Find("GetBtn/Text"):GetComponent(Text)

                self.rewardList[i] = tab
            end
            self.LuaBox:AddCell(self.rewardList[i].gameObject)
        end
    end
end

function AprilTurnRewardWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function AprilTurnRewardWindow:OnOpen()
    self:AddListeners()
    self:SetData()
end

function AprilTurnRewardWindow:OnHide()
    self:RemoveListeners()
end

function AprilTurnRewardWindow:AddListeners()
    self:RemoveListeners()

    AprilTreasureManager.Instance.OnFirstDataUpdate:AddListener(self._SetData)
end

function AprilTurnRewardWindow:RemoveListeners()
    AprilTreasureManager.Instance.OnFirstDataUpdate:RemoveListener(self._SetData)
end

function AprilTurnRewardWindow:OnClose()
end

function AprilTurnRewardWindow:SetData()

    --设置底部信息
    self.ShowText.text = string.format(TI18N("前进<color=#ffff00>%d</color>步即可完成第<color=#ffff00>%d</color>圈"),35 - self.model.CurrPos,self.model.TurnTimes + 1)
    self.ShowText.gameObject:SetActive(true)

    local TurnRewardList = DataZillionaireData.data_get_ring_reward
    for i,v in pairs(TurnRewardList) do
        self.rewardList[i].logo.text = string.format(TI18N("轮回%s次"),v.times)
        for j,k in pairs(v.rewards) do
            local info = ItemData.New()
            local base = DataItem.data_get[k[1]]
            info:SetBase(base)
            info.bind = k[2]
            info.quantity = k[3]
            self.rewardList[i].slot[j]:SetAll(info, {inbag = false, nobutton = true})
        end
    end

    local ReceivedList = self.model.ReceivedTurnTimes
    for i,v in pairs(TurnRewardList) do
        local hasGet = false
        for _, receive in pairs(ReceivedList) do
            if v.times == receive.times then
                hasGet = true
            end
        end

        if hasGet then
            --已领取
            self.rewardList[i].ButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.rewardList[i].ButtonText.color = ColorHelper.DefaultButton4
            self.rewardList[i].ButtonText.text = TI18N("已领取")
            self.rewardList[i].Button.onClick:RemoveAllListeners()
            self.rewardList[i].Button.onClick:AddListener(function() print("已领取") AprilTreasureManager.Instance:send20448(v.times) end)
        else
            --未领取（未达成 和 可领取）
            if self.model.TurnTimes >= v.times then
                --可领取
                self.rewardList[i].ButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                self.rewardList[i].ButtonText.color = ColorHelper.DefaultButton3
                self.rewardList[i].ButtonText.text = TI18N("领取")
                self.rewardList[i].Button.onClick:RemoveAllListeners()
                self.rewardList[i].Button.onClick:AddListener(function() AprilTreasureManager.Instance:send20448(v.times) end)
            elseif self.model.TurnTimes < v.times then
                --未达成
                self.rewardList[i].ButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                self.rewardList[i].ButtonText.color = ColorHelper.DefaultButton4
                self.rewardList[i].ButtonText.text = TI18N("未达成")
                self.rewardList[i].Button.onClick:RemoveAllListeners()
                self.rewardList[i].Button.onClick:AddListener(function() print("未达成") AprilTreasureManager.Instance:send20448(v.times)  end)
            end
        end
    end
end

function AprilTurnRewardWindow:OnRectScroll(value)
end

