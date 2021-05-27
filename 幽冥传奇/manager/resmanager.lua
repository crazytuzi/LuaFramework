
ResManager = ResManager or BaseClass(BaseController)

function ResManager:__init()
	if ResManager.Instance then
		ErrorLog("[ResManager] attempt to create singleton twice!")
		return
	end
	ResManager.Instance = self

	self.file_utils = cc.FileUtils:getInstance()
	self.temp_path_root = ""						-- 下载资源临时目录
	self.temp_path_root_len = 0
	self.res_path_root = ""							-- 处部资源根目录
	self.inner_res_path_root = ""					-- 内部资源根目录
	self.update_url = ""
	self.update_url2 = ""

	self.is_init = false
	self.can_dynamic_download = false				-- 是否支持动态下载
	self.exist_file_list = {}
	self.ver_list = nil

	self.loading_count = 0
	self.download_list = {}
	self.download_callback = BindTool.Bind1(self.DownloadCallback, self)

	self.load_scene_id_list = {}					-- 下载的场景id列表，包括正在下的
	self.load_scene_res_id_list = {}				-- 下载的场景resid列表，包括正在下的

	self.res_id_to_scene_id = {						-- 资源id对应的原始场景id
		[1101] = 6001,
		[1102] = 6002,
		[1103] = 6003,
		[1201] = 7001,
		[1202] = 7002,
	}
end

function ResManager:__delete()
	Runner.Instance:RemoveRunObj(self)
end

function ResManager:Init()
	if self.is_init then
		return
	end

	self.is_init = true

	if nil == AgentAdapter.IsDynamicDownloadRes or not AgentAdapter:IsDynamicDownloadRes() then
		self.can_dynamic_download = false
		return
	end

	self.temp_path_root = UtilEx:getDataPath() .. "temp/data/res/"
	self.temp_path_root_len = string.len(self.temp_path_root)
	self.res_path_root = UtilEx:getDataPath() .. "main/data/res/"
	self.update_url = GLOBAL_CONFIG.param_list.update_url .. "data/res/"
	if nil ~= GLOBAL_CONFIG.param_list.update_url2 then
		self.update_url2 = GLOBAL_CONFIG.param_list.update_url2 .. "data/res/"
	end

	local search_path_list = self.file_utils:getSearchPaths()
	self.inner_res_path_root = search_path_list[2] .. "res/"	-- 固定取第二个

	Runner.Instance:AddRunObj(self, 3)
end

function ResManager:InitVersionList()
	local text = UtilEx:readZipText(UtilEx:getDataPath() .. "main/list.zip")
	if nil == text or "" == text then
		text = UtilEx:readZipText(PlatformAdapter.GetListZipPath())
	end
	if nil == text or "" == text then
		text = "{}"
	end

	local f = loadstring("local t = " .. text .. " return t")
	if nil ~= f and "function" == type(f) then
		self.ver_list = f()
	end

	if nil == self.ver_list then
		self.ver_list = {}
	end
end

function ResManager:Update(now_time, elapse_time)
	if self.loading_count >= 1 then
		return
	end

	for k, v in pairs(self.download_list) do
		if not v.is_loading then
			self.loading_count = self.loading_count + 1
			v.url = self:HostPath(k, v.load_times, v.ver)
			v.is_loading = true
			v.load_times = v.load_times + 1
			HttpClient:Download(v.url, self.temp_path_root .. k, self.download_callback)
		end
	end
end

-- 判断文件是否存在， 不支持动态下载的渠道直接返回true
function ResManager:IsFileExist(path)
	if not self.can_dynamic_download then
		return true
	end

	if self.exist_file_list[path] then
		return true
	end

	if self.file_utils:isFileExist(self.res_path_root .. path) then
		self.exist_file_list[path] = true
		return true
	end

	if self.file_utils:isFileExist(self.inner_res_path_root .. path) then
		self.exist_file_list[path] = true
		return true
	end

	return false
end

-- 下载资源，返回要下载的资源大小
function ResManager:AddDownload(path, callback)
	local info = self.download_list[path]
	if nil == info then
		if nil == self.ver_list then
			self:InitVersionList()
		end

		local file_ver = 0
		local file_size = 10240
		local cfg = self.ver_list["data/res/" .. path]
		if nil ~= cfg then
			file_ver = cfg.v or 0
			file_size = cfg.s or 10240
		end

		info = {url = "", callback_list = {callback}, ver = file_ver, size = file_size, is_loading = false, load_times = 0}
		self.download_list[path] = info
	else
		table.insert(info.callback_list, callback)
	end

	return info.size
end

function ResManager:DownloadCallback(url, temp_path, size)
	local path = string.sub(temp_path, self.temp_path_root_len + 1, -1)
	local info = self.download_list[path]
	if nil == info then
		if size > 0 then
			UtilEx:copyFile(temp_path, self.res_path_root .. path)
		end
		return
	end

	self.loading_count = self.loading_count - 1

	if size <= 0 then
		if info.load_times < 10 then
			info.is_loading = false
			return
		end
		print("load fail:", url)
	else
		size = info.size
		UtilEx:copyFile(temp_path, self.res_path_root .. path)
	end

	self.download_list[path] = nil

	for k, v in pairs(info.callback_list) do
		v(path, size)
	end
end

-- 取消全部下载
function ResManager:CancelAll()
	for k, v in pairs(self.download_list) do
		HttpClient:CancelDownload(v.url, self.download_callback)
	end

	self.download_list = {}
	self.loading_count = 0
end

function ResManager:HostPath(path, load_times, file_ver)
	if 0 == math.mod(load_times, 2) and "" ~= self.update_url2 then
		return self.update_url2 .. path .. '?v=' .. file_ver
	end

	return self.update_url .. path .. '?v=' .. file_ver
end

-- 切换场景，返回需要下载的资源总大小，old_scene_type == nil表示第一次进场景
function ResManager:ChangeScene(scene_id, callback, old_scene_type)
	self:Init()

	if not self.can_dynamic_download then
		return 0
	end

	return self:AddSceneRes(scene_id, callback)
end

-- 添加场景资源
function ResManager:AddSceneRes(scene_id, callback)
	if nil == Config_scenelist[scene_id] or nil == Config_scenelist[scene_id].res_id then
		return 0
	end

	if nil ~= self.load_scene_id_list[scene_id] then
		return 0
	end
	self.load_scene_id_list[scene_id] = true

	local scene_res_id = Config_scenelist[scene_id].res_id
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	local res_scene_cfg = ConfigManager.Instance:GetSceneConfig(self.res_id_to_scene_id[scene_res_id] or scene_res_id)
	if nil == scene_cfg or nil == res_scene_cfg then
		return 0
	end

	local size = 0

	if nil == self.load_scene_res_id_list[scene_res_id] then
		self.load_scene_res_id_list[scene_res_id] = true

		-- 小地图
		size = size + self:AddNotExistRes(string.format("scene/%d/small.jpg", scene_res_id), callback)

		-- 图块
		local max_x = math.floor((res_scene_cfg.width + 511) / 512) - 1
		local max_y = math.floor((res_scene_cfg.height + 511) / 512) - 1
		for x = 0, max_x do
			for y = 0, max_y do
				size = size + self:AddNotExistRes(string.format("scene/%d/front/pic%d_%d.jpg", scene_res_id, x, y), callback)
			end
		end
	end

	return size
end

function ResManager:AddNotExistRes(path, callback)
	if self.file_utils:isFileExist(self.res_path_root .. path) then
		return 0
	end

	if self.file_utils:isFileExist(self.inner_res_path_root .. path) then
		return 0
	end

	return self:AddDownload(path, callback)
end
