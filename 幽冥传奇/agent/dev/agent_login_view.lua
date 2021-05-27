
AgentLoginView = AgentLoginView or BaseClass(XuiBaseView)

function AgentLoginView:__init()
	self.close_mode = CloseMode.CloseDestroy
	self.zorder = COMMON_CONSTS.ZORDER_AGENT_LOGIN
	self.is_async_load = false
	self.texture_path_list[1] = "res/xui/login.png"

	self.config_tab = {
		{"login_ui_cfg", 3, {0}},
	}
end


function AgentLoginView:__delete ()

end


function AgentLoginView:LoadCallBack (INPUT_VAR_0_)
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	self.root_node:setContentSize(cc.size(screen_w, screen_h))
	self.node_tree.layout_login.node:setPosition(screen_w /  2, screen_h /  2)
	
	self.is_fast = false
	
	self.edit_id = self.node_tree.layout_login.layout_login_normal.edit_idinput_1.node
	self.edit_id:setFontSize(LOGIN_FONT_SIZE)
	self.edit_id:setFontColor(COLOR3B.G_W)
	self.edit_id:setPlaceHolder("请输入账号")										   
	local last_account = cc.UserDefault:getInstance():getStringForKey("last_account")
	self.edit_id:setText(last_account)
	
	self.edit_psd = self.node_tree.layout_login.layout_login_normal.edit_passwordinput_1.node
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

	self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.layout_btn_login.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.layout_btn_login.node, BindTool.Bind1(self.Onclickzhuceenter, self), true)

	self.node_tree.layout_login.layout_login_normal.layout_btn_login.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_normal.layout_btn_login.node, BindTool.Bind1(self.OnClickBtnLogin, self), true)
	
	self.node_tree.layout_login.layout_login_normal.layout_btn_kszhuce.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_normal.layout_btn_kszhuce.node, BindTool.Bind1(self.OnclickBtnFastRegister, self), true)

	self.node_tree.layout_login.layout_login_normal.layout_btn_gb.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_normal.layout_btn_gb.node, BindTool.Bind1(self.OnclickBtngb, self), true)
	
	self.node_tree.layout_login.layout_login_normal.layout_btn_xiugai.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_normal.layout_btn_xiugai.node, BindTool.Bind1(self.OnclickBtnxiugai, self), true)
	
	self.node_tree.layout_login.layout_login_xiugai.layout_btn_xiugai_login.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_xiugai.layout_btn_xiugai_login.node, BindTool.Bind1(self.Onclickenterxiugai, self), true)
	
	self.node_tree.layout_login.layout_login_xiugai.layout_yanzheng_xiugai.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_xiugai.layout_yanzheng_xiugai.node, BindTool.Bind1(self.Onclickxiugaiyzm, self), true)
	
	self.node_tree.layout_login.layout_login_fastlogin.layout_bdsj.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_fastlogin.layout_bdsj.node, BindTool.Bind1(self.Onclickbdsj, self), true)
	
	self.node_tree.layout_login.layout_login_fastlogin.layout_btn_jinru.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_fastlogin.layout_btn_jinru.node, BindTool.Bind1(self.OnclickEnterFast, self), true)
	
	self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.layout_yhxy.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.layout_yhxy.node, BindTool.Bind1(self.Onclickyhxy, self), true)
	
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_yhxy.btn_fhdl.node, BindTool.Bind1(self.Onclickcloseyhxy, self), true)
	
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_fastlogin.btn_fh.node, BindTool.Bind1(self.Onclickfh, self), true)
	
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_xiugai.btn_fh.node, BindTool.Bind1(self.Onclickfh, self), true)
	
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_GB.btn_fh.node, BindTool.Bind1(self.Onclickfh, self), true)
	
	self.node_tree.layout_login.layout_login_GB.layout_btn_bd.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_GB.layout_btn_bd.node, BindTool.Bind1(self.Onclickyhbd, self), true)
	
	self.node_tree.layout_login.layout_login_GB.layout_btn_hb.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_GB.layout_btn_hb.node, BindTool.Bind1(self.Onclickyhhb, self), true)
	
	self.node_tree.layout_login.layout_login_GB.layout_bd.layout_1.layout_yzm_bd.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_GB.layout_bd.layout_1.layout_yzm_bd.node, BindTool.Bind1(self.Onclickbdyzm, self), true)
	
	self.node_tree.layout_login.layout_login_GB.layout_hb.layout_1.layout_yzm_gb.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_GB.layout_hb.layout_1.layout_yzm_gb.node, BindTool.Bind1(self.Onclickhbyzmold, self), true)
	
	self.node_tree.layout_login.layout_login_GB.layout_hb.layout_1.layout_yzm_gb_2.node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_GB.layout_hb.layout_1.layout_yzm_gb_2.node, BindTool.Bind1(self.Onclickhbyzmnew, self), true)
	
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_GB.layout_bd.layout_1.layout_btn_bd.node, BindTool.Bind1(self.Onclickqrbd, self), true)
	
	XUI.AddClickEventListener(self.node_tree.layout_login.layout_login_GB.layout_hb.layout_1.layout_btn_gaibang.node, BindTool.Bind1(self.Onclickqrgb, self), true)
	
	local yhxy = self.node_tree.layout_login.layout_yhxy.layout_img.node
	yhxy:removeFromParent()
	self.scroll_node = self.node_tree.layout_login.layout_yhxy.scroll_view.node
	self.scroll_node:addChild(yhxy, 100, 100)
	
	local scroll_size = self.scroll_node:getContentSize()
	local inner_h = math.max(yhxy:getContentSize().height + 20, scroll_size.height)
	self.scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	yhxy:setPosition(scroll_size.width / 2, inner_h/2+30)
	self.scroll_node:jumpToTop()
	
	local zhuce = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.node
	zhuce:removeFromParent()
	self.scroll_node_2= self.node_tree.layout_login.layout_login_zhuce.scroll_view.node
	self.scroll_node_2:addChild(zhuce, 100, 100)
	
	local scroll_size = self.scroll_node_2:getContentSize()
	local inner_h = math.max(zhuce:getContentSize().height + 20, scroll_size.height)
	self.scroll_node_2:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	zhuce:setPosition(scroll_size.width / 2, inner_h/2)
	self.scroll_node_2:jumpToTop()
	
	local hb = self.node_tree.layout_login.layout_login_GB.layout_hb.layout_1.node
	hb:removeFromParent()
	self.scroll_node_3 = self.node_tree.layout_login.layout_login_GB.layout_hb.scroll_view.node
	self.scroll_node_3:addChild(hb, 100, 100)
	
	local scroll_size = self.scroll_node_3:getContentSize()
	local inner_h = math.max(hb:getContentSize().height + 20, scroll_size.height)
	self.scroll_node_3:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	hb:setPosition(scroll_size.width / 2, inner_h/2)
	self.scroll_node_3:jumpToTop()
	
	local bd = self.node_tree.layout_login.layout_login_GB.layout_bd.layout_1.node
	bd:removeFromParent()
	self.scroll_node_4 = self.node_tree.layout_login.layout_login_GB.layout_bd.scroll_view.node
	self.scroll_node_4:addChild(bd, 100, 100)
	
	local scroll_size = self.scroll_node_4:getContentSize()
	local inner_h = math.max(bd:getContentSize().height + 20, scroll_size.height)
	self.scroll_node_4:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	bd:setPosition(scroll_size.width / 2, inner_h/2)
	self.scroll_node_4:jumpToTop()
	
	self:setPageState(1)
end

function AgentLoginView:ScreenCut()
	--[[local fileName = "IdAndPw.png"
	cc.utils:captureScreen(self.afterCaptured, fileName)--]]
end

function AgentLoginView:afterCaptured(succeed, outputFile)
	if succeed then
		SysMsgCtrl.Instance:ErrorRemind("截图已保存", true)
	else
		SysMsgCtrl.Instance:ErrorRemind("截图失败", true)
	end
end

function AgentLoginView:setPageState(index)
	self.node_tree.layout_login.layout_login_normal.node:setVisible(index == 1)
	self.node_tree.layout_login.layout_login_zhuce.node:setVisible(index == 2)
	self.node_tree.layout_login.layout_login_xiugai.node:setVisible(index == 3)
	self.node_tree.layout_login.layout_login_fastlogin.node:setVisible(index == 4)
	self.node_tree.layout_login.layout_login_GB.node:setVisible(index == 5)
	self.node_tree.layout_login.layout_yhxy.node:setVisible(false)
	if index == 1 or index == 2 then
		self:setTitleState(index)
	end
end

function AgentLoginView:setTitleState(index)
	self.node_tree.layout_login.layout_btn_denglu.img_dl_1.node:setVisible(index == 2)
	self.node_tree.layout_login.layout_btn_denglu.img_dl_2.node:setVisible(index == 1)
	self.node_tree.layout_login.layout_btn_denglu.img_dl_flag.node:setVisible(index == 1)
	
	self.node_tree.layout_login.layout_btn_zhuce.img_zc_1.node:setVisible(index == 1)
	self.node_tree.layout_login.layout_btn_zhuce.img_zc_2.node:setVisible(index == 2)
	self.node_tree.layout_login.layout_btn_zhuce.img_zc_flag.node:setVisible(index == 2)
	
	self:InitCurPage()
end

function AgentLoginView:setHBState(index)
	
	self.node_tree.layout_login.layout_login_GB.layout_btn_bd.img_bd_1.node:setVisible(index == 2)
	self.node_tree.layout_login.layout_login_GB.layout_btn_bd.img_bd_2.node:setVisible(index == 1)
	self.node_tree.layout_login.layout_login_GB.layout_btn_bd.img_bd_flag.node:setVisible(index == 1)
	
	self.node_tree.layout_login.layout_login_GB.layout_btn_hb.img_zc_1.node:setVisible(index == 1)
	self.node_tree.layout_login.layout_login_GB.layout_btn_hb.img_zc_2.node:setVisible(index == 2)
	self.node_tree.layout_login.layout_login_GB.layout_btn_hb.img_zc_flag.node:setVisible(index == 2)
	
	self.node_tree.layout_login.layout_login_GB.layout_bd.node:setVisible(index == 1)
	self.node_tree.layout_login.layout_login_GB.layout_hb.node:setVisible(index == 2)
	
	self:InitCurPage()
end

function AgentLoginView:InitCurPage()
	self.edit_bd_3:setText("")
	self.edit_bd_4:setText("")
	self.edit_hb_2:setText("")
	self.edit_hb_3:setText("")
	self.edit_hb_4:setText("")
	self.edit_zhuce_3:setText("")
	self.edit_zhuce_4:setText("")
	self.edit_zhuce_5:setText("")
	self.edit_zhuce_6:setText("")
	self.scroll_node_2:jumpToTop()
	self.scroll_node_3:jumpToTop()
	self.scroll_node_4:jumpToTop()
end

function AgentLoginView:OnClickBtnDL()
	self:setPageState(1)
end

function AgentLoginView:OnclickBtnZC()
	self:setPageState(2)
end
function AgentLoginView:OnclickBtnRegister()
	local account_name = self.edit_id:getText()
	local password = self.edit_psd:getText()
	
	local len_acc = string.len(account_name)
	local len_pwd = string.len(password)
	
	if len_acc <= 6 or len_acc > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.EditName, true)
		return
	end
	
	if len_pwd <= 6 or len_pwd > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.PsdLenErro, true)
		return
	end
	
	if (account_name == "" or password=="")then
		SysMsgCtrl.Instance:ErrorRemind("请输入账号或密码！", true)
		return
	end
	--UserVo.plat_pwd = password
	--cc.UserDefault:getInstance():setStringForKey("last_account", account_name)
	LoginController.Instance:accountSignLogin(account_name, password)
end


function AgentLoginView:OnClickBtnLogin()
	local account_name = self.edit_id:getText()
	local password = self.edit_psd:getText()
	
	local len_acc = string.len(account_name)
	local len_pwd = string.len(password)
	--print(account_name)
	--print(password)
	if len_acc <= 6 or len_acc > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.EditName, true)
		return
	end
	
	if len_pwd <= 6 or len_pwd > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.PsdLenErro, true)
		return
	end
	
	if (account_name == "" or password=="")then
		SysMsgCtrl.Instance:ErrorRemind("请输入账号或密码！", true)
		return
	end
	
	--UserVo.plat_pwd = password
	--cc.UserDefault:getInstance():setStringForKey("last_account", account_name)
	--LoginController.Instance:SendLoginCallBack(account_name, password)
	LoginController.Instance:accountSignLogin(account_name, password)
end

function AgentLoginView:OnclickBtnFastRegister()
	LoginController.Instance:accountSignFast()
end

function AgentLoginView:setFastState(account,pw)
	print(account,pw)
	self.node_tree.layout_login.layout_login_fastlogin.txt_id.node:setString(account)
	self.node_tree.layout_login.layout_login_fastlogin.txt_pw.node:setString(pw)
	self.is_fast = true
	self:setPageState(4)
	self:ScreenCut()
end

function AgentLoginView:OnclickEnterFast()
	local id = self.node_tree.layout_login.layout_login_fastlogin.txt_id.node:getString()
	local pw = self.node_tree.layout_login.layout_login_fastlogin.txt_pw.node:getString()

	local len_acc = string.len(id)
	local len_pwd = string.len(pw)
	--print(account_name)
	--print(password)
	if len_acc <= 6 or len_acc > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.EditName, true)
		return
	end
	
	if len_pwd <= 6 or len_pwd > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.PsdLenErro, true)
		return
	end
	
	if (id == "" or pw=="")then
		SysMsgCtrl.Instance:ErrorRemind("请输入账号或密码！", true)
		return
	end
	
	--UserVo.plat_pwd = password
	--cc.UserDefault:getInstance():setStringForKey("last_account", account_name)
	--LoginController.Instance:SendLoginCallBack(account_name, password)
	print(id,pw)
	LoginController.Instance:accountSignLogin(id, pw)
end

function AgentLoginView:Onclickbdsj()
	local id_node = self.node_tree.layout_login.layout_login_fastlogin.txt_id.node
	local pw_node = self.node_tree.layout_login.layout_login_fastlogin.txt_pw.node
	
	self:setBangDingIdAndPw(id_node:getString(),pw_node:getString())
end

function AgentLoginView:setBangDingIdAndPw(id,pw)
	self.edit_bd_1:setText(id)
	
	self.edit_bd_2:setText(pw)
	
	self:setHBState(1)
	self:setPageState(5)
end

function AgentLoginView:OnclickBtnxiugai()
	self:setPageState(3)
end

function AgentLoginView:OnclickBtnyzm() -- 注册界面验证码
	local mobile = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_3.node:getText()
	print(mobile)
	LoginController.Instance:getCodeMobile(mobile, 1)
end

function AgentLoginView:Onclickxiugaiyzm() -- 修改界面验证码
	local account_name = self.node_tree.layout_login.layout_login_xiugai.edit_xiugai_1.node:getText()
	local password = self.node_tree.layout_login.layout_login_xiugai.edit_xiugai_2.node:getText()
	if (account_name == "" or password=="")then
		SysMsgCtrl.Instance:ErrorRemind("请输入账号或密码！", true)
		return
	end
	LoginController.Instance:getCodeMobile(account_name, 2)
end

function AgentLoginView:Onclickenterxiugai() --修改界面
	local account_name = self.node_tree.layout_login.layout_login_xiugai.edit_xiugai_1.node:getText()
	local password = self.node_tree.layout_login.layout_login_xiugai.edit_xiugai_2.node:getText()
	
	local len_acc = string.len(account_name)
	local len_pwd = string.len(password)
	
	if len_acc <= 6 or len_acc > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.EditName, true)
		return
	end
	
	if len_pwd <= 6 or len_pwd > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.PsdLenErro, true)
		return
	end
	
	if (account_name == "" or password=="")then
		SysMsgCtrl.Instance:ErrorRemind("请输入账号或密码！", true)
		return
	end
	
	local yzm = self.node_tree.layout_login.layout_login_xiugai.edit_xiugai_3.node:getText()
	if yzm == "" then
		SysMsgCtrl.Instance:ErrorRemind("请输入验证码！", true)
		return
	end
	LoginController.Instance:accountSignChange(account_name, password, yzm)
end

function AgentLoginView:setFastFlag()
	self.is_fast = false
	--[[local account_name = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_1.node:getText()
	local password = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_2.node:getText()
	self.node_tree.layout_login.layout_login_fastlogin.txt_id.node:setString(account_name)
	self.node_tree.layout_login.layout_login_fastlogin.txt_pw.node:setString(password)--]]
	self:setPageState(1)
end

function AgentLoginView:Onclickzhuceenter() --注册界面进入游戏
	local account_name = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_1.node:getText()
	local password = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_2.node:getText()
	local mobile = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_3.node:getText()
	local code = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_4.node:getText()
	local real_name = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_5.node:getText()
	local id_card = self.node_tree.layout_login.layout_login_zhuce.layout_zc_panel.edit_zhuce_6.node:getText()
	
	local len_acc = string.len(account_name)
	local len_pwd = string.len(password)
	
	if len_acc <= 6 or len_acc > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.EditName, true)
		return
	end
	
	if len_pwd <= 6 or len_pwd > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.PsdLenErro, true)
		return
	end
	
	if (account_name == "" or password=="")then
		SysMsgCtrl.Instance:ErrorRemind("请输入账号或密码！", true)
		return
	end
	
--	if not self.is_fast then
	LoginController.Instance:accountSignNew(account_name, password, mobile, code,real_name,id_card)
	--[[else
		LoginController.Instance:accountSignBind(account_name, mobile, code)
	end--]]
end

function AgentLoginView:ChangeAndLogin()
	local account_name = self.node_tree.layout_login.layout_login_xiugai.edit_xiugai_1.node:getText()
	local password = self.node_tree.layout_login.layout_login_xiugai.edit_xiugai_2.node:getText()
	self.node_tree.layout_login.layout_login_fastlogin.txt_id.node:setString(account_name)
	self.node_tree.layout_login.layout_login_fastlogin.txt_pw.node:setString(password)
	self.is_fast = false
	self:setPageState(4)
	--LoginController.Instance:accountSignLogin(account_name, password)
end

function AgentLoginView:Onclickcloseyhxy()
	self.node_tree.layout_login.layout_yhxy.node:setVisible(false)
end

function AgentLoginView:Onclickyhxy() --点击用户协议
	self.node_tree.layout_login.layout_yhxy.node:setVisible(true)
end

function AgentLoginView:Onclickfh()
	self:setPageState(1)
end

function AgentLoginView:OnclickBtngb()
	self:setHBState(1)
	self:setPageState(5)
end

function AgentLoginView:Onclickyhbd()
	self:setHBState(1)
end

function AgentLoginView:Onclickyhhb()
	self:setHBState(2)
end

function AgentLoginView:Onclickbdyzm()
	
	local mb = self.edit_bd_3:getText()
	if mb == "" then
		SysMsgCtrl.Instance:ErrorRemind("请输入手机号", true)
		return
	end
	
	local len = string.len(mb)
	if len ~= 11 then
		SysMsgCtrl.Instance:ErrorRemind("请输入正确的手机号", true)
		return
	end
	LoginController.Instance:getCodeMobile(mb, 1)
end

function AgentLoginView:Onclickqrbd()
	local account = self.edit_bd_1:getText()
	local pw = self.edit_bd_2:getText()
	local mb = self.edit_bd_3:getText()
	local yzm = self.edit_bd_4:getText()
	
	if (account == "" or pw=="")then
		SysMsgCtrl.Instance:ErrorRemind("请输入账号或密码！", true)
		return
	end
	
	local len_acc = string.len(account)
	local len_pwd = string.len(pw)
	--print(account_name)
	--print(password)
	if len_acc <= 6 or len_acc > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.EditName, true)
		return
	end
	
	if len_pwd <= 6 or len_pwd > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.PsdLenErro, true)
		return
	end
	
	if mb == "" then
		SysMsgCtrl.Instance:ErrorRemind("请输入手机号", true)
		return
	end

	local len = string.len(mb)
	if len ~= 11 then
		SysMsgCtrl.Instance:ErrorRemind("请输入正确的手机号", true)
		return
	end
	
	if yzm == "" then
		SysMsgCtrl.Instance:ErrorRemind("请输入验证码", true)
		return
	end
	
	LoginController.Instance:accountSignBind(account, mb, yzm)
end

function AgentLoginView:Onclickqrgb()
	local account = self.edit_hb_1:getText()
	local oldyzm = self.edit_hb_2:getText()
	local newmb = self.edit_hb_3:getText()
	local newyzm = self.edit_hb_4:getText()
	
	if account == ""then
		SysMsgCtrl.Instance:ErrorRemind("请输入账号", true)
		return
	end
	
	local len_acc = string.len(account)
	--print(account_name)
	--print(password)
	if len_acc <= 6 or len_acc > 16 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.EditName, true)
		return
	end
	
	if oldyzm == "" then
		SysMsgCtrl.Instance:ErrorRemind("请输入验证码", true)
		return
	end

	if newmb == "" then
		SysMsgCtrl.Instance:ErrorRemind("请输入改绑手机号", true)
		return
	end
	
	local len = string.len(newmb)
	if len ~= 11 then
		SysMsgCtrl.Instance:ErrorRemind("请输入正确的手机号", true)
		return
	end
	
	if newyzm == "" then
		SysMsgCtrl.Instance:ErrorRemind("请输入验证码", true)
		return
	end
	
	LoginController.Instance:accountSignChangeBind(account,oldyzm, newmb, newyzm)
end

function AgentLoginView:Onclickhbyzmold()
	local account = self.edit_hb_1:getText()
	if account == "" then
		SysMsgCtrl.Instance:ErrorRemind("请输入账号", true)
		return
	end
	
	LoginController.Instance:getCodeMobile(account, 2)
end

function AgentLoginView:Onclickhbyzmnew()
	local mb = self.edit_hb_3:getText()
	if mb == "" then
		SysMsgCtrl.Instance:ErrorRemind("请输入手机号", true)
		return
	end
	
	local len = string.len(mb)
	if len ~= 11 then
		SysMsgCtrl.Instance:ErrorRemind("请输入正确的手机号", true)
		return
	end
	
	LoginController.Instance:getCodeMobile(mb, 1)
end

function AgentLoginView:setInitPage()
	self:setPageState(1)
end
