require("scripts/game/god_furnace/god_furnace_data")
require("scripts/game/god_furnace/god_furnace_view")

require("scripts/game/god_furnace/subviews/gf_common_view")

require("scripts/game/god_furnace/holy_synthesis_view")
require("scripts/game/god_furnace/select_holy_item_view")
require("scripts/game/god_furnace/fire_god_power_view")
require("scripts/game/god_furnace/resist_god_skill_view")

GodFurnaceCtrl = GodFurnaceCtrl or BaseClass(BaseController)

function GodFurnaceCtrl:__init()
	if GodFurnaceCtrl.Instance then
		ErrorLog("[GodFurnaceCtrl]:Attempt to create singleton twice!")
	end
	GodFurnaceCtrl.Instance = self

	self.data = GodFurnaceData.New()
	self.view = GodFurnaceView.New(ViewDef.GodFurnace)
	GFCommonView.New(ViewDef.GodFurnace.TheDragon):SetSlot(GodFurnaceData.Slot.TheDragonPos)
	GFCommonView.New(ViewDef.GodFurnace.Shield):SetSlot(GodFurnaceData.Slot.ShieldPos)
	GFCommonView.New(ViewDef.GodFurnace.ShenDing):SetSlot(GodFurnaceData.Slot.ShenDing)
	require("scripts/game/god_furnace/subviews/gem_stone_view").New(ViewDef.GodFurnace.GemStone)
	require("scripts/game/god_furnace/subviews/dragon_spirit_view").New(ViewDef.GodFurnace.DragonSpirit)

	self.holy_synthesis_view = HolySynthesisView.New(ViewDef.HolySynthesis)
	self.select_holy_item_view = SelectHolyItemView.New(ViewDef.SelectHolyItem)
	self.fire_god_power_view = FireGodPowerView.New(ViewDef.FireGodPower)
	self.resist_god_skill_view = ResistGodSkillView.New(ViewDef.ResistGodSkill)

	self:RegisterAllProtocols()
end

function GodFurnaceCtrl:__delete()
	GodFurnaceCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil

	self.holy_synthesis_view:DeleteMe()
	self.holy_synthesis_view = nil

	self.select_holy_item_view:DeleteMe()
	self.select_holy_item_view = nil

	self.fire_god_power_view:DeleteMe()
	self.fire_god_power_view = nil

	self.resist_god_skill_view:DeleteMe()
	self.resist_god_skill_view = nil

	self.data:DeleteMe()
	self.data = nil
end

function GodFurnaceCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCAllGodFurnaceData, "OnAllGodFurnaceData")
	self:RegisterProtocol(SCGodFurnaceUpResult, "OnGodFurnaceUpResult")
	self:RegisterProtocol(SCGodFurnaceAddValResult, "OnGodFurnaceAddValResult")
	self:RegisterProtocol(SCGFPutOnEquipResult, "OnGFPutOnEquipResult")
	self:RegisterProtocol(SCSynthesisGodItem, "OnSynthesisGodItem")
end

-- 合成成功
function GodFurnaceCtrl:OnSynthesisGodItem(protocol)
	GlobalEventSystem:Fire(GodFurnaceData.SYNTHESISSUCC)
	self.data:ChangeOneHolySynthesis(GodFurnaceData.HOLY_POS.SYNTHESIS, {item_id = protocol.item_id, num = 1, is_bind = 0})
end

-- 下发穿上结果
function GodFurnaceCtrl:OnGFPutOnEquipResult(protocol)
	self.data:SetOneEquip(protocol.equip_data)
end

-- 下发灌注印记结果
function GodFurnaceCtrl:OnGodFurnaceAddValResult(protocol)
	self.data:SetGodPowerLevel(protocol.level)
	self.data:SetGodPowerVal(protocol.val)
end

-- 下发神炉升级结果
function GodFurnaceCtrl:OnGodFurnaceUpResult(protocol)
	self.data:SetSlotData(protocol.slot, {level = protocol.level})
end

-- 下发所有神炉数据
function GodFurnaceCtrl:OnAllGodFurnaceData(protocol)
	for k, v in pairs(protocol.gf_data) do
		self.data:SetSlotData(k, v)
	end

	self.data:SetGodPowerLevel(protocol.god_power_level)
	self.data:SetGodPowerVal(protocol.god_power_val)

	self.data:SetAllEquip(protocol.equip_list)
end

-----------------------------------------------------------------------------
-- 神炉升级与激活
function GodFurnaceCtrl.SendGodFurnaceUpReq(slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGodFurnaceUpReq)
	protocol.slot = slot or 0
	protocol:EncodeAndSend()
end

-- 灌注印记(烈焰神力)
function GodFurnaceCtrl.SendGFAddGodPowerReq(item_id_list)
	if nil == item_id_list and #item_id_list == 0 then
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSGFAddGodPowerReq)
	protocol.item_id_list = item_id_list
	protocol:EncodeAndSend()
end

-- 神炉穿上装备
function GodFurnaceCtrl.SendPutOnEquipReq(series, equip_slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGodFurnacePutOnEquipReq)
	protocol.series = series or 0
	protocol.equip_slot = equip_slot or 0
	protocol:EncodeAndSend()
end

-- 合成圣物
function GodFurnaceCtrl.SendSynthesisGodItemReq(item_list)
	if nil == item_list and #item_list == 0 then
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSSynthesisGodItemReq)
	protocol.item_list = item_list
	protocol:EncodeAndSend()
end
