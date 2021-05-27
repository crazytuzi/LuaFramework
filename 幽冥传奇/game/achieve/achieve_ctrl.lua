require("scripts/game/achieve/achieve_data")
require("scripts/game/achieve/achieve_view")
require("scripts/game/achieve/achieve_medal_view")

AchieveCtrl = AchieveCtrl or BaseClass(BaseController)

function AchieveCtrl:__init()
	if AchieveCtrl.Instance then
		ErrorLog("[AchieveCtrl] attempt to create singleton twice!")
		return
	end
	AchieveCtrl.Instance = self

	self.data = AchieveData.New()
	self.view = AchieveView.New(ViewName.Achieve)

	self:RegisterAllProtocols()
	self.role_data_change_back = BindTool.Bind1(self.RoleDataChangeCallback,self)	
	RoleData.Instance:NotifyAttrChange(BindTool.Bind1(self.role_data_change_back, self))
end

function AchieveCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	if self.role_data_change_back then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_change_back)
		self.role_data_change_back = nil 
	end

	AchieveCtrl.Instance = nil
end

function AchieveCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCAchieveInfo,"OnAchieveInfo")
	self:RegisterProtocol(SCFinishOneAchieve,"OnFinishOneAchieve")
	self:RegisterProtocol(SCAchieveFinishEventTrigger,"OnAchieveFinishEventTrigger")
	self:RegisterProtocol(SCAchieveRewardResult,"OnAchieveRewardResult")
	self:RegisterProtocol(SCAchieveBadgeList,"OnAchieveBadgeList")
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.AchieveChuangQi)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.AchieveLoading)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.AchieveGrowUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.AchieveXYCM)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.AchieveCopter)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.AchieveStrengthen)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.AchieveWing)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.AchieveJade)
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.AchieveGem)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindAchievementSign, self), RemindName.AchieveAchievement, true, 1)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindAchieveSign, self), RemindName.AchieveMedal, true, 1)
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.SendAchieveInfoReq))
end

--下发成就数据
function AchieveCtrl:OnAchieveInfo(protocol)
	self.data:SetAchieveData(protocol)
	self.view:Flush(TabIndex.achieve_achievement)
	KnightCtrl.Instance:SendKnightInfoReq(0)
end

--完成了一个成就
function AchieveCtrl:OnFinishOneAchieve(protocol)
	self.data:SetSuccessData(protocol)
	self.view:Flush(TabIndex.achieve_achievement)
	KnightCtrl.Instance:SendKnightInfoReq(0)
end

--成就一个事件触发
function AchieveCtrl:OnAchieveFinishEventTrigger(protocol)
	self.data:SetTouchEvent(protocol)
	self.view:Flush(TabIndex.achieve_achievement)
end

--成就领取奖励的结果
function AchieveCtrl:OnAchieveRewardResult(protocol)
	if protocol.result == 0 then return end
	self.data:SetRewardResultData(protocol)
	self.view:Flush(TabIndex.achieve_achievement)
	KnightCtrl.Instance:SendKnightInfoReq(0)
end

--下发勋章列表
function AchieveCtrl:OnAchieveBadgeList(protocol)
	self.data:SetBadgeListData(protocol)
	self.view:Flush(TabIndex.achieve_medal)
end

--请求成就数据
function AchieveCtrl:SendAchieveInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSAchieveInfoReq)
	protocol:EncodeAndSend()
end

--请求成就奖励数据
function AchieveCtrl:SendAchieveRewardReq(achieve_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSAchieveRewardReq)
	protocol.achieve_id = achieve_id
	protocol:EncodeAndSend()
end

--获取徽章的数据
function AchieveCtrl:SendAchieveBadgeInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSAchieveBadgeInfoReq)
	protocol:EncodeAndSend()
end

function AchieveCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.AchieveChuangQi then
		return self.data:GetChangQiData()
	elseif remind_name == RemindName.AchieveLoading then
		return self.data:GetLoadingData()
	elseif remind_name == RemindName.AchieveGrowUp then
		return self.data:GetGrowUpData()
	elseif remind_name == RemindName.AchieveXYCM then
		return self.data:GetXYCMData()
	elseif remind_name == RemindName.AchieveCopter then
		return self.data:GetCopterData()
	elseif remind_name == RemindName.AchieveWing then
		return self.data:GetWingData()
	elseif remind_name == RemindName.AchieveStrengthen then
		return self.data:GetStrenthenData()
	end
end

function AchieveCtrl:GetRemindAchievementSign(remind_name)
	if remind_name == RemindName.AchieveAchievement then
		return self.data:GetAchievementData()
	end
end

function AchieveCtrl:GetRemindAchieveSign(remind_name)
	if remind_name == RemindName.AchieveMedal then
		return self.data:GetMedalData()
	end
end

function AchieveCtrl:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.CREATURE_LEVEL then
		RemindManager.Instance:DoRemind(RemindName.AchieveMedal)
	elseif key == OBJ_ATTR.ACTOR_ACHIEVE_VALUE then
		RemindManager.Instance:DoRemind(RemindName.AchieveMedal)
		RemindManager.Instance:DoRemind(RemindName.AchieveChuangQi)
		RemindManager.Instance:DoRemind(RemindName.AchieveLoading)
		RemindManager.Instance:DoRemind(RemindName.AchieveGrowUp)
		RemindManager.Instance:DoRemind(RemindName.AchieveXYCM)
		RemindManager.Instance:DoRemind(RemindName.AchieveCopter)
		RemindManager.Instance:DoRemind(RemindName.AchieveStrengthen)
		RemindManager.Instance:DoRemind(RemindName.AchieveJade)
		RemindManager.Instance:DoRemind(RemindName.AchieveGem)
		RemindManager.Instance:DoRemind(RemindName.AchieveWing)
		RemindManager.Instance:DoRemind(RemindName.AchieveAchievement)	
	end
end