require("game/adventure_shop/adventure_shop_data")
require("game/adventure_shop/adventure_shop_view")
require("game/adventure_shop/adventure_shop_pop")

AdventureShopCtrl= AdventureShopCtrl or BaseClass(BaseController)

function AdventureShopCtrl:__init()
	if AdventureShopCtrl.Instance then
		print_error("[AdventureShopCtrl]:Attempt to create singleton twice!")
	end
	AdventureShopCtrl.Instance = self
	self.view = AdventureShopView.New(ViewName.AdventureShopView)
	self.pop_view = AdventureShopPop.New(ViewName.AdventureShopPop)
	self.data = AdventureShopData.New()
	self:RegisterAllProtocols()
	self.is_first_open = true
end

function AdventureShopCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.pop_view then
		self.pop_view:DeleteMe()
		self.pop_view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

    if self.main_view_complete then
    	GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end
    
	AdventureShopCtrl.Instance = nil
end

function AdventureShopCtrl:GetView()
	return self.view
end

function AdventureShopCtrl:GetData()
	return self.data
end

function AdventureShopCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCQiyuShopAllInfo, "OnSCQiyuShopAllInfo")
	self:RegisterProtocol(CSQiyuShopReq)
end

function AdventureShopCtrl:SendAdventureShopReq(req_type, param1)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSQiyuShopReq)
	protocol_send.opera_type = req_type or 0
	protocol_send.param1 = param1 or 0
	protocol_send:EncodeAndSend()
end

function AdventureShopCtrl:OnSCQiyuShopAllInfo(protocol)
	self.data:SetAdventureShop(protocol)
	local reward_cfg = self.data:GetAdventureShopRewards()
	if next(reward_cfg) ~= nil then
		if protocol.ra_qiyushop_has_open_view == 0 and protocol.open_left_times > 0 then
			ViewManager.Instance:Open(ViewName.AdventureShopPop)
		else
			if protocol.open_left_times == 0 then
				self.is_first_open = true
				self.view:Close()
			elseif not self.view:IsOpen() and (protocol.open_left_times > 0 and protocol.has_fetch == 0) and self.is_first_open
				and self.data:GetIsOpenShopView(protocol.histroy_chongzhi) then
				ViewManager.Instance:Open(ViewName.AdventureShopView)
				self.is_first_open = false
			end
		end
		if self.view:IsOpen() then
			self.view:Flush()
		end
		MainUICtrl.Instance:OnShowAdventureShopIcon(protocol.open_left_times > 0)
		RemindManager.Instance:Fire(RemindName.AdventureShop)
	end
end