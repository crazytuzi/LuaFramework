--[[
    文件名: ActivityMoneyTreeLayer.lua
	描述: 摇钱树页面, 模块Id为：
		ModuleSub.eTimedMoneyTree -- "限时-摇钱树"
		ModuleSub.eChristmasActivity5  -- "圣诞活动-摇钱树"
	效果图:
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityMoneyTreeLayer = class("ActivityMoneyTreeLayer", function()
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
function ActivityMoneyTreeLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	-- 保存活动id与结束时间戳
	self.mActivityId = params.activityIdList[1].ActivityId
	self.mActivityEndTime = params.activityIdList[1].EndDate

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

    -- 是否有缓存数据
    local tempData = self.mLayerData
    if tempData then
        print("------摇钱树：读取缓存数据------")
        -- 保存数据
        self.mActivityInfo = tempData

        -- 添加进度条上面的奖励物品
        self:addGiftsOnProgressBar()

        -- 添加奖励物品到树上
        self:addGiftsOnTree()

        -- 刷新页面
        self:refreshLayer()
    else
        print("------摇钱树：缓存无数据，请求服务器------")
        self:requestGetInfo()
    end
end

-- 获取恢复数据
function ActivityMoneyTreeLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityMoneyTreeLayer:initUI()
   	-- 背景图
   	local bgSprite = ui.newSprite("xshd_19.png")
   	bgSprite:setPosition(320, 568)
   	self.mParentLayer:addChild(bgSprite)
   	self.mBgSprite = bgSprite
   	self.mBgSize = bgSprite:getContentSize()

    -- 添加摇钱树及铜币
    self:addMoneyTreeAndGold()

   	-- 上方文字描述黑色背景框
   	local titleBg = ui.newScale9Sprite("c_25.png", cc.size(580, 90))
   	titleBg:setPosition(320, 920)
   	bgSprite:addChild(titleBg)
   	--titleBg:setScaleY(1.1)

   	-- 招财进宝文字:XXXX
   	local title = ui.newLabel({
   		text = TR("招财进宝: 每次可随机获得铜钱,元宝,道具"),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 21,
   		align = ui.TEXT_ALIGN_CENTER
   	})
   	title:setPosition(320, 938)
   	bgSprite:addChild(title)

   	-- 时间标签
   	self.mTimeLabel = ui.newLabel({
   		text = TR(""),
        size = 21,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
   		align = ui.TEXT_ALIGN_CENTER
   	})
   	self.mTimeLabel:setPosition(320, 902)
   	bgSprite:addChild(self.mTimeLabel)
   	-- 倒计时
   	self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    -- 充值按钮
    local chargeBtn = ui.newButton({
        normalImage = "tb_21.png",
        position = cc.p(70, 920),
        clickAction = function()
            LayerManager.showSubModule(ModuleSub.eCharge)
        end
    })
    bgSprite:addChild(chargeBtn)

    --添加遮罩
    local clippingNode = cc.ClippingNode:create()
    clippingNode:setAlphaThreshold(1.0)
    local stencilNode = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
    stencilNode:setContentSize(cc.size(640, 700))
    clippingNode:setStencil(stencilNode)
    clippingNode:setPosition(0, 440)
    bgSprite:addChild(clippingNode)
    self.mClippingNode = clippingNode

    -- 招财进宝
    self.mZcOneBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("招财进宝"),
    })
    self.mZcOneBtn:setPosition(180, 195)
    self.mBgSprite:addChild(self.mZcOneBtn)

    -- 招10次
    self.mZcTenBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("招十次"),
    })
    self.mZcTenBtn:setPosition(460, 195)
    self.mBgSprite:addChild(self.mZcTenBtn)

    -- 招财消耗
    self.mZcOneCost = ui.newLabel({
        text = TR(""),
        color = Enums.Color.eWhite,
        outlineColor = Enums.Color.eBlack,
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mZcOneCost:setPosition(180, 140)
    self.mBgSprite:addChild(self.mZcOneCost)

    self.mZcTenCost = ui.newLabel({
        text = TR(""),
        color = Enums.Color.eWhite,
        outlineColor = Enums.Color.eBlack,
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mZcTenCost:setPosition(460, 140)
    self.mBgSprite:addChild(self.mZcTenCost)

    --下面透明背景
    -- local bottomBg = ui.newScale9Sprite("jchd_08.png", cc.size(650, 190))
    -- bottomBg:setPosition(cc.p(320, 345))
    -- bottomBg:setOpacity(120)
    -- bgSprite:addChild(bottomBg)

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

    --如果开启概率显示
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eShowTheProbability, false) then
        local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(70, 840),
        clickAction = function()
            local contentList = {[1]={}}
            for i,v in ipairs(self.mActivityInfo.ShowRewards or {}) do
                local list = {}
                list.resourceTypeSub = v.Reward[1].ResourceTypeSub
                list.modelId = v.Reward[1].ModelId
                list.num = v.Reward[1].Count
                list.OddsTips = v.OddsTips
                table.insert(contentList[1], list)
            end
            MsgBoxLayer.addprobabilityLayer(TR("概率详情"), contentList)
        end})
        self.mParentLayer:addChild(ruleBtn, 1)
    end

    --抽奖次数限制label
    local totalNumLabel = ui.newLabel({
        text = "",
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eRed,
        size = 20,
        align = ui.TEXT_ALIGN_CENTER
    })
    totalNumLabel:setPosition(320, 110)
    self.mParentLayer:addChild(totalNumLabel)
    self.mTotalNumLabel = totalNumLabel
end

-- 添加摇钱树和铜币
function ActivityMoneyTreeLayer:addMoneyTreeAndGold()
	-- 摇钱树
    self.mTreeEffect = ui.newEffect({
        parent = self.mBgSprite,
        effectName = "effect_ui_zhaocaishu",
        animation = "daiji",
        scale = 0.9,
        position = cc.p(320, 315),
        loop = true,
        endRelease = false,
    })

    -- 树上的铜币
    local goldInfos = {
        {
            skeleton = "jingbi_04"
        },
        {
            skeleton = "jingbi_05"
        },
        {
            skeleton = "jingbi_03"
        },
        {
            skeleton = "jingbi_02"
        },
        {
            skeleton = "jingbi_01"
        }
    }

    for k, info in pairs(goldInfos) do
        local bindingLoad = self.mTreeEffect:bindBoneNode(info.skeleton)

        local goldEffect = ui.newEffect({
            parent = bindingLoad,
            effectName = "effect_ui_zhaocaishu",
            animation = "jingbi",
            loop = true,
            endRelease = false
        })

        if k <= 3 then
            goldEffect:setRotationSkewY(180)
        end
    end
end

-- 活动倒计时
function ActivityMoneyTreeLayer:updateTime()
    local timeLeft = self.mActivityEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("本次活动剩余时间:  %s%s", "#8aedff", MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mTimeLabel:setString(TR("本次活动剩余时间:  %s00:00:00", "#8aedff"))

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

-- 拿到数据后，刷新页面
function ActivityMoneyTreeLayer:refreshLayer()
    -----------刷新进度条及其上方的奖品状态----------
    -- 刷新进度条
    self.mProgressBar:setCurrValue(self.mActivityInfo.Num <= self.mMaxNum and self.mActivityInfo.Num or self.mMaxNum)

    -- 已领取积分奖励项，20 50 100 分别对应的物品
    local drawnNumsList = string.splitBySep(self.mActivityInfo.DrawnNums, ",")
    --dump(drawnNumsList, "已领取的积分列表:", 10)
    for k, header in pairs(self.mRewardHeaders) do
        -- 是否领取标记
        local haveDrawn = false

        for i, v in ipairs(drawnNumsList) do
        	-- 已领取的物品
        	if tonumber(header.needNum) == tonumber(v) then
        		haveDrawn = true
                -- 已领取
        		if not header.doneSprite then
	                header.doneSprite = ui.newSprite("jc_21.png")
	                header.doneSprite:setPosition(header:getContentSize().width * 0.5, header:getContentSize().height * 0.5)
	                header:addChild(header.doneSprite)

                    if header.liubian then
                        header.liubian:setVisible(false)
                    end

                    -- 恢复默认点击事件
                    header:setClickCallback(nil)
	            end
        	end
        end

        -- 仍未领取过
        if not haveDrawn then
            if not header.liubian then
                --特效只加1次
                local liubian = ui.newEffect({
                    parent = header,
                    effectName = "effect_ui_liubian",
                    animation = "animation",
                    position = cc.p(header:getContentSize().width * 0.5, header:getContentSize().height * 0.5),
                    scale = 1,
                    loop = true,
                    endRelease = true,
                    speed = 1,
                })
                header.liubian = liubian
            end
            -- 更新按钮事件
            if self.mActivityInfo.Num >= header.needNum then
                ui.setWaveAnimation(header, 7.5, false)
                header:setClickCallback(function()
                    self:requestDrawReward(header)
                end)
            else
                header:setClickCallback(nil)
            end
        end
    end

    self.mTotalNumLabel:setString(TR("今日剩余招财次数：%d/%d", self.mActivityInfo.LimitNum, self.mActivityInfo.TotalNum))

    -----------刷新按钮消耗及点击事件---------
    self.mZcOneCost:setString(string.format("{xshd_47.png}*%d", 1))
    self.mZcTenCost:setString(string.format("{xshd_47.png}*%d", 10))

    local function zcBtnActions(price, count)
        if Utility.isResourceEnough(ResourcetypeSub.eDiamond, price, true) then
            MsgBoxLayer.addOKCancelLayer(
                TR("是否花费%d元宝购买{xshd_47.png}*%d？", price, count),
                TR("提示"),
                {
                    text = TR("确定"),
                    clickAction = function(layerObj)
                        if self.mActivityInfo.LimitNum < count then
                            ui.showFlashView(TR("剩余招财次数不足"))
                        else
                            self:requestShakeTree(count)
                        end
                        LayerManager.removeLayer(layerObj)
                    end
                })
        end
    end

    -- 点击事件
    self.mZcOneBtn:setClickAction(function()
        zcBtnActions(self.mActivityInfo.CostNum, 1)
    end)
    self.mZcTenBtn:setClickAction(function()
        zcBtnActions(self.mActivityInfo.CostNumTen, 10)
    end)
end

-- 添加进度条上方的物品卡牌
function ActivityMoneyTreeLayer:addGiftsOnProgressBar()
    -- 创建积分进度条
    self.mMaxNum = self.mActivityInfo.Rewards[#self.mActivityInfo.Rewards].Num
    self.mProgressBar = require("common.ProgressBar"):create({
        bgImage = "xshd_17.png",
        barImage = "xshd_18.png",
        currValue = 0,
        maxValue = self.mMaxNum,
        -- contentSize = cc.size(500, 28),
        needLabel = true,
        color = Enums.Color.eWhite
    })
    self.mProgressBar:setPosition(275, 305)
    self.mBgSprite:addChild(self.mProgressBar)

	-- 存放进度条上方的卡牌对象引用
    -- dump(self.mActivityInfo.Rewards,"cccccccccc")
    self.mRewardHeaders = {}
	for k, v in ipairs(self.mActivityInfo.Rewards) do
        local reward = v.Reward[1]

        if v.Num ~= self.mMaxNum then
        	-- 下方的数字标签
            local numLabel = ui.newLabel({
                text = v.Num,
                color = Enums.Color.eWhite,
                x = (v.Num / self.mMaxNum) * self.mProgressBar:getContentSize().width,
                y = -20,
                outlineColor = Enums.Color.eBlack,
                align = ui.TEXT_ALIGN_CENTER
            })
            self.mProgressBar:addChild(numLabel)

            -- 绿色箭头
            local arrow = ui.newSprite("c_77.png")
            arrow:setPosition((v.Num / self.mMaxNum) * self.mProgressBar:getContentSize().width, 40)
            self.mProgressBar:addChild(arrow)

            -- 箭头上的卡牌
            local header = CardNode.createCardNode({
                resourceTypeSub = reward.ResourceTypeSub,
                modelId = reward.ModelId,
                num = reward.Count,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
                cardShape = Enums.CardShape.eCircle
            })
            header:setAnchorPoint(cc.p(0.5, 0))
            header:setPosition((v.Num / self.mMaxNum) * self.mProgressBar:getContentSize().width, 55)
            self.mProgressBar:addChild(header)
            header:setScale(0.85)
            header.needNum = v.Num

            table.insert(self.mRewardHeaders, header)
        else
        	-- 最终大奖
            local label = ui.newLabel({
                text = TR("最终大奖"),
                color = Enums.Color.eYellow,
                x = self.mProgressBar:getContentSize().width + 50,
                size = 22,
                y = -15,
                align = ui.TEXT_ALIGN_CENTER
            })
            self.mProgressBar:addChild(label)

            -- 箭头上的卡牌
            local header = CardNode.createCardNode({
                resourceTypeSub = reward.ResourceTypeSub,
                modelId = reward.ModelId,
                num = reward.Count,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
                cardShape = Enums.CardShape.eCircle
            })
            header:setAnchorPoint(cc.p(0.5, 0))
            header:setPosition(self.mProgressBar:getContentSize().width + 50, 20)
            self.mProgressBar:addChild(header)

            header.needNum = v.Num
            table.insert(self.mRewardHeaders, header)
        end
    end
end

-- 添加书上的物品卡牌
function ActivityMoneyTreeLayer:addGiftsOnTree()
	-- 骨骼节点信息
    local GoodsSkeleton = {
        {
            skeleton = "Item1"
        },
        {
            skeleton = "Item2"
        },
        {
            skeleton = "Item3"
        },
        {
            skeleton = "Item5"
        },
        {
            skeleton = "Item4"
        },
    }

   	-- 向节点添加物品卡牌
    local pos = {
        [1] = cc.p(-30, 25),
        [2] = cc.p(40, -13),
        [3] = cc.p(0, 0),
        [4] = cc.p(20, -15),
        [5] = cc.p(-100, -10),
    }
	for i, v in ipairs(self.mActivityInfo.ShowRewards) do
        -- 限定书上只挂5个
        if i <= 5 then
    		local reward = v.Reward[1]
    		local bindingLoad = self.mTreeEffect:bindBoneNode(GoodsSkeleton[i].skeleton)

    		local good = CardNode.createCardNode({
    		    resourceTypeSub = reward.ResourceTypeSub,
    		    modelId = reward.ModelId,
    		    num = reward.Count,
    		    cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
                cardShape = Enums.CardShape.eCircle
    		})
    		good:setScale(0.9)
    		bindingLoad:addChild(good)
            good:setPosition(pos[i])

            -- local numLabel = ui.newLabel({
            --     text = string.format("%d", i),
            --     size = 27,
            -- })
            -- good:addChild(numLabel)
            -- good:setPosition(pos[i])
        end
	end
end

-- 摇钱树抖动，铜币、奖品掉落动效
function ActivityMoneyTreeLayer:playZCEffect()
    -- 声音
    MqAudio.playEffect("activity_yaoqianshu.mp3")

    ---大幅抖动，然后再小幅摆动---
    -- 摇钱树大幅抖动
    SkeletonAnimation.action({
        skeleton = self.mTreeEffect,
        action = "yaoqianshu",
        loop = false
    })
    -- 摇钱树小幅摆动
    SkeletonAnimation.action({
        skeleton = self.mTreeEffect,
        action = "daiji",
        loop = true,
        delay = 0
    })

    --  动作序列
    local actionArray = {}
    for i = 1, 5 do
        -- 铜币随机位置掉落
        table.insert(actionArray, cc.CallFunc:create(function()
            local effect = ui.newEffect({
                parent = self.mClippingNode,
                effectName = "effect_ui_zhaocaishu",
                scale = 0.9,
                animation = "jingbi",
                position = cc.p(130 + (i+math.random(2,4))%7 * 60, 170 + (i+math.random(2,4))%5 * 60 - 60),
                loop = false,
                endRelease = false
            })

            effect:runAction(cc.Sequence:create({
                cc.MoveBy:create(0.5, cc.p(0, -380)),
                cc.CallFunc:create(function()
                    --effect:setVisible(false)
                    effect:removeFromParent()
                end)
            }))
        end))

        table.insert(actionArray, cc.DelayTime:create(0.1))

        -- 礼品随机位置掉落
        table.insert(actionArray, cc.CallFunc:create(function()
            local showId = math.random(1, #self.mActivityInfo.ShowRewards)
            local reward = self.mActivityInfo.ShowRewards[showId].Reward[1]

            local good = CardNode.createCardNode({
                resourceTypeSub = reward.ResourceTypeSub,
                modelId = reward.ModelId,
                num = reward.Count,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
                cardShape = Enums.CardShape.eCircle
            })
            good:setScale(0.8)
            good:setPosition(130 + (i+math.random(2,4))%7 * 60, 170 + (i+math.random(2,4))%5 * 60 - 60)
            self.mClippingNode:addChild(good)

            good:runAction(cc.Sequence:create({
                cc.MoveBy:create(0.5, cc.p(0, -380)),
                cc.CallFunc:create(function()
                    good:removeFromParent()
                end)
            }))
        end))
        table.insert(actionArray, cc.DelayTime:create(0.1))
    end

    table.insert(actionArray, cc.CallFunc:create(function()
        self.mLockLayer:removeFromParent()
    end))

    self:runAction(cc.Sequence:create(actionArray))
end

------------------------网络相关---------------------------
-- 请求服务器，获取摇钱树页面信息
function ActivityMoneyTreeLayer:requestGetInfo()
    HttpClient:request({
        moduleName = "TimedMoneyTree",
        methodName = "GetInfo",
        svrMethodData = {self.mActivityId},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "requestGetInfo", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mLayerData = data.Value
            self.mActivityInfo = data.Value

            -- 添加进度条上面的奖励物品
    		self:addGiftsOnProgressBar()

    		-- 添加奖励物品到树上
    		self:addGiftsOnTree()

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 请求服务器，领取积分奖励
--[[
    params:
    num             -- 领取奖励所需的积分数
--]]
function ActivityMoneyTreeLayer:requestDrawReward(header)
    HttpClient:request({
        moduleName = "TimedMoneyTree",
        methodName = "DrawReward",
        svrMethodData = {self.mActivityId, header.needNum},
        callbackNode = self,
        callback = function (data)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            header:stopAllActions()
            header:setRotation(0)
            -- 刷新缓存
            self.mActivityInfo.DrawnNums = data.Value.DrawnNums
            self.mLayerData = self.mActivityInfo

            -- 飘窗显示奖品
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            -- 刷新页面
            self:refreshLayer()
        end
    })
end

-- 请求服务器，招财
--[[
    params:
    num                 -- 招财次数
--]]
function ActivityMoneyTreeLayer:requestShakeTree(num)
    -- 屏蔽层
    self.mLockLayer = cc.Layer:create()
    ui.registerSwallowTouch({node = self.mLockLayer})
    display.getRunningScene():addChild(self.mLockLayer, 255)

    HttpClient:request({
        moduleName = "TimedMoneyTree",
        methodName = "ShakeTree",
        svrMethodData = {self.mActivityId, num},
        callbackNode = self,
        callback = function (data)
            if data.Status == 0 then
                -- 播放招财动效
                self:playZCEffect()

                -- 刷新数据并保存
                self.mActivityInfo.CostNum = data.Value.CostNum
                self.mActivityInfo.CostNumTen = data.Value.CostNumTen
                self.mActivityInfo.Num = data.Value.Num
                self.mActivityInfo.LimitNum = data.Value.LimitNum
                self.mLayerData = self.mActivityInfo

                -- 飘窗显示奖励
                ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

                -- 刷新页面
                self:refreshLayer()
            else
                print("--招财失败---")
                self.mLockLayer:removeFromParent()
            end
        end
    })
end

return ActivityMoneyTreeLayer
