HongBaoData = HongBaoData or BaseClass()

function HongBaoData:__init()
	if HongBaoData.Instance ~= nil then
		print_error("[HongBaoData] Attemp to create a singleton twice !")
	end
	HongBaoData.Instance = self

	self.open_type = GameEnum.HONGBAO_SEND
	self.hongbao_type = RED_PAPER_TYPE.RED_PAPER_TYPE_COMMON

	-- HONGBAO_SEND = 0,							--发送红包
	-- HONGBAO_GET = 1,								--领取红包
	-- HONGBAO_SERVER = 2,							--全服红包

	self.red_info = {}
	self.red_result = {
		notify_reason = 0,
		fetch_gold = 0,
		creater_name = "",
	}

	self.cur_hongbao_id_list = {}
	self.cur_sever_hongbao_id_list = {}
	self.daily_can_send_gold = 1000			--当天可发送钻石数
	self.kouling_hongbao_info = {}
	self.kouling_hongbao_list = {}
end

function HongBaoData:__delete()
	HongBaoData.Instance = nil
end

function HongBaoData:GetOpenType()
	return self.open_type
end

function HongBaoData:SetOpenType(param)
	self.open_type = param
end

function HongBaoData:SetHongbaoType(param)
	self.hongbao_type = param
end

function HongBaoData:GetHongbaoType()
	return self.hongbao_type
end

function HongBaoData:GetRedPaperDetailInfo()
	return self.red_info
end
function HongBaoData:SetKoulingRedPaperInfo(info)
	self.kouling_hongbao_info = info
end

function HongBaoData:GetKoulingRedPaperInfo()
	return self.kouling_hongbao_info
end

function HongBaoData:SetDailyCanSendGold(gold)
	self.daily_can_send_gold = gold
end

function HongBaoData:GetDailyCanSendGold()
	return self.daily_can_send_gold
end

function HongBaoData:SetRedPaperDetailInfo(info)
	self.red_info.notify_reason = info.notify_reason
	self.red_info.id = info.id
	self.red_info.type = info.type
	self.red_info.currency_type = info.currency_type
	self.red_info.total_gold_num = info.total_gold_num
	self.red_info.fetch_gold_num = info.fetch_gold_num
	self.red_info.can_fetch_times = info.can_fetch_times
	self.red_info.timeount_timestamp = info.timeount_timestamp
	self.red_info.creater_uid = info.creater_uid
	self.red_info.creater_name = info.creater_name
	self.red_info.creater_guild_id = info.creater_guild_id
	self.red_info.fetch_user_count = info.fetch_user_count
	self.red_info.uid = info.uid
	self.red_info.gold_num = info.gold_num
	self.red_info.log_list = info.log_list
	self.red_info.sex = info.sex
	self.red_info.prof = info.prof
	self.red_info.avatar_key_big = info.avatar_key_big
	self.red_info.avatar_key_small = info.avatar_key_small
	self.red_info.boss_id = info.boss_id
end

function HongBaoData:AddKoulingRedPaper(info)
	local kl_hb = {}
	kl_hb.notify_reason = info.notify_reason
	kl_hb.id = info.id
	kl_hb.type = info.type
	kl_hb.total_gold_num = info.total_gold_num
	kl_hb.fetch_gold_num = info.fetch_gold_num
	kl_hb.can_fetch_times = info.can_fetch_times
	kl_hb.timeount_timestamp = info.timeount_timestamp
	kl_hb.creater_uid = info.creater_uid
	kl_hb.creater_name = info.creater_name
	kl_hb.creater_guild_id = info.creater_guild_id
	kl_hb.avatar_key_big = info.avatar_key_big
	kl_hb.avatar_key_small = info.avatar_key_small
	kl_hb.sex = info.sex
	kl_hb.prof = info.prof
	kl_hb.boss_id = info.boss_id
	kl_hb.fetch_user_count = info.fetch_user_count
	kl_hb.log_list = info.log_list
	self.kouling_hongbao_list[kl_hb.id] = kl_hb
end

function HongBaoData:GetRedPaperLog()
	return self.red_info.log_list or {}
end

function HongBaoData:GetRedPaperFetchResult()
	return self.red_result
end

function HongBaoData:SetRedPaperFetchResult(info)
	self.red_result.notify_reason = info.notify_reason
	self.red_result.fetch_gold = info.fetch_gold
	self.red_result.creater_name = info.creater_name
	self.red_result.type = info.type
end

function HongBaoData:SetRedPaperId(id)
	self.red_paper_id = id
end

function HongBaoData:GetRedPaperId()
	return self.red_paper_id or 0
end

function HongBaoData:SetCurHongBaoIdList(id, type)
	table.insert(self.cur_hongbao_id_list, {id = id, type = type})
end

function HongBaoData:RemoveCurHongBaoIdList()
	table.remove(self.cur_hongbao_id_list, 1)
end

function HongBaoData:GetCurHongBaoIdList()
	return self.cur_hongbao_id_list
end

function HongBaoData:GetCanGetId()
	local id = nil
	if self.cur_hongbao_id_list == nil then
		return 
	end

	local remove_list = {}
	local now_timer = TimeCtrl.Instance:GetServerTime()
	for k,v in pairs(self.cur_hongbao_id_list) do
		if v ~= nil then
			if v.timeount_timestamp > now_timer then
				table.insert(remove_list, v.id)
			else
				if id == nil then
					id = v.id
				end
			end
		end
	end

	for k,v in pairs(remove_list) do
		self:RemoveOneHongbao(v)
	end

	return id 
end

function HongBaoData:GetKouLingCanGetId()
	local id = nil
	if self.kouling_hongbao_list == nil then
		return 
	end

	local remove_list = {}
	local now_timer = TimeCtrl.Instance:GetServerTime()

	for k,v in pairs(self.kouling_hongbao_list) do
		if v ~= nil then
			if v.timeount_timestamp < now_timer then
				table.insert(remove_list, v.id)
			else
				if id == nil then
					id = v.id
				end
			end
		end
	end

	for k,v in pairs(remove_list) do
		self:RemoveOneHongbao(v)
	end

	return id
end

function HongBaoData:GetServerCanGetId()
	local id = nil
	if self.cur_sever_hongbao_id_list == nil then
		return 
	end

	local remove_list = {}
	local now_timer = TimeCtrl.Instance:GetServerTime()

	for k,v in pairs(self.cur_sever_hongbao_id_list) do
		if v ~= nil then
			if v.timeount_timestamp < now_timer then
				table.insert(remove_list, v.id)
			else
				if id == nil then
					id = v.id
				end
			end
		end
	end

	for k,v in pairs(remove_list) do
		self:RemoveOneHongbao(v)
	end

	return id
end


-- 全服红包
function HongBaoData:SetoveCurServerHongBaoIdList(id, type)
	table.insert(self.cur_sever_hongbao_id_list,  {id = id, type = type})
end

function HongBaoData:RemoveCurServerHongBaoIdList()
	table.remove(self.cur_sever_hongbao_id_list, 1)
end

function HongBaoData:GetCurServerHongBaoIdList()
	return self.cur_sever_hongbao_id_list
end

function HongBaoData:RemoveOneHongbao(id)
	local remove_k = nil
	for k,v in pairs(self.cur_hongbao_id_list) do
		if v.id == id then
			remove_k = k
			break
		end
	end

	if remove_k ~= nil then
		local data = table.remove(self.cur_hongbao_id_list, remove_k)
		return data.type
	end

	for k,v in pairs(self.cur_sever_hongbao_id_list) do
		if v.id == id then
			remove_k = k
			break
		end
	end

	if remove_k ~= nil then
		local data = table.remove(self.cur_sever_hongbao_id_list, remove_k)
		return data.type
	end	

	for k,v in pairs(self.kouling_hongbao_list) do
		if v.id == id then
			remove_k = k
			break
		end
	end

	if remove_k ~= nil then
		local data = self.kouling_hongbao_list[remove_k]
		self.kouling_hongbao_list[remove_k] = nil
		return data.type
	end

	return nil
end

function HongBaoData:GetKoulingRedPaper()
	return self.kouling_hongbao_list
end

function HongBaoData:RemoveKoulingRedPaper(id)
	self.kouling_hongbao_list[id] = nil
end

function HongBaoData:GetOneKoulingRedPaper()
	for k,v in pairs(self.kouling_hongbao_list) do
		return v
	end
	return nil
end