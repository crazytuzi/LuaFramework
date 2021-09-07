-- 主界面 万圣节南瓜精报名按钮
-- ljh 20161026

HalloweenSignup = HalloweenSignup or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function HalloweenSignup:__init(model)
    self.model = model
	self.resList = {
        {file = AssetConfig.halloweensignup, type = AssetType.Main}
        , {file = AssetConfig.halloween_textures, type = AssetType.Dep}
    }

    self.name = "HalloweenSignup"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------

    ------------------------------------
    self._update = function()
    	self:update()
	end

	self:LoadAssetBundleBatch()
end

function HalloweenSignup:__delete()
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

function HalloweenSignup:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweensignup))
    self.gameObject.name = "HalloweenSignup"
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


 --    -----------------------------
 --    EventMgr.Instance:AddListener(event_name.treasuremap_compass_update, self._update)
 --    EventMgr.Instance:AddListener(event_name.scene_load, self._change_map)

    self:Show()

    -- self:ClearMainAsset()
end

function HalloweenSignup:Show()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(true)
        self:update()
        EventMgr.Instance:RemoveListener(event_name.role_event_change, self._update)
        EventMgr.Instance:AddListener(event_name.role_event_change, self._update)
    end
end

function HalloweenSignup:Hide()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(false)
        EventMgr.Instance:RemoveListener(event_name.role_event_change, self._update)
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    else
        EventMgr.Instance:RemoveListener(event_name.role_event_change, self._update)
    end
end

function HalloweenSignup:update()
    if BaseUtils.is_null(self.gameObject) then
        EventMgr.Instance:RemoveListener(event_name.role_event_change, self._update)
        return
    end

	if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.Camp_halloween_pre then
		if self.effect == nil then
			local fun = function(effectView)
                if BaseUtils.is_null(self.button) then
                    GameObject.DestroyImmediate(effectView.gameObject)
                    return
                end
		        local effectObject = effectView.gameObject

		        effectObject.transform:SetParent(self.button.transform)
		        effectObject.transform.localScale = Vector3.one
		        effectObject.transform.localPosition = Vector3(-32, -28, -400)
		        effectObject.transform.localRotation = Quaternion.identity

		        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
		        effectObject:SetActive(true)
		    end
		    self.effect = BaseEffectView.New({effectId = 20053, time = nil, callback = fun})
		else
			self.effect:SetActive(true)
		end

        self.timeObj:SetActive(false)
        self.buttonImage.sprite = self.assetWrapper:GetSprite(AssetConfig.halloween_textures, "HalloweenSignUp")

        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
	else
		if self.effect ~= nil then
			self.effect:SetActive(false)
		end
        self.timeObj:SetActive(true)
        self.buttonImage.sprite = self.assetWrapper:GetSprite(AssetConfig.halloween_textures, "HalloweenMatching")

        if self.timerId == nil then
            self.timerId = LuaTimer.Add(0, 50, function() self:CountDown() end)
        end
	end
end

function HalloweenSignup:button_click()
    if HalloweenManager.Instance.model.less_times == HalloweenManager.Instance.pumpkingoblinTimes then
        NoticeManager.Instance:FloatTipsByString(TI18N("今天的活动次数用完了，明天再战吧！{face_1,7}"))
        return
    elseif HalloweenManager.Instance.model.status ~= 2 then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动开启时段为<color='#ffff00'>16:00-18:00</color>，请准时参加哦！{face_1,7}"))
        return
    end

	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.halloweenmatchwindow)
end

function HalloweenSignup:CountDown()
    local m = nil
    local s = nil
    local _ = nil
    _,_,m,s = BaseUtils.time_gap_to_timer(BaseUtils.BASE_TIME - self.model.match_time)

    if s < 10 then s = "0" .. s end
    if m < 10 then m = "0" .. m end
    self.timeText.text = string.format("<color='#13fc60'>%s:%s</color>", m, s)
end

