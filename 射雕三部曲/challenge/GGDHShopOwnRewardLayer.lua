--[[
    文件名：GGDHShopOwnRewardLayer.lua
    描述： 序列争霸商城个人奖励页面
    创建人：wusonglin
    创建时间：2016.6.20
-- ]]

local GGDHShopOwnRewardLayer = class("GGDHShopOwnRewardLayer", function(params)
	return display.newLayer()
end)


-- 自定义枚举（用于进行页面分页）
local TabPageTags = {
    eTagThreeReward = 1,  -- 豪侠令兑换页面
    eTagDailyReward = 2,  -- 排名奖励页面
}

--初始化页面
--[[
params:
    Table params:
    layerSize: 可选参数，页面的大小
    rank:      必须的参数，玩家的排名
    signupData 赛季数据
--]]
function GGDHShopOwnRewardLayer:ctor(params)
    -- 屏蔽下层事件
    -- ui.registerSwallowTouch({node = self})
   
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
    self.mSeasonRewardList = {} --赛季奖励
    self.mDailyRewardList = {}  --每日奖励
    -- 对每日，三日列表进行处理
    for i, v in pairs(GddhRankRewardRelation.items) do
    	
        if v.seasonReward ~= "" and v.rewardsType == tempType then
            table.insert(self.mSeasonRewardList, {rankMin = v.rankMin, rankMax = v.rankMax, seasonReward = Utility.analysisStrResList(v.seasonReward)})
        end
        if v.rankMin ~= 0 and v.rewardsType == tempType then
            print("次数---->"..i)
            table.insert(self.mDailyRewardList, {rankMin = v.rankMin, rankMax = v.rankMax, dailyReward = v.perRewardRawGold})
        end
    end
    
    -- 对每日，三日列表进行顺序整理
    table.sort(self.mSeasonRewardList, function(a, b) return a.rankMin < b.rankMin end)
    table.sort(self.mDailyRewardList, function(a, b) return a.rankMin < b.rankMin end)

    self.mTitleLabel = nil

    self.mListView = nil

    -- 创建原始界面
    self:setUI()
end

function GGDHShopOwnRewardLayer:setUI()
    local bgSprite = cc.Node:create()
   	bgSprite:setContentSize(cc.size(640,1136))
    self.mBackSize = cc.size(640,1136)
    self.mBackSprite = bgSprite
    self.mParentLayer:addChild(bgSprite)

    -- 创建分页
    self:showTabLayer()
end

-- 创建分页,进行分页显示
function GGDHShopOwnRewardLayer:showTabLayer()
    -- 创建分页
    local function cellOfPage(selectBtnTag)
        if tag == TabPageTags.eTagThreeReward then
            self:showThreeRewardLayer(parent)
        elseif tag == TabPageTags.eTagDailyReward then
            self:showRDailyRewardLayer(parent)
            self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_LEFTTORIGHT)
        end
    end
     
    --刷新页面
    local function refreshPage(selectBtnTag)
        -- 执行刷新页面操作
        if selectBtnTag == TabPageTags.eTagThreeReward then
            if self.mListView ~= nil then
                self:showThreeRewardLayer()
            end
        elseif selectBtnTag == TabPageTags.eTagDailyReward then
            if self.mListView ~= nil then
                self:showRDailyRewardLayer()
            end
        end
    end

    -- 创建分页
    self.tabLayer = ui.newTabLayer({
        btnInfos = {
            {
                text = TR("赛季大奖"),
                tag  = TabPageTags.eTagThreeReward
            },
            {
                text = TR("每日奖励"),
                tag  = TabPageTags.eTagDailyReward
            },
       	 },
        normalImage  = "c_28.png",
        lightedImage = "c_61.png",
        btnSize = cc.size(135, 60),
       	allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            refreshPage(selectBtnTag)
        end,
        needLine = false,
    })
    self.tabLayer:setPosition(cc.p(320,870))
    self.mBackSprite:addChild(self.tabLayer) 
    local tabBtns = self.tabLayer:getTabBtns()
    for i = 1, #tabBtns do
        tabBtns[i]:setTitleRateY(0.5)
    end

    self:showThreeRewardLayer()
end

-- 创建三日大奖layer
--[[
params:
    parent:父节点
]]--
function GGDHShopOwnRewardLayer:showThreeRewardLayer()
    if self.mTitleLabel then 
    	self.mTitleLabel:removeFromParent()
    	self.mTitleLabel = nil
    end

    self.mTitleLabel = ui.createLabelWithBg({
            bgFilename = "c_103.png",  
            bgSize = cc.size(612, 81),
            fontSize = 28,  
            labelStr = TR("每周#8EF20D一、三、五23点%s发放一次奖励，积分重置",Enums.Color.eWhiteH),
            outlineColor = Enums.Color.eBlack,
            alignType = ui.TEXT_ALIGN_CENTER,
        })
    
    -- self.mTitleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.mTitleLabel:setPosition(cc.p(320, 950))
    self.mParentLayer:addChild(self.mTitleLabel)

    -- 创建ListView列表
    if self.mListView ~= nil then
        self.mListView:removeAllChildren()
        for i = 1, #self.mSeasonRewardList do
            self.mListView:pushBackCustomItem(self:createThreeRewardView(i))
        end
        -- self.mListView:jumpToTop()
    else
    	self.mListView = ccui.ListView:create()
    	self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    	self.mListView:setBounceEnabled(true)
   		self.mListView:setContentSize(cc.size(self.mBackSize.width, 710))
    	self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
   		self.mListView:setItemsMargin(5)
    	self.mListView:setAnchorPoint(cc.p(0.5, 1))
        self.mListView:setPosition(320, 830)
    	self.mBackSprite:addChild(self.mListView)

		-- 添加数据
		for i = 1, #self.mSeasonRewardList do
		    self.mListView:pushBackCustomItem(self:createThreeRewardView(i))
		end
    end
    
end

-- 创建三日大奖View
--[[
params:
    index: cell条目
]]--
function GGDHShopOwnRewardLayer:createThreeRewardView(index)
    -- 创建custom_item
    local custom_item = ccui.Layout:create()
    local width = self.mBackSize.width
    local height = 140
    custom_item:setContentSize(cc.size(width, 110))

    -- 创建cell
    -- local rankSpriteList = {"c_16.png", "c_16.png", "c_16.png"}
    -- local rankSpriteImage = nil
    -- if index <= 3 then
    --     rankSpriteImage = rankSpriteList[index]
    -- else
    --     rankSpriteImage = "c_16.png"
    -- end

    local cellSprite = ui.newScale9Sprite("c_16.png",cc.size(630, 110))
    cellSprite:setPosition(cc.p(320,55))
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
	    rankSprite:setPosition(cc.p(15 - 20, cellSize.height * 0.5))
	    cellSprite:addChild(rankSprite)
	    local rankSize = rankSprite:getContentSize()

        if self.mSeasonRewardList[index].rankMin == self.mSeasonRewardList[index].rankMax then
            
            local rankLabel2 = ui.newLabel({
                text = TR("%s名", self.mSeasonRewardList[index].rankMin),
                size = 30,
                font = _FONT_PANGWA,
                color = Enums.Color.eNormalWhite,
            })
            rankLabel2:setAnchorPoint(cc.p(0, 0.5))
            rankLabel2:setPosition(cc.p(50 + 5, rankSize.height * 0.5))
            rankSprite:addChild(rankLabel2)

        else
            local rankLabel1 = ui.newLabel({
            text = TR("%s", self.mSeasonRewardList[index].rankMin),
            size = 30,
            font = _FONT_PANGWA,
            color = Enums.Color.eNormalWhite
            })
            rankLabel1:setAnchorPoint(cc.p(1.0, 0.5))
            rankLabel1:setPosition(cc.p(50 + 5, rankSize.height * 0.5))
            rankSprite:addChild(rankLabel1)

            local rankLabel2 = ui.newLabel({
                text = TR("~"),
                size = 30,
                font = _FONT_PANGWA,
                color = Enums.Color.eNormalWhite
            })
            rankLabel2:setAnchorPoint(cc.p(0, 0.5))
            rankLabel2:setPosition(cc.p(50 + 5, rankSize.height * 0.5))
            rankSprite:addChild(rankLabel2)

            local rankLabel3 = ui.newLabel({
                text = TR("%s名", self.mSeasonRewardList[index].rankMax),
                size = 30,
                font = _FONT_PANGWA,
                color = Enums.Color.eNormalWhite
            })
            rankLabel3:setAnchorPoint(cc.p(0, 0.5))
            rankLabel3:setPosition(cc.p(75, rankSize.height * 0.5))
            rankSprite:addChild(rankLabel3)
        end

	    
    end

    local listview = ccui.ListView:create()
    listview:setDirection(ccui.ScrollViewDir.horizontal)
    listview:setBounceEnabled(true)
    listview:setContentSize(cc.size(450, 130))
    listview:setItemsMargin(3)
    listview:setSwallowTouches(false)
    listview:setAnchorPoint(cc.p(0, 0.5))
    listview:setPosition(self.mBackSize.width * 0.2 + 40, 60)
    cellSprite:addChild(listview)

    -- 创建物品
    local data = self.mSeasonRewardList[index].seasonReward
    --dump(data)
    --  创建每一条＝
    function createListCard(index)
        local info = data[index]
        local custom_item = ccui.Layout:create()
        local width = 230
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
        heard:setPosition(cc.p(10, 60))
        heard:setAnchorPoint(cc.p(0, 0.5))
        custom_item:addChild(heard)
        -- 名字
        local nameFont = ui.newLabel({
            text = TR("%s",Utility.getGoodsName(info.resourceTypeSub, info.modelId)),
            color = Enums.Color.eNormalWhite
            })
        nameFont:setAnchorPoint(cc.p(0, 0))
        nameFont:setPosition(cc.p(100, 65))
        custom_item:addChild(nameFont)
        -- 数量
        local nameNum = ui.newLabel({
            text = TR("数量:%s",info.num),
            color = Enums.Color.eNormalWhite
            })
        nameNum:setAnchorPoint(cc.p(0, 1))
        nameNum:setPosition(cc.p(100, 60))
        custom_item:addChild(nameNum)

        return custom_item
    end
    for i=1,#data do
       listview:pushBackCustomItem(createListCard(i))
    end

    return custom_item
end

-- 创建每日奖励layer
--[[
params:
    parent:父节点
]]--
function GGDHShopOwnRewardLayer:showRDailyRewardLayer()
    -- 显示顶部lable

    if self.mTitleLabel then 
    	self.mTitleLabel:removeFromParent()
    	self.mTitleLabel = nil
    end

    self.mTitleLabel = ui.createLabelWithBg({
            bgFilename = "c_103.png",  
            bgSize = cc.size(612, 81),
            fontSize = 28,  
            labelStr = TR("每日#8EF20D23点%s发放一次奖励，积分不重置",Enums.Color.eNormalWhiteH),
            outlineColor = Enums.Color.eBlack,
            alignType = ui.TEXT_ALIGN_CENTER,
        })
    
    self.mTitleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.mTitleLabel:setPosition(cc.p(320,950))
    self.mParentLayer:addChild(self.mTitleLabel)

    -- 创建listView
    if self.mListView ~= nil then
        self.mListView:removeAllChildren()
        for i = 1, #self.mDailyRewardList do
            self.mListView:pushBackCustomItem(self:createDailyRewardView(i))
        end
        self.mListView:jumpToTop()
    end
end

-- 创建每日奖励View
--[[
params:
    parent:父节点
    index: cell条目
]]--
function GGDHShopOwnRewardLayer:createDailyRewardView(index)
    -- 创建custom_item
    local custom_item = ccui.Layout:create()
    local width = self.mBackSize.width
    local height = 110
    custom_item:setContentSize(cc.size(width, height))

    -- 创建cell
    local rankSpriteList = {"c_16.png", "c_16.png", "c_16.png"}
    local rankSpriteImage = nil
    if index <= 3 then
        rankSpriteImage = rankSpriteList[index]
    else
        rankSpriteImage = "c_16.png"
    end
    
    local cellSprite = ui.newScale9Sprite(rankSpriteImage,cc.size(630, 110))
    cellSprite:setPosition(cc.p(320,55))
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
	    rankSprite:setPosition(cc.p(15, cellSize.height * 0.5))
	    cellSprite:addChild(rankSprite)
	    local rankSize = rankSprite:getContentSize()

        if self.mDailyRewardList[index].rankMin == self.mDailyRewardList[index].rankMax then

            local rankLabel2 = ui.newLabel({
                text = TR("%s名", self.mDailyRewardList[index].rankMin),
                size = 30,
                font = _FONT_PANGWA,
                color = Enums.Color.eNormalWhite
            })
            rankLabel2:setAnchorPoint(cc.p(0, 0.5))
            rankLabel2:setPosition(cc.p(40, rankSize.height * 0.5))
            rankSprite:addChild(rankLabel2)

        else
            local rankLabel1 = ui.newLabel({
            text = TR("%s", self.mDailyRewardList[index].rankMin),
            size = 30,
            font = _FONT_PANGWA,
            color = Enums.Color.eNormalWhite
            })
            rankLabel1:setAnchorPoint(cc.p(1.0, 0.5))
            rankLabel1:setPosition(cc.p(50, rankSize.height * 0.5))
            rankSprite:addChild(rankLabel1)

            local rankLabel2 = ui.newLabel({
                text = TR("~"),
                size = 30,
                font = _FONT_PANGWA,
                color = Enums.Color.eNormalWhite
            })
            rankLabel2:setAnchorPoint(cc.p(0, 0.5))
            rankLabel2:setPosition(cc.p(50, rankSize.height * 0.5))
            rankSprite:addChild(rankLabel2)

            local rankLabel3 = ui.newLabel({
                text = TR("%s名", self.mDailyRewardList[index].rankMax),
                size = 30,
                font = _FONT_PANGWA,
                color = Enums.Color.eNormalWhite
            })
            rankLabel3:setAnchorPoint(cc.p(0, 0.5))
            rankLabel3:setPosition(cc.p(65 , rankSize.height * 0.5))
            rankSprite:addChild(rankLabel3)
        end
	    
    end

    --设置物品头像
    local header = CardNode.createCardNode({
    	resourceTypeSub = ResourcetypeSub.eGold, -- 资源类型
        num = self.mDailyRewardList[index].dailyReward * PlayerAttrObj:getPlayerAttrByName("Lv"), -- 资源数量
        cardShowAttrs = {
             CardShowAttr.eBorder
            }
		})
	header:setAnchorPoint(cc.p(0.5, 0.5))
    header:setPosition(cc.p(cellSize.width * 0.5 , 55))
    custom_item:addChild(header)

    -- 名字
    local nameFont = ui.newLabel({
        text = TR("%s",Utility.getGoodsName(ResourcetypeSub.eGold)),
        color = Enums.Color.eNormalWhite
        })
    nameFont:setAnchorPoint(cc.p(0, 0))
    nameFont:setPosition(cc.p(cellSize.width * 0.5 + 50, 65))
    custom_item:addChild(nameFont)
    -- 数量
    local numCoin = self.mDailyRewardList[index].dailyReward * PlayerAttrObj:getPlayerAttrByName("Lv")
    local nameNum = ui.newLabel({
        text = TR("数量：%s",Utility.numberWithUnit(numCoin)),
        color = Enums.Color.eNormalWhite
        })
    nameNum:setAnchorPoint(cc.p(0, 1))
    nameNum:setPosition(cc.p(cellSize.width * 0.5 + 50, 60))
    custom_item:addChild(nameNum)

    return custom_item
end

return GGDHShopOwnRewardLayer