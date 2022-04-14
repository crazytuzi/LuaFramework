TimeBossModel = TimeBossModel or class("TimeBossModel",BaseModel)
local TimeBossModel = TimeBossModel

function TimeBossModel:ctor()
	TimeBossModel.Instance = self
	self:Reset()
end

function TimeBossModel:Reset()
	self.care = {}
	self.bosses = {}
	self.dice_etime = 0
	self.logs = {}
end

function TimeBossModel.GetInstance()
	if TimeBossModel.Instance == nil then
		TimeBossModel()
	end
	return TimeBossModel.Instance
end

function TimeBossModel:SetCare(data)
	local bossid = data.id
	if self.bosses[bossid] then
		self.bosses[bossid].care = (data.op == 1)
	end
end

function TimeBossModel:SetBosses(bosses)
	for i=1, #bosses do
		local boss = bosses[i]
		self.bosses[boss.id] = boss
	end
end

function TimeBossModel:IsCare(bossid)
	return self.bosses[bossid] and self.bosses[bossid].care or false
end

function TimeBossModel:SetDropped(logs)
	self.logs = logs
end

function TimeBossModel:IsHaveRedDot()
	local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	if main_role_data then
		local buffer1 = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_TIMEBOSS_RANK_TIRED)
		local buffer2 = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_TIMEBOSS_JOIN_TIRED)
		local use_count1 = (buffer1 and buffer1.value or 0)
	    local use_count2 = (buffer2 and buffer2.value or 0)
	    local max_rank_count = String2Table(Config.db_game["timeboss_rank_times"].val)[1]
		local max_join_count = String2Table(Config.db_game["timeboss_join_times"].val)[1]
	    local left_count1 = max_rank_count-use_count1
	    left_count1 = (left_count1 < 0 and 0 or left_count1)
	    local left_count2 = max_join_count-use_count2
	    left_count2 = (left_count2 < 0 and 0 or left_count2)
	    return left_count1>0 or left_count2>0
	end
end

