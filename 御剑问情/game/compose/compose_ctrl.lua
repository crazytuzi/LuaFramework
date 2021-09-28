require("game/compose/compose_data")
require("game/compose/compose_view")
require("game/compose/duihuan/duihuan_view")
require("game/compose/new_select_equip_view")

ComposeCtrl = ComposeCtrl or BaseClass(BaseController)

function ComposeCtrl:__init()
	if ComposeCtrl.Instance then
		print_error("[ComposeCtrl] Attemp to create a singleton twice !")
	end
	ComposeCtrl.Instance = self

	self.data = ComposeData.New()
	self.view = ComposeView.New(ViewName.Compose)
	self.duihuan_view = DuihuanView.New(ViewName.DuihuanView)
	self.select_equip_view = NewSelectEquipView.New(ViewName.NewSelectEquipView)
end

function ComposeCtrl:__delete()
	self.view:DeleteMe()
	self.data:DeleteMe()
	self.duihuan_view:DeleteMe()
	self.select_equip_view:DeleteMe()
	ComposeCtrl.Instance = nil
end

function ComposeCtrl:SendItemCompose(product_seq, num, compose_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSItemCompose)
	send_protocol.product_seq = product_seq
	send_protocol.num = num
	send_protocol.compose_type = compose_type
	send_protocol:EncodeAndSend()
end

function ComposeCtrl:RedColorEquipCompose(stuff_knapsack_index_list, stuff_index_count, target_equipment_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRedColorEquipCompose)
	send_protocol.stuff_knapsack_index_list = stuff_knapsack_index_list or {}
	send_protocol.stuff_index_count = stuff_index_count or 0
	send_protocol.target_equipment_index = target_equipment_index or 0
	send_protocol:EncodeAndSend()
end

function ComposeCtrl:OpenSelectEquipView(data, callback)
	self.select_equip_view:SetData(data)
	self.select_equip_view:SetCallBack(callback)
	self.select_equip_view:Open()
end