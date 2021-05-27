SuperAfterVipView = SuperAfterVipView or BaseClass(XuiBaseView)
function SuperAfterVipView:__init()
	self:SetModal(true)
	self.texture_path_list = {"res/xui/vip.png", "res/xui/invest_plan.png"}
	self.config_tab = {
			{"common_ui_cfg", 5, {0}},
			{"common_ui_cfg", 1, {0}},
			{"common_ui_cfg", 2, {0}},
			{"vip_ui_cfg", 3, {0}},
		}
	self.title_img_path = ResPath.GetVipResPath("title_super_me")
end

function SuperAfterVipView:__delete()

end	

function SuperAfterVipView:ReleaseCallBack()
	
end

function SuperAfterVipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_superme.node, BindTool.Bind(self.OnPrayBindGoldClicked, self), true)
		for i=1,3 do
			XUI.AddClickEventListener(self.node_t_list["img_"..i].node, BindTool.Bind(self.OnBindGoldCTab, self,i), true)
		end
		self.node_t_list.img_level.node:setAnchorPoint(0.5, 1)
		self:OnBindGoldCTab(1)
		RichTextUtil.ParseRichText(self.node_t_list.txt_rich.node, Language.SuperMe.TxtRich, 24)
		XUI.SetRichTextVerticalSpace(self.node_t_list.txt_rich.node, 8)
		for i=1,2 do
			self.node_t_list["remind_flag"..i].node:setVisible(false)
		end
		self.node_t_list.img_level.node:setVisible(false)
		self.node_t_list.txt_num1.node:setVisible(false)
		XUI.SetLayoutImgsGrey(self.node_t_list.btn_superme.node, true, true)
	end
end

function SuperAfterVipView:OnClose()
	self:Close()
end

function SuperAfterVipView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:OnBindGoldCTab(1)
end

function SuperAfterVipView:OnPrayBindGoldClicked()
	
end

function SuperAfterVipView:OnBindGoldCTab(type)
	if type ~= 1 then
		if type == 2 then
			ViewManager.Instance:Open(ViewName.Privilege)
		elseif type == 3 then
			ViewManager.Instance:Open(ViewName.Vip)
		end
		self:Close()
	end
end

function SuperAfterVipView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SuperAfterVipView:ShowIndexCallBack(index)
	self:Flush(index)
end

function SuperAfterVipView:OnFlush(param_list, index)
	
end
