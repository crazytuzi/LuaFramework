require("game/personal_goals/personal_goals_view")
require("game/personal_goals/personal_guaji_tips_view")
require("game/personal_goals/personal_goals_data")

PersonalGoalsCtrl = PersonalGoalsCtrl or BaseClass(BaseController)

function PersonalGoalsCtrl:__init()
	if PersonalGoalsCtrl.Instance then
		print_error("[PersonalGoalsCtrl] 尝试创建第二个单例模式")
		return
	end
	PersonalGoalsCtrl.Instance = self
	self:RegisterAllProtocols()

	-- self.view = PersonalGoalsView.New(ViewName.PersonalGoals)
	self.guaji_tips_view = PersonGuaTips.New(ViewName.PersonalTips)
	self.data = PersonalGoalsData.New()
end

function PersonalGoalsCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if nil ~= self.guaji_tips_view then
		self.guaji_tips_view:DeleteMe()
		self.guaji_tips_view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	PersonalGoalsCtrl.Instance = nil
end

function PersonalGoalsCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSRoleGoalOperaReq)
	self:RegisterProtocol(SCRoleGoalInfo, "OnSCRoleGoalInfo")
end

function PersonalGoalsCtrl:SendRoleGoalOperaReq(opera_type, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleGoalOperaReq)
	protocol.opera_type = opera_type or 0
	protocol.param = param or 0
	protocol:EncodeAndSend()
end

function PersonalGoalsCtrl:OnSCRoleGoalInfo(protocol)
	local old_reward_index = self.data:GetReWardIndex()
	self.data:SetRoleGoalInfo(protocol)
	PlayerCtrl.Instance:FlushMieShiSkillView()
	local max_chapter = self.data:GetMaxChapter()
	local cur_chapter = self.data:GetOldChapter()
	MainUICtrl.Instance:FlushView("change_target_state", {cur_chapter < max_chapter})
	-- CollectiveGoalsCtrl.Instance:GetView():Flush()
	RemindManager.Instance:Fire(RemindName.PersonalGoals)
	RemindManager.Instance:Fire(RemindName.CollectiveGoals)
	GlobalEventSystem:Fire(OtherEventType.PLAYER_MIESHI_SKILL_CHANGE)
end

function PersonalGoalsCtrl:SendFinishGoleReq()
	PersonalGoalsCtrl:SendRoleGoalOperaReq(PERSONAL_GOAL_OPERA_TYPE.FINISH_GOLE_REQ, 1)
end