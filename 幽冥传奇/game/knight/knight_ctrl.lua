require("scripts/game/knight/knight_data")
require("scripts/game/knight/knight_view")
require("scripts/game/knight/knight_receive")
require("scripts/game/knight/knight_display_view")

KnightCtrl = KnightCtrl or BaseClass(BaseController)

function KnightCtrl:__init()
	if KnightCtrl.Instance then
		ErrorLog("[KnightCtrl]:Attempt to create singleton twice!")
	end
	KnightCtrl.Instance = self
	self.view = KnightView.New(ViewName.Knight)
	self.data = KnightData.New()
	self:RegisterAllProtocols()
end

function KnightCtrl:__delete()
	
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	
    KnightCtrl.Instance = nil
    if self.knight_display_view then
    	self.knight_display_view:DeleteMe()
    	self.knight_display_view = nil
    end
end

function KnightCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCKnightAcitivityInfromation,"OnKnightInfo")
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetKnightNum, self), RemindName.KnightView)
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.SendKnightInfoReq, self))
	self.icon_open_evt = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.CheckIconOpen, self))
end

function KnightCtrl:CheckIconOpen()
	if false == self.data:OpenKnight() then
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	end
	self.data:UpdateChapterOpenState()
end


function KnightCtrl:OnKnightInfo(protocol)
	self.data:KnightProtocolInfo(protocol)
	RemindManager.Instance:DoRemind(RemindName.KnightView)
	self.view:Flush(0, "just_data")
end

function KnightCtrl:SendKnightInfoReq(chaper_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSKnightActivityReq)
	protocol.chaper_id = chaper_id or 0
	protocol:EncodeAndSend()
end

function KnightCtrl:GetKnightNum(remind_name)
	if remind_name == RemindName.KnightView then
	  return self.data:GetKnightRemindNum()
	end
end

function KnightCtrl:OpenShowWing()
	self.knight_display_view = self.knight_display_view or KnightDispalyView.New()
	self.knight_display_view:Open()
end









