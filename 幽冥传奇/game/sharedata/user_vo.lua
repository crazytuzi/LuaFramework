
UserVo = UserVo or BaseClass()

-- 仅用来处理服务器登录流程
-- 主要是保存着平台相关的信息、角色列表、session_key、场景ID，场景key

PLAT_ACCOUNT_TYPE_COMMON = 0
PLAT_ACCOUNT_TYPE_TEST = 1

function UserVo:__init()
	if UserVo.Instance then
		ErrorLog("[UserVo] Attempt to create singleton twice!")
		return
	end
	UserVo.Instance = self

	-- 登录平台信息
	self.plat_name = ""
	self.plat_account_type = 0						-- 0正常，1测试
	self.plat_session_key = ""						-- php返回的加密sign
	self.plat_login_time = 0
	self.plat_fcm = 0								-- 防沉迷标记
	self.plat_server_id = 1							-- 角色原本的服id
	self.real_server_id = 1							-- 当前进入的服id
	self.plat_is_verify = false						-- 是否经过登录验证
	self.plat_server_name = ""
	self.merge_id = 0
	self.open_time = 0                              -- 开服时间

	-- 角色登录信息
	self.account_id = 0
	self.role_list = {}
	self.cur_role_id = 0
	self.create_role_limit_day = 0
	self.create_role_limit_level = 0
	self.role_max_cmp_level = 0
end

function UserVo:__delete()
	UserVo.Instance = nil
end

function UserVo:ClearRoleList()
	self.role_list = {}
	self.cur_role_id = 0
	self.role_max_cmp_level = 0
end

-- 添加角色到角色列表, role_info参考SCRoleListAck
function UserVo:AddRole(role_info)
	for k,v in pairs(self.role_list) do
		if v.role_id == role_info.role_id then
			return
		end
	end
	self.role_max_cmp_level = math.max(self.role_max_cmp_level, role_info.level or 0)
	table.insert(self.role_list, role_info)
end

-- 删除角色
function UserVo:RemoveRole(role_id)
	local remove_key = nil
 	for k,v in pairs(self.role_list) do
		if v.role_id == role_id then
			remove_key = k
		end
	end
	if remove_key then
		table.remove(self.role_list, remove_key)
	end
end
function UserVo:GetRoleList()
	return self.role_list
end

function UserVo:SetNowRole(role_id, role_name)
	AdapterToLua:getInstance():setDataCache("SET_NOW_ROLE", role_id)
	AdapterToLua:getInstance():setDataCache("SET_NOW_ROLE_NAME", role_name)
	self.cur_role_id = role_id
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	main_role_vo.role_id = role_id
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		main_role_vo.name = role_name
		local server_id = ""
		for i=2,10 do
		 	if tonumber(string.sub(role_name, i, i)) then
		 		server_id = server_id .. string.sub(role_name, i, i)
		 	else
		 		break
		 	end
		end 
		main_role_vo.server_id = tonumber(server_id) or self.plat_server_id
end

function UserVo:GetNowRole()
	return self.cur_role_id
end

function UserVo:GetNowRoleInfo()
	for i, v in ipairs(self.role_list) do
		if v.role_id == self.cur_role_id then
			return v
		end
	end
	return nil
end

-- 根据角色id获取服id
function UserVo.GetServerId(role_id)
	return bit:_rshift(role_id, 20)
end

--返回所有角色中最大等级
function UserVo:GetRoleCmpMaxLevel()
	return self.role_max_cmp_level
end	
