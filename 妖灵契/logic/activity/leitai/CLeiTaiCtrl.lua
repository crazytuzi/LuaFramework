local CLeiTaiCtrl = class("CLeiTaiCtrl", CCtrlBase)

function CLeiTaiCtrl.ctor(self)
	CCtrlBase.ctor(self)
end

function CLeiTaiCtrl.OpenLeitai(self)
	self:OnReceiveOpenLeiTai()
end

function CLeiTaiCtrl.OnReceiveOpenLeiTai(self)
	CLeiTaiMainView:ShowView()
end

return CLeiTaiCtrl