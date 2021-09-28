--[[
	文件名：ActivityChargeSingleLayer.lua
	描述：单笔充值页面, 模块Id为：
        ModuleSub.eTimedChargeSingle    -- "限时-单笔充值"
        ModuleSub.eCommonHoliday2       -- "通用活动-单笔充值"
        ModuleSub.eChristmasActivity2   -- "圣诞活动-单笔充值"
    效果图：x限时活动-单笔充值.jpg
	创建人：libowen
	创建时间：2016.5.19
--]]

local ActivityChargeSingleLayer = class("ActivityChargeSingleLayer", function(params)
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
function ActivityChargeSingleLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	-- 初始化数据
	self.mActivityId = params.activityIdList[1].ActivityId      -- 单笔充值只有一个活动Id

	-- 添加页面UI
	self:initUI()

    -- 是否有缓存数据
    local tempData = self.mLayerData
    if tempData then
        print("------单笔充值：读取缓存数据------")
        -- 保存数据
        self.mSingleChargeInfo = tempData

        -- 配置礼包信息表
        self:configSingleChargeList()

        -- 刷新页面
        self:refreshLayer()
    else
        print("------单笔充值：缓存无数据，请求服务器------")
        self:requestGetChargeSingleInfo()
    end
end

-- 获取恢复数据
function ActivityChargeSingleLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- UI相关
function ActivityChargeSingleLayer:initUI()
	--  父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

    -- 上方背景
    local topBg = ui.newSprite("xshd_09.jpg")
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

    -- 下方背景
    local mBottomBg = ui.newScale9Sprite("c_19.png", cc.size(640, 667))
    mBottomBg:setAnchorPoint(cc.p(0.5, 0))
    mBottomBg:setPosition(320, 75)
    self.mParentLayer:addChild(mBottomBg)

    self.mUnderSprite = ui.newScale9Sprite("c_17.png", cc.size(608, 590))
    self.mUnderSprite:setPosition(320, 405)
    self.mParentLayer:addChild(self.mUnderSprite)

    -- 活动倒计时
    self.mTimeLabel = ui.newLabel({
        text = "",
        color = Enums.Color.eWhite,
        size = 22,
        outlineColor = cc.c3b(0x30, 0x30, 0x30)
    })
    self.mTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mTimeLabel:setPosition(30, 815)
    self.mParentLayer:addChild(self.mTimeLabel)

    -- 最大充值数
    self.mMaxChargeNum = ui.newLabel({
        text = "",
        color = Enums.Color.eWhite,
        size = 22,
        outlineColor = cc.c3b(0x30, 0x30, 0x30)
    })
    self.mMaxChargeNum:setAnchorPoint(cc.p(0, 0.5))
    self.mMaxChargeNum:setPosition(30, 785)
    self.mParentLayer:addChild(self.mMaxChargeNum)

    -- 充值按钮
    local chargeBtn = ui.newButton({
        normalImage = "tb_21.png",
        position = cc.p(570, 790),
        clickAction = function()
            LayerManager.showSubModule(ModuleSub.eCharge)
        end
    })
    self.mParentLayer:addChild(chargeBtn)

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

-- 创建充值礼包滑动窗体
function ActivityChargeSingleLayer:createListView()
    -- 创建ListView视图
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
function ActivityChargeSingleLayer:configSingleChargeList()
    self.mSingleChargeList = {}
    -- 按照充值奖励，1：能领取 0：不能领取 2：已经领取来存放
    for k, v in ipairs(self.mSingleChargeInfo.ChargeSingleDrawNums) do
        if v.Status == 1 then
            table.insert(self.mSingleChargeList, v)
        end
    end

    for k, v in ipairs(self.mSingleChargeInfo.ChargeSingleDrawNums) do
        if v.Status == 0 then
            table.insert(self.mSingleChargeList, v)
        end
    end

    for k, v in ipairs(self.mSingleChargeInfo.ChargeSingleDrawNums) do
        if v.Status == 2 then
            table.insert(self.mSingleChargeList, v)
        end
    end
end

-- 刷新页面，包括上方的几个标签，下方的滑动视图
function ActivityChargeSingleLayer:refreshLayer()
    -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    -- 刷新最大充值数
    self.mMaxChargeNum:setString(TR("最大充值数:  %s%d%s元宝", "#1fee32",
                                    self.mSingleChargeInfo.ChargeMaxSingleReward, Enums.Color.eWhiteH))

    -- 刷新礼包列表
    self:refreshListView()
end

-- 活动倒计时
function ActivityChargeSingleLayer:updateTime()
    local timeLeft = self.mSingleChargeInfo.HLHKSingleRecharge - Player:getCurrentTime()
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

-- 刷新充值礼包窗体
--[[
    params:
    id                      -- 礼包id号
--]]
function ActivityChargeSingleLayer:refreshListView(id)
    -- 点击领取之后，刷新缓存数据
    if id then
        for i, v in ipairs(self.mSingleChargeInfo.ChargeSingleDrawNums) do
            if v.Id == id then
                v.Status = 2
            end
        end
        self.mLayerData = self.mSingleChargeInfo
        self:configSingleChargeList()
    end

    -- 移除所有并重新添加
    self.mListView:removeAllItems()
    for i = 1, table.maxn(self.mSingleChargeList) do
        self.mListView:pushBackCustomItem(self:createCellByIndex(i))
    end
end

-- 创建每一个条目
--[[
    params:
    index                       -- 充值奖励条目的索引号
--]]
function ActivityChargeSingleLayer:createCellByIndex(index)
    local cellInfo = self.mSingleChargeList[index]

    -- 创建cell
    local cellWidth, cellHeight = 598, 145
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

     -- cell背景框
    local cellBg = ui.newScale9Sprite("c_18.png", cc.size(cellWidth - 10, cellHeight-5))
    cellBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
    customCell:addChild(cellBg)
    local cellBgSize = cellBg:getContentSize()

    -- ”单笔充值“
    local chargeLabel = ui.newLabel({
        text = TR("单笔充值: %s%d%s 元宝", "#249029", cellInfo.Id, "#46220d"),
        anchorPoint = cc.p(0, 0.5),
        color = cc.c3b(0x46, 0x22, 0x0d),
        -- outlineColor = cc.c3b(0x30, 0x30, 0x30),
        size = 20,
        x = cellBgSize.width * 0.06,
        y = cellBgSize.height * 0.85
    })
    cellBg:addChild(chargeLabel)

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
        maxViewWidth = 450,
        space = 20,
        cardDataList = rewardList,
        allowClick = true,
        cardShape = Enums.CardShape.eSquare
    })
    rewardListView:setAnchorPoint(cc.p(0, 0.5))
    rewardListView:setPosition(cellBgSize.width * 0.06, cellBgSize.height * 0.38)
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
            self:requestDrawSingleChargeReward(cellInfo.Id)
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

---------------------------网络相关------------------------------
-- 未获取缓存数据，则请求服务器，获取玩家单笔充值的相关信息
function ActivityChargeSingleLayer:requestGetChargeSingleInfo()
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "GetChargeSingleInfo",
        svrMethodData = {self.mActivityId},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestGetChargeSingleInfo", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mLayerData = data.Value
            self.mSingleChargeInfo = data.Value

            -- 配置礼包信息表
            self:configSingleChargeList()

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 请求服务器，领取单笔充值相应的奖励
--[[
    params:
    id                              -- 单笔充值相应的礼包id号
--]]
function ActivityChargeSingleLayer:requestDrawSingleChargeReward(id)
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "DrawSingleChargeReward",
        svrMethodData = {self.mActivityId, id},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestDrawSingleChargeReward", 10)

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

return ActivityChargeSingleLayer
