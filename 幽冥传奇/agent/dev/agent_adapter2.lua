AgentAdapter = {
}

-- 平台ID
function AgentAdapter:GetSpid()
	return "dev"
end

-- 平台帐号唯一标识
function AgentAdapter:GetOpenId()
	return ""
end

-- 加前辍的平台帐号，全平台唯一
function AgentAdapter:GetPlatName()
	return GameVoManager.Instance:GetUserVo().plat_name
end

-- 获得游戏名
function AgentAdapter:GetGameName()
	return Language.Common.GameName[1]
end

function AgentAdapter:Login(callback)
end

function AgentAdapter:Logout()
end

function AgentAdapter:Pay(role_id, role_name, amount, server_id, callback)
end

function AgentAdapter:PayGift(role_id, role_name, amount, server_id, callback)
end

function AgentAdapter:SubmitRoleData(role_id, role_name, role_level, zone_id, zone_name)
end

function AgentAdapter:EnterUserCenter()
end

function AgentAdapter:ShowFloatButton()
end
-- 创建角色上报
function AgentAdapter:ReportOnCreateRole(role_name)	
	--print("创建角色:",role_name)
end

-- 进入游戏上报
function AgentAdapter:SubmitRoleData(role_id, role_name, role_level, zone_id, zone_name)
	--print("进入游戏:",role_id, role_name, role_level, zone_id, zone_name)
end

-- 升级上报
function AgentAdapter:ReportOnRoleLevUp(role_id, role_name, role_level, zone_id, zone_name)
	--print("角色升级:",role_id, role_name, role_level, zone_id, zone_name)
end
