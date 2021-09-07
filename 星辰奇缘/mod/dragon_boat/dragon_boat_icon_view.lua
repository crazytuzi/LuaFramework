-- 主界面 \划龙舟按钮
-- ljh 20170523

DragonBoatIcon = DragonBoatIcon or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function DragonBoatIcon:__init(model)
    self.model = model
	self.resList = {
        {file = AssetConfig.dragonboaticon, type = AssetType.Main}
        , {file = AssetConfig.dailyicon, type = AssetType.Dep}
    }

    self.name = "DragonBoatIcon"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------

    ------------------------------------
    self._update = function()
    	self:update()
	end

	self:LoadAssetBundleBatch()
end

function DragonBoatIcon:__delete()
    EventMgr.Instance:RemoveListener(event_name.halloween_rank_update, self._update)
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self:AssetClearAll()
end

function DragonBoatIcon:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragonboaticon))
    self.gameObject.name = "DragonBoatIcon"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    -- local rect = self.gameObject:GetComponent(RectTransform)
    -- rect.anchorMax = Vector2(1, 1)
    -- rect.anchorMin = Vector2(0, 0)
    -- rect.localPosition = Vector3(0, 0, 1)
    -- rect.offsetMin = Vector2(0, 0)
    -- rect.offsetMax = Vector2(0, 0)
    -- rect.localScale = Vector3.one

    self.transform = self.gameObject.transform

	-----------------------------
    local transform = self.transform

    self.button = transform:FindChild("Button").gameObject
    self.button:GetComponent(Button).onClick:AddListener(function() self:button_click() end)
    self.buttonImage = self.button.gameObject:GetComponent(Image)
    -- self.buttonImage.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon,"2053")
    self.buttonImage.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon,"2025")
    self.button:SetActive(true)

    self.timeObj = transform:Find("Time").gameObject
    self.timeText = transform:Find("Time/Text"):GetComponent(Text)
    self.timeObj:SetActive(true)

    self.bigTimeText = transform:Find("TimeText"):GetComponent(Text)
    self.bigTimeText.gameObject:SetActive(false)

    self.timeImage = transform:Find("TimeImage").gameObject
    self.timeImage:SetActive(false)

    -- local fun = function(effectView)
    --     if BaseUtils.is_null(self.gameObject) then
    --         return
    --     end

    --     local effectObject = effectView.gameObject

    --     effectObject.transform:SetParent(self.button.transform)
    --     effectObject.transform.localScale = Vector3.one
    --     effectObject.transform.localPosition = Vector3.zero
    --     effectObject.transform.localRotation = Quaternion.identity

    --     Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    --     effectObject:SetActive(true)
    -- end
    -- self.effect = BaseEffectView.New({effectId = 20256, time = nil, callback = fun})

 --    -----------------------------
 --    EventMgr.Instance:AddListener(event_name.treasuremap_compass_update, self._update)
 --    EventMgr.Instance:AddListener(event_name.scene_load, self._change_map)

    self:Show()

    -- self:ClearMainAsset()
end

function DragonBoatIcon:Show()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(true)

        self.button:SetActive(true)
        self.timeObj:SetActive(true)
        self.bigTimeText.gameObject:SetActive(false)
        self.timeImage:SetActive(false)

        self:update()
        EventMgr.Instance:RemoveListener(event_name.role_event_change, self._update)
        EventMgr.Instance:AddListener(event_name.role_event_change, self._update)

        if self.timerId == nil then
            self.timerId = LuaTimer.Add(0, 50, function() self:CountDown() end)
        end
    end
end

function DragonBoatIcon:Hide()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(false)
        EventMgr.Instance:RemoveListener(event_name.role_event_change, self._update)
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end

function DragonBoatIcon:update()
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.DragonBoat or DragonBoatManager.Instance.status ~= 1 then
        LuaTimer.Add(100, function () DragonBoatManager.Instance.model:HideIcon() end)
    end
end

function DragonBoatIcon:button_click()
    DragonBoatManager.Instance.model:OpenStartWindow()
end

function DragonBoatIcon:CountDown()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonBoat then
        local time = DragonBoatManager.Instance.time_out - BaseUtils.BASE_TIME
        if time > 3 then
            local m = nil
            local s = nil
            local _ = nil
            _, _, m,s = BaseUtils.time_gap_to_timer(time)
            if s < 10 then s = "0" .. s end
            if m < 10 then m = "0" .. m end
            self.timeText.text = string.format("<color='#13fc60'>%s:%s</color>", m, s)

            self.isConfirmTips = false
        elseif time > 0 then
            self.button:SetActive(false)
            self.timeObj:SetActive(false)
            self.bigTimeText.gameObject:SetActive(false)
            -- self.bigTimeText.gameObject:SetActive(true)
            -- self.bigTimeText.text = string.format("<color='#00ff00'>%s</color>", time)

            self.timeImage:SetActive(true)
            self.timeImage:GetComponent(Image).sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_4, "Num4_"..tostring(time))
            self.timeImage:GetComponent(Image):SetNativeSize()

            if not self.isTweening then
                self.isTweening = true
                -- self.bigTimeText.color = Color(1, 1, 1, 1)
                -- Tween.Instance:Alpha(self.bigTimeText, Vector3.zero, 1, function() self:TweenEnd() end)
                self.timeImage.transform.localScale = Vector3.one*3
                Tween.Instance:Scale(self.timeImage, Vector3(1,1,1), 1, function() self:TweenEnd() end, LeanTweenType.easeOutElastic)
            end

            if not self.isConfirmTips then
                self.isConfirmTips = true

                LuaTimer.Add(3000, function()
                    local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Sure
                    data.content = string.format( TI18N("%s正式开始，大家赶紧出发！"), DragonBoatManager.Instance.title_name)
                    data.sureLabel = TI18N("出发")
                    data.sureCallback = function()
                        DragonBoatManager.Instance:GoNext()
                    end
                    NoticeManager.Instance:ConfirmTips(data)
                end)
            end
        else
            DragonBoatManager.Instance.model:HideIcon()

            if self.timerId ~= nil then
                LuaTimer.Delete(self.timerId)
                self.timerId = nil
            end
        end
    end
    self:update()
end

function DragonBoatIcon:TweenEnd()
    self.isTweening = false
end
