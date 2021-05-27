require("scripts/game/active_degree/active_degree_data")
require("scripts/game/active_degree/active_degree_view")
require("scripts/game/active_degree/active_degree_desc_tips")

-- 活跃度
ActiveDegreeCtrl = ActiveDegreeCtrl or BaseClass(BaseController)

function ActiveDegreeCtrl:__init()
	if ActiveDegreeCtrl.Instance then
		ErrorLog("[ActiveDegreeCtrl]:Attempt to create singleton twice!")
	end
	ActiveDegreeCtrl.Instance = self

	self.view = ActiveDegreeView.New(ViewName.ActiveDegree)
	self.data = ActiveDegreeData.New()

	self:RegisterAllProtocals()
	-- self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	-- RoleData.Instance:NotifyAttrChange(self.role_data_event)
end

function ActiveDegreeCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil

	if self.reward_tip ~= nil then
		self.reward_tip:DeleteMe()
		self.reward_tip = nil 
	end

	ActiveDegreeCtrl.Instance = nil
end

function ActiveDegreeCtrl:RoleDataChangeCallback(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_ACTOR_SIGNIN then
	end
end

function ActiveDegreeCtrl:RegisterAllProtocals()
-- 	self:RegisterProtocol(SCVitalityAcitivityInfromation, "OnVitalityAcitivityInfromation")
-- 	-- GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.SendActivenessActivityReq, self, 1))
-- 	-- GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.SendActivenessActivityReq, self, 3))
-- 	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.RecvMainInfoCallBack, self))
-- 	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.ActivenessActivityReq, self, 0))

-- 	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ActiveDegree, true, 3)
end


function ActiveDegreeCtrl:CloseMyView()
	if self.view == nil then return end
	self.view:Close()
end


function ActiveDegreeCtrl:CloseTip()
	if self.reward_tip then
		if self.reward_tip:IsOpen() then
			self.reward_tip:Close()
		end
	end
end

function ActiveDegreeCtrl:RecvMainInfoCallBack()
	self:ActivenessActivityReq(0)
end
-----------------------------------
-- 协议
-----------------------------------
-- 请求 活跃度活动(1获取每日活跃度活动信息, 2领取活跃度活动奖励, 3获取行会活跃度(行会界面要显示))
-- function ActiveDegreeCtrl:SendActivenessActivityReq(activeness_type, activeness_grade)
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSActivenessActivityReq)
-- 	protocol.activeness_type = activeness_type
-- 	protocol.activeness_grade = activeness_grade
-- 	protocol:EncodeAndSend()
-- end

function ActiveDegreeCtrl:OnVitalityAcitivityInfromation(protocol)
	self.data:SetVitalityAcitivityInfromation(protocol)
	self.view:Flush()
	RemindManager.Instance:DoRemind(RemindName.ActiveDegree)
end

-- function ActiveDegreeCtrl:TransportToNpc(npc_id)
-- 	local id = self.data:GetNpcQuicklyTransportId(npc_id)
-- 	if nil == id then return end
-- 	Scene.SendQuicklyTransportReq(id)
-- end

function ActiveDegreeCtrl:OpenShowRewardView(activedegree)
	if self.reward_tip == nil then 
		self.reward_tip = ActiveDegreeRewardTips.New()
	end
	self.reward_tip:SetData(activedegree)
	self.reward_tip:Open()
end

function ActiveDegreeCtrl:ActivenessActivityReq(type_pos)
	local protocol = ProtocolPool.Instance:GetProtocol(CSActivenessActivityReq)
	protocol.activedegreerewardpos = type_pos 
	protocol:EncodeAndSend()
end







-----------------------------------------
-- 提醒

-- 获取提醒数
function ActiveDegreeCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.ActiveDegree then
		return self.data:GetActiveIconRemindNum()
	end
end