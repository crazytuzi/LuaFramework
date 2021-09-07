KillTipData = KillTipData or BaseClass()

function KillTipData:__init()
	if KillTipData.Instance then
		ErrorLog("[KillTipData] attempt to create singleton twice!")
		return
	end
	KillTipData.Instance =self

	self.role_count_info = {				-- 自己连杀的传闻
		liansha_count = 0,					-- 连杀数

		killer_camp = 0,					-- 杀人者国家
		killer_id = 0,						-- 杀人者id
		killer_prof = 0,					-- 杀人者职业
		killer_sex = 0,						-- 杀人者性别
		killer_avatar_key_big = 0,			-- 杀人者头像
		killer_avatar_key_small = 0,
		killer_name = "",					-- 杀人者名字

		dead_camp = 0,						-- 死者国家
		dead_id = 0,						-- 死者id
		dead_prof = 0,						-- 死者职业
		dead_sex = 0,						-- 死者性别
		dead_avatar_key_big = 0,			-- 死者头像
		dead_avatar_key_small = 0,
		dead_name = "",						-- 死者名字
		is_enter_or_leave_fb = 0,
	}

	self.kill_role_chuanwen = {				-- 传闻信息
		liansha_count = 0,					-- 连杀数

		killer_camp = 0,
		killer_id = 0,
		killer_prof = 0,
		killer_sex = 0,
		killer_avatar_key_big = 0,
		killer_avatar_key_small = 0,
		killer_name = "",

		dead_camp = 0,
		dead_id = 0,
		dead_prof = 0,
		dead_sex = 0,
		dead_avatar_key_big = 0,
		dead_avatar_key_small = 0,
		dead_name = "",
	}	
end

function KillTipData:__delete()
	KillTipData.Instance = nil
end

function KillTipData:SetKillRoleCount(protocol)
	self.role_count_info.liansha_count = protocol.liansha_count
	self.role_count_info.killer_camp = protocol.killer_camp
	self.role_count_info.killer_id = protocol.killer_id
	self.role_count_info.killer_prof = protocol.killer_prof
	self.role_count_info.killer_sex = protocol.killer_sex
	self.role_count_info.killer_avatar_key_big = protocol.killer_avatar_key_big
	self.role_count_info.killer_avatar_key_small = protocol.killer_avatar_key_small
	self.role_count_info.killer_name = protocol.killer_name

	self.role_count_info.dead_camp = protocol.dead_camp
	self.role_count_info.dead_id = protocol.dead_id
	self.role_count_info.dead_prof = protocol.dead_prof
	self.role_count_info.dead_sex = protocol.dead_sex
	self.role_count_info.dead_avatar_key_big = protocol.dead_avatar_key_big
	self.role_count_info.dead_avatar_key_small = protocol.dead_avatar_key_small
	self.role_count_info.dead_name = protocol.dead_name

	self.role_count_info.is_enter_or_leave_fb = protocol.is_enter_or_leave_fb

end

function KillTipData:GetKRoleCountInfo()
	return self.role_count_info
end

-- 传闻
function KillTipData:SetKillRoleChuanwen(protocol)
	self.kill_role_chuanwen.liansha_count = protocol.liansha_count
	self.kill_role_chuanwen.killer_camp = protocol.killer_camp
	self.kill_role_chuanwen.killer_id = protocol.killer_id
	self.kill_role_chuanwen.killer_prof = protocol.killer_prof
	self.kill_role_chuanwen.killer_sex = protocol.killer_sex
	self.kill_role_chuanwen.killer_avatar_key_big = protocol.killer_avatar_key_big
	self.kill_role_chuanwen.killer_avatar_key_small = protocol.killer_avatar_key_small
	self.kill_role_chuanwen.killer_name = protocol.killer_name

	self.kill_role_chuanwen.dead_camp = protocol.dead_camp
	self.kill_role_chuanwen.dead_id = protocol.dead_id
	self.kill_role_chuanwen.dead_prof = protocol.dead_prof
	self.kill_role_chuanwen.dead_sex = protocol.dead_sex
	self.kill_role_chuanwen.dead_avatar_key_big = protocol.dead_avatar_key_big
	self.kill_role_chuanwen.dead_avatar_key_small = protocol.dead_avatar_key_small
	self.kill_role_chuanwen.dead_name = protocol.dead_name

end


function KillTipData:GetKillRoleChuanwen(protocol)
	return self.kill_role_chuanwen
end
