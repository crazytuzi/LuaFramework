local LimitRankCell = class(LimitRankCell, function()
	return CCTableViewCell:new()
end)

function LimitRankCell:create(idx, width)
	self.rankName = ui.newTTFLabel({
	text = "1.侠客",
	size = 18,
	color = cc.c3b(64, 37, 7),
	textAlign = ui.TEXT_ALIGN_LEFT
	})
	self.rankName:setPosition(15, self.rankName:getContentSize().height / 2 + 5)
	self.rankName:setAnchorPoint(cc.p(0, 0.8))
	self:addChild(self.rankName)
	self.rankNum = ui.newTTFLabel({
	text = "4545",
	size = 18,
	color = cc.c3b(147, 5, 5),
	textAlign = ui.TEXT_ALIGN_RIGHT
	})
	self.rankNum:setAnchorPoint(cc.p(1, 0.8))
	self.rankNum:setPosition(width - 10, self.rankName:getContentSize().height / 2 + 5)
	self:addChild(self.rankNum)
	self.rankList = LimitHeroModel.rankList()
	self:refresh(idx)
	return self
end

function LimitRankCell:refresh(idx)
	local curListData = self.rankList[idx + 1]
	local curLv = curListData.runkid + 1
	local curName = curListData.username
	local curScore = curListData.score
	self.rankName:setString(curLv .. "." .. curName)
	self.rankNum:setString(curScore)
end

return LimitRankCell