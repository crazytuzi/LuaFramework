require("game/hpbag/hp_bag_view")
require("game/hpbag/hp_bag_data")

HpBagCtrl = HpBagCtrl or BaseClass(BaseController)
function HpBagCtrl:__init()
	if HpBagCtrl.Instance then
		print_error("[HpBagCtrl] Attemp to create a singleton twice !")
	end
	HpBagCtrl.Instance = self

	self.hp_bag_view = HpBagView.New(ViewName.HpBag)
	self.hp_bag_data = HpBagData.New()
	self:RegisterAllProtocols()
end

function HpBagCtrl:__delete()
	HpBagCtrl.Instance = nil

	if self.hp_bag_view then
		self.hp_bag_view:DeleteMe()
		self.hp_bag_view = nil
	end

	if self.hp_bag_data then
		self.hp_bag_data:DeleteMe()
		self.hp_bag_data = nil
	end
end

function HpBagCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSSupplyBuyItem)
	self:RegisterProtocol(CSSupplySetRecoverRangePer)
	self:RegisterProtocol(SCSupplyInfo, "OnSCSupplyInfo")
end

function HpBagCtrl:OnSCSupplyInfo(protocol)
	self.hp_bag_data:GetSupplyInfo(protocol)
	if self.hp_bag_view:IsOpen() then
		self.hp_bag_view:Flush()
	end
	self.hp_bag_data:SetIsShowRepdt(true)
	RemindManager.Instance:Fire(RemindName.HpBag)
end

function HpBagCtrl:SendSupplyBuyItem(supply_type, index,is_use_no_bind_gold)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSSupplyBuyItem)
	send_protocol.supply_type = supply_type or 0
	send_protocol.index = index or 0
	send_protocol.is_use_no_bind_gold = is_use_no_bind_gold or 0
	send_protocol.reserver_1 = 0
	send_protocol.reserve_2 = 0
	send_protocol:EncodeAndSend()
end

function HpBagCtrl:SendSupplySetRecoverRangePer(supply_type, recover_range_per)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSSupplySetRecoverRangePer)
	send_protocol.supply_type = supply_type or 0
	send_protocol.recover_range_per = recover_range_per or 0
	send_protocol:EncodeAndSend()
end