--[[
    文件名: ActivityRewardLoginDaysLayer.lua
	描述: 十万元宝页面, 模块Id为：
		ModuleSub.eShiWanYuanBao
	效果图: j精彩活动_十万元宝.jpg
	创建人: libowen
	创建时间: 2016.7.21
--]]

local ActivityRewardLoginDaysLayer = class("ActivityRewardLoginDaysLayer", function()
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
function ActivityRewardLoginDaysLayer:ctor(params)
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

    -- 累积登录，不能用缓存，必须每次请求
	-- 请求服务器，获取十万元宝活动信息
	self:requestGetSwdiamondInfo()
end

-- 获取恢复数据
function ActivityRewardLoginDaysLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityRewardLoginDaysLayer:initUI()
    -- 背景
    local bg = ui.newSprite("jc_24.jpg")
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setPosition(320,568)
    self.mParentLayer:addChild(bg)

    -- title图
    local titleSprite = ui.newSprite("jc_09.png")
    titleSprite:setAnchorPoint(cc.p(0, 0.5))
    titleSprite:setPosition(0,900)
    self.mParentLayer:addChild(titleSprite)

    --人物
    local bg = ui.newSprite("jc_18.png")
    bg:setPosition(420, 660)
    self.mParentLayer:addChild(bg)

    --说明背景
    local decBgSize = cc.size(450, 55)
    local decBg = ui.newScale9Sprite("c_145.png", decBgSize)
    decBg:setPosition(cc.p(-10, 750))
    decBg:setAnchorPoint(cc.p(0,0.5))
    self.mParentLayer:addChild(decBg)

    -- 感叹号icon
    local gantan = ui.newSprite("c_63.png")
    gantan:setPosition(60, decBgSize.height*0.5)
    decBg:addChild(gantan)

    -- 时间标签
    self.mTimeLabel = ui.newLabel({
        text = TR(""),
        color = Enums.Color.eWhite,
        align = ui.TEXT_ALIGN_CENTER,
        size = Enums.Fontsize.eBtnDefault,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        outlineSize = 2,
    })
    self.mTimeLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mTimeLabel:setPosition(80, decBgSize.height*0.5)
    decBg:addChild(self.mTimeLabel)

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
function ActivityRewardLoginDaysLayer:createListView()
    -- 下半部分背景图片大小
    local downBgSize = cc.size(640,700)
    -- 下半部分背景图片
    self.downBgSprite = ui.newScale9Sprite("c_19.png",downBgSize)
    self.downBgSprite:setAnchorPoint(cc.p(0.5, 0))
    self.downBgSprite:setPosition(320, 0)
    self.mParentLayer:addChild(self.downBgSprite)
    -- listView背景图大小
    local listViewBgSize = cc.size(downBgSize.width*0.95,downBgSize.height*0.84)
    -- listView背景图
    local listViewBgSprite = ui.newScale9Sprite("c_17.png",listViewBgSize)
    listViewBgSprite:setAnchorPoint(cc.p(0.5, 1))
    listViewBgSprite:setPosition(downBgSize.width*0.5, 665)
    self.downBgSprite:addChild(listViewBgSprite)

    -- 创建登录礼包ListView
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setItemsMargin(5)
    self.mListView:setContentSize(cc.size(listViewBgSize.width, listViewBgSize.height*0.97))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(listViewBgSize.width*0.5+10, listViewBgSize.height*0.5)
    listViewBgSprite:addChild(self.mListView)
end

-- 配置礼包信息表
function ActivityRewardLoginDaysLayer:configRewardList()
    self.mRewardList = {}
    -- 按照充值奖励，1：能领取 0：不能领取 2：已经领取来存放
    for k, v in ipairs(self.mActivityInfo.SwDiamondInfo) do
        if v.Status == 1 then
            table.insert(self.mRewardList, v)
        end
    end

    for k, v in ipairs(self.mActivityInfo.SwDiamondInfo) do
        if v.Status == 0 then
            table.insert(self.mRewardList, v)
        end
    end

    for k, v in ipairs(self.mActivityInfo.SwDiamondInfo) do
        if v.Status == 2 then
            table.insert(self.mRewardList, v)
        end
    end
end

-- 刷新页面，包括上方的几个标签，下方的滑动视图
function ActivityRewardLoginDaysLayer:refreshLayer()
    local timeLeft = self.mActivityInfo.StartTime - Player:getCurrentTime()
    -- 活动开启倒计时 还是 登录天数
    if timeLeft > 0 then
        -- 刷新时间，开始倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
        self:updateTime()
        self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
    else
        self.mTimeLabel:setString(TR("累计登录: %s%d%s天", "#ffe033", self.mActivityInfo.LoginDays, Enums.Color.eWhiteH))
    end

    -- 刷新礼包列表
    self:refreshListView()
end

-- 活动倒计时
function ActivityRewardLoginDaysLayer:updateTime()
    local timeLeft = self.mActivityInfo.StartTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("%s后活动开启", MqTime.formatAsDay(timeLeft)))
    else
        self.mTimeLabel:setString(TR("00:00:00后活动开启"))
        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        -- 重新请求数据
        self:requestGetSwdiamondInfo()
    end
end

-- 刷新礼包窗体
--[[
    params:
    dayNum                      -- 领取礼包所需的登录天数
--]]
function ActivityRewardLoginDaysLayer:refreshListView(dayNum)
    -- 点击领取之后，刷新缓存数据
    if dayNum then
    	for i, v in ipairs(self.mActivityInfo.SwDiamondInfo) do
    		if v.Days == dayNum then
    			v.Status = 2
    		end
    	end
    	self.mLayerData = self.mActivityInfo
        self:configRewardList()
    end

    -- 移除所有并重新添加
    self.mListView:removeAllItems()
    for i = 1, #self.mRewardList do
        self.mListView:pushBackCustomItem(self:createCellByIndex(i))
    end
end

-- 创建每一个条目
--[[
    params:
    index                       -- 礼包索引号
--]]
function ActivityRewardLoginDaysLayer:createCellByIndex(index)
    local cellInfo = self.mRewardList[index]

    -- 创建cell
    local cellWidth, cellHeight = self.mListView:getContentSize().width*0.97 ,120
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    -- cell背景框
    local cellBg = ui.newScale9Sprite("c_18.png", cc.size(cellWidth, cellHeight))
    cellBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
    customCell:addChild(cellBg)
    local cellBgSize = cellBg:getContentSize()

    -- 登录X天可领取
    local loginLabel1 = ui.newLabel({
        text = TR("%s累计登录", "#4b2710"),
        x = cellBgSize.width * 0.15,
        y = cellBgSize.height * 0.65,
        size = 22,
        align = ui.TEXT_ALIGN_CENTER
    })
    cellBg:addChild(loginLabel1)

    -- 奖励
    local rewardList = ShiwanyuanbaoRelation.items[cellInfo.Days]
    -- 元宝
    local diamondNum = rewardList.getDimonds
    if diamondNum ~= 0 then
        local leftCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eDiamond,
            modelId = 0,
            Num = diamondNum,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        })
        leftCard:setSwallowTouches(false)
        leftCard:setPosition(cellWidth * 0.38, cellHeight * 0.5)
        cellBg:addChild(leftCard)
    end

    -- 经验
    local expNum = rewardList.getVipExp
    if expNum ~= 0 then
        local rightCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eVIPEXP,
            modelId = 0,
            Num = expNum,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        })
        rightCard:setSwallowTouches(false)
        rightCard:setPosition(cellWidth * 0.58, cellHeight * 0.5)
        cellBg:addChild(rightCard)
    end

    -- 登录进度
    local labelColor = (self.mActivityInfo.LoginDays > cellInfo.Days) and "#27940e" or Enums.Color.eRedH
    local scheduleLabel = ui.newLabel({
        text = TR("%s%d/%d%s天", labelColor, self.mActivityInfo.LoginDays, cellInfo.Days, "#4b2710"),
        x = cellBgSize.width * 0.15,
        y = cellBgSize.height * 0.37,
        size = Enums.Fontsize.eBtnDefault,
        align = ui.TEXT_ALIGN_CENTER
    })
    cellBg:addChild(scheduleLabel)

    -- 领取按钮
    local rightBtn = ui.newButton({
        normalImage = "c_28.png",
        clickAction = function()
            self:requestGetSwdiamondReward(cellInfo.Days)
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
        doneSprite:setPosition(cellBgSize.width * 0.85, cellBgSize.height * 0.5)
        cellBg:addChild(doneSprite)

        -- 隐藏进度标签
        scheduleLabel:setVisible(false)
    end

    return customCell
end

---------------------------网络相关------------------------------
-- 请求服务器，获取玩家累积登录的相关信息
function ActivityRewardLoginDaysLayer:requestGetSwdiamondInfo()
    HttpClient:request({
        moduleName = "Swdiamonds",
        methodName = "GetSwdiamondInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestGetSwdiamondInfo", 10)

            -- 容错处理，有时候返回值可能为nil，避免crash
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mLayerData = data.Value
            self.mActivityInfo = data.Value

            -- 配置礼包信息表
            self:configRewardList()

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
function ActivityRewardLoginDaysLayer:requestGetSwdiamondReward(dayNum)
    HttpClient:request({
        moduleName = "Swdiamonds",
        methodName = "GetSwdiamondReward",
        svrMethodData = {dayNum},
        callbackNode = self,
        callback = function (data)

            -- 容错处理，有时候返回值可能为nil，避免crash
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

return ActivityRewardLoginDaysLayer
