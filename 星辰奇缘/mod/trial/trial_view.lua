---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
-- 策划一拍脑袋说要改界面，随时可能再拍一下改回来，旧代码整段注释掉
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

-- -- 极寒试炼界面
-- TrialView = TrialView or BaseClass(BaseWindow)

-- local GameObject = UnityEngine.GameObject
-- local Vector2 = UnityEngine.Vector2

-- function TrialView:__init(model)
--     self.model = model
--     self.name = "TrialView"
--     self.windowId = WindowConfig.WinID.trialwindow
--     self.winLinkType = WinLinkType.Link
--     self.cacheMode = CacheMode.Visible

--     self.resList = {
--         {file = AssetConfig.trialwindow, type = AssetType.Main}
--         , {file = AssetConfig.trial_textures, type = AssetType.Dep}
--         , {file = AssetConfig.number_icon_13, type = AssetType.Dep}
--         , {file = AssetConfig.number_icon_str, type = AssetType.Dep}
--     }

--     self.gameObject = nil
--     self.transform = nil

--     ------------------------------------------------
--     self.transform = nil
--     self.Button3 = nil
--     self.number1 = nil
--     self.number2 = nil
--     self.show = false
--     ------------------------------------------------
--     self._update = function()
--         self:update()
--     end
--     ------------------------------------------------

--     self.OnOpenEvent:Add(function() self:OnShow() end)
--     self.OnHideEvent:Add(function() self:OnHide() end)
-- end

-- function TrialView:__delete()
--     if self.gameObject ~= nil then
--         GameObject.DestroyImmediate(self.gameObject)
--         self.gameObject = nil
--     end
--     self:AssetClearAll()
-- end

-- function TrialView:InitPanel()
--     self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.trialwindow))
--     self.gameObject.name = "TrialView"
--     UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

--     self.transform = self.gameObject.transform
--     local transform = self.transform

--     local closeBtn = transform:FindChild("Main/CloseButton"):GetComponent(Button)
--     closeBtn.onClick:AddListener(function() self:OnClickClose() end)

--     local btn = transform:Find("Main/OkButtom"):GetComponent(Button)
--     btn.onClick:AddListener( function() self:GoTrial() end )

--     btn = transform:Find("Main/ResetButtom"):GetComponent(Button)
--     btn.onClick:AddListener( function() self:ResetTrial() end )

--     btn = transform:Find("Reset/Button1"):GetComponent(Button)
--     btn.onClick:AddListener( function() self:ResetButton1() end )

--     self.Button2 = transform:Find("Reset/Button2").gameObject
--     self.Button2:GetComponent(Button).onClick:AddListener( function() self:ResetButton2() end )

--     self.Button3 = transform:Find("Reset/Button3").gameObject
--     self.Button3:GetComponent(Button).onClick:AddListener( function() self:ResetButton3() end )

--     self.number1 = transform:FindChild("Main/Level/Number/Number1"):GetComponent(Image)
--     self.number2 = transform:FindChild("Main/Level/Number/Number2"):GetComponent(Image)

--     -------------------------------------------------------------
--     self:OnShow()
--     self:ClearMainAsset()
-- end

-- function TrialView:OnClickClose()
--     WindowManager.Instance:CloseWindow(self)
-- end

-- function TrialView:OnShow()
--     EventMgr.Instance:AddListener(event_name.trial_update, self._update)
--     self:update()
-- end

-- function TrialView:OnHide()
--     EventMgr.Instance:RemoveListener(event_name.trial_update, self._update)
-- end

-- function TrialView:update()
--     if self.model.mode == 0 then
--         self.transform.transform:Find("Main").gameObject:SetActive(false)
--         self.transform.transform:Find("Reset").gameObject:SetActive(true)
--         if self.model.clear_normal == 1 then
--             self.Button2:SetActive(true)
--             self.Button3:SetActive(false)
--         else
--             self.Button2:SetActive(false)
--             self.Button3:SetActive(true)
--         end
--     else
--         self.transform.transform:Find("Main").gameObject:SetActive(true)
--         self.transform.transform:Find("Reset").gameObject:SetActive(false)
--         if self.model.mode == 1 then
--             self.transform.transform:Find("Main/Lable1").gameObject:SetActive(true)
--             self.transform.transform:Find("Main/Lable2").gameObject:SetActive(false)
--         elseif self.model.mode == 2 then
--             self.transform.transform:Find("Main/Lable1").gameObject:SetActive(false)
--             self.transform.transform:Find("Main/Lable2").gameObject:SetActive(true)
--         end

--         self.transform.transform:Find("Main/RoundText"):GetComponent(Text).text = tostring(self.model.round)
--         self.transform.transform:Find("Main/MoneyText"):GetComponent(Text).text = tostring(self.model.coin)
--         self.transform.transform:Find("Main/TimesText"):GetComponent(Text).text = string.format("%s/%s", self.model.times, self.model.max_times)

--         self.transform.transform:Find("Main/NumText"):GetComponent(Text).text = tostring(self.model.reset)

--         local order = self.model.order
--         if order < self.model.direct_order then
--             order = self.model.direct_order
--         end

--         if DataTrial.data_trial_data[order] ~= nil then
--             order = tonumber(DataTrial.data_trial_data[order].order_desc) - 1
--         else
--             order = math.floor(order / 2)
--         end

--         if order < 10 then
--             self.number1.sprite = self.assetWrapper:GetSprite(AssetConfig.number_icon_13, string.format("Num13_%s", order))
--             self.number2.gameObject:SetActive(false)
--         else
--             self.number2.gameObject:SetActive(true)
--             self.number1.sprite = self.assetWrapper:GetSprite(AssetConfig.number_icon_13, string.format("Num13_%s", math.floor(order/10)))
--             self.number2.sprite = self.assetWrapper:GetSprite(AssetConfig.number_icon_13, string.format("Num13_%s", math.floor(order%10)))
--         end
--     end
-- end

-- function TrialView:ResetButton1()
--    TrialManager.Instance:Send13101(1)
--    self:OnClickClose()
-- end

-- function TrialView:ResetButton2()
--    TrialManager.Instance:Send13101(2)
--    self:OnClickClose()
-- end

-- function TrialView:ResetButton3()
--    NoticeManager.Instance:FloatTipsByString("通关普通难度后开放")
-- end

-- function TrialView:GoTrial()
--    print("GoTrial")
--    if self.model.times > 0 then
--        if DataTrial.data_trial_data[self.model.order] ~= nil then
--            TrialManager.Instance:Send13101(self.model.mode)
--            self:OnClickClose()
--         elseif self.model.reset > 0 then
--             TrialManager.Instance:Send13103()
--             NoticeManager.Instance:FloatTipsByString("自动重置成功")
--         else
--             NoticeManager.Instance:FloatTipsByString("今日可挑战次数为0")
--         end
--     elseif self.model.reset > 0 then
--         TrialManager.Instance:Send13103()
--         NoticeManager.Instance:FloatTipsByString("自动重置成功")
--     else
--         NoticeManager.Instance:FloatTipsByString("今日可挑战次数为0")
--     end
-- end

-- function TrialView:ResetTrial()
--    print("ResetTrial")
--    TrialManager.Instance:Send13103()
-- end




-- 极寒试炼界面

TrialView = TrialView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2

function TrialView:__init(model)
    self.model = model
    self.name = "TrialView"
    self.windowId = WindowConfig.WinID.trialwindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end

    self.resList = {
        {file = AssetConfig.trialwindow, type = AssetType.Main}
        , {file = AssetConfig.trial_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    ------------------------------------------------
    self.transform = nil
    self.Button3 = nil
    self.number1 = nil
    self.number2 = nil
    self.show = false
    ------------------------------------------------
    self._update = function()
        self:update()
    end
    ------------------------------------------------

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function TrialView:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()

    self:OnHide()
end

function TrialView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.trialwindow))
    self.gameObject.name = "TrialView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    local transform = self.transform

    local closeBtn = transform:FindChild("Main/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    closeBtn = transform:FindChild("Reset/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    local btn = nil
    self.goTrialBtn = transform:Find("Main/OkButtom"):GetComponent(Button)
    self.goTrialBtn .onClick:AddListener( function() self:GoTrial() end )

    self.resetTrialBtn = transform:Find("Main/ResetButtom"):GetComponent(Button)
    self.resetTrialBtn.onClick:AddListener( function() self:OnResetTrialButtonClick() end )

    btn = transform:Find("Main/DescButtom"):GetComponent(Button)
    btn.onClick:AddListener( function() TipsManager.Instance:ShowText({gameObject = transform:Find("Main/DescButtom").gameObject
            , itemData = {TI18N("每日<color='#ffff00'>5：00</color>获得一次重置次数，重置次数最多累计<color='#ffff00'>3次</color>。")}}) end )

    btn = transform:Find("Reset/Button1"):GetComponent(Button)
    btn.onClick:AddListener( function() self:ResetButton1() end )

    self.Button2 = transform:Find("Reset/Button2").gameObject
    self.Button2:GetComponent(Button).onClick:AddListener( function() self:ResetButton2() end )

    self.Button3 = transform:Find("Reset/Button3").gameObject
    self.Button3:GetComponent(Button).onClick:AddListener( function() self:ResetButton3() end )

    if self.imgLoader == nil then
        local go = transform:Find("Reset/Image").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 22505)
    
    -------------------------------------------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function TrialView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function TrialView:OnShow()
    EventMgr.Instance:AddListener(event_name.trial_update, self._update)
    self:update()
end

function TrialView:OnHide()
    EventMgr.Instance:RemoveListener(event_name.trial_update, self._update)
end

function TrialView:update()
    if self.gameObject == nil then return end

    self.transform.transform:Find("Main").gameObject:SetActive(true)
    self.transform.transform:Find("Reset").gameObject:SetActive(false)
    if self.model.mode == 0 then
        self.transform.transform:Find("Main/Lable1").gameObject:SetActive(false)
        self.transform.transform:Find("Main/Lable2").gameObject:SetActive(false)
    elseif self.model.mode == 1 then
        self.transform.transform:Find("Main/Lable1").gameObject:SetActive(true)
        self.transform.transform:Find("Main/Lable2").gameObject:SetActive(false)
    elseif self.model.mode == 2 then
        self.transform.transform:Find("Main/Lable1").gameObject:SetActive(false)
        self.transform.transform:Find("Main/Lable2").gameObject:SetActive(true)
    end

    local order = self.model.order
    if order < self.model.direct_order then
        order = self.model.direct_order
    end

    if DataTrial.data_trial_data[order] ~= nil then
        order = tonumber(DataTrial.data_trial_data[order].order_desc) - 1
    else
        order = math.floor(order / 2)
    end

    self.transform.transform:Find("Main/RoundText"):GetComponent(Text).text = tostring(order)
    self.transform.transform:Find("Main/MoneyText"):GetComponent(Text).text = tostring(self.model.coin)
    self.transform.transform:Find("Main/TimesText"):GetComponent(Text).text = string.format("%s/%s", self.model.times, self.model.max_times)

    self.transform.transform:Find("Main/NumText"):GetComponent(Text).text = tostring(self.model.reset)

    order = self.model.order
    if order < self.model.direct_order then
        order = self.model.direct_order
    end
    if self.model.times == 0 or (order ~= 0 and DataTrial.data_trial_data[order] == nil) then
        self.goTrialBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.resetTrialBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.goTrialBtn.gameObject.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton1
        self.resetTrialBtn.gameObject.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
    else
        self.goTrialBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.resetTrialBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.goTrialBtn.gameObject.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
        self.resetTrialBtn.gameObject.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton1
    end
end

function TrialView:ResetButton1()
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
    TrialManager.Instance:Send13101(1)
    self:OnClickClose()
end

function TrialView:ResetButton2()
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
    TrialManager.Instance:Send13101(2)
    self:OnClickClose()
end

function TrialView:ResetButton3()
   NoticeManager.Instance:FloatTipsByString(TI18N("通关普通难度后开放"))
end

function TrialView:GoTrial()
   -- print("GoTrial")
   if self.model.times > 0 then
        -- print(self.model.order)
        if self.model.order == 0 or DataTrial.data_trial_data[self.model.order] ~= nil then
           if self.model.mode == 0 then
               self:OpenResetPanle()
           else
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
                TrialManager.Instance:Send13101(self.model.mode)
                self:OnClickClose()
           end
        elseif self.model.reset > 0 then
            self:ResetTrial()
            NoticeManager.Instance:FloatTipsByString(TI18N("自动重置成功"))
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("今日可挑战次数为0"))
        end
    elseif self.model.reset > 0 then
        self:ResetTrial()
        NoticeManager.Instance:FloatTipsByString(TI18N("自动重置成功"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("今日可挑战次数为0"))
    end
end

function TrialView:OnResetTrialButtonClick()
    local mark = true
    if self.model.times > 0 then
        if self.model.order == 0 or DataTrial.data_trial_data[self.model.order] ~= nil then
           if self.model.mode == 0 then
               mark = false
           end
        elseif self.model.reset > 0 then
            mark = false
        end
    elseif self.model.reset > 0 then
        mark = false
    end

    if mark then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("当前关卡未完成，确定重置吗？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() self:ResetTrial() end
        NoticeManager.Instance:ConfirmTips(data)
    else
        self:ResetTrial()
    end
end

function TrialView:ResetTrial()
   -- print("ResetTrial")
   TrialManager.Instance:Send13103()
   self:OpenResetPanle()
end

function TrialView:OpenResetPanle()
    if self.model.mode == 0 then
        self.transform.transform:Find("Main").gameObject:SetActive(false)
        self.transform.transform:Find("Reset").gameObject:SetActive(true)
        if self.model.clear_normal == 1 then
            self.Button2:SetActive(true)
            self.Button3:SetActive(false)
        else
            self.Button2:SetActive(false)
            self.Button3:SetActive(true)
        end
    end
end
