--[[
    文件名：PvpInterFightLayer.lua
    描述：浑源之战战斗界面
    创建人：wukun
    创建时间：2017.06.05
-- ]]

local PvpInterFightLayer = class("PvpInterFightLayer", function()
    return display.newLayer()
end)

--[[
参数：
	fightInfo: 战斗数据
	memberList: 队伍成员信息
--]]
function PvpInterFightLayer:ctor(params)
	ui.registerSwallowTouch({node = self})

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self.mTeamsInfo = params.teamsInfo
	self.mTargetInfo = params.targetInfo
	self.mServerData = params.serverData
	self.mFightInfo = params.serverData.FightInfo
	self.mFightCount = 1

	-- 处理主角数据
	self:dealMainHeroData()

	self:initUI()
end

-- 对主角数据进行处理（使用主角本身ModelId, 不使用HeadImageId）
function PvpInterFightLayer:dealMainHeroData()
	local mainHeroData = HeroObj:getMainHero()

	self.mTeamsInfo.HeadImageId = mainHeroData.ModelId
end

function PvpInterFightLayer:initUI()
	local bg = ui.newSprite("zdcj_01.jpg")
	bg:setPosition(320, 568)
	self.mParentLayer:addChild(bg)

	-- 对战图标
    local topTipSprite = ui.newSprite("zdfb_31.png")
    topTipSprite:setPosition(320, 1085)
    self.mParentLayer:addChild(topTipSprite, 10)

	self:createNodeView()
	self:createFightView(self.mFightCount)
end

function PvpInterFightLayer:createNodeView()
	self.mEnemyList = {} --对手列表保存CardNode
	self.mTeamList = {}	-- 我方队伍列表保存CardNode

    local posX = 120
    -- 对手的信息
	local cardNode = CardNode.createCardNode({
		resourceTypeSub = ResourcetypeSub.eHero,
		modelId = self.mTargetInfo.HeroModelId,
		IllusionModelId = self.mTargetInfo.IllusionModelId,
		cardShowAttrs = {CardShowAttr.eBorder},
		allowClick = false,
	})
	cardNode:setPosition(60, 1070)
	self.mParentLayer:addChild(cardNode, 1)
	table.insert(self.mEnemyList, cardNode)

	local quality = HeroModel.items[self.mTargetInfo.HeroModelId].quality
	local nameLabel = ui.newLabel({
		text = self.mTargetInfo.Name,
		size = 22,
		color = Utility.getQualityColor(quality, 1),
		outlineColor = cc.c3b(0x14, 0x16, 0x12),
	})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(115, 1055)
	self.mParentLayer:addChild(nameLabel)

	local fapLabelWithBg = ui.createLabelWithBg({
	 	bgFilename = "c_23.png",
        labelStr = Utility.numberFapWithUnit(self.mTargetInfo.FAP),
        fontSize = 20,
        color = cc.c3b(0xff, 0xe3, 0x80),
        outlineColor = cc.c3b(0x89, 0x31, 0x0f),
        alignType = ui.TEXT_ALIGN_CENTER,
	})
	fapLabelWithBg:setPosition(75, 1010)
	self.mParentLayer:addChild(fapLabelWithBg)

	local fapSprite = ui.newSprite("c_127.png")
	fapSprite:setPosition(20, 1010)
	self.mParentLayer:addChild(fapSprite)

	-- 自己的信息
	local cardNode = CardNode.createCardNode({
		resourceTypeSub = ResourcetypeSub.eHero,
		modelId = self.mTeamsInfo.HeadImageId,
		fashionModelID = self.mTeamsInfo.FashionModelId,
		IllusionModelId = self.mTeamsInfo.IllusionModelId,
		cardShowAttrs = {CardShowAttr.eBorder},
		allowClick = false,
	})
	cardNode:setPosition(575, 1070)
	self.mParentLayer:addChild(cardNode, 1)
	table.insert(self.mTeamList, cardNode)

	local quality = Utility.getQualityByModelId(self.mTeamsInfo.HeadImageId)
	local nameLabel = ui.newLabel({
		text = self.mTeamsInfo.PlayerName,
		size = 22,
		color = Utility.getQualityColor(quality, 1),
		outlineColor = cc.c3b(0x14, 0x16, 0x12),
	})
	nameLabel:setAnchorPoint(cc.p(1, 0.5))
	nameLabel:setPosition(520, 1055)
	self.mParentLayer:addChild(nameLabel)

	local fapLabelWithBg = ui.createLabelWithBg({
	 	bgFilename = "c_23.png",
        labelStr = Utility.numberFapWithUnit(self.mTeamsInfo.FAP),
        fontSize = 20,
        color = cc.c3b(0xff, 0xe3, 0x80),
        outlineColor = cc.c3b(0x89, 0x31, 0x0f),
        alignType = ui.TEXT_ALIGN_CENTER,
	})
	fapLabelWithBg:setPosition(585, 1010)
	self.mParentLayer:addChild(fapLabelWithBg)

	local fapSprite = ui.newSprite("c_127.png")
	fapSprite:setPosition(525, 1010)
	self.mParentLayer:addChild(fapSprite)
end

function PvpInterFightLayer:createFightView(FightId)
	if FightId > 1 then
		PvpResult.showPvpResultLayer(
			ModuleSub.ePVPInter,
			self.mServerData,
			self.mTeamsInfo,
			self.mTargetInfo
		)
		return
	end

	local result = self.mFightInfo.IsWin
	-- 根据实际情况计算掉血比例
	local targetCsHp = self.mFightInfo.TargetCsHp
	self.mEnemyTotalHp = 0
	local enemyHp = 0
	self.mTeamTotalHp = 0
	self.mTeamHp = 0

	for k, v in pairs(targetCsHp) do
		if v.PosId > 6 then
			self.mEnemyTotalHp = self.mEnemyTotalHp + v.TotalHp
			enemyHp = enemyHp + v.HP
		else
			self.mTeamTotalHp = self.mTeamTotalHp + v.TotalHp
			self.mTeamHp = self.mTeamHp + v.HP
		end 
	end
	self.mHpLessNumE = enemyHp
	self.mHpLessNumT = self.mTeamHp

	-- 自己
	local teamNode = cc.Node:create()
	teamNode:setPosition(950, 530)
	self.mParentLayer:addChild(teamNode)
	self.mTeamNode = teamNode

	local teamFigure = Figure.newHero({
		heroModelID = self.mTeamsInfo.HeadImageId,
		fashionModelID = self.mTeamsInfo.FashionModelId,
		IllusionModelId = self.mTeamsInfo.IllusionModelId,
        parent = teamNode,
        position = cc.p(0, -100),
        scale = 0.16,
	})
	teamFigure:setRotationSkewY(180)
	self.mTeamFigure = teamFigure

	self.mHpBarT = require("common.ProgressBar"):create({
		bgImage = "zdfb_32.png",   -- 背景图片
        barImage = "zdfb_33.png",  -- 进度图片
        currValue = self.mTeamTotalHp,  -- 当前进度
        maxValue = self.mTeamTotalHp, -- 最大值
	})
	self.mHpBarT:setAnchorPoint(cc.p(0, 0.5))
	self.mHpBarT:setPosition(320, 1095)
	self.mParentLayer:addChild(self.mHpBarT)
	teamNode:runAction(self:fightAction(true))

	-- 敌方
	local enemyNode = cc.Node:create()
	enemyNode:setPosition(-250, 530)
	self.mParentLayer:addChild(enemyNode)
	self.mEnemyNode = enemyNode

	local enemyFigure = Figure.newHero({
		heroModelID = self.mTargetInfo.HeroModelId,
		fashionModelID = self.mTargetInfo.FashionModelId,
		IllusionModelId = self.mTargetInfo.IllusionModelId,
        parent = enemyNode,
        position = cc.p(0, -100),
        scale = 0.16,
	})
	self.mEnemyFigure = enemyFigure

	self.mHpBarE = require("common.ProgressBar"):create({
		bgImage = "zdfb_30.png",   -- 背景图片
        barImage = "zdfb_29.png",  -- 进度图片
        currValue = 0,  -- 当前进度
        maxValue = self.mEnemyTotalHp, -- 最大值
	})
	self.mHpBarE:setAnchorPoint(cc.p(1, 0.5))
	self.mHpBarE:setPosition(320, 1095)
	self.mParentLayer:addChild(self.mHpBarE)
	enemyNode:runAction(self:fightAction(false))
end

function PvpInterFightLayer:fightAction(nodeTag)
	local startPos = nodeTag and cc.p(550, 530) or cc.p(90, 530)
	local targetPos = nodeTag and cc.p(435, 530) or cc.p(185, 530)
	local tempMaxValueT = self.mTeamTotalHp
	local tempMaxValueE = self.mEnemyTotalHp

	local jumpIn = cc.JumpTo:create(0.5, startPos, 50, 1)
	local delayToF = cc.DelayTime:create(1)
	local moveTo = cc.MoveTo:create(0.1, targetPos)
	local callBackSetAnimation = cc.CallFunc:create(function ()
		if nodeTag then
			self.mTeamFigure:setToSetupPose()
			self.mEnemyFigure:setToSetupPose()
			self.mEnemyFigure:setAnimation(0, "pose2", true)
			self.mTeamFigure:setAnimation(0, "pose2", true)
			MqAudio.playEffect("duizhang.mp3")
		end
	end)

	local callBackEff = cc.CallFunc:create(function()
		if nodeTag then
			self.mFightEffect = ui.newEffect({
				parent = self.mParentLayer,
		        effectName = "effect_ui_duizhang",
		        speed = 1,
		        position = cc.p(320, 568),
		        loop = true,
			})
			tempMaxValueT = tempMaxValueT - self.mHpLessNumT
			tempMaxValueE = tempMaxValueE - self.mHpLessNumE
			self.mHpBarT:setCurrValue(self.mHpLessNumT, 1.5)
			self.mHpBarE:setCurrValue(self.mEnemyTotalHp - self.mHpLessNumE, 1.5)
		end
	end)
	local delayToP = cc.DelayTime:create(2)
	local crashSq = cc.Sequence:create({callBackSetAnimation, moveTo, callBackEff, delayToP})
	local callBackWin = cc.CallFunc:create(function()
		if nodeTag then
			self.mFightEffect:removeFromParent()
			self.mFightEffect = nil
			if self.mFightInfo.IsWin then
				local winSprite = ui.newSprite("zdfb_18.png")
				winSprite:setPosition(45, 45)
				self.mTeamList[self.mFightCount]:addChild(winSprite)

				local loseSprite = ui.newSprite("zdfb_23.png")
				loseSprite:setPosition(45, 45)
				self.mEnemyList[self.mFightCount]:addChild(loseSprite)

				self.mTeamFigure:setToSetupPose()
				self.mTeamFigure:setAnimation(0, "win", true)

				local action = cc.Sequence:create(
					cc.CallFunc:create(function()
						self.mEnemyFigure:setToSetupPose()
						self.mEnemyFigure:setAnimation(0, "aida", true)
					end),
					cc.DelayTime:create(0.1),
					cc.MoveTo:create(0.15, cc.p(-250, 490))
				)
				self.mEnemyNode:runAction(action)
			else
				local winSprite = ui.newSprite("zdfb_18.png")
				winSprite:setPosition(45, 45)
				self.mEnemyList[self.mFightCount]:addChild(winSprite)

				local loseSprite = ui.newSprite("zdfb_23.png")
				loseSprite:setPosition(45, 45)
				self.mTeamList[self.mFightCount]:addChild(loseSprite)

				self.mEnemyFigure:setToSetupPose()
				self.mEnemyFigure:setAnimation(0, "win", true)
				
				local action = cc.Sequence:create(
					cc.CallFunc:create(function()
						self.mTeamFigure:setToSetupPose()
						self.mTeamFigure:setAnimation(0, "aida", true)
					end),
					cc.DelayTime:create(0.1),
					cc.MoveTo:create(0.15, cc.p(950, 490))
				)
				self.mTeamNode:runAction(action)

				if self.mTeamHp > 0 then
					ui.showFlashView(TR("回合耗尽先手败"))
				end
			end
		end
	end)
	local delayToE = cc.DelayTime:create(1)
	local callBackRemove = cc.CallFunc:create(function()
		if nodeTag then
			self.mFightCount = self.mFightCount + 1
			self.mTeamNode:removeFromParent()
			self.mTeamNode = nil
		else
			self.mEnemyNode:removeFromParent()
			self.mEnemyNode = nil
		end
		self:checkFun()
	end)
	local action = cc.Sequence:create({jumpIn, delayToF, crashSq, callBackWin, delayToE, callBackRemove})

	return action
end

function PvpInterFightLayer:checkFun()
	if self.mEnemyNode == nil and self.mTeamNode == nil then
		self:createFightView(self.mFightCount)
	end
end

return PvpInterFightLayer