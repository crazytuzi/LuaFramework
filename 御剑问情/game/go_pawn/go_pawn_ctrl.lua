require("game/go_pawn/go_pawn_data")
require("game/go_pawn/go_pawn_view")
GoPawnCtrl = GoPawnCtrl or BaseClass(BaseController)

function GoPawnCtrl:__init()
	if GoPawnCtrl.Instance then
		print_error("[GoPawnCtrl] Attemp to create a singleton twice !")
	end
	GoPawnCtrl.Instance = self
	self.data = GoPawnData.New()
	self.view = GoPawnView.New(ViewName.GoPawnView)
	self:RegisterAllProtocols()
end

function GoPawnCtrl:__delete()
	self.view:DeleteMe()
	self.data:DeleteMe()
	GoPawnCtrl.Instance = nil
end

function GoPawnCtrl:GetView()
	return self.view
end

function GoPawnCtrl:GetData()
	return self.data
end

function GoPawnCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCMoveChessInfo, "OnMoveChessInfo")
	self:RegisterProtocol(SCMoveChessStepRewardInfo, "OnSCMoveChessStepRewardInfo")
	self:RegisterProtocol(SCMoveChessShakePoint, "OnMoveChessShakePoint")
end

--返回走棋子信息
function GoPawnCtrl:OnMoveChessInfo(protocol)
	self.data:OnMoveChessInfo(protocol)
	local go_pawn_view = GoPawnContentView.Instance

	if go_pawn_view ~= nil then
		if go_pawn_view:GetInitState() then
			go_pawn_view:InitCrapsPos(protocol.move_chess_cur_step)
		end
		go_pawn_view:CheckBtnState()
		go_pawn_view:FlushRemainText(protocol.move_chess_free_times)
		go_pawn_view:FlushRedPoint()
	end
	RemindManager.Instance:Fire(RemindName.HuanJing_XunBao)
end

-- 返回摇骰得到的物品
function GoPawnCtrl:OnSCMoveChessStepRewardInfo(protocol)
 	self.data:SetStepReward(protocol)
end
 
--摇骰子摇到点数
function GoPawnCtrl:OnMoveChessShakePoint(protocol)
	self.data:OnSaveShakePoint(protocol)
	local go_pawn_view = GoPawnContentView.Instance
	if go_pawn_view ~= nil then
		if protocol.shake_point ~= 0 then
            --转动骰子
			go_pawn_view:CalTurnCrapsTime()
			
		end
 	end
end


--请求重置骰子
function GoPawnCtrl:SendMoveChessResetReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMoveChessResetReq)
	send_protocol:EncodeAndSend()
end

--请求获取走棋子信息
function GoPawnCtrl:SendMoveChessFreeInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMoveChessFreeInfo)
	-- send_protocol.is_reqinfo = is_reqinfo  --传1就返回0，否则返回服务器记录的数据
	send_protocol:EncodeAndSend()
end

--请求摇骰子
function GoPawnCtrl:SendMoveChessShakeReq(is_use_item, reserve)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMoveChessShakeReq)
	send_protocol.is_use_item = is_use_item    --1使用物品，0不使用
	send_protocol.reserve = reserve
	send_protocol:EncodeAndSend()

end

--请求摇骰点数
-- function GoPawnCtrl:SendGetPointReq()
-- 	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetPointReq)
-- 	send_protocol:EncodeAndSend()
-- end

