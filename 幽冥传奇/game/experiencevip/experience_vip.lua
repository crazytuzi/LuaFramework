ExperienceVipView = ExperienceVipView or BaseClass(XuiBaseView)

function ExperienceVipView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/vip.png'
	self.texture_path_list[2] = 'res/xui/charge.png'
	self.config_tab  = {
		{"experience_vip_ui_cfg",1,{0},}
	}
	-- self:SetRootNodeOffPos({x = -136, y = -131})
end

function ExperienceVipView:__delete()
end	

function ExperienceVipView:ReleaseCallBack()

end

function ExperienceVipView:LoadCallBack(index, loaded_times)	
	XUI.AddClickEventListener(self.node_t_list.btn_vip.node, BindTool.Bind(self.OnClose, self), true)
	XUI.AddClickEventListener(self.node_t_list.onclose.node, BindTool.Bind(self.OnClose, self), true)
	RichTextUtil.ParseRichText(self.node_t_list.rich_txt_content.node, Language.Vip.ExperienceVIP, 22)
end	

function ExperienceVipView:OnFlush(params_t, index)
	

end	

function ExperienceVipView:OnClose()
	self:Close()
	ViewManager.Instance:Open(ViewName.Vip)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end
