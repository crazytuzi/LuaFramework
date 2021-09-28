--[[
	文件名：PvpInterRewardBoxLayer.lua
	文件描述：浑源之战每日宝箱奖励页面
	创建人：chenqiang
	创建时间：2017.08.01
]]

local PvpInterRewardBoxLayer = class("PvpInterRewardBoxLayer", function()
	return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

-- 构造函数
--[[
	isWinBox: 是否是胜利宝箱（true:是胜利宝箱；false:是场次宝箱）
	pvpInfo: 跨服战信息
	callback: 回调函数
]]
function PvpInterRewardBoxLayer:ctor(params)
	-- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 是否是胜利宝箱
    self.mIsWinBox = params.isWinBox or false
    self.mPvpInfo = params.pvpInfo or {}
    self.callback = params.callback

    -- 背景大小
    self.mBgSize = cc.size(587, 669)

    local popBgLayer = require("commonLayer.PopBgLayer").new({
		bgSize = self.mBgSize,
		title = TR("宝箱奖励"),
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(popBgLayer)

	-- 背景对象
	self.mBgSprite = popBgLayer.mBgSprite

    -- 初始化UI
    self:initUI()
end

-- 初始化UI
function PvpInterRewardBoxLayer:initUI()
	local text = self.mIsWinBox and TR(" 今日已获胜%d场", self.mPvpInfo.TodayWinCount) or
		TR(" 今日已完成%d场挑战", self.mPvpInfo.FightCount)
	local tempLabel = ui.createSpriteAndLabel({
		imgName = "c_63.png",
		labelStr = text,
		fontColor = Enums.Color.eBlack,
		fontSize = 25,
		alignType = ui.TEXT_ALIGN_RIGHT,
	})
	tempLabel:setAnchorPoint(cc.p(0, 0.5))
	tempLabel:setPosition(40, 580)
	self.mBgSprite:addChild(tempLabel)

	-- 背景
	local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(518, 517))
	tempSprite:setAnchorPoint(cc.p(0.5, 0))
	tempSprite:setPosition(self.mBgSize.width * 0.5, 35)
	self.mBgSprite:addChild(tempSprite)

	-- listView
	self.mListView = ccui.ListView:create()
	self.mListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mListView:setContentSize(cc.size(502, 510))
	self.mListView:setAnchorPoint(cc.p(0.5, 0))
	self.mListView:setPosition(self.mBgSize.width * 0.5, 35)
	self.mListView:setItemsMargin(15)
	self.mBgSprite:addChild(self.mListView)

	self:refreshListView()
end

-- 刷新列表
function PvpInterRewardBoxLayer:refreshListView()
	self.mListView:removeAllChildren()
	self.mDataList = {}
	local tempList = clone(PvpinterRewardBoxModel.items[self.mPvpInfo.State][self.mIsWinBox])
	for i, v in pairs(tempList) do
		table.insert(self.mDataList, v)
	end
	table.sort(self.mDataList, function(a, b)
		if a.num ~= b.num then
			return a.num < b.num
		end
	end)

	for index, item in ipairs(self.mDataList) do
		local cellItem = ccui.Layout:create()
		cellItem:setContentSize(cc.size(502, 159))
		self.mListView:pushBackCustomItem(cellItem)

		self:refreshListItem(index)
	end
end

-- 刷新单个列表条目
function PvpInterRewardBoxLayer:refreshListItem(index)
	local cellItem = self.mListView:getItem(index - 1)
	if not cellItem then
		cellItem = ccui.Layout:create()
		cellItem:setContentSize(cc.size(502, 159))
		self.mListView:insertCustomItem(cellItem, index - 1)
	end
	cellItem:removeAllChildren()

	local cellSize = cellItem:getContentSize()
	-- 条目背景
	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(502, 159))
	bgSprite:setPosition(cellSize.width * 0.5, cellSize.height * 0.5)
	cellItem:addChild(bgSprite)

	-- 描述
	local labelStr = self.mIsWinBox and TR("每日获胜%d场，可获得以下奖励", self.mDataList[index].num) or
		TR("每日参加挑战%d场，可获得以下奖励", self.mDataList[index].num)
	local tempLabel = ui.newLabel({
		text = labelStr,
		color = Enums.Color.eBlack,
	})
	tempLabel:setAnchorPoint(cc.p(0.5, 1))
	tempLabel:setPosition(cellSize.width * 0.5, cellSize.height * 0.95)
	cellItem:addChild(tempLabel)

	-- 奖励
	local rewardList = Utility.analysisStrResList(self.mDataList[index].reward)
	local reward = ui.createCardList({
		maxViewWidth = 330,
		cardDataList = rewardList,
	})
	reward:setAnchorPoint(cc.p(0, 0.5))
	reward:setPosition(20, cellSize.height * 0.4)
	cellItem:addChild(reward)

	-- 领取按钮
	local getBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("领取"),
		clickAction = function()
			if self.mIsWinBox then
				self:requestRewardWinBox(self.mDataList[index].num)
			else
				self:requestRewardBox(self.mDataList[index].num)
			end
		end
	})
	getBtn:setPosition(cellSize.width * 0.85, cellSize.height * 0.5)
	cellItem:addChild(getBtn)

	-- 判断领取状态
	if self.mIsWinBox then
		if self.mPvpInfo.WinBox[tostring(self.mDataList[index].num)] == 0 then
			getBtn:setEnabled(false)
		elseif self.mPvpInfo.WinBox[tostring(self.mDataList[index].num)] == 1 then
			getBtn:setEnabled(true)
		elseif self.mPvpInfo.WinBox[tostring(self.mDataList[index].num)] == 2 then
			getBtn:setTitleText(TR("已经领取"))
			getBtn:setEnabled(false)
		end
	else
		if self.mPvpInfo.ChallengeBox[tostring(self.mDataList[index].num)] == 0 then
			getBtn:setEnabled(false)
		elseif self.mPvpInfo.ChallengeBox[tostring(self.mDataList[index].num)] == 1 then
			getBtn:setEnabled(true)
		elseif self.mPvpInfo.ChallengeBox[tostring(self.mDataList[index].num)] == 2 then
			getBtn:setTitleText(TR("已经领取"))
			getBtn:setEnabled(false)
		end
	end
end

-- ============================ 网络请求相关 =========================
-- 领取胜利宝箱请求
function PvpInterRewardBoxLayer:requestRewardWinBox(index)
	HttpClient:request({
		moduleName = "PVPinter",
		methodName = "RewardWinBox",
		svrMethodData = {index},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end

			self.mPvpInfo = response.Value.PVPinterInfo
			-- 刷新宝箱信息
			self:refreshListView()

			if self.callback then
				self.callback(response.Value.PVPinterInfo)
			end

			ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
		end
	})
end

-- 领取挑战场次宝箱请求
function PvpInterRewardBoxLayer:requestRewardBox(index)
	HttpClient:request({
		moduleName = "PVPinter",
		methodName = "RewardBox",
		svrMethodData = {index},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end

			self.mPvpInfo = response.Value.PVPinterInfo
			-- 刷新宝箱信息
			self:refreshListView()

			if self.callback then
				self.callback(response.Value.PVPinterInfo)
			end

			ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
		end
	})
end

return PvpInterRewardBoxLayer