
-- 头像管理
AvatarManager = AvatarManager or BaseClass()
local AVATAR_URL = ""
if nil ~= GLOBAL_CONFIG.param_list.upload_url and "" ~= GLOBAL_CONFIG.param_list.upload_url then
	AVATAR_URL = GLOBAL_CONFIG.param_list.upload_url .. "/avatar/"
else
	AVATAR_URL = "http://upload.mg23.youyannet.com/dev/avatar/"  --"http://127.0.0.1/avatar/"
end

function AvatarManager:__init()
	if AvatarManager.Instance ~= nil then
		print_error("AvatarManager to create singleton twice!")
	end
	AvatarManager.Instance = self

	self.avatar_key_list = {}						-- 头像key列表
	self.quest_list = {}							-- 请求列表
	self.avatar_frame_list = {}						-- 头像框key列表
end

function AvatarManager:__delete()
	AvatarManager.Instance = nil

	for k, v in pairs(self.quest_list) do
		AvatarManager.CancelAvatar(v)
	end
	self.quest_list = {}
end

function AvatarManager:SetAvatarKey(role_id, avatar_key_big, avatar_key_small)
	if not role_id then
		return
	end
	if 0 == avatar_key_big and 0 == avatar_key_small then
		self.avatar_key_list[role_id] = nil
	else
		self.avatar_key_list[role_id] = {big = avatar_key_big, small = avatar_key_small,}
	end
end

function AvatarManager:GetAvatarKey(role_id, is_big)
	is_big = true
	local avatar_key = 0

	local avatar = self.avatar_key_list[role_id]
	if nil ~= avatar then
		avatar_key = is_big and avatar.big or avatar.small
	end

	return avatar_key
end

function AvatarManager:ChangeAvatarKey(role_id, avatar_key, is_big)
	is_big = true
	local avatar = self.avatar_key_list[role_id]
	if nil ~= avatar then
		if is_big then
			avatar.big = avatar_key
		else
			avatar.small = avatar_key
		end
	end
end

function AvatarManager.IsGetDefAvatar(role_id)
	local main_id = PlayerData.Instance.role_vo.role_id
	if IS_ON_CROSSSERVER and role_id ~= main_id then
		return true
	else
		return false
	end
end

-- 获取头像
-- callback(path, is_plist)
function AvatarManager:GetAvatar(role_id, is_big, callback)
	is_big = true
	local url = AvatarManager.GetFileUrl(role_id, is_big)
	self.role_id = role_id
	self.is_big = is_big
	local avatar_key = self:GetAvatarKey(role_id, is_big)
	local path = AvatarManager.GetFilePath(role_id, is_big)
	local file = io.open(path, "r")
	if file then
		io.close(file)
		if avatar_key == AvatarManager.getFileKey(path) then
			-- print("缓存已有")
			if callback then
				callback()
			end
			return nil
		end
	end
	local function load_callback(url2, path2, is_succ)
		-- print(" load_callback ", url2, path2, is_succ)
		if is_succ then
			local new_avatar_key = AvatarManager.getFileKey(path2)
			-- print(" load_callback avatar_key", avatar_key, new_avatar_key)
			-- if new_avatar_key ~= avatar_key then
			self:ChangeAvatarKey(role_id, new_avatar_key, is_big)
			-- end
			-- GlobalEventSystem:Fire(ObjectEventType.HEAD_CHANGE)
			if callback then
				callback(path2)
			end
		end
	end
	-- 通过http下载
	if not HttpClient:Download(url, path, load_callback) then
		print("GetAvatar下载失败")
		return nil
	end
	-- print(" GetAvatar 下载完成 url", url)
	self.quest_list[url] = {["url"] = url, ["load_callback"] = load_callback}
end

function AvatarManager.HasCache(avatar_key, path)
	local file = io.open(path, "r")
	if file then
		io.close(file)
		if avatar_key == AvatarManager.getFileKey(path) then
			return true
		end
	end
	return false
end

-- 获取公会头像
function AvatarManager:GetGuildAvatar(role_id, guild_id, is_big, callback)
	is_big = true
	local url = AvatarManager.GetGuildFileUrl(role_id, guild_id, is_big)
	self.role_id = role_id
	self.guild_id = guild_id
	self.is_big = is_big
	local guild_avatar_key = self:GetAvatarKey(guild_id, is_big)
	local path = AvatarManager.GetFilePath(guild_id, is_big)
	local file = io.open(path, "r")
	if file then
		io.close(file)
		if guild_avatar_key == AvatarManager.getFileKey(path) then
			-- print("公会头像缓存已有，不需要下载头像")
			if callback then
				callback()
			end
			return nil
		end
	end
	local function load_callback(url2, path2, is_succ)
		-- print(" load_callback ", url2, path2, is_succ)
		if is_succ then
			local new_guild_avatar_key = AvatarManager.getFileKey(path2)
			-- print(" load_callback guild_avatar_key", guild_avatar_key, new_guild_avatar_key)
			-- if new_guild_avatar_key ~= guild_avatar_key then
			self:ChangeAvatarKey(guild_id, new_guild_avatar_key, is_big)
			-- end
			-- GlobalEventSystem:Fire(ObjectEventType.HEAD_CHANGE)
			if callback then
				callback(path2)
			end
		end
	end
	-- 通过http下载
	if not HttpClient:Download(url, path, load_callback) then
		print("GetGuildAvatar下载失败")
		return nil
	end
	-- print(" GetGuildAvatar 下载完成 url", url)
	self.quest_list[url] = {["url"] = url, ["load_callback"] = load_callback}
end

function AvatarManager:CancelUpdateAvatar(url)
	local quest = self.quest_list[url]
	if nil ~= quest then
		self.quest_list[url] = nil
		AvatarManager.CancelAvatar(quest)
	end
end

-- 取消获取
function AvatarManager.CancelAvatar(quest)
	if nil ~= quest then
		HttpClient:CancelDownload(quest.url, quest.load_callback)
	end
end

-- 获取默认头像 sex: 1男 0女
function AvatarManager.GetDefAvatar(prof, is_big, sex)
	is_big = true
	if prof <= 0 then
		return "", 0
	end
	sex = sex or 1
	prof = PlayerData.Instance:GetRoleBaseProf(prof)

	if is_big then
		return ResPath.GetRoleHeadBig(prof, sex)
	end

	return ResPath.GetRoleHeadSmall(prof, sex)
end

function AvatarManager.GetFileName(role_id, is_big)
	is_big = true
	return role_id .. (is_big and "_big.jpg" or "_small.jpg")
end

function AvatarManager.GetFilePath(role_id, is_big)
	is_big = true
	return string.format("%s/cache/avatar/%s",
		UnityEngine.Application.persistentDataPath,
		AvatarManager.GetFileName(role_id, is_big))
end

function AvatarManager.GetFileUrl(role_id, is_big)
	is_big = true
	return AVATAR_URL .. UserVo.GetServerId(role_id) .. "/role/" .. AvatarManager.GetFileName(role_id, is_big)
end

function AvatarManager.getFileKey(path)
	return MD5.GetMD5FromFile(path)
end

--判断现在使用的头像是否是默认头像
function AvatarManager:isDefaultImg(role_id)
	local avatar_key = 0	--如果没有收到任何的当前使用头像的返回，则认为使用了默认头像
	if role_id ~= nil then
		avatar_key = self:GetAvatarKey(role_id, false)
	end

	return avatar_key
end

---------------------------公会头像相关--------------------------------------
function AvatarManager.GetGuildFileUrl(role_id, guild_id, is_big)
	is_big = true
	return AVATAR_URL .. UserVo.GetServerId(role_id) .. "/guild/" .. AvatarManager.GetFileName(guild_id, is_big)
end

--------------------------头像框信息存储-------------------------------------
function AvatarManager:SetAvatarFrameKey(role_id, use_frame_id)
	if not role_id then
		return
	end
	self.avatar_frame_list[role_id] = use_frame_id
end

function AvatarManager:GetAvatarFrameKey(role_id)
	if not role_id then
		return -1
	end
	return self.avatar_frame_list[role_id]
end