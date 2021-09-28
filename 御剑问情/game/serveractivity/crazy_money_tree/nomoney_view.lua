NoMoneyView = NoMoneyView or BaseClass(BaseView)
function NoMoneyView:__init()
	self.ui_config = {"uis/views/serveractivity/crazymoneytree_prefab", "NoMoneyView"}
end
function NoMoneyView:LoadCallBack()
	self:ListenEvent("OnClickYes", BindTool.Bind(self.OnClickShop, self))
	self:ListenEvent("OnClickNo", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
end

function NoMoneyView:__delete()

end

function NoMoneyView:ReleaseCallBack()
	
end
function NoMoneyView:OnClickShop()
		ViewManager.Instance:Open(ViewName.VipView)
end

function NoMoneyView:OnClickClose()
	CrazyMoneyTreeCtrl.Instance:Close()
end

function NoMoneyView:OnFlush(param_t, index)
	
end
	