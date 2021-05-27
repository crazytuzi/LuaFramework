require("scripts/game/guard_equip/guard_equip_data")
require("scripts/game/guard_equip/guard_equip_view")
require("scripts/game/guard_equip/guard_shop_view")

--------------------------------------------------------
-- 守护神装Ctrl
--------------------------------------------------------

GuardEquipCtrl = GuardEquipCtrl or BaseClass(BaseController)

function GuardEquipCtrl:__init()
	if	GuardEquipCtrl.Instance then
		ErrorLog("[GuardEquipCtrl]:Attempt to create singleton twice!")
	end
	GuardEquipCtrl.Instance = self

	self.data = GuardEquipData.New()
	self.view = GuardEquipView.New(ViewDef.GuardEquip)
	self.shop_view = GuardShopView.New(ViewDef.GuardShop)

	self:RegisterAllProtocols()
end

function GuardEquipCtrl:__delete()
	GuardEquipCtrl.Instance = nil
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.shop_view then
		self.shop_view:DeleteMe()
		self.shop_view = nil
	end
end

--登记所有协议
function GuardEquipCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCWearGuardEquipResult, "OnWearGuardEquipResult")
	self:RegisterProtocol(SCAllGuardEquipInfo, "OnAllGuardEquipInfo")
	self:RegisterProtocol(SCGuardShopData, "OnGuardShopData")
end

----------接收----------

-- 接收穿上/替换守护神装结果(53, 1)
function GuardEquipCtrl:OnWearGuardEquipResult(protocol)
	self.data:SetWearGuardEquipResult(protocol)
end

-- 接收所有守护神装信息(53, 2)
function GuardEquipCtrl:OnAllGuardEquipInfo(protocol)
	self.data:SetAllGuardEquipInfo(protocol)
end

-- 接收守护神装商铺数据(139, 70)
function GuardEquipCtrl:OnGuardShopData(protocol)
	self.data:SetGuardShopData(protocol)
end

----------发送----------

-- 请求穿上/替换守护神装(53, 1)
function GuardEquipCtrl.SendWearGuardEquipReq(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWearGuardEquipReq)
	protocol.series = series
	protocol:EncodeAndSend()
end

-- 请求守护商店信息(139, 69)
-- 达到开放条件后,因为刷新时间是固定的,新开放的商店还是没有物品,没有作用
function GuardEquipCtrl.SendGuardShopInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuardShopInfoReq)
	protocol:EncodeAndSend()
end

-- 购买守护神装(139, 70)
function GuardEquipCtrl.SendBuyGuardEquipReq(shop_type, item_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyGuardEquipReq)
	protocol.shop_type = shop_type
	protocol.item_index = item_index
	protocol:EncodeAndSend()
end

-- 手动刷新守护神装商铺(139, 71)
function GuardEquipCtrl.SendFlushGuardEquipReq(shop_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFlushGuardEquipReq)
	protocol.shop_type = shop_type
	protocol:EncodeAndSend()
end

--------------------
