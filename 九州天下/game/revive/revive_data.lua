ReviveData = ReviveData or BaseClass()

ReviveDataTime = {
	RevivieTime = 30
}

ReviveDataItemId = {
	ItemId = 26900
}

ReviveDataMoney = {
	Money = 20
}

function ReviveData:__init()
	if ReviveData.Instance ~= nil then
		print_error("[ReviveData] Attemp to create a singleton twice !")
		return
	end
	self.killer_name = ""
	ReviveData.Instance = self

	self.role_realive_cost = {
		local_revive_type = 0,
		param2 = 0
	}						

	self.huguozhili_info = {
		today_die_times = 0,
		active_huguozhili_timestamp = 0,
		today_active_times = 0
	}

	self:GetTodayFreeReviveNum()
end

function ReviveData:__delete()
	self.revive_info = nil
	ReviveData.Instance = nil
end

function ReviveData:SetRoleReviveInfo(portocol)
	self.revive_info = portocol
end

function ReviveData:GetRoleReviveInfo()
	return self.revive_info
end

function ReviveData:SetKillerName(name)
	self.killer_name = name
end

function ReviveData:GetKillerName()
	return self.killer_name
end

function ReviveData:SetRoleReAliveCostType(protocol)
	self.role_realive_cost.local_revive_type = protocol.local_revive_type		-- 0代表可用国家免费复活,1代表只能用元宝复活
	self.role_realive_cost.param2 = protocol.param2								-- 可用国家免费复活时,代表剩余的复活次数,可用元宝复活时,代表花费的元宝
end

function ReviveData:GetRoleReAliveCostType()
	return self.role_realive_cost
end

function ReviveData:GetGongNeng()
	self.gongneng_sort = {
		[1]={	-- 锻造
			img_name = 'Forge',
			view_name = "Forge",
		},
		[2]={	-- 形象
			img_name = 'Iconic',
			view_name = "Advance",
		},
		[3]={	-- 女神
			img_name = 'Beauty',
			view_name = "Beauty",
		},
		[4]={	-- 功勋
			img_name = 'Baoju',
			view_name = "BaoJu",
		},
		[5]={	-- 精灵
			img_name = 'General',
			view_name = "FamousGeneralView",
		},
	}
	return self.gongneng_sort
end

function ReviveData:SetReviveFreeTime(portocol)
	self.UsedTime=portocol.param1
end

function ReviveData:GetTodayFreeReviveNum()
	self.today_free_revive_num=ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1].today_free_relive_num
end

function ReviveData:SetHuguozhiliInfo(protocol)
	self.huguozhili_info.today_die_times = protocol.today_die_times
	self.huguozhili_info.active_huguozhili_timestamp = protocol.active_huguozhili_timestamp
	self.huguozhili_info.today_active_times = protocol.today_active_times
end

function ReviveData:GetHuguozhiliInfo()
	return self.huguozhili_info
end

function ReviveData:GetHuguozhiliCfg()
	return ConfigManager.Instance:GetAutoConfig("huguozhili_auto") or {}
end

function ReviveData:GetTotalActiveTime()
	local die_time = self.huguozhili_info.today_die_times
	local huguozhili_active_cfg = self:GetHuguozhiliCfg().huguozhili_active or {}
	local active_time = 0
	for k, v in pairs(huguozhili_active_cfg) do
		if die_time >= v.need_die_times then
			active_time = v.can_active_times
		end
	end

	local max_die_time = huguozhili_active_cfg[#huguozhili_active_cfg].need_die_times
	if die_time > max_die_time then
		return huguozhili_active_cfg[#huguozhili_active_cfg].can_active_times
	end

	return active_time
end

function ReviveData:GetCanActiveTime()
	local die_time = self.huguozhili_info.today_die_times
	local huguozhili_active_cfg = self:GetHuguozhiliCfg().huguozhili_active or {}
	for k, v in pairs(huguozhili_active_cfg) do
		if v.need_die_times - die_time > 0 then
			return v.need_die_times - die_time
		end
	end

	return 0
end

function ReviveData:GetCanActive()
	local huguozhili_other_cfg = self:GetHuguozhiliCfg().other[1] or {}
	local buff_interval = TimeCtrl.Instance:GetServerTime() - self.huguozhili_info.active_huguozhili_timestamp
	return buff_interval <= huguozhili_other_cfg.buff_cd_s and self.huguozhili_info.active_huguozhili_timestamp > 0
end

function ReviveData:GetBuffCd()
	local huguozhili_other_cfg = self:GetHuguozhiliCfg().other[1] or {}
	local buff_interval = TimeCtrl.Instance:GetServerTime() - self.huguozhili_info.active_huguozhili_timestamp
	return buff_interval <= huguozhili_other_cfg.buff_cd_s and buff_interval >= huguozhili_other_cfg.buff_interval_s and self.huguozhili_info.active_huguozhili_timestamp > 0, huguozhili_other_cfg.buff_cd_s - buff_interval
end