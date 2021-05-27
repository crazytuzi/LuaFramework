require("scripts/game/special_ring/special_ring_data")
require("scripts/game/special_ring/special_ring_view")
require("scripts/game/special_ring/special_ring_bag_view")
require("scripts/game/special_ring/special_ring_tip_view")
require("scripts/game/special_ring/special_ring_skill_tip_view")

--------------------------------------------------------
-- 特戒
--------------------------------------------------------

SpecialRingCtrl = SpecialRingCtrl or BaseClass(BaseController)

function SpecialRingCtrl:__init()
	if	SpecialRingCtrl.Instance then
		ErrorLog("[SpecialRingCtrl]:Attempt to create singleton twice!")
	end
	SpecialRingCtrl.Instance = self

	self.data = SpecialRingData.New()
	self.view = SpecialRingView.New(ViewDef.SpecialRing)
	self.bag_view = SpecialRingBagView.New(ViewDef.SpecialRingBag) -- 特戒背包
	self.tip_view = SpecialRingTipView.New() -- 特戒融合提示
	self.skill_tip_view = SpecialRingSkillTipView.New() -- 特戒技能tips

	self:RegisterAllProtocols()
end

function SpecialRingCtrl:__delete()
	SpecialRingCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.bag_view then
		self.bag_view:DeleteMe()
		self.bag_view = nil
	end

	if self.tip_view then
		self.tip_view:DeleteMe()
		self.tip_view = nil
	end

	if self.skill_tip_view then
		self.skill_tip_view:DeleteMe()
		self.skill_tip_view = nil
	end

end

--登记所有协议
function SpecialRingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSpecialRingInfo, "OnSpecialRingInfo")
end

----------接收----------

-- 接收特戒变更信息(139, 65)
function SpecialRingCtrl:OnSpecialRingInfo(protocol)
	self.data:SetSpecialRingInfo(protocol)
end

----------发送----------

-- 请求特戒融合(139, 65)
function SpecialRingCtrl.SendSpecialRingFusionReq(main_series, vice_series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSpecialRingFusionReq)
	protocol.main_series = main_series
	protocol.vice_series = vice_series
	protocol:EncodeAndSend()
end

--请求特戒分离(139, 66)
function SpecialRingCtrl.SendSpecialRingPartReq(main_series, slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSpecialRingPartReq)
	protocol.main_series = main_series
	protocol.slot = slot
	protocol:EncodeAndSend()
end

--------------------

function SpecialRingCtrl:OpenTip(equip)
	self.tip_view:SetData(equip)
	self.tip_view:Open()
end

function SpecialRingCtrl:OpenSkillTip(item_id)
	self.skill_tip_view:SetData(item_id)
	self.skill_tip_view:Open()
end
