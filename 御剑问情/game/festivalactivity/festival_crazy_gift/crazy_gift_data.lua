CrazyGiftData = CrazyGiftData or BaseClass()

function CrazyGiftData:__init()
  	if nil ~= CrazyGiftData.Instance then
		return
	end

     CrazyGiftData.Instance = self

     self.gift_config = ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto").crazy_gift

     self.gift_info_list = {}  --下发的协议存放的地方
     self.crazy_gift_list = {}
     self.all_sell = false
end

function CrazyGiftData:__delete()

    CrazyGiftData.Instance = nil
    self.gift_config = {}
    self.gift_info_list = {}
end


function CrazyGiftData:SetGiftInfo(protocol)
   self.gift_info_list = protocol.buy_times_list
   self:SetCrazyGiftList()
end

function  CrazyGiftData:SetCrazyGiftList()
	local num = self:GetGiftTypeCount() or 0
	local item_list = {}
	self.all_sell = true
	for i = 1, num do
		local list = self:GetCurGiftConfig(i - 1)
		local reward_list = self.gift_info_list[i] or {}
		for k, v in pairs(list) do
			if reward_list[k] == nil or reward_list[k] < v.max_buy_times or k == #list then
				 item_list[i] = {cfg = v, buy_num = reward_list[k] or 0 , gift_type = v.gift_type, is_sell_out = reward_list[k] < v.max_buy_times and 0 or 1}
				 if reward_list[k] < v.max_buy_times then
				 	self.all_sell = false
				 end
				 break
			end
		end
	end
	table.sort(item_list, SortTools.KeyLowerSorter("is_sell_out", "gift_type"))
	self.crazy_gift_list = item_list
end

function  CrazyGiftData:CrazyGiftInfo()
	return self.crazy_gift_list
end

function  CrazyGiftData:GetGiftInfo()
	return self.gift_info_list
end

function CrazyGiftData:IsAllSell()
	return self.all_sell
end

--根据服务端下发的活动天数 来自动获取相对应天数的配置
function CrazyGiftData:GetCrazyGiftConfig()
 return ActivityData.Instance:GetRandActivityConfig(self.gift_config, FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CRAZY_GIFT)
end

--得到礼包类型个数
function CrazyGiftData:GetGiftTypeCount()
  local list = (ListToMap(self:GetCrazyGiftConfig(),"gift_type"))
  local config_list = {}
  for k,v in pairs(list) do
  	table.insert(config_list,k+1,v)
  end

  return #config_list
end

--得到每一种礼包中的配置
function CrazyGiftData:GetCurGiftConfig(gift_type)
  local total_gift_config = self:GetCrazyGiftConfig()
  local gift_type_config = {}
  if gift_type then
	  for k,v in pairs (total_gift_config) do
	  	 if gift_type == v.gift_type then
	  	 	table.insert(gift_type_config,v)
	  	 end
	  end
  end
  return gift_type_config
end

--得到当前种类的礼包中，每一个礼包的配置
function CrazyGiftData:GetCurOnceGiftConfig(gift_type,seq)
	local gift_type_config = self:GetCurGiftConfig(gift_type)
	local cur_gift_cfg = {}
	if seq then
		for k,v in pairs (gift_type_config) do
			if seq == v.seq then
				table.insert(cur_gift_cfg,v)
			end
		end
	end
	return cur_gift_cfg
end

--得到当前第几档的全部种类的礼包
function CrazyGiftData:GetCurSeqGift(seq)
	local gift_config = self:GetCrazyGiftConfig()
	local cur_gift_cfg = {}
	for k,v in pairs(gift_config) do
		if seq == v.seq then
			table.insert(cur_gift_cfg,v)
		end
	end
	return cur_gift_cfg
end