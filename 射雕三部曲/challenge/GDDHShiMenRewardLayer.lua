--[[
	文件名：GDDHGuideRewardLayer.lua
	描述：武林大会排行榜帮派排名页面
	创建人：liucunxin
	创建时间：2016.1.3
--]]

local GDDHGuideRewardLayer = class("GDDHGuideRewardLayer", function()
    return display.newLayer()
end)

-- 构造函数
function GDDHGuideRewardLayer:ctor(params)
	-- 测试数据
	---------------
	-- self.mTestData = {}
	-- local tempData = {
	-- 	rank = 5,
	-- 	name = "1111111111",
	-- 	integral = "555",
	-- 	lv = 10
	-- }
	-- for i = 1, 10 do
	-- 	table.insert(self.mTestData, tempData)
	-- end

	-- self.mTestReward = Utility.analysisStrResList("1111,0,100||1111,0,100")
	-- for i,v in ipairs(self.mTestReward) do
	-- 	v.cardShowAttrs = {
	--             CardShowAttr.eBorder,
	--             CardShowAttr.eNum
	--         }
 --    end

	----------------
    -- 计算当前是何赛季
    self.mSignupData = params and params.signupData
    local tempType = 0
    local period = math.abs(self.mSignupData.EndRewardDate - self.mSignupData.FirstRewardDate)
    if period <= 60 * 60 *24 * 2 then
        tempType = 1        -- 两日大奖
    else
        tempType = 0        -- 三日大奖
    end
    -- 奖励列表
    self.mRewardInfo = {}
    for _, v in ipairs(GddhGuildrewardRelation.items) do
        if v.rewardsType == tempType then
            table.insert(self.mRewardInfo, v)
        end
    end

    -- 奖励列表排序
    table.sort(self.mRewardInfo, function(a, b) return a.rankMin < b.rankMin end)

    -- 配置配置表数据
	self:initUI()
end

function GDDHGuideRewardLayer:initUI()
	-- 创建规则说明
	-- -- 规则父节点
	-- local ruleIntroduce = ui.newScale9Sprite("c_124.png", cc.size(630, 120))
	-- ruleIntroduce:setAnchorPoint(cc.p(0, 0))
	-- ruleIntroduce:setPosition(cc.p(5, 860))
	-- self:addChild(ruleIntroduce)
	-- 规则
	local ruleLabel = ui.newLabel({
		text = TR("每周一、三、五的23点发放一次奖励\n1、帮派积分前5名\n2、对应帮派中积分大于2000的队员"),
        color = cc.c3b(0x59, 0x28, 0x17),
        -- outlineColor = Enums.Color.eWineRed,
        size = 24,
		})
	ruleLabel:setPosition(cc.p(320, 900))
	self:addChild(ruleLabel)
	-- 创建列表
	self:createListView()
end

-- 创建listview
function GDDHGuideRewardLayer:createListView()
    --灰色背景
    local underBgSprite = ui.newScale9Sprite("c_17.png", cc.size(606, 700))
    underBgSprite:setAnchorPoint(0.5, 1)
    underBgSprite:setPosition(320, 820)
    self:addChild(underBgSprite)

	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(640, 680))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setItemsMargin(10)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(345, 810)
    self:addChild(self.mListView)

    for _, v in ipairs(self.mRewardInfo) do
        -- local cell = self:createItem(v)
        -- cell:setAnchorPoint(cc.p(0.5, 0.5))
    	self.mListView:pushBackCustomItem(self:createItem(v))
    end
end

-- 创建条目
function GDDHGuideRewardLayer:createItem(data)
	-- 创建cell
    local width, height = 590, 126
    local customCell = ccui.Layout:create()
    -- customCell:setPosition(cc.p(self.mListView:getContentSize().width * 0.5, 0))
    customCell:setContentSize(cc.size(width, height))
	-- 背景条
	local bgSprite = ui.newScale9Sprite("c_18.png", cc.size(width, height))
    bgSprite:setPosition(width*0.5, height*0.5)
	customCell:addChild(bgSprite)

	local rankPic = nil
    if data.rankMin == 1 then
        rankPic = "c_44.png"
    elseif data.rankMin == 2 then
        rankPic = "c_45.png"
    elseif data.rankMin == 3 then
        rankPic = "c_46.png"
    end

 	-- 排名
    if rankPic then
        local rankSpr = ui.newSprite(rankPic)
        rankSpr:setPosition(width * 0.13, height * 0.5)
        customCell:addChild(rankSpr)
    else
        local tempText = (data.rankMin == data.rankMax) and TR("%d", data.rankMax)
            or TR("%d ~ %d", data.rankMin, data.rankMax)
        if (data.rankMin ~= data.rankMax) then    
        	local rankLable = ui.newLabel({
        		text = tempText,
                size = 26,
                color = Enums.Color.eBlack,
    		})
    		rankLable:setPosition(width * 0.13, height * 0.5)
        	customCell:addChild(rankLable)
        else     
            local rankLabel = ui.createSpriteAndLabel({
                imgName = "c_47.png",
                labelStr = tempText,
                fontColor = Enums.Color.eNormalWhite,
                fontSize = 40
            })
            rankLabel:setPosition(cc.p(width * 0.13, height * 0.5))
            customCell:addChild(rankLabel)
        end     
    end

    -- 掉落资源
    local tempRewardList = Utility.analysisStrResList(data.guildRewards)
    for _,v in ipairs(tempRewardList) do
        v.cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eNum
        }
    end
    local dropRes = ui.createCardList({
    	cardDataList = tempRewardList,
    	space = 50
    })
    dropRes:setAnchorPoint(cc.p(0, 0.5))
    dropRes:setPosition(cc.p(width * 0.3, height * 0.35))
    customCell:addChild(dropRes)
    -- else
    --     if rewardInfo.rankMin == rewardInfo.rankMax then
    --         local rankLabel = ui.newLabel({
    --             text = TR(rewardInfo.rankMin),
    --             color = Enums.Color.eYellow,
    --             x = tempSize.width * 0.13,
    --             y = tempSize.height * 0.5,
    --             size = 24,
    --             align = ui.TEXT_ALIGN_CENTER
    --         })
    --         cellBg:addChild(rankLabel)
    --     else
    --          local rankLabel = ui.newLabel({
    --             text = TR("%s ~ %s", rewardInfo.rankMin, rewardInfo.rankMax),
    --             color = Enums.Color.eNormalBlue,
    --             x = tempSize.width * 0.13,
    --             y = tempSize.height * 0.5,
    --             size = 24,
    --             align = ui.TEXT_ALIGN_CENTER
    --         })
    --         cellBg:addChild(rankLabel)
        -- end
    -- end
    return customCell
end

return GDDHGuideRewardLayer
