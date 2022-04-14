--
-- @Author: LaoY
-- @Date:   2019-07-13 15:18:19
--
OssManager = OssManager or class("OssManager",BaseManager)

function OssManager:ctor()
	OssManager.Instance = self
	self.local_file_path = Util.PhotoPath

	self.is_init = false

	self.down_loading_list = {}
	self.exists_list = {}

	self.down_load_info_list = {}

	local function call_back()
		self:InitOssManager()
	end
	GlobalEvent:AddListener(EventName.GameStart, call_back)
	self:Reset()

	-- 测试代码
	self:InitOssManager()
end

function OssManager:Reset()

end

function OssManager.GetInstance()
	if OssManager.Instance == nil then
		OssManager()
	end
	return OssManager.Instance
end

function OssManager:InitOssManager()
	if self.is_init then
		return
	end
	local channel_id = LoginModel:GetInstance():GetChannelNameById()
	channel_id = "xwgame-qylh"
	if not channel_id then
		return
	end
	if PlatformManager:GetInstance():IsKR() then
		channel_id = "xingwan-kr-down"
		aliyunOssMgr.endpoint = "oss-ap-northeast-1.aliyuncs.com"
	elseif PlatformManager:GetInstance():IsTW() or PlatformManager:GetInstance():IsEN() then
		channel_id = "xingwan-down"
		aliyunOssMgr.endpoint = "oss-ap-southeast-1.aliyuncs.com"
	elseif AppConfig.region == 10 or AppConfig.region == 11 then
		channel_id = "qylh"
		aliyunOssMgr.endpoint = "oss-cn-shenzhen.aliyuncs.com"
	else
		channel_id = "xwgame-qylh"
		aliyunOssMgr.endpoint = "oss-accelerate.aliyuncs.com"
	end
	aliyunOssMgr:Init(channel_id)
	local function call_back(str)
		self:CallBack(str)
	end
	aliyunOssMgr:SetLuaCallBack(call_back)
	self.is_init = true
end

function OssManager:CallBack(str)
	local params = json.decode(str)
	Yzprint('--LaoY OssManager.lua,line 39--',str)
	-- dump(params,"params")

	if params.func_name == "ObjectExists" then
		GlobalEvent:Brocast(EventName.ObjectExists,params.param.file_name,params.param.is_exists)
		self.exists_list[params.param.file_name] = nil
	elseif params.func_name == "AsyncPutObjectProgress_no_exists" then
		GlobalEvent:Brocast(EventName.PutObject,params.param,false)
		if AppConfig.Debug then
			logError("try upload a no exitsts file,the file name is :",params.param)
		end
	elseif params.func_name == "AsyncPutObjectProgress" then
		GlobalEvent:Brocast(EventName.PutObject,params.param,true)
	elseif params.func_name == "AsyncGetObjectProgress" then
		local filename = params.param
		-- local oss_file_name = self.down_load_info_list[filename]
		GlobalEvent:Brocast(EventName.GetObject,filename)
		self.down_loading_list[filename] = nil
		self.exists_list[filename] = nil
		-- self.down_load_info_list[filename] = nil
	end
end

--获取远端文件
function OssManager:AsyncGetObjectProgress(local_file_name,oss_file_name)
	if not self.is_init then
		return
	end
	if self.down_loading_list[oss_file_name] then
		return
	end
	local fileInfo = io.pathinfo(local_file_name)
	-- self.down_load_info_list[fileInfo.filename] = oss_file_name
	DebugLog('--LaoY OssManager.lua,line 80--',local_file_name)
	self.down_loading_list[oss_file_name] = true
	aliyunOssMgr:AsyncGetObjectProgress(local_file_name,oss_file_name)
end

function OssManager:IsInLoading(oss_file_name)
	return self.down_loading_list[oss_file_name] == true
end

function OssManager:IsInExistsing(oss_file_name)
	return self.exists_list[oss_file_name] == true
end

-- 上传文件到远端
-- todo lua端判断文件是否存在 文件大小(太大不要上传)
function OssManager:AsyncPutObject(local_file_name,oss_file_name)
	if not self.is_init then
		return
	end
	aliyunOssMgr:AsyncPutObject(local_file_name,oss_file_name)
end

-- 弃用
function OssManager:AsyncPutObjectServer(local_file_name,oss_file_name,url)
	if not self.is_init then
		return
	end
	aliyunOssMgr:AsyncPutObjectServer(local_file_name,oss_file_name,url)
end

-- 判断远端文件是否存在
-- 异步返回，千万不要同步使用
function OssManager:ObjectExists(oss_file_name)
	if self.exists_list[oss_file_name] then
		return
	end
	-- aliyunOssMgr:ObjectExists(oss_file_name)
	self.exists_list[oss_file_name] = true

	-- 不再而外请求文件是否存在，默认存在
	local function step()
		GlobalEvent:Brocast(EventName.ObjectExists,oss_file_name,true)
		self.exists_list[oss_file_name] = nil
	end
	GlobalSchedule:StartOnce(step,0)
end

local oss_file_name = "test.txt"
function OssManager:Test()
	self:AsyncPutObject(AvatarManager.local_file_path .. oss_file_name,oss_file_name)
end