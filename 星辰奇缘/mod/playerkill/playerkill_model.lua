-- -------------------------
-- 英雄擂台
-- hosr
-- -------------------------

PlayerkillModel = PlayerkillModel or BaseClass(BaseModel)

function PlayerkillModel:__init()
end

function PlayerkillModel:OpenMainWindow(args)
	if self.mainWindow == nil then
		self.mainWindow = PlayerkillWindow.New(self)
	end
    if self.mainWindow.minimize then
        self:CloseMinimizePanel()
        self:MaximizeMainWindow()
    else
		self.mainWindow:Show(args)
	end
end

function PlayerkillModel:CloseMainWindow(args)
	if self.mainWindow ~= nil then
		self.mainWindow:DeleteMe()
		self.mainWindow = nil
	end
	-- self.mainWindow:Show(args)
end

function PlayerkillModel:MaximizeMainWindow()
    if self.mainWindow ~= nil then
        self.mainWindow:MaximizeMainWindow()
    end
end

function PlayerkillModel:OpenNo1Show(args)
	if self.no1show == nil then
		self.no1show = PlayerkillShowBestPanel.New(self)
	end
	self.no1show:Show(args)
end

function PlayerkillModel:CloseNo1Show()
	if self.no1show ~= nil then
		self.no1show:DeleteMe()
		self.no1show = nil
	end
end

function PlayerkillModel:OpenReward(args)
	if self.reward == nil then
		self.reward = PlayerkillRewardPanel.New(self)
	end
	self.reward:Show(args)
end

function PlayerkillModel:CloseReward()
	if self.reward ~= nil then
		self.reward:DeleteMe()
		self.reward = nil
	end
end

function PlayerkillModel:OpenSettle(args)
	if self.settle == nil then
		self.settle = PlayerkillSettlementWindow.New(self)
	end
	self.settle:Open(args)
end

function PlayerkillModel:CloseSettle()
	if self.settle ~= nil then
		self.settle:DeleteMe()
		self.settle = nil
	end
end

function PlayerkillModel:OpenMinimizePanel()
	if self.minimizePanel == nil then
		self.minimizePanel = PlayerkillMinimizePanel.New(self)
	end
	self.minimizePanel:Show()
end

function PlayerkillModel:CloseMinimizePanel()
	if self.minimizePanel ~= nil then
		self.minimizePanel:DeleteMe()
		self.minimizePanel = nil
	end
end
