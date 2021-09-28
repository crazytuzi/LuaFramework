--[[
	文件名：ActivityShareLayer.lua
	描述：facebook分享奖励页面
	创建人：yanghongsheng
	创建时间：2018.7.19
--]]

local ActivityShareLayer = class("ActivityShareLayer", function(params)
	return display.newLayer(cc.c4b(0, 0, 0, 188))
end)


-- 构造函数
--[[
	param:
--]]
function ActivityShareLayer:ctor(params)
	-- 分享次数
	self.mShareNum = 0
	-- 领取过的奖励列表
	self.mReceivedList = {}
	-- 奖励列表
	self.mRewardList = {}
	-- 开始时间
	self.mStartTime = 0
	-- 结束时间
	self.mEndTime = 0

	-- 屏蔽下层触摸
	ui.registerSwallowTouch({node = self})
	-- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化
    self:initUI()

    -- 请求服务器
    self:requestInfo()
end

function ActivityShareLayer:initUI()
	--背景
    local bgSprite = ui.newSprite("fx_1.png")
    bgSprite:setPosition(320, 625)
    self.mParentLayer:addChild(bgSprite)

    -- 关闭按钮
    local closeBtn = ui.newButton({
        normalImage = "c_175.png",
        position = cc.p(560, 950),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)

    -- 分享得好礼
    local titleSprite = ui.newSprite("fx_2.png")
    titleSprite:setPosition(260, 765)
    self.mParentLayer:addChild(titleSprite)
    -- 时间
    local timeSprite = ui.newSprite("fx_3.png")
    timeSprite:setPosition(200, 715)
    self.mParentLayer:addChild(timeSprite)
    -- 至
    local tempSprite = ui.newSprite("fx_8.png")
    tempSprite:setPosition(318, 695)
    self.mParentLayer:addChild(tempSprite)
    -- 分享按钮
    self.shareBtn = ui.newButton({
    	text = TR("分享游戏"),
    	normalImage = "fx_11.png",
    	position = cc.p(280, 390),
    	outlineColor = Enums.Color.eRed,
    	clickAction = function ()
    		-- 分享游戏
			local shareFBData = {
				url = "http://xln.gamedreamer.com/",
			}
			
			local jstr = json.encode(shareFBData)

			IPlatform:getInstance():invoke("ShareToFB",jstr, function(jsonStr) 
				local data = cjson.decode(jsonStr)
				if data["ret"] == "0" then
					ui.showFlashView(TR("分享成功！"))
					--分享成功
					if not self.mIsShare then
						self:requestAddShareNum()
					end
				else
					--分享失败
					ui.showFlashView(TR("分享失败！！"))
				end
			end)
			-- if not self.mIsShare then
			-- 	self:requestAddShareNum()
			-- end
    	end,
	})
	self.mParentLayer:addChild(self.shareBtn)
	-- 左右箭头
	local leftSprite = ui.newSprite("c_26.png")
	leftSprite:setRotation(180)
	leftSprite:setPosition(62, 545)
	self.mParentLayer:addChild(leftSprite)

	local rightSprite = ui.newSprite("c_26.png")
	rightSprite:setPosition(500, 545)
	self.mParentLayer:addChild(rightSprite)
end

function ActivityShareLayer:createTimeLabel(timeTick)
	local date = os.date("*t", timeTick)

	local contentList = {}

	-- 年
	table.insert(contentList, {
		customCb = function()
		    local year = ui.newNumberLabel({
		    		text = date.year,
		    		imgFile = "fx_4.png",
		    	})
		    return year
	    end
	})
	table.insert(contentList, {
		customCb = function()
		    local year = ui.newSprite("fx_5.png")
		    return year
	    end
	})
	-- 月
	table.insert(contentList, {
		customCb = function()
		    local month = ui.newNumberLabel({
		    		text = date.month,
		    		imgFile = "fx_4.png",
		    	})
		    return month
	    end
	})
	table.insert(contentList, {
		customCb = function()
		    local month = ui.newSprite("fx_6.png")
		    return month
	    end
	})
	-- 日
	table.insert(contentList, {
		customCb = function()
		    local day = ui.newNumberLabel({
		    		text = date.day,
		    		imgFile = "fx_4.png",
		    	})
		    return day
	    end
	})
	table.insert(contentList, {
		customCb = function()
		    local day = ui.newSprite("fx_7.png")
		    return day
	    end
	})

	local retLabel = ui.newLabel({
        text = "",
        size = 18,
    })
    retLabel:setContent(contentList)

    return retLabel
end

function ActivityShareLayer:refreshListView()
	if not self.mRewardListView then
		self.mRewardListView = ccui.ListView:create()
	    self.mRewardListView:setDirection(ccui.ScrollViewDir.horizontal)
	    self.mRewardListView:setBounceEnabled(true)
	    self.mRewardListView:setItemsMargin(8)
	    self.mRewardListView:setAnchorPoint(cc.p(0.5, 0.5))
	    self.mRewardListView:setPosition(280, 545)
	    self.mRewardListView:setContentSize(cc.size(376, 140))
	    self.mParentLayer:addChild(self.mRewardListView)
	end

	for i, _ in ipairs(self.mRewardList) do
		self:refreshItem(i)
	end
end

function ActivityShareLayer:refreshItem(index)
	local cellSize = cc.size(120, self.mRewardListView:getContentSize().height)
	local itemInfo = self.mRewardList[index]

	local cellItem = self.mRewardListView:getItem(index-1)
	if not cellItem then
		cellItem = ccui.Layout:create()
		cellItem:setContentSize(cellSize)
		self.mRewardListView:pushBackCustomItem(cellItem)
	end
	cellItem:removeAllChildren()

	local rewardInfo = Utility.analysisStrResList(itemInfo.ResourceList)[1]
	rewardInfo.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
	rewardInfo.onClickCallback = function ()
		-- 已领取
		if self.mReceivedList[itemInfo.Num] then
			return
		-- 可领取
		elseif itemInfo.Num <= self.mShareNum then
			self:requestGetReward(itemInfo.Num)
		-- 不可领取
		else
			CardNode.defaultCardClick(rewardInfo)
		end
	end
	-- 创建卡
	local card = CardNode.createCardNode(rewardInfo)
	card:setPosition(cellSize.width*0.5, 80)
	cellItem:addChild(card)

	-- 需要分享次数
	local numLabel = ui.newLabel({
			text = TR("分享#ffe748%d#37ff40次", itemInfo.Num),
			color = cc.c3b(0x37, 0xff, 0x40),
			outlineColor = Enums.Color.eOutlineColor,
			size = 20,
		})
	numLabel:setPosition(cellSize.width*0.5, 13)
	cellItem:addChild(numLabel)

	-- 状态
	-- 已领取
	if self.mReceivedList[itemInfo.Num] then
		-- 黑遮罩
		local blackSprite = ui.newSprite("fx_13.png")
		blackSprite:setPosition(cellSize.width*0.5, 80)
		blackSprite:setScale(1.3)
		cellItem:addChild(blackSprite)
		-- 已领取
		local getSprite = ui.newSprite("fx_10.png")
		getSprite:setPosition(cellSize.width*0.5, 80)
		cellItem:addChild(getSprite)
	-- 可领取
	elseif itemInfo.Num <= self.mShareNum then
		-- 可领取
		local canGetSprite = ui.newSprite("fx_9.png")
		canGetSprite:setAnchorPoint(cc.p(0, 1))
		canGetSprite:setPosition(10, cellSize.height-10)
		cellItem:addChild(canGetSprite)
	end
end

function ActivityShareLayer:refreshUI()
	-- 时间
	if self.startTime then
		self.startTime:removeFromParent()
		self.startTime = nil
	end
	self.startTime = self:createTimeLabel(self.mStartTime)
	self.startTime:setAnchorPoint(cc.p(0, 0.5))
	self.startTime:setPosition(240, 715)
	self.mParentLayer:addChild(self.startTime)

	if self.endTime then
		self.endTime:removeFromParent()
		self.endTime = nil
	end
	self.endTime = self:createTimeLabel(self.mEndTime)
	self.endTime:setAnchorPoint(cc.p(0.5, 0.5))
	self.endTime:setPosition(315, 640)
	self.mParentLayer:addChild(self.endTime)

	-- 刷新奖励列表
	self:refreshListView()
	
	-- 已分享次数
	if not self.shareCountLabel then
		self.shareCountLabel = ui.newLabel({
				text = "",
				color = Enums.Color.eWhite,
				outlineColor = Enums.Color.eRed,
			})
		self.shareCountLabel:setAnchorPoint(cc.p(1, 0.5))
		self.shareCountLabel:setPosition(280, 435)
		self.mParentLayer:addChild(self.shareCountLabel)

		local hintLabel = ui.newLabel({
				text = TR("(每日只能累计1次)"),
				color = cc.c3b(0xff, 0xe7, 0x48),
				outlineColor = Enums.Color.eOutlineColor,
			})
		hintLabel:setAnchorPoint(cc.p(0, 0.5))
		hintLabel:setPosition(290, 435)
		self.mParentLayer:addChild(hintLabel)
	end
	self.shareCountLabel:setString(TR("已分享%d次#ffe748", self.mShareNum))
end

--------------------------网络相关-----------------------------
-- 请求信息
function ActivityShareLayer:requestInfo()
	HttpClient:request({
	    moduleName = "TimedShare",
	    methodName = "GetInfo",
	    svrMethodData = {},
	    callbackNode = self,
	    callback = function (response)
	    	if not response.Value or response.Status ~= 0 then
	            return
	        end

	        -- 分享次数
	        self.mShareNum = response.Value.ShareInfo.ShareNum
	        -- 已领取分享列表
	        local receivedList = string.splitBySep(response.Value.ShareInfo.ShareRewardIdStr, ",")
	        for _, receivedId in pairs(receivedList) do
	        	self.mReceivedList[tonumber(receivedId)] = true
	        end
	         -- 分享奖励列表
	        self.mRewardList = response.Value.ShareActivityInfo
	        table.sort(self.mRewardList, function (rewardInfo1, rewardInfo2)
	        	-- 已领取
	        	if self.mReceivedList[rewardInfo1.Num] ~= self.mReceivedList[rewardInfo2.Num] then
	        		return not self.mReceivedList[rewardInfo1.Num]
	        	end
	        	-- 可以领取
	        	if (self.mShareNum >= rewardInfo1.Num) ~= (self.mShareNum >= rewardInfo2.Num) then
	        		return (self.mShareNum >= rewardInfo1.Num)
	        	end
	        	return rewardInfo1.Num > rewardInfo2.Num
        	end)
        	-- 开始时间
			self.mStartTime = response.Value.StartDate
			-- 结束时间
			self.mEndTime = response.Value.EndDate
			-- 是否分享过
			self.mIsShare = response.Value.ShareInfo.IsShare

	        self:refreshUI()
	    end
	})
end

-- 分享次数+1
function ActivityShareLayer:requestAddShareNum()
	HttpClient:request({
	    moduleName = "TimedShare",
	    methodName = "Share",
	    svrMethodData = {},
	    callbackNode = self,
	    callback = function (response)
	    	if not response.Value or response.Status ~= 0 then
	            return
	        end

	        -- 是否分享过
			self.mIsShare = true
	        -- 分享次数
	        self.mShareNum = response.Value.ShareInfo.ShareNum
	        -- 已领取分享列表
	        local receivedList = string.splitBySep(response.Value.ShareInfo.ShareRewardIdStr, ",")
	        for _, receivedId in pairs(receivedList) do
	        	self.mReceivedList[tonumber(receivedId)] = true
	        end
	        -- 分享奖励列表
	        self.mRewardList = response.Value.ShareActivityInfo
	        table.sort(self.mRewardList, function (rewardInfo1, rewardInfo2)
	        	-- 已领取
	        	if self.mReceivedList[rewardInfo1.Num] ~= self.mReceivedList[rewardInfo2.Num] then
	        		return not self.mReceivedList[rewardInfo1.Num]
	        	end
	        	-- 可以领取
	        	if (self.mShareNum >= rewardInfo1.Num) ~= (self.mShareNum >= rewardInfo2.Num) then
	        		return (self.mShareNum >= rewardInfo1.Num)
	        	end
	        	return rewardInfo1.Num > rewardInfo2.Num
        	end)

	        self:refreshUI()
	    end
	})
end

-- 领取奖励
function ActivityShareLayer:requestGetReward(shareNum)
	HttpClient:request({
	    moduleName = "TimedShare",
	    methodName = "DrawReward",
	    svrMethodData = {shareNum},
	    callbackNode = self,
	    callback = function (response)
	    	if not response.Value or response.Status ~= 0 then
	            return
	        end

	        ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

	        -- 分享次数
	        self.mShareNum = response.Value.ShareInfo.ShareNum
	        -- 已领取分享列表
	        local receivedList = string.splitBySep(response.Value.ShareInfo.ShareRewardIdStr, ",")
	        for _, receivedId in pairs(receivedList) do
	        	self.mReceivedList[tonumber(receivedId)] = true
	        end
	        -- 分享奖励列表
	        self.mRewardList = response.Value.ShareActivityInfo
	        table.sort(self.mRewardList, function (rewardInfo1, rewardInfo2)
	        	-- 已领取
	        	if self.mReceivedList[rewardInfo1.Num] ~= self.mReceivedList[rewardInfo2.Num] then
	        		return not self.mReceivedList[rewardInfo1.Num]
	        	end
	        	-- 可以领取
	        	if (self.mShareNum >= rewardInfo1.Num) ~= (self.mShareNum >= rewardInfo2.Num) then
	        		return (self.mShareNum >= rewardInfo1.Num)
	        	end
	        	return rewardInfo1.Num > rewardInfo2.Num
        	end)

	        self:refreshUI()
	    end
	})
end

return ActivityShareLayer