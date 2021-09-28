--[[
    文件名：GGDHShopGuideRewardLayer.lua
    描述： 序列争霸商城帮派奖励页面
    创建人：wusonglin
    创建时间：2016.6.21
-- ]]

local GGDHShopGuideRewardLayer = class("GGDHShopGuideRewardLayer", function(params)
    return display.newLayer()
end)


--初始化页面
--[[
params:
    signupData 赛季数据
--]]
function GGDHShopGuideRewardLayer:ctor(params)
    -- 屏蔽下层事件
	-- ui.registerSwallowTouch({node = self})
    
    -- 获取页面大小
    -- self.bgSize = (params and params.layerSize) and params.layerSize or cc.size(display.width, LayerManager.heightNoBottom)  

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    params = params or {}
    -- 赛季信息，主界面传入
    self.mSignupData = params.signupData
     -- 计算当前是何赛季
    local tempType = 0
    local period = math.abs(self.mSignupData.EndRewardDate - self.mSignupData.FirstRewardDate)
    if period <= 60*60*24*2 then
        tempType = 1  --"两日大奖"
    else
        tempType = 0  --"三日大奖"
    end
    -- 初始化数据
    self.mRewardList = {}

    for i, v in ipairs(GddhGuildrewardRelation.items) do
        if v.rewardsType == tempType then
            table.insert(self.mRewardList, v)
        end
    end
    -- UI
    self:setUI()
end

function GGDHShopGuideRewardLayer:setUI()
    -- 创建界面背景
    local bgSprite = cc.Node:create()
   	bgSprite:setContentSize(cc.size(640,1136))
    local backSize = bgSprite:getContentSize()
    self.mBackSize  = cc.size(640,1136)
    self.mBgSprite = bgSprite
    self.mParentLayer:addChild(bgSprite)

    -- 显示上方说明
    local titleSprite = ui.newScale9Sprite("c_103.png", cc.size(612, 110))
    titleSprite:setPosition(320, 935)
    bgSprite:addChild(titleSprite)
    local sizeTitleSP = titleSprite:getContentSize()
    --显示上方说明1
    local titleLabel1 = ui.newLabel({
        text = TR("周一、三、五的23点发放奖励"),
        size = 27,
        outlineColor = Enums.Color.eBlack,
        align = cc.TEXT_ALIGNMENT_CENTER,
    })
    titleLabel1:setAnchorPoint(cc.p(0, 0.5))
    titleLabel1:setPosition(cc.p(sizeTitleSP.width * 0.1, sizeTitleSP.height * 0.8))
    titleSprite:addChild(titleLabel1)

    local titleLabel2 = ui.newLabel({
        text = TR("1、序列争霸帮派积分前%s5#FFFFFF名",Enums.Color.eNormalGreenH),
        size = 24,
        outlineColor = Enums.Color.eBlack,
        align = cc.TEXT_ALIGNMENT_CENTER,
    })
    titleLabel2:setAnchorPoint(cc.p(0, 0.5))
    titleLabel2:setPosition(cc.p(sizeTitleSP.width * 0.1, sizeTitleSP.height * 0.5))
    titleSprite:addChild(titleLabel2)

    local titleLabel3 = ui.newLabel({
        text = TR("2、对应帮派中积分大于%s2000#FFFFFF的队员",Enums.Color.eNormalGreenH),
        size = 24,
        outlineColor = Enums.Color.eBlack,
        align = cc.TEXT_ALIGNMENT_CENTER,
    })
    titleLabel3:setAnchorPoint(cc.p(0, 0.5))
    titleLabel3:setPosition(cc.p(sizeTitleSP.width * 0.1, sizeTitleSP.height * 0.2))
    titleSprite:addChild(titleLabel3)

    -- 创建listView
    self:createListView()
end

-- 创建listView
function GGDHShopGuideRewardLayer:createListView()
    -- 创建ListView列表
    self.listView = ccui.ListView:create()
    self.listView:setDirection(ccui.ScrollViewDir.vertical)
    self.listView:setBounceEnabled(true)
    self.listView:setContentSize(cc.size(self.mBackSize.width, 700))-- LayerManager.heightNoBottom - 269 * Adapter.AutoScaleX - Adapter.AutoHeight(85)))
    self.listView:setGravity(ccui.ListViewGravity.centerVertical)
    self.listView:setItemsMargin(2)
    -- self.listView:setTouchEnabled(false)
    self.listView:setAnchorPoint(cc.p(0.5, 1))
    self.listView:setPosition(self.mBackSize.width * 0.5, 865)
    self.mBgSprite:addChild(self.listView)

    -- 添加数据
    for i = 1, #self.mRewardList do
        self.listView:pushBackCustomItem(self:createRewardView(i))
    end
end

function GGDHShopGuideRewardLayer:createRewardView(index)
	print("---createRewardView--->"..index)
	-- 初始化数据
    local info = self.mRewardList[index]
    -- 创建custom_item
    local custom_item = ccui.Layout:create()
    local width = self.mBackSize.width
    local height = 140
    custom_item:setContentSize(cc.size(width, height))

	-- 创建cell
    local rankSpriteList = {"c_16.png", "c_16.png", "c_16.png"}
    local rankSpriteImage = nil
    if index <= 3 then
        rankSpriteImage = rankSpriteList[index]
    else
        rankSpriteImage = "c_16.png"
    end

    local cellSprite = ui.newScale9Sprite(rankSpriteImage,cc.size(630, 116 + 15))
    cellSprite:setPosition(cc.p(320,70))
    local cellSize = cellSprite:getContentSize()
    custom_item:addChild(cellSprite)

    local rankLabel = nil
    local rankLabelList = {"c_75.png", "c_76.png", "c_77.png"}
    if index <= 3 then
        rankLabel = ui.newSprite(rankLabelList[index])
        rankLabel:setAnchorPoint(cc.p(0, 0.5))
        rankLabel:setPosition(cellSize.width * 0.065, cellSize.height * 0.5)
        cellSprite:addChild(rankLabel)
    else
	    -- 创建排名需求
	    local rankSprite = cc.Node:create()
	    rankSprite:setContentSize(cc.size(120,70))
	    rankSprite:setAnchorPoint(cc.p(0, 0.5))
	    rankSprite:setPosition(cc.p(5, cellSize.height * 0.5))
	    cellSprite:addChild(rankSprite)
	    local rankSize = rankSprite:getContentSize()

        if info.rankMin == info.rankMax then
            
            local rankLabel2 = ui.newLabel({
            text = TR("%s名", info.rankMin),
            size = 30,
            color = Enums.Color.eNormalWhite,
            })
            rankLabel2:setAnchorPoint(cc.p(0, 0.5))
            rankLabel2:setPosition(cc.p(45, rankSize.height * 0.5))
            rankSprite:addChild(rankLabel2)

        else
            local rankLabel1 = ui.newLabel({
            text = TR("%s", info.rankMin),
            size = 30,
            color = Enums.Color.eNormalWhite
            })
            rankLabel1:setAnchorPoint(cc.p(1.0, 0.5))
            rankLabel1:setPosition(cc.p(50, rankSize.height * 0.5))
            rankSprite:addChild(rankLabel1)

            local rankLabel2 = ui.newLabel({
                text = TR("~"),
                size = 30,
                color = Enums.Color.eNormalWhite
            })
            rankLabel2:setAnchorPoint(cc.p(0, 0.5))
            rankLabel2:setPosition(cc.p(50, rankSize.height * 0.5))
            rankSprite:addChild(rankLabel2)

            local rankLabel3 = ui.newLabel({
                text = TR("%s名", info.rankMax),
                size = 30,
                color = Enums.Color.eNormalWhite
            })
            rankLabel3:setAnchorPoint(cc.p(0.0, 0.5))
            rankLabel3:setPosition(cc.p(70, rankSize.height * 0.5))
            rankSprite:addChild(rankLabel3)
        end
    end

    local listview = ccui.ListView:create()
    listview:setDirection(ccui.ScrollViewDir.horizontal)
    listview:setBounceEnabled(true)
    listview:setContentSize(cc.size(450 + 20 + 10, 130))
    listview:setItemsMargin(3)
    listview:setSwallowTouches(false)
    listview:setAnchorPoint(cc.p(0, 0.5))
    listview:setPosition(self.mBackSize.width * 0.2 + 40 - 10 - 20, 60)
    cellSprite:addChild(listview)

	-- 创建物品
    local data = Utility.analysisStrResList(self.mRewardList[index].guildRewards)
       --dump(data)
    function createListCard(index)
        local info = data[index]
        local custom_item = ccui.Layout:create()
        local width = 250
        local height = 130
        custom_item:setContentSize(cc.size(width, height))
        -- 头像
        local heard = CardNode.createCardNode({
            resourceTypeSub = info.resourceTypeSub, -- 资源类型
            modelId = info.modelId,  -- 模型Id
            num = info.num, -- 资源数量
            cardShowAttrs = {
             CardShowAttr.eBorder
            }
        })
        heard:setPosition(cc.p(10, 65))
        heard:setAnchorPoint(cc.p(0, 0.5))
        custom_item:addChild(heard)
        -- 名字
        local nameFont = ui.newLabel({
            text = TR("%s",Utility.getGoodsName(info.resourceTypeSub, info.modelId)),
            color = Enums.Color.eNormalWhite,
            size = 20
            })
        nameFont:setAnchorPoint(cc.p(0, 0))
        nameFont:setPosition(cc.p(100, 65 + 4))

        custom_item:addChild(nameFont)
        -- 数量
        local nameNum = ui.newLabel({
            text = TR("数量:%s",info.num),
            color = Enums.Color.eNormalWhite,
            size = 20
            })
        nameNum:setAnchorPoint(cc.p(0, 1))
        nameNum:setPosition(cc.p(100, 65))
        custom_item:addChild(nameNum)

        return custom_item
    end
    for i=1,#data do
       listview:pushBackCustomItem(createListCard(i))
    end
    -- local headListView = ui.createCardList({
    --         cardDataList = data,
    --         maxViewWidth = 300, -- 显示的最大宽度
    --         space = 60, -- 卡牌
    --         -- needArrows = true,
    --     })
    -- headListView:setAnchorPoint(cc.p(0, 0.5))
    -- headListView:setPosition(cc.p(self.mBackSize.width * 0.3 + 20, 40 + 10))
    -- custom_item:addChild(headListView)

    return custom_item
end

return GGDHShopGuideRewardLayer