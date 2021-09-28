--[[
    文件名：ExpediFightLayer.lua
    文件描述：副本组队战斗界面
    创建人：lengjiazhi
    创建时间：2017.07.14
]]
local ExpediFightLayer = class("ExpediFightLayer", function(params)
    return display.newLayer()
end)

--[[
参数：
fightInfo: 战斗数据
memberList: 队伍成员信息
--]]

function ExpediFightLayer:ctor(params)
	ui.registerSwallowTouch({node = self})
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mFightInfo = params.fightInfo or nil
	self.mMemberList = params.memberList or {{}, {}, {}}

	self.mFightCount = 1
	self.mWinCount = 0

	self:initUI()
end

function ExpediFightLayer:initUI()
	self.mNodeModelInfo = ExpeditionNodeModel.items[self.mFightInfo.NodeInfo.NodeModelId]
	-- self.mNodeModelInfo = ExpeditionNodeModel.items[1112]


	local bg = ui.newSprite(self.mNodeModelInfo.fightBgPic)
	-- local bg = ui.newSprite("zdcj_04.jpg")
	bg:setPosition(320, 568)
	self.mParentLayer:addChild(bg)

	 -- 创建退出按钮
    -- local button = ui.newButton({
    --     normalImage = "c_29.png",
    --     anchorPoint = cc.p(0.5, 0.5),
    --     position = cc.p(320, 520),
    --     clickAction = function()
    --         LayerManager.removeLayer(self)
    --     end
    -- })
    -- self.mParentLayer:addChild(button, 5)

    --对战图标
    local topTipSprite = ui.newSprite("zdfb_31.png")
    topTipSprite:setPosition(320, 1085)
    self.mParentLayer:addChild(topTipSprite, 10)

    if self.mFightInfo.ContinueFightInfo then
        local fightCountLabel = ui.newLabel({
            text = TR("连战中%s/%s", self.mFightInfo.ContinueFightInfo.BattleCount, self.mFightInfo.ContinueFightInfo.NeedBattleCount),
            size = 24,
            outlineColor = Enums.Color.eBlack,
            })
        fightCountLabel:setPosition(320, 1045)
        self.mParentLayer:addChild(fightCountLabel)
    end


	self:createNodeView()
	self:createFightView()
end

function ExpediFightLayer:getRestoreData()
	local retData = {
		memberList = self.mMemberList,
	}
	return retData
end

function ExpediFightLayer:createNodeView()
	self.mEnemyList = {} --对手列表保存CardNode
	self.mTeamList = {}	-- 我方队伍列表保存CardNode
	self.mEnemyData = {} -- 对手数据表
	local nodeFapList = self.mFightInfo.NodeInfo.NodeFap
    local enemyModelIdList = string.split(self.mNodeModelInfo.heroModelID, "|")
    local posX = 120
	for i,v in ipairs(enemyModelIdList) do
        local enemyModelId = tonumber(string.split(v, ",")[2])
        local enemyData = HeroModel.items[enemyModelId]
        table.insert(self.mEnemyData, enemyData)

		local cardNode = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eHero,
			modelId = enemyData.ID,
			cardShowAttrs = {CardShowAttr.eBorder},
			allowClick = false,
			})
		cardNode:setPosition(580, 960 - (i-1) * 100)
		cardNode:setScale(0.7)
		self.mParentLayer:addChild(cardNode)
		table.insert(self.mEnemyList, cardNode)

		local nameLabel = ui.newLabel({
			text = Utility.getGoodsName(ResourcetypeSub.eHero, enemyData.ID),
			size = 14,
			color = Enums.Color.eNormalWhite,
			outlineColor = cc.c3b(0x14, 0x16, 0x12),
			})
		nameLabel:setPosition(580, 920 - (i-1) * 100)
		self.mParentLayer:addChild(nameLabel)
		local FapLabel = ui.newLabel({
			text = TR("战力：%s", Utility.numberFapWithUnit(nodeFapList[i])),
			-- text = TR("战力:%s", Utility.numberWithUnit(11000000)),
			size = 14,
			color = Enums.Color.eNormalWhite,
			outlineColor = cc.c3b(0x14, 0x16, 0x12),
			})
		FapLabel:setPosition(580, 905 - (i-1) * 100)
		self.mParentLayer:addChild(FapLabel)
	end

	for i,v in ipairs(self.mMemberList) do
		local cardNode = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eHero,
			fashionModelID = v.FashionModelId,
			modelId = v.HeroModelId,
			-- modelId = 12010002,
			cardShowAttrs = {CardShowAttr.eBorder},
			allowClick = false,
			})
		cardNode:setPosition(60, 960 - (i-1) * 100)
		cardNode:setScale(0.7)
		self.mParentLayer:addChild(cardNode)
		table.insert(self.mTeamList, cardNode)

		local nameLabel = ui.newLabel({
			text = v.Name,
			size = 14,
			color = Enums.Color.eNormalWhite,
			outlineColor = cc.c3b(0x14, 0x16, 0x12),
			})
		nameLabel:setPosition(60, 920 - (i-1) * 100)
		self.mParentLayer:addChild(nameLabel)

		local FapLabel = ui.newLabel({
			text = TR("战力：%s", Utility.numberFapWithUnit(v.FAP)),
			-- text = TR("战力：%s", Utility.numberWithUnit(111111111)),
			size = 14,
			color = Enums.Color.eNormalWhite,
			outlineColor = cc.c3b(0x14, 0x16, 0x12),
			})
		FapLabel:setPosition(60, 905 - (i-1) * 100)
		self.mParentLayer:addChild(FapLabel)
	end
end

local startPosList = {
	[1] = {
		team = cc.p(190, 790),
		enemy = cc.p(435, 790),
	},
	[2] = {
		team = cc.p(150, 620),
		enemy = cc.p(480, 620),
	},
	[3] = {
		team = cc.p(110, 410),
		enemy = cc.p(520, 410),
	},
}

--创建下方战斗显示
function ExpediFightLayer:createFightView()
	self.mTeamNodeList = {}
	self.mEnemyNodeList = {}
	for i,v in ipairs(self.mMemberList) do
		local tempNode = cc.Node:create()
		tempNode:setPosition(-250 - (i-1) * 40, 790 - (i-1) * 120)
		self.mParentLayer:addChild(tempNode)

		local tempFigure = Figure.newHero({
			heroModelID = v.HeroModelId,
	        fashionModelID = v.FashionModelId,
	        IllusionModelId = v.IllusionModelId,
	        parent = tempNode,
	        position = cc.p(0, -100),
	        scale = 0.12 + (i-1) * 0.03,
		})
		tempNode.figure = tempFigure

		local tempName = ui.newLabel({
			text = v.Name,
			size = 14,
			outlineColor = cc.c3b(0x14, 0x16, 0x12),
			})
		tempName:setPosition(0, 80 + (i-1) * 40)
		tempNode:addChild(tempName)

		local hpBar = require("common.ProgressBar"):create({
			bgImage = "zd_01.png",   -- 背景图片
	        barImage = "zd_02.png",  -- 进度图片
	        currValue = 10,  -- 当前进度
	        maxValue = 10, -- 最大值
			})
		hpBar:setPosition(0, 65 + (i-1) * 40)
		hpBar:setVisible(false)
		tempNode:addChild(hpBar)
		tempNode.hpBar = hpBar

		table.insert(self.mTeamNodeList, tempNode)
	end

	for i,v in ipairs(self.mEnemyData) do
		local tempNode = cc.Node:create()
		tempNode:setPosition(640 + (i-1) * 40, 790 - (i-1) * 120)
		self.mParentLayer:addChild(tempNode)

		local tempFigure = Figure.newHero({
		heroModelID = v.ID,
        -- fashionModelID = 0,
        IllusionModelId = v.IllusionModelId,
        parent = tempNode,
        position = cc.p(0, -100),
        scale = 0.12 + (i-1) * 0.03,
		})
		tempFigure:setRotationSkewY(180)
		tempNode.figure = tempFigure

		local tempName = ui.newLabel({
			text = v.name,
			size = 14,
			outlineColor = cc.c3b(0x14, 0x16, 0x12),
			})
		tempName:setPosition(0, 80 + (i-1) * 40)
		tempNode:addChild(tempName)


		local hpBar = require("common.ProgressBar"):create({
			bgImage = "zd_01.png",   -- 背景图片
	        barImage = "zd_02.png",  -- 进度图片
	        currValue = 10,  -- 当前进度
	        maxValue = 10, -- 最大值
			})
		hpBar:setPosition(0, 65 + (i-1) * 40)
		hpBar:setVisible(false)
		tempNode:addChild(hpBar)
		tempNode.hpBar = hpBar

		table.insert(self.mEnemyNodeList, tempNode)
	end
	self:jumpInAction()
end

--全体跳进场动作
function ExpediFightLayer:jumpInAction()
	for i,v in ipairs(self.mTeamNodeList) do
		local action = cc.JumpTo:create(0.4, startPosList[i].team, 50, 1)
		v:runAction(action)
	end
	for i,v in ipairs(self.mEnemyNodeList) do
		local action = cc.JumpTo:create(0.4, startPosList[i].enemy, 50, 1)
		v:runAction(action)
	end
	self:refreshFightView(self.mFightCount)
end

--刷新
function ExpediFightLayer:refreshFightView(FightId)
	if self.mWinCount >= 2 then
		PvpResult.showPvpResultLayer(ModuleSub.eExpedition, self.mFightInfo, self.mMemberList)
		return
	end

	if FightId > #self.mMemberList then
		PvpResult.showPvpResultLayer(ModuleSub.eExpedition, self.mFightInfo, self.mMemberList)
		return
	end

	--根据实际情况计算掉血比例
	local targetCsHp = self.mFightInfo.FightResults[FightId].TargetCsHp
	local enemyTotalHp = 0
	local enemyHp = 0
	local teamTotalHp = 0
	local teamHp = 0
	for k,v in pairs(targetCsHp[1]) do
		if v.PosId > 6 then
			enemyTotalHp = enemyTotalHp + v.TotalHp
			enemyHp = enemyHp + v.HP
		else
			teamTotalHp = teamTotalHp + v.TotalHp
			teamHp = teamHp + v.HP
		end 
	end
	-- self.mHpLessNumE = enemyHp
	-- self.mHpLessNumT = teamHp
	self.mTeamHp = teamHp

	local hpInfoT = {
		totalHp = teamTotalHp,
		leftHp = teamHp,
	}
	local hpInfoE = {
		totalHp = enemyTotalHp,
		leftHp = enemyHp,
	}
	for i,v in ipairs(self.mTeamNodeList) do
		v.hpBar:setVisible(i == FightId)
	end
	for i,v in ipairs(self.mEnemyNodeList) do
		v.hpBar:setVisible(i == FightId)
	end

	-- if result then
	-- 	self.mHpLessNumT = 15
	-- 	self.mHpLessNumE = 33
	-- else
	-- 	self.mHpLessNumT = 33
	-- 	self.mHpLessNumE = 15
	-- end
	if self.mcurCardT then
		self.mcurCardT:removeFromParent()
		self.mcurCardT = nil
		self.mFapLabelT:removeFromParent()
		self.mFapLabelT = nil
		self.mNameLabelT:removeFromParent()
		self.mNameLabelT = nil
		self.mcurCardE:removeFromParent()
		self.mcurCardE = nil
		self.mFapLabelE:removeFromParent()
		self.mFapLabelE = nil
		self.mNameLabelE:removeFromParent()
		self.mNameLabelE = nil
	end

	--左上方头像信息
	local curCardNode = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eHero,
			modelId = self.mMemberList[FightId].HeroModelId,
			fashionModelID = self.mMemberList[FightId].FashionModelId,
			cardShowAttrs = {CardShowAttr.eBorder},
			allowClick = false,
		})
	curCardNode:setPosition(60, 1070)
	self.mParentLayer:addChild(curCardNode)
	self.mcurCardT = curCardNode

	local fapLabelWithBg = ui.createLabelWithBg({
		 	bgFilename = "c_23.png",
	        labelStr = Utility.numberFapWithUnit(self.mMemberList[FightId].FAP),
	        fontSize = 20,
	        color = cc.c3b(0xff, 0xe3, 0x80),
	        outlineColor = cc.c3b(0x89, 0x31, 0x0f),
	        alignType = ui.TEXT_ALIGN_CENTER,
		})
	fapLabelWithBg:setPosition(80, 1010)
	self.mParentLayer:addChild(fapLabelWithBg)
	self.mFapLabelT = fapLabelWithBg

	local fapSprite = ui.newSprite("c_127.png")
	fapSprite:setPosition(20, 1010)
	self.mParentLayer:addChild(fapSprite)

	local nameLabel = ui.newLabel({
			text = self.mMemberList[FightId].Name,
			size = 20,
			color = Enums.Color.eNormalWhite,
			outlineColor = cc.c3b(0x14, 0x16, 0x12),
			})
	nameLabel:setAnchorPoint(0, 0.5)
	nameLabel:setPosition(115, 1055)
	self.mParentLayer:addChild(nameLabel)
	self.mNameLabelT = nameLabel

	local teamNode = self.mTeamNodeList[FightId]
	teamNode.hpBar:setMaxValue(teamTotalHp, 0)
	teamNode.hpBar:setCurrValue(teamTotalHp, 0)

	self.mHpBarT = require("common.ProgressBar"):create({
		bgImage = "zdfb_30.png",   -- 背景图片
        barImage = "zdfb_29.png",  -- 进度图片
        currValue = 0,  -- 当前进度
        maxValue = teamTotalHp, -- 最大值
		})
	self.mHpBarT:setAnchorPoint(1, 0.5)
	self.mHpBarT:setPosition(320, 1095)
	self.mParentLayer:addChild(self.mHpBarT)

	teamNode:runAction(self:fightAction(teamNode, hpInfoT, true))
	--=========================================敌方===================================

	--右上方头像信息
	local curCardNode = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eHero,
			modelId = self.mEnemyData[FightId].ID,
			cardShowAttrs = {CardShowAttr.eBorder},
			allowClick = false,
		})
	curCardNode:setPosition(575, 1070)
	self.mParentLayer:addChild(curCardNode)
	self.mcurCardE = curCardNode

	local fapLabelWithBg = ui.createLabelWithBg({
		 	bgFilename = "c_23.png",
	        labelStr = Utility.numberFapWithUnit(self.mFightInfo.NodeInfo.NodeFap[FightId]),
	        fontSize = 20,
	        color = cc.c3b(0xff, 0xe3, 0x80),
	        outlineColor = cc.c3b(0x89, 0x31, 0x0f),
	        alignType = ui.TEXT_ALIGN_CENTER,
		})
	fapLabelWithBg:setPosition(590, 1010)
	self.mParentLayer:addChild(fapLabelWithBg)
	self.mFapLabelE = fapLabelWithBg

	local fapSprite = ui.newSprite("c_127.png")
	fapSprite:setPosition(525, 1010)
	self.mParentLayer:addChild(fapSprite)

	local nameLabel = ui.newLabel({
			text = self.mEnemyData[FightId].name,
			size = 20,
			color = Enums.Color.eNormalWhite,
			outlineColor = cc.c3b(0x14, 0x16, 0x12),
			})
	nameLabel:setAnchorPoint(1, 0.5)
	nameLabel:setPosition(520, 1055)
	self.mParentLayer:addChild(nameLabel)
	self.mNameLabelE = nameLabel

	local enemyNode = self.mEnemyNodeList[FightId]
	enemyNode.hpBar:setMaxValue(enemyTotalHp, 0)
	enemyNode.hpBar:setCurrValue(enemyTotalHp, 0)

	self.mHpBarE = require("common.ProgressBar"):create({
		bgImage = "zdfb_32.png",   -- 背景图片
        barImage = "zdfb_33.png",  -- 进度图片
        currValue = enemyTotalHp,  -- 当前进度
        maxValue = enemyTotalHp, -- 最大值
		})
	self.mHpBarE:setAnchorPoint(0, 0.5)
	self.mHpBarE:setPosition(320, 1095)
	self.mParentLayer:addChild(self.mHpBarE)

	enemyNode:runAction(self:fightAction(enemyNode, hpInfoE, false))

end

local TargetPosList = {
	[1] = {
		team = cc.p(250, 790),
		enemy = cc.p(445, 790),
		effect = cc.p(320, 790) 
	},
	[2] = {
		team = cc.p(205, 620),
		enemy = cc.p(445, 620),
		effect = cc.p(320, 620)  
	},
	[3] = {
		team = cc.p(205, 410),
		enemy = cc.p(445, 410),
		effect = cc.p(320, 410)  
	},
}

function ExpediFightLayer:fightAction(node, hpInfo, nodeTag)
	local startPos = nodeTag and startPosList[self.mFightCount].team or startPosList[self.mFightCount].enemy
	local targetPos = nodeTag and TargetPosList[self.mFightCount].team or TargetPosList[self.mFightCount].enemy

	local delayToF = cc.DelayTime:create(self.mFightCount == 1 and 1 or 0.1)

	local callBackSetAnimation = cc.CallFunc:create(function ()
		if nodeTag then
			MqAudio.playEffect("duizhang.mp3")
		end
		node.figure:setToSetupPose()
		node.figure:setAnimation(0, "pose2", true)
	end)

	local moveCenter = cc.MoveTo:create(0.1, targetPos)
	-- local moveBack = cc.MoveTo:create(0.2, targetPos)
	local callBackEff = cc.CallFunc:create(function()
		if nodeTag then
			self.mFightEffect = ui.newEffect({
				parent = self.mParentLayer,
		        effectName = "effect_ui_duizhang",
		        speed = 1,
		        position = TargetPosList[self.mFightCount].effect,
		        scale = 0.3,
		        loop = true,
			})

			self.mHpBarT:setCurrValue(hpInfo.totalHp - hpInfo.leftHp, 3)
		else
			self.mHpBarE:setCurrValue(hpInfo.leftHp, 3)
		end
		node.hpBar:setCurrValue(hpInfo.leftHp, 3)
	end)
	local delayToP = cc.DelayTime:create(3)
	local crashSq = cc.Sequence:create({callBackSetAnimation, callBackEff, delayToP})
	local callBackWin = cc.CallFunc:create(function()
		if nodeTag then
			if not tolua.isnull(self.mFightEffect) then
				self.mFightEffect:removeFromParent()
				self.mFightEffect = nil
			end
			if self.mFightInfo.FightResults[self.mFightCount].IsWin then
				local winSprite = ui.newSprite("zdfb_18.png")
				winSprite:setPosition(45, 45)
				self.mTeamList[self.mFightCount]:addChild(winSprite)

				local loseSprite = ui.newSprite("zdfb_23.png")
				loseSprite:setPosition(45, 45)
				self.mEnemyList[self.mFightCount]:addChild(loseSprite)
				self.mEnemyList[self.mFightCount]:setGray(true)

				node:runAction(cc.MoveTo:create(0.3, startPos))
				node.figure:setToSetupPose()
				node.figure:setAnimation(0, "win", true)
				self.mWinCount = self.mWinCount + 1
			else
				local winSprite = ui.newSprite("zdfb_18.png")
				winSprite:setPosition(45, 45)
				self.mEnemyList[self.mFightCount]:addChild(winSprite)

				local loseSprite = ui.newSprite("zdfb_23.png")
				loseSprite:setPosition(45, 45)
				self.mTeamList[self.mFightCount]:addChild(loseSprite)
				self.mTeamList[self.mFightCount]:setGray(true)

				node:runAction(cc.MoveTo:create(0.2, cc.p(startPos.x - 600, startPos.y + 200)))

				if self.mTeamHp > 0 then
					ui.showFlashView(TR("回合耗尽先手败"))
				end
			end
		else
			if self.mFightInfo.FightResults[self.mFightCount].IsWin then
				node:runAction(cc.MoveTo:create(0.2,cc.p(startPos.x + 300, startPos.y + 200)))
			else
				node.figure:setToSetupPose()
				node.figure:setAnimation(0, "win", true)
				node:runAction(cc.MoveTo:create(0.3, startPos))
			end
		end
	end)

	local delayToE = cc.DelayTime:create(1.5)
	local fadeOut = cc.FadeOut:create(0.5)
	local callBackRemove = cc.CallFunc:create(function()
		if nodeTag then
			self.mFightCount = self.mFightCount + 1
			self:checkFun()
		end
		
	end)
	local action = cc.Sequence:create({delayToF, moveCenter, crashSq, callBackWin, delayToE, fadeOut, callBackRemove})

	return action
end

function ExpediFightLayer:checkFun()
	-- if self.mEnemyNode == nil and self.mTeamNode == nil then
		self:refreshFightView(self.mFightCount)
	-- end	
end

return ExpediFightLayer