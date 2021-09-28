--[[
    文件名：PvpTopRewardSubLayer.lua
    描述： 武林盟主奖励子界面
    创建人：yanghongsheng
    创建时间：2017.11.2
-- ]]
local PvpTopRewardSubLayer = class("PvpTopRewardSubLayer", function(params)
	return display.newLayer()
end)

function PvpTopRewardSubLayer:ctor()
	-- 设置父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 初始化界面
    self:initUI()
end

function PvpTopRewardSubLayer:initUI()
	-- 第一的背景
	local firstBgSprite = ui.newSprite("wlmz_06.png")
	firstBgSprite:setPosition(320, 770)
	self.mParentLayer:addChild(firstBgSprite)
	-- 获取背景大小
	local firstBgSize = firstBgSprite:getContentSize()
	-- 第一图片
	local fristSprite = ui.newSprite("wlmz_07.png")
	fristSprite:setAnchorPoint(cc.p(0, 0.5))
	fristSprite:setPosition(firstBgSize.width*0.05, firstBgSize.height*0.6)
	firstBgSprite:addChild(fristSprite)
	-- 第一奖励粗略列表背景
	local cardListBgSize = cc.size(540, 105)
	local cardListBg = ui.newScale9Sprite("c_17.png", cardListBgSize)
	cardListBg:setAnchorPoint(cc.p(0, 1))
	cardListBg:setPosition(firstBgSize.width*0.07, firstBgSize.height*0.32)
	firstBgSprite:addChild(cardListBg)
	-- 第一奖励数据
	local firstRewardData = PvpinterTopRewardRelation.items[1][1]
	local rewardList = Utility.analysisStrResList(firstRewardData.reward)
	for _, cardData in pairs(rewardList) do
		cardData.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
	end
	-- 第一奖励粗略列表
	local firstRewardList = ui.createCardList({
			maxViewWidth = 540,
			cardDataList = rewardList,
		})
	-- firstRewardList:setScale(0.8)
	firstRewardList:setAnchorPoint(cc.p(0, 0.5))
	firstRewardList:setPosition(0, cardListBgSize.height*0.4)
	cardListBg:addChild(firstRewardList)
	self.firstRewardList = firstRewardList
	
	-- 头像框
	local frameEffect = ui.newEffect({
				parent = firstBgSprite,
				position = cc.p(firstBgSize.width*0.5, firstBgSize.height*0.62),
				effectName = "effect_ui_wulinmengzhu",
				loop = true,
			})
	-- 头像名字
	local frameName = ui.newLabel({
			text = TR("头像框"),
			size = 22,
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
	frameName:setAnchorPoint(cc.p(0, 0))
	frameName:setPosition(firstBgSize.width*0.62, firstBgSize.height*0.7)
	firstBgSprite:addChild(frameName)
	-- 描述
	local descLabel = ui.newLabel({
			text = TR("武林盟主专属霸气头像框"),
			size = 22,
			color = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(firstBgSize.width*0.3, 0)
		})
	descLabel:setAnchorPoint(cc.p(0, 1))
	descLabel:setPosition(firstBgSize.width*0.62, firstBgSize.height*0.6)
	firstBgSprite:addChild(descLabel)

	-- 其他人排名背景
	local otherBgSize = cc.size(610, 430)
	local otherBgSprite = ui.newScale9Sprite("c_17.png", otherBgSize)
	otherBgSprite:setPosition(320, 330)
	self.mParentLayer:addChild(otherBgSprite)
	-- 其人奖励列表
	local otherRewardInfoList = ccui.ListView:create()
	otherRewardInfoList:setDirection(ccui.ScrollViewDir.vertical)
	otherRewardInfoList:setBounceEnabled(true)
	otherRewardInfoList:setContentSize(cc.size(otherBgSize.width, otherBgSize.height*0.84))
	otherRewardInfoList:setItemsMargin(5)
	otherRewardInfoList:setGravity(ccui.ListViewGravity.centerHorizontal)
	otherRewardInfoList:setAnchorPoint(cc.p(0.5, 0.5))
	otherRewardInfoList:setPosition(otherBgSize.width*0.5, otherBgSize.height*0.55)
	otherBgSprite:addChild(otherRewardInfoList)
	self.otherRewardInfoList = otherRewardInfoList
	-- 下拉提示图
	local hintSprite = ui.newSprite("c_43.png")
	hintSprite:setPosition(otherBgSize.width*0.5, otherBgSize.height*0.05)
	otherBgSprite:addChild(hintSprite)
	-- 初始化列表
	self:refreshOtherList()
end

-- 更新2强到32强奖励列表
function PvpTopRewardSubLayer:refreshOtherList()
	self.otherRewardInfoList:removeAllChildren()
	-- 排位图
	local orderTextureList = {	"wlmz_08.png",	-- 第二
								"wlmz_09.png",	-- 4强
								"wlmz_10.png",	-- 8强
								"wlmz_11.png",	-- 16强
								"wlmz_12.png"	-- 32强
							}
	for key, texture in ipairs(orderTextureList) do
		local item = self:createOtherCell(key, texture)
		if item then
			self.otherRewardInfoList:pushBackCustomItem(item)
		end
	end
end
-- 创建2强到32强各个项
function PvpTopRewardSubLayer:createOtherCell(order, texture)
	-- 获取配置表中奖励信息
	local rankMax = math.pow(2, order)
	local rankMin = rankMax/2 + 1
	local rewardData = PvpinterTopRewardRelation.items[rankMax][rankMin]
	if not rewardData then return end
	-- 项大小
	local itemSize = cc.size(self.otherRewardInfoList:getContentSize().width-10, 140)

	local layout = ccui.Layout:create()
	layout:setContentSize(itemSize)
	-- 背景
	local bgSprite = ui.newScale9Sprite("c_18.png", itemSize)
	bgSprite:setPosition(itemSize.width*0.5, itemSize.height*0.5)
	layout:addChild(bgSprite)
	-- 排名图表
	local rankSprite = ui.newSprite(texture)
	rankSprite:setPosition(itemSize.width*0.15, itemSize.height*0.5)
	layout:addChild(rankSprite)
	-- 奖励列表
	local rewardList = Utility.analysisStrResList(rewardData.reward)
	local rewardCardList = ui.createCardList({
			maxViewWidth = itemSize.width*0.65,
			cardDataList = rewardList,
		})
	rewardCardList:setAnchorPoint(cc.p(0, 0.5))
	rewardCardList:setPosition(itemSize.width*0.3, itemSize.height*0.5)
	layout:addChild(rewardCardList)
	rewardCardList:setSwallowTouches(false)

	return layout
end


return PvpTopRewardSubLayer