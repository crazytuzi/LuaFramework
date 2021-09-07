UpdateAfficheData = UpdateAfficheData or BaseClass()

function UpdateAfficheData:__init()
	if UpdateAfficheData.Instance ~= nil then
		ErrorLog("[UpdateAfficheData] Attemp to create a singleton twice !")
	end
	UpdateAfficheData.Instance = self

	self.update_affiche = {
		server_version = 0,
		fetch_reward_version = 0,
	}
	self.is_update_affiche_ok = false
	self.everyday_text = ""
	
	self.img_data_list = {}							-- 图片key列表
	self.quest_list = {}							-- 请求列表
	self.noticeimg_data = {}
	self.is_start_load = false						-- 开始下载
end

function UpdateAfficheData:__delete()
	UpdateAfficheData.Instance = nil
end

-- 更新公告信息
function UpdateAfficheData:SetUpdateNoticeInfo(info)
	if nil == info then return end
	self.update_affiche.server_version = info.server_version or 0
	self.update_affiche.fetch_reward_version = info.fetch_reward_version or 0
	self.is_update_affiche_ok = true
end

-- 是否可以领取奖励
function UpdateAfficheData:CanFetchReward()
	return self.update_affiche.server_version > self.update_affiche.fetch_reward_version
end

function UpdateAfficheData:GetAfficheRemind()
	return self:CanFetchReward() and 1 or 0
end

function UpdateAfficheData:GetUpdateNoticeInfo()
	return self.update_affiche
end

function UpdateAfficheData:IsUpdateAfficheOk()
	return self.is_update_affiche_ok
end

function UpdateAfficheData:GetUpdateAfficheCfg()
	return ConfigManager.Instance:GetAutoConfig("updatenotice_auto").other[1]
end

-- 设置日常公告内容
function UpdateAfficheData:SetEverydayContent(data)
	if "table" ~= type(data) or nil == next(data) then return -1 end

	local content = ""
	for k,v in ipairs(data) do
		local str = v.content
		str = string.gsub(str, "\n", "\n")
		content = content .. str .. "\n"
	end

	self.everyday_text = content
end

-- 获取日常公告内容
function UpdateAfficheData:GetEverydayContent()
	return self.everyday_text or ""
end


------------------------------------


function UpdateAfficheData:SetNoticeImg(info)
	if nil == info then return end
	self.img_data_list = {}
	self.noticeimg_data = info
	self:GetNoticeImg()
end

function UpdateAfficheData:GetNoticeImg()
	if nil == self.noticeimg_data then return end
	for k,v in pairs(self.noticeimg_data) do
		if nil ~= self.quest_list[k] then
			return
		end

		local function callback(img_url, text, name, path)
			self.quest_list[k] = nil
			self.img_data_list[k] = {img_url = v.img_url, text = v.content, name = name, path = path}
			--刷新数据
			UpdateAfficheCtrl.Instance:FlushNoticeImg()
		end
		local quest = self:GetNoticeImgData(v.content, v.img_url, callback)
		if nil ~= quest then
			self.quest_list[k] = quest
		end
	end
end

function UpdateAfficheData:GetImgData()
	local data_list ={}
	for i = 1, 4 do
		data_list[i] = self.img_data_list
	end
	return self.img_data_list
end

function UpdateAfficheData:GetImgKey(name)
	local img_check = {}
	for k,v in pairs(self.img_data_list) do
		if name == v.name then
			img_check[k] = v
		end
	end
	return img_check
end

function UpdateAfficheData.GetFilePath(name)
	return string.format("%s/cache/avatar/%s", UnityEngine.Application.persistentDataPath, name)
end

-- 检查路径的资源大小是否一致
function UpdateAfficheData.checkFile(path, size)
	return UtilEx:checkFile(path, nil, size) 
end

-- 获取公告图片
-- (v.content, v.img_url, callback)
function UpdateAfficheData:GetNoticeImgData(content, img_url, callback)
	local text = content or ""
	local url = img_url.url or ""
	local name = img_url.name or ""
	local size = img_url.size or -1
	local path = UpdateAfficheData.GetFilePath(name)

	-- 如果没图片数据直接用文本
	if nil == img_url or "" == img_url then
		callback(url, text, name, "")
		return nil
	end

	-- 当前文件大小，本地是最新的用本地图片
	-- if AvatarManager.getFileKey(path) then
	-- 	callback(url, text, name, path)
	-- 	return nil
	-- end
	
	-- 通过http下载
	local function load_callback(load_url, path, is_succ)
		if is_succ then
			callback(load_url, text, name, path)
			return nil
		end
	end
	if not HttpClient:Download(url, path, load_callback) then
		return nil
	end
	return {["url"] = url, ["text"] = text, ["name"] = name, ["path"] = path, ["load_callback"] = load_callback}
end