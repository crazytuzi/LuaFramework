require("game/discount/discount_data")
require("game/discount/discount_view")

DisCountCtrl = DisCountCtrl or BaseClass(BaseController)

function DisCountCtrl:__init()
	if DisCountCtrl.Instance then
		print_error("[DisCountCtrl]:Attempt to create singleton twice!")
	end
	DisCountCtrl.Instance = self

	self.view = DisCountView.New(ViewName.DisCount)
	self.data = DisCountData.New()

	self:RegisterAllProtocols()

	self.interval = 1				--刷新间隔
	self.last_refresh_time = 0		--最后刷新的时间

	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
	Runner.Instance:AddRunObj(self, 16)
end

function DisCountCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	
	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end

	Runner.Instance:RemoveRunObj(self)
	DisCountCtrl.Instance = nil
end

function DisCountCtrl:Update()
	if Status.NowTime - self.interval < self.last_refresh_time then
		return
	end
	self.last_refresh_time = Status.NowTime

	local phase_list = self.data:GetPhaseList()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local is_active = false
	for k, v in ipairs(phase_list) do
		local close_timestamp = v.close_timestamp
		if close_timestamp > server_time then
			is_active = true
			break
		end
	end
	local can_active = self.data:GetCanActive()
	if not can_active then
		is_active = false
	end

	--获取当前状态
	local now_active_state = self.data:GetActiveState()
	if now_active_state == is_active then
		return
	end

	self.data:SetActiveState(is_active)

	MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.DisCount, {is_active})
end

function DisCountCtrl:RegisterAllProtocols()
	-- 注册接收到的协议
	self:RegisterProtocol(SCDiscountBuyInfo, "OnSCDiscountBuyInfo")		--一折抢购信息

	-- 注册发送的协议
	self:RegisterProtocol(CSDiscountBuyGetInfo)		--获得一折抢购信息
	self:RegisterProtocol(CSDiscountBuyReqBuy)		--一折抢购购买请求
end

function DisCountCtrl:OnSCDiscountBuyInfo(protocol)
	self.data:SetPhaseList(protocol.phase_list)
	local can_active = self.data:CheckCanActive()
	self.data:SetCanActive(can_active)
	local have_new_discount = self.data:GetHaveNewDiscount()
	if have_new_discount then
		-- MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.DisCountRed, {true})
		MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.DisCountAni)
	end
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function DisCountCtrl:SendDiscountBuyGetInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSDiscountBuyGetInfo)
	protocol:EncodeAndSend()
end

function DisCountCtrl:SendDiscountBuyReqBuy(seq, reserve_sh)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDiscountBuyReqBuy)
	protocol.seq = seq or 0
	protocol.reserve_sh = reserve_sh or 0
	protocol:EncodeAndSend()
end

function DisCountCtrl:MainuiOpen()
	self:SendDiscountBuyGetInfo()
end