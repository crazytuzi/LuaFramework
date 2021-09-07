VipRechargeTipView = VipRechargeTipView or BaseClass(BaseView)
function VipRechargeTipView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/vipview","VipRechargeTip"}
end

function VipRechargeTipView:ReleaseCallBack()
	self.vipdes = nil
end

function VipRechargeTipView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickClear", BindTool.Bind(self.ClickClear, self))
	self.vipdes = self:FindVariable("VipDes")
	self.vipdes:SetValue(Language.Common.VipRechargeTipDes)
end

function VipRechargeTipView:CloseWindow()
	self:Close()
end

function VipRechargeTipView:ClickClear()
	VipCtrl.Instance:GoToVipRecharge()
	self:Close()
end