-- 此界面不要尝试热更，热更会导致所有安装包都报错！！！！
local InitLoadingView = {
	visible = true,
	load_percent = 0,
	load_text = nil,
	message_title = nil,
	message_content = nil,
	message_button_name = nil,
	message_complete = nil,
	is_hide_slider = true,
	view = {
		root_obj = nil,
		slider = nil,
		text = nil,
		message_box = nil,
		message_title = nil,
		message_content = nil,
		message_button = nil,
		message_button_text = nil,
		bg = nil,
		notice = nil,
		bundle_name = nil,
		name = nil,
		str = nil,
		percent = nil,
		show_effect = nil,
	}
}

local LoadingCamera = GameObject.Find("Loading/UICamera")

function InitLoadingView:Start()
	print_log("InitLoadingView:Start")
	LoadingCamera:GetComponent(typeof(UnityEngine.Camera)).enabled = true
	local view_obj = GameObject.Find("Loading/UILayer/LoadingView")
	if view_obj ~= nil then
		view_obj.gameObject:SetActive(true)
		self:SetupView(view_obj.gameObject)
	else
		UtilU3d.PrefabLoad(
		"uis/views/loading_prefab",
		"LoadingView",
		function(obj)
			obj.name = string.gsub(obj.name, "%(Clone%)", "")
			self:SetupView(obj)
		end)
	end
end

function InitLoadingView:SetupView(obj)
	print_log("InitLoadingView Loading init view finished.")

	-- 通知SDK游戏启动，关闭闪屏页
	if NewUtilU3d then
		NewUtilU3d.CloseSplash()
	end

	self.view.root_obj = obj

	local variable_table = obj:GetComponent("UIVariableTable")
	self.view.bg = variable_table:FindVariable("Bg")
	self.view.bgURL = variable_table:FindVariable("BgURL")
	self.view.notice = variable_table:FindVariable("Notice")
	self.view.percent = variable_table:FindVariable("Percent")
	self.view.show_progress = variable_table:FindVariable("ShowProgress")
	self.view.IsIphoneX = variable_table:FindVariable("IsIphoneX")
	self.view.bg_splashURL = variable_table:FindVariable("BgSplashURL")
	self.view.is_hide_Slider = variable_table:FindVariable("IsHideSlider")
	self.view.show_effect = variable_table:FindVariable("ShowEffect")
	if self.view.hide_progress then
		self.view.show_progress:SetValue(false)
	else
		self.view.show_progress:SetValue(true)
	end
	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer
		and UnityEngine.iOS.Device.generation == UnityEngine.iOS.DeviceGeneration.iPhoneX then
		if self.view.IsIphoneX then
			self.view.IsIphoneX:SetValue(true)
		end
	else
		if self.view.IsIphoneX then
			self.view.IsIphoneX:SetValue(false)
		end
	end

	if self.view.show_effect then
		if GLOBAL_CONFIG.param_list.switch_list.show_loading_effect then
			self.view.show_effect:SetValue(true)
		else
			self.view.show_effect:SetValue(false)
		end
	end
	-- self.view.IsIphoneX:SetValue(true)
	self:HideSlider(self.is_hide_slider)
	self:SetBgAsset(self.view.bundle_name, self.view.name)
	self:SetBgURL(self.view.bg_url)
	self:SetNotice(self.view.str)

	local UIRoot = GameObject.Find("Loading/UILayer").transform
	obj.transform:SetParent(UIRoot, false)
	obj.transform:SetLocalScale(1, 1, 1)
	local rect = obj:GetComponent(typeof(UnityEngine.RectTransform))
	rect.anchorMax = Vector2(1, 1)
	rect.anchorMin = Vector2(0, 0)
	rect.anchoredPosition3D = Vector3(0, 0, 0)
	rect.sizeDelta = Vector2(0, 0)

	-- 设置深度
	local canvas = obj.transform:GetComponent(typeof(UnityEngine.Canvas))
	canvas.overrideSorting = true
	canvas.sortingOrder = 30000

	self.view.slider = obj.transform:Find("Progress"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.view.text = obj.transform:Find("ProgressText"):GetComponent(typeof(UnityEngine.UI.Text))
	self.view.message_box = obj.transform:Find("MessageBox").gameObject
	self.view.message_title = obj.transform:Find("MessageBox/Title/Title"):GetComponent(typeof(UnityEngine.UI.Text))
	self.view.message_content = obj.transform:Find("MessageBox/Content"):GetComponent(typeof(UnityEngine.UI.Text))
	self.view.message_button = obj.transform:Find("MessageBox/Button"):GetComponent(typeof(UnityEngine.UI.Button))
	self.view.back_ground = obj.transform:Find("Background").gameObject
	self.view.url_back_ground = obj.transform:Find("BackgroundURL").gameObject
	self.view.splash_url_back_ground = obj.transform:Find("BackgroundSplashURL").gameObject
	self.view.anim = self.view.splash_url_back_ground:GetComponent(typeof(UnityEngine.Animator))
	self.view.anim:ListenEvent("SplashEnd", function() self:StartSplash() end)
	self.view.message_button:AddClickListener(function()
		self.view.message_box:SetActive(false)
		if self.message_complete ~= nil then
			self.message_complete()
			self.message_complete = nil
		end
	end)
	self.view.message_button_text = obj.transform:Find("MessageBox/Button/Text"):GetComponent(typeof(UnityEngine.UI.Text))

	self:SetPercent(self.load_percent)
	self:SetText(self.load_text)
	self:StartSplash()
	self:ShowMessageBox(self.message_title,
		self.message_content,
		self.message_button_name,
		self.message_complete)

	if not self.visible then
		self.view.root_obj:SetActive(false)
	end
end

function InitLoadingView:Show()
	self.visible = true
	LoadingCamera:GetComponent(typeof(UnityEngine.Camera)).enabled = true
	if self.view.root_obj ~= nil then
		-- 显示Loading视图
		self.view.root_obj:SetActive(true)

		-- 重置坐标位置
		local transform = self.view.root_obj.transform
		transform:SetLocalScale(1, 1, 1)
		local rect = transform:GetComponent(typeof(UnityEngine.RectTransform))
		rect.anchorMax = Vector2(1, 1)
		rect.anchorMin = Vector2(0, 0)
		rect.anchoredPosition3D = Vector3(0, 0, 0)
		rect.sizeDelta = Vector2(0, 0)

		-- 设置深度
		local canvas = transform:GetComponent(typeof(UnityEngine.Canvas))
		canvas.overrideSorting = true
		canvas.sortingOrder = 30000

		-- 重置进度条
		self.view.slider.value = 0
	end
end

function InitLoadingView:Hide()
	self.visible = false
	LoadingCamera:GetComponent(typeof(UnityEngine.Camera)).enabled = false
	if self.view.root_obj ~= nil then
		self.view.root_obj:SetActive(false)
	end
end

function InitLoadingView:Destroy()
	if self.view.root_obj ~= nil then
		GameObject.Destroy(self.view.root_obj)
		self.view.root_obj = nil
	end
end

function InitLoadingView:SetPercent(percent, callback)
	self.load_percent = percent
	if nil ~= self.view.percent then
		self.view.percent:SetValue(math.floor(percent * 100) > 100 and 100 or math.floor(percent * 100))
	end
	if nil ~= self.view.slider then
		local time = (percent - self.view.slider.value) * 1
		if callback ~= nil then
			local tweener = self.view.slider:DOValue(percent, time, false)
			tweener:OnComplete(callback)
		else
			self.view.slider:DOValue(percent, time, false)
		end
	else
		if callback then
			callback()
		end
	end
end

function InitLoadingView:SetText(text)
	self.load_text = text
	if not IS_AUDIT_VERSION then
		if self.view.text ~= nil then
			self.view.text.text = text
		end
	end
end

function InitLoadingView:HideSlider(is_hide)
	if nil ~= self.view.is_hide_Slider then
		self.view.is_hide_Slider:SetValue(is_hide)
	else
		self.is_hide_slider = is_hide
	end
end

function InitLoadingView:ShowMessageBox(title, content, button_name, complete)
	self.message_title = title
	self.message_content = content
	self.message_button_name = button_name
	self.message_complete = complete

	if self.view.message_box ~= nil then
		if self.message_complete ~= nil then
			self.view.message_box:SetActive(true)
			self.view.message_title.text = title
			self.view.message_content.text = content
			self.view.message_button_text.text = button_name
			self.view.message_complete = complete
		else
			self.view.message_box:SetActive(false)
		end
	end
end

function InitLoadingView:SetBgAsset(bundle_name, name)
	if bundle_name ~= nil and bundle_name ~= "" and name ~= nil and name ~= "" then
		if self.view.bg ~= nil then
			self.view.bg:SetAsset(bundle_name, name)
		else
			self.view.bundle_name = bundle_name
			self.view.name = name
		end
	end
end

function InitLoadingView:SetBgURL(url)
	if url ~= nil and url ~= "" then
		if self.view.bgURL ~= nil then
			self.view.bgURL:SetValue(url)
		else
			self.view.bg_url = url
		end
	else
		if self.view.url_back_ground then
			self.view.url_back_ground:SetActive(false)
		end
	end
end

function InitLoadingView:SetNotice(str)
	if str ~= nil then
		if self.view.notice ~= nil then
			self.view.notice:SetValue(str)
		else
			self.view.str = str
		end
	end
end

-- 设置闪屏
function InitLoadingView:SetSplashUrl(url_tbl, splash_end_call_back)
	if url_tbl ~= nil then
		self.view.splash_end_call_back = splash_end_call_back
		self.view.url_tbl = url_tbl
		self:StartSplash()
	else
		if splash_end_call_back then
			splash_end_call_back()
		end
	end
end

-- 开始闪屏
function InitLoadingView:StartSplash()
	local url = ""
	if self.view.url_tbl ~= nil then
		url = self.view.url_tbl[1]
	end
	if self.view.bg_splashURL and self.view.anim then
		if url ~= nil and url ~= "" then
			self.view.show_progress:SetValue(false)
			self.view.back_ground:SetActive(false)
			self.view.url_back_ground:SetActive(false)
			self.view.splash_url_back_ground:SetActive(true)
			self.view.bg_splashURL:SetValue(url)
			self.view.anim:SetTrigger("Flash")
			table.remove(self.view.url_tbl, 1)
		else
			self.view.show_progress:SetValue(true)
			self.view.url_back_ground:SetActive(true)
			self.view.back_ground:SetActive(true)
			self.view.splash_url_back_ground:SetActive(false)
			-- 闪屏完成的回调
			if self.view.splash_end_call_back then
				self.view.splash_end_call_back()
				self.view.splash_end_call_back = nil
			end
		end
	else
		if url ~= nil and url ~= "" then
			self.view.hide_progress = true
		end
	end
end

return InitLoadingView