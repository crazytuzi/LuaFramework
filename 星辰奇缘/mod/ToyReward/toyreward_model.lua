ToyRewardModel = ToyRewardModel or BaseClass(BaseModel)

function ToyRewardModel:__init()
	self.mgr = ToyRewardModel.Instance
end



function ToyRewardModel:OpenWindow()
	if self.mainWin == nil then
		self.mainWin = ToyRewardWindow.New(self)
    end

    self.mainWin:Open()
end

function ToyRewardModel:CloseWin()
	WindowManager.Instance:CloseWindow(self.mainWin)
end