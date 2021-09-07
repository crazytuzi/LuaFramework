TipsLackDiamondView = TipsLackDiamondView or BaseClass(BaseView)

function TipsLackDiamondView:__init()
	self.ui_config = {"uis/views/tips/lackdiamondtips", "LackDiamondTips"}
	self.view_layer = UiLayer.Pop
	self.sure_call_back = nil
	self.play_audio = true
end

function TipsLackDiamondView:LoadCallBack()
	self:ListenEvent("OnClickCloseButton",
		BindTool.Bind(self.OnClickCloseButton, self))
	self:ListenEvent("OnClickChongZhi",
		BindTool.Bind(self.OnClickChongZhi, self))
end

function TipsLackDiamondView:ReleaseCallBack()

end

function TipsLackDiamondView:OnClickCloseButton()
	self:Close()
end

function TipsLackDiamondView:CloseCallBack()
	if self.sure_call_back ~= nil then
		self.sure_call_back()
	end
	ViewManager.Instance:Close(ViewName.TipsCommonBuyView)
end

function TipsLackDiamondView:SetSureCallBack(sure_call_back)
	self.sure_call_back = sure_call_back
end

function TipsLackDiamondView:OnClickChongZhi()
	ViewManager.Instance:CloseAll()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end
