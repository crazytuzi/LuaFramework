local InitDownload = {
	ctrl_state = CTRL_STATE.START,
}

local UpdateAssetBundles = require("config/config_strong_update")

local RestartAssetBundles = {
	"^lua/.*",
	"^luajit/.*",
}

local platform = UnityEngine.Application.platform
if platform ~= UnityEngine.RuntimePlatform.WindowsEditor then  -- editor模式不加载lua
	if platform == UnityEngine.RuntimePlatform.IPhonePlayer or
		platform == UnityEngine.RuntimePlatform.WindowsPlayer then
		table.insert(UpdateAssetBundles, "^lua/.*")
	else
		table.insert(UpdateAssetBundles, "^luajit/.*")
	end
end

local function NeedUpdate(bundle_name)
	for i,v in ipairs(UpdateAssetBundles) do
		if string.match(bundle_name, v) then
			return true
		end
	end

	return false
end

local function NeedRestart(bundle_name)
	for i,v in ipairs(RestartAssetBundles) do
		if string.match(bundle_name, v) then
			return true
		end
	end

	return false
end

function InitDownload:Start()
	print_log("update_url = ", GLOBAL_CONFIG.param_list.update_url)
	AssetManager.DownloadingURL = GLOBAL_CONFIG.param_list.update_url
	ReportManager:Step(Report.STEP_REQUEST_REMOTE_MANIFEST)

	if IS_AUDIT_VERSION and not GLOBAL_CONFIG.param_list.switch_list.update_assets then
		AssetManager.LoadLocalManifest("AssetBundle")
		self:OnUpdateComplete()
	else
		AssetManager.LoadRemoteManifest("AssetBundle", function(error)
			self:OnLoadRemoteManifest(error)
		end)
		InitCtrl:SetText("正在下载游戏资源，请稍等")
	end
end

function InitDownload:Update(now_time, elapse_time)
	if self.ctrl_state == CTRL_STATE.START then
		self.ctrl_state = CTRL_STATE.UPDATE
		self:Start()
	elseif self.ctrl_state == CTRL_STATE.STOP then
		self.ctrl_state = CTRL_STATE.NONE
		self:Stop()
		PopCtrl(self)
	end
end

function InitDownload:Stop()
end

function InitDownload:OnLoadRemoteManifest(error_msg)
	print_log("Load Remote Manifest finished")

	-- Skip when the server notify do not update assets
	--if not GLOBAL_CONFIG.param_list.switch_list.update_assets then
	--	self:OnUpdateComplete()
	--	return
	--end

	if IS_AUDIT_VERSION and not GLOBAL_CONFIG.param_list.switch_list.update_assets then
		self:OnUpdateComplete()
		return
	end

	if error_msg ~= nil then
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
			else
				ReportManager:Step(Report.STEP_REQUEST_REMOTE_MANIFEST_FAILED)
				-- InitCtrl:ShowMessageBox("下载失败", "下载失败:"..error_msg, "重试", function()
					GameRoot.Instance:Restart()
				-- end)
			end

			AssetManager.LoadRemoteManifest("AssetBundle", function(error)
				self:OnLoadRemoteManifest(error)
			end)
		else
			ReportManager:Step(Report.STEP_REQUEST_REMOTE_MANIFEST_FAILED)
			-- InitCtrl:ShowMessageBox("下载失败", "下载失败:"..error_msg, "重试", function()
				GameRoot.Instance:Restart()
			-- end)
		end

		return
	end

	if self.update_retry_times then
		self.update_retry_times = nil
		AssetManager.DownloadingURL = GLOBAL_CONFIG.param_list.update_url
	end

	-- Skip when using the simulate asset bundle mode.
	local manifest = AssetManager.Manifest
	if manifest == nil then
		self:OnUpdateComplete()
		return
	end

	-- Find the update bundles
	self.need_restart = false
	local update_bundles = {}
	local bundles = manifest:GetAllAssetBundles()
	bundles = bundles:ToTable()
	for i,v in ipairs(bundles) do
		if NeedUpdate(v) then
			if not AssetManager.IsVersionCached(v) then
				if NeedRestart(v) then
					self.need_restart = true
				end

				table.insert(update_bundles, v)
			end
		end
	end

	-- show loading
	ReportManager:Step(Report.STEP_UPDATE_ASSET_BUNDLE)
	InitCtrl:ShowUpdateBundles(update_bundles, self.need_restart, function()
		self:OnUpdateComplete()
	end)
end

function InitDownload:OnUpdateComplete()
	print_log("[POINT]InitDownload:OnUpdateComplete")
	ReportManager:Step(Report.STEP_UPDATE_ASSET_BUNDLE_COMPLETE)
	AssetManager.IgnoreHashCheck = false
	PushCtrl(require("init/init_require"))
	self.ctrl_state = CTRL_STATE.STOP
end

return InitDownload
