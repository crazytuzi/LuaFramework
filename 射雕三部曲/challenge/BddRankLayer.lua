--[[
    文件名：BddRankLayer.lua
    描述：比武招亲排行
    创建人：yanghongsheng
    创建时间：2017.4.22
--]]

local BddRankLayer = class("BddRankLayer", function()
	return cc.Layer:create()
end)

-- 构造函数
--[[
-- 参数:
	{
		mMaxStarCount: player的星星数量
	}
]]
function BddRankLayer:ctor(params)
	-- 星星最大数量
	self.mMaxStarCount = params.maxStarCount
	-- 排名信息
	self.mRankInfo = {}

	-- 页面父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:initUI()

	-- 请求排行榜数据
	self:requestRankInfo()

	-- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
           	ResourcetypeSub.eSTA,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource, Enums.ZOrderType.eDefault + 4)
end

function BddRankLayer:initUI()
	-- 背景图
	local bgSprite = ui.newSprite("bwzq_03.jpg")
	bgSprite:setAnchorPoint(cc.p(0.5, 1))
	bgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(bgSprite)

	-- 子背景
    local subBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 1000))
    subBgSprite:setAnchorPoint(cc.p(0.5, 1))
    subBgSprite:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.5, 1000))
    self.mParentLayer:addChild(subBgSprite)

    -- 列表背景
	local listBg = ui.newScale9Sprite("c_17.png", cc.size(618, 790))
	listBg:setAnchorPoint(cc.p(0.5, 1))
	listBg:setPosition(320, 960)
	self.mParentLayer:addChild(listBg)

	-- 排行榜按钮
	self:showTabLayer()

	-- 关闭按钮
	local closeButton = ui.newButton({
	 	normalImage = "c_29.png",
        -- anchorPoint = cc.p(0.5, 0),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
	})
	closeButton:setPosition(Enums.StardardRootPos.eCloseBtn)
	self.mParentLayer:addChild(closeButton)

	-- 我的排名
	local listLayer = cc.Layer:create()
	listLayer:setContentSize(cc.size(620, 780))
	listLayer:setPosition(0, 205)
	self.mListLayer = listLayer
	self.mParentLayer:addChild(listLayer)

	local listViewSize = cc.size(620, 780)
	self.mRankListView = ccui.ListView:create()
	self.mRankListView:setContentSize(listViewSize)
    self.mRankListView:setDirection(ccui.ListViewDirection.vertical)
    self.mRankListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mRankListView:setBounceEnabled(true)
    self.mRankListView:setAnchorPoint(0, 0)
    self.mRankListView:setPosition(10, -30)
    listLayer:addChild(self.mRankListView)
    -- 单个条目大小
    self.mCellSize = cc.size(606, 142)
end

function BddRankLayer:showTabLayer()
    -- 创建分页
    local buttonInfos = {
        {
            text = TR("排行榜"),
            size = 24,
            color = cc.c3b(0xff, 0xee, 0xe2),
            outlineColor = cc.c3b(0x78, 0x3f, 0x3a),
            tag = 1,
        },
    }
    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        viewSize = cc.size(640, 80),
        btnSize = cc.size(138, 56),
        defaultSelectTag = self.mSubPageType,
        allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            if self.mCurrentView == selectBtnTag then
                return
            end
        end
    })

    -- tabLayer:setAnchorPoint(cc.p(0.5, 1))
    tabLayer:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(tabLayer)
end

-- 判断本玩家是否上榜
--[[
-- 参数
	info: 神兵殿排行信息
]]
function BddRankLayer:isInRank(rankInfo)
	-- 获取玩家playerId
	local playerId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
	for index, info in ipairs(rankInfo) do
		local pId = info.PlayerId
		if Utility.isEntityId(pId) and playerId == pId then
			return true, index
		end
	end

	return false
end

function BddRankLayer:refreshListView()
	for index = 1, #self.mRankInfo do
		local item = ccui.Layout:create()
		item:setContentSize(self.mCellSize.width, self.mCellSize.height - 10)
		self.mRankListView:pushBackCustomItem(item)
		-- 刷新指定项
		self:refreshListItem(index)
	end
end

function BddRankLayer:refreshListItem(index)
	local item = self.mRankListView:getItem(index - 1)
	local cellSize = self.mCellSize

	if item == nil then
		item = ccui.Layout:create()
		item:setContentSize(cellSize)
		self.mRankListView:insertCustomItem(item, index - 1)
	end
	item:removeAllChildren()

	local info = self.mRankInfo[index]

	-- 条目背景
	local cellBgSprite = ui.newScale9Sprite("c_18.png", cellSize)
	cellBgSprite:setContentSize(cellSize.width - 10, 125)
	cellBgSprite:setPosition(cellSize.width * 0.5, cellSize.height * 0.5 - 5)
	item:addChild(cellBgSprite)

	-- 排名
	local rankNode = nil
	if index == 1 then
		rankNode = ui.newSprite("c_44.png")
		rankNode:setAnchorPoint(0, 0.5)
		rankNode:setPosition(25, cellSize.height * 0.5 - 5)
	elseif index == 2 then
		rankNode = ui.newSprite("c_45.png")
		rankNode:setAnchorPoint(0, 0.5)
		rankNode:setPosition(25, cellSize.height * 0.5 - 5)
	elseif index == 3 then
		rankNode = ui.newSprite("c_46.png")
		rankNode:setAnchorPoint(0, 0.5)
		rankNode:setPosition(25, cellSize.height * 0.5 - 5)
	else
		--[[
		rankNode = ui.newNumberLabel({
			text = index,
			imgFile = "c_42.png",
		})
		rankNode:setAnchorPoint(cc.p(0.5, 0.5))
		rankNode:setPosition(60, cellSize.height * 0.5)
		--]]
		rankNode = ui.newSprite("c_47.png")
		rankNode:setAnchorPoint(cc.p(0.5, 0.5))
		rankNode:setPosition(60, cellSize.height * 0.5 - 5)

		local numLabel = ui.newLabel({
			text = "" .. index,
			color = Enums.Color.eWhite,
			size = 33
		})
		numLabel:setAnchorPoint(cc.p(0.5, 0.5))
		numLabel:setPosition(rankNode:getContentSize().width*0.5, rankNode:getContentSize().height*0.5)
		rankNode:addChild(numLabel)
	end
	cellBgSprite:addChild(rankNode)

	-- 头像
  	local headSprite = require("common.CardNode").new({
  		allowClick = false,
  	})
  	--dump(info, "人物信息")
	local showAttrs = {CardShowAttr.eBorder}
	headSprite:setHero({HeroModelId = info.HeadImageId, pvpInterLv = info.DesignationId, FashionModelID = info.FashionModelId, IllusionModelId = info.IllusionModelId}, showAttrs)
	headSprite:setAnchorPoint(0, 0.5)
	headSprite:setPosition(110, cellSize.height * 0.5 - 5)
	cellBgSprite:addChild(headSprite)

	-- 玩家名
	local nameLabel = ui.newLabel({
		text = info.Name,
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 1),
		size = 22,
		x = 220,
		y = cellSize.height - 30,
	})
	cellBgSprite:addChild(nameLabel)

	-- 等级
	local LvLable = ui.newLabel({
			text = TR("等级: %s%d","#20781b",info.Lv),
			color = Enums.Color.eBlack,
			anchorPoint = cc.p(0, 1),
			size = 20,
			x = 220,
			y = cellSize.height - 57,
		})
	cellBgSprite:addChild(LvLable)
	-- 战力
	local playerFAPLabel = ui.newLabel({
		text = string.format("%s:%s%s", "战斗力", "#d17b00", " " .. Utility.numberFapWithUnit(info.FAP)),
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 1),
		x = 220,
		size = 20,
		y = cellSize.height - 80
	})
	cellBgSprite:addChild(playerFAPLabel)

	-- 历史最高
	local maxLabel = ui.newLabel({
		text = TR("历史最高: %s%d {%s}", "#d17b00", info.MaxStarCount, "c_75.png"),
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 1),
		size = 20,
		x = 220,
		y = cellSize.height - 105
	})
	cellBgSprite:addChild(maxLabel)
	-- 层数
	local maxFloorNum = info.MaxNodeId - 10
	if info.MaxNodeId == 0 then
		maxFloorNum = 0
	end
	local maxFloorLable = ui.newLabel({
		text = TR("第%s%d%s层", "#20781b", maxFloorNum, Enums.Color.eBlackH),
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 1),
		size = 20,
		x = 400,
		y = cellSize.height - 110
	})
	cellBgSprite:addChild(maxFloorLable)
	-- 会员
	local vipNode = ui.createVipNode(info.Vip)
	vipNode:setPosition(cc.p(cellSize.width * 0.8, cellSize.height - 35))
	cellBgSprite:addChild(vipNode)
	-- 查看阵容
    local playerZhenBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("阵容"),
        position = cc.p(cellSize.width * 0.84, cellSize.height * 0.5 - 5),
        clickAction = function()
            Utility.showPlayerTeam(info.PlayerId)
        end,
    })
    cellBgSprite:addChild(playerZhenBtn)
end

function BddRankLayer:refreshUI()
	-- 层数
	local maxFloorNum = self.mRankData.MyMaxNodeId - 10
	if self.mRankData.MyMaxNodeId == 0 then
		maxFloorNum = 0
	end
	-- 刷新列表
	self:refreshListView()
	local text = TR("历史最高: %s%d{%s}    %s第%s%d%s层",
					"#d17b00",
					self.mRankData.MyMaxStarCount,
					"c_75.png",
					Enums.Color.eBlackH,
					"#20781b",
					maxFloorNum,
					Enums.Color.eBlackH)
	-- 刷新历史最高
	if self.historyMaxLabel then
		self.historyMaxLabel:setString(text)
	else
		self.historyMaxLabel = ui.newLabel({
				text = text,
				size = 24,
				color = Enums.Color.eBlack,
			})
		self.historyMaxLabel:setAnchorPoint(cc.p(0, 0))
		self.historyMaxLabel:setPosition(cc.p(320, 130))
		self.mParentLayer:addChild(self.historyMaxLabel)
	end
end

-----------------网络相关---------------------
function BddRankLayer:requestRankInfo()
	HttpClient:request({
 		moduleName = "BddInfo",
        methodName = "GetRankInfo",
        callbackNode = self,
        callback = function(response)
        	-- 容错处理
        	if not response or response.Status ~= 0 then
        		return
        	end
        	--dump(response.Value)

        	self.mRankData = response.Value
        	self.mRankInfo = response.Value.Info
        	if #self.mRankInfo == 0 then
        		local nothingSprite = ui.createEmptyHint(TR("暂无排行榜数据！"))
				nothingSprite:setPosition(320, 550)
				self.mListLayer:addChild(nothingSprite)
			else
				self:refreshUI()
	   --  	 	-- 判断自己上榜
	   --  	 	local inRank, rank = self:isInRank(self.mRankInfo)
				-- if inRank then
				-- 	self.mRankLabel:setString("我的排名: "..rank)
				-- end
			end

        end
	})
end

return BddRankLayer
