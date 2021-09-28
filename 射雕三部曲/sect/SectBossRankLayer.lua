--[[
    文件名：SectBossRankLayer.lua
    文件描述：门派boss排行榜
    创建人：yanghongsheng
    创建时间：2017.11.17
]]
local SectBossRankLayer = class("SectBossRankLayer",function()
    return display.newLayer()
end)

-- 自定义枚举（用于进行页面分页）
local TabPageTags = {
    ePersonRank = 1,	-- 个人排行
    eGuildRank = 2,		-- 帮派排行
    ePersonReward = 3,	-- 个人奖励
    eGuildReward = 4,	-- 帮派奖励
}

function SectBossRankLayer:ctor()
	-- 页面缓存
	self.mSubPageData = {}

	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(586, 730),
        title = TR("排行榜"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	-- 创建页面控件
	self:initUI()
end


function SectBossRankLayer:initUI()
	-- listbg
	local listBgSize = cc.size(self.mBgSize.width*0.9, self.mBgSize.height*0.7)
	local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
	listBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.46)
	self.mBgSprite:addChild(listBg)
	-- 提示文字
	local hintLabel = ui.newLabel({
			text = TR("魔教被击退后奖励在12:30通过领奖中心发放\n至少要攻击3次魔教才能获得奖励"),
			size = 22,
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
	hintLabel:setAnchorPoint(cc.p(0, 1))
	hintLabel:setPosition(listBgSize.width*0.05, listBgSize.height-10)
	listBg:addChild(hintLabel)
	self.hintLabel = hintLabel
	-- listview
	self.mListSize = cc.size(listBgSize.width-20, listBgSize.height-20)
	self.mListView = ccui.ListView:create()
	self.mListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mListView:setBounceEnabled(true)
	self.mListView:setContentSize(self.mListSize)
	self.mListView:setItemsMargin(5)
	self.mListView:setGravity(ccui.ListViewGravity.centerHorizontal)
	self.mListView:setAnchorPoint(cc.p(0.5, 0))
	self.mListView:setPosition(listBgSize.width*0.5, 10)
	listBg:addChild(self.mListView)
	-- tabView
	local tabView = self:createTabView()
	tabView:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.87)
	self.mBgSprite:addChild(tabView)
	-- myRank
	local myRankSize = cc.size(self.mBgSize.width*0.9, 54)
	local myRankBg = ui.newScale9Sprite("c_25.png", myRankSize)
	myRankBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.07)
	self.mBgSprite:addChild(myRankBg)

	local myRankLabel = ui.newLabel({
			text = "",
			size = 20,
			color = Enums.Color.eWhite,
			outlineColor = Enums.Color.eOutlineColor,
		})
	myRankLabel:setAnchorPoint(cc.p(0.5, 0.5))
	myRankLabel:setPosition(myRankSize.width*0.5, myRankSize.height*0.5)
	myRankBg:addChild(myRankLabel)
	self.myRankLabel = myRankLabel

	local AuctionBtn = ui.newButton({
		normalImage = "mjrq_24.png",
		clickAction = function()
			LayerManager.removeLayer(self)
            LayerManager.addLayer({name = "activity.AuctionHouseLayer", cleanUp = false,})			
		end
	})
	AuctionBtn:setPosition(40, 730)
	self.mBgSprite:addChild(AuctionBtn)
end

function SectBossRankLayer:createTabView()
	-- btnList
	local btnList = {
		{
			tag = TabPageTags.ePersonRank,
			text = TR("个人排行"),
		},
		{
			tag = TabPageTags.eGuildRank,
			text = TR("帮派排行"),
		},
		{
			tag = TabPageTags.ePersonReward,
			text = TR("个人奖励"),
		},
		{
			tag = TabPageTags.eGuildReward,
			text = TR("帮派奖励"),
		},
	}	

	local tabView = ui.newTabLayer({
			btnInfos = btnList,
			viewSize = cc.size(self.mBgSize.width*0.9, 80),
			btnSize = cc.size(116, 50),
			needLine = false,
			normalImage = "c_155.png",
			lightedImage = "c_154.png",
			defaultSelectTag = btnList[1].tag,
			onSelectChange = function (selectBtnTag)
				if self.curTag == selectBtnTag then return end

				self.curTag = selectBtnTag

				self:refreshLayer(selectBtnTag)
			end,
		})

	return tabView
end
-- 刷新界面
function SectBossRankLayer:refreshLayer(tag)
	self.mListView:removeAllChildren()
	-- 只有帮派排行才显示这个提示
	self.hintLabel:setVisible(false)
	-- 重试列表大小
	self.mListView:setContentSize(self.mListSize)
	-- 个人排行
	if tag == TabPageTags.ePersonRank then
		if self.mSubPageData[tag] then
			self:refreshPersonRank(self.mSubPageData[tag])
			self.myRankLabel:setString(TR("我的排名: %s        我的伤害: %s", self.mPlayerRank, Utility.numberWithUnit(self.mPlayerHarm)))
		else
			self:requestGetRankInfo(tag)
		end
	-- 帮派排行
	elseif tag == TabPageTags.eGuildRank then
		self.hintLabel:setVisible(true)
		self.mListView:setContentSize(cc.size(self.mListSize.width, self.mListSize.height-60))

		if self.mSubPageData[tag] then
			self:refreshGuildRank(self.mSubPageData[tag])
			self.myRankLabel:setString(TR("帮派排名: %s        帮派伤害: %s", self.mGuildRank, Utility.numberWithUnit(self.mGuildHarm)))
		else
			self:requestGetRankInfo(tag)
		end
	-- 个人奖励
	elseif tag == TabPageTags.ePersonReward then
		if not self.mSubPageData[tag] then
			self.mSubPageData[tag] = clone(WorldbossRewardRankpersonRelation.items)
		end
		self:refreshRewardList(self.mSubPageData[tag])
		self.myRankLabel:setString(TR("我的排名: %s        我的伤害: %s", self.mPlayerRank, Utility.numberWithUnit(self.mPlayerHarm)))
	-- 帮派奖励
	elseif tag == TabPageTags.eGuildReward then
		if not self.mSubPageData[tag] then
			self.mSubPageData[tag] = clone(WorldbossRewardRankguildRelation.items)
		end
		self:refreshRewardList(self.mSubPageData[tag])
		self.myRankLabel:setString(TR("帮派排名: %s        帮派伤害: %s", self.mGuildRank, Utility.numberWithUnit(self.mGuildHarm)))
	end
end
-- 刷新个人排行
function SectBossRankLayer:refreshPersonRank(listData)
	-- 空列表提示
	self:createEmptyHint(listData and next(listData) and true or false)
	-- 1，2，3排名图
	local rankTexture = {
		"c_44.png",
		"c_45.png",
		"c_46.png",
	}
	local function createCell(itemData)
		local cellSize = cc.size(self.mListSize.width, 140)
		local layout = ccui.Layout:create()
		layout:setContentSize(cellSize)
		-- 背景
		local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
		bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
		layout:addChild(bgSprite)
		-- 排名图
		local orderTexture = rankTexture[itemData.Rank] or "c_47.png"
		local rankSprite = ui.newSprite(orderTexture)
		rankSprite:setPosition(cellSize.width*0.1, cellSize.height*0.5)
		layout:addChild(rankSprite)
		-- 排名
		if itemData.Rank > 3 then
			local rankLabel = ui.newLabel({
					text = itemData.Rank,
					color = Enums.Color.eWhite,
					size = 20,
				})
			rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
			rankLabel:setPosition(rankSprite:getContentSize().width*0.5, rankSprite:getContentSize().height*0.5)
			rankSprite:addChild(rankLabel)
		end
		-- 人物头像
		local hardCard = CardNode.createCardNode({
				resourceTypeSub = ResourcetypeSub.eHero,
                modelId = itemData.HeadImageId,
                fashionModelID = itemData.FashionModelId,
                IllusionModelId = itemData.IllusionModelId,
  				pvpInterLv = itemData.DesignationId,
                allowClick = true,
                cardShowAttrs = {
                   CardShowAttr.eBorder,
                },
                onClickCallback = function ()
                	Utility.showPlayerTeam(itemData.PlayerId)
                end,
			})
		hardCard:setPosition(cellSize.width*0.3, cellSize.height*0.5)
		layout:addChild(hardCard)
		-- 玩家名字
		local nameLabel = ui.newLabel({
				text = itemData.PlayerName,
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 20,
			})
		nameLabel:setAnchorPoint(cc.p(0, 0.5))
		nameLabel:setPosition(cellSize.width*0.42, cellSize.height*0.7)
		layout:addChild(nameLabel)
		-- 玩家战力
		local fabLabel = ui.newLabel({
				text = TR("战斗力: %s", Utility.numberFapWithUnit(itemData.FAP)),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 20,
			})
		fabLabel:setAnchorPoint(cc.p(0, 0.5))
		fabLabel:setPosition(cellSize.width*0.42, cellSize.height*0.5)
		layout:addChild(fabLabel)
		-- 帮派
		local guildLabel = ui.newLabel({
				text = itemData.GuildName ~= "" and TR("帮派: %s", itemData.GuildName) or TR("暂无帮派"),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 20,
			})
		guildLabel:setAnchorPoint(cc.p(0, 0.5))
		guildLabel:setPosition(cellSize.width*0.42, cellSize.height*0.3)
		layout:addChild(guildLabel)
		-- 伤害
		local harmSprite = ui.newSprite("mjrq_26.png")
		harmSprite:setPosition(cellSize.width*0.9, cellSize.height*0.55)
		layout:addChild(harmSprite)

		local harmLabel = ui.newLabel({
				text = TR("%s", Utility.numberWithUnit(itemData.Harm)),
				color = Enums.Color.eWhite,
				size = 20,
			})
		harmLabel:setAnchorPoint(cc.p(0, 0.5))
		harmLabel:setPosition(60, harmSprite:getContentSize().height*0.5)
		harmSprite:addChild(harmLabel)

		return layout
	end

	for _, itemData in pairs(listData) do
		local item = createCell(itemData)
		self.mListView:pushBackCustomItem(item)
	end

	self.mListView:jumpToTop()
end

function SectBossRankLayer:refreshGuildRank(listData)
	-- 空列表提示
	self:createEmptyHint(listData and next(listData) and true or false)

	-- 1，2，3排名图
	local rankTexture = {
		"c_44.png",
		"c_45.png",
		"c_46.png",
	}
	local function createCell(itemData)
		local cellSize = cc.size(self.mListSize.width, 140)
		local layout = ccui.Layout:create()
		layout:setContentSize(cellSize)
		-- 背景
		local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
		bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
		layout:addChild(bgSprite)
		-- 排名图
		local orderTexture = rankTexture[itemData.Rank] or "c_47.png"
		local rankSprite = ui.newSprite(orderTexture)
		rankSprite:setPosition(cellSize.width*0.1, cellSize.height*0.5)
		layout:addChild(rankSprite)
		-- 排名
		if itemData.Rank > 3 then
			local rankLabel = ui.newLabel({
					text = itemData.Rank,
					color = Enums.Color.eWhite,
					size = 20,
				})
			rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
			rankLabel:setPosition(rankSprite:getContentSize().width*0.5, rankSprite:getContentSize().height*0.5)
			rankSprite:addChild(rankLabel)
		end
		-- 帮派名
		local guildLabel = ui.newLabel({
				text = itemData.GuildName ~= "" and TR("帮派: %s", itemData.GuildName) or TR("#FF4A46该帮派已解散"),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 24,
			})
		guildLabel:setAnchorPoint(cc.p(0, 0.5))
		guildLabel:setPosition(cellSize.width*0.2, cellSize.height*0.7)
		layout:addChild(guildLabel)
		-- 帮派等级
		local lvLabel = ui.newLabel({
				text = TR("等级: %d", itemData.Lv or 0),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 24,
			})
		lvLabel:setAnchorPoint(cc.p(0, 0.5))
		lvLabel:setPosition(cellSize.width*0.2, cellSize.height*0.3)
		layout:addChild(lvLabel)
		-- 伤害
		local harmSprite = ui.newSprite("mjrq_26.png")
		harmSprite:setPosition(cellSize.width*0.85, cellSize.height*0.45)
		layout:addChild(harmSprite)

		local harmLabel = ui.newLabel({
				text = TR("%s", Utility.numberWithUnit(itemData.Harm)),
				color = Enums.Color.eWhite,
				size = 20,
			})
		harmLabel:setAnchorPoint(cc.p(0, 0.5))
		harmLabel:setPosition(60, harmSprite:getContentSize().height*0.5)
		harmSprite:addChild(harmLabel)

		return layout
	end

	for _, itemData in pairs(listData) do
		local item = createCell(itemData)
		self.mListView:pushBackCustomItem(item)
	end

	self.mListView:jumpToTop()
end

function SectBossRankLayer:refreshRewardList(listData)
	-- 空列表提示
	self:createEmptyHint(listData and next(listData) and true or false)

	-- 1，2，3排名图
	local rankTexture = {
		"c_44.png",
		"c_45.png",
		"c_46.png",
	}
	local function createCell(itemData)
		local cellSize = cc.size(self.mListSize.width, 140)
		local layout = ccui.Layout:create()
		layout:setContentSize(cellSize)
		-- 背景
		local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
		bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
		layout:addChild(bgSprite)
		-- 排名图
		local orderTexture = rankTexture[itemData.rankMax] or "c_47.png"
		local rankSprite = ui.newSprite(orderTexture)
		rankSprite:setPosition(cellSize.width*0.1, cellSize.height*0.5)
		layout:addChild(rankSprite)
		-- 排名
		if itemData.rankMax > 3 then
			local rankLabel = ui.newLabel({
					text = TR("%d~%d", itemData.rankMax, itemData.rankMin),
					color = Enums.Color.eWhite,
					size = 20,
				})
			rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
			rankLabel:setPosition(rankSprite:getContentSize().width*0.5, rankSprite:getContentSize().height*0.5)
			rankSprite:addChild(rankLabel)
		end
		-- 资料列表
		local resList = Utility.analysisStrResList(itemData.reward or itemData.guildReward)
		local resCardList = ui.createCardList({
				maxViewWidth = cellSize.width*0.75,
				cardDataList = resList,
			})
		resCardList:setAnchorPoint(cc.p(0, 0.5))
		resCardList:setPosition(cellSize.width*0.2, cellSize.height*0.5)
		layout:addChild(resCardList)

		return layout
	end

	for _, itemData in pairs(listData) do
		local item = createCell(itemData)
		self.mListView:pushBackCustomItem(item)
	end

	self.mListView:jumpToTop()
end

function SectBossRankLayer:createEmptyHint(isHave)
	if not self.emptyHintSprite then
		self.emptyHintSprite = ui.createEmptyHint(TR("暂无排行"))
	    self.emptyHintSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height * 0.5)
	    self.mBgSprite:addChild(self.emptyHintSprite)
	end

	self.emptyHintSprite:setVisible(not isHave)
end


--=============================================网络请求===============================
--请求信息
function SectBossRankLayer:requestGetRankInfo(tag)
	HttpClient:request({
        moduleName = "WorldBossInfo",
        methodName = "GetRankInfo",
        svrMethodData = {tag},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mPlayerRank = response.Value.PlayerRank == 0 and TR("未上榜") or tostring(response.Value.PlayerRank) 	-- 我的排名
            self.mPlayerHarm = response.Value.PlayerHarm 	-- 我的伤害
            self.mGuildRank = response.Value.GuildRank == 0 and TR("未上榜") or tostring(response.Value.GuildRank)		-- 帮派排名
            self.mGuildHarm = response.Value.GuildHarm 		-- 帮派伤害

            -- 个人排名
            if response.Value.PersonalRankList then
            	self.mSubPageData[tag] = response.Value.PersonalRankList
            	self:refreshPersonRank(response.Value.PersonalRankList)
            	self.myRankLabel:setString(TR("我的排名: %s        我的伤害: %s", self.mPlayerRank, Utility.numberWithUnit(self.mPlayerHarm)))
            -- 帮派排名
            elseif response.Value.GuildRankList then
            	self.mSubPageData[tag] = response.Value.GuildRankList
            	self:refreshGuildRank(response.Value.GuildRankList)
            	self.myRankLabel:setString(TR("帮派排名: %s        帮派伤害: %s", self.mGuildRank, Utility.numberWithUnit(self.mGuildHarm)))
            end
        end
    })
end


return SectBossRankLayer