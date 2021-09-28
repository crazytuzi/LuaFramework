--[[
    文件名：NationalZYTRankLayer.lua
    描述：铸倚天排行界面
    创建人：lengjiazhi
    创建时间：2017.9.22
--]]

local NationalZYTRankLayer = class("NationalZYTRankLayer", function(params)
    return display.newLayer()
end)

-- 个人排名、个人奖励
local TabPageTags = {
    eTagSingle = 1,
    eTagOwnReward = 2,
}

-- 构造函数

function NationalZYTRankLayer:ctor(params)
    self.mRankInfo = {}
    self.mRewardInfo = {}
    self.mMyScore = nil
    self.mRank = nil

    -- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})
    self:initUI()
end

-- 添加UI相关
function NationalZYTRankLayer:initUI()
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 包含顶部底部的公共layer
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    -- 背景
    local bgSprite = ui.newSprite("c_34.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    self.mBgSprite = bgSprite
    self.mBgSize = bgSprite:getContentSize()

    --下方背景
    local bottomSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 990))
    bottomSprite:setAnchorPoint(0.5, 0)
    bottomSprite:setPosition(320, 10)
    self.mParentLayer:addChild(bottomSprite)

    local tipLabel = ui.newLabel({
        text = TR("活动结束当日晚23:00~24:00结算排名奖励"),
        size = 24,
        color = cc.c3b(0x46, 0x22, 0x0d),
        })
    tipLabel:setPosition(320, 950)
    self.mParentLayer:addChild(tipLabel)

    local lessSCoreLabel = ui.newLabel({
        text = TR(""),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d),
        })
    lessSCoreLabel:setPosition(265, 1015)
    lessSCoreLabel:setAnchorPoint(0, 0.5)
    self.mParentLayer:addChild(lessSCoreLabel)
    self.mLessScoreLabel = lessSCoreLabel

    -- 创建分页控件
    self:addTabView()

    -- 显示关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)
end

-- 创建分页控件，个人排名、公会排名、规则
function NationalZYTRankLayer:addTabView()
    local buttonInfos = {}
    -- 道具按钮配置
    local btnInfo1 = {
        text = TR("个人排名"),
        tag = TabPageTags.eTagSingle,
    }
    table.insert(buttonInfos, btnInfo1)

    -- 个人奖励
    local btnInfo2 = {
        text = TR("个人奖励"),
        tag = TabPageTags.eTagOwnReward
    }
    table.insert(buttonInfos, btnInfo2)

    -- 创建分页
    self.mTabView = ui.newTabLayer({
        btnInfos = buttonInfos,
        isVert = false,
        space = 18,
        needLine = true,
        defaultSelectTag = self.mSelectedBtn or TabPageTags.eTagSingle,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            self.mSelectedBtn = selectBtnTag
            if selectBtnTag == TabPageTags.eTagSingle then
                self:rankPage()
            elseif selectBtnTag == TabPageTags.eTagOwnReward then
                self:rewardPage()
            end
        end
    })
    self.mTabView:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(self.mTabView)
end

--排行页面
function NationalZYTRankLayer:rankPage()
    if self.mRewardPageNode then
        self.mRewardPageNode:setVisible(false)
    end
    if self.mRankPageNode then
        self.mRankPageNode:setVisible(true)
        return
    end
    self:requestRankList()
end

--奖励页面
function NationalZYTRankLayer:rewardPage()
    if self.mRankPageNode then
        self.mRankPageNode:setVisible(false)
    end
    if self.mRewardPageNode then
        self.mRewardPageNode:setVisible(true)
        return
    end
    self:requestRewardList()
end

--创建排行显示
function NationalZYTRankLayer:createRankPage()
    self.mRankPageNode = cc.Node:create()
    self.mRankPageNode:setAnchorPoint(0.5, 0.5)
    self.mRankPageNode:setContentSize(640, 1136)
    self.mRankPageNode:setPosition(320, 568)
    self.mParentLayer:addChild(self.mRankPageNode)

    local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(600, 740))
    grayBgSprite:setAnchorPoint(0.5, 1)
    grayBgSprite:setPosition(320, 920)
    self.mRankPageNode:addChild(grayBgSprite)

    local myRankBgSprite = ui.newScale9Sprite("c_25.png", cc.size(550, 50))
    myRankBgSprite:setPosition(320, 140)
    self.mRankPageNode:addChild(myRankBgSprite)

    local myRankLabel = ui.newLabel({
        text = TR("我的排名：%s", self.mRank==0 and TR("未上榜") or self.mRank),
        size = 22,
        outlineColor = Enums.Color.eBlack,
        })
    myRankLabel:setAnchorPoint(0, 0.5)
    myRankLabel:setPosition(110, 140)
    self.mRankPageNode:addChild(myRankLabel)

    local myScoreLabel = ui.newLabel({
        text = TR("个人福运值：%s", self.mMyScore or TR("暂无")),
        size = 22,
        outlineColor = Enums.Color.eBlack,
        })
    myScoreLabel:setAnchorPoint(0, 0.5)
    myScoreLabel:setPosition(380, 140)
    self.mRankPageNode:addChild(myScoreLabel)

    -- 排名列表
    local rankListView = ccui.ListView:create()
    rankListView:setDirection(ccui.ScrollViewDir.vertical)
    rankListView:setBounceEnabled(true)
    rankListView:setContentSize(cc.size(600, 720))
    rankListView:setItemsMargin(5)
    rankListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rankListView:setAnchorPoint(cc.p(0.5, 1))
    rankListView:setPosition(310, 910)
    self.mRankPageNode:addChild(rankListView)

    local function createRankCell(i)
        local info = self.mRankInfo[i]

        local layout = ccui.Layout:create()
        layout:setContentSize(580, 130)

        local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(570, 120))
        bgSprite:setPosition(300, 65)
        layout:addChild(bgSprite)

        -- 排名
        local rankLabel = ui.createLabelWithBg({
            bgFilename = "c_47.png",
            labelStr = info.Rank,
            fontSize = 20,
            alignType = ui.TEXT_ALIGN_CENTER,
            outlineColor = Enums.Color.eBlack,
            -- offset = -5,
        })

        rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
        rankLabel:setPosition(cc.p(60, 65))
        layout:addChild(rankLabel)

        if info.Rank <= 3 then
            local picName = nil
            if info.Rank == 1 then
                picName = "c_44.png"
            elseif info.Rank == 2 then
                picName = "c_45.png"
            elseif  info.Rank == 3 then
                picName = "c_46.png"
            end

            local spr = ui.newSprite(picName)
            spr:setAnchorPoint(cc.p(0.5, 0.5))
            spr:setPosition(rankLabel:getPosition())
            layout:addChild(spr)
            -- spr:setScale(0.6)

            rankLabel:setVisible(false)
        end

        local headCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.eHero,
            modelId = info.HeadImageId, 
            IllusionModelId = info.IllusionModelId,
            cardShowAttrs = {CardShowAttr.eBorder},
            allowClick = false,
        })
        headCard:setPosition(160, 65)
        layout:addChild(headCard)

        local nameLabel = ui.newLabel({
            text = info.Name,
            color = Enums.Color.eRed,
            size = 22,
            outlineColor = Enums.Color.eBlack
            })
        nameLabel:setAnchorPoint(0, 0.5)
        nameLabel:setPosition(220, 95)
        layout:addChild(nameLabel)

        local severLabel = ui.newLabel({
            text = TR("服务器：#d17b00%s", info.ServerName),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
            })
        severLabel:setAnchorPoint(0, 0.5)
        severLabel:setPosition(220, 65)
        layout:addChild(severLabel)

        local scoreLabel = ui.newLabel({
            text = TR("福运值：#d17b00%s", info.Num),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 20,
            })
        scoreLabel:setAnchorPoint(0, 0.5)
        scoreLabel:setPosition(220, 35)
        layout:addChild(scoreLabel)

        local vipLv = tonumber(info.Vip)
        if vipLv > 0 then
            local vipNode = ui.createVipNode(vipLv)
            vipNode:setPosition(380, 95)
            layout:addChild(vipNode)
        end

        return layout
    end

    for i = 1, #self.mRankInfo do
        rankListView:pushBackCustomItem(createRankCell(i))
    end
end

--创建奖励显示
function NationalZYTRankLayer:createRewardPage()
    self.mRewardPageNode = cc.Node:create()
    self.mRewardPageNode:setAnchorPoint(0.5, 0.5)
    self.mRewardPageNode:setContentSize(640, 1136)
    self.mRewardPageNode:setPosition(320, 568)
    self.mParentLayer:addChild(self.mRewardPageNode)

    local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(600, 790))
    grayBgSprite:setAnchorPoint(0.5, 1)
    grayBgSprite:setPosition(320, 920)
    self.mRewardPageNode:addChild(grayBgSprite)


    -- 排名列表
    local rewardListView = ccui.ListView:create()
    rewardListView:setDirection(ccui.ScrollViewDir.vertical)
    rewardListView:setBounceEnabled(true)
    rewardListView:setContentSize(cc.size(600, 720))
    rewardListView:setItemsMargin(5)
    rewardListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    rewardListView:setAnchorPoint(cc.p(0.5, 1))
    rewardListView:setPosition(310, 910)
    self.mRewardPageNode:addChild(rewardListView)

    local function createRewardCell(i)
        local info = self.mRewardInfo[i]

        local layout = ccui.Layout:create()
        layout:setContentSize(580, 130)

        local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(570, 120))
        bgSprite:setPosition(300, 65)
        layout:addChild(bgSprite)

        -- 排名
        local rankLabel = ui.createLabelWithBg({
            bgFilename = "c_47.png",
            labelStr = string.format("%s~%s", info.RankMin, info.RankMax),
            fontSize = 22,
            alignType = ui.TEXT_ALIGN_CENTER,
            outlineColor = Enums.Color.eBlack,
            -- offset = -5,
        })

        rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
        rankLabel:setPosition(cc.p(60, 65))
        layout:addChild(rankLabel)


        if info.RankMin <= 3 then
            local picName = nil
            if info.RankMin == 1 then
                picName = "c_44.png"
            elseif info.RankMin == 2 then
                picName = "c_45.png"
            elseif  info.RankMin == 3 then
                picName = "c_46.png"
            end

            local spr = ui.newSprite(picName)
            spr:setAnchorPoint(cc.p(0.5, 0.5))
            spr:setPosition(rankLabel:getPosition())
            layout:addChild(spr)
            -- spr:setScale(0.6)
            rankLabel:setVisible(false)
        end

        --整理数据
        local tempRewardList = {}
        for i,v in ipairs(info.RewardList) do
            tempRewardList[i] = {}
            tempRewardList[i].resourceTypeSub = v.ResourceTypeSub
            tempRewardList[i].modelId = v.ModelId
            tempRewardList[i].num = v.Count
            tempRewardList[i].cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        end

        --奖励列表
        local rewardList = ui.createCardList({
            maxViewWidth = 470,
            viewHeight = 110,
            space = 10,
            cardDataList = tempRewardList,
            allowClick = true, 
            isSwallow = false,
        })
        rewardList:setAnchorPoint(cc.p(0, 0.5))
        rewardList:setPosition(100, 60)
        layout:addChild(rewardList)

        return layout
    end

    for i = 1, #self.mRewardInfo do
        rewardListView:pushBackCustomItem(createRewardCell(i))
    end

end

-----------------------------网络相关-------------------------------
-- 请求服务器，获取排行榜信息
function NationalZYTRankLayer:requestRankList()
    HttpClient:request({
        moduleName = "TimedPolaroid", 
        methodName = "GetRankInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            dump(data, "rank")
            self.mRankInfo = data.Value.RankInfo
            self.mRank = data.Value.Rank 
            self.mMyScore = data.Value.Num 
            self:createRankPage()

            self.mLessScoreLabel:setString(TR("进入前500名需要高于：%s", data.Value.LessScore))
        end
    })
end

--获取奖励信息
function NationalZYTRankLayer:requestRewardList()
    HttpClient:request({
        moduleName = "TimedPolaroid", 
        methodName = "GetRankRewardInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
            if data.Status ~= 0 then
                return
            end
            dump(data, "reward")
            self.mRewardInfo = data.Value
            self:createRewardPage()
        end
    })
end

return NationalZYTRankLayer
