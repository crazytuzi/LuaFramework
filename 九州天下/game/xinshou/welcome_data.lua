WelcomeData = WelcomeData or BaseClass()

function WelcomeData:__init()
	if WelcomeData.Instance then
		print_error("[WelcomeData] 尝试创建第二个单例模式")
		return
	end
	WelcomeData.Instance = self


end