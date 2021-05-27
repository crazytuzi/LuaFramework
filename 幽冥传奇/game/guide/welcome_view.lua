
--------------------------------------------------
--新手欢迎界面
--------------------------------------------------
WelcomeView = WelcomeView or BaseClass(BaseView)
function WelcomeView:__init()
	if WelcomeView.Instance then
		ErrorLog("[WelcomeView] Attemp to create a singleton twice !")
	end
	WelcomeView.Instance = self
	self.is_modal = true
	self.background_opacity = 200
	self.config_tab  = {
		{"welcome_ui_cfg",1,{0},}
	}

	self.call_back = nil
end
function WelcomeView:__delete()
	WelcomeView.Instance = nil
end
function WelcomeView:LoadCallBack()
	self.startgame_btn = self.node_t_list.btn_startgame.node
	--self.img_logo = self.node_t_list.img_logo.node
	self.img_welcomebg = self.node_t_list.img_welcomebg.node

	
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	
	self.root_node:setTouchEnabled(true)
	XUI.AddClickEventListener(self.root_node, BindTool.Bind1(self.ClickHandler, self))
	XUI.AddClickEventListener(self.startgame_btn, BindTool.Bind1(self.ClickHandler, self))
	local size = self.startgame_btn:getContentSize()
	local path, name = ResPath.GetEffectUiAnimPath(1139)
	local startgame_btn_effc = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	startgame_btn_effc:setPosition(size.width / 2+3,  size.height / 2+6)
	self.startgame_btn:addChild(startgame_btn_effc, 99)
end

--欢迎界面的logo替换写到了opencallback中
function WelcomeView:ShowIndexCallBack()
	-- if self.img_logo ~= nil then
	-- 	local logo_path = ResPath.GetLogoPath()
	-- 	self.img_logo:loadTexture(logo_path, true)
	-- end
end

function WelcomeView:SetClickCallBack(call_back)
	self.call_back = call_back
end

function WelcomeView:GetGuideUI()
	if self.node_t_list.btn_startgame then
		return self.node_t_list.btn_startgame.node, BindTool.Bind1(self.ClickHandler, self)
	end
end

function WelcomeView:ClickHandler()
	if self.on_close then return end
	self.on_close = true
	if self.call_back ~= nil then
		self.call_back()
	end
	local fade_out = cc.FadeOut:create(0.3)
	local call_back = cc.CallFunc:create(function() 
		self:Close() 
		self.on_close = false
		end)
	local action = cc.Sequence:create(fade_out, call_back)
	self.root_node:runAction(action)
end
