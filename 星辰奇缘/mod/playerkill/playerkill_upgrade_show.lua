-- ----------------------------
-- 英雄擂台升级展示
-- hosr
-- ----------------------------
PlayerkillUpgradeShow = PlayerkillUpgradeShow or BaseClass()

function PlayerkillUpgradeShow:__init(parent, callback)
	self.parent = parent
	self.callback = callback

	self.starIndex = 0

	self.tweenIdList = {}
end

function PlayerkillUpgradeShow:__delete()
	self:Clean()
end

function PlayerkillUpgradeShow:Show()
	-- 播特效
	self:PlayEffect()
	-- 飞星星
	self:FlyStars()
	-- 缩小icon
	self:ScaleSmall()
	-- 替换icon放大
	-- 结束回调
end

function PlayerkillUpgradeShow:FlyStars()
	self:EndStarTime()
	self.starIndex = 0
	self.timeStar = LuaTimer.Add(0, 100, function() self:LoopStar() end)
end

function PlayerkillUpgradeShow:LoopStar()
	if self.starIndex >= 5 then
		self:EndStarTime()
		return
	end
	self.starIndex = self.starIndex + 1
	local star = self.parent.starsList[self.starIndex]
	star.transform.localRotation = Quaternion.identity
	local tweenId1 = Tween.Instance:RotateZ(star.gameObject, 1080, 0.6, nil, LeanTweenType.linear).id
	local tweenId2 = Tween.Instance:MoveLocal(star.gameObject, Vector3(0, -90, 0), 0.5, nil, LeanTweenType.linear).id
	local tweenId6 = Tween.Instance:Scale(star.gameObject, Vector3.zero, 0.5, nil, LeanTweenType.linear).id
	table.insert(self.tweenIdList, tweenId1)
	table.insert(self.tweenIdList, tweenId2)
	table.insert(self.tweenIdList, tweenId6)
end

function PlayerkillUpgradeShow:EndStarTime()
	if self.timeStar ~= nil then
		LuaTimer.Delete(self.timeStar)
		self.timeStar = nil
	end
end

function PlayerkillUpgradeShow:PlayEffect()
	if self.parent.effectUpgrade == nil then
		return
	end

	self.parent.effectUpgrade:SetActive(false)
	self.parent.effectUpgrade:SetActive(true)
end

function PlayerkillUpgradeShow:ScaleSmall()
	self.tweenId3 = Tween.Instance:Scale(self.parent.cycleIconObj, Vector3.one * 0.8, 1.4, function() self:ScaleBig() end, LeanTweenType.linear).id
end

function PlayerkillUpgradeShow:ScaleBig()
	if self.parent.assetWrapper ~= nil then 
		self.parent.cycleIcon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.playkillicon, string.format("Lev%s", self.parent.data.rank_lev))
	end
	self.tweenId4 = Tween.Instance:Scale(self.parent.cycleIconObj, Vector3.one, 0.3, nil, LeanTweenType.easeOutElastic).id
	self:EndTime()
	self.timeId = LuaTimer.Add(1000, function() self:Over() end)
end

function PlayerkillUpgradeShow:Over()
	self.parent.cycleIconObj.transform.localScale = Vector3.one
	self.parent.effectUpgrade:SetActive(false)
	if self.callback ~= nil then
		self.callback()
	end
end

function PlayerkillUpgradeShow:EndTime()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function PlayerkillUpgradeShow:Clean()
	self:EndStarTime()
	self:EndTime()
	for i,v in ipairs(self.tweenIdList) do
		Tween.Instance:Cancel(v)
	end
	self.tweenIdList = nil

	if self.tweenId3 ~= nil then
		Tween.Instance:Cancel(self.tweenId3)
	end
	self.tweenId3 = nil

	if self.tweenId4 ~= nil then
		Tween.Instance:Cancel(self.tweenId4)
	end
	self.tweenId4 = nil
end