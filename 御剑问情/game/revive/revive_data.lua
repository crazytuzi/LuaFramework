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

FETCH_BUFF_OPERATE_TYPE = {
	FETCH_BUFF_INFO = 0,
	ACTIVE_BUFF = 1,
}

function ReviveData:__init()
	if ReviveData.Instance ~= nil then
		print_error("[ReviveData] Attemp to create a singleton twice !")
		return
	end
	self.killer_name = ""
	ReviveData.Instance = self
	self:GetTodayFreeReviveNum()

	self.revive_type = -1
	self.buff_cfg = ConfigManager.Instance:GetAutoConfig("huguozhili_auto").huguozhili_active
	self.other_buff_cfg = ConfigManager.Instance:GetAutoConfig("huguozhili_auto").other[1]
	self.buff_info = {}
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
			img_name = 'Goddress',
			view_name = "Goddess",
		},
		[4]={	-- 功勋
			img_name = 'Treasure',
			view_name = "BaoJu",
		},
		[5]={	-- 精灵
			img_name = 'Spirit',
			view_name = "SpiritView",
		},
	}
	return self.gongneng_sort
end

function  ReviveData:SetReviveFreeTime(portocol)
	self.UsedTime = portocol.param1
end

function  ReviveData:GetTodayFreeReviveNum()
	self.today_free_revive_num=ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1].today_free_relive_num
end

--记录当前点击的复活类型
function ReviveData:SetLastReviveType(revive_type)
	self.revive_type = revive_type
end

function ReviveData:GetLastReviveType()
	return self.revive_type
end

function ReviveData:SetDieBuffInfo(protocol)
	self.buff_info.today_die_times = protocol.today_die_times or 0
	self.buff_info.today_active_times = protocol.today_active_times or 0
	self.buff_info.active_buiff_timestamp = protocol.active_buff_timestamp or 0
end

function ReviveData:GetDieBuffInfo()
	return self.buff_info
end

function ReviveData:GetOtherDieBuffCfg()
	return self.other_buff_cfg
end

function ReviveData:GetCanActiveTimesByDieTimes(die_times)
	if die_times > self.buff_cfg[#self.buff_cfg].need_die_times then
		return self.buff_cfg[#self.buff_cfg].can_active_times
	end

	for i,v in ipairs(self.buff_cfg) do
		if v.need_die_times == die_times then
			return v.can_active_times
		elseif v.need_die_times > die_times then
			if i > 1 then
				return self.buff_cfg[i - 1].can_active_times
			else
				return 0
			end
		end
	end
	return 0
end

function ReviveData:GetNeedDieTimesByActivedTimes(active_times)
	for k,v in pairs(self.buff_cfg) do
		if v.can_active_times == active_times then
			return v.need_die_times
		end
	end
	return 0
end

function ReviveData:GetMaxCanActiveBuffTimes()
	return self.buff_cfg[#self.buff_cfg].can_active_times
end
