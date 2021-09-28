--[[
	文件名：PvpInterRewardLayer.lua
	文件描述：浑源之战赛季奖励页面
	创建人：chenqiang
	创建时间：2017.07.31
]]

local PvpInterRewardLayer = class("PvpInterRewardLayer", function()
	return display.newLayer()
end)

-- 构造函数
--[[
	pvpInfo: 跨服战信息
	seasonInfo: 赛季信息
	isInTruce: 休战状态
	callback: 回调函数
]]
function PvpInterRewardLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	params = params or {}
	self.mPvpInfo = params.pvpInfo
	self.mSeasonInfo = params.seasonInfo
	self.mIsInTruce = params.isInTruce
	self.callback = params.callback
	-- 宝箱信息
	self.mBoxInfo = self.mPvpInfo.SeasonWinBox

	-- 背景大小
    self.mBgSize = cc.size(608, 950)
    -- 列表大小
    self.mListSize = cc.size(546, 795)
    -- 列表项大小
    self.mCellSize = cc.size(546, 160)

    local popBgLayer = require("commonLayer.PopBgLayer").new({
		bgSize = self.mBgSize,
		title = TR("赛季奖励"),
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(popBgLayer)

	-- 背景对象
	self.mBgSprite = popBgLayer.mBgSprite

    -- 整理数据
    self:handleData()
    -- 初始化UI
    self:initUI()
end

-- 整理数据
function PvpInterRewardLayer:handleData()
	self.mRewardList = {}

	for key, item in pairs(clone(PvpinterSeasonWinRewardModel.items)) do
		item.statusNum = self.mBoxInfo[tostring(key)]
		item.status = self.mBoxInfo[tostring(key)] == 1 and true or false
		table.insert(self.mRewardList, item)
	end

	table.sort(self.mRewardList, function(item1, item2)
		-- 领取状态
		if item1.status and not item2.status then
			return true
		end
		if not item1.status and item2.status then
			return false
		end

		-- 不能领取状态（未完成 > 已领取）
		if item1.statusNum ~= item2.statusNum then
			return item1.statusNum < item2.statusNum
		end

		-- 场次
		if item1.winNum ~= item2.winNum then
			return item1.winNum < item2.winNum
		end

		return false
	end)
end

-- 初始化UI
function PvpInterRewardLayer:initUI()
	-- 赛季结束时间
	if self.mIsInTruce then
		local tempLabel = ui.createSpriteAndLabel({
			imgName = "c_25.png",
			scale9Size = cc.size(500, 54),
			labelStr = TR("赛季休战中"),
			fontColor = Enums.Color.eYellow,
			outlineColor = Enums.Color.eOutlineColor,
			fontSize = 25,
		})
		tempLabel:setPosition(self.mBgSize.width * 0.5, 860)
		self.mBgSprite:addChild(tempLabel)
	else
		local timeLabel = ui.createSpriteAndLabel({
			imgName = "c_25.png",
			scale9Size = cc.size(500, 54),
			labelStr = TR("赛季倒计时: %s%s", Enums.Color.eYellowH, "00:00:00"),
			fontSize = 25,
			fontColor = Enums.Color.eNormalWhite,
			outlineColor = Enums.Color.eOutlineColor,
		})
		timeLabel:setAnchorPoint(cc.p(0.5, 0.5))
		timeLabel:setPosition(self.mBgSize.width * 0.5, 860)
		self.mBgSprite:addChild(timeLabel)
		-- 计时器
		local time = self.mSeasonInfo.EndDate - Player:getCurrentTime() - 3600
		Utility.schedule(timeLabel, function()
			time = time - 1
			local timeStr = MqTime.formatAsDay(time)
			timeLabel:setString(TR("赛季倒计时: %s%s", Enums.Color.eYellowH, timeStr))
		end, 1)
	end

	-- 奖励背景
	local bgSprite = ui.newScale9Sprite("c_17.png", cc.size(546, 805))
	bgSprite:setAnchorPoint(cc.p(0.5, 0))
	bgSprite:setPosition(self.mBgSize.width * 0.5, 25)
	self.mBgSprite:addChild(bgSprite)

	-- listView
	self.mListView = ccui.ListView:create()
	self.mListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mListView:setContentSize(self.mListSize)
	self.mListView:setAnchorPoint(cc.p(0.5, 0))
	self.mListView:setPosition(self.mBgSize.width * 0.5, 30)
	self.mListView:setItemsMargin(10)
	self.mListView:setBounceEnabled(true)
	self.mBgSprite:addChild(self.mListView)

	self:refreshListView()
end

-- 刷新列表
function PvpInterRewardLayer:refreshListView()
	self.mListView:removeAllChildren()
	
	for index, item in pairs(self.mRewardList) do
		local cellItem = ccui.Layout:create()
		cellItem:setContentSize(self.mCellSize)
		self.mListView:pushBackCustomItem(cellItem)

		self:refreshListItem(index)
	end
end

-- 刷新列表单个条目
function PvpInterRewardLayer:refreshListItem(index)
	local cellItem = self.mListView:getItem(index - 1)
	if not cellItem then
		cellItem = ccui.Layout:create()
		cellItem:setContentSize(self.mCellSize)
		self.mListView:insertCustomItem(index - 1, cellItem)
	end
	cellItem:removeAllChildren()

	-- 条目背景
	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(540, 160))
	bgSprite:setPosition(self.mCellSize.width * 0.5, self.mCellSize.height * 0.5)
	cellItem:addChild(bgSprite)

	-- 卡牌
	local rewardInfo = Utility.analysisStrResList(self.mRewardList[index].reward)
	local rewardCard = ui.createCardList({
		maxViewWidth = 350,
		cellWidth = 100,
		viewHeight = 100,
		space = 0,
		cardDataList = rewardInfo,
		allowClick = true,
	})
	rewardCard:setAnchorPoint(cc.p(0, 0.5))
	rewardCard:setPosition(20, self.mCellSize.height * 0.47)
	cellItem:addChild(rewardCard)

	-- 达成条件
	local winLabel = ui.newLabel({
		text = TR("本赛季获得%s%d/%d%s胜", "#D74F34", self.mPvpInfo.TotalWinCount, self.mRewardList[index].winNum, Enums.Color.eBlackH),
		color = Enums.Color.eBlack,
		size = 22,
	})
	winLabel:setAnchorPoint(cc.p(0, 0.5))
	winLabel:setPosition(25, self.mCellSize.height * 0.87)
	cellItem:addChild(winLabel)

	-- 领取按钮
	local getBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("领取"),
		clickAction = function()
			self:requestRewardSeasonWinBox(self.mRewardList[index].winNum)
		end
	})
	getBtn:setPosition(self.mCellSize.width * 0.83, self.mCellSize.height * 0.5)
	cellItem:addChild(getBtn)

	-- 判断按钮状态
	if self.mBoxInfo[tostring(self.mRewardList[index].winNum)] == 0 then
		getBtn:setEnabled(false)
	elseif self.mBoxInfo[tostring(self.mRewardList[index].winNum)] == 1 then
		getBtn:setEnabled(true)
	elseif self.mBoxInfo[tostring(self.mRewardList[index].winNum)] == 2 then
		getBtn:setTitleText(TR("已经领取"))
		getBtn:setEnabled(false)
	end
end

-- ==================== 网络请求相关 =======================
-- 领取奖励请求
function PvpInterRewardLayer:requestRewardSeasonWinBox(num)
	HttpClient:request({
		moduleName = "PVPinter",
		methodName = "RewardSeasonWinBox",
		svrMethodData = {num},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end

			self.mPvpInfo = response.Value.PVPinterInfo
			self.mBoxInfo = self.mPvpInfo.SeasonWinBox

			-- 整理宝箱配置信息
    		self:handleData()
			-- 刷新宝箱信息
			self:refreshListView()

			if self.callback then
				self.callback(response.Value.PVPinterInfo)
			end

			ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
		end
	})
end

return PvpInterRewardLayer