require("game/screen_shot/screen_shot_view")

ScreenShotCtrl = ScreenShotCtrl or BaseClass(BaseController)

function ScreenShotCtrl:__init()
	if ScreenShotCtrl.Instance ~= nil then
		print_error("[ScreenShotCtrl] attempt to create singleton twice!")
		return
	end
	ScreenShotCtrl.Instance = self
	-- self.view = ScreenShotView.New()
end

function ScreenShotCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	ScreenShotCtrl.Instance = nil
end

function ScreenShotCtrl:OpenScreenView(path, load_callback)
	-- self.view:SetLoadCallBack(load_callback)
	-- self.view:Open()
	-- self.view:Flush("all", {path})
end