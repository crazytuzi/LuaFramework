ExtremeVipView = ExtremeVipView or BaseClass(XuiBaseView)

function ExtremeVipView:__init()
	self.def_index = 1
 	self.texture_path_list[1] = 'res/xui/supervip.png'
 	self.texture_path_list[2] = 'res/xui/vip.png'
 	self.texture_path_list[3] = 'res/xui/extremevip.png'
 	self.texture_path_list[4] = 'res/xui/invest_plan.png'
 	self.title_img_path = ResPath.GetExtremePath("img_biaoti")
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		{"common_ui_cfg", 1, {0}},
		{"extremevip_ui_cfg", 1, {0}},
		{"extremevip_ui_cfg", 2, {0}},
		{"common_ui_cfg", 2, {0}},
	}	

end

function ExtremeVipView:__delete()
	
end

function ExtremeVipView:ReleaseCallBack()
	if self.svip_numbar then
		self.svip_numbar:DeleteMe()
		self.svip_numbar = nil
	end
end

function ExtremeVipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateNumBar()
		XUI.AddClickEventListener(self.node_t_list.btn_end.node, BindTool.Bind1(self.PanelClose, self))
		XUI.AddClickEventListener(self.node_t_list.btn_chongzhi.node, BindTool.Bind1(self.GetChargeData, self), true)
	end
	-- XUI.RichTextAddText(self.node_t_list.text_info.node, Language.SuperVip.Info, nil, 20, COLOR3B.WHITE)
	RichTextUtil.ParseRichText(self.node_t_list.text_giftinfo.node, Language.SuperVip.GiftInfo2, 20)
	--self.node_t_list.txt_qq.node:setVisible(false)


end

function ExtremeVipView:OpenCallBack()

end

function ExtremeVipView:CloseCallBack()

end

function ExtremeVipView:OnFlush(param_t, index)
	local spid_info = ExtremeVipData.Instance:GetSvipSpidInfo()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	self.svip_numbar:SetNumber(spid_info.vip_level)
	self.node_t_list.btn_chongzhi.node:setEnabled(level < spid_info.vip_level)
	self.node_t_list.txt_kefu_qq.node:setString(spid_info.kefu_qq and spid_info.kefu_qq or "")

	if level < spid_info.vip_level then
		local level_info = string.format(Language.SuperVip.LevelInfo, level)
		self.node_t_list.txt_vip_level.node:setString(level_info)
		self.node_t_list.txt_kefu_qq.node:setVisible(false)
		self.node_t_list.btn_copy.node:setVisible(false)
	else
		self.node_t_list.txt_change.node:setVisible(false)
		self.node_t_list.txt_vip_level.node:setVisible(false)
		self.node_t_list.txt_kefu_qq.node:setVisible(true)
		self.node_t_list.txt_kefu_qq.node:enableOutline(COLOR4B.BLACK, 1)
		self.node_t_list.btn_copy.node:setVisible(true)
		XUI.AddClickEventListener(self.node_t_list.txt_change.node, BindTool.Bind1(self.WriteqqInfo, self))
		XUI.AddClickEventListener(self.node_t_list.btn_copy.node, BindTool.Bind1(self.GetKefuInfo, self), true)
	end
	self.node_t_list.img_kefu.node:loadTexture(ResPath.GetBigPainting("evip_kefu_" .. spid_info.icon, true))

	--self.effec = RenderUnit.CreateEffect(11, self.node_t_list.txt_qq.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
	--self.effec:setScaleX(1.2)
	
	
end

-- 复制客服QQ
function ExtremeVipView:GetKefuInfo()
	PlatformAdapter.CopyStrToClipboard(self.node_t_list.txt_kefu_qq.node:getString())
end

function ExtremeVipView:WriteqqInfo()
	ViewManager.Instance:Open(ViewName.ExtremeVipCommonView)
end

function ExtremeVipView:CreateNumBar()
	local ph = self.ph_list.img_vip_level
	self.svip_numbar = NumberBar.New()
	self.svip_numbar:SetRootPath(ResPath.GetCommon("svip_"))
	self.svip_numbar:SetPosition(ph.x, ph.y)
	self.svip_numbar:SetSpace(-3)
	self.node_t_list.layout_svip.node:addChild(self.svip_numbar:GetView(), 90)
	self.svip_numbar:SetNumber(0)
end

function ExtremeVipView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ExtremeVipView:GetChargeData()
	ViewManager.Instance:Open(ViewName.ChargePlatForm)
end

function ExtremeVipView:PanelClose()
	self:Close()
end

