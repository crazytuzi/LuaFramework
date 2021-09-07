AdventureShopPop = AdventureShopPop or BaseClass(BaseView)

function AdventureShopPop:__init()
	self.ui_config = {"uis/views/adventureshopview", "AdventureShopPop"}
	self.play_audio = true
	self.full_screen = false
	self:SetMaskBg()
end

function AdventureShopPop:LoadCallBack()
	self:ListenEvent("OnClick", BindTool.Bind(self.OnHandleClick, self))
	self.box_state = self:FindVariable("BoxState")
end

function AdventureShopPop:CloseCallBack()
	self.box_state = nil

	if self.delay_open_adventure_shop ~= nil and GlobalTimerQuest then
		GlobalTimerQuest:CancelQuest(self.delay_open_adventure_shop)
		self.delay_open_adventure_shop = nil
	end
end

function AdventureShopPop:OnHandleClick()
	self.box_state:SetValue(true)
	self.delay_open_adventure_shop = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.JumpToAdventureShop,self), 2)
end

function AdventureShopPop:JumpToAdventureShop()
	ViewManager.Instance:Open(ViewName.AdventureShopView)
	self:Close()
end