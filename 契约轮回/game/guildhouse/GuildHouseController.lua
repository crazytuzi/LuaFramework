require('game.guildhouse.RequireGuildHouse')
GuildHouseController = GuildHouseController or class("GuildHouseController",BaseController)
local GuildHouseController = GuildHouseController

function GuildHouseController:ctor()
	GuildHouseController.Instance = self
	self.model = GuildHouseModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function GuildHouseController:dctor()
end

function GuildHouseController:GetInstance()
	if not GuildHouseController.Instance then
		GuildHouseController.new()
	end
	return GuildHouseController.Instance
end

function GuildHouseController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1403_guild_house_pb"
    self:RegisterProtocal(proto.GUILD_HOUSE_QUESTION, self.HandleQuestion)
    self:RegisterProtocal(proto.GUILD_HOUSE_ANSWER, self.HandleAnswer)
    self:RegisterProtocal(proto.GUILD_HOUSE_CALLBOSS, self.HandleCallBoss)
    self:RegisterProtocal(proto.GUILD_HOUSE_EXP, self.HandleUpdateExp)
    self:RegisterProtocal(proto.GUILD_QUESTION_FIRST, self.HandleQuestionFirst)
    self:RegisterProtocal(proto.GUILD_QUESTION_RESULT, self.HandleQuestionResult)
    self:RegisterProtocal(proto.GUILD_HOUSE_SCORE, self.HandleQuestionScore)
    self:RegisterProtocal(proto.GUILD_HOUSE_CALLBOSS_BC, self.HandleCallBossBc)
    self:RegisterProtocal(proto.GUILD_HOUSE_BOSS_FINISH, self.HandleBossFinish)
end

function GuildHouseController:AddEvents()
	-- --请求基本信息
	local function call_back(data)
		if not lua_panelMgr:GetPanel(GuildQuestionPanel) then
			local num = String2Table(Config.db_game["guild_question_num"].val)[1]
			if not self.model.is_opened_panel or data.num == num or data.num == 1 then
				lua_panelMgr:GetPanelOrCreate(GuildQuestionPanel):Open(data)
			end
		end
	end
	self.model:AddListener(GuildHouseEvent.GetQuestionEvent, call_back)

	local function call_back(data)
		--self.model:SetQuestion(nil)
		lua_panelMgr:GetPanelOrCreate(GuildQuestionResultPanel):Open(data)
	end
	self.model:AddListener(GuildHouseEvent.QuestionResult, call_back)

	local function call_back(scene_id)
		local scene = Config.db_scene[scene_id]
		if scene.stype == enum.SCENE_STYPE.SCENE_STYPE_GUILDHOUSE then
			if self.model:IsInQuestion() and not self.model:IsInQuestionPre() then
				self:RequestQuestion()
			end
		else
			self.model.is_opened_panel = nil
		end
	end
	GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)

	local function call_back(chat_msg)
		if chat_msg.channel_id ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_QUESTION then
			return
		end
		self.model:AddMessage(chat_msg)
	end
	GlobalEvent:AddListener(ChatEvent.ReceiveMessage, call_back)

	--活动开启
	local function call_back(is_open, activity_id)
		if is_open and activity_id == 10211 then
			lua_panelMgr:GetPanelOrCreate(GuildHouseEnterPanel):Open()
		end
	end
	GlobalEvent:AddListener(ActivityEvent.ChangeActivity, call_back)

	local function call_back()
		lua_panelMgr:GetPanelOrCreate(GuildHouseEnterPanel):Open()
	end
	GlobalEvent:AddListener(FactionEvent.Faction_PreGuildHouseEvent, call_back)
end

-- overwrite
function GuildHouseController:GameStart()
	
end

----请求基本信息
function GuildHouseController:RequestQuestion()
	local pb = self:GetPbObject("m_guild_house_question_tos")
	self:WriteMsg(proto.GUILD_HOUSE_QUESTION,pb)
end

----服务的返回信息
function GuildHouseController:HandleQuestion(  )
	local data = self:ReadMsg("m_guild_house_question_toc")
	--self.model:SetQuestion(data)
	self.model:Brocast(GuildHouseEvent.GetQuestionEvent, data)
end

--答题
function GuildHouseController:RequestAnswer(index)
	local pb = self:GetPbObject("m_guild_house_answer_tos")
	pb.answer = index
	self:WriteMsg(proto.GUILD_HOUSE_ANSWER,pb)
end

function GuildHouseController:HandleAnswer()
	local data = self:ReadMsg("m_guild_house_answer_toc")

	if data.is_right then
		Notify.ShowText(string.format("Answer right, gain %s pts", data.score - self.model.score))
	end
	self.model:SetScore(data.score)
	self.model:Brocast(GuildHouseEvent.AnswerEvent, data)
end

function GuildHouseController:RequestQuestionScore()
	local pb = self:GetPbObject("m_guild_house_score_tos")
	self:WriteMsg(proto.GUILD_HOUSE_SCORE,pb)
end

----服务的返回信息
function GuildHouseController:HandleQuestionScore(  )
	local data = self:ReadMsg("m_guild_house_score_toc")
	
	self.model:SetScore(data.score)
	self.model:Brocast(GuildHouseEvent.UpdateQuestionScoreEvent, data)
end

--召唤boss
function GuildHouseController:RequestCallBoss(item_id)
	local pb = self:GetPbObject("m_guild_house_callboss_tos")
	pb.id = item_id
	self:WriteMsg(proto.GUILD_HOUSE_CALLBOSS,pb)
end

function GuildHouseController:HandleCallBoss()
	local data = self:ReadMsg("m_guild_house_callboss_toc")

	Notify.ShowText("Summoned Boss")
end

function GuildHouseController:RequestBossTime()
	local pb = self:GetPbObject("m_guild_house_boss_time_tos")
	self:WriteMsg(proto.GUILD_HOUSE_BOSS_TIME,pb)
end

function GuildHouseController:HandleCallBossBc()
	local data = self:ReadMsg("m_guild_house_callboss_bc_toc")

	self.model:Brocast(GuildHouseEvent.BossStart, data.start_time)
end

function GuildHouseController:HandleBossFinish()
	local data = self:ReadMsg("m_guild_house_boss_finish_toc")

	self.model:Brocast(GuildHouseEvent.BossFinish)
end


function GuildHouseController:HandleUpdateExp( )
	local data = self:ReadMsg("m_guild_house_exp_toc")

	self.model:Brocast(GuildHouseEvent.UpdateExpEvent, data.exp)
end

--第一个答对玩家
function GuildHouseController:HandleQuestionFirst()
	local data = self:ReadMsg("m_guild_question_first_toc")

	self.model:Brocast(GuildHouseEvent.QuestionFirstEvent, data.name)
end

--结算
function GuildHouseController:HandleQuestionResult()
	local data = self:ReadMsg("m_guild_question_result_toc")

	self.model:Brocast(GuildHouseEvent.QuestionResult, data)
end
