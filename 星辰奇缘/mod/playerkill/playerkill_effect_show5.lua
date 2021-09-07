-- --------------------------------
-- 擂台加星表现5
-- 流程 = 进阶
-- hosr
-- --------------------------------
PlayerkillEffectShow5 = PlayerkillEffectShow5 or BaseClass()

function PlayerkillEffectShow5:__init(parent)
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

	self.upgrade = PlayerkillUpgradeShow.New(self, function() self:EndShow() end)
end

function PlayerkillEffectShow5:__delete()
	if self.upgrade ~= nil then
		self.upgrade:DeleteMe()
		self.upgrade = nil
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

function PlayerkillEffectShow5:Show()
	self.upgrade:Show()
end

function PlayerkillEffectShow5:EndShow()
	self.parent:UpdateAllAfterShow()
end