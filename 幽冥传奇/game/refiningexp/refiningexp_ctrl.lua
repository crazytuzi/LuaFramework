require("scripts/game/refiningexp/refiningexp_data")
require("scripts/game/refiningexp/refiningexp_view")
require("scripts/game/refiningexp/refiningexp_tip")

-- 经验炼制
RefiningExpCtrl = RefiningExpCtrl or BaseClass(BaseController)

function RefiningExpCtrl:__init()
	if	RefiningExpCtrl.Instance then
		ErrorLog("[RefiningExpCtrl]:Attempt to create singleton twice!")
	end
	RefiningExpCtrl.Instance = self

	self.data = RefiningExpData.New()
	self.view = RefiningExpView.New(ViewDef.RefiningExp)
	self.exp_tip = RefiningExpTip.New(ViewDef.RefiningTip)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRefineExpRemindNum, self), RemindName.RefiningExp)
	self:RegisterAllProtocols()

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.SendRefiningExpReq, self, 1))
end

function RefiningExpCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	RefiningExpCtrl.Instance = nil
end

function RefiningExpCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGetRefiningExpMsg, "OnGetRefiningExpMsg")
end

function RefiningExpCtrl:GetRefineExpRemindNum(remind_name)
	if remind_name == RemindName.RefiningExp then
		return 1
	end
end

-- 请求经验炼制(1获取炼制信息, 2确定炼制)
function RefiningExpCtrl:SendRefiningExpReq(index)
	if index == 1 then
		RemindManager.Instance:DoRemind(RemindName.RefiningExp)
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSRefiningExpReq)
	protocol.index = index
	protocol:EncodeAndSend()
end

-- 经验炼制次数下发
function RefiningExpCtrl:OnGetRefiningExpMsg(protocol)
	self.data:SetRefiningExpMsg(protocol)
end