CompleteBagData = CompleteBagData or BaseClass()

CompleteBagData.Normal = 0
CompleteBagData.Loading = 1
CompleteBagData.ItemFinish = 2
CompleteBagData.ItemError = 3

CompleteBagData.AchieveID = 295

function CompleteBagData:__init()
	if CompleteBagData.Instance then
		ErrorLog("[CompleteBagData]:Attempt to create singleton twice!")
	end
	CompleteBagData.Instance = self

	self.update_url = GLOBAL_CONFIG.param_list.update_url
	self.update_url2 = GLOBAL_CONFIG.param_list.update_url2
	self.total_file = 0
	self.has_loaded = 0
	self.total_size = 0
	self.loaded_size = 0
	self.progress_time = 0
	self.recored_time = 0
	
	self.asset_list = {}
	self.temp_asset_list = {}
	self.main_asset_list = {}
	
	self.is_check_complete = false
	self.is_achieve_complete = false
	self.is_init_mainrole = false
	self.check_queue = {}

	self.last_time = cc.UserDefault:getInstance():getIntegerForKey("down_load_last_time") or 0
	self.is_auto_down = cc.UserDefault:getInstance():getIntegerForKey("auto_down_load") or 1
	self.is_down_ing = cc.UserDefault:getInstance():getIntegerForKey("down_loading") or 0

	if self.is_down_ing > 0 then
		if self.is_auto_down < 1 then
			self.is_down_ing = 0
		end	
	end	

	--print("记录数据:",self.last_time,self.is_auto_down,self.is_down_ing)
	

	self.achieve_handler = GlobalEventSystem:Bind(AchievementEventType.ACHIEVE_DATA_CHANGE,BindTool.Bind(self.OnAchieveChange,self))
	self.check_all_handler = GlobalEventSystem:Bind(CompleteBagEvent.CHECKALLCOMPLETE,BindTool.Bind(self.CheckAllComplete,self))
	self.role_init_handler = GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO,BindTool.Bind(self.OnRoleCallBack,self))

	self:CheckCompleteBagData()
end

function CompleteBagData:__delete()
	if self.achieve_handler then
		GlobalEventSystem:UnBind(self.achieve_handler)
		self.achieve_handler = nil
	end
	if self.check_all_handler then
		GlobalEventSystem:UnBind(self.check_all_handler)
		self.check_all_handler = nil
	end
	if self.role_init_handler then
		GlobalEventSystem:UnBind(self.role_init_handler)
		self.role_init_handler = nil
	end
	CompleteBagData.Instance = nil
end

function CompleteBagData:OnRoleCallBack()
	self.is_init_mainrole = true
	self:CheckAllComplete()
end	

function CompleteBagData:CheckAllComplete()
	--print("状态:",self.is_check_complete,self.is_init_mainrole,self.total_file,self.is_auto_down,self.is_down_ing,TimeCtrl.Instance:GetServerTime())
	if self.is_check_complete and self.is_init_mainrole then
		if self.total_file > 0 then
			if self.is_auto_down > 0 and self.is_down_ing > 0 then
				if TimeCtrl.Instance:GetServerTime() - self.last_time < 900 then
					self:Start()
					self:RecordStart()
					return
				end	
			end	
		end	
		self:End()	
		self:RecordEnd()
	end	
end

function CompleteBagData:OnAchieveChange()
	if self.achieve_handler then
		GlobalEventSystem:UnBind(self.achieve_handler)
		self.achieve_handler = nil
	end
	self.is_achieve_complete = true
	if self.total_file <= 0  and self.is_achieve_complete and self.is_check_complete then
		CompleteBagCtrl.Instance:SendFinishDownload() --完成成就通知
		GlobalEventSystem:Fire(CompleteBagEvent.COMPLETE,self.has_loaded,self.total_file)
	end
end	


function CompleteBagData:OnFileFetched(url, path, size)
	--print(url, path, size)
	local file = self.temp_asset_list[path]
	if size > 0 then
		self.has_loaded = self.has_loaded + 1
		self.loaded_size = self.loaded_size + file.size
		if file then
			file.state = CompleteBagData.ItemFinish
		end	

		local target_path = self.main_asset_list[path]
		UtilEx:copyFile(path,target_path)
	else
		if file then
			self:RetryFile(file)	
		end	
	end	

	if self.has_loaded >= self.total_file then
		self.loaded_size = self.total_size
		--print("加载结束")
		self:End()
		self:RecordEnd()
		CompleteBagCtrl.Instance:SendFinishDownload() --完成成就通知
		GlobalEventSystem:Fire(CompleteBagEvent.COMPLETE,self.has_loaded,self.total_file)

		self.asset_list = {}
		self.temp_asset_list = {}
		self.main_asset_list = {}

		if cc.PLATFORM_OS_WINDOWS ~= PLATFORM then
			PlatformAdapter.RemoveFile(self:TempPath(""))
		end

	end	
	--print(self.has_loaded,self.total_file)
end

--支持双线资源下载
function CompleteBagData:HostPath(path, file)
	local url = self.update_url
	if self.update_url2 and file and file.retry then
		if file.retry > 0 then
			url = self.update_url2
			print("change host " .. url)
		end
	end

	return url .. path .. '?v=' .. file.ver
end

function CompleteBagData:FetchFile(path,size,ver)
	local file = {retry = 0,size = size,ver = ver,state = CompleteBagData.Normal}
	self.asset_list[path] = file
	local temp_path = self:TempPath(path)
	self.temp_asset_list[temp_path] = file
	self.main_asset_list[temp_path] = self:GetMainPath(path)
end

function CompleteBagData:TempPath(path)
	return UtilEx:getDataPath() .. "temp/" .. path
end	

function CompleteBagData:GetMainPath(path)
	return UtilEx:getDataPath() .. "main/" .. path
end	

function CompleteBagData:CheckLoadFile(count)
	local current_count = 0
	for k,v in pairs(self.asset_list) do
		if v.state == CompleteBagData.Loading then
			current_count = current_count + 1
			if current_count >= 5 then
				return
			end	
		end	
	end	

	for k,v in pairs(self.asset_list) do
		if v.state == CompleteBagData.Normal then
			if HttpClient:Download(self:HostPath(k, v), self:TempPath(k),BindTool.Bind1(self.OnFileFetched, self)) then
				v.state = CompleteBagData.Loading
				current_count = current_count + 1
			else
				self:RetryFile(v)
			end
		end	

		if current_count >= count then
			break
		end	
	end	

	if current_count <= 0 then
		self:End()
	end	
end	

function CompleteBagData:RetryFile(file)
	file.retry = file.retry + 1
	if file.retry > 1 then
		file.state = CompleteBagData.ItemError
		self.has_loaded = self.has_loaded + 1
		self.loaded_size = self.loaded_size + file.size
	else
		file.state = CompleteBagData.Normal	
	end	
end

--预计当前需要下载的文件数
function CompleteBagData:CheckCompleteBagData()
	self.total_file = 0
	self.has_loaded = 0
	self.asset_list = {}
	self.temp_asset_list = {}
	self.main_asset_list = {}
	
	local list_file = ResManager.Instance.ver_list
	if list_file then
		for k, v in pairs(list_file) do
			table.insert(self.check_queue,{p = k,f = v})
		end	
		self:Start()
	end
	
end	

function CompleteBagData:Start()
	Runner.Instance:AddRunObj(self, 8)
end

function CompleteBagData:End()
	Runner.Instance:RemoveRunObj(self)
end	

function CompleteBagData:RecordStart()
	self.is_down_ing = 1
	cc.UserDefault:getInstance():setIntegerForKey("down_loading", self.is_down_ing)
	GlobalEventSystem:Fire(CompleteBagEvent.START,self.has_loaded,self.total_file)
end	

function CompleteBagData:RecordEnd()
	self.is_down_ing = 0
	cc.UserDefault:getInstance():setIntegerForKey("down_loading", self.is_down_ing)
	GlobalEventSystem:Fire(CompleteBagEvent.STOP,self.has_loaded,self.total_file)
end	

function CompleteBagData:LoadTable(text)
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

function CompleteBagData:Update()
	if not self.is_check_complete then
		while true do
			if #self.check_queue > 0 then
				local f = table.remove(self.check_queue,#self.check_queue)
				local k = f.p
				local v = f.f
				local params = Split(k,"%.")

				local is_check_audit = true
				local b1, e1 = string.find(k, "res/", 1, false)
				if nil ~= b1 then
					local b2, e2 = string.find(k, "/", e1 + 1, false)
					if nil ~= b2 then
						local dir = string.sub(k, e1 + 1, b2 - 1)
						if dir == "res_ios" or 
							dir == "chibang" then
							is_check_audit = false
						end	
					end
				end
				
				if is_check_audit and v.t ~= 0 and params[2] ~= "lua" and params[2] ~="xml" and params[2] ~="jpg" then
					local abspath = self:GetMainPath(k)
					if not cc.FileUtils:getInstance():isFileExist(abspath) then
						self.total_file = self.total_file + 1
						self.total_size = self.total_size + v.s
						self:FetchFile(k,v.s,v.v)
					end	
				end
			else
				self:End()
				self.is_check_complete = true
				if self.total_file <= 0  and self.is_achieve_complete and self.is_check_complete then
					CompleteBagCtrl.Instance:SendFinishDownload() --完成成就通知
					GlobalEventSystem:Fire(CompleteBagEvent.COMPLETE,self.has_loaded,self.total_file)
				end	

				GlobalEventSystem:Fire(CompleteBagEvent.CHECKALLCOMPLETE,self.has_loaded,self.total_file)
				--print("初始化结束")
				break
			end	

			if XCommon:getHighPrecisionTime() - HIGH_TIME_NOW >= 0.016 then
				--print("跳出")
				break
			end
		end
	else	
		self:CheckLoadFile(5)

		if Status.NowTime > self.progress_time then
			self.progress_time = Status.NowTime + 1
			GlobalEventSystem:Fire(CompleteBagEvent.PROGRESS,self.has_loaded,self.total_file)
		end	

		if Status.NowTime > self.recored_time then
			self.recored_time = Status.NowTime + 10
			cc.UserDefault:getInstance():setIntegerForKey("down_load_last_time", TimeCtrl.Instance:GetServerTime())
		end	
	end	
end	

function CompleteBagData:IsShowCompleteBagIcon()
	local achieve = AchieveData.Instance:GetAwardState(CompleteBagData.AchieveID)
	if achieve and achieve.reward == 1 then
		return false
	end	
	return true
end	
