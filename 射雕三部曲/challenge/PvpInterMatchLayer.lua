--[[
	文件名：PvpInterMatchLayer.lua
	文件描述：浑源之战匹配页面
	创建人：chenqiang
	创建时间：2017.07.31
]]

local PvpInterMatchLayer = class("PvpInterMatchLayer", function()
	return display.newLayer()
end)

-- 文字数字替换
local labelRef = {
    [1] = TR("壹"),
    [2] = TR("贰"),
    [3] = TR("叁"),
    [4] = TR("肆"),
    [5] = TR("伍"),
    [6] = TR("陆"),
    [7] = TR("柒"),
    [8] = TR("捌"),
    [9] = TR("玖"),
}

-- 构造函数
--[[
	pvpFightInfo: 匹配数据信息
]]
function PvpInterMatchLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	params = params or {}
	self.mPvpFightInfo = params.pvpFightInfo

	-- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 最高屏蔽层(禁止切换导航按钮退出界面)
	local maskLayer = ui.createSwallowLayer()
	self:addChild(maskLayer, Enums.ZOrderType.eNewbieGuide)

	-- 初始化	UI
	self:initUI()
end

-- 初始化UI
function PvpInterMatchLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("sc_25.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 特效
	ui.newEffect({
		parent = self.mParentLayer,
		effectName = "effect_ui_qunxiongzhengba",
		animation = "animation",
		position = cc.p(320, 568),
		zorder = 1,
		loop = true,
		endRelease = true,
	})
	-- 创建对战双方的信息
	self:createVsInfo()
end

-- 创建对战双方信息
function PvpInterMatchLayer:createVsInfo()
	-- 创建自己的信息
	self:createMyselfInfo()
	-- 创建对手的信息
	self:createEnemyInfo()
end

-- 创建玩家自己的信息
function PvpInterMatchLayer:createMyselfInfo()
	-- 人物模型
	local mainHero = HeroObj:getMainHero()
	local playerInfo = PlayerAttrObj:getPlayerInfo()
	local heroScale = 0.23
	local heroFigure = Figure.newHero({
		heroModelID = mainHero.ModelId,
		fashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId"),
		IllusionModelId = mainHero.IllusionModelId,
		fashionModelID = -1,
		parent = self.mParentLayer,
		position = cc.p(500, 130),
		scale = heroScale,
	})
	heroFigure:setRotationSkewY(180)

	-- 信息背景
	local bgSprite = ui.newScale9Sprite("hslj_04.png", cc.size(220, 100))
	bgSprite:setAnchorPoint(cc.p(1, 0.5))
	bgSprite:setPosition(440, 390)
	self.mParentLayer:addChild(bgSprite)

	-- 境界图片
	local stateInfo = PvpinterStateRelation.items[self.mPvpFightInfo.PVPinterFightLog.BeforeState]
	Utility.performWithDelay(heroFigure , function()
		local figureRect = heroFigure:getBoundingBox()
		local scale = heroFigure:getScale()
        if scale then
            figureRect.width = figureRect.width * scale
            figureRect.height = figureRect.height / scale
        end

		-- 境界图片
		local stateImg = ui.newSprite(stateInfo.stateHeadFrame2 .. ".png")
		stateImg:setAnchorPoint(cc.p(0.5, 0.5))
		stateImg:setPosition(figureRect.width * 0.5, figureRect.height + 50)
		stateImg:setScale(2.5)
		stateImg:setFlippedX(true)
		heroFigure:addChild(stateImg)

		-- 重设信息背景坐标
		bgSprite:setPosition(440, figureRect.height*0.5*heroScale+200)
	end, 0.001)

	local bgSize = bgSprite:getContentSize()
	-- 境界信息
	local stateStr
	if self.mPvpFightInfo.PVPinterFightLog.BeforeState >= 6 then
		stateStr = TR("%s%d分", stateInfo.name, self.mPvpFightInfo.PVPinterFightLog.BeforeRate)
	else
		stateStr = TR("%s%s阶", stateInfo.name, labelRef[self.mPvpFightInfo.PVPinterFightLog.BeforeStep])
	end
	local stateNode = ui.newLabel({
		text = stateStr,
		color = cc.c3b(0x62, 0x2f, 0x0e),
	})
	stateNode:setPosition(bgSize.width * 0.5, 80)
	bgSprite:addChild(stateNode)

	-- 玩家名称
	local quality = HeroModel.items[mainHero.ModelId].quality
	local playerName = ui.newLabel({
		text = playerInfo.PlayerName,
		color = Utility.getQualityColor(quality, 1),
		shadowColor = Enums.Color.eShadowColor,
	})
	playerName:setPosition(bgSize.width * 0.5, 47)
	bgSprite:addChild(playerName)

	-- 战力
	local fap = ui.newLabel({
		text = TR("战力: %s", Utility.numberFapWithUnit(playerInfo.FAP)),
		color = Enums.Color.eNormalWhite,
		outlineColor = Enums.Color.eOutlineColor,
	})
	fap:setPosition(bgSize.width * 0.5, 17)
	bgSprite:addChild(fap)
end

-- 创建玩家对手的信息
function PvpInterMatchLayer:createEnemyInfo()
	local tempHeroIds = {12010005, 12010003, 12011301, 12011302, 12011304, 12012304}
	local oldModleId

	-- 在列表中随机一个ID，随机到相同ID时重新随机
	local function randomHeroModelId()
		local randomIndex = math.floor(math.random(1, #tempHeroIds))
    	local tempModelId = tempHeroIds[randomIndex]
    	if tempModelId == oldModleId then
    		return randomHeroModelId()
    	else
    		oldModleId = tempModelId 
    		return tempModelId
    	end
	end

	local function newPlayer()
		local tempModelId = randomHeroModelId()
		self.mRole = Figure.newHero({
        	parent = self.mParentLayer,
        	heroModelID = tempModelId,
        	scale = 0.23,
        	position = cc.p(160, 700),
        	needAction = false,
        })

        local scaleAction = cc.RepeatForever:create(
            cc.Sequence:create(
                cc.DelayTime:create(0.08),
                cc.CallFunc:create(function()
                	self.mRole:removeFromParent()
                	self.mRole = nil

                	newPlayer()
                end)
            )
        )
        self.mRole:runAction(scaleAction)
	end
	newPlayer()

	local function createPlayerInfo()
		local heroScale = 0.23
		local heroFigure = Figure.newHero({
			heroModelID = self.mPvpFightInfo.TargetInfo.HeroModelId,
			fashionModelID = self.mPvpFightInfo.TargetInfo.FashionModelId,
			IllusionModelId = self.mPvpFightInfo.TargetInfo.IllusionModelId,
			parent = self.mParentLayer,
			position = cc.p(160, 700),
			scale = heroScale,
		})

		-- 信息背景
		local bgSprite = ui.newScale9Sprite("hslj_04.png", cc.size(220, 100))
		bgSprite:setAnchorPoint(cc.p(0, 0.5))
		bgSprite:setPosition(220, 950)
		self.mParentLayer:addChild(bgSprite)

		local stateInfo = PvpinterStateRelation.items[self.mPvpFightInfo.TargetInfo.PVPInterState]
		Utility.performWithDelay(heroFigure , function()
			local figureRect = heroFigure:getBoundingBox()
			local scale = heroFigure:getScale()
	        if scale then
	            figureRect.width = figureRect.width / scale
	            figureRect.height = figureRect.height / scale
	        end

			-- 境界图片
			local stateImg = ui.newSprite(stateInfo.stateHeadFrame2 .. ".png")
			stateImg:setAnchorPoint(cc.p(1, 0.5))
			stateImg:setPosition(figureRect.width * 0.5, figureRect.height + 50)
			stateImg:setScale(2.5)
			heroFigure:addChild(stateImg)

			-- 重设信息背景坐标
			bgSprite:setPosition(220, 750+figureRect.height*0.5*heroScale)
		end, 0.001)

		local bgSize = bgSprite:getContentSize()
		-- 境界信息
		local stateStr
		if self.mPvpFightInfo.TargetInfo.PVPInterState >= 6 then
			stateStr = TR("%s%d分", stateInfo.name, self.mPvpFightInfo.TargetInfo.Rate)
		else
			stateStr = TR("%s%s阶", stateInfo.name, labelRef[self.mPvpFightInfo.TargetInfo.PVPInterStep])
		end
		local stateNode = ui.newLabel({
			text = stateStr,
			color = cc.c3b(0x62, 0x2f, 0x0e),
		})
		stateNode:setPosition(bgSize.width * 0.5, 80)
		bgSprite:addChild(stateNode)

		-- 玩家名称
		local quality = HeroModel.items[self.mPvpFightInfo.TargetInfo.HeroModelId].quality
		local playerName = ui.newLabel({
			text = self.mPvpFightInfo.TargetInfo.Name,
			color = Utility.getQualityColor(quality, 1),
			shadowColor = Enums.Color.eShadowColor,
		})
		playerName:setPosition(bgSize.width * 0.5, 47)
		bgSprite:addChild(playerName)

		-- 战力
		local fap = ui.newLabel({
			text = TR("战力: %s", Utility.numberFapWithUnit(self.mPvpFightInfo.TargetInfo.FAP)),
			color = Enums.Color.eNormalWhite,
			outlineColor = Enums.Color.eOutlineColor,
		})
		fap:setPosition(bgSize.width * 0.5, 17)
		bgSprite:addChild(fap)
	end

	-- 随机2~5秒时间来结束动画
	local time = math.floor(math.random(2, 5))	-- 总时间
	local timeIncrement = 0.2					-- 时间增量
	local tempTime = 0							-- 当前时间
	Utility.schedule(self.mParentLayer, function()
		tempTime = tempTime + timeIncrement
		if tempTime >= time then
			self.mParentLayer:stopAllActions()
			self.mRole:stopAllActions()
			-- 播放选定音效
			MqAudio.playEffect("luo.mp3")

			if not tolua.isnull(self.mRole) then
				self.mRole:removeFromParent()
				self.mRole = nil
			end

			createPlayerInfo()

			Utility.performWithDelay(self.mParentLayer, function()		
				LayerManager.addLayer({
                    name = "challenge.PvpInterFightLayer",
                    data = {
                        teamsInfo = clone(PlayerAttrObj:getPlayerInfo()),
                        targetInfo = self.mPvpFightInfo.TargetInfo,
                        serverData = self.mPvpFightInfo,
                    },
                })
                LayerManager.deleteStackItem("challenge.PvpInterMatchLayer")
			end, 1)
		end
		-- 播放敲鼓音效
		MqAudio.playEffect("gu.mp3")
	end, timeIncrement)
end

return PvpInterMatchLayer