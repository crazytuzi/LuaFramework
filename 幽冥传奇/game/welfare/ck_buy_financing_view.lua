
CkBuyFinancingView = CkBuyFinancingView or BaseClass(XuiBaseView)
function CkBuyFinancingView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.config_tab = {
		{"welfare_ui_cfg", 10, {0}},
	}
end

function CkBuyFinancingView:__delete()
end

function CkBuyFinancingView:ReleaseCallBack()
end

function CkBuyFinancingView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_OK.node:addClickEventListener(BindTool.Bind1(self.OnClickOK, self))
		self.node_t_list.btn_OK.node:setTitleText(Language.Common.ActivateVip)
		self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind1(self.OnClickCancel, self))
		self.node_t_list.rich_content.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	end

	self:Flush()
end

function CkBuyFinancingView:ShowIndexCallBack(index)
	self:Flush()
end
	
function CkBuyFinancingView:OpenCallBack()
end

function CkBuyFinancingView:CloseCallBack()
end

function CkBuyFinancingView:OnFlush(param_t, index)
	RichTextUtil.ParseRichText(self.node_t_list.rich_content.node, Language.Welfare.CanNotBuyFinancing, 24, COLOR3B.RED)
	RichTextUtil.ParseRichText(self.node_t_list.rich_1.node, string.format(Language.Welfare.BuyFinancingReq1, FinancingCfg.vipLevel), 24, COLOR3B.OLIVE)
	RichTextUtil.ParseRichText(self.node_t_list.rich_2.node, Language.Welfare.BuyFinancingReq2, 24, COLOR3B.OLIVE)
end

function CkBuyFinancingView:OnClickOK()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	self:Close()
end

function CkBuyFinancingView:OnClickCancel()
	self:Close()
end