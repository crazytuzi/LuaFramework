VipData = VipData or BaseClass()

VipData.VIP_INFO_EVENT = "vip_info_event"
VipData.VIP_REWARD = "vip_reward"
VipData.POLI_CHANGE = "poli_change"

VipData.VIP_BOSS_MAX_SHOW = 8 -- vip_boss最大显示数量
VipData.VIP_BOSS_OID_SHOW = 4 -- vip_boss已挑战成功显示数量

function VipData:__init()
	if VipData.Instance ~= nil then
		ErrorLog("[VipData] Attemp to create a singleton twice !")
	end
	VipData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.all_server_vip_user_num = 0
	self.daily_recv_reward_flag = 1
	self.vip_level = 0
	self.charge_total_yuanbao = 0
	self.lev_reward_recv_flag_list = {}

	self.vip_boss_guan_info = {			 -- vip_boss关卡信息
		guan_num = 1,					 -- 已挑战关卡数
		count = 0,						 -- 当前魄力值
	}
	self.need_play_eff = false -- 是否播放魄力值增加特效

	GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.VipLevel, BindTool.Bind(self.CondVipLevel, self))
end

function VipData:__delete()
	VipData.Instance = nil
end

function VipData:SetIssueVIPInfo(protocol)
	self.all_server_vip_user_num = protocol.all_server_vip_user_num
	self.daily_recv_reward_flag = protocol.daily_recv_reward_flag
	self.vip_level = protocol.vip_lev
	self.charge_total_yuanbao = protocol.charge_total_yuanbao

	GameCondMgr.Instance:CheckCondType(GameCondType.VipLevel)
	self:DispatchEvent(VipData.VIP_INFO_EVENT)
end

function VipData:SetVIPLevRewardFlag(protocol)
	local temp_flag_list = bit:d2b(protocol.recv_vip_reward_flag or 0)
	for i=1,32 do
		self.lev_reward_recv_flag_list[i] = temp_flag_list[33 - i]
	end
	self:DispatchEvent(VipData.VIP_REWARD)
end

function VipData:IsVIPLevRewardReceive(level)
	local flag = self.lev_reward_recv_flag_list[level]
	return flag and flag == 1 or false
end

function VipData:IsExpBuffReceive()
	return self.daily_recv_reward_flag == 1
end

function VipData.GetVipPrivilegeCfgByLevel(vip_level)
	return VipPrivilegesCfg and VipPrivilegesCfg[vip_level] or {}
end

function VipData.GetVipCfg()
	return VipConfig
end

function VipData.GetVipGradeCfgByLevel(vip_level)
	return VipData.GetVipCfg().VipGrade[vip_level]
end


function VipData.GetVipGradeItems(vip_level)
	local items = {}
	local level_cfg = VipData.GetVipCfg().VipGrade[vip_level]
	if level_cfg and level_cfg.reward then
		if level_cfg.headtitleItemId then
			items[1] = {type=0, id=level_cfg.headtitleItemId, count=1, strong=0, quality=0,
			bind=1, sex=-1, job=0, effectId=920}
		end

		local role_prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local role_sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		for i = 1, #level_cfg.reward do
			local item = level_cfg.reward[i]
			if item.sex == -1 or item.sex == role_sex then
				if item.job == 0 or item.job == role_prof then
					items[#items + 1] = item
				end
			end
		end
	end
	return items
end

function VipData:GetNextVipNeedInfo()
	local next_level_info = {next_level = 0, need_gold = 0}
	local cur_level_cfg = VipData.GetVipGradeCfgByLevel(self.vip_level)
	local next_level_cfg = VipData.GetVipGradeCfgByLevel(self.vip_level + 1)
	if next_level_cfg then
		next_level_info.next_level = next_level_cfg.vip
		next_level_info.need_gold = next_level_cfg.needYuanBao
	elseif cur_level_cfg then
		next_level_info.next_level = cur_level_cfg.vip
		next_level_info.need_gold = cur_level_cfg.needYuanBao
	end
	return next_level_info
end

function VipData.GetVipWelfareList(level)
	local vip_welfare_data = {
		{type = 1,param = 0},
		{type = 2,param = 0},
		{type = 3,param = nil},
	}
	local vip_privilege_cfg = VipData.GetVipPrivilegeCfgByLevel(level)
	if vip_privilege_cfg then
		vip_welfare_data[1].param = vip_privilege_cfg.barscount
		vip_welfare_data[2].param = vip_privilege_cfg.attack
	end

	return vip_welfare_data
end

function VipData:GetVipWelfareRemindNum()
	-- if self.vip_level > 0 and self:IsExpBuffReceive() == false then
	-- 	return 1
	-- end
	for i = 1, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE) do
		if self:IsVIPLevRewardReceive(i) == false then
			return 1
		end
	end
	return 0
end

function VipData:GetVipLevel()
	return self.vip_level
end

function VipData:SetSelectVipBossData(data)
	self.select_vip_boss_data = data or {}
end

function VipData:GetSelectVipBossData()
	return self.select_vip_boss_data or {}
end

function VipData:SetSelectVipBossNextData(data)
	self.select_vip_boss_next_data = data or {}
end

function VipData:GetSelectVipBossNextData()
	return self.select_vip_boss_next_data or {}
end

function VipData:SetVipBossGuanInfo(protocol)
	local old_count = self.vip_boss_guan_info.count or 0
	self.vip_boss_guan_info.guan_num = protocol.guan_num or 1
	self.vip_boss_guan_info.count = protocol.count or 0
	self:DispatchEvent(VipData.POLI_CHANGE, {part = self.vip_boss_guan_info.guan_num, count = self.vip_boss_guan_info.count, old_count = old_count, need_play_eff = self.need_play_eff})
	if not self.need_play_eff then
		if TaskData.Instance:GetCurTaskId() >= ClientVipTaskId then
			self.need_play_eff = true
		end
	end
end

function VipData:GetVipBossGuanInfo()
	return self.vip_boss_guan_info or {guan_num = 1, count = 0}
end

function VipData.GetVipBossGuanShowList()
	local vip_boss_cfg = VipChapterConfig and VipChapterConfig.Chapters or {}
	local guan_info = VipData.Instance:GetVipBossGuanInfo()

	-- 从挑战成功前几个boss开始取
	local state_guan = guan_info.guan_num - VipData.VIP_BOSS_OID_SHOW

	local list = {}
	for i = 1, VipData.VIP_BOSS_MAX_SHOW do
		local guan = state_guan + i
		local cfg = vip_boss_cfg[guan]
		if cfg then
			local boss_id = cfg.boss and cfg.boss.monId or 1
			local boss_cfg = StdMonster and StdMonster[boss_id] or {}
			local boss_name = boss_cfg.name or ""

			-- 此关的魄力值的进度
			local consume = vip_boss_cfg.consumeCharm or 100
			local bool = guan_info.guan_num > guan		 -- 是否已通关
			local calibration = consume * (guan - guan_info.guan_num - 1)
			local count = bool and consume or (guan_info.count - calibration)
			local percent = count / consume * 100
			
			local power = cfg.power or 0
			local show = {}
			for i,v in ipairs(cfg.show or {}) do
				show[i] = ItemData.InitItemDataByCfg(v)
			end
			
			list[#list + 1] = {
				["guan"] = guan,
				["boss_name"] = boss_name,
				["percent"] = percent,
				["power"] = power,
				["show"] = show,
			}
		end
	end

	return list
end

function VipData:CondVipLevel(param)
	return self.vip_level >= param
end
