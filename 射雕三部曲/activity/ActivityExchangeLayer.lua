--[[
    文件名: ActivityExchangeLayer.lua
	描述: 限时兑换页面, 模块Id为：
		ModuleSub.eTimedExchange -- "限时-兑换"
		ModuleSub.eCommonHoliday3 -- "通用活动-兑换"
		ModuleSub.eChristmasActivity3 -- "圣诞活动-兑换"
	效果图:
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityExchangeLayer = class("ActivityExchangeLayer", function()
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
function ActivityExchangeLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	self.mActivityId = params.activityIdList[1].ActivityId      -- 限时兑换只有一个活动Id

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

    -- 是否有缓存数据
    local tempData = self.mLayerData
    if tempData then
        print("------限时兑换：读取缓存数据------")
        -- 保存数据
        self.mLimitExchangeInfo = tempData

        -- 刷新页面
        self:refreshLayer()
    else
        print("------限时兑换：缓存无数据，请求服务器------")
        self:requestGetTimedLimitExchangeInfo()
    end
end

-- 获取恢复数据
function ActivityExchangeLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityExchangeLayer:initUI()
	-- 上方背景
    local topBg = ui.newSprite("xshd_06.jpg")
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
    -- local plan = ui.newSprite("xshd_24.png")
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
    self.mTimeLabel:setPosition(30, 800)
    self.mParentLayer:addChild(self.mTimeLabel)

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
function ActivityExchangeLayer:createListView()
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(598, 580))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(304, 585)
    self.mUnderSprite:addChild(self.mListView)
end

-- 活动倒计时
function ActivityExchangeLayer:updateTime()
    local timeLeft = self.mLimitExchangeInfo.EndTime - Player:getCurrentTime()
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

-- 刷新礼包窗体
function ActivityExchangeLayer:refreshListView()
    -- 移除所有并重新添加
    self.mListView:removeAllItems()
    for i = 1, table.maxn(self.mLimitExchangeInfo.ActivityList) do
        self.mListView:pushBackCustomItem(self:createCellByIndex(i))
    end
end

-- 创建每一个条目
--[[
    params:
    index                       -- 礼包的索引号
--]]
function ActivityExchangeLayer:createCellByIndex(index)
    local cellInfo = self.mLimitExchangeInfo.ActivityList[index]

    -- 创建cell
    local cellWidth, cellHeight = 598, 143
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    -- cell背景框
    local cellBg = ui.newScale9Sprite("c_18.png", cc.size(cellWidth - 10, cellHeight - 5))
    cellBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
    customCell:addChild(cellBg)
    local cellBgSize = cellBg:getContentSize()

    -- cellInfo.Discount = 0.86
    -- 打折
    if cellInfo.Discount then
        -- 红色背景斜条
        cellInfo.Discount = math.floor(cellInfo.Discount * 100) / 100
        local discountBG = ui.newSprite("c_57.png")
        discountBG:setAnchorPoint(cc.p(0, 1))
        discountBG:setPosition(cellBgSize.width, cellBgSize.height)
        cellBg:addChild(discountBG)
        discountBG:setRotation(90)

        local str = nil
        if (cellInfo.Discount * 100) % 10 == 0 then
            str = TR("%s折", cellInfo.Discount * 10)
        else
            str = TR("%s.%s折", math.floor(cellInfo.Discount * 10), cellInfo.Discount * 100 % 10)
        end
        local discountLabel = ui.newLabel({
            text = str,
            size = 19,
            outlineColor = Enums.Color.eBlack,
            align = ui.TEXT_ALIGN_CENTER
        })
        discountLabel:setPosition(discountBG:getContentSize().width * 0.36, discountBG:getContentSize().height * 0.64)
        discountBG:addChild(discountLabel)
        discountLabel:setRotation(-44)
    end

    -- 个人可购 标签
    local str = TR("%s个人可购: %s%s       ",
    	"#46220d",
    	"#249029",
    	cellInfo.PersonalNum ~= -1 and cellInfo.PersonalNum or TR("无限")
    )
    if cellInfo.NeedVIPLv ~= 0 then
        str = TR("%s %sVIP等级:%sVIP%s", str, "#46220d", "#249029", cellInfo.NeedVIPLv)
    end
    if cellInfo.NeedLv ~= 0 then
        str = TR("%s %s玩家等级:%sLv.%s", str, "#46220d", "#249029", cellInfo.NeedLv)
    end
    local desLabel = ui.newLabel({
        text = TR("%s", str),
        x = cellBgSize.width * 0.06,
        y = cellBgSize.height * 0.84,
        size = 20
    })
    desLabel:setAnchorPoint(cc.p(0, 0.5))
    cellBg:addChild(desLabel)

    -- 滑动窗体
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.horizontal)
    listView:setContentSize(cc.size(cellBgSize.width * 0.8, cellBgSize.height * 0.9))
    listView:setItemsMargin(40)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    listView:setSwallowTouches(false)
    listView:setAnchorPoint(cc.p(0, 0.5))
    listView:setPosition(cellBgSize.width * 0.06, cellBgSize.height * 0.38)
    cellBg:addChild(listView)
    listView:setScale(0.8)

    -- 创建兑换所需的资源卡牌
    local function addNeedItem(index, list)
    	local haveNum = Utility.getOwnedGoodsCount(list[index].ResourceTypeSub, list[index].ModelId)
        local isShowHaveNum = math.floor(tonumber(list[index].ModelId) / 10) == 1605004

        -- 创建cell
        local width, height = cellBgSize.width * 0.18, cellBgSize.height * 0.9
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(width, height))

        -- header
        local goods, cardShowAttrs = CardNode.createCardNode({
        	resourceTypeSub = list[index].ResourceTypeSub,
        	modelId = list[index].ModelId,
        	num = (not isShowHaveNum) and list[index].Count or nil,
        	cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, not isShowHaveNum and CardShowAttr.eNum or nil}
        })
        goods:setAnchorPoint(cc.p(0.5, 0.5))
        goods:setPosition(width * 0.5, height * 0.6)
        layout:addChild(goods)
        if haveNum < list[index].Count then
            goods:setGray(true)
        end

        -- 拥有标签
        if isShowHaveNum then
            local numLabel = ui.newLabel({
                text = string.format("%s/%s", Utility.numberWithUnit(haveNum), Utility.numberWithUnit(list[index].Count)),
                size = 20,
                align = ui.TEXT_ALIGN_CENTER,
                color = haveNum < list[index].Count and Enums.Color.eRed or Enums.Color.eGreen,
                outlineColor = Enums.Color.eOutlineColor,
            })
            numLabel:setPosition(goods:getContentSize().width * 0.5, goods:getContentSize().height * 0.17)
            goods:addChild(numLabel)
        else
            if cardShowAttrs[CardShowAttr.eNum] then
                local numLabel = cardShowAttrs[CardShowAttr.eNum].label
                numLabel:setString(string.format("%s/%s", Utility.numberWithUnit(haveNum), Utility.numberWithUnit(list[index].Count)))
                numLabel:setColor(haveNum < list[index].Count and Enums.Color.eRed or Enums.Color.eGreen)
            end
        end
        return layout
    end

    -- 创建兑换奖品卡牌
    local function addExchangeItem(index, list)
        -- 创建cell
        local width, height = cellBgSize.width * 0.18, cellBgSize.height * 0.9
        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(width, height))

        -- header
        local goods = CardNode.createCardNode({
        	resourceTypeSub = list[index].ResourceTypeSub,
        	modelId = list[index].ModelId,
        	num = list[index].Count,
        	cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
        })
        goods:setAnchorPoint(cc.p(0.5, 0.5))
		goods:setPosition(width * 0.5, height * 0.6)
        layout:addChild(goods)

        return layout
    end

    -- 中间的箭头
    local function addArrowItem()
        local width, height = 50, cellBgSize.height * 0.9

        local layout = ccui.Layout:create()
        layout:setContentSize(cc.size(width, height))

        local arrow = ui.newSprite("jc_15.png")
        arrow:setPosition(width * 0.5, height * 0.6)
        layout:addChild(arrow)
        return layout
    end

    for i = 1, table.maxn(cellInfo.NeedGameResourceList) do
        listView:pushBackCustomItem(addNeedItem(i, cellInfo.NeedGameResourceList))
    end
    listView:pushBackCustomItem(addArrowItem())
    for i = 1, table.maxn(cellInfo.ExchaneGameResourceList) do
        listView:pushBackCustomItem(addExchangeItem(i, cellInfo.ExchaneGameResourceList))
    end

    -- 兑换按钮
    local exchangeBtn = ui.newButton({
    	normalImage = "c_28.png",
        text = TR("兑换"),
        -- fontSize = 20,
        clickAction = function (pSender)
            self:exchangeBtnClicked(pSender, cellInfo)
        end
    })
	exchangeBtn:setPosition(cellBgSize.width * 0.85, cellBgSize.height * 0.5)
	cellBg:addChild(exchangeBtn)
    exchangeBtn:setEnabled(self:checkButtonEnabled(cellInfo))

    return customCell
end

-- 兑换按钮点击事件
--[[
	params:
	pSender   				-- 点击的按钮
	cellInfo 				-- 按钮所在的cell包含的礼包信息
--]]
function ActivityExchangeLayer:exchangeBtnClicked(pSender, cellInfo)
	local isEnoughResource, isEnoughDiamond = true, true
	local maxExchangeNumber = nil
	local notEnoughResourceList = {}
	for k, v in pairs(cellInfo.NeedGameResourceList) do
		-- 把不够的资源名字存放起来
	    if Utility.getOwnedGoodsCount(v.ResourceTypeSub, v.ModelId) < v.Count then
	        if v.ResourceTypeSub == ResourcetypeSub.eDiamond then
	            isEnoughDiamond = false
	        else
	            isEnoughResource = false
	        end
	        table.insert(notEnoughResourceList, Utility.getGoodsName(v.ResourceTypeSub, v.ModelId))
	    end

	    -- 最大的兑换次数
	    if maxExchangeNumber then
	        local tempExchangeNumber = math.floor(Utility.getOwnedGoodsCount(v.ResourceTypeSub, v.ModelId) / v.Count)
	        if tempExchangeNumber < maxExchangeNumber then
	            maxExchangeNumber = tempExchangeNumber
	        end
	    else
	        maxExchangeNumber = math.floor(Utility.getOwnedGoodsCount(v.ResourceTypeSub, v.ModelId) / v.Count)
	    end
	    if cellInfo.PersonalNum ~= -1 and cellInfo.PersonalNum < maxExchangeNumber then
	        maxExchangeNumber = cellInfo.PersonalNum
	    end
	    if maxExchangeNumber > 9999 then
	        maxExchangeNumber = 9999
	    end
	end
	-- 资源足够的情况下
	if isEnoughResource and isEnoughDiamond then
		local selectNum = 1
        MsgBoxLayer.addDIYLayer({
            title = TR("兑换"),
            DIYUiCallback = function (layer, bgSprite, bgSize)
                -- 数量选择控件
                local tempView = require("common.SelectCountView"):create({
                    maxCount = maxExchangeNumber or 1,
                    viewSize = cc.size(500, 200),
                    changeCallback = function(count)
                        selectNum = count
                    end
                })
                tempView:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
                bgSprite:addChild(tempView)
            end,
            btnInfos = {
                [1] = {
                    text = TR("确定"),
                    clickAction = function (layerObj, btnObj)
                        LayerManager.removeLayer(layerObj)
                        --请求服务器，兑换奖品
                        self:requestExchange(self.mActivityId, cellInfo, selectNum)
                    end
                }
            },
            closeBtnInfo = {
                clickAction = function (layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                end
            }
        })
	elseif isEnoughResource == false then
	    local str = nil
	    for i, v in ipairs(notEnoughResourceList) do
	        if i == 1 then
	            str = TR("%s'%s%s%s'", Enums.Color.eWhiteH, Enums.Color.eRedH, v, Enums.Color.eWhiteH)
	        else
	            str = TR("%s、'%s%s%s'", str, Enums.Color.eRedH, v, Enums.Color.eWhiteH)
	        end
	    end
	    ui.showFlashView({
	    	text = TR("%s不足", str)
	    })
	elseif isEnoughDiamond == false then
		MsgBoxLayer.addGetDiamondHintLayer()
	end
end

-- 判断兑换按钮是否可点击
--[[
	params:
	cellInfo    				-- 该按钮所在的cell的礼包信息
--]]
function ActivityExchangeLayer:checkButtonEnabled(cellInfo)
    if cellInfo.PersonalNum < 1 and cellInfo.PersonalNum ~= -1 then
        return false
    end
    return true
end

-- 刷新页面，包括上方的几个标签，下方的滑动视图
function ActivityExchangeLayer:refreshLayer()
    -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    -- 刷新礼包列表
    self:refreshListView()
end

---------------------网络相关------------------------
-- 请求服务器，获取当家当前限时兑换的相关信息
function ActivityExchangeLayer:requestGetTimedLimitExchangeInfo()
    HttpClient:request({
        moduleName = "TimedLimitExchange",
        methodName = "GetInfo",
        svrMethodData = {self.mActivityId},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestGetTimedLimitExchangeInfo:", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mLayerData = data.Value
            self.mLimitExchangeInfo = data.Value

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 请求服务器，兑换奖品
--[[
	params:
	activityId   				-- 当前活动Id号
	cellInfo 				    -- cell包含的礼包信息
	exchangeNum 				-- 兑换次数
--]]
function ActivityExchangeLayer:requestExchange(activityId, cellInfo, exchangeNum)
	local postData = {activityId, cellInfo.Serial, exchangeNum}
	HttpClient:request({
		moduleName = "TimedLimitExchange",
		methodName = "Exchange",
		svrMethodData = postData,
        callbackNode = self,
    	callback = function (data)
    		if data.Status == 0 then
                -- 不是无限次兑换
                if cellInfo.PersonalNum ~= -1 then
                    cellInfo.PersonalNum = cellInfo.PersonalNum - exchangeNum
                end
                -- 兑换掉侠客
                for i,v in ipairs(data.Value.BaseConsumeGameResourceList) do
                    HeroObj:deleteHeroById(v.EntityId)
                end
                -- 飘窗显示奖励
                ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

                -- 刷新窗体
                self:refreshLayer()
            elseif data.Status == -1802 then
            	MsgBoxLayer.addOKCancelLayer(TR("道具不足或有装备/神兵/侠客进行过进阶或强化"),
            		TR("提示"),
            		{
            			text = TR("去重生"),
            			clickAction = function (layerObj, btnObj)
            				local isOpen = ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eDisassemble)
                    		if isOpen then
                                LayerManager.removeLayer(layerObj)

                        		LayerManager.addLayer({
                        			name = "disassemble.DisassembleLayer",
                        			data = {currTag = Enums.DisassemblePageType.eRebirth}
                        		})
                        	end
                    	end
            		}
            	)
            end
        end
	})
end

return ActivityExchangeLayer
