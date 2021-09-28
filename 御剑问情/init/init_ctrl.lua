InitCtrl = {
	ctrl_state = CTRL_STATE.START,
	loading_view = nil,
	last_flush_time = -1,
	str_list = {},
	loading_data = nil,
	scene_state = false,
}

require("init/global_config")
require("init/init_device")

local FlushTime = 3

function InitCtrl:Start()
	assert(not InitCtrl.Instance, "multi instance InitCtrl")
	if not InitCtrl.Instance then
		InitCtrl.Instance = self
	end

	self.init_request_times = 1
	self.init_url_index = 1
	self.cjson_request_time = 1
	self.client_time = 0
	self.is_delay_time = false
	self.init_max_request_times = math.max(8, #GLOBAL_CONFIG.package_info.config.init_urls)
	self.cjson_max_request_times = 8
	self.is_retry = false

	self.update_total_size = 0
	self.downloaded_size = 0

	self.is_receive_json = false

	print_log("init ctrl start")
	self.loading_data = require("init/init_loading_data")
	self.loading_view = require("init/init_loading_view")
	self.loading_view:Start()

	self:GetRandomStr()
	self:GetRandomAsset()

	self:SendRequest()
	self:CheckDefaultSetting()
end

function InitCtrl:Update(now_time, elapse_time)
	self.client_time = now_time
	if self.last_flush_time == -1 then
		self.last_flush_time = now_time
	elseif self.last_flush_time + FlushTime < now_time then
		self.last_flush_time = now_time
		self:GetRandomStr()
	end
	if self.ctrl_state == CTRL_STATE.START then
		self.ctrl_state = CTRL_STATE.UPDATE
		self:Start()
	elseif self.ctrl_state == CTRL_STATE.STOP then
		self.ctrl_state = CTRL_STATE.NONE
		self:Stop()
		PopCtrl(self)
	end
	if self.is_require_complete and self.is_receive_json then
		self:StartPreLoad()
		self.is_require_complete = false
		self.is_receive_json = false
	end
	if self.is_complete then
		if self.splash_complete then
			self:OnComplete()
			self.is_complete = false
		end
	end
	if self.is_delay_time then
		self:UpdateDelayTime(now_time, elapse_time)
	end
end

function InitCtrl:GetRandomStr()
	if IS_AUDIT_VERSION and not self.is_retry then
		local str = self.loading_data.IOSLoadingText
		self.loading_view:SetNotice(str)
		return
	end
	if #self.str_list < 1 then
		local temp_list = {}
		for k,v in pairs(self.loading_data.Reminding) do
			table.insert(temp_list, v)
		end
		self.str_list = temp_list
	end
	local index = math.random(1, #self.str_list)
	local str = self.str_list[index]
	self.loading_view:SetNotice(str)
	table.remove(self.str_list, index)
end

function InitCtrl:GetRandomAsset()
	-- 检查SDK是否存在闪屏页
	local url_tbl = {}
	-- 是否是第一次进游戏
	local is_first_start = UtilU3d.GetCacheData("is_first_start")
	if is_first_start == nil then
		if AssetManager.ExistedInStreaming("AgentAssets/splash_1.png") then
			local url = UnityEngine.Application.streamingAssetsPath.."/AgentAssets/splash_1.png"
			table.insert(url_tbl, url)
		end
		if AssetManager.ExistedInStreaming("AgentAssets/splash_2.png") then
			local url = UnityEngine.Application.streamingAssetsPath.."/AgentAssets/splash_2.png"
			table.insert(url_tbl, url)
		end
	end
	self.loading_view:SetSplashUrl(url_tbl, function() self.splash_complete = true end)
	UtilU3d.CacheData("is_first_start", 1)

	-- 检查SDK是否存在特殊的背景页，如果存在则使用SDK的背景页.
	if AssetManager.ExistedInStreaming("AgentAssets/loading_bg.png") then
		local url = UnityEngine.Application.streamingAssetsPath.."/AgentAssets/loading_bg.png"
		self.loading_view:SetBgURL(url)
		return
	end

	local bunle_name = UtilU3d.GetCacheData("loading_bg_bundle_name")
	local asset_name = UtilU3d.GetCacheData("loading_bg_asset_name")

	if nil ~= bunle_name and nil ~= asset_name then
		self.loading_view:SetBgAsset(bunle_name, asset_name)
		return
	end

	local temp_list = self.loading_data.SceneImages
	local index = math.random(1, #temp_list)
	local asset = temp_list[index]
	if asset then
		bunle_name = asset[1]
		asset_name = asset[2]
		UtilU3d.CacheData("loading_bg_bundle_name", bunle_name)
		UtilU3d.CacheData("loading_bg_asset_name", asset_name)
		self.loading_view:SetBgAsset(bunle_name, asset_name)
	end
end

function InitCtrl:Stop()
end

function InitCtrl:SendRequest()
	local os = "unknown"
	local platform = UnityEngine.Application.platform
	if platform == UnityEngine.RuntimePlatform.Android then
		os = "android"
	elseif platform == UnityEngine.RuntimePlatform.IPhonePlayer then
		os = "ios"
	elseif platform == UnityEngine.RuntimePlatform.WindowsPlayer then
		os = "windows"
	elseif platform == UnityEngine.RuntimePlatform.WindowsEditor or
		platform == UnityEngine.RuntimePlatform.OSXEditor then
		os = "windows"
	end

	local url = string.format("%s?plat=%s&pkg=%s&asset=%s&device=%s&os=%s",
		GLOBAL_CONFIG.package_info.config.init_urls[self.init_url_index],
		GLOBAL_CONFIG.package_info.config.agent_id,
		GLOBAL_CONFIG.package_info.version,
		GLOBAL_CONFIG.assets_info.version,
		DeviceTool.GetDeviceID(),
		os)

	print_log("SendRequest", url)
	HttpClient:Request(url, function(url, is_succ, data)
		InitCtrl:OnRequestCallback(url, is_succ, data)
	end)
end

function InitCtrl:OnRequestCallback(url, is_succ, data)
	print_log("Request", url, is_succ)
	if not is_succ then
		if self.init_request_times < self.init_max_request_times then
			self.init_request_times = self.init_request_times + 1
			self.init_url_index = self.init_url_index + 1
			if self.init_url_index > #GLOBAL_CONFIG.package_info.config.init_urls then
				self.init_url_index = 1
			end

			self:SendRequest()
		else
			self.init_request_times = 1
			self.loading_view:ShowMessageBox("网络错误", "连接服务器失败", "重试", function()
				print_log("重试连接服务器")
				self.is_retry = true
				self:SendRequest()
			end)
		end
		return
	end

	for i = 1, 1 do
		local init_info = cjson.decode(data)
		if init_info == nil then
			if self.cjson_request_time < self.cjson_max_request_times then
				self.cjson_request_time = self.cjson_request_time + 1
				self.init_url_index = self.init_url_index + 1
				if self.init_url_index > #GLOBAL_CONFIG.package_info.config.init_urls then
					self.init_url_index = 1
				end
				self:SendRequest()
			else
				self.cjson_request_time = 1
				self.loading_view:ShowMessageBox("网络错误", "连接服务器失败", "重试", function()
					print_log("重试连接服务器")
					self.is_retry = true
					self:SendRequest()
				end)
			end
			return
		end

		if init_info.ret == "login block" then
			local error_remind = "您的设备已被封禁：封禁id为" .. init_info.msg
			self.loading_view:ShowMessageBox("封禁", error_remind, "重试", function()
				print_log("重试连接服务器")
				self:SendRequest()
			end)
			return
		end

		if cjson.null == init_info.param_list then break end

		GLOBAL_CONFIG.param_list = init_info.param_list

		if GLOBAL_CONFIG.param_list.switch_list.audit_version then
			IS_AUDIT_VERSION = true
		end
		self.loading_view:HideSlider(IS_AUDIT_VERSION)
		self:GetRandomStr()

		-- 1:红装、永恒、单人副本
		-- 2：钻石转盘、兑换、投资计划
		-- 3：弹首冲提示、首冲、打开首冲
		-- 4：VIPBOSS、黄金会员、百倍返利
		-- 5：VIP体验、累计充值、每日累充
		-- 6：每日首充、零元礼包

		GLOBAL_CONFIG.param_list.ios_shield = GLOBAL_CONFIG.param_list.ios_shield or ""

		self.is_receive_json = true

		if cjson.null == init_info.server_info then break end
		GLOBAL_CONFIG.server_info = init_info.server_info
		GLOBAL_CONFIG.client_time = self.client_time

		if cjson.null == init_info.version_info then break end
		local version_info = init_info.version_info
		GLOBAL_CONFIG.version_info = {}

		if cjson.null == version_info.package_info then break end
		GLOBAL_CONFIG.version_info.package_info = version_info.package_info

		if cjson.null ~= version_info.assets_info then
			GLOBAL_CONFIG.version_info.assets_info = version_info.assets_info
			AssetManager.AssetVersion = version_info.assets_info.version
		end

		-- 上报服务器第一条协议：游戏启动
		require("manager/report_manager")
		ReportManager:Step(Report.STEP_GAME_BEGIN, nil, nil, nil, nil,
				UnityEngine.SystemInfo.deviceName,
				UnityEngine.SystemInfo.deviceModel,
				UnityEngine.SystemInfo.deviceUniqueIdentifier)

		if cjson.null == version_info.update_data then break end
		local update_data = mime.unb64(version_info.update_data)

		if cjson.null == update_data then break end
		local update_func = loadstring(update_data)
		if cjson.null ~= update_func and "function" == type(update_func) then
			-- PushCtrl(update_func())
			PushCtrl(require("update"))
			return
		end

		self:SetPercent(1)
	end
end

-- view
function InitCtrl:ShowLoading()
	if not self.loading_view then
		return
	end
	self.loading_view:Show()
end

function InitCtrl:HideLoading()
	if not self.loading_view then
		return
	end
	self.loading_view:Hide()
end

function InitCtrl:SetSceneState(scene_state)
	self.scene_state = scene_state
end

function InitCtrl:SetText(text)
	self.loading_view:SetText(text)
end

function InitCtrl:SetPercent(percent, callback)
	self.loading_view:SetPercent(percent, callback)
end

function InitCtrl:ShowMessageBox(title, content, button_name, complete)
	self.loading_view:ShowMessageBox(title, content, button_name, complete)
end
--

-- level:0,1,2
local function SetQuality(level)
	QualityConfig.QualityLevel = level
	UnityEngine.PlayerPrefs.SetInt("quality_level", level)
end

function InitCtrl:CheckDefaultSetting()
	-- 如果玩家设置了，就不再进入默认设置
	if UnityEngine.PlayerPrefs.HasKey("quality_level") then
		local quality_level = UnityEngine.PlayerPrefs.GetInt("quality_level")
		QualityConfig.QualityLevel = quality_level
		return
	end

	-- gpu, cpu, ram
	local sysInfo = UnityEngine.SystemInfo
	print_log("sysInfo ",
		"\nsupportsImageEffects=",sysInfo.supportsImageEffects,
		"\ndeviceName=", sysInfo.deviceName,
		"\ndeviceModel=", sysInfo.deviceModel,
		"\ndeviceUniqueIdentifier=",sysInfo.deviceUniqueIdentifier,
		"\nsupportsRenderToCubemap=",sysInfo.supportsRenderToCubemap,
		"\nsystemMemorySize=",sysInfo.systemMemorySize,
		"\ngraphicsMemorySize=",sysInfo.graphicsMemorySize,
		"\ngraphicsDeviceID=",sysInfo.graphicsDeviceID,
		"\ngraphicsDeviceName=",sysInfo.graphicsDeviceName,
		"\ngraphicsDeviceVendorID=",sysInfo.graphicsDeviceVendorID,
		"\ngraphicsDeviceType=",sysInfo.graphicsDeviceType,
		"\ngraphicsDeviceVersion=",sysInfo.graphicsDeviceVersion,
		"\ngraphicsShaderLevel=",sysInfo.graphicsShaderLevel,
		"\ngraphicsMultiThreaded=",sysInfo.graphicsMultiThreaded,
		"\nsupportsShadows=",sysInfo.supportsShadows,
		"\ngraphicsDeviceVendor=",sysInfo.graphicsDeviceVendor,
		"\nmaxCubemapSize=",sysInfo.maxCubemapSize
		)

	-- 特殊型号, 直接low品质
	for _, device_name in ipairs(LOW_QUALITY_DEVICE) do
		if device_name == sysInfo.deviceName then
			print_log("[InitCtrl]special device name, set quality to low")
			SetQuality(3)
			return
		end
	end

	for _, graphics_id in ipairs(LOW_QUALITY_GRAPHICS) do
		if graphics_id == sysInfo.graphicsDeviceID then
			print_log("[InitCtrl]special graphics id, set quality to low")
			SetQuality(3)
			return
		end
	end

	-- 不支持特定功能，直接low品质
	if not sysInfo.supportsImageEffects or
		not sysInfo.supportsRenderToCubemap or
		not sysInfo.supportsShadows or
		not sysInfo.graphicsMultiThreaded then
		SetQuality(3)
		return
	end

	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer then
		if UnityEngine.SystemInfo.systemMemorySize <= 1500 then -- 超低配
			SetQuality(3)
		else
			SetQuality(0)
		end
	else
		-- 高配
		if sysInfo.supportedRenderTargetCount >= 4 and
			sysInfo.systemMemorySize >= 3072 and
			sysInfo.graphicsMemorySize >= 500 and
			sysInfo.processorCount >= 4 and
			sysInfo.processorFrequency > 2200 then
			SetQuality(0)
			return
		end

		-- 中配
		if sysInfo.supportedRenderTargetCount >= 2 and
			sysInfo.systemMemorySize >= 2000 and
			sysInfo.graphicsMemorySize >= 400 and
			sysInfo.processorCount >= 2 and
			sysInfo.processorFrequency > 2000 then
			SetQuality(1)
			return
		end

		-- 低配
		if sysInfo.supportedRenderTargetCount >= 2 and
			sysInfo.systemMemorySize >= 1500 and
			sysInfo.graphicsMemorySize >= 256 and
			sysInfo.processorCount >= 2 and
			sysInfo.processorFrequency > 1500 then
			SetQuality(2)
			return
		end

		-- 超低配
		SetQuality(3)
	end
end

function InitCtrl:OnCompleteRequire()
	self.is_require_complete = true
end

function InitCtrl:StartPreLoad()
	local play = nil
	if IS_AUDIT_VERSION then
		play = require("audit_play")
	else
		play = require("play")
	end
	play:SetComplete(function ()
		-- 预加载场景依赖的AB包
		print_log("[loading] start load login scene or cg", os.date())
		LoginCtrl.Instance:PreLoadDependBundles(function (percent)
			self:SetPercent(0.1 * percent + 0.6)
			if percent >= 1 then
				print_log("[loading] finish load login scene or cg", os.date())
				-- 开始预加载
				print_log("[loading] start load preload prefab", os.date())
				PreloadManager.Instance:Start()
				PreloadManager.Instance:WaitComplete(function (percent)
					self:SetPercent(0.29 * percent + 0.7)
					if percent < 1 then
						return
					end
					print_log("[loading] finish load preload prefab", os.date())
					print_log("[loading] start sync load login scene", os.date())
					local login_view_complete_callback = function ()
						self:SetPercent(1, function ()
							print_log("finish login view", os.date())
							local select_role_state = UtilU3d.GetCacheData("select_role_state")
							if select_role_state ~= 1 then
								self:HideLoading()
								self:DestroyLoadingView()
							end
							self:OnComplete()
						end)
					end

					if IS_AUDIT_VERSION then
						-- 打开登录界面
						play:SetTrulyCompleteCallBack(function ()
							LoginCtrl.Instance:ModulesComplete()
						end)
						LoginCtrl.Instance:StartLogin(login_view_complete_callback)
						return
					end
					-- 加载登录场景
					AssetManager.LoadLevelSync(
						"scenes/map/w2_ts_denglu_denglu",
						"W2_TS_DengLu.unity",
						UnityEngine.SceneManagement.LoadSceneMode.Single,
						function()
							if nil ~= LoginView.Instance then
								LoginView.Instance:OnLoadDengluLevelScene("scenes/map/w2_ts_denglu_denglu")
							end

							print_log("[loading] finish sync load login scene", os.date())
							Scheduler.Delay(function()
								-- 预加载Shader
								print_log("[loading] start load login shader", os.date())
								AssetManager.LoadObject(
									"shaders",
									"Preload.shadervariants",
									typeof(UnityEngine.ShaderVariantCollection),
									function(variant)
										if variant ~= nil then
											variant:WarmUp()
										else
											print_error("Can not load the Preload.shadervariants")
										end

										print_log("[loading] finish load login shader", os.date())

										print_log("start open login view", os.date())
										-- 打开登录界面
										LoginCtrl.Instance:StartLogin(login_view_complete_callback)
									end)
							end)
						end)
				end)
			end
		end)
	end)

	PushCtrl(play)
end

function InitCtrl:OnComplete()
	-- 闪屏完成后
	if self.splash_complete then
		print_log("InitCtrl:OnComplete")
		self:Delete()
	else
		self.is_complete = true
	end
end

function InitCtrl:Delete()
	self.ctrl_state = CTRL_STATE.STOP
end

function InitCtrl:DestroyLoadingView()
	self.loading_view:Destroy()
end

--
local function CalculateUpdateSize(update_bundles, file_info)
	local size = 0
	for i,v in ipairs(update_bundles) do
		size = size + file_info:GetSize(v)
	end

	return size
end

function InitCtrl:ShowUpdateBundles(update_bundles, need_restart, complete_callback)
	assert(complete_callback, "[InitCtrl:ShowUpdateBundles]complete_callback is not valid")
	assert(update_bundles, "[InitCtrl:ShowUpdateBundles]update_bundles is not valid")

	print("[InitCtrl:ShowUpdateBundles]#update_bundles=", #update_bundles)
	if #update_bundles <= 0 then
		complete_callback()
		return
	end

	self.complete_callback = complete_callback
	self.need_restart = need_restart
	self.update_total_size = 0
	self.downloaded_size = 0

	AssetManager.LoadFileInfo(function(error, file_info)
		if error ~= nil then
			print_error("LoadFileInfo Failed: ", error)

			complete_callback()
			self.complete_callback = nil
			self.need_restart = nil
			return
		end

		local update_size = CalculateUpdateSize(update_bundles, file_info)
		local update_text = nil
		if update_size > 1024 * 1024 then
			update_text = string.format("检查到版本更新,本次更新内容大约:%dMB,点击确认更新.\n\n<size=22><color=#00ff00>(建议使用WIFI下载新版本)</color></size>", update_size / 1024 / 1024)
		elseif update_size > 1024 then
			update_text = string.format("检查到版本更新,本次更新内容大约:%dKB,点击确认更新.\n\n<size=22><color=#00ff00>(建议使用WIFI下载新版本)</color></size>", update_size / 1024)
		else
			update_text = string.format("检查到版本更新,本次更新内容大约:%dB,点击确认更新.\n\n<size=22><color=#00ff00>(建议使用WIFI下载新版本)</color></size>", update_size)
		end

		print_log("update_size=", update_size)

		self.update_total_size = update_size
		self:UpdateBundles(update_bundles, 1, file_info)
	end)
end

function InitCtrl:UpdateDelayTime(now_time, elapse_time)
	local initctrl_delay_time = UtilU3d.GetCacheData("initctrl_delay_time")
	if nil == initctrl_delay_time then
		UtilU3d.CacheData("initctrl_delay_time", now_time + 2)
	end
	if initctrl_delay_time and now_time > initctrl_delay_time then
		self.is_delay_time = false
		UtilU3d.CacheData("initctrl_delay_time", nil)
		GameRoot.Instance:Restart()
	end
end

function InitCtrl:UpdateBundles(update_bundles, index, file_info)
	if index > #update_bundles then
		-- 写入Version文件
		local version = AssetManager.Manifest:CalculateVersion()
		print_log("Write Version: ", GLOBAL_CONFIG.assets_info.version, version)
		AssetManager.SaveVersion(version)

		-- 继续或者重启
		if self.need_restart then
			GameRoot.Instance:Restart()

			self.complete_callback = nil
			self.need_restart = nil
		else
			self.complete_callback()
			self.complete_callback = nil
			self.need_restart = nil
		end
		return
	end

	local bundle = update_bundles[index]
	local file_size = file_info:GetSize(bundle) or 0

	AssetManager.UpdateBundle(bundle,
		function(progress, download_speed, bytes_downloaded, content_length)
			local p = 0.9 * (index + progress) / #update_bundles
			local speed_in_kb = download_speed / 1024
			local downloaded_mb = (self.downloaded_size + file_size * progress) / 1024 / 1024
			local total_mb = self.update_total_size / 1024 / 1024

			self:SetPercent(p)
			self:SetText(self.scene_state and self.loading_data.UpdateText[2] or self.loading_data.UpdateText[1])

			local tip = string.format(
				"新版本更新: %0.1fMB/%0.1fMB, 速度: %0.1fMB/s", downloaded_mb, total_mb, speed_in_kb / 1024)
			self:SetText(tip)
		end,
		function(error_msg)
			if error_msg ~= nil and error_msg ~= "" then
				print_log("下载: ", bundle, " 失败: ", error_msg)

				-- 最多重试8次
				if not self.update_retry_times or self.update_retry_times < 8 then
					self.update_retry_times = (self.update_retry_times or 0) + 1
					-- 切换下载地址
					if GLOBAL_CONFIG.param_list.update_url2 ~= nil then
						if self.update_retry_times%2 == 1 then
							AssetManager.DownloadingURL = GLOBAL_CONFIG.param_list.update_url2
						else
							AssetManager.DownloadingURL = GLOBAL_CONFIG.param_list.update_url
						end
					end

					self:UpdateBundles(update_bundles, index, file_info)
				else
					self:SetText("您网络不好，正在为您尝试中。。。")
					self.is_delay_time = true
					-- self:ShowMessageBox("下载失败", "下载失败点击[重试]尝试重新更新", "重试", function()
						-- GameRoot.Instance:Restart()
					-- end)
				end
				-- self:ShowMessageBox("下载失败", "下载失败点击[重试]尝试重新更新", "重试", function()
					-- GameRoot.Instance:Restart()
				-- end)
			else
				self.downloaded_size = self.downloaded_size + file_size
				-- 下载成功, 还原网络下载地址
				if self.update_retry_times then
					self.update_retry_times = nil
					AssetManager.DownloadingURL = GLOBAL_CONFIG.param_list.update_url
				end

				-- 继续下载
				self:UpdateBundles(update_bundles, index + 1, file_info)
			end
		end)
end

return InitCtrl