RebateRewardModel = RebateRewardModel or BaseClass(BaseModel)


function RebateRewardModel:__init()
	self.mainWin = nil
	self.win = nil
	self.openArgs = args
  
end


function RebateRewardModel:OpenWindow(args)
	self.openArgs = args

	if self.win == nil then
		self.win = RebateRewardWindow.New(self)
	end
	self.win:Open(args)
end

function RebateRewardModel:OpenMainWindow(args)
	if self.mainWin == nil then
		self.mainWin = RebateRewardMainWindow.New(self)
	end
	self.mainWin:Open(args)
end

function RebateRewardModel:CloseWindow()
	WindowManager.Instance:CloseWindow(self.win)
end

function RebateRewardModel:CloseMainWindow()
	WindowManager.Instance:CloseWindow(self.mainWin)
end

function RebateRewardModel:__delete()
	if self.mainWin ~= nil then
		self.mainWin:DeleteMe()
	end

	if self.win ~= nil then
		self.win:DeleteMe()
	end
end