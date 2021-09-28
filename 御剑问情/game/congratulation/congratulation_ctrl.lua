require("game/congratulation/congratulation_view")
require("game/congratulation/congratulation_data")
require("game/congratulation/tips_congratulation_view")
CongratulationCtrl = CongratulationCtrl or BaseClass(BaseController)

function CongratulationCtrl:__init()
	if nil ~= CongratulationCtrl.Instance then
		print_error("[CongratulationCtrl] Attemp to create a singleton twice !")
		return
	end
	CongratulationCtrl.Instance = self
	self.congratulation_view = CongratulationView.New(ViewName.CongratulationView)
	self.congratulation_data = CongratulationData.New()
	self.tips_congratulation_view = TipsCongratulationView.New(ViewName.TipsCongratulationView)
	self:RegisterAllProtocols()
	self.friend_congratulation_list = {}
	self.closen_time = 0
	self.tip_closetime = 0
	self.show_tips = true
end

function CongratulationCtrl:__delete()
	self.congratulation_data:DeleteMe()
	self.congratulation_view:DeleteMe()
	self.tips_congratulation_view:DeleteMe()
	self.friend_congratulation_list = {}
	
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.closen_time = 0

	if self.tip_time_quest then
		GlobalTimerQuest:CancelQuest(self.tip_time_quest)
		self.tip_time_quest = nil
	end

	CongratulationCtrl.Instance = nil
end

function CongratulationCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFriendHeliNotice, "OnSCFriendHeliNotice")
	self:RegisterProtocol(SCFriendHeliSend,"OnSCCongratulateInfo")
	self:RegisterProtocol(CSFriendHeliSendReq)
end

--接受好友升级/打怪信息
function CongratulationCtrl:OnSCFriendHeliNotice(protocol)
	if not self.show_tips then
		return
	end
	local  cell = {heli_type = protocol.heli_type, uid = protocol.uid, param1 = protocol.param1, param2 = protocol.param2}
	self.congratulation_data:PushTipCongratulation(cell)
	if self.congratulation_data:GetIsAuto() then
		local send_gift = self.congratulation_data:GetAutoType()
		local role_id = protocol.uid
		self:SendReq(role_id, send_gift)
		return
	else
		self:ShowCongratulation()
	end
end

--接受礼物
function CongratulationCtrl:OnSCCongratulateInfo(protocol)
	self.congratulation_data:PushCongratulation({uid = protocol.uid, _type = protocol.type})
	local name = ScoietyData.Instance:GetFriendNameById(protocol.uid)
	local experience = CongratulationData.Instance:GetExperience()
	if protocol.type == CONGRATULATION_TYPE.EGG then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Congratulation.Info1, name, experience))
	elseif protocol.type == CONGRATULATION_TYPE.FLOWER then 
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Congratulation.Info2, name, experience))
	end
	-- if self.congratulation_view:IsOpen() then
	-- 	self.congratulation_view:Flush()
	-- 	return
	-- end
	
	local friend_congratulation_list = self.congratulation_data:GetTempList()		
	if #friend_congratulation_list >= 3 and self.congratulation_data:GetCanShowHe() then
		MainUICtrl.Instance.view:Flush("congratulate_btn", {true})
	end	
end

--发送礼物	
function CongratulationCtrl:SendReq(role_id,send_gift)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFriendHeliSendReq)	
	send_protocol.uid = role_id or 0
	send_protocol.type = send_gift or 0
	send_protocol:EncodeAndSend()
end

function CongratulationCtrl:SetTipShow()
	self.show_tips = false
		self.tip_time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.tip_closetime = self.tip_closetime + UnityEngine.Time.deltaTime
		if self.tip_closetime > 30 then
			self.tip_closetime = 0
			self.show_tips = true
			GlobalTimerQuest:CancelQuest(self.tip_time_quest)
			self.tip_closetime = 0
			self.tip_time_quest = nil
		end
	end, 0)
end

function CongratulationCtrl:SetClosenTime()
	self.congratulation_data:SetCanShowHe(false)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.closen_time = self.closen_time + UnityEngine.Time.deltaTime
		if self.closen_time > 20 then
			self.congratulation_data:SetCanShowHe(true)
			self.closen_time = 0
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end, 0)
end

function CongratulationCtrl:ShowCongratulation()
	if self.tips_congratulation_view:IsOpen() then
		self.tips_congratulation_view:Flush()
	else
		ViewManager.Instance:Open(ViewName.TipsCongratulationView)
	end
end