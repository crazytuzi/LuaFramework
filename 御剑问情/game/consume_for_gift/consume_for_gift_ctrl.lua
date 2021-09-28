require("game/consume_for_gift/consume_for_gift_view")
require("game/consume_for_gift/consume_for_gift_data")

ConsunmForGiftCtrl = ConsunmForGiftCtrl or BaseClass(BaseController)

function ConsunmForGiftCtrl:__init()
	if ConsunmForGiftCtrl.Instance then
		print_error("[ConsunmForGiftCtrl] Attemp to create a singleton twice !")
	end
	ConsunmForGiftCtrl.Instance = self

	self.consume_for_gift_data = ConsumeForGiftData.New()
	self.consume_for_gift_view = ConsunmForGiftView.New(ViewName.ConsunmForGiftView)

	self:RegisterAllProtocols()

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.CousumeForGiftRemind)

end

function ConsunmForGiftCtrl:__delete()
	ConsunmForGiftCtrl.Instance = nil

	if self.consume_for_gift_view then
		self.consume_for_gift_view:DeleteMe()
		self.consume_for_gift_view = nil
	end

	if self.consume_for_gift_data then
		self.consume_for_gift_data:DeleteMe()
		self.consume_for_gift_data = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function ConsunmForGiftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAConsumeForGiftAllInfo, "OnSCRAConsumeForGiftAllInfo")
end

function ConsunmForGiftCtrl:OnSCRAConsumeForGiftAllInfo(protocol)
	self.consume_for_gift_data:SetConsumeForGiftAllInfo(protocol)
	
	self.consume_for_gift_view:Flush()
	RemindManager.Instance:Fire(RemindName.CousumeForGiftRemind)
end

function ConsunmForGiftCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.CousumeForGiftRemind then
		self.consume_for_gift_data:FlushHallRedPoindRemind()
	end
end