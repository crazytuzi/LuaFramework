--[[
	文件名：GuildPvpReportLayer.lua
	描述：帮派战报名界面
	创建人：yanghongsheng
	创建时间： 2017.1.2
--]]

local GuildPvpReportLayer = class("GuildPvpReportLayer", function(params)
	return display.newLayer()
end)

local FightResultTag = {
		eWin = 1,
		eLose = -1,
		eDeuce = 0,
		eTotal = 2,
	}

function GuildPvpReportLayer:ctor()
	-- 战报信息
	self.mReportInfo = {}
	-- 胜利场数
	self.mWinNum = 0
	-- 失败场数
	self.mLoseNum = 0
	-- 平局场数
	self.mDeuceNum = 0
	-- 总场数
	self.mTotalNum = 0
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(615, 895),
        title = TR("往期战报"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	-- 创建页面控件
	self:initUI()

	-- 请求帮派战报信息
	self:requestInfo()
end

function GuildPvpReportLayer:initUI()
	local space = self.mBgSize.width/3-50
	-- 胜利，战败，平局，总计四个标签列表
	self.ResultTagList = {
		-- 胜利
		[FightResultTag.eWin] = {
			image = "bpz_25.png",
			position = cc.p(space*0+75, self.mBgSize.height-90),
		},
		-- 战败
		[FightResultTag.eLose] = {
			image = "bpz_24.png",
			position = cc.p(space*1+75, self.mBgSize.height-90),
		},
		-- 平局
		[FightResultTag.eDeuce] = {
			image = "bpz_23.png",
			position = cc.p(space*2+75, self.mBgSize.height-90),
		},
		-- 总计
		[FightResultTag.eTotal] = {
			image = "bpz_22.png",
			position = cc.p(space*3+75, self.mBgSize.height-90),
		},
	}

	-- 创建标签
	for _, tagInfo in pairs(self.ResultTagList) do
		-- 图片
		local tagSprite = ui.newSprite(tagInfo.image)
		tagSprite:setPosition(tagInfo.position)
		self.mBgSprite:addChild(tagSprite)
		-- 次数
		local numLabel = ui.newLabel({
				text = "0",
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 24,
			})
		numLabel:setAnchorPoint(cc.p(0.5, 0.5))
		numLabel:setPosition(tagInfo.position.x, tagInfo.position.y-40)
		self.mBgSprite:addChild(numLabel)

		tagInfo.numLabel = numLabel
	end

	-- 列表背景
	local listBgSize = cc.size(550, 725)
	local listBg = ui.newScale9Sprite("c_24.png", listBgSize)
	listBg:setAnchorPoint(cc.p(0.5, 0))
	listBg:setPosition(self.mBgSize.width*0.5, 22)
	self.mBgSprite:addChild(listBg)
	-- 列表
	self.mReportListView = ccui.ListView:create()
	self.mReportListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mReportListView:setBounceEnabled(true)
	self.mReportListView:setContentSize(cc.size(listBgSize.width-10, listBgSize.height-15))
	self.mReportListView:setItemsMargin(10)
	self.mReportListView:setGravity(ccui.ListViewGravity.centerHorizontal)
	self.mReportListView:setAnchorPoint(cc.p(0.5, 0.5))
	self.mReportListView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
	listBg:addChild(self.mReportListView)

	-- 创建空提示
	self.mEmptyHint = ui.createEmptyHint(TR("暂无战报"))
	self.mEmptyHint:setPosition(listBgSize.width*0.5, listBgSize.height*0.6)
	listBg:addChild(self.mEmptyHint)
end

function GuildPvpReportLayer:createCell(itemInfo)
	local cellSize = cc.size(self.mReportListView:getContentSize().width, 127)
	local itemLayout = ccui.Layout:create()
	itemLayout:setContentSize(cellSize)

	-- 背景
	local itemBg = ui.newScale9Sprite("bpz_20.png", cellSize)
	itemBg:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	itemLayout:addChild(itemBg)

	-- 自己的帮派等级，名
	local ownNameBg = ui.newSprite("bpz_44.png")
	ownNameBg:setAnchorPoint(cc.p(0, 0.5))
	ownNameBg:setPosition(20, cellSize.height*0.8-5)
	itemLayout:addChild(ownNameBg)
	local guildLabel = ui.newLabel({
			text = itemInfo.GuildName,
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 20,
		})
	guildLabel:setAnchorPoint(cc.p(0, 0.5))
	guildLabel:setPosition(20, ownNameBg:getContentSize().height*0.5)
	ownNameBg:addChild(guildLabel)

	-- 第几轮
	local turnLabel = ui.newLabel({
			text = TR("第%d轮", itemInfo.TurnNum),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 22,
		})
	turnLabel:setAnchorPoint(cc.p(0.5, 0.5))
	turnLabel:setPosition(cellSize.width*0.5-10, cellSize.height-20)
	itemLayout:addChild(turnLabel)

	-- vs图
	local vsSprite = ui.newSprite("zdjs_07.png")
	vsSprite:setPosition(cellSize.width*0.5-10, cellSize.height*0.5-10)
	itemLayout:addChild(vsSprite)

	-- 对战帮派等级，名
	local otherNameBg = ui.newSprite("bpz_44.png")
	otherNameBg:setAnchorPoint(cc.p(0, 0.5))
	otherNameBg:setPosition(cellSize.width*0.6, cellSize.height*0.8-5)
	itemLayout:addChild(otherNameBg)
	local otherGuildLabel = ui.newLabel({
			text = itemInfo.DefenderGuildName,
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 20,
		})
	otherGuildLabel:setAnchorPoint(cc.p(0, 0.5))
	otherGuildLabel:setPosition(20, otherNameBg:getContentSize().height*0.5)
	otherNameBg:addChild(otherGuildLabel)

	-- 自己帮派星数
	local ownStarLabel = ui.newLabel({
			text = TR("获得星数: #d17b00{c_75.png}%d", itemInfo.Star),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 20,
		})
	ownStarLabel:setAnchorPoint(cc.p(0, 0.5))
	ownStarLabel:setPosition(30, cellSize.height*0.4)
	itemLayout:addChild(ownStarLabel)

	-- 对方帮派星数
	local otherStarLabel = ui.newLabel({
			text = TR("获得星数: #d17b00{c_75.png}%d", itemInfo.DefenderStar),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 20,
		})
	otherStarLabel:setAnchorPoint(cc.p(0, 0.5))
	otherStarLabel:setPosition(cellSize.width*0.6+10, cellSize.height*0.4)
	itemLayout:addChild(otherStarLabel)

	-- 修改底板
	if itemInfo.GameState == FightResultTag.eWin then
		itemBg:setTexture("bpz_21.png")
		itemBg:setContentSize(cellSize)
	end

	return itemLayout
end

function GuildPvpReportLayer:refreshListView()
	self.mReportListView:removeAllChildren()
	self.mEmptyHint:setVisible(false)

	local ListData = self.mReportInfo or {}
	self.mWinNum = 0
	self.mLoseNum = 0
	self.mDeuceNum = 0
	self.mTotalNum = 0

	if next(ListData) then
		-- 排序
		table.sort(ListData, function(item1, item2)
			return item1.TurnNum > item2.TurnNum
		end)
		-- 填充列表
		for _, itemData in pairs(ListData) do
			local itemLayout = self:createCell(itemData)
			self.mReportListView:pushBackCustomItem(itemLayout)

			self.mTotalNum = self.mTotalNum + 1

			if itemData.GameState == FightResultTag.eWin then
				self.mWinNum = self.mWinNum + 1
			elseif itemData.GameState == FightResultTag.eLose then
				self.mLoseNum = self.mLoseNum + 1
			elseif itemData.GameState == FightResultTag.eDeuce then
				self.mDeuceNum = self.mDeuceNum + 1
			end
		end
	else
		self.mEmptyHint:setVisible(true)
	end
end

function GuildPvpReportLayer:refreshResultStatistics()
	self.ResultTagList[FightResultTag.eWin].numLabel:setString(self.mWinNum)
	self.ResultTagList[FightResultTag.eLose].numLabel:setString(self.mLoseNum)
	self.ResultTagList[FightResultTag.eDeuce].numLabel:setString(self.mDeuceNum)
	self.ResultTagList[FightResultTag.eTotal].numLabel:setString(self.mTotalNum)
end

function GuildPvpReportLayer:refreshUI()
	self:refreshListView()
	self:refreshResultStatistics()
end

--================================服务器相关=============================
-- 请求初始信息
function GuildPvpReportLayer:requestInfo()
    HttpClient:request({
        moduleName = "Guild",
        methodName = "GetBattleSeasonInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
        	if not response or response.Status ~= 0 then
        	    return
        	end
        	self.mReportInfo = response.Value.BattleSeasonInfo
        	self:refreshUI()
        end
    })
    
end

return GuildPvpReportLayer