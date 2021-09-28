--[[
    文件名：GDDHRankLayer.lua
    描述：武林大会排行页面
    创建人：libowen
    修改人：liucunxin
    创建时间：2016.12.6
--]]

local GDDHRankLayer = class("GDDHRankLayer", function(params)
    return display.newLayer()
end)

-- 个人排名、个人奖励、帮派排名、帮派奖励分页tag
local TabPageTags = {
    eTagSingle = 1,
    eTagOwnReward = 2,
    eTagGuildRank = 3,
    eTagGuideReward = 4
}

-- 构造函数
--[[
params:
    Table params:
    {
        groupId                         -- 玩家所在组号
        rank                            -- 玩家的名次
        integral                        -- 玩家积分
        signupData                      -- 赛季数据
        selectedBtn                     -- 当前选择的那个主分页，页面恢复时使用
        selectedSubBtn                  -- 个人排名中，选中的哪个组，页面恢复时使用
        scrollViewPos                   -- 个人排名中，listView的滑动位置，恢复页面时使用
        rankInfo                        -- 个人排行榜信息，页面恢复时使用
        guideInfo                      -- 帮派排行榜信息
        rewardInfo                      -- 奖励列表
    }
--]]
function GDDHRankLayer:ctor(params)
    -- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    self.mGroupId = params and params.groupId
    self.mRank = params and params.rank
    self.mGuideList = params and params.guideList

    -- 缓存数据
    self.mSelectedBtn = params and params.selectedBtn
    self.mSelectedSubBtn = params.selectedSubBtn
    self.mScrollViewPos = params and params.scrollViewPos
    self.mRankInfo = params and params.rankInfo
    self.mIntegral = params and params.integral
    self.mGuildInfo = params and params.guildInfo

    -- 赛季信息，主界面传入
    self.mSignupData = params and params.signupData

    -- 计算当前时何赛季
    local tempType = 0
    local period = math.abs(self.mSignupData.EndRewardDate - self.mSignupData.FirstRewardDate)
    if period <= 60 * 60 *24 * 2 then
        tempType = 1        -- 两日大奖
    else
        tempType = 0        -- 三日大奖
    end

    -- 初始化数据
    self.mSeasonRewardList = {} --赛季奖励
    self.mDailyRewardList = {}  --每日奖励

    -- 对每日，三日列表进行处理
    for i, v in pairs(GddhRankRewardRelation.items) do
        if v.seasonReward ~= "" and v.rewardsType == tempType then
            table.insert(self.mSeasonRewardList, {rankMin = v.rankMin, rankMax = v.rankMax, seasonReward = Utility.analysisStrResList(v.seasonReward)})
        end
        if v.rankMin ~= 0 and v.rewardsType == tempType then
            table.insert(self.mDailyRewardList, {rankMin = v.rankMin, rankMax = v.rankMax, dailyReward = v.perRewardRawGold})
        end
    end

    -- 对每日，三日列表进行顺序整理
    table.sort(self.mSeasonRewardList, function(a, b) return a.rankMin < b.rankMin end)
    table.sort(self.mDailyRewardList, function(a, b) return a.rankMin < b.rankMin end)


    if not self.mRankInfo then
        -- 请求服务器，获取排行榜信息
        self:requestGddhRankList()
    else
        -- 初始化UI
        self:initUI()
    end
end

-- 添加UI相关
function GDDHRankLayer:initUI()
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

    -- 子背景
    -- local subBgSprite = ui.newScale9Sprite("c_124.png", cc.size(640, 142))
    -- subBgSprite:setAnchorPoint(cc.p(0.5, 1))
    -- subBgSprite:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.5, self.mParentLayer:getContentSize().height))
    -- self.mParentLayer:addChild(subBgSprite)
    --下方背景
    local bottomSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 990))
    bottomSprite:setAnchorPoint(0.5, 0)
    bottomSprite:setPosition(320, 10)
    self.mParentLayer:addChild(bottomSprite)

    -- 子页面父节点
    self.mParentLayerNode = cc.Node:create()
    -- self.mParentLayerNode:setPosition(cc.p(5, 568))
    self.mParentLayer:addChild(self.mParentLayerNode)

    -- 存放分页内容的容器layer
    self.mChildLayer = display.newLayer()
    self.mChildLayer:setContentSize(640, 1136)
    bgSprite:addChild(self.mChildLayer)

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

-- 数据恢复
function GDDHRankLayer:getRestoreData()
    local retData = {
        groupId = self.mGroupId,
        rank = self.mRank,
        selectedBtn = self.mSelectedBtn,
        selectedSubBtn = self.mSelectedSubBtn,
        scrollViewPos = self.mScrollViewPos,
        rankInfo = self.mRankInfo,
        guildInfo = self.mGuildInfo,
        signupData = self.mSignupData,
        integral = self.mIntegral
    }
    return retData
end

-- 创建分页控件，个人排名、公会排名、规则
function GDDHRankLayer:addTabView()
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

    -- 帮派排名
    local btnInfo3 = {
        text = TR("帮派排名"),
        tag = TabPageTags.eTagGuildRank
    }
    table.insert(buttonInfos, btnInfo3)

    local btnInfo4 = {
        text = TR("帮派奖励"),
        tag = TabPageTags.eTagGuideReward
    }
    table.insert(buttonInfos, btnInfo4)

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
            -- 先移除再添加
            self.mChildLayer:removeAllChildren()
            self.mParentLayerNode:removeAllChildren()

            if selectBtnTag == TabPageTags.eTagSingle then
                local templayer = require("challenge.GDDHOwnRankLayer"):create({
                    groupId = self.mGroupId,
                    selectedSubBtn = self.mSelectedSubBtn,
                    rankInfo = clone(self.mRankInfo),
                    rank = self.mRank,
                    integral = self.mIntegral,
                })
                self.mParentLayerNode:addChild(templayer)
            elseif selectBtnTag == TabPageTags.eTagOwnReward then
                local templayer = require("challenge.GDDHOwnRewardLayer"):create({
                    seasonRewardList = clone(self.mSeasonRewardList),
                    dailyRewardList = clone(self.mDailyRewardList),
                    rank = self.mRank,
                })
                self.mParentLayerNode:addChild(templayer)
            elseif selectBtnTag == TabPageTags.eTagGuildRank then
                local templayer = require("challenge.GDDHShiMenRankLayer"):create({
                    guildList = self.mGuildInfo
                    })
                self.mParentLayerNode:addChild(templayer)
            elseif selectBtnTag == TabPageTags.eTagGuideReward then
                local templayer = require("challenge.GDDHShiMenRewardLayer"):create({
                    signupData = self.mSignupData
                    })
                self.mParentLayerNode:addChild(templayer)
            end
        end
    })
    self.mTabView:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(self.mTabView)

end

-----------------------------网络相关-------------------------------
-- 请求服务器，获取排行榜信息
function GDDHRankLayer:requestGddhRankList()
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "GddhRankList",
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- 保存数据
            self.mRankInfo = {}
            self.mRankInfo[1] = clone(data.Value.GddhRankList.One)
            self.mRankInfo[2] = clone(data.Value.GddhRankList.Two)
            self.mRankInfo[3] = clone(data.Value.GddhRankList.Three)
            self.mRankInfo[4] = clone(data.Value.GddhRankList.Four)
            self.mGuildInfo = clone(data.Value.GddhRankList.GuildInfo) or {}

            -- self.mGuideList = data.Value.GddhRankList.guideList
            -- 初始化UI
            self:initUI()
        end
    })
end

return GDDHRankLayer
