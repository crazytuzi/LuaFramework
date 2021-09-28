LoginView =BaseClass()

-- 初始构造函数 .New()
function LoginView:__init()
	self:Config()
	self:InitEvent()
	self:LayoutUI()
end

-- 基本变量属性
function LoginView:Config()
	self.model = LoginModel:GetInstance()
	self.curPanel = nil
	self.roleCreatePanel = nil
	self.roleSelectPanel = nil
	self.loginPanel = nil
	self.createAccountPanel = nil
	self.accountManagerPanel = nil
	self.phoneBindPanel = nil
	self.tweener = nil
	self.tips = {}
end

-- 事件
function LoginView:InitEvent()
end

-- 布局
function LoginView:LayoutUI()
	if self.isInited then return end
	resMgr:AddUIAB("login")
	resMgr:AddUIAB("RoleCreateSelect")
	self.isInited = true
end

function LoginView:Close()
	local pane = self.curPanel
	if pane ~= nil then
		pane:Close()
		pane:Destroy()
		pane = nil
	end
end

--打开新版角色创建界面
function LoginView:OpenRoleCreatePanel()
	if not self.isInited then return end
	self:Close()
	local roleCreatePanel = RoleCreatePanel.New()
	if roleCreatePanel ~= nil then
		roleCreatePanel:Open()
		self.curPanel = roleCreatePanel
	end
end

--打开新版角色选择界面
function LoginView:OpenRoleSelectPanel()
	if not self.isInited then return end
	self:Close()
	local roleSelectPanel = RoleSelectPanel.New()
	if roleSelectPanel ~= nil then
		roleSelectPanel:Open()
		self.curPanel = roleSelectPanel
	end
end

function LoginView:OpenLoginPanel()
	if not self.isInited then return end
	self:Close()
	local p = LoginPanel.New()
	if p then
		p:Open()
		self.curPanel =p
	end
end

function LoginView:OpenCreateAccountPanel(isVisitorBind)
	if not self.isInited then return end
	self:Close()
	local p = CreateAccountPanel.New(isVisitorBind)
	if p then
		p:Open()
		self.curPanel =p
	end
end

function LoginView:OpenPhoneBindPanel()
	if not self.isInited then return end
	self:Close()
	local p =PhoneBindPanel.New()
	if p then
		p:Open()
		self.curPanel =p
	end
end

function LoginView:OpenAccountManagerPanel()
	if not self.isInited then return end
	self:Close()
	local p = AccountManagerPanel.New()
	if p then
		p:Open()
		self.curPanel =p
	end
end

function LoginView:OpenVisitorLoginPanel(accountData)
	if not self.isInited then return end
	self:Close()
	local p = VisitorLoginPanel.New(accountData)
	if p then
		p:Open()
		self.curPanel =p
	end
end

function LoginView:OpenResetPasswordPanel(accountData)
	if not self.isInited then return end
	self:Close()
	local p = ResetPasswordPanel.New(accountData)
	if p then
		p:Open()
		self.curPanel =p
	end
end

function LoginView:GetCurPanel()
	return self.curPanel
end

function LoginView:OpenServerSelectPanel(accountData)
	if not self.isInited then return end
	self:Close()
	local p = ServerSelectPanel.New(accountData)
	if p then
		p:Open()
		self.curPanel =p
	end
end

function LoginView:LoadRoleCreateSelectScene(callback)
	if self.isSceneLoaded then return end
	self.isSceneLoaded = true
	loaderMgr:LoadScene("2006",--"1003",
		function (s)
			callback()
			-- print("角色场景加载完成=>" ..s)
		end,
		function (v)
			-- print("角色场景加载进度=>".. v)
		end,
	true)
end

function LoginView:UnloadRoleCreateSelectScene()
	if self.isSceneLoaded then
		SceneManager.UnloadScene("2006")
		self.isSceneLoaded = false
	end
end

function LoginView:Win_FloatTip(accountData)
	if not resMgr:AddUIAB("Tips") then return end
	if TableIsEmpty(accountData) then return end
	if #self.tips > 10 then
		table.remove(self.tips, 1)
	end
	table.insert(self.tips, accountData)
	if not self.tweener then
		self.tweener = TweenUtils.TweenFloat(0, 1, 0.5, function() end)
		TweenUtils.OnComplete(self.tweener, function ()
			self:Float()
		end)
	end
end
function LoginView:Float()
	if #self.tips ~= 0 then
		local msgWin = LoginNameTips.New()
		if msgWin == nil then return end
		msgWin:Open()
		msgWin:SetMsg(table.remove(self.tips,1))
		self.tweener = TweenUtils.TweenFloat(0, 1, 0.5, function() end)
		TweenUtils.OnComplete(self.tweener, function ()
			self:Float()
		end)

	else
		self.tweener = nil
	end
end

--弹出游戏服正在维护的提示
function LoginView:PopUpMaintainTips(strContent)
	if strContent then
		UIMgr.Win_Alter("系统维护中" , strContent , "确定" , function() UnityEngine.Application.Quit() end)
	end	
end

function LoginView:PopUpReStartTips(strContent)
	if strContent then
		UIMgr.Win_Alter("系统维护中" , strContent , "确定" , function() 
			-- SceneModel:GetInstance():Clear()
			-- local scene = SceneController:GetInstance():GetScene()
			-- if scene then
			-- 	scene:Clear()
			-- end
			-- Network.ResetLinkTimes()
			-- self:OpenLoginPanel()

			UnityEngine.Application.Quit()
		 end)
	end
end

-- 销毁 .Destroy()
function LoginView:__delete()
	self.isSceneLoaded = false
	self.isInited = false
	self:Close()
	if self.roleCreatePanel then
		self.roleCreatePanel:Destroy()
		self.roleCreatePanel = nil
	end

	if self.roleSelectPanel then
		self.roleSelectPanel:Destroy()
		self.roleSelectPanel = nil
	end

	if self.loginPanel then
		self.loginPanel:Destroy()
		self.loginPanel = nil
	end

	if self.accountManagerPanel then
		self.accountManagerPanel:Destroy()
		self.accountManagerPanel = nil
	end

	if self.phoneBindPanel then
		self.phoneBindPanel:Destroy()
		self.phoneBindPanel = nil
	end

	if self.createAccountPanel then
		self.createAccountPanel:Destroy()
		self.createAccountPanel = nil
	end

	self.tweener = nil
end