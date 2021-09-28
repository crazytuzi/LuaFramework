--[[
文件名：MysteryShopSelectLayer.lua
描述： 黑市选择复制物品界面
创建人：lengjiazhi
创建时间：2016.9.27
--]]

local MysteryShopSelectLayer = class("MysteryShopSelectLayer",function (params)
	return display.newLayer()
end)

local SelectTag = {
	eHero = 1,
	-- eDebris = 3,
	eGoods = 2,
	}
--构造函数
--[[
--参数：
	tag:初始页签
	isHide:是否隐藏上阵人物
	callback:选择回调函数 原型为callback(slectLayerObj, data)
--]]
function MysteryShopSelectLayer:ctor(params)
	
	self.mOriginalTag = params.tag or SelectTag.eHero

	self.mPages = {}
	self.mCurTag = nil
	self.mIsHide = params.isHide or false
	self.mCallback = params.callback
	--元素父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	--顶部公共控件
	self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eHeroCoin, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

	--背景图
	local bgSprite = ui.newSprite("c_34.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

    -- 子背景
    -- local subBgSprite = ui.newScale9Sprite("c_124.png", cc.size(640, 142))
    -- subBgSprite:setAnchorPoint(cc.p(0.5, 1))
    -- subBgSprite:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.5, self.mParentLayer:getContentSize().height))
    -- self.mParentLayer:addChild(subBgSprite)

	--提示文字
	self.mTipLabel = ui.newLabel({
		text = TR("请选择要复制的侠客"),
		size = 22,
		color = Enums.Color.eNormalYellow,
		outlineColor = Enums.Color.eBlack,
		})
	self.mTipLabel:setPosition(320, 960)
	self.mParentLayer:addChild(self.mTipLabel,5)

	--隐藏按钮
	self.mCheckBtn = ui.newCheckbox({
		normalImage = "c_60.png",
        selectImage = "c_61.png",
        text = TR("隐藏已上阵侠客"),
        fontSize = 22,
        outlineColor = Enums.Color.eBlack,
        callback = function (isSelect)
        	self.mIsHide = isSelect
        	local tempData
        	if self.mIsHide then
	        	tempData = HeroObj:getHeroList({notInFormation = true})
        	else
        		tempData = HeroObj:getHeroList()
        	end
			local originalData = {}
			for i,data in ipairs(tempData) do
				local colorLv = Utility.getColorLvByModelId(data.ModelId)
				if colorLv == 5 then
					table.insert(originalData, data)
				end
			end
			self:sortHero(originalData)
    		self:addpage(self.mOriginalTag, originalData)
        end
		})
	self.mCheckBtn:setPosition(110, 930)
	self.mParentLayer:addChild(self.mCheckBtn)

	--空白提示
	self.mEmptyHintSprite, self.mEmptyHintLabel = ui.createEmptyHint(TR("暂时没有可以复制的侠客"))
    self.mEmptyHintSprite:setPosition(320, 520)
    self.mParentLayer:addChild(self.mEmptyHintSprite)
    self.mEmptyHintSprite:setVisible(false)
		
	--页签
	self:createTabView()

	--返回键
	local button = ui.newButton({
		normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function()
            LayerManager.removeLayer(self)
        end
		})
	self.mParentLayer:addChild(button)

	self:changePage(self.mOriginalTag)
end

--创建Tab页签
function MysteryShopSelectLayer:createTabView()

	local tabInfo = {
		[1] = {
			text = TR("侠客"),
			tag = SelectTag.eHero,
		},
		[2] = {
			text = TR("道具"),
			tag = SelectTag.eGoods,
		},
		-- [3] = {
		-- 	text = TR("道具"),
		-- 	tag = SelectTag.eGoods,
		-- },
	}

	local tabView = ui.newTabLayer({
		btnInfos = tabInfo,
		onSelectChange = function (tag)
			self:changePage(tag)
		end,
		})
	tabView:setPosition(Enums.StardardRootPos.eTabView)
	self.mParentLayer:addChild(tabView)
	self.mTab = tabView
end

--切换分页
function MysteryShopSelectLayer:changePage(tag)
	if self.mTab == nil then
		return
	end
	--切换页面时的控件改变
	if tag == SelectTag.eHero then
		self.mCheckBtn:setVisible(true)
		self.mTipLabel:setString(TR("请选择要复制的侠客"))
		self.mEmptyHintLabel:setString(TR("暂时没有可以复制的侠客"))
	else
		self.mCheckBtn:setVisible(false)
		self.mTipLabel:setString(TR("请选择要复制的道具"))
		self.mEmptyHintLabel:setString(TR("暂时没有可以复制的道具"))
	end

	local oldTag = self.mCurTag
	--隐藏旧分页
	if self.mPages[oldTag] ~= nil then
		self.mPages[oldTag]:setVisible(false)
	end

	--转到新分页
	self.mCurTag = tag
	local page = self.mPages[tag]
	if page ~= nil then
		page:setVisible(true)

		if #page.itemsData == 0 then
			self.mEmptyHintSprite:setVisible(true)
		else
			self.mEmptyHintSprite:setVisible(false)
		end
	else
		if tag == SelectTag.eHero then
			local tempData = HeroObj:getHeroList()
			local originalData = {}
			for i,data in ipairs(tempData) do
				local colorLv = Utility.getColorLvByModelId(data.ModelId)
				if colorLv == 5 then
					data.Num = 1
					table.insert(originalData, data)
				end
			end
			self:sortHero(originalData)
			self:addpage(tag, originalData)
		-- elseif tag == SelectTag.eDebris then
		-- 	local originalData = GoodsObj:getHeroDebrisList()
		-- 	self:addpage(tag, originalData)
		elseif tag == SelectTag.eGoods then
			local tempData = GoodsObj:getPropsList()
			local originalData = {}
			for i,data in ipairs(tempData) do
				if data.ModelId == 16050001 then
					table.insert(originalData, data)
				end
			end
			self:addpage(tag, originalData)
		end

	end
end

--排序
function MysteryShopSelectLayer:sortHero(data)
	table.sort(data, function (a, b)

		--是否已上阵
		local isInA = FormationObj:heroInFormation(a.Id)
		local isInB = FormationObj:heroInFormation(b.Id)
		if isInA and not isInB then
			return true
		end
		if not isInA and isInB then
			return false
		end

		--缘分
		local relationA = FormationObj:getRelationStatus(a.ModelId, ResourcetypeSub.eHero)
		local relationB = FormationObj:getRelationStatus(b.ModelId, ResourcetypeSub.eHero)
		if relationA ~= relationB then
			return relationA > relationB
		end
		-- 比较资质
		local qualityA = HeroModel.items[a.ModelId].quality
		local qualityB = HeroModel.items[b.ModelId].quality
		if qualityA ~= qualityB then
			return qualityA > qualityB
		end

		-- 比较进阶数
		if a.Step ~= b.Step then
			return a.Step > b.Step
		end

		-- 比较等级
		if a.Lv ~= b.Lv then
			return a.Lv > b.Lv
		end

		-- Todo

		return a.ModelId > b.ModelId
	end)
end

--添加分页
function MysteryShopSelectLayer:addpage(tag, itemsData)	
	--列表
	local listView = ccui.ListView:create()
	listView:setDirection(ccui.ScrollViewDir.vertical)
	listView:setBounceEnabled(true)
	listView:setContentSize(620, 750)
	listView:setGravity(ccui.ListViewGravity.centerVertical)
	listView:setItemsMargin(10)
	listView:setAnchorPoint(0.5, 0.5)	
	listView:setScrollBarEnabled(false)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mParentLayer:addChild(listView)

    if tag == SelectTag.eHero then
    	listView:setPosition(320, 520)
	elseif tag == SelectTag.eGoods then
		listView:setPosition(320, 560)
	end
	--创建条目
    for i, data in ipairs(itemsData) do
    	local item 
    	if tag == SelectTag.eHero then
    		item = self:heroItemView(tag, data)
    	elseif tag == SelectTag.eGoods then
    		item = self:goodItemView(tag, data)
    	end
    	listView:pushBackCustomItem(item)
    end
    listView:jumpToTop()

    if #itemsData == 0 then
    	self.mEmptyHintSprite:setVisible(true)
	else
		self.mEmptyHintSprite:setVisible(false)
    end
 	self:removePage(tag)
    self.mPages[tag] = listView
    listView.itemsData = itemsData

end

--删除旧分页
function MysteryShopSelectLayer:removePage(tag)
	if self.mPages[tag] ~= nil then
		self.mParentLayer:removeChild(self.mPages[tag])
        self.mPages[tag] = nil
    end
end

--创建道具条目
function MysteryShopSelectLayer:goodItemView(tag, data)

	--容器
	local layout = ccui.Layout:create()
	layout:setContentSize(620, 120)

	--背景
	local sprite = ui.newScale9Sprite("c_18.png",cc.size(620, 120))
	sprite:setAnchorPoint(0, 0)
	layout:addChild(sprite)

	--头像
	local heroCard = CardNode.createCardNode({
		resourceTypeSub = Utility.getTypeByModelId(data.ModelId),
		modelId = data.ModelId,
		cardShowAttrs = {CardShowAttr.eBorder},
		allowClick = true,
		})
	heroCard:setPosition(60, 60)
	layout:addChild(heroCard)

	--名字
	local tempStr = Utility.getGoodsName(Utility.getTypeByModelId(data.ModelId), data.ModelId)
	local label = ui.newLabel({
		text = TR(tempStr),
		size = 24,
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 0.5)
		})
	label:setPosition(120, 85)
	layout:addChild(label)

	--选择按钮
	local chooseBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("选择"),
		clickAction = self:btnCallfun(tag, data)
		})
	chooseBtn:setPosition(520, 60)
	layout:addChild(chooseBtn)
	if isInFormation or isInMateHero then
		chooseBtn:setEnabled(false)
	end

	--数量
	if tag == SelectTag.eGoods then
		local label = ui.newLabel({
			text = TR("数量: %s", data.Num),
			size = 22,
			color = Enums.Color.eBlack,
			anchorPoint = cc.p(0, 0.5),
			})
		label:setPosition(230, 30)
		if tag == SelectTag.eGoods then
			label:setPosition(120, 30)
		end
		layout:addChild(label)
	end
	--碎片资质
	-- if tag == SelectTag.eDebris then
	-- 	local label = ui.newLabel({
	-- 		text = TR("资质: %s", GoodsModel.items[data.ModelId].quality),
	-- 		size = 22,
	-- 		color = Enums.Color.eNormalWhite,
	-- 		anchorPoint = cc.p(0, 0.5),
	-- 		})
	-- 	label:setPosition(120, 30)
	-- 	layout:addChild(label)
	-- end

	return layout
end

--创建人物条目
function MysteryShopSelectLayer:heroItemView(tag, data)
	local isInFormation ,isInMateHero = FormationObj:heroInFormation(data.Id)
	local relationStatus = FormationObj:getRelationStatus(data.ModelId, Utility.getTypeByModelId(data.ModelId))
	local relationList = {
			[Enums.RelationStatus.eIsMember] = TR("缘份"),     -- 推荐
            [Enums.RelationStatus.eTriggerPr] = TR("可激活"),   -- 缘分
        } 
    local isSameHero = FormationObj:haveSameHero(data.ModelId)

    --容器
	local layout = ccui.Layout:create()
	layout:setContentSize(620, 120)

	--背景
	local sprite = ui.newScale9Sprite("c_18.png",cc.size(620, 120))
	sprite:setAnchorPoint(0, 0)
	layout:addChild(sprite)

	--头像
	local heroCard = CardNode.createCardNode({
		resourceTypeSub = Utility.getTypeByModelId(data.ModelId),
		modelId = data.ModelId,
		cardShowAttrs = {CardShowAttr.eBorder},
		allowClick = true,
		})
	heroCard:setPosition(60, 60)
	layout:addChild(heroCard)

	--名字
	local tempStr = Utility.getGoodsName(Utility.getTypeByModelId(data.ModelId), data.ModelId)
	local label = ui.newLabel({
		text = TR(tempStr),
		size = 24,
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 0.5)
		})
	label:setPosition(120, 85)
	layout:addChild(label)

	--选择按钮
	local chooseBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("选择"),
		clickAction = self:btnCallfun(tag, data)
		})
	chooseBtn:setPosition(520, 60)
	layout:addChild(chooseBtn)
	if isInFormation or isInMateHero then
		chooseBtn:setEnabled(false)
	end

	--资质
	local label = ui.newLabel({
		text = TR("资质: %s", HeroModel.items[data.ModelId].quality),
		size = 22,
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 0.5)
		})
	label:setPosition(120, 30)
	layout:addChild(label)

	--等级
	local label = ui.newLabel({
		text = TR("等级: %s", data.Lv),
		size = 22,
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 0.5),
		})
	label:setPosition(230, 30)
	layout:addChild(label)

	--进阶数
	local tempStr = Utility.getGoodsName(Utility.getTypeByModelId(data.ModelId), data.ModelId)
	local label = ui.newLabel({
		text = string.format("+ %s", data.Step),
		size = 22,
		color = Enums.Color.eBlack,
		anchorPoint = cc.p(0, 0.5),
		})
	label:setPosition(120 + string.len(tempStr) / 3 * 28, 85)
	layout:addChild(label)
	label:setVisible(data.Step > 0)

	--已上阵标识
	if isInFormation or isInMateHero then
		heroCard:setCardData({
			resourceTypeSub = Utility.getTypeByModelId(data.ModelId),
			modelId = data.ModelId,
			cardShowAttrs = {CardShowAttr.eBorder,CardShowAttr.eBattle},
		})
	end

	--缘分标识
	if not isInFormation and isSameHero == nil then
		if relationStatus == Enums.RelationStatus.eIsMember then
			heroCard:createStrImgMark("c_57.png", relationList[relationStatus])
		elseif relationStatus == Enums.RelationStatus.eTriggerPr then
			heroCard:createStrImgMark("c_58.png", relationList[relationStatus])
		end
	end

	--相同人物上阵文字
	if not isInFormation and isSameHero ~= nil then
		local label = ui.newLabel({
			text = TR("[相同侠客上阵]"),
			size = 21,
			color = Enums.Color.eBlack,
			})
		label:setPosition(520, 90)
		layout:addChild(label)
		chooseBtn:setPosition(520,50)
	end
	return layout
end

--按钮回调函数
function MysteryShopSelectLayer:btnCallfun(tag, data)
	local callfun 
	if tag == SelectTag.eHero then
		callfun = function ()
			self.mCallback(self, data)
		end
	-- elseif tag == SelectTag.eDebris then
	-- 	callfun = function ()
	-- 		print("heroCALLFUN")
	-- 	end
	elseif tag == SelectTag.eGoods then
		local maxNum = data.Num <= 200 and data.Num or 200
		callfun = function ()
			local countLayer = MsgBoxLayer.addUseGoodsCountLayer(
				TR("复制"),
				data.ModelId, maxNum,
				function (selCount)
					local tempData = {}
					for i,v in pairs(data) do
						if i == "Num" then
							tempNum = selCount
							tempData[i] = tempNum
						else
							tempData[i] = v
						end 		
					end
	    			self.mCallback(self, tempData)
				end
			)
		end		
	end
	return callfun
end

return MysteryShopSelectLayer