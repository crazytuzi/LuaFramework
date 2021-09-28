ScratchTicketData = ScratchTicketData or BaseClass()

function ScratchTicketData:__init()
	if ScratchTicketData.Instance ~= nil then
		ErrorLog("[ScratchTicketData] attempt to create singleton twice!")
		return
	end
	ScratchTicketData.Instance = self
	self.count = -1
	self.chest_shop_mode = -1

	RemindManager.Instance:Register(RemindName.GuaGuaLe, BindTool.Bind(self.GetGuaGuaLeRemind, self))
end

function ScratchTicketData:__delete()
	ScratchTicketData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.GuaGuaLe)
	self.count = nil
	self.chest_shop_mode =nil
end

function ScratchTicketData:GetGuaGuaLeOtherCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().other
end

function ScratchTicketData:GetGuaGuaLeCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig()
end

function ScratchTicketData:GetThirtyKeyNum()
	self.cfg = self:GetGuaGuaLeOtherCfg()
    local  keynum = 0
	if self.cfg and self.cfg[1] and self.cfg[1].guagua_roll_item_id then
        keynum = ItemData.Instance:GetItemNumInBagById(self.cfg[1].guagua_roll_item_id)
    end
    
	return keynum
end

function ScratchTicketData:GetGuaGuaCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().guagua
	if cfg == nil then 
		return cfg
    end

    local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA)
	return data
end

function ScratchTicketData:GetGuaGuaCfgByList()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().guagua
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA)
	local data_list = ListToMapList(data,"is_special")
	if cfg == nil and data_list == nil then
		return nil
	end

	return data_list[1]
end

function ScratchTicketData:GetGuaGuaRewardCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().guagua_acc_reward
	if cfg == nil then
		return nil
	end
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA)
	return data
end

function ScratchTicketData:GetGuaGuaCfgBySeq()
	local cfg = self:GetGuaGuaCfg()
	return ListToMap(cfg,"seq")
end

function ScratchTicketData:SetRAGuaGuaInfo(protocol)
	self.guagua_acc_count = protocol.guagua_acc_count or 0
	self.guagua_acc_reward_has_fetch_flag_table = bit:d2b(protocol.guagua_acc_reward_has_fetch_flag)   
end

function ScratchTicketData:GuaGuaMultiReward(protocol)
	self.reward_count = protocol.reward_count
	self.is_bind = protocol.is_bind
	self.reward_seq_list = protocol.reward_seq_list
end

function ScratchTicketData:GetGuaGuaCount()
	return self.guagua_acc_count or 0
end

function ScratchTicketData:GetCanFetchFlag(index)
	if not self.guagua_acc_reward_has_fetch_flag_table then
		return false
	end

	return (1 == self.guagua_acc_reward_has_fetch_flag_table[33 - index]) and true or false
end

function ScratchTicketData:GetAccFlag()
	-- body
end

function  ScratchTicketData:GetGuaGuaIndex()
	return self.reward_seq_list
end

function ScratchTicketData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

function ScratchTicketData:GetChestShopMode()
	return self.chest_shop_mode
end

function ScratchTicketData:GetChestCount()
	return self.count
end

function ScratchTicketData:GetGuaGuaLeRemind()
	local num = GetListNum(self:GetGuaGuaRewardCfg())
	local data = self:GetGuaGuaRewardCfg()
	if data ~= nil then 
		if self:GetThirtyKeyNum() > 0 then
		    return 1
		end

		for i = 1, num do
		    if not data[i] or not data[i].acc_count then
		        return 0
		    end
            
			if not self:GetCanFetchFlag(i) and self.guagua_acc_count and data[i].acc_count <= self.guagua_acc_count then
				return 1
			end
		end
	end

	return 0
end

function ScratchTicketData:GetChestShopItemInfo()
	local cfg = self:GetGuaGuaCfgBySeq()
	local data = {}
	 for k,v in pairs(self.reward_seq_list) do
	 	table.insert(data,cfg[v].reward_item[0])
	 end
	 return data
end