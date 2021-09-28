require("game/gold_member/gold_member_data")
require("game/gold_member/gold_member_view")
require("game/gold_member/gold_member_shop")
GoldMemberCtrl = GoldMemberCtrl or BaseClass(BaseController)

function GoldMemberCtrl:__init()
	if GoldMemberCtrl.Instance then
		print_error("[GoldMemberCtrl] Attemp to create a singleton twice !")
	end
	GoldMemberCtrl.Instance = self

	self.data = GoldMemberData.New()
	self.view = GoldMemberView.New(ViewName.GoldMemberView)

	self.member_shop_view = GoldMemberShop.New(ViewName.GoldMemberShop)

	self:RegisterAllProtocols()
end

function GoldMemberCtrl:__delete()
	self.view:DeleteMe()
	self.member_shop_view:DeleteMe()
	self.member_shop_view = nil
	
	self.data:DeleteMe()
	GoldMemberCtrl.Instance = nil
end

function GoldMemberCtrl:GetView()
	return self.view
end

function GoldMemberCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGoldVipInfo, "OnSCGoldVipInfo")
end

-- 黄金会员操作请求
function GoldMemberCtrl:SendGoldVipOperaReq(opera_type, param1, param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGoldVipOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol:EncodeAndSend()
end

--黄金会员信息返回
function GoldMemberCtrl:OnSCGoldVipInfo(protocol)
	self.data:SetGuldMeMberInfo(protocol)

	if self.data:IsGetReward() then
		--已激活，天数大于可领取天数并且已领取奖励关闭界面
		self.view:Close()
	else
		self.view:Flush()
		self.member_shop_view:Flush()
	end

	ViewManager.Instance:FlushView(ViewName.Main, "flush_gold_member")

	RemindManager.Instance:Fire(RemindName.GoldMember)
end