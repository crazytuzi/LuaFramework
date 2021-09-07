MidAutumnLotteryData = MidAutumnLotteryData or BaseClass()

function MidAutumnLotteryData:__init()
	if MidAutumnLotteryData.Instance then
		print_error("[MidAutumnLotteryData] Attempt to create to singleton twice")
	end
	MidAutumnLotteryData.Instance = self

	self.chest_shop_mode = -1
	self.rare_item_list = {}
	self.draw_result_list = {} 

	self.happy_draw2_list_cfg = {} 
	self.happy_draw2_other_list_cfg = {} 
	self.happy_draw2_baodi_list_cfg = {}
	self.baodi_copy_table = {}

	self.draw_times = 0 
	self.anim_state = false

	RemindManager.Instance:Register(RemindName.MidAutumnLottery,BindTool.Bind(self.LotteryViewRemind,self))
end

function MidAutumnLotteryData:__delete()
	self.rare_item_list = {}
	self.draw_result_list = {}  
 
	self.happy_draw2_list_cfg = {}  
	self.happy_draw2_other_list_cfg = {} 
	self.happy_draw2_baodi_list_cfg = {}
	self.baodi_copy_table = {}

	MidAutumnLotteryData.Instance = nil 

	RemindManager.Instance:UnRegister(RemindName.MidAutumnLottery)
end

function MidAutumnLotteryData:GetCurRandActCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig()
end

function MidAutumnLotteryData:GetHappyDraw2Cfg()
	local act_cfg = self:GetCurRandActCfg()
	if self.happy_draw2_list_cfg == nil or not next(self.happy_draw2_list_cfg) and act_cfg then 
		self.happy_draw2_list_cfg = ListToMap(act_cfg.happy_draw2,"act_open_days","seq")
	end
	return self.happy_draw2_list_cfg
end

function MidAutumnLotteryData:GetHappyDraw2OtherCfg()
	local act_cfg = self:GetCurRandActCfg()
	if self.happy_draw2_other_list_cfg == nil or not next(self.happy_draw2_other_list_cfg) then  
		self.happy_draw2_other_list_cfg = ListToMap(act_cfg.happy_draw2_other,"act_open_days") 
	end
	return self.happy_draw2_other_list_cfg
end

function MidAutumnLotteryData:GetHappydraw2BaoDiRewardCfg() 
	local act_cfg = self:GetCurRandActCfg() 
	if self.happy_draw2_baodi_list_cfg == nil or not next(self.happy_draw2_baodi_list_cfg) then 
		self.happy_draw2_baodi_list_cfg = ListToMap(act_cfg.happy_draw2_baodi_reward,"seq")
	end 
	return self.happy_draw2_baodi_list_cfg
end

function MidAutumnLotteryData:GetBaoDiRewardCfgLength()
	return #self:GetHappydraw2BaoDiSortRewardCfg() or 0
end

function MidAutumnLotteryData:GetHappydraw2BaoDiSortRewardCfg() 
	local cur_draw_times = self:GetDrawTimes()  
	local happy_draw2_baodi_list_cfg = self:GetHappydraw2BaoDiRewardCfg()
	local baodi_cfg = TableCopy(happy_draw2_baodi_list_cfg)
	local copy_cfg = {}

	if baodi_cfg ~= nil then
		for k, v in pairs(baodi_cfg) do
			if cur_draw_times >= v.draw_times then
				v.is_received = 1
			else
				v.is_received = -1
			end
			table.insert(copy_cfg, v)
		end
	end
	table.sort(copy_cfg, SortTools.KeyLowerSorters("is_received", "draw_times"))
	-- SortTools.SortAsc(copy_cfg,"is_received","draw_times")
	return copy_cfg
end

function MidAutumnLotteryData:GetMaxDrawTimes()
	local cfg = self:GetHappydraw2BaoDiRewardCfg()
	local max_draw_times = 0
	if cfg then
		for k,v in pairs(cfg) do 
			if max_draw_times < v.draw_times then
				max_draw_times = v.draw_times
			end
		end
	end 
	return max_draw_times or 20
end

function MidAutumnLotteryData:GetCurDayPreviewItemList()
	
end

--奖品预览  
function MidAutumnLotteryData:GetCurDayPreviewItemShowList() 
	local cur_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY) 
	local temp_cfg = self:GetHappyDraw2Cfg() 
	cur_day = cur_day or 1  

	local item_list = {}
	if temp_cfg and temp_cfg[cur_day] then  
		for k, v in pairs(temp_cfg[cur_day]) do
			if v.is_show == 1 then
				table.insert(item_list, v)
			end
		end
	end 
	return item_list
end

function MidAutumnLotteryData:GetComsumeInfoList(draw_times)
	if draw_times == nil then 
		draw_times = 1
	end
	local info_list = {}
	local cur_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY) 
	cur_day = cur_day or 1
	local temp_other_cfg = self:GetHappyDraw2OtherCfg()
	if temp_other_cfg and temp_other_cfg[cur_day] then
		if draw_times == 1 then
			info_list = temp_other_cfg[cur_day].one_draw_consume_item
		elseif draw_times == 10 then
			info_list = temp_other_cfg[cur_day].ten_draw_consume_item
		end
	end
	if info_list == nil or not next(info_list) then
		return nil
	end
	return info_list
end

function MidAutumnLotteryData:GetNeedGoldByDrawTimes(draw_times)
	if draw_times == nil then 
		draw_times = 1
	end
	local need_gold = 0
	local cur_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY)
	cur_day = cur_day or 1
	local temp_other_cfg = self:GetHappyDraw2OtherCfg()
	if temp_other_cfg and temp_other_cfg[cur_day] then
		if draw_times == 1 then
			need_gold = temp_other_cfg[cur_day].one_draw_need_gold
		elseif draw_times == 10 then
			need_gold = temp_other_cfg[cur_day].ten_draw_need_gold
		end
	end
	return need_gold or 0
end

function MidAutumnLotteryData:GetLeftTime()
	local act_status = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MID_AUTUMN_LOTTERY) or 0
	local server_time = TimeCtrl.Instance:GetServerTime() or 0
	local time_left = act_status.end_time - server_time 
	return time_left
end

-- 抽奖纪录排行rank list
function MidAutumnLotteryData:SetRareItemList(protocol)
	self.rare_item_list = protocol.rare_item_list
end

function MidAutumnLotteryData:GetRareItemList()
	return self.rare_item_list 
end

function MidAutumnLotteryData:GetRareItemListByIndex(index)
	local record_list = {} 
	if self.rare_item_list and index and self.rare_item_list[index] then
		record_list = self.rare_item_list[index]
	end  
	return record_list or nil
end

function MidAutumnLotteryData:SetChestShopMode(the_mode)
	self.chest_shop_mode = the_mode
end

function MidAutumnLotteryData:GetChestShopMode()
	return self.chest_shop_mode
end

--抽奖结果list
function MidAutumnLotteryData:SetDrawResultList(protocol)
	self.draw_result_list = protocol.item_info_list 
end

function MidAutumnLotteryData:GetDrawResultList()
	return self.draw_result_list
end

function MidAutumnLotteryData:SetOperaTypeInfo(protocol)
	self.draw_times = protocol.draw_times 
end

function MidAutumnLotteryData:GetDrawTimes()
	return self.draw_times or 0
end

function MidAutumnLotteryData:LotteryViewRemind()  
	local info_list = self:GetComsumeInfoList()
	if info_list == nil then
		return 0
	end
	local item_id = info_list.item_id
	local min_num = info_list.num
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)   
	if item_id and item_num and min_num then 
		if item_num >= min_num then
			return 1
		end
	end
	return 0
end

function MidAutumnLotteryData:SetAnimState(state)
	self.anim_state = state
end

function MidAutumnLotteryData:GetAnimState()
	return self.anim_state
end

function MidAutumnLotteryData:SetIfUseIngot(is_use)
	self.is_use_ingot = is_use
end

function MidAutumnLotteryData:GetIfUseIngot()
	return self.is_use_ingot or 0
end