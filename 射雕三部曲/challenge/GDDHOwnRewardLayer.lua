--[[
	文件名：GDDHOwnRewardLayer.lua
	描述：武林大会排行排名奖励页面
	创建人：liucunxin
	创建时间：2016.1.3
--]]

local GDDHOwnRewardLayer = class("GDDHOwnRewardLayer", function()
    return display.newLayer()
end)

-- 个人奖励类型
local SelfReward = {
    eSeasonReward = 1,              -- 三日大奖
    eDaliyReward = 2,               -- 每日奖励
    eMondayReward = 3,              -- 周一奖励
}

-- 构造函数
--[[
	params:
		seasonRewardList 	 	-- 赛季大奖
		dailyRewardList 		-- 每日奖励
        rank                    -- 当前排名
--]]
function GDDHOwnRewardLayer:ctor(params)
	self.mSeasonRewardList = params and params.seasonRewardList
	self.mDailyRewardList = params and params.dailyRewardList

    -- 初始化数据
    if params.rank ~= nil then
        self.mRank = params.rank
        if self.mRank == 1000000 or self.mRank == 0 then
            self.mRank = TR("无排名")
        end
    end

	self:initUI()

	-------测试按钮-------
	-- local testBtn = ui.newButton({
	-- 	normalImage = "c_82.png",
	-- 	clickAction = function ()
	-- 		--dump(self.mRewardListView, "before")
	-- 		self.mRewardListView:removeAllItems()
	-- 		--dump(self.mRewardListView, "after")
	-- 		-- self:removeChild(self.mRewardListView)
	-- 	end
	-- 	})
	-- testBtn:setPosition(cc.p(50, 900))
	-- self:addChild(testBtn)
	---------------------
end

function GDDHOwnRewardLayer:initUI()
	self:showRankRewardTab()
end

-- 创建个人奖励奖励页面
function GDDHOwnRewardLayer:showRankRewardTab()
    -- 创建标题栏背景
    local bgSpr = ui.newScale9Sprite("c_25.png", cc.size(600, 50))
    bgSpr:setAnchorPoint(cc.p(0.5, 0.5))
    bgSpr:setPosition(cc.p(320, 935))
    self:addChild(bgSpr)

    -- 创建标题栏中label
    local tempSize = bgSpr:getContentSize()
    self.mRewardExplainLabel = ui.newLabel({
        text = TR("当前豪侠令：{%s}%s%s        %s当前排名：%s%s",
            Utility.getDaibiImage(ResourcetypeSub.eGDDHCoin),
            Enums.Color.eYellowH,
            PlayerAttrObj:getPlayerAttrByName("GDDHCoin"),
            Enums.Color.eNormalWhiteH,
            Enums.Color.eYellowH,
            self.mRank),
        size = 24,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        color = Enums.Color.eNormalWhite,
    })
    self.mRewardExplainLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.mRewardExplainLabel:setPosition(cc.p(tempSize.width * 0.5, tempSize.height * 0.5))
    bgSpr:addChild(self.mRewardExplainLabel)
    -- 按钮信息
    local btnInfoList = {
    {
        text = TR("赛季大奖"),
        fontSize = 22,
        titlePosRateY = 0.5,
        tag = 1
    },
    {
        text = TR("每日奖励"),
        titlePosRateY = 0.5,
        fontSize = 22,
        tag = 2
    },
    -- {
    --     text = "周一奖励",
    --     tag = 3
    -- }
    }
    -- 创建tab
    local rewardTab = ui.newTabLayer({
        btnInfos = btnInfoList,
        space = 100,
        btnSize = cc.size(160,61),
        isVert = false,
        needLine = false,
        normalImage = "c_169.png",
        lightedImage = "c_169.png",

        defaultSelectTag = SelfReward.eSeasonReward,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            if self.mRewardListView then
                self:refreshRewardListView(selectBtnTag)
            end
        end
    })
    rewardTab:setAnchorPoint(cc.p(0.5, 0))
    rewardTab:setPosition(cc.p(430, 830))
    self:addChild(rewardTab)

    --灰色背景
    local underBgSprite = ui.newScale9Sprite("c_17.png", cc.size(606, 715))
    underBgSprite:setAnchorPoint(0.5, 1)
    underBgSprite:setPosition(320, 830)
    self:addChild(underBgSprite)

    -- 创建奖励页面listview
    self.mRewardListView = ccui.ListView:create()
    self.mRewardListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mRewardListView:setBounceEnabled(true)
    self.mRewardListView:setContentSize(cc.size(598, 700))
    self.mRewardListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mRewardListView:setItemsMargin(3)
    self.mRewardListView:setAnchorPoint(cc.p(0.5, 1))
    self.mRewardListView:setPosition(325, 825)
    self:addChild(self.mRewardListView)
	self:refreshRewardListView(SelfReward.eSeasonReward)
end

-- 刷新个人奖励listview
--[[
    params:
        rewardsType                     -- 奖励类型
--]]
function GDDHOwnRewardLayer:refreshRewardListView(rewardType)
    self.mRewardListView:removeAllItems()
    if rewardType == SelfReward.eSeasonReward then
        for _, v in ipairs(self.mSeasonRewardList) do
            self.mRewardListView:pushBackCustomItem(self:createSeasonRewardCell(v))
        end
    elseif rewardType == SelfReward.eDaliyReward then
        for _, v in ipairs(self.mDailyRewardList) do
            self.mRewardListView:pushBackCustomItem(self:createDaliyRawardCell(v))
        end
    end
end

-- 创建三日大奖cell
--[[
    params:
        reawrdInfo                      -- 奖励信息
--]]
function GDDHOwnRewardLayer:createSeasonRewardCell(rewardInfo)
    -- 创建cell
    local width, height = 590, 126
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(width, height))

    --背景条
    local bgPic, rankPic = "c_18.png", nil 
    if rewardInfo.rankMax == 1 then
        rankPic = "c_44.png"
    elseif rewardInfo.rankMax == 2 then
        rankPic = "c_45.png"
    elseif rewardInfo.rankMax == 3 then
        rankPic = "c_46.png"
    end

    local cellBg = ui.newScale9Sprite(bgPic, cc.size(width, height))
    cellBg:setPosition(width * 0.5, height* 0.5)
    customCell:addChild(cellBg)
    local tempSize = cellBg:getContentSize()

    -- 排名
    if rankPic then
        local rankSpr = ui.newSprite(rankPic)
        rankSpr:setPosition(tempSize.width * 0.13, tempSize.height * 0.5)
        cellBg:addChild(rankSpr)
    else
        if rewardInfo.rankMin == rewardInfo.rankMax then
            local rankLabel = ui.newLabel({
                text = TR(rewardInfo.rankMin),
                color = cc.c3b(0x46, 0x22, 0x0d),
                x = tempSize.width * 0.13,
                y = tempSize.height * 0.5,
                size = 26,
                align = ui.TEXT_ALIGN_CENTER
            })
            cellBg:addChild(rankLabel)
        else
             local rankLabel = ui.newLabel({
                text = TR("%s ~ %s", rewardInfo.rankMin, rewardInfo.rankMax),
                color = cc.c3b(0x46, 0x22, 0x0d),
                x = tempSize.width * 0.13,
                y = tempSize.height * 0.5,
                size = 26,
                align = ui.TEXT_ALIGN_CENTER
            })
            cellBg:addChild(rankLabel)
        end
    end

    -- 奖励图例
    for i,v in ipairs(rewardInfo.seasonReward) do
        -- 资源头像
        local rewardPic = CardNode.createCardNode({
            resourceTypeSub = v.resourceTypeSub,         -- 资源类型
            modelId = v.modelId,                        -- 模型Id
            num = v.num,                                 -- 资源数量
            cardShowAttrs = {
                CardShowAttr.eBorder
            }
        })
        rewardPic:setAnchorPoint(cc.p(0, 0.5))
        rewardPic:setPosition(cc.p(150 + 220 * (i - 1), 65))
        customCell:addChild(rewardPic)

        -- 资源名字
        local nameFont = ui.newLabel({
            text = TR("#d17b00%s",Utility.getGoodsName(v.resourceTypeSub, v.modelId)),
            color = cc.c3b(0x46, 0x22, 0x0d),
            })
        nameFont:setAnchorPoint(cc.p(0, 0))
        nameFont:setPosition(cc.p(260 + 220 * (i - 1), 80))
        customCell:addChild(nameFont)
        -- 资源数量
        local nameNum = ui.newLabel({
            text = TR("数量:%s%s",Enums.Color.eDarkGreenH, v.num),
            color = cc.c3b(0x46, 0x22, 0x0d),
            })
        nameNum:setAnchorPoint(cc.p(0, 1))
        nameNum:setPosition(cc.p(260 + 220 * (i - 1), 70))
        customCell:addChild(nameNum)
    end

    return customCell
end

-- 创建每日奖励cell
--[[
    params:
        reawrdInfo                      -- 奖励信息
--]]
function GDDHOwnRewardLayer:createDaliyRawardCell(rewardInfo)
    -- 创建cell
    local width, height = 590, 126
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(width, height))

    --背景条
    local bgPic, rankPic = "c_18.png", nil 
    if rewardInfo.rankMax == 1 then
        rankPic = "c_44.png"
    elseif rewardInfo.rankMax == 2 then
        rankPic = "c_45.png"
    elseif rewardInfo.rankMax == 3 then
        rankPic = "c_46.png"
    end

    local cellBg = ui.newScale9Sprite(bgPic, cc.size(width, height))
    cellBg:setPosition(width * 0.5, height* 0.5)
    customCell:addChild(cellBg)
    local tempSize = cellBg:getContentSize()

    -- 排名
    if rankPic then
        local rankSpr = ui.newSprite(rankPic)
        rankSpr:setPosition(tempSize.width * 0.13, tempSize.height * 0.5)
        cellBg:addChild(rankSpr)
    else
        if rewardInfo.rankMin == rewardInfo.rankMax then
            local rankLabel = ui.newLabel({
                text = TR(rewardInfo.rankMin),
                color = Enums.Color.eYellow,
                x = tempSize.width * 0.13,
                y = tempSize.height * 0.5,
                size = 24,
                align = ui.TEXT_ALIGN_CENTER
            })
            cellBg:addChild(rankLabel)
        else
             local rankLabel = ui.newLabel({
                text = TR("%s ~ %s", rewardInfo.rankMin, rewardInfo.rankMax),
                color = Enums.Color.eBlack,
                x = tempSize.width * 0.15,
                y = tempSize.height * 0.5,
                size = 26,
                align = ui.TEXT_ALIGN_CENTER
            })
            cellBg:addChild(rankLabel)
        end
    end

    -- 奖励图例
    -- 资源头像
    local header = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eGold, -- 资源类型
        num = rewardInfo.dailyReward * PlayerAttrObj:getPlayerAttrByName("Lv"), -- 资源数量
        cardShowAttrs = {
             CardShowAttr.eBorder
            }
        })
    header:setAnchorPoint(cc.p(0.5, 0.5))
    header:setPosition(cc.p(tempSize.width * 0.4, 65))
    customCell:addChild(header)

    -- 资源名字
    local nameFont = ui.newLabel({
        text = TR("%s",Utility.getGoodsName(ResourcetypeSub.eGold)),
        color = Enums.Color.eBlack
        })
    nameFont:setAnchorPoint(cc.p(0, 0))
    nameFont:setPosition(cc.p(tempSize.width * 0.42 + 50, 75))
    customCell:addChild(nameFont)
    -- 资源数量
    local numCoin = rewardInfo.dailyReward * PlayerAttrObj:getPlayerAttrByName("Lv")
    local nameNum = ui.newLabel({
        text = TR("数量：%s%s",Enums.Color.eDarkGreenH, Utility.numberWithUnit(numCoin)),
        color = Enums.Color.eBlack
        })
    nameNum:setAnchorPoint(cc.p(0, 1))
    nameNum:setPosition(cc.p(tempSize.width * 0.42 + 50, 65))
    customCell:addChild(nameNum)
    return customCell
end

-- 创建周一奖励
--[[
    params:
        reawrdInfo                      -- 奖励信息
--]]
-- function GDDHOwnRewardLayer:createMondayRewardCell(rewardInfo)
--    self.mRewardExplainLabel:setString(TR("每周一%s%s; %s%s%s发放一次奖励，积分将重置", 
--         Enums.Color.eGreenH, 
--         "23", 
--         Enums.Color.eGreenH, 
--         "00", 
--         Enums.Color.eWhiteH)
--     )

--     -- 创建cell
--     local width, height = 630, 112
--     local customCell = ccui.Layout:create()
--     customCell:setContentSize(cc.size(width, height))

--     --背景条
--     local bgPic, rankPic = nil, nil 
--     if rewardInfo.rankMax == 1 then
--         bgPic = "c_16.png"
--         rankPic = "c_75.png"
--     elseif rewardInfo.rankMax == 2 then
--         bgPic = "c_16.png"
--         rankPic = "c_76.png"
--     elseif rewardInfo.rankMax == 3 then
--         bgPic = "c_16.png"
--         rankPic = "c_77.png"
--     else
--         bgPic = "c_16.png"
--     end

--     local cellBg = ui.newScale9Sprite(bgPic, cc.size(width, height))
--     cellBg:setPosition(width * 0.5 - 5, height* 0.5)
--     customCell:addChild(cellBg)
--     local tempSize = cellBg:getContentSize()

--     -- 排名
--     if rankPic then
--         local rankSpr = ui.newSprite(rankPic)
--         rankSpr:setPosition(tempSize.width * 0.13, tempSize.height * 0.5)
--         cellBg:addChild(rankSpr)
--     else
--         if rewardInfo.rankMin == rewardInfo.rankMax then
--             local rankLabel = ui.newLabel({
--                 text = TR(rewardInfo.rankMin),
--                 color = Enums.Color.eYellow,
--                 x = tempSize.width * 0.13,
--                 y = tempSize.height * 0.5,
--                 size = 24,
--                 align = ui.TEXT_ALIGN_CENTER
--             })
--             cellBg:addChild(rankLabel)
--         else
--              local rankLabel = ui.newLabel({
--                 text = TR("%s ~ %s", rewardInfo.rankMin, rewardInfo.rankMax),
--                 color = Enums.Color.eNormalBlue,
--                 x = tempSize.width * 0.13,
--                 y = tempSize.height * 0.5,
--                 size = 24,
--                 align = ui.TEXT_ALIGN_CENTER
--             })
--             cellBg:addChild(rankLabel)
--         end
--     end

--     return customCell
-- end



return GDDHOwnRewardLayer