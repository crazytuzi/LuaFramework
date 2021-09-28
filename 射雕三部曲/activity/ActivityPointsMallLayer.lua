--[[
    文件名: ActivityPointsMallLayer.lua
	描述: 积分商城页面, 模块Id为：
		ModuleSub.eTimedPointsMall  -- "限时-积分商城"
		ModuleSub.eChristmasActivity11 -- "节日活动-积分商城"
	效果图:
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityPointsMallLayer = class("ActivityPointsMallLayer", function()
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
function ActivityPointsMallLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	-- 保存数据
	self.mActivityId = params.activityIdList[1].ActivityId

    --ListView滚动的位置
    self.mListViewIndex = 1
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

    -- 是否有缓存数据
    local tempData = self.mLayerData
    if tempData then
        print("------积分商城：读取缓存数据------")
        -- 保存数据
        self.mActivityInfo = tempData

        -- 整理数据，2个一组
        self:configGoodsList(self.mActivityInfo.GoodsInfo)

        -- 刷新页面
        self:refreshLayer()
    else
        print("------积分商城：缓存无数据，请求服务器------")
        self:requestGetRewardList()
    end
end

-- 获取恢复数据
function ActivityPointsMallLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityPointsMallLayer:initUI()
	-- 背景图
	local bgSprite = ui.newSprite("xshd_12.jpg")
    bgSprite:setAnchorPoint(0.5, 1)
	bgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(bgSprite)
	self.mBgSprite = bgSprite
	self.mBgSize = bgSprite:getContentSize()

    --icon
    -- local upBgSprite = ui.newScale9Sprite("jchd_13.png")
    -- upBgSprite:setAnchorPoint(cc.p(0, 0.5))
    -- upBgSprite:setPosition(150, 925)
    -- self.mParentLayer:addChild(upBgSprite)
    -- local plan = ui.newSprite("xshd_27.png")
    -- plan:setAnchorPoint(cc.p(0, 0.5))
    -- plan:setPosition(70, 52)
    -- upBgSprite:addChild(plan)

    --人物
    local bg = ui.newSprite("xshd_20.png")
    bg:setPosition(380, 615)
    self.mParentLayer:addChild(bg)

    --说明背景
    local decBg = ui.newScale9Sprite("c_145.png", cc.size(383, 88))
    decBg:setAnchorPoint(cc.p(0, 0.5))
    decBg:setPosition(cc.p(-10, 800))
    self.mParentLayer:addChild(decBg)

    --下方背景
    self.mBottomBg = ui.newScale9Sprite("c_19.png", cc.size(640, 677))
    self.mBottomBg:setAnchorPoint(cc.p(0.5, 0))
    self.mBottomBg:setPosition(320, 75)
    self.mParentLayer:addChild(self.mBottomBg)

	-- 文字介绍
	local descText1 = ui.newLabel({
		text = TR("活动期间每充值 %s20 %s元宝获得一点积分", "#1fee32", Enums.Color.eWhiteH),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        align = ui.TEXT_ALIGN_CENTER,
        size = 22,
	})
	descText1:setPosition(170, 815)
	self.mParentLayer:addChild(descText1)

	local descText2 = ui.newLabel({
		text = TR("活动结束后拥有积分清零"),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        align = ui.TEXT_ALIGN_CENTER,
        size = 22,
	})
	descText2:setPosition(170, 780)
	self.mParentLayer:addChild(descText2)

	-- 充值按钮
    local chargeBtn = ui.newButton({
        normalImage = "tb_21.png",
        position = cc.p(590, 790),
        clickAction = function()
            LayerManager.showSubModule(ModuleSub.eCharge)
        end
    })
    self.mParentLayer:addChild(chargeBtn)

	-- 创建滑动窗口
	self:createListView()

	-- 黑色背景条
	local labelBg1 = ui.newScale9Sprite("xshd_03.png", cc.size(138, 32))
    labelBg1:setOpacity(150)
	labelBg1:setPosition(235, 135)
	self.mParentLayer:addChild(labelBg1)
	labelBg1:setScaleX(1.1)

	-- 倒计时标签
   	self.mTimeLabel = ui.newLabel({
   		text = TR(""),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        size = 20,
   	})
   	self.mTimeLabel:setAnchorPoint(cc.p(0, 0.5))
   	self.mTimeLabel:setPosition(30, 135)
   	self.mParentLayer:addChild(self.mTimeLabel)

   	-- 黑色背景条
	local labelBg2 = ui.newScale9Sprite("xshd_03.png", cc.size(138, 32))
    labelBg2:setOpacity(150)
	labelBg2:setPosition(535, 135)
	self.mParentLayer:addChild(labelBg2)
	labelBg2:setScaleX(1.1)

   	-- 拥有积分
   	self.mScoreLabel = ui.newLabel({
   		text = TR(""),
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        size = 20,
   	})
   	self.mScoreLabel:setAnchorPoint(cc.p(0, 0.5))
   	self.mScoreLabel:setPosition(370, 135)
   	self.mParentLayer:addChild(self.mScoreLabel)

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
end

-- 活动倒计时
function ActivityPointsMallLayer:updateTime()
    local timeLeft = self.mActivityInfo.EndDate - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时:     %s%s", "#f8ea3a", MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mTimeLabel:setString(TR("活动倒计时:     %s00:00:00", "#f8ea3a"))

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

-- 创建奖品滑动窗口
function ActivityPointsMallLayer:createListView()
    self.mListView = ccui.ListView:create()
   	self.mListView:setContentSize(cc.size(590, 625))
    self.mListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.mListView:setBounceEnabled(true)
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setItemsMargin(10)
    self.mListView:setIgnoreAnchorPointForPosition(false)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(320, 398)
    self.mListView:setScrollBarEnabled(false)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mParentLayer:addChild(self.mListView)


    -- 左右箭头
    local leftArrow = ui.newSprite("c_26.png")
    leftArrow:setAnchorPoint(cc.p(0, 0.5))
    leftArrow:setPosition(610, 445)
    self.mParentLayer:addChild(leftArrow)

    -- 箭头
    local rightArrow = ui.newSprite("c_26.png")
    rightArrow:setAnchorPoint(cc.p(1, 0.5))
    rightArrow:setPosition(30, 445)
    rightArrow:setFlippedX(true)
    self.mParentLayer:addChild(rightArrow)
end

-- 配置奖品信息表，将服务器返回的奖品信息进行整理，2个奖品信息为1组
--[[
	params:
	goodsInfos    		-- 奖品信息表
--]]
function ActivityPointsMallLayer:configGoodsList(goodsInfos)
	--dump(goodsInfos, "整理奖品信息表----->goodsInfos", 10)

	-- 每次刷新时，重置此表
	self.mGroupInfoList = {}

	local tempList = {}
	for i, v in ipairs(goodsInfos) do
		table.insert(tempList, v)
		if table.maxn(tempList) == 2 then
			table.insert(self.mGroupInfoList, tempList)
			tempList = {}
		end
	end

	-- 道具数量为单数时
	if table.maxn(tempList) ~= 0 then
		table.insert(self.mGroupInfoList, tempList)
	end
end

-- 刷新页面
function ActivityPointsMallLayer:refreshLayer()

    -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

	-- 拥有积分
	self.mScoreLabel:setString(TR("拥有积分:     %s%s", "#b2e283", self.mActivityInfo.Score))

	-- 移除所有并重新添加
    self.mListView:removeAllItems()
    for i = 1, table.maxn(self.mGroupInfoList) do
        self.mListView:pushBackCustomItem(self:createCellByIndex(i))
    end

    --滑动到指定位置
    ui.setListviewItemShow(self.mListView, self.mListViewIndex)
end

-- 创建ListView的每个Cell
--[[
	params:
	index                	-- cell的索引号
--]]
function ActivityPointsMallLayer:createCellByIndex(index)
	-- 获取每个小组的数据信息, 可能包含2个奖品信息  也可能只有1个
    local groupInfo = self.mGroupInfoList[index]

    -- 创建cell
    local cellWidth, cellHeight = 190, 540
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    local goodsPos = {
        cc.p(95, 452),
        cc.p(95, 175)
    }
    for i, v in ipairs(groupInfo) do
    	-- 解析资源
		local goodsInfo = Utility.analysisStrResList(v.Reward)[1]

        -- -- cell背景框
        -- local cellBg = ui.newScale9Sprite("c_16.png", cc.size(cellWidth - 10, cellHeight + 10))
        -- cellBg:setPosition(cellWidth * 0.5, cellHeight * 0.5)
        -- customCell:addChild(cellBg)
        -- local cellBgSize = cellBg:getContentSize()

    	-- 底层背景框
        local bgSpr = ui.newScale9Sprite("xshd_13.png", cc.size(180, 262))
        bgSpr:setPosition(goodsPos[i])
        customCell:addChild(bgSpr)
        local bgSprSize = bgSpr:getContentSize()

        -- 设置头像
        local header = CardNode.createCardNode({
            modelId = goodsInfo.modelId,
            resourceTypeSub = goodsInfo.resourceTypeSub,
            num = goodsInfo.num,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum},
            cardShape = Enums.CardShape.eCircle
        })
        header:setAnchorPoint(cc.p(0.5, 0))
        header:setPosition(bgSprSize.width * 0.5, bgSprSize.height * 0.59)
        bgSpr:addChild(header)

        -- 需要积分
	    local scoreLabel = ui.newLabel({
	        text = TR("需要积分: %s%s", "#249029", v.NeedScore),
            color = Enums.Color.eBrown,
	        x = bgSprSize.width * 0.5,
	        y = bgSprSize.height * 0.45,
            size = 19,
            align = ui.TEXT_ALIGN_CENTER
	    })
	    bgSpr:addChild(scoreLabel)
	    -- 积分不够时高亮显示
	    if v.NeedScore > self.mActivityInfo.Score then
	        scoreLabel:setString(TR("需要积分: %s%s", "#249029", v.NeedScore))
	    end

        -- 显示可购买次数
        local numLabel = ui.newLabel({
            text = TR("可购买%s次", v.Num),
            color = Enums.Color.eBrown,
            size = 19,
            align = ui.TEXT_ALIGN_CENTER
        })
        numLabel:setPosition(bgSprSize.width * 0.5, bgSprSize.height * 0.35)
        bgSpr:addChild(numLabel)

        --创建卡牌数据
        local rewardData = Utility.analysisStrResList(v.Reward)
        local count = v.Num > math.floor(self.mActivityInfo.Score / v.NeedScore) and math.floor(self.mActivityInfo.Score / v.NeedScore) or v.Num

        -- 购买按钮
        local buyBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("购买"),
            clickAction = function()
                --获取当前的self.mListView中item位置
                self.mListViewIndex = index
                local usedMsgLayer = nil
                local sendCount = 0
                usedMsgLayer = self:addUseGoodsCountLayer(
                    TR("购买"),
                    count,
                    rewardData,
                    function(selCount)
                        sendCount = selCount
                        if self.mActivityInfo.Score < selCount * v.NeedScore then
                            ui.showFlashView(TR("积分不足"))
                        end
                        if selCount > count then
                            ui.showFlashView(TR("最多可以购买%d次", count))
                        end
                    end,
                    function()
                        if not Utility.checkBagSpace() then
                            return
                        end
                        self:requestBuyGoods(v.Serial, sendCount)
                        usedMsgLayer:removeFromParent()
                    end
                )
            end
        })
        buyBtn:setPosition(bgSprSize.width * 0.5, 50)
        bgSpr:addChild(buyBtn)

        -- 是否可点击
	    if v.Num == 0 or v.NeedScore > self.mActivityInfo.Score then
	        buyBtn:setEnabled(false)
	    end
    end

    return customCell
end

--选择次数
--[[
    title:标题
    maxNum：最大购买次数
    cardData：卡牌数据
    countChangeCallback：次数选择回调
    OkCallback：确认回调
]]
function ActivityPointsMallLayer:addUseGoodsCountLayer(title, maxNum, cardData, countChangeCallback, OkCallback)
    local selCount = 1 -- 当前选择的数量
    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 数量改变的回调
        local function changeCallback(count)
            selCount = count
        end

        -- 物品信息的背景
        local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(546, 280))
        tempSprite:setAnchorPoint(cc.p(0.5, 1))
        tempSprite:setPosition(layerSize.width / 2, layerSize.height - 85)
        layerBgSprite:addChild(tempSprite)

        --创建card
        local propCard = CardNode.createCardNode({
            resourceTypeSub = cardData[1].resourceTypeSub,
            modelId = cardData[1].modelId,
            num = cardData[1].num,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName},
        })
        propCard:setPosition(cc.p(layerSize.width / 2, 300))
        layerBgSprite:addChild(propCard)

	    -- 数量选择控件
        local tempView = require("common.SelectCountView"):create({
	        maxCount = maxNum,
	        viewSize = cc.size(500, 200),
	        changeCallback = function(count)
	            if countChangeCallback then
	                countChangeCallback(count)
	            end
	            return true
	        end
	    })
	    tempView:setPosition(layerSize.width / 2, 180)
	    layerBgSprite:addChild(tempView)
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            OkCallback(selCount, layerObj, btnObj)
        end,
    }
    return MsgBoxLayer.addDIYLayer({
        msgText = TR(""),
        title = title or TR("选择"),
        bgSize = cc.size(598, 474),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
    })
end

--------------------网络相关-----------------------
-- 请求服务器，获取玩家积分信息及奖励信息
function ActivityPointsMallLayer:requestGetRewardList()
    HttpClient:request({
        moduleName = "TimedChargeScore",
        methodName = "GetRewardList",
        svrMethodData = {self.mActivityId},
        callbackNode = self,
        callback = function (data)
        	--dump(data, "requestGetRewardList", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mLayerData = data.Value
            self.mActivityInfo = data.Value

            -- 整理数据，2个一组
    		self:configGoodsList(self.mActivityInfo.GoodsInfo)

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 请求服务器，用积分购买物品
--[[
	params:
	goodsId    				-- 物品id号，此处为"Serial"字段
    count ：购买次数
--]]
function ActivityPointsMallLayer:requestBuyGoods(goodsId, count)
    HttpClient:request({
        moduleName = "TimedChargeScore",
        methodName = "BuyGoods",
        svrMethodData = {self.mActivityId, goodsId, count},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

        	-- 更新数据
            self.mActivityInfo.Score = data.Value.Score
            self.mActivityInfo.GoodsInfo = data.Value.GoodsInfo
            self.mLayerData = self.mActivityInfo

            -- 飘窗显示奖励物品
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            -- 整理数据，2个一组
            self:configGoodsList(self.mActivityInfo.GoodsInfo)
            -- 刷新页面
            self:refreshLayer()
        end
    })
end

return ActivityPointsMallLayer
