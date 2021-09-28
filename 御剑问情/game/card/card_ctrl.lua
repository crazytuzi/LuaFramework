require("game/card/card_view")
require("game/card/card_recyle_select_view")
require("game/card/card_auto_guaji_view")
require("game/card/card_data")
require("game/card/card_piece_tips")

CardCtrl = CardCtrl or  BaseClass(BaseController)

function CardCtrl:__init()
	if CardCtrl.Instance ~= nil then
		ErrorLog("[CardCtrl] attempt to create singleton twice!")
		return
	end
	CardCtrl.Instance = self

	self:RegisterAllProtocols()

	self.card_piece_tips = CardPieceTip.New()
	self.data = CardData.New()
	self.view = CardView.New(ViewName.CardView)
	self.guaji_view = CardAutoGuajiView.New()
	self.recyle_view = CardRecyleSelectView.New()
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event, true)
end

function CardCtrl:__delete()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.guaji_view ~= nil then
		self.guaji_view:DeleteMe()
		self.guaji_view = nil
	end

	if self.recyle_view ~= nil then
		self.recyle_view:DeleteMe()
		self.recyle_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.card_piece_tips ~= nil then
		self.card_piece_tips:DeleteMe()
		self.card_piece_tips = nil
	end
	CardCtrl.Instance = nil

	if self.card_recyle_count_down then
		CountDown.Instance:RemoveCountDown(self.card_recyle_count_down)
		self.card_recyle_count_down = nil
	end
end

-- 协议注册
function CardCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCardAllInfo, "OnCardAllInfo")
	self:RegisterProtocol(SCCardLevelUp, "OnCardLevelUp")
	self:RegisterProtocol(SCCardSlotPutOnUpdate, "OnCardSlotPutOnUpdate")
end

function CardCtrl:OpenCardPieceTip(data, from_view, param_t, close_call_back, gift_id, is_check_item)
	self.card_piece_tips:SetData(data, from_view, param_t, close_call_back, gift_id, is_check_item)
end

function CardCtrl:OpenGuajiView()
	self.guaji_view:Open()
end

function CardCtrl:OpenRecyleView(call_back)
	self.recyle_view:SetCallBack(call_back)
	self.recyle_view:Open()
end

function CardCtrl:OnCardAllInfo(protocol)
	self.data:SetAllInfo(protocol)
	self.view:Flush()
end

function CardCtrl:OnCardLevelUp(protocol)
	local card_exp = self.data:GetCardExp()
	if protocol.card_exp > card_exp then
		local msg = string.format(Language.SysRemind.AddCardScore, protocol.card_exp - card_exp)
		TipsCtrl.Instance:ShowFloatingLabel(msg)
	end
	self.data:SetExpInfo(protocol)
	self.view:Flush()
end

function CardCtrl:OnCardSlotPutOnUpdate(protocol)
	self.data:SetCardItem(protocol.card_idx, protocol.slot_idx, protocol.item_id)
	GlobalEventSystem:Fire(OtherEventType.FLUSH_BAG_GRID)
	self.view:Flush()
end

function CardCtrl.SendCardAllInfoReq()
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCardAllInfoReq)
	protocol_send:EncodeAndSend()
end

function CardCtrl.SendCardSlotPutOn(card_idx, slot_idx, grid_index)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCardSlotPutOn)
	protocol_send.card_idx = card_idx
	protocol_send.slot_idx = slot_idx
	protocol_send.grid_index = grid_index
	protocol_send:EncodeAndSend()
end

function CardCtrl.SendCardSlotTakeOff(card_idx, slot_idx)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCardSlotTakeOff)
	protocol_send.card_idx = card_idx
	protocol_send.slot_idx = slot_idx
	protocol_send:EncodeAndSend()
end

function CardCtrl:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if nil == item_id or self.data:IsCardPiece(item_id) then
		local color = self.data:GetCardColor(item_id)
		self.data:ClearCacheCardItemList()
		local is_better, is_open = self.data:IsBetterCardPiece(item_id)
		if is_better and not is_open then
			is_better = color > 2
		end
		if (new_num and new_num > 0) and not self.data:IsMaxCardLevel() and (PUT_REASON_TYPE.PUT_REASON_PICK == put_reason or PUT_REASON_TYPE.PUT_REASON_GM == put_reason)
			and color <= SettingData.Instance:GetCardPieceIndex() and not is_better then
			PackageCtrl.Instance:SendDiscardItem(index, new_num, item_id, new_num, 1)
		end
		self.view:Flush()
	end
end

function CardCtrl:SetDelayRemind()
	if self.card_recyle_count_down then
		return
	end
	local total_time = DelayTimeRemindList[RemindName.CardRecyle]
	self.card_recyle_count_down = CountDown.Instance:AddCountDown(total_time, 1,
		function ()
			DelayTimeRemindList[RemindName.CardRecyle] = DelayTimeRemindList[RemindName.CardRecyle] - 1
			if DelayTimeRemindList[RemindName.CardRecyle] == 0 then
				RemindManager.Instance:Fire(RemindName.CardRecyle)
				self.card_recyle_count_down = nil
			end
		end)
end