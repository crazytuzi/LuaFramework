--[[
    文件名：ActivityLuckDrawLayer.lua
    描述：宝库抽奖 页面，模块Id为：
        ModuleSub.eTimedLuckDraw  -- "限时 宝库抽奖"
        ModuleSub.eCommonHoliday4 -- "通用活动-宝库抽奖"
        ModuleSub.eChristmasActivity4 -- "圣诞活动-宝库抽奖"
    效果图：x限时活动-宝库抽奖.jpg  、x限时活动-宝库抽奖-宝库抽奖规则.jpg
    创建人：libowen
    创建时间：2016.5.26
-- ]]

local ActivityLuckDrawLayer = class("ActivityLuckDrawLayer", function(params)
    return display.newLayer()
end)

-- 宝库类型枚举
local PageType = {
	eNormalDarw = 1,					-- 普通宝库
	eAdvanceDarw = 2  					-- 高级宝库
}

-- 抽奖所消耗的具体道具：抽奖券
local ExchangePropId = 16050027

-- 构造函数
--[[
-- 参数 params 中的各项为：
	{
		activityIdList: 活动实体Id列表
		parentModuleId: 该活动的主模块Id

		cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
	}
--]]
function ActivityLuckDrawLayer:ctor(params)
    params = params or {}
    -- 活动实体Id列表
    self.mActivityIdList = params.activityIdList
    -- 该活动的主模块Id
    self.mParentModuleId = params.parentModuleId
    -- 该页面的数据信息
    self.mLayerData = params.cacheData

	-- 数据初始化
	self.mActivityId = params.activityIdList[1]         -- 只有一个活动Id

    -- 设置14个宝箱的位置
    self:configBoxPos()

	-- 初始化UI
    self:initUI()

    -- 是否有缓存数据
    local tempData = self.mLayerData
    if tempData then
        print("------宝库抽奖：读取缓存数据------")
        -- 保存数据
        self.mLuckDrawInfo = tempData

        -- 刷新页面
        self:refreshLayer()
        self:refreshMessageBox()
    else
        print("------宝库抽奖：缓存无数据，请求服务器------")
        self:requestGetLuckDrawInfo()
    end
end

-- 获取恢复数据
function ActivityLuckDrawLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 添加页面相关的UI元素
function ActivityLuckDrawLayer:initUI()
	-- 页面元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

    -- 上方背景
    local topBg = ui.newSprite("c_34.jpg")
    topBg:setAnchorPoint(cc.p(0.5, 1))
    topBg:setPosition(320, 1136)
    self.mParentLayer:addChild(topBg)

    -- 顶部文字背景
    local topLabelBg = ui.newScale9Sprite("c_25.png", cc.size(551, 54))
    topLabelBg:setPosition(320, 935)
    self.mParentLayer:addChild(topLabelBg)

    -- 顶部文字："充值XX获得XX 当前已充值XXX"
    self.mTopLabel = ui.newLabel({
        text = TR(""),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mTopLabel:setPosition(topLabelBg:getContentSize().width * 0.5, topLabelBg:getContentSize().height * 0.5)
    topLabelBg:addChild(self.mTopLabel)

    -- 充值按钮
    local rechargeBtn = ui.newButton({
        normalImage = "tb_21.png",
        position = cc.p(118 - 45, 860),
        clickAction = function()
            LayerManager.showSubModule(ModuleSub.eCharge)
        end
    })
    self.mParentLayer:addChild(rechargeBtn)

    -- 排行按钮
    local rankBtn = ui.newButton({
        normalImage = "tb_16.png",
        position = cc.p(118 + 65, 860),
        clickAction = function()
            local data = self.mLuckDrawInfo.LuckdrawRankreturnConfig
            --dump(data, "抽奖返还信息", 10)

            -- 按两种情况考虑，一种是返还元宝，一种是返还道具，
            -- 返还元宝虽然很少使用，但是不排除日后运营会这么做
            if next(data) ~= nil and data[1] then                   -- next()函数用以检测表是否为空
                -- 返还元宝页面
                if data[1].Ratio then
                    self:showRankLayer(true)
                -- 返还道具页面
                elseif data[1].ReturnResource then
                    self:showRankLayer(false)
                end
            end
            -- self:showBoxLayer()
        end
    })
    self.mParentLayer:addChild(rankBtn)

    -- 活动倒计时文字图片
    local timefont = ui.newLabel({
            text = TR("活动倒计时："),
            size = 25,
            color = cc.c3b(0x4e, 0x28, 0x0f),
            -- outlineColor = Enums.Color.eBlack,
        })
    timefont:setPosition(125, 755)
    self.mParentLayer:addChild(timefont)

    -- 倒计时标签
    self.mTimeLabel = ui.newLabel({
        text = TR(""),
        color = cc.c3b(0xff, 0x00, 0x00),
        -- outlineColor = Enums.Color.eBrown,
        anchorPoint = cc.p(0.5, 0.5),
        size = 26,
        x = 125,
        y = 715,
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mParentLayer:addChild(self.mTimeLabel)

    -- 中奖记录背景框
    local boxBg = ui.newScale9Sprite("xshd_02.png", cc.size(380, 240))
    boxBg:setPosition(440, 770)
    self.mParentLayer:addChild(boxBg)

    -- -- 描述边框
    -- local sp = ui.newScale9Sprite("jchd_24.png")
    -- sp:setCapInsets(cc.rect(74, 10, 4, 26))
    -- sp:setContentSize(cc.size(370, 50))
    -- sp:setPosition(cc.p(440, 865))
    -- self.mParentLayer:addChild(sp)
    -- 描述
    local bgSprite = ui.newLabel({
        text = TR("中奖记录"),
        -- align = ui.TEXT_ALIGN_CENTER,
        size = 24,
        -- color = cc.c3b(0xfe, 0xef, 0xcb),
        outlineColor = cc.c3b(0x47, 0x50, 0x54),
        outlineSize = 2,
    })
    bgSprite:setPosition(440, 865)
    self.mParentLayer:addChild(bgSprite)
    -- -- "中奖记录"
    -- local boxTitle = ui.createAttrTitle({
    --     leftImg = "c_39.png",
    --     titleStr = TR("中奖记录"),
    --     color = Enums.Color.eBrown
    -- })
    -- boxTitle:setPosition(boxBg:getContentSize().width * 0.5, boxBg:getContentSize().height * 0.86)
    -- boxBg:addChild(boxTitle)

    -- 模板
    local stencilNode = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
    stencilNode:setIgnoreAnchorPointForPosition(false)
    stencilNode:setAnchorPoint(cc.p(0.5, 0.5))
    stencilNode:setContentSize(cc.size(boxBg:getContentSize().width, boxBg:getContentSize().height - 70))
    stencilNode:setPosition(boxBg:getContentSize().width * 0.5, boxBg:getContentSize().height * 0.5 - 18)
    -- 遮照框
    self.mMaskNode = cc.ClippingNode:create()
    self.mMaskNode:setContentSize(boxBg:getContentSize())
    self.mMaskNode:setAlphaThreshold(1.0)
    self.mMaskNode:setStencil(stencilNode)
    self.mMaskNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.mMaskNode:setPosition(boxBg:getContentSize().width * 0.5, boxBg:getContentSize().height * 0.5 + 5)
    boxBg:addChild(self.mMaskNode)

    -- 下方背景
    self.mBottomBg = ui.newScale9Sprite("c_19.png", cc.size(640, 1136 - 535))
    self.mBottomBg:setAnchorPoint(cc.p(0.5, 0))
    self.mBottomBg:setPosition(320, 0)
    self.mParentLayer:addChild(self.mBottomBg)

    -- 宝库内容父节点
    self.mTabContentLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
    self.mTabContentLayer:setContentSize(640, 480)
    self.mTabContentLayer:setIgnoreAnchorPointForPosition(false)
    self.mTabContentLayer:setPosition(320, 352)
    self.mBottomBg:addChild(self.mTabContentLayer)

    -- 添加分页控件
    self:addTabView()

    -- 拥有道具标签
    local haveBg = ui.newScale9Sprite("xshd_03.png", cc.size(150, 35))
    haveBg:setPosition(cc.p(555, 622))
    self.mBottomBg:addChild(haveBg)


    local picName = string.format("%s.png", GoodsModel.items[ExchangePropId].pic)
    local propSpr = ui.newSprite(picName)
    propSpr:setPosition(506, 622)
    self.mBottomBg:addChild(propSpr)
    propSpr:setScale(0.8)

    local haveNum = GoodsObj:getCountByModelId(ExchangePropId)
    self.mOwnLabel = ui.newLabel({
        text = TR("x %s", Utility.numberWithUnit(haveNum)),
        color = Enums.Color.eWhite,
        size = 24,
        anchorPoint = cc.p(0, 0.5)
    })
    self.mOwnLabel:setPosition(540, 622)
    self.mBottomBg:addChild(self.mOwnLabel)

    -- 帮助按钮，规则提示
    local helpBtn = ui.newButton({
        normalImage = "c_72.png",
        clickAction = function (pSender)
            self:helpBtnCallBack(pSender)
        end
    })
    helpBtn:setPosition(60, 935)
    self.mBottomBg:addChild(helpBtn)

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

-- 配置14个宝箱的摆放位置
function ActivityLuckDrawLayer:configBoxPos()
    local function getCalcPos(x, y)
        return cc.p(x * 125 - 57, 521 - y * 115)
    end
    -- 创建固定顺序的点
    -- 1  2  3  4  5
    -- 14 x  x  x  6
    -- 13 x  x  x  7
    -- 12 11 10 9  8
    self.mBoxPos = {}
    for i=1,5 do
        table.insert(self.mBoxPos, getCalcPos(i, 1))
    end
    for j=2,3 do
        table.insert(self.mBoxPos, getCalcPos(5, j))
    end
    for i=5,1,-1 do
        table.insert(self.mBoxPos, getCalcPos(i, 4))
    end
    for j=3,2,-1 do
        table.insert(self.mBoxPos, getCalcPos(1, j))
    end
end

-- 帮助按钮点击事件，显示抽奖规则
--[[
    params:
    pSender                         -- 传回来的按钮引用
--]]
function ActivityLuckDrawLayer:helpBtnCallBack(pSender)
    --如果开启概率显示
    if ModuleInfoObj:moduleIsOpen(ModuleSub.eShowTheProbability, false) then
        local contentList = {[1]={}, [2]={}}
        for i,v in ipairs(self.mLuckDrawInfo.LuckdrawRewardConfig or {}) do
            local list = {}
            if v.OutResource ~= "" then
                list = Utility.analysisStrResList(v.OutResource)
                list[1].OddsTips = v.OddsTips
                table.insert(contentList[1], list[1])
            else
                list[1] = {}
                if v.Ratio == 2 then
                    list[1].header = "xshd_32.png"
                elseif v.Ratio == 3 then
                    list[1].header = "xshd_31.png"
                end

                list[1].OddsTips = v.OddsTips
                table.insert(contentList[1], list[1])
            end     
        end
        local reuleList = {
            [1] = TR("1.活动期间每充值120元宝即可获得一个抽奖券，抽奖券用于宝库抽奖"),
            [2] = TR("2.在抽奖过程中光圈停止于特殊图标例如下一次奖品x2，则下次抽中奖品后可获得双倍奖励"),
            [3] = TR("3.每消耗1个抽奖券即可获得1积分，积分排名越高，可获得特殊奖励越多"),
            [4] = TR("4.高级宝库每次单抽需要消耗10张抽奖券，普通宝库单抽一次消耗一张抽奖券")
        }
        for i,v in ipairs(reuleList) do
            table.insert(contentList[2], v)
        end
        MsgBoxLayer.addprobabilityLayer(TR("概率详情"), contentList)
    else 
        MsgBoxLayer.addRuleHintLayer(TR("规则"),
        {
            [1] = TR("1.活动期间每充值120元宝即可获得一个抽奖券，抽奖券用于宝库抽奖"),
            [2] = TR("2.在抽奖过程中光圈停止于特殊图标例如下一次奖品x2，则下次抽中奖品后可获得双倍奖励"),
            [3] = TR("3.每消耗1个抽奖券即可获得1积分，积分排名越高，可获得特殊奖励越多"),
            [4] = TR("4.高级宝库每次单抽需要消耗10张抽奖券，普通宝库单抽一次消耗一张抽奖券")
        })
    end
end

-- 添加分页控件
function ActivityLuckDrawLayer:addTabView()
    local buttonInfos = {
        {
            text = TR("普通宝库"),
            tag = PageType.eNormalDarw
        },
        {
            text = TR("高级宝库"),
            tag = PageType.eAdvanceDarw
        }
    }

    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        viewSize = cc.size(640, 80),
        isVert = false,
        btnSize = cc.size(130, 50),
        space = 14,
        needLine = false,
        defaultSelectTag = PageType.eNormalDarw,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            self.mCurrDrawType = selectBtnTag

            -- 首次调用时，内容为空，不刷新
            if self.mLuckDrawInfo then
                self:refreshTabContentLayer()
            end
        end
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 1))
    tabLayer:setPosition(320, 665)
    self.mBottomBg:addChild(tabLayer)
end

-- 添加14个宝箱
function ActivityLuckDrawLayer:addBoxs()
    local box = {}
    for k, v in ipairs(self.mLuckDrawInfo.LuckdrawRewardConfig) do
        if self.mCurrDrawType == v.Type then
            -- 产出资源不为空
            if v.OutResource ~= "" then
                local infos = Utility.analysisStrResList(v.OutResource)
                box[v.OrderId] = CardNode.createCardNode({
                    resourceTypeSub = infos[1].resourceTypeSub,
                    modelId = infos[1].modelId,
                    num = infos[1].num,
                    cardShape = Enums.CardShape.eSquare
                })
                self.mTabContentLayer:addChild(box[v.OrderId])
                box[v.OrderId]:setPosition(self.mBoxPos[v.OrderId])
                box[v.OrderId]:setScale(0.9)
            -- 产出资源为空，则为翻倍按钮。 下一次2倍  下一次3倍 图片没有，下图替代，待修改
            elseif v.OutResource == "" and v.Ratio ~= 0 then
                if v.Ratio == 2 then
                    -- 下一次2倍
                    box[v.OrderId] = ui.newSprite("xshd_32.png")
                    box[v.OrderId]:setPosition(self.mBoxPos[v.OrderId])
                    self.mTabContentLayer:addChild(box[v.OrderId])

                    -- 橙色方框
                    local boxBg = ui.newSprite("c_08.png")
                    boxBg:setPosition(box[v.OrderId]:getContentSize().width * 0.5, box[v.OrderId]:getContentSize().height * 0.5)
                    box[v.OrderId]:addChild(boxBg, -1)
                    box[v.OrderId]:setScale(0.9)
                elseif v.Ratio == 3 then
                    -- 下一次3倍
                    box[v.OrderId] = ui.newSprite("xshd_31.png")
                    box[v.OrderId]:setPosition(self.mBoxPos[v.OrderId])
                    self.mTabContentLayer:addChild(box[v.OrderId])

                    -- 橙色方框
                    local boxBg = ui.newSprite("c_08.png")
                    boxBg:setPosition(box[v.OrderId]:getContentSize().width * 0.5, box[v.OrderId]:getContentSize().height * 0.5)
                    box[v.OrderId]:addChild(boxBg, -1)
                    box[v.OrderId]:setScale(0.9)
                end
            end
        end
    end

    -- 服务器返回的宝箱数少于14个，"下次再来"替代
    for i = 1, 14 do
        if box[i] == nil then
            box[i] = ui.newSprite("c_08.png")
            box[i]:setPosition(self.mBoxPos[i])
            self.mTabContentLayer:addChild(box[i])

            -- "下次再来"
            local label = ui.newLabel({
                text = TR("下次\n再来"),
                align = ui.TEXT_ALIGN_CENTER
            })
            label:setPosition(box[i]:getContentSize().width * 0.5, box[i]:getContentSize().height * 0.5)
            box[i]:addChild(label)
        end
    end
end

-- 更新时间
function ActivityLuckDrawLayer:updateTime()
    local timeLeft = self.mLuckDrawInfo.EndDate - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR(MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
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
end

--获得随机名字
function ActivityLuckDrawLayer:getRandomName()
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

-- 刷新抽奖记录内容，滚动效果
function ActivityLuckDrawLayer:refreshMessageBox()
    local list = self.mLuckDrawInfo.Message
    --最少保持50条数据循环
    --如果服务器返回不满50条 则使用 服务器返回数据 + 假数据 = 50
    local fakeListNum = 50
    if #list < fakeListNum then
        fakeListNum = fakeListNum - #list --得到当前需要生成的假数据
    else
        fakeListNum = 0
    end
    --排除没有 OutResource 的数据 用于随机
    local dealT = {}
    for k, v in ipairs(self.mLuckDrawInfo.LuckdrawRewardConfig) do
        if not v.IsDouble then
            table.insert(dealT, clone(v))
        end
    end
    --添加假数据
    for i = 1, fakeListNum do
        local tempT = {}
        local randReward = math.random(1, #dealT)
        tempT.PlayerName = self:getRandomName() --随机名字
        tempT.Reward = dealT[randReward].OutResource
        tempT.Type = dealT[randReward].Type
        table.insert(list, tempT)
    end

    local function insertOneMessage(i, v)
        -- 资源解析
        local resList = Utility.analysisStrResList(v.Reward)

        -- 判断是否是玩家属性
        local name = nil
        if Utility.isPlayerAttr(resList[1].resourceTypeSub) then
            name = ResourcetypeSubName[resList[1].resourceTypeSub]
        else
            name = Utility.getGoodsName(resList[1].resourceTypeSub, resList[1].modelId)
        end

        local messageLabel = ui.newLabel({
            text = TR("%s %s抽中 %s%s*%s",
                v.PlayerName,
                "#ff0000",
                "#4e280f",
                name,
                resList[1].num
            ),
            color = cc.c3b(0x4e, 0x28, 0x0f),
            dimensions = cc.size(500, 30)
        })
        messageLabel:setAnchorPoint(cc.p(0, 0.5))

        return messageLabel
    end

    self.mItemList = {}
    self.mShowList = {}
    self.mPrepareList = {}
    if #list < 7 then
        for i, v in ipairs(list) do
            self.mItemList[i] = insertOneMessage(i, v)
            self.mItemList[i]:setPosition(cc.p(20, 221 - i * 30))
            self.mMaskNode:addChild(self.mItemList[i])
        end
    else
        local scrollTime = 2
        for i, v in ipairs(list) do
            if i > 7 then
                table.insert(self.mPrepareList, v)
            else
                self.mShowList[i] = v
            end
        end
        for i = 1, 7 do
            if self.mShowList[i] then
                self.mItemList[i] = insertOneMessage(i, self.mShowList[i])
                self.mItemList[i]:setPosition(cc.p(20, 192 - i * 30))
                self.mMaskNode:addChild(self.mItemList[i])
            end
        end


        local function scrollFunction()
            for i = 1, 7 do
                if self.mShowList[i] and self.mItemList[i] then
                    self.mItemList[i]:runAction(cc.Sequence:create({cc.MoveBy:create(scrollTime, cc.p(0, 30))}))
                end
            end
        end

        self:runAction(cc.RepeatForever:create(cc.Sequence:create({
            cc.CallFunc:create(function()
                scrollFunction()
            end),
            cc.DelayTime:create(scrollTime),
            cc.CallFunc:create(function()
                if not tolua.isnull(self.mItemList[1]) then
                    self.mItemList[1]:removeFromParent()
                end
                if self.mShowList[1] then--and #self.mPrepareList < 14 then
                    table.insert(self.mPrepareList, self.mShowList[1])
                end
                for i = 1, 6 do
                    if self.mShowList[i+1] and not tolua.isnull(self.mItemList[i+1]) then
                        self.mShowList[i] = clone(self.mShowList[i+1])
                        self.mItemList[i] = self.mItemList[i+1]
                    end
                end
                if self.mPrepareList[1] then
                    self.mShowList[7] = clone(self.mPrepareList[1])
                    table.remove(self.mPrepareList, 1)
                    self.mItemList[7] = insertOneMessage(i, self.mShowList[7])
                    self.mItemList[7]:setPosition(cc.p(20, -18))
                    self.mMaskNode:addChild(self.mItemList[7])
                end
            end),
        })))
    end
end

-- 抽奖之后，刷新相关UI
function ActivityLuckDrawLayer:refreshPartViews()
    -- 刷新现有道具数量
    self.mOwnLabel:setString(TR("X%d", GoodsObj:getCountByModelId(ExchangePropId)))

    -- 刷新消息盒子
    -- if #self.mShowList < 7 then
    --     for _, v in pairs(self.mItemList) do
    --         v:removeFromParent()
    --     end
    --     self:refreshMessageBox()
    -- else
    --     for _, v in ipairs(self.mNewRecords) do
    --         local isExist = false
    --         for _, vv in ipairs(self.mShowList) do
    --             if v.PlayerName == vv.PlayerName and v.Reward == vv.Reward and v.Type == vv.Type then
    --                 isExist = true
    --             end
    --         end
    --         for _, vv in ipairs(self.mPrepareList) do
    --             if v.PlayerName == vv.PlayerName and v.Reward == vv.Reward and v.Type == vv.Type then
    --                 isExist = true
    --             end
    --         end
    --         if not isExist then
    --             table.insert(self.mPrepareList, v)
    --         end
    --     end
    -- end
end

-- 更新顶部标签
function ActivityLuckDrawLayer:updateTopLabel()
    if self.mRatioLabel then
        self.mRatioLabel:removeFromParent()
        self.mRatioLabel = nil
    end

    if self.mCurrDrawType == PageType.eNormalDarw and self.mLuckDrawInfo.TimedLuckdrawInfo.OrdinaryPlusRatio ~= 1 then
        local ratio = (self.mLuckDrawInfo.TimedLuckdrawInfo.OrdinaryPlusRatio == 2) and TR("双") or TR("三")
            self.mRatioLabel = ui.newLabel({
            text = TR("下一次抽奖必出暴击,获得%s倍奖励!", ratio),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x83, 0x45, 0x00),
            dimensions = cc.size(320, 0)
        })
        self.mRatioLabel:setAnchorPoint(cc.p(0, 0.5))
        self.mRatioLabel:setPosition(170, 301)
        self.mTabContentLayer:addChild(self.mRatioLabel)
    elseif self.mCurrDrawType == PageType.eAdvanceDarw and self.mLuckDrawInfo.TimedLuckdrawInfo.SeniorPlusRatio ~= 1 then
        local ratio = (self.mLuckDrawInfo.TimedLuckdrawInfo.SeniorPlusRatio == 2) and TR("双") or TR("三")
            self.mRatioLabel = ui.newLabel({
            text = TR("下一次抽奖必出暴击,获得%s倍奖励!", ratio),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x83, 0x45, 0x00),
            dimensions = cc.size(320, 0)
        })
        self.mRatioLabel:setAnchorPoint(cc.p(0, 0.5))
        self.mRatioLabel:setPosition(170, 301)
        self.mTabContentLayer:addChild(self.mRatioLabel)
    else
        self.mRatioLabel = ui.newLabel({
            text = TR("抽奖可能触发奖励,下次抽奖必然获得两至三倍奖励!"),
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x83, 0x45, 0x00),
            dimensions = cc.size(320, 0)
        })
        self.mRatioLabel:setAnchorPoint(cc.p(0, 0.5))
        self.mRatioLabel:setPosition(170, 301)
        self.mTabContentLayer:addChild(self.mRatioLabel)
    end
end

-- 刷新宝库视图
function ActivityLuckDrawLayer:refreshTabContentLayer()
    -- 移除所有子节点,重新添加
    self.mTabContentLayer:removeAllChildren()
    self.mRatioLabel = nil

    ---------------下方的消耗标签与积分标签------------------
    local useInfo = {}
    if self.mCurrDrawType == PageType.eNormalDarw then
        useInfo = Utility.analysisStrResList(self.mLuckDrawInfo.LuckdrawConfig.OrdinaryUseResource)
    else
        useInfo = Utility.analysisStrResList(self.mLuckDrawInfo.LuckdrawConfig.SeniorUseResource)
    end
    -- 每次抽奖消耗XX
    local useStr = nil
    if self.mCurrDrawType == PageType.eNormalDarw then
        useStr = TR("%s普通宝库每次抽奖消耗: {db_50027.png}%sx%d",
            "#502619",
            "#ff0000",
            useInfo[1].num
        )
    else
        useStr = TR("%s高级宝库每次抽奖消耗: {db_50027.png}%sx%d",
            "#502619",
            "#ff0000",
            useInfo[1].num
        )
    end
    local useLabel = ui.newLabel({
        text = useStr,
    })
    useLabel:setAnchorPoint(cc.p(0, 0.5))
    useLabel:setPosition(cc.p(170, 180))
    self.mTabContentLayer:addChild(useLabel)
    -- "积分+10"
    local scoreLabel = ui.newLabel({
        text = TR("%s积分:%s+%d",
            "#502619",
            "#ff0000",
            useInfo[1].num
        )
    })
    scoreLabel:setAnchorPoint(cc.p(0, 0.5))
    scoreLabel:setPosition(cc.p(170, 150))
    self.mTabContentLayer:addChild(scoreLabel)


    --------------------中间抽奖按钮—----------------------
    -- 一次
    self.mDrawOneBtn = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(240, 172.5 + 60),
        text = TR("抽奖"),
        clickAction = function (pSender)
            -- 检查数量是否足够
            local count = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, 16050027)
            local name = Utility.getGoodsName(ResourcetypeSub.eFunctionProps, 16050027)
            if count >= 1 then
                self:requestLuckdraw(1)
            else
                ui.showFlashView({
                    text = TR("您的%s不足!", name)
                })
            end
        end
    })
    self.mTabContentLayer:addChild(self.mDrawOneBtn)
    -- 十次按钮
    self.mDrawTenBtn = ui.newButton({
        normalImage = "c_28.png",
        position = cc.p(400, 172.5 + 60),
        text = TR("十连抽"),
        clickAction = function (pSender)
            -- 检查数量是否足够
            local count = Utility.getOwnedGoodsCount(ResourcetypeSub.eFunctionProps, 16050027)
            local name = Utility.getGoodsName(ResourcetypeSub.eFunctionProps, 16050027)
            if count >= 10 then
                self:requestLuckdraw(10)
            else
                ui.showFlashView({
                    text = TR("您的%s不足!", name)
                })
            end
        end
    })
    self.mTabContentLayer:addChild(self.mDrawTenBtn)

    -----------------上方的奖励倍数标签----------------
    self:updateTopLabel()

    ------------------添加14个宝箱----------------------
    self:addBoxs()

    -- 每次刷新之后，设置默认的选中序号，产生新的选中框
    self.mSelectIndex = 1
    self.mSelectSprite = ui.newSprite("c_31.png")
    self.mSelectSprite:setScale(0.9)
    self.mSelectSprite:setPosition(self.mBoxPos[self.mSelectIndex])
    self.mTabContentLayer:addChild(self.mSelectSprite)
    self.mSelectSprite:setVisible(false)
end

-- 刷新顶部标签、时间标签、中奖纪录区域内容、宝库奖励内容
function ActivityLuckDrawLayer:refreshLayer()
    -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

    -- 更新顶部标签
    -- 解析字符串数据为表数据
    local exchangeResourceInfo = Utility.analysisStrResList(self.mLuckDrawInfo.LuckdrawConfig.ExchangeResource)
    self.mTopLabel:setString(TR("充值%d元宝获得{db_50027.png}%sx%d%s 当前已充值:%s%d/%d",
        self.mLuckDrawInfo.LuckdrawConfig.ExchangeQuota,
        "#8aedff",
        exchangeResourceInfo[1].num,
        Enums.Color.eWhiteH,
        "#8aedff",
        self.mLuckDrawInfo.TimedLuckdrawInfo.RechargeNum,
        self.mLuckDrawInfo.LuckdrawConfig.ExchangeQuota
    ))

    -- 刷新底部分页内容
    self:refreshTabContentLayer()

    -- 刷新中奖记录内容
    --self:refreshMessageBox()
end

-- 选中框的绕圈动画
--[[
    params:
    index                       -- 当前选中的序号
    dropList                    -- 掉落的物品列表
--]]
function ActivityLuckDrawLayer:executeRollingEffect(index, dropList)
    -- 绕圈时禁止触摸
    local layer = cc.Layer:create()
    ui.registerSwallowTouch({node = layer})
    self:addChild(layer, Enums.ZOrderType.eWaiting)

    -- 选中框的绕圈起始位置
    local rollStartIndex = self.mSelectIndex
    -- 此次得到的index，作为下一次绕圈的起始位置
    self.mSelectIndex = index

    ----------------------开始绕圈-----------------------
    self.mSelectSprite:setVisible(true)
    local actionArray = {}
    -- 抽奖按钮失效
    table.insert(actionArray, cc.CallFunc:create(function()
        self.mDrawOneBtn:setEnabled(false)
        self.mDrawTenBtn:setEnabled(false)
    end))

    -- 绕圈运动
    function move(time, index)
        table.insert(actionArray, cc.DelayTime:create(time))
        table.insert(actionArray, cc.CallFunc:create(
            function()
                self.mSelectSprite:setPosition(self.mBoxPos[index])
            end
        ))
    end
    -- 加速
    local count = 1
    for i = rollStartIndex, 14 do
        move(0.31 - count * 0.02, i)
        count = count + 1
    end
    for i = 1, rollStartIndex do
        move(0.31 - count * 0.02, i)
        count = count + 1
    end
    for i = rollStartIndex, 14 do
        move(0.03, i)
    end
    -- 匀速绕四圈
    for j = 1, 4 do
        for i = 1, 14 do
            move(0.03, i)
        end
    end
    -- 减速
    count = 0
    for i = 1, 14 do
        if i < index then
            move(0.03, i)
        else
            move(0.03 + count * 0.02, i)
            count = count + 1
        end
    end
    for i = 1, index do
        move(0.03 + count * 0.02, i)
        count = count + 1
    end

    -- 按钮恢复，显示奖励飘窗
    table.insert(actionArray, cc.CallFunc:create(function()
        self.mDrawOneBtn:setEnabled(true)
        self.mDrawTenBtn:setEnabled(true)

        -- 可能的是抽到的奖品，也可能是下一次2倍、3倍
        if dropList[1] and next(dropList[1]) ~= nil then
            ui.ShowRewardGoods(dropList)
        else
            print("---下次双倍/三倍---")
        end
    end))

    -- 更新标签，移除屏蔽层
    table.insert(actionArray, cc.CallFunc:create(function()
        self:updateTopLabel()
        --恢复点击
        layer:removeFromParent()
    end))
    self.mSelectSprite:runAction(cc.Sequence:create(actionArray))
end

-- 抽奖排行页面
-- 有两种显示方式，一种是抽奖赠礼，另一种是抽奖返钻，更多使用第一种
--[[
    params:
    isOldWay                -- 按老的方式显示还是按新的方式显示
--]]
function ActivityLuckDrawLayer:showRankLayer(isOldWay)
    -- 添加提示框
    local layerParams = {
        bgImage = "c_30.png",
        bgSize = cc.size(598, 770),
        title = TR("积分抽奖排名"),
        msgText = "",
        notNeedBlack = true,
        closeBtnInfo = {
            position = cc.p(575, 745)
        },
        btnInfos = {
                {
                text = TR("确定"),
                normalImage = "c_28.png",
                position = cc.p(299, 50),
                clickAction = function (layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                end
            }
        },
        DIYUiCallback = function(layerObj, bgObj,bgSize)
            -- 我的排名xx 我的积分xx / 我的积分xx 返钻xx
            local myRankBg = ui.newScale9Sprite("c_25.png", cc.size(550, 54))
            myRankBg:setPosition(299, 670)
            bgObj:addChild(myRankBg)

            local tempRankStr = nil
            if not isOldWay then
                tempRankStr = TR("我的排名: %s   我的积分: %s",
                    self.mLuckDrawInfo.TimedLuckdrawInfo.Rank == 0 and "" or self.mLuckDrawInfo.TimedLuckdrawInfo.Rank,
                    Utility.numberWithUnit(self.mLuckDrawInfo.TimedLuckdrawInfo.Integral)
                )
            else
                tempRankStr = TR("我的积分: %s   返元宝: %s",
                    Utility.numberWithUnit(self.mLuckDrawInfo.TimedLuckdrawInfo.Integral),
                    Utility.numberWithUnit(math.ceil(self.mLuckDrawInfo.TimedLuckdrawInfo.Ratio / 100))
                )
            end
            local myRank = ui.newLabel({
                text = tempRankStr,
                size = 21,
                color = Enums.Color.eNormalWhite,
                outlineColor = cc.c3b(0x82, 0x49, 0x36),
                align = ui.TEXT_ALIGN_CENTER
            })
            myRank:setPosition(299, 670)
            bgObj:addChild(myRank)

            -- 每一列的标题
            local firstLabel = ui.newLabel({
                text = TR("排名"),
                size = 23,
                color = cc.c3b(0x46, 0x22, 0x0d),
                -- outlineColor = Enums.Color.eBrown,
                align = ui.TEXT_ALIGN_CENTER
            })
            firstLabel:setPosition(85, 625)
            bgObj:addChild(firstLabel)

            local secondLabel = ui.newLabel({
                text = TR("玩家姓名"),
                size = 23,
                color = cc.c3b(0x46, 0x22, 0x0d),
                -- outlineColor = Enums.Color.eBrown,
                align = ui.TEXT_ALIGN_CENTER
            })
            secondLabel:setPosition(220, 625)
            bgObj:addChild(secondLabel)

            local thirdLabel = ui.newLabel({
                text = TR("积分"),
                size = 23,
                color = cc.c3b(0x46, 0x22, 0x0d),
                -- outlineColor = Enums.Color.eBrown,
                align = ui.TEXT_ALIGN_CENTER
            })
            thirdLabel:setPosition(350, 625)
            bgObj:addChild(thirdLabel)

            local tempSpr = nil
            if isOldWay then
                tempSpr = TR("返元宝")
            else
                tempSpr = TR("赠礼")
            end
            local forthLabel = ui.newLabel({
                text = tempSpr,
                size = 23,
                color = cc.c3b(0x46, 0x22, 0x0d),
                -- outlineColor = Enums.Color.eBrown,
                align = ui.TEXT_ALIGN_CENTER
            })
            forthLabel:setPosition(485, 625)
            bgObj:addChild(forthLabel)

            -- -- 下方的背景框
            local bottomBg = ui.newScale9Sprite("c_17.png", cc.size(540, 510))
            bottomBg:setPosition(299, 340)
            bgObj:addChild(bottomBg)


            -- 插入排行的每一个条目
            local function addRankItem(index)
                local itemNode = ccui.Layout:create()
                itemNode:setContentSize(536, 100)

                local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(530, 98))
                bgSprite:setPosition(270, 50)
                itemNode:addChild(bgSprite)

                local rankInfo = self.mLuckDrawInfo.RankList[index]
                --背景
                -- local bg = ui.newScale9Sprite("c_25.png", cc.size(bottomBg:getContentSize().width - 10, 100))
                -- bg:setPosition(cc.p(bottomBg:getContentSize().width / 2, 40))
                -- itemNode:addChild(bg)
                -- 排名

                 -- 前三名显示圆圈
                if rankInfo.Rank <= 3 then
                    local picName = nil
                    if rankInfo.Rank == 1 then
                        picName = "c_44.png"
                    elseif rankInfo.Rank == 2 then
                        picName = "c_45.png"
                    elseif  rankInfo.Rank == 3 then
                        picName = "c_46.png"
                    end

                    local spr = ui.newSprite(picName)
                    spr:setAnchorPoint(cc.p(0.5, 0.5))
                    spr:setPosition(65, 50)
                    itemNode:addChild(spr)
                    -- spr:setScale(0.6)
                else
                    local rankNumLabel = ui.createSpriteAndLabel({
                        imgName = "c_47.png",
                        -- scale9Size = cc.size(69, 69),
                        labelStr = rankInfo.Rank,
                        fontColor = Enums.Color.eNormalWhite,
                        -- outlineColor = Enums.Color.eOutlineColor,
                        fontSize = 28
                    })
                    rankNumLabel:setPosition(cc.p(65, 50))
                    itemNode:addChild(rankNumLabel)
                end

                -- local label1 = ui.newLabel({
                --     text = TR(rankInfo.Rank),
                --     size = 20,
                --     color = Enums.Color.eBlack,
                --     align = ui.TEXT_ALIGN_CENTER
                -- })
                -- label1:setPosition(65, 30)
                -- itemNode:addChild(label1)
                -- 姓名
                local label2 = ui.newLabel({
                    text = rankInfo.Name,
                    size = 22,
                    color = cc.c3b(0x46, 0x22, 0x0d),
                    anchorPoint = cc.p(0, 0.5)
                })
                itemNode:addChild(label2)
                label2:setPosition(120, 50)

                -- 积分
                local label3 = ui.newLabel({
                    text = Utility.numberWithUnit(rankInfo.Integral),
                    size = 22,
                    color = cc.c3b(0xd1, 0x7b, 0x00),
                    align = ui.TEXT_ALIGN_CENTER
                })
                label3:setPosition(320, 50)
                itemNode:addChild(label3)

                -- 赠礼/返钻
                if isOldWay then
                    local returnConfig = self.mLuckDrawInfo.LuckdrawRankreturnConfig[index]
                    if returnConfig and returnConfig.Ratio then
                        local label = ui.newLabel({
                            text = Utility.numberWithUnit(math.ceil(returnConfig.Ratio / 100)),
                            size = 30,
                            color = Enums.Color.eBrown,
                            align = ui.TEXT_ALIGN_CENTER
                        })
                        label:setPosition(448, 50)
                        itemNode:addChild(label)
                    end
                else
                    -- 赠礼
                    local returnConfig = self.mLuckDrawInfo.LuckdrawRankreturnConfig[index]
                    local rewardList = Utility.analysisStrResList(returnConfig.ReturnResource)
                    for i, v in ipairs(rewardList) do
                        v.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
                    end
                    local rewardListView = ui.createCardList({
                        maxViewWidth = 210,
                        space = -15,
                        cardDataList = rewardList,
                        cardShape = Enums.CardShape.eCircle,
                        allowClick = true
                    })
                    rewardListView:setAnchorPoint(cc.p(0, 0.5))
                    rewardListView:setPosition(380, 40)
                    itemNode:addChild(rewardListView)
                    rewardListView:setScale(0.7)
                end

                return itemNode
            end

            -- 排名列表
            local rankListView = ccui.ListView:create()
            rankListView:setDirection(ccui.ScrollViewDir.vertical)
            rankListView:setBounceEnabled(true)
            rankListView:setContentSize(cc.size(540, 490))
            rankListView:setGravity(ccui.ListViewGravity.centerVertical)
            rankListView:setAnchorPoint(cc.p(0.5, 1))
            rankListView:setItemsMargin(5)
            rankListView:setPosition(299, 585)
            bgObj:addChild(rankListView)

            for i = 1, #self.mLuckDrawInfo.RankList do
                rankListView:pushBackCustomItem(addRankItem(i))
            end

            -- 底部按钮全部隐藏
            -- for k, v in pairs(layerObj:getBottomBtns()) do
            --     v:setVisible(false)
            -- end
        end
    }
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = layerParams,
        cleanUp = false
    })
end

--创建宝箱弹窗
function ActivityLuckDrawLayer:showBoxLayer()
    --弹窗
    local popLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(598, 720),
        title = TR("宝库兑换"),
        closeAction = function(pSender)
            LayerManager.removeLayer(pSender)
        end,
    })
    self:addChild(popLayer)
    self.mPopLayer = popLayer
    self.mPopBgSprite = popLayer.mBgSprite

    --灰色底板
    local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(539, 560))
    grayBgSprite:setPosition(299, 372)
    self.mPopBgSprite:addChild(grayBgSprite)


    -- local onekeyBtn = ui.newButton({
    --         normalImage = "c_33.png",
    --         text = TR("确定"),
    --         clickAction = function()
    --             self:requestGetOneKeyReward()
    --         end
    --     })
    -- onekeyBtn:setPosition(299, 55)
    -- self.mPopBgSprite:addChild(onekeyBtn)


    -- 奖励列表控件
    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.vertical)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(550, 545))
    rewardListView:setItemsMargin(5)
    rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rewardListView:setAnchorPoint(cc.p(0.5, 0))
    rewardListView:setPosition(299, 102)
    self.mPopBgSprite:addChild(rewardListView)

    self.mGetBtnList = {}
    for i, v in ipairs(self.mLuckDrawInfo.LuckdrawNumRewardConfig) do
        local layout = ccui.Layout:create()
        layout:setContentSize(550, 170)

        local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(530, 170))
        bgSprite:setPosition(275, 85)
        layout:addChild(bgSprite)

        local getBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("领取"),
            clickAction = function(pSender)
                self:requestGetReward(v.Num, pSender)
            end
            })
        getBtn:setPosition(460, 85)
        layout:addChild(getBtn)
        getBtn:setEnabled(false)
        table.insert(self.mGetBtnList, getBtn)

        -- 已使用抽奖劵数量
        local lotteryNum = self.mLuckDrawInfo.TimedLuckdrawInfo.LotteryNum or 0

        if self.mRecivedList[v.Num] then
            getBtn:setTitleText(TR("已领取"))        
        elseif lotteryNum >= v.Num then
            getBtn:setEnabled(true)
        end

        local rewardList = Utility.analysisStrResList(v.Reward)
        local cardList = ui.createCardList({
                maxViewWidth = 350  , -- 显示的最大宽度
                viewHeight = 120, -- 显示的高度，默认为120
                space = 10, -- 卡牌之间的间距, 默认为 10
                cardDataList = rewardList
            })
        cardList:setAnchorPoint(0, 0.5)
        cardList:setPosition(20, 70)
        layout:addChild(cardList)

        local tipLabel = ui.newLabel({
            text = TR("使用抽奖券数量达到%s%d#46220d/%d", lotteryNum >= v.Num and "#258711" or "#ea2c00", lotteryNum, v.Num),
            size = 22,
            color = cc.c3b(0x46, 0x22, 0x0d),
            })
        tipLabel:setAnchorPoint(0, 0.5)
        tipLabel:setPosition(20, 150)
        layout:addChild(tipLabel)

        rewardListView:pushBackCustomItem(layout)
    end
end

-----------------------网络相关------------------------
-- 请求服务器，获取玩家宝库抽奖信息
function ActivityLuckDrawLayer:requestGetLuckDrawInfo()
    HttpClient:request({
        moduleName = "TimedLuckdrawInfo",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            -- dump(data, "requestGetLuckDrawInfo")

            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 保存数据
            self.mLayerData = data.Value
            self.mLuckDrawInfo = data.Value

            -- 宝库已兑换列表
            local tempList = string.splitBySep(self.mLuckDrawInfo.TimedLuckdrawInfo.DrawRewardNumStr or "", ",")
            self.mRecivedList = {}
            for _, recivedId in pairs(tempList) do
                self.mRecivedList[tonumber(recivedId)] = true
            end
            -- 刷新页面
            self:refreshLayer()
            --刷新奖励box
            self:refreshMessageBox()
        end
    })
end

-- 请求服务器，抽奖
--[[
    params:
    times                   -- 抽奖次数
--]]
function ActivityLuckDrawLayer:requestLuckdraw(times)
    HttpClient:request({
        moduleName = "TimedLuckdrawInfo",
        methodName = "Luckdraw",
        svrMethodData = {self.mCurrDrawType == PageType.eNormalDarw and 1 or 2, times},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            MqAudio.playEffect("choujiang.mp3")

            -- 保存新返回的抽奖记录
            self.mNewRecords = data.Value.Message

            -- 刷新数据
            -- 对比新记录与老记录，加不重复的新记录添加到老记录中
            for k0, v0 in pairs(data.Value.Message) do
                local isExist = false
                for k1, v1 in pairs(self.mLuckDrawInfo.Message) do
                    if v0.Name == v1.Name and v0.Reward == v1.Reward and v0.Type == v1.Type then
                        isExist = true
                    end
                end

                if not isExist then
                    table.insert(self.mLuckDrawInfo.Message, v0)
                end
            end

            self.mLuckDrawInfo.TimedLuckdrawInfo = data.Value.TimedLuckdrawInfo
            self.mLuckDrawInfo.RankList = data.Value.RankList
            -- 缓存到父页面
            self.mLayerData = self.mLuckDrawInfo

            -- 刷新当前道具数量、滚动消息列表
            self:refreshPartViews()

            if times == 1 then
                -- 选中框的绕圈效果
                self:executeRollingEffect(data.Value.OrderId[1], data.Value.BaseGetGameResourceList)
            elseif times == 10 then
                -- 飘窗显示获取的物品
                ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
            end
        end
    })
end

function ActivityLuckDrawLayer:requestGetReward(num, btnObj)
    HttpClient:request({
        moduleName = "TimedLuckdrawInfo",
        methodName = "DrawNumReward",
        svrMethodData = {num},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)

            btnObj:setEnabled(false)
            btnObj:setTitleText(TR("已领取"))

            -- 保存数据
            self.mLayerData.TimedLuckdrawInfo = data.Value.TimedLuckdrawInfo
            self.mLuckDrawInfo.TimedLuckdrawInfo = data.Value.TimedLuckdrawInfo

            -- 宝库已兑换列表
            local tempList = string.splitBySep(self.mLuckDrawInfo.TimedLuckdrawInfo.DrawRewardNumStr or "", ",")
            self.mRecivedList = {}
            for _, recivedId in pairs(tempList) do
                self.mRecivedList[tonumber(recivedId)] = true
            end
        end
    })
end

return ActivityLuckDrawLayer
