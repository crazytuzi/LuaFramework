
TimeBossController = TimeBossController or class("TimeBossController",BaseController)
local TimeBossController = TimeBossController

function TimeBossController:ctor()
	TimeBossController.Instance = self
	self.model = TimeBossModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function TimeBossController:dctor()
end

function TimeBossController:GetInstance()
	if not TimeBossController.Instance then
		TimeBossController.new()
	end
	return TimeBossController.Instance
end

function TimeBossController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1608_timeboss_pb"
    self:RegisterProtocal(proto.TIMEBOSS_CARE, self.HandleCare)
    self:RegisterProtocal(proto.TIMEBOSS_LIST, self.HandleBossList)
    self:RegisterProtocal(proto.TIMEBOSS_RANKING, self.HandleRanking)
    self:RegisterProtocal(proto.TIMEBOSS_DICE, self.HandleDice)
    self:RegisterProtocal(proto.TIMEBOSS_DICING, self.HandleDicing)
    self:RegisterProtocal(proto.TIMEBOSS_BOXINFO, self.HanleBoxInfo)
    self:RegisterProtocal(proto.TIMEBOSS_BOXOPEN, self.HanleBoxOpen)
    self:RegisterProtocal(proto.TIMEBOSS_DROPPED, self.HandleDropped)
    self:RegisterProtocal(proto.TIMEBOSS_REMIND, self.HandleRemind)
end

function TimeBossController:AddEvents()
	
	local function call_back()
		self:RequestBoxInfo()
	end
	GlobalEvent:AddListener(TimeBossEvent.OpenBoxPanel, call_back)

	local function call_back(is_open, activity_id, stime)
		local now_time = os.time()
		if is_open and (activity_id == 11101 or activity_id == 11102 or activity_id == 20000 ) 
			and now_time - stime <= 300 then
			lua_panelMgr:GetPanelOrCreate(TimeBossEnterPanel):Open()
		end
	end
	GlobalEvent:AddListener(ActivityEvent.ChangeActivity, call_back)

	local function call_back(data)
		if not data.can_open then
			return Notify.ShowText("You don't have the access to open infinite chest.")
		end
		lua_panelMgr:GetPanelOrCreate(TimeBossOpenBoxPanel):Open(data)
	end
	self.model:AddListener(TimeBossEvent.UpdateBoxInfo, call_back)

	local function call_back(data, boss_id, count)
		local panel = lua_panelMgr:GetPanel(TimeBossRewardPanel)
		if not panel then
			lua_panelMgr:GetPanelOrCreate(TimeBossRewardPanel):Open(data, boss_id, count)
		end
	end
	self.model:AddListener(TimeBossEvent.UpdateBoxRewards, call_back)
end

-- overwrite
function TimeBossController:GameStart()
	
end

----请求基本信息
function TimeBossController:RequestCare(bossid, op, bosstype)
	local pb = self:GetPbObject("m_timeboss_care_tos")
	pb.id = bossid
	pb.op = op
	pb.type = bosstype
	self:WriteMsg(proto.TIMEBOSS_CARE, pb)
end

----服务的返回信息
function TimeBossController:HandleCare()
	local data = self:ReadMsg("m_timeboss_care_toc")

	self.model:SetCare(data)
	self.model:Brocast(TimeBossEvent.BossCare, data.op)
end

function TimeBossController:RequestBossList()
	local pb = self:GetPbObject("m_timeboss_list_tos")

	self:WriteMsg(proto.TIMEBOSS_LIST, pb)
end

function TimeBossController:HandleBossList()
	local data = self:ReadMsg("m_timeboss_list_toc")

	self.model:SetBosses(data.bosses)
	self.model:Brocast(TimeBossEvent.BossList)
end

function TimeBossController:RequestRanking()
	local pb = self:GetPbObject("m_timeboss_ranking_tos")

	self:WriteMsg(proto.TIMEBOSS_RANKING, pb)
end

function TimeBossController:HandleRanking()
	local data = self:ReadMsg("m_timeboss_ranking_toc")

	self.model:Brocast(TimeBossEvent.UpdateRanking, data)
end

function TimeBossController:HandleDice()
	local data = self:ReadMsg("m_timeboss_dice_toc")

	self.model.dice_etime = data.etime
	self.model:Brocast(TimeBossEvent.DiceNotice, data.etime)
end

function TimeBossController:RequestDicing()
	local pb = self:GetPbObject("m_timeboss_dicing_tos")

	self:WriteMsg(proto.TIMEBOSS_DICING, pb)
end

function TimeBossController:HandleDicing()
	local data = self:ReadMsg("m_timeboss_dicing_toc")

	if data.score > 0 then
		self.model.my_score = data.score
	end
	if data.highest > 0 then
		self.model.highest = data.highest
		self.model.owner = data.owner
	end
	self.model:Brocast(TimeBossEvent.DiceResult, data)
end

function TimeBossController:RequestBoxInfo()
	local pb = self:GetPbObject("m_timeboss_boxinfo_tos")

	self:WriteMsg(proto.TIMEBOSS_BOXINFO, pb)
end

function TimeBossController:HanleBoxInfo()
	local data = self:ReadMsg("m_timeboss_boxinfo_toc")

	self.model:Brocast(TimeBossEvent.UpdateBoxInfo, data)
end

function TimeBossController:RequestBoxOpen(type_id, count, boss_id)
	local pb = self:GetPbObject("m_timeboss_boxopen_tos")
	pb.type = type_id
	pb.boss = boss_id
	pb.times = count or 0
	self.model.open_boss_id = boss_id
	self.model.open_count = count or 0
	self:WriteMsg(proto.TIMEBOSS_BOXOPEN, pb)
end

function TimeBossController:HanleBoxOpen()
	local data = self:ReadMsg("m_timeboss_boxopen_toc")

	self.model:Brocast(TimeBossEvent.UpdateBoxRewards, data, self.model.open_boss_id, self.model.open_count)
end

--请求掉落日志
function TimeBossController:RequestDropped()
	local pb = self:GetPbObject("m_timeboss_dropped_tos")

	self:WriteMsg(proto.TIMEBOSS_DROPPED, pb)
end

function TimeBossController:HandleDropped()
	local data = self:ReadMsg("m_timeboss_dropped_toc")

	self.model:SetDropped(data.logs)
	self.model:Brocast(TimeBossEvent.UpdateDropped)
end

function TimeBossController:HandleRemind()
	local data = self:ReadMsg("m_timeboss_remind_toc")
	if not OpenTipModel:IsOpenSystem(160, 14) then
        return
    end
    local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	local can_enter = true
	if main_role_data then
		local max_rank_count = String2Table(Config.db_game["timeboss_rank_times"].val)[1]
		local max_join_count = String2Table(Config.db_game["timeboss_join_times"].val)[1]
	    local buffer1 = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_TIMEBOSS_JOIN_TIRED)
	    local buffer2 = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_TIMEBOSS_RANK_TIRED)
	    local use_count1 = (buffer1 and buffer1.value or 0)
	    local use_count2 = (buffer2 and buffer2.value or 0)
	    if use_count1 >= max_join_count and use_count2 >= max_rank_count then
	       return
	    end
	end
	if self.dbri then
        self.dbri:destroy()
    end
    local sceneid = SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneid] or {}
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_CITY or config.type == enum.SCENE_TYPE.SCENE_TYPE_FIELD then
        self.dbri = DungeonBottomRightItem(LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.Top), data.id);
    end
end

