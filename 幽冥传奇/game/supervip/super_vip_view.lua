SuperVipView = SuperVipView or BaseClass(XuiBaseView)

function SuperVipView:__init()
	self.def_index = 1
 	self.texture_path_list[1] = 'res/xui/supervip.png'
 	self.texture_path_list[2] = 'res/xui/vip.png'
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		
		{"supervip_ui_cfg", 1, {0}},
		{"supervip_ui_cfg", 2, {0}},
	}	

end

function SuperVipView:__delete()
	
end

function SuperVipView:ReleaseCallBack()
	if self.svip_numbar then
		self.svip_numbar:DeleteMe()
		self.svip_numbar = nil
	end
end

function SuperVipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateNumBar()
		XUI.AddClickEventListener(self.node_t_list.btn_end.node, BindTool.Bind1(self.PanelClose, self))
		XUI.AddClickEventListener(self.node_t_list.btn_chongzhi.node, BindTool.Bind1(self.GetChargeData, self), true)
	end
	XUI.RichTextAddText(self.node_t_list.text_info.node, Language.SuperVip.Info, nil, 20, COLOR3B.WHITE)
	RichTextUtil.ParseRichText(self.node_t_list.text_giftinfo.node, Language.SuperVip.GiftInfo, 20)
	self.node_t_list.txt_qq.node:setVisible(false)


end

function SuperVipView:OpenCallBack()

end

function SuperVipView:CloseCallBack()

end

function SuperVipView:OnFlush(param_t, index)
	local spid_info = SuperVipData.Instance:GetSvipSpidInfo()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	self.svip_numbar:SetNumber(spid_info.vip_level)
	self.node_t_list.btn_chongzhi.node:setEnabled(level < spid_info.vip_level)
	if level < spid_info.vip_level then
		local level_info = string.format(Language.SuperVip.LevelInfo, level)
		self.node_t_list.txt_vip_level.node:setString(level_info)
	else
		self.node_t_list.txt_qq.node:setVisible(true)
		RichTextUtil.ParseRichText(self.node_t_list.txt_qq.node, spid_info.kefu_qq, 26, COLOR3B.WHITE)
		XUI.RichTextSetCenter(self.node_t_list.txt_qq.node)
		self.node_t_list.txt_vip_level.node:setVisible(false)
		self.node_t_list.txt_change.node:setVisible(false)
	end
	self.node_t_list.img_kefu.node:loadTexture(ResPath.GetBigPainting("svip_kefu_" .. spid_info.icon, true))

	self.effec = RenderUnit.CreateEffect(11, self.node_t_list.txt_qq.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
	self.effec:setScaleX(1.2)
	
	
end

function SuperVipView:CreateNumBar()
	local ph = self.ph_list.img_vip_level
	self.svip_numbar = NumberBar.New()
	self.svip_numbar:SetRootPath(ResPath.GetCommon("svip_"))
	self.svip_numbar:SetPosition(ph.x, ph.y)
	self.svip_numbar:SetSpace(-3)
	self.node_t_list.layout_svip.node:addChild(self.svip_numbar:GetView(), 90)
	self.svip_numbar:SetNumber(0)
end

function SuperVipView:ShowIndexCallBack(index)
	self:Flush(index)
end

function SuperVipView:GetChargeData()
	ViewManager.Instance:Open(ViewName.ChargePlatForm)
end

function SuperVipView:PanelClose()
	self:Close()
end

