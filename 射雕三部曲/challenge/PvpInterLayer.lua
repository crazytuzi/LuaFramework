--[[
	文件名：PvpInterLayer.lua
	文件描述：武林争霸页面（个人PVP）
	创建人：chenqiang
	创建时间：2017.07.31
]]

local PvpInterLayer = class("PvpInterLayer", function()
	return display.newLayer()
end)

-- 构造函数
function PvpInterLayer:ctor()
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	-- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 顶部资源栏和底部导航栏
	local commonLayer = require("commonLayer.CommonLayer"):create({
		needMainNav = true,
		currentLayerType = Enums.MainNav.eChallenge,
		topInfos = {
			ResourcetypeSub.eDiamond,
			ResourcetypeSub.eGold,
			ResourcetypeSub.eSTA,
		}
	})
	self:addChild(commonLayer)

	-- 初始化UI
	self:initUI()

	-- 请求跨服战信息
	self:requestGetPVPInterInfo()
end

-- 初始化UI
function PvpInterLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("qxzb_4.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 中间控件的背景
	local tempSprite = ui.newSprite("qxzb_3.png")
	tempSprite:setPosition(320, 455)
	self.mParentLayer:addChild(tempSprite)

	-- 玩家信息层
	self.mPlayerInfoNode = cc.Node:create()
	self.mParentLayer:addChild(self.mPlayerInfoNode)

	-- 返回按钮
	local closeBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	closeBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
	self.mParentLayer:addChild(closeBtn)

	-- 匹配按钮
	local matchBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("匹 配"),
		clickAction = function()
			self:requestFightForMatch()
		end
	})
	matchBtn:setPosition(320, 245)
	self.mParentLayer:addChild(matchBtn)
	self.mMatchBtn = matchBtn

	-- 消耗耐力
	local STANum = PvpinterConfig.items[1].fightSTA
	local costLabel = ui.createSpriteAndLabel({
		imgName = "c_23.png",
		scale9Size = cc.size(119, 30),
		labelStr = string.format("{%s}-%d", "db_1103.png", STANum),
		fontSize = 25,
		fontColor = Enums.Color.eNormalWhite,
		outlineColor = Enums.Color.eOutlineColor,
	})
	costLabel:setPosition(325, 180)
	self.mParentLayer:addChild(costLabel)

	-- 赛季剩余时间
	local timeLabel = ui.newLabel({
		text = TR("赛季结束时间: %s", "00:00:00"),
		size = 25,
		color = Enums.Color.eYellow,
		outlineColor = Enums.Color.eOutlineColor,
	})
	timeLabel:setAnchorPoint(cc.p(0.5, 1))
	timeLabel:setPosition(320, 320)
	self.mParentLayer:addChild(timeLabel)
	self.mTimeLabel = timeLabel

	-- 创建中间按钮（战报、排行榜、商店、...）
	self:createMiddleBtns()
	-- 创建宝箱信息
	self:createBoxInfo()
end

-- 创建中间按钮
function PvpInterLayer:createMiddleBtns()
	local btnInfos = {
		{	-- 排行榜
			normalImage = "tb_16.png",
			clickAction = function()
				LayerManager.addLayer({name = "challenge.PvpInterRankLayer", cleanUp = false})
			end
		},
		{ 	-- 战报
			normalImage = "tb_121.png",
			clickAction = function()
				LayerManager.addLayer({name = "challenge.PvpInterReportLayer", cleanUp = false})
			end
		},
		{	-- 商店
			normalImage = "tb_178.png",
			clickAction = function()
				LayerManager.addLayer({
					name = "challenge.PvpInterShopLayer",
					cleanUp = true,
				})
			end
		},
		{	-- 赛季奖励
			normalImage = "tb_179.png",
			showRedDot = true,
			clickAction = function()
				LayerManager.addLayer({
					name = "challenge.PvpInterRewardLayer",
					data = {
						pvpInfo = self.mPvpInterInfo,
						seasonInfo = self.mPvpInterSeasonInfo,
						isInTruce = self.mInTruceState,
						callback = function(info)
							self:refreshPvpInterData(info)
						end
					},
					cleanUp = false,
				})
			end
		},
		{	-- 规则
			normalImage = "tb_127.png",
			clickAction = function()
				MsgBoxLayer.addRuleHintLayer(TR("规则"), {
					[1] = TR("1、武林争霸共分为6个阶段，初入江湖、小有名气、名动一方、天下闻名、一代宗师、登峰造极"),
					[2] = TR("2、登峰造极以下以获得若干颗星数作为晋升条件，每胜利一场获得一星，失败一场减少一星；登峰造极后获胜加积分，失败减积分"),
					[3] = TR("3、若玩家达到3连胜，则之后的每场胜利可以额外获得1颗星星直到玩家战败为止"),
					[4] = TR("4、每两周（14天）为一个赛季，每个赛季最后一天晚23点-24点通过领奖中心发放赛季奖励"),
					[5] = TR("5、上赛季的最终阶段越高，新赛季初始阶段越高"),
				})
			end
		}
	}

	for index, btnInfo in ipairs(btnInfos) do
		local tempBtn = ui.newButton(btnInfo)
		tempBtn:setPosition(80 + (index - 1) * 120, 425)
		self.mParentLayer:addChild(tempBtn)

		-- 小红点信息
		if btnInfo.showRedDot then
			local function dealRedDotInfo(tempSprite)
				local redDot = RedDotInfoObj:isValid(ModuleSub.ePVPInter, "SeasonWinBox")
				tempSprite:setVisible(redDot)
			end
			ui.createAutoBubble({refreshFunc = dealRedDotInfo, parent = tempBtn,
        	    eventName = RedDotInfoObj:getEvents(ModuleSub.ePVPInter, "SeasonWinBox")})
		end
	end
end

-- 创建玩家段位星数信息
function PvpInterLayer:refreshPlayerInfo()
	self.mPlayerInfoNode:removeAllChildren()

	local pvpInterStateInfo = PvpinterStateRelation.items[self.mPvpInterInfo.State or 1]

	-- 境界图片
	local realmImg = ui.newSprite(pvpInterStateInfo.stateHeadFrame2 .. ".png")
	realmImg:setAnchorPoint(cc.p(0.5, 0))
	realmImg:setPosition(320, 630)
	self.mPlayerInfoNode:addChild(realmImg)

	local labelStr, winLabelStr
	if self.mPvpInterInfo.State < 6 then  -- 浑源境以下
		winLabelStr = TR("胜利星数")

		-- 境界
		local tempSprite = ui.newSprite("qxzb_20.png")
		tempSprite:setPosition(320, 620)
		self.mParentLayer:addChild(tempSprite)
		-- 阶位
		local stepSprite = ui.newNumberLabel({
			text = self.mPvpInterInfo.Step,
			imgFile = "qxzb_19.png",
			startChar = 49,
		})
		stepSprite:setPosition(290, 620)
		self.mParentLayer:addChild(stepSprite)

		-- 星数
		for index = 1, pvpInterStateInfo.perStepStars do
			local tempSprite = ui.newSprite("c_75.png")
			tempSprite:setAnchorPoint(cc.p(0.5, 0.5))
			tempSprite:setPosition(310 + 50 * (index - 1), 507)
			self.mPlayerInfoNode:addChild(tempSprite)
			tempSprite:setGray(index > self.mPvpInterInfo.Star)
		end
	else   -- 浑源境
		winLabelStr = TR("胜利积分:")

		-- 积分
		local scoreLabel = ui.newLabel({
			text = self.mPvpInterInfo.Rate or 0,
			size = 28,
			color = Enums.Color.eNormalWhite,
			outlineColor = Enums.Color.eOutlineColor,
		})
		scoreLabel:setAnchorPoint(cc.p(0, 0.5))
		scoreLabel:setPosition(310, 507)
		self.mPlayerInfoNode:addChild(scoreLabel)
	end

	-- 星数/积分文本
	local winLabel = ui.newLabel({
		text = winLabelStr,
		color = Enums.Color.eYellow,
		size = 30,
		outlineColor = Enums.Color.eOutlineColor,
	})
	winLabel:setAnchorPoint(cc.p(1, 0.5))
	winLabel:setPosition(280, 507)
	self.mPlayerInfoNode:addChild(winLabel)
end

-- 创建玩家宝箱信息
function PvpInterLayer:createBoxInfo()
	-- 场次宝箱
	local challengeBoxProg = require("common.ProgressBar"):create({
		bgImage = "qxzb_1.png",
		barImage = "qxzb_2.png",
		currValue = 0,
		maxValue = 1,
	})
	challengeBoxProg:setPosition(130, 1020)
	self.mParentLayer:addChild(challengeBoxProg)
	self.mChallengeBoxProg = challengeBoxProg
	-- 宝箱
	local boxSprite = ui.newButton({
		normalImage = "r_05.png",
		clickAction = function()
			LayerManager.addLayer({
				name = "challenge.PvpInterRewardBoxLayer",
				data = {
					isWinBox = false, 
					pvpInfo = self.mPvpInterInfo,
					callback = function(info)
						self:refreshPvpInterData(info)
					end
				},
				cleanUp = false,
			})
		end
	})
	boxSprite:setPosition(50, 1023)
	self.mParentLayer:addChild(boxSprite)
	self.mChallengeBox = boxSprite
	-- 场次文本
	local challengeBoxLabel = ui.newLabel({
		text = TR("挑战宝箱\n挑战%d/%d场", 0, 1),
		color = Enums.Color.eNormalWhite,
		size = 20,
		outlineColor = Enums.Color.eOutlineColor,
	})
	challengeBoxLabel:setAnchorPoint(cc.p(0, 0.5))
	challengeBoxLabel:setPosition(110, 1023)
	self.mParentLayer:addChild(challengeBoxLabel)
	self.mChallengeBoxLabel = challengeBoxLabel
	-- 宝箱事件
	local function dealChallengeBox()
		local redDot = RedDotInfoObj:isValid(ModuleSub.ePVPInter, "ChallengeBox")
		self:refreshChallengeBoxInfo()
	end
	Notification:registerAutoObserver(self.mChallengeBox, dealChallengeBox, {EventsName.eRedDotPrefix .. ModuleSub.ePVPInter})

	-- 胜利宝箱
	local winBoxProg = require("common.ProgressBar"):create({
		bgImage = "qxzb_1.png",
		barImage = "qxzb_2.png",
		currValue = 0,
		maxValue = 1,
	})
	winBoxProg:setPosition(380, 1020)
	self.mParentLayer:addChild(winBoxProg)
	self.mWinBoxProg = winBoxProg
	-- 宝箱
	local boxSprite = ui.newButton({
		normalImage = "r_06.png",
		clickAction = function()
			LayerManager.addLayer({
				name = "challenge.PvpInterRewardBoxLayer",
				data = {
					isWinBox = true, 
					pvpInfo = self.mPvpInterInfo,
					callback = function(info)
						self:refreshPvpInterData(info)
					end
				},
				cleanUp = false,
			})
		end
	})
	boxSprite:setPosition(300, 1020)
	self.mParentLayer:addChild(boxSprite)
	self.mWinBox = boxSprite
	-- 场次文本
	local winBoxLabel = ui.newLabel({
		text = TR("胜利宝箱\n胜利%d/%d场", 0, 1),
		color = Enums.Color.eNormalWhite,
		size = 20,
		outlineColor = Enums.Color.eOutlineColor,
	})
	winBoxLabel:setAnchorPoint(cc.p(0, 0.5))
	winBoxLabel:setPosition(360, 1023)
	self.mParentLayer:addChild(winBoxLabel)
	self.mWinBoxLabel = winBoxLabel
	-- 宝箱事件
	local function dealWinBox()
		local redDot = RedDotInfoObj:isValid(ModuleSub.ePVPInter, "WinBox")
		self:refreshWinBoxInfo()
	end
	Notification:registerAutoObserver(self.mWinBox, dealWinBox, {EventsName.eRedDotPrefix .. ModuleSub.ePVPInter})
end

-- 刷新宝箱信息
function PvpInterLayer:refreshBoxInfo()
	-- 刷新场次宝箱信息
	self:refreshChallengeBoxInfo()
	-- 刷新胜利宝箱信息
	self:refreshWinBoxInfo()
end

-- 刷新挑战场次宝箱信息
function PvpInterLayer:refreshChallengeBoxInfo()
	if self.mPvpInterInfo then
		-- 场次宝箱信息
		local challengeBoxInfo = self.mPvpInterInfo.ChallengeBox
		-- 场次宝箱配置信息
		local challengeBoxConfig = PvpinterRewardBoxModel.items[self.mPvpInterInfo.State][false]
		local tempList = {}
		for i, v in pairs(challengeBoxConfig) do
			table.insert(tempList, v)
		end
		table.sort(tempList, function(a, b)
			if a.num ~= b.num then
				return a.num < b.num
			end
		end)

		local tempNum, isDraw, drawDown
		for key, value in pairs(tempList) do
			if challengeBoxInfo[tostring(value.num)] == 0 or challengeBoxInfo[tostring(value.num)] == 1 then -- 不可领取或者可领取
				tempNum = value.num
				if challengeBoxInfo[tostring(value.num)] == 1 then
					isDraw = true
				else
					isDraw = false
				end
				drawDown = false
				break
			end

			tempNum = value.num
			isDraw = false
			drawDown = true
		end

		-- 宝箱显示的当前场次
		local curNum = self.mPvpInterInfo.FightCount > table.maxn(challengeBoxConfig) and 
			table.maxn(challengeBoxConfig) or self.mPvpInterInfo.FightCount
		-- 设置挑战场次宝箱数据
		self.mChallengeBoxProg:setMaxValue(tempNum)
		self.mChallengeBoxProg:setCurrValue(curNum)
		self.mChallengeBoxLabel:setString(TR("挑战宝箱\n挑战%d/%d场", curNum, tempNum))

		self.mChallengeBox:stopAllActions()
		self.mChallengeBox:setRotation(0)
		if not tolua.isnull(self.mChallengeBox.flashNode) then
			self.mChallengeBox.flashNode:removeFromParent()
	    	self.mChallengeBox.flashNode = nil
	    end
		if isDraw then
			ui.setWaveAnimation(self.mChallengeBox)
		end
		if drawDown then
			self.mChallengeBox:loadTextureNormal("r_14.png")
		end
	end
end

-- 刷新胜利宝箱信息
function PvpInterLayer:refreshWinBoxInfo()
	if self.mPvpInterInfo then
		-- 胜利宝箱信息
		local winBoxInfo = self.mPvpInterInfo.WinBox
		-- 胜利宝箱配置信息
		local winBoxConfig = PvpinterRewardBoxModel.items[self.mPvpInterInfo.State][true]
		local winBoxNumList = table.keys(winBoxConfig)
		table.sort(winBoxNumList, function(num1, num2)
			return num1 < num2
		end)

		local tempNum, isDraw, drawDown
		for key, value in ipairs(winBoxNumList) do
			if winBoxInfo[tostring(value)] == 0 or winBoxInfo[tostring(value)] == 1 then -- 不可领取或者可领取
				tempNum = value
				if winBoxInfo[tostring(value)] == 1 then
					isDraw = true
				else
					isDraw = false
				end
				drawDown = false
				break
			end

			tempNum = value
			isDraw = false
			drawDown = true
		end
		-- 宝箱显示的当前场次
		local curNum = self.mPvpInterInfo.TodayWinCount > winBoxNumList[#winBoxNumList] and 
			winBoxNumList[#winBoxNumList] or self.mPvpInterInfo.TodayWinCount
		-- 设置挑战场次宝箱数据
		self.mWinBoxProg:setMaxValue(tempNum)
		self.mWinBoxProg:setCurrValue(curNum)
		self.mWinBoxLabel:setString(TR("胜利宝箱\n胜利%d/%d场", curNum, tempNum))

		self.mWinBox:stopAllActions()
		self.mWinBox:setRotation(0)
		if not tolua.isnull(self.mWinBox.flashNode) then
			self.mWinBox.flashNode:removeFromParent()
	    	self.mWinBox.flashNode = nil
	    end
	    if isDraw then
			ui.setWaveAnimation(self.mWinBox)
		end
		if drawDown then
			self.mWinBox:loadTextureNormal("r_13.png")
		end
	end
end

-- 领取宝箱后刷新跨服战数据
function PvpInterLayer:refreshPvpInterData(pvpInfo)
	self.mPvpInterInfo = pvpInfo
end

-- 刷新赛季结束时间
function PvpInterLayer:refreshEndDate()
	if self.mInTruceState then
		self.mTimeLabel:setString(TR("赛季休战中"))
		self.mMatchBtn:setEnabled(false)
		return
	end

	local time = self.mPvpInterSeasonInfo.EndDate - Player:getCurrentTime() - 3600
	Utility.schedule(self.mTimeLabel, function()
		time = time - 1
		self.mTimeLabel:setString(TR("赛季结束时间: %s", MqTime.formatAsDay(time)))
		if time == 0 then
			self.mTimeLabel:stopAllActions()
		end
	end, 1)
end

-- ========================== 网络请求相关 ================================
-- 获取跨服战信息
function PvpInterLayer:requestGetPVPInterInfo()
	HttpClient:request({
		moduleName = "PVPinter",
		methodName = "GetPVPInterInfo",
		svrMethodData = {},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end

			-- 跨服战信息
			self.mPvpInterInfo = response.Value.PVPinterInfo
			-- 跨服战赛季信息
			self.mPvpInterSeasonInfo = response.Value.PVPinterSeasonInfo
			-- 休战状态
			self.mInTruceState = response.Value.IsInTruce

			-- 玩家段位信息
			self:refreshPlayerInfo()
			-- 刷新宝箱信息
			self:refreshBoxInfo()
			-- 刷新赛季时间
			self:refreshEndDate()
		end
	})
end

-- 匹配战斗
function PvpInterLayer:requestFightForMatch()
	-- 检测耐力值
	local count = PlayerAttrObj:getPlayerAttr(ResourcetypeSub.eSTA)
	if count < PvpinterConfig.items[1].fightSTA then
		MsgBoxLayer.addGetStaOrVitHintLayer(ResourcetypeSub.eSTA, PvpinterConfig.items[1].fightSTA)
        return
	end
	HttpClient:request({
		moduleName = "PVPinter",
		methodName = "FightForMatch",
		svrMethodData = {},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end

			LayerManager.addLayer({
				name = "challenge.PvpInterMatchLayer",
				data = {pvpFightInfo = response.Value},
			})
		end
	})
end

return PvpInterLayer