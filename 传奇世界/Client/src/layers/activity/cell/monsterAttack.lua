local monsterAttackRank = class("monsterAttackRank", function() return cc.Node:create() end)

function monsterAttackRank:ctor()
	print("monsterAttackRank:ctor")
	self.isShow = true
	
	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	self.baseNode = baseNode
	local posX = display.cx + 50
	posX = display.cx + 60 +(display.cx - 270 - 60)/2
	self.rankBg = createSprite(baseNode, "res/mainui/sideInfo/textBg_min.png", cc.p(posX, 50 - 10), cc.p(0.5, 0), 2)
	self.showBtn = createMenuItem(self.rankBg, "res/mainui/anotherbtns/show.png", cc.p(self.rankBg:getContentSize().width/2, self.rankBg:getContentSize().height + 5), function() self:changeRankMode() end)
	self.hideBtn = createMenuItem(self.rankBg, "res/mainui/anotherbtns/hide.png", cc.p(self.rankBg:getContentSize().width/2, self.rankBg:getContentSize().height + 5), function() self:changeRankMode() end)
	self.selfRankNode = cc.Node:create()
	self.rankBg:addChild(self.selfRankNode)

	self.otherRankBg = createSprite(baseNode, "res/mainui/sideInfo/textBg1_min.png", cc.p(posX, 115 - 10), cc.p(0.5, 0))
	self.otherRankNode = cc.Node:create()
	self.otherRankBg:addChild(self.otherRankNode)
	self.baseNode:setVisible(false)
	self:changeRankMode()
end

function monsterAttackRank:changeRankMode()
	self.isShow = not self.isShow
	self.otherRankBg:setVisible(self.isShow)
	self.hideBtn:setEnabled(self.isShow)
	self.hideBtn:setVisible(self.isShow)

	self.showBtn:setEnabled(not self.isShow)
	self.showBtn:setVisible(not self.isShow)
	if self.rankInfo then
		self:changeRank(self.rankInfo)
	end
end

function monsterAttackRank:changeRank(rankInfo)
	if rankInfo == nil or rankInfo.rankData == nil or type(rankInfo.rankData) ~= "table" or #rankInfo.rankData == 0 then
		removeFromParent(self)
		return
	end
	local offSetX = 5
	local offSetX1 = 153
	local fontSize = 16

	self.rankInfo = rankInfo

	-- rankInfo.rankData[2] = {}
	-- rankInfo.rankData[2].Name = "名字六个字个"
	-- rankInfo.rankData[2].Num = 9892
	-- rankInfo.rankData[#rankInfo.rankData+1] = rankInfo.rankData[2]
	-- rankInfo.rankData[#rankInfo.rankData+1] = rankInfo.rankData[2]
	-- rankInfo.rankData[#rankInfo.rankData+1] = rankInfo.rankData[2]

	self.selfRankNode:removeAllChildren()
	createLabel(self.selfRankNode, game.getStrByKey("rank_selfRank") .. ":   ", cc.p(offSetX, 40), cc.p(0, 0.5), fontSize):setColor(MColor.lable_yellow)
	createLabel(self.selfRankNode, "" .. rankInfo.myRank, cc.p(offSetX1, 40), cc.p(1, 0.5), fontSize)
	createLabel(self.selfRankNode, game.getStrByKey("rank_selfNum")  .. ":   ", cc.p(offSetX, 15), cc.p(0, 0.5), fontSize):setColor(MColor.lable_yellow)
	createLabel(self.selfRankNode, "" .. rankInfo.myNum, cc.p(offSetX1, 15), cc.p(1, 0.5), fontSize)


	if self.isShow then
		local height, offsetY = 125, 20
		self.otherRankNode:removeAllChildren()
		createLabel(self.otherRankNode, game.getStrByKey("integral") .. game.getStrByKey("rank_title1"), cc.p(offSetX, height), cc.p(0, 1), fontSize):setColor(MColor.lable_yellow)
		for i=1, #rankInfo.rankData do
			if i > 5 then
				break
			end
			createLabel(self.otherRankNode, "" .. i .."." .. rankInfo.rankData[i].Name .. ":", cc.p(offSetX, height - i * offsetY), cc.p(0, 1), fontSize):setColor(MColor.yellow)
			createLabel(self.otherRankNode, "" .. rankInfo.rankData[i].Num, cc.p(offSetX1, height - i * offsetY), cc.p(1, 1), fontSize)
		end
	end

	self.baseNode:setVisible(true)
end

return monsterAttackRank