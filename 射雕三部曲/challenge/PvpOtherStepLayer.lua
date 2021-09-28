--[[
    文件名：PvpOtherStepLayer.lua
    描述：竞技场阶段展示页面
    创建人：lengjiazhi
    创建时间：2017.5.18
-- ]]
local PvpOtherStepLayer = class("PvpOtherStepLayer", function(params)
	return display.newLayer()
end)

local Item = {
    width = 600,
    height = 300,
}
function PvpOtherStepLayer:ctor(params)
    self.mStep = params.step
    
    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 可滑动背景
    self.mBackgrounds = {}
    self:addBackground({"hslj_30.jpg", "hslj_29.jpg"}, 2)
    self:initUI()
    self:requestGetPVPInfo()
end

function PvpOtherStepLayer:initUI()
    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
            ResourcetypeSub.eSTA,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.ePVPCoin,
        }
    })
    self:addChild(topResource, Enums.ZOrderType.eDefault + 4)

    -- 创建退出按钮
    local backBtn = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(600 , 1040),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(backBtn, Enums.ZOrderType.eDefault + 5)
    self.mCloseBtn = backBtn

end

local MapHeroPosList = {
    [1] = cc.p(160,1610),
    [2] = cc.p(40,1360),
    [3] = cc.p(270,1100),
    [4] = cc.p(60,750),
    [5] = cc.p(270,530),
    [6] = cc.p(60,300),
    [7] = cc.p(250,0),
}
-- 显示玩家列表
function PvpOtherStepLayer:showPlayerList()
    if self.mPlayerListView then
        self.mPlayerListView:removeFromParent()
    end

    self:mergeList()

    -- 内容容器
    -- local layout = require("challenge.LieanerLayout").new()
    local layout = ccui.Layout:create()
    layout:setContentSize(640, 2000)

    local alignRight = true
    -- 添加玩家
    local count = #self.mPlayerList
    for i, playerInfo in ipairs(self.mPlayerList) do
        -- layout:addItem({node = self:createPlayerInfoLayout(
        --  playerInfo, alignRight, playerInfo.Rank <= TopCount, (count - i)*0.11
        -- )})
        if i%2 == 0 then
            alignRight = false
        else
            alignRight = true
        end
        local tempItem = self:createPlayerInfoLayout(playerInfo, alignRight, (count - i)*0.11)
        tempItem:setPosition(MapHeroPosList[i])
        layout:addChild(tempItem)
    end

    -- 滑动容器
    local size = layout:getContentSize()
    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(600, 990)
    scrollView:setInnerContainerSize(cc.size(size.width, size.height + 110))
    scrollView:setDirection(ccui.ScrollViewDir.vertical)
    scrollView:setScrollBarEnabled(false)
    scrollView:setPosition(0, 100)
    scrollView:addChild(layout)
    -- scrollView:setBounceEnabled(true)
    scrollView:getInnerContainer():setPosition(cc.p(0, 0))
    self.mParentLayer:addChild(scrollView, -1)
    self.mPlayerListView = scrollView

    self:scrollToItem(1)

    local prePosY = 0
    self.mPlayerListView:addEventListener(function(sender, eventType)
        if eventType == 9 then  --SCROLLING
            local nowPosY = self.mPlayerListView:getInnerContainer():getPositionY()

            local moveY = nowPosY - prePosY
            if moveY ~= 0 then
                self:scrollBackgrounds(moveY)
            end

            prePosY = nowPosY
        end
    end)
end

-- 显示玩家信息
function PvpOtherStepLayer:createPlayerInfoLayout(playerInfo, alignRight, delay)
    local layout = ccui.Layout:create()
    layout:setContentSize(Item.width, Item.height)

    local x = 100
    local y = 40
    -- if alignRight then x = 320 end

    -- 英雄
    y = y + 45
    Utility.performWithDelay(layout, function ()
        ui.newEffect({
            parent = layout,
            effectName = "effect_ui_fengmobang",
            position = cc.p(x, y - 10),
            loop = false,
            endRelease = true,
            completeListener = function()
                local figure
                if Utility.isEntityId(playerInfo.PlayerId) then
                    -- 可用英雄形象
                    local heroModelID
                    if playerInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                        heroModelID = PlayerAttrObj:getPlayerInfo().HeadImageId
                    else
                        heroModelID = playerInfo.HeadImageId
                    end

                    figure = Figure.newHero({
                        parent = layout,
                        heroModelID = heroModelID,
                        fashionModelID = playerInfo.FashionModelId, 
                        IllusionModelId = playerInfo.IllusionModelId,
                        position = cc.p(x, y),
                        scale = 0.175,
                        async = function(figureNode)
                            figureNode:setOpacity(0)
                            figureNode:runAction(cc.FadeTo:create(0.5, 255))
                        end,
                        needRace = false,
                        buttonAction = function ()
                            -- MqAudio.playEffect("sound_dianjikaizhan.mp3")
                            -- self:requestPVPFight(playerInfo)
                            Utility.showPlayerTeam(playerInfo.PlayerId)
                        end
                    })
                else
                    figure = ui.newButton({
                        normalImage = "c_36.png",
                        clickAction = function ()
                            -- MqAudio.playEffect("sound_dianjikaizhan.mp3")
                            -- self:requestPVPFight(playerInfo)
                        end
                    })
                    figure:setScale(0.5)
                    figure:setPosition(x, y + 110)
                    layout:addChild(figure)
                end
            end
        })
    end, delay)

    -- 文字信息
    local y = y + 85
    local node = self:createPlayerTextLayout(playerInfo)
    node:setSwallowTouches(false)
    node:setPosition(alignRight and x-285 or x+35, y)
    layout:addChild(node, 1)

    -- -- 可挑战标记
    -- local ifAllowRank = self:ifAllowRank(playerInfo)
    -- if ifAllowRank then
    --     if Utility.isEntityId(playerInfo.PlayerId) and playerInfo.Rank > self.mData.Rank then
    --         -- 对排名比自己低的玩家，可以连续战斗5次
    --         local button = ui.newButton({
    --             normalImage = "c_28.png",
    --             text = TR("战5次"),
    --             clickAudio = "sound_dianjikaizhan.mp3",
    --             anchorPoint = cc.p(0.5, 1),
    --             position = cc.p(alignRight and x-120 or x+170, y - 20),
    --             clickAction = function()
    --                 self:requestPVPConFight(playerInfo)
    --             end
    --         })
    --         layout:addChild(button, 1)
    --     end

        -- 可以挑战玩家的标识
        -- local sprite = ui.newSprite("")
        -- sprite:setPosition(alignRight and x+60 or x-55, 150)
        -- layout:addChild(sprite, 1)
    -- end

    -- 首次排名奖励
    -- local bottomRank = #PvpRankFirstRewardRelation.items[self.mData.HistoryMaxStep]  --当前阶数最低奖励名次
    -- local rank = self.mData.HistoryMaxRank
    -- if rank >= bottomRank then  --排行超过最大奖励排名
    --     rank = bottomRank
    -- end
    -- local targetRank = playerInfo.Rank
    -- if targetRank >= bottomRank then  --排行超过最大奖励排名
    --     targetRank = bottomRank
    -- end


    -- local bottomRankData = Utility.analysisStrResList(PvpRankFirstRewardRelation.items[self.mData.HistoryMaxStep][rank].firstReward)
    -- local topRankData = Utility.analysisStrResList(PvpRankFirstRewardRelation.items[self.mData.HistoryMaxStep][targetRank].firstReward)
    -- local num = topRankData[1].num - bottomRankData[1].num

    -- if num > 0 then
    --     local sprite = ui.createDaibiView({
    --         resourceTypeSub = bottomRankData[1].resourceTypeSub,
    --         number = num,
    --         fontColor = Enums.Color.eNormalWhite,
    --     })
    --     sprite:setPosition(x, 35)
    --     layout:addChild(sprite, 1)
    -- end


    return layout
end

function PvpOtherStepLayer:getRestoreData()
    return {
        step = self.mStep,
    }
end

local rankPic = {
    "hslj_23.png",
    "hslj_22.png",
    "hslj_24.png"
}

-- 显示玩家文字信息
--[[
    params:
        playerInfo:玩家的信息
        isTop:是否为前3名
]]
function PvpOtherStepLayer:createPlayerTextLayout(playerInfo)
    -- 父容器
    local layout = ui.newButton({
        normalImage = "",
        clickAction = function ()
            -- MqAudio.playEffect("sound_dianjikaizhan.mp3")
            -- self:requestPVPFight(playerInfo)
        end,
        size = cc.size(260, 92),
        anchorPoint = cc.p(0, 0),
    })

    -- 是否是自己
    local isSelf = playerInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")

    -- 背景
    local sprite = ui.newScale9Sprite(isSelf and "hslj_04.png" or "hslj_05.png", cc.size(210, 89))
    sprite:setAnchorPoint(1, 0.5)
    sprite:setPosition(260, 30)
    layout:addChild(sprite)

    -- 排名
    if playerInfo.Rank <= 3 then
        local rankLabel = ui.newSprite(rankPic[playerInfo.Rank])
        rankLabel:setPosition(160, 55)
        layout:addChild(rankLabel)
    else
        local rankLabel = ui.newLabel({
            text = TR("排行: %d", playerInfo.Rank),
            color = (isSelf and cc.c3b(0x4b, 0x16, 0x30) or cc.c3b(0xd3, 0xdd, 0xe4)),
            size = 20,
            anchorPoint = cc.p(0.5, 0.5),
            x = 160,
            y = 55,
        })
        layout:addChild(rankLabel)
    end

    if Utility.isEntityId(playerInfo.PlayerId) then
        -- 名望称号
        local titleNode = ui.createTitleNode(playerInfo.TitleId)
        if (titleNode ~= nil) then
            titleNode:setPosition(155, ((playerInfo.Rank <= 3) and 100 or 90))
            layout:addChild(titleNode)
        end

        -- 姓名等级
        local label = ui.newLabel({
            text = TR("等级%s:%s", playerInfo.Lv, playerInfo.Name),
            color = (isSelf and cc.c3b(0xff, 0xe6, 0x94) or cc.c3b(0xd3, 0xdd, 0xe4)),
            anchorPoint = cc.p(0.5, 0.5),
            size = 20,
            x = 160,
            y = 25,
        })
        layout:addChild(label)

        -- 战力
        local label = ui.newLabel({
            text = TR("{%s}%s","c_127.png", Utility.numberFapWithUnit(playerInfo.FAP)),
            color = (isSelf and cc.c3b(0xff, 0xe6, 0x94) or cc.c3b(0xd3, 0xdd, 0xe4)),
            anchorPoint = cc.p(0.5, 0.5),
            size = 23,
            x = 150,
            y = 0,
        })
        label:setScale(0.8)
        layout:addChild(label)
    else
        -- 空位
        local label = ui.newLabel({
            text = TR("虚位以待"),
            color = cc.c3b(0xd3, 0xdd, 0xe4),
            size = 22,
            anchorPoint = cc.p(0.5, 0.5),
            x = 155,
            y = 15,
        })
        layout:addChild(label)
    end

    return layout
end

-- 整合列表
function PvpOtherStepLayer:mergeList()
    self.mPlayerList = {}
    for i = 1, 7 do
        self.mPlayerList[i] = self.mData[i]
    end
end

--- ===================== 操作相关 ========================
--
function PvpOtherStepLayer:scrollToItem(index)
    if not self.mPlayerListView then return end

    --
    local viewLength = self.mPlayerListView:getContentSize().height
    local totalLength = self.mPlayerListView:getInnerContainerSize().height
    local bottomLength = viewLength / 2
    local topLength = totalLength - bottomLength

    -- 计算位置
    local count = #self.mPlayerList - index + 0.7
    local length = Item.height * count
    if length < bottomLength then length = bottomLength end
    if length > topLength then length = topLength end

    -- 滑动英雄列表
    local percent = 100 - 100 * (length - bottomLength) / (totalLength - viewLength)
    self.mPlayerListView:scrollToPercentVertical(percent, 1.5 ,true)
end
--- ===================== 背景相关 ========================
local ViewHeight = 1136
function PvpOtherStepLayer:addBackground(imgList, factor)
	-- 创建背景
	local layout = require("challenge.LieanerLayout").new()
	layout:setAnchorPoint(0.5, 0)
	layout:setPosition(320, 0)

	for i, imgName in ipairs(imgList) do
		layout:addItem({node = ui.newSprite(imgName)})
	end

	-- 添加辅助变量
	layout.factor = factor
	self:caculateVariable(layout)

	-- 保存
	self.mParentLayer:addChild(layout, Enums.ZOrderType.eDefault - 2)
	table.insert(self.mBackgrounds, layout)
end

function PvpOtherStepLayer:caculateVariable(layout)
    local x, y = layout:getPosition()
    -- 计算辅助变量
    layout.bottom = y
    layout.top = y + layout.mVariableLength
    local configs = layout:getItems()
    local count = #configs
    layout.uponBottom = layout.bottom -- 暂定
    layout.underTop = layout.top -- 暂定
end

-- 滑动所有背景
function PvpOtherStepLayer:scrollBackgrounds(offset)
    for i, layout in ipairs(self.mBackgrounds) do
        self:scrollBackground(layout, offset / layout.factor * 2)
    end
end

-- 滑动某个背景组
function PvpOtherStepLayer:scrollBackground(layout, offset)
    local x, y = layout:getPosition()
    y = y + offset
    layout:setPosition(x, y)

    -- 辅助变量修正
    layout.bottom = layout.bottom + offset
    layout.top = layout.top + offset
    layout.uponBottom = layout.uponBottom + offset
    layout.underTop = layout.underTop + offset

    -- 判断是否循环
    local configs = layout:getItems()
    local count = #configs
    local fixY = 0
    if offset > 0 then
        -- 上滑
        if layout.uponBottom > 0 or layout.bottom > 0 then
            fixY = -configs[1].node:getContentSize().height
            layout:moveItem(1, count)
        end
    else
        -- 下滑
        if layout.underTop < ViewHeight or layout.top < ViewHeight then
            fixY = configs[count].node:getContentSize().height
            layout:moveItem(1, count)
        end
    end

    y = y + fixY
    layout:setPosition(x, y)
    self:caculateVariable(layout)
end

--- ===================== 请求服务器 ========================
-- PVP信息
function PvpOtherStepLayer:requestGetPVPInfo()
    HttpClient:request({
        moduleName = "PVP",
        methodName = "GetPVPStepInfo",
        svrMethodData = {self.mStep},
        callback = function(response)
            if response.Status ~= 0 then 
                return 
            end
            self.mData = response.Value
            -- self.mBaseGetGameResourceList = response.Value.BaseGetGameResourceList
            self:showPlayerList()
        end
    })
end


return PvpOtherStepLayer