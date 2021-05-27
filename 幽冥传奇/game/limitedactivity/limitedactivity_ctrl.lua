require("scripts/game/limitedactivity/limitedactivity_data")
require("scripts/game/limitedactivity/limitedactivity_view")

LimitedActivityCtrl = LimitedActivityCtrl or BaseClass(BaseController)

function LimitedActivityCtrl:__init()
	if LimitedActivityCtrl.Instance then
		ErrorLog("[LimitedActivityCtrl]:Attempt to create singleton twice!")
	end
	LimitedActivityCtrl.Instance = self

	self.data = LimitedActivityData.New()
	self.view = LimitedActivityView.New(ViewName.LimitedActivity)
	self:RegisterAllProtocals()
	self.close_acts = {}
end

function LimitedActivityCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil
	self.close_acts = {}
	LimitedActivityCtrl.Instance = nil
end

function LimitedActivityCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCGetRewardShujuReq, "OnGetRewardShujuReq")
	self:RegisterProtocol(SCGetConsumeShujuReq, "OnGetConsumeShujuReq")
	self:RegisterProtocol(SCTimeLimitedGoodsDataIss, "OnTimeLimitedGoodsDataIss")

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnLimitedActivity, self))
end


function LimitedActivityCtrl:OnLimitedActivity()
	self:TimeLimitedGoodsDataReq()
	self:SendChongzhjiReq()
	self:SendXiaofeiReq()
end

function LimitedActivityCtrl:CloseAct()
	ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
end

function LimitedActivityCtrl:GetCloseActs()
	return self.close_acts
end
----------------------------下发---------------------------
--累计充值数据
function LimitedActivityCtrl:OnGetRewardShujuReq(protocol)
	-- print("充值奖励数据")
	self.data:SetLimitRewardData(protocol)
	self.view:Flush(TabIndex.limitedactivity_cz)
	GlobalEventSystem:Fire(OtherEventType.TIME_LIMITED_HEAP_RECHARGE_CHANGE)
end

--累计消费数据
function LimitedActivityCtrl:OnGetConsumeShujuReq(protocol)
	-- print("消费奖励数据")
	self.data:SetLimitConsumeData(protocol)
	self.view:Flush(TabIndex.limitedactivity_xf)
	GlobalEventSystem:Fire(OtherEventType.TIME_LIMITED_HEAP_CONSUME_CHANGE)
end

function LimitedActivityCtrl:OnTimeLimitedGoodsDataIss(protocol)
	-- print("限时商品")
	self.data:SetTimeLimitedGoodsData(protocol)
	GlobalEventSystem:Fire(OtherEventType.TIME_LIMITED_GOODS_DATA_CHANGE)
end



--------------------------请求----------------------------

function LimitedActivityCtrl:SendChongzhjiReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetRewardReq)
	protocol:EncodeAndSend()
end

function LimitedActivityCtrl:SendCzGetGiftReq(pos)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetRewardGiftReq)
	protocol.place = pos
	protocol:EncodeAndSend()
end

function LimitedActivityCtrl:SendXiaofeiReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetConsumeReq)
	protocol:EncodeAndSend()
end

function LimitedActivityCtrl:SendXfGetGiftReq(pose)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetConsumeGiftReq)
	protocol.place = pose
	protocol:EncodeAndSend()
end

--请求限时商品数据
function LimitedActivityCtrl:TimeLimitedGoodsDataReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTimeLimitedGoodsDataReq)
	protocol:EncodeAndSend()
end

