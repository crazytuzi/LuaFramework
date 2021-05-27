local asset_update = {
	STATE_FATAL 		= -2,
	STATE_ERROR 		= -1,
	STATE_FETCH_INFO	= 0,
	STATE_FETCH_LIST	= 1,
	STATE_FETCH_FILE	= 2,
	STATE_MOVE 			= 3,
	STATE_DONE 			= 4,

	FILE_STATE_ERROR 	= -1,
	FILE_STATE_ADD 		= 0,
	FILE_STATE_REQ 		= 1,
	FILE_STATE_DONE 	= 2,
	FILE_STATE_CALL 	= 3,
	FILE_STATE_MOVE 	= 4,

	FILE_TYPE_DIR		= 0,
	FILE_TYPE_RES 		= 1,
	FILE_TYPE_LUA 		= 2,
	FILE_TYPE_ZIP 		= 3,

	MAX_REQ 			= 5,
	MAX_MOVE			= 32,
	MAX_RETRY			= 16,
	RETRY_DELAY			= 2,

	is_paused			= false,
	net_state			= -1,
	wifi_flag			= -1,
	delay_time			= 0,

	speed				= 0,
	size_total			= 0,
	size_done			= 0,
	size_pend			= 0,

	file_total			= 0,
	file_moved			= 0,

	main_version		= 0,
	temp_version		= 0,

	start_time			= 0,
	task_status			= 0,
}

function asset_update:Name()
	return "asset_update"
end

function asset_update:HostPath(path, file)
	local url = self.update_url
	if self.update_url2 and file and file.retry then
		if (3 == math.mod(math.floor(file.retry / 1), 4)) then
			url = self.update_url2
			print("change host " .. url)
		end
	end

	return url .. path .. '?v=' .. file.ver
end

function asset_update:TempPath(path)
	return self.path_temp .. path
end

function asset_update:MainPath(path)
	if self.STATE_MOVE == self.state then
		return self.path_main .. path
	else
		return path
	end
end

function asset_update:LoadTable(text)
	if nil == text then
		text = "{}"
	end

	local t = nil

	local f = loadstring("local t = " .. text .. " return t")
	if nil ~= f and "function" == type(f) then
		t = f()
	end
	if (nil == t or "table" ~= type(t)) then
		t = {}
	end

	return t 
end

function asset_update:OutOfDate(temp_file, main_file)
	return (nil == main_file or main_file.v ~= temp_file.v or main_file.s ~= temp_file.s)
end

function asset_update:IsPaused()
	if self.is_paused or self.net_state < 1 or (self.STATE_FETCH_FILE == self.state and self.net_state < 2 and 1 ~= self.wifi_flag) then
		return true
	end
end

function asset_update:LoadScript()
	print("LoadScript")
	MainProber:Step(MainProber.STEP_TASK_ASSET_UPDATE_END, self.size_total, self.main_version, self.temp_version)
	if MainProber.Step2 then
		MainProber:Step2(500, MainLoader.assets_ver, self.size_total, NOW_TIME - self.start_time) 
	end

	MainLoader:PushTask(require("scripts/preload/load_script"))
end

function asset_update:CopyFile(file, flag, filtered)
	if filtered then
		UtilEx:removeFile(self:MainPath(file))
		return true
	end

	if self.FILE_TYPE_ZIP == flag then
		local data = UtilEx:readZipText(self:TempPath(file))
		print("copy zip 1 " .. file .. ", " .. string.len(data))
		if nil == data or "" == data then
			return false
		end
		return UtilEx:writeText(self:MainPath(file), data)
	else
		return UtilEx:copyFile(self:TempPath(file), self:MainPath(file))
	end
end

function asset_update:MoveFile()
	if self.STATE_MOVE ~= self.state then
		self:OnError()
		return
	end

	local count_move = 0 all_moved = true
	for k,v in pairs(self.update_list) do
		if self.FILE_STATE_CALL == v.state and "version.txt" ~= k then
			if count_move < self.MAX_MOVE then
				if self:CopyFile(k, v.flag, v.filtered) then
					v.state = self.FILE_STATE_MOVE
				else
					self:OnFatal()
					return
				end
				count_move = count_move + 1
			else
				all_moved = false
				break
			end
		end
	end

	self.file_moved = self.file_moved + count_move

	if all_moved then
		if UtilEx:copyFile(self:TempPath("version.txt"), self:MainPath("version.txt")) then
			self:OnUpdated()
		else
			self:OnFatal()
		end
	end
end

function asset_update:CheckFile()
	if self.STATE_FETCH_INFO > self.state or self.state > self.STATE_FETCH_FILE then
		return
	end

	if self.delay_time > 0 and NOW_TIME < self.delay_time then
		return
	end
	self.delay_time = 0

	local state = self.state
	local count_all = 0 count_error = 0 count_add = 0 count_req = 0 count_done = 0

	for k,v in pairs(self.update_list) do
		count_all = count_all + 1
		
		if self.FILE_STATE_ADD == v.state then
			count_add = count_add + 1

		elseif self.FILE_STATE_REQ == v.state then
			count_req = count_req + 1

		elseif self.FILE_STATE_DONE == v.state then
			if nil ~= v.func then v.func(self, k) end
			v.state = self.FILE_STATE_CALL
			self.size_done = self.size_done + v.size
			if state < self.STATE_FETCH_FILE then break end

		elseif self.FILE_STATE_CALL == v.state then
			count_done = count_done + 1

		elseif self.FILE_STATE_ERROR == v.state then
			count_error = count_error + 1
		end
	end

	if 0 ~= count_error then
		self:OnError()
		return
	end

	if self.STATE_FETCH_FILE == state and count_done >= count_all then
		self:OnFetched()
		return
	end

	if count_req >= self.MAX_REQ then
		return
	end

	if self:IsPaused() then
		return
	end

	for k,v in pairs(self.update_list) do
		if count_req >= self.MAX_REQ then
			break
		end

		if self.FILE_STATE_ADD == v.state then
			local timeout = (v.size / 10000) + (5 * v.retry) + 5;
			if self.downloader:addRequest(self:HostPath(k, v), self:TempPath(k), timeout) then
				v.state = self.FILE_STATE_REQ
				count_req = count_req + 1
			else
				self:RetryFile(k, v)
				break
			end
		end
	end
end

function asset_update:RetryFile(path, file)
	local timeout = (file.size / 10000) + (5 * file.retry) + 5;
	MainProber:Warn(MainProber.EVENT_ASSET_RETRY or 10017, path, file.retry, timeout)

	file.retry = file.retry + 1
	if file.retry >= self.MAX_RETRY then
		MainProber:Warn(MainProber.EVENT_UPDATE_RETRY, path, file.retry)
		file.state = self.FILE_STATE_ERROR
	else
		file.state = self.FILE_STATE_ADD
		self.delay_time = NOW_TIME + self.RETRY_DELAY
	end
end

function asset_update:FetchFile(path, ver, md5, size, func, force, flag, filtered)
	local file = { ver = ver or 0, md5 = md5, size = size, func = func, state = self.FILE_STATE_ADD, retry = 0, flag = flag, filtered = filtered }
	self.update_list[path] = file

	if filtered then
		file.state = self.FILE_STATE_CALL
	else
		if (not force) and UtilEx:checkFile(self:TempPath(path), md5, size) then
			file.state = self.FILE_STATE_DONE
		else
			print("fetch host " .. self:HostPath(path, file))
		end
		self.size_total = self.size_total + size
	end

	self.file_total = self.file_total + 1
end

function asset_update:FilterFile(path)
	local filtered = false
	local b1, e1 = string.find(path, "res/", 1, false)
	if nil ~= b1 then
		local b2, e2 = string.find(path, "/", e1 + 1, false)
		if nil ~= b2 then
			local dir = string.sub(path, e1 + 1, b2 - 1)
			if "chibang" == dir or "monster" == dir or "mount" == dir or "peri" == dir or "pet" == dir or "role" == dir or "wuqi" == dir or "spirit" == dir then
				local path2 = string.sub(path, 6)
				if not self.file_util:isFileExist(self.path_inner .. path2) then
					filtered = true 
					print("filter file " .. path2)
				end
			end
		end
	end

	return filtered
end

function asset_update:OnFileFetched(url, path, data, size)
	local file_path = path
	path = string.sub(file_path, string.len(self.path_temp) + 1, -1)
	if nil == path then
		self:OnError()
		return
	end

	local file = self.update_list[path]
	if nil == file then
		self:OnError()
		return
	end

	if size > 0 and UtilEx:checkFile(file_path, file.md5, file.size) then
		file.state = self.FILE_STATE_DONE
		print("fetch succ " .. path .. " " .. size)
	else
		self:RetryFile(path, file)
		print("fetch fail " .. path .. " " .. file.retry)
	end
end

function asset_update:OnInfoFetched(path)
	self.temp_version = 0
	self.main_version = 0

	local info_temp = cjson.decode(UtilEx:readText(self:TempPath(path)))
	local info_main = cjson.decode(UtilEx:readText(self:MainPath(path)))

	if nil ~= info_temp and nil ~= info_temp.version then
		self.temp_version = info_temp.version
	end

	if nil ~= info_main and nil ~= info_main.version then
		self.main_version = info_main.version
	end

	MainProber:Step(MainProber.STEP_TASK_ASSET_UPDATE_BEG, self.update_url, self.main_version, self.temp_version)
	if MainProber.Step2 then MainProber:Step2(400, self.temp_version, self.update_url) end

	if 0 == self.temp_version then
		self:OnError()
		return
	end

	if 0 ~= self.main_version and self.main_version >= self.temp_version then
		self:OnNothing()
		return 
	end

	if nil == info_temp.file_list or nil == info_temp.file_list.path then
		self:OnError()
		return
	end

	self:FetchFile(info_temp.file_list.path, self.temp_version, info_temp.file_list.md5, info_temp.file_list.size, self.OnListFetched, true, 1, false)
	self.state = self.STATE_FETCH_LIST
end

function asset_update:OnListFetched(path)
	local list_temp = self:LoadTable(UtilEx:readZipText(self:TempPath(path)))
	local list_main = self:LoadTable(UtilEx:readZipText(self:MainPath(path)))

	local path_list = self.file_util:getSearchPaths()
	local inner_list = GetInnerPathList(path_list)
	self.file_util:setSearchPaths(inner_list)

	for k,v in pairs(list_temp) do
		if self.FILE_TYPE_DIR ~= v.t and self:OutOfDate(v, list_main[k]) then
			self:FetchFile(k, v.v, "", v.s, nil, nil, v.t, self:FilterFile(k))
		end
	end
	self.file_util:setSearchPaths(path_list)

	self.state = self.STATE_FETCH_FILE
end

function asset_update:OnFatal()
	self.state = self.STATE_FATAL
	self.task_status = MainLoader.TASK_STATUS_EXIT

	print("OnFatal")
	MainProber:Warn(MainProber.EVENT_UPDATE_FATAL)
end

function asset_update:OnError()
	self.state = self.STATE_ERROR
	self.task_status = MainLoader.TASK_STATUS_EXIT

	print("OnError")
	MainProber:Warn(MainProber.EVENT_UPDATE_ERROR)
end

function asset_update:OnFetched()
	self.state = self.STATE_MOVE
	print("OnFetched")
end

function asset_update:OnNothing()
	self.state = self.STATE_DONE
	self.task_status = MainLoader.TASK_STATUS_DONE
	if IS_IOS_OR_ANDROID then
		UtilEx:removeFile(self.path_temp)
	end
	print("OnNothing")

	self:LoadScript()
end

function asset_update:OnUpdated()
	self.state = self.STATE_DONE
	self.task_status = MainLoader.TASK_STATUS_DONE
	if IS_IOS_OR_ANDROID then
		UtilEx:removeFile(self.path_temp)
	end
	print("OnUpdated")

	self:LoadScript()
end

function asset_update:Start()
	if 0 ~= self.start_time then return end

	self.update_url = GLOBAL_CONFIG.param_list.update_url
	self.update_url2 = GLOBAL_CONFIG.param_list.update_url2
	self.path_root = UtilEx:getDataPath()
	self.path_temp = self.path_root .. "temp/"
	self.path_main = self.path_root .. "main/"

	self.file_util = cc.FileUtils:getInstance()
	self.path_inner = GetInnerPathRoot(self.file_util:getSearchPaths())

	self.update_list = {}
	self.delete_list = {}

	self.downloader = HttpDownloader:create()
	if nil == self.downloader then
		self:OnError()
		return
	end
	self.downloader:retain()
	self.downloader:setCallback(LUA_CALLBACK(self, self.OnFileFetched))

	self:FetchFile("version.txt", 0, "", -1, self.OnInfoFetched, force_fetch_version, 1, false)
	self.state = self.STATE_FETCH_INFO

	self.net_state = PlatformAdapter:GetNetState()
	self.delay_time = 0
	self.speed = 0
	self.size_total = 0
	self.size_done = 0
	self.size_pend = 0

	self.start_time = NOW_TIME
	self.task_status = MainLoader.TASK_STATUS_FINE
end

function asset_update:Update()
	if nil ~= self.downloader then
		self.speed = self.downloader:getDownloadSpeed()
		self.size_pend = self.downloader:getDownloadSize()
	else
		self.speed = 0
		self.size_pend = 0
	end

	if self.STATE_ERROR < self.state and self.state < self.STATE_MOVE then
		self:CheckFile()
	elseif self.STATE_MOVE == self.state then
		self:MoveFile()
	end

	return self.task_status
end

function asset_update:Stop()
	if 0 == self.start_time then return end

	if nil ~= self.downloader then
		self.downloader:release()
		self.downloader = nil
	end
	
	self.delete_list = nil
	self.update_list = nil

	self.path_main = nil
	self.path_temp = nil
	self.path_root = nil
	self.update_url = nil
	self.update_url2 = nil

	self.is_paused = false
	self.net_state = -1
	self.wifi_flag = -1
	self.delay_time = 0

	self.speed = 0
	self.size_total = 0
	self.size_done = 0
	self.size_pend = 0

	self.temp_version = 0
	self.main_version = 0

	self.start_time = 0
	self.task_status = 0
end

function asset_update:Status()
	return self.state, 
	self.size_total, (self.size_done + self.size_pend), 
	self.file_total, self.file_moved, 
	self.speed, self.net_state, self.wifi_flag, 
	self.is_paused
end

function asset_update:Pause()
	self.is_paused = true
end

function asset_update:Resume()
	self.net_state = PlatformAdapter:GetNetState()
	self.is_paused = false
end

function asset_update:NetStateChanged(net_state)
	self.net_state = net_state
	print("asset_update:NetStateChanged = " .. net_state)
end

function asset_update:SetWifiFlag(wifi_flag)
	self.wifi_flag = wifi_flag
end

return asset_update
