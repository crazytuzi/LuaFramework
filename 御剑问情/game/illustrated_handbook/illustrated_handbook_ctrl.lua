require("game/illustrated_handbook/illustrated_handbook_view")
require("game/illustrated_handbook/illustrated_handbook_data")

IllustratedHandbookCtrl = IllustratedHandbookCtrl or BaseClass(BaseController)

function IllustratedHandbookCtrl:__init()
	if IllustratedHandbookCtrl.Instance ~= nil then
		ErrorLog("[IllustratedHandbookCtrl] attempt to create singleton twice!")
		return
	end
	IllustratedHandbookCtrl.Instance = self

	self.data = IllustratedHandbookData.New()
	self.view = IllustratedHandbookView.New(ViewName.IllustratedHandbookView)

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	self:RegisterAllProtocols()
end

function IllustratedHandbookCtrl:__delete()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	IllustratedHandbookCtrl.Instance = nil

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
end

-- 协议注册
function IllustratedHandbookCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCBossHandBookAllInfo, "OnBossHandBookAllInfo")
	self:RegisterProtocol(SCBossHandBookCardInfo, "OnBossHandBookCardInfo")
end

function IllustratedHandbookCtrl:OnBossHandBookAllInfo(protocol)
	self.data:SetAllCardInfo(protocol)
	self:FlushHandbookView()
end

function IllustratedHandbookCtrl:OnBossHandBookCardInfo(protocol)
	self.data:SetSingleCardInfo(protocol)
	self:FlushHandbookView()
end

function IllustratedHandbookCtrl:SendBossHandBookPutOn(card_idx)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSBossHandBookPutOn)
	protocol_send.card_idx = card_idx or 0
	protocol_send:EncodeAndSend()
end

function IllustratedHandbookCtrl:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if nil == item_id then return end

	if self.view and self.view:IsOpen() then
		local is_need_item = self.data:IsNeedItem(item_id)
		if not is_need_item then return end

		self:FlushHandbookView()
	end
end

function IllustratedHandbookCtrl:FlushHandbookView()
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.BossHandBook)
end

function IllustratedHandbookCtrl:FlushEffect(result)
	if nil == result or result ~= 1 then return end
	 
	if self.view and self.view:IsOpen() then
		self.view:FlushEffect()
	end
end