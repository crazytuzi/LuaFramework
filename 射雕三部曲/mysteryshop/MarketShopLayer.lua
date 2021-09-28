--[[
	文件名：MarketShopLayer.lua
	描述：黑市
	创建人：lichunsheng
	创建时间：2017.08.23
--]]

-- 该页面作为子节点添加到已适配的父节点上，坐标按照 640 1136来即可
local MarketShopLayer = class("MarketShopLayer", function(params)
	return display.newLayer()
end)

-- 构造函数
function MarketShopLayer:ctor(params)
	--保存数据list
	self.mShopInfo = {}
	self:setContentSize(640, 1136)

	-- 请求服务器，获取专属卖场数据
	self:requestSeniorGetInfo(true)
end

-- 初始化UI元素
function MarketShopLayer:initUI()
    -- 背景框
    local bgSprite = ui.newScale9Sprite("c_94.png",cc.size(640, 868))
    bgSprite:setPosition(320, 550)
    self:addChild(bgSprite)

	--背景底板
	local underBgSprite = ui.newScale9Sprite("c_97.png", cc.size(570, 670))
	underBgSprite:setPosition(320, 598)
	self:addChild(underBgSprite)

    -- 标题
    local title = ui.newLabel({
        text = TR("高级宝阁"),
		size = 24,
		color = cc.c3b(0x4e, 0x15, 0x0c),
        x = 320,
        y = 960,
        align = ui.TEXT_ALIGN_CENTER
    })
    self:addChild(title)

	--去分解按钮
	local fenjieBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("去分解"),
		size = cc.size(150, 60),
		position = cc.p(200, 165),
		clickAction = function()
			LayerManager.addLayer({
				name = "disassemble.DisassembleLayer",
				--data = {isRebirth = true}
			})
		end
	})
	self:addChild(fenjieBtn)

	--刷新按钮
	self.mRefreshBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("刷新"),
		size = cc.size(150, 60),
		position = cc.p(440, 165),
		clickAction = function()
			LayerManager.addLayer({
				self:refreshBtnClicked()
			})
		end
	})
	self:addChild(self.mRefreshBtn)

	-- 剩余时间、刷新次数的背景
	local lineBg = ui.newScale9Sprite("jbg_03.png", cc.size(584, 60))
	lineBg:setPosition(cc.p(320, 230))
	self:addChild(lineBg)

	-- 剩余时间标签
	self.mTimeLabel = ui.newLabel({
		text = TR(""),
		size = 20,
		anchorPoint = cc.p(0, 0.5),
		color = Enums.Color.eWhite,
		outlineColor = cc.c3b(0x83, 0x45, 0x00),
		x = lineBg:getContentSize().width * 0.08,
		y = lineBg:getContentSize().height * 0.5
	})
	lineBg:addChild(self.mTimeLabel)


	-- 免费刷新次数/拥有刷新令/刷新消耗元宝标签
	self.mFreeLabel = ui.newLabel({
		text = TR(""),
		size = 20,
		anchorPoint = cc.p(0, 0.5),
		color = Enums.Color.eWhite,
		outlineColor = cc.c3b(0x83, 0x45, 0x00),
		x = lineBg:getContentSize().width * 0.55,
		y = lineBg:getContentSize().height * 0.5,
	})
	lineBg:addChild(self.mFreeLabel)

    --今日次数限制label
    local totalNumLabel = ui.newLabel({
        text = "",
        color = Enums.Color.eRed,
        -- outlineColor = Enums.Color.eRed,
        size = 20,
        align = ui.TEXT_ALIGN_CENTER
    })
    totalNumLabel:setPosition(420, 100)
    self:addChild(totalNumLabel)
    self.mTotalNumLabel = totalNumLabel

    -- 添加ListView
    self:addListView()
end

-- 创建物品滑动列表
function MarketShopLayer:addListView()
	if not self.mListView then
		self.mListView = ccui.ListView:create()
		self.mListView:setDirection(ccui.ScrollViewDir.vertical)
		self.mListView:setBounceEnabled(true)
		self.mListView:setContentSize(cc.size(570, 660))
		self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
		self.mListView:setAnchorPoint(cc.p(0.5, 1))
		self.mListView:setPosition(325, 925)
		self.mListView:setItemsMargin(10)
		self:addChild(self.mListView)
	end
	self:refreshListView()
end


-- 获取数据后，刷新ListView
function MarketShopLayer:refreshListView()
    -- 移除所有并重新添加
    self.mListView:removeAllItems()
	--刷新倒计时
	if self.mCountDown then
		self:stopAction(self.mCountDown)
		self.mCountDown = nil
	end
	--倒计时
	self.mCountDown = Utility.schedule(self, self.CountDown, 1.0)

	-- 刷新令模型Id及图片
    local resourceInfo = Utility.analysisStrResList(MysteryshopConfig.items[1].seniorRefreshUseResource)[1]
    local haveNum = Utility.getOwnedGoodsCount(resourceInfo.resourceTypeSub, resourceInfo.modelId)

	-- 有刷新令
	if haveNum > resourceInfo.num then
		local propPic = Utility.getDaibiImage(ResourcetypeSub.eFunctionProps, resourceInfo.modelId)
		self.mFreeLabel:setString(TR("拥有刷新令: {%s}#FFF000%d", propPic, haveNum))
		self.mRefreshBtn.mTitleLabel:setString(TR("刷新{%s}X%d", propPic, resourceInfo.num))
		self.mRefreshBtn.mTitleLabel:setSystemFontSize(24)
	-- 无刷新令则消耗神魂
	else
        resourceInfo = Utility.analysisStrResList(MysteryshopConfig.items[1].seniorRefreshUseResourceSub)[1]
        local propPic = Utility.getDaibiImage(resourceInfo.resourceTypeSub)
		self.mFreeLabel:setString(TR("刷新消耗%s: {%s}#FFF000%d", Utility.getGoodsName(resourceInfo.resourceTypeSub), propPic, resourceInfo.num))
		self.mRefreshBtn.mTitleLabel:setString(TR("刷新{%s}X%d", propPic, resourceInfo.num))
		self.mRefreshBtn.mTitleLabel:setSystemFontSize(22)
	end

	--整理数据
	local dataList = {}
	local cellDataTable = {}
	for index, items in ipairs(self.mShopInfo.MysteryShopGoodsList) do
		table.insert(dataList, items)
		if index % 2 == 0 then
			table.insert(cellDataTable, dataList)
			dataList = {}
		end
	end

	--防止数据为单数数据的时候遗漏一组数据
	if next(dataList) ~= nil then
		table.insert(cellDataTable, dataList)
	end

    for index, items in ipairs(cellDataTable) do
     -- 向已创建的cell添加UI元素
        local layout = self:addItems(items, index)
        -- 添加cell到listview
        self.mListView:pushBackCustomItem(layout)
    end
    self.mTotalNumLabel:setString(TR("今日剩余刷新次数：%d/%d", self.mShopInfo.LimitNum, self.mShopInfo.TotalNum))

end


-- 向创建的cell添加UI元素
--[[
	itemsData			--整理之后每一条cell需要的数据
    cellIndex           --cell索引号
--]]
function MarketShopLayer:addItems(itemsData, cellIndex)
	--获取数据
	local itemsSize = cc.size(570, 156)
	local cellItems = ccui.Layout:create()
	cellItems:setContentSize(itemsSize)

	local underTray = ui.newScale9Sprite("c_96.png", cc.size(558, 71))
	underTray:setAnchorPoint(cc.p(0.5, 0.5))
	underTray:setPosition(cc.p(285, -15))
	cellItems:addChild(underTray)

    -- items背景
	local boxPos = {
		[1] = cc.p(itemsSize.width * 0.25, itemsSize.height * 0.5 ),
		[2] = cc.p(itemsSize.width * 0.74, itemsSize.height * 0.5 )
	}
	for index, items in ipairs(itemsData) do
		local cellBox = ui.newScale9Sprite("c_65.png", cc.size(260, 140))
		cellBox:setPosition(boxPos[index])
		cellItems:addChild(cellBox)

		local dataList = {}
		local rewardData = {
			--资源类型
			["resourceTypeSub"] = items.SellResourceTypeSub,
			--模型ID
			["modelId"] = items.SellGoodsModelId,
			--数量
			["num"] = items.SellNum,
		}
		table.insert(dataList, rewardData)

		-- 创建奖励物品列表
		local cardListNode = ui.createCardList({
			maxViewWidth = 400,
			space = 15,
			cardDataList = dataList,
			allowClick = true,
			needArrows = true,
		})
		cardListNode:setAnchorPoint(cc.p(0.5, 0.5))
		cardListNode:setPosition(60, 55)
		cellBox:addChild(cardListNode)
		--重设名字位置
		local cardList = cardListNode.getCardNodeList()
		for _, item in ipairs(cardList) do
			local colorLv = Utility.getColorLvByModelId(items.SellGoodsModelId, items.SellResourceTypeSub)
			local quality = Utility.getQualityByModelId(items.SellGoodsModelId, items.SellResourceTypeSub)
			local  color = Utility.getQualityColor(quality, colorLv)
			item.mShowAttrControl[CardShowAttr.eName].label:setVisible(false)
			local nameLabel = ui.newLabel({
				text = TR(" %s%s", color, item.mShowAttrControl[CardShowAttr.eName].label:getString()),
				size = 22,
				outlineColor = Enums.Color.eBlack,
				outlineSize = 2,
				x = item:getContentSize().width + 5,
				y = item:getContentSize().height - 5,
				anchorPoint = cc.p(0, 0.5),

			})
			item:addChild(nameLabel)
		end

		--创建已经拥有道具的个数
		--根据不同的道具类型 创建不同的标签
			-- 人物和道具
		local textString = ""
		if Utility.isHero(items.SellResourceTypeSub) then
			-- 人物碎片
			textString = TR("拥有: %d", HeroObj:getCountByModelId(items.SellGoodsModelId))
		elseif Utility.isGoods(items.SellResourceTypeSub) then
			--道具碎片
			textString = TR("拥有: %s", Utility.numberWithUnit(GoodsObj:getCountByModelId(items.SellGoodsModelId)))
		elseif Utility.isHeroDebris(items.SellResourceTypeSub) then
			local havePropCout = Utility.getOwnedGoodsCount(items.SellResourceTypeSub, items.SellGoodsModelId) or 0
			textString = TR("拥有: %d/%d", havePropCout, GoodsModel.items[items.SellGoodsModelId].maxNum)
		elseif Utility.isPlayerAttr(items.SellResourceTypeSub) then
			textString = TR("拥有: %s", Utility.numberWithUnit(PlayerAttrObj:getPlayerAttr(items.SellResourceTypeSub)))
		end

		local haveLabel = ui.newLabel({
		   text = textString,
		   anchorPoint = cc.p(0, 0.5),
		   color = cc.c3b(0x00, 0x95, 0x23),
	       x = 115,
	       y = 70,
		})
		cellBox:addChild(haveLabel)

		-- 购买按钮
		local buyButton = ui.newButton({
		    normalImage = "c_59.png",
		    size = cc.size(127 * 0.8, 55 * 0.8),
		    text = TR(""),
		    position = cc.p(185, 35),
		    clickAction = function(pSender)
				if not Utility.isResourceEnough(items.BuyResourceTypeSub, items.BuyNum) then
					return
				end
				self:requestSeniorMysteryShopBuyGoods(items.Id, pSender)
		    end
		})
		cellBox:addChild(buyButton)

		--创建代币和代币消耗数量
		local costRes = ui.newSprite(Utility.getDaibiImage(items.BuyResourceTypeSub, items.BuyGoodsModelId))
		costRes:setPosition(cc.p(20, 17))
		buyButton:addChild(costRes)
		costRes:setScale(0.8)

		local costNum = ui.newLabel({
			text = items.BuyNum or 0,
			anchorPoint = cc.p(0, 0.5),
			x = 35,
			y = 17,
			outlineColor = Enums.Color.eBlack,
			outlineSize = 2,
		})
		buyButton:addChild(costNum)

		--是否已经购买, 是否代币足够
		local playerResCount = PlayerAttrObj:getPlayerAttr(items.BuyResourceTypeSub)
		if items.IsSell or items.BuyNum > playerResCount then
			buyButton:setEnabled(false)
		end

		--------左上角羁绊标签--------
		local relationPics = {
			[Enums.RelationStatus.eIsMember] = "c_57.png",         -- 推荐
			[Enums.RelationStatus.eTriggerPr] = "c_58.png",        -- 缘分
			[Enums.RelationStatus.eSame] = "c_62.png"              -- 已上阵
		}
		local relationStr = {
			[Enums.RelationStatus.eIsMember] = TR("推荐"),
			[Enums.RelationStatus.eTriggerPr] = TR("缘分"),
			[Enums.RelationStatus.eSame] = TR("已上阵")
		}
		local relationSpr = nil
		local relationLab = nil

		-- 突破石单独处理，显示推荐
		if items.SellGoodsModelId == 16050001 then
			relationSpr = ui.newSprite(relationPics[Enums.RelationStatus.eIsMember])
			relationSpr:retain()
			relationLab = ui.newLabel({
				text = relationStr[Enums.RelationStatus.eIsMember],
				size = 21,
				outlineColor = Enums.Color.eBlack,
				})

		-- 英雄
		elseif Utility.isHero(items.SellResourceTypeSub) then
			local status = FormationObj:getRelationStatus(items.SellGoodsModelId, ResourcetypeSub.eHero)

			if status ~= Enums.RelationStatus.eNone then
				relationSpr = ui.newSprite(relationPics[status])
				relationSpr:retain()
				relationLab = ui.newLabel({
				text = relationStr[status],
				size = 21,
				outlineColor = Enums.Color.eBlack
				})
				if HeroModel.items[items.SellGoodsModelId].quality <= 10 then
					relationSpr:setVisible(false)
				end
			end
		-- 英雄碎片
		elseif Utility.isHeroDebris(items.SellResourceTypeSub) then
			local item = GoodsModel.items[items.SellGoodsModelId]
			local status = FormationObj:getRelationStatus(item.outputModelID, ResourcetypeSub.eHero)

			if status ~= Enums.RelationStatus.eNone then
				relationSpr = ui.newSprite(relationPics[status])
				relationSpr:retain()
				relationLab = ui.newLabel({
				text = relationStr[status],
				size = 21,
				outlineColor = Enums.Color.eBlack
				})
				if HeroModel.items[item.outputModelID].quality <= 10 then
					relationSpr:setVisible(false)
				end
			end
		end

		if relationSpr then
			relationSpr:setPosition(0, 140)
			relationSpr:setAnchorPoint(cc.p(0, 1))
			cellBox:addChild(relationSpr)
			relationSpr:release()
			relationLab:setPosition(25, 112)
			relationLab:setRotation(-45)
			cellBox:addChild(relationLab)
		end


	end

	return  cellItems
end

--刷新规则
-- 刷新按钮点击事件，2、3分别表示：道具刷新、神魂刷新
function MarketShopLayer:refreshBtnClicked()
    -- 拥有的刷新令数量
    local resourceInfo = Utility.analysisStrResList(MysteryshopConfig.items[1].seniorRefreshUseResource)[1]
    local havePropNum = Utility.getOwnedGoodsCount(resourceInfo.resourceTypeSub, resourceInfo.modelId)
    -- 刷新令 > 5 优先使用刷新另
    if havePropNum >= resourceInfo.num then
        self:requestSeniorRefreshtGoodsList(2)
    else
    	--没有刷新另使用神魄（加入确认弹窗）
        resourceInfo = Utility.analysisStrResList(MysteryshopConfig.items[1].seniorRefreshUseResourceSub)[1]
        if Utility.isResourceEnough(resourceInfo.resourceTypeSub, resourceInfo.num) then
			-- MsgBoxLayer.addOKLayer(
			-- 	TR("是否确定花费%s刷新?", Utility.getGoodsName(resourceInfo.resourceTypeSub)),
			-- 	TR("提示"),
			-- 	 {{
			-- 		text = TR("确定"),
			-- 		clickAction = function(layerObj, btnObj)
			-- 			LayerManager.removeLayer(layerObj)
			-- 			-- 上面已经判断了资源是否足够
			-- 			self:requestSeniorRefreshtGoodsList(3)
			-- 		end
			-- 	}},{})
			self:requestSeniorRefreshtGoodsList(3)
        end
    end
end


--倒计时函数
function MarketShopLayer:CountDown()
	local refreshTime = self.mShopInfo.LastFreshDate - Player:getCurrentTime() or 0
	if refreshTime > 0 then
		self.mTimeLabel:setString(TR("剩余时间: #FFF000%s",MqTime.formatAsDay(refreshTime)))
	else--如果等待在此界面，需要从新刷新倒计时
		self:stopAction(self.mCountDown)
		self.mCountDown = nil
		self:requestSeniorGetInfo()
	end
end

-----------------------网络相关-------------------------
-- 请求服务器，获取玩家专属卖场相关数据
function MarketShopLayer:requestSeniorGetInfo(isInit)
	HttpClient:request({
        moduleName = "MysteryShop",
        methodName = "SeniorGetInfo",
        callbackNode = self,
        callback = function (response)
            -- 容错处理
            if not response.Value or response.Status ~= 0 then
                return
            end
            -- dump(response, "SeniorGetInfo")
            -- 保存数据
			self.mShopInfo.MysteryShopGoodsList = response.Value.MysteryShopGoodsList or {}
			self.mShopInfo.LastFreshDate = response.Value.LastFreshDate or 0
			self.mShopInfo.LimitNum = response.Value.LimitNum 
			self.mShopInfo.TotalNum = response.Value.TotalNum 

			-- 初始化UI
			if isInit then
				self:initUI()
			else
				self:refreshListView()
			end
        end
    })
end

-- 请求服务器，购买相应物品
--[[
    params:
    id               -- 物品Id号
--]]
function MarketShopLayer:requestSeniorMysteryShopBuyGoods(id, pSender)
    HttpClient:request({
        moduleName = "MysteryShop",
        methodName = "SeniorMysteryShopBuyGoods",
        svrMethodData = {id},
        callbackNode = self,
        callback = function (response)
            -- 容错处理
            if not response.Value or response.Status ~= 0 then
                return
            end
			--pSender:setEnabled(false)
            -- 飘窗显示获得的物品
			-- 更新数据，改变商品购买状态
			for index, items in ipairs(self.mShopInfo.MysteryShopGoodsList) do
				if items.Id == id then
					self.mShopInfo.MysteryShopGoodsList[index].IsSell = 1
					break
				end
			end

            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
			--购买之后重新刷新数据
			self:refreshListView()
        end
    })
end


--刷新高级黑市的列表接口
--[[
	params说明：
    	Byte:刷新类型(1:免费刷新2:道具刷新3:钻石刷新)
]]

function MarketShopLayer:requestSeniorRefreshtGoodsList(refreshType)
	HttpClient:request({
		moduleName = "MysteryShop",
		methodName = "SeniorRefreshtGoodsList",
		svrMethodData = {refreshType},
		callbackNode = self,
		callback = function (response)
			-- 容错处理
			if not response.Value or response.Status ~= 0 then
				return
			end
			self.mShopInfo.MysteryShopGoodsList = response.Value.MysteryShopGoodsList
			self.mShopInfo.LimitNum = response.Value.LimitNum

			--刷新界面
			self:refreshListView()
		end
	})

end

return MarketShopLayer
