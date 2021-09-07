require("game/world_question/world_question_data")
require("game/world_question/world_question_view")
local ANSWER_TIME_LIMIT = 5  --上线时剩余5s答题则不打开界面
WorldQuestionCtrl = WorldQuestionCtrl or BaseClass(BaseController)
function WorldQuestionCtrl:__init()
	if WorldQuestionCtrl.Instance then
		print_error("[WorldQuestionCtrl] Attemp to create a singleton twice !")
	end
	WorldQuestionCtrl.Instance = self
	self.data = WorldQuestionData.New()
	self.view = WorldQuestionView.New(ViewName.WorldQuestionView)
	self:RegisterAllProtocols()
	self.time_quest = {}
	self.timers = {}
end

function WorldQuestionCtrl:__delete()
	WorldQuestionCtrl.Instance = nil
	self.data:DeleteMe()
	self.view:DeleteMe()
	for k,v in pairs(WORLD_GUILD_QUESTION_NAME_TYPE) do
		self:CancelQuest(v)
	end
end

function WorldQuestionCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCQuestionBroadcast, "OnSCQuestionBroadcast")       		--返回答题内容
	self:RegisterProtocol(SCQuestionAnswerResult, "OnSCQuestionAnswerResult") 		--返回玩家回答结果
	self:RegisterProtocol(SCQuestionGuildRankInfo, "OnSCQuestionGuildRankInfo")  	--返回答题排名
	self:RegisterProtocol(SCQuestionRightAnswerNum, "OnSCQuestionRightAnswerNum") 	--返回答题数量
end

--玩家答题请求
function WorldQuestionCtrl.SendQuestionAnswerReq(answer_type, choose)
	local protocol = ProtocolPool.Instance:GetProtocol(CSQuestionAnswerReq)
	protocol.answer_type = answer_type --回答类型 2世界 3公会
	protocol.choose = choose           --选择答案(从0起)
	protocol:EncodeAndSend()
end

--答题内容
function WorldQuestionCtrl:OnSCQuestionBroadcast(protocol)
	--结束事件剩余大于5秒
	if protocol.cur_question_end_time - TimeCtrl.Instance:GetServerTime() < ANSWER_TIME_LIMIT then
		return
	end

	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local question_cfg = self.data:GetWGQuestionCfg(protocol.question_type)
	if not role_vo or not question_cfg then return end
	if role_vo.level < question_cfg.open_level then
		return
	end

	local name_type = ""
	if protocol.question_type == WORLD_GUILD_QUESTION_TYPE.WORLD then
		name_type = WORLD_GUILD_QUESTION_NAME_TYPE.WORLD
		--清空和保存世界答题数据
		self.data:ClearWorldList()
		self.data:SetSelectQuestion(0, WORLD_GUILD_QUESTION_TYPE.WORLD)
		self.data:OnSCQuestionBroadcast(protocol)

		--刷新界面
		if self.view:IsOpen() then
			self.view:Flush()
		else
			self.view:SetType(WORLD_GUILD_QUESTION_TYPE.WORLD, name_type)
			ViewManager.Instance:Open(ViewName.WorldQuestionView)
		end
	elseif protocol.question_type == WORLD_GUILD_QUESTION_TYPE.GUILD then
		name_type = WORLD_GUILD_QUESTION_NAME_TYPE.GUILD
		--清空和保存公会答题数据
		self.data:ClearGuildList()
		self.data:SetSelectQuestion(0, WORLD_GUILD_QUESTION_TYPE.GUILD)
		self.data:OnSCQuestionBroadcast(protocol)

		--刷新界面
		--ChatCtrl.Instance:FlushGuildChatView("guild_answer")
		if self.view:IsOpen() then
			self.view:Flush()
		else
			self.view:SetType(WORLD_GUILD_QUESTION_TYPE.GUILD, name_type)
			ViewManager.Instance:Open(ViewName.WorldQuestionView)
		end
	end

	local is_auto_answer = self.data:GetCanAutoAnswer()
	if not is_auto_answer then return end

	--自动答题
	local time = protocol.cur_question_end_time - TimeCtrl.Instance:GetServerTime()
	self:CalAutoAnswer(name_type, time)
end

--玩家回答结果
function WorldQuestionCtrl:OnSCQuestionAnswerResult(protocol)
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local question_cfg = self.data:GetWGQuestionCfg(protocol.answer_type)
	if not role_vo or not question_cfg then return end
	if role_vo.level < question_cfg.open_level then
		return
	end

	self.data:OnSCQuestionAnswerResult(protocol)
	local answer_list = {}
	local channel_type = nil
	if protocol.answer_type == WORLD_GUILD_QUESTION_TYPE.WORLD then
		--频道类型
		channel_type = CHANNEL_TYPE.WORLD
		answer_list = self.data:GetWorldAnswerList()

		--刷新界面
		if self.view:IsOpen() then
			self.view:Flush()
		else
			self.data:ClearWorldList()
		end

		--取消自动答题倒计时
		self:CancelQuest(WORLD_GUILD_QUESTION_NAME_TYPE.WORLD)
	elseif protocol.answer_type == WORLD_GUILD_QUESTION_TYPE.GUILD then
		--频道类型
		channel_type = CHANNEL_TYPE.GUILD
		answer_list = self.data:GetGuildAnswerList()

		--刷新界面
		--ChatCtrl.Instance:FlushGuildChatView("guild_qustion_result")
		if self.view:IsOpen() then
			self.view:Flush()
		else
			self.data:ClearGuildList()
		end

		--取消自动答题倒计时
		self:CancelQuest(WORLD_GUILD_QUESTION_NAME_TYPE.GUILD)
	end

	if next(answer_list) then
		local index = self.data:GetSelectQuestion(protocol.answer_type)
		local content = answer_list.question_list[index]
		--发送内容到频道(世界, 公会)
		--if channel_type == CHANNEL_TYPE.GUILD then
			ChatCtrl.SendChannelChat(channel_type, content..NO_FILTER_LIST.QUESTION_ANSWER, CHAT_CONTENT_TYPE.TEXT, SHOW_CHAT_TYPE.ANSWER)
		--end
	end
end

--返回答题排名
function WorldQuestionCtrl:OnSCQuestionGuildRankInfo(protocol)
	self.data:SetGuildQuestionRank(protocol.rank_list)
	ChatCtrl.Instance:FlushGuildChatView("guild_question_rank")
end

--返回答题数量
function WorldQuestionCtrl:OnSCQuestionRightAnswerNum(protocol)
	self.data:SetMyQustionNum(protocol)
	ChatCtrl.Instance:FlushGuildChatView("guild_question_rank")
end

--vip3以上玩家如果没有答题, 则在最后5秒自动答题
function WorldQuestionCtrl:CalAutoAnswer(question_type, time)
	if self.time_quest[question_type] then
	   GlobalTimerQuest:CancelQuest(self.time_quest[question_type])
	   self.time_quest[question_type] = nil
	end
	self.timers[question_type] = time
	self.time_quest[question_type] = GlobalTimerQuest:AddRunQuest(function()
		self.timers[question_type] = self.timers[question_type] - UnityEngine.Time.deltaTime
		--少于5s时自动答题
		if self.timers[question_type] <= ANSWER_TIME_LIMIT then
			local result_list = {}
			local send_question_type = -1
			local random_value = -1
			if question_type == WORLD_GUILD_QUESTION_NAME_TYPE.WORLD then
				result_list = self.data:GetWorldResultList()
				send_question_type = WORLD_GUILD_QUESTION_TYPE.WORLD
				random_value = math.random(0, 3)
			elseif question_type == WORLD_GUILD_QUESTION_NAME_TYPE.GUILD then
				result_list = self.data:GetGuildResultList()
				send_question_type = WORLD_GUILD_QUESTION_TYPE.GUILD
				random_value = math.random(0, 1)
			end

			--还没答题结果
			if not next(result_list) and send_question_type ~= -1 then
				--保存自动答题选择的答案
				self.data:SetSelectQuestion(random_value + 1, send_question_type)
				WorldQuestionCtrl.SendQuestionAnswerReq(send_question_type, random_value)
			end

			--暂停主界面群聊颤抖(公会)
			if question_type == WORLD_GUILD_QUESTION_NAME_TYPE.GUILD then
				MainUICtrl.Instance:FlushView("GuildShake",{[1] = false})
			end

			--关闭
			self:CancelQuest(question_type)
		end
	end, 0)
end

function WorldQuestionCtrl:CancelQuest(question_type)
	if self.time_quest[question_type] then
	   GlobalTimerQuest:CancelQuest(self.time_quest[question_type])
	   self.time_quest[question_type] = nil
	end
end
