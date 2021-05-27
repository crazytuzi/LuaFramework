
AgentLoginView = AgentLoginView or BaseClass(BaseView)

function AgentLoginView:__init()
	self.close_mode = CloseMode.CloseDestroy
	self.zorder = COMMON_CONSTS.ZORDER_AGENT_LOGIN
	self.is_async_load = false
	self.texture_path_list[1] = "res/xui/login.png"

	self.config_tab = {
		{"login_ui_cfg", 3, {0}},
	}
end

function AgentLoginView:__delete()

end

function AgentLoginView:LoadCallBack()
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	self.root_node:setContentSize(cc.size(screen_w, screen_h))
	self.node_tree.layout_login.node:setPosition(screen_w / 2, screen_h / 2)

	--设置用户名输入框
	self.edit_id = self.node_tree.layout_login.edit_idinput_1.node
	self.edit_id:setFontSize(LOGIN_FONT_SIZE)
	self.edit_id:setFontColor(COLOR3B.G_W)
	local last_account = cc.UserDefault:getInstance():getStringForKey("last_account")
	self.edit_id:setText(last_account)

	--设置密码输入框
	self.edit_psd = self.node_tree.layout_login.edit_passwordinput_1.node
	self.edit_psd:setFontSize(LOGIN_FONT_SIZE)
	self.edit_psd:setFontColor(COLOR3B.G_W)
	self.edit_psd:setPlaceHolder("请输入7-16位登录密码")																		
	self.edit_psd:setInputFlag(0)
	local last_password = cc.UserDefault:getInstance():getStringForKey("last_password")																				
	self.edit_psd:setText(last_password)
	self.edit_zhuce_1 = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_1.node
	self.edit_zhuce_1:setFontSize(LOGIN_FONT_SIZE)
	self.edit_zhuce_1:setFontColor(COLOR3B.G_W)
	self.edit_zhuce_1:setPlaceHolder("请输入账号")
	
	self.edit_zhuce_2 = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_2.node
	self.edit_zhuce_2:setFontSize(LOGIN_FONT_SIZE)
	self.edit_zhuce_2:setFontColor(COLOR3B.G_W)
	self.edit_zhuce_2:setPlaceHolder("请输入7-16位登录密码")
	
	self.edit_zhuce_3 = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_3.node
	self.edit_zhuce_3:setFontSize(LOGIN_FONT_SIZE)
	self.edit_zhuce_3:setFontColor(COLOR3B.G_W)
	self.edit_zhuce_3:setPlaceHolder("请输入手机号")
	
	self.edit_zhuce_4 = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_4.node
	self.edit_zhuce_4:setFontSize(LOGIN_FONT_SIZE)
	self.edit_zhuce_4:setFontColor(COLOR3B.G_W)
	self.edit_zhuce_4:setPlaceHolder("请输入验证码")
	
	self.edit_zhuce_5 = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_5.node
	self.edit_zhuce_5:setFontSize(LOGIN_FONT_SIZE)
	self.edit_zhuce_5:setFontColor(COLOR3B.G_W)
	self.edit_zhuce_5:setPlaceHolder("请输入您的姓名")
	
	self.edit_zhuce_6 = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_6.node
	self.edit_zhuce_6:setFontSize(LOGIN_FONT_SIZE)
	self.edit_zhuce_6:setFontColor(COLOR3B.G_W)
	self.edit_zhuce_6:setPlaceHolder("请输入您的身份证号")
	
	self.edit_xiugai_1 = self.node_tree.layout_login.layout_login_xiugai.edit_xiugai_1.node
	self.edit_xiugai_1:setFontSize(LOGIN_FONT_SIZE)
	self.edit_xiugai_1:setFontColor(COLOR3B.G_W)
	self.edit_xiugai_1:setPlaceHolder("请输入账号")
	
	self.edit_xiugai_3 = self.node_tree.layout_login.layout_login_xiugai.edit_xiugai_3.node
	self.edit_xiugai_3:setFontSize(LOGIN_FONT_SIZE)
	self.edit_xiugai_3:setFontColor(COLOR3B.G_W)
	self.edit_xiugai_3:setPlaceHolder("请输入验证码")
	
	self.edit_xiugai_2 = self.node_tree.layout_login.layout_login_xiugai.edit_xiugai_2.node
	self.edit_xiugai_2:setFontSize(LOGIN_FONT_SIZE)
	self.edit_xiugai_2:setFontColor(COLOR3B.G_W)
	self.edit_xiugai_2:setPlaceHolder("请输入6-16位新登录密码")
	
	self.edit_bd_1 = self.node_tree.layout_login.layout_login_GB.layout_bd.layout_1.edit_bd_1.node
	self.edit_bd_1:setFontSize(LOGIN_FONT_SIZE)
	self.edit_bd_1:setFontColor(COLOR3B.G_W)
	self.edit_bd_1:setPlaceHolder("请输入账号")
	
	self.edit_bd_2 = self.node_tree.layout_login.layout_login_GB.layout_bd.layout_1.edit_bd_3.node
	self.edit_bd_2:setFontSize(LOGIN_FONT_SIZE)
	self.edit_bd_2:setFontColor(COLOR3B.G_W)
	self.edit_bd_2:setPlaceHolder("请输入6-16位登录密码")
	
	self.edit_bd_3 = self.node_tree.layout_login.layout_login_GB.layout_bd.layout_1.edit_bd_2.node
	self.edit_bd_3:setFontSize(LOGIN_FONT_SIZE)
	self.edit_bd_3:setFontColor(COLOR3B.G_W)
	self.edit_bd_3:setPlaceHolder("请输入手机号")
	
	self.edit_bd_4 = self.node_tree.layout_login.layout_login_GB.layout_bd.layout_1.edit_bd_4.node
	self.edit_bd_4:setFontSize(LOGIN_FONT_SIZE)
	self.edit_bd_4:setFontColor(COLOR3B.G_W)
	self.edit_bd_4:setPlaceHolder("请输入验证码")
	
	self.edit_hb_1 = self.node_tree.layout_login.layout_login_GB.layout_hb.layout_1.edit_gb_1.node
	self.edit_hb_1:setFontSize(LOGIN_FONT_SIZE)
	self.edit_hb_1:setFontColor(COLOR3B.G_W)
	self.edit_hb_1:setPlaceHolder("请输入账号")
	
	self.edit_hb_2 = self.node_tree.layout_login.layout_login_GB.layout_hb.layout_1.edit_gb_3.node
	self.edit_hb_2:setFontSize(LOGIN_FONT_SIZE)
	self.edit_hb_2:setFontColor(COLOR3B.G_W)
	self.edit_hb_2:setPlaceHolder("请输入验证码")
	
	self.edit_hb_3 = self.node_tree.layout_login.layout_login_GB.layout_hb.layout_1.edit_gb_2.node
	self.edit_hb_3:setFontSize(LOGIN_FONT_SIZE)
	self.edit_hb_3:setFontColor(COLOR3B.G_W)
	self.edit_hb_3:setPlaceHolder("请输入新手机号")
	
	self.edit_hb_4 = self.node_tree.layout_login.layout_login_GB.layout_hb.layout_1.edit_gb_4.node
	self.edit_hb_4:setFontSize(LOGIN_FONT_SIZE)
	self.edit_hb_4:setFontColor(COLOR3B.G_W)
	self.edit_hb_4:setPlaceHolder("请输入验证码")																								 
	self.node_tree.layout_login.layout_btn_denglu.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_btn_denglu.node, BindTool.Bind1(self.OnClickBtnDL, self), true)
	
	self.node_tree.layout_login.layout_btn_zhuce.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_btn_zhuce.node, BindTool.Bind1(self.OnclickBtnZC, self), true)
	
	self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.layout_yzm.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.layout_yzm.node, BindTool.Bind1(self.OnclickBtnyzm, self), true)


	self.node_tree.layout_login.layout_btn_login.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_btn_login.node, BindTool.Bind1(self.OnClickBtnLogin, self), true)

	if not IS_AUDIT_VERSION then
		local notic_btn = XUI.CreateButton(50, screen_h - 44, 0, 0, false, ResPath.GetLogin("login_btn_bg"), ResPath.GetLogin("login_btn_bg"), nil, true)
		self.node_tree.layout_login.node:addChild(notic_btn)
		notic_btn:setTitleFontName(COMMON_CONSTS.FONT)
		notic_btn:setTitleFontSize(24)
		notic_btn:setTitleText(Language.ViewName.Notice)
		notic_btn:setTitleColor(COLOR3B.G_W2)
		notic_btn:addClickEventListener(function ()
			ViewManager.Instance:OpenViewByDef(ViewDef.Notice)
		end)
	end
end

function AgentLoginView:OnClickBtnLogin()
	local account_name = self.edit_id:getText()
	local len = string.len(account_name)
	if len <= 0 or len > 1000 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.IdErro, true)
		return
	end

	cc.UserDefault:getInstance():setStringForKey("last_account", account_name)

	LoginController.Instance:LoginPlatSucc(account_name)
end
