--
-- @Author: LaoY
-- @Date:   2019-07-14 13:06:48
-- 头像管理

AvatarManager = AvatarManager or class("AvatarManager",BaseManager)

AvatarManager.local_file_path = Util.PhotoPath

function AvatarManager:ctor()
	AvatarManager.Instance = self
	self:AddEvent()
	self:Reset()
	local channel_id = LoginModel:GetInstance():GetChannelId()
	local channel_id_dir = channel_id .. "/"

	channel_id_dir = AvatarManager.local_file_path .. channel_id_dir
	-- io.CheckDirOrCreate(AvatarManager.local_file_path)
	-- io.CheckDirOrCreate(channel_id_dir)
end

function AvatarManager:Reset()
	self.avatar_take_photo_ref_list = {}
	setmetatable(self.avatar_take_photo_ref_list, {__mode = "k"})

	self.get_oss_image_ref_list = {}
	setmetatable(self.get_oss_image_ref_list, {__mode = "k"})
end

function AvatarManager.GetInstance()
	if AvatarManager.Instance == nil then
		AvatarManager()
	end
	return AvatarManager.Instance
end

function AvatarManager:AddEvent()
	-- 拍照/获取照片 事件
	self.global_event_list = self.global_event_list or {}
	local function call_back(param)
		self:CheckTakePhoto(param)
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.GetPhoto, call_back)

	-- 上传oss完成后 事件
	local function call_back(file_name,bo)
		local function step()
			self:CheckUploadImage(file_name,bo)
		end
		GlobalSchedule:StartOnce(step,0.1)
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.PutObject, call_back)

	-- 下载oss文件完成后 事件
	local function call_back(file_name)
		self:CheckDownloadImage(file_name)
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.GetObject, call_back)

	-- 判断oss是否存在文件事件
	local function call_back(file_name,bo)
		self:CheckImageIsExists(file_name,bo)
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.ObjectExists, call_back)
end

function AvatarManager:CheckTakePhoto(param)
	local file_name = param.file_name
	local file_path = param.file_path

	for cls,list in pairs(self.avatar_take_photo_ref_list) do
		local deleta_tab
		local len = #list
		for i=1,len do
			local info = list[i]
			if info.file_name == file_name then
				if info.set_img_func then
					if cls.is_dctored then
						return
					end
					local url = file_path .. file_name
					local function call_back(sprite,texture)
						info.set_img_func(sprite,texture)
						if info.auto_send_func then
							local function step()
								OssManager:GetInstance():AsyncPutObject(AvatarManager.local_file_path .. file_name,file_name)
							end
							GlobalSchedule:StartOnce(step,0.05)
						end
					end
					-- F:/work/xwgame/client/project/game/Assets/photo_cache/test_1.png
					Yzprint('--LaoY AvatarManager.lua,line 77--',url)
				    HttpManager:GetInstance():LoadSprite(url, Vector2(0.5, 0.5), call_back)
				end

				if info.auto_send_func then
					
				else
					deleta_tab = deleta_tab or {}
					deleta_tab[#deleta_tab+1] = i
				end
			end
		end
		if not table.isempty(deleta_tab) then
			table.RemoveByIndexList(list,deleta_tab)
		end
	end
end

function AvatarManager:CheckUploadImage(file_name,bo)
	for cls,list in pairs(self.avatar_take_photo_ref_list) do
		local deleta_tab
		local len = #list
		for i=1,len do
			local info = list[i]
			if info.file_name == file_name then
				if bo and info.auto_send_func then
					local url = AvatarManager.local_file_path .. file_name
					local md5 = Util.md5file(url)
					info.auto_send_func(file_name,md5)
				end
				deleta_tab = deleta_tab or {}
				deleta_tab[#deleta_tab+1] = i
			end
		end
		if not table.isempty(deleta_tab) then
			table.RemoveByIndexList(list,deleta_tab)
		end
	end
end


--[[
	@author LaoY
	@des	获取相册图片 必须在 destroy是调用 RemoveTakePhotoRef
	@param1 cls
	@param2 set_img_func 	照相/选择相片后，设置图片的回调
			参数：sprite
	@param3 auto_send_func  上传完Oss服务器后,通知游戏服务器的回调
			参数：file_name
			参数：md5

	-- 后面参数见 PlatformManager:TakePhoto
	@param1 type 			1.照相 2.选择相片
	@param2 file_name		图片名字，带后缀
	@param3 width 			宽
	@param4 height 			高
--]]
function AvatarManager:TakePhoto(cls,set_img_func,auto_send_func,type,file_name,width,height,quality)
	if file_name then
		local channel_id = LoginModel:GetInstance():GetChannelId()
		local channel_id_dir = channel_id .. "_"
		if not file_name:find(channel_id_dir) then
			file_name = channel_id_dir .. file_name
		end
	end
	self.avatar_take_photo_ref_list[cls] = self.avatar_take_photo_ref_list[cls] or {}
	table.insert(self.avatar_take_photo_ref_list[cls],{set_img_func = set_img_func,auto_send_func = auto_send_func,file_name  = file_name})
	PlatformManager:GetInstance():TakePhoto(type,file_name,width,height,quality)
end

function AvatarManager:RemoveTakePhotoRef(cls)
	self.avatar_take_photo_ref_list[cls] = nil
end

--[[
	@author LaoY
	@des	获取远端图片 必须在 destroy是调用 RemoveGetOssImageRef
	@param1 cls
	@param2 set_img_func 	下载完远端图片后设置图片的回调
	@param3 file_name
	@param4 md5 			服务器保存的，远端最新的md5 
--]]
local errTimeList = {}
function AvatarManager:GetOssImage(cls,set_img_func,file_name,md5)
	if not set_img_func then
		logError("没有设置图片的方法")
		return
	end
	local path = AvatarManager.local_file_path .. file_name
	DebugLog('--LaoY AvatarManager.lua,line 162--',file_name,OssManager:GetInstance().down_loading_list[file_name])

	-- 如果在加载中，等待加载完成
	if OssManager:GetInstance():IsInLoading(file_name) or OssManager:GetInstance():IsInExistsing(file_name) then
		self.get_oss_image_ref_list[cls] = self.get_oss_image_ref_list[cls] or {}
		table.insert(self.get_oss_image_ref_list[cls],{set_img_func = set_img_func,file_name = file_name , md5 = md5})
		errTimeList[file_name] = nil
		return
	end
	local isExists = io.exists(path)
	local localMd5 = nil
	if isExists then
		local status, value = pcall(Util.md5file,path)
		if status then
			localMd5 = value
		else
			if AppConfig.Debug then
				logError("====AvatarManager:GetOssImage====",value)
			end
			errTimeList[file_name] = errTimeList[file_name] or 0
			errTimeList[file_name] = errTimeList[file_name] + 1
			if errTimeList[file_name] < 3 then
				local function step()
					self:GetOssImage(cls,set_img_func,file_name,md5)
				end
				GlobalSchedule:StartOnce(step,0.04)
				return
			end
		end
	end
	errTimeList[file_name] = nil
	-- 本地存在和远端相同的版本，不需要下载
	if isExists and localMd5 == md5 then
		if set_img_func then
			HttpManager:GetInstance():LoadSprite(path, Vector2(0.5, 0.5), set_img_func)
		end
	else
		self.get_oss_image_ref_list[cls] = self.get_oss_image_ref_list[cls] or {}
		table.insert(self.get_oss_image_ref_list[cls],{set_img_func = set_img_func,file_name = file_name , md5 = md5})
		OssManager:GetInstance():ObjectExists(file_name)
	end
end

function AvatarManager:RemoveGetOssImageRef(cls)
	self.get_oss_image_ref_list[cls] = nil
end

function AvatarManager:CheckImageIsExists(file_name,bo)
	for cls,list in pairs(self.get_oss_image_ref_list) do
		local len = #list
		for i=1,len do
			local info = list[i]
			if info.file_name == file_name then
				if bo then
					OssManager:GetInstance():AsyncGetObjectProgress(AvatarManager.local_file_path .. file_name,file_name)
				end
			end
		end
	end
end

function AvatarManager:CheckDownloadImage(file_name)
	for cls,list in pairs(self.get_oss_image_ref_list) do
		local deleta_tab
		local len = #list
		for i=1,len do
			local info = list[i]
			if info.file_name == file_name then
				deleta_tab = deleta_tab or {}
				deleta_tab[#deleta_tab+1] = i
				if info.set_img_func then
					HttpManager:GetInstance():LoadSprite(AvatarManager.local_file_path .. file_name, Vector2(0.5, 0.5), info.set_img_func)
				end
			end
		end
		if not table.isempty(deleta_tab) then
			table.RemoveByIndexList(list,deleta_tab)
		end
	end
end