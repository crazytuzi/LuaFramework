HotStringChatData = HotStringChatData or BaseClass()

function HotStringChatData:__init()
	if HotStringChatData.Instance then
		print_error("[HotStringChatData]:Attempt to create singleton twice!")
	end
	HotStringChatData.Instance = self
	self.rank_list = {}
	self.add_exp_total = 0				--累计获取的经验值
	self.partner_id = 0						--双休伴侣id
	self.partner_server_id = 0				--双休伴侣渠道id

	self.frist_role_id = 0
	self.frist_role_vo = {}

	self.server_id = 0
	self.target_id = 0

	self.main_uuid = 0					--自己跨服中的唯一id

	self.is_repair = false

	self.other_cfg = ConfigManager.Instance:GetAutoConfig("hotspring_auto").other or {}
	self.present_list =ListToMap( ConfigManager.Instance:GetAutoConfig("hotspring_auto").present_list, "present_id")
	self.piting_list = {}
	self.question_info = {
		curr_question_begin_time = 0,
		curr_question_end_time = 0,
		next_question_start_time = 0,
		broadcast_question_total = 0,
		curr_question_id = 0,
		is_exchange = 0,
		curr_question_str = "",
		curr_answer0_desc_str = "",
		curr_answer1_desc_str = "",
	}
	self.answer_info = {
		question_right_count = 0,
		question_wrong_count = 0,
		curr_score = 0,
		total_exp = 0,
	}
	self.rank_info = {
		self_score = 0,
		self_rank = 0,
		is_finish = 0,
		reserve_1 = 0,
		reserve_2 = 0,
		rank_count = 0,
		rank_list = {},
	}
	self.partner_obj_id = 65535
	self.question_start_time = 0
end

function HotStringChatData:__delete()
	HotStringChatData.Instance = nil
end

function HotStringChatData:SetRankList(list)
	self.rank_list = list
	-- table.sort(self.rank_list.rank_list, HotStringChatData.SortRankList)
end

function HotStringChatData:GetRankList()
	return self.rank_list
end

function HotStringChatData.SortRankList(a, b)
	if a.popularity >= b.popularity then
		return true
	end
	return false
end

function HotStringChatData:ChangeRankListByPop(popularity)
	if next(self.rank_list) then
		self.rank_list.popularity = popularity
		-- for k, v in ipairs(self.rank_list.rank_list) do
		-- 	local rank = self.rank_list.v
		-- 	if rank == k then
		-- 		v.popularity = popularity
		-- 	end
		-- end
		-- table.sort(self.rank_list.rank_list, HotStringChatData.SortRankList)
	end
end

function HotStringChatData:SetPlayerInfo(info)
	self.partner_id = info.partner_id
	self.partner_server_id = info.server_id
	self:ChangeRankListByPop(info.popularity)
	self:SetFreePresentTimes(info.give_free_times)
	self:SetMainUUid(info.uuid)
	self.answer_info.question_right_count = info.question_right_count
	self.answer_info.question_wrong_count = info.question_wrong_count
	self.answer_info.curr_score = info.curr_score
	self.answer_info.total_exp = info.total_exp
end

function HotStringChatData:SetMainUUid(uuid)
	self.main_uuid = uuid
end

function HotStringChatData:GetMainUUid()
	return self.main_uuid or 0
end

function HotStringChatData:SetJingYan(info)
	self.add_exp_total = info.add_exp_total
	self.add_addition = info.add_addition
end

function HotStringChatData:GetJingYan()
	return math.abs(self.add_exp_total)
end

function HotStringChatData:GetPresentList()
	return self.present_list
end

function HotStringChatData:GetMyRank()
	return self.rank_list.rank or 0
end

function HotStringChatData:SetFreePresentTimes(give_free_times)
	local free_give_present_times = self.other_cfg[1].free_give_present_times or 5
	self.free_present_time = free_give_present_times - give_free_times
end

function HotStringChatData:GetFreePresentTimes()
	return self.free_present_time or 0
end

function HotStringChatData:GetPresentPriceById(id)
	-- for k, v in pairs(self.present_list) do
	-- 	if v.present_id == id then
	-- 		return v.present_price
	-- 	end
	-- end
	-- return 0

	return self.present_list[id] or nil
end

function HotStringChatData:SetIsRoleId(value)
	self.is_role_id = value
end

function HotStringChatData:GetIsRoleId()
	return self.is_role_id
end

function HotStringChatData:SetRecGiftId(server_id, id)
	self.server_id = server_id
	self.target_id = id
end

function HotStringChatData:GetRecGiftId()
	return self.server_id, self.target_id
end

function HotStringChatData:SetFristRoleId(id)
	self.frist_role_id = id
end

function HotStringChatData:GetFristRoleId()
	return self.frist_role_id
end

function HotStringChatData:SetFristRoleVo(info)
	self.frist_role_vo = info
end

function HotStringChatData:ClearFristRoleVo()
	self.frist_role_vo = {}
end

function HotStringChatData:GetFristRoleVo()
	return self.frist_role_vo
end

-- 主角是否正在双修
function HotStringChatData:GetRepairState()
	if self.partner_obj_id >= 0 and self.partner_obj_id < 65535 then
		return true
	else
		return false
	end
end

function HotStringChatData:SetpartnerId(protocol)
	self.partner_id = protocol.partner_id
	self.partner_server_id = protocol.server_id
	self.partner_obj_id = protocol.partner_obj_id
end

function HotStringChatData:ClearpartnerId()
	self.partner_id = 65535
	self.partner_server_id = 0
	self.partner_obj_id = 65535
end

function HotStringChatData:GetpartnerObjId()
	return self.partner_obj_id
end

function HotStringChatData:IsFreeGift(id)
	local gift_other = self.other_cfg[1] or {}
	local free_present_id = gift_other.free_present_id or 0
	if free_present_id == id then
		return true
	end

	return false
end

function HotStringChatData.IsHotSpringScene(scene_id)
	return scene_id == 1110
end

-----------------------------------------------答题------------------------------------------------

function HotStringChatData:SetQuestionInfo(info)
	for k,v in pairs(info) do
		self.question_info[k] = v
	end
end

function HotStringChatData:GetQuestionInfo()
	return self.question_info
end

-- 得到角色答题信息
function HotStringChatData:GetRoleAnswerInfo()
	return self.answer_info
end

function HotStringChatData:GetQuestionConfig()
	if not self.question_config then
		self.question_config = ConfigManager.Instance:GetAutoConfig("question_auto")
	end
	return self.question_config
end

-- 得到题目总数
function HotStringChatData:GetTotalQuestionCount()
	local total_question_count = 0
	local cfg = self:GetQuestionConfig()
	if cfg then
		local other_cfg = cfg.other[1]
		if other_cfg then
			total_question_count = other_cfg.total_question_count
		end
	end
	return total_question_count
end

-- 得到答题准备时间
function HotStringChatData:GetQuestionPrepareTime()
	local answer_prepare_time = 0
	local cfg = self:GetQuestionConfig()
	if cfg then
		local other_cfg = cfg.other[1]
		if other_cfg then
			answer_prepare_time = other_cfg.answer_prepare_time
		end
	end
	return answer_prepare_time
end

function HotStringChatData:SetRankInfo(info)
	if info then
		for k,v in pairs(info) do
			self.rank_info[k] = v
		end
	end
end

function HotStringChatData:GetRankInfo()
	return self.rank_info
end

function HotStringChatData:SetQuestionStartTime(start_time)
	self.question_start_time = start_time
end

function HotStringChatData:GetActivityPrepareTime()
	return self.question_start_time - TimeCtrl.Instance:GetServerTime()
end