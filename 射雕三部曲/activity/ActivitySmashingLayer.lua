--[[
    文件名: ActivitySmashingLayer.lua
	描述: 彩蛋活动页面, 模块Id为：
		ModuleSub.eTimedSmashingEggs -- "限时彩蛋活动"
		ModuleSub.eCommonHoliday6  -- "通用节日-砸金蛋"
		ModuleSub.eChristmasActivity6 -- "圣诞活动-砸金蛋"
	效果图:
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivitySmashingLayer = class("ActivitySmashingLayer", function()
    return display.newLayer()
end)

-- 锤子所属的道具类型id和锤子的模型id
local ChuiZiTypeSub = 1605
local ChuiZiModelId = 16050041

--[[
-- 参数 params 中的各项为：
	{
		activityIdList: 活动实体Id列表
		parentModuleId: 该活动的主模块Id

		cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
	}
]]
function ActivitySmashingLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	self.mActivityId = self.mActivityIdList[1].ActivityId

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()

    self.mLayerData = self.mLayerData or {}

    -- 注意：砸蛋记录动态变化，每次必须重新请求数据 --
	-- 请求服务器，获取砸金蛋掉落物品信息
	self:requestGetRewardList()

	-- 请求服务器，获取砸金蛋记录信息
	self:requestGetSmashingRecord()
end

-- 获取恢复数据
function ActivitySmashingLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivitySmashingLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("xshd_22.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
	self.mBgSprite = bgSprite
	self.mBgSize = bgSprite:getContentSize()

    -----------------消息滚动窗口------------------
    -- 灰色背景
    local boxBg = ui.newScale9Sprite("xshd_27.png", cc.size(590, 180))
    boxBg:setPosition(320, 775)
    self.mParentLayer:addChild(boxBg)

    -- 遮罩节点
    self.mMessageBox = cc.ClippingNode:create()
    self.mMessageBox:setAlphaThreshold(1.0)
    self.mMessageBox:setContentSize(cc.size(boxBg:getContentSize().width, boxBg:getContentSize().height - 20))
    self.mMessageBox:setAnchorPoint(cc.p(0.5, 0.5))
    self.mMessageBox:setPosition(boxBg:getContentSize().width * 0.5, boxBg:getContentSize().height * 0.5)
    boxBg:addChild(self.mMessageBox)

    -- 模板
    local stencilNode = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
    stencilNode:setAnchorPoint(cc.p(0.5, 0.5))
    stencilNode:setIgnoreAnchorPointForPosition(false)
    stencilNode:setPosition(self.mMessageBox:getContentSize().width * 0.5, self.mMessageBox:getContentSize().height * 0.5)
    stencilNode:setContentSize(self.mMessageBox:getContentSize().width - 10, self.mMessageBox:getContentSize().height - 10)
    self.mMessageBox:setStencil(stencilNode)

    -- 金蛋
    self.mTamakoBtn = ui.newButton({
        normalImage = "xshd_24.png",
        position = cc.p(cc.p(320, 390)),
        clickAction = function()
            -- 锤子的数量
            local hammerNum = Utility.getOwnedGoodsCount(ChuiZiTypeSub, ChuiZiModelId)
            if hammerNum < 1 then
                ui.showFlashView({
                    text = TR("%s不足", Utility.getGoodsName(ChuiZiTypeSub, ChuiZiModelId))
                })
                return
            end
            self:eggClicked()
        end
    })
    -- self.mTamakoBtn:setScale(0.9)
    self.mParentLayer:addChild(self.mTamakoBtn)

    -- 碎蛋
    self.mBrokenEggSprite = ui.newSprite("xshd_25.png")
    self.mBrokenEggSprite:setPosition(320, 390)
	self.mParentLayer:addChild(self.mBrokenEggSprite)
    -- self.mBrokenEggSprite:setScale(0.9)
    self.mBrokenEggSprite:setVisible(false)

    -- 锤子
    self.mHammerSprite = ui.newSprite("xshd_23.png")
    self.mHammerSprite:setPosition(360, 560)
    self.mParentLayer:addChild(self.mHammerSprite)
    -- 锤子动画
    local action = cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, 40)), cc.MoveBy:create(0.3, cc.p(0, -40)), nil)
    self.mHammerSprite:runAction(cc.RepeatForever:create(action))

    -- 倒计时
    local labelBg = ui.newScale9Sprite("c_25.png", cc.size(590, 45))
    labelBg:setPosition(320, 670)
   	self.mParentLayer:addChild(labelBg)

    self.mTimeLabel = ui.newLabel({
        text = TR(""),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mTimeLabel:setPosition(labelBg:getContentSize().width * 0.5, labelBg:getContentSize().height * 0.5)
    labelBg:addChild(self.mTimeLabel)


    -- 概率掉落背景
    local sp = ui.newSprite("c_93.png")
    sp:setPosition(cc.p(320, 225))
    self.mParentLayer:addChild(sp)

    -- 概率掉落文字
    local textLabel = ui.newSprite("xshd_30.png")
    textLabel:setPosition(325, 285)
    self.mParentLayer:addChild(textLabel)

    -- 可点击查看属性的锤子
    self.mHammerBtn = CardNode.createCardNode({
        resourceTypeSub = ChuiZiTypeSub,
        modelId = ChuiZiModelId,
        num = Utility.getOwnedGoodsCount(ChuiZiTypeSub, ChuiZiModelId),
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
        cardShape = Enums.CardShape.eCircle
    })
    self.mHammerBtn:setPosition(550, 380)
    self.mParentLayer:addChild(self.mHammerBtn)

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
        position = cc.p(530, 930),
        clickAction = function()
            local contentList = {[1]={}}
            for i,v in ipairs(self.mRewardInfo.TimedSmashingReward or {}) do
                local list = {}
                list = Utility.analysisStrResList(v.OutResource)
                list[1].OddsTips = v.OddsTips
                table.insert(contentList[1], list[1])
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
    totalNumLabel:setPosition(530, 620)
    self.mParentLayer:addChild(totalNumLabel)
    self.mTotalNumLabel = totalNumLabel
end

-- 点击金蛋事件
function ActivitySmashingLayer:eggClicked()
	-- 锤子的数量
	local num = Utility.getOwnedGoodsCount(ChuiZiTypeSub, ChuiZiModelId)

	-- 砸蛋函数
	local function smashFunc(times)
        if self.mRecordInfo.LimitNum < times then
            ui.showFlashView(TR("剩余砸蛋次数不足"))
        else  
	        -- 请求服务器，砸蛋
	        self:requestSmashingEggs(times)
        end
    end
    local tempStr = ""
    local smashNum
    if self.mRecordInfo.LimitNum > num then
        tempStr = num < 100 and TR("全部砸") or TR("砸百次")
        smashNum = num
    else
        tempStr = self.mRecordInfo.LimitNum < 100 and TR("全部砸") or TR("砸百次")
        smashNum = self.mRecordInfo.LimitNum
    end
	-- 添加提示框
    local layerParams = {
        bgImage = "c_30.png",
        bgSize = cc.size(598, 410),
        title = TR("选择次数"),
        msgText = "",
        closeBtnInfo = {
            position = cc.p(575, 390)
        },
        btnInfos = {
            {
                text = TR("砸一次"),
                position = cc.p(175, 205),
                normalImage = "c_33.png",
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                    smashFunc(1)
                end
            },
            {

                text = tempStr,
                normalImage = "c_33.png",
                position = cc.p(445, 205),
                clickAction = function(layerObj, btnObj)
                    if smashNum < 1 then
                        if num > 0 then
                            ui.showFlashView(TR("剩余砸蛋次数不足"))
                        else
                            ui.showFlashView({
                                text = TR("%s不足", Utility.getGoodsName(ChuiZiTypeSub, ChuiZiModelId))
                            })
                        end
                        LayerManager.removeLayer(layerObj)
                    else
                        -- 移除弹窗
                        LayerManager.removeLayer(layerObj)
                        smashFunc(smashNum < 100 and smashNum or 100)
                    end
                end
            },
            {
                text = TR("确定"),
                position = cc.p(299, 50),
                clickAction = function (layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)

                end
            }

        }
    }
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = layerParams,
        cleanUp = false
    })
end

-- 活动倒计时
function ActivitySmashingLayer:updateTime()
    local timeLeft = self.mRewardInfo.EndDate - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动结束时间: %s%s", Enums.Color.eGoldH, MqTime.formatAsDay(timeLeft)))
    else
        self.mTimeLabel:setString(TR("活动结束时间: %s00:00:00", Enums.Color.eGoldH))

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

-- 创建掉落物品窗口
function ActivitySmashingLayer:createRewardListView()
	-- 奖励列表
    local rewardList = {}
    for i, v in ipairs(self.mRewardInfo.TimedSmashingReward) do
        if v.IsDisplay == 1 then 
        	local configList = Utility.analysisStrResList(v.OutResource)

            local tempList = {}
            tempList.resourceTypeSub = configList[1].resourceTypeSub
            tempList.modelId = configList[1].modelId
            tempList.num = configList[1].num
            tempList.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}

            table.insert(rewardList, tempList)
        end     
    end
    local rewardListView = ui.createCardList({
        maxViewWidth = 578,
        space = 0,
        cardDataList = rewardList,
        cardShape = Enums.CardShape.eCircle,
        allowClick = true
    })
    rewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    rewardListView:setPosition(320, 190)
    self.mParentLayer:addChild(rewardListView)
end

--获得随机名字
function ActivitySmashingLayer:getRandomName()
    -- quick已经初始化随机生成器了，此时不用再设置
    local firstname, lastname = _firstname, _lastname
    if not firstname then
        local fullpath1 = cc.FileUtils:getInstance():fullPathForFilename(Enums.RandomName.name1)
        local fullpath2 = cc.FileUtils:getInstance():fullPathForFilename(Enums.RandomName.name2)

        local randomString1 = cc.FileUtils:getInstance():getStringFromFile(fullpath1)
        local randomString2 = cc.FileUtils:getInstance():getStringFromFile(fullpath2)

        if #randomString1 == 0 or #randomString2 == 0 then
            return nil
        end

        firstname, lastname = {}, {}
        for i in randomString1:gmatch "%S+" do
            table.insert(firstname, i)
        end

        for i in randomString2:gmatch "%S+" do
            table.insert(lastname, i)
        end

        _firstname, _lastname = firstname, lastname
    end

    local x, y = math.random(1, #firstname), math.random(1, #lastname)
    return firstname[x]..lastname[y]
end

-- 添加砸蛋记录，永久滚动
function ActivitySmashingLayer:addRecordsAndRolling()
    -- -- 记录列表
    local list = self.mRecordInfo.TimedSmashingRecord

    --最少保持50条数据循环
    --如果服务器返回不满50条 则使用 服务器返回数据 + 假数据 = 50
    local fakeListNum = 50
    if #list < fakeListNum then
        fakeListNum = fakeListNum - #list --得到当前需要生成的假数据
    else
        fakeListNum = 0
    end

    --添加假数据
    for i = 1, fakeListNum do
        local tempT = {}
        local randReward = math.random(1, #(self.mRewardInfo.TimedSmashingReward))
        tempT.Name = self:getRandomName() --随机名字
        tempT.Reward = self.mRewardInfo.TimedSmashingReward[randReward].OutResource --随机奖励
        table.insert(list, tempT)
    end

    -- 产生一条 "恭喜XX获得XX" 信息
    local function getOneMessage(i, v)
        -- 解析资源
        local resList = Utility.analysisStrResList(v.Reward)

        -- 创建父节点
        local node = ccui.Layout:create()
        node:setAnchorPoint(cc.p(0.5, 0))
        node:setContentSize(cc.size(590, 30))

        local posX = 100
        local label1 = ui.newLabel({
            text = TR("%s恭喜%s %s %s 获得",
                Enums.Color.eWhiteH,
                Enums.Color.eGoldH,
                v.Name,
                Enums.Color.eWhiteH
            ),
            size = 20,
        })
        label1:setPosition(posX, 15)
        label1:setAnchorPoint(cc.p(0, 0.5))
        node:addChild(label1)

        posX = posX + label1:getContentSize().width
        local header = CardNode.createCardNode({
            resourceTypeSub = resList[1].resourceTypeSub,
            modelId = resList[1].modelId,
            num = resList[1].num,
            cardShowAttrs = {CardShowAttr.eBorder},
            cardShape = Enums.CardShape.eCircle
        })
        node:addChild(header)
        header:setPosition(posX, 16)
        header:setScale(0.3)
        header:setAnchorPoint(cc.p(0, 0.5))

        posX = posX + 30
        local label2 = ui.newLabel({
            text = string.format("%s%s*%s !",
                Enums.Color.eGoldH,
                Utility.getGoodsName(resList[1].resourceTypeSub, resList[1].modelId),
                resList[1].num
            )
        })
        label2:setPosition(posX, 15)
        label2:setAnchorPoint(cc.p(0, 0.5))
        node:addChild(label2)

        return node
    end

    self.mItemList = {}
    self.mShowList = {}
    self.mPrepareList = {}

    -- 小于7条直接静态显示出来
    if #list < 7 then
        for i, v in ipairs(list) do
            self.mItemList[i] = getOneMessage(i, v)
            self.mItemList[i]:setPosition(self.mMessageBox:getContentSize().width * 0.5, 155 * i)
            self.mMessageBox:addChild(self.mItemList[i])
        end
    else
        -- 滚动时间
        local scrollTime = 2

        -- 7条以上的放入准备数据列表，以下放入要显示的数据列表
        for i, v in ipairs(list) do
            if i > 7 then
                table.insert(self.mPrepareList, v)
            else
                self.mShowList[i] = v
            end
        end
        for i = 1, 7 do
            if self.mShowList[i] then
                self.mItemList[i] = getOneMessage(i, self.mShowList[i])
                self.mItemList[i]:setPosition(self.mMessageBox:getContentSize().width * 0.5, 185 - 30 * i)
                self.mMessageBox:addChild(self.mItemList[i])
            end
        end

        -- 滚动函数
        local function scrollFunction()
            for i = 1, 7 do
                if self.mShowList[i] and self.mItemList[i] then
                    self.mItemList[i]:runAction(cc.Sequence:create({cc.MoveBy:create(scrollTime, cc.p(0, 30))}))
                end
            end
        end

        self.mParentLayer:runAction(cc.RepeatForever:create(cc.Sequence:create({
            cc.CallFunc:create(function()
                scrollFunction()
            end),
            cc.DelayTime:create(scrollTime),
            cc.CallFunc:create(function()
                if not tolua.isnull(self.mItemList[1]) then
                    self.mItemList[1]:removeFromParent()
                end
                if self.mShowList[1] and #self.mPrepareList < 14 then
                    table.insert(self.mPrepareList, self.mShowList[1])
                end
                for i = 1, 6 do
                    if self.mShowList[i + 1] and not tolua.isnull(self.mItemList[i + 1]) then
                        self.mShowList[i] = clone(self.mShowList[i+1])
                        self.mItemList[i] = self.mItemList[i+1]
                    end
                end
                if self.mPrepareList[1] then
                    self.mShowList[7] = clone(self.mPrepareList[1])
                    table.remove(self.mPrepareList, 1)
                    self.mItemList[7] = getOneMessage(i, self.mShowList[7])
                    self.mItemList[7]:setPosition(self.mMessageBox:getContentSize().width * 0.5, -25)
                    self.mMessageBox:addChild(self.mItemList[7])
                end
            end)
        })))
    end
end

-- 砸蛋过程中的动效
--[[
    params:
    rewardList                  -- 砸出的物品列表
--]]
function ActivitySmashingLayer:showSmashingEggActions(rewardList)
    -- 屏蔽层
    self.mLockLayer = cc.Layer:create()
    ui.registerSwallowTouch({node = self.mLockLayer})
    display.getRunningScene():addChild(self.mLockLayer, 255)

    -- 一系列动效
    self:runAction(cc.Sequence:create(
        cc.CallFunc:create(function()
            self.mHammerSprite:runAction(cc.FadeOut:create(0.5))
        end),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function()
            Utility.performWithDelay(self, function ()
                -- 锤子砸蛋动效
                MqAudio.playEffect("activity_jindan.mp3")
            end, 0.95)

            local ponponpon = ui.newEffect({
                parent = self.mParentLayer,
                effectName = "effect_ui_zadan",
                position = cc.p(320, 480),
                loop = false,
                endRelease = true,
                completeListener = function()
                    local actionArray = {}
                    -- 金蛋抖动
                    table.insert(actionArray, cc.CallFunc:create(function()
                        self.mTamakoBtn:runAction(cc.Sequence:create({
                            cc.MoveBy:create(0.1, cc.p(10, 0)),
                            cc.MoveBy:create(0.1, cc.p(-20, 0)),
                            cc.MoveBy:create(0.1, cc.p(20, 0)),
                            cc.MoveBy:create(0.1, cc.p(-20, 0)),
                            cc.MoveBy:create(0.1, cc.p(20, 0)),
                            cc.MoveBy:create(0.1, cc.p(-10, 0))
                        }))
                    end))
                    table.insert(actionArray, cc.DelayTime:create(0.6))
                    table.insert(actionArray, cc.CallFunc:create(function()
                        self.mTamakoBtn:setVisible(false)
                        self.mBrokenEggSprite:setVisible(true)

                        -- 飘窗显示奖品
                        ui.ShowRewardGoods(rewardList)
                    end))
                    table.insert(actionArray, cc.DelayTime:create(2))
                    table.insert(actionArray, cc.CallFunc:create(function()
                        self.mTamakoBtn:setVisible(true)
                        self.mBrokenEggSprite:setVisible(false)
                        self.mLockLayer:removeFromParent()
                    end))

                    self:runAction(cc.Sequence:create(actionArray))
                end
            })
        end)
    ))
end

-- 刷新锤子数量图标及消息盒子
function ActivitySmashingLayer:refreshHammerAndMessageBox()
    -- 移除锤子，重新添加
    self.mHammerBtn:removeFromParent()
    self.mHammerBtn = CardNode.createCardNode({
        resourceTypeSub = ChuiZiTypeSub,
        modelId = ChuiZiModelId,
        num = Utility.getOwnedGoodsCount(ChuiZiTypeSub, ChuiZiModelId),
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
        cardShape = Enums.CardShape.eCircle
    })
    self.mHammerBtn:setPosition(550, 380)
    self.mParentLayer:addChild(self.mHammerBtn)

    self.mTotalNumLabel:setString(TR("剩余次数：%d/%d", self.mRecordInfo.LimitNum, self.mRecordInfo.TotalNum))

end

-----------------网络相关-------------------
-- 请求服务器，获取砸金蛋掉落物品信息
function ActivitySmashingLayer:requestGetRewardList()
    HttpClient:request({
        moduleName = "TimedSmashingeggsInfo",
        methodName = "GetRewardList",
        svrMethodData = {self.mActivityId},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "requestGetRewardList", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mLayerData.rewardInfo = data.Value
            self.mRewardInfo = data.Value
            --dump(self.mRewardInfo, "=====----dddddd--")
            -- 刷新时间，开始倒计时
            if self.mSchelTime then
                self:stopAction(self.mSchelTime)
                self.mSchelTime = nil
            end
		    self:updateTime()
		    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

            -- 创建掉落物品列表视图
       		self:createRewardListView()
        end
    })
end

-- 请求服务器，获取砸金蛋记录信息
function ActivitySmashingLayer:requestGetSmashingRecord()
    HttpClient:request({
        moduleName = "TimedSmashingeggsInfo",
        methodName = "GetSmashingRecord",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "requestGetSmashingRecord", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mLayerData.recordInfo = data.Value
            self.mRecordInfo = data.Value

            self:refreshHammerAndMessageBox()


           	-- 向消息盒子添加记录
    		self:addRecordsAndRolling()
        end
    })
end

-- 请求服务器，砸蛋
--[[
	params:
	times   			-- 砸蛋次数
--]]
function ActivitySmashingLayer:requestSmashingEggs(times)
	HttpClient:request({
    	moduleName = "TimedSmashingeggsInfo",
    	methodName = "SmashingEggs",
    	svrMethodData = {self.mActivityId ,times},
        callbackNode = self,
        callback = function (data)
            dump(data, "requestSmashingEggs", 10)

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存新的砸蛋记录
            self.mNewRecords = data.Value.TimedSmashingRecord
            self.mRecordInfo.LimitNum = data.Value.LimitNum

            -- 对比新记录与老记录，加不重复的新记录添加到老记录中
            for k0, v0 in pairs(data.Value.TimedSmashingRecord) do
                local isExist = false
                for k1, v1 in pairs(self.mRecordInfo.TimedSmashingRecord) do
                    if v0.Name == v1.Name and v0.Reward == v1.Reward then
                        isExist = true
                    end
                end

                if not isExist then
                    table.insert(self.mRecordInfo.TimedSmashingRecord, v0)
                end
            end

            -- 更新缓存
            self.mLayerData.recordInfo = self.mRecordInfo

            -- 砸蛋动效
            self:showSmashingEggActions(data.Value.BaseGetGameResourceList)

            -- 刷新相关元素
            self:refreshHammerAndMessageBox()
        end
    })
end

return ActivitySmashingLayer
