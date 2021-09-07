CrossArenaIcon = CrossArenaIcon or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function CrossArenaIcon:__init(model)
    self.model = model
	self.resList = {
        {file = AssetConfig.crossarenaicon, type = AssetType.Main}
        , {file = AssetConfig.crossarena_textures, type = AssetType.Dep}
    }

    self.name = "CrossArenaIcon"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------

    ------------------------------------
    self._update = function()
    	self:update()
	end

	self:LoadAssetBundleBatch()
end

function CrossArenaIcon:__delete()
    EventMgr.Instance:RemoveListener(event_name.halloween_rank_update, self._update)
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    self:AssetClearAll()
end

function CrossArenaIcon:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarenaicon))
    self.gameObject.name = "CrossArenaIcon"
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

    self.timeObj = transform:Find("Time").gameObject
    self.timeText = transform:Find("Time/Text"):GetComponent(Text)

    -- if self.effect == nil then
    --     local fun = function(effectView)
    --         if BaseUtils.is_null(self.gameObject) then
    --             GameObject.Destroy(effectView.gameObject)
    --             return
    --         end
    --         local effectObject = effectView.gameObject

    --         effectObject.transform:SetParent(self.button.transform)
    --         effectObject.transform.localScale = Vector3(1.2, 1.2, 1.2)
    --         effectObject.transform.localPosition = Vector3(-2, 5, -400)
    --         effectObject.transform.localRotation = Quaternion.identity

    --         Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    --         effectObject:SetActive(true)
    --     end
    --     self.effect = BaseEffectView.New({effectId = 20121, time = nil, callback = fun})
    -- else
    --     self.effect:SetActive(true)
    -- end
    -----------------------------

    self:Show()

    -- self:ClearMainAsset()
end

function CrossArenaIcon:Show()
    EventMgr.Instance:AddListener(event_name.end_fight, self._update)
    EventMgr.Instance:AddListener(event_name.begin_fight, self._update)

    self:update()
end

function CrossArenaIcon:Hide()
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self._update)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self._update)
end

function CrossArenaIcon:update()
    if not BaseUtils.is_null(self.gameObject) then
        local roleData = RoleManager.Instance.RoleData
        if roleData.status == RoleEumn.Status.Fight then
            self.gameObject:SetActive(false)
        else
            self.gameObject:SetActive(true)
        end
    end
end

function CrossArenaIcon:button_click()
    local roleData = RoleManager.Instance.RoleData
    if roleData.event == RoleEumn.Event.Provocation then
        -- self.model:OpenCrossArenaWindow()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.crossarenawindow)
    elseif roleData.event == RoleEumn.Event.ProvocationRoom then
        self.model:OpenCrossArenaRoomWindow()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动暂未开放，请耐心等待{face_1,3}"))
    end
end

