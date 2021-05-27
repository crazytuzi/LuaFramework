require("scripts/game/out_of_print/out_of_print_data")
require("scripts/game/out_of_print/out_of_print_view")

--------------------------------------------------------
-- 绝版限购
--------------------------------------------------------

OutOfPrintCtrl = OutOfPrintCtrl or BaseClass(BaseController)

function OutOfPrintCtrl:__init()
	if	OutOfPrintCtrl.Instance then
		ErrorLog("[OutOfPrintCtrl]:Attempt to create singleton twice!")
	end
	OutOfPrintCtrl.Instance = self

	self.data = OutOfPrintData.New()
	self.view = OutOfPrintView.New(ViewDef.OutOfPrint)

	self:RegisterAllProtocols()
	-- self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end

function OutOfPrintCtrl:__delete()
	OutOfPrintCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end


end

--登记所有协议
function OutOfPrintCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCOutOfPrintInfo, "OnOutOfPrintInfo")
end

-- -- 绝版限购上线请求
-- function OutOfPrintCtrl:RecvMainInfoCallBack()
-- 	local cfg = JueBanQiangGouConfig or {}
-- 	local open_days = cfg.opendays or 1
-- 	local open_lv = cfg.openlimitLevel or 50

-- 	local open_server_day = OtherData.Instance:GetOpenServerDays() + 1
-- 	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)

-- 	if open_server_day >= open_days and role_lv >= open_lv then
-- 		OutOfPrintCtrl.SendOutOfPrintReq(1)
-- 	else
-- 		-- 等级未达到时,监听人物等级
-- 		self.lv_event_handle = RoleData.Instance:AddEventListener(OBJ_ATTR.CREATURE_LEVEL, BindTool.Bind(self.OnRoleLeveChange, self))
-- 	end
-- end

-- function OutOfPrintCtrl:OnRoleLeveChange(data)
-- 	local cfg = JueBanQiangGouConfig or {}
-- 	local open_lv = cfg.openlimitLevel or 50
-- 	if data.value >= open_lv then
-- 		OutOfPrintCtrl.SendOutOfPrintReq(1)
-- 		RoleData.Instance:RemoveEventListener(self.lv_event_handle) -- 取消监听
-- 		self.lv_event_handle = nil
-- 	end
-- end

----------接收----------

-- 接受绝版抢购信息(139, 217)
function OutOfPrintCtrl:OnOutOfPrintInfo(protocol)
	self.data:SetOutOfPrintInfo(protocol)
end

----------发送----------

-- 请求绝版抢购(139, 218)
function OutOfPrintCtrl.SendOutOfPrintReq(gear)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOutOfPrintReq)
	protocol.gear = gear
	protocol:EncodeAndSend()
end

--------------------
