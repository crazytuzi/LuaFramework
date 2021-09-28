--[[
	文件名：ActivityChargeTotalLayer.lua
	描述：累计充值页面,模块Id为：
        ModuleSub.eTimedChargeTotal  -- "限时-累积充值"
        ModuleSub.eCommonHoliday1  -- "通用活动-累计充值"
        ModuleSub.eChristmasActivity1  -- "圣诞活动-累计充值"
	创建人：libowen
	创建时间：2016.5.23
--]]

local ActivityChargeTotalLayer = class("ActivityChargeTotalLayer", function(params)
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
function ActivityChargeTotalLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	self.mActivityId = params.activityIdList[1].ActivityId          -- 累积充值只有一个活动Id

	-- 初始化UI
	self:initUI()

    -- 是否有缓存数据
    local tempData = self.mLayerData
    if tempData then
        print("------累计充值：读取缓存数据------")
        -- 保存数据
        self.mTotalChargeInfo = tempData

        -- 配置礼包信息表
        self:configTotalChargeList()

        -- 刷新页面
        self:refreshLayer()
    else
        print("------累计充值：缓存无数据，请求服务器------")
        self:requestGetChargeTotalInfo()
    end
end

-- 获取恢复数据
function ActivityChargeTotalLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- UI相关
function ActivityChargeTotalLayer:initUI()
	-- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 上方背景
    local topBg = ui.newSprite("xshd_11.jpg")
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
    -- local plan = ui.newSprite("xshd_28.png")
    -- plan:setAnchorPoint(cc.p(0, 0.5))
    -- plan:setPosition(70, 52)
    -- upBgSprite:addChild(plan)

    -- 下方背景
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
    self.mTimeLabel:setPosition(30, 815)
    self.mParentLayer:addChild(self.mTimeLabel)

    -- 累计充值数
    self.mTotalChargeNum = ui.newLabel({
        text = TR(""),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        size = 22,
    })
    self.mTotalChargeNum:setAnchorPoint(cc.p(0, 0.5))
    self.mTotalChargeNum:setPosition(30, 785)
    self.mParentLayer:addChild(self.mTotalChargeNum)

    -- -- 充值按钮
    -- local chargeBtn = ui.newButton({
    --     normalImage = "xshd_1.png",
    --     position = cc.p(570, 770),
    --     clickAction = function()
    --         LayerManager.showSubModule(ModuleSub.eCharge)
    --     end
    -- })
    -- self.mParentLayer:addChild(chargeBtn)
    -- 创建礼包列表视图
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

    self:createListView()
end

-- 根据获取到的累计充值信息，创建礼包视图
function ActivityChargeTotalLayer:createListView()
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
function ActivityChargeTotalLayer:configTotalChargeList()
    self.mTotalChargeList = {}
    -- 按照充值奖励，1：能领取 0：不能领取 2：已经领取来存放
    for k, v in ipairs(self.mTotalChargeInfo.ChargeTotalDrawNums) do
        if v.Status == 1 then
            table.insert(self.mTotalChargeList, v)
        end
    end

    for k, v in ipairs(self.mTotalChargeInfo.ChargeTotalDrawNums) do
        if v.Status == 0 then
            table.insert(self.mTotalChargeList, v)
        end
    end

    for k, v in ipairs(self.mTotalChargeInfo.ChargeTotalDrawNums) do
        if v.Status == 2 then
            table.insert(self.mTotalChargeList, v)
        end
    end
end

-- 刷新页面，包括上方的标签文字及下方的礼包视图
function ActivityChargeTotalLayer:refreshLayer()
    -- 更新时间，并倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    -- 刷新累计充值数
    self.mTotalChargeNum:setString(TR("累计充值数:  %s%d%s元宝",
        "#1fee32",
        self.mTotalChargeInfo.ChargeTotalReward,
        Enums.Color.eWhiteH)
    )

    -- 创建充值礼包列表
    self:refreshListView()
end

-- 活动倒计时
function ActivityChargeTotalLayer:updateTime()
    local timeLeft = self.mTotalChargeInfo.HLHKTotalRecharge - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时:  #f8ea3a%s", MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mTimeLabel:setString(TR("活动倒计时:  #f8ea3a%s", "00:00:00"))

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

-- 刷新礼包滑动窗体
--[[
    params:
    id                      -- 礼包id号
--]]
function ActivityChargeTotalLayer:refreshListView(id)
    -- 点击领取之后，刷新缓存数据
    if id then
        for i, v in ipairs(self.mTotalChargeInfo.ChargeTotalDrawNums) do
            if v.Id == id then
                v.Status = 2
            end
        end
        self.mLayerData = self.mTotalChargeInfo
        self:configTotalChargeList()
    end

    -- 移除所有并重新添加
    self.mListView:removeAllItems()
    for i, v in ipairs(self.mTotalChargeList) do
        self.mListView:pushBackCustomItem(self:createCellByIndex(i))
    end
end

-- 创建每一个礼包条目
--[[
    params:
    index                       -- 充值奖励条目的索引号
--]]
function ActivityChargeTotalLayer:createCellByIndex(index)
    local cellInfo = self.mTotalChargeList[index]

    -- 创建cell
    local cellWidth, cellHeight = 598, 145
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    -- cell背景框
    local cellBg = ui.newScale9Sprite("c_18.png", cc.size(cellWidth - 10, cellHeight - 5))
    cellBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
    customCell:addChild(cellBg)
    local cellBgSize = cellBg:getContentSize()

    -- ”再充值XXX元“
    local chargeLabel = ui.newLabel({
        text = TR("再充值: #249029%d#46220d 元宝", cellInfo.NeedValue),
        anchorPoint = cc.p(0, 0.5),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        x = cellBgSize.width * 0.06,
        y = cellBgSize.height * 0.84
    })
    cellBg:addChild(chargeLabel)
    -- 当前充值已完成的话
    if cellInfo.NeedValue == 0 then
        chargeLabel:setString(TR("已完成充值，可领取奖励"))
    end

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
        allowClick = true
    })
    rewardListView:setAnchorPoint(cc.p(0, 0.5))
    rewardListView:setPosition(cellBgSize.width * 0.04, cellBgSize.height * 0.38)
    cellBg:addChild(rewardListView)
    rewardListView:setScale(0.8)

    -- 右方按钮
    local rightBtn = ui.newButton({
        normalImage = "c_28.png",
        text = "",
        -- fontSize = 20,
        position = cc.p(cellBgSize.width * 0.83, cellBgSize.height * 0.5),
    })
    cellBg:addChild(rightBtn)

    -- 待领取状态
    if cellInfo.Status == 1 then
        rightBtn:setTitleText(TR("领取"))
        rightBtn:setClickAction(function()
        	-- 请求服务器，领取相应的礼包奖励
            -- cellInfo.Id: 礼包的id号
            self:requestDrawChargeTotalReward(cellInfo.Id)
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

----------------------网络相关------------------------
-- 请求服务器，获取玩家累计充值信息
function ActivityChargeTotalLayer:requestGetChargeTotalInfo()
    HttpClient:request({
    moduleName = "TimedInfo",
    methodName = "GetChargeTotalInfo",
    svrMethodData = {self.mActivityId},
    callbackNode = self,
    callback = function (data)
        --dump(data, "requestGetChargeTotalInfo", 10)

        -- 容错处理
        if not data.Value or data.Status ~= 0 then
            return
        end

        -- 保存数据
        self.mLayerData = data.Value
        self.mTotalChargeInfo = data.Value

        -- 配置礼包信息表
        self:configTotalChargeList()

        -- 刷新页面
        self:refreshLayer()
    end
})
end

-- 请求服务器，领取相应的礼包
--[[
    params:
    id                              -- 相应的礼包id号
--]]
function ActivityChargeTotalLayer:requestDrawChargeTotalReward(id)
	HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "DrawChargeTotalReward",
        svrMethodData = {self.mActivityId, id},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestDrawChargeTotalReward", 10)

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

return ActivityChargeTotalLayer
