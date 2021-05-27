require("scripts/game/gemstone/gemstone_data")
require("scripts/game/gemstone/gemstone_view")
require("scripts/game/gemstone/gemstone_up_view")

GemStoneCtrl = GemStoneCtrl or BaseClass(BaseController)

function GemStoneCtrl:__init()
	if GemStoneCtrl.Instance then
		ErrorLog("[GemStoneCtrl]:Attempt to create singleton twice!")
	end
	GemStoneCtrl.Instance = self
	-- self.view = GemStoneView.New(ViewName.GemStone)
	self.data = GemStoneData.New()
	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	self:RegisterAllProtocols()
end

function GemStoneCtrl:__delete()
	
	-- self.view:DeleteMe()
	-- self.view = nil

	self.data:DeleteMe()
	self.data = nil

	
    GemStoneCtrl.Instance = nil
    if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end
	if self.up_view then
		self.up_view:DeleteMe()
		self.up_view = nil 
	end
end

function GemStoneCtrl:RegisterAllProtocols()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.RemindDef, self), RemindName.GemCouond, 1)
	-- GlobalEventSystem:Fire(SoulStoneEventType.GET_MY_SOUL_STONE_INFO)
	-- self.icon_open_evt = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.CheckIconOpen, self))
	self:RegisterProtocol(SCPolishDiamondData,"OnPolishDiamondResult")
end

function GemStoneCtrl:SendPolishDiamondReq(diamond_model, polish_equipslot_pos, polish_pos, polish_hero_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPolishDiamondReq)
	protocol.diamond_model = diamond_model
	protocol.polish_equipslot_pos = polish_equipslot_pos
	protocol.polish_pos = polish_pos 
	protocol.polish_hero_id = polish_hero_id
	protocol:EncodeAndSend()
end

function GemStoneCtrl:OnPolishDiamondResult(protocol)
	self.data:SetPolishDiamondResult(protocol)
	GlobalEventSystem:Fire(SoulStoneEventType.GET_MY_SOUL_STONE_RESULT)
end

function GemStoneCtrl:OpenUpView(equipment_pos, diamond_pos)
	self.up_view = self.up_view or GemStoneUpView.New()
	self.up_view:Open()
	self.up_view:SetData(equipment_pos, diamond_pos)
end

function GemStoneCtrl:RemindDef(remind_name)
	if remind_name == RemindName.GemCouond then
		return self.data:BoolCanCoupond()
	end
end

function GemStoneCtrl:ItemDataChangeCallback(change_type, item_id, index, series, reason)
	
	if not self.delay_do_equipment_comp then
		self.delay_do_equipment_comp = GlobalTimerQuest:AddDelayTimer(function()
			local config = ItemData.Instance:GetItemConfig(item_id)
			if config and config.dura then
				RemindManager.Instance:DoRemind(RemindName.GemCouond)
			end
			if self.delay_do_equipment_comp then
				GlobalTimerQuest:CancelQuest(self.delay_do_equipment_comp)
				self.delay_do_equipment_comp = nil
			end	
		end,0.5)
	end
end


