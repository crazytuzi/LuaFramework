--[[
    文件名：ShengyuanWarsRankLayer.lua
    描述：赛马排行榜
    创建人：wukun
    创建时间：2017.05.22
--]]

local ShengyuanWarsRankLayer = class("ShengyuanWarsRankLayer", function(params)
    return display.newLayer(cc.c4b(10, 10, 10, 170))
end)

-- 页面类型
local PageType = {
    eFamily = 0, -- 家族排行
    ePersonal = 1, -- 个人排行
    eReward = 2 ,-- 家族奖励
    eSingeReward = 3 -- 个人奖励
}

-- 赛季类型
local SeasonType = {
    eNow = 0, -- 当前赛季
    eOld = 1, -- 上个赛季
}

function ShengyuanWarsRankLayer:ctor(params)
    -- 页面恢复相关数据
    local params = params or {}
    self.mSeasonType = SeasonType.eNow -- 赛季(默认当前赛季)

    -- 分页页数标签
    self.mCurrPage = 1
    self.mIsRequesting = false

    -- 初始化UI
    self:initUI()
end

-- 添加UI相关
function ShengyuanWarsRankLayer:initUI()
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    local bgSprite = ui.newScale9Sprite("c_30.png", cc.size(574, 861))
    bgSprite:setPosition(320, 580)
    self.mParentLayer:addChild(bgSprite)
    self.mBgSize = bgSprite:getContentSize()

    -- 标题
    local titleLabel = ui.newLabel({
        text = TR("排行榜"),
        size = Enums.Fontsize.eTitleDefault,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x6b, 0x48, 0x28),
        outlineSize = 2,
        x = self.mBgSize.width * 0.5,
        y = self.mBgSize.height - 38,
    })
    bgSprite:addChild(titleLabel)

    local tiao = ui.newScale9Sprite("c_17.png", cc.size(520, 710))
    tiao:setAnchorPoint(0.5, 1)
    tiao:setPosition(320, 880)
    self.mParentLayer:addChild(tiao)

    -- 存放分页内容的容器layer
    self.mChildLayer = display.newLayer()
    self.mChildLayer:setContentSize(640, 1136)
    self.mParentLayer:addChild(self.mChildLayer)

    -- 创建分页控件
    self:addTabView()

    -- 显示关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(self.mBgSize.width - 30, self.mBgSize.height - 25)
    bgSprite:addChild(self.mCloseBtn)
end

-- 创建分页控件，家族排行、个人排行、家族奖励
function ShengyuanWarsRankLayer:addTabView()
    local buttonInfos = {
        {
            text = TR("帮派排行"),
            fontSize = 24,
            tag = PageType.eFamily
        },
        {
            text = TR("个人排行"),
            fontSize = 24,
            tag = PageType.ePersonal
        },
        {
            text = TR("帮派奖励"),
            fontSize = 24,
            tag = PageType.eReward
        },
        {
            text = TR("个人奖励"),
            fontSize = 24,
            tag = PageType.eSingeReward
        }
    }

    -- 创建分页
    self.mTabView = ui.newTabLayer({
        btnInfos = buttonInfos,
        space = 10,
        needLine = false,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            -- 页签切换时才清空数据，初始化有缓存的情况则不清空
            if self.mPageType == selectBtnTag then
                return
            end
            self.mPageType = selectBtnTag
            -- 分页页数
            self.mCurrPage = 1
            self.mTotalPage = 0
            self.mIsRequest = false
            self:refreshLayer()
        end
    })
    self.mTabView:setAnchorPoint(cc.p(0.5, 1))
    self.mTabView:setPosition(375, 950)
    self.mParentLayer:addChild(self.mTabView, 1)
end

-- 切换标签
function ShengyuanWarsRankLayer:refreshLayer()
    -- 清除页面的数据
    self.mChildLayer:removeAllChildren()
    self.mNoMoreCell = nil

    -- 创建listview
    local ListViewSize = cc.size(600, 630)
    if self.mPageType == PageType.eReward or self.mPageType == PageType.eSingeReward then
        ListViewSize = cc.size(600, 700)
    end    
    if self.mPageType == PageType.eFamily then
        ListViewSize = cc.size(600, 560)
        local tipLabel = ui.newLabel({
            text = TR("每周一发放帮派排行奖励\n只有个人积分大于300的玩家才能获得奖励"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
        })
        tipLabel:setPosition(320, 840)
        self.mChildLayer:addChild(tipLabel)
    end 
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setContentSize(ListViewSize)
    listView:setSwallowTouches(true)
    listView:setAnchorPoint(cc.p(0.5, 1))
    listView:setPosition(320, self.mPageType == PageType.eFamily and 805 or 875)
    listView:setBounceEnabled(true)
    self.mChildLayer:addChild(listView)
    self.mListView = listView

    if self.mPageType == PageType.eFamily  then -- 家族排行
        self:getGuildTotalData()
    end 

    if self.mPageType == PageType.ePersonal then -- 个人排行
        self:requestGetPersonalRankTotalPage()
    end 

    if self.mPageType == PageType.eReward then  -- 帮派奖励页签
        local info = {}
        for k, v in pairs(ShengyuanwarsRankGuildRelation.items) do
            for i, j in pairs(v) do
                table.insert(info, j)
            end
        end
        table.sort(info, function (a,b)
            return a.rankMin < b.rankMin
        end)

        for index = 1, #info do
            self.mListView:pushBackCustomItem(self:addRewardItem(index, info[index]))
        end
    end

    if self.mPageType == PageType.eSingeReward then  -- 帮派奖励页签
        local info = {}
        for k, v in pairs(ShengyuanwarsRankPersonRelation.items) do
            for i, j in pairs(v) do
                table.insert(info, j)
            end
        end
        table.sort(info, function (a,b)
            return a.rankMin < b.rankMin
        end)

        for index = 1, #info do
            self.mListView:pushBackCustomItem(self:addRewardItem(index, info[index]))
        end
    end

    --添加listView监听
    self.mListView:addScrollViewEventListener(function(sender, eventType)
        if eventType == 6 then -- 触发底部弹性事件(BOUNCE__BOTTOM)
            if self.mPageType == PageType.eReward or self.mPageType == PageType.eSingeReward then -- 家族奖励页签
                return
            end

            if self.mCurrPage > self.mTotalPage and self.mTotalPage > 0 then
                if self.mNoMoreCell ~= nil then
                    return
                else
                    self.mNoMoreCell = self:createNoMoreCell()
                    self.mListView:pushBackCustomItem(self.mNoMoreCell)
                end
            else
                if self.mIsRequest == false then 
                    if self.mPageType == PageType.eFamily  then          -- 家族排行
                        self:getGuildTotalData()
                    elseif self.mPageType == PageType.ePersonal then     -- 个人排行
                        self:requestGetPersonalRankTotalPage()
                    end
                end     
            end
        end
    end)
end

-- 添加家族排行条目
function ShengyuanWarsRankLayer:addFamilyitem(index, data)
    local cellInfo = data
    local GuildName = cellInfo.GuildName or ""    -- 家族名
    local Zone =  cellInfo.Zone or ""    -- string.sub(cellInfo.Zone, -8)区服
    local FightScore = cellInfo.FightScore or 555    -- 积分
    local Rank = cellInfo.Rank or 0  -- 排名

    local sellSize = cc.size(600, 120)
    local item = ccui.Layout:create()
    item:setContentSize(sellSize)

    -- 底板
    local bgImage = ui.newScale9Sprite("c_18.png", cc.size(500, 120))
    bgImage:setPosition(sellSize.width / 2, sellSize.height / 2)
    item:addChild(bgImage)
    local bgSize = bgImage:getContentSize()

    -- 排名
    local imageData = {
        [1] = {image = "c_44.png"},
        [2] = {image = "c_45.png"},
        [3] = {image = "c_46.png"},
    }
    if imageData[Rank] then
        local rankSprite = ui.newSprite(imageData[Rank].image)
        rankSprite:setPosition(cc.p(55, bgSize.height / 2))
        bgImage:addChild(rankSprite)
    else
        local rankNumLabel = ui.createSpriteAndLabel({
            imgName = "c_47.png",
            labelStr = string.format("%s", Rank),
            fontColor = Enums.Color.eNormalWhite,
            fontSize = 40
        })
        rankNumLabel:setPosition(cc.p(55, bgSize.height / 2))
        bgImage:addChild(rankNumLabel)
    end

    -- 帮派名
    local familyNameLabel = ui.newLabel({
        text = TR("帮派: %s", GuildName),
        size = 24,
        anchorPoint = cc.p(0, 0.5),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    familyNameLabel:setPosition(135, bgSize.height/2 + 25)
    bgImage:addChild(familyNameLabel)

    -- 区服
    local serverNameLabel = ui.newLabel({
        text = TR("区服: #44AC06%s", Zone),
        size = 24,
        anchorPoint = cc.p(0, 0.5),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    serverNameLabel:setPosition(135, bgSize.height/2 - 20)
    bgImage:addChild(serverNameLabel)

    -- 积分
    local scorelabel = ui.newLabel({
        text = TR("积分: #44AC06%s", FightScore),
        size = 24,
        anchorPoint = cc.p(0, 0.5),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    scorelabel:setPosition(bgSize.width/2 + 80, bgSize.height/2 - 20)
    bgImage:addChild(scorelabel)

    return item
end

-- 添加个人排行条目
function ShengyuanWarsRankLayer:addPersonalItem(index, data)
    local cellInfo = data
    local Rank = cellInfo.Rank or 0   -- 排名
    local PlayerId = cellInfo.PlayerId or PlayerAttrObj:getPlayerAttrByName("PlayerId")    -- 玩家ID
    local PlayerName = cellInfo.PlayerName or ""    -- 玩家名称
    local HeadImageId = cellInfo.HeadImageId or PlayerAttrObj:getPlayerAttrByName("HeadImageId")    -- 玩家头像Id
    local FashionModelId = cellInfo.FashionModelId or PlayerAttrObj:getPlayerAttrByName("FashionModelId")    -- 时装模型Id
    local DesignationId = cellInfo.DesignationId or PlayerAttrObj:getPlayerAttrByName("DesignationId")    -- 头像框
    local Zone = cellInfo.Zone or ""    -- 服务器名称
    local FightScore = cellInfo.FightScore or 6000    -- 战斗所得积分
    local SeasonWinCount = cellInfo.SeasonWinCount or 200    -- 战斗所得积分
    local seasonDefeatCount = cellInfo.SeasonDefeatCount or 200    -- 赛季失败次数
    local WinRatlo = tonumber(string.format("%0.2f", cellInfo.WinRatio)) * 100 or 50    -- 胜率

    local sellSize = cc.size(600, 125)
    local item = ccui.Layout:create()
    item:setContentSize(sellSize)

    -- 底板
    local bgImage = ui.newScale9Sprite("c_18.png", cc.size(500, 120))
    bgImage:setPosition(sellSize.width / 2, sellSize.height / 2)
    item:addChild(bgImage)
    local bgSize = bgImage:getContentSize()

    -- 排名
    local imageData = {
        [1] = {image = "c_44.png"},
        [2] = {image = "c_45.png"},
        [3] = {image = "c_46.png"},
    }
    if imageData[Rank] then
        local rankSprite = ui.newSprite(imageData[Rank].image)
        rankSprite:setPosition(cc.p(55, bgSize.height / 2))
        bgImage:addChild(rankSprite)
    else
        local rankNumLabel = ui.createSpriteAndLabel({
            imgName = "c_47.png",
            labelStr = string.format("%s", Rank),
            fontColor = Enums.Color.eNormalWhite,
            fontSize = 40
        })
        rankNumLabel:setPosition(cc.p(55, bgSize.height / 2))
        bgImage:addChild(rankNumLabel)
    end

    -- 玩家头像
    local header = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = HeadImageId,
        fashionModelID = FashionModelId,
        IllusionModelId = cellInfo.IllusionModelId,
        cardShowAttrs = {CardShowAttr.eBorder},
        PVPInterLv = DesignationId,
        onClickCallback = function()
            -- 只能查看前10名的玩家信息
            if cellInfo.Rank <= 10 then
                -- 查看其他玩家阵容
                self:requestGetGodDomainPlayerRankData(PlayerId)
            end
        end
    })
    header:setPosition(bgSize.width * 0.3, bgSize.height / 2 + 3)
    header:setSwallowTouches(false)
    bgImage:addChild(header)

    -- 玩家名字
    local color = Utility.getColorValue(Utility.getColorLvByModelId(HeadImageId),1)
    local nameLabel = ui.newLabel({
        text = PlayerName,
        color = color,
        size = 20,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(bgSize.width * 0.42, bgSize.height * 0.79)
    bgImage:addChild(nameLabel)

    -- 区服
    local serverNameLabel = ui.newLabel({
        text = TR("区服：#44AC06%s", Zone),
        size = 20,
        anchorPoint = cc.p(0, 0.5),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    serverNameLabel:setPosition(bgSize.width * 0.42, bgSize.height * 0.53)
    bgImage:addChild(serverNameLabel)

    -- 积分
    local scorelabel = ui.newLabel({
        text = TR("积分：#44AC06%s", FightScore),
        size = 20,
        anchorPoint = cc.p(0, 0.5),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    scorelabel:setPosition(bgSize.width * 0.42, bgSize.height * 0.27)
    bgImage:addChild(scorelabel)

    -- 胜利次数
    local winLabel = ui.newLabel({
        text = TR("胜: #44AC06%d", SeasonWinCount),
        size = 20,
        outlineColor = cc.c3b(0x46, 0x36, 0x0d),
        outlineSize = 1,
        align = ui.TEXT_ALIGN_CENTER
    })
    winLabel:setPosition(bgSize.width * 0.86, bgSize.height * 0.8)
    bgImage:addChild(winLabel)

    -- 失败次数
    local defeatLabel = ui.newLabel({
        text = TR("负: #44AC06%d", seasonDefeatCount),
        size = 20,
        outlineColor = cc.c3b(0x46, 0x36, 0x0d),
        outlineSize = 1,
        align = ui.TEXT_ALIGN_CENTER
    })
    defeatLabel:setPosition(bgSize.width * 0.86, bgSize.height * 0.6)
    bgImage:addChild(defeatLabel)

    -- 胜率标签
    local rateLabel = ui.newLabel({
        text = TR("胜率:%s%s%%", "#44AC06", WinRatlo),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
        align = ui.TEXT_ALIGN_CENTER,
        x = bgSize.width * 0.86,
        y = bgSize.height * 0.25
    })
    bgImage:addChild(rateLabel)

    return item
end

-- 添加家族奖励条目
function ShengyuanWarsRankLayer:addRewardItem(index, info)
    local sellSize = cc.size(600, 125)
    local item = ccui.Layout:create()
    item:setContentSize(sellSize)

    -- 底板
    local bgImage = ui.newScale9Sprite("c_18.png", cc.size(500, 120))
    bgImage:setPosition(sellSize.width / 2, sellSize.height / 2)
    item:addChild(bgImage)
    local bgSize = bgImage:getContentSize()

    -- 排名
    local imageData = {
        [1] = {image = "c_44.png"},
        [2] = {image = "c_45.png"},
        [3] = {image = "c_46.png"},
    }

    if imageData[index] then
        local rankSprite = ui.newSprite(imageData[index].image)
        rankSprite:setPosition(cc.p(55, bgSize.height / 2))
        bgImage:addChild(rankSprite)
    else
        local rankNumLabel = ui.createSpriteAndLabel({
            imgName = "c_47.png",
            labelStr = TR("%s ~ %s", info.rankMin, info.rankMax),
            fontColor = Enums.Color.eNormalWhite,
            fontSize = 18,
            outlineColor = cc.c3b(0x54, 0x17, 0x17),
            outlineSize = 2,
        })
        rankNumLabel:setPosition(cc.p(55, bgSize.height / 2))
        bgImage:addChild(rankNumLabel)
    end

    -- 掉落物品列表
    local rankRewards = info.reward
    local tempResource = Utility.analysisStrResList(rankRewards)
    local rewardList = {}
    for i, v in ipairs(tempResource) do
        local tempList = {}
        tempList.resourceTypeSub = v.resourceTypeSub
        tempList.modelId = v.modelId
        tempList.num = v.num
        tempList.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName}
        table.insert(rewardList, tempList)
    end
    local rewardListView = ui.createCardList({
        maxViewWidth = bgSize.width - 140,
        space = -10,
        cardDataList = rewardList,
        allowClick = true,
        isSwallow = false
    })
    rewardListView:setAnchorPoint(cc.p(0, 0.5))
    rewardListView:setPosition(bgSize.width * 0.3 , bgSize.height / 2)
    rewardListView:setScale(0.85)
    bgImage:addChild(rewardListView)
    local list = rewardListView:getCardNodeList()
    for k,v in pairs(list) do
        v:setSwallowTouches(false)
    end
    return item
end

-- 没有更多数据
function ShengyuanWarsRankLayer:createNoMoreCell()
    -- 创建cell
    local width, height = 580, 60
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(width, height))

    local noMoreLabel =  ui.newLabel({
        text = TR("没有更多数据"),
        x = width * 0.5,
        y = height * 0.5,
        color = cc.c3b(0x46, 0x22, 0x0d),
        align = ui.TEXT_ALIGN_CENTER
    })
    customCell:addChild(noMoreLabel)

    return customCell
end

-- 检查当前赛季
function ShengyuanWarsRankLayer:checkSeasonType()
    local startTime = string.split(ShengyuanwarsConfig.items[1].dayStartTime, ":")
    -- 判断赛季
    local day = os.date("%A", Player:getCurrentTime())
    if day == "Monday" then
        -- 周一(显示上个赛季)
        local time = os.date("*t", Player:getCurrentTime())
        local hour = tonumber(time.hour)
        if hour >= 0 and hour < tonumber(startTime[1]) then
            -- print("显示上个赛季", tonumber(startTime[1]))
            self.mSeasonType = SeasonType.eOld
        else
            -- print("显示当前赛季", tonumber(startTime[1]))
            self.mSeasonType = SeasonType.eNow
        end
    end
    print("检查赛季",self.mSeasonType)
end
-- -----------------------------网络相关-------------------------------
-- 获取帮派排行榜的数据
function ShengyuanWarsRankLayer:getGuildTotalData()
    self.mIsRequest = true
    HttpClient:request({
        moduleName = "Shengyuan",
        methodName = "GetShengyuanGuildRankData",
        svrMethodData = {self.mCurrPage ,self.mSeasonType},
        callbackNode = self,
        callback = function(data)
            --dump(data, "帮派排行榜概要信息")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            self.mTotalPage = data.Value.TotalPage
            if data.Value.TotalPage == 0 then
               local node = ui.createEmptyHint(TR("暂无排行信息"))
               node:setAnchorPoint(cc.p(0.5, 0.5))
               node:setPosition(320, 600)
               self.mChildLayer:addChild(node)
               return
            end 

            for i, v in ipairs(data.Value.ShengyuanGuildRankInfo) do
                self.mListView:pushBackCustomItem(self:addFamilyitem(i+10 * (self.mCurrPage - 1), v))
            end

            self.mCurrPage = self.mCurrPage + 1 
            self.mIsRequest = false

            -- 添加自己的帮派排行信息
            if self.mCurrPage > 2 then -- 不需要重复创建
                return
            end     
            if data.Value.MyRank and next(data.Value.MyRank) ~= nil then 
                local myRankInfo = data.Value.MyRank
                local myRankBg = ui.newScale9Sprite("c_25.png", cc.size(480, 56))
                myRankBg:setAnchorPoint(0.5, 1)
                myRankBg:setPosition(320, 230)
                self.mChildLayer:addChild(myRankBg)

                local rankNum = myRankInfo.Rank == 0 and TR("未上榜") or myRankInfo.Rank
                local myRankLabel = ui.newLabel({
                    text = TR("#46220d帮派排名:#44AC06%s #46220d帮派积分:#44AC06%s", rankNum, myRankInfo.FightScore), 
                    size = 24,
                    x = 240,
                    y = 28,
                })
                myRankBg:addChild(myRankLabel)
            end    
        end
    })
end

-- 请求服务器，获取个人排行榜概要信息
function ShengyuanWarsRankLayer:requestGetPersonalRankTotalPage()
    -- self:checkSeasonType()
    self.mIsRequest = true
    HttpClient:request({
        moduleName = "Shengyuan",
        methodName = "GetShengyuanPersonRankTotalPage",
        svrMethodData = {self.mSeasonType, self.mCurrPage},
        callbackNode = self,
        callback = function(data)
            --dump(data, "个人排行榜概要信息")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            self.mTotalPage = data.Value.TotalPage
            if data.Value.TotalPage == 0 then
               local node = ui.createEmptyHint(TR("暂无排行信息"))
               node:setAnchorPoint(cc.p(0.5, 0.5))
               node:setPosition(320, 600)
               self.mChildLayer:addChild(node)
               return
            end 

            -- 排序
            local rankInfo = data.Value.PageInfo
            local rankInfo = {}
            for k,v in pairs(data.Value.PageInfo) do
                table.insert(rankInfo, v)
            end
            table.sort(rankInfo, function (a, b)
                if a.Rank < b.Rank then return true else return false end
            end)
            for i, v in ipairs(rankInfo) do
                self.mListView:pushBackCustomItem(self:addPersonalItem(i+10 * (self.mCurrPage - 1), v))
            end

            self.mCurrPage = self.mCurrPage + 1
            --dump(self.mCurrPage,"self.mCurrPage")
            self.mIsRequest = false
            -- 添加自己的排行信息
            if self.mCurrPage > 2 then -- 不需要重复创建
                return
            end     
            if data.Value.MyRank and next(data.Value.MyRank) ~= nil then 
                local myRankInfo = data.Value.MyRank
                local myRankBg = ui.newScale9Sprite("c_25.png", cc.size(480, 56))
                myRankBg:setAnchorPoint(0.5, 1)
                myRankBg:setPosition(320, 230)
                self.mChildLayer:addChild(myRankBg)

                local rankNum = myRankInfo.Rank == 0 and TR("未上榜") or myRankInfo.Rank
                local myRankLabel = ui.newLabel({
                    text = TR("#46220d我的排名:#44AC06%s #46220d积分:#44AC06%s #46220d胜:#44AC06%s #46220d负:#44AC06%s", rankNum, myRankInfo.FightScore, myRankInfo.SeasonWinCount ,myRankInfo.SeasonDefeatCount), 
                    size = 24,
                    x = 240,
                    y = 28,
                })
                myRankBg:addChild(myRankLabel)
            end    
        end
    })
end

-- 请求服务器，获取跨服玩家阵容信息
function ShengyuanWarsRankLayer:requestGetGodDomainPlayerRankData(playerId)
    -- self:checkSeasonType()
    HttpClient:request({
        moduleName = "Shengyuan",
        methodName = "GetShengyuanPersonInfo",
        svrMethodData = {self.mSeasonType, playerId},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 返回的是json字符串，必须解析
            if not data.Value.Formation or data.Value.Formation == "" then
                ui.showFlashView({text = TR("未获取到玩家数据")})
                return
            end
            local formation = cjson.decode(data.Value.Formation)

            -- 如果玩家穿戴了时装，则将时装组装道阵容信息中
            if data.Value.FashionModelId then
                formation.PlayerInfo.FashionModelId = data.Value.FashionModelId
            end
            -- 创建其他玩家阵容数据对象
            local tempObj = require("data.CacheFormation"):create()
            tempObj:setFormation(formation.SlotInfos, formation.MateInfos)
            tempObj:setOtherPlayerInfo(formation.PlayerInfo)

            LayerManager.addLayer({
                name = "team.OtherTeamLayer",
                cleanUp = false,
                data = {
                    formationObj = tempObj,
                }
            })
        end
    })
end

return ShengyuanWarsRankLayer