AgentLoginView = AgentLoginView or BaseClass(XuiBaseView)

function AgentLoginView:__init()
	self.close_mode = CloseMode.CloseDestroy
	self.zorder = COMMON_CONSTS.ZORDER_AGENT_LOGIN
	
	self.texture_path_list[1] = "res/xui/login.png"
end

function AgentLoginView:__delete()

end

function AgentLoginView:LoadCallBack()
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	self.root_node:setContentSize(cc.size(screen_w, screen_h))

	--logo
	local logo = XUI.CreateImageView(screen_w / 2, 500, ResPath.GetLogoPath(), false)
	self.root_node:addChild(logo, 0, 0)
	
	local img_btn_bg = XImage:create(ResPath.GetLogin("login_btn_bg"), true)
	local btn_size = img_btn_bg:getContentSize()
	img_btn_bg:setPosition(btn_size.width / 2, btn_size.height / 2)

	local img_btn_text = XUI.CreateImageView(btn_size.width / 2, btn_size.height / 2, ResPath.GetLogin("font_login"), true)

	local layout_btn = XUI.CreateLayout(screen_w / 2, screen_h / 3, btn_size.width, btn_size.height)
	layout_btn:addChild(img_btn_bg, 0)
	layout_btn:addChild(img_btn_text, 1)

	self.root_node:addChild(layout_btn)

	XUI.AddClickEventListener(layout_btn, BindTool.Bind1(self.OnClickBtnLogin, self), true)

	AgentAdapter:Init()
	self:OnClickBtnLogin()
end

function AgentLoginView:OnClickBtnLogin()
	local function callback(account_name)
		LoginController.Instance:LoginPlatSucc(account_name)
	end
	local switch_account_data =  AdapterToLua:getInstance():getDataCache("SWITCH_ACCOUNT_DATA")
	AgentAdapter:Login(callback,switch_account_data)
end