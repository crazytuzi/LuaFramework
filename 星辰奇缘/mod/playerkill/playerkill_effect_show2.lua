-- --------------------------------
-- 擂台加星表现2
-- 流程 = 加星->3连胜->进阶
-- hosr
-- --------------------------------
PlayerkillEffectShow2 = PlayerkillEffectShow2 or BaseClass()

function PlayerkillEffectShow2:__init(parent)
	self.parent = parent

	self.effectStarFly = self.parent.effectStarFly
	self.effectUpgrade = self.parent.effectUpgrade
	self.cycleIconObj = self.parent.cycleIconObj
	self.cycleIcon = self.parent.cycleIcon
	self.assetWrapper = self.parent.assetWrapper
	self.data = self.parent.data
	self.winList = self.parent.winList
	self.starsList = self.parent.starsList
	self.curr_star = PlayerkillManager.Instance.curr_star
	self.baseData = self.parent.baseData
	self.currData = PlayerkillManager.Instance.currData

	self.star = PlayerkillGetStarShow.New(self, function() self:ShowWin() end)
	self.win = PlayerkillWin3Show.New(self, function() self:ShowUpgrade() end)
	self.upgrade = PlayerkillUpgradeShow.New(self, function() self:EndShow() end)
end

function PlayerkillEffectShow2:__delete()
	if self.star ~= nil then
		self.star:DeleteMe()
		self.star = nil
	end

	if self.win ~= nil then
		self.win:DeleteMe()
		self.win = nil
	end

	if self.upgrade ~= nil then
		self.upgrade:DeleteMe()
		self.upgrade = nil
	end

	for i,v in ipairs(self.winList) do
		v:NoBoom()
	end

	self.effectStarFly = nil
	self.effectUpgrade = nil
	self.cycleIconObj = nil
	if self.cycleIcon ~= nil then
		self.cycleIcon.sprite = nil
		self.cycleIcon = nil
	end
	self.winList = nil
	self.starsList = nil
	self.baseData = nil
	self.assetWrapper = nil
end

function PlayerkillEffectShow2:Show()
	self.star:Show()
end

function PlayerkillEffectShow2:ShowWin()
	self.win:Show()
end

function PlayerkillEffectShow2:ShowUpgrade()
	self.upgrade:Show()
end

function PlayerkillEffectShow2:EndShow()
	self.parent:UpdateAllAfterShow()
end