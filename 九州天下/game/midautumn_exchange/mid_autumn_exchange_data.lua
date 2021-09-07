MidAutumnExchangeData = MidAutumnExchangeData or BaseClass()

function MidAutumnExchangeData:__init()
	if MidAutumnExchangeData.Instance then
		ErrorLog("[MidAutumnExchangeData] attempt to create singleton twice!")
		return
	end
	MidAutumnExchangeData.Instance =self
	self.is_show_red = true
	self.need_cfg = nil
	self.type_cfg = nil
	self.type_num = 0
	self.old_day = 0
	self.num_list = {}
	RemindManager.Instance:Register(RemindName.MidAutumnActExchange, BindTool.Bind(self.GetRemind, self))
end

function MidAutumnExchangeData:__delete()
	MidAutumnExchangeData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.MidAutumnActExchange)
end

function MidAutumnExchangeData:SetNumTimeInfo(procotol)
	self.num_list = procotol.num_list or {}
end

function MidAutumnExchangeData:GetNumTimeInfo(type,index,falg_index)
	falg_index = falg_index or 0
	if self.num_list and self.num_list[type] and self.num_list[type][index] and self.num_list[type][index][falg_index] then
		return self.num_list[type][index][falg_index]
	end
	return 0
end

function MidAutumnExchangeData:GetDressShopCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().active_item_exchange or {}
end

--获取对应天数类型配置
function MidAutumnExchangeData:GetCurShopCfg()
	TimeCtrl.Instance:SendTimeReq()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if self.old_day == cur_day and self.need_cfg ~= nil then
		return self.need_cfg, self.type_num, self.type_cfg
	end
	self.old_day = cur_day
	self.need_cfg = {}
	self.type_cfg = {}
	local all_cfg = self:GetDressShopCfg()
	self.type_num = 0
	for k,v in pairs(all_cfg) do
		if cur_day >= v.open_day and cur_day <= v.close_day then
			if self.need_cfg[v.type] == nil then
				self.need_cfg[v.type] = {}
				self.type_cfg[self.type_num] = v
				self.type_num = self.type_num + 1
			end
			self.need_cfg[v.type][v.index] =  v
		end
	end
	return self.need_cfg, self.type_num, self.type_cfg
end

function MidAutumnExchangeData:GetRemind()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN_ITEM_EXCHANGE)
	if is_open then
		return self.is_show_red and 1 or 0
	end
	return 0
end

function MidAutumnExchangeData:SetRemind(is_show_red)
	self.is_show_red = is_show_red
end