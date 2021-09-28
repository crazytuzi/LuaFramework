--[[
	文件名：ActivityChargeDaysLayer.lua
	描述：累计充值天数页面（包含多个条目，如天天豪礼、天天好礼等），模块Id为：ModuleSub.eChargeDays
	创建人：libowen
	创建时间：2016.5.24
--]]

local ActivityChargeDaysLayer = class("ActivityChargeDaysLayer", function(params)
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
function ActivityChargeDaysLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	-- 添加UI
	self:initUI()
end

-- 获取恢复数据
function ActivityChargeDaysLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 添加UI元素
function ActivityChargeDaysLayer:initUI()
	-- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 上方背景
    local topBg = ui.newSprite("xshd_21.jpg")
    topBg:setAnchorPoint(cc.p(0.5, 1))
    topBg:setPosition(320, 1136)
    self.mParentLayer:addChild(topBg)

    --人物
    local bg = ui.newSprite("xshd_20.png")
    bg:setPosition(380, 615)
    self.mParentLayer:addChild(bg)

    --说明背景
    local decBg = ui.newScale9Sprite("c_145.png", cc.size(383, 100))
    decBg:setAnchorPoint(cc.p(0, 0.5))
    decBg:setPosition(cc.p(-10, 800))
    self.mParentLayer:addChild(decBg)

    --icon
    -- local upBgSprite = ui.newScale9Sprite("jchd_13.png")
    -- upBgSprite:setAnchorPoint(cc.p(0, 0.5))
    -- upBgSprite:setPosition(10, 920)
    -- self.mParentLayer:addChild(upBgSprite)
    -- local plan = ui.newSprite("xshd_25.png")
    -- plan:setAnchorPoint(cc.p(0, 0.5))
    -- plan:setPosition(70, 52)
    -- upBgSprite:addChild(plan)

    -- -- 连续充值
    -- local titleSprite = ui.newSprite("xshd_5.png")
    -- titleSprite:setPosition(180, 320)
    -- topBg:addChild(titleSprite)

    -- 活动倒计时
    local timeLabel = ui.newLabel({
    	text = TR("活动倒计时:"),
    	color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        size = 21,
        align = ui.TEXT_ALIGN_RIGHT
    })
    timeLabel:setAnchorPoint(cc.p(0, 0.5))
    timeLabel:setPosition(25, 825)
    self.mParentLayer:addChild(timeLabel)


    self.mActivityTimeLabel = ui.newLabel({
    	size = 21,
        color = cc.c3b(0xf8, 0xea, 0x3a),
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        text = TR(""),
    })
    self.mActivityTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    local width, height = timeLabel:getContentSize()
    self.mActivityTimeLabel:setPosition(cc.p(150, 825))
    self.mParentLayer:addChild(self.mActivityTimeLabel)

    -- 连续充值天数
    local chargeDaysLabel = ui.newLabel({
    	text = TR("连续充值天数:"),
    	color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        size = 21,
        align = ui.TEXT_ALIGN_RIGHT
    })
    chargeDaysLabel:setAnchorPoint(cc.p(0, 0.5))
    chargeDaysLabel:setPosition(25, 797)
    self.mParentLayer:addChild(chargeDaysLabel)

    self.mChargeDaysLabel = ui.newLabel({
    	size = 21,
        color = cc.c3b(0xff, 0x00, 0x00),
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        text = TR(""),
    })
    self.mChargeDaysLabel:setAnchorPoint(cc.p(0, 0.5))
    local width, height = chargeDaysLabel:getContentSize()
    self.mChargeDaysLabel:setPosition(cc.p(170, 797))
    self.mParentLayer:addChild(self.mChargeDaysLabel)

    -- 今日累计充值数
    local dayTotalChargeNum = ui.newLabel({
    	text = TR("今日累计充值:"),
    	color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        size = 21,
        align = ui.TEXT_ALIGN_RIGHT
    })
    dayTotalChargeNum:setAnchorPoint(cc.p(0, 0.5))
    dayTotalChargeNum:setPosition(25, 770)
    self.mParentLayer:addChild(dayTotalChargeNum)

    self.mDayTotalChargeNum = ui.newLabel({
    	text = TR(""),
        size = 21,
        color = cc.c3b(0xff, 0x00, 0x00),
        outlineColor = cc.c3b(0x30, 0x30, 0x30)
    })
    self.mDayTotalChargeNum:setAnchorPoint(cc.p(0, 0.5))
    self.mDayTotalChargeNum:setPosition(170, 770)
    self.mParentLayer:addChild(self.mDayTotalChargeNum)

    -- -- 充值按钮
    -- local chargeBtn = ui.newButton({
    --     normalImage = "tb_129.png",
    --     position = cc.p(440, 116),
    --     clickAction = function()
    --         LayerManager.showSubModule(ModuleSub.eCharge)
    --     end
    -- })
    -- topBg:addChild(chargeBtn)

	-- 下方背景
    self.mBottomBg = ui.newScale9Sprite("c_19.png", cc.size(640, 1136 - 451))
    self.mBottomBg:setAnchorPoint(cc.p(0.5, 0))
    self.mBottomBg:setPosition(320, 0)
    self.mParentLayer:addChild(self.mBottomBg)

    self.mUnderSprite = ui.newScale9Sprite("c_17.png", cc.size(608, 540))
    self.mUnderSprite:setPosition(320, 378)
    self.mParentLayer:addChild(self.mUnderSprite)

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

    -- 创建活动滑动列表
    self:createListView()

    -- 添加Tabview
    self:addTabView()
end

-- 添加分页控件
function ActivityChargeDaysLayer:addTabView()
    -- 配置分页按钮信息
    local btnInfos = {}
    for i, v in ipairs(self.mActivityIdList) do
        local btnInfo = {
            text = string.format("%s", v.Name),
            tag = i,
			activityId = v.ActivityId
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
            self.mActivityId = self.mActivityIdList[selectBtnTag].ActivityId

            -- 是否有缓存数据
            local tempData = self.mLayerData and self.mLayerData[self.mActivityId]
            if tempData then
                print("------连续充值：读取缓存数据------")
                -- 保存数据
                self.mCurrActivityInfo = tempData

                -- 配置礼包信息表
                self:configActivityList()

                -- 刷新页面
                self:refreshLayer()
            else
                print("------连续充值：缓存无数据，请求服务器------")
                self:requestGetChargeDaysInfo()
            end
        end
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 1))
    tabLayer:setLocalZOrder(-1)
    tabLayer:setPosition(320, 748)
    self.mBottomBg:addChild(tabLayer)


	-- 添加选项卡上的小红点
    for i, info in ipairs(btnInfos) do
		local parentBtn = tabLayer:getTabBtnByTag(info.tag)
		local function dealRedDotVisible(redDotSprite)
            redDotSprite:setVisible(RedDotInfoObj:isValid(ModuleSub.eChargeDays, "ActivityId"..info.activityId))
        end

        ui.createAutoBubble({parent = parentBtn,
            eventName = RedDotInfoObj:getEvents(ModuleSub.eChargeDays, "ActivityId"..info.activityId),
            refreshFunc = dealRedDotVisible})
    end

end

-- 创建滑动列表
function ActivityChargeDaysLayer:createListView()
	-- 创建ListView视图
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(598, 525))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(304, 535)
    self.mUnderSprite:addChild(self.mListView)
end

-- 活动倒计时
function ActivityChargeDaysLayer:updateTime()
    local timeLeft = self.mCurrActivityInfo.ChargeDaysEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mActivityTimeLabel:setString(TR(MqTime.formatAsDay(timeLeft)))
        -- print("更新时间")
    else
        self.mActivityTimeLabel:setString(TR("00:00:00"))

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

-- 刷新两个标签
function ActivityChargeDaysLayer:updateLabels()
	self.mChargeDaysLabel:setString(TR("%s%d%s天", "#1fee32", self.mCurrActivityInfo.ChargeDaysTotal, Enums.Color.eWhiteH))
	self.mDayTotalChargeNum:setString(TR("%s%d%s元宝", "#1fee32", self.mCurrActivityInfo.DailyNum, Enums.Color.eWhiteH))
end

-- 根据序号创建每一个cell
--[[
    params:
    index                       -- 礼包条目的索引号

    returns:
    customCell  				--自定义的cell条
--]]
function ActivityChargeDaysLayer:createCellByIndex(index)
    local cellInfo = self.mCurrActivityList[index]

    -- 创建cell
    local cellWidth, cellHeight = 598, 155
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    -- cell背景框
    local cellBg = ui.newScale9Sprite("c_18.png", cc.size(cellWidth - 10, cellHeight-5))
    cellBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
    customCell:addChild(cellBg)
    local cellBgSize = cellBg:getContentSize()

    -- "连续充值XXX元"标签，NeedNum == 30 用以区分天天豪礼和其他天天好礼之类的
    local str = TR("连续充值%s%d%s元宝: %s%d%s 天",
            "#249029",
            self.mCurrActivityInfo.NeedNum,
            "#46220d",
            "#249029",
            cellInfo.NeedValue,
            "#46220d"
        )
    local chargeLabel = ui.newLabel({
        text = str,
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
        -- outlineColor = cc.c3b(0x30, 0x30, 0x30),
        anchorPoint = cc.p(0, 0.5),
        x = cellBgSize.width * 0.05,
        y = cellBgSize.height * 0.84
    })
    cellBg:addChild(chargeLabel)

    -- 充值奖励列表
    -- 此处服务器返回的数据格式为
    --    {
    --        "Count" = 1,
    --        "ResourceTypeSub" = 1111,
    --        "ModelId" = 0,
    --   }
    -- 为了使用刚哥的便利函数，整理数据
    local rewardList = {}
    for i, v in ipairs(cellInfo.ResourceList) do
        local tempList = {}
        tempList.resourceTypeSub = v.ResourceTypeSub
        tempList.modelId = v.ModelId
        tempList.num = v.Count
        tempList.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}

        table.insert(rewardList, tempList)
    end
    local rewardListView = ui.createCardList({
        maxViewWidth = 460,
        space = 20,
        cardDataList = rewardList,
        allowClick = true
    })
    rewardListView:setAnchorPoint(cc.p(0, 0.5))
    rewardListView:setPosition(cellBgSize.width * 0.05, cellBgSize.height * 0.38)
    cellBg:addChild(rewardListView)
    rewardListView:setScale(0.8)

    -- 右方按钮
    local rightBtn = ui.newButton({
        normalImage = "c_28.png",
        text = "",
        position = cc.p(cellBgSize.width * 0.83, cellBgSize.height * 0.5),
    })
    cellBg:addChild(rightBtn)

    -- 待领取状态
    if cellInfo.Status == 1 then
        rightBtn:setTitleText(TR("领取"))
        rightBtn:setClickAction(function()
            -- 请求领取礼包  cellInfo.Id: 礼包的id号
            self:requestDrawChargeDaysReward(cellInfo.Id)
        end)
    -- 不可领取状态
    elseif cellInfo.Status == 0 then
        rightBtn:setTitleText(TR("去充值"))
        rightBtn:setClickAction(function()
            LayerManager.showSubModule(ModuleSub.eCharge)
        end)
    -- 已领取状态
    elseif cellInfo.Status == 2 then
        -- 移除
        if rightBtn then
            rightBtn:removeFromParent()
        end

        -- 已领取按钮
        local doneSprite = ui.newSprite("jc_21.png")
        doneSprite:setPosition(cellBgSize.width * 0.83, cellBgSize.height * 0.5)
        cellBg:addChild(doneSprite)
    end

    return customCell
end

-- 服务器返回的活动信息，按照领取状态分类存放
function ActivityChargeDaysLayer:configActivityList()
	self.mCurrActivityList = {}

    -- 按照充值奖励，1：能领取 0：不能领取 2：已经领取来存放
    for k, v in ipairs(self.mCurrActivityInfo.ChargeDaysDrawNums) do
        if v.Status == 1 then
            table.insert(self.mCurrActivityList, v)
        end
    end

    for k, v in ipairs(self.mCurrActivityInfo.ChargeDaysDrawNums) do
        if v.Status == 0 then
            table.insert(self.mCurrActivityList, v)
        end
    end

    for k, v in ipairs(self.mCurrActivityInfo.ChargeDaysDrawNums) do
        if v.Status == 2 then
            table.insert(self.mCurrActivityList, v)
        end
    end
end

-- 刷新页面
function ActivityChargeDaysLayer:refreshLayer()
	-- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
	self:updateTime()
	self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

	-- 刷新连续充值天数和日累计充值
	self:updateLabels()

	-- 刷新滑动列表
	self:refreshListView()
end

-- 刷新充值礼包窗体
--[[
    params:
    id                      -- 礼包id号
--]]
function ActivityChargeDaysLayer:refreshListView(id)
	-- 点击领取之后，刷新缓存数据
	if id then
        for i, v in ipairs(self.mCurrActivityInfo.ChargeDaysDrawNums) do
            if v.Id == id then
                v.Status = 2
            end
        end
        self.mLayerData[self.mActivityId] = self.mCurrActivityInfo
	    self:configActivityList()
	end

   	-- 移除所有并重新添加
	self.mListView:removeAllItems()
   	for i = 1, table.maxn(self.mCurrActivityList) do
   		self.mListView:pushBackCustomItem(self:createCellByIndex(i))
   	end
end

--------------------------网络相关-------------------------
-- 请求服务器，获取活动的具体信息
function ActivityChargeDaysLayer:requestGetChargeDaysInfo()
    -- 此处请求任何一个活动id，服务器都会返回累积充值天数这个大类型下的所有活动的详细信息
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "GetChargeDaysInfo",
        svrMethodData = {self.mActivityId},
        callbackNode = self,
        callback = function (data)
        	--dump(data, "requestGetChargeDaysInfo:", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

        	-- 缓存数据
            self.mLayerData = {}
            for i, v in ipairs(data.Value) do
                self.mLayerData[v.ActivityId] = v

                if v.ActivityId == self.mActivityId then
                    self.mCurrActivityInfo = v
                end
            end

            -- 配置礼包信息表
            self:configActivityList()

            -- 刷新页面
    		self:refreshLayer()
        end
    })
end

-- 请求服务器，获取相应的礼包奖励
--[[
	params:
	id   					-- 礼包的id号
--]]
function ActivityChargeDaysLayer:requestDrawChargeDaysReward(id)
	HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "DrawChargeDaysReward",
        svrMethodData = {self.mCurrActivityInfo.ActivityId, id},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestDrawChargeDaysReward", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 刷新页面
            self:refreshListView(id)

            -- 飘窗显示奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        end
    })
end

return ActivityChargeDaysLayer
