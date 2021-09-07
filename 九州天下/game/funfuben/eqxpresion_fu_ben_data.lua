ExpresionFuBenData = ExpresionFuBenData or BaseClass()

function ExpresionFuBenData:__init()
	if ExpresionFuBenData.Instance ~= nil then
		print_error("[ExpresionFuBenData] Attemp to create a singleton twice !")
		return
	end
	ExpresionFuBenData.Instance = self
	self.expresion_cfg = ConfigManager.Instance:GetAutoConfig("funopenfbconfig_auto")
	self.mount_fb_info = {}
	self.wing_fb_info = {}
	self.jingling_fb_info = {}
end

function ExpresionFuBenData:__delete()
	ExpresionFuBenData.Instance = nil
end

function ExpresionFuBenData:GetExpresionFuBenCfg()
	return self.expresion_cfg
end

function ExpresionFuBenData:GetMountFuBenCfg()
	return self.expresion_cfg.mount_fb
end

function ExpresionFuBenData:GetWingFuBenCfg()
	return self.expresion_cfg.wing_fb
end

function ExpresionFuBenData:GetSpiritFuBenCfg()
	return self.expresion_cfg.jingling_fb
end

--坐骑副本信息
function ExpresionFuBenData:SetMountFuBenInfo(protocol)
	self.mount_fb_info.is_finish 						= protocol.is_finish or 0					--是否结束
	self.mount_fb_info.is_pass_phase_one 				= protocol.is_pass_phase_one or 0			--是否通过关卡1
	self.mount_fb_info.is_pass_phase_two 				= protocol.is_pass_phase_two or 0			--是否通过关卡2
	self.mount_fb_info.is_pass_phase_three 				= protocol.is_pass_phase_three or 0			--是否通过关卡3
	self.mount_fb_info.phase_one_monster_refresh_num 		= protocol.phase_one_monster_refresh_num or 0	--关卡1怪物刷新总数量
	self.mount_fb_info.kill_phase_one_monster_num 		= protocol.kill_phase_one_monster_num or 0	--关卡1怪物击杀数量
	self.mount_fb_info.kill_phase_two_master_num 		= protocol.kill_phase_two_master_num or 0	--关卡2击杀法师数量
	self.mount_fb_info.phase_three_monster_refresh_num 	= protocol.phase_three_monster_refresh_num or 0	--关卡3怪物刷新总数量
	self.mount_fb_info.kill_phase_three_monster_num 	= protocol.kill_phase_three_monster_num or 0	--关卡3怪物击杀数量
end

function ExpresionFuBenData:GetMountFuBenInfo()
	return self.mount_fb_info
end

--羽翼副本信息
function ExpresionFuBenData:SetWingFuBenInfo(protocol)
	self.wing_fb_info.is_finish 						= protocol.is_finish or 0					--是否结束
	self.wing_fb_info.is_pass_phase_one 				= protocol.is_pass_phase_one or 0			--是否通过关卡1
	self.wing_fb_info.is_pass_phase_two 				= protocol.is_pass_phase_two or 0			--是否通过关卡2

	self.wing_fb_info.is_pass_phase_three 				= protocol.is_pass_phase_three or 0			--是否通过关卡3
	self.wing_fb_info.is_kill_bridge_monster 			= protocol.is_kill_bridge_monster or 0		--是否击杀吊桥机关

	self.wing_fb_info.phase_one_monster_refresh_num 	= protocol.phase_one_monster_refresh_num or 0--关卡1怪物刷新总数量
	self.wing_fb_info.kill_phase_one_monster_num 		= protocol.kill_phase_one_monster_num or 0	--关卡1怪物击杀数量
	self.wing_fb_info.phase_two_monster_refresh_num 	= protocol.phase_two_monster_refresh_num or 0	--关卡2怪物刷新总数量
	self.wing_fb_info.kill_phase_two_monster_num 		= protocol.kill_phase_two_monster_num or 0	--关卡2怪物击杀数量
	self.wing_fb_info.phase_three_monster_refresh_num 	= protocol.phase_three_monster_refresh_num or 0	--关卡3怪物刷新总数量
	self.wing_fb_info.kill_phase_three_monster_num 		= protocol.kill_phase_three_monster_num or 0	--关卡3怪物击杀数量
end

function ExpresionFuBenData:GetWingFuBenInfo()
	return self.wing_fb_info
end

--精灵副本信息
function ExpresionFuBenData:SetJingLingFuBenInfo(protocol)
	self.jingling_fb_info.is_finish 						= protocol.is_finish or 0					--是否结束
	self.jingling_fb_info.is_pass_phase_one 				= protocol.is_pass_phase_one or 0			--是否通过关卡1
	self.jingling_fb_info.is_pass_phase_two 				= protocol.is_pass_phase_two or 0			--是否通过关卡2
	self.jingling_fb_info.is_kill_little_boss 				= protocol.is_kill_little_boss or 0			--是否击杀小boss
	
	self.jingling_fb_info.is_kill_large_boss 				= protocol.is_kill_large_boss or 0			--是否击杀大boss

	self.jingling_fb_info.phase_one_monster_refresh_num 	= protocol.phase_one_monster_refresh_num or 0--阶段1怪物数量
	self.jingling_fb_info.kill_phase_one_monster_num 		= protocol.kill_phase_one_monster_num or 0	--击杀阶段1怪物数量
	self.jingling_fb_info.phase_two_monster_refresh_num 	= protocol.phase_two_monster_refresh_num or 0--阶段2怪物数量
	self.jingling_fb_info.kill_phase_two_monster_num 		= protocol.kill_phase_two_monster_num or 0	--击杀阶段2怪物数量
end

function ExpresionFuBenData:GetJingLingFuBenInfo()
	return self.jingling_fb_info
end

function ExpresionFuBenData:GetGatherInfoById(id)
	local gather_config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list
	return gather_config[id]
end