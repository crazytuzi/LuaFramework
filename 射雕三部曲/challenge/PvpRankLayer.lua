--[[
	文件名：PvpRankLayer.lua
	描述：竞技场排行查询界面
	创建人：xuchen
	修改人：chenqiang
	创建时间：2016.06.23
--]]

local PvpRankLayer = class("PvpRankLayer",function()
    return display.newLayer()
end)

-- 构造函数
--[[
-- params结构：
	{
		pvpInfo（必传参数）服务器PVP模块 GetPVPInfo 方法返回的数据结构
	}
--]]
function PvpRankLayer:ctor(params)
	-- 排名信息
	self.pvpInfo = params.pvpInfo
	-- 父节点
	self.mParent = params.parent
	-- 前10排名数据
	self.mTopRankList = self.pvpInfo.TopRankList
	-- 我的排名
	self.mMyRank = self.pvpInfo.Rank
	-- 我的阶数
	self.mMyStep = self.pvpInfo.HistoryMaxStep

	local bgLayer = require("commonLayer.PopBgLayer").new({
		bgSize = cc.size(640, 950),
		title = TR("排行榜"),
		closeAction =  function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(bgLayer)

	-- 保存弹出框控件
	self.mBgSprite = bgLayer.mBgSprite
	self.mBgSize = bgLayer.mBgSprite:getContentSize()
	
	-- 设置背景精灵的位置
	--self.mBgSprite:setPosition(display.cx, display.cy + 30)

	-- 初始化UI
	self:initUI()
end

function PvpRankLayer:initUI()
	local listBgLayer = ui.newScale9Sprite("c_17.png",cc.size(self.mBgSize.width - 70, self.mBgSize.height - 170))
	listBgLayer:setAnchorPoint(0.5,0.5)
	listBgLayer:setPosition(self.mBgSize.width / 2, self.mBgSize.height / 2 + 15)
	self.mBgSprite:addChild(listBgLayer)
	local listBgSize = listBgLayer:getContentSize()

	local rankListViewSize = cc.size(listBgSize.width - 8, listBgSize.height - 15)
	self.mRankListView = ccui.ListView:create()
	self.mRankListView:setContentSize(rankListViewSize)
 	self.mRankListView:setItemsMargin(2)
    self.mRankListView:setDirection(ccui.ListViewDirection.vertical)
    self.mRankListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mRankListView:setBounceEnabled(true)
    self.mRankListView:setAnchorPoint(0.5, 0.5)
    self.mRankListView:setPosition(listBgSize.width * 0.5, listBgSize.height * 0.5)
    listBgLayer:addChild(self.mRankListView)
    -- 单个条目大小
    self.mCellSize = cc.size(listBgSize.width - 8, 130)

    if #self.mTopRankList == 0 then
		local nothingSprite = ui.createEmptyHint(TR("暂无排行榜数据！"))
		nothingSprite:setPosition(self.mBgSize.width * 0.5, (self.mBgSize.height - 140) * 0.5)
		listBgLayer:addChild(nothingSprite)
    else
    	self:refreshListView()
    end

 	-- 我的排名信息
 	local myRankLabel = ui.newLabel({
 		text = TR("我的排名:  %s%d", Enums.Color.eYellowH, self.mMyRank),
 		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
 		x = self.mBgSize.width * 0.25,
 		y = self.mBgSize.height * 0.07
	})
	self.mBgSprite:addChild(myRankLabel)

	-- 自己的奖励信息
	local tempStep = math.min(self.mMyStep, PvpRankRewardRelation.items_count)
	local tempRank = math.min(self.mMyRank, #PvpRankRewardRelation.items[tempStep])
	local tempItem = PvpRankRewardRelation.items[tempStep][tempRank]
	local rewardCoinNum = (tempItem.rawGold or 0) * PlayerAttrObj:getPlayerAttrByName("Lv")
	local rewardPvpCoinNum = tempItem.PVPCoin or 0

	-- 创建自己的奖励信息
	local myRewardCoinLabel = ui.newLabel({
		text = string.format("{%s}%s%s", Utility.getDaibiImage(ResourcetypeSub.eGold), Enums.Color.eYellowH,
			Utility.numberWithUnit(rewardCoinNum, 0)),
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		x = self.mBgSize.width * 0.55,
		y = self.mBgSize.height * 0.07,
	})
	self.mBgSprite:addChild(myRewardCoinLabel)

	local myRewardPVPLabel = ui.newLabel({
		text = string.format("{%s}%s%s", Utility.getDaibiImage(ResourcetypeSub.ePVPCoin), Enums.Color.eYellowH,
			Utility.numberWithUnit(rewardPvpCoinNum, 0)),
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
		outlineSize = 2,
		x = self.mBgSize.width * 0.8,
		y = self.mBgSize.height * 0.07,
	})
	self.mBgSprite:addChild(myRewardPVPLabel)
end

function PvpRankLayer:refreshListView()
	for index = 1, #self.mTopRankList do
		local item = ccui.Layout:create()
		item:setContentSize(self.mCellSize)
		self.mRankListView:pushBackCustomItem(item)
		-- 刷新指定项
		self:refreshListItem(index)
	end
end

function PvpRankLayer:refreshListItem(index)
	local item = self.mRankListView:getItem(index - 1)
	local cellSize = self.mCellSize

	if item == nil then
		item = ccui.Layout:create()
		item:setContentSize(cellSize)
		self.mRankListView:insertCustomItem(item, index - 1)
	end
	item:removeAllChildren()

	local info = self.mTopRankList[index]

	-- 条目背景
	local cellBgSprite = ui.newScale9Sprite("c_18.png")
	cellBgSprite:setContentSize(cellSize.width - 8, 126)
	cellBgSprite:setPosition(cellSize.width * 0.5, cellSize.height * 0.5)
	item:addChild(cellBgSprite)

	-- 排名
	local rankNode = nil
	if info.Rank == 1 then
		rankNode = ui.newSprite("c_44.png")
		rankNode:setAnchorPoint(0, 0.5)
		rankNode:setPosition(10, cellSize.height * 0.5)
	elseif info.Rank == 2 then
		rankNode = ui.newSprite("c_45.png")
		rankNode:setAnchorPoint(0, 0.5)
		rankNode:setPosition(10, cellSize.height * 0.5)
	elseif info.Rank == 3 then
		rankNode = ui.newSprite("c_46.png")
		rankNode:setAnchorPoint(0, 0.5)
		rankNode:setPosition(10, cellSize.height * 0.5)
	else
		rankNode = ui.newNumberLabel({
			text = info.Rank,
			imgFile = "c_81.png",
			charCount = 10,
			startChar = 48
		})
		rankNode:setAnchorPoint(cc.p(0.5, 0.5))
		rankNode:setPosition(50, cellSize.height * 0.5)
	end
	cellBgSprite:addChild(rankNode)

	-- 头像信息
	if Utility.isEntityId(info.PlayerId) then
		-- 头像
	  	local headSprite = require("common.CardNode").new({
	  		allowClick = false,
	  	})
    	local showAttrs = {CardShowAttr.eBorder}
    	headSprite:setHero({HeroModelId = info.HeadImageId, pvpInterLv = info.DesignationId, FashionModelID = info.FashionModelId, IllusionModelId = info.IllusionModelId}, showAttrs)
    	headSprite:setAnchorPoint(0, 0.5)
    	headSprite:setPosition(90, cellSize.height * 0.5 - 3)
    	headSprite:setScale(0.9)
    	cellBgSprite:addChild(headSprite)
    	-- 玩家名
    	local nameLabel = ui.newLabel({
    		text = info.Name,
    		color = Enums.Color.eBlack,
    		size = 20,
    		anchorPoint = cc.p(0, 1),
    		x = 190,
    		y = cellSize.height - 18,
		})
    	cellBgSprite:addChild(nameLabel)
		-- 战力
		local playerFAPLabel = ui.newLabel({
			text = TR("战力:%s%s", Enums.Color.eNormalGreenH, Utility.numberFapWithUnit(info.FAP)),
			color = Enums.Color.eBlack,
			anchorPoint = cc.p(0, 1),
			size = 20,
			x = 315,
			y = cellSize.height - 18,
		})
		cellBgSprite:addChild(playerFAPLabel)
		-- 帮派
		local playerGuildLabel = ui.newLabel({
			text = TR("帮派: %s", (info.Guild or "")),
			color = Enums.Color.eBlack,
			anchorPoint = cc.p(0, 0.5),
			size = 20,
			x = 190,
			y = cellSize.height * 0.5,	
		})
		cellBgSprite:addChild(playerGuildLabel)

        -- 查看阵容
        local playerZhenBtn = ui.newButton({
            normalImage = "c_28.png",
            text = TR("阵容"),
            position = cc.p(cellSize.width * 0.85, cellSize.height * 0.5 - 5),
            clickAction = function()
            	self.mParent.mGotoRank = true
                Utility.showPlayerTeam(info.PlayerId)
            end,
        })
        cellBgSprite:addChild(playerZhenBtn)
	else
	 	local kongLabel = ui.newLabel({
            text = TR("该位置尚无人占领"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 26,
            anchorPoint = cc.p(0, 0.5),
            x = 150,
            y = cellSize.height * 0.6
        })
        cellBgSprite:addChild(kongLabel)
	end

	-- 奖励
	local tempStep = math.min(self.mMyStep, PvpRankRewardRelation.items_count)
	local tempRank = math.min(info.Rank, #PvpRankRewardRelation.items[tempStep])
	local tempItem = PvpRankRewardRelation.items[tempStep][tempRank]
 	local rewardCoinNum = tempItem.rawGold * info.Lv
	local rewardPvpCoinNum = tempItem.PVPCoin
	
	-- 铜币奖励
	local rewardCoinLabel = ui.newLabel({
        text = string.format("{%s}%s", Utility.getDaibiImage(ResourcetypeSub.eGold), 
			Utility.numberWithUnit(rewardCoinNum, 0)),
		color = Enums.Color.eRed,
		anchorPoint = cc.p(0, 0.5),
		size = 20,
		x = 190,
		y = 23,
    })
    cellBgSprite:addChild(rewardCoinLabel)
    -- 声望奖励
    local rewardPVPCoinLabel = ui.newLabel({
	  	text = string.format("{%s}%s", Utility.getDaibiImage(ResourcetypeSub.ePVPCoin), 
		Utility.numberWithUnit(rewardPvpCoinNum, 0)),
		color = Enums.Color.eRed,
		anchorPoint = cc.p(0, 0.5),
		size = 20,
		x = 300,
		y = 23,
	})
	cellBgSprite:addChild(rewardPVPCoinLabel)

end

return PvpRankLayer
