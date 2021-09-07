require("game/kill_tips/kill_tips_data")
require("game/kill_tips/kill_tips_view")

KillTipCtrl = KillTipCtrl or  BaseClass(BaseController)

function KillTipCtrl:__init()
	if KillTipCtrl.Instance ~= nil then
		print_error("[KillTipCtrl] attempt to create singleton twice!")
		return
	end
	KillTipCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = KillTipData.New()
	self.kill_tips = KillTipView.New()

	self.show_timer_quest = nil
end

function KillTipCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.kill_tips then
		self.kill_tips:DeleteMe()
		self.kill_tips = nil
	end

	KillTipCtrl.Instance = nil
	self:ClearTimer()
end

function KillTipCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCKillRoleCountInfo, "OnKillRoleCountInfo")
	self:RegisterProtocol(SCKillRoleChuanwen, "OnKillRoleChuanwen")
end

function KillTipCtrl:OnKillRoleCountInfo(protocol)
	self.data:SetKillRoleCount(protocol)
	self.kill_tips:Open()

	if self.kill_tips:IsOpen() then
		self:Flush("flush_kill_role_count_info")
	end

	local totle_time = 300 --ElementBattleCtrl.Instance:GetData():GetQunxianOtherCfg().time
	self:ClearTimer()
	self.show_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnCloseKillTip,self), totle_time)
end

function KillTipCtrl:OnKillRoleChuanwen(protocol)
	self.data:SetKillRoleChuanwen(protocol)
	self.kill_tips:Open()

	if self.kill_tips:IsOpen() then
		self:Flush("flush_kill_role_chuanwen_info")
	end
end

function KillTipCtrl:OnCloseKillTip()
	self.kill_tips:Close()
end

function KillTipCtrl:ClearTimer()
	if self.show_timer_quest then
		GlobalTimerQuest:CancelQuest(self.show_timer_quest)
		self.show_timer_quest = nil
	end
end

-- Ë¢ÐÂÊý¾Ý
function KillTipCtrl:Flush(key, value_t)
	if self.kill_tips then
		self.kill_tips:Flush(key, value_t)
	end
end
