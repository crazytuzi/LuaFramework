--[[
    文件名: ActivityRecruitLayer.lua
	描述: 限时招募页面, 模块Id为：ModuleSub.eTimedRecruit
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityRecruitLayer = class("ActivityRecruitLayer", function()
    return display.newLayer()
end)

-- 宝箱领取状态
local ChestStatus = {
    eCanNotDraw = 0,            -- 不可领取
    eCanDraw = 1,               -- 可领取
    eHaveDraw = 2               -- 已领取
}

--[[
-- 参数 params 中的各项为：
	{
		activityIdList: 活动实体Id列表
		parentModuleId: 该活动的主模块Id
	}
]]
function ActivityRecruitLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId

	-- 保存活动id与结束时间戳
	self.mActivityId = params.activityIdList[1].ActivityId

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

    -- 请求数据接口(每次请求，避免已选择神将失效(外部弹窗领取时))
    self:requestGetTimedRecruitInfo()
end

-- 获取恢复数据
function ActivityRecruitLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
	}

	return retData
end

-- 初始化页面控件
function ActivityRecruitLayer:initUI()
	-- 背景图
	local bgSprite = ui.newSprite("c_34.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)
	self.mBgSprite = bgSprite
	self.mBgSize = bgSprite:getContentSize()

	-- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(60, 957),
        clickAction = function()
            self:ruleBtnCallFun()
        end})
    bgSprite:addChild(ruleBtn, 1)

   	-- 下方背景图
    local bottomBg = ui.newScale9Sprite("c_19.png", cc.size(645, 1136 - 670 + 10))
    bottomBg:setAnchorPoint(cc.p(0.5, 0))
    bottomBg:setPosition(320, 0)
    bgSprite:addChild(bottomBg)

    ----------------积分排名---------------
    -- 积分排名标签
    local rankLabel = ui.newLabel({
    	text = TR("积分排名"),
    	color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x72, 0x25, 0x13),
    })
    rankLabel:setPosition(self.mBgSize.width * 0.25, self.mBgSize.height * 0.37)
    bgSprite:addChild(rankLabel, 2)

 	-- 左右的线
 	-- local posX1, posY1 = rankLabel:getPosition()
 	-- local line1 = ui.newSprite("c_25.png")
 	-- line1:setAnchorPoint(cc.p(1, 0.5))
 	-- line1:setPosition(posX1 - rankLabel:getContentSize().width * 0.5 - 5, posY1)
  --   line1:setFlippedX(true)
 	-- bgSprite:addChild(line1)

 	-- local line2 = ui.newSprite("c_25.png")
 	-- line2:setAnchorPoint(cc.p(0, 0.5))
 	-- line2:setPosition(posX1 + rankLabel:getContentSize().width * 0.5 + 5, posY1)
 	-- bgSprite:addChild(line2)

 	-- 窗体
 	local window1 = ui.newScale9Sprite("c_54.png",cc.size(300, 330))
    -- window1:setContentSize(cc.size(300, 300))
    -- window1:setCapInsets(cc.rect(59, 50, 5, 5))
 	window1:setPosition(self.mBgSize.width * 0.255, self.mBgSize.height * 0.241)
 	bgSprite:addChild(window1)

 	-------------排名奖励-------------
 	-- 排名奖励标签
    local awardLabel = ui.newLabel({
    	text = TR("排名奖励"),
    	color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x72, 0x25, 0x13),
    })
    awardLabel:setPosition(self.mBgSize.width * 0.75, self.mBgSize.height * 0.37)
    bgSprite:addChild(awardLabel, 2)

 	-- 左右的线
 	local posX2, posY2 = awardLabel:getPosition()
 	-- local line3 = ui.newSprite("c_25.png")
 	-- line3:setAnchorPoint(cc.p(1, 0.5))
 	-- line3:setPosition(posX2 - rankLabel:getContentSize().width * 0.5 - 5, posY2)
  --   line3:setFlippedX(true)
 	-- bgSprite:addChild(line3)

 	-- local line4 = ui.newSprite("c_25.png")
 	-- line4:setAnchorPoint(cc.p(0, 0.5))
 	-- line4:setPosition(posX2 + rankLabel:getContentSize().width * 0.5 + 5, posY2)
 	-- bgSprite:addChild(line4)

 	-- 窗体
 	local window2 = ui.newScale9Sprite("c_54.png",cc.size(300, 330))
    -- window2:setContentSize(cc.size(300, 300))
    -- window2:setCapInsets(cc.rect(59, 50, 5, 5))
 	window2:setPosition(self.mBgSize.width * 0.745, self.mBgSize.height * 0.241)
 	bgSprite:addChild(window2)

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

--规则特殊回调
function ActivityRecruitLayer:ruleBtnCallFun()
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eShowTheProbability, false) then
            -- 规则窗体的 DIY 函数
        local function DIYFuncion(layer, layerBgSprite, layerSize)

            local function showRule(list)
                -- 滑动控件
                local listSize = cc.size(layerSize.width * 0.75, layerSize.height*0.42)
                local listView = ccui.ListView:create()
                listView:setItemsMargin(5)
                listView:setDirection(ccui.ListViewDirection.vertical)
                listView:setBounceEnabled(true)
                listView:setAnchorPoint(cc.p(0.5, 0.5))
                listView:setPosition(layerSize.width / 2, layerSize.height*0.47)
                layerBgSprite:addChild(listView)
                listView:setTag(999)

                local maxHeight = 0
                for index, item in ipairs(list or {}) do
                    local lvItem = ccui.Layout:create()
                    local tempLabel = ui.newLabel({
                        text = item,
                        color = cc.c3b(0x46, 0x22, 0x0d),
                        dimensions = cc.size(listSize.width, 0)
                    })
                    tempLabel:setAnchorPoint(cc.p(0, 0.5))
                    local cellSize = tempLabel:getContentSize()
                    tempLabel:setPosition(0, cellSize.height / 2)
                    lvItem:addChild(tempLabel)

                    lvItem:setContentSize(cellSize)
                    listView:pushBackCustomItem(lvItem)

                    maxHeight = maxHeight + cellSize.height + 5
                end

                if maxHeight < listSize.height then
                    listView:setTouchEnabled(false)
                end
                listView:setContentSize(cc.size(listSize.width, math.min(maxHeight, listSize.height)))
            end

            local buttonInfos = {
                [1] = {
                    text = TR("概率详情"),
                    tag = 1,
                },
                [2] = {
                    text = TR("规则"),
                    tag = 2,
                }
            }

            local ruleList = {
                [1] = TR("1.每次抽奖都有概率获得%s[武林传说选择包]%s，打开后可任意选择1名当前展示的武林传说级侠客", "#ff0000", "#46220d"),
                [2] = TR("2.每抽奖一次可额外获得10点积分，积分达到60/200/300/400/500/600后即可领取宝箱，打开宝箱可获得武林传说级侠客碎片"),
                [3] = TR("3.领取最后一个宝箱后，将额外获得大量祝福值，同时在之后的抽奖中可获得随机数量的祝福值"),
                [4] = TR("4.祝福值达到500即可打开宝箱获得%s[武林传说选择包]", "#ff0000"),
                [5] = TR("5.活动结束后，系统对积分排行榜中前20的玩家通过领奖中心发放额外的%s[武林传说选择包]%s奖励", "#ff0000", "#46220d")
            }
            local probabilityList = {
                [1] = TR("限时招募概率为：\n传说1%、神话3%、宗师20%、豪侠76%。"),
            }

            -- 创建分页按钮
            local tabLayer = ui.newTabLayer({
                btnInfos = buttonInfos,
                viewSize = cc.size(572, 80),
                isVert = false,
                btnSize = cc.size(130, 50),
                space = 14,
                needLine = false,
                defaultSelectTag = 1,
                onSelectChange = function(selectBtnTag)
                    layerBgSprite:removeChildByTag(999)    
                    if selectBtnTag == 1 then
                        showRule(probabilityList)
                    elseif selectBtnTag == 2 then
                        showRule(ruleList)
                    end
                end
            })
            tabLayer:setAnchorPoint(cc.p(0.5, 1))
            tabLayer:setPosition(300, 370)
            layerBgSprite:addChild(tabLayer)

            local blackSize = cc.size(layerSize.width*0.9, (layerSize.height-220))
            local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
            blackBg:setAnchorPoint(0.5, 0)
            blackBg:setPosition(layerSize.width/2, 100)
            layerBgSprite:addChild(blackBg)
        end

        local tempData = {
            bgSize = bgSize or cc.size(572, 420),
            title = title or TR("规则"),
            closeBtnInfo = closeBtnInfo or {},
            btnInfos = btnInfos or {{text = TR("确定"),}},
            DIYUiCallback = DIYFuncion,
            notNeedBlack = true,
        }

        return LayerManager.addLayer({
            name = "commonLayer.MsgBoxLayer",
            data = tempData,
            cleanUp = false,
        })
    else
        MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.每次抽奖都有概率获得%s[武林传说选择包]%s，打开后可任意选择1名当前展示的武林传说级侠客", "#ff0000", "#46220d"),
                [2] = TR("2.每抽奖一次可额外获得10点积分，积分达到60/200/300/400/500/600后即可领取宝箱，打开宝箱可获得武林传说级侠客碎片"),
                [3] = TR("3.领取最后一个宝箱后，将额外获得大量祝福值，同时在之后的抽奖中可获得随机数量的祝福值"),
                [4] = TR("4.祝福值达到500即可打开宝箱获得%s[武林传说选择包]", "#ff0000"),
                [5] = TR("5.活动结束后，系统对积分排行榜中前20的玩家通过领奖中心发放额外的%s[武林传说选择包]%s奖励", "#ff0000", "#46220d")
            })
    end
end
-- 持续时间倒计时
function ActivityRecruitLayer:updateTime()
    -- 活动结束倒计时
    local timeLeft1 = self.mTimedRecruitInfo.EndTime - Player:getCurrentTime()
    if timeLeft1 > 0 then
        self.mTimeLabel:setString(TR(MqTime.formatAsDay(timeLeft1)))
    else
        self.mTimeLabel:setString(TR("00:00:00"))

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

    -- 招募按钮免费时间
    local str = nil
    local timeLeft2 = self.mTimedRecruitInfo.CooledTime - Player:getCurrentTime()
    if timeLeft2 > 0 then
        str = TR("%s%s%s后免费", Enums.Color.eSkyBlueH, MqTime.formatAsDay(timeLeft2), "#4E280F")

        -- 按钮名称及事件
        self.mRecruitBtn:setTitleText(TR("元宝招募"))
        self.mRecruitBtn:setClickAction(function()
            self:showRecruitSelectLayer()
        end)
    else
        str = TR("可免费招募一次")

        -- 按钮名称及事件
        self.mRecruitBtn:setTitleText(TR("免费招募"))
        self.mRecruitBtn:setClickAction(function()
            self:requestRecruit(1)
        end)
    end
    self.mBtnTimeLabel:setString(str)
end

-- 整理限时招募信息
function ActivityRecruitLayer:handleTimedRecruitInfo()
    -- 3个神将modelId列表
    local goodsID = TimedRecruitModel.items[self.mTimedRecruitInfo.ActivityEnumId].goldHeroModelID      -- 产出神将的道具模型id
    self.mHeroIdList = {}
    for _, v in pairs(GoodsOutputRelation.items[goodsID]) do
        self.mHeroIdList[#self.mHeroIdList + 1] = v.outputModelID
    end

    -- 已领取的积分列表，保险起见转换为number类型
    self.mDrawnCreditList = {}
    local tempList = string.splitBySep(self.mTimedRecruitInfo.DrawCreditRewards, ",")
    for k, v in pairs(tempList) do
        table.insert(self.mDrawnCreditList, tonumber(v))
    end
    table.sort(self.mDrawnCreditList, function (a, b)
        return a < b
    end)

    -- 宝箱积分奖励列表
    self.mCreditRewardList = {}
    for i, v in ipairs(TimedRecruitCreditrewardRelation.items) do
        if v.activityEnumID == self.mTimedRecruitInfo.ActivityEnumId then
            table.insert(self.mCreditRewardList, v)
        end
    end
    table.sort(self.mCreditRewardList, function (a, b)
        return a.needCredit < b.needCredit
    end)

    -- 排名奖励列表，从小到大排序
    self.mRankRewardList = {}
    for k1, v1 in pairs(TimedRecruitRankrewardModel.items[self.mTimedRecruitInfo.ActivityEnumId]) do
        for k2, v2 in pairs(v1) do
            table.insert(self.mRankRewardList, v2)
        end
    end
    table.sort(self.mRankRewardList, function(a, b)
        return a.rankMin < b.rankMin
    end)
end

-- 根据在英雄表中的索引号创建一个包含有名字、阵营的英雄，并添加到指定节点上
--[[
    params:
    index                  英雄表中的索引号，由此号来创建英雄
    parent                 英雄添加到该节点上去

    return:
    hero                   返回新创建的这名英雄
--]]
function ActivityRecruitLayer:createHeroByIndex(index, parent)
    --得到英雄信息
    local heroModelInfo = HeroModel.items[self.mHeroIdList[index]]
    -- dump(heroModelInfo)
    -- 创建英雄
    local hero = Figure.newHero({
        heroModelID = self.mHeroIdList[index],
        position = cc.p(parent:getContentSize().width / 2, parent:getContentSize().height / 2),
        scale = 0.22,
        buttonAction = function()
            local tempData = {
                heroModelId = self.mHeroIdList[index],
                onlyViewInfo = false,
            }
            LayerManager.addLayer({name = "hero.HeroInfoLayer", data = tempData, cleanUp = false})
        end,
    })
    parent:addChild(hero)

    -- 名字标签背景
    local nameBg = ui.newSprite("xshd_04.png")
    nameBg:setPosition(-101, 130)
    nameBg:setScale(1.2)
    parent:addChild(nameBg)

    -- 名称
    local nameLabel = ui.newLabel({
        text = ConfigFunc:getHeroName(self.mHeroIdList[index]),
        color = Utility.getQualityColor(heroModelInfo.quality, 1),
        anchorPoint = cc.p(0.5, 1),
        dimensions = cc.size(22, 0),
        size = 24,
        align = ui.TEXT_ALIGN_CENTER
    })
    nameLabel:setPosition(-100, 200)
    parent:addChild(nameLabel)

    -- 阵营标签
    local raceSprite = Figure.newHeroRaceAndQuality(self.mHeroIdList[index])
    if (raceSprite ~= nil) then
        raceSprite:setPosition(80, 220)
        parent:addChild(raceSprite)
    end
end

-- 添加持续滑动的神将
function ActivityRecruitLayer:addSlidingHeros()
    -- 每帧移动的距离
    local deltaX = 2
    -- 人物形象位置，用于滚动
    self.mHeroPos = {
        [1] = cc.p(self.mBgSize.width * -0.2, self.mBgSize.height * 0.52),
        [2] = cc.p(self.mBgSize.width * 0.5, self.mBgSize.height * 0.52),
        [3] = cc.p(self.mBgSize.width * 1.2, self.mBgSize.height * 0.52),
        [4] = cc.p(self.mBgSize.width * -0.95, self.mBgSize.height * 0.52),
    }
    local cycleCount = #self.mHeroPos-1 < #self.mHeroIdList and #self.mHeroPos or #self.mHeroIdList
    self.mHeroNodeList = {}
    for i = 1, cycleCount do
        local heroNode = cc.Node:create()
        heroNode:setPosition(self.mHeroPos[i])
        self.mBgSprite:addChild(heroNode)
        self:createHeroByIndex(i, heroNode)
        self.mHeroNodeList[#self.mHeroNodeList + 1] = heroNode
    end
    -- -- 创建第一个node
    -- self.mHeroNode1 = cc.Node:create()
    -- self.mHeroNode1:setPosition(self.mHeroPos[1])
    -- self.mBgSprite:addChild(self.mHeroNode1)
    -- -- node上的人物
    -- self:createHeroByIndex(1, self.mHeroNode1)

    -- -- 创建第二个node
    -- self.mHeroNode2 = cc.Node:create()
    -- self.mHeroNode2:setPosition(self.mHeroPos[2])
    -- self.mBgSprite:addChild(self.mHeroNode2)
    -- -- node上的人物
    -- self:createHeroByIndex(2, self.mHeroNode2)

    -- -- 创建第三个nodde
    -- self.mHeroNode3 = cc.Node:create()
    -- self.mHeroNode3:setPosition(self.mHeroPos[3])
    -- self.mBgSprite:addChild(self.mHeroNode3)
    -- -- node上的人物
    -- self:createHeroByIndex(3, self.mHeroNode3)

    -- 神将持续滑动逻辑(改变神将的显示位置)
    local function updateHeroLocation()
        for i = 1, #self.mHeroNodeList do
            -- 获取node的坐标
            local posX, posY = self.mHeroNodeList[i]:getPosition()
            -- 改变node的位置
            posX = posX - deltaX
            -- 重置node的坐标
            self.mHeroNodeList[i]:setPosition(posX, posY)
            -- 判断神将的位置，到一定距离后重置神将的位置
            if posX <= self.mHeroPos[4].x then
                self.mHeroNodeList[i]:setPosition(self.mHeroPos[3])
            end
        end
        -- -- 获取node的坐标
        -- local pos1X, pos1Y = self.mHeroNode1:getPosition()
        -- local pos2X, pos2Y = self.mHeroNode2:getPosition()
        -- local pos3X, pos3Y = self.mHeroNode3:getPosition()

        -- -- 改变node的位置
        -- pos1X = pos1X - deltaX
        -- pos2X = pos2X - deltaX
        -- pos3X = pos3X - deltaX

        -- -- 重置node的坐标
        -- self.mHeroNode1:setPosition(cc.p(pos1X, pos1Y))
        -- self.mHeroNode2:setPosition(cc.p(pos2X, pos2Y))
        -- self.mHeroNode3:setPosition(cc.p(pos3X, pos3Y))

        -- -- 判断神将的位置，到一定距离后重置神将的位置
        -- if pos1X <= self.mHeroPos[4].x then
        --     self.mHeroNode1:setPosition(self.mHeroPos[3])
        -- end

        -- if pos2X <= self.mHeroPos[4].x then
        --     self.mHeroNode2:setPosition(self.mHeroPos[3])
        -- end

        -- if pos3X <= self.mHeroPos[4].x then
        --     self.mHeroNode3:setPosition(self.mHeroPos[3])
        -- end
    end

    -- 定时器
    Utility.schedule(self, updateHeroLocation, 0.01)
end

-- 点击元宝招募，弹出的招募次数选择页面
function ActivityRecruitLayer:showRecruitSelectLayer()
    local function makeSureView(price, count)
        MsgBoxLayer.addOKCancelLayer(
            TR("是否花费%d元宝购买{xshd_48.png}*%d？", price, count),
            TR("提示"),
            {
                text = TR("确定"),
                clickAction = function(layerObj)
                    if self.mTimedRecruitInfo.LimitNum < count then
                        ui.showFlashView(TR("剩余招募次数不足"))
                    else
                        if count == 1 then
                            self:requestRecruit(3)
                        else
                            self:requestRecruit(30)
                        end
                    end
                    LayerManager.removeLayer(layerObj)
                end
        })
    end

    local function DIYFunction(layerObj, layerBg, layerBgSize)
        local info = TimedRecruitModel.items[self.mTimedRecruitInfo.ActivityEnumId]

        -- 招募一次按钮
        local oneBtn = ui.newButton({
            normalImage = "xshd_28.png",
            clickAction = function()
                local isEnough = Utility.isResourceEnough(ResourcetypeSub.eDiamond,
                    info.recruitPrice)
                if isEnough then
                    -- LayerManager.removeLayer(layerObj)
                    makeSureView(info.recruitPrice, 1) 
                end
            end
        })
        oneBtn:setPosition(layerBgSize.width * 0.3, layerBgSize.height * 0.6)
        layerBg:addChild(oneBtn)

        -- 招募一次消耗
        local picName = "xshd_48.png"

        local oneLabel = ui.newLabel({
            text = string.format("{%s}%s*%d", picName, Enums.Color.eNormalWhiteH, 1),
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            align = ui.TEXT_ALIGN_CENTER
        })
        oneLabel:setPosition(layerBgSize.width * 0.3, layerBgSize.height * 0.33)
        layerBg:addChild(oneLabel)

        -- 招募十次按钮
        local tenBtn = ui.newButton({
            normalImage = "xshd_29.png",
            clickAction = function()
                local isEnough = Utility.isResourceEnough(ResourcetypeSub.eDiamond,
                    tonumber(TimedRecruitModel.items[self.mTimedRecruitInfo.ActivityEnumId].recruitPrice) * 10)
                if isEnough then
                    makeSureView(info.recruitPrice*10, 10) 
                end
            end
        })
        tenBtn:setPosition(layerBgSize.width * 0.7, layerBgSize.height * 0.6)
        layerBg:addChild(tenBtn)

        -- 招募十次消耗
        local tenLabel = ui.newLabel({
            text = string.format("{%s}%s*%d", picName, Enums.Color.eNormalWhiteH, 10),
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            align = ui.TEXT_ALIGN_CENTER
        })
        tenLabel:setPosition(layerBgSize.width * 0.7, layerBgSize.height * 0.33)
        layerBg:addChild(tenLabel)
    end


    -- 招募次数选择
    MsgBoxLayer.addDIYLayer({
        bgSize = cc.size(572, 360),
        msgText = "",
        title = TR("元宝招募"),
        closeBtnInfo = {},
        DIYUiCallback = DIYFunction
    })
end

-- 添加活动结束时间标签、招募按钮及时间标签
function ActivityRecruitLayer:addRecruitBtnAndTimeLabels()
    ------------移除所有------------
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil

        for k, v in pairs(self.mRemoveList) do
            v:removeFromParent()
        end
    end
    -------------------------------

    -----------重新添加-------------
    self.mRemoveList = {}
    -- 活动倒计时
    local timeLabel1 = ui.newLabel({
        text = TR("持续时间"),
        color = cc.c3b(0x4e, 0x28, 0x0f),
        align = ui.TEXT_ALIGN_CENTER
    })
    timeLabel1:setAnchorPoint(cc.p(0.5, 0))
    timeLabel1:setPosition(520, 515)
    self.mBgSprite:addChild(timeLabel1)
    table.insert(self.mRemoveList, timeLabel1)

    local timeLabel2 = ui.newLabel({
        text = "",
        color = Enums.Color.eRed,
        align = ui.TEXT_ALIGN_CENTER
    })
    timeLabel2:setAnchorPoint(cc.p(0.5, 0))
    timeLabel2:setPosition(520, 485)
    self.mBgSprite:addChild(timeLabel2)
    self.mTimeLabel = timeLabel2
    table.insert(self.mRemoveList, timeLabel2)

    -- 招募按钮
    self.mRecruitBtn = ui.newButton({
        normalImage = "c_33.png",
        text = "",
    })
    self.mRecruitBtn:setPosition(320, 520)
    self.mBgSprite:addChild(self.mRecruitBtn)
    table.insert(self.mRemoveList, self.mRecruitBtn)

    local timeLabel3 = ui.newLabel({
        text = "",
        size = 22,
        color = cc.c3b(0x4e, 0x28, 0x0f),
        align = ui.TEXT_ALIGN_CENTER
    })
    timeLabel3:setPosition(320, 570)
    self.mBgSprite:addChild(timeLabel3)
    self.mBtnTimeLabel = timeLabel3
    table.insert(self.mRemoveList, timeLabel3)

    -- 倒计时
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    -- 标题标签 再招XX次必出橙将
    local titleBg = ui.newScale9Sprite("c_25.png", cc.size(300, 50))
    titleBg:setPosition(320, 940)
    self.mBgSprite:addChild(titleBg)
    table.insert(self.mRemoveList, titleBg)

    local titleStr = nil
    if self.mTimedRecruitInfo.OutputHighHeroIntervalNum == 0 then
        titleStr = TR("本次必出%s宗师", Enums.Color.eOrangeH)
    else
        titleStr = TR("再招%s次必出%s宗师", self.mTimedRecruitInfo.OutputHighHeroIntervalNum + 1, Enums.Color.eOrangeH)
    end
    self.mTitleLabel = ui.newLabel({
        text = titleStr,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mTitleLabel:setPosition(titleBg:getContentSize().width * 0.5, titleBg:getContentSize().height * 0.5)
    titleBg:addChild(self.mTitleLabel)

    --抽奖次数限制label
    local totalNumLabel = ui.newLabel({
        text = TR("今日剩余招募次数：%d/%d", self.mTimedRecruitInfo.LimitNum, self.mTimedRecruitInfo.TotalNum),
        color = Enums.Color.eRed,
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 20,
        align = ui.TEXT_ALIGN_CENTER
    })
    totalNumLabel:setPosition(320, 480)
    self.mParentLayer:addChild(totalNumLabel)
    table.insert(self.mRemoveList, totalNumLabel)

end

-- 添加宝箱及积分标签
function ActivityRecruitLayer:addChestAndIntegralLabel()
    if self.mChestBtn then
        self.mChestBtn:stopAllActions()
        self.mChestBtn:removeFromParent()
        self.mIntegralLabel:removeFromParent()
    end

    -- 设置宝箱按钮
    self.mChestBtn = ui.newButton({
        normalImage = "c_83.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(100, 552),
        size = cc.size(100, 100),
        clickAction = function()
           self:showChestBoxLayer()
        end
    })
    self.mBgSprite:addChild(self.mChestBtn)
    self.mRewardBox = ui.newEffect({
            parent = self.mChestBtn,
            effectName = "effect_jipingbaoxiang",
            scale = 0.2,
            position = cc.p(self.mChestBtn:getContentSize().width / 2, self.mChestBtn:getContentSize().height / 2),
            loop = true,
            endRelease = true,
        })

    -- 积分标签
    self.mIntegralLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0xff, 0x00, 0x00),
        anchorPoint = cc.p(0.5, 0.5),
    })
    self.mIntegralLabel:setPosition(100, 495)
    self.mBgSprite:addChild(self.mIntegralLabel)

    ------------宝箱及标签状态---------
    -- 未领到最大积分奖励，一直显示 积分:X/X
    if #self.mDrawnCreditList < #self.mCreditRewardList then
        -- 没有领取任何一个积分奖励
        if #self.mDrawnCreditList == 0 then
            self.mNeedIntegral = self.mCreditRewardList[1].needCredit
        else
            for i, v in ipairs(self.mCreditRewardList) do
                if v.needCredit == self.mDrawnCreditList[#self.mDrawnCreditList] then
                    self.mNeedIntegral = self.mCreditRewardList[i + 1].needCredit
                end
            end
        end

        if self.mTimedRecruitInfo.MyCredit >= self.mNeedIntegral then
            self.mIntegralLabel:setString(TR("积分: %s/%s", self.mTimedRecruitInfo.MyCredit, self.mNeedIntegral))

            -- 宝箱抖动
            self.mChestStatus = ChestStatus.eCanDraw
            --ui.setWaveAnimation(self.mChestBtn, 7.5, false)
            self.mRewardBox:setAnimation(0, "kaiqi", true)
            -- 显示宝箱弹窗界面
            self.mShowChestBoxLayer = true
        else
            self.mIntegralLabel:setString(TR("积分: %s/%s", self.mTimedRecruitInfo.MyCredit, self.mNeedIntegral))

            self.mChestStatus = ChestStatus.eCanNotDraw
            self.mShowChestBoxLayer = false
        end
    else
        self.mIsBless = true
        -- self.mChestBtn:loadTextureNormal("r_12.png")
        -- self.mChestBtn:loadTexturePressed("r_12.png")
        --self.mRewardBox:setAnimation(0, "kaiqi", false)

        self.mNeedIntegral = TimedRecruitModel.items[self.mTimedRecruitInfo.ActivityEnumId].receiveBlessNum
        if self.mTimedRecruitInfo.BlessNum >= self.mNeedIntegral then
            self.mIntegralLabel:setString(TR("祝福值: %s/%s", self.mTimedRecruitInfo.BlessNum, self.mNeedIntegral))

            self.mChestStatus = ChestStatus.eCanDraw
            --ui.setWaveAnimation(self.mChestBtn, 7.5, false)
            self.mRewardBox:setAnimation(0, "kaiqi", true)

            self.mShowChestBoxLayer = true
        else
             self.mIntegralLabel:setString(TR("祝福值: %s/%s", self.mTimedRecruitInfo.BlessNum, self.mNeedIntegral))

            self.mChestStatus = ChestStatus.eCanNotDraw
            self.mShowChestBoxLayer = false
        end
    end

    -- 显示弹框条件成立，进入页面直接显示出来
    if self.mShowChestBoxLayer then
        self:showChestBoxLayer()
    end
end

-- 点击宝箱弹出的奖励预览页面
function ActivityRecruitLayer:showChestBoxLayer()
    local rewardGoodsList = nil
    local text = nil
    local btnInfo = nil
    if self.mIsBless then
        -- 奖励预览资源表
        local mId = TimedRecruitModel.items[self.mTimedRecruitInfo.ActivityEnumId].goldHeroModelID
        local tId = ResourcetypeSub.eBoxChoice              -- 此处已经确定是神将选择包
        rewardGoodsList = {
            {
                resourceTypeSub = tId,
                modelId = mId,
                num = 1
            }
        }

        -- 内容
        text = TR("达到%s%s%s祝福值可以领取", Enums.Color.eNormalGreenH, self.mNeedIntegral, Enums.Color.eNormalWhiteH)

        -- 按钮
        if self.mTimedRecruitInfo.BlessNum >= self.mNeedIntegral then
            btnInfo = {
                text = TR("领取"),
                textColor = Enums.Color.eWhite,
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)

                    local layerParams = {
                        activityEnumId = self.mTimedRecruitInfo.ActivityEnumId,
                        isBless = true,
                        needCloseBtn = true,
                        callback = function (blessNum)
                            self.mTimedRecruitInfo.BlessNum = blessNum

                            -- 重新添加宝箱按钮和积分标签
                            self:addChestAndIntegralLabel()
                        end
                    }
                    LayerManager.addLayer({
                        name = "activity.ChooseGoldHeroLayer",
                        data = layerParams,
                        cleanUp = false
                    })
                end
            }
        else
            btnInfo = {
                text = TR("关闭"),
                textColor = Enums.Color.eWhite,
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                end
            }
        end
    else
        -- 奖励预览资源表
        for i, v in ipairs(self.mCreditRewardList) do
            if v.needCredit == self.mNeedIntegral then
                rewardGoodsList = Utility.analysisStrResList(v.creditReward)
                break
            end
        end

        -- 文字内容
        text = TR("达到%s%s%s积分可以领取", Enums.Color.eNormalGreenH, self.mNeedIntegral, Enums.Color.eNormalWhiteH)

        -- 按钮
        if self.mTimedRecruitInfo.MyCredit >= self.mNeedIntegral then
            btnInfo = {
                text = TR("领取"),
                textColor = Enums.Color.eWhite,
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)

                    self:requestDrawCreditReward(self.mNeedIntegral)
                end
            }
        else
            btnInfo = {
                text = TR("关闭"),
                textColor = Enums.Color.eWhite,
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                end
            }
        end
    end

    MsgBoxLayer.addPreviewDropLayer(
        rewardGoodsList,
        text,
        TR("宝箱领取"),
        {btnInfo},
        {}
    )
end

-- 添加积分排名滑动窗体
function ActivityRecruitLayer:addIntegralListView()
    -- 每次先移除再重新添加
    if self.mIntegralListView then
        self.mIntegralListView:removeFromParent()
        self.mPlayerLabelNode:removeFromParent()
    end

    self.mIntegralListView = ccui.ListView:create()
    self.mIntegralListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mIntegralListView:setBounceEnabled(true)
    self.mIntegralListView:setContentSize(cc.size(300, 220))
    self.mIntegralListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mIntegralListView:setItemsMargin(3)
    self.mIntegralListView:setAnchorPoint(cc.p(0.5, 1.0))
    self.mIntegralListView:setIgnoreAnchorPointForPosition(false)
    self.mIntegralListView:setPosition(self.mBgSize.width * 0.255, self.mBgSize.height * 0.34)
    self.mBgSprite:addChild(self.mIntegralListView)

    for i = 1, #self.mTimedRecruitInfo.RankList do
        self.mIntegralListView:pushBackCustomItem(self:createCellByIndex1(i))
    end

    -- 玩家自己的排名情况
    self.mPlayerLabelNode = cc.Node:create()
    self.mPlayerLabelNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.mPlayerLabelNode:setContentSize(cc.size(300, 30))
    self.mPlayerLabelNode:setPosition(self.mBgSize.width * 0.255, self.mBgSize.height * 0.12 + 10)
    self.mBgSprite:addChild(self.mPlayerLabelNode)

    -- 排名
    local rankLabel = ui.newLabel({
        text = self.mTimedRecruitInfo.MyRank,
        color = cc.c3b(0x3b, 0x55, 0x8a),
        size = 20,
    })
    rankLabel:setPosition(30, 10)
    self.mPlayerLabelNode:addChild(rankLabel)

    -- 名字
    local nameLabel = ui.newLabel({
        text = PlayerAttrObj:getPlayerAttrByName("PlayerName"),
        color = cc.c3b(0x3b, 0x55, 0x8a),
    })
    nameLabel:setPosition(140, 10)
    self.mPlayerLabelNode:addChild(nameLabel)

    -- 积分
    local integralLabel = ui.newLabel({
        text = self.mTimedRecruitInfo.MyCredit,
        color = cc.c3b(0x3b, 0x55, 0x8a),
        size = 20,
    })
    integralLabel:setPosition(260, 10)
    self.mPlayerLabelNode:addChild(integralLabel)
end

-- 创建积分排名的每一个条目
--[[
    params:
    index                       -- 条目的索引号
--]]
function ActivityRecruitLayer:createCellByIndex1(index)
    local info = self.mTimedRecruitInfo.RankList[index]

    -- 创建cell
    local cellWidth, cellHeight = 300, 30
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    -- 排名
    local rankLabel = ui.newLabel({
        text = info.Rank,
        color = cc.c3b(0x4e, 0x28, 0x0f),
        size = 20,
    })
    rankLabel:setPosition(30, 15)
    customCell:addChild(rankLabel)

    -- 名字
    local nameLabel = ui.newLabel({
        text = info.PlayerName,
        color = cc.c3b(0x4e, 0x28, 0x0f),
    })
    nameLabel:setPosition(140, 15)
    customCell:addChild(nameLabel)

    -- 积分
    local integralLabel = ui.newLabel({
        text = info.Credit,
        color = cc.c3b(0x4e, 0x28, 0x0f),
        size = 20,
    })
    integralLabel:setPosition(260, 15)
    customCell:addChild(integralLabel)

    return customCell
end

-- 添加排名奖励滑动窗体
function ActivityRecruitLayer:addRewardListView()
    -- 创建ListView列表
    self.mRewardListView = ccui.ListView:create()
    self.mRewardListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mRewardListView:setBounceEnabled(true)
    self.mRewardListView:setContentSize(cc.size(300, 245))
    self.mRewardListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mRewardListView:setItemsMargin(12)
    self.mRewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mRewardListView:setIgnoreAnchorPointForPosition(false)
    self.mRewardListView:setPosition(self.mBgSize.width * 0.745, self.mBgSize.height * 0.235)
    self.mBgSprite:addChild(self.mRewardListView)

    for i = 1, #self.mRankRewardList do
        self.mRewardListView:pushBackCustomItem(self:createCellByIndex2(i))
    end
end

-- 创建排名奖励的每一个条目
--[[
    params:
    index                       -- 条目的索引号
--]]
function ActivityRecruitLayer:createCellByIndex2(index)
    local info = self.mRankRewardList[index]
    local goodsList = Utility.analysisStrResList(info.resourceList)

    -- 创建custom_item
    local labelHeight, headerHeight = 30, 93
    local cellWidth, cellHeight = 300, labelHeight + headerHeight
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(cellWidth, cellHeight))

    -- 第X~X名
    local str = nil
    if info.rankMin == info.rankMax then
        str = TR("第  %s  名", info.rankMin)
    else
        str = TR("第  %s~%s  名", info.rankMin, info.rankMax)
    end
    local label = ui.newLabel({
        text = str,
        color = cc.c3b(0x4e, 0x28, 0x0f),
        align = ui.TEXT_ALIGN_LEFT
    })
    label:setAnchorPoint(cc.p(0, 1))
    label:setPosition(10, cellHeight)
    customCell:addChild(label)

    -- 奖品listView
    local rewardList = {}
    for i, v in ipairs(goodsList) do
        local tempList = {}
        tempList.resourceTypeSub = v.resourceTypeSub
        tempList.modelId = v.modelId
        tempList.num = v.num
        tempList.needNameTitle = false
        tempList.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}

        table.insert(rewardList, tempList)
    end
    local listView = ui.createCardList({
        maxViewWidth = 300 / 0.7,
        space = -10,
        cardDataList = rewardList,
        cardShape = Enums.CardShape.eCircle,
        allowClick = true,
    })
    listView:setAnchorPoint(cc.p(0, 1))
    listView:setIgnoreAnchorPointForPosition(false)
    listView:setPosition(0, cellHeight - labelHeight)
    listView:setScale(0.85)
    customCell:addChild(listView)

    return customCell
end

-- 判断是否有可领取的神将选择包
-- 当免费招募，获得了神将选择包，没有领取直接退游戏或杀进程，再次进入页面时需判断是否有可领的神将选择包
function ActivityRecruitLayer:checkGoldHeroDrawnAvailable()
    -- 神将包是否可领取   false: 可领取  true:不可领取
    if self.mTimedRecruitInfo.DrawGoldHero == false then
        local layerParams = {
            activityEnumId = self.mTimedRecruitInfo.ActivityEnumId,
            isBless = false,
            recruitType = 3,
            callback = function(recruit)
                local info = TimedRecruitModel.items[self.mTimedRecruitInfo.ActivityEnumId]
                local isEnough = Utility.isResourceEnough(ResourcetypeSub.eDiamond, info.recruitPrice)
                if isEnough then
                    self:requestRecruit(recruit)
                end
            end
        }
        LayerManager.addLayer({
            name = "activity.ChooseGoldHeroLayer",
            data = layerParams,
            cleanUp = false
        })
    end
end

--------------------网络相关---------------------
-- 请求服务器，获取限时招募页面信息
function ActivityRecruitLayer:requestGetTimedRecruitInfo()
    HttpClient:request({
        moduleName = "TimedRecruitInfo",
        methodName = "GetTimedRecruitInfo",
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mTimedRecruitInfo = data.Value

            --------整理数据-------
            self:handleTimedRecruitInfo()

            -- 添加滑动的英雄
            self:addSlidingHeros()

            -- 添加活动结束时间标签、招募按钮及时间标签、标题标签
            self:addRecruitBtnAndTimeLabels()

            -- 添加宝箱和积分标签
            self:addChestAndIntegralLabel()

            -- 添加积分排名滑动窗体
            self:addIntegralListView()

            -- 添加排名奖励滑动窗体
            self:addRewardListView()

            -- 检查是否有可领取的神将选择包
            self:checkGoldHeroDrawnAvailable()
        end
    })
end

-- 请求服务器，领取积分奖励
--[[
    credit                  -- 领取该宝箱所需要的积分
--]]
function ActivityRecruitLayer:requestDrawCreditReward(credit)
    HttpClient:request({
        moduleName = "TimedRecruitInfo",
        methodName = "DrawCreditReward",
        svrMethodData = {credit},
        callbackNode = self,
        callback = function (data)
            --dump(data, "requestDrawCreditReward:", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 飘窗显示奖励
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            ----------更新数据----------
            -- 已领取的积分列表
            self.mTimedRecruitInfo.DrawCreditRewards = string.format("%s,%s",
                self.mTimedRecruitInfo.DrawCreditRewards, credit)
            self.mDrawnCreditList = {}
            local tempList = string.splitBySep(self.mTimedRecruitInfo.DrawCreditRewards, ",")
            for k, v in pairs(tempList) do
                table.insert(self.mDrawnCreditList, tonumber(v))
            end
            table.sort(self.mDrawnCreditList, function (a, b)
                return a < b
            end)

            -- 重新添加宝箱和积分标签
            self:addChestAndIntegralLabel()
        end
    })
end

-- 请求服务器，招募英雄
--[[
    params:
    recruitType: 招募类型: 1 免费;2 道具;3 元宝;30 元宝*10次
--]]
function ActivityRecruitLayer:requestRecruit(recruitType)
    HttpClient:request({
        moduleName = "TimedRecruitInfo",
        methodName = "Recruit",
        svrMethodData = {recruitType},
        callbackNode = self,
        callback = function (data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 更新数据
            self.mTimedRecruitInfo.CooledTime = data.Value.RecruitInfo.CooledTime
            self.mTimedRecruitInfo.MyCredit = data.Value.RecruitInfo.MyCredit
            self.mTimedRecruitInfo.MyRank = data.Value.RecruitInfo.MyRank
            self.mTimedRecruitInfo.DrawGoldHero = data.Value.RecruitInfo.DrawGoldHero
            self.mTimedRecruitInfo.DrawCreditRewards = data.Value.RecruitInfo.DrawCreditRewards
            self.mTimedRecruitInfo.OutputHighHeroIntervalNum = data.Value.RecruitInfo.OutputHighHeroIntervalNum
            self.mTimedRecruitInfo.BlessNum = data.Value.RecruitInfo.BlessNum
            self.mTimedRecruitInfo.RankList = data.Value.RecruitInfo.RankList
            self.mTimedRecruitInfo.LimitNum = data.Value.RecruitInfo.LimitNum

            -- 重新添加几个标签和招募按钮
            self:addRecruitBtnAndTimeLabels()

            -- 重新添加宝箱和积分标签
            self:addChestAndIntegralLabel()

            -- 重新添加积分排名
            self:addIntegralListView()

            -- 显示招募信息
            local info = TimedRecruitModel.items[self.mTimedRecruitInfo.ActivityEnumId]
            local cost = (recruitType == 3) and info.recruitPrice or info.recruitPrice * 10
            -- 第一个就是神将
            if not data.Value.BaseGetGameResourceList[1].Hero then
                local rType = recruitType
                local layerParams = {
                    activityEnumId = self.mTimedRecruitInfo.ActivityEnumId,
                    isBless = false,
                    recruitType = rType,
                    isCanEvaluate = data.Value.IsFirstHighQualityHero,
                    callback = function(recruit)
                        local isEnough = Utility.isResourceEnough(ResourcetypeSub.eDiamond, cost)
                        if isEnough then
                            self:requestRecruit(recruit)
                        end
                    end
                }
                LayerManager.addLayer({
                    name = "activity.ChooseGoldHeroLayer",
                    data = layerParams,
                    cleanUp = false
                })
            else
                if recruitType < 30 then
                    local layerParams = {
                        activityID = self.mTimedRecruitInfo.ActivityEnumId,
                        heroInfo = data.Value.BaseGetGameResourceList[1].Hero,
                        recruitBtnType = 3,
                        typeFrom = ModuleSub.eTimedRecruit,
                        blessNum = self.mTimedRecruitInfo.BlessNum,
                        credit = self.mTimedRecruitInfo.MyCredit,
                        isCanEvaluate = data.Value.IsFirstHighQualityHero,
                        needCrd = self.mNeedIntegral,
                        btnCallBack = function(recruit)
                            local isEnough = Utility.isResourceEnough(ResourcetypeSub.eDiamond, cost)
                            if isEnough then
                                self:requestRecruit(recruit)
                            end
                        end,
                        closeCallBack = function()
                            if #self.mDrawnCreditList < #self.mCreditRewardList then
                                if self.mTimedRecruitInfo.MyCredit >= self.mCreditRewardList[#self.mCreditRewardList].needCredit then
                                    self:showChestBoxLayer()
                                end
                            else
                                if self.mTimedRecruitInfo.BlessNum >= TimedRecruitModel.items[self.mTimedRecruitInfo.ActivityEnumId].receiveBlessNum then
                                    self:showChestBoxLayer()
                                end
                            end
                        end
                    }
                    LayerManager.addLayer({
                        name = "shop.HeroRecruitShowActionLayer",
                        data = layerParams,
                        cleanUp = false
                    })
                else
                    local layerParams = {
                        activityID = self.mTimedRecruitInfo.ActivityEnumId,
                        heroList = data.Value.BaseGetGameResourceList[1].Hero,
                        recruitBtnType = 30,
                        blessNum = self.mTimedRecruitInfo.BlessNum,
                        credit = self.mTimedRecruitInfo.MyCredit,
                        needCrd = self.mNeedIntegral,
                        isCanEvaluate = data.Value.IsFirstHighQualityHero,
                        goodInfo = data.Value.BaseGetGameResourceList[1].Goods,
                        btnCallBack = function(recruit)
                            local isEnough = Utility.isResourceEnough(ResourcetypeSub.eDiamond, cost)
                            if isEnough then
                                self:requestRecruit(recruit)
                            end
                        end,
                        closeCallBack = function()
                            if #self.mDrawnCreditList < #self.mCreditRewardList then
                                if self.mTimedRecruitInfo.MyCredit >= self.mCreditRewardList[#self.mCreditRewardList].needCredit then
                                    self:showChestBoxLayer()
                                end
                            else
                                if self.mTimedRecruitInfo.BlessNum >= TimedRecruitModel.items[self.mTimedRecruitInfo.ActivityEnumId].receiveBlessNum then
                                    self:showChestBoxLayer()
                                end
                            end
                        end
                    }
                    LayerManager.addLayer({
                        name ="shop.HeroRecruitShowTenActionLayer",
                        data = layerParams,
                        cleanUp = false
                    })
                end
            end
        end
    })
end

return ActivityRecruitLayer
