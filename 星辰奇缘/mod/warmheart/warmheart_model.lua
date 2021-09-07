WarmHeartModel = WarmHeartModel or BaseClass(BaseModel)


function WarmHeartModel:__init()
	self.mainWin = nil
	self.win = nil
	self.openArgs = args
  
end


-- function WarmHeartModel:OpenWindow(args)
-- 	self.openArgs = args

-- 	if self.win == nil then
-- 		self.win = RebateRewardWindow.New(self)
-- 	end
-- 	self.win:Open(args)
-- end

function WarmHeartModel:OpenMainWindow(args)
	if self.mainWin == nil then
		self.mainWin = WarmHeartMainWindow.New(self)
	end
	self.mainWin:Open(args)
end

-- function WarmHeartModel:CloseWindow()
-- 	WindowManager.Instance:CloseWindow(self.win)
-- end

function WarmHeartModel:CloseMainWindow()
	WindowManager.Instance:CloseWindow(self.mainWin)
end

function WarmHeartModel:__delete()
	if self.mainWin ~= nil then
		self.mainWin:DeleteMe()
	end

	if self.win ~= nil then
		self.win:DeleteMe()
	end
end