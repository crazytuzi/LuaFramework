--[[
    文件名: OpenContestLayer.lua
    描述: 开服比拼页面
    创建人: suntao
    创建时间: 2016.07.19
--]]

--local DEBUG_S = false

local OpenContestLayer = class("OpenContestLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

-- 构造函数
function OpenContestLayer:ctor(params)
	-- 初始化数据
	self.mCurTag = params.rankType
	self.mData = nil	    	-- 总数据 网络请求
    self.mPagesData = {}

    -- 控件
	self.mTabs = nil       		-- 顶部按钮集合
    self.mSelectedSprites = {}
    self.mPages = {}            -- 页面
    self.mTopNodes = {}
    self.mButtons = {}

	-- 初始化界面
	self:createLayer()

    -- 获取总数据
    self:requestGetActiveRank()
end

-- 基本载入完毕
function OpenContestLayer:onEnterTransitionFinish()
    self.mEnterTransitionFinish = true
    if not self.mShowed and self.mData ~= nil then
        self.mShowed = true
        self:changePage(self.mCurTag)
    end
end

-- 初始化界面
function OpenContestLayer:createLayer()
    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 大背景
    local sprite = ui.newSprite("c_34.jpg")
    sprite:setPosition(320, 568)
    self.mParentLayer:addChild(sprite, Enums.ZOrderType.eDefault - 2)

    -- 上方条件列表背景
    local sprite = ui.newScale9Sprite("c_69.png", cc.size(650 ,150))
    sprite:setAnchorPoint(0.5, 0.5)
    sprite:setPosition(320, 995)
    self.mParentLayer:addChild(sprite)

    --飘带背景
    -- local offsetX = 140
    -- local sprite = ui.newSprite("kfbp_15.png")
    -- sprite:setAnchorPoint(0.5, 0.5)
    -- sprite:setPosition(320 , 900)
    -- self.mParentLayer:addChild(sprite)

    self:initUI()
end

-- 创建UI
function OpenContestLayer:initUI()
    -- 创建顶部资源栏和底部导航栏
    local mainNavLayer = require("commonLayer.MainNavLayer"):create({
        needMainNav = true,
    })
    self:addChild(mainNavLayer, Enums.ZOrderType.eDefault + 4)

    -- 创建退出按钮
    local x = 600
    local y = 902
    local button = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(x, y),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(button, Enums.ZOrderType.eDefault + 5)
    self.mCloseBtn = button

    -- 创建规则按钮
    local button = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(640 - x, y),
        clickAction = function()
            local rulesData = {
                [1] = TR("1. 开服比拼是以服务器开放时间的第二天开始结算，即1月1日开的服务器，第一天的比拼是在1月2日晚24点结算排名"),
                [2] = TR("2. 开服比拼为全服排名比拼，只要进入筛选条件后的玩家均可以参加，按照每天不同的比拼内容进行对应的排名"),
                [3] = TR("3. 每天的每项比拼只取前三名玩家，可以获得对应的1/2/3名奖励，有些奖励可是特殊绝版奖励哦"),
                [4] = TR("4. 每天的每项比拼还有参与限制，只要达到参与限制的玩家，可以领取每天对应的道具奖励"),
                [5] = TR("5. 每天的比拼在24点结算，结算以后奖励通过领奖中心发放，请及时领取对应奖励"),
                [6] = TR("6. 比拼分为7类比拼（等级/江湖总星数/侠客进阶数/华山论剑排名/比武招亲星数/装备锻造等级/最高战力）其中，装备品级为上阵主将身上的所有装备品级总和"),
            }
            MsgBoxLayer.addRuleHintLayer(TR("全服比拼说明"), rulesData)
        end
    })
    self.mParentLayer:addChild(button, Enums.ZOrderType.eDefault + 3)

    -- 创建比拼名称
    local label = ui.newLabel({
        text = TR(" "),
        size = 33,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(64,117,162),
        outlineSize = 3,
        x = 320,
        y = 910,
    })
    self.mParentLayer:addChild(label)
    self.mContestNameLabel = label

    -- 创建标签
    self:createTabs()

    -- 创建个人比拼奖励
    self:createSelfReward()

    -- 创建全服比拼奖励
    self:createTopReward()
end

-- 创建个人比拼
function OpenContestLayer:createSelfReward()
    local x = 75
    local y = 997
    -- 奖励头像
    local card = CardNode.createCardNode({})
    card:setPosition(x, y)
    card:setEmpty({CardShowAttr.eBorder}, "c_01.png")
    self.mParentLayer:addChild(card)
    self.mSelfRewardNode = card

    -- 条件
    local offset = 18
    x = x + 60
    local label = ui.newLabel({
        text = string.format("%s ", Enums.Color.eWhiteH),
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        anchorPoint = cc.p(0, 0.5),
        size = 20,
        x = x,
        y = y + offset
    })
    self.mParentLayer:addChild(label)
    self.mSelfConditionLabel = label

    -- 状态
    local label = ui.newLabel({
        text = string.format("%s ", Enums.Color.eWhiteH),
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        anchorPoint = cc.p(0, 0.5),
        size = 20,
        x = x,
        y = y - offset
    })
    self.mParentLayer:addChild(label)
    self.mSelfStateLabel = label
end

local Top3Config = {
    {
        cardBg = "kfbp_01.png", cardNameBg = "kfbp_11.png",
        rankBg = "gd_10.png"   , rankPic     = "c_44.png"  ,
        cardNumBg = "kfbp_13.png",
    },
    {
        cardBg = "kfbp_11.png", cardNameBg = "kfbp_12.png",
        rankBg = "gd_10.png"   , rankPic     = "c_45.png"  ,
        cardNumBg = "kfbp_18.png",
    },
    {
        cardBg = "kfbp_12.png", cardNameBg = "kfbp_15.png",
        rankBg = "gd_10.png"   , rankPic     = "c_46.png"  ,
        cardNumBg = "kfbp_14.png",
    },
}

-- 创建全服比拼
function OpenContestLayer:createTopReward()
    -- 新建椭圆控件
    local ellipseLayer = require("common.EllipseLayer").new({
        longAxias = 220,
        shortAxias = 2,
        fixAngle = 30,
        totalItemNum = 3,
        unlockItemNum = 3,
        itemContentCallback = function(parent, index)
            local i = 4 - index
            local config = Top3Config[i]

            -- 父节点
            local layout = ccui.Layout:create()
            layout:setAnchorPoint(0.5, 0.5)
            parent:addChild(layout)

            -- 背景
            local sprite = ui.newSprite(config.cardBg)
            local size = sprite:getContentSize()
            sprite:setPosition(size.width/2, size.height/2)
            layout:setContentSize(size.width, size.height)
            layout:addChild(sprite)
            self.mTopNodes[i] = sprite

            -- 名次
            -- local Numberlabel = ui.newSprite(config.titleImagle)
            -- Numberlabel:setPosition(size.width / 2, size.height - 30)
            -- layout:addChild(Numberlabel)
        end,
    })
    ellipseLayer:setPosition(320, 750)
    self.mParentLayer:addChild(ellipseLayer, 1)

    -- 注册触摸事件
    self:registerDragTouch(ellipseLayer)

    -- 父容器
    local layout = ccui.Layout:create()
    layout:setContentSize(640, 470)
    layout:setAnchorPoint(0.5, 1)
    layout:setPosition(320, 470)
    self.mParentLayer:addChild(layout, 1)
    self.mPanelLayout = layout

    -- 下方操作面板背景
    local sprite = ui.newScale9Sprite("c_19.png", cc.size(645, 575))
    sprite:setAnchorPoint(0.5, 1)
    sprite:setPosition(320, 600)
    self.mPanelLayout:addChild(sprite)
    --灰色底板
    local underGraySprite = ui.newScale9Sprite("c_17.png", cc.size(620, 365))
    underGraySprite:setAnchorPoint(0.5, 1)
    underGraySprite:setPosition(320, 520)
    self.mPanelLayout:addChild(underGraySprite)

    --标题背景板
    local titleBgImage = ui.newScale9Sprite("c_25.png", cc.size(540, 48))
    titleBgImage:setPosition(320, 550)
    self.mPanelLayout:addChild(titleBgImage)

    -- 下方列表标题
    local offsetX = 215
    local tmpLabel = ui.newLabel({
        text = TR(" "),
        size = 23,
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
    })
    tmpLabel:setPosition(320, 550)
    self.mPanelLayout:addChild(tmpLabel)
    self.mContestConditionLabel = tmpLabel
end

--- ==================== 标签相关 =======================
local ButtonsConfig = {
    {RankType = 1, NamePic = "kfbp_06.png"},    --最高等级
    {RankType = 2, NamePic = "kfbp_05.png"},    --江湖总星数
    {RankType = 3, NamePic = "kfbp_03.png"},    --上阵侠客进阶总等级
    {RankType = 4, NamePic = "kfbp_04.png"},    --华山论剑排名
    {RankType = 5, NamePic = "kfbp_07.png"},    --比武招亲星数
    {RankType = 6, NamePic = "kfbp_09.png"},    --上阵装备锻造总等级
    {RankType = 7, NamePic = "kfbp_08.png"},     --最高战力
}

-- 创建标签
function OpenContestLayer:createTabs()
    local buttonInfos = {}
    -- 初始化按钮信息
    for i, config in ipairs(ButtonsConfig) do
        buttonInfos[i] = {
            text = TR("第%d天", config.RankType + 1),
            tag = config.RankType,
        }
        if i == 1 then
               buttonInfos[i] = {
                text = TR("第1,2天"),
                tag = config.RankType,
            }
        end
    end

    -- 创建标签
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        -- btnSize = cc.size(84, 52),
        needLine = true,
        space = 5,
        defaultSelectTag = self.mOriginalTag,
        onSelectChange = function (tag)
            if tag == self.mCurTag then return end
            self:changePage(tag)
        end,
        allowChangeCallback = function (tag) return true end
    })
    tabLayer:setAnchorPoint(0.5, 0)
    tabLayer:setPosition(320, 1065)
    self.mParentLayer:addChild(tabLayer)
    self.mTabs = tabLayer

    --ui需求tabView加特殊的线
    -- local topLine = ui.newScale9Sprite("kfbp_01.png", cc.size(640, 8))
    -- topLine:setPosition(320, 1070)
    -- self.mParentLayer:addChild(topLine)

    -- 添加"小红点"
    local buttons = self.mTabs:getTabBtns()

    for tag, button in ipairs(buttons) do
        -- 小红点是否显示判断函数
        local moduleId = ModuleSub["eOpenContest"..tag]
        local function dealRedDotVisible(redDotSprite)
            redDotSprite:setVisible(RedDotInfoObj:isValid(moduleId))
        end
        ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(moduleId), parent = button})
    end
end

-- 跳转到分页
function OpenContestLayer:changePage(tag)
    if self.mTabs == nil then
        return
    end

    -- 旧分页
    local oldTag = self.mCurTag
    if self.mSelectedSprites[oldTag] then
        self.mSelectedSprites[oldTag]:setVisible(false)
    end

    -- 请求新分页
    self.mCurTag = tag
    --self.mSelectedSprites[tag]:setVisible(true)
    self:requestGetRank(tag, oldTag)
end

--- ==================== 单个Page相关 =======================
local PageWidth = 597
local PageHeight = 456
local ItemHeight = 112

-- 添加新分页(如果对应的页面已经存在，先移除后添加)
function OpenContestLayer:addPage(tag)
    -- 显示个人奖励
    self:showSelfReward(tag)

    -- 显示全服奖励
    self:showTopReward(tag)

    -- 排行容器
    local page = self:createRankLayer(tag)
    page:setAnchorPoint(0.5, 1)
    page:setPosition(320, 510)

    -- 保存
    self:removePage(tag)
    self.mPanelLayout:addChild(page)

    self.mPages[tag] = page
    page.needReload = false

    -- 动画
    page:jumpToTop()
    for i=1, 4 do
        local node = page:getItem(i - 1)
        if node then
            local x, y = node:getPosition()
            local offsetX = -0
            local offsetY = 0

            node:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.06 * (i-1)),
            cc.MoveTo:create(0.5, cc.p(x + offsetX, y + offsetY))))
        end
    end
end

-- 删除分页
function OpenContestLayer:removePage(tag)
    if self.mPages[tag] then
        self.mPages[tag]:removeFromParent()
        self.mPages[tag] = nil
    end
end

-- 显示个人奖励
function OpenContestLayer:showSelfReward(tag)
    -- 配置与数据
    local config = OpencontestProjectModel.items[tag]
    local rewardState = {}
    --dump(self.mData,"=============self.mData============")
    for k, v in ipairs(self.mData.OpencontestState) do
        if tag == v.RankType then
            rewardState = v
            break
        end
    end

    -- 显示奖励头像
    local resInfo = Utility.analysisStrResList(config.personalRewards)[1]
    self.mSelfRewardNode:setCardData({
        resourceTypeSub = resInfo.resourceTypeSub, -- 资源类型
        modelId = resInfo.modelId,  -- 模型Id
        num = resInfo.num,
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
        onClickCallback = function ()
            if rewardState.State == 1 and tag <= self.mData.RankType then
                self:requestDrawReward(tag)
            elseif rewardState.State == 2 then
                ui.showFlashView(TR("已领取奖励"))
            else
                CardNode.defaultCardClick({
                    resourceTypeSub = resInfo.resourceTypeSub,
                    modelId = resInfo.modelId,
                })
            end
        end
    })
    if rewardState.State == 1 and tag <= self.mData.RankType then
        ui.setWaveAnimation(self.mSelfRewardNode, 7.5, true, cc.p(44, 40))
    else
        self.mSelfRewardNode:setRotation(0)
        -- self.mSelfRewardNode.flashNode:removeFromParent()
        -- self.mSelfRewardNode.flashNode = nil
        if not tolua.isnull(self.mSelfRewardNode.flashNode) then
            self.mSelfRewardNode.flashNode:removeFromParent()
            self.mSelfRewardNode.flashNode = nil
        end
        self.mSelfRewardNode:stopAllActions()
    end


    --dump(rewardState,"============rewardState============")
    -- 显示条件
    local scoreNum, standardNum, rankCondition = self:figureScore(rewardState)
    self.mSelfConditionLabel:setString(TR("%s达到(%s%s%s/%s)可领取",
        config.name,
        rewardState.State > 0 and Enums.Color.eGreenH or Enums.Color.eRedH,
        tostring(scoreNum),
        Enums.Color.eNormalWhiteH,
        tostring(standardNum)
    ))

    -- 取消状态更新
    if self.mSelfStateAction then
        self.mSelfStateLabel:stopAction(self.mSelfStateAction)
        self.mSelfStateAction = nil
    end
    -- 显示状态
    if self.mData.RankType == 0 or tag < self.mData.RankType then
        self.mSelfStateLabel:setString(TR("比拼已结束"))
    elseif tag > self.mData.RankType then
        self.mSelfStateLabel:setString(TR("比拼尚未开始"))
    else
        self:showStateTime(self.mData.EndTime)
    end

    -- 显示比拼名称和条件
    --self.mContestNameLabel:setString(config.name)
    self.mContestConditionLabel:setString(TR("%s达%s可参与",config.name, rankCondition))

    self.mContestNameLabel:removeFromParent()
    local sprite = ui.newSprite(ButtonsConfig[tag].NamePic)
    sprite:setPosition(170, 910)
    self.mParentLayer:addChild(sprite)
    self.mContestNameLabel = sprite
end

-- 剩余时间
function OpenContestLayer:showStateTime(endTime)
    self.mSelfStateAction = Utility.schedule(self, function()
        local interval = endTime - Player:getCurrentTime()
        if interval >= 0 then
            -- 当免战时间还有剩余时
            self.mSelfStateLabel:setString(TR("比拼剩余时间: %s%s",
                Enums.Color.eGreenH,
                MqTime.formatAsHour(interval)
            ))
        else
            self.mSelfStateLabel:stopAction(self.mSelfStateAction)
            self.mSelfStateAction = nil
            self.mSelfStateLabel:setString(TR("比拼已结束",
                Enums.Color.eGreenH,
                MqTime.formatAsHour(0)
            ))
        end
    end, 1)
end

-- 显示前三奖励
function OpenContestLayer:showTopReward(tag)
    local relation = OpencontestRewardsRelation.items[tag]

    for index=1, 3 do
        --
        local config = relation[index][index]
        local layout = self.mTopNodes[index]
        local size = layout:getContentSize()
        layout:removeAllChildren()

        -- 显示名字
        local resInfos = Utility.analysisStrResList(config.rewards)
        -- 第1个
        local resInfo = resInfos[1]
        local name = Utility.getGoodsName(resInfo.resourceTypeSub, resInfo.modelId)

        local rewardCard1 = CardNode.createCardNode({
            resourceTypeSub = resInfo.resourceTypeSub,
            modelId = resInfo.modelId,
            num = resInfo.num,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
        })
        rewardCard1:setPosition(size.width/2 + 25, size.height/2)
        layout:addChild(rewardCard1, 10)

        if #resInfos > 1 then
            rewardCard1:setPosition(size.width/2 + 25, size.height/2 - 58)

            local resInfo = resInfos[2]
            local rewardCard2 = CardNode.createCardNode({
                resourceTypeSub = resInfo.resourceTypeSub,
                modelId = resInfo.modelId,
                num = resInfo.num,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
            })
            rewardCard2:setPosition(size.width/2 + 25, size.height/2 + 48)
            layout:addChild(rewardCard2, 10)

        end
    end
end

-- 创建排行子页面
function OpenContestLayer:createRankLayer(tag)
    -- 创建列表容器
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(false)
    listView:setContentSize(cc.size(PageHeight + 184, PageHeight + 10))
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setItemsMargin(5)
    listView:setScrollBarEnabled(false)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    --listView:setPosition(cc.p(320,800))

    -- 循环创建
    for i=1, 3 do
        local data = self.mPagesData[tag].OpencontestRank[i] or {Rank = i}
        local item = self:createPlayerLayout(tag, data)
        listView:pushBackCustomItem(item)
    end

    -- 自己
    local data = self.mPagesData[tag].MyRank
    --if data.Rank < 0 or data.Rank > 3 then
        local item = self:createPlayerLayout(tag, self.mPagesData[tag].MyRank, true)
        listView:pushBackCustomItem(item)
    --end

    return listView
end

-- 创建单个Item
function OpenContestLayer:createPlayerLayout(tag, data, isMyself)
    -- 配置
    local config = Top3Config[data.Rank] or {}

    -- 容器
    local layout = ccui.Layout:create()
    layout:setContentSize(PageHeight + 184 , ItemHeight)

    if not isMyself then
        local sprite = ui.newScale9Sprite(config.rankBg, cc.size(PageWidth , ItemHeight))
        sprite:setPosition((PageHeight + 184)/2, ItemHeight/2)
        layout:addChild(sprite)

        if config.rankPic then
            -- 前三
            local rankSpr = ui.newSprite(config.rankPic)
            rankSpr:setPosition(PageWidth * 0.11, ItemHeight * 0.5)
            layout:addChild(rankSpr)
        else
            local rankLabel = ui.newNumberLabel({
                text = data.Rank,
                imgFile = "c_42.png",
            })
            rankLabel:setPosition(PageWidth * 0.11, ItemHeight * 0.5)
            layout:addChild(rankLabel)
        end

        if data.Id then
            -- 该排名存在玩家
            -- 玩家头像
            local header = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.eHero,
                modelId = data.HeadImageId,
                IllusionModelId = data.IllusionModelId,
                cardShowAttrs = {CardShowAttr.eBorder},
                onClickCallback = function()
                    Utility.showPlayerTeam(data.Id)
                end
            })
            header:setPosition(PageWidth * 0.25, ItemHeight * 0.5)
            layout:addChild(header)

            -- 玩家名字
            local nameLabel = ui.newLabel({
                text = TR("%s", data.Name),
                color = cc.c3b(0x62, 0x0e, 0x00),
                size = 24,
            })
            nameLabel:setAnchorPoint(cc.p(0, 0))
            nameLabel:setPosition(PageWidth * 0.35, ItemHeight * 0.55)
            layout:addChild(nameLabel)

            -- 分数
            local scoreNum, standardNum, rankCondition = self:figureScore({
                RankType = tag,
                Score = data.Score,
            })
            local scoreLabel = ui.newLabel({
                text = string.format("%s: %s", OpencontestProjectModel.items[tag].name, scoreNum),
                color = cc.c3b(0x24, 0x90, 0x29),
                -- outlineColor = Enums.Color.eBlack,
            })
            scoreLabel:setAnchorPoint(cc.p(0, 1))
            scoreLabel:setPosition(PageWidth * 0.35, ItemHeight* 0.45)
            layout:addChild(scoreLabel)
            if tag == 3 then --根据特殊需求修改显示
                scoreLabel:setString(TR("侠客突破总等级：%s", scoreNum))
            end
            if tag == 6 then --根据特殊需求修改显示
                scoreLabel:setString(TR("装备锻造总等级：%s", scoreNum))
            end
            --胜出标志
            if tag < self.mData.RankType or self.mData.RankType == 0 then
                local wintable = ui.newSprite("kfbp_22.png")
                wintable:setPosition(PageWidth * 0.93 + 20, ItemHeight* 0.5 + 20)
                layout:addChild(wintable)
            else
                local wintable = ui.newSprite("kfbp_21.png")
                wintable:setPosition(PageWidth * 0.93, ItemHeight* 0.5 + 30)
                layout:addChild(wintable)
            end

        else
            -- 该排名没有玩家
            local NoOneSprite = ui.newSprite("kfbp_16.png")
            NoOneSprite:setPosition(PageWidth * 0.55, ItemHeight * 0.5)
            layout:addChild(NoOneSprite)


        end
    else
        -- 是自己
        local sprite = ui.newScale9Sprite("kfbp_10.png", cc.size(PageHeight + 184, ItemHeight/2 - 20))
        sprite:setPosition((PageHeight + 184)/2, ItemHeight/2 + 25)
        layout:addChild(sprite)

        -- local upline1 = ui.newScale9Sprite("c_19.png", cc.size(PageHeight + 184, 10))
        -- upline1:setPosition((PageHeight + 184)/2, ItemHeight/2 + 19)
        -- layout:addChild(upline1)

        -- local upline2 = ui.newScale9Sprite("c_19.png", cc.size(PageHeight + 184, 10))
        -- upline2:setPosition((PageHeight + 184)/2, ItemHeight/2 - 38)
        -- layout:addChild(upline2)

        -- 排名
        -- local labelword = ui.newSprite("kfbp_12.png")
        -- labelword:setPosition(PageHeight * 0.19, (ItemHeight+10) * 0.64)
        -- layout:addChild(labelword)

        local label = ui.newLabel({
            text = TR("我的排名：%s%s", Enums.Color.eGoldH, data.Rank > 0 and data.Rank or "50+"),
            size = 24,
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
            x = PageHeight * 0.19 + 20,
            y = (ItemHeight+10) * 0.64,
        })
        layout:addChild(label)

        -- 提示
        if data.Rank > 0 then
            -- 分数
            local scoreNum, standardNum, rankCondition = self:figureScore({
                RankType = tag,
                Score = data.Score,
            })
            local scoreLabel = ui.newLabel({
                text = string.format("%s: %s", OpencontestProjectModel.items[tag].name, scoreNum),
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
                size = 24,
            })
            scoreLabel:setAnchorPoint(cc.p(0, 0.5))
            scoreLabel:setPosition(PageWidth * 0.6, (ItemHeight+10) * 0.64)
            layout:addChild(scoreLabel)
            if tag == 3 then --根据特殊需求修改显示
                scoreLabel:setString(TR("侠客突破总等级：%s", scoreNum))
            end
            if tag == 6 then --根据特殊需求修改显示
                scoreLabel:setString(TR("装备锻造总等级：%s", scoreNum))
            end
        else
            local label = ui.newLabel({
                text = TR("暂未进入前50名"),
                color = Enums.Color.eWhite,
                outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
                size = 24,
            })
            label:setAnchorPoint(cc.p(0, 0.5))
            label:setPosition(PageWidth * 0.66, (ItemHeight+10) * 0.64)
            layout:addChild(label)
        end
    end

    return layout
end

--- ==================== 数据相关 =======================
-- 辅助函数 读取排行榜玩家分数
function OpenContestLayer:figureScore(info)
    -- 初始化
    local scoreNum = nil
    local standardScore = OpencontestProjectModel.items[info.RankType].personalCondition
    local standardNum = standardScore
    local rankCondition = OpencontestProjectModel.items[info.RankType].rankCondition

    -- 没有分数信息 就返回了
    if not next(info.Score) then info.Score = {} end

    -- 等级
    if info.RankType == 1 then
        scoreNum = info.Score.Lv
    -- 关卡总星数
    elseif info.RankType == 2 then
        scoreNum = info.Score.NewAllStarCount
    -- 站天榜
    elseif info.RankType == 4 then
        if info.Score.HistoryMaxStep and info.Score.HistoryMaxRank then
            scoreNum = info.Score.HistoryMaxStep..TR("阶")..info.Score.HistoryMaxRank..TR("名")
        else
            scoreNum = TR("暂无排名")
        end
        standardNum = TR("3阶%d名", standardScore)
        rankCondition = TR("3阶%d名", rankCondition)
    -- 神装殿星数
    elseif info.RankType == 5 then
        scoreNum = info.Score.MaxStarCount
    -- 上阵装备品级总分数, 至尊密藏最高伤害, 战力总和
    else
        scoreNum = Utility.numberWithUnit(info.Score.Score or 0, 0)
        standardNum = Utility.numberWithUnit(standardScore, 0)
        rankCondition = Utility.numberWithUnit(rankCondition, 0)
    end

    return scoreNum or 0, standardNum, rankCondition
end

-- 数据恢复
function OpenContestLayer:getRestoreData()
    return {
        rankType = self.mCurTag
    }
end

--- ==================== 触摸相关 =======================
-- 添加触摸事件处理
function OpenContestLayer:registerDragTouch(node)
    -- 触摸层
    local layout = ccui.Layout:create()
    layout:setContentSize(640, 300)
    layout:setAnchorPoint(0.5, 0.5)
    layout:setPosition(320, 750)
    layout:setTouchEnabled(true)
    self.mParentLayer:addChild(layout)

    --
    local prePos

    layout:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            -- 移动
            local curPos = sender:getTouchMovePosition()
            if curPos.x > 0 and curPos.x < 640 * Adapter.AutoScaleX then
                local offsetX = (curPos.x - prePos.x) * -2 / 7 / Adapter.AutoScaleX
                node:setRadiansOffset(offsetX)

                prePos = curPos
                return
            end
        elseif eventType == ccui.TouchEventType.began then
            -- 开始
            prePos = sender:getTouchBeganPosition()
            return
        end

        -- 触摸闪断
        layout:setTouchEnabled(false)
        layout:setTouchEnabled(true)

        -- 对齐
        node:alignTheLayer()
    end)
end

--- ==================== 请求服务器数据相关 =======================
-- 请求总数据
function OpenContestLayer:requestGetActiveRank()
    --[[ 调试
    if DEBUG_S then
        self.mData = {
            RankType = 2,
            EndTime = 1468959790,
            RewardState = {
                -- 第1天
                {
                    RankType = 1,
                    State = 0,
                    Score = {
                        Lv = 20,
                    },
                },
                -- 第2天
                {
                    RankType = 2,
                    State = 0,
                    Score = {
                        StarCount = 180,
                    },
                },
                -- 第3天
                {
                    RankType = 3,
                    State = 1,
                    Score = {
                        HistoryMaxStep = 1,
                        HistoryMaxRank = 200,
                    },
                },
            },
        }
        --self.mButtons[self.mData.RankType]:loadTextureNormal("c_12.png")
        self:changePage(self.mData.RankType)
        return
    end--]]

    HttpClient:request({
        moduleName = "GlobalOpencontestRank",
        methodName = "GetActiveRank",
        callbackNode = self,
        callback = function(response)
            if response.Status ~= 0 then return end
            if response.Value.RankType < 0 then
                ui.showFlashView(TR("开服比拼已经关闭"))
                LayerManager.removeLayer(self)
                return
            end

            self.mData = response.Value

            local tag = self.mCurTag
            if not tag then tag = self.mData.RankType end

            if tag == 0 then tag = 1 end
            self.mTabs:activeTabBtnByTag(tag)
            --第6天的时候tab滚动到最右
            if tag > 4 then 
                self.mTabs.mScrollView:scrollToPercentHorizontal(100, 0.5, true)
            end
            if not self.mShowed and self.mEnterTransitionFinish then
                self.mShowed = true
                self:changePage(tag)
            end
        end
    })
end

-- 请求当前排行
function OpenContestLayer:requestGetRank(tag, oldTag)
    --[[ 调试
    if DEBUG_S then
        -- 移除旧分页
        if self.mPages[oldTag] ~= nil then
            self.mPages[oldTag]:removeFromParent()
            self.mPages[oldTag] = nil
        end

        self.mPagesData[tag] = {

        }
        self:addPage(tag)
        return
    end--]]

    HttpClient:request({
        moduleName = "GlobalOpencontestRank",
        methodName = "GetRank",
        svrMethodData = {tag},
        callbackNode = self,
        callback = function(response)
            if response.Status ~= 0 then return end

            -- 移除旧分页
            if self.mPages[oldTag] ~= nil then
                self.mPages[oldTag]:removeFromParent()
                self.mPages[oldTag] = nil
            end

            self.mPagesData[tag] = response.Value
            self:addPage(tag)
        end
    })
end

-- 请求奖励
function OpenContestLayer:requestDrawReward(tag)
    HttpClient:request({
        moduleName = "GlobalOpencontestRank",
        methodName = "DrawReward",
        svrMethodData = {tag},
        callbackNode = self,
        callback = function(response)
            if response.Status ~= 0 then return end

            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            -- 修正数据
            local rewardState = {}
            for k, v in ipairs(self.mData.OpencontestState) do
                if tag == v.RankType then
                    rewardState = v
                    break
                end
            end
            rewardState.State = 2

            --停止动画显示、停止动作并复原位置
            if not tolua.isnull(self.mSelfRewardNode.flashNode) then
                self.mSelfRewardNode.flashNode:removeFromParent()
                self.mSelfRewardNode.flashNode = nil
            end
            self.mSelfRewardNode:stopAllActions()
            self.mSelfRewardNode:runAction(cc.RotateTo:create(0.01, 0))
        end
    })
end


return OpenContestLayer
