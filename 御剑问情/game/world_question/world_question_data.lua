WorldQuestionData = WorldQuestionData or BaseClass()

--服务端定义的类型
WORLD_GUILD_QUESTION_TYPE =
{
	WORLD = 2, 			 --世界
	GUILD = 3,  		 --公会
}

WORLD_GUILD_QUESTION_NAME_TYPE =
{
	WORLD = "world", 	 --世界
	GUILD = "guild",  	 --公会
}

local REWRARD_FLOWER_COUNTS =
{
	999,
	520,
	99,
	9
}
function WorldQuestionData:__init()
	if WorldQuestionData.Instance then
		print_error("[WorldQuestionData] Attemp to create a singleton twice !")
	end
	WorldQuestionData.Instance = self
	self.answer_list = {}
	self.answer_list.guild = {}
	self.answer_list.world = {}
	self.result_list = {}
	self.result_list.guild = {}
	self.result_list.world = {}
	self.world_right_answer_num = 0
	self.guild_right_answer_num = 0
	self.other_cfg = ConfigManager.Instance:GetAutoConfig("question_auto").other[1]
end

function WorldQuestionData:__delete()
	WorldQuestionData.Instance = nil
end

function WorldQuestionData:ClearWorldList()
	self.answer_list[WORLD_GUILD_QUESTION_NAME_TYPE.WORLD] = {}
	self.result_list[WORLD_GUILD_QUESTION_NAME_TYPE.WORLD] = {}
end

function WorldQuestionData:ClearGuildList()
	self.answer_list[WORLD_GUILD_QUESTION_NAME_TYPE.GUILD] = {}
	self.result_list[WORLD_GUILD_QUESTION_NAME_TYPE.GUILD] = {}
end

--答题内容
function WorldQuestionData:OnSCQuestionBroadcast(protocol)
	local name_type = ""
	if protocol.question_type == WORLD_GUILD_QUESTION_TYPE.WORLD then
		name_type = WORLD_GUILD_QUESTION_NAME_TYPE.WORLD
	elseif protocol.question_type == WORLD_GUILD_QUESTION_TYPE.GUILD then
		name_type = WORLD_GUILD_QUESTION_NAME_TYPE.GUILD
	end
	self.answer_list[name_type] = {}
	self.answer_list[name_type].question_type = protocol.question_type   						--题目类型 2 世界 3公会
	self.answer_list[name_type].cur_question_id = protocol.cur_question_id 						--当前问题id
	self.answer_list[name_type].question = protocol.cur_question_str  							--当前题目字符串
	self.answer_list[name_type].question_list = {}
	for i=1,4 do
		self.answer_list[name_type].question_list[i] = protocol["cur_answer_desc_"..i] 			--当前答案字符串
	end
	self.answer_list[name_type].cur_question_begin_time = protocol.cur_question_begin_time 		--本题开始时间
	self.answer_list[name_type].cur_question_end_time = protocol.cur_question_end_time  		--本题结束时间
	self.answer_list[name_type].next_question_begin_time = protocol.next_question_begin_time   	--下一题开始时间
end

--玩家回答结果
function WorldQuestionData:OnSCQuestionAnswerResult(protocol)
	local name_type = ""
	if protocol.answer_type == WORLD_GUILD_QUESTION_TYPE.WORLD then
		name_type = WORLD_GUILD_QUESTION_NAME_TYPE.WORLD
	elseif protocol.answer_type == WORLD_GUILD_QUESTION_TYPE.GUILD then
		name_type = WORLD_GUILD_QUESTION_NAME_TYPE.GUILD
	end
	self.result_list[name_type] = {}
	self.result_list[name_type].answer_type = protocol.answer_type 								--结果类型 2世界， 3公会
	self.result_list[name_type].result = protocol.result     									--1 回答正确，0 回答错误
	self.result_list[name_type].right_result = protocol.right_result 							--正确答案
end

function WorldQuestionData:SetGuildQuestionRank(rank_list)
	function sortfun(a, b)
		return a.right_answer_num > b.right_answer_num
	end
	table.sort(rank_list, sortfun)
	self.guild_rank_list = rank_list
end

function WorldQuestionData:GetGuildQuestionRank()
	return self.guild_rank_list
end

--答对数量
function WorldQuestionData:SetMyQustionNum(protocol)
	self.world_right_answer_num = protocol.world_right_answer_num
	self.guild_right_answer_num = protocol.guild_right_answer_num
end

function WorldQuestionData:GetMyQustionNum(question_type)
	if question_type == WORLD_GUILD_QUESTION_TYPE.WORLD then
		return self.world_right_answer_num
	elseif question_type == WORLD_GUILD_QUESTION_TYPE.GUILD then
		return self.guild_right_answer_num
	end
end

function WorldQuestionData:GetWorldAnswerList()
	return self.answer_list[WORLD_GUILD_QUESTION_NAME_TYPE.WORLD]
end

function WorldQuestionData:GetGuildAnswerList()
	return self.answer_list[WORLD_GUILD_QUESTION_NAME_TYPE.GUILD]
end

function WorldQuestionData:GetWorldResultList()
	return self.result_list[WORLD_GUILD_QUESTION_NAME_TYPE.WORLD]
end

function WorldQuestionData:GetGuildResultList()
	return self.result_list[WORLD_GUILD_QUESTION_NAME_TYPE.GUILD]
end

--从1起
function WorldQuestionData:SetSelectQuestion(question_index, question_type)
	if question_type == WORLD_GUILD_QUESTION_TYPE.WORLD then
		self.cur_world_question_index = question_index
	elseif question_type == WORLD_GUILD_QUESTION_TYPE.GUILD then
		self.cur_guild_question_index = question_index
	end
end

function WorldQuestionData:GetSelectQuestion(question_type)
	if question_type == WORLD_GUILD_QUESTION_TYPE.WORLD then
		return self.cur_world_question_index
	elseif question_type == WORLD_GUILD_QUESTION_TYPE.GUILD then
		return self.cur_guild_question_index
	end
end

--获取我的公会答题排名
function WorldQuestionData:GetMyRank()
	local rank = -1
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	for k,v in pairs(self.guild_rank_list) do
		if v.uid == role_id then
			return k
		end
	end
	return -1
end

--获得自动答题的最小vip
function WorldQuestionData:GetAutoAnswerVip()
	return self.other_cfg.auto_answer
end

function WorldQuestionData:GetCanAutoAnswer()
	local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	return my_vip >= self:GetAutoAnswerVip()
end

function WorldQuestionData:GetGuildAnswerRewardList()
	if self.reward_list_cfg == nil then
		self.reward_list_cfg = {}
		local cfg = ConfigManager.Instance:GetAutoConfig("question_auto").g_rank_reward
		local no_in_rank_reward_cfg = ConfigManager.Instance:GetAutoConfig("question_auto").other[1].guild_rank_other_reward[0]
		for k,v in ipairs(cfg) do
			local data = {}
			data.item_id = no_in_rank_reward_cfg.item_id
			data.num = REWRARD_FLOWER_COUNTS[k]
			data.is_bind = v.rank_reward[0].is_bind
			self.reward_list_cfg[k] = data
		end

		--不上榜奖励
		local data = {}
		data.item_id = no_in_rank_reward_cfg.item_id
		data.num = no_in_rank_reward_cfg.num
		data.is_bind = no_in_rank_reward_cfg.is_bind
		self.reward_list_cfg[#self.reward_list_cfg + 1] = data
	end
	return self.reward_list_cfg
end

function WorldQuestionData:GetMyReward(rank)
	if rank > 4 or rank == -1 then rank = 4 end
	return self:GetGuildAnswerRewardList()[rank]
end