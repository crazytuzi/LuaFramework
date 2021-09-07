ScenePreload = ScenePreload or BaseClass()

ScenePreload.main_scene_bundle_name = ""
ScenePreload.main_scene_asset_name = ""
ScenePreload.detail_scene_bundle_name = ""
ScenePreload.detail_scene_asset_name = ""
ScenePreload.first_load = true
ScenePreload.cache_cg_t = {}
local UnityStaticBatchingUtility = UnityEngine.StaticBatchingUtility

local LOAD_TYPE =
{
	LOAD_PREFAB = 1, 			 	-- 加载prefab到内存
	LOAD_GAMEOBJ = 2,			 	-- 预创建gameobject到对象池（虽快，但1分钟后没用则释放)
	DOWNLOAD = 3,				 	-- 下载bundle
	LOAD_MAIN_SCENE = 4,			-- 加载主场景
	LOAD_DETAIL_SCENE = 5,			-- 加载详细场景
	LOAD_ITEM_CELL = 6,				-- 预创建ItemCell
	LOAD_UNFREE_GAMEOBJECT = 7,		-- 加载不释放的gameobject(即长久在对象池中)
	LOAD_CG = 8,					-- 预加载CG
}

function ScenePreload:__init(show_loading)
	self.progress_fun = nil
	self.main_complete_fun = nil
	self.complete_fun = nil
	self.load_list = {}
	self.load_num_once = 1		-- 每次加载个数
	self.loading_num = 0		-- 正在加载的数量
	self.update_retry_times = 0
	self.download_scene_id = 0
	self.cache_gameobj_list = {}
	self.is_stop_load = false 	-- 是否停止加载
	self.show_loading = show_loading
	self.bytes_total = 0
	self.bytes_loaded = 0
	self.bytes_vir_loaded = 0 	-- 虚拟加载，为了让加载本地的资源时，进度条更平滑

	Runner.Instance:AddRunObj(self, 8)
end

function ScenePreload:__delete()
	self.is_stop_load = true
	self.cache_gameobj_list = {}
	Runner.Instance:RemoveRunObj(self)
end

function ScenePreload:Update(now_time, elapse_time)
	if self.is_stop_load then
		return
	end

	if self.bytes_vir_loaded > 0 then
		local inc_bytes = math.min(self.bytes_vir_loaded, 4)
		self.bytes_vir_loaded = self.bytes_vir_loaded - inc_bytes
		self.bytes_loaded = self.bytes_loaded + inc_bytes
		self:CheckLoadComplete()
		return
	end

	if #self.load_list <= 0 then
		return
	end

	if self.loading_num > 0 then
		return
	end
	local num = math.min(self.load_num_once, #self.load_list)
	for i = 1, num do
		local t = table.remove(self.load_list, 1)

		if LOAD_TYPE.LOAD_PREFAB == t.load_type then
			self:LoadPrefab(t.bundle_name, t.asset_name, t.bytes_total)

		elseif LOAD_TYPE.LOAD_GAMEOBJ == t.load_type then
			self:LoadGameObject(t.bundle_name, t.asset_name, t.bytes_total)

		elseif LOAD_TYPE.DOWNLOAD == t.load_type then
			self:DownloadBundle(t.bundle, t.bytes_total)

		elseif LOAD_TYPE.LOAD_MAIN_SCENE == t.load_type then
			self:LoadUnityMainScene(t.bundle_name, t.asset_name, t.bytes_total)

		elseif LOAD_TYPE.LOAD_DETAIL_SCENE == t.load_type then
			self:LoadUnityDetailScene(t.bundle_name, t.asset_name, t.bytes_total)

		elseif LOAD_TYPE.LOAD_ITEM_CELL == t.load_type then
			self:LoadItemCell(t.bundle_name, t.asset_name, t.bytes_total)
		
		elseif LOAD_TYPE.LOAD_UNFREE_GAMEOBJECT == t.load_type then
			self:LoadUnFreeGameObject(t.bundle_name, t.asset_name, t.bytes_total)
		
		elseif LOAD_TYPE.LOAD_CG == t.load_type then
			self:LoadCG(t.bundle_name, t.asset_name, t.bytes_total)
		end
	end
end

function ScenePreload:StartLoad(scene_id, load_list, download_scene_id, progress_fun, main_complete_fun, complete_fun)
	ScenePreload.DeleteAllCacheCg()

	if ScenePreload.first_load or IsLowMemSystem then  -- 第一次进入场景前或者低内存配置把登陆游戏创角相关的所有释放掉
		Scene.Instance:ReduceMemory(true)
	end
	self.progress_fun = progress_fun
	self.main_complete_fun = main_complete_fun
	self.complete_fun = complete_fun
	self.update_retry_times = 0
	self.is_stop_load = false

	self.load_list = load_list or {}
	self.download_scene_id = download_scene_id
	self.loading_num = 0
	self.bytes_loaded = 0
	self.bytes_vir_loaded = 0
	self.bytes_total = self:GetBytesTotal()

	if self.download_scene_id > 0 then
		ReportManager:Step(Report.STEP_UPDATE_SCENE_BEGIN, self.download_scene_id)
	end

	self:CheckLoadComplete()
end

function ScenePreload:GetBytesTotal()
	local bytes_total = 0
	for _, v in ipairs(self.load_list) do
		bytes_total = bytes_total + v.bytes_total
	end

	return bytes_total
end

-- 预加载prefab到内存
function ScenePreload:LoadPrefab(bundle_name, asset_name, bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes

	PrefabPool.Instance:Load(AssetID(bundle_name, asset_name), function(prefab)
			PrefabPool.Instance:Free(prefab)
			self.loading_num = self.loading_num - 1

			self:CheckLoadComplete()
		end)
end

-- 预加载对象进对象池
function ScenePreload:LoadGameObject(bundle_name, asset_name, bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes

	GameObjectPool.Instance:SpawnAsset(bundle_name, asset_name, function(obj)
		if nil ~= obj then
			table.insert(self.cache_gameobj_list, obj)
		end

		self.loading_num = self.loading_num - 1
		self:CheckLoadComplete()
	end)
end

-- 预加载itemcell进池
function ScenePreload:LoadItemCell(bundle_name, asset_name, bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes

	local prefab = PreloadManager.Instance:GetPrefab(bundle_name, asset_name)
	table.insert(self.cache_gameobj_list, GameObjectPool.Instance:Spawn(prefab, nil))
	self.loading_num = self.loading_num - 1
end

-- 预加载永不释放的动象（没有做free)
function ScenePreload:LoadUnFreeGameObject(bundle_name, asset_name, bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes

	GameObjectPool.Instance:SpawnAsset(bundle_name, asset_name, function(obj)
		if nil ~= obj then
			table.insert(self.cache_gameobj_list, obj)
		end

		GameObjectPool.Instance:SetDefaultReleaseAfterFree(AssetID(bundle_name, asset_name), 9999999)
		self.loading_num = self.loading_num - 1
		self:CheckLoadComplete()
	end)
end

-- 预加载CG到内存（在用完之前不释放）
function ScenePreload:LoadCG(bundle_name, asset_name, bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes

	PrefabPool.Instance:Load(AssetID(bundle_name, asset_name), function(prefab)
			self.loading_num = self.loading_num - 1
			ScenePreload.cache_cg_t[bundle_name .. "_" .. asset_name] = prefab
			self:CheckLoadComplete()
		end)
end

-- 下载bundle
function ScenePreload:DownloadBundle(bundle, bytes)
	self.loading_num = self.loading_num + 1
	local old_progress = self.bytes_loaded

	AssetManager.UpdateBundle(bundle,
		function(progress, download_speed, bytes_downloaded, content_length)
			if self.is_stop_load then
				return
			end

			self.bytes_loaded = old_progress + math.ceil(bytes * progress)
			local speed_in_kb = math.ceil(download_speed / 1024)
			local downloaded_in_kb = math.ceil(bytes_downloaded / 1024)
			local length_in_kb = math.ceil(content_length / 1024)
			local tip = string.format(Language.Common.MapDownload, bundle, downloaded_in_kb, length_in_kb, speed_in_kb)
			self:CheckLoadComplete()
		end,

		function(error_msg)
			if self.is_stop_load then
				return
			end
			if error_msg ~= nil and error_msg ~= "" then
				self.loading_num = self.loading_num - 1
				print_log("下载: ", bundle, " 失败: ", error_msg)

				self.bytes_loaded = old_progress
				self:OnDownloadBundleFail(bundle, bytes)
			else
				if self.update_retry_times > 0 then
					self.update_retry_times = 0
					AssetManager.DownloadingURL = GLOBAL_CONFIG.param_list.update_url
				end

				self.bytes_loaded = old_progress + bytes
				self.loading_num = self.loading_num - 1
				self:CheckLoadComplete()
			end
		end)
end

-- 下载bundle失败后再尝试
function ScenePreload:OnDownloadBundleFail(bundle, bytes)
	if self.update_retry_times < 8 then
		self.update_retry_times = self.update_retry_times + 1
		if GLOBAL_CONFIG.param_list.update_url2 ~= nil then -- 切换下载地址
			if self.update_retry_times % 2 == 1
				and nil ~= GLOBAL_CONFIG.param_list.update_url2
				and "" ~= GLOBAL_CONFIG.param_list.update_url2 then
				AssetManager.DownloadingURL = GLOBAL_CONFIG.param_list.update_url2
			else
				AssetManager.DownloadingURL = GLOBAL_CONFIG.param_list.update_url
			end
		end

		print_log("retry download ", bundle, ", retry times=", self.update_retry_times, ", url=", AssetManager.DownloadingURL)
		self:DownloadBundle(bundle, bytes)
	else
		self.is_stop_load = true
		TipsCtrl.Instance:OpenMessageBox(Language.MapLoading.LoadFail, function()
			GameRoot.Instance:Restart()
		end)
	end
end

-- 加载unity主场景
function ScenePreload:LoadUnityMainScene(bundle_name, asset_name, bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes
	self.main_has_compelet = false
	local load_func = function(need_find_camera)
		self.loading_num = self.loading_num - 1
		ScenePreload.main_scene_bundle_name = bundle_name
		ScenePreload.main_scene_asset_name = asset_name

		if need_find_camera then
			local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(asset_name)
			local has_find = false
			if nil ~= scene then
				local objs = scene:GetRootGameObjects()
				for i = 0, objs.Length - 1 do
					local obj = objs[i]
					local camera = obj:GetComponentInChildren(typeof(UnityEngine.Camera))
					if nil ~= camera then
						if camera.tag == "MainCamera" then
							MainCamera = camera
							has_find = true
							break
						end
					end
				end
			end
			if not has_find then
				MainCamera = UnityEngine.Camera.main
			end
		end

		if not IsNil(MainCamera) then
			MainCamera.farClipPlane = 500
			local camera_follow = MainCamera:GetComponentInParent(typeof(CameraFollow))
			local camera_follow2 = CameraFollow2.Bind(MainCamera.transform.parent.gameObject)
			-- 如果是自由视角
			if CAMERA_TYPE == CameraType.Free then
				MainCameraFollow = camera_follow2
				if camera_follow then
					camera_follow.enabled = false
				end
				Scene.Instance:UpdateCameraSetting()
			else
				camera_follow2.enabled = false				
				MainCameraFollow = MainCamera:GetComponentInParent(typeof(CameraFollow))
			end
		end

		Scheduler.Delay(function()
			self.main_has_compelet = true			
			if self.show_loading then
				self:CheckLoadComplete()
			else
				if self.main_complete_fun ~= nil then
					self.main_complete_fun()
					self.main_complete_fun = nil
				end
			end
		end)
	end

	if ScenePreload.main_scene_asset_name == asset_name then
		load_func(false)
		return
	end

	MainCamera = nil -- 置空，否则在加载过程中用到的camera已经被destory了
	MainCameraFollow = nil

	local load_mode = UnityEngine.SceneManagement.LoadSceneMode.Single
	if nil == UIScene.scene_asset or "" == UIScene.scene_asset then
		load_mode = UnityEngine.SceneManagement.LoadSceneMode.Single
	else
		load_mode = UnityEngine.SceneManagement.LoadSceneMode.Additive
		self:UnLoadScene(ScenePreload.main_scene_asset_name)
	end

	AssetManager.LoadLevelSync(bundle_name, asset_name, load_mode, function ()
		if "" ~= ScenePreload.main_scene_bundle_name then
			AssetManager.UnloadAsseBundle(ScenePreload.main_scene_bundle_name)
		end

		Scheduler.Delay(function()
			load_func(true)
		end)
	end)
end

-- 加载unity详细场景
function ScenePreload:LoadUnityDetailScene(bundle_name, asset_name, bytes)
	self.loading_num = self.loading_num + 1
	self.bytes_vir_loaded = self.bytes_vir_loaded + bytes

	local load_func = function()
		self.loading_num = self.loading_num - 1
		ScenePreload.detail_scene_bundle_name = bundle_name
		ScenePreload.detail_scene_asset_name = asset_name

		self:CheckLoadComplete()
	end

	if ScenePreload.detail_scene_asset_name == asset_name then
		load_func()
		return
	end
	self:UnLoadScene(ScenePreload.detail_scene_asset_name)

	AssetManager.LoadLevel(bundle_name, asset_name, UnityEngine.SceneManagement.LoadSceneMode.Additive, function ()
		if "" ~= ScenePreload.detail_scene_bundle_name then
			AssetManager.UnloadAsseBundle(ScenePreload.detail_scene_bundle_name)
		end

		load_func()
	end)
end

function ScenePreload:UnLoadScene(asset_name)
	if "" ~= asset_name and nil ~= asset_name then
		local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(asset_name)
		if nil ~= scene and scene:IsValid() then
			UnityEngine.SceneManagement.SceneManager.UnloadSceneAsync(asset_name)
		end
	end
end

function ScenePreload:CheckLoadComplete(tip)
	if nil ~= self.progress_fun and self.bytes_total > 0 then
		local precent = math.ceil(self.bytes_loaded / self.bytes_total * 100)

		self.progress_fun(math.min(precent, 100), tip or Language.Common.MapReading)
	end

	if (self.bytes_loaded >= self.bytes_total) and 0 == self.loading_num then
		self:OnLoadComplete()
	end
end

function ScenePreload:OnLoadComplete()
	if self.download_scene_id > 0 then
		ReportManager:Step(Report.STEP_UPDATE_SCENE_COMPLETE, self.download_scene_id)
	end

	for _, v in ipairs(self.cache_gameobj_list) do
		GameObjectPool.Instance:Free(v)  -- 进入对象池，下次取出会很快
	end
	self.cache_gameobj_list = {}

	-- 合批 iphone6包括以下机子不合批
	local is_combine = true
	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer then
		if UnityEngine.iOS.Device.generation:ToInt() <= UnityEngine.iOS.DeviceGeneration.iPhone6SPlus:ToInt() then
			is_combine = false
		end
	end
	if is_combine then
		local static_batching_roots = GameObject.FindGameObjectsWithTag("StaticBatching")
		for i = 0, static_batching_roots.Length - 1 do
			local root = static_batching_roots[i]
			UnityStaticBatchingUtility.Combine(root)
		end
	end

	Scene.Instance:ReduceMemory(IsLowMemSystem)

	if self.show_loading and self.main_has_compelet and self.main_complete_fun ~= nil then
		self.main_complete_fun()
		self.main_complete_fun = nil
	end

	if nil ~= self.complete_fun then
		self.complete_fun()
		self.complete_fun = nil
	end
end

function ScenePreload.DeleteCacheCg(bundle_name, asset_name)
	local key = bundle_name .. "_" .. asset_name
	local prefab = ScenePreload.cache_cg_t[key]
	if nil ~= prefab then
		PrefabPool.Instance:Free(prefab)
		ScenePreload.cache_cg_t[key] = nil
	end
end

function ScenePreload.DeleteAllCacheCg()
	for _, v in pairs(ScenePreload.cache_cg_t) do
		PrefabPool.Instance:Free(v)
	end

	ScenePreload.cache_cg_t = {}
end

-- 获得场景预加载列表，
function ScenePreload.GetLoadList(scene_id)
	local list = {}
	local download_scene_id = 0

	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil ~= scene_cfg then
		-- 加载网络上的场景
		local name_list = {scene_cfg.bundle_name .."_main", scene_cfg.bundle_name .."_detail"}
		for _, v in ipairs(name_list) do
			local uncached_bundles = AssetManager.GetBundlesWithoutCached(v)
			if uncached_bundles ~= nil and uncached_bundles.Length > 0 then
				local update_bundles = uncached_bundles:ToTable()
				for _, v in ipairs(update_bundles) do
					table.insert(list, {load_type = LOAD_TYPE.DOWNLOAD, bundle = v, bytes_total = 100})
					download_scene_id = scene_id
				end
			end
		end

		-- 加载本地场景
		table.insert(list, {load_type = LOAD_TYPE.LOAD_MAIN_SCENE, bundle_name = scene_cfg.bundle_name .. "_main", asset_name = scene_cfg.asset_name .. "_Main", bytes_total = 40})
		table.insert(list, {load_type = LOAD_TYPE.LOAD_DETAIL_SCENE, bundle_name = scene_cfg.bundle_name .. "_detail", asset_name = scene_cfg.asset_name .. "_Detail", bytes_total = 40})
	end

	-- 首次进入指定要加载的prefab
	if ScenePreload.first_load then
		ScenePreload.first_load = false

		ScenePreload.GetLoadSkillList(list)		-- 预加载技能
	end

	ScenePreload.GetLoadCgList(list, scene_id) 	-- 预加载CG

	return list, download_scene_id
end

-- 预加载技能列表(这些配置必须在包里有)
function ScenePreload.GetLoadSkillList(list)
	local prof = GameVoManager.Instance:GetMainRoleVo().prof

	local bundle_name_list = {} 
	if prof == GameEnum.ROLE_PROF_1 then
		table.insert(bundle_name_list, "effects2/prefab/role/nj_prefab")
	end

	if prof == GameEnum.ROLE_PROF_2 then
		table.insert(bundle_name_list, "effects2/prefab/role/1202_prefab")
	end

	if prof == GameEnum.ROLE_PROF_3 then
		table.insert(bundle_name_list, "effects2/prefab/role/nangong_prefab")
	end

	if prof == GameEnum.ROLE_PROF_4 then
		table.insert(bundle_name_list, "effects2/prefab/role/1204_prefab")
	end

	for _, bundle_name in ipairs(bundle_name_list) do
		local assets = AssetManager.GetAssetsNamesInBundle(bundle_name)
		local assets_t = assets:ToTable()
		for _, v in ipairs(assets_t) do
			table.insert(list, {load_type = LOAD_TYPE.LOAD_UNFREE_GAMEOBJECT, bundle_name = bundle_name, asset_name = v, bytes_total = 20})
		end
	end

end

-- 预加载CG列表
function ScenePreload.GetLoadCgList(list, scene_id)
	if IsLowMemSystem then  -- 低内存系统不使用预加载cg
		return
	end

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if scene_id == 2000 or scene_id == 2100 or scene_id == 2200 then
		if 1 == role_level then
			table.insert(list, {load_type = LOAD_TYPE.LOAD_CG, bundle_name = "cg/gz_xsc01_prefab", asset_name = "GZ_Xsc01_Cg1", bytes_total = 20})
		end
	end

	local cfg_list = ConfigManager.Instance:GetAutoConfig("story_auto")["normal_scene_story"] or {}
	for k, v in pairs(cfg_list) do
		if scene_id == v.scene_id and v.operate_param and v.operate_param ~= "" and v.preload == 1 then
			local tab = Split(v.operate_param, "##")
			table.insert(list, {load_type = LOAD_TYPE.LOAD_CG, bundle_name = tab[1], asset_name = tab[2], bytes_total = 20})
		end
	end
end