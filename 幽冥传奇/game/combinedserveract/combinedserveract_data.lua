CombinedServerActData = CombinedServerActData or BaseClass()
CombinedActId ={
--	Double = 1,    			--双倍经验, 
--	Gongcheng = 2,			--合区领取城主奖励, 
--	YB_Party = 3,			--元宝派对, 
--	CB_Party = 4,			--翅膀派对, 
--	BS_Party = 5,			--宝石派对, 
--	SZ_Party = 6,			--圣珠派对, 
--	Fashion = 7,			--时装礼包, 
--	DZP = 8,				--幸运大转盘, 
--	Xunbao = 9,				--疯狂寻宝
    Accumulative = 1,	    -- 累计充值,
    Gongcheng = 2,	        -- 合区领取城主奖励,
    YB_Party = 3,	        -- 元宝派对,
    CB_Party = 4,	        -- 翅膀派对,
    BS_Party = 5,	        -- 宝石派对,
    ZH_Party = 6,	        -- 铸魂派对,
    LH_Party = 7,           --龙魂派对,
    Fashion = 8,	        -- 时装礼包,
    DZP = 9,	            -- 幸运大转盘
}

function CombinedServerActData:__init()
	if CombinedServerActData.Instance then
		ErrorLog("[CombinedServerActData] Attemp to create a singleton twice !")
	end

	CombinedServerActData.Instance = self
	self.act_info = {}
	self.dzp_reward_log = {}
	self:InitActInfo()
end

function CombinedServerActData:__delete()
	CombinedServerActData.Instance = nil
end


function CombinedServerActData:InitActInfo()
	for i,v in pairs(CombinedActId) do
		self.act_info[v] = {}
		self.act_info[v].act_id = v
		self.act_info[v].begin_time = 0
		self.act_info[v].end_time = 0
		if self.act_info[v].act_id == CombinedActId.Gongcheng then
			self.act_info[v].act_state = 0
		elseif self.act_info[v].act_id == CombinedActId.Fashion then
			self.act_info[v].reward_count = 0
			self.act_info[v].xb_count = 0
		elseif self.act_info[v].act_id == CombinedActId.DZP then
			self.act_info[v].is_open = 0
			self.act_info[v].ylq_count = 0
			self.act_info[v].ylq_gold = 0
			self.act_info[v].cqq_count = 0
			self.act_info[v].cqq_gold = 0 
		end
	end
end

function CombinedServerActData.GetCombinedServActCfg(act_id)
	if cc.FileUtils:getInstance():isFileExist("scripts/config/server/config/activityconfig/CombineServerActivity/CombineActivity/ComActivity" .. act_id .. ".lua") then
		return ConfigManager.Instance:GetServerConfig("activityconfig/CombineServerActivity/CombineActivity/ComActivity" .. act_id)[1]
	end
	return nil
end

function CombinedServerActData.GetIndexByActId(act_id)
	if act_id == CombinedActId.Accumulative then
		return TabIndex.combinedserv_accumulative
	elseif act_id == CombinedActId.Gongcheng then
		return TabIndex.combinedserv_gongcheng
	elseif act_id == CombinedActId.YB_Party then
		return TabIndex.combinedserv_ybparty
	elseif act_id == CombinedActId.CB_Party then 
		return TabIndex.combinedserv_cbparty
	elseif act_id == CombinedActId.BS_Party then 
		return TabIndex.combinedserv_bsparty
	elseif act_id == CombinedActId.ZH_Party then
		return TabIndex.combinedserv_zhparty
    elseif act_id == CombinedActId.LH_Party then
		return TabIndex.combinedserv_lhparty
	elseif act_id == CombinedActId.Fashion then
		return TabIndex.combinedserv_fashion
	elseif act_id == CombinedActId.DZP then
		return TabIndex.combinedserv_turntable
	end
	return 0
end

function CombinedServerActData.GetActIdByIndex(index)
	if index == TabIndex.combinedserv_accumulative then
		return CombinedActId.Accumulative
	elseif index == TabIndex.combinedserv_gongcheng then
		return CombinedActId.Gongcheng 
	elseif index == TabIndex.combinedserv_ybparty then
		return CombinedActId.YB_Party
	elseif index == TabIndex.combinedserv_cbparty then 
		return CombinedActId.CB_Party
	elseif index == TabIndex.combinedserv_bsparty then 
		return CombinedActId.BS_Party
	elseif index == TabIndex.combinedserv_zhparty then
		return CombinedActId.ZH_Party
	elseif index == TabIndex.combinedserv_lhparty then
		return CombinedActId.LH_Party
	elseif index == TabIndex.combinedserv_fashion then
		return CombinedActId.Fashion
	elseif index == TabIndex.combinedserv_turntable then
		return CombinedActId.DZP

	end
	return 0
end

function CombinedServerActData:SetCombinedServData(protocol)
	self.act_info[protocol.act_id].act_id = protocol.act_id
	self.act_info[protocol.act_id].begin_time = protocol.begin_time
	self.act_info[protocol.act_id].end_time = protocol.end_time
    if self.act_info[protocol.act_id].act_id == CombinedActId.Accumulative then
        self.act_info[protocol.act_id].recharge_amount = protocol.recharge_amount
        self.act_info[protocol.act_id].accumul_state = protocol.accumul_state
	elseif self.act_info[protocol.act_id].act_id == CombinedActId.Gongcheng then
		self.act_info[protocol.act_id].act_state = protocol.act_state
	elseif self.act_info[protocol.act_id].act_id == CombinedActId.Fashion then
		self.act_info[protocol.act_id].reward_count = protocol.reward_count
		self.act_info[protocol.act_id].xb_count = protocol.xb_count
	elseif self.act_info[protocol.act_id].act_id == CombinedActId.DZP then
		self.act_info[protocol.act_id].is_open = protocol.is_open
		self.act_info[protocol.act_id].ylq_count = protocol.ylq_count
		self.act_info[protocol.act_id].ylq_gold = protocol.ylq_gold
		self.act_info[protocol.act_id].cqq_count = protocol.cqq_count
		self.act_info[protocol.act_id].cqq_gold = protocol.cqq_gold
	end
end

function CombinedServerActData:SetCombinedAccumulData(protocol)
    self.act_info[CombinedActId.Accumulative].recharge_amount = protocol.amount
end

function CombinedServerActData:GetActInfo(act_id)
	return self.act_info[act_id]
end

function CombinedServerActData:ClearDZPRewardLog()
	self.dzp_reward_log = {}
end


function CombinedServerActData:SetDZPRewardLog(log)
	self.dzp_reward_log = log
end

function CombinedServerActData:AddDZPRewardLog(info)
	local vo = {}
	vo.type = info.type
	vo.item_id = info.item_id
	vo.num = info.num
	vo.name = info.name
	table.insert(self.dzp_reward_log, 1, vo)
end

function CombinedServerActData:GetDZPRewardLog()
	return self.dzp_reward_log
end

function CombinedServerActData:GetAccumulInfo()
	local reverse_receive_state_list = bit:d2b(self.act_info[CombinedActId.Accumulative].accumul_state)
	local receive_state_list = {}
	for i = 1, #reverse_receive_state_list do
		receive_state_list[i] = table.remove(reverse_receive_state_list)
	end

	local cfg = CombinedServerActData.GetCombinedServActCfg(CombinedActId.Accumulative)

    local accumul_info = {}
    accumul_info.item_list = {}
    accumul_info.charge_money= self.act_info[CombinedActId.Accumulative].recharge_amount
	for k, v in pairs(cfg.gradeAwards) do
		accumul_info.item_list[k] = {}
		accumul_info.item_list[k].index = k
		accumul_info.item_list[k].need_money = v.limitYb
		if accumul_info.charge_money >=  v.limitYb then
			accumul_info.item_list[k].btn_state = 1
		else
			accumul_info.item_list[k].btn_state = 0
		end
		accumul_info.item_list[k].btn_state = accumul_info.item_list[k].btn_state + receive_state_list[k]
		accumul_info.item_list[k].award_list = {}
		for k1, v1 in pairs(v.awards) do
			if role_sex == v1.sex or nil == v1.sex then
				table.insert(accumul_info.item_list[k].award_list, ItemData.FormatItemData(v1))
			end
		end
	end
--    local combind_days = OtherData.Instance:GetCombindDays() -- 已经开服多少天
--	local end_day = cfg.activityDays
--	accumul_info.left_day = end_day - combind_days
    return accumul_info
end

function CombinedServerActData:SortList(item_list)
	local temp_list = {}
	local index = 1
	for k, v in pairs(item_list) do
		if 1 == v.btn_state then
			temp_list[index] = v
			index = index + 1
		end
	end
	for k, v in pairs(item_list) do
		if 0 == v.btn_state then
			temp_list[index] = v
			index = index + 1
		end
	end
	for k, v in pairs(item_list) do
		if 2 == v.btn_state then
			temp_list[index] = v
			index = index + 1
		end
	end
	return temp_list
end
function CombinedServerActData:GetAwardListRemindNum(tabbar_index)
	local remind_num = 0
	if nil ~= self.info_list[tabbar_index] then
		for k, v in pairs(self.info_list[tabbar_index].item_list) do
			if 1 == v.btn_state then
				remind_num = remind_num + 1
			end
		end
	end
	return remind_num
end
function CombinedServerActData:GetCombinedIndexIsOpen(index)
	local act_id = CombinedServerActData.GetActIdByIndex(index)
	return self:GetCombinedActIsOpen(act_id)
end

function CombinedServerActData:GetCombinedActIsOpen(act_id)
	if nil == self.act_info[act_id] then return false end
	local now_time = TimeCtrl.Instance:GetServerTime()
	return now_time >= self.act_info[act_id].begin_time and  now_time < self.act_info[act_id].end_time
end

function CombinedServerActData:GetRemindNum(remind_name)
	local num = 0
	if remind_name == RemindName.CombinedServGCZReward then
		if self.act_info[CombinedActId.Gongcheng] and self.act_info[CombinedActId.Gongcheng].act_state == 1
		and self:GetCombinedActIsOpen(CombinedActId.Gongcheng) then
			num = num + 1
		end
	elseif remind_name == RemindName.CombinedServFashionReward then
		if self:GetCombinedActIsOpen(CombinedActId.Fashion) then
			if self.act_info[CombinedActId.Fashion] and 0 < self.act_info[CombinedActId.Fashion].reward_count then
				num = num + 1
			end
		end
	elseif remind_name == RemindName.CombinedServDZPCount then
		local cfg = CombinedServerActData.GetCombinedServActCfg(CombinedActId.DZP)
		if cfg and self.act_info[CombinedActId.DZP] 
			and self.act_info[CombinedActId.DZP].ylq_count >= cfg.maxYlBook 
			and self.act_info[CombinedActId.DZP].cqq_count >= cfg.maxCqBook 
			and self:GetCombinedActIsOpen(CombinedActId.DZP) then
			num = num + 1
		end
    elseif remind_name == RemindName.CombinedServLJCZReward then
		if self.act_info[CombinedActId.Accumulative] and self:GetCombinedActIsOpen(CombinedActId.Accumulative) then
            local item_list = self:GetAccumulInfo()
            for k, v in pairs(item_list.item_list) do
	            if 1 == v.btn_state then
				    num = num + 1
			    end
            end
		end
    end
	return num
end