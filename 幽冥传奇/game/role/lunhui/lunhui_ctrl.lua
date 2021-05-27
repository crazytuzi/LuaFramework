require("scripts/game/role/lunhui/lunhui_data")

LunHuiCtrl = LunHuiCtrl or BaseClass(BaseController)

function LunHuiCtrl:__init()
	if	LunHuiCtrl.Instance then
		ErrorLog("[LunHuiCtrl]:Attempt to create singleton twice!")
	end
	LunHuiCtrl.Instance = self

	self.data = LunHuiData.New()
	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
end

function LunHuiCtrl:__delete()
	LunHuiCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function LunHuiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCLunHui, "OnLunHui")
end

function LunHuiCtrl:OnRecvMainRoleInfo()
	-- 请求轮回数据
	GlobalTimerQuest:AddDelayTimer(function() 
    		if GameCondMgr.Instance:GetValue("CondId18") then
    			LunHuiCtrl.SendLunHuiReq(3)
    		end
		end, 5)
end

function LunHuiCtrl.SendLunHuiReq(opt_type, equip_index, btn_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSLunHuiReq)
	protocol.opt_type = opt_type or 3
	protocol.equip_index = equip_index or 0
	protocol.btn_index = btn_index or 0
	protocol:EncodeAndSend()
end

function LunHuiCtrl:OnLunHui(protocol)
	if 0 == protocol.protocol_result then
		if protocol.type <= 3 then
			self.data:SetAllData(protocol)
		elseif protocol.type == 4 or protocol.type == 5 then
		end
	end
end
