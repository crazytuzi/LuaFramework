--[[
	文件名：GDDHOwnRankLayer.lua
	描述：武林大会排行榜个人排名页面
	创建人：liucunxin
	创建时间：2016.1.3
--]]

local GDDHOwnRankLayer = class("GDDHOwnRankLayer", function()
    return display.newLayer()
end)

-- 所属分组名字
local GroupName = {
    TR("少林"), TR("武当"), TR("朝廷"), TR("明教")
}

-- "所在组"标签坐标
local inTeamPosX = {
    55, 210, 365, 520
}

-- 构造函数
--[[
	params:
		groupId   		-- 组号
		rankInfo 		-- 排名信息
		selectedSubBtn 	-- 所选择组号
--]]
function GDDHOwnRankLayer:ctor(params)
    if not params.rankInfo and params.groupId then
		return
	end

	self.mGroupId = params.groupId
	self.mSelectedSubBtn = params.selectedSubBtn or (self.mGroupId or 1)
	self.mRankInfo = params.rankInfo
    self.mRank = params.rank
    self.mIntegral = params.integral

	self:initUI()
end

function GDDHOwnRankLayer:initUI()
	self:showSingleRankLayer()
end

-- 个人排名页面
function GDDHOwnRankLayer:showSingleRankLayer()
    -- -- 上方的4个组别按钮
    -- local btnInfoList = {
    --     {
    --         normalTextImage = "wldh_08.png",
    --         lightedTextImage = "wldh_07.png",
    --         tag = 1,
    --         text = "",
    --         titlePosRateY = 0.5
    --     },
    --     {
    --         normalTextImage = "wldh_10.png",
    --         lightedTextImage = "wldh_09.png",
    --         tag = 2,
    --         text = "",
    --         titlePosRateY = 0.5
    --     },
    --     {
    --         normalTextImage = "wldh_12.png",
    --         lightedTextImage = "wldh_11.png",
    --         tag = 3,
    --         text = "",
    --         titlePosRateY = 0.5
    --     },
    --     {
    --         normalTextImage = "wldh_14.png",
    --         lightedTextImage = "wldh_13.png",
    --         tag = 4,
    --         text = "",
    --         titlePosRateY = 0.5
    --     },
    -- }

    -- self.mSelectedSubBtn = self.mSelectedSubBtn or (self.mGroupId or 1)

    -- local tempData = {
    --     btnInfos = btnInfoList,
    --     viewSize = cc.size(640, 125),
    --     isVert = false,
    --     space = 40,
    --     btnSize = cc.size(115, 115),
    --     needLine = false,
    --     defaultSelectTag = self.mSelectedSubBtn,
    --     normalImage = "c_83.png",
    --     lightedImage = "c_83.png",
    --     allowChangeCallback = function(btnTag)
    --         return true
    --     end,
    --     onSelectChange = function(selectBtnTag)
    --         self.mSelectedSubBtn = selectBtnTag
    --         if self.mRankInfo and self.mRankListView then
    --             self:refreshRankListView()
    --         end
    --     end
    -- }
    -- self:refreshRankListView()

    -- self.mSubRankTab = ui.newTabLayer(tempData)
    -- self.mSubRankTab:setAnchorPoint(cc.p(0.5, 0))
    -- self.mSubRankTab:setPosition(cc.p(330, 860))
    -- self:addChild(self.mSubRankTab)

    -- 所在组标签
    -- self.mTeamSprite = ui.newSprite("wldh_18.png")
    -- self.mTeamSprite:setAnchorPoint(cc.p(0.5, 0))
    -- self.mTeamSprite:setVisible(self.mGroupId ~= nil)
    -- self.mTeamSprite:setPosition(cc.p(inTeamPosX[self.mGroupId], 65))
    -- self.mSubRankTab:addChild(self.mTeamSprite)

    local underBgSprite = ui.newScale9Sprite("c_17.png", cc.size(606, 780))
    underBgSprite:setPosition(320, 500)
    self:addChild(underBgSprite)

    -- 创建ListView列表
    self.mRankListView = ccui.ListView:create()
    self.mRankListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mRankListView:setBounceEnabled(true)
    self.mRankListView:setContentSize(cc.size(598, 760))
    self.mRankListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mRankListView:setItemsMargin(3)
    self.mRankListView:setAnchorPoint(cc.p(0.5, 1))
    self.mRankListView:setPosition(308, 770)
    underBgSprite:addChild(self.mRankListView)
    if self.mScrollViewPos then
        self.mRankListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)

        -- 必须延迟调用，否选位置设置不生效
        Utility.performWithDelay(
            self,
            function()
                self.mRankListView:setInnerContainerPosition(cc.p(self.mScrollViewPos.x, self.mScrollViewPos.y))
            end,
            0.0
        )
    end

    if self.mRankInfo and #self.mRankInfo ~= 0 then
        -- 刷新页面
        self:refreshRankListView()
    end

    -- 创建我的排名标签
    self:createSelfRankLabel()
end

-- 创建个人排名页面的每一个条目
--[[
    params:
    cellInfo                        -- cell条目包含的数据信息
--]]
function GDDHOwnRankLayer:createRankCell(cellInfo)
    -- 创建cell
    local width, height = 590, 126
    local customCell = ccui.Layout:create()
    customCell:setContentSize(cc.size(width, height))

    -- 背景条
    local bgPic, rankPic = "c_18.png", nil
    if cellInfo.Rank == 1 then
        rankPic = "c_44.png"
    elseif cellInfo.Rank == 2 then
        rankPic = "c_45.png"
    elseif cellInfo.Rank == 3 then
        rankPic = "c_46.png"
    end
    local cellBg = ui.newScale9Sprite(bgPic, cc.size(width, height))
    cellBg:setPosition(width * 0.5, height* 0.5)
    customCell:addChild(cellBg)
    local cellBgSize = cellBg:getContentSize()

    -- 排名
    if rankPic then
        local rankSpr = ui.newSprite(rankPic)
        rankSpr:setPosition(cellBgSize.width * 0.11, cellBgSize.height * 0.5)
        cellBg:addChild(rankSpr)
    else
        local rankLabel = ui.createSpriteAndLabel({
            imgName = "c_47.png",
            labelStr = cellInfo.Rank,
            fontColor = Enums.Color.eNormalWhite,
            fontSize = 40
        })
        rankLabel:setPosition(cc.p(cellBgSize.width * 0.11, cellBgSize.height * 0.5))
        cellBg:addChild(rankLabel)
    end
    -- 玩家头像
    local header = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        fashionModelID = cellInfo.FashionModelId,
        IllusionModelId = cellInfo.IllusionModelId,
        modelId = cellInfo.HeadImageId,
        pvpInterLv = cellInfo.DesignationId,
        cardShowAttrs = {CardShowAttr.eBorder},
        onClickCallback = function()
            self.mScrollViewPos = self.mRankListView:getInnerContainerPosition()
            --dump(self.mScrollViewPos, "滑动位置:")

            Utility.showPlayerTeam(cellInfo.PlayerId)
        end
    })
    header:setPosition(cellBgSize.width * 0.3, cellBgSize.height * 0.5)
    cellBg:addChild(header)

    -- 玩家名字
    local nameLabel = ui.newLabel({
        text = cellInfo.Name,
        color = Utility.getQualityColor(Utility.getQualityByModelId(cellInfo.HeadImageId), 1),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b), 
        outlineSize = 2,
        size = 24
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(cellBgSize.width * 0.4, cellBgSize.height * 0.65)
    cellBg:addChild(nameLabel)

    -- vip等级
    local vipNode = ui.createVipNode(cellInfo.Vip)
    vipNode:setPosition(nameLabel:getContentSize().width+cellBgSize.width * 0.4+10, cellBgSize.height * 0.65)
    cellBg:addChild(vipNode)

    -- 战斗力
    local fapLabel = ui.newLabel({
        text = TR("#46220d战斗力: #d17b00%s", Utility.numberFapWithUnit(cellInfo.FAP)),
        size = 22
    })
    fapLabel:setAnchorPoint(cc.p(0, 1))
    fapLabel:setPosition(cellBgSize.width * 0.4, cellBgSize.height * 0.45)
    cellBg:addChild(fapLabel)

    -- 积分
    local integralLabel = ui.newLabel({
        text = TR("#46220d积分: #249029%s", cellInfo.Integral),
        size = 22
    })
    integralLabel:setAnchorPoint(cc.p(0, 1))
    integralLabel:setPosition(cellBgSize.width * 0.72, cellBgSize.height * 0.45)
    cellBg:addChild(integralLabel)

    return customCell
end

-- 刷新个人排名ListView
function GDDHOwnRankLayer:refreshRankListView()
    local infoList = self.mRankInfo[self.mSelectedSubBtn]
    self.mRankListView:removeAllItems()
    for i, v in ipairs(infoList) do
        self.mRankListView:pushBackCustomItem(self:createRankCell(v))
    end
end

-- 创建我的排名label
function GDDHOwnRankLayer:createSelfRankLabel()
    -- 创建排名背景
    local rankBgSprite = ui.newScale9Sprite("c_25.png", cc.size(590, 56))
    rankBgSprite:setAnchorPoint(cc.p(0.5, 0))
    rankBgSprite:setPosition(cc.p(320, 900))
    self:addChild(rankBgSprite)
    local tempSize = rankBgSprite:getContentSize()
    -- 子背景
    -- local rankBgSubSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 15))
    -- rankBgSubSprite:setAnchorPoint(cc.p(0.5, 0))
    -- rankBgSubSprite:setPosition(cc.p(tempSize.width * 0.5, tempSize.height - 10))
    -- rankBgSprite:addChild(rankBgSubSprite)
    -- 未上榜标签
    local noRank = ui.newLabel({
        text = TR("未上榜"),
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
    })
    noRank:setPosition(cc.p(rankBgSprite:getContentSize().width * 0.5, rankBgSprite:getContentSize().height * 0.5))
    noRank:setVisible(self.mRank == nil)
    rankBgSprite:addChild(noRank)

    -- 创建我的排名
    local rankLabel = ui.newLabel({
        text = TR("我的排名："),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        align = TEXT_ALIGN_CENTER,
        size = 22
    })
    rankLabel:setAnchorPoint(cc.p(0, 0.5))
    rankLabel:setPosition(cc.p(tempSize.width * 0.07, tempSize.height * 0.5))
    rankLabel:setVisible(self.mRank ~= nil)
    rankBgSprite:addChild(rankLabel)

    -- 创建排名标签
    local selfRankLabel = ui.newLabel({
        text = TR("#ffe289%s", self.mRank),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        align = TEXT_ALIGN_CENTER,
        size = 22
    })
    selfRankLabel:setAnchorPoint(cc.p(0, 0.5))
    selfRankLabel:setPosition(cc.p(tempSize.width * 0.26, tempSize.height * 0.5))
    selfRankLabel:setVisible(self.mRank ~= nil)
    rankBgSprite:addChild(selfRankLabel)

    -- -- 创建所属组名标签
    -- local selfGroupLabel = ui.newLabel({
    --     text = TR("#eefff4【%s】", GroupName[self.mGroupId]),
    --     outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
    --     align = TEXT_ALIGN_CENTER,
    --     size = 24
    -- })
    -- selfGroupLabel:setAnchorPoint(cc.p(0, 0.5))
    -- selfGroupLabel:setPosition(cc.p(tempSize.width * 0.35, tempSize.height * 0.5))
    -- selfGroupLabel:setVisible(self.mGroupId ~= nil)
    -- rankBgSprite:addChild(selfGroupLabel)

    -- "积分"标签
    local selfIntegralLabel = ui.newLabel({
        text = TR("积分:"),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        align = TEXT_ALIGN_CENTER,
        size = 22
        })
    selfIntegralLabel:setAnchorPoint(cc.p(0.5, 0.5))
    selfIntegralLabel:setPosition(cc.p(tempSize.width * 0.7, tempSize.height * 0.5))
    selfIntegralLabel:setVisible(self.mRank ~= nil)
    rankBgSprite:addChild(selfIntegralLabel)
    -- 积分
    local selfIntLabel = ui.newLabel({
        text = TR("#ffe289%s", self.mIntegral),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        align = TEXT_ALIGN_CENTER,
        size = 22
        })
    selfIntLabel:setAnchorPoint(cc.p(0.5, 0.5))
    selfIntLabel:setPosition(cc.p(tempSize.width * 0.8, tempSize.height * 0.5))
    selfIntLabel:setVisible(self.mRank ~= nil)
    rankBgSprite:addChild(selfIntLabel)
end

return GDDHOwnRankLayer
