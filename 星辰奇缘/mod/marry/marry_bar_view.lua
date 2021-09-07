-- 主界面 典礼按钮操作栏
MarryBarView = MarryBarView or BaseClass(BaseView)

function MarryBarView:__init()
    self.model = MarryManager.Instance.model
	self.resList = {
        {file = AssetConfig.marry_bar_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
    }

    self.name = "MarryBarView"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------
    self.btn1 = nil
	self.btn2 = nil
	self.btn3 = nil
	self.btn4 = nil
	self.btn5 = nil
	self.btn6 = nil

    self.text1 = nil
	self.text2 = nil
	self.text3 = nil
	self.text4 = nil
	self.text5 = nil
	self.text6 = nil

	self.timer_id = nil

	self.promptList = { false, false, false, false, false, false}
	self.actionNameList = { TI18N("糖果"), TI18N("礼炮"), TI18N("红包"), TI18N("敬酒"), TI18N("撒花"), TI18N("弹幕")}

    ------------------------------------
    self._update = function() self:update() end
    EventMgr.Instance:AddListener(event_name.marry_data_update, self._update)
    EventMgr.Instance:AddListener(event_name.role_event_change, self._update)

	self:LoadAssetBundleBatch()
end

function MarryBarView:__delete()
	if self.timer_id ~= nil then LuaTimer.Delete(self.timer_id) self.timer_id = nil end

	EventMgr.Instance:RemoveListener(event_name.marry_data_update, self._update)
	EventMgr.Instance:RemoveListener(event_name.role_event_change, self._update)

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MarryBarView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_bar_window))
    self.gameObject.name = "MarryBarView"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 0)
    rect.localScale = Vector3.one

    self.transform = self.gameObject.transform

	-----------------------------
    local transform = self.transform

    self.btn1 = self.transform:FindChild("main/icon1").gameObject
    self.btn1:GetComponent(Button).onClick:AddListener(function() self:button_click(1) end)

    self.btn2 = self.transform:FindChild("main/icon2").gameObject
    self.btn2:GetComponent(Button).onClick:AddListener(function() self:button_click(2) end)

    self.btn3 = self.transform:FindChild("main/icon3").gameObject
    self.btn3:GetComponent(Button).onClick:AddListener(function() self:button_click(3) end)

    self.btn4 = self.transform:FindChild("main/icon4").gameObject
    self.btn4:GetComponent(Button).onClick:AddListener(function() self:button_click(4) end)

    self.btn5 = self.transform:FindChild("main/icon5").gameObject
    self.btn5:GetComponent(Button).onClick:AddListener(function() self:button_click(5) end)

    self.btn6 = self.transform:FindChild("main/icon6").gameObject
    self.btn6:GetComponent(Button).onClick:AddListener(function() self:button_click(6) end)

    self.text1 = self.transform:FindChild("main/icon1/Text"):GetComponent(Text)
    self.text2 = self.transform:FindChild("main/icon2/Text"):GetComponent(Text)
    self.text3 = self.transform:FindChild("main/icon3/Text"):GetComponent(Text)
    self.text4 = self.transform:FindChild("main/icon4/Text"):GetComponent(Text)
    self.text5 = self.transform:FindChild("main/icon5/Text"):GetComponent(Text)
    self.text6 = self.transform:FindChild("main/icon6/Text"):GetComponent(Text)

    self.image1 = self.btn1:GetComponent(Image)
    self.image2 = self.btn2:GetComponent(Image)
    self.image3 = self.btn3:GetComponent(Image)
    self.image4 = self.btn4:GetComponent(Image)
    self.image5 = self.btn5:GetComponent(Image)
    self.image6 = self.btn6:GetComponent(Image)

	self.coolDown = { true, true, true, true, true, true}

	self.iconList = { self.image1.gameObject.transform
					, self.image2.gameObject.transform
					, self.image3.gameObject.transform
					, self.image4.gameObject.transform
					, self.image5.gameObject.transform
					, self.image6.gameObject.transform}
    -----------------------------

	self.timer_id = LuaTimer.Add(1000, 1000, function() self:update_coolDown() end)
    self:update()

    self:ClearMainAsset()
end

function MarryBarView:update()
	if self.gameObject == nil then return end

	local roleData = RoleManager.Instance.RoleData
	if roleData.event == RoleEumn.Event.Marry or roleData.event == RoleEumn.Event.Marry_cere then
		self.btn1:SetActive(true)
		self.btn2:SetActive(true)

		self.btn3:SetActive(false)
		self.btn4:SetActive(false)
		self.btn5:SetActive(false)
		self.btn6:SetActive(false)

		self:update_coolDown()
		-- self:update_times()
	else
		self.btn2:SetActive(true)
		self.btn5:SetActive(true)
		self.btn6:SetActive(true)

		self.btn1:SetActive(false)
		self.btn3:SetActive(false)
		self.btn4:SetActive(false)

		self:update_coolDown()
		-- self:update_times()
	end
end

function MarryBarView:update_coolDown()
	if self.gameObject == nil then return end

	local roleData = RoleManager.Instance.RoleData
	if roleData.event == RoleEumn.Event.Marry or roleData.event == RoleEumn.Event.Marry_cere then
		local action_times_data
		local data
		action_times_data = self.model.action_times_list[1]
		data = self:get_data_wedding_action(1)
		if action_times_data ~= nil then
			self.coolDown[1] = BaseUtils.BASE_TIME > action_times_data.mtime
			BaseUtils.SetGrey(self.image1, not self.coolDown[1])
			if not self.coolDown[1] then
				self.text1.text = string.format("%ss", action_times_data.mtime-BaseUtils.BASE_TIME)
			else
				if action_times_data.num < data.free_num then
					self.text1.text = TI18N("<color='#00ff00'>免费</color>")
				else
					self.text1.text = string.format("%s/%s", action_times_data.num, data.max_num)
				end
			end
		else
			if 0 < data.free_num then
				self.text1.text = TI18N("<color='#00ff00'>免费</color>")
			else
				self.text1.text = string.format("%s/%s", 0, data.max_num)
			end
		end
		action_times_data = self.model.action_times_list[2]
		data = self:get_data_wedding_action(2)
		if action_times_data ~= nil then
			self.coolDown[2] = BaseUtils.BASE_TIME > action_times_data.mtime
			BaseUtils.SetGrey(self.image2, not self.coolDown[2])
			if not self.coolDown[2] then
				self.text2.text = string.format("%ss", action_times_data.mtime-BaseUtils.BASE_TIME)
			else
				if action_times_data.num < data.free_num then
					self.text2.text = TI18N("<color='#00ff00'>免费</color>")
				else
					self.text2.text = string.format("%s/%s", action_times_data.num, data.max_num)
				end
			end
		else
			if 0 < data.free_num then
				self.text2.text = TI18N("<color='#00ff00'>免费</color>")
			else
				self.text2.text = string.format("%s/%s", 0, data.max_num)
			end
		end
	else
		local action_times_data
		local data
		action_times_data = self.model.action_times_list[2]
		data = self:get_data_wedding_action(2)
		if action_times_data ~= nil then
			self.coolDown[2] = BaseUtils.BASE_TIME > action_times_data.mtime
			BaseUtils.SetGrey(self.image2, not self.coolDown[2])
			if not self.coolDown[2] then
				self.text2.text = string.format("%ss", action_times_data.mtime-BaseUtils.BASE_TIME)
			else
				if action_times_data.num < data.free_num then
					self.text2.text = TI18N("<color='#00ff00'>免费</color>")
				else
					self.text2.text = string.format("%s/%s", action_times_data.num, data.max_num)
				end
			end
		else
			if 0 < data.free_num then
				self.text2.text = TI18N("<color='#00ff00'>免费</color>")
			else
				self.text2.text = string.format("%s/%s", 0, data.max_num)
			end
		end
		-- action_times_data = self.model.action_times_list[3]
		-- data = self:get_data_wedding_action(3)
		-- if action_times_data ~= nil then
		-- 	self.coolDown[3] = BaseUtils.BASE_TIME > action_times_data.mtime
		-- 	BaseUtils.SetGrey(self.image3, not self.coolDown[3])
		-- 	if not self.coolDown[3] then
		-- 		self.text3.text = string.format("%ss", action_times_data.mtime-BaseUtils.BASE_TIME)
		-- 	else
		-- 		if action_times_data.num < data.free_num then
		-- 			self.text3.text = "<color='#00ff00'>免费</color>"
		-- 		else
		-- 			self.text3.text = string.format("%s/%s", action_times_data.num, data.max_num)
		-- 		end
		-- 	end
		-- else
		-- 	self.text3.text = "<color='#00ff00'>免费</color>"
		-- end
		-- action_times_data = self.model.action_times_list[4]
		-- data = self:get_data_wedding_action(4)
		-- if action_times_data ~= nil then
		-- 	self.coolDown[4] = BaseUtils.BASE_TIME > action_times_data.mtime
		-- 	BaseUtils.SetGrey(self.image4, not self.coolDown[4])
		-- 	if not self.coolDown[4] then
		-- 		self.text4.text = string.format("%ss", action_times_data.mtime-BaseUtils.BASE_TIME)
		-- 	else
		-- 		if action_times_data.num < data.free_num then
		-- 			self.text4.text = "<color='#00ff00'>免费</color>"
		-- 		else
		-- 			self.text4.text = string.format("%s/%s", action_times_data.num, data.max_num)
		-- 		end
		-- 	end
		-- else
		-- 	self.text4.text = "<color='#00ff00'>免费</color>"
		-- end
		action_times_data = self.model.action_times_list[5]
		data = self:get_data_wedding_action(5)
		if action_times_data ~= nil then
			self.coolDown[5] = BaseUtils.BASE_TIME > action_times_data.mtime
			BaseUtils.SetGrey(self.image5, not self.coolDown[5])
			if not self.coolDown[5] then
				self.text5.text = string.format("%ss", action_times_data.mtime-BaseUtils.BASE_TIME)
			else
				if action_times_data.num < data.free_num then
					self.text5.text = TI18N("<color='#00ff00'>免费</color>")
				else
					self.text5.text = string.format("%s/%s", action_times_data.num, data.max_num)
				end
			end
		else
			if 0 < data.free_num then
				self.text5.text = TI18N("<color='#00ff00'>免费</color>")
			else
				self.text5.text = string.format("%s/%s", 0, data.max_num)
			end
		end
		action_times_data = self.model.action_times_list[6]
		data = self:get_data_wedding_action(6)
		if action_times_data ~= nil then
			self.coolDown[6] = BaseUtils.BASE_TIME > action_times_data.mtime
			BaseUtils.SetGrey(self.image6, not self.coolDown[6])
			if not self.coolDown[6] then
				self.text6.text = string.format("%ss", action_times_data.mtime-BaseUtils.BASE_TIME)
			else
				if action_times_data.num < data.free_num then
					self.text6.text = TI18N("<color='#00ff00'>免费</color>")
				else
					self.text6.text = string.format("%s/%s", action_times_data.num, data.max_num)
				end
			end
		else
			if 0 < data.free_num then
				self.text6.text = TI18N("<color='#00ff00'>免费</color>")
			else
				self.text6.text = string.format("%s/%s", 0, data.max_num)
			end
		end
	end
end

function MarryBarView:update_times()
	if self.gameObject == nil then return end

	local roleData = RoleManager.Instance.RoleData
	if roleData.event == RoleEumn.Event.Marry or roleData.event == RoleEumn.Event.Marry_cere then
		local data
		local action_times_data
		action_times_data = self.model.action_times_list[1]
		data = self:get_data_wedding_action(1)
		if action_times_data ~= nil then
			if action_times_data.num < data.free_num then
				self.text1.text = tostring(data.free_num - action_times_data.num)
			else
				self.text1.text = ""
			end
		else
			self.text1.text = data.free_num
		end

		action_times_data = self.model.action_times_list[2]
		data = self:get_data_wedding_action(2)
		if action_times_data ~= nil then
			if action_times_data.num < data.free_num then
				self.text2.text = tostring(data.free_num - action_times_data.num)
			else
				self.text2.text = ""
			end
		else
			self.text2.text = data.free_num
		end

		-- local length = 0
		-- for key, value in pairs(MarryManager.Instance.model.requestData) do
		-- 	length = length + 1
		-- end
		-- if length > 0 then
		-- 	self.text8.text = tostring(length)
		-- else
		-- 	self.text8.text = ""
		-- end
	else
		local data
		local action_times_data
		action_times_data = self.model.action_times_list[2]
		data = self:get_data_wedding_action(2)
		if action_times_data ~= nil then
			if action_times_data.num < data.free_num then
				self.text2.text = tostring(data.free_num - action_times_data.num)
			else
				self.text2.text = ""
			end
		else
			self.text2.text = data.free_num
		end

		-- action_times_data = self.model.action_times_list[3]
		-- data = self:get_data_wedding_action(3)
		-- if action_times_data ~= nil then
		-- 	if action_times_data.num < data.free_num then
		-- 		self.text3.text = tostring(data.free_num - action_times_data.num)
		-- 	else
		-- 		self.text3.text = ""
		-- 	end
		-- else
		-- 	self.text3.text = data.free_num
		-- end

		action_times_data = self.model.action_times_list[4]
		data = self:get_data_wedding_action(4)
		if action_times_data ~= nil then
			if action_times_data.num < data.free_num then
				self.text4.text = tostring(data.free_num - action_times_data.num)
			else
				self.text4.text = ""
			end
		else
			self.text4.text = data.free_num
		end

		action_times_data = self.model.action_times_list[5]
		data = self:get_data_wedding_action(5)
		if action_times_data ~= nil then
			if action_times_data.num < data.free_num then
				self.text5.text = tostring(data.free_num - action_times_data.num)
			else
				self.text5.text = ""
			end
		else
			self.text5.text = data.free_num
		end

		action_times_data = self.model.action_times_list[6]
		data = self:get_data_wedding_action(6)
		if action_times_data ~= nil then
			if action_times_data.num < data.free_num then
				self.text6.text = tostring(data.free_num - action_times_data.num)
			else
				self.text6.text = ""
			end
		else
			self.text6.text = data.free_num
		end
	end
end

function MarryBarView:button_click(type)
	if not self.coolDown[type] then NoticeManager.Instance:FloatTipsByString(TI18N("冷却中")) return end
	if type == 6 then
    	DanmakuManager.Instance:OpenInputWin()
    -- elseif type == 7 then
    -- 	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_invite_window)
    -- elseif type == 8 then
    -- 	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marry_request_window)
    else
		local action_times_data = self.model.action_times_list[type]
		if ((action_times_data ~= nil and action_times_data.num >= self:get_data_wedding_action(type).free_num)
			or (action_times_data == nil and 0 >= self:get_data_wedding_action(type).free_num))
			and not self.promptList[type] then
			local confirmData = NoticeConfirmData.New()
			confirmData.type = ConfirmData.Style.Normal
			confirmData.content = string.format(TI18N("%s需要消耗{assets_1, %s, %s}"), self.actionNameList[type], self:get_data_wedding_action(type).cost[1][1], self:get_data_wedding_action(type).cost[1][2])
			confirmData.sureLabel = TI18N("确定")
			confirmData.cancelLabel = TI18N("取消")
			confirmData.sureCallback = function() MarryManager.Instance:Send15006(type, "") self.promptList[type] = true end
			NoticeManager.Instance:ConfirmTips(confirmData)
		else
	    	MarryManager.Instance:Send15006(type, "")
	    end
    end
end

function MarryBarView:get_data_wedding_action(type)
	local roleData = RoleManager.Instance.RoleData
	local data = nil
	if roleData.event == RoleEumn.Event.Marry or roleData.event == RoleEumn.Event.Marry_cere then
		if roleData.sex == 1 then
			data = DataWedding.data_wedding_action[string.format("%s_%s_1", type, self.model.type)]
		else
			data = DataWedding.data_wedding_action[string.format("%s_%s_2", type, self.model.type)]
		end
	else
		data = DataWedding.data_wedding_action[string.format("%s_%s_3", type, self.model.type)]
	end
	return data
end

function MarryBarView:PlayEffect(type)
	if self.gameObject == nil then return end

	local time1 = 800
	local time1_2 = 300
	local time2 = 800
	local time3 = 1000
	-- 特效
	local fun = function(effectView)
		local pos = Vector3(330, -5, -1000)
	    local effectObject = effectView.gameObject

	    effectObject.transform:SetParent(self.iconList[type])
		effectObject.transform.localScale = Vector3.one
		effectObject.transform.localPosition = Vector3(0, 0, -1000)
		effectObject.transform.localRotation = Quaternion.identity

		Utils.ChangeLayersRecursively(effectObject.transform, "UI")

		local fun2 = function(effectView)
		    local effectObject = effectView.gameObject

		    effectObject.transform:SetParent(self.iconList[type])
			effectObject.transform.localScale = Vector3.one
			effectObject.transform.localPosition = Vector3(0, 0, -1000)
			effectObject.transform.localRotation = Quaternion.identity
			effectObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.gameObject.transform)

			Utils.ChangeLayersRecursively(effectObject.transform, "UI")

			Tween.Instance:MoveLocal(effectObject, pos, time2/1000)

			local fun3 = function(effectView)
			    local effectObject = effectView.gameObject

			    effectObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.gameObject.transform)
				effectObject.transform.localScale = Vector3.one
				effectObject.transform.localPosition = pos
				effectObject.transform.localRotation = Quaternion.identity

				Utils.ChangeLayersRecursively(effectObject.transform, "UI")
			end
			LuaTimer.Add(time2, function() BaseEffectView.New({effectId = 20132, time = time3, callback = fun3}) end)
		end
		LuaTimer.Add(time1_2, function() BaseEffectView.New({effectId = 20131, time = time2, callback = fun2}) end)
	end
	BaseEffectView.New({effectId = 20130, time = time1, callback = fun})
end