--[[
    文件名：ShengyuanWarsChestRewardLayer.lua
    描述：决战桃花岛宝箱页面
    创建人：chenzhogn
    创建时间：2017.9.2
-- ]]

local ShengyuanWarsChestRewardLayer = class("ShengyuanWarsChestRewardLayer", function(params)
    return display.newLayer(cc.c4b(10, 10, 10, 170))
end)

-- 构造函数
--[[
    params:
    {
        winNum              -- 当前获胜场数
        todayNum            -- 今天参与次数
        chestType           -- 宝箱类型
        drawStr             -- 可领取字符串
        callback            -- 领取之后的回调
    }
--]]
function ShengyuanWarsChestRewardLayer:ctor(params)
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    self.mWinNum = params.winNum
    self.mTodayNum = params.todayNum
    self.mType = params.chestType
    self.mDrawList = string.splitBySep(params.drawStr, ",")
    self.mCallback = params.callback

    -- 表数据处理
    self:dealData()

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化UI
    self:initUI()
end

-- 处理表数据
function ShengyuanWarsChestRewardLayer:dealData()
    local tempList = nil
    if self.mType == Enums.ShengyuanWarsChestType.ePersonal then
        tempList = ShengyuanwarsWinboxPersonRelation.items
    else
        tempList = ShengyuanwarsWinboxGuildRelation.items
    end

    -- 奖励列表
    self.mRewardList = {}
    for k, v in pairs(tempList) do
        table.insert(self.mRewardList, v)
    end
    table.sort(self.mRewardList, function(a, b)
        return a.winNum < b.winNum
    end)
end

-- 初始化UI
function ShengyuanWarsChestRewardLayer:initUI()
    -- 背景
    local bgSprite = ui.newScale9Sprite("c_30.png", cc.size(574, 813))
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    self.mBgSprite = bgSprite
    self.mBgSize = bgSprite:getContentSize()

    -- 标题
    local titleLabel = ui.newLabel({
        text = TR("每日宝箱奖励"),
        size = Enums.Fontsize.eTitleDefault,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x6b, 0x48, 0x28),
        outlineSize = 2,
        x = self.mBgSize.width * 0.5,
        y = self.mBgSize.height - 38,
    })
    bgSprite:addChild(titleLabel)

    -- 关闭按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(self.mBgSize.width - 30, self.mBgSize.height - 25),
        clickAction = function(btnObj)
            LayerManager.removeLayer(self)
        end
    })
    bgSprite:addChild(closeBtn)

    -- 背景条
    local lineBg = ui.newScale9Sprite("c_25.png", cc.size(542, 54))
    lineBg:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 90)
    bgSprite:addChild(lineBg)
    local lineSize = lineBg:getContentSize()

    -- 感叹号标识
    local flagSprite = ui.newSprite("c_63.png")
    flagSprite:setPosition(lineSize.width * 0.1, lineSize.height * 0.5)
    lineBg:addChild(flagSprite)

    -- 今日已获胜xx场
    local winLabel = ui.newLabel({
        text = TR("今日已获胜%s%s场，%s已参与%s%s场", Enums.Color.eGreenH, self.mWinNum or 0,
        "#46220d", Enums.Color.eGreenH, self.mTodayNum or 0),
        color = cc.c3b(0x46, 0x22, 0x0d),
        anchorPoint = cc.p(0, 0.5),
        x = lineSize.width * 0.13,
        y = lineSize.height * 0.5
    })
    lineBg:addChild(winLabel)

    -- 家族组队
    if self.mType == Enums.ShengyuanWarsChestType.eGuild then
        local tipLabel = ui.newLabel({
            text = TR("仅限帮派组队"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5),
            x = lineSize.width * 0.65,
            y = lineSize.height * 0.5
        })
        lineBg:addChild(tipLabel)
    end

    local listBg = ui.newScale9Sprite("c_17.png", cc.size(521, self.mBgSize.height - 150))
    listBg:setAnchorPoint(cc.p(0.5, 0))
    listBg:setPosition(self.mBgSize.width * 0.5, 30)
    bgSprite:addChild(listBg)

    -- 添加listview
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(521, self.mBgSize.height - 165))
    listView:setItemsMargin(5)
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setAnchorPoint(cc.p(0.5, 0))
    listView:setPosition(self.mBgSize.width * 0.5, 35)
    bgSprite:addChild(listView)
    self.mListView = listView

    -- listview刷新函数
    listView.refresh = function(lv)
        lv:removeAllItems()

        for i, v in ipairs(self.mRewardList) do    
            local width, height = lv:getContentSize().width, 163
            local customCell = ccui.Layout:create()
            customCell:setContentSize(cc.size(width, height))

            -- cell背景框
            local cellBg = ui.newScale9Sprite("c_18.png", cc.size(511, 163))
            cellBg:setPosition(width * 0.5, height * 0.5)
            customCell:addChild(cellBg)
            local cellBgSize = cellBg:getContentSize()

            -- 描述标签
            local descLabel = ui.newLabel({
                text = TR("今日获胜%s场或参与%s场，可获以下奖励", v.winNum, v.partNum),
                size = 20,
                color = cc.c3b(0x46, 0x28, 0x0d),
                anchorPoint = cc.p(0, 0.5),
                x = cellBgSize.width * 0.05,
                y = cellBgSize.height * 0.85
            })
            cellBg:addChild(descLabel)

            -- 奖励列表
            local goodsList = Utility.analysisStrResList(v.rewards)
            for _, item in ipairs(goodsList) do
                item.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum, CardShowAttr.eDebris}
            end
            local goodsNode = ui.createCardList({
                maxViewWidth = 380,
                -- space = 5,
                cardDataList = goodsList,
            })
            goodsNode:setAnchorPoint(cc.p(0, 0.5))
            goodsNode:setPosition(15, cellBgSize.height * 0.4)
            cellBg:addChild(goodsNode)
            goodsNode:setScale(0.9)

            -- 领取按钮
            local getBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("领取"),
                position = cc.p(cellBgSize.width * 0.83, cellBgSize.height * 0.5),
                scale = 0.85,
                clickAction = function(btnObj)
                    self:requestDrawChallengeReward(v.winNum)
                end
            })
            cellBg:addChild(getBtn)

            -- 是否可以领取
            local canDraw = false
            for _, numStr in ipairs(self.mDrawList) do
                if tonumber(numStr) == v.winNum then
                    canDraw = true
                    break
                end
            end
            getBtn:setEnabled(canDraw)

            -- 已领取状态
            if not canDraw and (self.mWinNum >= v.winNum or self.mTodayNum >= v.partNum) then
                getBtn:setTitleText(TR("已领取"))
            end

            lv:pushBackCustomItem(customCell)
        end
    end
    listView:refresh()
end

-----------------------网络相关-----------------------
-- 请求服务器，领取宝箱奖励
function ShengyuanWarsChestRewardLayer:requestDrawChallengeReward(winNum)
    HttpClient:request({
        moduleName = "Shengyuan",
        methodName = "DrawChallengeReward",
        svrMethodData = {winNum, self.mType},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return 
            end

            -- 更新数据
            if self.mType == Enums.ShengyuanWarsChestType.ePersonal then
                self.mDrawList = string.splitBySep(data.Value.SingleRewardState, ",")
                
                -- 更新父页面数据
                if self.mCallback then
                    self.mCallback(data.Value.SingleRewardState)
                end
            else
                self.mDrawList = string.splitBySep(data.Value.TeamRewardState, ",")

                -- 更新父页面数据
                if self.mCallback then
                    self.mCallback(data.Value.TeamRewardState)
                end
            end

            -- 刷新listview
            self.mListView:refresh()

            -- 奖品
            ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        end
    })
end

return ShengyuanWarsChestRewardLayer