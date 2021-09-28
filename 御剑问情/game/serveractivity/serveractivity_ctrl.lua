require("game/serveractivity/serveractivity_data")

ServerActivityCtrl = ServerActivityCtrl or BaseClass(BaseController)

function ServerActivityCtrl:__init()
	if ServerActivityCtrl.Instance then
		print_error("[ServerActivityCtrl]:Attempt to create singleton twice!")
	end
	ServerActivityCtrl.Instance = self

	self.data = ServerActivityData.New()

	-- self.mainui_open_comlete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))
	
end

function ServerActivityCtrl:__delete()
	-- if self.mainui_open_comlete then
	-- 	GlobalEventSystem:UnBind(self.mainui_open_comlete)
	-- 	self.mainui_open_comlete = nil
	-- end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	ServerActivityCtrl.Instance = nil
end
