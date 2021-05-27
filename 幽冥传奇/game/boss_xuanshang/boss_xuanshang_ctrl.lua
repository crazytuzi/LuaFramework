require("scripts/game/boss_xuanshang/boss_xuanshang_data")
require("scripts/game/boss_xuanshang/boss_xuanshang_view")

BossXuanShangCtrl = BossXuanShangCtrl or BaseClass(BaseController)

function BossXuanShangCtrl:__init()
	if BossXuanShangCtrl.Instance then
		ErrorLog("[BossXuanShangCtrl]:Attempt to create singleton twice!")
	end
	BossXuanShangCtrl.Instance = self
	self.view = BossXuanShangView.New(ViewName.BossXuanShang)
	self.data = BossXuanShangData.New()
	self:RegisterAllProtocols()
end

function BossXuanShangCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil


	self.data:DeleteMe()
	self.data = nil

	BossXuanShangCtrl.Instance = nil
end

function BossXuanShangCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCBossXuanShangData, "OnBossXuanShangData")
end

-- 请求悬赏boss数据
function BossXuanShangCtrl:SendBossInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSBossXuanShangInfoReq)
	protocol:EncodeAndSend()
end

function BossXuanShangCtrl:OnBossXuanShangData(protocol)
	self.data:SetXuanShangBossInfo(protocol)
	self.view:Flush()
end