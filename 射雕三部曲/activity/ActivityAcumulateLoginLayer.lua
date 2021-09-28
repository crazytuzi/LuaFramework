--[[
    文件名: ActivityAcumulateLoginLayer.lua
	描述: 累计登录页面, 模块Id为：
		ModuleSub.eTimedAcumulateLogin -- "限时-累计登录"
		ModuleSub.eChristmasActivity8 -- "节日活动-累计登录"
	效果图:
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityAcumulateLoginLayer = class("ActivityAcumulateLoginLayer", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
	{
		activityIdList: 活动实体Id列表
		parentModuleId: 该活动的主模块Id

		cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
	}
]]
function ActivityAcumulateLoginLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

    --[[
    -- 是否有缓存数据
    local tempData = self.mLayerData
    if tempData then
        print("------累积登录：读取缓存数据------")
        -- 保存数据
        self.mAcumulateDaysInfo = tempData

        -- 配置礼包信息表
        self:configAcumulateDaysList()

        -- 刷新页面
        self:refreshLayer()
    else
        print("------累积登录：缓存无数据，请求服务器------")
        self:requestGetAcumulateDaysRewardInfo()
    end
    --]]

    -- 凌晨，天数+1，每次必须重新请求
    self:requestGetAcumulateDaysRewardInfo()
end

-- 获取恢复数据
function ActivityAcumulateLoginLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityAcumulateLoginLayer:initUI()
	-- 上方背景
    local topBg = ui.newSprite("xshd_07.jpg")
    topBg:setAnchorPoint(cc.p(0.5, 1))
    topBg:setPosition(320, 1136)
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

    --icon
    -- local upBgSprite = ui.newScale9Sprite("jchd_13.png")
    -- upBgSprite:setAnchorPoint(cc.p(0, 0.5))
    -- upBgSprite:setPosition(10, 920)
    -- self.mParentLayer:addChild(upBgSprite)
    -- local plan = ui.newSprite("xshd_21.png")
    -- plan:setAnchorPoint(cc.p(0, 0.5))
    -- plan:setPosition(70, 52)
    -- upBgSprite:addChild(plan)

    -- -- 下方背景
    self.mBottomBg = ui.newScale9Sprite("c_19.png", cc.size(640, 667))
    self.mBottomBg:setAnchorPoint(cc.p(0.5, 0))
    self.mBottomBg:setPosition(320, 75)
    self.mParentLayer:addChild(self.mBottomBg)

    self.mUnderSprite = ui.newScale9Sprite("c_17.png", cc.size(608, 590))
    self.mUnderSprite:setPosition(320, 405)
    self.mParentLayer:addChild(self.mUnderSprite)

    -- 活动倒计时
    self.mTimeLabel = ui.newLabel({
        text = TR(""),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        size = 22,
    })
    self.mTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mTimeLabel:setPosition(30, 785)
    self.mParentLayer:addChild(self.mTimeLabel)

    -- 当前已登录X天
    self.mLoginLabel = ui.newLabel({
        text = TR(""),
        size = 22,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30)
    })
    self.mLoginLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mLoginLabel:setPosition(30, 815)
    self.mParentLayer:addChild(self.mLoginLabel)

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

    -- 创建礼包窗口
    self:createListView()
end

-- 创建礼包滑动窗体
function ActivityAcumulateLoginLayer:createListView()
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(598, 580))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(304, 585)
    self.mUnderSprite:addChild(self.mListView)
end

-- 配置礼包信息表
function ActivityAcumulateLoginLayer:configAcumulateDaysList()
    self.mAcumulateDaysList = {}
    -- 按照充值奖励，1：能领取 0：不能领取 2：已经领取来存放
    for k, v in ipairs(self.mAcumulateDaysInfo.DrawInfo) do
        if v.Status == 1 then
            table.insert(self.mAcumulateDaysList, v)
        end
    end

    for k, v in ipairs(self.mAcumulateDaysInfo.DrawInfo) do
        if v.Status == 0 then
            table.insert(self.mAcumulateDaysList, v)
        end
    end

    for k, v in ipairs(self.mAcumulateDaysInfo.DrawInfo) do
        if v.Status == 2 then
            table.insert(self.mAcumulateDaysList, v)
        end
    end
end

-- 刷新页面，包括上方的几个标签，下方的滑动视图
function ActivityAcumulateLoginLayer:refreshLayer()
    -- 刷新时间标签，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    -- 刷新当前已登录天数
    self.mLoginLabel:setString(TR("当前已登录:  %s%d%s天", "#1fee32", self.mAcumulateDaysInfo.Days, Enums.Color.eWhiteH))

    -- 刷新礼包列表
    self:refreshListView()
end

-- 活动倒计时
function ActivityAcumulateLoginLayer:updateTime()
    local timeLeft = self.mAcumulateDaysInfo.EndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时:  %s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
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

-- 刷新礼包窗体
--[[
    params:
    dayNum                      -- 礼包所需的登录天数
--]]
function ActivityAcumulateLoginLayer:refreshListView(dayNum)
    -- 点击领取之后，刷新缓存数据
    if dayNum then
    	for i, v in ipairs(self.mAcumulateDaysInfo.DrawInfo) do
    		if v.Day == dayNum then
    			v.Status = 2
    		end
    	end
    	self.mLayerData = self.mAcumulateDaysInfo
        self:configAcumulateDaysList()
    end

    -- 移除所有并重新添加
    self.mListView:removeAllItems()
    for i = 1, table.maxn(self.mAcumulateDaysList) do
        self.mListView:pushBackCustomItem(self:createCellByIndex(i))
    end
end

-- 创建每一个条目
--[[
    params:
    index                       -- 礼包索引号
--]]
function ActivityAcumulateLoginLayer:createCellByIndex(index)
    local cellInfo = self.mAcumulateDaysList[index]

    -- 创建cell
    local cellWidth, cellHeight = 598, 129
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    -- cell背景框
    local cellBg = ui.newScale9Sprite("c_18.png", cc.size(cellWidth - 10, cellHeight-5))
    cellBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
    customCell:addChild(cellBg)
    local cellBgSize = cellBg:getContentSize()

    -- 累计登录X/X天
    local loginLabel = ui.newLabel({
        text = TR("累计登录 %s%d/%d%s天",
        	"#249029",
        	self.mAcumulateDaysInfo.Days,
        	cellInfo.Day,
        	"#46220d"
        ),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        x = cellBgSize.width * 0.73,
        y = cellBgSize.height * 0.8
    })
    loginLabel:setAnchorPoint(cc.p(0, 0.5))
    cellBg:addChild(loginLabel)

    -- 奖励列表
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
        maxViewWidth = 500,
        space = 10,
        cardDataList = rewardList,
        allowClick = true
    })
    rewardListView:setAnchorPoint(cc.p(0, 0.5))
    rewardListView:setPosition(cellBgSize.width * 0.04, cellBgSize.height * 0.5)
    rewardListView:setSwallowTouches(false)
    cellBg:addChild(rewardListView)
    rewardListView:setScale(0.8)

    -- 领取按钮
    local rightBtn = ui.newButton({
        normalImage = "c_28.png",
        clickAction = function()
            self:requestDrawAcumulateDaysReward(cellInfo.Day)
        end,
        text = TR("领取")
    })
    rightBtn:setPosition(cellBgSize.width * 0.85, cellBgSize.height * 0.4)
    cellBg:addChild(rightBtn)

    if cellInfo.Status == 1 then
        rightBtn:setEnabled(true)
    elseif cellInfo.Status == 0 then
        rightBtn:setEnabled(false)
    elseif cellInfo.Status == 2 then
        rightBtn:removeFromParent()

        -- 已领取按钮
        local doneSprite = ui.newSprite("jc_21.png")
        doneSprite:setPosition(cellBgSize.width * 0.83, cellBgSize.height * 0.5)
        cellBg:addChild(doneSprite)
    end

    return customCell
end

---------------------------网络相关------------------------------
-- 请求服务器，获取玩家累积登录的相关信息
function ActivityAcumulateLoginLayer:requestGetAcumulateDaysRewardInfo()
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "GetAcumulateDaysRewardInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestGetAcumulateDaysRewardInfo:", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mLayerData = data.Value
            self.mAcumulateDaysInfo = data.Value

            -- 配置礼包信息表
            self:configAcumulateDaysList()

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 请求服务器，领取累积登录的相应奖励
--[[
    params:
    dayNum                              	-- 礼包所需的登录天数
--]]
function ActivityAcumulateLoginLayer:requestDrawAcumulateDaysReward(dayNum)
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "DrawAcumulateDaysReward",
        svrMethodData = {dayNum},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestDrawAcumulateDaysReward", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 刷新礼包窗口
            self:refreshListView(dayNum)

            -- 飘窗显示奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        end
    })
end

return ActivityAcumulateLoginLayer
