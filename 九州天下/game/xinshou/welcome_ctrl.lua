-- require ("game/xinshou/welcome_data")
require ("game/xinshou/welcome_view")

WelcomeCtrl = WelcomeCtrl or BaseClass(BaseController)

function WelcomeCtrl:__init()
	if 	WelcomeCtrl.Instance ~= nil then
		print("[WelcomeCtrl] attempt to create singleton twice!")
		return
	end
	WelcomeCtrl.Instance = self
	self.view = WelcomeView.New()
	-- self.data = WelcomeData.New()
	-- GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function WelcomeCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	WelcomeCtrl.Instance = nil

end

function WelcomeCtrl:RegisterAllProtocols()

end

function WelcomeCtrl:MainuiOpen()
	-- if GameVoManager.Instance:GetMainRoleVo().level == 1 then
	-- 	self.view:Open()
		-- print(ToColorStr("打开欢迎面板，暂停自动任务", TEXT_COLOR.GREEN))
		-- MainUICtrl.Instance:SetIsAutoTaskState(false)
	-- end
end
