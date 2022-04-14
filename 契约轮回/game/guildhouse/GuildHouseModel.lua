GuildHouseModel = GuildHouseModel or class("GuildHouseModel",BaseModel)
local GuildHouseModel = GuildHouseModel

function GuildHouseModel:ctor()
	GuildHouseModel.Instance = self
	self:Reset()
	self.rank_id = 1010
	self.card_id1 = 11150
	self.card_id2 = 11151
	self.card_id3 = 11152
	self.activity_id = 10211
end

function GuildHouseModel:Reset()
	self.score = 0
	self.question = nil
	self.is_opened_panel = false
	self.messages = {}
end

function GuildHouseModel.GetInstance()
	if GuildHouseModel.Instance == nil then
		GuildHouseModel()
	end
	return GuildHouseModel.Instance
end

function GuildHouseModel:SetScore(score)
	self.score = score
end

function GuildHouseModel:SetQuestion(question)
	self.question = question
end


local index_letter = {
		[1] = "A",
		[2] = "B",
		[3] = "C",
		[4] = "D",
	}
function GuildHouseModel:AnswerIndexToLetter(index)
	return index_letter[index]
end

local letter_index = {
		A = 1,
		B = 2,
		C = 3,
		D = 4,
	}
function GuildHouseModel:LetterToIndex(letter)
	return letter_index[letter]
end

function GuildHouseModel:AddMessage(chat_msg)
	if #self.messages < 20 then
		table.insert(self.messages, chat_msg)
	else
		table.remove(self.messages, 1)
		self.messages[#self.messages+1] = chat_msg
	end
end

--是否在答题准备时间内
function GuildHouseModel:IsInQuestionPre()
	local activity = ActivityModel:GetInstance():GetActivity(self.activity_id)
	local now = os.time()
	if activity and now >= activity.stime and now < activity.stime + 60 then
		return true
	end
	return false
end

--是否在答题时间内
function GuildHouseModel:IsInQuestion()
	local activity = ActivityModel:GetInstance():GetActivity(self.activity_id)
	local now = os.time()
	if activity and now >= activity.stime and now < activity.stime + 560 then
		return true
	end
	return false
end

--是否可以召唤boss
function GuildHouseModel:CanCallBoss()
	local activity = ActivityModel:GetInstance():GetActivity(self.activity_id)
	local now = os.time()
	if activity and now >= activity.stime + 600 and now <= activity.etime then
		return true
	end
	return false
end

function GuildHouseModel:GetRankReward(rank)
	for i=1, #Config.db_guild_question_reward do
		local item = Config.db_guild_question_reward[i]
		if rank>=item.rank_min and rank<=item.rank_max then
			return item.gain
		end
	end
end

--获取boss阶数
function GuildHouseModel:GetBossOrder(worldlv)
	for i=1, #Config.db_guild_house_boss do
		local item = Config.db_guild_house_boss[i]
		if worldlv >= item.world_level_min and worldlv <= item.world_level_max then
			return item.order
		end
	end
end

--获取boss评级
function GuildHouseModel:GetBossScore(start_time)
	local use_time = os.time() - start_time
	use_time = (use_time < 0 and 0 or use_time)
	for k, v in pairs(Config.db_guild_house_kill) do
		if use_time >= v.time_min and use_time <= v.time_max then
			return v.point, v.time_max
		end
	end
	return false
end

--是否有红点
function GuildHouseModel:IsShowRed()
	local activity = ActivityModel:GetInstance():GetActivity(self.activity_id)
	if not activity then
		return  false
	end
	return true
	--local now = os.time()
	--if activity and now >= activity.stime and now < activity.etime then
		--return true
	--end
	--return false
end
