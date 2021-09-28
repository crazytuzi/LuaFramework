--[[
    文件名: ActivityUseTotalLayer.lua
	描述: 累积消费页面, 模块Id为：
		ModuleSub.eTimedUseTotal -- "限时-累积消费"
		ModuleSub.eChristmasActivity9-- "节日活动-消费送"
	效果图:
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityUseTotalLayer = class("ActivityUseTotalLayer", function()
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
function ActivityUseTotalLayer:ctor(params)
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

    -- 是否有缓存数据
    --[[
    local tempData = self.mLayerData
    if tempData then
        print("------累积消费：读取缓存数据------")
        -- 保存数据
        self.mUseTotalInfo = tempData

        -- 配置礼包信息表
        self:configUseTotalList()

        -- 刷新页面
        self:refreshLayer()
    else
        print("------累积消费：缓存无数据，请求服务器------")
        self:requestGetUseTotalInfo()
    end
    --]]

    -- 在其他限时活动中消费了元宝的话，因读取缓存导致统计数据不对，无法领取对应的奖励
    -- 故每次进入页面重新请求数据，不缓存
    self:requestGetUseTotalInfo()
end

-- 获取恢复数据
function ActivityUseTotalLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityUseTotalLayer:initUI()
	-- 上方背景
    local topBg = ui.newSprite("xshd_08.jpg")
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
    -- local plan = ui.newSprite("xshd_22.png")
    -- plan:setAnchorPoint(cc.p(0, 0.5))
    -- plan:setPosition(67, 52)
    -- upBgSprite:addChild(plan)

    -- 下方背景
    self.mBottomBg = ui.newScale9Sprite("c_19.png", cc.size(640, 742))
    self.mBottomBg:setAnchorPoint(cc.p(0.5, 0))
    self.mBottomBg:setPosition(320, 0)
    self.mParentLayer:addChild(self.mBottomBg)

    local underSprite = ui.newScale9Sprite("c_17.png",cc.size(608, 590))
    underSprite:setPosition(320, 405)
    self.mParentLayer:addChild(underSprite)
    self.mUnderSprite = underSprite

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

    -- 当前已消费
    self.mUseTotalLabel = ui.newLabel({
        text = TR(""),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        size = 22,
    })
    self.mUseTotalLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mUseTotalLabel:setPosition(30, 785)
    self.mParentLayer:addChild(self.mUseTotalLabel)

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

-- 创建礼包滑动窗体
function ActivityUseTotalLayer:createListView()
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
function ActivityUseTotalLayer:configUseTotalList()
    self.mUseTotalList = {}
    -- 按照充值奖励，1：能领取 0：不能领取 2：已经领取来存放
    for k, v in ipairs(self.mUseTotalInfo.UseTotalDrawNums) do
        if v.Status == 1 then
            table.insert(self.mUseTotalList, v)
        end
    end

    for k, v in ipairs(self.mUseTotalInfo.UseTotalDrawNums) do
        if v.Status == 0 then
            table.insert(self.mUseTotalList, v)
        end
    end

    for k, v in ipairs(self.mUseTotalInfo.UseTotalDrawNums) do
        if v.Status == 2 then
            table.insert(self.mUseTotalList, v)
        end
    end
end

-- 刷新页面，包括上方的几个标签，下方的滑动视图
function ActivityUseTotalLayer:refreshLayer()
    -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    -- 刷新当前已消费元宝数目
    local picName = Utility.getResTypeSubImage(ResourcetypeSub.eDiamond)
    self.mUseTotalLabel:setString(TR("当前已消费:  %s%s {%s}",
    	"#1fee32",
    	self.mUseTotalInfo.UseTotalReward,
    	picName)
   	)

    -- 刷新礼包列表
    self:refreshListView()
end

-- 活动倒计时
function ActivityUseTotalLayer:updateTime()
    local timeLeft = self.mUseTotalInfo.HLHKUse - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时:  %s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
        -- print("更新时间")
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
function ActivityUseTotalLayer:refreshListView(id)
    -- 点击领取之后，刷新缓存数据
    if id then
    	for i, v in ipairs(self.mUseTotalInfo.UseTotalDrawNums) do
    		if v.Id == id then
    			v.Status = 2
    		end
    	end
        self.mLayerData = self.mUseTotalInfo
        self:configUseTotalList()
    end

    -- 移除所有并重新添加
    self.mListView:removeAllItems()
    for i = 1, table.maxn(self.mUseTotalList) do
        self.mListView:pushBackCustomItem(self:createCellByIndex(i))
    end
end

-- 创建每一个条目
--[[
    params:
    index                       -- 礼包条目的索引号
--]]
function ActivityUseTotalLayer:createCellByIndex(index)
    local cellInfo = self.mUseTotalList[index]

    -- 创建cell
    local cellWidth, cellHeight = 598, 145
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    -- cell背景框
    local cellBg = ui.newScale9Sprite("c_18.png", cc.size(cellWidth, cellHeight-5))
    cellBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
    customCell:addChild(cellBg)
    local cellBgSize = cellBg:getContentSize()

    -- "累计消费"
    local useLabel = ui.newLabel({
        text = TR("累积消费"),
        x = cellBgSize.width * 0.06,
        y = cellBgSize.height * 0.85,
        size = 21,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    useLabel:setAnchorPoint(cc.p(0, 0.5))
    cellBg:addChild(useLabel)

    -- 消费元宝进度
    local picName = Utility.getResTypeSubImage(ResourcetypeSub.eDiamond)
    local curCount = cellInfo.Id - cellInfo.NeedValue
    local needCount = tonumber(Utility.numberWithUnit(cellInfo.Id))
    local progressLabel = ui.newLabel({
    	text = TR("{%s}%d/%d",
    		picName,
    		curCount,
    		needCount
    	),
    	color = (curCount >= needCount) and cc.c3b(0x24, 0x90, 0x29) or Enums.Color.eRed,
		x = cellBgSize.width * 0.21,
        size = 20,
        y = cellBgSize.height * 0.85
    })
    progressLabel:setAnchorPoint(cc.p(0, 0.5))
    cellBg:addChild(progressLabel)

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
        maxViewWidth = 500,
        space = 20,
        cardDataList = rewardList,
        allowClick = true
    })
    rewardListView:setAnchorPoint(cc.p(0, 0.5))
    rewardListView:setPosition(cellBgSize.width * 0.05, cellBgSize.height * 0.4)
    cellBg:addChild(rewardListView)
    rewardListView:setScale(0.8)

    -- 领取按钮
    local rightBtn = ui.newButton({
        normalImage = "c_28.png",
        clickAction = function()
            self:requestDrawUseTotalReward(cellInfo.Id)
        end,
        text = TR("领取"),
    })
    rightBtn:setPosition(cellBgSize.width * 0.85, cellBgSize.height * 0.5)
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
-- 未获取缓存数据，则请求服务器，获取玩家累积消费的相关信息
function ActivityUseTotalLayer:requestGetUseTotalInfo()
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "GetUseTotalInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestGetUseTotalInfo", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mLayerData = data.Value
            self.mUseTotalInfo = data.Value

            -- 配置礼包信息表
            self:configUseTotalList()

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 请求服务器，领取累积消费相应的奖励
--[[
    params:
    id                              -- 要领取的礼包id号
--]]
function ActivityUseTotalLayer:requestDrawUseTotalReward(id)
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "DrawUseTotalReward",
        svrMethodData = {id},
        callbackNode = self,
        callback = function (data)
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

return ActivityUseTotalLayer
