--[[
    文件名: ActivityWelfareLayer.lua
	描述: 福利多多页面(翻倍收益),模块Id为：
		ModuleSub.eTimedWelfareMaxJJC  -- "福利多多-天道榜"
		ModuleSub.eTimedWelfareMaxDWDH  -- "福利多多-传承之战"
		ModuleSub.eTimedWelfareMaxYCJK  -- "福利多多-丹神古墓"
		ModuleSub.eTimedWelfareMaxEquip  -- "福利多多-装备召唤打折"
		ModuleSub.eTimedWelfareMaxHero  --  "福利多多-人物召唤打折"
		ModuleSub.eTimedWelfareEquipCompareCrid  -- "福利多多-装备合成暴击"
		ModuleSub.eTimedWelfareEquipCallCrid  -- "福利多多-装备召唤暴击"
		ModuleSub.eTimedWelfareMaxBDD  -- "福利多多-装备中心战功翻倍"
	效果图:
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityWelfareLayer = class("ActivityWelfareLayer", function()
    return display.newLayer()
end)

-- 福利多多配置信息
local TimedActivityInfo = {
    [TimedActivity.eSalesPVP] = {
        name = TR("华山论剑"),
        pic = "tb_57.png",
        text = TR("活动期间内，华山论剑挑战可\n获得"),
        goPath = "challenge.PvpLayer",
        rewardName = TR("华山令"),
        moduleId = ModuleSub.eChallengeArena,
        params = {}
    },
    [TimedActivity.eSalesGDDH] = {
        name = TR("武林大会"),
        pic = "tb_58.png",
        text = TR("活动期间内，武林大会挑战可\n获得"),
        goPath = "challenge.GDDHLayer",
        rewardName = TR("豪侠令"),
        moduleId = ModuleSub.eChallengeWrestle,
        params = {}
    },
    [TimedActivity.eSalesGGZJ] = {
        name = TR("通缉令"),
        pic = "tb_170.png",
        text = TR("活动期间内，挑战江湖悬赏\n铜钱收益增加"),
        goPath = "challenge.GGZJLayer",
        rewardName = "",
        moduleId = ModuleSub.eXrxs,
        params = {}
    },
    [TimedActivity.eSalesRebornCoin] = {
        name = TR("真气翻倍"),
        pic = "tb_161.png",
        text = TR("活动期间内，挑战光明顶\n真气收益增加"),
        goPath = "challenge.ExpediDifficultyLayer",
        rewardName = "",
        moduleId = ModuleSub.eExpedition,
        params = {}
    },
    [TimedActivity.eSalesSectPalace] = {
        name = TR("门派地宫产出翻倍"),
        pic = "tb_341.png",
        text = TR("活动期间内，前往地宫探索掠夺\n藏宝图碎片收益增加"),
        goPath = "sect.SectPalaceHomeLayer",
        rewardName = "",
        moduleId = ModuleSub.eSectPalace,
        params = {}
    },
    -- 未来可能要添加的跳转模块，暂不支持
    -- [TimedActivity.eSalesHeroRecruit] = {
    --     name = "",
    --     pic = "tb_29.png",
    --     text = TR("活动期间内，神将招募"),
    --     goPath = "shop.ShopLayer",
    --     rewardName = "",
    --     moduleId = ModuleSub.eRecruit,
    --     params = {}
    -- },
}

--[[
-- 参数 params 中的各项为：
	{
		activityIdList: 活动实体Id列表
		parentModuleId: 该活动的主模块Id

		cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
	}
]]
function ActivityWelfareLayer:ctor(params)
	--dump(params, "ActivityWelfareLayer:")
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
    local tempData = self.mLayerData
    if tempData then
        print("------翻倍收益：读取缓存数据------")
        -- 保存数据
        self.mActivityListInfo = tempData

        -- 刷新页面
        self:refreshLayer()
    else
        print("------翻倍收益：缓存无数据，请求服务器------")
        self:requestGetTimedActivityInfo()
    end
end

-- 获取恢复数据
function ActivityWelfareLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityWelfareLayer:initUI()
	-- 上方背景
    local topBg = ui.newSprite("xshd_10.jpg")
    topBg:setAnchorPoint(cc.p(0.5, 1))
    topBg:setPosition(320, 1136)
    self.mParentLayer:addChild(topBg)

    --人物
    local bg = ui.newSprite("xshd_20.png")
    bg:setPosition(380, 615)
    self.mParentLayer:addChild(bg)

    --icon
    -- local upBgSprite = ui.newScale9Sprite("jchd_13.png")
    -- upBgSprite:setAnchorPoint(cc.p(0, 0.5))
    -- upBgSprite:setPosition(10, 875)
    -- self.mParentLayer:addChild(upBgSprite)
    -- local plan = ui.newSprite("xshd_26.png")
    -- plan:setAnchorPoint(cc.p(0, 0.5))
    -- plan:setPosition(70, 52)
    -- upBgSprite:addChild(plan)

    -- 下方背景
    self.mBottomBg = ui.newScale9Sprite("c_19.png", cc.size(640, 667))
    self.mBottomBg:setAnchorPoint(cc.p(0.5, 0))
    self.mBottomBg:setPosition(320, 75)
    self.mParentLayer:addChild(self.mBottomBg)

    -- self.mUnderSprite = ui.newScale9Sprite("xshd_03.png", cc.size(608, 590))
    -- self.mUnderSprite:setPosition(320, 405)
    -- self.mParentLayer:addChild(self.mUnderSprite)

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
function ActivityWelfareLayer:createListView()
    -- 创建ListView视图
    self.mListView = ccui.ListView:create()
    self.mListView:setItemsMargin(5)
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(630, 580))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(320, 620)
    self.mBottomBg:addChild(self.mListView)
end

-- 刷新页面，包括上方的几个标签，下方的滑动视图
function ActivityWelfareLayer:refreshLayer()
    -- 刷新礼包列表
    self:refreshListView()

    -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
end

-- 活动倒计时
function ActivityWelfareLayer:updateTime()
    for i, v in ipairs(self.mTimeLabels) do
    	local timeLeft = v.endDate - Player:getCurrentTime()
        if timeLeft > 0 then
    	    v:setString(TR("倒计时:     %s%s", Enums.Color.eRedH, MqTime.formatAsDay(timeLeft)))
        else
            v:setString(TR("倒计时:     %s00:00:00", Enums.Color.eRedH))

            -- 停止倒计时
             if self.mSchelTime then
                self:stopAction(self.mSchelTime)
                self.mSchelTime = nil
             end

            -- 重新进入提示
            MsgBoxLayer.addOKLayer(
                TR("%s活动已结束，请重新进入", v.acName),
                TR("提示"),
                {},
                {
                    normalImage = "c_28.png",
                    text = TR("确定"),
                    clickAction = function()
                        LayerManager.addLayer({
                            name = "activity.ActivityMainLayer",
                            data = {moduleId = ModuleSub.eTimedActivity},
                        })
                    end
                }
            )

            break
        end
    end

    print("更新时间")
end

-- 刷新活动列表窗体
function ActivityWelfareLayer:refreshListView()
	self.mTimeLabels = {}

    -- 移除所有并重新添加
    self.mListView:removeAllItems()
    for i = 1, table.maxn(self.mActivityListInfo) do
        self.mListView:pushBackCustomItem(self:createCellByIndex(i))
    end
end

-- 创建每一个活动条目
--[[
    params:
    index                       -- 活动条目的索引号
--]]
function ActivityWelfareLayer:createCellByIndex(index)
    local cellInfo = self.mActivityListInfo[index]

    -- 创建cell
    local cellWidth, cellHeight = 625, 148
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    -- cell背景框
    local cellBg = ui.newScale9Sprite("c_54.png")
    --cellBg:setCapInsets(cc.rect(59, 50, 5, 5))
    cellBg:setContentSize(cc.size(625, 148))
    cellBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
    customCell:addChild(cellBg)
    local cellBgSize = cellBg:getContentSize()

    -- 中间的标题
    local titleLabel = ui.newLabel({
        text = TR(cellInfo.Name),
        color = cc.c3b(0xfa, 0xf6, 0xf1),
        outlineColor = cc.c3b(0x8d, 0x4b, 0x3b),
        size = 23,
        x = cellBgSize.width * 0.5,
        y = cellBgSize.height * 0.85,
        align = ui.TEXT_ALIGN_CENTER
   	})
    cellBg:addChild(titleLabel)

    -- -- 标题两边的线
    -- local posX, posY = titleLabel:getPosition()
    -- local lineSpr1 = ui.newSprite("c_39.png")
    -- lineSpr1:setAnchorPoint(cc.p(1, 0.5))
    -- lineSpr1:setPosition(posX - titleLabel:getContentSize().width * 0.5, posY)
    -- cellBg:addChild(lineSpr1)
    -- lineSpr1:setScale(0.8)

    -- local lineSpr2 = ui.newSprite("c_39.png")
    -- lineSpr2:setAnchorPoint(cc.p(0, 0.5))
    -- lineSpr2:setPosition(posX + titleLabel:getContentSize().width * 0.5, posY)
    -- cellBg:addChild(lineSpr2)
    -- lineSpr2:setFlippedX(true)
    -- lineSpr2:setScale(0.8)

    -- 左边的图标
    local headerSpr = ui.newSprite(TimedActivityInfo[cellInfo.ActivityEnumId].pic)
    headerSpr:setPosition(cellBgSize.width * 0.12, cellBgSize.height * 0.4)
    cellBg:addChild(headerSpr)

    -- 倒计时
    local timeLabel = ui.newLabel({
        text = TR(""),
        size = 21,
        color = cc.c3b(0x4e, 0x28, 0x0f),
        anchorPoint = cc.p(0, 0.5),
        x = cellBgSize.width * 0.24,
        y = cellBgSize.height * 0.55
    })
    cellBg:addChild(timeLabel)
    timeLabel.endDate = cellInfo.EndDate
    -- 活动名称
    timeLabel.acName = TimedActivityInfo[cellInfo.ActivityEnumId].name
    table.insert(self.mTimeLabels, timeLabel)

    -- 中间的描述
    local str = nil
    if TimedActivityInfo[cellInfo.ActivityEnumId] then
        --增益类型
        local addType = false
        if cellInfo.CritNum > 1 then
            addType = true
        end
        if not addType then
            cellInfo.CritNum = cellInfo.CritNum * 10
        end
        local addUnit = addType and TR("倍") or TR("折")
    	str = TimedActivityInfo[cellInfo.ActivityEnumId].text .. cellInfo.CritNum .. addUnit
                                            .. TimedActivityInfo[cellInfo.ActivityEnumId].rewardName
    else
    	str = TR("无相关配置信息")
    end
    local descLabel = ui.newLabel({
        text = str,
        size = 21,
        color = cc.c3b(0x4e, 0x28, 0x0f),
        x = cellBgSize.width * 0.24,
        y = cellBgSize.height * 0.25,
    })
    descLabel:setAnchorPoint(cc.p(0, 0.5))
    cellBg:addChild(descLabel)

    -- 前往按钮
    local goBtn = ui.newButton({
        text = TR("前往"),
        normalImage = "c_28.png",
        clickAction = function()
            local moduleId = TimedActivityInfo[cellInfo.ActivityEnumId].moduleId
            -- 服务器是否开启此功能模块
            if ModuleInfoObj:moduleIsOpenInServer(moduleId) then
                -- 玩家是否达到相应等级
                if ModuleInfoObj:modulePlayerIsOpen(moduleId, true) then
                    LayerManager.addLayer({
                        name = TimedActivityInfo[cellInfo.ActivityEnumId].goPath,
                        data = TimedActivityInfo[cellInfo.ActivityEnumId].params
                    })
                end
            else
                ui.showFlashView({
                    text = TR("功能暂未开放")
                })
            end
        end})
    goBtn:setPosition(cellBgSize.width * 0.85, cellBgSize.height * 0.4)
    cellBg:addChild(goBtn)

    return customCell
end

-------------------网络相关----------------------
-- 请求服务器，获取所有已开启的福利多多活动的信息
function ActivityWelfareLayer:requestGetTimedActivityInfo()
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "GetTimedActivityInfo",
        svrMethodData = {self.mActivityId},
        callbackNode = self,
        callback = function (data)
        	-- dump(data, "requestGetTimedActivityInfo", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mLayerData = data.Value.TimedActivityList
            self.mActivityListInfo = data.Value.TimedActivityList
            --dump(self.mActivityListInfo, "列表羡煞安师大就啊")

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

return ActivityWelfareLayer
