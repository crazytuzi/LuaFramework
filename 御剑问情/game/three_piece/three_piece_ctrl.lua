require("game/three_piece/three_piece_view")
require("game/three_piece/three_piece_data")

ThreePieceCtrl = ThreePieceCtrl or BaseClass(BaseController)
function ThreePieceCtrl:__init()
	if ThreePieceCtrl.Instance then
		print_error("[ThreePieceCtrl] Attemp to create a singleton twice !")
	end
	ThreePieceCtrl.Instance = self

	self.three_piece_data = ThreePieceData.New()
	self.three_piece_view = ThreePieceView.New(ViewName.ThreePiece)

	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
end

function ThreePieceCtrl:__delete()
	ThreePieceCtrl.Instance = nil

	if self.three_piece_view then
		self.three_piece_view:DeleteMe()
		self.three_piece_view = nil
	end

	if self.three_piece_data then
		self.three_piece_data:DeleteMe()
		self.three_piece_data = nil
	end

	if self.main_view_complete then
    	GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end
end

function ThreePieceCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRATotalCharge4Info, "OnRATotalCharge4Info")
end

function ThreePieceCtrl:OnRATotalCharge4Info(protocol)
	self.three_piece_data:SetChargeInfo(protocol)
	self.three_piece_view:Flush()
end

function ThreePieceCtrl.SendRATotalCharge4Info()
	local protocol = ProtocolPool.Instance:GetProtocol(CSRATotalCharge4Info)
	protocol:EncodeAndSend()
end

function ThreePieceCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_NEW_THREE_SUIT)
	if is_open then
		-- 请求活动信息
	 	ThreePieceCtrl.SendRATotalCharge4Info()
	end
end