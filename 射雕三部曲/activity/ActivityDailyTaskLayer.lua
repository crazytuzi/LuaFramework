--[[
	文件名：ActivityDailyTaskLayer.lua
	描述：每日挑战活动
	创建人：lengjiazhi
	创建时间：2017.12.13
--]]

local ActivityDailyTaskLayer = class("ActivityDailyTaskLayer", function(params)
	return display.newLayer()
end)

-- 构造函数
--[[
-- 参数 params 中的各项为：
	{
		activityIdList: 活动实体Id列表
		parentModuleId: 该活动的主模块Id

		cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
	}
--]]
function ActivityDailyTaskLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	--当前页签号
	self.mSelectedIndex = 1

	-- 添加UI
	self:initUI()
end

-- 获取恢复数据
function ActivityDailyTaskLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 添加UI元素
function ActivityDailyTaskLayer:initUI()
	-- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	local bgSprite = ui.newSprite("jc_24.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 上方背景
    local topBg = ui.newSprite("jc_12.png")
    topBg:setAnchorPoint(cc.p(0, 0.5))
    topBg:setPosition(0, 890)
    self.mParentLayer:addChild(topBg)

    --人物
    local bg = ui.newSprite("xshd_20.png")
    bg:setPosition(380, 615)
    self.mParentLayer:addChild(bg)

    --说明背景
    local decBg = ui.newScale9Sprite("c_145.png", cc.size(383, 88))
    decBg:setAnchorPoint(cc.p(0, 0.5))
    decBg:setPosition(cc.p(-10, 800))
    self.mParentLayer:addChild(decBg)

    -- 活动倒计时
    self.mTimeLabel = ui.newLabel({
        text = TR("活动倒计时"),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        size = 22,
    })
    self.mTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mTimeLabel:setPosition(30, 800)
    self.mParentLayer:addChild(self.mTimeLabel)

	-- 下方背景
    self.mBottomBg = ui.newScale9Sprite("c_19.png", cc.size(640, 1136 - 451))
    self.mBottomBg:setAnchorPoint(cc.p(0.5, 0))
    self.mBottomBg:setPosition(320, 0)
    self.mParentLayer:addChild(self.mBottomBg)

    self.mUnderSprite = ui.newScale9Sprite("c_17.png", cc.size(608, 540))
    self.mUnderSprite:setPosition(320, 378)
    self.mParentLayer:addChild(self.mUnderSprite)

    -- 创建ListView视图
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(598, 525))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(304, 535)
    self.mUnderSprite:addChild(self.mListView)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)

    self:requestGetInfo()
end

-- 活动倒计时
function ActivityDailyTaskLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时:  %s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
    else
        self.mTimeLabel:setString(TR("活动倒计时:  %s00:00:00", "#f8ea3a"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        -- 重新进入提示
        MsgBoxLayer.addOKLayer(
            TR("%s活动已结束，请重新进入", self.mActivityIdList[1].Name),
            TR("提示"),
            {
                normalImage = "c_28.png",
            },
            {
                normalImage = "c_29.png",
                clickAction = function()
                    LayerManager.addLayer({
                        name = "activity.ActivityMainLayer",
                        data = {moduleId = ModuleSub.eTimedActivity},
                    })
                end
            }
        )
    end
end

--创建页签
function ActivityDailyTaskLayer:addTabView()
	local btnInfos = {}
	for i,v in ipairs(self.mModelInfo) do
		local btnInfo = {
            text = string.format("%s", v.Name),
            tag = i,
            moduleTag = v.ModelId,
        }
        table.insert(btnInfos, btnInfo)
	end

	-- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = btnInfos,
        viewSize = cc.size(640, 80),
        isVert = false,
        space = 14,
        needLine = false,
        defaultSelectTag = 1,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            self.mSelectedIndex = selectBtnTag
            self:refreshListView(selectBtnTag)
        end
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 1))
    tabLayer:setLocalZOrder(-1)
    tabLayer:setPosition(320, 748)
    self.mBottomBg:addChild(tabLayer)

    local tabBtns = tabLayer:getTabBtns()
    for i,v in ipairs(tabBtns) do
        -- 师傅头上小红点
        local subKeyId = "Order" .. btnInfos[i].moduleTag
        print(subKeyId, "iii", i)
        local function dealRedDotVisible(redDotSprite)
            local redDotData = RedDotInfoObj:isValid(ModuleSub.eTimedDailyChallenge, subKeyId)
            redDotSprite:setVisible(redDotData)
        end
        ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = v,
            eventName = RedDotInfoObj:getEvents(ModuleSub.eTimedDailyChallenge, subKeyId)})
    end
end

--刷新列表
function ActivityDailyTaskLayer:refreshListView(tag)
	self.mListView:removeAllChildren()
	local curInfo = self.mModelInfo[tag].RewardList
	table.sort(curInfo, function(a, b)
		if a.RewardStatus == 2 and b.RewardStatus ~= 2 then
			return false
		elseif a.RewardStatus ~= 2 and b.RewardStatus == 2 then
			return true
		end
		if a.OrderId ~= b.OrderId then
			return a.OrderId < b.OrderId 
		end
	end)
	for i,v in ipairs(curInfo) do
		local layout = ccui.Layout:create()
		layout:setContentSize(598, 155)
		--背景
		local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(598, 150))
		bgSprite:setPosition(299, 78)
		layout:addChild(bgSprite)

		--奖励
		local rewardList = Utility.analysisStrResList(v.Reward)
		local rewardListView = ui.createCardList({
	        maxViewWidth = 460,
	        space = 20,
	        cardDataList = rewardList,
	        allowClick = true
	    })
	    rewardListView:setAnchorPoint(cc.p(0, 0.5))
	    rewardListView:setPosition(10, 60)
	    layout:addChild(rewardListView)
	    rewardListView:setScale(0.9)

	    --领取按钮
	    local exchangeBtn = ui.newButton({
	    	normalImage = "c_28.png",
	    	text = TR("领取"),
	    	clickAction = function()
	    		if v.Num > self.mModelInfo[tag].Score then
	    			ui.showFlashView(TR("完成次数不足"))
	    			return
	    		end
	    		self:requestGetReward(v.OrderId)
	    	end
	    	})
	    exchangeBtn:setPosition(520, 60)
	    layout:addChild(exchangeBtn)

        if v.Num > self.mModelInfo[tag].Score then
            exchangeBtn:setEnabled(false)
        end

	    --条件标识
	    local curImpressLabel = ui.newLabel({
	    	text = string.format("%s/%s", self.mModelInfo[tag].Score, v.Num),
	    	color = cc.c3b(0x46, 0x22, 0x0d),
	    	size = 23,
	    	})
	    curImpressLabel:setPosition(520, 110)
	    layout:addChild(curImpressLabel)

	    if v.RewardStatus == 2 then
	    	curImpressLabel:setVisible(false)
	    	exchangeBtn:setVisible(false)
	    	-- 已领取按钮
	        local doneSprite = ui.newSprite("jc_21.png")
	        doneSprite:setPosition(520, 78)
	        layout:addChild(doneSprite)
    	end

	    --提示文字
	    local modelName = ModuleSubModel.items[self.mModelInfo[tag].ModelId].name
	    local tipLabel = ui.newLabel({
	    	text = TR("完成%s次%s", v.Num, modelName),
	    	color = cc.c3b(0x46, 0x22, 0x0d),
	    	size = 22,
	    	})
	    tipLabel:setAnchorPoint(0, 0.5)
	    tipLabel:setPosition(20, 130)
	    layout:addChild(tipLabel)

		self.mListView:pushBackCustomItem(layout)
	end
end
--================================================网络请求=========================================
-- 请求服务器，获取活动的具体信息
function ActivityDailyTaskLayer:requestGetInfo()
    -- 此处请求任何一个活动id，服务器都会返回累积充值天数这个大类型下的所有活动的详细信息
    HttpClient:request({
        moduleName = "TimedDailytask",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
        	dump(data, "requestGetChargeDaysInfo:")

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            self.mModelInfo = data.Value.Info
            self.mEndTime = data.Value.EndTime
   			self:addTabView()

		    self:updateTime()
    		self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
        	
        end
    })
end

-- 请求服务器，获取活动的具体信息
function ActivityDailyTaskLayer:requestGetReward(orderId)
    -- 此处请求任何一个活动id，服务器都会返回累积充值天数这个大类型下的所有活动的详细信息
    HttpClient:request({
        moduleName = "TimedDailytask",
        methodName = "Reward",
        svrMethodData = {orderId},
        callbackNode = self,
        callback = function (data)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            self.mModelInfo[self.mSelectedIndex].RewardList = data.Value.RewardList
            self:refreshListView(self.mSelectedIndex)
            -- 飘窗显示奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        end
    })
end

return ActivityDailyTaskLayer