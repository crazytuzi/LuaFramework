--[[
    SectPalaceSelectHeroLayer.lua
    描述: 门派地宫选将界面
    创建人: yanghongsheng
    创建时间: 2019.3.9
-- ]]

local SectPalaceSelectHeroLayer = class("SectPalaceSelectHeroLayer", function(params)
    return display.newLayer()
end)

--[[
	params:
		limitHeroIdList		-- 已被限制不能选的侠客列表
		btnTitle 			-- 确定按钮上字
		callback 			-- 确定按钮回调
		isShowDouble		-- 是否显示双倍令
]]

function SectPalaceSelectHeroLayer:ctor(params)
	self.mLimitHeroIdList = params.limitHeroIdList or {}
	self.mBtnTitle = params.btnTitle
	self.mCallback = params.callback
	self.mIsShowDouble = params.isShowDouble or false
	self.mIsUseDouble = false
	self.mDoubleGoodsId = 16050532
	self.mHeroMaxNum = SectPalaceModel.items[1].maxDiscoveryNum		-- 选择上限
	self.mHeroMinNum = SectPalaceModel.items[1].minDiscoveryNum		-- 选择下限
	self.mHeroList = HeroObj:getHeroList({
			excludeIdList = self.mLimitHeroIdList,
			minLv = PlayerAttrObj:getPlayerAttrByName("Lv")
		})
	-- 排序
	table.sort(self.mHeroList, function (heroInfo1, heroInfo2)
		-- 突破等级
		if (heroInfo1.Step or 0) ~= (heroInfo2.Step or 0) then
			return (heroInfo1.Step or 0) > (heroInfo2.Step or 0)
		end
		-- 淬体等级
		if (heroInfo1.QuenchStep or 0) ~= (heroInfo2.QuenchStep or 0) then
			return (heroInfo1.QuenchStep or 0) > (heroInfo2.QuenchStep or 0)
		end
		-- 经脉等级
		local currRebornNum1 = heroInfo1.RebornId and RebornLvModel.items[heroInfo1.RebornId].rebornNum or 0
		local currRebornNum2 = heroInfo2.RebornId and RebornLvModel.items[heroInfo2.RebornId].rebornNum or 0
		if currRebornNum1 ~= currRebornNum2 then
			return currRebornNum1 > currRebornNum2
		end
		-- 资质
		local tempModel1 = HeroModel.items[heroInfo1.ModelId]
		local illusionModel1 = IllusionModel.items[heroInfo1.IllusionModelId]
		local quality1 = illusionModel1 and illusionModel1.quality or tempModel1.quality

		local tempModel2 = HeroModel.items[heroInfo2.ModelId]
		local illusionModel2 = IllusionModel.items[heroInfo2.IllusionModelId]
		local quality2 = illusionModel2 and illusionModel2.quality or tempModel2.quality
		if quality1 ~= quality2 then
			return quality1 > quality2
		end
	end)
	self.mSelectList = {}	-- 已选择侠客列表
	self.mGoodsList = {}	-- 选择道具列表
	-- 屏蔽下层触摸
	ui.registerSwallowTouch({node = self})
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建底部导航和顶部玩家信息部分
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    self:initUI()

    self:requestGetTimedActivityInfo()
end

-- 初始化界面
function SectPalaceSelectHeroLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("c_34.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)
	-- 上面灰背景
	local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(610, 660))
    tempSprite:setAnchorPoint(cc.p(0.5, 1))
    tempSprite:setPosition(320, 1000)
    self.mParentLayer:addChild(tempSprite)
	-- 下面灰背景
	local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(610, 130))
    tempSprite:setAnchorPoint(cc.p(0.5, 1))
    tempSprite:setPosition(320, 320)
    self.mParentLayer:addChild(tempSprite)

    -- 双倍令数量
    local ownDoubleNum = Utility.getOwnedGoodsCount(GoodsModel.items[self.mDoubleGoodsId].typeID, self.mDoubleGoodsId)
    -- 双倍令复选
    self.mDoubleCheckout = ui.newCheckbox({
    	text = TR("勾选使用%s，地宫奖励翻倍", GoodsModel.items[self.mDoubleGoodsId].name),
    	outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
    	callback = function (status)
    		if status then
    			if self.mIsDoubleActivity then
    				self.mIsUseDouble = false
    				self.mDoubleCheckout:setCheckState(self.mIsUseDouble)
    				ui.showFlashView(TR("双倍活动期间不能使用%s", GoodsModel.items[self.mDoubleGoodsId].name))
    			elseif ownDoubleNum <= 0 then
    				self.mIsUseDouble = false
    				self.mDoubleCheckout:setCheckState(self.mIsUseDouble)
    				ui.showFlashView(TR("%s不足", GoodsModel.items[self.mDoubleGoodsId].name))
    			else
    				self.mIsUseDouble = true
    			end
    		else
    			self.mIsUseDouble = false
    		end
    	end
    })
    self.mDoubleCheckout:setAnchorPoint(cc.p(0, 0.5))
    self.mDoubleCheckout:setPosition(20, 1055)
    self.mParentLayer:addChild(self.mDoubleCheckout)
    -- 双倍令剩余数量
    self.mDoubleNumLabel = ui.newLabel({
    	text = TR("剩余数量：%s", ownDoubleNum),
    	outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
    })
    self.mDoubleNumLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mDoubleNumLabel:setPosition(65, 1020)
    self.mParentLayer:addChild(self.mDoubleNumLabel)

    self.mDoubleCheckout:setCheckState(self.mIsUseDouble)
    self.mDoubleCheckout:setVisible(self.mIsShowDouble)
    self.mDoubleNumLabel:setVisible(self.mIsShowDouble)

    -- 创建列表控件
	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(600, 640))
    self.mListView:setItemsMargin(10)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(cc.p(320, 990))
    self.mParentLayer:addChild(self.mListView)
    -- 空提示
    self.mEmptyHint = ui.createEmptyHint(TR("没有满足要求的侠客"))
	self.mEmptyHint:setPosition(320, 568)
	self.mParentLayer:addChild(self.mEmptyHint)
	self.mEmptyHint:setVisible(false)

	-- 创建道具列表控件
	self.mGoodsListView = ccui.ListView:create()
    self.mGoodsListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.mGoodsListView:setBounceEnabled(true)
    self.mGoodsListView:setContentSize(cc.size(600, 120))
    self.mGoodsListView:setItemsMargin(10)
    self.mGoodsListView:setAnchorPoint(cc.p(0.5, 1))
    self.mGoodsListView:setPosition(cc.p(320, 315))
    self.mParentLayer:addChild(self.mGoodsListView)
    -- 空提示
    self.mGoodsEmptyHint = ui.newLabel({
    	text = TR("没有可使用道具"),
    	color = Enums.Color.eWhite,
    	outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
    })
	self.mGoodsEmptyHint:setPosition(320, 260)
	self.mParentLayer:addChild(self.mGoodsEmptyHint)
	self.mGoodsEmptyHint:setVisible(false)

    -- 返回按钮
    local mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function (pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(mCloseBtn)

    -- 确定按钮
    local confirmBtn = ui.newButton({
        normalImage = "c_28.png",
        text = self.mBtnTitle or TR("确定"),
        position = cc.p(450, 140),
        clickAction = function (pSender)
        	if #self.mSelectList < self.mHeroMinNum then
        		ui.showFlashView(TR("至少需要%s侠客", self.mHeroMinNum))
        		return
        	end

        	if self.mCallback then
        		self.mCallback(self.mSelectList, self.mGoodsList, self.mIsUseDouble)
        	end

        	LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(confirmBtn)

    -- 一键选择
    local oneKeyBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("一键选择"),
        position = cc.p(190, 140),
        clickAction = function (pSender)
        	self:onekeySelect()
        end
    })
    self.mParentLayer:addChild(oneKeyBtn)

    -- 刷新列表
    self:refreshList()
    self:refreshGoodsList()
end

-- 刷新列表
function SectPalaceSelectHeroLayer:refreshList()
	self.mListView:removeAllChildren()
	self.mEmptyHint:setVisible(false)

	if next(self.mHeroList) then
		for _, heroInfo in pairs(self.mHeroList) do
			local heroItem = self:createItem(heroInfo)
			self.mListView:pushBackCustomItem(heroItem)
		end
	else
		self.mEmptyHint:setVisible(true)
	end
end

-- 刷新道具列表
function SectPalaceSelectHeroLayer:refreshGoodsList()
	self.mGoodsListView:removeAllChildren()
	self.mGoodsEmptyHint:setVisible(false)

	local goodsList = require("sect.SectPalacePlunderLayer").getGoodsList()
	if next(goodsList) then
		for _, goodModelId in pairs(goodsList) do
			local goodsItem = self:createGoodsItem(goodModelId)
			self.mGoodsListView:pushBackCustomItem(goodsItem)
		end
	else
		self.mGoodsEmptyHint:setVisible(true)
	end
end

-- 创建侠客列表项
function SectPalaceSelectHeroLayer:createItem(heroInfo)
	local cellSize = cc.size(self.mListView:getContentSize().width, 120)
	local cellItem = ccui.Layout:create()
	cellItem:setContentSize(cellSize)

	-- 背景
	local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width - 20, cellSize.height))
	tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
	cellItem:addChild(tempSprite)

	-- 头像
	local tempCard = CardNode:create({allowClick = true,})
	tempCard:setPosition(80, cellSize.height / 2)
	tempCard:setHero(heroInfo, {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eStep, CardShowAttr.eMedicine})
	cellItem:addChild(tempCard)

	-- 人物的模型数据
	local tempModel = HeroModel.items[heroInfo.ModelId]
	local illusionModel = IllusionModel.items[heroInfo.IllusionModelId]
	local quality = illusionModel and illusionModel.quality or tempModel.quality

	-- 名字
	local heroName, heroStep = ConfigFunc:getHeroName(heroInfo.ModelId, {heroStep = heroInfo.Step, IllusionModelId = heroInfo.IllusionModelId, heroFashionId = heroInfo.CombatFashionOrder})
	if heroStep > 0 then
        heroName = heroName .. "+".. heroStep
    end
	local nameLabel = ui.newLabel({
		text = heroName,
		color = Utility.getQualityColor(quality, 1),
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
	})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(150, cellSize.height - 25)
	cellItem:addChild(nameLabel)

	-- 资质
	local qualityLabel = ui.newLabel({
		text = TR("资质:%s%d", Enums.Color.eBlackH, quality),
		color = Enums.Color.eBrown,
	})
	qualityLabel:setAnchorPoint(cc.p(0, 0.5))
	qualityLabel:setPosition(150, cellSize.height * 0.5)
	cellItem:addChild(qualityLabel)

	-- 淬体、经脉等级
	local currRebornNum = heroInfo.RebornId and RebornLvModel.items[heroInfo.RebornId].rebornNum or 0 -- 当前转生次数
	local quenchLabel = ui.newLabel({
		text = TR("淬体:%s%d重    %s经脉:%s%s重", Enums.Color.eBlackH, heroInfo.QuenchStep or 0, Enums.Color.eBrownH, Enums.Color.eBlackH, currRebornNum),
		color = Enums.Color.eBrown,
	})
	quenchLabel:setAnchorPoint(cc.p(0, 0.5))
	quenchLabel:setPosition(150, 25)
	cellItem:addChild(quenchLabel)

	-- 复选框
	local checkbox = ui.newCheckbox({
		callback = function (status)
			cellItem:selectCallback(status)
		end,
	})
	checkbox:setPosition(500, cellSize.height * 0.5)
	cellItem:addChild(checkbox)
	cellItem.checkbox = checkbox

	-- 选择回调
	cellItem.selectCallback = function (target, status)
		if status then
			if #self.mSelectList >= self.mHeroMaxNum then	-- 已达上限
				target.checkbox:setCheckState(false)
				ui.showFlashView(TR("已达选择数量上限"))
			else
				target.checkbox:setCheckState(true)
				table.insert(self.mSelectList, heroInfo.Id)
			end
		else
			local index = table.indexof(self.mSelectList, heroInfo.Id)
			table.remove(self.mSelectList, index)
		end
	end

	-- 当前状态回调
	cellItem.getStatus = function (target)
		return target.checkbox:getCheckState()
	end

	return cellItem
end

function SectPalaceSelectHeroLayer:createGoodsItem(goodModelId)
	local cellSize = cc.size(120, self.mGoodsListView:getContentSize().height)
	local cellItem = ccui.Layout:create()
	cellItem:setContentSize(cellSize)

	local goodModel = GoodsModel.items[goodModelId]
	-- 创建显示图片
    local card = CardNode.createCardNode({
    	resourceTypeSub = Utility.getTypeByModelId(goodModel.ID),
		modelId = goodModel.ID,
		num = GoodsObj:getCountByModelId(goodModel.ID),
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eNum},
        -- allowClick = false,
    })
    card:setPosition(cellSize.width*0.5, cellSize.height*0.5+10)
    cellItem:addChild(card)

    -- 复选框
	local checkbox = ui.newCheckbox({
		callback = function (status)
			if status then
				local index = table.indexof(self.mGoodsList, goodModelId)
				if not index then
					table.insert(self.mGoodsList, goodModelId)
				end
			else
				local index = table.indexof(self.mGoodsList, goodModelId)
				table.remove(self.mGoodsList, index)
			end
		end,
	})
	checkbox:setPosition(cellSize.width-7, cellSize.height-17)
	cellItem:addChild(checkbox)

	return cellItem
end

-- 一键选择
function SectPalaceSelectHeroLayer:onekeySelect()
	for _, cellItem in ipairs(self.mListView:getItems()) do
		local status = cellItem:getStatus()
		if #self.mSelectList < self.mHeroMaxNum then
			if not status then
				cellItem:selectCallback(true)
			end
		else
			break
		end
	end
end

-- 请求服务器，获取所有已开启的福利多多活动的信息
function SectPalaceSelectHeroLayer:requestGetTimedActivityInfo()
    HttpClient:request({
        moduleName = "TimedInfo",
        methodName = "GetTimedActivityInfo",
        callbackNode = self,
        callback = function (data)
            -- dump(data, "requestGetTimedActivityInfo")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            for i,v in ipairs( data.Value.TimedActivityList) do
                if v.ActivityEnumId == TimedActivity.eSalesSectPalace then -- 有地宫翻倍活动
                	self.mIsDoubleActivity = true
                    -- 创建地宫双倍气泡
                    self.mDoubleCheckout:setCheckState(false)
                    self.mIsUseDouble = false
                    break
                end
            end
        end
    })
end

return SectPalaceSelectHeroLayer