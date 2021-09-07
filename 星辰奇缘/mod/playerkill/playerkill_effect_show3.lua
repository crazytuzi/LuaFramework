-- --------------------------------
-- 擂台加星表现3
-- 流程 = 加星
-- hosr
-- --------------------------------
PlayerkillEffectShow3 = PlayerkillEffectShow3 or BaseClass()

function PlayerkillEffectShow3:__init(parent)
	self.parent = parent
	self.starsList = self.parent.starsList
	self.curr_star = PlayerkillManager.Instance.curr_star
	self.effectStarFly = self.parent.effectStarFly
	self.baseData = self.parent.baseData
	self.currData = PlayerkillManager.Instance.currData

	self.star = PlayerkillGetStarShow.New(self, function() self:EndShow() end)
end

function PlayerkillEffectShow3:__delete()
	if self.star ~= nil then
		self.star:DeleteMe()
		self.star = nil
	end
	self.starsList = nil
	self.baseData = nil
end

function PlayerkillEffectShow3:Show()
	self.star:Show()
end

function PlayerkillEffectShow3:EndShow()
	self.parent:UpdateAllAfterShow()
end