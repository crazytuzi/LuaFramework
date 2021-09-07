SignRewardModel = SignRewardModel or BaseClass(BaseModel)

function SignRewardModel:__init()

	self.mgr = SignRewardModel.Instance
end


function SignRewardModel:OpenWindow(args)
	if self.mainWin == nil then
		self.mainWin = SignRewardWindow.New(self)
	end

	self.mainWin:Open(args)
end

function SignRewardModel:CloseWin()
	WindowManager.Instance:CloseWindow(self.mainWin)
end