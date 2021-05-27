require("scripts/game/equipment/equipment_data")
require("scripts/game/equipment/equipment_view")
require("scripts/game/equipment/equipment_suit_attr")
require("scripts/game/equipment/equipment_fusion_recycle_view")

EquipmentCtrl = EquipmentCtrl or BaseClass(BaseController)

function EquipmentCtrl:__init()
	if EquipmentCtrl.Instance then
		ErrorLog("[EquipmentCtrl]:Attempt to create singleton twice!")
	end
	EquipmentCtrl.Instance = self

	self.data = EquipmentData.New()
	self.view = EquipmentView.New(ViewDef.Equipment)
	self.equipment_suit_attr = EquipmentSuitAttr.New(ViewDef.EquipmentSuitAttr)
	self.equipment_fusion_recycle = EquipmentFusionRecycleView.New(ViewDef.EquipmentFusionRecycle)

	self:RegisterAllProtocols()
end

function EquipmentCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	if self.equipment_suit_attr then
		self.equipment_suit_attr:DeleteMe()
		self.equipment_suit_attr = nil
	end

	if self.equipment_fusion_recycle then
		self.equipment_fusion_recycle:DeleteMe()
		self.equipment_fusion_recycle = nil
	end

    EquipmentCtrl.Instance = nil
end

function EquipmentCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCEquipFulingResult, "OnEquipFulingResult")
	self:RegisterProtocol(SCEquipFulingShiftResult, "OnEquipFulingShiftResult")
	self:RegisterProtocol(SCGodSaveResult, "OnGodSaveResult")
end

--打开套装属性面板
-- _type = 1-强化 2-精炼 3-鉴定 4-基础融合 5-热血融合 6-神装神铸套装 7-热血神铸套装 8-豪装神铸套装
function EquipmentCtrl:OpenSuitAttr(_type)
	self.equipment_suit_attr:SetType(_type)
	ViewManager.Instance:OpenViewByDef(ViewDef.EquipmentSuitAttr)
end

---------------------------------------------
--------- ******* 无用功能代码 ******* -----------
---------------------------------------------


----------------------------------------------------
-- 附灵 begin
----------------------------------------------------
function EquipmentCtrl:OpenItem(equip_tip, excluse_data)
	if nil ~= self.item_view then
		self.item_view:SetEquipTip(equip_tip)
		self.item_view:SetExcluseData(excluse_data)
		self.item_view:Open()
	end
end

function EquipmentCtrl:CloseItem()
	if nil ~= self.item_view then
		self.item_view:Close()
	end
end

function EquipmentCtrl:MoveItemToFulingMainCell(data) 
	self.view:SetFulingMainCellData(data)
	self.item_view:Close()
end

function EquipmentCtrl:MoveItemToFulingMateCell(data)
	self.view:SetFulingMateCellData(data)
	self.item_view:Close()
end

function EquipmentCtrl:RemoveFulingMainCellData()
	self.view:SetFulingMainCellData(nil)
end

function EquipmentCtrl:RemoveFulingMateCellData()
	self.view:SetFulingMateCellData(nil)
end

function EquipmentCtrl:MoveItemToFulingShiftMain(data)
	self.view:SetFulingShiftMainCellData(data)
	self.item_view:Close()
end

function EquipmentCtrl:MoveItemToFulingShiftMate(data)
	self.view:SetFulingMateShiftCellData(data)
	self.item_view:Close()
end

function EquipmentCtrl:RemoveFulingShiftMainCell()
	self.view:SetFulingShiftMainCellData(nil)
end

function EquipmentCtrl:RemoveFulingShiftMateCell()
	self.view:SetFulingMateShiftCellData(nil)
end

-- 装备附灵请求
function EquipmentCtrl.SentEquipFulingReq(is_in_bag, fuling_equip, consume_equip)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipFulingReq)
	protocol.is_in_bag = is_in_bag
	protocol.fuling_equip = fuling_equip
	protocol.consume_equip = consume_equip
	protocol:EncodeAndSend()
end

-- 装备附灵转移请求
function EquipmentCtrl.SentEquipFulingShiftReq(is_in_bag, fuling_equip, consume_equip)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipFulingShiftReq)
	protocol.is_in_bag = is_in_bag
	protocol.fuling_equip = fuling_equip
	protocol.consume_equip = consume_equip
	protocol:EncodeAndSend()
end

-- 附灵属性变更
function EquipmentCtrl.ChangeEquipFuling(series, fuling_level, fuling_exp)
	if nil == series then
		return
	end

	fuling_level = fuling_level or 0
	fuling_exp = fuling_exp or 0

	local equip_data = EquipData.Instance:GetEquipBySeries(series)
	if nil ~= equip_data then
		equip_data.fuling_level = fuling_level
		equip_data.fuling_exp = fuling_exp
		EquipData.Instance:EquipInfoChange(equip_data)
	else
		equip_data = ItemData.Instance:GetItemInBagBySeries(series)
		if nil ~= equip_data then
			equip_data.fuling_level = fuling_level
			equip_data.fuling_exp = fuling_exp
			ItemData.Instance:BagItemInfoChange(equip_data)
		end
	end
end

-- 装备附灵结果
function EquipmentCtrl:OnEquipFulingResult(protocol)
	if 1 == protocol.result then
		EquipmentCtrl.ChangeEquipFuling(protocol.equip_series, protocol.level, protocol.exp)
	end
end

-- 装备附灵转移结果
function EquipmentCtrl:OnEquipFulingShiftResult(protocol)
	if 1 == protocol.result then
		EquipmentCtrl.ChangeEquipFuling(protocol.fuling_series, protocol.level, protocol.exp)
		EquipmentCtrl.ChangeEquipFuling(protocol.consume_series, 0, 0)
	end
end

----------------------------------------------------
-- 附灵 end
----------------------------------------------------

----------------------------------------------------
-- 神佑 began
----------------------------------------------------

function EquipmentCtrl:OnGodSaveResult(protocol)
	local last_level = self.data:GetLastGodsaveLevel()
	if last_level == 0 and protocol.level == 1 then
		self.view:SetShowPlayEff(901, 566, 286)
	elseif protocol.level > 1 and protocol.level > last_level then
		self.view:SetShowPlayEff(902, 566, 286)
	end
end

-- 接口废弃
-- function EquipmentCtrl.SendInjectElemReq(is_bag, series, elem_index)
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSInjectElement)
-- 	protocol.is_in_bag = is_bag
-- 	protocol.series = series
-- 	protocol.elem_index = elem_index
-- 	protocol:EncodeAndSend()
-- end

function EquipmentCtrl.SendElemUpgradeReq(is_bag, series, elem_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSElementUpgrade)
	protocol.is_in_bag = is_bag
	protocol.series = series
	protocol.elem_index = elem_index
	protocol:EncodeAndSend()
end

----------------------------------------------------
-- 神佑 end
----------------------------------------------------
