require("game/kuafu_chongzhirank/kuafu_chongzhirank_view")
require("game/kuafu_chongzhirank/kuafu_chongzhirank_data")

KuaFuChongZhiRankCtrl = KuaFuChongZhiRankCtrl or BaseClass(BaseController)

function KuaFuChongZhiRankCtrl:__init()
	if KuaFuChongZhiRankCtrl.Instance ~= nil then
		print_error("[KuaFuChongZhiRankCtrl] attempt to create singleton twice!")
		return
	end
	KuaFuChongZhiRankCtrl.Instance=self
	self.data = KuaFuChongZhiRankData.New()
	self.view = KuaFuChongZhiRankView.New(ViewName.KuaFuChongZhiRank)
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
	self:RegisterAllProtocols()
end


function KuaFuChongZhiRankCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.main_view_complete then
    	GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end

	KuaFuChongZhiRankCtrl.Instance = nil
end
-- 协议注册
function KuaFuChongZhiRankCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSCrossRandActivityRequest)
	self:RegisterProtocol(CSCrossRAChongzhiRankGetRank)

	self:RegisterProtocol(SCCrossRAChongzhiRankChongzhiInfo, "OnSCCrossRAChongzhiRankChongzhiInfo")
	self:RegisterProtocol(SCCrossRAChongzhiRankGetRankACK, "OnSCCrossRAChongzhiRankGetRankACK")
end

function KuaFuChongZhiRankCtrl:OnSCCrossRAChongzhiRankGetRankACK(protocol)
	self.data:SetCrossRAChongzhiRankGetRankACK(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KuaFuChongZhiRankCtrl:OnSCCrossRAChongzhiRankChongzhiInfo(protocol)
	self.data:SetChongZhiInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KuaFuChongZhiRankCtrl.SendTianXiangOperate(activity_type,operate_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossRandActivityRequest)
	send_protocol.activity_type = activity_type or 0
    send_protocol.opera_type = operate_type or 0
    send_protocol.param_1 = param_1 or 0
    send_protocol.param_2 = param_2 or 0
    send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end


function KuaFuChongZhiRankCtrl.SendTianXiangOperate2()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossRAChongzhiRankGetRank)
	send_protocol:EncodeAndSend()
end

function KuaFuChongZhiRankCtrl:MianUIOpenComlete()
	KuaFuChongZhiRankCtrl.SendTianXiangOperate(ACTIVITY_TYPE.KF_KUAFUCHONGZHI, 0)
	KuaFuChongZhiRankCtrl.SendTianXiangOperate2()
end
