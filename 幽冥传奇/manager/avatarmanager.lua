
-- 头像管理
AvatarManager = AvatarManager or BaseClass()
if nil ~= GLOBAL_CONFIG.param_list.upload_url then
	AVATAR_URL = GLOBAL_CONFIG.param_list.upload_url .. "/avatar/"
else
	AVATAR_URL = "http://127.0.0.1/avatar/"
end

function AvatarManager:__init()
	if AvatarManager.Instance ~= nil then
		ErrorLog("AvatarManager to create singleton twice!")
	end
	AvatarManager.Instance = self

	self.avatar_key_list = {}						-- 头像key列表
	self.quest_list = {}							-- 请求列表
end

function AvatarManager:__delete()
	AvatarManager.Instance = nil

	for k, v in pairs(self.quest_list) do
		AvatarManager.CancelAvatar(v)
	end
	self.quest_list = {}
end

function AvatarManager:SetAvatarKey(role_id, avatar_key_big, avatar_key_small)
	if 0 == avatar_key_big and 0 == avatar_key_small then
		self.avatar_key_list[role_id] = nil
	else
		self.avatar_key_list[role_id] = {big = avatar_key_big, small = avatar_key_small,}
	end
end

function AvatarManager:GetAvatarKey(role_id, is_big)
	avatar_key = 0

	local avatar = self.avatar_key_list[role_id]
	if nil ~= avatar then
		avatar_key = is_big and avatar.big or avatar.small
	end

	return avatar_key
end

function AvatarManager:ChangeAvatarKey(role_id, avatar_key, is_big)
	local avatar = self.avatar_key_list[role_id]
	if nil ~= avatar then
		if is_big then
			avatar.big = avatar_key
		else
			avatar.small = avatar_key
		end
	end
end

-- 更新头像按钮
function AvatarManager:UpdateAvatarBtn(btn, role_id, prof, is_big, sex)
	if nil ~= self.quest_list[btn] then
		return
	end

	local function callback_func(path, load_type, is_reload)
		self.quest_list[btn] = nil
		if "" == path then return end

		if is_reload then
			cc.Director:getInstance():getTextureCache():reloadTexture(path)
		end
		
		btn:loadTextures(path, path, "", load_type)
	end

	local quest = self:GetAvatar(role_id, prof, is_big, callback_func, sex)
	if nil ~= quest then
		self.quest_list[btn] = quest

		local def_path, load_type = AvatarManager.GetDefAvatar(prof, is_big, sex)
		btn:loadTextures(def_path, def_path, "", load_type)
	end
end

-- 更新头像图片, is_gray可为nil
function AvatarManager:UpdateAvatarImg(img, role_id, prof, is_big, is_gray, sex)
	if nil ~= self.quest_list[img] then
		return
	end

	local function callback_func(path, load_type, is_reload)
		self.quest_list[img] = nil
		if "" == path then return end

		if is_reload then
			cc.Director:getInstance():getTextureCache():reloadTexture(path)
		end

		if img:getDescription() == "XImage" then
			img:loadTexture(path, load_type)
			if nil ~= is_gray then
				img:setGrey(is_gray)
			end
		else
			img:loadTexture(path, load_type and 1 or 0)
			if nil ~= is_gray then
				AdapterToLua:makeGray(img:getVirtualRenderer(), is_gray)
			end
		end
	end

	local quest = self:GetAvatar(role_id, prof, is_big, callback_func, sex)
	if nil ~= quest then
		self.quest_list[img] = quest

		local def_path, load_type = AvatarManager.GetDefAvatar(prof, is_big, sex)
		if img:getDescription() == "XImage" then
			img:loadTexture(def_path, load_type)
			if nil ~= is_gray then
				img:setGrey(is_gray)
			end
		else
			img:loadTexture(def_path, load_type and 1 or 0)
			if nil ~= is_gray then
				AdapterToLua:makeGray(img:getVirtualRenderer(), is_gray)
			end
		end
	end
end

-- 取消更新
function AvatarManager:CancelUpdateAvatar(node)
	local quest = self.quest_list[node]
	if nil ~= quest then
		self.quest_list[node] = nil
		AvatarManager.CancelAvatar(quest)
	end
end

-- 获取头像
-- callback(path, is_plist)
function AvatarManager:GetAvatar(role_id, prof, is_big, callback, sex)
	-- 没有自定义过头像用默认的
	local avatar_key = self:GetAvatarKey(role_id, is_big)
	if 0 == avatar_key then
		local def_path, load_type = AvatarManager.GetDefAvatar(prof, is_big, sex)
		callback(def_path, load_type, false)
		return nil
	end

	local path = AvatarManager.GetFilePath(role_id, is_big)

	-- 用文件大小当key，本地是最新的用本地头像
	if avatar_key == AvatarManager.getFileKey(path) then
		callback(path, false, true)
		return nil
	end
	
	-- 通过http下载
	local url = AvatarManager.GetFileUrl(role_id, is_big)
	local function load_callback(url, path, size)
		if size >= 0 then
			callback(path, false, true)
			local new_avatar_key = AvatarManager.getFileKey(path)
			if new_avatar_key ~= avatar_key then
				self:ChangeAvatarKey(role_id, new_avatar_key, is_big)
			end
		end
	end

	if not HttpClient:Download(url, path, load_callback) then
		return nil
	end

	return {["url"] = url, ["load_callback"] = load_callback}
end

-- 取消获取
function AvatarManager.CancelAvatar(quest)
	if nil ~= quest then
		HttpClient:CancelDownload(quest.url, quest.load_callback)
	end
end

-- 获取默认头像
function AvatarManager.GetDefAvatar(prof, is_big, sex)
	if prof <= 0 then
		return "", 0
	end
	prof = RoleData.Instance:GetRoleBaseProf(prof)
	
	if is_big then
		if sex then
			return ResPath.GetRoleHead("big_" .. prof .. "_" .. sex), false
		else
			return ResPath.GetRoleHead("big_" .. prof), false
		end

		return ResPath.GetRoleHead("big_" .. prof), false
	end
	if sex then
		return ResPath.GetRoleHead("small_" .. prof .. "_" .. sex), false
	else
		return ResPath.GetRoleHead("small_" .. prof), false
	end
end

function AvatarManager.GetFileName(role_id, is_big)
	return role_id .. (is_big and "_big.jpg" or "_small.jpg")
end

function AvatarManager.GetFilePath(role_id, is_big)
	return PlatformAdapter.GetCachePath() .. "avatar/" .. AvatarManager.GetFileName(role_id, is_big)
end

function AvatarManager.GetFileUrl(role_id, is_big)
	return AVATAR_URL .. UserVo.GetServerId(role_id) .. "/" .. AvatarManager.GetFileName(role_id, is_big)
end

function AvatarManager.getFileKey(path)
	return UtilEx:getFileKey(path, 2048)
end

--判断现在使用的头像是否是默认头像
function AvatarManager:isDefaultImg(role_id)
	local avatar_key = 0	--如果没有收到任何的当前使用头像的返回，则认为使用了默认头像
	if role_id ~= nil then
		avatar_key = self:GetAvatarKey(role_id, false)
	end
	return avatar_key
end