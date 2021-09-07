-- --------------------------------
-- 擂台加星表现4
-- 流程 = 加星->3连胜->加星
-- hosr
-- --------------------------------
PlayerkillEffectShow4 = PlayerkillEffectShow4 or BaseClass()

function PlayerkillEffectShow4:__init(parent)
	self.parent = parent
	self.effectStarFly = self.parent.effectStarFly
	self.winList = self.parent.winList
	self.starsList = self.parent.starsList
	self.curr_star = PlayerkillManager.Instance.curr_star
	self.baseData = self.parent.baseData
	self.currData = PlayerkillManager.Instance.currData

	self.star = PlayerkillGetStarShow.New(self, function() self:ShowWin() end)
	self.win = PlayerkillWin3Show.New(self, function() self:ShowStar2() end)
end

function PlayerkillEffectShow4:__delete()
	if self.star ~= nil then
		self.star:DeleteMe()
		self.star = nil
	end

	if self.win ~= nil then
		self.win:DeleteMe()
		self.win = nil
	end

	for i,v in ipairs(self.winList) do
		v:NoBoom()
	end
	self.winList = nil
	self.starsList = nil
	self.baseData = nil
end

function PlayerkillEffectShow4:Show()
	self:ShowStar(function() self:ShowWin() end)
end

function PlayerkillEffectShow4:ShowStar(callback, is3win)
	self.star.callback = callback
	self.star:Show(is3win)
end

function PlayerkillEffectShow4:ShowStar2()
	self:ShowStar(function() self:EndShow() end, true)
end

function PlayerkillEffectShow4:ShowWin()
	self.win:Show()
end

function PlayerkillEffectShow4:EndShow()
	self.parent:UpdateAllAfterShow()
end