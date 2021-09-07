require("game/scene/loading/scene_preload")
SceneLoading = SceneLoading or BaseClass(BaseView)

local UICamera = GameObject.Find("GameRoot/UICamera")
local post_effects = UICamera:GetComponent(typeof(PostEffects))

function SceneLoading:__init()
	self.ui_config = {"uis/views/miscpreload","SceneLoadingView"}
	self.loading_data = require("init/init_loading_data")
	self.view_layer = UiLayer.SceneLoading
	self.view_name = ViewName.SceneLoading

	self.notice_str_list = {}
	self.main_complete_callback = nil
	self.complete_callback = nil
	self.preload_complete = false
	self.cur_precent = 0
	self.bg = nil
	self.notice = nil
	self.progress = nil
	self.percent = nil
	self.delay_close_timer = nil
	self.audit_percent = nil
	self.is_scene_loading = false
	self.is_wait_load = false
	self.full_screen = true

	self.start_loading_callback = nil
	self.scene_preload = nil
	self.show_loading = true
end

function SceneLoading:ReleaseCallBack()
	self:StopTimer()
	self:StopScenePreload()

	-- 清理变量和对象
	self.percent = nil
	self.progress = nil
	self.fade = nil
	self.audit_percent = nil
end

function SceneLoading:SetStartLoadingCallback(start_loading_callback)
	self.start_loading_callback = start_loading_callback
end

function SceneLoading:Load(index)
	self.bundle_name, self.asset_name = self:GetRandomAsset()
	TexturePool.Instance:Load(
		AssetID(self.bundle_name, self.asset_name),
		function(texture)
			TexturePool.Instance:Free(texture)
			BaseView.Load(self, index)
		end, true)
end

function SceneLoading:OpenCallBack()
	local show_audit = self:FindVariable("ShowAudit")
	if show_audit ~= nil then
		show_audit:SetValue(IS_AUDIT_VERSION)
	end

	if self.show_loading then
		self:FindVariable("ShowLoading"):SetValue(true)
		local is_show_agent = false
		if AssetManager.ExistedInStreaming("AgentAssets/scene_loading_bg.png") then
			is_show_agent = true
		else 
			self:FindVariable("Bg"):SetAsset(self.bundle_name, self.asset_name)
		end

		local show_flag = self:FindVariable("ShowAgentBg")
		if show_flag ~= nil then
			show_flag:SetValue(is_show_agent)
		end

		if is_show_agent then
			local res_url = UnityEngine.Application.streamingAssetsPath.."/AgentAssets/scene_loading_bg.png"
			local agent_bg = self:FindVariable("AgentRes")
			if agent_bg ~= nil then
				agent_bg:SetValue(res_url)
			end
		end
		
		self:FindVariable("Notice"):SetValue(self:GetRandomNoticeStr())

		self.percent = self:FindVariable("Percent")
		self.percent:SetValue(0)

		self.progress = self:FindVariable("Progress")
		self.progress:SetValue(0)
		self:CheckStart()

		self.audit_percent = self:FindVariable("AuditPercent")
	else
		self:FindVariable("ShowLoading"):SetValue(false)
		self.fade = self:FindObj("Fade")
		self.fade.image.color = Color.New(0, 0, 0, 0)
		--self.fade.image:DOFade(1.0, 0.5)
		post_effects.EnableBlur = true
		post_effects.BlurSpread = 0.0
		post_effects.WaveStrength = 0.0
		post_effects:DoBlurSpread(2.5, 1.5)
		post_effects:DoWave(1.0, 1.5)

		GlobalTimerQuest:AddDelayTimer(function()
			self:CheckStart()
		end, 1.5)
	end
end

function SceneLoading:Start(scene_id, main_complete_callback, complete_callback)
	if self.scene_id == scene_id and self.is_scene_loading then
		return
	end

	self:StopTimer()
	local last_scene_loading = self.is_scene_loading
	self.is_scene_loading = true
	local old_scene_id = self.scene_id
	self.scene_id = scene_id
	self.main_complete_callback = main_complete_callback
	self.complete_callback = complete_callback
	self.is_wait_load = true

	self.load_list, self.download_scene_id = ScenePreload.GetLoadList(scene_id)

	-- 如果上个场景触发了水纹效果，但是在场景没加载完之前，又切换了新的场景，则会导致水纹效果没有还原
	if not self.show_loading then
		self:ResetPostEffects()
	end

	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	self.show_loading = scene_cfg.skip_loading == nil or scene_cfg.skip_loading == 0
	if self.download_scene_id > 0 or nil == old_scene_id then
		self.show_loading = true
	end

	self.full_screen = self.show_loading

	self:Open()
	if self.show_loading or last_scene_loading then
		self:CheckStart()
	end
end

function SceneLoading:CheckStart()
	if self:IsLoaded() and self.is_wait_load then
		self.is_wait_load = false
		self:DoStart()
	end
end

function SceneLoading:DoStart()
	if nil ~= self.start_loading_callback then
		self.start_loading_callback(self.scene_id)
		self.start_loading_callback = nil
	end

	self:StopTimer()
	self:StopScenePreload()
	self.cur_precent = 0

	-- 把音效音量降为0
	AudioService.Instance:SetSFXVolume(0)

	self.scene_preload = ScenePreload.New(self.show_loading)
	self.scene_preload:StartLoad(self.scene_id,
		self.load_list,
		self.download_scene_id,
		BindTool.Bind(self.OnSceneLoadProgress, self),
		BindTool.Bind(self.OnMainSceneLoadComplete, self),
		BindTool.Bind(self.OnSceneLoadComplete, self))
end

function SceneLoading:OnSceneLoadProgress(per_value, tip)
	-- print("OnSceneLoadProgress ----- ", per_value, " ", debug.traceback())
	if nil ~= self.percent then
		local content = string.format("%s 【%d%%】", tip, per_value)
		self.percent:SetValue(content)
	end

	if nil ~= self.progress then
		self.progress:SetValue(per_value / 100)
	end

	if nil ~= self.audit_percent and IS_AUDIT_VERSION then
		self.audit_percent:SetValue(per_value)
	end
end

function SceneLoading:IsSceneLoading()
	return self.is_scene_loading
end

function SceneLoading:OnMainSceneLoadComplete()
	self.is_scene_loading = false
	if not self.show_loading then
		self:ResetPostEffects()
	end

	if nil ~= self.main_complete_callback then
		self.main_complete_callback(self.scene_id)
		self.main_complete_callback = nil
	end
end

function SceneLoading:OnSceneLoadComplete()
	if nil ~= self.complete_callback then
		self.complete_callback(self.scene_id)
		self.complete_callback = nil
	end
	self.scene_id = 0

	-- 为了效果，特意延迟关闭（因为在场景加载完成处可能会在下一帧才创建对象，比如从对象池中取cg）
	-- 关闭加载界面后，是一个较完整的画面
	self:StopTimer()
	self.delay_close_timer = GlobalTimerQuest:AddDelayTimer(function ()
		self.delay_close_timer = nil
		-- 还原音效音量
		local volume = 1
		if SettingData.Instance:GetSettingData(SETTING_TYPE.CLOSE_SOUND_EFFECT) then
			volume = 0
		end
		AudioService.Instance:SetSFXVolume(volume)
		self:Close()
	end, 0.25)
end

function SceneLoading:StopTimer()
	if nil ~= self.delay_close_timer then
		GlobalTimerQuest:CancelQuest(self.delay_close_timer)
		self.delay_close_timer = nil
	end
end

function SceneLoading:StopScenePreload()
	if nil ~= self.scene_preload then
		self.scene_preload:DeleteMe()
		self.scene_preload = nil
	end
end

function SceneLoading:GetRandomNoticeStr()
	if #self.notice_str_list < 1 then
		local temp_list = {}
		for k,v in pairs(self.loading_data.Reminding) do
			table.insert(temp_list, v)
		end
		self.notice_str_list = temp_list
	end
	local index = math.random(1, #self.notice_str_list)
	local str = self.notice_str_list[index]
	table.remove(self.notice_str_list, index)

	return str
end

function SceneLoading:GetRandomAsset()
	local temp_list = self.loading_data.SceneImages
	local index = math.random(1, #temp_list)
	local asset = temp_list[index] or {}
	return asset[1], asset[2]
end

function SceneLoading:ResetPostEffects()
	if self.fade ~= nil then
		--self.fade.image:DOFade(0.0, 0.5)
		post_effects.BlurSpread = 0.0
		post_effects.WaveStrength = 0.0
		post_effects.EnableBlur = false
	end
end